# Change Log — Phase 5 — Athkar in Habit iOS Widget
# 2026-05-06

---

## 1. Phase Number and Name
Phase 5 — Athkar in Habit iOS Widget (read-only rows)

---

## 2. Root Cause / Motivation

`pushHabitData` filtered `h.type == HabitType.regular`, so Athkar habits (أذكار الصباح, أذكار المساء, etc.) never appeared in the Habit widget. Users track Athkar daily but had no widget visibility.

Athkar habits must not be interactive — they are managed through the dedicated Athkar session sheet in the app, not by individual tap. No `CompleteHabitIntent` or `IncrementHabitIntent` may be wired to them.

---

## 3. Files Modified

- `lib/core/services/widget_data_service.dart` — `pushHabitData()` updated
- `ios/AtharHabitWidget/AtharHabitWidget.swift` — `WHabit` struct + `athkarRow()` + dispatcher

---

## 4. Dart Changes (`widget_data_service.dart`)

### Filter split

**Before:**
```dart
final todayHabits = allHabits
    .where((h) =>
        h.deletedAt == null &&
        h.type == HabitType.regular &&
        (h.startDate == null || !h.startDate!.isAfter(today)) &&
        (h.endDate == null || !h.endDate!.isBefore(today)))
    .toList();
```

**After:**
```dart
bool activeToday(HabitModel h) =>
    h.deletedAt == null &&
    (h.startDate == null || !h.startDate!.isAfter(today)) &&
    (h.endDate == null || !h.endDate!.isBefore(today));

final todayRegular =
    allHabits.where((h) => h.type == HabitType.regular && activeToday(h)).toList();
final todayAthkar =
    allHabits.where((h) => h.type == HabitType.athkar && activeToday(h)).toList();
```

### Payload

Added `'tp': h.type == HabitType.athkar ? 'a' : 'r'` to each item in the JSON array.

Regular habits fill the first slots; Athkar appended; total cap remains 5.

`habitsTotal` and `habitsDone` (header badge) remain **regular-only** — Athkar are read-only display items, not tracked in the done/total counter.

---

## 5. Swift Changes (`AtharHabitWidget.swift`)

### `WHabit` struct

Added `type: String` field (CodingKey `"tp"`), default `"r"` if missing (backward-compatible with old payloads).

Added computed properties:
```swift
var isAthkar: Bool    { type == "a" }
var isCountBased: Bool { !isAthkar && target > 1 }
```

`isCountBased` now excludes Athkar (defensive — athkar target is `athkarItems.length` which is > 1 but must not use the count-based row).

### `habitRow()` dispatcher

```swift
// BEFORE:
if habit.isCountBased { countBasedRow(habit) }
else                  { booleanRow(habit) }

// AFTER:
if habit.isAthkar     { athkarRow(habit) }
else if habit.isCountBased { countBasedRow(habit) }
else                  { booleanRow(habit) }
```

### `athkarRow()` — new read-only view

```swift
private func athkarRow(_ habit: WHabit) -> some View {
    HStack(spacing: 8) {
        // Static icon — no Button(intent:...)
        Image(systemName: habit.done ? "book.closed.fill" : "book.fill")
            .font(.system(size: 14, weight: .light))
            .foregroundColor(habit.done ? .white.opacity(0.30) : .gold.opacity(0.80))

        Text(habit.title)
            .font(.system(size: 12))
            .foregroundColor(habit.done ? .white.opacity(0.30) : .white)
            .strikethrough(habit.done, color: .white.opacity(0.30))
            .lineLimit(1)

        Spacer(minLength: 4)

        // Show cp/tg if multi-item athkar; checkmark if single-item done
        if habit.target > 1 {
            Text("\(habit.currentProgress)/\(habit.target)")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(habit.done ? .white.opacity(0.30) : .gold.opacity(0.70))
        } else if habit.done {
            Image(systemName: "checkmark")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.white.opacity(0.40))
        }
    }
}
```

---

## 6. Invariants Preserved

- **`WidgetKeys` not renamed** — no UserDefaults key changes
- **App Group ID unchanged** — `group.com.iappsnet.athar`
- **Backward compat** — old payloads without `"tp"` field decode with `type = "r"` (regular); rendered as before
- **Pending-action routing unchanged** — Athkar rows have no Button(intent:...), so no pending actions are ever written for them
- **`habitsTotal` / `habitsDone`** — still regular-only; Athkar do not inflate the header badge

---

## 7. Verification

```
flutter analyze → "No issues found!" ✅
```

Swift SourceKit `@main` false positive on `AtharHabitWidgetBundle` — pre-existing, not introduced here.

---

## 8. Device Test Checklist

1. **Athkar habit visible** — أذكار الصباح / أذكار المساء appear in widget below regular habits ✅
2. **Athkar row is read-only** — tapping the book icon does nothing (no intent) ✅
3. **Athkar progress shown** — multi-item athkar shows `cp/tg`; single-item shows checkmark when done ✅
4. **Athkar done = dimmed** — completed athkar row is white.opacity(0.30) with strikethrough ✅
5. **Header badge unchanged** — `done/total` counts only regular habits ✅
6. **Regular habit interaction intact** — checkbox and increment still work ✅
7. **Old payloads (no tp field)** — habits decode as regular; no crash ✅
8. **5-slot cap preserved** — if 5+ regular habits, no Athkar row appears; if 3 regular, up to 2 Athkar fill remaining slots ✅

---

## 9. Rollback Plan

```dart
// In widget_data_service.dart, revert pushHabitData() to:
final todayHabits = allHabits
    .where((h) =>
        h.deletedAt == null &&
        h.type == HabitType.regular &&
        (h.startDate == null || !h.startDate!.isAfter(today)) &&
        (h.endDate == null || !h.endDate!.isBefore(today)))
    .toList();
// ...and remove 'tp' from the JSON map, restore todayHabits.length for totals
```

```swift
// In AtharHabitWidget.swift:
// - Remove 'type' field and CodingKey from WHabit
// - Revert isCountBased to: var isCountBased: Bool { target > 1 }
// - Remove isAthkar
// - Remove athkarRow()
// - Revert habitRow() dispatcher to if/else isCountBased
```
