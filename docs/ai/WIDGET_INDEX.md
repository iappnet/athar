<!--
CANONICAL-FOR: iOS native widget architecture, WidgetKeys, App Group, data push flow
OWNER:         Claude Code
PRECEDENCE:    5 (Tier 2 — load for PR9 / any widget change)
LAST-UPDATED:  2026-06-01 · Stage A
LOADS-AT:      Tier 2 (PR9 / any iOS widget change)
-->

# Athar — Widget Index (Native Home Widgets)

## Architecture Overview

Flutter bridge: `WidgetDataService` (`lib/core/services/widget_data_service.dart`)
App Group: `group.com.iappsnet.athar` — shared between Runner and all 3 iOS extensions
Flutter package: `home_widget` — `HomeWidget.saveWidgetData()` writes to UserDefaults, `HomeWidget.updateWidget()` triggers timeline reload

iOS minimum: 17.0 (required for `AppIntentConfiguration` and interactive `AppIntent`)

---

## iOS Widget Extensions

### Prayer Widget
- **File**: `ios/AtharPrayerWidget/AtharPrayerWidget.swift`
- **Config**: `AppIntentConfiguration` with `PrayerWidgetIntent` (size: compact/detailed; lang: system/ar/en)
- **Provider**: `AppIntentTimelineProvider`
- **Families**: `.systemSmall`, `.systemMedium`, `.accessoryCircular`, `.accessoryRectangular`
- **No interaction** — display only
- **Locale**: `resolvedLocale()` handles `'ar'`/`'en'`/`'system'` from `athar_app_locale`; `'system'` resolves via `Locale.current.language.languageCode`
- **Special states**: `isCurrentPrayerWindow` (< 30 min after `prevPrayerTimestamp`) → shows "صلاة جارية"; NaflBadge for Duha (gold) and Qiyam (blue)
- **Payload schema**: v6 — see WidgetKeys section below

### Task Widget
- **File**: `ios/AtharTaskWidget/AtharTaskWidget.swift`
- **Config**: `AppIntentConfiguration` with `TaskWidgetIntent` (no user params)
- **Provider**: `AppIntentTimelineProvider`; refreshes every 30 minutes
- **Families**: `.systemSmall`, `.systemMedium`, `.systemLarge`
- **Interaction**: `ToggleTaskIntent` — tapping checkbox toggles completion
  - Writes `{type: "toggle_task", uuid, done, createdAt}` to `athar_pending_task_actions`
  - Optimistic in-widget update (mutates `athar_tasks` JSON + updates `athar_tasks_done`)
  - `WidgetCenter.shared.reloadTimelines(ofKind: "AtharTaskWidget")`
- **Locale**: `resolvedLang()` — same sentinel pattern as prayer widget
- **RTL**: `.environment(\.layoutDirection, entry.isArabic ? .rightToLeft : .leftToRight)`
- **Data key**: `athar_tasks` — JSON array of `{t, d, p, u}`

### Habit Widget
- **File**: `ios/AtharHabitWidget/AtharHabitWidget.swift`
- **Config**: `AppIntentConfiguration` with `HabitWidgetIntent` (no user params)
- **Provider**: `AppIntentTimelineProvider`; refreshes every 30 minutes
- **Families**: `.systemSmall`, `.systemMedium`, `.systemLarge`
- **Interactions**:
  - `CompleteHabitIntent` — boolean toggle; writes `{type: "complete_habit", uuid, done, createdAt}`
  - `IncrementHabitIntent` — count +1; writes `{type: "increment_habit", uuid, createdAt}`
  - Both write to `athar_pending_habit_actions`
- **Row types**: Boolean habits show circle/checkmark; count-based habits show `+`/`✓` + teal progress bar
- **Streak badge**: `flame.fill` icon + streak count
- **Data key**: `athar_habits` — JSON array of `{t, d, s, u, cp, tg}`
- **Filter at decode**: `decoded.filter { !$0.uuid.isEmpty }` (line 264 in Swift file)

---

## WidgetKeys — Shared UserDefaults Keys

`lib/core/services/widget_data_service.dart` — abstract final class `WidgetKeys`

**NEVER rename these constants.** Renaming breaks installed widgets on all user devices.

| Constant | UserDefaults Key | Type | Payload Version |
|----------|-----------------|------|----------------|
| `nextPrayerNameAr` | `athar_next_prayer_name_ar` | String | v1 |
| `nextPrayerNameEn` | `athar_next_prayer_name_en` | String | v1 |
| `nextPrayerTime` | `athar_next_prayer_time` | String (ISO-8601) | v1 |
| `cityName` | `athar_city_name` | String | v1 |
| `nextPrayerType` | `athar_next_prayer_type` | String | v2 |
| `nextPrayerTimestamp` | `athar_next_prayer_timestamp` | Double (epoch ms) | v2 |
| `appLocale` | `athar_app_locale` | String (`ar`/`en`/`system`) | v2 |
| `lastUpdatedAt` | `athar_last_updated_at` | String (ISO-8601) | v2 |
| `widgetDataVersion` | `athar_widget_data_version` | Int | v2 |
| `remainingSeconds` | `athar_remaining_seconds` | Int | v3 |
| `currentDateAr` | `athar_current_date_ar` | String | v3 |
| `currentDateEn` | `athar_current_date_en` | String | v3 |
| `prevPrayerTimestamp` | `athar_prev_prayer_timestamp` | Double (epoch ms) | v4 |
| `isDuhaTime` | `athar_is_duha_time` | Int (0/1) | v5 |
| `isQiyamTime` | `athar_is_qiyam_time` | Int (0/1) | v5 |
| `prevPrayerNameAr` | `athar_prev_prayer_name_ar` | String | v6 |
| `prevPrayerNameEn` | `athar_prev_prayer_name_en` | String | v6 |
| `tasks` | `athar_tasks` | String (JSON) | task |
| `tasksTotal` | `athar_tasks_total` | Int | task |
| `tasksDone` | `athar_tasks_done` | Int | task |
| `currentPeriod` | `athar_current_period` | Int | task |
| `habits` | `athar_habits` | String (JSON) | habit |
| `habitsTotal` | `athar_habits_total` | Int | habit |
| `habitsDone` | `athar_habits_done` | Int | habit |
| `pendingTaskActions` | `athar_pending_task_actions` | String (JSON array) | task |
| `pendingHabitActions` | `athar_pending_habit_actions` | String (JSON array) | habit |

---

## Pending Action Payloads

### Task action (ToggleTaskIntent):
```json
{"type": "toggle_task", "uuid": "...", "done": true, "createdAt": 1234567890.0}
```

### Habit complete action (CompleteHabitIntent):
```json
{"type": "complete_habit", "uuid": "...", "done": true, "createdAt": 1234567890.0}
```

### Habit increment action (IncrementHabitIntent):
```json
{"type": "increment_habit", "uuid": "...", "createdAt": 1234567890.0}
```

Flutter consumption: `WidgetDataService.consumePendingTaskActions()` / `consumePendingHabitActions()` — reads + clears queue atomically.

---

## Flutter Side: Data Push

`WidgetDataService.pushTaskData(allTasks)`:
- Filters: `_sameDay(t.date, today)`, `t.deletedAt == null`, `!t.isSampleData`
- Priority: tasks in current time period (`AtharTimeCalculator.approximatePeriod`); fallback: all unfinished sorted by priority
- Top 5 tasks only
- Writes: `athar_tasks`, `athar_tasks_total`, `athar_tasks_done`, `athar_current_period`, `athar_app_locale`

`WidgetDataService.pushHabitData(allHabits)`:
- Filters: `h.deletedAt == null`, `h.type == HabitType.regular` (**Athkar excluded**), date range contains today
- Sorts: uncompleted first, then by streak descending
- Top 5 habits with non-null uuid only
- Writes: `athar_habits`, `athar_habits_total`, `athar_habits_done`, `athar_app_locale`

---

## Locale / RTL

Both task and habit widget Swift files:
1. Read `athar_app_locale` from UserDefaults on every timeline entry
2. Call `resolvedLang(_)`: `"ar"` → Arabic, `"en"` → English, `"system"` → resolve from `Locale.current`
3. Apply: `.environment(\.layoutDirection, entry.isArabic ? .rightToLeft : .leftToRight)`

**Known issue (Phase 5)**: `athar_app_locale` is only updated when `pushTaskData` or `pushHabitData` is called. Changing language in the app does NOT immediately update the widget locale. Fix: `LocaleCubit.setLocale()` should call `WidgetDataService.pushLocaleOnly()`.

---

## Android Widgets

**Files** (6 total — 3 widget types + 3 receivers):
- `android/.../widgets/TaskWidget.kt` + `TaskWidgetReceiver.kt`
- `android/.../widgets/HabitWidget.kt` + `HabitWidgetReceiver.kt`
- `android/.../widgets/PrayerWidget.kt` + `PrayerWidgetReceiver.kt`

**Display-only.** No AppIntent. No interactive taps. No UUID field parsed. No pending-action queue.

**Data source**: `SharedPreferences` via `home_widget` package. Reads same keys as iOS (`athar_tasks`, `athar_habits`, prayer keys) but the `u` (uuid) field in task/habit JSON is not parsed.

**Known gap**: Android has no equivalent to iOS AppIntent interaction — widget taps do not write pending actions. This is a platform capability gap, not a bug.

---

## Xcode Configuration Notes

- **Entitlements**: Each extension must have `com.apple.security.application-groups` with value `group.com.iappsnet.athar` in both Debug and Release configs
- **Bundle IDs**: `com.iappsnet.athar.AtharPrayerWidgetExtension`, `com.iappsnet.athar.AtharTaskWidgetExtension`, `com.iappsnet.athar.AtharHabitWidgetExtension`
- **iOS deployment target**: 17.0 for all targets (Runner + all extensions)
- **Stale directory**: `ios/AtharHabitWidget AtharHabitWidget AtharHabitWidget/` was deleted — if it reappears it's a build artifact, not a target
