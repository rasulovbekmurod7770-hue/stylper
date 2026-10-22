-- =====================================================================
-- Stylper — 0002: one namespace for usernames and brand slugs
-- ---------------------------------------------------------------------
-- People and brands share one handle namespace: Search finds both by
-- handle, and both will get a page at stylper.app/<handle>. So
--   * a username may not equal any brand slug,
--   * a brand slug may not equal any username,
--   * neither may be a reserved name (routes and official accounts).
-- Comparison is case-insensitive (both columns are citext).
--
-- A clash raises unique_violation (23505), exactly like a username that
-- another person already has, so the app shows its "username taken" message.
-- The rule also binds Stylper admins: brands created with the service role
-- are checked too.
-- =====================================================================

-- Names nobody can take, people or brands. Changing the list needs a
-- migration, so it is reviewed like the rest of the schema.
create or replace function is_reserved_handle(p_handle text)
returns boolean language sql immutable as $$
  select lower(p_handle) = any (array['stylper', 'admin', 'support', 'help', 'api', 'www', 'settings'])
$$;

-- Raises unique_violation unless p_handle is free for a profile
-- (p_for = 'profile') or a brand (p_for = 'brand'). Each table's own unique
-- constraint already covers clashes within it.
--
-- Security definer, so the lookup sees every row (RLS hides blocked users'
-- profiles from the caller). The advisory lock serialises claims of the same
-- handle across both tables, so two concurrent transactions can't take it
-- as a username and as a slug at the same time.
create or replace function assert_handle_available(p_handle citext, p_for text)
returns void language plpgsql security definer set search_path = public as $$
begin
  perform pg_advisory_xact_lock(hashtext('stylper.handle:' || lower(p_handle)));
  if is_reserved_handle(p_handle) then
    raise exception using errcode = 'unique_violation',
      message = format('handle "%s" is reserved', p_handle);
  end if;
  if p_for = 'profile' and exists (select 1 from brands where slug = p_handle) then
    raise exception using errcode = 'unique_violation',
      message = format('handle "%s" belongs to a brand', p_handle);
  end if;
  if p_for = 'brand' and exists (select 1 from profiles where username = p_handle) then
    raise exception using errcode = 'unique_violation',
      message = format('handle "%s" belongs to a person', p_handle);
  end if;
end $$;
revoke all on function assert_handle_available(citext, text) from public, anon, authenticated;

-- Checked only when the handle is set or actually changes, so saving a
-- profile or brand with the same handle (or other fields) never fails.
create or replace function trg_profiles_handle() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.username is not null and (tg_op = 'INSERT' or new.username is distinct from old.username) then
    perform assert_handle_available(new.username, 'profile');
  end if;
  return new;
end $$;
create trigger profiles_handle before insert or update of username on profiles
  for each row execute function trg_profiles_handle();

create or replace function trg_brands_handle() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if tg_op = 'INSERT' or new.slug is distinct from old.slug then
    perform assert_handle_available(new.slug, 'brand');
  end if;
  return new;
end $$;
create trigger brands_handle before insert or update of slug on brands
  for each row execute function trg_brands_handle();

-- Existing data must already follow the rule; stop here if it doesn't.
do $$ begin
  if exists (select 1 from profiles p join brands b on b.slug = p.username)
     or exists (select 1 from profiles where is_reserved_handle(username))
     or exists (select 1 from brands where is_reserved_handle(slug)) then
    raise exception 'usernames and brand slugs clash; rename them before applying 0002';
  end if;
end $$;
