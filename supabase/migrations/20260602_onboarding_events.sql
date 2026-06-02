-- onboarding_events: lightweight analytics table for PR-ONBOARD-AB A/B test.
-- Rows are inserted pre-auth (anon), so user_id is nullable.
-- device_id provides cross-session linkage before auth.

create table public.onboarding_events (
  id         uuid        primary key default gen_random_uuid(),
  user_id    uuid        references auth.users on delete cascade,
  device_id  text,
  event_name text        not null,
  variant    text        not null,
  properties jsonb       default '{}'::jsonb,
  created_at timestamptz default now()
);

create index on public.onboarding_events (user_id, created_at desc);
create index on public.onboarding_events (variant, event_name);

-- Enable RLS
alter table public.onboarding_events enable row level security;

-- Anon and authenticated users may insert (no select/update/delete for anon).
-- This is required for pre-auth analytics (OQ5 ruling: anon insert path).
create policy "anon and authenticated can insert onboarding events"
  on public.onboarding_events
  for insert
  to anon, authenticated
  with check (true);

-- Authenticated users can read their own rows (backfill after auth if needed).
create policy "users can read own onboarding events"
  on public.onboarding_events
  for select
  to authenticated
  using (auth.uid() = user_id);
