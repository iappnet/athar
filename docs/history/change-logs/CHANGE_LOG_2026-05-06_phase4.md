# Change Log — Phase 4 — Task/Habit iOS Widget Localization
# 2026-05-06

---

## 1. Phase Number and Name
Phase 4 — Task/Habit iOS Widget localization (verification + documentation)

---

## 2. Result

**No code changes required.** Phase 4 was already fully implemented in the working tree as part of the P1 widget locale fix and the widget bilingual rewrite that preceded Phases 1–3.

---

## 3. Full Localization Chain (verified correct)

### Flutter side

| Step | Location | Status |
|------|----------|--------|
| User changes language | `GeneralSettingsPage` → `LocaleCubit.setLocale()` | ✅ |
| Locale persisted | `FlutterSecureStorage('preferred_locale')` | ✅ |
| Widgets notified immediately | `setLocale()` calls `pushLocaleOnly(localeCode)` | ✅ |
| `pushLocaleOnly` writes key | `HomeWidget.saveWidgetData(WidgetKeys.appLocale, code)` | ✅ |
| `pushLocaleOnly` triggers reload | `_updateTaskWidget()` + `_updateHabitWidget()` (+ prayer) | ✅ |
| `pushTaskData` also writes locale | `_readLocale()` from secure storage → `WidgetKeys.appLocale` | ✅ |
| `pushHabitData` also writes locale | same | ✅ |

`_readLocale()` reads `preferred_locale` from `FlutterSecureStorage` — the same key used by `LocaleCubit`. Possible values: `"ar"` / `"en"` / `null` → `"system"`.

### Swift side — AtharTaskWidget

| Step | Location | Status |
|------|----------|--------|
| Read stored locale | `d?.string(forKey: "athar_app_locale")` in `readEntry()` | ✅ |
| Resolve final lang | `resolvedLang(intent: configuration.language, stored:)` | ✅ |
| Intent override | `@Parameter(default: .system) var language: WidgetLanguage` | ✅ |
| `system` → stored locale | `"ar"` / `"en"` / device-locale fallback | ✅ |
| RTL applied | `.environment(\.layoutDirection, entry.isArabic ? .rightToLeft : .leftToRight)` | ✅ |
| Bilingual UI text | `entry.isArabic ? "مهام اليوم" : "Today's Tasks"` (all strings) | ✅ |
| Placeholder | `lang: "ar"` hardcoded — intentional (Arabic-first app) | ✅ |
| Snapshot/timeline | Uses `readEntry()` → correct stored locale | ✅ |

### Swift side — AtharHabitWidget

Same pattern as task widget — identical implementation. All items above verified ✅.

### `resolvedLang()` logic (same in both widgets)

```swift
switch intent {
case .arabic:  return "ar"             // user forced Arabic in widget config
case .english: return "en"             // user forced English in widget config
case .system:
    let s = stored ?? "system"
    if s == "ar" { return "ar" }       // app set to Arabic
    if s == "en" { return "en" }       // app set to English
    // null/system → device locale, Arabic fallback
    let code = Locale.current.language.languageCode?.identifier ?? "ar"
    return (code == "en") ? "en" : "ar"
}
```

---

## 4. Files Involved (no changes)

- `lib/core/presentation/cubit/locale_cubit.dart` — `setLocale()` calls `pushLocaleOnly()`
- `lib/core/services/widget_data_service.dart` — `pushLocaleOnly()`, `pushTaskData()`, `pushHabitData()`
- `ios/AtharTaskWidget/AtharTaskWidget.swift` — `resolvedLang()`, `entry.isArabic`, RTL env
- `ios/AtharHabitWidget/AtharHabitWidget.swift` — same

---

## 5. Previous Bug (KNOWN_PROBLEMS.md P1 — now fixed)

**Before fix:** `LocaleCubit.setLocale()` only updated `FlutterSecureStorage`. Widgets received the new locale only on the *next* `pushTaskData`/`pushHabitData` call (i.e., only after tasks/habits were next loaded). Language change had no immediate effect on widgets.

**After fix:** `setLocale()` immediately calls `pushLocaleOnly(localeCode)` which:
1. Writes `athar_app_locale` to UserDefaults  
2. Triggers `reloadTimelines` on all three widget kinds  
3. Each widget's next `readEntry()` call sees the new locale

---

## 6. Verification

```
flutter analyze → "No issues found!" ✅
```

Swift changes are compile-time verified (part of the Xcode project build). No new Swift changes in this phase.

---

## 7. Device Test Checklist

### Task Widget localization
- [ ] App language: Arabic → Task widget shows "مهام اليوم", RTL layout, Arabic task titles
- [ ] Switch app to English → Widget immediately updates to "Today's Tasks", LTR layout
- [ ] Switch back to Arabic → Widget reverts to Arabic within ~1 second
- [ ] Widget config: override language to "English" while app is Arabic → widget shows English
- [ ] Widget config: override to "Arabic" while app is English → widget shows Arabic
- [ ] Widget config: "System" → follows app language setting

### Habit Widget localization
- [ ] App language: Arabic → Habit widget shows "عادات اليوم", RTL layout
- [ ] Switch app to English → Widget shows "Today's Habits", LTR layout
- [ ] Switch back to Arabic → Widget reverts immediately
- [ ] Count-based habits: progress text switches language correctly
- [ ] Streak badge: flame icon + streak count visible in both locales

### Interaction regression
- [ ] Tapping task checkbox in English mode still writes correct UUID to pending actions
- [ ] Tapping habit complete/increment in English mode still works
- [ ] Pending actions processed correctly after locale switch

---

## 8. Rollback Plan

No code changes in this phase — no rollback needed.

---

## 9. Remaining Phases

- Phase 5: Athkar in Habit iOS Widget
- Phase 6: Prayer notifications default OFF
- Phase 7: Final regression verification
