# PR-THEME Readiness Report

**Date:** 2026-06-01
**Branch:** `feat/athar-v2-pr1-tokens-theme`
**Scope:** Full analysis of theme wiring state, font fallback gaps, and migration risks
**Status:** ANALYSIS ONLY — no code modified

---

## Executive Summary

The `ThemeMode` switching infrastructure is **fully wired** in `app.dart` and the settings stack. What is **not yet done**: the design system themes (`AtharLightTheme`, `AtharDarkTheme`) are **orphaned** — built but never connected to `MaterialApp`. The app currently serves the legacy `AppTheme` stub to all users regardless of their theme preference. PR-THEME must wire the real themes and fix font fallback gaps in both.

---

## 1 · ThemeMode Wiring Status

### What is already working

| Layer | File : Line | Status |
|-------|-------------|--------|
| `ThemePreference` enum (`system` / `light` / `dark`) | `user_settings.dart:19` | ✅ exists |
| `UserSettings.themePreference` field | `user_settings.dart:28` | ✅ exists, default `system` |
| `UserSettings.isDarkMode` field | `user_settings.dart:24` | ✅ exists (legacy, kept) |
| `UserSettings.isAutoModeEnabled` field | `user_settings.dart:25` | ✅ exists (legacy, kept) |
| One-time theme migration: `isDarkMode` → `ThemePreference` | `settings_cubit.dart:380–392` | ✅ implemented |
| `SettingsCubit.toggleThemePreference()` | `settings_cubit.dart:370–378` | ✅ implemented |
| Settings UI: 3-way toggle (Light / Dark / System) | `general_settings_page.dart:1003–1053` | ✅ implemented |
| `themeMode` switch in `MaterialApp` | `app.dart:173–177` | ✅ wired |
| `themePreference` read from `SettingsCubit` state | `app.dart:163–166` | ✅ wired |

### The critical gap: wrong ThemeData at both slots

```dart
// app.dart:171–172  — CURRENT (wrong)
theme:      AppTheme.lightTheme,    // legacy stub: Cairo, 3 text styles, no design system
darkTheme:  AppTheme.darkTheme,     // legacy stub: Cairo, 3 text styles, no design system
```

```dart
// app.dart:171–172  — TARGET (correct)
theme:      AtharLightTheme.theme,  // full design system, Calibri, 30+ token-matched styles
darkTheme:  AtharDarkTheme.theme,   // full design system, dark surfaces, same structure
```

`AtharLightTheme` and `AtharDarkTheme` are defined, complete, and exported from `themes.dart` — **but are imported by zero files in the runtime app**. The `themeMode` switch works today (it toggles `ThemeMode.light / dark / system`) but switches between two `AppTheme` stub instances that differ only in `scaffoldBackgroundColor` and a handful of hardcoded dark colors. No user sees the Athar design system in dark mode.

**`athar_theme.dart` is an empty 0-byte file** — it is a stub placeholder that can be deleted.

---

## 2 · Dark-Theme Font Fallback Gaps

### Gap in `athar_dark_theme.dart`

**45 occurrences** of `fontFamily: AtharTypography.fontFamilyAr` (= `'Calibri'`) set via `.copyWith()` in `ThemeData` and `TextTheme` definitions — **zero** have `fontFamilyFallback`.

Affected locations (representative, not exhaustive):

| Component | File : Line | Pattern |
|-----------|-------------|---------|
| `ThemeData.fontFamily` | `athar_dark_theme.dart:80` | Top-level `fontFamily: fontFamilyAr` — controls inherited glyph resolution |
| `TextTheme` — all 14 slots | `athar_dark_theme.dart:668–731` | `copyWith(fontFamily: fontFamilyAr)` — 14 occurrences, no fallback |
| `AppBarTheme.titleTextStyle` | `athar_dark_theme.dart:96–99` | `copyWith(fontFamily: fontFamilyAr)` |
| `BottomNavigationBarTheme` labels | `athar_dark_theme.dart:122–128` | `copyWith(fontFamily: fontFamilyAr)` ×2 |
| `NavigationBarTheme` labels | `athar_dark_theme.dart:150–157` | `copyWith(fontFamily: fontFamilyAr)` ×2 |
| Button themes (elevated, filled, outlined, text) | `athar_dark_theme.dart:191–243` | `copyWith(fontFamily: fontFamilyAr)` ×4 |
| `InputDecorationTheme` (label, floating, hint, error, helper) | `athar_dark_theme.dart:307–325` | ×5 |
| `SliderTheme.valueIndicatorTextStyle` | `athar_dark_theme.dart:391–394` | ×1 |
| `ChipTheme` labels | `athar_dark_theme.dart:413–419` | ×2 |
| `DialogTheme` (title, content) | `athar_dark_theme.dart:438–444` | ×2 |
| `SnackBarTheme.contentTextStyle` | `athar_dark_theme.dart:471–473` | ×1 |
| `TabBarTheme` labels | `athar_dark_theme.dart:486–490` | ×2 |
| `ListTileTheme` (title, subtitle) | `athar_dark_theme.dart:528–533` | ×2 |
| `TooltipTheme.textStyle` | `athar_dark_theme.dart:555–557` | ×1 |
| `PopupMenuTheme.textStyle` | `athar_dark_theme.dart:572–574` | ×1 |
| `DropdownMenuTheme.textStyle` | `athar_dark_theme.dart:582–584` | ×1 |
| `DatePickerTheme.dayStyle` | `athar_dark_theme.dart:604–605` | ×1 |
| `BadgeTheme.textStyle` | `athar_dark_theme.dart:631–632` | ×1 |

**When `copyWith(fontFamily: 'Calibri')` fires without `fontFamilyFallback: ['Cairo']`, Cairo theme inheritance is severed.** Any Arabic glyph that Calibri cannot render becomes a tofu box. This gap is inert today (dark theme not wired) but becomes a P0 bug the moment `AtharDarkTheme` is connected.

### Gap in `athar_light_theme.dart`

Identical pattern: **45 occurrences** of `fontFamily: AtharTypography.fontFamilyAr` without `fontFamilyFallback`. Same component list as above. Same risk — higher urgency because light is the theme that will be wired first.

### Gap in `app_theme.dart` (legacy)

`AppTheme` uses `fontFamily: 'Cairo'` (not Calibri) throughout. Since Cairo natively supports Arabic, it has no tofu risk. This file becomes dead code after the theme swap — but is safe today.

---

## 3 · Files Requiring Updates in PR-THEME

### Priority 1 — Mandatory before merge

| File | Change required |
|------|----------------|
| `lib/app.dart:171–172` | Replace `AppTheme.lightTheme` → `AtharLightTheme.theme`; `AppTheme.darkTheme` → `AtharDarkTheme.theme` |
| `lib/core/design_system/themes/athar_dark_theme.dart` | Add `fontFamilyFallback: AtharTypography.fontFallback` to all 45 `copyWith(fontFamily: fontFamilyAr)` calls; add `fontFamilyFallback` to top-level `fontFamily` line |
| `lib/core/design_system/themes/athar_light_theme.dart` | Same treatment as dark theme — 45 occurrences |
| `lib/app.dart` import | Add `import 'core/design_system/themes/athar_light_theme.dart'` + `athar_dark_theme.dart` (or via `design_system.dart`) |
| `lib/app.dart` import | Remove `import 'core/design_system/themes/app_theme.dart'` |

### Priority 2 — RTL/directional correctness (fix in same PR)

| File | Issue | Change required |
|------|-------|----------------|
| `athar_dark_theme.dart:509–516` | `DrawerTheme.shape` uses `BorderRadius.only(topLeft:0, bottomLeft:0, topRight:16, bottomRight:16)` — hardcoded LTR assumption | Replace with `BorderRadiusDirectional.only(topStart:0, bottomStart:0, topEnd:16, bottomEnd:16)` |
| `athar_light_theme.dart:509–516` | Same drawer hardcoded border radius | Same fix |

Note: Both themes share the identical drawer shape definition. In RTL (Arabic), the drawer enters from the right, so the Drawer `shape` rounded corners point the wrong way. `BorderRadiusDirectional` resolves this automatically.

### Priority 3 — Cleanup (can be separate micro-PR or same PR)

| File | Action |
|------|--------|
| `lib/core/design_system/themes/athar_theme.dart` | Delete — 0-byte empty file, has no content |
| `lib/core/design_system/themes/app_theme.dart` | Delete or archive after confirming no remaining import |
| `lib/core/design_system/themes/app_colors.dart` | Delete after confirming no live import (currently re-exported by `tokens.dart:20` — verify nothing active uses it) |
| `lib/core/design_system/themes/themes.dart` | Remove `export 'athar_theme.dart'` line after deleting the empty file |

---

## 4 · Migration Impact

### What changes when `AppTheme` → `AtharLightTheme / AtharDarkTheme`

| Dimension | AppTheme (current) | AtharLightTheme/Dark (target) | Risk |
|-----------|--------------------|-------------------------------|------|
| `ThemeData.fontFamily` | `'Cairo'` | `'Calibri'` (= `fontFamilyAr`) | **High** — glyph resolution flips; without `fontFamilyFallback: ['Cairo']` on every TextStyle, all Arabic text goes tofu. This is exactly the gap PR-THEME must fix. |
| `textTheme` completeness | 3 slots (displayLarge, bodyLarge, bodyMedium) | 14 slots, all named | Low risk — more complete is correct |
| `colorScheme` | `ColorScheme.fromSeed` (one color) | Full `ColorScheme.light/dark` (explicit) | Medium — widgets that read `colorScheme.*` will get new values |
| `cardColor`, `dividerColor`, etc | Partially set | Fully set via `AtharColors.light/dark` tokens | Low — expected improvement |
| `useMaterial3` | `true` | `true` | No change |
| Design system extensions (`AtharColors`) | Absent | Present (`extensions: [AtharColors.light/dark]`) | Positive — `Theme.of(context).extension<AtharColors>()` starts working |
| Button themes | Not set (Material defaults) | Full `ElevatedButtonTheme`, `FilledButtonTheme`, etc. | Medium — buttons change appearance; all use `AtharColors` tokens |
| Input decoration | Not set | Full `InputDecorationTheme` | Medium — text fields change appearance |

### Data migration: no changes

`ThemePreference` is already stored in Isar. No schema change needed. The one-time migration from `isDarkMode → themePreference` already runs on `SettingsCubit.loadSettings()`.

---

## 5 · Regression Risks

### R1 — Arabic tofu (HIGH if not fixed before wiring)

When `AppTheme` (Cairo primary) is replaced by `AtharLightTheme` (Calibri primary), the top-level `fontFamily` switches from Cairo to Calibri. Any `Text()` widget that relies on theme inheritance for Arabic glyph resolution will immediately tofu. Mitigation: fix both theme files' `fontFamilyFallback` gaps **in the same commit** as the `app.dart` wire-up. Do not wire without fixing.

### R2 — Theme extension dependency (LOW)

Code that calls `Theme.of(context).extension<AtharColors>()` will only work after the new themes are wired. Currently returns null on all paths. Verify no production code does a null-checked extension read before PR-THEME lands.

```bash
grep -rn "extension<AtharColors>" lib/ --include="*.dart"
```
Run this before merging to confirm it's safe.

### R3 — `AppTheme` import in `app.dart` (LOW)

`app.dart:20` currently imports `core/design_system/themes/app_theme.dart`. After the swap, this import becomes unused. Dart analyzer will flag it as an error. Remove the import in the same commit.

### R4 — `AppColors` re-export (LOW)

`tokens.dart:20` re-exports `app_colors.dart`. If anything in the codebase imports `tokens.dart` and reads `AppColors`, removing `app_colors.dart` breaks that. The grep above shows all live usages are in commented-out dead code. Verify with:

```bash
grep -rn "AppColors\." lib/ --include="*.dart" | grep -v "//\|\.g\.dart"
```

### R5 — Design system extensions active in tests (LOW)

Golden tests use `ThemeData.dark()` (a Material default, not `AtharDarkTheme`). After PR-THEME, if any golden test scaffold switches to `AtharDarkTheme.theme`, all 16 goldens will need regeneration. Only relevant if the test scaffold is updated as part of this PR — which it should not be unless explicitly planned.

---

## 6 · RTL Risks

### DrawerTheme hardcoded direction (CONFIRMED)

Both `athar_dark_theme.dart:509–516` and `athar_light_theme.dart:509–516` define:

```dart
DrawerTheme.shape = RoundedRectangleBorder(
  borderRadius: BorderRadius.only(
    topLeft:    Radius.circular(0),
    bottomLeft: Radius.circular(0),
    topRight:   Radius.circular(16),
    bottomRight: Radius.circular(16),
  ),
)
```

This assumes the drawer opens from the **left** (LTR default). In Arabic RTL layout, `Scaffold` places the drawer on the **right** edge. The rounded corners (topRight/bottomRight) face the interior of the screen in RTL instead of the edge — visually wrong.

Fix: replace `BorderRadius.only` with `BorderRadiusDirectional.only` using `topStart/bottomStart/topEnd/bottomEnd`. Flutter's `RoundedRectangleBorder` handles directional radii correctly.

### No other RTL directional hardcoding found in theme files

Checked for `EdgeInsets.only(left/right)`, `Alignment.centerLeft/centerRight`, hardcoded `TextDirection` — none found in either theme file. Theme files are otherwise RTL-safe.

---

## 7 · Localization Risks

### Theme files carry no localization dependency

Neither `athar_dark_theme.dart` nor `athar_light_theme.dart` import `AppLocalizations`, reference locale strings, or make locale-conditional decisions. Zero localization risk from the theme swap itself.

### Font rendering across locales

The font fallback fix (`fontFamilyFallback: ['Cairo', ...]`) handles both locales:
- AR: `'Calibri'` renders Latin metadata; Cairo fallback renders Arabic glyphs
- EN: `'Calibri'` renders all Latin glyphs; Cairo fallback is never reached

No locale-specific TextStyle branching is needed in theme files — the single fallback list covers both.

---

## 8 · Validation Plan

### Step 1 — Pre-wire font gap fix (same commit)

Fix `fontFamilyFallback` in both theme files **before** the `app.dart` wire-up. Pattern:

```dart
// Before (gap)
displayLarge: AtharTypography.displayLarge.copyWith(
  color: colors.textPrimary,
  fontFamily: AtharTypography.fontFamilyAr,
),

// After (correct)
displayLarge: AtharTypography.displayLarge.copyWith(
  color: colors.textPrimary,
  fontFamily: AtharTypography.fontFamilyAr,
  fontFamilyFallback: AtharTypography.fontFallback,
),
```

Apply to all 45 occurrences in each file (90 total edits across both files).  
Apply to `AppBarTheme`, `BottomNavigationBarTheme`, `NavigationBarTheme`, all button themes, `InputDecorationTheme`, `ChipTheme`, `DialogTheme`, `SnackBarTheme`, `TabBarTheme`, `ListTileTheme`, `TooltipTheme`, `PopupMenuTheme`, `DropdownMenuTheme`, `DatePickerTheme`, `BadgeTheme`.

### Step 2 — Wire themes in `app.dart`

```dart
// app.dart — remove:
import 'core/design_system/themes/app_theme.dart';

// app.dart — add (or via design_system.dart import already present):
import 'core/design_system/themes/athar_light_theme.dart';
import 'core/design_system/themes/athar_dark_theme.dart';

// app.dart:171–172 — change:
theme:     AtharLightTheme.theme,
darkTheme: AtharDarkTheme.theme,
```

### Step 3 — Fix drawer RTL in both theme files

Replace `BorderRadius.only(...)` with `BorderRadiusDirectional.only(...)` in `DrawerTheme` shape in both files.

### Step 4 — Analyzer

```
flutter analyze --no-fatal-infos
```

Must pass with zero issues before merge.

### Step 5 — Regression grep suite

Run before merge:

```bash
# Confirm AppColors is dead
grep -rn "AppColors\." lib/ --include="*.dart" | grep -v "//\|\.g\.dart"

# Confirm AtharColors extension is not null-checked in production
grep -rn "extension<AtharColors>" lib/ --include="*.dart"

# Confirm no remaining AppTheme import
grep -rn "import.*app_theme" lib/ --include="*.dart"

# Confirm no fontFamily without fontFamilyFallback in theme files
grep -n "fontFamily: AtharTypography" lib/core/design_system/themes/athar_dark_theme.dart
grep -n "fontFamily: AtharTypography" lib/core/design_system/themes/athar_light_theme.dart
# → all matches must be immediately followed by a fontFamilyFallback line
```

### Step 6 — Golden test decision

The existing 16 golden tests use `ThemeData.dark()` (not `AtharDarkTheme`) and are not affected by the theme swap unless explicitly updated. **Do not update goldens in PR-THEME** — preserve them as-is. A dedicated golden update can follow if needed.

### Step 7 — Live-device smoke test (light + dark, AR + EN)

| Check | AR | EN |
|-------|----|----|
| All text legible — no tofu boxes | | |
| Dark mode surfaces correct dark green palette (not GitHub-dark) | | |
| Settings → System / Light / Dark toggle responds immediately | | |
| Drawer rounded corners on correct side in RTL | | |
| Buttons, chips, input fields match design system tokens | | |
| Prayer card unaffected (uses explicit inline styles, not ThemeData) | | |

---

## Appendix: File Inventory

| File | Current state | PR-THEME action |
|------|--------------|-----------------|
| `lib/app.dart` | Uses `AppTheme.lightTheme/darkTheme` | Swap to `AtharLightTheme/AtharDarkTheme` |
| `lib/core/design_system/themes/athar_light_theme.dart` | Built, orphaned, 45 font gaps | Fix gaps, becomes active |
| `lib/core/design_system/themes/athar_dark_theme.dart` | Built, orphaned, 45 font gaps | Fix gaps, becomes active |
| `lib/core/design_system/themes/app_theme.dart` | Legacy stub (Cairo, 3 text styles) | Delete after swap |
| `lib/core/design_system/themes/app_colors.dart` | Legacy color constants | Delete after confirming no live usage |
| `lib/core/design_system/themes/athar_theme.dart` | Empty 0-byte file | Delete |
| `lib/core/design_system/themes/themes.dart` | Exports all above | Remove empty `athar_theme.dart` export |

---

*Analysis complete. No code modified. Ready for implementation.*
