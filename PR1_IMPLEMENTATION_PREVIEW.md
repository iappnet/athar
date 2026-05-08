# PR1 — Tokens & Theme: Implementation Preview

**Status:** AWAITING FINAL APPROVAL — do not implement until user explicitly approves  
**Last validated:** 2026-05-08 (against handoff_v2-2)  
**Scope:** Token value updates only. No layout changes. No component changes. No new files.  
**Spec authority:** `handoff_v2-2/colors_and_type.css` + `handoff_v2-2/DESIGN_SYSTEM_GAP_VALIDATION.md`

---

## Validation Status (2026-05-08)

| Check | Result |
|-------|--------|
| colors_and_type.css values re-verified | ✅ All hex values confirmed match PR1 mappings below |
| DESIGN_SYSTEM_GAP_VALIDATION.md read | ✅ Typography authority lockdown confirmed (2026-05-08) |
| FINAL_PACKAGE_MANIFEST.md changelog reviewed | ✅ Two changes post-date session state — neither affects PR1 scope |
| PACKAGE_C_DECISIONS.md reviewed | ✅ No PR1-scope changes |
| THEME_DARK_SPEC.md reviewed | ✅ Dark surface tokens are NOT in PR1 scope |
| PR1 isolation: 10 scope checks | ✅ All 10 pass — see table below |

---

## PR1 Scope Isolation — 10 Checks

| Isolation Check | Status | Notes |
|----------------|--------|-------|
| Tokens / theme / typography / font assets / pubspec only | ✅ PASS | Exact scope |
| No onboarding logic changes | ✅ PASS | Onboarding is PR-ONBOARD-AB |
| No calendar rebuild work | ✅ PASS | Calendar is PR4a/PR4b |
| No widget redesign work | ✅ PASS | Widgets is PR9 |
| No Spaces refactors | ✅ PASS | Spaces is PR8 |
| No Isar schema changes | ✅ PASS | No entity files touched |
| No routing changes | ✅ PASS | No route file touched |
| No auth changes | ✅ PASS | No auth file touched |
| No Supabase changes | ✅ PASS | No repository/remote changes |
| No settings behavior changes | ✅ PASS | `isAutoModeEnabled` wiring is PR-THEME |

---

## Files Changed (Complete List)

### Changed

| File | Change Type | Lines Affected |
|------|-------------|----------------|
| `lib/core/design_system/tokens/athar_colors.dart` | Value updates (light + dark palettes) | ~11 value lines |
| `lib/core/design_system/tokens/athar_typography.dart` | Font family names + new numericMono style | ~5 lines |

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
| `pubspec.yaml` | Font assets (Calibri .ttf) are Step B — see Calibri section |

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
- `prayerCardGradient` — already matches spec, **MUST NOT change**

### `AtharColors.dark` — Color Changes

| CSS Dark Variable | Hex Target | Dart Field | Current Value | New Value |
|---|---|---|---|---|
| `--primary` | `#2E8B57` | `primary` | `Color(0xFF8B85FF)` | `Color(0xFF2E8B57)` |
| `--primary-light` | `#4DAD7A` | `primaryLight` | `Color(0xFFB8B4FF)` | `Color(0xFF4DAD7A)` |
| `--primary-dark` | `#1A6B3C` | `primaryDark` | `Color(0xFF6C63FF)` | `Color(0xFF1A6B3C)` |
| `--border-focused` | `#2E8B57` | `borderFocused` | `Color(0xFF8B85FF)` | `Color(0xFF2E8B57)` |

> **Note:** `THEME_DARK_SPEC.md` specifies new green-tinted dark surface tokens (`surface #1A2520`, `background #0E1714`, `text-primary #EDE6C8`) that differ from `colors_and_type.css`. These dark surface changes are **explicitly out of PR1 scope** — they represent a larger dark-mode redesign. Flagged as DRIFT-2 in `IMPLEMENTATION_SESSION_STATE.md`. Requires designer resolution before dark surface PR.

**Dark secondary variants:** CSS dark spec does not define dark secondary. Keep existing dark secondary values unchanged.

### `AtharTypography` — Font Family Changes

| Constant | Current Value | New Value | Authority |
|---|---|---|---|
| `fontFamilyAr` | `'Cairo'` | `'Calibri'` | `colors_and_type.css --font-ar`, `DESIGN_SYSTEM_GAP_VALIDATION.md` |
| `fontFamilyEn` | `'Inter'` | `'Calibri'` | `colors_and_type.css --font-en`, `DESIGN_SYSTEM_GAP_VALIDATION.md` |
| `fontFamilyMono` | `'JetBrains Mono'` | unchanged | Matches `--font-mono` |

**New constant to add:**

```dart
static const TextStyle numericMono = TextStyle(
  fontFamily: fontFamilyMono,
  fontFeatures: [FontFeature.tabularFigures()],
  fontSize: 14,
  fontWeight: FontWeight.w400,
);
```

**Fallback stack:** Cairo remains in pubspec as OS-level fallback for AR rendering. Inter remains as OS-level fallback for EN rendering. Neither is a design-authority font. Both are fallbacks only if Calibri fails to load entirely.

---

## Typography Authority (Locked — 2026-05-08)

**Calibri is the sole canonical brand typeface across the entire Athar experience — Arabic AND English.** This is locked by:
- `DESIGN_SYSTEM_GAP_VALIDATION.md` (locked 2026-05-08)
- `FINAL_PACKAGE_MANIFEST.md` "Typography authority" section
- `colors_and_type.css` — all five `--font-*` variables use `'Calibri', system-ui, sans-serif`

Cairo is NOT the Arabic primary. It carries no design authority. It may appear only as a last-resort emergency OS-level fallback.

---

## Calibri Font Handling Plan

### The Blocker (B1 — unchanged)

Calibri `.ttf` files are in `handoff_v2-2/fonts/`:
- `calibri-light.ttf` (weight 300)
- `calibri-regular.ttf` (weight 400)
- `calibri-bold.ttf` (weight 700)

These files are **not yet in the Flutter project**. PR1 Dart changes reference `'Calibri'` — without the asset registration, Flutter silently falls through to Cairo/Inter. The feature works, but the visual spec is not applied.

### Two-Step Approach

**Step A — Dart changes only (safe, ready to implement):**
- Update `fontFamilyAr` and `fontFamilyEn` to `'Calibri'`
- Flutter falls back to Cairo/Inter — no visual regression, no crash
- Mergeable immediately once user approves this diff list

**Step B — Font wiring (blocked on B1):**
1. Copy `.ttf` files from `handoff_v2-2/fonts/` → `assets/fonts/`
2. Register in `pubspec.yaml` under `flutter.fonts`
3. Confirm App Store licence with designer
4. Merge only after licence confirmation

**Risk:** Step A without Step B is safe. Step B without licence confirmation risks App Store rejection.

---

## Excluded from PR1 (Explicitly Out of Scope)

| Item | Where it belongs |
|------|------------------|
| `isAutoModeEnabled` → `ThemeMode.system` wiring | PR-THEME (3-line fix in app.dart:162–172) |
| Dark surface/background/text tokens (THEME_DARK_SPEC.md values) | Future dark-mode surface PR — needs designer resolution |
| `AtharColors.copyWith` / `lerp` method updates | PR1 (update alongside values) |
| `adaptive_scaffold.dart` rename | PR2 |
| Bottom-nav FAB position (standalone pill outside bar) | PR2 (via PACKAGE_C_DECISIONS.md #2, locked 2026-05-08) |
| Prayer card gradient | Already matches spec — no change |
| `AppColors` flat class | Not part of ThemeExtension system — leave as-is |
| `typography.dart` empty stub | Leave as-is |
| Any component or layout change | PR2+ |
| Adhan audio asset wiring | PR-ADHAN |
| Calibri font file copy + pubspec registration | Step B (blocked on licence B1) |
| Calendar dual-date display | PR4a/PR4b |
| Dark mode secondary gradient colors | Spec gap — seek designer input |

---

## Expected UI Impact

### Visual Changes After PR1

1. **All primary-colored elements shift from purple → Islamic green.**
   - AppBar fill color (primary)
   - Active NavBar tab indicator
   - Primary buttons (ElevatedButton)
   - Toggle/switch active color
   - Any component using `Theme.of(context).colorScheme.primary`
   - Any component using `context.colors.primary`

2. **All secondary-colored elements shift from teal-cyan → teal-green.**
   - Secondary buttons
   - Chips using secondary color
   - Any `context.colors.secondary` consumer

3. **Font family name changes — no visual change until Calibri font files are added.**
   - Without font files: Cairo/Inter continue to render (transparent to user)
   - With font files (Step B): all text shifts to Calibri weight 300/400/700

4. **No layout changes. No spacing changes. No radius changes.**

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
| Purple-dependent hardcoded colors clash with green | Medium | Audit `grep -r "6C63FF\|9D97FF\|8B85FF" lib/` post-merge |
| Prayer card gradient overwritten | Low | `prayerCardGradient` explicitly DO-NOT-CHANGE in commit |
| Calibri fallback silent failure | Low | Flutter renders Cairo/Inter — no crash, only visual delta |
| `context.colors.primary` consumer reads old value in cached build | Low | Hot restart clears; no runtime cache |
| Dark mode primary shows purple if dark const not updated | High | PR1 MUST update both `.light` and `.dark` primary instances |

---

## Spec References

| Section | Canonical Source |
|---|---|
| Light palette values | `handoff_v2-2/colors_and_type.css` `:root` block |
| Dark primary values | `handoff_v2-2/colors_and_type.css` `[data-theme="dark"]` block |
| Dark surface values | `handoff_v2-2/THEME_DARK_SPEC.md` — **NOT in PR1 scope** |
| Font family stack | `handoff_v2-2/colors_and_type.css` `--font-ar`, `--font-en`, `--font-mono` |
| Calibri authority | `handoff_v2-2/DESIGN_SYSTEM_GAP_VALIDATION.md`, `handoff_v2-2/PACKAGE_A_DECISIONS.md` |
| numericMono requirement | `handoff_v2-2/CLAUDE_CODE_PROMPT.md` PR1 section |
| Prayer gradient preserve | `lib/core/design_system/tokens/athar_colors.dart` — already matches spec |

---

## Pre-Implementation Checklist

Before any Dart file is edited, confirm:

- [ ] User has explicitly approved this PR1 diff list
- [ ] Designer has confirmed Calibri App Store licence status (or Step A only is proceeding)
- [ ] Screenshot of current purple UI captured for before/after comparison
- [ ] `flutter analyze` runs clean on current branch
- [ ] `prayerCardGradient` is explicitly marked DO-NOT-CHANGE in the commit message
- [ ] Dark surface token discrepancy (DRIFT-2) is acknowledged and deferred to future PR
- [ ] Security review cleared (✅ 2026-05-08)

---

## Recommended Commit Message

```
feat(tokens): migrate color palette from purple to Islamic green (PR1 Step A)

- AtharColors.light: primary/secondary family → CSS spec #1A6B3C/#0D7377
- AtharColors.dark: primary family → CSS spec #2E8B57
- AtharTypography: fontFamilyAr/En → 'Calibri' (falls back to Cairo/Inter
  until font assets wired in Step B, pending App Store licence confirm)
- AtharTypography: add numericMono with tabularFigures

Spec: handoff_v2-2/colors_and_type.css + DESIGN_SYSTEM_GAP_VALIDATION.md
Prayer card gradient intentionally unchanged (already matches spec).
Dark surface tokens (THEME_DARK_SPEC.md) deferred — separate PR.
```
