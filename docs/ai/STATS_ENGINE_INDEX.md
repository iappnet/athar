<!--
CANONICAL-FOR: Stats feature file map — cubit, state, page, widget, chart dependencies
OWNER:         Claude Code
PRECEDENCE:    5 (Tier 2 — load for PR6/Stats work)
LAST-UPDATED:  2026-06-01 · Stage A
LOADS-AT:      Tier 2 (Stats PR only)
-->

# Athar — Stats Engine Index

## Files

| File | Role |
|------|------|
| `lib/features/stats/presentation/cubit/stats_cubit.dart` | State management; triggers load |
| `lib/features/stats/presentation/cubit/stats_state.dart` | States: Initial, Loading, Loaded, Error |
| `lib/features/stats/domain/usecases/get_stats_usecase.dart` | Single use case; delegates to repository |
| `lib/features/stats/domain/repositories/i_stats_repository.dart` | Abstract interface |
| `lib/features/stats/data/repositories/stats_repository_impl.dart` | Concrete; calls remote source |
| `lib/features/stats/data/datasources/stats_remote_source.dart` | Supabase queries |
| `lib/features/stats/domain/models/stats_data.dart` | Domain model passed up the stack |
| `lib/features/stats/domain/entities/stats_entity.dart` | Equatable entity |
| `lib/features/stats/domain/logic/stats_helpers.dart` | Pure computation helpers |
| `lib/features/stats/data/models/stats_model.dart` | Data model with fromJson/toJson |
| `lib/features/stats/presentation/pages/stats_page.dart` | Display page |
| `lib/features/stats/presentation/widgets/statistics_card.dart` | Per-metric card widget |
| `lib/features/stats/presentation/widgets/stats_weekly_focus_chart.dart` | Focus time chart |

## Data Flow

```
StatsCubit.loadStats(dateRange)
  → GetStatsUseCase.execute(dateRange)
    → StatsRepositoryImpl.getStats(dateRange)
      → StatsRemoteSource queries Supabase:
          - Task completion rate (tasks table)
          - Habit completion rate (habits/habit_completions tables)
          - Focus session total (focus_sessions table)
          - Prayer attendance (prayer_logs table)
      → Returns StatsModel
    → Maps StatsModel → StatsData (domain)
  → Returns Either<Failure, StatsData>
→ Emits StatsLoaded(StatsData) or StatsError
```

## Metrics Computed

- **Task completion**: completed / total tasks in date range
- **Habit completion**: completed / active habits in date range
- **Focus time**: total minutes from focus sessions
- **Prayer attendance**: logged prayers / total expected prayers

## Caching

Stats are **not cached locally** (no Isar). Every `loadStats()` call hits Supabase.
No background refresh — stats load on-demand when `StatsPage` is opened.

## StatsData Model Fields

Inspect `lib/features/stats/domain/models/stats_data.dart` for current fields. Common fields:
- `taskCompletionRate` (double 0.0–1.0)
- `habitCompletionRate` (double 0.0–1.0)
- `totalFocusMinutes` (int)
- `prayerAttendanceRate` (double 0.0–1.0)
- `dateRange` (DateTimeRange)

## Productivity Formula (StatsHelpers)

`lib/features/stats/domain/logic/stats_helpers.dart` — pure static computation:

```
score = 0.4 × taskScore + 0.4 × habitScore + 0.2 × focusScore

taskScore  = completedTasks  / max(expectedTasks,  1)   [clamped 0–1]
habitScore = completedHabits / max(expectedHabits, 1)   [clamped 0–1]
focusScore = focusMinutes    / 30.0                      [target 30 min/day, clamped 0–1]
```

**App weekday convention**: `(dartWeekday % 7) + 1` — different from standard Dart. Sunday = 1.

Stats fetched from Supabase provide `taskCompletionRate`, `habitCompletionRate`, `totalFocusMinutes`, `prayerAttendanceRate`. The formula above applies to the `StatsHelpers` local computation path (used in tests and offline calculations). Supabase path computes rates server-side.

---

## Common Issues

- **Stale data**: No background refresh. Closing and reopening `StatsPage` is the only trigger.
- **Empty stats**: If Supabase query returns null for a field, stats_helpers.dart should handle null safely — check before assuming zero means actual zero.
- **Date range mismatch**: Stats use UTC on Supabase; device may be in local timezone. Verify `dateRange` parameters are normalized before passing to Supabase.
- **Large date ranges**: Queries with long date ranges (e.g. "all time") may be slow — no pagination implemented.
