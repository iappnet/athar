# Implementation Readiness Report
**Date:** 2026-05-07  
**Source:** handoff_v2 (canonical) + live codebase read-only audit  
**Status:** Pre-implementation. No Dart files modified.  
**Scope:** Full redesign from PR1 (Tokens & Theme) through PR-CLEANUP.

---

## 1. Understanding of the Current Architecture

### Token layer (lib/core/design_system/tokens/)
Six token files exist: `athar_colors.dart`, `athar_typography.dart`, `athar_spacing.dart`, `athar_radii.dart`, `athar_shadows.dart`, `athar_animations.dart`. All are `abstract class` + `ThemeExtension` (colors) or `abstract class` of constants (others). Structure is correct; **values need updating**.

### Theme wiring (lib/core/design_system/themes/)
`AppTheme.lightTheme` and `AppTheme.darkTheme` are referenced in `app.dart:170–171`. `AtharColors` is a `ThemeExtension` registered in both themes. `app.dart:172` drives `themeMode` from `UserSettings.isDarkMode`. `UserSettings.isAutoModeEnabled` is persisted to Isar but **never read** in `app.dart`.

### Font pipeline
`pubspec.yaml` loads four Cairo weights (Regular, Medium, SemiBold, Bold) from `assets/fonts/`. Cairo is the current primary for Arabic and English. `AtharTypography.fontFamilyAr = 'Cairo'`, `fontFamilyEn = 'Inter'`. **Calibri is not in pubspec.yaml and not in assets/fonts/.**

### Design-context/ files in handoff_v2
These are **snapshots of the current repo state** captured for context. They do NOT represent the target design. The target comes from `colors_and_type.css`. Critically, `design-context/athar_colors.dart` shows the OLD purple palette (`primary: Color(0xFF6C63FF)`) — this is the current live state, not what PR1 implements.

### Adaptive scaffold
`lib/core/layouts/adaptive_scaffold.dart` exists (confirmed). PR2 renames it to `lib/core/design_system/widgets/adaptive_shell.dart` — that is a **PR2 concern, not PR1**.

---

## 2. Understanding of the handoff_v2 Package

### Canonical contract
`colors_and_type.css` defines all token values to port into Dart. It is the ground truth, not `design-context/*.dart` (those are current state snapshots).

### Color palette shift (MAJOR)
Current primary is **purple** (`#6C63FF`). New primary is **Islamic green** (`#1A6B3C`). This is a full brand palette replacement. Every surface/border/focus color that currently references purple shifts to green.

### Font shift (MAJOR, LICENSE RISK)
Target: `Calibri` primary (Light 300 / Regular 400 / Bold 700), `Cairo` fallback for Arabic, `Inter` fallback for English. Calibri TTF files are bundled in `handoff_v2/fonts/`. **PACKAGE_A_DECISIONS.md explicitly flags: "legal/product owner must confirm Calibri embedding licence before App Store submission."** This is a known accepted risk, not an oversight.

### New `numericMono` style
`colors_and_type.css` defines `.num { font-variant-numeric: tabular-nums; font-feature-settings: "tnum" 1; }`. No equivalent exists in current `AtharTypography`. PR1 must add a `numericMono` static `TextStyle` to `AtharTypography` with `fontFeatures: [FontFeature.tabularFigures()]` and `fontFamily: fontFamilyMono`.

### Dark theme target
`colors_and_type.css` `[data-theme="dark"]` overrides define the dark values. Key shifts: primary → `#2E8B57`, background → `#121212`, surfaces match current Dart `AtharColors.dark` already. The surface/text values in dark theme mostly match the current `AtharColors.dark` constants — the **primary/secondary/border-focused** values need updating.

### Motion tokens
`colors_and_type.css` defines `--dur-fast: 150ms`, `--dur-base: 200ms`, `--dur-slow: 300ms` with `ease-out: cubic-bezier(.16,1,.3,1)`. Current `athar_animations.dart` may have different values — needs delta comparison in PR1.

### What PR1 does NOT touch
- File structure (no new files for PR1, only value updates in 6 token files)
- Theme wiring logic (that is PR-THEME)
- Font loading in pubspec.yaml (part of PR1 but requires adding Calibri fonts to assets and pubspec)
- Any feature widget code

---

## 3. Understanding of Locked Decisions

From `INVESTIGATION_RECONCILIATION.md` and `PACKAGE_A_DECISIONS.md`:

| Decision | Implementation impact for PR1 |
|----------|-------------------------------|
| Calibri primary (Arabic + English), Cairo fallback | Must add Calibri to pubspec + assets in PR1; update `fontFamilyAr` and `fontFamilyEn` |
| Islamic green primary (#1A6B3C) | Update all primary/primaryLight/primaryDark values in `AtharColors.light` and `.dark` |
| Islamic teal secondary (#0D7377) | Update secondary values |
| `isAutoModeEnabled` → `ThemeMode.system` | PR-THEME, NOT PR1 |
| `numericMono` tabular figures style | PR1 — add to `AtharTypography` |
| Do NOT introduce `prayerCardVariant` | PR1 is token-only, this is not relevant |
| Eastern numerals opt-in (default OFF) | PR5, not PR1 |
| `design-context/` files are context, not target | Colors_and_type.css is the target |

---

## 4. Understanding of Onboarding Governance

**Onboarding is PR-ONBOARD-AB, entirely separate from PR1.** Governance rules that must survive ALL PRs including PR1:

- Variant A (existing 4-slide `onboarding_page.dart`) is the **canonical behavioral baseline** — must not regress
- New token colors applied to Variant B (existing-restyled) in `PR-ONBOARD-AB`, not in PR1
- `onboarding_page.dart` at `lib/features/home/presentation/pages/` must not be touched in PR1
- PR1 updates token values; the onboarding slide backgrounds in `_buildSlides()` reference hardcoded `Color(0x…)` — these are NOT migrated in PR1 (they belong to PR-ONBOARD-AB or PR-CLEANUP)
- The `SharedPreferences` key `'onboarding_seen'` must remain unchanged
- No new `OnboardingVariantService` in PR1

---

## 5. Identified Dependencies

### PR1 internal dependencies (must complete in order)
1. Copy Calibri TTF files from `handoff_v2/fonts/` → `assets/fonts/`
2. Register in `pubspec.yaml` under `fonts:`
3. Update `athar_colors.dart` (light values)
4. Update `athar_colors.dart` (dark values)
5. Update `athar_colors.dart` prayerCardGradient (this is a `static const` — must remain unchanged per spec; `--gradient-prayer: linear-gradient(135deg, #1E293B 0%, #0F172A 100%)` matches current value)
6. Update `athar_typography.dart` font families + add `numericMono`
7. Update `athar_spacing.dart` if values differ from CSS
8. Update `athar_radii.dart` if values differ from CSS
9. Update `athar_shadows.dart` if values differ from CSS
10. Update `athar_animations.dart` if duration/curve values differ

### PR1 downstream dependencies (not PR1's job but blocked until PR1 merges)
- All other PRs depend on PR1 being correct and merged first
- PR-THEME depends on PR1 token structure remaining intact
- PR2–PR9 all require correct color tokens to be present

---

## 6. Identified Migration Risks

| Risk | Severity | Details |
|------|----------|---------|
| **Calibri license** | 🔴 HIGH BLOCKER | PACKAGE_A_DECISIONS.md states licence must be confirmed before App Store submission. Embedding without confirmation risks App Store rejection. Risk accepted by designer per the decision doc, but must be called out explicitly. |
| **Primary color shift purple→green** | 🟡 MEDIUM | 211 hardcoded `Color(0x…)` occurrences in 20+ files continue to use old purple values until cleanup sweep. These will visually conflict with new green tokens during the transition period. |
| **`fontFamilyAr` rename** | 🟡 MEDIUM | Any widget with `.arabic` extension (via `AtharTextStyleExtension`) will render Calibri instead of Cairo. If Calibri TTF is not loaded correctly at runtime, Flutter silently falls back to system font — no crash but visual degradation. |
| **Calibri Arabic rendering** | 🟡 MEDIUM | Calibri is a Microsoft font designed for Latin. Arabic glyph coverage in Calibri is minimal. Arabic text with `fontFamilyAr = 'Calibri'` may render with system Arabic font or Cairo fallback. Need to verify actual Arabic text rendering at runtime. |
| **Dark theme primary mismatch** | 🟡 MEDIUM | Current dark primary is purple `#8B85FF`. New dark primary is green `#2E8B57`. Affects all surfaces that use `context.colors.primary` in dark mode — buttons, FAB, focus indicators, nav bar active state. |
| **`borderFocused` color shift** | 🟡 MEDIUM | Current: `#6C63FF` (purple). New: `#1A6B3C` (green). Affects focus rings on all text fields, search bars, form inputs. Visual change everywhere. |
| **`prayerCardGradient` static const** | 🟢 LOW | Current value is `[Color(0xFF1E293B), Color(0xFF0F172A)]`. CSS spec `--gradient-prayer: linear-gradient(135deg, #1E293B 0%, #0F172A 100%)` matches exactly. No change needed. |
| **Shadow opacity delta** | 🟢 LOW | CSS `--shadow-sm: 0 2px 4px rgba(0,0,0,.06)`. Dart may have slightly different values. Needs verification — likely minor visual delta. |
| **`AtharColors.lerp()` method** | 🟢 LOW | The lerp implementation in `athar_colors.dart` doesn't lerp gradients (uses `t < 0.5 ? a : b`). This is pre-existing behavior; PR1 doesn't change it. |

---

## 7. Identified UI Regression Risks

| Area | Risk | Details |
|------|------|---------|
| **All buttons** | 🟡 MEDIUM | Background shifts purple→green. Visually different everywhere. |
| **Nav bar active tab** | 🟡 MEDIUM | Active tab indicator color changes. |
| **Prayer card** | 🟢 LOW | `prayerCardGradient` is unchanged (static const). Prayer card visuals survive PR1. |
| **Focus FAB** | 🟡 MEDIUM | FAB background uses `primary` token. Will shift to green. |
| **Form fields** | 🟡 MEDIUM | Focus rings shift from purple to green. |
| **Snackbars / feedback** | 🟡 MEDIUM | `athar_feedback.dart` has 6 hardcoded colors — not migrated in PR1 (these are cleanup-sweep files). However, if they reference theme `primary` they will change. |
| **Onboarding slide gradients** | 🟢 LOW | Hardcoded in `onboarding_page.dart` — not changed by PR1. Safe. |
| **Dark mode primary surfaces** | 🟡 MEDIUM | All surfaces using `context.colors.primary` in dark mode shift green. |
| **`oil_animation.dart` / `fluid_engine.dart`** | 🟢 NONE | PR1 does not touch these files. Carve-out respected. |

---

## 8. Identified Architecture Risks

| Risk | Details |
|------|---------|
| **Token files are const** | Most token values are `static const`. Dart `const` is safe at compile time; no architecture risk. |
| **`AtharColors` is a `ThemeExtension`** | All consumers use `Theme.of(context).extension<AtharColors>()` or `context.colors.*`. No direct instantiation in feature code means PR1 value changes propagate cleanly. |
| **`app_colors.dart` vs `athar_colors.dart`** | Two color files exist (`themes/app_colors.dart` and `tokens/athar_colors.dart`). Need to verify `app_colors.dart` content before modifying. It may be a legacy file with hardcoded values that PR1 should also update. |
| **`typography.dart` (themes/) vs `athar_typography.dart` (tokens/)** | Same duplication concern. Both files exist. Need to verify which one is the live source. |
| **No build_runner impact** | PR1 changes no Isar models, no @injectable classes, no generated files. `build_runner` not needed. |

---

## 9. Identified Localization / RTL Risks

| Risk | Details |
|------|---------|
| **Calibri Arabic rendering** | Calibri has limited Arabic glyph support. If `fontFamilyAr = 'Calibri'` renders Arabic text visually different from Cairo, every Arabic screen will look wrong. Must device-test before merging PR1. |
| **Arabic numerals** | `numericMono` style uses `fontFamilyMono` (JetBrains Mono). Eastern Arabic numerals feature is PR5 opt-in — not in PR1. Tabular figures still apply to Western numerals. |
| **Token-level RTL** | PR1 changes color/spacing values only. No directionality logic changes. RTL behaviors are unaffected. |
| **Font weight `light` (300)** | Cairo does NOT have a 300-weight variant in the current pubspec (only Regular/Medium/SemiBold/Bold loaded). Calibri Light 300 is new. If Cairo is used as fallback for `fontWeight: FontWeight.w300`, the fallback may use its Regular weight instead. This is a subtle regression risk in low-weight text. |

---

## 10. Identified Theme / Token Risks

| Risk | Details |
|------|---------|
| **`themes/app_colors.dart`** | Unknown content — may contain old purple palette hardcoded separately. Must read before implementing PR1. |
| **`themes/typography.dart`** | Unknown content — may be a legacy mapping file. Must read before implementing. |
| **`themes/athar_light_theme.dart` and `athar_dark_theme.dart`** | Listed in `_manifest.json`. These build `ThemeData` objects using `AtharColors`. Contain 4 hardcoded color literals each (from investigation). Will NOT be touched in PR1 unless they reference primary directly (audit needed). |
| **`themes/athar_theme.dart`** | Unknown content. May register `AtharColors` as theme extension. |
| **Missing `gradientPrayer` in `athar_colors.dart`** | The `prayerCardGradient` and `prayerCardShadow` are `static const` outside the instance fields — they don't participate in `copyWith` or `lerp`. If any theme code tries to override them, it would silently fail. However, this is pre-existing behavior. |
| **`athar_shadows.dart` delta** | Must verify current shadow values vs CSS spec before claiming PR1 is complete. |
| **`athar_animations.dart` delta** | CSS specifies `--dur-fast: 150ms`, `--dur-base: 200ms`, `--dur-slow: 300ms`. Current Dart values are unknown and must be verified. |

---

## 11. Identified Widget Risks

| Risk | Details |
|------|---------|
| **`liquid_glass_nav_bar.dart`** — 7 hardcoded colors | PR1 does not touch this file. Nav bar will still use old hardcoded colors. Visual inconsistency with new green tokens on widgets that DO use tokens. |
| **`next_prayer_card.dart`** — 12 hardcoded colors | Same issue. Not PR1 scope. Prayer card will be a visual mix of old hardcoded and new token colors until PR3 or PR-CLEANUP. |
| **`context_aware_fab.dart`** — 9 hardcoded colors | Not PR1 scope. FAB button background may partially use new green (if it reads `context.colors.primary`) and partially use hardcoded old colors. |
| **`athar_button.dart`** — 4 hardcoded colors | Not PR1 scope. |
| **Calibri in `app_button.dart`** | Buttons use `AtharTypography.button` style. After PR1, button text will use Calibri. Large visual change to all buttons. Needs screenshot validation. |

---

## 12. Identified Onboarding Risks

- **PR1 must not touch `onboarding_page.dart`** — any accidental change regresses Variant A (the canonical baseline)
- Onboarding slide gradient colors are hardcoded — they change only in PR-ONBOARD-AB, not PR1
- The 4-slide count, `SharedPreferences` key `'onboarding_seen'`, step structure are all untouched by PR1
- No `OnboardingVariantService` added in PR1

---

## 13. Identified Blockers

| # | Blocker | Impact | Owner |
|---|---------|--------|-------|
| **B1** | **Calibri embedding licence not confirmed** | If licence is invalid, PR1 cannot merge to production. It can proceed as a dev branch but App Store submission is blocked. | Product owner / legal |
| **B2** | **`themes/app_colors.dart` and `themes/typography.dart` not yet read** | These files may contain hardcoded values that conflict with PR1 token updates. Must be read before writing PR1 diffs. | Claude Code (trivial to unblock — read the files) |
| **B3** | **Current `athar_spacing.dart`, `athar_radii.dart`, `athar_shadows.dart`, `athar_animations.dart` values not verified against CSS** | May already match CSS spec (reducing PR1 scope) or may need updates. Must read before writing PR1 diffs. | Claude Code (trivial — read the files) |
| **B4** | **Calibri Arabic glyph coverage unknown** | If Calibri does not render Arabic glyphs correctly, `fontFamilyAr = 'Calibri'` will cause visual regression across all Arabic text. Requires device test before merge. | QA / developer |

---

## 14. Assumptions That Must NOT Be Made

1. **Do NOT assume `design-context/*.dart` files in handoff_v2 represent the target state.** They are current-repo snapshots for context only. The target comes from `colors_and_type.css`.
2. **Do NOT assume Calibri renders Arabic correctly.** Must be verified on device.
3. **Do NOT assume the Calibri licence is clear.** PACKAGE_A_DECISIONS.md explicitly warns it must be confirmed before App Store submission.
4. **Do NOT assume all other token files (spacing, radii, shadows, animations) need changes.** They might already match the CSS spec. Read them first.
5. **Do NOT rename or restructure token files.** Update values only.
6. **Do NOT introduce `prayerCardVariant` anywhere.** `UserSettings.prayerCardDisplayMode` already covers this.
7. **Do NOT create `lib/features/onboarding/`.** Refactor in place.
8. **Do NOT touch `onboarding_page.dart` in any PR before PR-ONBOARD-AB.**
9. **Do NOT assume `adaptive_scaffold.dart` exists at `lib/core/design_system/widgets/`.** It is at `lib/core/layouts/adaptive_scaffold.dart` — that rename is PR2.
10. **Do NOT run `build_runner` for PR1.** No Isar or Injectable changes in PR1.
11. **Do NOT add `prayerCardVariant` field to `UserSettings`.** Blocked explicitly.
12. **Do NOT migrate colors in `oil_animation.dart` or `fluid_engine.dart`.** Designer review required before touching these files.
13. **Do NOT assume `app_colors.dart` in `themes/` is identical to `athar_colors.dart` in `tokens/`.** They are different files and both need inspection.

---

## 15. Questions Requiring Approval Before Implementation

| # | Question | Blocking? |
|---|----------|-----------|
| **Q1** | Is the Calibri embedding licence cleared for App Store submission? If not, should PR1 proceed as a dev branch only, or should Calibri be deferred? | YES — blocks production merge |
| **Q2** | Should `fontFamilyAr` in `AtharTypography` be set to `'Calibri'` (with Cairo as CSS fallback) or should it remain `'Cairo'` and only English use Calibri? Arabic Calibri rendering quality is unknown. | YES — affects typography PR1 scope |
| **Q3** | The `design-context/athar_colors.dart` in handoff_v2 shows old purple values. Should PR1 port the `colors_and_type.css` green palette INTO the existing `AtharColors` class structure exactly as-is (same field names, just new values), or is there a new field needed (e.g., `prayerGradient` as an instance field instead of static const)? | Clarifying — low risk to assume no structural change |
| **Q4** | Do the existing `athar_spacing.dart`, `athar_radii.dart`, `athar_shadows.dart`, `athar_animations.dart` values already match `colors_and_type.css`? If yes, those files are no-ops in PR1. Confirming scope before writing diff. | Should be trivially answerable by reading files |
| **Q5** | `themes/app_colors.dart` and `themes/typography.dart` exist alongside the `tokens/` files. Are these legacy files to be deleted, kept in sync with `tokens/`, or are they the actual source used by `athar_light_theme.dart` / `athar_dark_theme.dart`? | YES — determines whether PR1 edits 6 or 8 files |

---
