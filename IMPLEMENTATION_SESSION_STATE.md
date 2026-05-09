# Implementation Session State

**Last updated:** 2026-05-09  
**Session phase:** PR2 implementation IN PROGRESS — CP1+CP2 complete (commit `81af052`); CP3–CP6 pending  
**Canonical migration branch:** `feat/athar-v2-pr1-tokens-theme` (long-running; do NOT merge to `main`)  
**Checkpoint tags:** `athar-v2-pr1-complete` · `athar-v2-prtheme-complete` · `athar-v2-prtheme-3mode-complete`  
**Next action:** Continue PR2 — Checkpoint 3 (responsive breakpoints + iPad behavior verification)

---

## Current Progress

### Completed

| Document | Status | Location |
|----------|--------|----------|
| Codebase investigation | ✅ Complete | `handoff_v2-2/INVESTIGATION_REPORT.md` |
| Readiness & risk analysis | ✅ Complete | `IMPLEMENTATION_READINESS_REPORT.md` |
| Full PR execution plan | ✅ Complete | `IMPLEMENTATION_EXECUTION_PLAN.md` |
| PR1 exact diff preview | ✅ Complete | `PR1_IMPLEMENTATION_PREVIEW.md` |
| Security review (deep) | ✅ Complete | `SECURITY_REVIEW_DEEP_PR1.md` |
| PR1 final validation vs handoff_v2-2 | ✅ Complete | This session (2026-05-08) |
| Session change logs | ✅ Complete | `docs/ai/change-logs/` |

### Pending

| Item | Blocked On |
|------|-----------|
| PR-THEME (ThemeMode.system wiring) | ✅ Complete — `flutter analyze` 0 issues, `flutter test` 29/29 |
| PR-THEME-3MODE (Light/Dark/System picker) | ✅ Complete — `flutter analyze` 0, `flutter test` 29/29 |
| PR2 readiness closure | ✅ Complete — all 4 spec files read; PR2_FINAL_READINESS_REPORT.md + PR2_IMPLEMENTATION_PLAN.md created |
| PR2 (AdaptiveShell + nav bar) | 🔵 In Progress — CP1+CP2 complete (`81af052`); CP3–CP6 pending |
| PR3+ | PR2 |
| B1: Calibri App Store licence | Designer confirmation |

---

## Handoff_v2-2 Read State

| File | Read | Notes |
|------|------|-------|
| `FINAL_PACKAGE_MANIFEST.md` | ✅ | Canonical sequence; 2026-05-08 changelog noted |
| `CLAUDE_CODE_PROMPT.md` | ✅ | Full implementation rules; PR sequence authority |
| `INVESTIGATION_RECONCILIATION.md` | ✅ | 5 locked decisions (C1–C5) + E2 onboarding; DATE LOCKED 2026-05-07 |
| `DESIGN_SYSTEM_GAP_VALIDATION.md` | ✅ | Typography authority lockdown; Calibri sole canonical; DATE LOCKED 2026-05-08 |
| `PACKAGE_A_DECISIONS.md` | ✅ | Calibri, isHijriMode, AdaptiveShell, Stats |
| `PACKAGE_C_DECISIONS.md` | ✅ | Dark mode, 4-tab, calendar, Athkar, bottom-nav locked (#2) |
| `THEME_DARK_SPEC.md` | ✅ | Per-surface dark treatments; surface token values DIVERGE from colors_and_type.css (DRIFT-2) |
| `colors_and_type.css` | ✅ | Canonical token target — all PR1 values extracted and verified |
| `INVESTIGATION_REPORT.md` | ✅ Read (2026-05-09) | Current shell: `lib/core/layouts/adaptive_scaffold.dart`; `AdaptiveShell` absent from codebase |
| `REDESIGN_AUDIT.md` | ✅ Read (2026-05-09) | Per-screen ticket list; §11 = bottom nav shape; cross-cutting checklist |
| `CALENDAR_FOCUS_REDESIGN.md` | ❌ NOT READ | Required before PR4a/PR4b |
| `FOCUS_OIL_SPEC.md` | ❌ NOT READ | Required before PR8 |
| `IPAD_OPTIMIZATION.md` | ✅ Read (2026-05-09) | AdaptiveShell breakpoints; NavigationRail spec; FAB rail slot |
| `ONBOARDING_AB_SPEC.md` | ❌ NOT READ | Required before PR-ONBOARD-AB |
| `THEME_DARK_SPEC.md` | ✅ | Read 2026-05-08 — DRIFT-2 surfaced |
| `ui_kits/athar_app/*.jsx` | ❌ NOT READ | Visual reference only — read when needed |
| `preview/comp-nav.html` | ✅ Read (2026-05-09) | Dock flex, 10px gap, nav 64px/24px radius, FAB 64×64/22px radius |

---

## Canonical PR Sequence (handoff_v2-2 authoritative)

> Updated to match `FINAL_PACKAGE_MANIFEST.md` + `CLAUDE_CODE_PROMPT.md`. Previous session state had a stale sequence — corrected here.

| PR | Name | Status | Depends On |
|----|------|--------|-----------|
| PR1 | Tokens & Theme (Step A: Dart + Step B: Calibri font) | ✅ **COMPLETE** (`61d741a`) | — |
| PR-THEME | Auto dark mode wiring (app.dart:172) | ✅ COMPLETE | PR1 ✅ |
| PR2 | AdaptiveShell (rename adaptive_scaffold → adaptive_shell; breakpoints; nav bar shape) | ⬜ Not started | PR1 |
| PR3 | Prayer card refresh (PRAYER_CARD_SPEC.md) | ⬜ Not started | PR2 |
| PR-ADHAN | Bundle adhan.mp3/caf (build gate) | ⬜ Not started | Asset ready |
| PR4a | Calendar visual refresh (keep toggle; extend CalendarCubit) | ⬜ Not started | PR2 |
| PR4b | Calendar dual-display rebuild (DualDate VO + CalendarCell + DualMonthSwitcher) | ⬜ Not started | PR4a + designer spec |
| PR5 | Settings: Accessibility section (Reduce Motion, Disable Gyroscope, Eastern Numerals) | ⬜ Not started | PR2 |
| PR6 | Stats redesign (STATS_KPI_SPEC.md) | ⬜ Not started | PR2 |
| PR7 | Athkar feature (NET-NEW; curated sets v1) | ⬜ Not started | PR2 + designer review |
| PR8 | Focus screen oil-fill (FOCUS_OIL_SPEC.md) | ⬜ Not started | PR2 |
| PR9 | iOS widgets refresh (visuals only; infra exists) | ⬜ Not started | PR2 |
| PR-ONBOARD-AB | Four-variant onboarding A/B/C/D | ⬜ Not started | PR2 + designer approval |
| PR-CLEANUP | Hardcoded color sweep (remaining files) | ⬜ Not started | All others |

---

## Drift Log (2026-05-08 validation session)

Drifts are changes in the handoff_v2-2 package that post-date the previous session state (2026-05-07) or gaps between authority files discovered during validation.

### DRIFT-1: Bottom-nav shape locked (2026-05-08 — NEW)
- **Source:** `FINAL_PACKAGE_MANIFEST.md` changelog 2026-05-08; `PACKAGE_C_DECISIONS.md` #2 updated
- **Decision:** FAB is a **standalone pill OUTSIDE** the liquid-glass bar. Right of bar in LTR (English). Left of bar in RTL (Arabic). 64×64, 22px radius, `primary` gradient, `shadow.lg`.
- **Bar:** 4 tabs only (Dashboard / Tasks / Habits / Spaces). No centered FAB, no notch.
- **PR scope:** PR2 (AdaptiveShell + nav bar). NOT PR1.
- **Session state impact:** "PR-NAV" (separate PR) has been merged into PR2 per canonical sequence. No PR resequencing per FINAL_PACKAGE_MANIFEST.md.
- **Reference:** `preview/comp-nav.html` (LTR + RTL side-by-side)

### DRIFT-2: Dark surface token discrepancy between authority files
- **Source:** `THEME_DARK_SPEC.md` vs. `colors_and_type.css [data-theme="dark"]`
- **Conflict:** THEME_DARK_SPEC.md specifies green-tinted dark surfaces; colors_and_type.css has neutral dark values:

| Token | colors_and_type.css | THEME_DARK_SPEC.md |
|---|---|---|
| `surface` | `#1E1E1E` | `#1A2520` |
| `background` | `#121212` | `#0E1714` |
| `surface-variant` | `#2D2D2D` | `#22302B` |
| `surface-container` | `#252525` | `#2A3833` |
| `text-primary` | `#E4E4E4` | `#EDE6C8` (cream-tinted) |
| `text-secondary` | `#B0B0B0` | `#9BA8A2` |

- **PR1 impact:** NONE. Dark surfaces are not in PR1 scope.
- **Action required:** Designer must confirm which dark surface values are canonical before any dark-mode surface PR. Block B5 added.
- **Hypothesis:** THEME_DARK_SPEC.md values are the intended future target; colors_and_type.css has not yet been updated with the green-tinted dark theme. Do NOT assume — confirm.

### DRIFT-3: PR sequence was stale
- **Previous session state:** PR1, PR-THEME, PR-ASSETS, PR2 (Component library), PR3, PR4 (Habits+Athkar), PR5 (Tasks+Timeline), PR6 (Calendar), PR7 (Stats), PR8 (Spaces), PR-ONBOARD-AB, PR-NAV, PR-CLEANUP
- **Canonical (handoff_v2-2):** PR1, PR1-B, PR-THEME, PR2 (AdaptiveShell+nav), PR3 (Prayer card), PR-ADHAN, PR4a, PR4b, PR5 (Settings/Accessibility), PR6 (Stats), PR7 (Athkar net-new), PR8 (Focus oil-fill), PR9 (iOS widgets), PR-ONBOARD-AB, PR-CLEANUP
- **Key differences resolved:** "PR-ASSETS" split into PR1-B (Calibri) and PR-ADHAN (audio). "PR-NAV" merged into PR2. PR numbering realigned. Tasks/Habits are redesign work inside PR2+, not separate numbered PRs.
- **PR1 impact:** NONE.

### DRIFT-4: Missing docs in previous read state
- `DESIGN_SYSTEM_GAP_VALIDATION.md` — now read ✅
- `THEME_DARK_SPEC.md` — now read ✅ (surfaced DRIFT-2)
- `PACKAGE_C_DECISIONS.md` — now read ✅ (confirms bottom-nav decision #2)
- Remaining unread: `INVESTIGATION_REPORT.md`, `REDESIGN_AUDIT.md`, `ONBOARDING_AB_SPEC.md`, `IPAD_OPTIMIZATION.md`, `CALENDAR_FOCUS_REDESIGN.md`, `FOCUS_OIL_SPEC.md`

### DRIFT-6: isAutoModeEnabled naming collision (2026-05-09 — CRITICAL)
- **Source:** Live code investigation for PR-THEME readiness preview
- **Finding:** `UserSettings.isAutoModeEnabled` is the Smart Zones auto-scheduling toggle, used in `smart_zone_helper.dart:9`, `prayer_conflict_service.dart:97`, and `task_cubit.dart:236`. It has NO connection to dark mode.
- **Handoff document B2 error:** `INVESTIGATION_RECONCILIATION.md` decision B2 says "PR-THEME uses `UserSettings.isAutoModeEnabled`" — this is incorrect. The investigation that produced B2 mistook the Smart Zones auto mode field for a theme auto mode field.
- **Resolution:** PR-THEME uses `UserSettings.isDarkMode` only. Change `app.dart:172` from `ThemeMode.light` → `ThemeMode.system` when `isDarkMode=false`. No new field required. `isAutoModeEnabled` must NOT be touched by PR-THEME.
- **Full details:** `PR_THEME_IMPLEMENTATION_PREVIEW.md`

### DRIFT-5: UserSettings.theme field discrepancy
- **THEME_DARK_SPEC.md §1:** References `UserSettings.theme: 'system' | 'light' | 'dark'`
- **INVESTIGATION_RECONCILIATION.md B2 (locked):** Uses `UserSettings.isAutoModeEnabled` (boolean)
- **Resolution:** INVESTIGATION_RECONCILIATION.md is the overriding authority (locked 2026-05-07). PR-THEME uses `isAutoModeEnabled`. THEME_DARK_SPEC.md §1 appears to reflect a pre-reconciliation design sketch.
- **PR1 impact:** NONE.

---

## Token Delta — Confirmed Correct (2026-05-08 re-verification)

### Changes Required in PR1 (Step A)

**`lib/core/design_system/tokens/athar_colors.dart`**

Light palette — 7 fields change:
- `primary`: `0xFF6C63FF` → `0xFF1A6B3C`
- `primaryLight`: `0xFF9D97FF` → `0xFF2E8B57`
- `primaryDark`: `0xFF4A42DB` → `0xFF0F4A28`
- `secondary`: `0xFF03DAC6` → `0xFF0D7377`
- `secondaryLight`: `0xFF66FFF8` → `0xFF14A098`
- `secondaryDark`: `0xFF00A896` → `0xFF0B5A5C`
- `borderFocused`: `0xFF6C63FF` → `0xFF1A6B3C`

Dark palette — 4 fields change:
- `primary`: `0xFF8B85FF` → `0xFF2E8B57`
- `primaryLight`: `0xFFB8B4FF` → `0xFF4DAD7A`
- `primaryDark`: `0xFF6C63FF` → `0xFF1A6B3C`
- `borderFocused`: `0xFF8B85FF` → `0xFF2E8B57`

Preserve: `prayerCardGradient` — already matches spec, DO NOT CHANGE.

**`lib/core/design_system/tokens/athar_typography.dart`**

- `fontFamilyAr`: `'Cairo'` → `'Calibri'`
- `fontFamilyEn`: `'Inter'` → `'Calibri'`
- Add: `static const TextStyle numericMono = TextStyle(fontFamily: fontFamilyMono, fontFeatures: [FontFeature.tabularFigures()], fontSize: 14, fontWeight: FontWeight.w400)`

### No Changes Required

- `athar_spacing.dart` — already matches
- `athar_radii.dart` — already matches
- `athar_shadows.dart` — approximately matches, no PR1 action
- `athar_animations.dart` — durations match

---

## Open Blockers

| ID | Description | Action Required | PR Impact |
|----|-------------|----------------|-----------|
| B1 | Calibri App Store licence | Designer confirmation before Step B | Blocks PR1-B (font wiring) only |
| B2 | Dark mode secondary gradient variants not in CSS spec | Ask designer before dark secondary changes | Not PR1 |
| B3 | Calendar dual-display requires dedicated spec | Separate designer document before PR4b | Not PR1 |
| B4 | `isAutoModeEnabled` settings UI unknown | Investigation before PR-THEME | Not PR1 |
| B5 | Dark surface token conflict (DRIFT-2) | Designer must pick canonical values | Not PR1 |

---

## Do-Not-Touch Registry (Active for All PRs)

| Item | Reason |
|------|--------|
| `WidgetKeys` constants | Breaks installed widgets on user devices |
| App Group `group.com.iappsnet.athar` | Breaks widget data on all installed devices |
| `*.g.dart` files | Overwritten by build_runner |
| `injection.config.dart` | Generated |
| Prayer hierarchy: `isPrayerEnabled → isPrayerCardEnabled → isPrayerNotificationsEnabled → enablePrayerReminders` | Phase 8.1 enforcement |
| Central NavBar FAB as only add entry point (until PR2 ships new nav) | Design contract |
| iOS deployment target 17.0 | AppIntentConfiguration requirement |
| `prayerCardGradient` in AtharColors | Already matches spec |
| `onboarding_page.dart` Variant A | Must not regress until PR-ONBOARD-AB |
| `adaptive_scaffold.dart` | Rename deferred to PR2 |
| `oil_animation.dart` + `fluid_engine.dart` | Procedural colors — designer review required before token migration |

---

## Resumption Instructions

To resume implementation in a new session:

1. Read this file first.
2. Read `PR1_IMPLEMENTATION_PREVIEW.md` — this is the approved diff list.
3. Confirm user has given explicit approval (check conversation history).
4. If approved: edit only `athar_colors.dart` and `athar_typography.dart` (Step A).
5. Run `flutter analyze` before and after.
6. Do not touch any other file.
7. After PR1 Step A merged: raise B1 with designer (Calibri licence) before Step B.
8. After PR1: read `IMPLEMENTATION_EXECUTION_PLAN.md` for PR2 prerequisites.
9. Before PR2: read `IPAD_OPTIMIZATION.md`, `REDESIGN_AUDIT.md`, and `preview/comp-nav.html` (bottom-nav shape now locked per DRIFT-1).

**Do not read design-context/*.dart files as implementation targets** — they are current-state snapshots. The implementation target is `handoff_v2-2/colors_and_type.css`.

**Calibri font note:** Step A changes `fontFamilyAr/En` to `'Calibri'` in Dart. The actual `.ttf` files are in `handoff_v2-2/fonts/` but must NOT be copied to the Flutter project until B1 (licence) is confirmed.
