# Change Log — PR1 Complete (Tokens & Theme)

**Date:** 2026-05-08 22:30  
**Branch:** feat/athar-v2-pr1-tokens-theme  
**Session type:** Implementation (Dart + font assets)  
**Rules applied:** PR1 implementation rules 1–10

---

## Files Modified

| File | Type | Change |
|------|------|--------|
| `lib/core/design_system/tokens/athar_colors.dart` | Modified | Token corrections — light + dark palette |
| `lib/core/design_system/tokens/athar_typography.dart` | Modified | Font family → Calibri; `numericMono` added |
| `pubspec.yaml` | Modified | Calibri font family registered (300/400/700) |
| `assets/fonts/calibri-light.ttf` | Added | Calibri Light weight 300 |
| `assets/fonts/calibri-regular.ttf` | Added | Calibri Regular weight 400 |
| `assets/fonts/calibri-bold.ttf` | Added | Calibri Bold weight 700 |

---

## Token Delta — Final Verified State

### athar_colors.dart — Light palette

| Token | Old value | New value | Authority |
|-------|-----------|-----------|-----------|
| `primaryLight` | `0xFF2D8A54` | `0xFF2E8B57` | colors_and_type.css |
| `primaryDark` | `0xFF0F4828` | `0xFF0F4A28` | colors_and_type.css |
| `secondaryLight` | `0xFF1A9EA3` | `0xFF14A098` | colors_and_type.css |
| `secondaryDark` | `0xFF075258` | `0xFF0B5A5C` | colors_and_type.css |
| `primaryGradient` stop 2 | `0xFF0F4828` | `0xFF0F4A28` | follows primaryDark |
| `secondaryGradient` stop 2 | `0xFF075258` | `0xFF0B5A5C` | follows secondaryDark |

### athar_colors.dart — Dark palette

| Token | Old value | New value | Authority |
|-------|-----------|-----------|-----------|
| `primary` | `0xFF4DA878` | `0xFF2E8B57` | colors_and_type.css |
| `primaryLight` | `0xFF71C49A` | `0xFF4DAD7A` | colors_and_type.css |
| `background` | `0xFF121212` | `0xFF0E1714` | THEME_DARK_SPEC.md (rule 2) |
| `surface` | `0xFF1E1E1E` | `0xFF1A2520` | THEME_DARK_SPEC.md (rule 2) |
| `surfaceVariant` | `0xFF2D2D2D` | `0xFF22302B` | THEME_DARK_SPEC.md (rule 2) |
| `surfaceContainer` | `0xFF252525` | `0xFF2A3833` | THEME_DARK_SPEC.md (rule 2) |
| `scaffoldBackground` | `0xFF121212` | `0xFF0E1714` | THEME_DARK_SPEC.md (rule 2) |
| `textPrimary` | `0xFFE4E4E4` | `0xFFEDE6C8` | THEME_DARK_SPEC.md (rule 2) |
| `textSecondary` | `0xFFB0B0B0` | `0xFF9BA8A2` | THEME_DARK_SPEC.md (rule 2) |
| `textTertiary` | `0xFF808080` | `0xFF6B7771` | THEME_DARK_SPEC.md (rule 2) |
| `borderLight` | `0xFF333333` | `0xFF2A3833` | THEME_DARK_SPEC.md (rule 2) |
| `borderFocused` | `0xFF4DA878` | `0xFF2E8B57` | colors_and_type.css |
| `shimmerBase` | `0xFF2D2D2D` | `0xFF22302B` | follows surfaceVariant |
| `shimmerHighlight` | `0xFF404040` | `0xFF2A3833` | follows surfaceContainer |
| `primaryGradient` stop 1 | `0xFF4DA878` | `0xFF2E8B57` | follows primary |
| `surfaceGradient` stops | `0xFF1E1E1E/0xFF121212` | `0xFF1A2520/0xFF0E1714` | follows surface/background |

### Preserved (unchanged, already correct)

- `prayerCardGradient` — `[0xFF1E293B, 0xFF0F172A]` ✅
- `prayerCardShadow` — `0xFF0F172A` ✅
- All light background/text/status tokens ✅
- `surfaceContainerHigh`, `surfaceContainerLow` (dark) ✅

### athar_typography.dart

| Change | Old | New |
|--------|-----|-----|
| `fontFamilyAr` | `'Cairo'` | `'Calibri'` |
| `fontFamilyEn` | `'Inter'` | `'Calibri'` |
| `numericMono` | not present | Added: JetBrains Mono + tabularFigures, 14sp Regular |

---

## Verification Results

| Check | Result |
|-------|--------|
| `flutter pub get` | ✅ Success |
| `flutter analyze` | ✅ 0 issues |
| `flutter test` | ✅ 29/29 passed |
| Only PR1-approved files modified | ✅ |
| `prayerCardGradient` untouched | ✅ |
| THEME_DARK_SPEC.md used for dark surfaces | ✅ |
| PR1 isolated (no PR-THEME / PR2 work) | ✅ |

---

## Screens Affected (Before/After Reference)

The following screens visually change because they consume `primary`, `secondary`, or dark surface tokens via `context.colors.*`:

| Screen | What changes |
|--------|-------------|
| All screens (light) | `primaryLight`/`primaryDark`/`secondaryLight`/`secondaryDark` tints adjusted (subtle) |
| All screens (dark) | Background goes warm green-tinted; text goes cream-tinted |
| Focused text fields (both modes) | `borderFocused` now consistent green |
| Dark mode scaffold | `0xFF121212` → `0xFF0E1714` (warmer, greener) |
| Dark mode cards/surfaces | `0xFF1E1E1E` → `0xFF1A2520` (green-tinted) |
| Dark mode body text | `0xFFE4E4E4` (neutral grey) → `0xFFEDE6C8` (warm cream) |
| All text using `fontFamilyAr`/`fontFamilyEn` | Font switches from Cairo/Inter → Calibri |
| Counters/stats using `numericMono` | Now available with tabular figures |

---

## Open Blockers (unchanged from previous session)

| ID | Description | PR Impact |
|----|-------------|-----------|
| B1 | Calibri App Store licence — designer confirmation required | Font files added; need licence confirmation before App Store submission |
| B2 | Dark secondary gradient variants not in CSS spec | Not PR1 |
| B3 | Calendar dual-display requires dedicated spec | Not PR1 |
| B4 | `isAutoModeEnabled` settings UI unknown | Not PR1 (PR-THEME) |
| B5 | Dark surface token conflict resolved — THEME_DARK_SPEC.md used | Closed for PR1 |

---

## What Was NOT Done (PR1 boundary enforced)

- PR-THEME: `isAutoModeEnabled` wiring in `app.dart` — deferred
- PR2: AdaptiveShell / nav bar — deferred
- Any other file outside the 3 approved Dart files + pubspec + fonts
