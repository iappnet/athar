# Athar Phase Tracker

_Last updated: 2026-05-09 (PR-THEME-3MODE complete — theme architecture stabilized)_

---

## Phase 0 — Project Stabilization

Status: ✅ Complete

Completed items:
- iOS 17.0 minimum deployment target set in Podfile and all `project.pbxproj` targets (was mixed 16/17 causing `objective_c.framework` invalid signature on device)
- `AtharHabitWidgetExtension` entitlements wired in Debug + Release configs (previously only Profile config was wired)
- `LocaleCubit` locale default: stores `'ar'` / `'en'`; null key → Arabic default; `PrayerCubit` uses `?? 'system'` fallback
- `localeResolutionCallback` added to `MaterialApp` — `ar` → `ar-SA`, `en` → `en-US`, unsupported → `en-US`
- `initializeDateFormatting('en_US')` added in `main.dart` — prevents runtime crash on first English switch
- `HijriCalendar` global locale — removed redundant `setLocal('ar')` reset from `_buildDateEn()`
- Stale scaffold dir `ios/AtharHabitWidget AtharHabitWidget AtharHabitWidget/` deleted (never in build target; zero pbxproj refs)
- Stale `AtharHabitWidget AtharHabitWidget AtharHabitWidgetExtension.entitlements` deleted
- `sync_page.dart` deleted — sync is background-only via `SyncCubit`
- Language switching fully functional via `LocaleCubit` + `FlutterSecureStorage`

Remaining: none

---

## Phase 1 — Core Workflow Fixes

Status: ✅ Complete

Completed items:
- `HealthError as HabitState` crash fixed — removed `health_state.dart` import from `habit_cubit.dart`; catch blocks now emit `HabitError("...: $e")` correctly
- `HabitError` handling in `habit_page.dart` — `BlocListener` shows `SnackBar` on `HabitError`
- `TaskError` handling in `task_page.dart` — `BlocListener` shows `AtharSnackbar.error` on `TaskError`
- Prayer widget (iOS) fully rewritten (`AtharPrayerWidget.swift`) — `AppIntentConfiguration`, `PrayerWidgetIntent`, `NaflBadge`, v5 payload schema, all families (small/medium/accessoryCircular/accessoryRectangular), RTL/LTR, bilingual
- `WidgetDataService.pushPrayerData` writes all v5 keys: `prevPrayerTimestamp`, `isDuhaTime`, `isQiyamTime`, `athar_app_locale` (sentinel `'system'`)
- `PrayerCubit.loadPrayerTimes()` computes `isDuhaTime` / `isQiyamTime` correctly
- Widget data contract extended: task JSON `{t,d,p}` → `{t,d,p,u}`; habit JSON `{t,d,s}` → `{t,d,s,u,cp,tg}`
- Both `pushTaskData` and `pushHabitData` write `athar_app_locale` to App Group
- `WidgetDataService._readLocale()` added — reads `preferred_locale` from `FlutterSecureStorage`
- `app.dart` `onResume` calls `PrayerCubit.loadPrayerTimes()` to keep widget fresh after backgrounding

Remaining: none

---

## Phase 2 — Task Interactive Widget

Status: ✅ Complete

Completed items:
- `AtharTaskWidget.swift` fully rewritten — `StaticConfiguration` → `AppIntentConfiguration` + `AppIntentTimelineProvider`
- `ToggleTaskIntent: AppIntent` — writes `{type:"toggle_task", uuid, done, createdAt}` to `athar_pending_task_actions`; optimistic toggle of `athar_tasks` + `athar_tasks_done` in App Group; calls `WidgetCenter.shared.reloadTimelines`
- `TaskWidgetIntent: WidgetConfigurationIntent` — no user params; locale from `athar_app_locale`
- `WTask` struct — `Decodable` from keys `{t,d,p,u}`; `uuid` field drives AppIntent routing
- `TaskWidgetView` — dark gradient (`navyDeep/navyMid`), gold header, 3/4/7 rows (small/medium/large), priority color dots, strikethrough on done, bilingual AR/EN, RTL/LTR via `.environment(\.layoutDirection, ...)`
- `WidgetKeys.pendingTaskActions = 'athar_pending_task_actions'` added
- `WidgetDataService.consumePendingTaskActions()` — reads + clears queue; returns `List<Map<String,dynamic>>`
- `TaskCubit.toggleTaskCompletionByUuid(String uuid, bool isDone)` — looks up in `_cachedTasks`, calls `_repository.toggleTaskCompletion`, invalidates stats cache
- `TaskCubit.processWidgetPendingActions()` — dispatches all `toggle_task` actions
- `app.dart` `onResume` calls `ctx.read<TaskCubit>().processWidgetPendingActions()`
- `flutter analyze` clean; `AtharTaskWidgetExtension` BUILD SUCCEEDED

Remaining: none

---

## Phase 3 — Habit Interactive Widget

Status: ✅ Complete

Completed items:
- `AtharHabitWidget.swift` fully rewritten — `StaticConfiguration` → `AppIntentConfiguration` + `AppIntentTimelineProvider`
- `CompleteHabitIntent: AppIntent` — writes `{type:"complete_habit", uuid, createdAt}`; optimistically toggles `d`/`cp` in `athar_habits`; updates `athar_habits_done`; calls `WidgetCenter.shared.reloadTimelines`
- `IncrementHabitIntent: AppIntent` — writes `{type:"increment_habit", uuid, createdAt}`; optimistically increments `cp`, clamps to `tg`, marks `d=true` when `cp>=tg`
- Shared `appendPendingHabitAction(d:type:uuid:)` free function used by both intents — writes to `athar_pending_habit_actions`
- `WHabit` struct — resilient `Decodable` with fallback defaults; decodes `{t,d,s,u,cp,tg}`; exposes `isCountBased` and `progressFraction`
- `HabitWidgetView` — dark gradient, gold header (`leaf.fill` icon), 3/4/6 rows (small/medium/large)
- Boolean rows (`target<=1`): circle/checkmark `Button(intent: CompleteHabitIntent)` + flame streak badge
- Count-based rows (`target>1`): `+`/`✓` button (IncrementHabitIntent / CompleteHabitIntent for reset), `cp/tg` counter, 3px teal capsule progress bar
- Bilingual AR/EN; RTL/LTR via `.environment(\.layoutDirection, ...)`; Athkar habits excluded by Flutter `pushHabitData` filter
- `WidgetKeys.pendingHabitActions = 'athar_pending_habit_actions'` added
- `WidgetDataService.consumePendingHabitActions()` — reads + clears queue
- `HabitCubit.completeHabitByUuid(String uuid)` — delegates to `toggleHabitOnDate(habit.id, DateTime.now())` (handles `completedDays`, `currentStreak`, `isCompleted`)
- `HabitCubit.incrementHabitProgressByUuid(String uuid)` — increments `currentProgress` by 1; marks complete with streak/completedDays update when `>=target`; calls `updateHabit` + `_emitCategorizedHabits`
- `HabitCubit.processWidgetPendingActions()` — dispatches `complete_habit` and `increment_habit` actions
- `app.dart` `onResume` calls `ctx.read<HabitCubit>().processWidgetPendingActions()`
- `flutter analyze` clean; `AtharHabitWidgetExtension` BUILD SUCCEEDED

Remaining: none

---

## Phase 4 — Hardening + Edge Cases + Prayer Widget Polish

Status: ✅ Complete

Completed items:
- **Safe UUID lookup** — `toggleTaskCompletionByUuid` and `completeHabitByUuid` now use `indexWhere` + `-1` check; explicit debug log on cache miss; no more silent `StateError` from `firstWhere`
- **Parity dedup for `complete_habit`** — `processWidgetPendingActions` counts `complete_habit` occurrences per uuid; even count → net no-op (skipped); odd count → applied once; prevents double-toggle from rapid widget taps
- **Prayer widget current-prayer state** — added `prevPrayerNameAr/En` keys (v6 payload) to `WidgetDataService`; `PrayerCubit` passes `prevPrayer.nameArabic/nameEnglish`; Swift computes `isCurrentPrayerWindow` (< 30 min after `prevPrayerTime`); `headerLabel` shows "صلاة جارية" / "Prayer Time" when in window
- **"باقي/in" in small prayer widget** — countdown section now shows locale-aware "باقي" / "in" label above the live timer (parity with medium widget)
- **Color normalization** — `navyDeep` and `navyMid` values unified across Task, Habit, and Prayer widgets (`0.07,0.09,0.15` and `0.12,0.16,0.24`)
- **`flutter analyze` clean** — no issues
- **All 3 widget extensions BUILD SUCCEEDED** — AtharPrayerWidgetExtension, AtharTaskWidgetExtension, AtharHabitWidgetExtension

Remaining:
- **Cairo font** — apply Cairo font to Task + Habit widget text (deferred to post-Phase 5)
- **Android widgets** — 4 widget types exist; need same interactive treatment as iOS or at minimum data-contract parity

---

## Phase 5 — Device Validation + Release Readiness

Status: 🔲 Pending

Completed items: none

Remaining:
- Physical device test — interactive widget taps (simulator does not support `AppIntent` interactions)
- Verify Task widget: tap checkbox → optimistic toggle → open app → Isar committed → widget canonical refresh
- Verify Habit widget: boolean tap, count-based increment, done→reset tap
- Verify Prayer widget: correct nafl badge display, RTL/LTR, both locales
- Regression test: language switch (AR↔EN) while widget is on Home Screen → widget updates locale
- Regression test: app kill immediately after widget tap → action replayed on next cold start
- App Store / TestFlight submission checklist: entitlements, App Group provisioning, widget display names

---

---

## v2 Design System PR Track

_Authority: `handoff_v2-2/CLAUDE_CODE_PROMPT.md` + `handoff_v2-2/FINAL_PACKAGE_MANIFEST.md`_  
_Branch: `feat/athar-v2-pr1-tokens-theme` (long-running migration branch — do NOT merge to `main` until complete)_  
_Roadmap verified 2026-05-09 — see `MIGRATION_ROADMAP_VERIFICATION.md` for corrected canonical sequence_

### PR1 — Tokens & Theme

**Status: ✅ Complete — commit `61d741a` on `feat/athar-v2-pr1-tokens-theme`**

Completed items:
- `athar_colors.dart` — 6 light palette corrections + 16 dark palette corrections (green brand + THEME_DARK_SPEC.md warm dark surfaces)
- `athar_typography.dart` — `fontFamilyAr/En` → `'Calibri'`; `numericMono` TextStyle added
- `pubspec.yaml` — Calibri font family registered (weights 300/400/700)
- `assets/fonts/` — `calibri-light.ttf`, `calibri-regular.ttf`, `calibri-bold.ttf` added
- `flutter analyze`: 0 issues; `flutter test`: 29/29 passed

Remaining:
- B1: Calibri App Store licence confirmation (submission gate only — does not block development)

### PR-THEME — Design System Theme Wiring (full arc)

**Status: ✅ Complete 2026-06-01 — tag `athar-v2-prtheme-complete-final`**

Full arc delivered across 4 commits:
- `14c13d6` ThemeMode.system wiring (`athar-v2-prtheme-complete`)
- `66bc884` ThemePreference enum + 3-mode picker (`athar-v2-prtheme-3mode-complete`)
- `3872860` PR-FONT-FALLBACK — Cairo fallback on all 38 AtharTypography base styles
- `bfaf863` Wire AtharLightTheme/AtharDarkTheme; 88 fontFamilyFallback; RTL DrawerTheme

`flutter analyze`: 0 issues · `flutter test`: 45/45 · Verification: `VERIFICATION_PR_THEME.md`

### PR-THEME-3MODE — ThemePreference enum (3-option picker)

**Status: ✅ Complete — `athar-v2-prtheme-3mode-complete`**

- `ThemePreference` enum (`system` / `light` / `dark`) added to `UserSettings`
- One-time migration: `isDarkMode=true` → `ThemePreference.dark`; `isDarkMode=false` → `ThemePreference.system`
- `_ThemeTile` + bottom-sheet picker replaces Dark Mode toggle in Settings
- `app.dart` uses exhaustive Dart 3 `switch` expression
- `flutter analyze`: 0 issues | `flutter test`: 29/29
- Theme architecture: **STABLE**
- Full details: `ARCHITECTURE_STABILIZATION_REPORT.md`

---

### PR2 — AdaptiveShell

**Status: ✅ Complete — tag `athar-v2-pr2-complete`**

All spec files read: `IPAD_OPTIMIZATION.md` ✅ · `REDESIGN_AUDIT.md` ✅ · `INVESTIGATION_REPORT.md` ✅ · `preview/comp-nav.html` ✅

CP1 ✅ `adaptive_shell.dart` created  
CP2 ✅ `main_page.dart` + `liquid_glass_nav_bar.dart` updated  
CP3 ✅ Responsive breakpoints — code-verified  
CP4 ✅ Navigation persistence + routing — code-verified  
CP5 ✅ Safe-area + RTL + keyboard — code-verified  
CP6 ✅ Final validation — 0 issues · 29/29 · tag created

Governance: `PR2_PROGRESS_REPORT.md` · `PR2_CHECKPOINTS.md`

---

### PR-FONT-FALLBACK

**Status: ✅ Complete — commit `3872860`**

Cairo fallback on all 38 `AtharTypography` `const TextStyle` definitions + 3 extension methods.
Delivered as part of the PR-THEME arc.

---

### PR3 — Prayer Card Refresh

**Status: ✅ Complete 2026-06-01 — commit `1cd4f80`**

Forest gradient (`#0F3D2E → #1A5A45`), 44pt countdown (weight 300), calm active/post-prayer states.  
16/16 golden tests pass (AR + EN × 8 scenarios). Shadow blurRadius 20/8 accepted (canonical).  
`flutter analyze`: 0 issues · `flutter test`: 45/45 · Sign-off: `PR3_SIGNOFF.md`

---

### PR4a through PR-CLEANUP

**Status: 🔲 Not started — PR2 ✅ unblocks PR4a, PR5, PR6, PR8, PR9**

| PR | First prerequisite |
|----|-------------------|
| PR4a — Calendar visual refresh | Read `CALENDAR_FOCUS_REDESIGN.md` |
| PR4b — Calendar dual-display | PR4a + designer spec |
| PR5 — Accessibility Settings | None |
| PR6 — Stats redesign | Read `STATS_KPI_SPEC.md` |
| PR7 — Athkar feature | PR2 + designer review |
| PR8 — Focus oil-fill | Read `FOCUS_OIL_SPEC.md` |
| PR9 — iOS widget visual refresh | None |
| PR-ONBOARD-AB | PR2 + designer approval |
| PR-CLEANUP | All others complete |

See `IMPLEMENTATION_MASTER_STATUS.md` + `PROGRAM_IMPLEMENTATION_STATUS.md` for full roadmap.

---

## Global Constraints

- Do not add page-level FABs to `TaskPage` or `HabitPage`.
- Central `LiquidGlassNavBar` add button is the only add entry point.
- iOS minimum target is 17.0 — required for `AppIntentConfiguration` + `AppIntentTimelineProvider`.
- All interactive widgets use the `AppIntent` + App Group pending-action queue pattern.
- Isar is the source of truth — Swift widgets read display data only; they never write to Isar directly.
- Do not access Isar directly from Swift widget extensions.
- Do not add polling hacks — use `WidgetCenter.shared.reloadTimelines` after intent and `onResume` consumer for Dart sync.
- `WidgetKeys` constants are canonical — never rename existing keys; only add new ones.
- App Group ID `group.com.iappsnet.athar` is fixed — never change.
- Athkar habits are excluded from the Habit widget — they belong to the prayer/dhikr flow.
