-- =====================================================================
-- Stylper — initial database schema (Supabase / Postgres 15+)
-- ---------------------------------------------------------------------
-- Covers every screen in the Stylper prototype:
--   consumer app : onboarding, profile setup, style quiz, feed, posts,
--                  item tags, likes, comments, saves, follows, boards,
--                  wardrobe, search, notifications
--   brand app    : brands, team members, stores, catalog, variants,
--                  stock per store, showroom features, rights requests,
--                  rewards (vouchers), analytics events + daily stats
--   safety       : reports, blocks, moderation flags
--
-- Images are NOT stored in Postgres or Supabase Storage. Bytes live in
-- Cloudflare R2; the `media` table only holds the object keys.
--
-- Conventions
--   * all ids are uuid (gen_random_uuid()) except high-volume events
--   * money is integer UZS (bigint), never float
--   * soft delete with deleted_at on user content
--   * counters are maintained by triggers, never written by clients
--   * every table has RLS enabled; anything not granted by a policy is denied
-- =====================================================================

create extension if not exists citext;
create extension if not exists pg_trgm;

-- ---------------------------------------------------------------------
-- Enums
-- ---------------------------------------------------------------------
create type gender_t           as enum ('male', 'female', 'unspecified');
create type item_category_t    as enum ('tops', 'bottoms', 'outerwear', 'shoes', 'accessories', 'other');
create type brand_role_t       as enum ('owner', 'admin', 'editor');
create type post_visibility_t  as enum ('public', 'followers', 'private');
create type media_kind_t       as enum ('post', 'avatar', 'product', 'wardrobe', 'brand');
create type media_status_t     as enum ('pending', 'ready', 'rejected');
create type wardrobe_source_t  as enum ('manual', 'from_post', 'from_product', 'scan');
create type rights_status_t    as enum ('pending', 'accepted', 'declined', 'expired', 'revoked');
create type reward_type_t      as enum ('voucher', 'gift', 'early_access');
create type reward_status_t    as enum ('sent', 'redeemed', 'expired', 'cancelled');
create type report_reason_t    as enum ('spam', 'nudity', 'harassment', 'hate', 'violence', 'ip', 'other');
create type report_status_t    as enum ('open', 'actioned', 'dismissed');
create type notif_type_t       as enum ('like', 'comment', 'reply', 'follow', 'brand_feature',
                                        'rights_request', 'rights_response', 'reward', 'system');
create type event_type_t       as enum ('post_view', 'tag_tap', 'shop_click', 'wardrobe_add',
                                        'product_view', 'brand_view', 'post_save', 'store_view');

-- ---------------------------------------------------------------------
-- Shared trigger: updated_at
-- ---------------------------------------------------------------------
create or replace function set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

-- =====================================================================
-- 1. People
-- =====================================================================

-- Public profile. One row per auth user, created by trigger on sign-up.
create table profiles (
  id               uuid primary key references auth.users(id) on delete cascade,
  username         citext unique check (username ~ '^[a-z0-9._]{3,30}$'),
  display_name     text check (char_length(display_name) <= 60),
  bio              text check (char_length(bio) <= 160),
  avatar_media_id  uuid,                                   -- fk added after media exists
  city             text default 'Tashkent',
  style_dna        text[] not null default '{}',           -- e.g. {Minimal,Casual,Streetwear}
  is_private       boolean not null default false,         -- private account: posts visible to followers only
  onboarded_at     timestamptz,                            -- set when setup + quiz finished or skipped
  posts_count      integer not null default 0,
  followers_count  integer not null default 0,
  following_count  integer not null default 0,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create trigger profiles_updated before update on profiles for each row execute function set_updated_at();
create index profiles_username_trgm on profiles using gin ((username::text) gin_trgm_ops);

-- Private profile data: only the owner can read or write it.
-- Height/weight/age are optional and used only for fit recommendations.
create table profile_private (
  user_id          uuid primary key references profiles(id) on delete cascade,
  gender           gender_t not null default 'unspecified',
  birth_year       smallint check (birth_year between 1900 and 2100),
  height_cm        smallint check (height_cm between 80 and 250),
  weight_kg        smallint check (weight_kg between 20 and 300),
  -- settings screen toggles
  allow_brand_features_default boolean not null default true,
  show_like_counts boolean not null default true,
  notify_brand_activity boolean not null default true,
  notify_drops     boolean not null default false,
  updated_at       timestamptz not null default now()
);
create trigger profile_private_updated before update on profile_private for each row execute function set_updated_at();

-- Onboarding "Dress like you" quiz: which top/bottom combinations the user liked.
create table style_quiz_answers (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles(id) on delete cascade,
  top_key     text not null,
  bottom_key  text not null,
  liked       boolean not null default true,
  created_at  timestamptz not null default now()
);
create index style_quiz_answers_user on style_quiz_answers(user_id);

create table follows (
  follower_id  uuid not null references profiles(id) on delete cascade,
  followee_id  uuid not null references profiles(id) on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (follower_id, followee_id),
  check (follower_id <> followee_id)
);
create index follows_followee on follows(followee_id);

create table blocks (
  blocker_id  uuid not null references profiles(id) on delete cascade,
  blocked_id  uuid not null references profiles(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);
create index blocks_blocked on blocks(blocked_id);

-- =====================================================================
-- 2. Media (pointers to Cloudflare R2 objects)
-- =====================================================================
-- Flow: Edge Function `create-upload` inserts a 'pending' row and returns
-- presigned PUT URLs for the full + thumb keys; the app uploads straight
-- to R2; Edge Function `finalize-upload` checks both objects exist and
-- flips status to 'ready'. Clients never insert here directly.
create table media (
  id           uuid primary key default gen_random_uuid(),
  owner_id     uuid references profiles(id) on delete set null,
  brand_id     uuid,                                       -- set for brand-owned media; fk added below
  kind         media_kind_t not null,
  full_key     text not null unique,                       -- e.g. posts/<uid>/<uuid>_1080.webp
  thumb_key    text not null unique,                       -- e.g. posts/<uid>/<uuid>_400.webp
  width        integer check (width > 0),
  height       integer check (height > 0),
  bytes        integer check (bytes > 0),
  blurhash     text,                                       -- placeholder while the image loads
  status       media_status_t not null default 'pending',
  created_at   timestamptz not null default now()
);
create index media_owner on media(owner_id);
create index media_pending on media(created_at) where status = 'pending';  -- for cleanup job

alter table profiles
  add constraint profiles_avatar_fk foreign key (avatar_media_id) references media(id) on delete set null;

-- =====================================================================
-- 3. Brands, stores, catalog
-- =====================================================================
create table brands (
  id               uuid primary key default gen_random_uuid(),
  slug             citext not null unique check (slug ~ '^[a-z0-9-]{2,40}$'),
  name             text not null,
  tagline          text,
  logo_media_id    uuid references media(id) on delete set null,
  cover_media_id   uuid references media(id) on delete set null,
  website_url      text,
  city             text default 'Tashkent',
  is_verified      boolean not null default false,          -- set by Stylper admins only
  followers_count  integer not null default 0,
  products_count   integer not null default 0,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);
create trigger brands_updated before update on brands for each row execute function set_updated_at();
create index brands_name_trgm on brands using gin (name gin_trgm_ops);

alter table media
  add constraint media_brand_fk foreign key (brand_id) references brands(id) on delete cascade;

create table brand_members (
  brand_id    uuid not null references brands(id) on delete cascade,
  user_id     uuid not null references profiles(id) on delete cascade,
  role        brand_role_t not null default 'editor',
  created_at  timestamptz not null default now(),
  primary key (brand_id, user_id)
);
create index brand_members_user on brand_members(user_id);

create table brand_follows (
  user_id     uuid not null references profiles(id) on delete cascade,
  brand_id    uuid not null references brands(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (user_id, brand_id)
);
create index brand_follows_brand on brand_follows(brand_id);

create table stores (
  id            uuid primary key default gen_random_uuid(),
  brand_id      uuid not null references brands(id) on delete cascade,
  name          text not null,
  address       text,
  city          text default 'Tashkent',
  lat           double precision,
  lng           double precision,
  opening_hours jsonb,                                      -- {"mon":"10:00-22:00", ...}
  is_active     boolean not null default true,
  created_at    timestamptz not null default now()
);
create index stores_brand on stores(brand_id);

create table products (
  id            uuid primary key default gen_random_uuid(),
  brand_id      uuid not null references brands(id) on delete cascade,
  ref_code      text,                                       -- brand's own reference, e.g. 1245812
  name          text not null,
  description   text,
  category      item_category_t not null,
  price_uzs     bigint check (price_uzs >= 0),
  external_url  text,                                       -- "Buy Now" goes here
  is_active     boolean not null default true,
  styled_count  integer not null default 0,                 -- # of posts tagging it ("142 styles")
  search_tsv    tsvector generated always as
                  (to_tsvector('simple', coalesce(name,'') || ' ' || coalesce(description,''))) stored,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  unique (brand_id, ref_code)
);
create trigger products_updated before update on products for each row execute function set_updated_at();
create index products_brand on products(brand_id) where is_active;
create index products_search on products using gin (search_tsv);
create index products_name_trgm on products using gin (name gin_trgm_ops);
create index products_most_styled on products(brand_id, styled_count desc) where is_active;

create table product_variants (
  id          uuid primary key default gen_random_uuid(),
  product_id  uuid not null references products(id) on delete cascade,
  color       text not null,
  size        text not null,                                -- XS..XL, 42, etc.
  sku         text,
  unique (product_id, color, size)
);

create table product_images (
  id          uuid primary key default gen_random_uuid(),
  product_id  uuid not null references products(id) on delete cascade,
  media_id    uuid not null references media(id) on delete cascade,
  color       text,                                         -- null = all colours
  position    smallint not null default 0
);
create index product_images_product on product_images(product_id, position);

create table store_stock (
  store_id    uuid not null references stores(id) on delete cascade,
  variant_id  uuid not null references product_variants(id) on delete cascade,
  quantity    integer not null default 0 check (quantity >= 0),
  updated_at  timestamptz not null default now(),
  primary key (store_id, variant_id)
);
create index store_stock_variant on store_stock(variant_id);

-- =====================================================================
-- 4. Posts, tags, engagement
-- =====================================================================
create table posts (
  id                    uuid primary key default gen_random_uuid(),
  author_id             uuid not null references profiles(id) on delete cascade,
  caption               text check (char_length(caption) <= 2200),
  location_text         text,                               -- "Tashkent"
  city                  text,                               -- normalised, used for "Trending in <city>"
  styles                text[] not null default '{}',       -- Style DNA chips chosen on publish
  visibility            post_visibility_t not null default 'public',
  allow_brand_feature   boolean not null default true,      -- "Allow brands to feature this"
  brand_consent_at      timestamptz,                        -- when that toggle was last set to true
  likes_count           integer not null default 0,
  comments_count        integer not null default 0,
  saves_count           integer not null default 0,
  is_hidden             boolean not null default false,     -- moderation
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  deleted_at            timestamptz
);
create trigger posts_updated before update on posts for each row execute function set_updated_at();
create index posts_author_recent on posts(author_id, created_at desc) where deleted_at is null;
create index posts_recent on posts(created_at desc) where deleted_at is null and not is_hidden;
create index posts_city_recent on posts(city, created_at desc) where deleted_at is null and not is_hidden;
create index posts_styles on posts using gin (styles);

-- Record consent time whenever the feature toggle is switched on.
create or replace function posts_consent_stamp() returns trigger
language plpgsql as $$
begin
  if new.allow_brand_feature and (tg_op = 'INSERT' or not old.allow_brand_feature) then
    new.brand_consent_at := now();
  elsif not new.allow_brand_feature then
    new.brand_consent_at := null;
  end if;
  return new;
end $$;
create trigger posts_consent before insert or update of allow_brand_feature on posts
  for each row execute function posts_consent_stamp();

-- One or more photos per post (prototype uses one; carousel-ready).
create table post_images (
  id        uuid primary key default gen_random_uuid(),
  post_id   uuid not null references posts(id) on delete cascade,
  media_id  uuid not null references media(id) on delete restrict,
  position  smallint not null default 0,
  unique (post_id, position)
);
create index post_images_post on post_images(post_id);

-- Wardrobe items are referenced by tags, so define them first.
create table wardrobe_items (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid not null references profiles(id) on delete cascade,
  category        item_category_t not null,
  name            text not null,
  brand_name      text,                                     -- free text when not a catalog product
  product_id      uuid references products(id) on delete set null,
  media_id        uuid references media(id) on delete set null,
  source          wardrobe_source_t not null default 'manual',
  source_post_id  uuid references posts(id) on delete set null,
  created_at      timestamptz not null default now()
);
create index wardrobe_owner on wardrobe_items(owner_id, category);
-- can't add the same catalog product twice
create unique index wardrobe_one_per_product on wardrobe_items(owner_id, product_id) where product_id is not null;

-- A tag is a dot on a photo at (x_pct, y_pct) pointing at a product,
-- a wardrobe item, or a free-text label.
create table post_tags (
  id                uuid primary key default gen_random_uuid(),
  post_id           uuid not null references posts(id) on delete cascade,
  post_image_id     uuid not null references post_images(id) on delete cascade,
  x_pct             numeric(5,2) not null check (x_pct between 0 and 100),
  y_pct             numeric(5,2) not null check (y_pct between 0 and 100),
  product_id        uuid references products(id) on delete set null,
  wardrobe_item_id  uuid references wardrobe_items(id) on delete set null,
  label             text,                                   -- fallback "Brand · Item" text
  created_at        timestamptz not null default now(),
  check (product_id is not null or wardrobe_item_id is not null or label is not null)
);
create index post_tags_post on post_tags(post_id);
create index post_tags_product on post_tags(product_id) where product_id is not null;

create table likes (
  user_id     uuid not null references profiles(id) on delete cascade,
  post_id     uuid not null references posts(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (user_id, post_id)
);
create index likes_post on likes(post_id);

create table saves (
  user_id     uuid not null references profiles(id) on delete cascade,
  post_id     uuid not null references posts(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (user_id, post_id)
);
create index saves_user_recent on saves(user_id, created_at desc);

create table comments (
  id          uuid primary key default gen_random_uuid(),
  post_id     uuid not null references posts(id) on delete cascade,
  author_id   uuid not null references profiles(id) on delete cascade,
  parent_id   uuid references comments(id) on delete cascade,  -- one level of replies
  body        text not null check (char_length(body) between 1 and 1000),
  is_hidden   boolean not null default false,
  created_at  timestamptz not null default now(),
  deleted_at  timestamptz
);
create index comments_post on comments(post_id, created_at);

-- "Style Boards" on the profile
create table style_boards (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null references profiles(id) on delete cascade,
  name        text not null check (char_length(name) between 1 and 60),
  is_private  boolean not null default false,
  created_at  timestamptz not null default now()
);
create index style_boards_owner on style_boards(owner_id);

create table board_posts (
  board_id  uuid not null references style_boards(id) on delete cascade,
  post_id   uuid not null references posts(id) on delete cascade,
  added_at  timestamptz not null default now(),
  primary key (board_id, post_id)
);

-- =====================================================================
-- 5. Brand ↔ creator workflows
-- =====================================================================

-- Brand features a community post in its showroom ("Styled by Community").
create table brand_features (
  brand_id     uuid not null references brands(id) on delete cascade,
  post_id      uuid not null references posts(id) on delete cascade,
  featured_by  uuid references profiles(id) on delete set null,
  created_at   timestamptz not null default now(),
  primary key (brand_id, post_id)
);
create index brand_features_brand on brand_features(brand_id, created_at desc);

-- Brand asks a creator for permission to reuse their photo off-platform.
create table rights_requests (
  id            uuid primary key default gen_random_uuid(),
  brand_id      uuid not null references brands(id) on delete cascade,
  post_id       uuid not null references posts(id) on delete cascade,
  creator_id    uuid not null references profiles(id) on delete cascade,
  requested_by  uuid references profiles(id) on delete set null,
  channels      text[] not null check (channels <@ array['social','web','ads','print']::text[]
                                       and cardinality(channels) > 0),
  duration_days smallint not null default 90 check (duration_days between 1 and 365),
  message       text check (char_length(message) <= 1000),
  status        rights_status_t not null default 'pending',
  responded_at  timestamptz,
  expires_at    timestamptz,                                -- set on accept: responded_at + duration
  created_at    timestamptz not null default now()
);
create index rights_requests_creator on rights_requests(creator_id, status);
create index rights_requests_brand on rights_requests(brand_id, created_at desc);
create unique index rights_requests_one_open on rights_requests(brand_id, post_id) where status = 'pending';

create table rewards (
  id            uuid primary key default gen_random_uuid(),
  brand_id      uuid not null references brands(id) on delete cascade,
  recipient_id  uuid not null references profiles(id) on delete cascade,
  post_id       uuid references posts(id) on delete set null,
  type          reward_type_t not null default 'voucher',
  percent_off   smallint check (percent_off between 1 and 100),
  code          text,                                       -- voucher code, shown to recipient only
  message       text check (char_length(message) <= 1000),
  status        reward_status_t not null default 'sent',
  expires_at    timestamptz,
  redeemed_at   timestamptz,
  created_by    uuid references profiles(id) on delete set null,
  created_at    timestamptz not null default now()
);
create index rewards_recipient on rewards(recipient_id, created_at desc);
create index rewards_brand on rewards(brand_id, created_at desc);

-- =====================================================================
-- 6. Notifications, moderation, analytics
-- =====================================================================
create table notifications (
  id                 uuid primary key default gen_random_uuid(),
  recipient_id       uuid not null references profiles(id) on delete cascade,
  type               notif_type_t not null,
  actor_id           uuid references profiles(id) on delete cascade,
  brand_id           uuid references brands(id) on delete cascade,
  post_id            uuid references posts(id) on delete cascade,
  comment_id         uuid references comments(id) on delete cascade,
  rights_request_id  uuid references rights_requests(id) on delete cascade,
  reward_id          uuid references rewards(id) on delete cascade,
  data               jsonb not null default '{}',
  read_at            timestamptz,
  created_at         timestamptz not null default now()
);
create index notifications_inbox on notifications(recipient_id, created_at desc);
create index notifications_unread on notifications(recipient_id) where read_at is null;

create table reports (
  id            uuid primary key default gen_random_uuid(),
  reporter_id   uuid references profiles(id) on delete set null,
  post_id       uuid references posts(id) on delete cascade,
  comment_id    uuid references comments(id) on delete cascade,
  user_id       uuid references profiles(id) on delete cascade,
  reason        report_reason_t not null,
  details       text check (char_length(details) <= 1000),
  status        report_status_t not null default 'open',
  created_at    timestamptz not null default now(),
  resolved_at   timestamptz,
  check (num_nonnulls(post_id, comment_id, user_id) = 1)
);
create index reports_open on reports(created_at) where status = 'open';

-- Raw analytics events. Written only through log_event(); never read by
-- clients. A nightly job rolls them into brand_daily_stats and deletes
-- rows older than 90 days.
create table events (
  id           bigint generated always as identity primary key,
  type         event_type_t not null,
  user_id      uuid,                                        -- null for guests
  anon_id      text,                                        -- device id for guests
  brand_id     uuid,
  product_id   uuid,
  post_id      uuid,
  store_id     uuid,
  city         text,
  occurred_at  timestamptz not null default now()
);
create index events_brand_time on events(brand_id, occurred_at) where brand_id is not null;
create index events_time on events(occurred_at);

create table brand_daily_stats (
  brand_id        uuid not null references brands(id) on delete cascade,
  day             date not null,
  post_views      integer not null default 0,
  tag_taps        integer not null default 0,
  shop_clicks     integer not null default 0,
  wardrobe_adds   integer not null default 0,
  product_views   integer not null default 0,
  brand_views     integer not null default 0,
  store_views     integer not null default 0,
  new_followers   integer not null default 0,
  new_styled_posts integer not null default 0,
  primary key (brand_id, day)
);

-- =====================================================================
-- 7. Helper functions (security definer, used by RLS and RPCs)
-- =====================================================================

create or replace function is_brand_member(p_brand uuid, p_min brand_role_t default 'editor')
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from brand_members m
    where m.brand_id = p_brand and m.user_id = auth.uid()
      and case p_min
            when 'editor' then true
            when 'admin'  then m.role in ('admin','owner')
            when 'owner'  then m.role = 'owner'
          end
  );
$$;

create or replace function is_blocked_between(a uuid, b uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select a is not null and b is not null and exists (
    select 1 from blocks
    where (blocker_id = a and blocked_id = b) or (blocker_id = b and blocked_id = a)
  );
$$;

-- Single source of truth for "can the current viewer see this post?"
create or replace function can_view_post(p_post uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1
    from posts p
    join profiles a on a.id = p.author_id
    where p.id = p_post
      and p.deleted_at is null
      and (
        p.author_id = auth.uid()
        or (
          not p.is_hidden
          and not is_blocked_between(auth.uid(), p.author_id)
          and (
            (p.visibility = 'public' and not a.is_private)
            or (p.visibility in ('public','followers') and exists (
                  select 1 from follows f
                  where f.follower_id = auth.uid() and f.followee_id = p.author_id))
            -- brand team members can see posts that tag their products
            or (p.visibility = 'public' and exists (
                  select 1 from post_tags t join products pr on pr.id = t.product_id
                  where t.post_id = p.id and is_brand_member(pr.brand_id)))
          )
        )
      )
  );
$$;

-- =====================================================================
-- 8. Triggers: profile bootstrap, counters, notifications
-- =====================================================================

-- Create profile rows when a user signs up through Supabase Auth.
create or replace function handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name'));
  insert into profile_private (user_id) values (new.id);
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function handle_new_user();

create or replace function bump(p_table regclass, p_col text, p_id uuid, p_delta int)
returns void language plpgsql security definer set search_path = public as $$
begin
  execute format('update %s set %I = greatest(%I + $1, 0) where id = $2', p_table, p_col, p_col)
    using p_delta, p_id;
end $$;
revoke all on function bump(regclass, text, uuid, int) from public;

create or replace function trg_counts() returns trigger
language plpgsql security definer set search_path = public as $$
declare d int := case when tg_op = 'INSERT' then 1 else -1 end;
        r record;
begin
  if tg_op = 'INSERT' then r := new; else r := old; end if;
  if tg_table_name = 'likes' then
    perform bump('posts', 'likes_count', r.post_id, d);
  elsif tg_table_name = 'saves' then
    perform bump('posts', 'saves_count', r.post_id, d);
  elsif tg_table_name = 'follows' then
    perform bump('profiles', 'followers_count', r.followee_id, d);
    perform bump('profiles', 'following_count', r.follower_id, d);
  elsif tg_table_name = 'brand_follows' then
    perform bump('brands', 'followers_count', r.brand_id, d);
  end if;
  return null;
end $$;
create trigger likes_count  after insert or delete on likes         for each row execute function trg_counts();
create trigger saves_count  after insert or delete on saves         for each row execute function trg_counts();
create trigger follows_cnt  after insert or delete on follows       for each row execute function trg_counts();
create trigger bfollows_cnt after insert or delete on brand_follows for each row execute function trg_counts();

-- posts_count respects soft delete
create or replace function trg_posts_count() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' and new.deleted_at is null then
    perform bump('profiles', 'posts_count', new.author_id, 1);
  elsif tg_op = 'UPDATE' and old.deleted_at is null and new.deleted_at is not null then
    perform bump('profiles', 'posts_count', new.author_id, -1);
  elsif tg_op = 'DELETE' and old.deleted_at is null then
    perform bump('profiles', 'posts_count', old.author_id, -1);
  end if;
  return null;
end $$;
create trigger posts_count after insert or update of deleted_at or delete on posts
  for each row execute function trg_posts_count();

-- comments_count respects soft delete / hiding
create or replace function trg_comments_count() returns trigger
language plpgsql security definer set search_path = public as $$
declare was boolean; isnow boolean;
begin
  was   := tg_op <> 'INSERT' and old.deleted_at is null and not old.is_hidden;
  isnow := tg_op <> 'DELETE' and new.deleted_at is null and not new.is_hidden;
  if isnow and not was then
    perform bump('posts', 'comments_count', coalesce(new.post_id, old.post_id), 1);
  elsif was and not isnow then
    perform bump('posts', 'comments_count', coalesce(new.post_id, old.post_id), -1);
  end if;
  return null;
end $$;
create trigger comments_count after insert or update of deleted_at, is_hidden or delete on comments
  for each row execute function trg_comments_count();

-- products.styled_count = number of distinct posts tagging the product
create or replace function trg_styled_count() returns trigger
language plpgsql security definer set search_path = public as $$
declare pid uuid;
begin
  if tg_op = 'INSERT' then pid := new.product_id; else pid := old.product_id; end if;
  if pid is not null then
    update products set styled_count =
      (select count(distinct t.post_id) from post_tags t join posts p on p.id = t.post_id
        where t.product_id = pid and p.deleted_at is null)
    where id = pid;
  end if;
  return null;
end $$;
create trigger post_tags_styled after insert or delete on post_tags
  for each row execute function trg_styled_count();

-- brands.products_count
create or replace function trg_products_count() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' then perform bump('brands', 'products_count', new.brand_id, 1);
  else perform bump('brands', 'products_count', old.brand_id, -1); end if;
  return null;
end $$;
create trigger products_count after insert or delete on products
  for each row execute function trg_products_count();

-- In-app notifications for social actions
create or replace function trg_notify() returns trigger
language plpgsql security definer set search_path = public as $$
declare owner uuid;
begin
  if tg_table_name = 'likes' then
    select author_id into owner from posts where id = new.post_id;
    if owner <> new.user_id then
      insert into notifications (recipient_id, type, actor_id, post_id)
      values (owner, 'like', new.user_id, new.post_id);
    end if;
  elsif tg_table_name = 'comments' then
    if new.parent_id is not null then
      select author_id into owner from comments where id = new.parent_id;
      if owner <> new.author_id then
        insert into notifications (recipient_id, type, actor_id, post_id, comment_id)
        values (owner, 'reply', new.author_id, new.post_id, new.id);
      end if;
    end if;
    select author_id into owner from posts where id = new.post_id;
    if owner <> new.author_id then
      insert into notifications (recipient_id, type, actor_id, post_id, comment_id)
      values (owner, 'comment', new.author_id, new.post_id, new.id);
    end if;
  elsif tg_table_name = 'follows' then
    insert into notifications (recipient_id, type, actor_id)
    values (new.followee_id, 'follow', new.follower_id);
  elsif tg_table_name = 'brand_features' then
    insert into notifications (recipient_id, type, brand_id, post_id)
    select author_id, 'brand_feature', new.brand_id, new.post_id from posts where id = new.post_id;
  elsif tg_table_name = 'rights_requests' then
    insert into notifications (recipient_id, type, brand_id, post_id, rights_request_id)
    values (new.creator_id, 'rights_request', new.brand_id, new.post_id, new.id);
  elsif tg_table_name = 'rewards' then
    insert into notifications (recipient_id, type, brand_id, post_id, reward_id)
    values (new.recipient_id, 'reward', new.brand_id, new.post_id, new.id);
  end if;
  return null;
end $$;
create trigger likes_notify    after insert on likes           for each row execute function trg_notify();
create trigger comments_notify after insert on comments        for each row execute function trg_notify();
create trigger follows_notify  after insert on follows         for each row execute function trg_notify();
create trigger features_notify after insert on brand_features  for each row execute function trg_notify();
create trigger rights_notify   after insert on rights_requests for each row execute function trg_notify();
create trigger rewards_notify  after insert on rewards         for each row execute function trg_notify();

-- Blocking someone also removes follows in both directions.
create or replace function trg_block_cleanup() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  delete from follows
  where (follower_id = new.blocker_id and followee_id = new.blocked_id)
     or (follower_id = new.blocked_id and followee_id = new.blocker_id);
  return null;
end $$;
create trigger blocks_cleanup after insert on blocks for each row execute function trg_block_cleanup();

-- =====================================================================
-- 9. RPCs (called from the app with supabase.rpc(...))
-- =====================================================================

-- Creator answers a rights request. Only the creator can call this.
create or replace function respond_rights_request(p_id uuid, p_accept boolean)
returns rights_requests language plpgsql security definer set search_path = public as $$
declare r rights_requests;
begin
  update rights_requests
     set status       = case when p_accept then 'accepted' else 'declined' end::rights_status_t,
         responded_at = now(),
         expires_at   = case when p_accept then now() + make_interval(days => duration_days) end
   where id = p_id and creator_id = auth.uid() and status = 'pending'
  returning * into r;
  if r.id is null then raise exception 'request not found or not pending'; end if;

  insert into notifications (recipient_id, type, actor_id, brand_id, post_id, rights_request_id, data)
  select m.user_id, 'rights_response', auth.uid(), r.brand_id, r.post_id, r.id,
         jsonb_build_object('status', r.status)
  from brand_members m where m.brand_id = r.brand_id;
  return r;
end $$;

-- Creator can withdraw an accepted permission early.
create or replace function revoke_rights(p_id uuid)
returns void language sql security definer set search_path = public as $$
  update rights_requests set status = 'revoked', expires_at = now()
  where id = p_id and creator_id = auth.uid() and status = 'accepted';
$$;

-- Soft-delete a post (author only).
create or replace function delete_post(p_id uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  update posts set deleted_at = now()
  where id = p_id and author_id = auth.uid() and deleted_at is null;
  if not found then raise exception 'post not found'; end if;
  delete from brand_features where post_id = p_id;
  update products pr set styled_count =
    (select count(distinct t.post_id) from post_tags t join posts p on p.id = t.post_id
      where t.product_id = pr.id and p.deleted_at is null)
  where pr.id in (select product_id from post_tags where post_id = p_id and product_id is not null);
  update rights_requests set status = 'revoked', expires_at = now()
  where post_id = p_id and status in ('pending','accepted');
end $$;

-- Comment author deletes own comment; post owner deletes any comment on their post.
create or replace function delete_comment(p_id uuid)
returns void language plpgsql security definer set search_path = public as $$
begin
  update comments c set deleted_at = now()
  where c.id = p_id and c.deleted_at is null
    and (c.author_id = auth.uid()
         or exists (select 1 from posts p where p.id = c.post_id and p.author_id = auth.uid()));
  if not found then raise exception 'comment not found'; end if;
end $$;

create or replace function mark_notifications_read(p_before timestamptz default now())
returns void language sql security definer set search_path = public as $$
  update notifications set read_at = now()
  where recipient_id = auth.uid() and read_at is null and created_at <= p_before;
$$;

-- Analytics: fire-and-forget from the app. Works for guests too.
create or replace function log_event(
  p_type event_type_t, p_post uuid default null, p_product uuid default null,
  p_brand uuid default null, p_store uuid default null, p_anon text default null, p_city text default null)
returns void language plpgsql security definer set search_path = public as $$
declare b uuid := p_brand;
begin
  if b is null and p_product is not null then select brand_id into b from products where id = p_product; end if;
  if b is null and p_store   is not null then select brand_id into b from stores   where id = p_store;   end if;
  insert into events (type, user_id, anon_id, brand_id, product_id, post_id, store_id, city)
  values (p_type, auth.uid(), left(p_anon, 64), b, p_product, p_post, p_store, left(p_city, 60));
end $$;

-- Feed: "Following" tab. Keyset pagination on created_at.
create or replace function feed_following(p_before timestamptz default now(), p_limit int default 20)
returns setof posts language sql stable security definer set search_path = public as $$
  select p.* from posts p
  join follows f on f.followee_id = p.author_id and f.follower_id = auth.uid()
  where p.created_at < p_before and p.deleted_at is null and not p.is_hidden
    and p.visibility in ('public','followers')
  order by p.created_at desc
  limit least(p_limit, 50);
$$;

-- Feed: "For you" tab. Simple, explainable ranking for launch:
-- style overlap with the viewer's Style DNA + engagement + freshness.
-- Optional p_style filters to one chip (Casual / Minimal / Street).
create or replace function feed_for_you(p_style text default null, p_offset int default 0, p_limit int default 20)
returns setof posts language sql stable security definer set search_path = public as $$
  with me as (select coalesce((select style_dna from profiles where id = auth.uid()), '{}') as dna)
  select p.* from posts p cross join me
  where p.deleted_at is null and not p.is_hidden and p.visibility = 'public'
    and p.created_at > now() - interval '30 days'
    and (p_style is null or p_style = any(p.styles))
    and (auth.uid() is null or p.author_id <> auth.uid())
    and not is_blocked_between(auth.uid(), p.author_id)
    and not exists (select 1 from profiles a where a.id = p.author_id and a.is_private)
  order by
      (select count(*) from unnest(p.styles) s where s = any(me.dna)) * 3
    + ln(1 + p.likes_count + 2 * p.comments_count + 3 * p.saves_count)
    - extract(epoch from now() - p.created_at) / 86400.0 * 0.5
    desc
  offset greatest(p_offset, 0) limit least(p_limit, 50);
$$;

-- "Trending in Tashkent": most engagement in the last 7 days in a city.
create or replace function trending_in_city(p_city text default 'Tashkent', p_limit int default 20)
returns setof posts language sql stable security definer set search_path = public as $$
  select p.* from posts p
  where p.city = p_city and p.deleted_at is null and not p.is_hidden and p.visibility = 'public'
    and p.created_at > now() - interval '7 days'
    and not is_blocked_between(auth.uid(), p.author_id)
    and not exists (select 1 from profiles a where a.id = p.author_id and a.is_private)
  order by p.likes_count + 2 * p.comments_count + 3 * p.saves_count desc, p.created_at desc
  limit least(p_limit, 50);
$$;

-- Search across people, brands and products (one call for the Search screen).
-- Matches partial words ("blaz" -> "Wool Oversized Blazer") and small typos.
create or replace function search_all(p_q text, p_limit int default 10)
returns table (kind text, id uuid, title text, subtitle text, score real)
language sql stable security definer set search_path = public as $$
  with q as (select lower(trim(p_q)) as t,
                    '%' || replace(replace(lower(trim(p_q)), '%', '\%'), '_', '\_') || '%' as pat)
  (select 'user'::text, pf.id, pf.username::text, pf.display_name, word_similarity(q.t, pf.username::text)
     from profiles pf, q
     where char_length(q.t) >= 2 and pf.username is not null
       and (pf.username::text ilike q.pat or q.t <% pf.username::text)
       and not is_blocked_between(auth.uid(), pf.id)
     order by 5 desc limit p_limit)
  union all
  (select 'brand', b.id, b.name, b.tagline, word_similarity(q.t, b.name)
     from brands b, q
     where char_length(q.t) >= 2 and (b.name ilike q.pat or q.t <% b.name)
     order by 5 desc limit p_limit)
  union all
  (select 'product', pr.id, pr.name, b.name, word_similarity(q.t, pr.name || ' ' || b.name)
     from products pr join brands b on b.id = pr.brand_id, q
     where pr.is_active and char_length(q.t) >= 2
       and (pr.name ilike q.pat or q.t <% (pr.name || ' ' || b.name)
            or pr.search_tsv @@ plainto_tsquery('simple', q.t))
     order by 5 desc limit p_limit);
$$;

-- Nightly job (pg_cron or scheduled Edge Function): roll up yesterday's events.
create or replace function rollup_brand_stats(p_day date default ((now() at time zone 'Asia/Tashkent') - interval '1 day')::date)
returns void language sql security definer set search_path = public as $$
  -- days are Tashkent calendar days (UTC+5), not UTC days
  insert into brand_daily_stats (brand_id, day, post_views, tag_taps, shop_clicks, wardrobe_adds,
                                 product_views, brand_views, store_views, new_followers, new_styled_posts)
  select b.id, p_day,
    count(*) filter (where e.type = 'post_view'),
    count(*) filter (where e.type = 'tag_tap'),
    count(*) filter (where e.type = 'shop_click'),
    count(*) filter (where e.type = 'wardrobe_add'),
    count(*) filter (where e.type = 'product_view'),
    count(*) filter (where e.type = 'brand_view'),
    count(*) filter (where e.type = 'store_view'),
    (select count(*) from brand_follows f
       where f.brand_id = b.id and (f.created_at at time zone 'Asia/Tashkent')::date = p_day),
    (select count(distinct t.post_id) from post_tags t join products pr on pr.id = t.product_id
       where pr.brand_id = b.id and (t.created_at at time zone 'Asia/Tashkent')::date = p_day)
  from brands b
  left join events e on e.brand_id = b.id
        and (e.occurred_at at time zone 'Asia/Tashkent')::date = p_day
  group by b.id
  on conflict (brand_id, day) do update set
    post_views = excluded.post_views, tag_taps = excluded.tag_taps, shop_clicks = excluded.shop_clicks,
    wardrobe_adds = excluded.wardrobe_adds, product_views = excluded.product_views,
    brand_views = excluded.brand_views, store_views = excluded.store_views,
    new_followers = excluded.new_followers, new_styled_posts = excluded.new_styled_posts;
  delete from events where occurred_at < now() - interval '90 days';
  update rights_requests set status = 'expired' where status = 'accepted' and expires_at < now();
  update rewards set status = 'expired' where status = 'sent' and expires_at < now();
  delete from media where status = 'pending' and created_at < now() - interval '1 day';
$$;
revoke all on function rollup_brand_stats(date) from public, anon, authenticated;
revoke all on function bump(regclass, text, uuid, int) from anon, authenticated;

-- =====================================================================
-- 10. Row Level Security
-- =====================================================================
alter table profiles            enable row level security;
alter table profile_private     enable row level security;
alter table style_quiz_answers  enable row level security;
alter table follows             enable row level security;
alter table blocks              enable row level security;
alter table media               enable row level security;
alter table brands              enable row level security;
alter table brand_members       enable row level security;
alter table brand_follows       enable row level security;
alter table stores              enable row level security;
alter table products            enable row level security;
alter table product_variants    enable row level security;
alter table product_images      enable row level security;
alter table store_stock         enable row level security;
alter table posts               enable row level security;
alter table post_images         enable row level security;
alter table post_tags           enable row level security;
alter table wardrobe_items      enable row level security;
alter table likes               enable row level security;
alter table saves               enable row level security;
alter table comments            enable row level security;
alter table style_boards        enable row level security;
alter table board_posts         enable row level security;
alter table brand_features      enable row level security;
alter table rights_requests     enable row level security;
alter table rewards             enable row level security;
alter table notifications       enable row level security;
alter table reports             enable row level security;
alter table events              enable row level security;
alter table brand_daily_stats   enable row level security;

-- profiles: public read, owner update. Counters cannot be edited by clients
-- (column grants below).
create policy profiles_read   on profiles for select using (not is_blocked_between(auth.uid(), id));
create policy profiles_update on profiles for update using (id = auth.uid()) with check (
  id = auth.uid()
  and (avatar_media_id is null or exists (
        select 1 from media m where m.id = avatar_media_id and m.owner_id = auth.uid() and m.status = 'ready')));

create policy private_own on profile_private for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy quiz_own    on style_quiz_answers for all using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy follows_read   on follows for select using (true);
create policy follows_insert on follows for insert with check (follower_id = auth.uid()
                                 and not is_blocked_between(follower_id, followee_id));
create policy follows_delete on follows for delete using (follower_id = auth.uid() or followee_id = auth.uid());

create policy blocks_own on blocks for all using (blocker_id = auth.uid()) with check (blocker_id = auth.uid());

-- media: readable once ready; rows are written only by Edge Functions (service role).
create policy media_read on media for select using (status = 'ready' or owner_id = auth.uid());

-- brands & catalog: public read; team members write.
create policy brands_read   on brands for select using (true);
create policy brands_update on brands for update using (is_brand_member(id, 'admin')) with check (is_brand_member(id, 'admin'));

create policy members_read   on brand_members for select using (user_id = auth.uid() or is_brand_member(brand_id));
create policy members_manage on brand_members for all using (is_brand_member(brand_id, 'owner'))
                                                with check (is_brand_member(brand_id, 'owner'));

create policy bfollows_read   on brand_follows for select using (user_id = auth.uid() or is_brand_member(brand_id));
create policy bfollows_insert on brand_follows for insert with check (user_id = auth.uid());
create policy bfollows_delete on brand_follows for delete using (user_id = auth.uid());

create policy stores_read  on stores for select using (is_active or is_brand_member(brand_id));
create policy stores_write on stores for all using (is_brand_member(brand_id)) with check (is_brand_member(brand_id));

create policy products_read  on products for select using (is_active or is_brand_member(brand_id));
create policy products_write on products for all using (is_brand_member(brand_id)) with check (is_brand_member(brand_id));

create policy variants_read  on product_variants for select using (true);
create policy variants_write on product_variants for all
  using (is_brand_member((select brand_id from products where id = product_id)))
  with check (is_brand_member((select brand_id from products where id = product_id)));

create policy pimages_read  on product_images for select using (true);
create policy pimages_write on product_images for all
  using (is_brand_member((select brand_id from products where id = product_id)))
  with check (is_brand_member((select brand_id from products where id = product_id))
              and exists (select 1 from media m join products pr on pr.id = product_images.product_id
                          where m.id = media_id and m.brand_id = pr.brand_id and m.status = 'ready'));

create policy stock_read  on store_stock for select using (true);
create policy stock_write on store_stock for all
  using (is_brand_member((select brand_id from stores where id = store_id)))
  with check (is_brand_member((select brand_id from stores where id = store_id))
              and (select brand_id from stores where id = store_id) =
                  (select pr.brand_id from product_variants v join products pr on pr.id = v.product_id
                    where v.id = variant_id));

-- posts
create policy posts_read   on posts for select using (can_view_post(id));
create policy posts_insert on posts for insert with check (author_id = auth.uid());
create policy posts_update on posts for update using (author_id = auth.uid()) with check (author_id = auth.uid());

create policy pimgs_read  on post_images for select using (can_view_post(post_id));
create policy pimgs_write on post_images for all
  using (exists (select 1 from posts where id = post_id and author_id = auth.uid()))
  with check (exists (select 1 from posts where id = post_id and author_id = auth.uid())
              and exists (select 1 from media m where m.id = media_id and m.owner_id = auth.uid()
                          and m.kind = 'post' and m.status = 'ready'));

create policy tags_read  on post_tags for select using (can_view_post(post_id));
create policy tags_write on post_tags for all
  using (exists (select 1 from posts where id = post_id and author_id = auth.uid()))
  with check (exists (select 1 from posts where id = post_id and author_id = auth.uid())
              and (wardrobe_item_id is null or exists (
                    select 1 from wardrobe_items w where w.id = wardrobe_item_id and w.owner_id = auth.uid()))
              and exists (select 1 from post_images i where i.id = post_image_id and i.post_id = post_tags.post_id));

create policy wardrobe_own on wardrobe_items for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy likes_read   on likes for select using (can_view_post(post_id));
create policy likes_insert on likes for insert with check (user_id = auth.uid() and can_view_post(post_id));
create policy likes_delete on likes for delete using (user_id = auth.uid());

create policy saves_own_read   on saves for select using (user_id = auth.uid());
create policy saves_own_insert on saves for insert with check (user_id = auth.uid() and can_view_post(post_id));
create policy saves_own_delete on saves for delete using (user_id = auth.uid());

create policy comments_read   on comments for select using (
  can_view_post(post_id) and deleted_at is null
  and (not is_hidden or author_id = auth.uid())
  and not is_blocked_between(auth.uid(), author_id));
create policy comments_insert on comments for insert with check (
  author_id = auth.uid() and can_view_post(post_id)
  and not is_blocked_between(auth.uid(), (select author_id from posts where id = post_id)));
-- author can edit the text of their own comment; deleting goes through delete_comment()
create policy comments_update on comments for update using (author_id = auth.uid()) with check (author_id = auth.uid());

create policy boards_read  on style_boards for select using (not is_private or owner_id = auth.uid());
create policy boards_write on style_boards for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy bposts_read  on board_posts for select using (exists (
  select 1 from style_boards b where b.id = board_id and (not b.is_private or b.owner_id = auth.uid()))
  and can_view_post(post_id));
create policy bposts_write on board_posts for all
  using (exists (select 1 from style_boards b where b.id = board_id and b.owner_id = auth.uid()))
  with check (exists (select 1 from style_boards b where b.id = board_id and b.owner_id = auth.uid())
              and can_view_post(post_id));

-- brand features: only on posts that allow it AND tag one of the brand's products.
create policy features_read   on brand_features for select using (can_view_post(post_id));
create policy features_insert on brand_features for insert with check (
  is_brand_member(brand_id)
  and exists (select 1 from posts p where p.id = post_id and p.allow_brand_feature
              and p.visibility = 'public' and p.deleted_at is null and not p.is_hidden)
  and exists (select 1 from post_tags t join products pr on pr.id = t.product_id
              where t.post_id = brand_features.post_id and pr.brand_id = brand_features.brand_id));
create policy features_delete on brand_features for delete using (
  is_brand_member(brand_id) or exists (select 1 from posts p where p.id = post_id and p.author_id = auth.uid()));

-- rights requests: brand creates; creator responds via RPC.
create policy rights_read   on rights_requests for select using (creator_id = auth.uid() or is_brand_member(brand_id));
create policy rights_insert on rights_requests for insert with check (
  is_brand_member(brand_id) and requested_by = auth.uid() and status = 'pending'
  and creator_id = (select author_id from posts where id = post_id)
  and can_view_post(post_id));

-- rewards: brand sends; recipient reads (and sees the code).
create policy rewards_read   on rewards for select using (recipient_id = auth.uid() or is_brand_member(brand_id));
create policy rewards_insert on rewards for insert with check (
  is_brand_member(brand_id) and created_by = auth.uid() and status = 'sent');

create policy notifs_own on notifications for select using (recipient_id = auth.uid());
create policy notifs_del on notifications for delete using (recipient_id = auth.uid());

create policy reports_insert on reports for insert with check (reporter_id = auth.uid());

-- events: no client policies at all — writes go through log_event().
create policy stats_read on brand_daily_stats for select using (is_brand_member(brand_id));

-- =====================================================================
-- 11. Column-level protection for counters and moderation flags
-- =====================================================================
-- RLS decides WHICH rows a user may update; column grants decide WHICH
-- columns. Clients may never touch counters, verification or moderation.
revoke update on profiles from authenticated;
grant  update (username, display_name, bio, avatar_media_id, city, style_dna, is_private, onboarded_at)
  on profiles to authenticated;

revoke update on posts from authenticated;
grant  update (caption, location_text, city, styles, visibility, allow_brand_feature)
  on posts to authenticated;

revoke update on brands from authenticated;
grant  update (name, tagline, logo_media_id, cover_media_id, website_url, city) on brands to authenticated;

revoke update on products from authenticated;
grant  update (ref_code, name, description, category, price_uzs, external_url, is_active)
  on products to authenticated;

revoke update on comments from authenticated;
grant  update (body) on comments to authenticated;

revoke insert, update, delete on media, events, notifications, brand_daily_stats from anon, authenticated;
revoke all on events from anon, authenticated;                   -- analytics only via log_event()
revoke insert, update, delete on brands from anon, authenticated;     -- brands are created by Stylper admins
grant  insert on brands to service_role;

-- Guests (anon) can read public content but cannot write anything.
revoke insert, update, delete on all tables in schema public from anon;

-- Functions callable from the app
grant execute on function feed_for_you(text, int, int)          to anon, authenticated;
grant execute on function trending_in_city(text, int)           to anon, authenticated;
grant execute on function search_all(text, int)                 to anon, authenticated;
grant execute on function log_event(event_type_t, uuid, uuid, uuid, uuid, text, text) to anon, authenticated;
grant execute on function feed_following(timestamptz, int)      to authenticated;
grant execute on function respond_rights_request(uuid, boolean) to authenticated;
grant execute on function revoke_rights(uuid)                   to authenticated;
grant execute on function mark_notifications_read(timestamptz)  to authenticated;
grant execute on function delete_post(uuid)                     to authenticated;
grant execute on function delete_comment(uuid)                  to authenticated;
