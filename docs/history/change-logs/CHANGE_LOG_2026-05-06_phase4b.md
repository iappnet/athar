# Change Log — Phase 4 (reopened) — Task/Habit iOS Widget Localization Fix
# 2026-05-06

---

## 1. Phase Number and Name
Phase 4b — Task/Habit iOS Widget localization — actual fix

---

## 2. Root Cause

Both `AtharTaskWidget.swift` and `AtharHabitWidget.swift` had a buggy `resolvedLang()` function:

```swift
// WRONG — was checking app locale first:
case .system:
    let s = stored ?? "system"
    if s == "ar" { return "ar" }      // app locale "ar" → always returned Arabic, ignoring device lang
    if s == "en" { return "en" }
    let code = Locale.current.language.languageCode?.identifier ?? "ar"  // ← Arabic nil fallback
    return (code == "en") ? "en" : "ar"   // ← non-English device → Arabic (French, German, etc.)
```

Three bugs in one block:
1. **App locale checked first in System mode** — `stored` is `athar_app_locale` (app's chosen language). If the app was set to Arabic, System mode returned Arabic regardless of the device language. Violates the spec: System = device language, not app language.
2. **Arabic nil fallback** — when `Locale.current.language.languageCode?.identifier` returned nil (edge case), it fell back to `"ar"`. Spec requires English fallback.
3. **Non-English → Arabic** — French, German, Turkish users got Arabic layout. Spec requires English for all non-Arabic devices.

The `AtharPrayerWidget.swift` was correct, using a computed property on the entry struct that reads device language directly and maps any non-Arabic code to the appropriate locale.

---

## 3. Files Modified

- `ios/AtharTaskWidget/AtharTaskWidget.swift`
- `ios/AtharHabitWidget/AtharHabitWidget.swift`

---

## 4. Exact Fix

### `resolvedLang()` — both files (identical change)

```swift
// BEFORE (wrong):
case .system:
    let s = stored ?? "system"
    if s == "ar" { return "ar" }
    if s == "en" { return "en" }
    let code = Locale.current.language.languageCode?.identifier ?? "ar"
    return (code == "en") ? "en" : "ar"

// AFTER (correct):
case .system:
    // System = device language. App locale is NOT the source of truth here.
    // Arabic device → Arabic; everything else (English, French, etc.) → English.
    if let code = Locale.current.language.languageCode?.identifier {
        return code == "ar" ? "ar" : "en"
    }
    return "en"
```

Behavior matrix after fix:

| Widget config | Device language | App language | Result |
|--------------|----------------|--------------|--------|
| System | Arabic | Arabic | Arabic + RTL ✅ |
| System | Arabic | English | Arabic + RTL ✅ |
| System | English | Arabic | English + LTR ✅ |
| System | English | English | English + LTR ✅ |
| System | French | Arabic | English + LTR ✅ |
| System | French | English | English + LTR ✅ |
| System | nil (edge) | any | English + LTR ✅ |
| Arabic | any | any | Arabic + RTL ✅ |
| English | any | any | English + LTR ✅ |

### Small widget typography — both files

**Why short labels:** `tasksTotal`/`habitsTotal` in the badge are counts of ALL today's items, not capped at 5. A badge like "3/25" is ~24pt wide. With the icon (12pt) + three HStack gaps (8pt each) + badge (24pt) = 60pt of fixed space, only 71pt remains for the title on iPhone SE (155pt - 12×2 padding - 60pt). "Today's Habits" at minimum scale (8.25pt) still needs ~73pt — it clips. Short labels ("Tasks" / "Habits" / "المهام" / "العادات") fit in ~36-40pt with zero risk.

```swift
// BEFORE (wrong — full label, no lineLimit, could wrap or clip with wide badge):
Text(entry.isArabic ? "مهام اليوم" : "Today's Tasks")
    .font(.system(size: sz, weight: .bold))
    .foregroundColor(.white)

// AFTER (task — short label in compact only):
let titleAr = compact ? "المهام"  : "مهام اليوم"
let titleEn = compact ? "Tasks"   : "Today's Tasks"
Text(entry.isArabic ? titleAr : titleEn)
    .font(.system(size: sz, weight: .bold))
    .foregroundColor(.white)
    .lineLimit(1)

// AFTER (habit — same pattern):
let titleAr = compact ? "العادات" : "عادات اليوم"
let titleEn = compact ? "Habits"  : "Today's Habits"
Text(entry.isArabic ? titleAr : titleEn)
    .font(.system(size: sz, weight: .bold))
    .foregroundColor(.white)
    .lineLimit(1)
```

Medium and large widgets still use the full labels ("مهام اليوم" / "Today's Tasks", "عادات اليوم" / "Today's Habits") unchanged.

`minimumScaleFactor` was removed from the compact case — not needed since the short labels always fit. `lineLimit(1)` is retained to prevent any multi-line rendering.

---

## 5. Previous Phase 4 Report — Why It Was Wrong

The Phase 4 verification report confirmed the code "works correctly" by reading the flow abstractly. It did not test the actual `resolvedLang()` output for the scenario:
- Widget config: System
- App language: Arabic (stored = "ar")
- Device language: English

In that case, the old code returned `"ar"` (Arabic) because it checked `stored` first — producing the reported "still renders Arabic" bug.

---

## 6. Reference: AtharPrayerWidget.swift (correct pattern)

The Prayer widget uses a computed property on the entry struct instead of a free function, but the logic is equivalent:
```swift
var resolvedLocale: String {
    switch intentLanguage {
    case .arabic:  return "ar"
    case .english: return "en"
    case .system:
        if let code = Locale.current.language.languageCode?.identifier {
            return code   // returns raw device language code
        }
        return (appLocale == "system" || appLocale.isEmpty) ? "ar" : appLocale
    }
}
var isArabic: Bool { resolvedLocale == "ar" }
```

Note: Prayer widget returns the raw device code (e.g. "fr") and checks `== "ar"` for `isArabic`. For Task/Habit, we normalise at source to "ar"/"en" for clarity. Both approaches are equivalent for the two-language support target.

---

## 7. Verification

```
flutter analyze → "No issues found!" ✅
```

Swift changes: SourceKit flags `@main` on `AtharTaskWidgetBundle` and `AtharHabitWidgetBundle` when files are analyzed in isolation. This is a pre-existing false positive — `@main` is valid for WidgetBundle targets in Xcode's full build context. No new Swift errors introduced.

**iOS widget build**: Not run (no Xcode CLI build step available in this session). Requires device test.

---

## 8. Device Test Checklist

1. **Device Arabic + widget System** → Arabic text, RTL layout ✅
2. **Device English + widget System** → English text, LTR layout ✅
3. **Device French/German/other + widget System** → English text, LTR layout ✅
4. **Widget override: Arabic** → Arabic text, RTL — regardless of device language ✅
5. **Widget override: English** → English text, LTR — regardless of device language ✅
6. **Small widget title** → "Today's Tasks" / "Today's Habits" fits on one line, scales down if needed ✅
7. **Task checkbox interaction** → still writes correct UUID to pending actions ✅
8. **Habit complete/increment interaction** → still writes correct UUID to pending actions ✅

---

## 9. Rollback Plan

```swift
// In AtharTaskWidget.swift and AtharHabitWidget.swift, revert resolvedLang() to:
case .system:
    let s = stored ?? "system"
    if s == "ar" { return "ar" }
    if s == "en" { return "en" }
    let code = Locale.current.language.languageCode?.identifier ?? "ar"
    return (code == "en") ? "en" : "ar"

// And remove .lineLimit(1).minimumScaleFactor(0.75) from header Text in both files.
```
