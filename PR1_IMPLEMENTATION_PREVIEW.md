# PR1 — Tokens & Theme: Implementation Preview

**Status:** AWAITING APPROVAL — do not merge or implement until user explicitly approves  
**Scope:** Token value updates only. No layout changes. No component changes. No new files.  
**Spec authority:** `handoff_v2/colors_and_type.css`

---

## Files Changed (Complete List)

### Changed

| File | Change Type | Lines Affected |
|------|-------------|----------------|
| `lib/core/design_system/tokens/athar_colors.dart` | Value updates (light + dark palettes) | ~30 value lines |
| `lib/core/design_system/tokens/athar_typography.dart` | Font family + new numericMono style | ~5 lines |

### Unchanged (Confirmed Match)

| File | Reason |
|------|--------|
| `lib/core/design_system/tokens/athar_spacing.dart` | All 12 spacing values already match CSS spec |
| `lib/core/design_system/tokens/athar_radii.dart` | All radius values already match CSS spec |
| `lib/core/design_system/tokens/athar_shadows.dart` | Shadow layers match (minor decimal rounding — no action) |
| `lib/core/design_system/tokens/athar_animations.dart` | 150ms/200ms/300ms durations already match CSS |
| `lib/core/design_system/themes/app_colors.dart` | Flat utility class, not ThemeExtension — not part of PR1 |
| `lib/core/design_system/themes/typography.dart` | Empty stub — not part of PR1 |
| `lib/core/design_system/themes/athar_light_theme.dart` | Consumes AtharColors by field reference — auto-propagates |
| `lib/core/design_system/themes/athar_dark_theme.dart` | Same — auto-propagates |
| `pubspec.yaml` | Font assets (Calibri .ttf) are a BLOCKER — see section below |

---

## Exact Token Mappings

### `AtharColors.light` — Color Changes

| CSS Variable | Hex Target | Dart Field | Current Value | New Value |
|---|---|---|---|---|
| `--primary` | `#1A6B3C` | `primary` | `Color(0xFF6C63FF)` | `Color(0xFF1A6B3C)` |
| `--primary-light` | `#2E8B57` | `primaryLight` | `Color(0xFF9D97FF)` | `Color(0xFF2E8B57)` |
| `--primary-dark` | `#0F4A28` | `primaryDark` | `Color(0xFF4A42DB)` | `Color(0xFF0F4A28)` |
| `--secondary` | `#0D7377` | `secondary` | `Color(0xFF03DAC6)` | `Color(0xFF0D7377)` |
| `--secondary-light` | `#14A098` | `secondaryLight` | `Color(0xFF66FFF8)` | `Color(0xFF14A098)` |
| `--secondary-dark` | `#0B5A5C` | `secondaryDark` | `Color(0xFF00A896)` | `Color(0xFF0B5A5C)` |
| `--border-focused` | `#1A6B3C` | `borderFocused` | `Color(0xFF6C63FF)` | `Color(0xFF1A6B3C)` |

**Unchanged in light theme (already match CSS):**
- `background: Color(0xFFF8F9FA)` — matches `--background: #F8F9FA`
- `surface: Color(0xFFFFFFFF)` — matches `--surface: #FFFFFF`
- `surfaceVariant: Color(0xFFF5F5F5)` — matches `--surface-variant`
- `textPrimary: Color(0xFF2D3436)` — matches `--text-primary`
- `textSecondary: Color(0xFF636E72)` — matches `--text-secondary`
- `success: Color(0xFF00B894)` — matches `--success`
- `error: Color(0xFFFF7675)` — matches `--error`
- `warning: Color(0xFFFDCB6E)` — matches `--warning`
- `border: Color(0xFFDFE6E9)` — matches `--border`
- `prayerCardGradient` — matches CSS gradient spec, must NOT change

### `AtharColors.dark` — Color Changes

| CSS Dark Variable | Hex Target | Dart Field | Current Value | New Value |
|---|---|---|---|---|
| `--primary` | `#2E8B57` | `primary` | `Color(0xFF8B85FF)` | `Color(0xFF2E8B57)` |
| `--primary-light` | `#4DAD7A` | `primaryLight` | `Color(0xFFB8B4FF)` | `Color(0xFF4DAD7A)` |
| `--primary-dark` | `#1A6B3C` | `primaryDark` | `Color(0xFF6C63FF)` | `Color(0xFF1A6B3C)` |
| `--border-focused` | `#2E8B57` | `borderFocused` | `Color(0xFF8B85FF)` | `Color(0xFF2E8B57)` |

**Note:** CSS spec does not define dark secondary variants. Keep existing dark secondary values unless confirmed otherwise.

### `AtharTypography` — Font Family Changes

| Constant | Current Value | New Value | Reason |
|---|---|---|---|
| `fontFamilyAr` | `'Cairo'` | `'Calibri'` | CSS `--font-ar` primary is Calibri |
| `fontFamilyEn` | `'Inter'` | `'Calibri'` | CSS `--font-en` primary is Calibri |
| `fontFamilyMono` | `'JetBrains Mono'` | unchanged | Matches CSS `--font-mono` |

**New constant to add:**

```dart
static const TextStyle numericMono = TextStyle(
  fontFamily: fontFamilyMono,
  fontFeatures: [FontFeature.tabularFigures()],
  fontSize: 14,
  fontWeight: FontWeight.w400,
);
```

> Exact `fontSize` and `fontWeight` defaults TBD — PR1 ships a baseline; consuming components override as needed.

**Fallback stack (do NOT remove from pubspec):**
- Cairo remains in pubspec as fallback for AR rendering
- Inter remains in pubspec as fallback for EN rendering
- Both are fallbacks in the Calibri font-family stack per CSS spec

---

## Calibri Font Handling Plan

### The Blocker

Calibri `.ttf` files are bundled in `handoff_v2/fonts/`:
- `calibri-light.ttf` (300)
- `calibri-regular.ttf` (400)
- `calibri-bold.ttf` (700)

These files are **not yet in the Flutter project**. PR1 Dart changes reference `'Calibri'` — without the asset registration, Flutter silently falls through to Cairo/Inter. The feature works, but the font spec is not applied.

### Two-Step Approach

**Step A — Dart changes only (safe, mergeable now):**
- Update `fontFamilyAr` and `fontFamilyEn` to `'Calibri'`
- Flutter falls back to Cairo/Inter — no visual regression, no crash
- This step can merge as a preparatory commit

**Step B — Font wiring (blocked, merge separately):**
1. Copy `.ttf` files from `handoff_v2/fonts/` → `assets/fonts/`
2. Register in `pubspec.yaml` under `flutter.fonts`
3. Confirm App Store licence with designer
4. Merge only after licence confirmation

**Risk:** Step A without Step B is safe. Step B without licence confirmation risks App Store rejection.

---

## Excluded from PR1 (Explicitly Out of Scope)

| Item | Where it belongs |
|------|------------------|
| `isAutoModeEnabled` → `ThemeMode.system` wiring | PR-THEME (3-line fix in app.dart) |
| `AtharColors.copyWith` / `lerp` method updates | PR1 (these are structural, update alongside values) |
| `adaptive_scaffold.dart` rename | PR2 |
| Prayer card gradient | Already matches spec — no change |
| `AppColors` flat class | Not part of ThemeExtension system — leave as-is |
| `typography.dart` empty stub | Leave as-is |
| Any component or layout change | PR2+ |
| Adhan audio asset wiring | PR-ASSETS |
| Calendar dual-date display | PR-CAL |
| Dark mode secondary gradient colors | Spec gap — seek designer input |

---

## Expected UI Impact

### Visual Changes After PR1

1. **All primary-colored elements shift from purple → green.**
   - AppBar fill color (primary)
   - Active NavBar tab indicator
   - Primary buttons (ElevatedButton)
   - Toggle/switch active color
   - Text using `Theme.of(context).colorScheme.primary`
   - Any component using `context.colors.primary`

2. **All secondary-colored elements shift from teal-cyan → teal-green.**
   - Secondary buttons
   - Chips using secondary color
   - Any `context.colors.secondary` consumer

3. **Font family name changes — no visual change until Calibri font files are added.**
   - Without font files: Cairo/Inter continue to render (transparent to user)
   - With font files: all text shifts to Calibri weight 300/400/700

4. **No layout changes.** No spacing changes. No radius changes.

### Screens Most Visibly Affected

| Screen | Impact |
|--------|--------|
| Dashboard / MainPage | NavBar active state, FAB, action buttons |
| Prayer card | Primary-tinted elements (gradient is unchanged) |
| Habits page | Primary habit creation button, progress rings |
| Tasks page | Primary checkbox/completion colors |
| Settings page | Toggle active colors |
| Onboarding | Step indicator dots, primary CTA button |

---

## Regression Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Purple-dependent hardcoded colors now clash with green surroundings | Medium | Audit `grep -r "6C63FF\|9D97FF\|8B85FF" lib/` post-merge |
| Prayer card gradient accidentally overwritten | Low | Explicitly document as DO-NOT-CHANGE in PR diff |
| Calibri font fallback silent failure | Low | Flutter renders Cairo — no crash, only visual delta |
| `context.colors.primary` consumer reads old value in cached build | Low | Hot restart clears; no runtime cache |
| Dark mode primary still shows purple if dark const not updated | High | PR1 MUST update both `.light` and `.dark` instances |

---

## Spec References

| This file section | Canonical source |
|---|---|
| Light palette values | `handoff_v2/colors_and_type.css` `:root` block |
| Dark palette values | `handoff_v2/colors_and_type.css` `[data-theme="dark"]` block |
| Font family stack | `handoff_v2/colors_and_type.css` `--font-ar`, `--font-en`, `--font-mono` |
| Calibri font authority | `handoff_v2/PACKAGE_A_DECISIONS.md` — Calibri primary, licence risk accepted |
| numericMono requirement | `handoff_v2/CLAUDE_CODE_PROMPT.md` typography section |
| Prayer gradient preserve | `lib/core/design_system/tokens/athar_colors.dart` — already matches spec |

---

## Pre-Implementation Checklist

Before any Dart file is edited, confirm:

- [ ] User has explicitly approved this PR1 diff list
- [ ] Designer has confirmed Calibri App Store licence status (or Step A only is proceeding)
- [ ] Screenshot of current purple UI captured for before/after comparison
- [ ] `flutter analyze` runs clean on current branch
- [ ] `prayerCardGradient` is explicitly marked DO-NOT-CHANGE in the commit

---

## Recommended Commit Message

```
feat(tokens): migrate color palette from purple to Islamic green (PR1)

- AtharColors.light: primary/secondary family → CSS spec #1A6B3C/#0D7377
- AtharColors.dark: primary family → CSS spec #2E8B57
- AtharTypography: fontFamilyAr/En → 'Calibri' (falls back to Cairo/Inter until font assets wired)
- AtharTypography: add numericMono with tabularFigures

Spec: handoff_v2/colors_and_type.css
Prayer card gradient intentionally unchanged (already matches spec).
Font asset wiring deferred to Step B pending licence confirmation.
```
