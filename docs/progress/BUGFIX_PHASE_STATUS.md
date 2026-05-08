# Bugfix Phase Status

_Last updated: 2026-05-06_

---

## Current Stopped Phase: 8.1

## Last Completed Phase: 8.1 — Prayer master toggle + card sub-setting + migration, code-verified

---

## Phase 1 — Task Add Flow from central NavBar

**Status: ✅ Code-verified (fix applied, pending device test)**

### Real Root Cause (confirmed by device test failure)
`TaskCubit.addTask()` calls `await getIt<SubscriptionCubit>().ready`. `SubscriptionCubit` was annotated `@injectable` (factory) — every `getIt<>()` call creates a NEW instance whose `_readyCompleter` is never completed → infinite hang → spinner freezes, sheet never closes, no task saved.

Previous session's fix (state-check after `addTask()`) was correct in isolation but irrelevant — the code never reached it because `addTask()` itself hung.

### Root Cause Fix
Changed `@injectable` → `@lazySingleton` in `subscription_cubit.dart` (line 16).
Regenerated `injection.config.dart` via `flutter pub run build_runner build --delete-conflicting-outputs`.
`injection.config.dart` now registers `gh.lazySingleton<SubscriptionCubit>` — all `getIt<>()` calls return the same instance whose `_readyCompleter` is completed by `loadStatus()` at startup.

### Files Modified
- `lib/features/subscription/presentation/cubit/subscription_cubit.dart` — `@injectable` → `@lazySingleton`
- `lib/core/di/injection.config.dart` — regenerated (never edit directly)
- `lib/features/task/presentation/cubit/task_cubit.dart` — added debug logs (3 `debugPrint` calls)
- `lib/features/task/presentation/widgets/unified_add_sheet.dart` — state check (prior session, still correct)

### Bugs Fixed
- **CRITICAL**: `addTask()` infinite hang — save button permanently grey/spinning, sheet never closed
- Task add: sheet no longer closes when `addTask()` emits `TaskError` or `TaskFreeLimitReached` (prior session)
- Task add: `_isSaving` spinner is reset on failure (prior session)
- Task add: `barrierDismissible: false` on ConflictDialog (prior session)

### Bugs NOT Fixed in This Phase
- NavBar + Habit add (Phase 2) — likely same `@lazySingleton` issue in `addHabit()`
- iOS Widget localization (Phase 4)
- Athkar in Habit widget (Phase 5)
- Prayer notifications default (Phase 6)

### Verification
- `flutter analyze` → No issues found ✅
- `injection.config.dart` → `gh.lazySingleton<SubscriptionCubit>` confirmed ✅
- Device test: PENDING — required to confirm fix

---

## Phase 2 — Habit Add Flow from central NavBar

**Status: ✅ Code-verified (fix applied, pending device test)**

### Root Cause
`HabitFormSheet._saveHabit()` called `cubit.addHabit(newHabit)` without `await` and immediately called `Navigator.pop(context)`. The sheet always closed regardless of success/failure. No loading guard — user could tap Save multiple times.

### Fix Applied
- `_saveHabit()` is now `async`; `await cubit.addHabit(habit)` before popping
- `_isSaving` flag prevents double-taps and disables the save button with a spinner
- After `await`, checks `cubit.state`: if `HabitFreeLimitReached` or `HabitError`, resets `_isSaving` and returns (sheet stays open; `HabitPage` BlocListener handles the nudge/snackbar)
- Only pops on success (`HabitLoaded`)
- Debug prints added to `addHabit()` for device-test verification

### Files Modified
- `lib/features/habits/presentation/widgets/habit_form_dialog.dart` — async save, `_isSaving` state, state check
- `lib/features/habits/presentation/cubit/habit_cubit.dart` — debug prints in `addHabit()`

### Verification
- `flutter analyze` → No issues found ✅
- Device test: PENDING

---

## Phase 3 — Verify remaining NavBar targets

**Status: ✅ Code-verified (fix applied, pending device test)**

### Targets Audited
- Task add: already fixed (Phase 1) — no change
- Habit add: already fixed (Phase 2) — no change
- Medicine add: `await healthCubit.addMedicine()` + HealthError state check
- Appointment add: `await healthCubit.addAppointment()` + HealthError state check
- Module add (`AddModuleSheet`): `_isSaving` guard + async `_save()` + `ModuleError` state check
- Space create (inline dialog): `await createSpace()` + `ctx.mounted` guard before pop

### Files Modified
- `lib/features/task/presentation/widgets/unified_add_sheet.dart`
- `lib/features/space/presentation/widgets/add_module_sheet.dart`
- `lib/features/home/presentation/pages/main_page.dart`

### Verification
- `flutter analyze` → No issues found ✅
- Device test: PENDING

---

## Phase 4 — Task/Habit iOS Widget localization

**Status: ✅ Code-verified (Phase 4b fix applied), pending device test**

### Root Cause (Phase 4 first report was wrong)
`resolvedLang()` in both Task and Habit Swift files checked `stored` (app locale from `athar_app_locale`) first in System mode — causing Arabic-app users to always see Arabic in the widget even when device language is English. Three bugs: app locale used instead of device locale; Arabic nil fallback; non-English devices → Arabic.

### Fix
Rewrote `resolvedLang()` System branch in both files:
- **Before**: `stored` (app locale) checked first → Arabic fallback for anything else
- **After**: `Locale.current.language.languageCode?.identifier` only → Arabic if device is Arabic, English for everything else including nil

### Typography
Small widget uses short labels (`"Tasks"`/`"المهام"`, `"Habits"`/`"العادات"`) + `.lineLimit(1)`. Full labels reserved for medium/large. Short labels needed because badge text (`done/total`) can be wide (e.g. "3/25") and only ~71pt is available for the title on iPhone SE — full label clips at minimum scale.

### Files Modified
- `ios/AtharTaskWidget/AtharTaskWidget.swift`
- `ios/AtharHabitWidget/AtharHabitWidget.swift`

### Verification
- `flutter analyze` → No issues found ✅
- Device test: PENDING

---

## Phase 5 — Athkar in Habit iOS Widget

**Status: ✅ Code-verified (fix applied, pending device test)**

### Root Cause
`pushHabitData` filtered `h.type == HabitType.regular` — Athkar habits were never included in the widget payload.

### Fix
- Split filter into `todayRegular` + `todayAthkar`; combine with regular first, Athkar appended; cap at 5
- Added `'tp': 'a'|'r'` field to JSON payload
- `habitsTotal` / `habitsDone` (badge) remain regular-only
- `WHabit` struct: added `type: String` (key `"tp"`, default `"r"` for backward compat)
- Added `isAthkar` computed property; updated `isCountBased` to exclude Athkar
- Added `athkarRow()` — static book icon, title, `cp/tg` or checkmark, no Button(intent:...)
- Updated `habitRow()` dispatcher: Athkar → `athkarRow()` first

### Files Modified
- `lib/core/services/widget_data_service.dart` — `pushHabitData()`
- `ios/AtharHabitWidget/AtharHabitWidget.swift` — `WHabit`, dispatcher, `athkarRow()`

### Verification
- `flutter analyze` → No issues found ✅
- Device test: PENDING

---

## Phase 6 — Prayer notifications default OFF

**Status: ✅ Code-verified (fix applied, pending device test)**

### Root Cause
Two save-ordering bugs in `settings_cubit.dart`:

1. `togglePrayerEnabled(true)` called `initializeScheduling()` BEFORE `updateSettings()`. The scheduler reads Isar and saw `isPrayerEnabled = false` (stale) → guard fired → no notifications scheduled.
2. `togglePrayerReminders` called `scheduleSevenDays()` BEFORE `updateSettings()` → scheduler saw stale `enablePrayerReminders` → 15-min reminder state not applied.

Default `isPrayerEnabled = false` was already correct in `UserSettings`; startup guard in `initializeScheduling()` was already correct.

### Fix
- Moved `updateSettings()` BEFORE the scheduler call in both `togglePrayerEnabled` and `togglePrayerReminders`
- Added `isPrayerEnabled` guard to `onLocationChanged()` (dead code, defensive)

### Files Modified
- `lib/features/settings/presentation/cubit/settings_cubit.dart`
- `lib/core/services/prayer_notification_scheduler.dart`

### Verification
- `flutter analyze` → No issues found ✅
- Device test: PENDING

---

## Phase 7 — Final regression verification

**Status: ✅ Code-verified — All phases 1–6 confirmed, no regressions found**

---

## Phase 8 — Separate Prayer Dashboard Visibility from Prayer Notifications

**Status: ✅ Code-verified (fix applied, pending device test)**

### Root Cause
`isPrayerEnabled` controlled both card visibility AND notification scheduling. No way to use one without the other.

### New Model
- `isPrayerEnabled = false` → card/dashboard visibility only (no scheduling side effects)
- `isPrayerNotificationsEnabled = false` → prayer notification scheduling (new field, always OFF by default)
- `enablePrayerReminders = true` → 15-min reminder, sub-setting under notifications (unchanged)

### Fixed Open Bugs
- `handleAutoRenewal()` now has `isPrayerNotificationsEnabled` guard (Phase 7 open bug)
- `settings?.isPrayerEnabled ?? true` → `?? false` (Phase 7 cosmetic flicker fixed)
- `togglePrayerEnabled` stripped of all notification side effects
- All scheduler guards changed from `isPrayerEnabled` → `isPrayerNotificationsEnabled`

### Files Modified
- `lib/features/settings/data/models/user_settings.dart`
- `lib/features/settings/data/models/user_settings.g.dart` (regenerated)
- `lib/l10n/app_en.arb`, `app_ar.arb` (+ regenerated l10n)
- `lib/core/services/prayer_notification_scheduler.dart`
- `lib/features/settings/presentation/cubit/settings_cubit.dart`
- `lib/features/settings/presentation/cubit/settings_state.dart`
- `lib/features/settings/presentation/pages/general_settings_page.dart`

### Verification
- `build_runner` → Succeeded ✅
- `flutter gen-l10n` → OK ✅
- `flutter analyze` → No issues found ✅
- Device test: PENDING

### Remaining Risk
Existing users with old `isPrayerEnabled = true` will have `isPrayerNotificationsEnabled = false` (Isar default for new field). Their previously scheduled prayer notifications will be cancelled on first startup. They need to re-enable in Settings.

### Known Open Issues (not in scope)
- `toggleTaskCompletionByUuid` cache miss (KNOWN_PROBLEMS P2, pre-existing)
- `completeHabitByUuid` / `incrementHabitProgressByUuid` cache miss (KNOWN_PROBLEMS P3, pre-existing)

### Release Readiness
**8/10 — Code-ready, full device test required before shipping**

---

## Phase 8.1 — Prayer master toggle + isPrayerCardEnabled + one-time migration

**Status: ✅ Code-verified (fix applied, pending device test)**

### Root Cause
Phase 8 used `isPrayerEnabled` for both card visibility AND as a guard in the notification scheduler. `isPrayerEnabled` was semantically overloaded. No independent card sub-toggle existed.

### Changes
- `isPrayerEnabled` promoted to true master toggle: turning it OFF also cancels notifications (scheduler guard is now `!isPrayerEnabled || !isPrayerNotificationsEnabled`)
- `isPrayerCardEnabled = false` added as new Isar field — controls card visibility independently
- `didMigratePrayerFeatureSettings = false` migration flag: on first load, `isPrayerCardEnabled` inherits the old `isPrayerEnabled` value (safe forward-migration for existing users)
- `SmartPrayerCardWrapper`: checks `isPrayerCardEnabled` after master check
- `SettingsCubit`: added `_runPrayerMigrationIfNeeded()` called in `loadSettings()`; added `togglePrayerCardEnabled()`; master OFF now calls `disableNotifications()`; `togglePrayerReminders` guard requires both `isPrayerEnabled && isPrayerNotificationsEnabled`
- `SettingsState.props`: added `isPrayerCardEnabled`
- Settings UI: master → (card + notifications → 15-min) → location hierarchy; sub-settings hidden when master OFF
- `app_en.arb` / `app_ar.arb`: `"prayerCard"` key added

### Files Modified
- `lib/features/settings/data/models/user_settings.dart`
- `lib/features/settings/data/models/user_settings.g.dart` (regenerated)
- `lib/l10n/app_en.arb`, `app_ar.arb` (+ regenerated l10n)
- `lib/core/services/prayer_notification_scheduler.dart`
- `lib/core/design_system/molecules/cards/smart_prayer_wrapper.dart`
- `lib/features/settings/presentation/cubit/settings_cubit.dart`
- `lib/features/settings/presentation/cubit/settings_state.dart`
- `lib/features/settings/presentation/pages/general_settings_page.dart`

### Verification
- `build_runner` → Succeeded ✅
- `flutter gen-l10n` → OK ✅
- `flutter analyze` → No issues found ✅
- Device test: PENDING
