-- =====================================================================
-- Stylper — demo data for LOCAL DEVELOPMENT ONLY
-- ---------------------------------------------------------------------
-- Loaded by `npx supabase db reset` (config.toml [db.seed]) after the
-- migrations. Deliberately NOT a migration: seed data must never reach a
-- real project.
--
-- Mirrors the Flutter prototype's FakeBackend content: COS, UNIQLO, ZARA
-- and ARKET with their catalog (prices in soʻm), one COS store, five
-- people, and eight public outfit posts with tagged items.
--
-- Sign in as any of them with password `stylper123`:
--   developer@stylper.ai (john) · katty.miller@stylper.ai · leo@stylper.ai
--   mina@stylper.ai · fozil@stylper.ai
--
-- Images: R2 isn't set up yet, so media rows point at placeholder keys
-- under `seed/` (named after the app's bundled demo photos), not real
-- objects.
--
-- Counters (likes, followers, styled_count, …) are left to the triggers,
-- as for real users.
-- =====================================================================

-- ---------- people ----------
-- Real Supabase auth users with a password and a confirmed email; the
-- signup trigger creates their profiles. GoTrue can't read NULL tokens,
-- hence the ''s.
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
)
select '00000000-0000-0000-0000-000000000000', id, 'authenticated', 'authenticated',
       email, extensions.crypt('stylper123', extensions.gen_salt('bf')), now(),
       '{"provider":"email","providers":["email"]}', jsonb_build_object('full_name', name),
       now(), now(), '', '', '', ''
from (values
  ('a0000000-0000-4000-8000-000000000001'::uuid, 'developer@stylper.ai',    'John. B'),
  ('a0000000-0000-4000-8000-000000000002'::uuid, 'katty.miller@stylper.ai', 'Katty Miller'),
  ('a0000000-0000-4000-8000-000000000003'::uuid, 'leo@stylper.ai',          'Leo'),
  ('a0000000-0000-4000-8000-000000000004'::uuid, 'mina@stylper.ai',         'Mina Cho'),
  ('a0000000-0000-4000-8000-000000000005'::uuid, 'fozil@stylper.ai',        'Fozil Can Fly')
) as u(id, email, name);

insert into auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
select id::text, id, jsonb_build_object('sub', id::text, 'email', email, 'email_verified', true),
       'email', now(), now(), now()
from auth.users where email like '%@stylper.ai';

update profiles p set
  username = v.username, bio = v.bio, style_dna = v.style_dna, onboarded_at = now()
from (values
  ('a0000000-0000-4000-8000-000000000001'::uuid, 'john',         'Minimalist fashion lover | NYC', '{minimal,casual,streetwear,neutral,oversized}'::text[]),
  ('a0000000-0000-4000-8000-000000000002'::uuid, 'katty_miller', null,                             '{casual}'::text[]),
  ('a0000000-0000-4000-8000-000000000003'::uuid, 'leo',          'Knitwear collector',             '{streetwear,casual}'::text[]),
  ('a0000000-0000-4000-8000-000000000004'::uuid, 'mina',         'Sneakers first, outfit second',  '{casual,streetwear}'::text[]),
  ('a0000000-0000-4000-8000-000000000005'::uuid, 'fozil',        'Tashkent streets',               '{streetwear,oversized}'::text[])
) as v(id, username, bio, style_dna)
where p.id = v.id;

-- Avatars for the three who have a photo in the prototype.
insert into media (id, owner_id, kind, full_key, thumb_key, width, height, bytes, blurhash, status) values
  ('e3000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000003', 'avatar', 'seed/avatar/leo_1080.webp',   'seed/avatar/leo_400.webp',   400, 400, 24000, 'L6PZfSi_.AyE_3t7t7R**0o#DgR4', 'ready'),
  ('e3000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000004', 'avatar', 'seed/avatar/mina_1080.webp',  'seed/avatar/mina_400.webp',  400, 400, 24000, 'L6PZfSi_.AyE_3t7t7R**0o#DgR4', 'ready'),
  ('e3000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000005', 'avatar', 'seed/avatar/fozil_1080.webp', 'seed/avatar/fozil_400.webp', 400, 400, 24000, 'L6PZfSi_.AyE_3t7t7R**0o#DgR4', 'ready');
update profiles set avatar_media_id = ('e3000000-0000-4000-8000-00000000000' || right(id::text, 1))::uuid
where id in ('a0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000004',
             'a0000000-0000-4000-8000-000000000005');

-- ---------- brands, store, catalog ----------
insert into brands (id, slug, name, tagline, website_url, is_verified) values
  ('b0000000-0000-4000-8000-000000000001', 'cos',    'COS',    'Modern essentials for timeless style', 'https://www.cos.com',    true),
  ('b0000000-0000-4000-8000-000000000002', 'uniqlo', 'UNIQLO', 'LifeWear',                             'https://www.uniqlo.com', true),
  ('b0000000-0000-4000-8000-000000000003', 'zara',   'ZARA',   null,                                   'https://www.zara.com',   true),
  ('b0000000-0000-4000-8000-000000000004', 'arket',  'ARKET',  'A modern-day market',                  'https://www.arket.com',  true);

insert into stores (id, brand_id, name, address, lat, lng, opening_hours) values
  ('d0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001',
   'COS Tashkent City Mall', 'Tashkent City Mall', 41.3167, 69.2486,
   '{"mon":"10:00-22:00","tue":"10:00-22:00","wed":"10:00-22:00","thu":"10:00-22:00","fri":"10:00-22:00","sat":"10:00-22:00","sun":"10:00-22:00"}');

-- Prices in soʻm, as in the app.
insert into products (id, brand_id, name, description, category, price_uzs, external_url) values
  ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Cotton Cardigan',            'Relaxed cardigan in soft cotton knit.',         'tops',      1130000, 'https://www.cos.com'),
  ('c0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000001', 'Wool Oversized Blazer',      'Single-breasted blazer in a wool blend.',       'outerwear', 2950000, 'https://www.cos.com'),
  ('c0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000002', 'Striped Long Sleeve',        'Breton-stripe cotton long-sleeve T-shirt.',     'tops',       320000, 'https://www.uniqlo.com'),
  ('c0000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000002', 'Waffle Long-Sleeve',         'Waffle-knit crew neck.',                        'tops',       370000, 'https://www.uniqlo.com'),
  ('c0000000-0000-4000-8000-000000000005', 'b0000000-0000-4000-8000-000000000003', 'Oversized White T-Shirt',    'Heavy cotton tee with dropped shoulders.',      'tops',       240000, 'https://www.zara.com'),
  ('c0000000-0000-4000-8000-000000000006', 'b0000000-0000-4000-8000-000000000003', 'Wide Leg Tailored Trousers', 'High-waisted trousers with front pleats.',      'bottoms',    700000, 'https://www.zara.com'),
  ('c0000000-0000-4000-8000-000000000007', 'b0000000-0000-4000-8000-000000000003', 'Vintage Jeans',              'Straight-leg jeans in a washed blue.',          'bottoms',    570000, 'https://www.zara.com'),
  ('c0000000-0000-4000-8000-000000000008', 'b0000000-0000-4000-8000-000000000004', 'Rugby Polo Sweater',         'Knitted rugby polo with a contrast collar.',    'tops',      1000000, 'https://www.arket.com');

-- A colour in a few sizes each.
insert into product_variants (id, product_id, color, size)
select ('c1000000-0000-4000-8000-0000000000' || lpad((row_number() over ())::text, 2, '0'))::uuid,
       product_id, color, size
from (values
  ('c0000000-0000-4000-8000-000000000001'::uuid, 'Navy',  array['S','M','L']),
  ('c0000000-0000-4000-8000-000000000002'::uuid, 'Sand',  array['S','M','L']),
  ('c0000000-0000-4000-8000-000000000003'::uuid, 'Navy stripe', array['S','M','L']),
  ('c0000000-0000-4000-8000-000000000004'::uuid, 'Grey',  array['M','L']),
  ('c0000000-0000-4000-8000-000000000005'::uuid, 'White', array['S','M','L','XL']),
  ('c0000000-0000-4000-8000-000000000006'::uuid, 'Black', array['XS','S','M']),
  ('c0000000-0000-4000-8000-000000000007'::uuid, 'Blue',  array['S','M','L']),
  ('c0000000-0000-4000-8000-000000000008'::uuid, 'Green', array['M','L'])
) as v(product_id, color, sizes), unnest(v.sizes) as size;

-- The COS store has every COS size, a few of each.
insert into store_stock (store_id, variant_id, quantity)
select 'd0000000-0000-4000-8000-000000000001', pv.id, 2 + (row_number() over (order by pv.id))::int % 4
from product_variants pv
join products p on p.id = pv.product_id
where p.brand_id = 'b0000000-0000-4000-8000-000000000001';

-- One cut-out photo per product, owned by the brand.
insert into media (id, brand_id, kind, full_key, thumb_key, width, height, bytes, blurhash, status)
select ('e2000000-0000-4000-8000-' || right(p.id::text, 12))::uuid, p.brand_id, 'product',
       'seed/product/' || slug || '_1080.webp', 'seed/product/' || slug || '_400.webp',
       1080, 1080, 90000, 'L6PZfSi_.AyE_3t7t7R**0o#DgR4', 'ready'
from products p
join (values
  ('c0000000-0000-4000-8000-000000000001'::uuid, 'cotton_cardigan_cos'),
  ('c0000000-0000-4000-8000-000000000002'::uuid, 'wool_oversized_blazer_cos'),
  ('c0000000-0000-4000-8000-000000000003'::uuid, 'striped_long_sleeve_uniqlo'),
  ('c0000000-0000-4000-8000-000000000004'::uuid, 'waffle_long_sleeve_uniqlo'),
  ('c0000000-0000-4000-8000-000000000005'::uuid, 'oversized_white_tshirt_zara'),
  ('c0000000-0000-4000-8000-000000000006'::uuid, 'wide_leg_tailored_trousers_zara'),
  ('c0000000-0000-4000-8000-000000000007'::uuid, 'vintage_jeans_zara'),
  ('c0000000-0000-4000-8000-000000000008'::uuid, 'rugby_polo_sweater_arket')
) as s(id, slug) on s.id = p.id;

insert into product_images (product_id, media_id)
select p.id, ('e2000000-0000-4000-8000-' || right(p.id::text, 12))::uuid from products p;

-- ---------- wardrobe ----------
-- John saved two products and added clothes no brand here sells.
insert into wardrobe_items (id, owner_id, category, name, brand_name, product_id, source) values
  ('a1000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'tops',    'Cotton Cardigan', 'COS',        'c0000000-0000-4000-8000-000000000001', 'from_product'),
  ('a1000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'bottoms', 'Vintage Jeans',   'ZARA',       'c0000000-0000-4000-8000-000000000007', 'from_product'),
  ('a1000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001', 'tops',    'Grey Cardigan',   'TIMEOFLESS', null,                                   'manual');

-- ---------- posts ----------
-- Eight public outfits, newest first, each with a 1080×1429 photo (the
-- post screen's 390:516) and its tags at x/y % of the photo.
insert into posts (id, author_id, caption, location_text, city, styles, created_at)
select id, author_id, caption, 'Tashkent', 'Tashkent', styles, now() - hours * interval '1 hour'
from (values
  ('f0000000-0000-4000-8000-000000000001'::uuid, 'a0000000-0000-4000-8000-000000000003'::uuid, 'Utility chic',     '{streetwear}'::text[],         2),
  ('f0000000-0000-4000-8000-000000000002'::uuid, 'a0000000-0000-4000-8000-000000000004'::uuid, null,               '{casual}'::text[],         5),
  ('f0000000-0000-4000-8000-000000000003'::uuid, 'a0000000-0000-4000-8000-000000000005'::uuid, null,               '{streetwear,oversized}'::text[], 9),
  ('f0000000-0000-4000-8000-000000000004'::uuid, 'a0000000-0000-4000-8000-000000000001'::uuid, 'Rainy layers',     '{minimal}'::text[],        14),
  ('f0000000-0000-4000-8000-000000000005'::uuid, 'a0000000-0000-4000-8000-000000000002'::uuid, 'Stripes and denim', '{casual}'::text[],        20),
  ('f0000000-0000-4000-8000-000000000006'::uuid, 'a0000000-0000-4000-8000-000000000005'::uuid, 'I like my Outfit', '{minimal}'::text[],        27),
  ('f0000000-0000-4000-8000-000000000007'::uuid, 'a0000000-0000-4000-8000-000000000001'::uuid, 'Soft knit',        '{casual}'::text[],         36),
  ('f0000000-0000-4000-8000-000000000008'::uuid, 'a0000000-0000-4000-8000-000000000003'::uuid, null,               '{casual}'::text[],         48)
) as v(id, author_id, caption, styles, hours);

insert into media (id, owner_id, kind, full_key, thumb_key, width, height, bytes, blurhash, status)
select ('e1000000-0000-4000-8000-' || right(p.id::text, 12))::uuid, p.author_id, 'post',
       'seed/post/' || photo || '_1080.webp', 'seed/post/' || photo || '_400.webp',
       1080, 1429, 180000, 'L6PZfSi_.AyE_3t7t7R**0o#DgR4', 'ready'
from posts p
join (values
  ('f0000000-0000-4000-8000-000000000001'::uuid, 'utility_chic'),
  ('f0000000-0000-4000-8000-000000000002'::uuid, 'mina'),
  ('f0000000-0000-4000-8000-000000000003'::uuid, 'fozil'),
  ('f0000000-0000-4000-8000-000000000004'::uuid, 'john_coat'),
  ('f0000000-0000-4000-8000-000000000005'::uuid, 'sofia'),
  ('f0000000-0000-4000-8000-000000000006'::uuid, 'like_my_outfit'),
  ('f0000000-0000-4000-8000-000000000007'::uuid, 'john_knit'),
  ('f0000000-0000-4000-8000-000000000008'::uuid, 'leo')
) as s(id, photo) on s.id = p.id;

insert into post_images (id, post_id, media_id)
select ('f1000000-0000-4000-8000-' || right(id::text, 12))::uuid, id,
       ('e1000000-0000-4000-8000-' || right(id::text, 12))::uuid
from posts;

-- Tags point at a product; John's own cardigan points at his wardrobe item,
-- and a brand not on Stylper is a plain label. Wardrobe items are private,
-- so their tags carry a label everyone can read.
insert into post_tags (post_id, post_image_id, x_pct, y_pct, product_id, wardrobe_item_id, label)
select ('f0000000-0000-4000-8000-0000000000' || post)::uuid,
       ('f1000000-0000-4000-8000-0000000000' || post)::uuid,
       x, y,
       ('c0000000-0000-4000-8000-0000000000' || product)::uuid,
       ('a1000000-0000-4000-8000-0000000000' || item)::uuid,
       label
from (values
  ('01', 44, 36, '01',  null, null),                          -- Leo: COS cardigan
  ('01', 30, 84, '06',  null, null),                          --      ZARA trousers
  ('02', 30, 12, '06',  null, null),                          -- Mina: ZARA trousers
  ('03', 44, 16, '04',  null, null),                          -- Fozil: UNIQLO waffle
  ('03', 34, 70, null,  null, 'Kink · Baggy Jeans'),          --        not on Stylper yet
  ('04', 48, 30, '02',  null, null),                          -- John: COS blazer
  ('04', 50, 72, '06',  null, null),                          --       ZARA trousers
  ('05', 52, 22, '03',  null, null),                          -- Katty: UNIQLO stripes
  ('05', 44, 62, '07',  null, null),                          --        ZARA jeans
  ('06', 50, 42, '05',  null, null),                          -- Fozil: ZARA tee
  ('06', 50, 78, '06',  null, null),                          --        ZARA trousers
  ('07', 42, 24, null,  '03', 'TIMEOFLESS · Grey Cardigan'),  -- John: his own cardigan
  ('07', 50, 62, '07',  null, null),                          --       ZARA jeans
  ('08', 50, 26, '08',  null, null)                           -- Leo: ARKET polo
) as t(post, x, y, product, item, label);

-- ---------- a little social graph ----------
insert into follows (follower_id, followee_id) values
  ('a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003'),
  ('a0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000004'),
  ('a0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001'),
  ('a0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001'),
  ('a0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000005'),
  ('a0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000004');

insert into brand_follows (user_id, brand_id) values
  ('a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001'),
  ('a0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000003');

insert into likes (user_id, post_id) values
  ('a0000000-0000-4000-8000-000000000001', 'f0000000-0000-4000-8000-000000000001'),
  ('a0000000-0000-4000-8000-000000000002', 'f0000000-0000-4000-8000-000000000001'),
  ('a0000000-0000-4000-8000-000000000004', 'f0000000-0000-4000-8000-000000000001'),
  ('a0000000-0000-4000-8000-000000000001', 'f0000000-0000-4000-8000-000000000002'),
  ('a0000000-0000-4000-8000-000000000003', 'f0000000-0000-4000-8000-000000000004'),
  ('a0000000-0000-4000-8000-000000000005', 'f0000000-0000-4000-8000-000000000002');

insert into saves (user_id, post_id) values
  ('a0000000-0000-4000-8000-000000000001', 'f0000000-0000-4000-8000-000000000001'),
  ('a0000000-0000-4000-8000-000000000001', 'f0000000-0000-4000-8000-000000000006');
