<!--
CANONICAL-FOR: PR4b calendar dual-display architecture feasibility audit + design sign-off
OWNER:         Claude Code
PRECEDENCE:    5 (Tier 2 — load for PR4b work)
LAST-UPDATED:  2026-06-01 · Architecture option (b) approved; Stage A
LOADS-AT:      Tier 2 (PR4b only)
-->

# PR4b Calendar Dual-Display — Architecture Feasibility Audit

**Date:** 2026-06-01
**Status:** READ-ONLY AUDIT — no Dart changes.
**Spec authority:**
- Domain + integration: `DUAL_DATE_SPEC.md` (project root) — locked 2026-06-01
- Visual: `CALENDAR_CELL_SPEC.md` (Athar Design System repo)
- Pre-existing PR4a audit: `design-context/_audit_calendar.md`

**Purpose:** Evaluate options (a)/(b)/(c) from `ROADMAP_AFTER_PR4A.md` §"PR4b
Architecture Feasibility" and `DUAL_DATE_SPEC.md §4`. Return a single
recommendation for designer sign-off before any PR4b Dart is written.

---

## 1. Files Inspected

| Path | Lines Read | Role |
|------|-----------|------|
| `DUAL_DATE_SPEC.md` (project root) | 1–247 | Primary domain + integration spec for PR4b — locked 2026-06-01 |
| `ROADMAP_AFTER_PR4A.md` (project root) | 1–124 | Architecture options definition, PR4b blocker status |
| `[Design System]/CALENDAR_CELL_SPEC.md` | 1–129 | Visual spec: cell, header, day-sheet, eastern numerals, performance |
| `[Design System]/CALENDAR_FOCUS_REDESIGN.md` | 1–67 | Redesign brief §A — dual Hijri/Gregorian goal (earlier doc) |
| `lib/features/calendar/presentation/cubit/calendar_cubit.dart` | 1–71 | Post-PR4a cubit — full read |
| `lib/features/calendar/presentation/cubit/calendar_state.dart` | 1–35 | Post-PR4a state — full read |
| `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart` | 1–349 | Post-PR4a grid widget — full read |
| `lib/features/calendar/presentation/pages/calendar_page.dart` | 1–281 | Calendar page — full read |
| `lib/features/calendar/domain/entities/calendar_item.dart` | 1–32 | CalendarTask + CalendarAppointment sealed union |
| `lib/features/calendar/domain/usecases/get_calendar_usecase.dart` | 1–2 | Empty stub — 2 lines |
| `lib/features/calendar/domain/repositories/i_calendar_repository.dart` | 1–1 | Empty interface stub — 1 line |
| `lib/core/services/hijri_service.dart` | 1–29 | HijriService wrapper (@lazySingleton) — full read |
| `pubspec.yaml` | 1–186 | Dependency manifest |
| `lib/features/settings/data/models/user_settings.dart` | 55–90 | isHijriMode field declaration (line 61) |
| `lib/features/settings/presentation/cubit/settings_cubit.dart` | 380–409 | toggleHijriMode implementation |
| `lib/features/settings/presentation/pages/general_settings_page.dart` | 165–179 | isHijriMode settings UI toggle |
| `lib/core/design_system/molecules/pickers/athar_date_picker.dart` | 1–50 | HijriCalendar.fromDate API confirmation |
| `design-context/_audit_calendar.md` | 1–378 | PR4a pre-implementation audit — baseline |
| `lib/app.dart` | line 138 | CalendarCubit injection + initial selectDate call |
| `lib/core/di/injection.config.dart` | line 285 | CalendarCubit DI registration (gh.factory) |

[Design System] = `/Users/itech/Development/new_projects/Athar Design System/`

---

## 2. Spec Files Found

### In project root (`/Users/itech/Development/new_projects/athar/`)

| File | Exists | DualDate spec? | CalendarCell spec? | §4 Options? |
|------|--------|---------------|-------------------|-------------|
| `DUAL_DATE_SPEC.md` | YES | YES — full value object, factory, `isFirstOfHijriMonth`, Equatable contract, conversion rules | References `CALENDAR_CELL_SPEC.md` as separate visual spec | YES — §4 lists (a)/(b)/(c) with designer lean toward (c) |
| `ROADMAP_AFTER_PR4A.md` | YES | No (references DUAL_DATE_SPEC.md) | No | YES — identical (a)/(b)/(c) listing |

### In design system repo (`/Users/itech/Development/new_projects/Athar Design System/`)

| File | Exists | DualDate spec? | CalendarCell spec? | §4 Options? |
|------|--------|---------------|-------------------|-------------|
| `CALENDAR_CELL_SPEC.md` | YES | Defines `DualDate` inputs in §1 (visual contract only, not the domain spec) | YES — cell layout, states, hairline, activity dots (§1); header + switcher (§2); day-sheet (§3); eastern numerals (§4); RTL (§5); performance (§6) | NO — visual spec only |
| `CALENDAR_FOCUS_REDESIGN.md` | YES | Mentions `DualDate` value object and `activityByDate` in prose | §A describes cell target behavior | NO |

### `handoff_v2-2/` and `handoff_v2/`

`handoff_v2-2/` exists inside the design system directory but contains no calendar-specific spec files. Only `colors_and_type.css` (token authority) is present there — no calendar spec. No `handoff_v2/` directory found at the project root or design system root.

---

## 3. Current CalendarState Shape (post-PR4a)

Source: `lib/features/calendar/presentation/cubit/calendar_state.dart` (lines 1–35).

`CalendarState` is a **sealed class** with three subtypes:

| Subtype | Purpose |
|---------|---------|
| `CalendarLoading` | No fields |
| `CalendarLoaded` | Day-level data for the selected day |
| `CalendarError` | `message: String` |

### CalendarLoaded field table

| Field | Type | Description |
|-------|------|-------------|
| `selectedDate` | `DateTime` | Midnight-normalized selected day (`DateTime(y, m, d)`) — `calendar_cubit.dart:39` |
| `items` | `List<CalendarItem>` | Tasks + appointments for the **selected day only** — sealed: `CalendarTask(TaskModel)` \| `CalendarAppointment(AppointmentModel)` |

**Total fields in CalendarLoaded: 2.**

### Critical finding: activityByDate does NOT exist

`CalendarState` has no `activityByDate` map, no month-level data, no DualDate cache.

`DUAL_DATE_SPEC.md §3` (point 2) states: "Activity fan-in is already done (PR4a)." **This is incorrect.** PR4a did not add month-level activity aggregation.

Evidence:
- `calendar_cubit.dart:41–58`: `selectDate(date)` calls `getTasksForDay(normalised)` + `getAppointmentsForDay(normalised)` — single selected day only.
- `calendar_state.dart:14–26`: `CalendarLoaded` has only `{selectedDate, items}`.
- `design-context/_audit_calendar.md:65`: "no month-level data, no activityByDate map" — explicitly confirmed in PR4a audit.

**Impact:** The spec assumes PR4b inherits an activity map from PR4a. It must build the full activity fan-in as part of its own scope. This is not a blocker — it is additional PR4b scope that must be acknowledged. All three architecture options must account for it.

### Activity map key format

`selectDate()` normalizes via `DateTime(date.year, date.month, date.day)` (`calendar_cubit.dart:39`). `DUAL_DATE_SPEC.md §1` specifies `DualDate.gregorian = DateTime(y, m, d)` — same normalization. **Keys will match** when the activity map is built. Confirmed midnight-normalized Gregorian DateTime.

### Cubit injection registration

`@injectable` annotation (`calendar_cubit.dart:15`) — registered as `gh.factory<CalendarCubit>` (`injection.config.dart:285`). Instantiated in `app.dart:138` via `getIt<CalendarCubit>()..selectDate(DateTime.now())`.

---

## 4. Option Evaluation

**Framing note:** `ROADMAP_AFTER_PR4A.md` and `DUAL_DATE_SPEC.md §4` use different but overlapping option taxonomies. ROADMAP options: (a) extend cubit, (b) new CalendarMonthCubit, (c) use-case layer. Spec options: (a) `List<DualDate>` in state, (b) domain service with memoization, (c) `Map<DateTime, DualDate>` in state. This audit evaluates the ROADMAP options (architectural decision) and within that, recommends `Map<DateTime, DualDate>` (spec option c) as the data structure regardless of which ROADMAP option is chosen.

---

### Option (a) — Extend CalendarCubit

Add `DualDate` cache, `activityByDate`, `primaryHijri`, `focusedMonth` to the existing cubit.

**State-size impact:**
- Current `CalendarLoaded`: 2 fields.
- Post-PR4b: `{selectedDate, items, dualDates: Map<DateTime, DualDate>, activityByDate: Map<DateTime, ActivitySet>, primaryHijri: bool, focusedMonth: DateTime}` — 6 fields.
- Map sizes: visible month ± 1 buffer = ~93 DualDate entries per map. Memory impact is negligible (~5–10 KB). Not a performance concern.

**Month-scroll rebuild cost:**
- Currently `DualCalendarWidget` is `StatefulWidget` — `_changeMonth()` calls `setState()` internally. The cubit is NOT involved in month navigation. Month scrolling is free: a local state update, no BlocBuilder involved.
- If month navigation moves into the cubit, `_changeMonth()` → `cubit.loadMonth()` → cubit emits new state → every `BlocBuilder<CalendarCubit>` rebuilds.
- `calendar_page.dart:122`: the entire page body (grid + event list) is wrapped in a single `BlocBuilder<CalendarCubit>`. A month-scroll would trigger a full page rebuild including the day-events list below the grid. This is a real, unnecessary rebuild cost.
- Mitigation exists (split with `BlocSelector`) but requires surgical page refactor.

**activityByDate fan-in complexity:**
- Month-level activity fan-in requires: tasks per day in window (Isar query), appointments per day in window (Isar query), habit completions per day (no current month-level query exists), prayer completions per day (no current query exists).
- Current cubit deps: `TaskRepository`, `HealthRepository`, `AppointmentNotifier` (3 deps). Adding habit + prayer sources: 5+ deps.
- `CalendarCubit` already handles appointment reactivity via `_appointmentSub` (`calendar_cubit.dart:25`). The pattern for reactive fan-in is established, but extending it to habits + prayer increases complexity significantly.
- This cubit would own: day-selection, day-item fetch, month navigation, DualDate cache, 4-source activity fan-in, settings reads (`primaryHijri`). Clear SRP violation.

**Testability:**
- Hijri conversion and activity fan-in tested by driving `CalendarCubit` — requires all 5+ repository mocks. Less isolated than option (b).
- Month aggregation logic cannot be tested independently of day-selection logic.

**Exact files changed:**
- `lib/features/calendar/presentation/cubit/calendar_cubit.dart` — add `loadMonth()`, 2+ new injected repos, reactive subscriptions for habits + prayer.
- `lib/features/calendar/presentation/cubit/calendar_state.dart` — expand `CalendarLoaded` with 4 new fields.
- `lib/features/calendar/presentation/pages/calendar_page.dart` — refactor `BlocBuilder` to avoid full rebuild on month-scroll; wire month navigation through cubit.
- `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart` — delete; replaced.
- NEW: `lib/features/calendar/domain/entities/dual_date.dart`
- NEW: `lib/features/calendar/presentation/widgets/calendar_day_cell.dart`
- NEW: `lib/features/calendar/presentation/widgets/dual_calendar_header.dart`
- `lib/core/di/injection.config.dart` — regenerated via `build_runner` (new injected repos).

**Risk: HIGH**

Reasoning: Adding month-level aggregation (4 sources) + DualDate caching to a cubit that already owns day-selection creates a god-cubit. The month-scroll rebuild cost requires surgical page refactoring to fix. The cubit's constructor dependency count reaches 5+, which violates the project's observable pattern (existing cubits have 1–3 deps). The current `StatefulWidget` month-navigation is efficient (pure `setState`); replacing it with cubit emit adds latency without user-visible benefit.

---

### Option (b) — New `CalendarMonthCubit`

Keep `CalendarCubit` for day-selection. New `CalendarMonthCubit` owns month-level state: `DualDate` cache, `activityByDate`, `primaryHijri`, month navigation.

**State-size impact:**
- `CalendarCubit.CalendarLoaded`: unchanged — still `{selectedDate, items}` (2 fields).
- New `CalendarMonthCubit` state: `{focusedMonth, dualDates: Map<DateTime, DualDate>, activityByDate: Map<DateTime, ActivitySet>, primaryHijri: bool}` — 4 fields in its own state class.

**Month-scroll rebuild cost:**
- Month navigation calls `CalendarMonthCubit.setFocusedMonth()` → emits new month state.
- `CalendarPage` hosts two separate BlocBuilders: `BlocBuilder<CalendarMonthCubit>` wraps the grid only; `BlocBuilder<CalendarCubit>` wraps the day-events list only.
- Month scroll does **not** rebuild the day-events list. Day-tap does **not** rebuild the grid (if `focusedMonth` unchanged). **Rebuilds are properly isolated.** This is the cleanest rebuild story.

**activityByDate fan-in complexity:**
- `CalendarMonthCubit` owns all month-level subscriptions. Clean SRP: `CalendarCubit` = day-details; `CalendarMonthCubit` = month-aggregate.
- Highest dep count per cubit: `CalendarMonthCubit` gets 3–4 repos (tasks, appointments, habits, prayer source TBD). `CalendarCubit` remains at its current 3 deps.

**Testability:**
- `CalendarMonthCubit` tested independently: DualDate computation, activity aggregation per day, month-scroll behavior. Excellent isolation.
- `CalendarCubit` tests unchanged.

**Exact files changed:**
- NEW: `lib/features/calendar/presentation/cubit/calendar_month_cubit.dart`
- NEW: `lib/features/calendar/presentation/cubit/calendar_month_state.dart`
- NEW: `lib/features/calendar/domain/entities/dual_date.dart`
- NEW: `lib/features/calendar/presentation/widgets/calendar_day_cell.dart`
- NEW: `lib/features/calendar/presentation/widgets/dual_calendar_header.dart`
- DELETE: `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart`
- EDIT: `lib/features/calendar/presentation/pages/calendar_page.dart` — add `BlocProvider<CalendarMonthCubit>`, split BlocBuilders.
- EDIT: `lib/app.dart:138` — add `BlocProvider<CalendarMonthCubit>` alongside existing `BlocProvider<CalendarCubit>`.
- `lib/core/di/injection.config.dart` — regenerated via `build_runner` after `@injectable` added to `CalendarMonthCubit`.

**Codebase precedent:** This exact split (day-level cubit + aggregate-level cubit) already exists: `TaskCubit` handles task state; `TimelineCubit` handles aggregated day-timeline display (`CLAUDE.md` and `docs/ai/STATE_MANAGEMENT_INDEX.md`). Option (b) follows the established pattern.

**Risk: MEDIUM**

Reasoning: Introduces one new cubit + one new state class + one `build_runner` run. The trade-off is clear files with clear responsibilities. The `app.dart` already manages 18+ cubits (`CLAUDE.md`); adding one more follows the established pattern exactly. The mechanical steps (annotate with `@injectable`, run `build_runner`, add `BlocProvider` to `app.dart`) are well-understood in this codebase. Rebuild isolation is the best of the three options.

---

### Option (c) — Use-case aggregation layer

Introduce a `CalendarAggregationUseCase` that handles multi-source fan-in. `CalendarCubit` (or a new thin cubit) calls the use case.

**State-size impact:**
- If CalendarCubit consumes it: same as option (a) — state grows by 4 fields, same rebuild problems.
- If a new thin cubit consumes it: effectively option (b) + an extra domain layer file. State split is identical.
- The use-case layer is **orthogonal** to the cubit architecture decision — it does not answer "one cubit or two."

**Month-scroll rebuild cost:**
- Same as option (a) if CalendarCubit owns the result; same as option (b) if a separate cubit does.
- The use-case layer does not improve the rebuild story.

**activityByDate fan-in complexity:**
- A use case is appropriate when the fan-in involves **business rules** — deduplication, priority logic, filtering by subscription tier, etc.
- Current spec fan-in: tasks → blue dot, habits → green dot, prayer → primary dot (`CALENDAR_CELL_SPEC.md §1`). This is a simple display aggregation — no business rules, no deduplication, no computed values.
- The existing `CalendarCubit.selectDate()` fan-in (tasks + appointments, `calendar_cubit.dart:41–58`) was simple enough to live inline (8 lines). Month-level fan-in is the same pattern at wider scope.

**Existing use-case layer status:**
- `lib/features/calendar/domain/usecases/get_calendar_usecase.dart` — **empty file** (2-line comment header only).
- `lib/features/calendar/domain/repositories/i_calendar_repository.dart` — **empty interface** (1 line: `abstract class ICalendarRepository {}`).
- The Clean Architecture skeleton exists but has no foundation. Building a use case here adds 2–3 files with no existing code to leverage.

**Exact files changed (use-case + new cubit, the complete form):**
- NEW: `lib/features/calendar/domain/usecases/get_calendar_activity_usecase.dart`
- NEW: `lib/features/calendar/data/repositories/calendar_activity_repository_impl.dart`
- NEW: `lib/features/calendar/presentation/cubit/calendar_month_cubit.dart` (thin caller)
- NEW: `lib/features/calendar/presentation/cubit/calendar_month_state.dart`
- NEW: `lib/features/calendar/domain/entities/dual_date.dart`
- NEW: `lib/features/calendar/presentation/widgets/calendar_day_cell.dart`
- NEW: `lib/features/calendar/presentation/widgets/dual_calendar_header.dart`
- DELETE: `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart`
- EDIT: `lib/features/calendar/presentation/pages/calendar_page.dart`
- EDIT: `lib/app.dart`
- `build_runner` run required.

**Risk: MEDIUM-HIGH**

Reasoning: Highest file count. The use-case + repository layer adds 2 files that are currently empty stubs with no existing logic. For a fan-in that is 3 dot flags per day (no business rules), this is over-engineering. The upfront cost is highest of the three options. If the `Activity` struct becomes a first-class domain concept reused across Stats and Timeline features, option (c) becomes more attractive — but no such reuse is specified in current PRs.

---

## 5. Recommendation

**Recommended: Option (b) — New `CalendarMonthCubit`.**

The fan-in complexity is real: 4 async sources (tasks, appointments, habits, prayer) with reactive updates mean this is not a "thin display concern only" (the condition under which option (a) is appropriate per `ROADMAP_AFTER_PR4A.md`). This disqualifies option (a)'s god-cubit risk.

Option (b) produces the cleanest rebuild isolation (month-scroll rebuilds the grid; day tap rebuilds the event list — independently). It follows the `TaskCubit`/`TimelineCubit` precedent already in the codebase. The mechanical cost — one new cubit file, one new state file, one `build_runner` run, one new `BlocProvider` in `app.dart` — is low.

**The evidence does not support the designer's lean toward option (c).** The use-case layer (`get_calendar_usecase.dart`, `i_calendar_repository.dart`) is empty stubs. The fan-in logic (3 dot-flag aggregation per day) does not contain business rules that require domain-layer isolation — it is a display concern that belongs in a cubit. Option (c) would add 2 extra files with no commensurate benefit at this fan-in complexity. If the designer anticipates the `Activity` struct becoming a domain concept shared with Stats/Timeline, option (c) is defensible. Otherwise, option (b) is correct.

**Within option (b):** the `DualDate` cache should be a `Map<DateTime, DualDate>` (spec option c / `DUAL_DATE_SPEC.md §4 (c)`) rather than `List<DualDate>` (spec option a), for O(1) cell lookup with key alignment to `activityByDate`.

---

## 6. package:hijri Compatibility

**Version in pubspec.yaml:** `hijri: ^3.0.0` (line 63 — confirmed)

**HijriCalendar API confirmed present:**

| API | Evidence |
|-----|---------|
| `HijriCalendar.fromDate(DateTime date)` — static factory | `lib/core/services/hijri_service.dart:14`; `lib/core/design_system/molecules/pickers/athar_date_picker.dart:39` |
| `HijriCalendar.setLocal('ar')` — static locale setter | `hijri_service.dart:9`; `athar_date_picker.dart:40` |
| `.hDay` — Hijri day integer | `hijri_service.dart:14` (implicit), `dual_calendar_widget.dart:280` (`hijriDate.hDay`) |
| `.hYear` — Hijri year integer | `dual_calendar_widget.dart:113, 116` (`hijriMonth.hYear`) |
| `.longMonthName` — full Arabic month name string | `hijri_service.dart:14`; `dual_calendar_widget.dart:113, 116` |
| `.toFormat("dd MMMM yyyy")` — string formatting | `athar_date_picker.dart:41` |

**DualDate.from factory feasibility: CONFIRMED**

The factory specified in `DUAL_DATE_SPEC.md §1`:
```dart
factory DualDate.from(DateTime day) {
  final g = DateTime(day.year, day.month, day.day);
  final h = HijriCalendar.fromDate(g);
  return DualDate(gregorian: g, hijri: h, isFirstOfHijriMonth: h.hDay == 1);
}
```
is fully implementable. `HijriCalendar.fromDate(DateTime)` is confirmed working. `hDay` property confirmed available. No new package dependency required.

**Caveat — global locale state:** `HijriService.__constructor__` calls `HijriCalendar.setLocal('ar')` (`hijri_service.dart:9`). `HijriCalendar` locale is global mutable state. `DualDate.from()` called before `HijriService` is initialized (e.g., in a unit test) will use the library default locale. Recommendation: `DualDate` should rely only on `.hDay` and `.hYear` (numeric, locale-independent) internally; month-name display should route through `HijriService.toHijri()` which guarantees locale is set.

---

## 7. isHijriMode Repurposing Safety

### All current usages (file:line)

**Reads — display logic:**

| File | Line(s) | Semantic used |
|------|---------|--------------|
| `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart` | 41–43, 52–56, 64 | `_isGregorianPrimary = !isHijriMode` — primary/secondary control |
| `lib/features/calendar/presentation/pages/calendar_page.dart` | 61–67 | BlocSelector passes to `DualCalendarWidget` |
| `lib/features/settings/presentation/cubit/settings_state.dart` | 35 | Included in `SettingsLoaded` props |
| `lib/features/settings/presentation/pages/general_settings_page.dart` | 176 | Toggle switch current value |
| `lib/features/habits/presentation/pages/habit_page.dart` | 694 | `isHijriMode ? hijriString : gregorianString` — **show-one-only** |
| `lib/features/task/presentation/widgets/add_task_sheet.dart` | 75, 97, 368 | Same — show Hijri OR Gregorian string in date picker |
| `lib/features/task/presentation/widgets/unified_add_sheet.dart` | 95, 140, 351 | Same |
| `lib/features/task/presentation/widgets/components/date_time_picker.dart` | 10, 17, 42, 49 | `isHijriMode ? hijriString : gregorianString` — **show-one-only** |

**Writes — toggle:**

| File | Line(s) | Action |
|------|---------|--------|
| `lib/features/settings/presentation/cubit/settings_cubit.dart` | 394–398 | `toggleHijriMode(bool value)` via SettingsCubit |
| `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart` | 81–88 | Direct `SettingsRepository` write (tech debt noted in PR4a audit) |
| `lib/features/sync/data/repositories/sync_repository_impl.dart` | 397, 411–412 | Synced to/from Supabase as `is_hijri_mode` |

### Current semantic

**`isHijriMode` has a "show-one-only" semantic in ALL non-calendar consumers.** In `date_time_picker.dart:42`, `add_task_sheet.dart:368`, `habit_page.dart:694`: `isHijriMode ? hijriString : gregorianString` — shows only one calendar string. The date pickers are a mutual-exclusion toggle, not a dual-display control.

In the calendar widget post-PR4a: `_isGregorianPrimary = !isHijriMode` — the field already drives "which is primary" rather than "which to show," because `dual_calendar_widget.dart` always renders both numerals (lines 283–296). The calendar has partially transitioned.

**Safe to repurpose: CONDITIONAL**

Repurposing `isHijriMode` to mean "Hijri is primary in dual display" is **safe for the calendar** — the calendar already uses both-always-visible semantics post-PR4a.

It creates a **semantic split** with date pickers in tasks and habits: same boolean, two different behaviors depending on consumer. After PR4b, `isHijriMode = true` would mean "Hijri primary in calendar" but "show Hijri only in task/habit date pickers."

This is only safe if:
1. The task/habit date pickers are also migrated to dual-display in PR4b (resolving the split), OR
2. A distinct `hijriPrimary: bool` field is used for the calendar only (no migration cost on pickers), OR
3. The designer explicitly accepts the semantic split (different behavior per consumer).

`DUAL_DATE_SPEC.md §9 Q5` notes this as an open question and recommends reusing `isHijriMode`. This audit flags it as requiring explicit designer decision before PR4b proceeds.

---

## 8. Eastern Numerals (PR5) Dependency

**Can PR4b proceed without PR5 shipped?: YES (defensive default-OFF read)**

Evidence:
- No `easternNumerals`, `isEasternNumerals`, or `EasternNumerals` identifier exists anywhere in `lib/` — grep returned zero results.
- `UserSettings` does not have an `easternNumerals` field — confirmed absent from `user_settings.dart`.
- `CALENDAR_CELL_SPEC.md §4`: behavior is `when Accessibility.easternNumerals = true AND locale is Arabic` → Eastern digits; default OFF → Western digits.
- `DUAL_DATE_SPEC.md §6` explicitly states: "If PR5 hasn't shipped when PR4b starts, PR4b reads the flag defensively (default OFF → Western digits) and the behavior lights up once PR5 lands."

**Reasoning:** PR4b should read `settings.easternNumerals ?? false` or, if the field truly doesn't exist yet, use a local `const _easternNumeralsEnabled = false` with a `// TODO(PR5): wire to settings.easternNumerals` comment. Both numerals render as Western digits until PR5 adds the field. No coordination with PR5 timing is required.

Note: `HijriCalendar.setLocal('ar')` causes Hijri month names to be in Arabic regardless of `easternNumerals` — that is correct (month names are always Arabic). Only numeral glyphs (١٢٣ vs 123) are governed by `easternNumerals`.

---

## 9. Open Questions for Designer

1. **activityByDate scope in PR4b.** `DUAL_DATE_SPEC.md §3.2` says "Activity fan-in is already done (PR4a)" — this is incorrect (`calendar_state.dart` confirmed: no activity map). PR4b must build the month-level activity map from scratch. Which dot types are in PR4b scope: tasks only? tasks + appointments? all four (tasks + habits + prayer + appointments)? The answer determines `CalendarMonthCubit` dependency count and `loadMonth()` implementation scope.

2. **isHijriMode semantic collision in date pickers.** `isHijriMode` currently drives "show Hijri OR Gregorian (one only)" in `add_task_sheet.dart`, `unified_add_sheet.dart`, `date_time_picker.dart`, and `habit_page.dart`. PR4b repurposes it to "Hijri is primary in dual display." This creates contradictory semantics across the app unless those pickers are also migrated to dual display. Three options: (a) repurpose and migrate all pickers in PR4b, (b) add a distinct `hijriPrimary: bool` field for the calendar only, (c) accept the split (different behavior per consumer). Which approach is intended? (`DUAL_DATE_SPEC.md §9 Q5` carryover.)

3. **Prayer completion data source.** `CALENDAR_CELL_SPEC.md §1` shows a prayer dot (`AppColors.primary`). The prayer system uses `PrayerNotificationScheduler` and does not currently expose a per-day completion map. Is a prayer dot in scope for PR4b? If yes, which repository/method should be called to get month-level prayer completion status?

4. **Habit completion data source.** `CALENDAR_CELL_SPEC.md §1` shows a habit dot (`AppColors.success`). `CalendarCubit` currently has no habit repository dependency. Does `HabitRepository` expose a method for "habits completed on day X" or "habit completions in date range"? If not, a new method must be added. Is habit dot in scope for PR4b?

5. **DualMonthSwitcher scope.** `CALENDAR_CELL_SPEC.md §2` specifies a full dual-row pill month switcher (12 pills per row, Gregorian + Hijri, independent scrolling). This is a significant widget. `DUAL_DATE_SPEC.md §7` lists it as a new file. Is this in scope for PR4b, or deferred to a later PR? Current chevron navigation (`_changeMonth(±1)`) should remain as fallback until confirmed.

6. **Hijri month-name truncation.** `CALENDAR_CELL_SPEC.md §1` (Hijri-month boundary section): month name "truncated to 6 chars." For long names like "ذو الحجة" (8 chars) and "ذو القعدة" (9 chars), is truncation correct (hard cutoff: "ذو الح"), or should there be a predefined abbreviation table? (`DUAL_DATE_SPEC.md §9 Q2` carryover.)

7. **Leading/trailing (other-month) days.** `CALENDAR_CELL_SPEC.md §1` defines a `disabled` state (`AppColors.text3` ink, transparent bg). Currently `dual_calendar_widget.dart` renders empty `SizedBox()` for leading cells — no other-month days are shown at all. Should PR4b render other-month days as disabled dual-numeral cells, or maintain the current empty-cell approach? (`DUAL_DATE_SPEC.md §9 Q3` carryover.)

8. **isHijriMode locale auto-default.** Should `isHijriMode` auto-default to `true` when Arabic locale is active on first launch, or is it purely user-controlled? (`DUAL_DATE_SPEC.md §9 Q4` carryover.)

9. **CALENDAR_CELL_SPEC vs CALENDAR_FOCUS_REDESIGN numeral position discrepancy.** `CALENDAR_FOCUS_REDESIGN.md §A` (older doc) places numerals at "top-right" and "bottom-left" corners (absolute positioning). `CALENDAR_CELL_SPEC.md §1` (authoritative, newer) places them at "top-center, 4pt from top" and "bottom-center, 3pt from bottom" with named text styles (`AppText.bodyM`, `AppText.captionS`). Confirm `CALENDAR_CELL_SPEC.md` is the authoritative visual source. If absolute corner positioning is intended, the spec needs an update before implementation.

---

## 10. Definition of Done (PR4b) — Confirmed from Spec

Per `DUAL_DATE_SPEC.md §10`:
- Both numerals render in every cell, every state, both locales.
- `isHijriMode` flips primary/secondary (not visibility).
- First-of-Hijri-month hairline + month-name swap correct.
- Day-sheet header shows both dates joined by `·`.
- Month-scroll holds frame budget; conversions memoized.
- `dual_calendar_widget.dart` deleted; no `_isGregorianPrimary` remains.
- Activity dots (from PR4b fan-in build) correct on new cells.
- `flutter analyze` 0 issues; golden suite for new cell.
- PR3 goldens untouched.

---

## 11. Sign-Off Gate

**No PR4b Dart until the designer confirms all of the following:**

- [ ] Option (b) — New `CalendarMonthCubit` — approved as architecture (or alternative with justification)
- [ ] Q1 — activityByDate scope confirmed (which dot types are in PR4b)
- [ ] Q2 — isHijriMode repurposing approach decided (reuse vs. new field vs. accepted split)
- [ ] Q3 — Prayer dot: in scope? data source identified?
- [ ] Q4 — Habit dot: in scope? repository method identified?
- [ ] Q5 — DualMonthSwitcher: in PR4b or deferred?
- [ ] Q6 — Hijri month-name: truncation or abbreviation table?
- [ ] Q7 — Other-month leading/trailing cells: dual-dimmed or empty?
- [ ] Q8 — isHijriMode locale auto-default behavior
- [ ] Q9 — CALENDAR_CELL_SPEC confirmed as authoritative for numeral position

---

## 12. Confirmation: No Dart Code Modified

This audit session was read-only. No Dart files were modified. No UI implementation was started. All output is this markdown document.
