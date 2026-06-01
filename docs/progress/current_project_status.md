# Athar — Current Project Status
_Last updated: 2026-06-01 (PR-THEME FINAL complete — AtharLightTheme/AtharDarkTheme wired, 88 fontFamilyFallback, RTL drawer, 0 analyzer issues, 45/45 tests)_

## Completed Work

### Infrastructure & Architecture
- **iOS 17.0 minimum deployment target** — all native targets and pod post-install set to 17.0 (was mixed 16/17 causing `objective_c.framework` invalid signature on device)
- **AtharHabitWidgetExtension entitlements** — Debug and Release configs now wire `CODE_SIGN_ENTITLEMENTS = AtharHabitWidgetExtensionProfile.entitlements`; previously only Profile config was wired
- **Locale default** — `LocaleCubit` stores `'ar'` / `'en'`; missing key means Arabic (default). `PrayerCubit` reads locale with `?? 'system'` fallback (not `?? 'ar'`)
- **`localeResolutionCallback`** added to `MaterialApp` in `app.dart` — maps `ar` → `ar-SA`, `en` → `en-US`, unsupported → `en-US` (previously Flutter defaulted to index-0 of supportedLocales = Arabic for unsupported languages)
- **`initializeDateFormatting('en_US')`** added in `main.dart` — prevents runtime errors when switching to English after first launch
- **HijriCalendar global locale** — removed redundant `setLocal('ar')` reset from `_buildDateEn()` in `widget_data_service.dart`

### Prayer Widget (iOS) — Phase 0–7 Complete
- Widget v5 payload schema: `prevPrayerTimestamp`, `isDuhaTime` (int 0/1), `isQiyamTime` (int 0/1), `locale` (sentinel `'system'`)
- `WidgetDataService.pushPrayerData` accepts and writes all v5 keys
- `PrayerCubit.loadPrayerTimes()` computes `isDuhaTime` / `isQiyamTime` matching `PrayerTimerService` algorithm
- Swift `AtharPrayerWidget.swift` fully rewritten:
  - `resolvedLocale` handles `'system'` sentinel via `Locale.current.language.languageCode`
  - RTL layout via `.environment(\.layoutDirection, .rightToLeft/.leftToRight)`
  - `NaflBadge` view: gold capsule for Duha ("وقت الضحى"), soft blue for Qiyam ("قيام الليل")
  - `AppIntentConfiguration` with `PrayerWidgetIntent` (size/detail parameters)
  - All three widget families: small, medium, large

### Habit Feature
- **`HealthError as HabitState` crash fixed** — removed `health_state.dart` import from `habit_cubit.dart`; `addHabit` and `updateHabit` catch blocks now emit `HabitError("...: $e")` correctly
- **`HabitError` handling in `habit_page.dart`** — `BlocListener` now shows SnackBar on `HabitError` state

### Task Feature
- **`TaskError` handling in `task_page.dart`** — `BlocListener` now shows `AtharSnackbar.error` on `TaskError` state

### Sync & Settings
- Sync page removed (deleted `sync_page.dart`); sync is background-only via `SyncCubit`
- Language switching fully functional via `LocaleCubit` with `FlutterSecureStorage` persistence

### iOS Widget Data Contracts — Phase 0–3 Complete

- **Phase 0** — stale scaffold directory `ios/AtharHabitWidget AtharHabitWidget AtharHabitWidget/` deleted (was never in build target; confirmed zero pbxproj references). Stale `AtharHabitWidget AtharHabitWidget AtharHabitWidgetExtension.entitlements` also deleted. Both habit and task widget targets build successfully.
- **Phase 1** — `WidgetDataService.pushTaskData` and `pushHabitData` extended:
  - Task JSON items: `{t, d, p}` → `{t, d, p, u}` where `u` = `uuid` (String, non-nullable)
  - Habit JSON items: `{t, d, s}` → `{t, d, s, u, cp, tg}` where `u` = uuid, `cp` = currentProgress, `tg` = target
  - Habits with null uuid skipped (guard for safety; uuid is `String?` on HabitModel)
  - Both methods now write `athar_app_locale` (`'ar'`/`'en'`/`'system'`) to App Group
  - Added `_readLocale()` private helper; added `flutter_secure_storage` import
- **Phase 2** — `AtharTaskWidget.swift` fully rewritten (`StaticConfiguration` → `AppIntentConfiguration`):
  - `ToggleTaskIntent: AppIntent` writes `{type, uuid, done, createdAt}` to `athar_pending_task_actions`
  - Optimistic in-widget toggle + `WidgetCenter.shared.reloadTimelines`
  - `TaskCubit.toggleTaskCompletionByUuid` + `processWidgetPendingActions` added
  - `app.dart` `onResume` calls `TaskCubit.processWidgetPendingActions()`
  - `WidgetDataService.consumePendingTaskActions()` reads + clears queue
  - flutter analyze clean; AtharTaskWidgetExtension BUILD SUCCEEDED
- **Phase 4** — Hardening + edge cases + prayer widget polish:
  - Safe UUID lookup: `toggleTaskCompletionByUuid` and `completeHabitByUuid` use `indexWhere` + `-1` guard — no more `StateError` on cache miss
  - Parity dedup: `complete_habit` actions counted per uuid; even count → skip (rapid double-tap no-op); odd → apply once
  - Prayer widget v6 payload: `prevPrayerNameAr/En` keys written by `WidgetDataService` and read by Swift; `isCurrentPrayerWindow` computed in Swift (< 30 min after `prevPrayerTime`); `headerLabel` switches to "صلاة جارية" / "Prayer Time"
  - Small prayer widget: "باقي/in" label now shown above live countdown timer (parity with medium)
  - Color normalization: `navyDeep(0.07,0.09,0.15)` and `navyMid(0.12,0.16,0.24)` unified across all 3 widget Swift files
  - flutter analyze clean; all 3 widget extensions BUILD SUCCEEDED
- **Phase 3** — `AtharHabitWidget.swift` fully rewritten (`StaticConfiguration` → `AppIntentConfiguration`):
  - `CompleteHabitIntent` (boolean toggle) + `IncrementHabitIntent` (count +1) AppIntents
  - Boolean rows: circle/checkmark toggle; count-based rows: `+`/`✓` + teal progress bar
  - Streak badge (`flame.fill` + count); bilingual (AR/EN); RTL/LTR via `.environment(\.layoutDirection, ...)`
  - `athar_pending_habit_actions` queue; optimistic update in Swift
  - `HabitCubit.completeHabitByUuid` → `toggleHabitOnDate`; `incrementHabitProgressByUuid` → `updateHabit`
  - `HabitCubit.processWidgetPendingActions` dispatches both action types
  - `app.dart` `onResume` calls `HabitCubit.processWidgetPendingActions()`
  - `WidgetKeys.pendingHabitActions` + `consumePendingHabitActions()` added to `WidgetDataService`
  - flutter analyze clean; AtharHabitWidgetExtension BUILD SUCCEEDED

---

## v2 Design System Status

### PR1 — Complete (`61d741a` on `feat/athar-v2-pr1-tokens-theme`)

- **`athar_colors.dart`** — 22 token corrections: green brand palette (light) + warm green-tinted dark surfaces/cream text (THEME_DARK_SPEC.md)
- **`athar_typography.dart`** — `fontFamilyAr/En` → `'Calibri'`; `numericMono` (JetBrains Mono + tabularFigures) added
- **`pubspec.yaml`** — Calibri font family: Light 300 / Regular 400 / Bold 700
- **Font assets** — `calibri-light.ttf`, `calibri-regular.ttf`, `calibri-bold.ttf` added to `assets/fonts/`
- `flutter analyze`: 0 issues | `flutter test`: 29/29 passed
- **Blocker B1 open:** Calibri App Store licence — designer confirmation required before TestFlight submission

### PR-THEME — Complete ✅ (superseded by PR-THEME-3MODE)

`ThemeMode.system` wired when `isDarkMode=false`. Superseded by PR-THEME-3MODE.

### PR-THEME-3MODE — Complete ✅

- `ThemePreference` enum (`system` / `light` / `dark`) added to `UserSettings` with `@Enumerated(EnumType.name)`
- One-time migration: `isDarkMode=true` → `ThemePreference.dark`; `isDarkMode=false` → `ThemePreference.system`
- Dark Mode toggle replaced by 3-option picker tile in Settings → Appearance
- `app.dart` uses exhaustive Dart 3 `switch` expression
- `build_runner` + `gen-l10n` run; `darkModeDesc` removed from ARBs
- `flutter analyze`: 0 issues | `flutter test`: 29/29
- Theme architecture: **STABLE** — see `ARCHITECTURE_STABILIZATION_REPORT.md`
- Tag: `athar-v2-prtheme-3mode-complete`

### PR2 — AdaptiveShell — COMPLETE ✅

**Tag: `athar-v2-pr2-complete` — all 6 checkpoints verified**

Files created/modified:
- `lib/core/design_system/widgets/adaptive_shell.dart` — **new** (`ShellBreakpoint` enum + `AdaptiveShell` LayoutBuilder)
- `lib/features/home/presentation/pages/main_page.dart` — Scaffold wrapped in `AdaptiveShell`; `effectivelyExpanded`; compact-rail guard; RTL Row
- `lib/core/design_system/widgets/liquid_glass_nav_bar.dart` — FAB shape: circle → 22px pill; gradient: `#2F7A5E→#0F3D2E`

Governance: `PR2_PROGRESS_REPORT.md` · `PR2_CHECKPOINTS.md`  
Analyzer: 0 issues · Tests: 29/29

### PR-FONT-FALLBACK — Complete ✅ (commit `3872860`)

- Cairo fallback on all 38 `AtharTypography` `const TextStyle` definitions
- Cairo fallback on `.arabic`, `.english`, `.mono` extension methods
- `fontFallback = ['Cairo', 'Roboto', 'Arial', 'sans-serif']` canonical constant added

### PR3 — Prayer Card Refresh — Complete ✅ (commit `1cd4f80`)

- Forest gradient (`#0F3D2E → #1A5A45`), 44pt countdown (light weight), calm active state
- 16/16 golden tests: AR + EN × 8 scenarios (upcoming, active, nafl-duha, expanded, loading, permission-denied, SE-375×667, progress-50%)
- Shadow blurRadius 20/8 accepted (canonical, locked); shadow colors correct
- `flutter analyze`: 0 · `flutter test`: 45/45
- Verified: `CONSOLIDATED_REPORT_PR3.md` + `PR3_SIGNOFF.md`

### PR-THEME FINAL — Complete ✅ (commit `bfaf863`, tag `athar-v2-prtheme-complete-final`)

- Wire `app.dart` to `AtharLightTheme.theme` / `AtharDarkTheme.theme` (replaces legacy `AppTheme` stub)
- 44 × `fontFamilyFallback: AtharTypography.fontFallback` in `athar_light_theme.dart`
- 44 × `fontFamilyFallback: AtharTypography.fontFallback` in `athar_dark_theme.dart`
- `DrawerTheme.shape`: `BorderRadius.only` → `BorderRadiusDirectional.only` (RTL fix) in both files
- Deleted: `app_theme.dart` (legacy stub), `athar_theme.dart` (empty stub)
- Cleaned: `themes.dart` barrel
- `flutter analyze`: 0 · `flutter test`: 45/45 · PR3 goldens: 16/16 unchanged
- Verification: `VERIFICATION_PR_THEME.md`

### PR4a — Calendar Visual Refresh ✅ Complete 2026-06-01

Commit `85ada1e`. Tag `athar-v2-pr4a-complete`. RULE 1 fix, token migration, today state, RTL. 2 device-QA gates in Deferred QA Bucket (`CURRENT_MIGRATION_STATE.md`).

### Next PR — PR5 / PR6 / PR8 / PR9

All unblocked by PR2 ✅. Pending designer confirmation.  
See `ROADMAP_AFTER_PR4A.md` for options and `IMPLEMENTATION_MASTER_STATUS.md` for authoritative PR ordering + %.

---

## Remaining Work

### Priority 1 — Device Validation (Phase 5)
- Physical device test: interactive widget taps (Task toggle, Habit boolean + count-based)
- Verify current-prayer window "صلاة جارية" state with live prayer times
- Verify locale switching (AR↔EN) while widget on Home Screen
- Verify cold-start pending-action replay (kill app after widget tap, reopen)
- App Store / TestFlight checklist: entitlements, App Group provisioning, widget display names

### Priority 2 — Cairo Font for Widget Text
- Apply Cairo font to Task + Habit widget rows (Arabic text rendering)

### Priority 3 — Android Widgets
- Four Android widget types exist but are lower priority than iOS
- Task + Habit widgets need same interactive treatment as iOS

---

## Key Project Decisions (Do Not Reverse Without Discussion)

| Decision | Rationale |
|---|---|
| No page-level FABs on TaskPage or HabitPage | Central NavBar add button is the single creation entry point; duplicate FABs were confusing |
| iOS 17.0 minimum | Required for `AppIntentConfiguration` + `AppIntentTimelineProvider` (interactive widgets) |
| `'system'` locale sentinel in widget payload | Decouples app locale from device locale; widget self-resolves via `Locale.current` |
| Athkar excluded from habit widget | Athkar belong to the prayer/dhikr flow, not the habit tracking flow |
| App Group ID: `group.com.iappsnet.athar` | Shared between Runner and all widget extensions — never change this |
| `WidgetKeys` constants are canonical | Any rename breaks live widgets on user devices — add new keys, never rename existing |

---

## Widget Payload Schema — Current (v5)

| Key constant | UserDefaults key | Type | Notes |
|---|---|---|---|
| `nextPrayerName` | `athar_next_prayer_name_ar` | String | Arabic name |
| `nextPrayerNameEn` | `athar_next_prayer_name_en` | String | English name |
| `prayerType` | `athar_prayer_type` | String | `fard` / `nafl_duha` / `nafl_qiyam` |
| `nextPrayerTime` | `athar_next_prayer_time` | String | Formatted HH:mm |
| `prevPrayerTimestamp` | `athar_prev_prayer_timestamp` | Double | Unix epoch (prev prayer time) |
| `cityName` | `athar_city_name` | String | Display city |
| `appLocale` | `athar_app_locale` | String | `"ar"` / `"en"` / `"system"` |
| `isDuhaTime` | `athar_is_duha_time` | Int | 0 or 1 |
| `isQiyamTime` | `athar_is_qiyam_time` | Int | 0 or 1 |
| `widgetDataVersion` | `athar_widget_data_version` | Int | Currently 5 |

---

## SocratiCode Index Status
- 2798 chunks indexed, watcher active
- Dependency graph: 477 files / 426 edges
- Last updated: 2026-05-03
