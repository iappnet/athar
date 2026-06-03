# Change Log — Phase 7 — Final Regression Verification
# 2026-05-06

---

## 1. Phase Number and Name
Phase 7 — Final regression verification

---

## 2. Phase 1–6 Confirmation

| Phase | Fix | Key Files | Code-Verified | Regression Found |
|-------|-----|-----------|---------------|-----------------|
| 1 | `SubscriptionCubit @lazySingleton` | `subscription_cubit.dart`, `injection.config.dart` | ✅ | None |
| 2 | Habit add async save + `_isSaving` | `habit_form_dialog.dart`, `habit_cubit.dart` | ✅ | None |
| 3 | All NavBar add targets (medicine, appointment, module, space) | `unified_add_sheet.dart`, `add_module_sheet.dart`, `main_page.dart` | ✅ | None |
| 4 | Widget locale `resolvedLang()` + small widget typography | `AtharTaskWidget.swift`, `AtharHabitWidget.swift` | ✅ | None |
| 5 | Athkar in Habit widget (read-only rows + `tp` field) | `widget_data_service.dart`, `AtharHabitWidget.swift` | ✅ | None |
| 6 | Prayer notifications save-ordering fix | `settings_cubit.dart`, `prayer_notification_scheduler.dart` | ✅ | None |

---

## 3. Verification Checks

### 3.1 NavBar Add Flows

| Target | `_isSaving` guard | `await` save | State check on failure | Sheet stays open on failure | Pop only on success |
|--------|-------------------|--------------|------------------------|----------------------------|---------------------|
| Task add | ✅ (`unified_add_sheet.dart:94`) | ✅ | ✅ (`TaskError` / `TaskFreeLimitReached`) | ✅ | ✅ |
| Habit add | ✅ (`habit_form_dialog.dart:49`) | ✅ | ✅ (`HabitError` / `HabitFreeLimitReached`) | ✅ | ✅ |
| Medicine add | ✅ (shared `_isSaving`) | ✅ (`await healthCubit.addMedicine`) | ✅ (`HealthError`) | ✅ | ✅ |
| Appointment add | ✅ (shared `_isSaving`) | ✅ (`await healthCubit.addAppointment`) | ✅ (`HealthError`) | ✅ | ✅ |
| Module/Project add | ✅ (`add_module_sheet.dart:37`) | ✅ | ✅ (`ModuleError`) | ✅ | ✅ |
| Space create | N/A (inline dialog) | ✅ (`await createSpace`) | `ctx.mounted` guard | ✅ | ✅ |

### 3.2 iOS Widget Localization

| Widget | `resolvedLang()` / `resolvedLocale` | Arabic device → Arabic RTL | English device → English LTR | Unsupported → English LTR | Small widget short labels | `lineLimit(1)` |
|--------|-------------------------------------|---------------------------|------------------------------|--------------------------|--------------------------|----------------|
| Task | Fixed: device language only, `"en"` fallback | ✅ | ✅ | ✅ | `"Tasks"` / `"المهام"` ✅ | ✅ |
| Habit | Fixed: device language only, `"en"` fallback | ✅ | ✅ | ✅ | `"Habits"` / `"العادات"` ✅ | ✅ |
| Prayer | Unchanged: raw device code, `"ar"` nil fallback | ✅ | ✅ | ✅ (not == "ar") | N/A | ✅ |

### 3.3 Habit Widget — Athkar Rows

| Check | Result |
|-------|--------|
| Regular habits render as before | ✅ — sort, filter, and JSON keys unchanged |
| Regular habit checkbox intent | ✅ — `CompleteHabitIntent` / `IncrementHabitIntent` unchanged |
| Athkar habits included in payload | ✅ — `todayAthkar` list, appended after regular |
| `tp` field in payload | ✅ — `"tp": "a"` for Athkar, `"tp": "r"` for regular |
| `WHabit.type` decoded with default `"r"` | ✅ — backward compat with old payloads |
| `isAthkar = type == "a"` | ✅ |
| `isCountBased = !isAthkar && target > 1` | ✅ — Athkar excluded from count-based row |
| `athkarRow()` has no Button(intent:...) | ✅ — static `Image(systemName:)` only |
| Athkar show `cp/tg` for multi-item | ✅ |
| Athkar show checkmark when single-item done | ✅ |
| `habitsTotal` / `habitsDone` = regular-only | ✅ |

### 3.4 Prayer Notifications

| Check | Result |
|-------|--------|
| `UserSettings.isPrayerEnabled` default | `false` ✅ |
| Startup: `initializeScheduling()` guard | Reads Isar; if false → `disableNotifications()` + return ✅ |
| Auto-renewal handler: `handleAutoRenewal()` | Calls `scheduleSevenDays()` WITHOUT `isPrayerEnabled` guard ⚠️ (see remaining risks) |
| `togglePrayerEnabled(true)`: save before schedule | ✅ — `updateSettings()` now BEFORE `initializeScheduling()` |
| `togglePrayerEnabled(false)`: cancel | ✅ — `disableNotifications()` = `cancelRange(100000, 199999)` + cancel auto-renewal |
| `togglePrayerReminders`: save before reschedule | ✅ — `updateSettings()` now BEFORE `scheduleSevenDays()` |
| `onLocationChanged()` guard | ✅ — added `isPrayerEnabled` check |
| Prayer IDs isolated from task/medication | ✅ — prayer: 100000–199999; medication: 200000+; task: 400000+; habit: 500000+ |

### 3.5 Flutter Analyzer

```
flutter analyze → "No issues found!" ✅
```

---

## 4. Bugs Fixed (all phases)

| # | Bug | Severity | Phase |
|---|-----|----------|-------|
| 1 | `SubscriptionCubit @injectable` factory → `getIt<>()` created new instance → `_readyCompleter` never completed → `addTask()` infinite hang | CRITICAL | 1 |
| 2 | Task add sheet closed silently on `TaskError` / `TaskFreeLimitReached` | HIGH | 1 |
| 3 | `_isSaving` not reset on task add failure — spinner stuck | HIGH | 1 |
| 4 | Habit add: fire-and-forget (no `await`) → sheet always closed regardless of success | HIGH | 2 |
| 5 | Habit add: no `_isSaving` guard — double-tap possible | MEDIUM | 2 |
| 6 | Medicine add: no `await`, sheet closed before result | HIGH | 3 |
| 7 | Appointment add: no `await`, sheet closed before result | HIGH | 3 |
| 8 | Module add: no `_isSaving`, no `await`, sheet closed before result | HIGH | 3 |
| 9 | Space create: no `await`, `Navigator.pop` without `mounted` guard | MEDIUM | 3 |
| 10 | Task/Habit widget: `resolvedLang()` System mode used app locale (`stored`) first → Arabic users always saw Arabic even on English device | HIGH | 4 |
| 11 | Widget locale: Arabic nil fallback → edge-case users got Arabic | MEDIUM | 4 |
| 12 | Widget locale: non-English devices got Arabic layout | MEDIUM | 4 |
| 13 | Small widget header clipped with wide badge (e.g. "3/25") | MEDIUM | 4 |
| 14 | Athkar habits never appeared in Habit widget | MEDIUM | 5 |
| 15 | Prayer enable toggle: `initializeScheduling()` read stale Isar → no notifications scheduled | HIGH | 6 |
| 16 | Prayer reminder toggle: `scheduleSevenDays()` read stale `enablePrayerReminders` | MEDIUM | 6 |

---

## 5. Bugs Still Open (known, not in scope)

| # | Bug | Location | Notes |
|---|-----|----------|-------|
| 1 | `handleAutoRenewal()` lacks `isPrayerEnabled` guard | `prayer_notification_scheduler.dart:207` | Race condition only; auto-renewal is cancelled when prayer disabled. Low risk. |
| 2 | `settings?.isPrayerEnabled ?? true` in settings page | `general_settings_page.dart:96` | Cosmetic — toggle flashes ON during null load state. No scheduling impact. Pre-existing. |
| 3 | `toggleTaskCompletionByUuid` cache miss | `task_cubit.dart` | KNOWN_PROBLEMS.md P2 — widget action may drop if task not in cache |
| 4 | `completeHabitByUuid` / `incrementHabitProgressByUuid` cache miss | `habit_cubit.dart` | KNOWN_PROBLEMS.md P3 — same cache miss pattern |

---

## 6. Build / Analyze Result

```
flutter analyze → "No issues found!" ✅
iOS build: not run (no Xcode CLI build step)
Swift SourceKit @main false positive on WidgetBundle targets: pre-existing, not a real error
```

---

## 7. Device Test Status

All phases are **code-verified**, none are **device-verified**. All require device test to fully confirm.

Priority order for device testing:
1. Phase 1 (CRITICAL — task add hang)
2. Phase 6 (prayer enable toggle)
3. Phase 2 (habit add)
4. Phase 3 (medicine/appointment/module/space)
5. Phase 4 (widget locale — need device with different language settings)
6. Phase 5 (Athkar widget — need device with Athkar habits)

---

## 8. Release Readiness Score

**8 / 10 — Code-ready, device test pending**

- All 16 confirmed bugs fixed
- `flutter analyze` clean
- Zero regressions found in code review
- 2 minor known issues (not blockers)
- Full device test required before shipping — especially Phase 1 (previously confirmed broken on device)

---

## 9. Files Changed Across All Phases

| File | Phases |
|------|--------|
| `lib/features/subscription/presentation/cubit/subscription_cubit.dart` | 1 |
| `lib/core/di/injection.config.dart` | 1 |
| `lib/features/task/presentation/cubit/task_cubit.dart` | 1 |
| `lib/features/task/presentation/widgets/unified_add_sheet.dart` | 1, 3 |
| `lib/features/habits/presentation/widgets/habit_form_dialog.dart` | 2 |
| `lib/features/habits/presentation/cubit/habit_cubit.dart` | 2 |
| `lib/features/space/presentation/widgets/add_module_sheet.dart` | 3 |
| `lib/features/home/presentation/pages/main_page.dart` | 3 |
| `ios/AtharTaskWidget/AtharTaskWidget.swift` | 4 |
| `ios/AtharHabitWidget/AtharHabitWidget.swift` | 4, 5 |
| `lib/core/services/widget_data_service.dart` | 5 |
| `lib/features/settings/presentation/cubit/settings_cubit.dart` | 6 |
| `lib/core/services/prayer_notification_scheduler.dart` | 6 |
