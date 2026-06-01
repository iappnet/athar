# Stats — PR6 Pre-Implementation Audit

**Date:** 2026-06-01  
**Scope:** lib/features/stats/ + KPI data sources + activity logging + HealthKit  
**Status:** AUDIT ONLY — no Dart modified

---

## Files Inspected

| File | Read? |
|---|---|
| lib/features/stats/presentation/pages/stats_page.dart | ✅ |
| lib/features/stats/presentation/cubit/stats_cubit.dart | ✅ |
| lib/features/stats/presentation/cubit/stats_state.dart | ✅ |
| lib/features/stats/domain/models/stats_data.dart | ✅ |
| lib/features/stats/domain/repositories/i_stats_repository.dart | ✅ |
| lib/features/stats/data/repositories/stats_repository_impl.dart | ✅ |
| lib/features/stats/presentation/widgets/stats_weekly_focus_chart.dart | Skimmed (via imports) |
| lib/features/stats/presentation/widgets/statistics_card.dart | Skimmed (via imports) |
| lib/features/stats/domain/logic/stats_helpers.dart | Listed |
| lib/features/stats/domain/entities/stats_entity.dart | Listed |
| lib/features/stats/data/datasources/stats_remote_source.dart | Listed |
| lib/features/stats/data/models/stats_model.dart | Listed |
| lib/features/stats/domain/usecases/get_stats_usecase.dart | Listed |
| lib/features/prayer/data/models/prayer_model.dart | ✅ |
| lib/features/dhikr/data/models/dhikr_model.dart | ✅ |
| lib/features/space/data/models/space_model.dart | ✅ |
| lib/features/habits/data/models/habit_model.dart (fields only) | ✅ |
| pubspec.yaml (deps grep) | ✅ |

---

## 1. Current Stats Feature — State and Widget Tree

### Architecture

**StatsCubit** (`@injectable`): thin orchestrator. Holds `_rangeDays` (7 or 30). Calls `_repository.getStats(rangeDays, userId)`. Emits `StatsInitial → StatsLoading → StatsLoaded | StatsError`.

**StatsRepositoryImpl** (`@LazySingleton`): does all computation. Queries Isar directly — bypasses every feature cubit entirely. In-memory TTL cache (5 min, keyed `"$userId-$rangeDays"`). Has `invalidateCache()` on `IStatsRepository`. Data sources: `isar.taskModels`, `isar.habitModels`, `isar.focusSessions`, `isar.categoryModels`.

**StatsState** shape:
```
StatsLoaded {
  StatsData data     → TaskMetrics + HabitMetrics + FocusMetrics
                       + List<PeriodMetric> + List<DomainMetric>
                       + List<StatsInsight>
                       + productivityScore / consistencyScore / streakQuality (doubles)
  int rangeDays
}
```

### Period selector (current)

`SegmentedButton<int>` in the AppBar trailing slot. Two segments only: **7 days / 30 days**. Stored in cubit field `_rangeDays`. No "Today", no "Custom", no month, no persistence.

**Gap vs spec:** Spec wants a horizontal pills row (Today / This week / This month / Last 7d / Last 30d / Custom…) with selection persisted in state. This is a new widget + new period enum.

### Current widget tree outline

```
StatisticsPage
└── BlocProvider<StatsCubit>
    └── _StatisticsView (Scaffold)
        ├── AppBar
        │   └── SegmentedButton<int> (7d / 30d) [trailing]
        └── BlocBuilder<StatsCubit>
            └── BlocBuilder<SubscriptionCubit>  [determines hasAccess]
                └── _StatsContent (SingleChildScrollView, Column)
                    ├── _ScoreDashboard  ← 3× CircularProgressIndicator gauges
                    │   productivityScore / consistencyScore / streakQuality
                    ├── _TodayCard  ← tasks today, habits today, focus today
                    ├── _SectionHeader("Tasks") + _TaskSummaryRow + _DailyCompletionChart
                    │   └── fl_chart BarChart (completed/total stacked, daily)
                    ├── _SectionHeader("Focus") + _FocusSummaryRow + WeeklyFocusChart
                    │   + _FocusByPeriodBars (LinearProgressIndicators by Islamic period)
                    ├── _SectionHeader("Habits") [subscribers only or _PaywallSection]
                    │   ├── _HabitConsistencyRow (single _MetricChip)
                    │   ├── _TopStreaksCard (top 3 habits by streak)
                    │   └── HabitHeatmap (from habits/presentation/widgets)
                    ├── _SectionHeader("Periods") [subscribers only, if data exists]
                    │   └── _PeriodChart (LinearProgressIndicator per Islamic period)
                    ├── _SectionHeader("Domains") [subscribers only, if data exists]
                    │   └── _DomainList (progress bars by category, color dot)
                    └── _SectionHeader("Insights") [subscribers only, if data exists]
                        └── _InsightsList (_InsightCard per insight)
```

### Token / style status

- Uses `AtharSpacing`, `AtharRadii`, `AtharGap` tokens — ✅ partially tokenised
- Uses `colorScheme.primary/surface/etc.` — ✅ theme-aware
- **Hardcoded colors present:** `Colors.green`, `Colors.orange`, `Colors.white`, `Colors.white70` — ❌ must migrate to AppColors tokens
- `TextStyle(fontSize: N.sp, fontWeight: ...)` inline throughout — ❌ must migrate to AppText
- `SizedBox(width: 8.w)` inline — ❌ partial, use AtharGap/AtharSpacing
- No `numericMono` usage anywhere — ❌ spec requires numericMono 28pt on all metric values
- `_SectionHeader` is local (different from PR3 card pattern) — needs alignment check

---

## 2. Charting — fl_chart ^1.2.0

**Status:** ✅ Already in pubspec. Already used.

**Currently used chart types:**
- `BarChart` — task daily completion (_DailyCompletionChart)
- `WeeklyFocusChart` (separate widget, likely fl_chart LineChart or BarChart — not read in full)
- `LinearProgressIndicator` (Flutter Material) — period bars, domain bars, habit % (NOT fl_chart)
- `CircularProgressIndicator` (Flutter Material) — score gauges (NOT fl_chart)
- `HabitHeatmap` — custom widget (NOT fl_chart)

**Available in fl_chart ^1.2.0 for spec needs:**
- `LineChart` — ✅ can implement sparklines (KPI #1 task trend, #3 habit rate trend)
- `BarChart` — ✅ already used; can implement weekly bar (KPI #4 focus)
- `BarChart` (stacked) — ✅ can implement stacked bar (Tier-2 #7 space breakdown)
- Heatmap — ❌ not in fl_chart; custom widget already exists for habits; would need adaptation for any new heatmap

**No new dependency required for any chart type in the spec.**

---

## 3. Tier-1 KPI Source Existence Table

> ⚠️ Architecture note: The spec names `XxxCubit.method` as sources but the actual architecture has `StatsRepositoryImpl` query Isar directly, bypassing all feature cubits. PR6 adds new KPI cards but the fan-in pattern for #5 and #6 is physically impossible today — no data exists.

| # | KPI | Spec source | Actual status |
|---|---|---|---|
| 1 | Tasks completed | `TaskCubit.completedCount` | ⚠️ Partial: `completedCount` is a field on `TaskLoaded` state (task_state.dart:21), not a cubit method. Stats repo computes equivalent from Isar. `totalTasks` + `completedTasks` already in `TaskMetrics`. `dailyCounts` (sparkline data) already computed. **Ready to wire into a KPI card.** |
| 2 | Longest habit streak | `HabitCubit.maxStreak` | ⚠️ No cubit method. Stats repo already computes `topStreaks` (top 3 by `currentStreak`). Max streak = `topStreaks.first.currentStreak`. **Ready to wire.** |
| 3 | Habit completion rate 7d | `HabitCubit.completionRate7d` | ⚠️ No cubit method. Stats repo already computes `HabitMetrics.overallConsistency` (0.0–1.0), which is the 7d equivalent. **Ready to wire.** |
| 4 | Focus minutes | `FocusCubit.minutesToday/7d` | ⚠️ No cubit methods. Stats repo already computes `FocusMetrics.todayMinutes` and `FocusMetrics.totalMinutes` from FocusSession Isar. **Ready to wire.** |
| 5 | Prayer adherence (7d) | `PrayerCubit.adherence7d` | ❌ **DOES NOT EXIST — NO DATA INFRASTRUCTURE.** `PrayerModel` has Isar imports commented out; it's a stub (`class PrayerModel extends Equatable { const PrayerModel(); }`). PrayerCubit only loads prayer *times* (computed/remote) — there is NO mechanism to record whether a prayer was performed. `adherence7d` requires: (a) a new Isar collection for prayer completion events, (b) a "mark prayed" user action in the prayer UI, (c) stats repo reading that collection. **Net-new data infrastructure.** |
| 6 | Athkar sessions (7d) | `AthkarCubit.sessions7d` | ❌ **DOES NOT EXIST — NO SESSION HISTORY.** No `AthkarCubit` exists; the cubit is `DhikrCubit`. `DhikrModel` has only `currentCount: int` — no completion timestamp, no session log. When a dhikr round is completed the count resets in memory; nothing is persisted to Isar. `sessions7d` requires a new `DhikrSessionLog` Isar collection. **Net-new data infrastructure AND PR7 feature gating (per your brief).** |

---

## 4. Tier-2 Gating Flags

| Flag | Status |
|---|---|
| `isMoodEnabled` | ❌ Not in UserSettings. No mood feature exists anywhere. |
| `isSleepEnabled` | ❌ Not in UserSettings. No sleep feature exists anywhere. |
| Mood data source | ❌ None. No Isar collection, no cubit, no UI. |
| Sleep data source | ❌ None. No Isar collection, no cubit, no UI. |

---

## 5. Space Model — Color for Stacked Bar

`SpaceModel` (space_model.dart) fields: `id`, `uuid`, `name`, `type`, `ownerId`, `isSynced`, `allowMemberDelegation`, `createdAt`, `updatedAt`, `deletedAt`.

**No color field.** ❌

> Note: The existing "Domains" section in stats uses `CategoryModel.colorValue` (an int) — these are task categories, not spaces. The spec's "per-space stacked bar" refers to the Space feature (family/work spaces), not categories. Adding a `colorValue` to SpaceModel is additive and straightforward, but it is a UserSettings-touching model change (needs build_runner).

---

## 6. Export (CSV/PDF)

- `share_plus: ^12.0.2` is in pubspec — can drive the system share sheet ✅
- No `pdf` / `printing` / `csv` package in pubspec ❌
- No export logic anywhere in the codebase ❌
- `file_service.dart` handles file picker + Supabase upload for attachments — unrelated to export

---

## 7. AI-Readiness / Activity Logging Investigation

> For a future `ActivityEvent` unified log spec. No build here.

### Isar collections: historical vs. current state

| Collection | File | Time-series? | What it stores |
|---|---|---|---|
| `TaskModel` | task/data/models/task_model.dart | ✅ Historical | `date`, `completedAt`, `createdAt`, `updatedAt` — full completion timeline |
| `HabitModel` | habits/data/models/habit_model.dart | ✅ Historical | `completedDays: List<DateTime>` — per-day completion history |
| `FocusSession` | focus/data/models/focus_session.dart | ✅ Historical | `date`, `startTime`, `durationMinutes`, `timePeriodIndex` — clean time-series |
| `ServiceLogModel` | assets/data/models/service_log_model.dart | ✅ Historical | Service logs for physical assets (not productivity) |
| `MedicineLogModel` | health/data/models/medicine_log_model.dart | ✅ Historical | Medicine dose logs with likely date |
| `NotificationModel` | notifications/data/models/notification_model.dart | Partial | Notification records, likely timestamp |
| `UploadQueueModel` | core/models/upload_queue_model.dart | Partial | Pending uploads — not activity |
| `DhikrModel` | dhikr/data/models/dhikr_model.dart | ❌ Current state only | `currentCount` (int) — resets on session end; no timestamp, no session log |
| `UserSettings` | settings/data/models/user_settings.dart | ❌ Current state | Singleton preferences row |
| `CategoryModel` | settings/data/models/category_model.dart | ❌ Metadata | Category definitions |
| `AppointmentModel` | health/data/models/appointment_model.dart | ❌ Future-facing | Scheduled appointments (not completion log) |
| `VitalSignModel` | health/data/models/vital_sign_model.dart | Partial | Manual vital sign entries — likely dated |
| `SpaceModel` + members/modules | space/ | ❌ Relational | Space membership, not activity |

### Per-feature completion event patterns

| Feature | When user completes | What is written | Queryable by date? |
|---|---|---|---|
| Task | Tap complete | `isCompleted = true`, `completedAt = DateTime.now()` on TaskModel | ✅ Yes |
| Habit | Toggle day | `completedDays.add(date)` on HabitModel | ✅ Yes |
| Focus session | Timer finishes | New `FocusSession` row saved with `date`, `durationMinutes` | ✅ Yes |
| Prayer | N/A | **Nothing written.** PrayerCubit only shows times. No "mark prayed" feature. | ❌ No data |
| Dhikr / Athkar | Counter reaches target | **Nothing written.** `currentCount` resets in memory; no persistence. | ❌ No data |

### Hardness assessment for a unified ActivityEvent log

**Easy (data already exists, needs mapping only):** Tasks, Habits, Focus.

**Hard (new data infrastructure required):**
- Prayer: needs new `PrayerCompletionLog` Isar collection + "mark prayed" UI affordance + migration strategy (users have no historical data). Cannot be retrofitted.
- Dhikr: needs new `DhikrSessionLog` Isar collection + write on session completion. `DhikrCubit` would need to write a record when `currentCount == count`. Sessions completed before this change are permanently lost.

**Conclusion:** A unified ActivityEvent log is feasible for tasks/habits/focus with a mapping layer. Prayer and Dhikr require new infrastructure and cannot have historical data backfilled.

---

## 8. Apple Health / HealthKit Investigation

> Investigation only. No build.

- **`health` package in pubspec:** ❌ Not present.
- **HealthKit entitlement / Info.plist strings:** ❌ Not present in ios/Runner/. The only HealthKit mentions in ios/ are inside Fastlane gem documentation (vendor/bundle/…) — not app code.
- **`NSHealthShareUsageDescription` / `NSHealthUpdateUsageDescription`:** ❌ Not in Info.plist.
- **Android Health Connect:** ❌ Not configured.
- **`lib/features/health/` feature:** Exists. Contains: `AppointmentModel`, `MedicineModel`, `MedicineLogModel`, `VitalSignModel`, `HealthProfileModel` — all pure Isar collections populated by the user manually inside the app. No system health API is called.
- **HealthKit data types read today:** None. Zero.

**Conclusion:** The `health` feature is an in-app tracker (appointments, medicines, vitals) with zero HealthKit/Health Connect integration. Adding HealthKit would require: pubspec dep, entitlement, Info.plist strings, App Store health data declaration, and review approval. It is a significant scope addition.

---

## Conflict Resolutions (A–D) — Recommendations

### A — KPI #6 Athkar depends on PR7

**Options:**
- (a) Omit card #6 until PR7
- (b) Disabled "Coming soon" placeholder
- (c) Build + feature-flag off

**Recommendation: (a) Omit card #6 entirely until PR7.**

Reasons: (b) adds dead UI that must be removed/replaced, creating two PRs of churn on the same card. (c) feature-flagging a card backed by zero data infrastructure is premature abstraction — the flag would protect nothing meaningful. Shipping 5 KPI cards now and adding the 6th in PR7 (when the DhikrSessionLog table also ships) is the cleanest seam. The grid goes from 6→5 cards for one PR, then completes in PR7.

### B — KPI #5 Prayer adherence and isPrayerEnabled

**Recommendation: Yes, KPI #5 should respect `isPrayerEnabled` and hide entirely when prayer is off.**

This is consistent with every other prayer surface. However, KPI #5 faces a deeper problem (see table above): there is no prayer completion data today. The card cannot render a meaningful `adherence7d` value even if shown. Recommend: include card #5 in PR6 scope only IF you decide to also create the prayer completion infrastructure in PR6. Otherwise, defer card #5 alongside card #6. I flag this for your decision — see PR6 scope boundary below.

### C — Mood/Sleep (#8/#9) — flags and data don't exist

**Recommendation: Defer Tier-2 #8 and #9 entirely out of PR6.**

`isMoodEnabled` and `isSleepEnabled` do not exist on `UserSettings`. No mood/sleep data source exists. Adding placeholder cards with fake/zero data violates the constraint "do not stub fake data." These require a full mood-log feature and sleep-log feature before they can surface on the stats screen.

### D — Export + isolate-offloaded heavy queries

**Recommendation: Defer both out of PR6.**

Export requires a `pdf` or `csv` package addition (needs your approval before I can add a dependency) plus a non-trivial rendering layer. Isolate offloading for heavy queries is an optimization that should be added when a query demonstrably causes jank — not speculatively. Defer both.

---

## Proposed PR6 Scope Boundary

### IN (PR6)

1. **Visual redesign** of `stats_page.dart` to match spec card layout:
   - Replace `_ScoreDashboard` + `_TodayCard` + ad-hoc chips with `StatsMetricCard` grid (2-column, 5 cards: #1–#4 + empty slot or only #1–#4)
   - `StatsMetricCard`: radius 18, surface, 1pt borderLt, `numericMono` 28pt value, `AppText.captionM` title, trend pill
   - `ChartCard` wrapper for all charts

2. **Period selector pill row** — replace SegmentedButton with horizontal scroll pills: Today / This week / Last 7d / Last 30d (defer Custom); new `StatsPeriod` enum in state

3. **Token migration** — migrate all `Colors.green/orange/white`, inline `TextStyle`, `SizedBox` to design system tokens

4. **RTL fixes** — charts x-axis direction, pill row direction, trend arrows

5. **KPIs #1–#4** — data already in `StatsData`; wire into `StatsMetricCard` cards (tasks completed, max streak, habit rate 7d, focus minutes)

6. **Insights** — apply `InsightCard` spec styling (AppText.bodyM, forest accent on numbers, dismiss mechanism)

7. **Empty/loading states** — skeleton grid (6 placeholder cards while computing), `EmptyState.stats`

8. **ARB strings** — any new stat labels not yet in ARBs

### DEFERRED (post-PR6)

| Item | Blocker |
|---|---|
| KPI #5 Prayer adherence | No prayer completion data infrastructure |
| KPI #6 Athkar sessions | PR7 + no DhikrSessionLog |
| Tier-2 #7 Space stacked bar | SpaceModel has no color field; space-level task grouping unspecified |
| Tier-2 #8/#9 Mood/Sleep | Feature doesn't exist |
| Custom date range picker | Deferred per D |
| Export CSV/PDF | Deferred per D + needs dep approval |
| Isolate-offloaded queries | Defer until jank observed |

### Decision required before implementation starts

1. **KPI #5 (Prayer adherence)**: Include in PR6 (requires prayer completion infrastructure to be added too) OR defer? If include, the scope balloons significantly.
2. **KPI #6 (Athkar)**: Confirmed (a) omit until PR7?
3. **Period selector**: "Today" as a distinct period means `rangeDays = 1` — confirm this maps correctly to current repo logic, or needs a today-specific query path.

---

## Open Questions

| # | Question |
|---|---|
| Q1 | KPI #5 in PR6 or defer? Prayer completion infrastructure is ~1 day of additional work. |
| Q2 | Confirm: KPI #6 omitted entirely until PR7? |
| Q3 | `StatsMetricCard` sparkline — KPI #1 task sparkline uses `dailyCounts`; for KPI #3 habit rate, there's no `dailyConsistencyRate` series. Add a `List<double> dailyConsistency` to `HabitMetrics`, or show only the current value (no sparkline)? |
| Q4 | `StatsMetricCard` trend delta — how should "prior period" delta be computed for habit rate and max streak? (Focus already has `weekOverWeekChange`; task has overdue rate but no explicit prior-period count.) |
| Q5 | Space stacked bar: spec says "top 5 spaces by activity" but SpaceModel has no color and space→task linkage is unspecified. Defer to a dedicated Tier-2 PR? |
| Q6 | "Custom…" date range: include in PR6 or defer? (Recommend defer — adds sheet, date-pair state, repo range override.) |
| Q7 | Period selector: should selected period persist across app restarts (UserSettings field) or only in-session (cubit state)? |
| Q8 | `ChartCard` "tap → opens detail screen": implement full drill-down in PR6 or shell nav only? |

---

---

## Designer Sign-off — 2026-06-01

**Status: APPROVED ✅ — proceed to implementation.**

Scope locked as proposed with the following rulings:

- **KPI #5 Prayer adherence:** Deferred — ActivityEvent track, needs prayer-completion log.
- **KPI #6 Athkar sessions:** Deferred — PR7 + ActivityEvent track (DhikrSessionLog needed).
- **PR6 hero grid:** 4 cards only (#1–#4). Grid is 2-col phone / 3-col iPad.
- **KPI #2 streak:** No trend pill (point-in-time), no sparkline.
- **KPI #3 habit rate:** Trend pill only if cheaply derivable, else omit.
- **Period selector:** 3 pills (Today / Last 7 Days / Last 30 Days), in-session only.
- **ChartCard:** Display-only, no tap→detail nav.
- **ARB copy:** AI drafts; designer reviews before commit.
- All DEFERRED items confirmed deferred.

*Audit complete. Implementation authorised.*
