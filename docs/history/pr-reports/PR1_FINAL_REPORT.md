# PR1 Final Report — Tokens & Theme

**PR:** PR1 — Athar v2 Design System Tokens & Calibri Font  
**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Commit:** `61d741a`  
**Date completed:** 2026-05-09  
**Status:** ✅ Approved and committed

---

## PR1 Implementation Summary

PR1 migrates the Athar design system from the legacy purple/teal palette (Cairo/Inter fonts) to the canonical Athar v2 green brand palette with Calibri as the sole typeface. This is the foundation layer — all subsequent PRs (PR-THEME, PR2, PR3, …) inherit these tokens.

**Scope:** Token values only. No UI layout, navigation, or component changes. No scope creep occurred.

---

## Files Changed

| File | Change type | Summary |
|------|-------------|---------|
| `lib/core/design_system/tokens/athar_colors.dart` | Modified | 22 token corrections — light palette (6 values) + dark palette (16 values) |
| `lib/core/design_system/tokens/athar_typography.dart` | Modified | `fontFamilyAr/En` → `'Calibri'`; added `numericMono` TextStyle |
| `pubspec.yaml` | Modified | Calibri font family registered: weights 300 / 400 / 700 |
| `assets/fonts/calibri-light.ttf` | Added | Calibri Light (300) |
| `assets/fonts/calibri-regular.ttf` | Added | Calibri Regular (400) |
| `assets/fonts/calibri-bold.ttf` | Added | Calibri Bold (700) |

**Total Dart files modified:** 2  
**Total asset files added:** 3  
**Total pubspec changes:** 1 font family declaration

---

## Token/Theme Changes Summary

### Light Palette — Corrected Values

| Token | Before | After | Authority |
|-------|--------|-------|-----------|
| `primaryLight` | `0xFF2D8A54` | `0xFF2E8B57` | `colors_and_type.css` |
| `primaryDark` | `0xFF0F4828` | `0xFF0F4A28` | `colors_and_type.css` |
| `secondaryLight` | `0xFF1A9EA3` | `0xFF14A098` | `colors_and_type.css` |
| `secondaryDark` | `0xFF075258` | `0xFF0B5A5C` | `colors_and_type.css` |
| `primaryGradient` stop 2 | `0xFF0F4828` | `0xFF0F4A28` | follows `primaryDark` |
| `secondaryGradient` stop 2 | `0xFF075258` | `0xFF0B5A5C` | follows `secondaryDark` |

### Dark Palette — Corrected Values

| Token | Before | After | Authority |
|-------|--------|-------|-----------|
| `primary` | `0xFF4DA878` | `0xFF2E8B57` | `colors_and_type.css` |
| `primaryLight` | `0xFF71C49A` | `0xFF4DAD7A` | `colors_and_type.css` |
| `background` | `0xFF121212` | `0xFF0E1714` | `THEME_DARK_SPEC.md` |
| `surface` | `0xFF1E1E1E` | `0xFF1A2520` | `THEME_DARK_SPEC.md` |
| `surfaceVariant` | `0xFF2D2D2D` | `0xFF22302B` | `THEME_DARK_SPEC.md` |
| `surfaceContainer` | `0xFF252525` | `0xFF2A3833` | `THEME_DARK_SPEC.md` |
| `scaffoldBackground` | `0xFF121212` | `0xFF0E1714` | `THEME_DARK_SPEC.md` |
| `textPrimary` | `0xFFE4E4E4` | `0xFFEDE6C8` | `THEME_DARK_SPEC.md` |
| `textSecondary` | `0xFFB0B0B0` | `0xFF9BA8A2` | `THEME_DARK_SPEC.md` |
| `textTertiary` | `0xFF808080` | `0xFF6B7771` | `THEME_DARK_SPEC.md` |
| `borderLight` | `0xFF333333` | `0xFF2A3833` | `THEME_DARK_SPEC.md` |
| `borderFocused` | `0xFF4DA878` | `0xFF2E8B57` | `colors_and_type.css` |
| `shimmerBase` | `0xFF2D2D2D` | `0xFF22302B` | follows `surfaceVariant` |
| `shimmerHighlight` | `0xFF404040` | `0xFF2A3833` | follows `surfaceContainer` |
| `primaryGradient` stop 1 | `0xFF4DA878` | `0xFF2E8B57` | follows `primary` |
| `surfaceGradient` stops | `0xFF1E1E1E / 0xFF121212` | `0xFF1A2520 / 0xFF0E1714` | follows surface/background |

**Rule applied:** Where `colors_and_type.css` and `THEME_DARK_SPEC.md` conflicted on dark surface tokens, `THEME_DARK_SPEC.md` was used (implementation rule 2). This is correct: `THEME_DARK_SPEC.md` represents the green-tinted dark theme intent; `colors_and_type.css` had neutral-grey dark values from an earlier draft.

### Preserved (not touched)

- `prayerCardGradient: [0xFF1E293B, 0xFF0F172A]` — ✅ already matched spec, must not change
- `prayerCardShadow: 0xFF0F172A` — ✅ preserved
- All light background / status / shadow / shimmer / overlay tokens — ✅ already correct
- `surfaceContainerHigh`, `surfaceContainerLow` (dark) — ✅ preserved

---

## Typography Migration Summary

| Change | Before | After |
|--------|--------|-------|
| `fontFamilyAr` | `'Cairo'` | `'Calibri'` |
| `fontFamilyEn` | `'Inter'` | `'Calibri'` |
| `numericMono` style | Not present | Added: JetBrains Mono + `tabularFigures()`, 14sp Regular |
| Comment (arabic extension) | "تطبيق خط عربي (Cairo)" | "تطبيق خط عربي (Calibri)" |
| Comment (english extension) | "تطبيق خط إنجليزي (Inter)" | "تطبيق خط إنجليزي (Calibri)" |

Cairo and Inter font assets remain in `pubspec.yaml` and `assets/fonts/` — they are not removed because they may still be referenced by components not yet migrated. They will be pruned in PR-CLEANUP after all components use Calibri.

---

## Dark-Mode Migration Summary

Dark mode now uses warm green-tinted surfaces and cream-tinted text, matching the Athar v2 Islamic aesthetic from `THEME_DARK_SPEC.md`. The previous dark mode used neutral grey values from the generic default palette.

**Visual effect:**
- Scaffold/background: cold black `#121212` → warm dark green `#0E1714`
- Cards/surfaces: neutral `#1E1E1E` → warm green `#1A2520`
- Body text: neutral grey `#E4E4E4` → warm cream `#EDE6C8`
- Secondary text: `#B0B0B0` → muted teal-grey `#9BA8A2`

This dark mode palette is intentional and design-confirmed. Future PR-CLEANUP will sweep components with hardcoded dark colours to also use these tokens.

---

## Tests Run

| Test | Result |
|------|--------|
| `flutter pub get` | ✅ Success |
| `flutter analyze` | ✅ 0 issues |
| `flutter test` | ✅ 29/29 passed |

Test suite: `test/features/stats/stats_helpers_test.dart` (28 stats tests) + `test/widget_test.dart` (AtharApp instantiation). No test regressions.

---

## Analyzer Result

```
Analyzing athar...
No issues found! (ran in 5.4s)
```

---

## Screenshot Checklist

The following screens will show visual changes. A manual visual regression pass should be run on device before PR-THEME:

| Screen | What changed | Light mode | Dark mode |
|--------|-------------|------------|-----------|
| All screens with text | Font: Cairo/Inter → Calibri | 🔲 | 🔲 |
| Home / Dashboard | Primary accent elements, focused borders | 🔲 | 🔲 |
| Task page | Task items, completion states | 🔲 | 🔲 |
| Habit page | Habit cards, progress bars | 🔲 | 🔲 |
| Prayer page | Prayer card gradient (unchanged) | 🔲 | 🔲 |
| Settings | Toggle/switch accents | 🔲 | 🔲 |
| Onboarding | Brand colour, CTA buttons | 🔲 | 🔲 |
| Stats page | Charts, numerics (new numericMono style available) | 🔲 | 🔲 |
| Scaffold background (dark) | `#121212` → `#0E1714` | N/A | 🔲 |
| Surface cards (dark) | `#1E1E1E` → `#1A2520` | N/A | 🔲 |
| Body text (dark) | `#E4E4E4` → `#EDE6C8` | N/A | 🔲 |

---

## Confirmation: No Scope Creep

The following were explicitly deferred and NOT touched:

| Deferred item | Target PR |
|---------------|-----------|
| `isAutoModeEnabled` wiring in `app.dart:162–172` | PR-THEME |
| AdaptiveShell rename / nav bar shape | PR2 |
| Prayer card visual refresh | PR3 |
| Calendar dual-display rebuild | PR4b |
| Accessibility settings section | PR5 |
| Stats redesign | PR6 |
| Any file outside the 3 approved Dart files + pubspec + fonts | — |

---

## Known Accepted Risks

| Risk | Severity | Status |
|------|----------|--------|
| **B1 — Calibri App Store licence** | Medium | Open. Font files are in the repo and wired. Licence must be confirmed by designer before App Store / TestFlight submission. This is a submission gate only — does not block development or further PRs. |
| **B5 — Dark surface conflict resolved** | Closed | `THEME_DARK_SPEC.md` adopted as canonical. Noted in change log. |
| **Cairo/Inter still in pubspec** | Low | Both old font families remain declared but will go unused as components migrate. Pruned in PR-CLEANUP. |

---

## Remaining Notes

- `numericMono` is now available at `AtharTypography.numericMono` — stats, counters, and timers should adopt it in PR6 and later.
- The `.arabic` and `.english` TextStyle extensions now resolve to Calibri. Any component calling `.arabic` on a TextStyle will now use Calibri, not Cairo.
- Dark mode wiring (`ThemeMode` response to `isAutoModeEnabled`) is not yet active — dark tokens exist but the app is not yet switching to them in response to the setting. That is PR-THEME.

---

## Rollback Instructions

To roll back PR1 on the feature branch:

```bash
# Discard all changes and return to the checkpoint state
git checkout main
git branch -D feat/athar-v2-pr1-tokens-theme
git checkout -b feat/athar-v2-pr1-tokens-theme 32e59c3
```

To roll back on main after merge:

```bash
git revert 61d741a
```

The revert will restore the old token values and remove Calibri font files.

---

## Git Information

| Field | Value |
|-------|-------|
| Commit hash | `61d741a` |
| Branch | `feat/athar-v2-pr1-tokens-theme` |
| Base commit | `32e59c3` (checkpoint before PR1) |
| Base branch | `main` |
| Working tree | Clean — nothing uncommitted |
| Files changed in commit | 13 (6 Dart/config + 3 font TTFs + 4 docs) |
| Insertions | 879 |
| Deletions | 124 |
