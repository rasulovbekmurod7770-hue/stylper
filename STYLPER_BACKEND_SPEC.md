# Stylper backend — build spec

Hand this file to Claude Code together with `supabase/migrations/0001_stylper_schema.sql`.
The schema is written and tested. This spec says how to wire it up and what to build around it.

## 1. What we're building

Stylper is two apps on one backend:

- **Consumer app (Flutter):** onboarding (sign in/up, profile setup, "Dress like you" quiz), Home feed (For you / Following, style chips, Trending in Tashkent), outfit posts with items tagged on the photo, product pages, search, profile (posts, saved, style boards, Style DNA), wardrobe, 4-step posting flow, notifications.
- **Brand workspace:** brand page/showroom, catalog with variants and stock per store, community posts featuring the brand's items, content-rights requests, reward vouchers, analytics.

Launch target: about 5,000 users in Tashkent. Prices are in UZS. There's no in-app payment; "Buy Now" opens the brand's website.

## 2. Stack (decided)

| Layer | Choice | Notes |
|---|---|---|
| Database, auth, realtime | **Supabase Pro** (Postgres) | Auth providers: email + password, Google, Apple |
| Server logic | **Postgres functions (RPC)** + **Supabase Edge Functions (TypeScript/Deno)** | Business rules live in SQL where possible |
| Images | **Cloudflare R2** + a custom domain (TODO: not decided) behind Cloudflare cache | No image bytes in Postgres or Supabase Storage |
| App | Flutter with `supabase_flutter` | Compress images on device |
| Scheduled jobs | `pg_cron` (enable in Supabase dashboard) | Nightly rollup |

## 3. Repo layout

```
stylper-backend/
  STYLPER_BACKEND_SPEC.md          ← this file
  supabase/
    config.toml                    ← from `supabase init`
    migrations/
      0001_stylper_schema.sql      ← DONE: tables, RLS, triggers, RPCs
      0002_handles.sql             ← DONE: usernames, brand slugs and reserved names share one namespace
      0003_style_keys.sql          ← DONE: styles are fixed keys (see §4)
      0004_tag_limit.sql           ← DONE: at most 10 tags per photo (see "Layered outfits", §7)
      0005_cron.sql                ← TODO: schedule nightly job
    seed.sql                       ← DONE: demo data for local dev only (loaded by `supabase db reset`; never a migration)
    functions/
      create-upload/index.ts       ← DONE
      finalize-upload/index.ts     ← DONE
      _shared/r2.ts                ← DONE: R2 via aws4fetch (presigned PUTs, reads, deletes)
      _shared/http.ts              ← DONE: CORS, JSON errors with the app's error codes
      _shared/supabase.ts          ← DONE: service-role client, caller check
      .env.example                 ← local secrets template (.env is gitignored)
    tests/
      00_supabase_stub.sql         ← plain-Postgres stand-in for Supabase auth (tests only)
      01_rls_and_workflows.sql     ← DONE: behaviour tests, must stay green
```

## 4. Data model at a glance

30 tables in 6 groups. The migration is the source of truth. Read its comments before changing anything.

1. **People:** `profiles` (public), `profile_private` (gender, birth year, height, weight, notification settings, owner-only), `style_quiz_answers`, `follows`, `blocks`
2. **Media:** `media`, which holds pointers to R2 objects (`full_key`, `thumb_key`, size, blurhash, status)
3. **Brands & catalog:** `brands`, `brand_members` (owner/admin/editor), `brand_follows`, `stores`, `products`, `product_variants`, `product_images`, `store_stock`
4. **Posts & engagement:** `posts`, `post_images`, `post_tags` (x/y % on the photo → product, wardrobe item or label), `likes`, `saves`, `comments` (one reply level), `style_boards`, `board_posts`, `wardrobe_items`
5. **Brand ↔ creator:** `brand_features`, `rights_requests`, `rewards`
6. **Ops:** `notifications`, `reports`, `events` (raw analytics), `brand_daily_stats`

**Rules that must not be broken:**
- Clients never write counters (`likes_count`, `followers_count`, `styled_count`, …). Triggers maintain them, and column grants block clients.
- Clients never insert into `media`, `events`, `notifications`, `brand_daily_stats`, or `brands`.
- `can_view_post()` is the single definition of who can see a post. Reuse it; don't copy its logic.
- Height and weight live only in `profile_private`, which only its owner can read.
- Styles are fixed keys, never display words: `minimal`, `casual`, `streetwear`, `neutral`, `oversized`, `smart_casual` (`style_keys()`). `posts.styles` and `profiles.style_dna` reject anything else (`0003_style_keys.sql`), so "For you" can match a post's styles against the viewer's Style DNA. Apps show translated labels.
- Usernames and brand slugs are one namespace: neither may equal the other or a reserved name (`stylper`, `admin`, `support`, `help`, `api`, `www`, `settings`). Triggers from `0002_handles.sql` enforce it and raise `unique_violation`, the same error as a taken username.
- When a creator switches **Allow brands to feature this** on, `posts.brand_consent_at` is stamped with the time. Brands can only feature posts where it's on and that tag one of their products.

## 5. Security model (RLS summary)

| Who | Can |
|---|---|
| Guest (`anon`) | Read public posts, profiles, brands, catalog; call `feed_for_you`, `trending_in_city`, `search_all`, `log_event`. Nothing else. |
| Signed-in user | Everything a guest can, plus write their own posts, tags, likes, saves, comments, follows, boards, wardrobe, private profile; see followers-only posts of people they follow; answer rights requests sent to them; see their own vouchers and notifications |
| Brand editor | Their brand's products, variants, images, stores, stock; feature consenting posts; send rights requests and rewards; read their brand's stats |
| Brand owner | Plus manage team members |
| Stylper admin | Uses the service role (dashboard / Edge Functions): creates brands, verifies them, handles reports, sets `is_hidden` |

Blocking someone hides content both ways and removes follows in both directions.

## 6. Image pipeline

Goal: fast feeds, near-zero bandwidth cost, and the API server never handles image bytes.

**On the device (Flutter):**
1. User picks or takes a photo.
2. Make two WebP files with `flutter_image_compress`: **full** (longest side 1080px, quality ~80) and **thumb** (longest side 400px, quality ~75). Strip EXIF metadata, because it contains GPS location.
3. Compute a blurhash from the thumb (`blurhash_dart`).

**Edge Function `create-upload`** (POST, requires a signed-in user):
- Input: `{ kind: 'post'|'avatar'|'wardrobe'|'product'|'brand', brand_id?, width, height, bytes, blurhash }`
- Checks: user is signed in; if `kind` is `product` or `brand`, the user is a member of `brand_id`; `bytes` ≤ 2 MB; at most 30 pending uploads per user per hour.
- Creates keys: `{kind}/{user_or_brand_id}/{uuid}_1080.webp` and `_400.webp`.
- Inserts a `media` row with status `pending` (service role).
- Returns `{ media_id, full_put_url, thumb_put_url }`. These are presigned R2 PUT URLs valid for 10 minutes with `Content-Type: image/webp`.

**App uploads** both files directly to R2 with HTTP PUT.

**Edge Function `finalize-upload`** (POST `{ media_id }`):
- Checks that the caller owns the row and it's still pending.
- Reads the first 12 bytes of both objects in R2 (a ranged GET: what a HEAD gives, plus the `RIFF····WEBP` signature); checks they exist, the content type is `image/webp`, and the size is under the limit. A missing file answers `upload_incomplete` (the row stays pending); a wrong one deletes both files and sets `status = 'rejected'` (`upload_rejected`).
- Sets `status = 'ready'` (and `bytes` to the stored size), returning `{ media_id, full_url, thumb_url, width, height, blurhash }`. Finalizing a ready row again returns the same, so retries are safe. Only ready media can be attached to posts, avatars or products; RLS enforces this.

Both functions check the caller's token themselves (`verify_jwt = false`), answer CORS preflights, and give R2 10 seconds per request. The rate limit counts uploads still pending from the last hour.

**Serving:** `{IMG_PUBLIC_BASE}/{key}`: the dev bucket's r2.dev URL locally; in production a custom domain (TODO: not decided). Feeds and grids use `thumb_key`; the post detail view uses `full_key`. Use a Cloudflare cache rule with a 1-year TTL; keys never change because every upload gets a new UUID.

**Cleanup:** pending rows older than 1 day are deleted by the nightly job. A weekly Edge Function should also delete R2 objects that no `media` row points to.

**R2 secrets** for Edge Functions: `R2_ACCOUNT_ID`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`, `R2_BUCKET`, `IMG_PUBLIC_BASE`. Locally they're in `supabase/functions/.env` (dev bucket). In the cloud they're set at deploy time with `npx supabase secrets set --env-file supabase/functions/.env.production.local` (gitignored), for the `stylper-images` bucket and its own token.

- [ ] **TODO: production `IMG_PUBLIC_BASE`.** The production bucket has no public URL yet and its custom domain isn't decided. `create-upload` fails until it's set, and the app's env files need the same value.

## 7. Screen → API map

Use `supabase_flutter`. Table reads go through PostgREST (`.from('table').select(...)`), and RLS filters them automatically. RPCs are `.rpc('name', params: {...})`.

| Screen (prototype) | Calls |
|---|---|
| Sign in / Create account / Forgot password | Supabase Auth: `signInWithPassword`, `signUp`, `signInWithIdToken` (Google, Apple), `resetPasswordForEmail`. **Apple sign-in is required on iOS** because Google sign-in is offered. |
| Profile setup | `update profiles (username, display_name)`, `update profile_private (gender, birth_year, height_cm, weight_kg)`. All optional except username. |
| Dress like you quiz | `insert style_quiz_answers`, then `update profiles set style_dna = ..., onboarded_at = now()` |
| Home · For you + style chips | `rpc feed_for_you(p_style, p_offset, p_limit)` |
| Home · Following | `rpc feed_following(p_before, p_limit)`, using keyset pagination on `created_at` |
| Home · Trending in Tashkent / Search grid | `rpc trending_in_city('Tashkent')` |
| Post detail | `posts` + `post_images(media(*))` + `post_tags(*, products(*, brands(name)))` + author profile in one PostgREST select; `log_event('post_view')` |
| Tap a tag dot | `log_event('tag_tap', post, product)` |
| Like / save / comment | insert/delete `likes`, `saves`; insert `comments`; `rpc delete_comment(id)` |
| Product page | `products` + `product_variants` + `product_images` + "See it on people" (posts whose `post_tags.product_id` = this product); `log_event('product_view')` |
| Buy Now / Shop | open `external_url`; `log_event('shop_click')` |
| Add to wardrobe | insert `wardrobe_items (source 'from_post' or 'from_product')`; `log_event('wardrobe_add')` |
| Search | `rpc search_all(q)` (as you type, 250 ms debounce, minimum 2 characters) |
| Profile | `profiles` + own `posts`; Saved tab = `saves` join `posts`; Style Boards = `style_boards` + `board_posts` |
| My Wardrobe | `wardrobe_items` grouped by `category` |
| New post 1–4 | create-upload → PUT ×2 → finalize-upload → `insert posts` → `insert post_images` → `insert post_tags` (x/y in % of the image). Do this in one flow; if a step fails, delete the half-made post. |
| Notifications (heart icon) | `notifications` ordered by `created_at desc`; Realtime subscription on `notifications` filtered to `recipient_id`; `rpc mark_notifications_read()` |
| Settings | `update profile_private` toggles, `update profiles set is_private`, `insert blocks`, `insert reports` |
| Brand page (COS) | `brands` + `products` ordered by `styled_count` (Most-Styled Pieces) + `brand_features` (Styled by Community); `log_event('brand_view')`; follow = `insert brand_follows` |
| Brand product detail | variants + `store_stock` + `stores` for "available in store" |
| Brand · Create product | insert `products`, `product_variants`, `product_images` (media kind `product`) |
| Brand · Community hub | posts tagging the brand's products, newest first; feature = `insert brand_features` |
| Brand · Rights request | `insert rights_requests`; creator answers with `rpc respond_rights_request(id, accept)` or later `rpc revoke_rights(id)` |
| Brand · Reward | `insert rewards` |
| Brand · Overview (analytics) | `brand_daily_stats` for the last 7/30 days |
| Delete my post | `rpc delete_post(id)`. This also removes brand features and revokes reuse rights. |

### Layered outfits (tagging)

People wear layers (a jacket over a t-shirt, a scarf over a coat) and must be able to tag each layer, so tags often sit close together on the photo.

- Every tag has the category of its product or wardrobe item (`item_category_t`); label-only tags count as `other`. The tag picker and the wardrobe offer every category, including **Outerwear** and **Accessories**.
- **At most 10 tags per photo** (per `post_image_id`), enforced in the database by `0004_tag_limit.sql`. The app stops at 10 as well.
- **Outfit details** (the list of tagged items on the post) is ordered outside-in: outerwear, tops, bottoms, shoes, accessories, then `other`; within a category, in the order they were tagged.
- **Close-together dots** stay readable and tappable: no dot hides another and no labels overlap. Posts with more than 4 tags start with tags hidden behind a count badge; tapping the photo shows or hides them.

## 8. Jobs

`0005_cron.sql`:
```sql
select cron.schedule('nightly-rollup', '15 19 * * *', $$select rollup_brand_stats()$$);  -- 00:15 Tashkent time
```
It rolls up yesterday's events (Tashkent calendar day), deletes events older than 90 days, expires rights and vouchers, and cleans up abandoned uploads.

## 9. Things deliberately left for later

- Rate limiting for likes, comments and follows. Start with a simple per-user counter in the Edge Functions if spam appears. Supabase also has built-in Auth rate limits.
- Push notifications via FCM. Add an Edge Function triggered by a database webhook on `notifications`.
- A smarter "For you" ranking. The current SQL is simple and explainable; revisit after you have real engagement data.
- Moving analytics to a separate store. Not needed below roughly 1M events per day.
- An admin panel. Use the Supabase dashboard plus saved SQL queries for reports at launch.

## 10. Build order (each step should be shippable)

1. `supabase init`, link the project, apply 0001, enable Google + Apple auth. **Done when:** tests pass locally (see §11) and a Flutter user can sign up and see their profile row.
2. R2 bucket + custom domain + `create-upload` / `finalize-upload`. **Done when:** an avatar upload works end to end and loads from the bucket's custom domain (TODO: not decided). *(2026-10-23: works end to end locally against the dev bucket's r2.dev URL, from Chrome; the custom domain and the cloud deployment come later.)*
3. Posting flow + post detail + tags. **Done when:** a post with 2 tagged items appears on another account's feed with working tag dots, and a layered outfit (jacket over a t-shirt, tagged separately) shows both tags readable and tappable.
4. Feed, likes, saves, comments, follows, notifications (Realtime). **Done when:** counters and notifications update live on a second device.
5. Product pages, search, wardrobe, boards.
6. Brand workspace: catalog, stores and stock, community hub, features, rights, rewards.
7. Analytics events + nightly rollup + brand Overview screen.
8. Moderation: report button everywhere, block, hide flow for admins. **Required before public launch.**

## 11. Testing

The SQL tests run on plain Postgres, using a stub of Supabase's `auth` schema:

```bash
createdb stylper_test
PGOPTIONS='-c stylper.allow_destructive_tests=on' \
psql -d stylper_test -v ON_ERROR_STOP=1 \
  -f supabase/tests/00_supabase_stub.sql \
  -f supabase/migrations/0001_stylper_schema.sql \
  -f supabase/migrations/0002_handles.sql \
  -f supabase/migrations/0003_style_keys.sql \
  -f supabase/migrations/0004_tag_limit.sql \
  -f supabase/tests/01_rls_and_workflows.sql
# → ALL TESTS PASSED
```

The tests empty every table before they start (and roll everything back at the end), so the script refuses to run unless the connection sets `stylper.allow_destructive_tests=on`. Never set it against a real project.

They cover privacy (height/weight, private accounts, blocks), permissions (brand vs non-brand, guests), counters, notifications, the consent toggle, rights and voucher flows, search, and analytics rollup. **Any schema change must keep these green, and new features should add tests here.**

Against a real Supabase project, use `supabase db reset` locally and skip `00_supabase_stub.sql`, because Supabase provides the real auth schema.

## 12. Before launch checklist

- [ ] Privacy policy that explains height and weight are optional and used only for fit; how brand features and rights requests work; how to delete an account
- [ ] Account deletion in-app (required by Apple and Google): an Edge Function that deletes the `auth.users` row (everything cascades) and that user's R2 objects
- [ ] Report + block available on every post, comment and profile
- [ ] Spend cap left ON in Supabase; Cloudflare budget alert set
- [ ] Daily backups confirmed (included in Pro, 7-day retention)
