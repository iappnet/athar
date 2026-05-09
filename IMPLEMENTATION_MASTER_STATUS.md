# Implementation Master Status — Athar v2 Design System

**Last updated:** 2026-05-09  
**Updated by:** Roadmap verification + migration branch strategy  
**Program-level view:** `PROGRAM_IMPLEMENTATION_STATUS.md`  
**Branch strategy:** `MIGRATION_BRANCH_STRATEGY.md`  
**Roadmap verification:** `MIGRATION_ROADMAP_VERIFICATION.md`  
**Canonical handoff package:** `handoff_v2-2/`  
**Canonical migration branch:** `feat/athar-v2-pr1-tokens-theme` ← do NOT merge to `main` until migration complete  
**main:** stable legacy baseline at `32e59c3` — do not touch  
**Authoritative sequence:** `handoff_v2-2/CLAUDE_CODE_PROMPT.md` + `handoff_v2-2/FINAL_PACKAGE_MANIFEST.md`

---

## Phase Overview

### Legacy Phase Track (Phases 0–5 — iOS Widget + Stability)

| Phase | Name | Status |
|-------|------|--------|
| Phase 0 | Project stabilization + iOS widget scaffolding | ✅ Complete |
| Phase 1 | Core workflow fixes (crashes, error handling, locale) | ✅ Complete |
| Phase 2 | Task interactive iOS widget | ✅ Complete |
| Phase 3 | Habit interactive iOS widget | ✅ Complete |
| Phase 4 | Hardening + edge cases + prayer widget polish | ✅ Complete |
| Phase 5 | Device validation + release readiness | 🔲 Pending (physical device required) |

### v2 Design System PR Track

> PRs are **logical migration checkpoints** on `feat/athar-v2-pr1-tokens-theme`, not immediate merges to `main`.  
> `main` stays at `32e59c3` until full migration + QA is complete. See `MIGRATION_BRANCH_STRATEGY.md`.

| # | PR | Name | Status | Tag | Blocker |
|---|----|----- |--------|-----|---------|
| 1 | **PR1** | Tokens & Theme — green palette, Calibri, dark surfaces | ✅ Complete | `athar-v2-pr1-complete` | — |
| 2 | **PR-THEME** | `app.dart:172` `ThemeMode.light` → `ThemeMode.system`; `darkModeDesc` subtitle added | ✅ Complete | `athar-v2-prtheme-complete` | — |
| 2b | **PR-THEME-3MODE** | `ThemePreference` enum + migration + 3-option picker; supersedes 2-state toggle; architecture stabilized | ✅ Complete | `athar-v2-prtheme-3mode-complete` | — |
| 3 | **PR2** | AdaptiveShell rename + iPad breakpoints + 4-tab nav + FAB pill | 🟡 Ready to implement | — | All 4 spec files read; see PR2_FINAL_READINESS_REPORT.md + PR2_IMPLEMENTATION_PLAN.md |
| 4 | **PR3** | Prayer card refresh (`PRAYER_CARD_SPEC.md`) | 🔲 Not started | — | PR2 |
| 5 | **PR-ADHAN** | Bundle `adhan.mp3` + `adhan.caf`; build gate if absent | 🔲 Not started | — | Asset from designer |
| 6 | **PR4a** | Calendar visual refresh + `CalendarCubit` 4-source fan-in | 🔲 Not started | — | PR2 |
| 7 | **PR4b** | Calendar dual-display (`DualDate` VO + `CalendarCell` + `DualMonthSwitcher`) | 🔲 Not started | — | PR4a + spec |
| 8 | **PR5** | Settings: Accessibility section (Reduce Motion, Gyroscope, Eastern Numerals) | 🔲 Not started | — | PR2 |
| 9 | **PR6** | Stats redesign (`STATS_KPI_SPEC.md`) | 🔲 Not started | — | PR2 |
| 10 | **PR7** | Athkar feature net-new (curated sets v1; designer review before screens) | 🔲 Not started | — | PR2 + designer |
| 11 | **PR8** | Focus screen oil-fill (`FOCUS_OIL_SPEC.md`; procedural colour carve-out) | 🔲 Not started | — | PR2 |
| 12 | **PR9** | iOS widgets visual refresh (infra complete; visuals only) | 🔲 Not started | — | PR2 |
| 13 | **PR-ONBOARD-AB** | Four-variant onboarding A/B/C/D; Variant A must not regress | 🔲 Not started | — | PR2 + designer |
| 14 | **PR-CLEANUP** | Hardcoded colour sweep (files untouched by other PRs) | 🔲 Not started | — | All others |

**Total PRs:** 14 (+ PR-THEME-3MODE as 2b) · **Complete:** 3 · **Ready:** 1 (PR2) · **Blocked:** 11

---

## Completion Percentages

| Dimension | Complete | Total | % |
|-----------|---------|-------|---|
| v2 Design System PRs | 1 | 14 | **7%** |
| Design system token migration | ✅ Foundation layer done | Component + screen migration pending | ~5% |
| Typography migration | Tokens updated | Component-level `.arabic`/`.english` callsites still use Cairo/Inter in some files | ~10% |
| Dark-mode migration | Tokens correct + `ThemeMode.system` wired (PR-THEME ✅) | Component-level migration pending (PR2+) | ~50% |
| Component library | 0 components migrated | PR2+ | 0% |
| iOS widget visual refresh | 0 | PR9 | 0% |

---

## Current Blocker List

| ID | Description | Severity | Blocks |
|----|-------------|----------|--------|
| B1 | **Calibri App Store licence** — designer must confirm before submission | Medium | App Store submission only (not dev/build) |
| B2 | Dark secondary gradient variants not in CSS spec | Low | Dark mode secondary gradient in PR-THEME or later |
| B3 | Calendar dual-display requires dedicated designer spec | Medium | PR4b |
| B4 | ~~`isAutoModeEnabled` settings UI unknown~~ | **Closed** | DRIFT-6: field is Smart Zones only; PR-THEME used `isDarkMode` + `ThemeMode.system` |
| B5 | ~~Dark surface token conflict~~ | **Closed** | Resolved: `THEME_DARK_SPEC.md` adopted as canonical |

---

## Accepted Risks

| Risk | Accepted On | Note |
|------|------------|------|
| Calibri added without App Store licence confirmation | 2026-05-08 | Font is functional; licence is a submission gate. Designer confirmation required before first Calibri-font TestFlight submission. |
| Cairo/Inter font families remain in `pubspec.yaml` | 2026-05-09 | Intentional — old font assets stay until PR-CLEANUP sweeps all remaining callsites. Unused fonts add ~350KB to the bundle temporarily. |
| Dark surfaces use `THEME_DARK_SPEC.md` values | 2026-05-08 | Accepted over `colors_and_type.css` values due to design intent. Documented in DRIFT-2 log. |

---

## Deferred Risks (Not Yet Accepted)

| Risk | Notes | When to address |
|------|-------|----------------|
| Prayer card gradient in dark mode | `prayerCardGradient` is `[0xFF1E293B, 0xFF0F172A]` — navy, not green. Intentional, but hasn't been reviewed against the new dark background (`0xFF0E1714`). | PR3 (prayer card refresh) |
| `oil_animation.dart` / `fluid_engine.dart` procedural colours | Not yet migrated to tokens. Designer review required before migration. | PR8 |
| Athkar widget rows are read-only | No `Button(intent:...)` in Athkar rows — by design. Verify this is still the correct decision when PR7 ships. | PR7 |
| Android widgets | 4 widget types exist; no v2 visual refresh planned yet. | After PR9 |

---

## Dangerous Future PRs

| PR | Risk | Why dangerous |
|----|------|--------------|
| **PR4b** | High | Calendar rebuild requires `DualDate` value object, new `CalendarCell`, and `DualMonthSwitcher`. Hijri/Gregorian dual display is a significant state change in `CalendarCubit`. Requires designer spec sign-off. |
| **PR7** | High | Athkar is a net-new feature. Wrong scoping could accidentally merge Athkar into the habits domain. Must gate on designer spec + `isAthkarEnabled` flag. |
| **PR8** | Medium | `oil_animation.dart` + `fluid_engine.dart` use procedural colours. Migrating to tokens without designer review could change the animation feel. |
| **PR-ONBOARD-AB** | Medium | Four-variant A/B/C/D onboarding requires strict non-regression on Variant A until the experiment ships. |

---

## Recommended Next PR

**PR-THEME** — `isAutoModeEnabled` dark mode wiring.

**Why next:**
- No blockers
- Small scope: `app.dart` lines 162–172 only
- Unblocks PR2 (AdaptiveShell) which unblocks everything else
- Dark tokens are now correct (PR1 complete) — wiring them is the logical next step

**Before starting PR-THEME:**
- Read `IMPLEMENTATION_EXECUTION_PLAN.md` § PR-THEME
- Confirm `UserSettings.isAutoModeEnabled` field path in the settings repository
- Verify B4: which settings UI control drives `isAutoModeEnabled`

---

## Highest-Risk Remaining Phase

**PR4b — Calendar dual-display rebuild.**

Requires creating new value objects, a new widget component, and a `CalendarCubit` extension while keeping the existing Hijri/Gregorian toggle. No designer spec exists yet. This PR must not start until `CALENDAR_FOCUS_REDESIGN.md` is read and designer sign-off is obtained.

---

## Handoff Authority Reference

| Document | Purpose | Status |
|----------|---------|--------|
| `handoff_v2-2/CLAUDE_CODE_PROMPT.md` | Full implementation rules; PR sequence authority | ✅ Read |
| `handoff_v2-2/FINAL_PACKAGE_MANIFEST.md` | Canonical PR sequence + changelog | ✅ Read |
| `handoff_v2-2/INVESTIGATION_RECONCILIATION.md` | 5 locked decisions (C1–C5) | ✅ Read |
| `handoff_v2-2/DESIGN_SYSTEM_GAP_VALIDATION.md` | Typography authority lockdown | ✅ Read |
| `handoff_v2-2/PACKAGE_A_DECISIONS.md` | Calibri, isHijriMode, AdaptiveShell, Stats | ✅ Read |
| `handoff_v2-2/PACKAGE_C_DECISIONS.md` | Dark mode, 4-tab, calendar, Athkar, bottom-nav | ✅ Read |
| `handoff_v2-2/THEME_DARK_SPEC.md` | Per-surface dark treatments | ✅ Read |
| `handoff_v2-2/colors_and_type.css` | Canonical token target (light + dark) | ✅ Read |
| `handoff_v2-2/INVESTIGATION_REPORT.md` | Full codebase investigation | ✅ Read (2026-05-09) — PR2 readiness closure |
| `handoff_v2-2/REDESIGN_AUDIT.md` | Component audit | ✅ Read (2026-05-09) — PR2 readiness closure |
| `handoff_v2-2/CALENDAR_FOCUS_REDESIGN.md` | Calendar dual-display spec | ❌ Not read — required before PR4a/PR4b |
| `handoff_v2-2/FOCUS_OIL_SPEC.md` | Focus oil-fill animation spec | ❌ Not read — required before PR8 |
| `handoff_v2-2/IPAD_OPTIMIZATION.md` | iPad breakpoints | ✅ Read (2026-05-09) — PR2 readiness closure |
| `handoff_v2-2/ONBOARDING_AB_SPEC.md` | Onboarding A/B variants | ❌ Not read — required before PR-ONBOARD-AB |

---

## Token Authority (Post-PR1)

| Token group | Canonical source |
|-------------|----------------|
| Light primary/secondary | `handoff_v2-2/colors_and_type.css` |
| Light surfaces/text | `handoff_v2-2/colors_and_type.css` |
| Dark primary/secondary | `handoff_v2-2/colors_and_type.css` |
| Dark surfaces/text | `handoff_v2-2/THEME_DARK_SPEC.md` (overrides CSS — DRIFT-2 decision) |
| Typography (font families) | `handoff_v2-2/DESIGN_SYSTEM_GAP_VALIDATION.md` (Calibri sole canonical) |
| Prayer card gradient | `athar_colors.dart` static const — must not change |

---

## Security Review Status

- **PR1 security review:** Complete (`SECURITY_REVIEW_DEEP_PR1.md`)
- **Findings:** No security issues. Token changes are UI-only values; font files are static assets; no secrets, no API calls, no permissions changes.
- **Calibri licence note:** Confirmed in security review — requires App Store licence verification (B1).
