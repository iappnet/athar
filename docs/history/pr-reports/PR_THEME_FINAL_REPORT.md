# PR-THEME Final Report

**Date:** 2026-06-01
**Branch:** `feat/athar-v2-pr1-tokens-theme`
**Commit:** `bfaf863`
**Tag:** `athar-v2-prtheme-complete-final`
**Status:** COMPLETE — all phases delivered, approved, committed

---

## Full PR-THEME Arc

PR-THEME is a logical PR arc delivered across four commits on the migration branch:

| Commit | Phase | Scope | Tag |
|--------|-------|-------|-----|
| `14c13d6` | PR-THEME initial | Wire `ThemeMode.system` for auto dark mode in `app.dart` | `athar-v2-prtheme-complete` |
| `66bc884` | PR-THEME-3MODE | `ThemePreference` enum (system/light/dark) + migration + 3-option picker | `athar-v2-prtheme-3mode-complete` |
| `3872860` | PR-FONT-FALLBACK | Cairo fallback on all 38 `AtharTypography` base styles + extensions | — |
| `bfaf863` | PR-THEME FINAL | Wire `AtharLightTheme`/`AtharDarkTheme` + 88 `fontFamilyFallback` edits + RTL drawer | `athar-v2-prtheme-complete-final` |

---

## PR-THEME FINAL — Scope (commit `bfaf863`)

### STEP 1 — Font fallback gaps (88 edits across 2 files)

Every `TextStyle.copyWith` call that sets `fontFamily: AtharTypography.fontFamilyAr`
in both theme files now carries `fontFamilyFallback: AtharTypography.fontFallback`.

- `athar_light_theme.dart` — 44 edits
- `athar_dark_theme.dart` — 44 edits
- **Exception (both files, line 80):** `ThemeData.fontFamily` is a `String` field,
  not a `TextStyle`. It cannot carry `fontFamilyFallback`. Left as-is with an inline
  comment. This is the sole documented exception.

### STEP 2 — app.dart wiring

| Before | After |
|--------|-------|
| `import 'core/design_system/themes/app_theme.dart'` | `import 'core/design_system/themes/athar_light_theme.dart'` + dark |
| `theme: AppTheme.lightTheme` | `theme: AtharLightTheme.theme` |
| `darkTheme: AppTheme.darkTheme` | `darkTheme: AtharDarkTheme.theme` |

**Untouched:** `themeMode` switch, `themePreference`, `LocaleCubit`, routes — zero behavioral change.

### STEP 3 — DrawerTheme RTL fix

Both theme files:
```dart
// BEFORE (LTR-hardcoded):
borderRadius: BorderRadius.only(
  topLeft: Radius.circular(0), bottomLeft: Radius.circular(0),
  topRight: Radius.circular(16), bottomRight: Radius.circular(16),
)

// AFTER (RTL-aware):
borderRadius: BorderRadiusDirectional.only(
  topStart: Radius.circular(0), bottomStart: Radius.circular(0),
  topEnd: Radius.circular(16), bottomEnd: Radius.circular(16),
)
```

### STEP 4 — Cleanup

| Action | File |
|--------|------|
| DELETED | `lib/core/design_system/themes/athar_theme.dart` (1-line empty stub) |
| DELETED | `lib/core/design_system/themes/app_theme.dart` (legacy, 0 live imports) |
| CLEANED | `lib/core/design_system/themes/themes.dart` — removed `export 'athar_theme.dart'` |
| DEFERRED | `lib/core/design_system/themes/app_colors.dart` — all lib/ usages commented-out; deferred to PR-CLEANUP |

---

## Validation Results

| Check | Result |
|-------|--------|
| `flutter analyze --no-fatal-infos` | ✅ 0 issues |
| `flutter test` | ✅ 45/45 passed (16 golden + 28 stats + 1 config) |
| PR3 golden PNGs (16/16) | ✅ Untouched — no regen forced |
| `AppTheme` references in lib/ | ✅ NONE |
| `BorderRadius.only` in DrawerTheme | ✅ NONE |
| themeMode/themePreference in app.dart | ✅ Intact and unchanged |

---

## Open Items (Non-Blocking)

| Item | Owner | When |
|------|-------|------|
| Physical device QA — forest-dark surfaces | QA | Post-merge (pre-release gate) |
| Physical device QA — dark-mode visual validation | QA | Post-merge (pre-release gate) |
| Physical device QA — RTL drawer direction | QA | Post-merge (pre-release gate) |
| Physical device QA — Arabic rendering (Cairo fallback) | QA | Post-merge (pre-release gate) |
| Physical device QA — countdown tick, active prayer window | QA | Post-merge (pre-release gate) |
| `app_colors.dart` dead-code cleanup | PR-CLEANUP | After all component PRs |
| Calibri App Store licence (bug B1) | Legal/design | Before submission |

---

## Why This PR Was Needed

`AtharLightTheme` and `AtharDarkTheme` were fully built since PR1 but `app.dart` continued
serving the legacy `AppTheme` stub (3 text styles, `fontFamily: 'Cairo'`, no tokens).

Additionally, every `copyWith(fontFamily: 'Calibri')` call severs Flutter's inherited
Cairo glyph chain. Without `fontFamilyFallback: ['Cairo', ...]` on every such TextStyle,
Arabic text would render tofu boxes wherever a component theme overrides the font.
This PR fixes both issues atomically.

---

## Files Changed

```
lib/app.dart                                           — theme import + wiring swap
lib/core/design_system/themes/athar_light_theme.dart  — 44 fontFamilyFallback + RTL drawer
lib/core/design_system/themes/athar_dark_theme.dart   — 44 fontFamilyFallback + RTL drawer
lib/core/design_system/themes/themes.dart             — remove athar_theme.dart export
VERIFICATION_PR_THEME.md                              — evidence document (6-step proof)
[DELETED] lib/core/design_system/themes/app_theme.dart
[DELETED] lib/core/design_system/themes/athar_theme.dart
```
