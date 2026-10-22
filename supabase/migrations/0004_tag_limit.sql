-- =====================================================================
-- Stylper — 0004: at most 10 tags per photo
-- ---------------------------------------------------------------------
-- People tag every layer they wear (a jacket over a t-shirt, a scarf over
-- a coat), so tags sit close together; past 10 a photo stops being
-- readable. The app stops at 10 as well (spec §7, "Layered outfits").
-- An 11th tag raises check_violation (23514).
-- =====================================================================

-- Security definer, so the count sees every tag on the photo whatever the
-- caller may read. Locking the photo's row first serialises concurrent
-- inserts, so two of them can't both see 9 tags and make it 11.
create or replace function trg_post_tags_limit() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  perform 1 from post_images where id = new.post_image_id for update;
  if (select count(*) from post_tags
      where post_image_id = new.post_image_id and id <> new.id) >= 10 then
    raise exception using errcode = 'check_violation',
      message = 'a photo takes at most 10 tags';
  end if;
  return new;
end $$;
create trigger post_tags_limit before insert or update of post_image_id on post_tags
  for each row execute function trg_post_tags_limit();

-- Existing photos must already follow the rule; stop here if one doesn't.
do $$ begin
  if exists (select 1 from post_tags group by post_image_id having count(*) > 10) then
    raise exception 'a photo has more than 10 tags; remove some before applying 0004';
  end if;
end $$;
