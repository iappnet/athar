-- Fix recursive RLS policies on public.space_members
--
-- Diagnosis:
-- The existing policy on public.space_members is recursively referencing
-- public.space_members inside a policy expression. When Postgres evaluates
-- the policy, it re-enters the same policy and throws:
--   42P17 infinite recursion detected in policy for relation "space_members"
--
-- This migration replaces direct self-references inside policy expressions
-- with SECURITY DEFINER helper functions. Those helpers execute as the
-- function owner and do not recurse through the table's RLS policy.

begin;

create schema if not exists private;
grant usage on schema private to authenticated;

create or replace function private.is_space_member(
  p_space_id uuid,
  p_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.space_members sm
    where sm.space_id = p_space_id
      and sm.user_id = p_user_id
  );
$$;

create or replace function private.is_space_admin(
  p_space_id uuid,
  p_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.space_members sm
    where sm.space_id = p_space_id
      and sm.user_id = p_user_id
      and sm.role in ('owner', 'admin')
  );
$$;

create or replace function private.is_space_owner(
  p_space_id uuid,
  p_user_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.spaces s
    where s.uuid = p_space_id
      and s.owner_id = p_user_id
  );
$$;

create or replace function private.has_pending_space_invitation(
  p_space_id uuid,
  p_user_id uuid,
  p_email text
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.invitations i
    where i.space_id = p_space_id
      and i.status = 'pending'
      and (
        i.invitee_id = p_user_id
        or (p_email is not null and i.invitee_email = p_email)
      )
  );
$$;

alter table public.space_members enable row level security;

do $$
declare
  policy_name text;
begin
  for policy_name in
    select pol.policyname
    from pg_policies pol
    where pol.schemaname = 'public'
      and pol.tablename = 'space_members'
  loop
    execute format(
      'drop policy if exists %I on public.space_members',
      policy_name
    );
  end loop;
end
$$;

create policy "space_members_select_visible_to_members"
on public.space_members
for select
to authenticated
using (
  auth.uid() = user_id
  or private.is_space_member(space_id, auth.uid())
  or private.is_space_owner(space_id, auth.uid())
);

create policy "space_members_insert_owner_admin_or_invited"
on public.space_members
for insert
to authenticated
with check (
  auth.uid() = user_id
  and (
    private.is_space_owner(space_id, auth.uid())
    or private.is_space_admin(space_id, auth.uid())
    or private.has_pending_space_invitation(
      space_id,
      auth.uid(),
      auth.jwt() ->> 'email'
    )
  )
);

create policy "space_members_update_owner_or_admin"
on public.space_members
for update
to authenticated
using (
  private.is_space_owner(space_id, auth.uid())
  or (
    private.is_space_admin(space_id, auth.uid())
    and role <> 'owner'
  )
)
with check (
  private.is_space_owner(space_id, auth.uid())
  or (
    private.is_space_admin(space_id, auth.uid())
    and role <> 'owner'
  )
);

create policy "space_members_delete_owner_or_admin"
on public.space_members
for delete
to authenticated
using (
  private.is_space_owner(space_id, auth.uid())
  or (
    private.is_space_admin(space_id, auth.uid())
    and role <> 'owner'
  )
);

revoke all on function private.is_space_member(uuid, uuid) from public;
revoke all on function private.is_space_admin(uuid, uuid) from public;
revoke all on function private.is_space_owner(uuid, uuid) from public;
revoke all on function private.has_pending_space_invitation(uuid, uuid, text) from public;

grant execute on function private.is_space_member(uuid, uuid) to authenticated;
grant execute on function private.is_space_admin(uuid, uuid) to authenticated;
grant execute on function private.is_space_owner(uuid, uuid) to authenticated;
grant execute on function private.has_pending_space_invitation(uuid, uuid, text) to authenticated;

commit;
