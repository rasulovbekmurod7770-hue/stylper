-- Behaviour tests for the Stylper schema. Run after 00_supabase_stub.sql and
-- the migration. Every check is an ASSERT; the script stops at the first failure.
-- Everything runs in one transaction that is rolled back at the end (or when
-- psql stops on a failure), so the database is left as it was and the script
-- can be run again without a reset.
\set ON_ERROR_STOP 1
\set QUIET 1

begin;

-- Start from an empty database, since the local one holds the demo data from
-- seed.sql; the rollback brings it back.
do $$ begin
  execute (select 'truncate table ' || string_agg(format('%I.%I', schemaname, tablename), ', ') || ' cascade'
           from pg_tables where schemaname = 'public');
end $$;
delete from auth.users;

-- Fixed ids:  A = Aziza (creator)   B = Bobur   C = Kamila (private account)
--             M = COS team member   X = random user, no brand
-- helper: act as a user (or guest when uid is null)
create or replace function test_as(uid uuid) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', coalesce(uid::text, ''), false);
end $$;
grant execute on function test_as(uuid) to anon, authenticated;

-- ---------- seed (as superuser, like the dashboard / service role) ----------
insert into auth.users (id, email, raw_user_meta_data) values
 ('aaaaaaaa-0000-0000-0000-000000000001', 'a@x.uz', '{"full_name":"Aziza"}'),
 ('bbbbbbbb-0000-0000-0000-000000000002', 'b@x.uz', '{"full_name":"Bobur"}'),
 ('cccccccc-0000-0000-0000-000000000003', 'c@x.uz', '{"name":"Kamila"}'),
 ('dddddddd-0000-0000-0000-000000000004', 'm@cos.uz', '{}'),
 ('eeeeeeee-0000-0000-0000-000000000005', 'x@x.uz', '{}');

do $$ begin
  assert (select count(*) from profiles) = 5, 'signup trigger should create profiles';
  assert (select count(*) from profile_private) = 5, 'signup trigger should create profile_private';
  assert (select display_name from profiles where id = 'aaaaaaaa-0000-0000-0000-000000000001') = 'Aziza';
end $$;

update profiles set username = 'aziza', style_dna = '{Minimal,Casual}' where id = 'aaaaaaaa-0000-0000-0000-000000000001';
update profiles set username = 'bobur', style_dna = '{Casual}'        where id = 'bbbbbbbb-0000-0000-0000-000000000002';
update profiles set username = 'kamila', is_private = true            where id = 'cccccccc-0000-0000-0000-000000000003';

insert into brands (id, slug, name, tagline) values
 ('b0000000-0000-0000-0000-00000000c05a', 'cos', 'COS', 'Modern essentials for timeless style'),
 ('b0000000-0000-0000-0000-0000000000a2', 'zara', 'Zara', null);
insert into brand_members (brand_id, user_id, role) values
 ('b0000000-0000-0000-0000-00000000c05a', 'dddddddd-0000-0000-0000-000000000004', 'editor');
insert into products (id, brand_id, ref_code, name, category, price_uzs) values
 ('a0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000c05a', '1245812', 'Wool Oversized Blazer', 'outerwear', 2950000),
 ('a0000000-0000-0000-0000-000000000002', 'b0000000-0000-0000-0000-0000000000a2', 'Z1', 'Baggy Fit Jeans', 'bottoms', 400000);
insert into product_variants (id, product_id, color, size) values
 ('f0000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001', 'Sand', 'M'),
 ('f0000000-0000-0000-0000-000000000002', 'a0000000-0000-0000-0000-000000000002', 'Blue', 'M');
insert into stores (id, brand_id, name) values
 ('5e000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000c05a', 'COS Tashkent City Mall');
-- media rows are created by the upload Edge Function (service role)
insert into media (id, owner_id, kind, full_key, thumb_key, status) values
 ('ee000000-0000-0000-0000-000000000001', 'aaaaaaaa-0000-0000-0000-000000000001', 'post', 'posts/a/1_1080.webp', 'posts/a/1_400.webp', 'ready'),
 ('ee000000-0000-0000-0000-000000000003', 'cccccccc-0000-0000-0000-000000000003', 'post', 'posts/c/1_1080.webp', 'posts/c/1_400.webp', 'ready'),
 ('ee000000-0000-0000-0000-000000000009', 'aaaaaaaa-0000-0000-0000-000000000001', 'post', 'posts/a/9_1080.webp', 'posts/a/9_400.webp', 'pending');

-- ---------- A publishes an outfit post with two tags ----------
set role authenticated;
select test_as('aaaaaaaa-0000-0000-0000-000000000001');
insert into posts (id, author_id, caption, city, styles)
  values ('50000000-0000-0000-0000-00000000000a', 'aaaaaaaa-0000-0000-0000-000000000001',
          'Soft tailoring, slow mornings.', 'Tashkent', '{Minimal,Casual}');
insert into post_images (id, post_id, media_id)
  values ('51000000-0000-0000-0000-00000000000a', '50000000-0000-0000-0000-00000000000a', 'ee000000-0000-0000-0000-000000000001');
insert into post_tags (post_id, post_image_id, x_pct, y_pct, product_id) values
 ('50000000-0000-0000-0000-00000000000a', '51000000-0000-0000-0000-00000000000a', 52, 40, 'a0000000-0000-0000-0000-000000000001'),
 ('50000000-0000-0000-0000-00000000000a', '51000000-0000-0000-0000-00000000000a', 50, 80, 'a0000000-0000-0000-0000-000000000002');

do $$ begin
  -- pending media cannot be attached to a post
  begin
    insert into post_images (post_id, media_id, position)
      values ('50000000-0000-0000-0000-00000000000a', 'ee000000-0000-0000-0000-000000000009', 1);
    assert false, 'pending media must be rejected';
  exception when insufficient_privilege then null; end;
  -- someone else's media cannot be attached either
  begin
    insert into post_images (post_id, media_id, position)
      values ('50000000-0000-0000-0000-00000000000a', 'ee000000-0000-0000-0000-000000000003', 2);
    assert false, 'foreign media must be rejected';
  exception when insufficient_privilege then null; end;
  -- clients cannot write counters
  begin
    update posts set likes_count = 9999 where id = '50000000-0000-0000-0000-00000000000a';
    assert false, 'counter update must be denied';
  exception when insufficient_privilege then null; end;
  -- cannot post as someone else
  begin
    insert into posts (author_id) values ('bbbbbbbb-0000-0000-0000-000000000002');
    assert false, 'impersonated post must be rejected';
  exception when insufficient_privilege then null; end;
  -- height/weight: owner can write
  update profile_private set height_cm = 168, weight_kg = 55 where user_id = auth.uid();
  assert (select height_cm from profile_private where user_id = auth.uid()) = 168;
  -- consent timestamp recorded
  assert (select brand_consent_at from posts where id = '50000000-0000-0000-0000-00000000000a') is not null,
    'brand_consent_at should be stamped';
end $$;

-- ---------- B engages ----------
select test_as('bbbbbbbb-0000-0000-0000-000000000002');
do $$ begin
  assert (select count(*) from profile_private) = 1, 'B must only see own private row';
  assert (select height_cm from profile_private where user_id = 'aaaaaaaa-0000-0000-0000-000000000001') is null,
    'B must not read A''s height';
  assert (select count(*) from posts where id = '50000000-0000-0000-0000-00000000000a') = 1, 'public post visible';
  assert (select count(*) from post_tags where post_id = '50000000-0000-0000-0000-00000000000a') = 2, 'tags visible';
end $$;
insert into likes (user_id, post_id) values ('bbbbbbbb-0000-0000-0000-000000000002', '50000000-0000-0000-0000-00000000000a');
insert into saves (user_id, post_id) values ('bbbbbbbb-0000-0000-0000-000000000002', '50000000-0000-0000-0000-00000000000a');
insert into comments (id, post_id, author_id, body) values
 ('c0000000-0000-0000-0000-000000000001', '50000000-0000-0000-0000-00000000000a', 'bbbbbbbb-0000-0000-0000-000000000002', 'Love this blazer');
insert into follows (follower_id, followee_id) values ('bbbbbbbb-0000-0000-0000-000000000002', 'aaaaaaaa-0000-0000-0000-000000000001');
insert into wardrobe_items (owner_id, category, name, product_id, source, source_post_id) values
 ('bbbbbbbb-0000-0000-0000-000000000002', 'outerwear', 'Wool Oversized Blazer', 'a0000000-0000-0000-0000-000000000001', 'from_post', '50000000-0000-0000-0000-00000000000a');
insert into wardrobe_items (owner_id, category, name) values
 ('bbbbbbbb-0000-0000-0000-000000000002', 'tops', 'Old grey tee'),
 ('bbbbbbbb-0000-0000-0000-000000000002', 'tops', 'Black tee');
do $$ begin
  begin
    update posts set caption = 'hacked' where id = '50000000-0000-0000-0000-00000000000a';
    assert (select caption from posts where id = '50000000-0000-0000-0000-00000000000a') <> 'hacked',
      'B must not edit A''s post';
  end;
  begin
    perform respond_rights_request(gen_random_uuid(), true);
    assert false, 'unknown request must raise';
  exception when raise_exception then null; end;
end $$;

-- ---------- counters & notifications (checked as superuser) ----------
reset role;
do $$ begin
  assert (select likes_count    from posts where id = '50000000-0000-0000-0000-00000000000a') = 1, 'likes_count';
  assert (select saves_count    from posts where id = '50000000-0000-0000-0000-00000000000a') = 1, 'saves_count';
  assert (select comments_count from posts where id = '50000000-0000-0000-0000-00000000000a') = 1, 'comments_count';
  assert (select posts_count     from profiles where id = 'aaaaaaaa-0000-0000-0000-000000000001') = 1, 'posts_count';
  assert (select followers_count from profiles where id = 'aaaaaaaa-0000-0000-0000-000000000001') = 1, 'followers_count';
  assert (select following_count from profiles where id = 'bbbbbbbb-0000-0000-0000-000000000002') = 1, 'following_count';
  assert (select styled_count from products where id = 'a0000000-0000-0000-0000-000000000001') = 1, 'styled_count';
  assert (select count(*) from notifications where recipient_id = 'aaaaaaaa-0000-0000-0000-000000000001') = 3,
    'A should have like + comment + follow notifications';
end $$;

-- ---------- A deletes B's comment on her post; B can't see A's notifications ----------
set role authenticated;
select test_as('aaaaaaaa-0000-0000-0000-000000000001');
select delete_comment('c0000000-0000-0000-0000-000000000001');
select test_as('bbbbbbbb-0000-0000-0000-000000000002');
do $$ begin
  assert (select count(*) from notifications) = 0, 'B has no notifications and cannot see A''s';
  assert (select count(*) from comments) = 0, 'deleted comment hidden';
  begin
    update comments set body = 'edited' where id = 'c0000000-0000-0000-0000-000000000001';
  end;
end $$;
reset role;
do $$ begin
  assert (select comments_count from posts where id = '50000000-0000-0000-0000-00000000000a') = 0, 'comments_count after delete';
end $$;

-- ---------- private account ----------
set role authenticated;
select test_as('cccccccc-0000-0000-0000-000000000003');
insert into posts (id, author_id, caption) values ('50000000-0000-0000-0000-00000000000c', 'cccccccc-0000-0000-0000-000000000003', 'private look');
select test_as('bbbbbbbb-0000-0000-0000-000000000002');
do $$ begin
  assert (select count(*) from posts where id = '50000000-0000-0000-0000-00000000000c') = 0, 'private post hidden from non-follower';
end $$;
insert into follows (follower_id, followee_id) values ('bbbbbbbb-0000-0000-0000-000000000002', 'cccccccc-0000-0000-0000-000000000003');
do $$ begin
  assert (select count(*) from posts where id = '50000000-0000-0000-0000-00000000000c') = 1, 'private post visible to follower';
end $$;

-- ---------- brand workspace ----------
select test_as('dddddddd-0000-0000-0000-000000000004');   -- COS editor
insert into products (brand_id, ref_code, name, category, price_uzs)
  values ('b0000000-0000-0000-0000-00000000c05a', '1199402', 'Minimalist Wool Coat', 'outerwear', 4200000);
insert into store_stock (store_id, variant_id, quantity)
  values ('5e000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 3);
do $$ begin
  begin
    insert into products (brand_id, name, category) values ('b0000000-0000-0000-0000-0000000000a2', 'Fake Zara item', 'tops');
    assert false, 'COS member must not add Zara products';
  exception when insufficient_privilege then null; end;
  begin
    insert into store_stock (store_id, variant_id, quantity)
      values ('5e000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000002', 1);
    assert false, 'cannot stock another brand''s variant';
  exception when insufficient_privilege then null; end;
  begin
    update brands set is_verified = true where id = 'b0000000-0000-0000-0000-00000000c05a';
    assert false, 'verification is admin-only';
  exception when insufficient_privilege then null; end;
end $$;
insert into brand_features (brand_id, post_id, featured_by)
  values ('b0000000-0000-0000-0000-00000000c05a', '50000000-0000-0000-0000-00000000000a', 'dddddddd-0000-0000-0000-000000000004');
insert into rights_requests (id, brand_id, post_id, creator_id, requested_by, channels, message) values
 ('77000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-00000000c05a', '50000000-0000-0000-0000-00000000000a',
  'aaaaaaaa-0000-0000-0000-000000000001', 'dddddddd-0000-0000-0000-000000000004', '{social}',
  'Could COS share this on Instagram for 90 days?');
insert into rewards (brand_id, recipient_id, post_id, percent_off, code, created_by, expires_at) values
 ('b0000000-0000-0000-0000-00000000c05a', 'aaaaaaaa-0000-0000-0000-000000000001', '50000000-0000-0000-0000-00000000000a',
  15, 'COS-AZIZA-15', 'dddddddd-0000-0000-0000-000000000004', now() + interval '30 days');

-- random user X cannot do brand things or answer someone else's request
select test_as('eeeeeeee-0000-0000-0000-000000000005');
do $$ begin
  begin
    insert into brand_features (brand_id, post_id) values ('b0000000-0000-0000-0000-00000000c05a', '50000000-0000-0000-0000-00000000000a');
    assert false, 'non-member cannot feature';
  exception when insufficient_privilege or unique_violation then null; end;
  begin
    perform respond_rights_request('77000000-0000-0000-0000-000000000001', true);
    assert false, 'only the creator may respond';
  exception when raise_exception then null; end;
  assert (select count(*) from rewards) = 0, 'X cannot see vouchers';
  assert (select count(*) from rights_requests) = 0, 'X cannot see rights requests';
end $$;

-- A accepts the request and sees her voucher
select test_as('aaaaaaaa-0000-0000-0000-000000000001');
select status from respond_rights_request('77000000-0000-0000-0000-000000000001', true);
do $$ begin
  assert (select code from rewards limit 1) = 'COS-AZIZA-15', 'recipient sees voucher code';
  assert (select expires_at::date from rights_requests) = (now() + interval '90 days')::date, '90-day expiry';
  -- turning the feature toggle off clears consent
  update posts set allow_brand_feature = false where id = '50000000-0000-0000-0000-00000000000a';
  assert (select brand_consent_at from posts where id = '50000000-0000-0000-0000-00000000000a') is null;
end $$;

-- COS cannot feature a post once the creator turned the toggle off
select test_as('dddddddd-0000-0000-0000-000000000004');
delete from brand_features where post_id = '50000000-0000-0000-0000-00000000000a';
do $$ begin
  begin
    insert into brand_features (brand_id, post_id) values ('b0000000-0000-0000-0000-00000000c05a', '50000000-0000-0000-0000-00000000000a');
    assert false, 'feature must respect creator toggle';
  exception when insufficient_privilege then null; end;
  assert (select count(*) from notifications where type = 'rights_response') = 1, 'brand notified of response';
end $$;

-- ---------- guests ----------
reset role;
set role anon;
select test_as(null);
do $$ begin
  assert (select count(*) from feed_for_you()) >= 1, 'guest sees For You feed';
  assert (select count(*) from trending_in_city('Tashkent')) >= 1, 'guest sees trending';
  assert (select count(*) from search_all('blaz')) >= 1, 'search finds the blazer';
  assert (select count(*) from search_all('cos')) >= 1, 'search finds COS';
  begin
    insert into likes (user_id, post_id) values (gen_random_uuid(), '50000000-0000-0000-0000-00000000000a');
    assert false, 'guest cannot like';
  exception when insufficient_privilege then null; end;
  perform log_event('product_view', null, 'a0000000-0000-0000-0000-000000000001', null, null, 'device-123', 'Tashkent');
  perform log_event('shop_click',   null, 'a0000000-0000-0000-0000-000000000001', null, null, 'device-123', 'Tashkent');
  begin
    perform count(*) from events;
    assert false, 'events are not readable';
  exception when insufficient_privilege then null; end;
end $$;

-- ---------- blocking ----------
reset role;
set role authenticated;
select test_as('aaaaaaaa-0000-0000-0000-000000000001');
insert into blocks (blocker_id, blocked_id) values ('aaaaaaaa-0000-0000-0000-000000000001', 'bbbbbbbb-0000-0000-0000-000000000002');
select test_as('bbbbbbbb-0000-0000-0000-000000000002');
do $$ begin
  assert (select count(*) from posts where author_id = 'aaaaaaaa-0000-0000-0000-000000000001') = 0, 'blocked user cannot see posts';
  assert (select count(*) from follows where followee_id = 'aaaaaaaa-0000-0000-0000-000000000001') = 0, 'block removes follow';
  begin
    insert into follows (follower_id, followee_id) values ('bbbbbbbb-0000-0000-0000-000000000002', 'aaaaaaaa-0000-0000-0000-000000000001');
    assert false, 'blocked user cannot re-follow';
  exception when insufficient_privilege then null; end;
end $$;

-- ---------- nightly rollup + brand analytics ----------
reset role;
update events set occurred_at = now() - interval '1 day';
select rollup_brand_stats();
set role authenticated;
select test_as('dddddddd-0000-0000-0000-000000000004');
do $$ begin
  assert (select shop_clicks from brand_daily_stats where brand_id = 'b0000000-0000-0000-0000-00000000c05a') = 1, 'COS sees its stats';
end $$;
select test_as('bbbbbbbb-0000-0000-0000-000000000002');
do $$ begin
  assert (select count(*) from brand_daily_stats) = 0, 'non-member cannot read stats';
  begin
    perform rollup_brand_stats();
    assert false, 'rollup is not callable by users';
  exception when insufficient_privilege then null; end;
end $$;

-- ---------- author deletes post ----------
select test_as('aaaaaaaa-0000-0000-0000-000000000001');
select delete_post('50000000-0000-0000-0000-00000000000a');
reset role;
do $$ begin
  assert (select posts_count from profiles where id = 'aaaaaaaa-0000-0000-0000-000000000001') = 0, 'posts_count after delete';
  assert (select status from rights_requests) = 'revoked', 'deleting a post revokes reuse rights';
  assert (select styled_count from products where id = 'a0000000-0000-0000-0000-000000000001') = 0,
    'styled_count drops when the post is deleted';
end $$;

\echo ALL TESTS PASSED

rollback;
