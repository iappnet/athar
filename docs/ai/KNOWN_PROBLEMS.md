<!--
CANONICAL-FOR: Confirmed bugs, suspected issues, behavioral quirks, fragile areas
OWNER:         Claude Code
PRECEDENCE:    3 (Tier 0 — prevents re-breaking fragile code / re-fixing closed bugs)
LAST-UPDATED:  2026-06-01 · B2 closed (PR-THEME fixed) + Stage A
LOADS-AT:      Tier 0
-->

# Athar — Known Problems

Confirmed bugs, suspected issues, and non-obvious behavioral quirks. Updated as issues are found and fixed.

---

## OPEN — Phase 5 Device-Confirmed Bugs

_All P1/P2/P3 have been fixed. Pending physical device verification._

---

## OPEN — Design System v2 (Post-PR1)

### REL-1: UI design-system coverage below ship bar

App currently renders mixed forest (v2) / navy (v1) surfaces across ~76% of the UI (151 total surfaces; 36 conformant, 60 partial, 55 not-migrated).

- **Impact:** Release blocker. No App Store or external TestFlight submission until coverage reaches the designer-agreed target.
- **Dark mode is a confirmed v1 launch requirement.** Every surface still using `static const AppColors.*` is dark-mode-broken — `const` values cannot adapt to `ThemeMode`; they always render the light-mode hex. Migration to `context.colors.*` is required for every screen before submission. B2 (dark secondary gradient gap in CSS spec) is part of this same blocker.
- **Acceptance criterion for every per-feature refresh PR:** "All migrated surfaces verified in both light and dark mode on device." A PR that migrates colors but does not verify dark mode does NOT close its share of REL-1.
- **Source:** `design-context/_audit_ui_coverage.md` (2026-06-02) — 36/151 surfaces conformant (24%)
- **Action required:** Per-feature refresh PRs must land before any store submission: PR-DS-ATOMS · PR-TASK-REFRESH · PR-HABITS-REFRESH · PR-HEALTH-REFRESH · PR-SPACE-REFRESH · PR-SETTINGS-REFRESH · PR-PRAYER-DETAILS · PR-SPLASH-ONBOARD-A (tracked in `docs/status/ROADMAP.md` UI Coverage Refresh section).

### B1: Calibri App Store licence unconfirmed
`assets/fonts/calibri-*.ttf` (3 files) are in the repo and declared in `pubspec.yaml`. Calibri is a Microsoft typeface — its licence for App Store distribution has not been confirmed by the designer.
- **Impact:** Submission gate only. Development builds and TestFlight internal builds are unaffected.
- **Action required:** Designer must confirm Calibri licence before any external TestFlight or App Store submission.
- **Files:** `assets/fonts/calibri-light.ttf`, `assets/fonts/calibri-regular.ttf`, `assets/fonts/calibri-bold.ttf`, `pubspec.yaml`, `lib/core/design_system/tokens/athar_typography.dart`

---

## OPEN — NavBar Add Workflow

### P4: Task/Habit added via NavBar + may not appear (unconfirmed)
**Symptom**: Bottom sheet closes but task/habit not visible in list.
**Analysis**:
- Task path: `MainPage._openAddTaskSheet` → `unified_add_sheet.dart _handleSave` → `MainPage's TaskCubit.addTask()` → Isar write → `TimelineCubit` Isar stream fires → `UnifiedTasksView` rebuilds. This chain SHOULD work.
- Habit path: `MainPage._openAddHabitSheet` → `HabitFormSheet._saveHabit` → `MainPage's HabitCubit.addHabit()` → Isar write → `loadHabits()` called at end → `HabitLoaded` emitted → `HabitPage` rebuilds. This chain SHOULD work.
**Possible cause**: Multiple `TaskCubit` instances (global → MainPage → UnifiedTasksPage). If `UnifiedTasksView` is somehow reading the wrong cubit instance, the Isar stream from MainPage's cubit would not reach it.
**Files to inspect if reported again**: `lib/features/task/presentation/pages/unified_tasks_page.dart`, `lib/features/home/presentation/pages/main_page.dart`, `lib/features/home/presentation/cubit/timeline_cubit.dart`

---

## OPEN — Prayer Month View Deferred Items

### P5: `_getPrayerShortName()` uses hardcoded Arabic strings (not l10n)
`lib/features/prayer/presentation/widgets/prayer_month_view.dart` — `_getPrayerShortName()` returns hardcoded Arabic string literals (`'الفجر'`, `'الشروق'`, etc.) instead of using `AppLocalizations`. In English locale the prayer names will still show Arabic.
- **Impact:** English UI shows Arabic prayer names in the month view's selected-day panel.
- **Action required:** Replace with `l10n.prayerFajrShort`, `l10n.prayerSunrise`, etc. Requires confirming all short-name keys exist in both ARBs.
- **Deferred from:** PR-PRAYER-DETAILS (audit note — not in scope without ARB key audit).

### P6: `_toArabicNumerals()` in prayer month view ignores `easternNumerals` setting
`lib/features/prayer/presentation/widgets/prayer_month_view.dart` — `_toArabicNumerals()` always converts digits to Arabic-Indic numerals unconditionally. The `easternNumerals` user setting (in `UserSettings`) is not consulted.
- **Impact:** Users who disable Eastern Numerals will still see Arabic-Indic digits in the prayer calendar.
- **Action required:** Read `context.watch<SettingsCubit>().state` in `_buildDayCell` and `_buildMonthGrid` and pass `useArabicNumerals` flag; call `_toArabicNumerals()` only when the setting is enabled.
- **Deferred from:** PR-PRAYER-DETAILS (isPast dimming also deferred in the same PR).

---

## RESOLVED — Previously Fixed Issues

### FIXED: B2 — `isAutoModeEnabled` → `ThemeMode` not wired
Fixed in **PR-THEME** (commit `bfaf863`, tag `athar-v2-prtheme-complete-final`). `UserSettings.isAutoModeEnabled` was superseded by the `ThemePreference` enum (`system` / `light` / `dark`). `app.dart` now uses a 3-way switch driving `AtharLightTheme.theme` / `AtharDarkTheme.theme` / `ThemeMode.system`. The field `isAutoModeEnabled` is no longer the mechanism — do NOT attempt to wire it.

### FIXED: P1 — Widget locale not updated on language change
`LocaleCubit.setLocale()` now calls `WidgetDataService.pushLocaleOnly(localeCode)` after writing to secure storage. `pushLocaleOnly` writes `athar_app_locale` to UserDefaults and triggers all three widget extensions to re-render.
- `lib/core/presentation/cubit/locale_cubit.dart` — `WidgetDataService` injected; `setLocale` calls `pushLocaleOnly`
- `lib/core/services/widget_data_service.dart` — `pushLocaleOnly(String localeCode)` added
- `lib/app.dart` — `LocaleCubit` constructor updated to pass `getIt<WidgetDataService>()`

### FIXED: P2 — toggleTaskCompletionByUuid cache miss drops widget action
`toggleTaskCompletionByUuid` now falls back to `_repository.getTaskByUuid(uuid)` (Isar query) when the task is not in `_cachedTasks`. `getTaskByUuid` was added to `TaskRepository` (abstract) and `TaskRepositoryImpl`.
- `lib/features/task/presentation/cubit/task_cubit.dart`
- `lib/features/task/domain/repositories/task_repository.dart`
- `lib/features/task/data/repositories/task_repository_impl.dart`

### FIXED: P3 — completeHabitByUuid / incrementHabitProgressByUuid cache miss
Both methods now fall back to `_habitRepository.getHabitByUuid(uuid)` when the habit is not in `_cachedHabits`. The repository method already existed at `habit_repository_impl.dart` line 215.
- `lib/features/habits/presentation/cubit/habit_cubit.dart`



### FIXED: HealthError imported into HabitCubit
`health_state.dart` was imported in `habit_cubit.dart`. `HealthError` type leaked into habit error handling. Removed import; habit catch blocks now emit `HabitError` correctly.

### FIXED: iOS deployment target inconsistency
Mixed 16/17 across targets caused `objective_c.framework` invalid signature on device. All targets now set to 17.0 in Podfile and project.pbxproj.

### FIXED: AtharHabitWidget entitlements only wired for Profile config
Debug and Release configs now also wire `CODE_SIGN_ENTITLEMENTS`.

### FIXED: localeResolutionCallback missing
MaterialApp previously defaulted to Arabic for any unsupported device language (first supportedLocales entry). Fixed with explicit callback: ar→ar-SA, en→en-US, other→en-US.

### FIXED: initializeDateFormatting not called for en_US
Runtime error when switching to English after first launch. Fixed in `main.dart`.

### FIXED: StaticConfiguration → AppIntentConfiguration
All three widget extensions migrated to interactive `AppIntentConfiguration` (requires iOS 17).

### FIXED: Prayer widget v4/v5/v6 payload
`prevPrayerTimestamp`, nafl window flags, prev prayer names all wired through.

### FIXED: Parity dedup for rapid habit widget taps
Even count of same-uuid complete actions = skip (double-tap no-op).

---

## Behavioral Quirks (Not Bugs — Intentional)

### Athkar excluded from Habit widget
Morning/evening Athkar (`HabitType.athkar`) are intentionally not shown in the Habit widget. `pushHabitData` filters `h.type == HabitType.regular` only. Athkar belong to the prayer/dhikr flow.

### UnifiedTasksPage has a dead TaskCubit
`UnifiedTasksPage` creates a `TaskCubit` via `getIt<TaskCubit>()` but never calls `watchTasks()`. It's essentially unused. Task display comes from `TimelineCubit`. Don't try to wire the page's TaskCubit for display.

### HabitCubit in MainPage does not call loadHabits() on creation
`MainPage._localHabitCubit` is created without calling `loadHabits()`. `HabitPage.initState()` calls it on first build via `context.read<HabitCubit>().loadHabits()`. Don't expect habits to load before HabitPage mounts.

### WidgetKeys constants cannot be renamed
Any rename silently breaks installed widgets on all user devices. Add new versioned keys instead; keep old ones even if unused.

### GoRouter stub
`core/config/routes.dart` exists but is not wired into `MaterialApp`. All routing uses named routes defined in `app.dart`. Do not attempt to use GoRouter.

### task feature has no local Isar datasource class
Unlike other features, `task` has no `TaskLocalDataSource`. Isar writes are done directly from `TaskRepositoryImpl`. The `task_remote_source.dart` handles Supabase.

---

## Fragile Areas (High Risk of Regression)

| Area | Why fragile |
|------|------------|
| BlocProvider shadowing in MainPage | 3 TaskCubit instances; wrong one is easy to read |
| processWidgetPendingActions context | Uses `DeepLinkService.navigatorKey.currentContext` — null if no active route |
| HijriCalendar locale global state | `HijriCalendar.setLocal()` is a global setter; interleaved calls can return wrong locale strings |
| SyncService on first launch | If Isar is empty on first launch, sync may push no records and skip initial seeding |
| Notification auto-renewal | Payload string `'auto_reschedule_prayers'` is hardcoded in both `main.dart` and scheduler — must stay in sync |
