-- =====================================================================
-- Stylper — 0003: styles are fixed keys
-- ---------------------------------------------------------------------
-- posts.styles (chosen when posting) and profiles.style_dna (from the
-- style quiz) hold keys, never display words:
--   minimal, casual, streetwear, neutral, oversized, smart_casual
-- The app shows translated labels (en/ru/uz). "For you" ranks posts by
-- matching their styles against the viewer's Style DNA, so both columns
-- must use the same keys; the database rejects anything else.
--
-- Adding a style: a migration that replaces style_keys() with a longer
-- list, plus its labels in the app.
-- =====================================================================

create or replace function style_keys() returns text[]
language sql immutable as $$
  select array['minimal', 'casual', 'streetwear', 'neutral', 'oversized', 'smart_casual']
$$;

-- ---------------------------------------------------------------------
-- Convert the English words stored so far. Street and Streetwear become
-- one key; Layered (only ever on a demo account) becomes oversized.
-- Anything else stops the migration rather than being dropped.
-- ---------------------------------------------------------------------
create function pg_temp.style_key(p_word text) returns text
language sql immutable as $$
  select case lower(trim(p_word))
    when 'minimal'      then 'minimal'
    when 'casual'       then 'casual'
    when 'street'       then 'streetwear'
    when 'streetwear'   then 'streetwear'
    when 'neutral'      then 'neutral'
    when 'oversized'    then 'oversized'
    when 'smart casual' then 'smart_casual'
    when 'smart_casual' then 'smart_casual'
    when 'layered'      then 'oversized'
  end
$$;

-- Keys in their first-seen order, without duplicates: Style DNA lists the
-- strongest style first.
create function pg_temp.style_keys_of(p_words text[]) returns text[]
language sql immutable as $$
  select coalesce(array_agg(key order by first_seen), '{}')
  from (select pg_temp.style_key(word) as key, min(n) as first_seen
        from unnest(p_words) with ordinality as w(word, n)
        group by 1) keys
$$;

do $$ begin
  if exists (select 1 from posts, unnest(styles) as w(word) where pg_temp.style_key(word) is null)
     or exists (select 1 from profiles, unnest(style_dna) as w(word) where pg_temp.style_key(word) is null) then
    raise exception 'unknown style values; map them in 0003 before applying it';
  end if;
end $$;

update posts    set styles    = pg_temp.style_keys_of(styles)    where styles    <> '{}';
update profiles set style_dna = pg_temp.style_keys_of(style_dna) where style_dna <> '{}';

alter table posts    add constraint posts_styles_known       check (styles    <@ style_keys());
alter table profiles add constraint profiles_style_dna_known check (style_dna <@ style_keys());
