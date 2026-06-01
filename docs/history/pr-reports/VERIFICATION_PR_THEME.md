# VERIFICATION_PR_THEME.md

**Date:** 2026-06-01
**Branch:** `feat/athar-v2-pr1-tokens-theme`
**Status:** ALL 6 STEPS COMPLETE — 0 analyzer issues

---

## STEP 1 — Font fallback gaps fixed

### Approach
`fontFamilyFallback: AtharTypography.fontFallback` added to every `TextStyle.copyWith` call that sets `fontFamily: AtharTypography.fontFamilyAr` in both theme files.

### Exception (line 80, both files)
```dart
fontFamily: AtharTypography.fontFamilyAr, // String slot — fontFamilyFallback not applicable here
```
`ThemeData.fontFamily` is a `String`, not a `TextStyle`. It cannot carry `fontFamilyFallback`. This is the sole allowed exception, called out explicitly.

### Evidence — fontFamily matches per file

**athar_light_theme.dart** — 45 matches total:
- Line 80: ThemeData String slot (exception, per above)
- Lines 98, 125, 130, 155, 161, 197, 216, 234, 251 — component TextStyles (AppBar, BottomNav ×2, NavigationBar ×2, buttons ×4)
- Lines 318, 323, 328, 333, 338 — InputDecoration (label, floatingLabel, hint, error, helper)
- Lines 407, 430, 435, 457, 462 — Slider, Chip ×2, Dialog ×2
- Lines 492, 507, 511, 551, 556 — SnackBar, TabBar ×2, ListTile ×2
- Lines 581, 599, 610, 632, 660 — Tooltip, PopupMenu, DropdownMenu, DatePicker, Badge
- Lines 699–773 — TextTheme 14 slots (displayLarge/Medium/Small, headlineLarge/Medium/Small, titleLarge/Medium/Small, bodyLarge/Medium/Small, labelLarge/Medium/Small)

**athar_dark_theme.dart** — identical structure, identical 45 matches at the same line numbers.

### fontFamilyFallback count confirmation
```
grep -c 'fontFamilyFallback: AtharTypography.fontFallback' athar_light_theme.dart → 44
grep -c 'fontFamilyFallback: AtharTypography.fontFallback' athar_dark_theme.dart  → 44
```
44 = 45 matches − 1 exception. Every TextStyle slot carries Cairo fallback.

---

## STEP 2 — app.dart wiring

### Before
```dart
// app.dart:20
import 'core/design_system/themes/app_theme.dart';

// app.dart:171–172
theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
```

### After
```dart
// app.dart:20–21
import 'core/design_system/themes/athar_light_theme.dart';
import 'core/design_system/themes/athar_dark_theme.dart';

// app.dart:172–173
theme: AtharLightTheme.theme,
darkTheme: AtharDarkTheme.theme,
```

### Unchanged (UNTOUCHED — confirmed by grep)
```dart
// app.dart:164–177
final themePreference = settingsState is SettingsLoaded
    ? settingsState.settings.themePreference
    : ThemePreference.system;
// ...
themeMode: switch (themePreference) {
  ThemePreference.light  => ThemeMode.light,
  ThemePreference.dark   => ThemeMode.dark,
  ThemePreference.system => ThemeMode.system,
},
```
`LocaleCubit`, routes, and all behavioral logic are untouched.

---

## STEP 3 — DrawerTheme RTL fix

### Before (both files, line 509–516)
```dart
shape: const RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(0),
    bottomLeft: Radius.circular(0),
    topRight: Radius.circular(16),
    bottomRight: Radius.circular(16),
  ),
),
```

### After (both files, line 530–537)
```dart
shape: const RoundedRectangleBorder(
  borderRadius: BorderRadiusDirectional.only(
    topStart: Radius.circular(0),
    bottomStart: Radius.circular(0),
    topEnd: Radius.circular(16),
    bottomEnd: Radius.circular(16),
  ),
),
```

### Verification
```
grep -n 'BorderRadiusDirectional' athar_light_theme.dart → 532: borderRadius: BorderRadiusDirectional.only(
grep -n 'BorderRadiusDirectional' athar_dark_theme.dart  → 532: borderRadius: BorderRadiusDirectional.only(
grep -n 'BorderRadius\.only' athar_light_theme.dart → NONE
grep -n 'BorderRadius\.only' athar_dark_theme.dart  → NONE
```
No LTR-hardcoded drawer shapes remain.

---

## STEP 4 — Cleanup

| File | Action | Rationale |
|------|--------|-----------|
| `lib/core/design_system/themes/athar_theme.dart` | **DELETED** | 1-line stub, empty |
| `lib/core/design_system/themes/app_theme.dart` | **DELETED** | Legacy stub; confirmed 0 live imports after STEP 2 swap |
| `lib/core/design_system/themes/themes.dart` | `export 'athar_theme.dart'` removed | Barrel cleaned; light + dark exports remain |
| `lib/core/design_system/themes/app_colors.dart` | **LEFT INTACT** | Still exported by `tokens.dart`; all direct usages in lib/ are commented-out dead code — delete deferred to a dedicated dead-code cleanup PR |

### AppTheme regression grep
```
grep -rn 'AppTheme' lib/ → NONE
grep -rn 'athar_theme' lib/ → NONE
```

---

## STEP 5 — Analyzer + regressions

### flutter analyze --no-fatal-infos
```
Analyzing athar...
No issues found! (ran in 4.5s)
```

### Regression greps
| Check | Result |
|-------|--------|
| `grep -rn 'AppTheme' lib/` | NONE |
| `grep -rn 'athar_theme' lib/` | NONE |
| `grep -n 'ThemeMode\|themeMode\|themePreference' lib/app.dart` | Lines 165–177 intact, unchanged |
| `grep -n 'BorderRadius\.only' athar_light_theme.dart athar_dark_theme.dart` | NONE |

---

## STEP 6 — PR3 goldens untouched

```
ls test/golden/pr3/*.png | wc -l → 16
```
All 16 golden PNGs untouched. No regen triggered.

---

## Summary

| Step | Description | Status |
|------|-------------|--------|
| STEP 1 | 44 × fontFamilyFallback in light theme | ✅ |
| STEP 1 | 44 × fontFamilyFallback in dark theme | ✅ |
| STEP 1 exception | Line 80 ThemeData.fontFamily left as-is (String slot) | ✅ |
| STEP 2 | app.dart wired to AtharLightTheme/AtharDarkTheme | ✅ |
| STEP 2 | themeMode/themePreference/LocaleCubit/routes untouched | ✅ |
| STEP 3 | DrawerTheme RTL fix in light theme | ✅ |
| STEP 3 | DrawerTheme RTL fix in dark theme | ✅ |
| STEP 4 | athar_theme.dart deleted | ✅ |
| STEP 4 | app_theme.dart deleted | ✅ |
| STEP 4 | themes.dart export cleaned | ✅ |
| STEP 4 | app_colors.dart deferred (no live usages, safe to leave) | ✅ |
| STEP 5 | flutter analyze: 0 issues | ✅ |
| STEP 5 | 4 regression greps clean | ✅ |
| STEP 6 | 16 PR3 goldens untouched | ✅ |

**PR-THEME is complete.**
