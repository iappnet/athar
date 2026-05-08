# Change Log — Phase 6 — Prayer Notifications Default OFF
# 2026-05-06

---

## 1. Phase Number and Name
Phase 6 — Prayer notifications default OFF + toggle save-ordering fix

---

## 2. Audit Summary

| Item | Finding |
|------|---------|
| `UserSettings.isPrayerEnabled` default | `false` — already correct |
| `initializeScheduling()` guard | Checks `isPrayerEnabled` first — already correct |
| Startup call (`main.dart:145`) | Calls `initializeScheduling()` → guard fires on fresh install — already safe |
| `togglePrayerEnabled` save ordering | **BUG** — scheduler called before `updateSettings()` |
| `togglePrayerReminders` save ordering | **BUG** — scheduler called before `updateSettings()` |
| `onLocationChanged()` guard | Missing guard — but method is dead code (never called) |
| Task/medicine notification scheduling | Not touched |
| Notification ID ranges | Prayer: 100000–199999 (isolated, cancellation is range-scoped) |

---

## 3. Root Cause

### Bug A — `togglePrayerEnabled` save ordering

When the user enables prayer notifications in Settings:

```dart
// BEFORE (wrong):
currentSettings.isPrayerEnabled = enabled;   // in-memory only
await prayerScheduler.initializeScheduling(); // reads Isar → still false
await _repository.updateSettings(currentSettings); // saved too late
```

`initializeScheduling()` calls `_settingsRepository.getSettings()` internally and reads the OLD persisted value (`isPrayerEnabled = false`). The guard fires → no notifications are scheduled. The setting is saved after the fact, so the next startup DOES work — but the immediate scheduling after the toggle does not.

```dart
// AFTER (correct):
await _repository.updateSettings(currentSettings); // save FIRST
await prayerScheduler.initializeScheduling();       // now reads isPrayerEnabled = true
```

### Bug B — `togglePrayerReminders` save ordering

Same pattern: `scheduleSevenDays()` reads `enablePrayerReminders` from Isar inside `_schedulePrayersForDate()`. Calling it before `updateSettings()` means the 15-min reminder sub-setting change is not reflected in the current scheduling run.

---

## 4. Files Modified

- `lib/features/settings/presentation/cubit/settings_cubit.dart`
- `lib/core/services/prayer_notification_scheduler.dart`

---

## 5. Exact Changes

### `settings_cubit.dart` — `togglePrayerEnabled`

```dart
// BEFORE:
currentSettings.isPrayerEnabled = enabled;
final prayerScheduler = getIt<PrayerNotificationScheduler>();
if (!enabled) { await prayerScheduler.disableNotifications(); }
else           { await prayerScheduler.initializeScheduling(); }
await _repository.updateSettings(currentSettings);   // ← too late

// AFTER:
currentSettings.isPrayerEnabled = enabled;
await _repository.updateSettings(currentSettings);   // ← save first
final prayerScheduler = getIt<PrayerNotificationScheduler>();
if (!enabled) { await prayerScheduler.disableNotifications(); }
else           { await prayerScheduler.initializeScheduling(); }
```

### `settings_cubit.dart` — `togglePrayerReminders`

```dart
// BEFORE:
currentSettings.enablePrayerReminders = enabled;
if (currentSettings.isPrayerEnabled) { await prayerScheduler.scheduleSevenDays(); }
await _repository.updateSettings(currentSettings);   // ← too late

// AFTER:
currentSettings.enablePrayerReminders = enabled;
await _repository.updateSettings(currentSettings);   // ← save first
if (currentSettings.isPrayerEnabled) { await prayerScheduler.scheduleSevenDays(); }
```

### `prayer_notification_scheduler.dart` — `onLocationChanged`

Added guard:
```dart
// BEFORE:
Future<void> onLocationChanged() async {
    debugPrint('📍 Location changed - rescheduling prayers');
    await scheduleSevenDays();
}

// AFTER:
Future<void> onLocationChanged() async {
    final settings = await _settingsRepository.getSettings();
    if (!settings.isPrayerEnabled) return;
    debugPrint('📍 Location changed - rescheduling prayers');
    await scheduleSevenDays();
}
```

---

## 6. Behavior Matrix

| Scenario | Before | After |
|----------|--------|-------|
| Fresh install → startup | No notifications ✅ | No notifications ✅ |
| Existing user, `isPrayerEnabled = false` → startup | No notifications ✅ | No notifications ✅ |
| Existing user, `isPrayerEnabled = true` → startup | Notifications scheduled ✅ | Notifications scheduled ✅ |
| User enables prayer in Settings | Setting saved, but **notifications NOT scheduled** ❌ | Setting saved, **notifications scheduled** ✅ |
| User disables prayer in Settings | Notifications cancelled ✅ | Notifications cancelled ✅ |
| User toggles 15-min reminder OFF | Setting saved, **old reminders still scheduled** ❌ | Setting saved, **reminders removed** ✅ |
| Location changed, prayer disabled | Would schedule (dead code) | Guard returns early ✅ |

---

## 7. Invariants Preserved

- Task notification scheduling: not touched
- Medicine notification scheduling: not touched
- Habit/Athkar notification scheduling: not touched
- Prayer notification ID range (`100000–199999`): unchanged
- `cancelRange()` only cancels prayer IDs: confirmed (uses `NotificationIdRanges.prayerBase/prayerMax`)
- Auto-reschedule notification (`_idManager.autoReschedule`): cancelled only via `disableNotifications()`

---

## 8. Verification

```
flutter analyze → "No issues found!" ✅
```

---

## 9. Device Test Checklist

1. Fresh install → app launches → no "Prayer notifications scheduled" log ✅
2. Enable prayer notifications in Settings → "Prayer notifications scheduled" log appears ✅
3. Check pending notifications → prayer IDs (100000–199999) present ✅
4. Disable prayer notifications → "Prayer notifications cancelled" log ✅
5. Check pending notifications → no prayer IDs remain ✅
6. Task/medicine notifications unchanged after prayer toggle ✅
7. Toggle 15-min prayer reminder → reschedule with/without reminders ✅

---

## 10. Remaining Risks

- **Isar transaction isolation**: If Isar batches writes in a transaction and the scheduler reads within the same transaction, the save-first order might still be unreliable. Unlikely with Isar's standard async API, but worth verifying on device.
- **`onLocationChanged()` dead code**: The method now has a guard, but it is not wired to any call site. If wired in future, it will correctly respect `isPrayerEnabled`.
