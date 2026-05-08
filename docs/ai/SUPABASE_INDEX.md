# Athar — Supabase Index

## Directory Layout

```
supabase/
  migrations/
    20260420_fix_space_members_rls.sql   — RLS policy fix for space members table
    20260429_entitlements_and_rls.sql    — Entitlement + RLS updates (RevenueCat integration)
  functions/
    revenuecat-webhook/
      index.ts                           — Edge function: receives RevenueCat webhook events
```

---

## When to Inspect This Directory

| Situation | File to inspect |
|---|---|
| RLS / permission error on Supabase table | `migrations/*.sql` matching the affected table |
| RevenueCat subscription event not processed | `functions/revenuecat-webhook/index.ts` |
| New table or column needed | Create a new `migrations/<timestamp>_<description>.sql` |
| Pro feature gate behaving wrong | Check `functions/revenuecat-webhook/` + `SubscriptionCubit` |

## When NOT to Inspect This Directory

- Flutter app-side bugs (wrong state, wrong UI) — these are in `lib/`
- Widget data not updating — this is `WidgetDataService`, not Supabase
- Isar local storage issues — Supabase is not involved in local writes
- Habit/task display issues — these use Isar, not Supabase directly

---

## How Supabase Connects to Flutter

### Remote Datasources

Every feature that syncs to Supabase has a `*_remote_source.dart` in `data/datasources/`. These files use `supabase_flutter` to query/upsert Postgres tables.

| Feature | Remote datasource | Supabase table(s) |
|---|---|---|
| task | `task_remote_source.dart` | `tasks` |
| habits | `habit_remote_source.dart` | `habits`, `habit_completions` |
| prayer | `prayer_remote_source.dart` | `prayer_logs` |
| stats | `stats_remote_source.dart` | aggregate queries across multiple tables |
| space | `space_remote_source.dart` | `spaces`, `space_members`, `modules`, `lists` |
| notifications | `notifications_remote_source.dart` | `notifications` |
| settings | `settings_remote_source.dart` | `user_settings` |
| calendar | `calendar_remote_source.dart` | `appointments` |
| focus | `focus_remote_source.dart` | `focus_sessions` |
| assets | `assets_remote_source.dart` | `assets` |

### SyncService

`lib/core/services/sync_service.dart` — Isar → Supabase push.
Called by `SyncCubit.startSync()` at startup and by `workmanager` background task.
Decision matrix: hasCloudData + isLocalDirty → clean / restoreCloud / pushLocal / conflict.
Gated by `SubscriptionCubit.hasSyncAccess` (Spaces Pro).

### RevenueCat Webhook

`supabase/functions/revenuecat-webhook/index.ts` — Supabase Edge Function.
Receives purchase events from RevenueCat and updates entitlements in Postgres.
`SubscriptionCubit` reads entitlement status from Supabase on startup via `SubscriptionRepositoryImpl`.

---

## Running Migrations

```bash
# Apply migrations to remote Supabase project
supabase db push

# Local development
supabase start
supabase db reset  # applies all migrations from scratch
```

## Adding a New Migration

1. Name: `supabase/migrations/<YYYYMMDD>_<description>.sql`
2. Follow existing RLS pattern (enable RLS + policy per table)
3. Run `supabase db push` to apply
4. Update relevant feature's remote datasource if schema changes

---

## Non-Negotiable Rules

- Never change `group.com.iappsnet.athar` App Group ID (widget data, not Supabase)
- RLS must be enabled on all user-data tables — no open read/write policies
- Edge function URL is in `.env` via `SUPABASE_URL` — do not hardcode
