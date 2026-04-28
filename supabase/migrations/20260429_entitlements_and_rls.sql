-- ═══════════════════════════════════════════════════════════════════════════
-- Server-side entitlement enforcement
--
-- What this migration does:
--   1. Creates public.user_entitlements — the source of truth for which
--      RevenueCat entitlements each user currently has.
--   2. Creates private.has_entitlement() — a SECURITY DEFINER helper so
--      RLS policies can query entitlements without infinite recursion or
--      leaking data across users.
--   3. Adds RLS policies on:
--        • spaces        — only users with spaces_pro can create spaces
--        • tasks         — enforce freeTasksLimit (20) for users without
--                          spaces_pro / sync_pro
--        • habits        — enforce freeHabitsLimit (5) for the same set
--   4. Grants the 'service_role' the right to upsert user_entitlements
--      (used by the Edge Function that receives RevenueCat webhooks).
--
-- Free-tier limits (must stay in sync with SubscriptionConfig in Dart):
--   freeTasksLimit  = 20
--   freeHabitsLimit = 5
-- ═══════════════════════════════════════════════════════════════════════════

begin;

-- ── 1. user_entitlements table ─────────────────────────────────────────────

create table if not exists public.user_entitlements (
  user_id          uuid        not null references auth.users(id) on delete cascade,
  entitlement_id   text        not null,   -- e.g. 'spaces_pro', 'sync_pro', 'health_pack', 'assets_pack'
  is_active        boolean     not null default false,
  expires_at       timestamptz,            -- null = lifetime purchase
  updated_at       timestamptz not null default now(),

  primary key (user_id, entitlement_id)
);

-- Fast lookup by user
create index if not exists user_entitlements_user_id_idx
  on public.user_entitlements (user_id);

-- RLS on the table itself
alter table public.user_entitlements enable row level security;

-- Users can read only their own entitlements
create policy "entitlements_select_own"
  on public.user_entitlements
  for select
  to authenticated
  using (user_id = auth.uid());

-- Only service_role (Edge Function) may write
create policy "entitlements_service_role_write"
  on public.user_entitlements
  for all
  to service_role
  using (true)
  with check (true);

-- ── 2. private helper ─────────────────────────────────────────────────────

create schema if not exists private;
grant usage on schema private to authenticated;

-- Returns true when the given user has an active, non-expired entitlement.
create or replace function private.has_entitlement(
  p_user_id      uuid,
  p_entitlement  text
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.user_entitlements
    where user_id       = p_user_id
      and entitlement_id = p_entitlement
      and is_active      = true
      and (expires_at is null or expires_at > now())
  );
$$;

-- Returns the number of active (non-deleted) rows a user owns in a table.
-- Used inline in policy expressions.
-- NOTE: used for task/habit count checks — see policies below.
create or replace function private.count_user_tasks(p_user_id uuid)
returns bigint
language sql
stable
security definer
set search_path = public
as $$
  -- Count all tasks owned by the user (tasks are hard-deleted on the server;
  -- soft-delete is Isar-local only, so no deleted_at column exists here).
  select count(*)
  from public.tasks
  where created_by = p_user_id;
$$;

create or replace function private.count_user_habits(p_user_id uuid)
returns bigint
language sql
stable
security definer
set search_path = public
as $$
  -- Same reasoning — habits are hard-deleted on the server.
  select count(*)
  from public.habits
  where user_id = p_user_id;
$$;

-- ── 3. RLS — spaces ───────────────────────────────────────────────────────
-- Users need spaces_pro to CREATE a space.
-- Reading/updating their own spaces is always allowed.

alter table public.spaces enable row level security;

-- Drop & recreate to avoid duplicate-policy errors on re-run
drop policy if exists "spaces_select_own_or_member"  on public.spaces;
drop policy if exists "spaces_insert_pro_only"        on public.spaces;
drop policy if exists "spaces_update_owner"           on public.spaces;
drop policy if exists "spaces_delete_owner"           on public.spaces;

create policy "spaces_select_own_or_member"
  on public.spaces
  for select
  to authenticated
  using (
    owner_id = auth.uid()
    or private.is_space_member(uuid, auth.uid())
  );

create policy "spaces_insert_pro_only"
  on public.spaces
  for insert
  to authenticated
  with check (
    owner_id = auth.uid()
    and private.has_entitlement(auth.uid(), 'spaces_pro')
  );

create policy "spaces_update_owner"
  on public.spaces
  for update
  to authenticated
  using  (owner_id = auth.uid())
  with check (owner_id = auth.uid());

create policy "spaces_delete_owner"
  on public.spaces
  for delete
  to authenticated
  using (owner_id = auth.uid());

-- ── 4. RLS — tasks ────────────────────────────────────────────────────────
-- Free tier: max 20 tasks (freeTasksLimit).
-- Unlimited for users with spaces_pro OR sync_pro.

alter table public.tasks enable row level security;

drop policy if exists "tasks_select_own"    on public.tasks;
drop policy if exists "tasks_insert_limit"  on public.tasks;
drop policy if exists "tasks_update_own"    on public.tasks;
drop policy if exists "tasks_delete_own"    on public.tasks;

create policy "tasks_select_own"
  on public.tasks
  for select
  to authenticated
  using (created_by = auth.uid());

create policy "tasks_insert_limit"
  on public.tasks
  for insert
  to authenticated
  with check (
    created_by = auth.uid()
    and (
      -- paid users have no limit
      private.has_entitlement(auth.uid(), 'spaces_pro')
      or private.has_entitlement(auth.uid(), 'sync_pro')
      -- free users may not exceed 20
      or private.count_user_tasks(auth.uid()) < 20
    )
  );

create policy "tasks_update_own"
  on public.tasks
  for update
  to authenticated
  using  (created_by = auth.uid())
  with check (created_by = auth.uid());

create policy "tasks_delete_own"
  on public.tasks
  for delete
  to authenticated
  using (created_by = auth.uid());

-- ── 5. RLS — habits ───────────────────────────────────────────────────────
-- Free tier: max 5 habits (freeHabitsLimit).
-- Unlimited for users with spaces_pro OR sync_pro.

alter table public.habits enable row level security;

drop policy if exists "habits_select_own"   on public.habits;
drop policy if exists "habits_insert_limit" on public.habits;
drop policy if exists "habits_update_own"   on public.habits;
drop policy if exists "habits_delete_own"   on public.habits;

create policy "habits_select_own"
  on public.habits
  for select
  to authenticated
  using (user_id = auth.uid());

create policy "habits_insert_limit"
  on public.habits
  for insert
  to authenticated
  with check (
    user_id = auth.uid()
    and (
      private.has_entitlement(auth.uid(), 'spaces_pro')
      or private.has_entitlement(auth.uid(), 'sync_pro')
      or private.count_user_habits(auth.uid()) < 5
    )
  );

create policy "habits_update_own"
  on public.habits
  for update
  to authenticated
  using  (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "habits_delete_own"
  on public.habits
  for delete
  to authenticated
  using (user_id = auth.uid());

-- ── 6. Grant helper functions ─────────────────────────────────────────────

revoke all on function private.has_entitlement(uuid, text)    from public;
revoke all on function private.count_user_tasks(uuid)         from public;
revoke all on function private.count_user_habits(uuid)        from public;

grant execute on function private.has_entitlement(uuid, text)    to authenticated;
grant execute on function private.count_user_tasks(uuid)         to authenticated;
grant execute on function private.count_user_habits(uuid)        to authenticated;

commit;
