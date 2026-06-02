<!--
CANONICAL-FOR: PR sequence, completion %, blockers, accepted risks, token authority, handoff reference table
OWNER:         Claude Code
PRECEDENCE:    3 (Tier 0 — SSOT for PR order + %; CHECKPOINT level 2 wins on "current state")
LAST-UPDATED:  2026-06-02 · governance — all handoff_v2-2/ refs repointed to docs/design-specs/; colors_and_type.css added to mirror
LOADS-AT:      Tier 0
LEGACY-ALIASES: IMPLEMENTATION_MASTER_STATUS.md (root)
CANONICAL-SINCE: 2026-06-01
-->

# Implementation Master Status — Athar v2 Design System

> **CHECKPOINT:** `docs/progress/CHECKPOINT.md` — read this file FIRST on any resume, then verify against `git log`.
>
> **SINGLE SOURCE OF TRUTH** — roadmap + % live here ONLY. Other docs must not restate these numbers.

**Last updated:** 2026-06-02
**Updated by:** PR-DS-ATOMS complete (028f99f) — DS atoms/molecules context.colors + Calibri + RTL

**Branch strategy:** `docs/status/MIGRATION_BRANCH_STRATEGY.md`  
**Canonical handoff package:** `docs/design-specs/` (B2 mirror, read-only)  
**Canonical migration branch:** `feat/athar-v2-pr1-tokens-theme` ← do NOT merge to `main` until migration complete  
**main:** stable legacy baseline at `32e59c3` — do not touch  
**Authoritative sequence:** `docs/design-specs/CLAUDE_CODE_PROMPT.md` + `docs/design-specs/FINAL_PACKAGE_MANIFEST.md`

---

## Phase Overview

### Legacy Phase Track (Phases 0–5 — iOS Widget + Stability)

| Phase | Name | Status |
| ------- | ------ | -------- |
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
| --- | ---- | ----- | -------- | ----- | --------- |
| 1 | **PR1** | Tokens & Theme — green palette, Calibri, dark surfaces | ✅ Complete | `athar-v2-pr1-complete` | — |
| 2 | **PR-THEME** | `ThemeMode.system` wiring + `ThemePreference` enum + 3-mode picker + PR-FONT-FALLBACK + wire `AtharLightTheme`/`AtharDarkTheme` + 88 fontFamilyFallback + RTL drawer | ✅ **Complete 2026-06-01** | `athar-v2-prtheme-complete-final` | — |
| 2b | **PR-FONT-FALLBACK** | Cairo fallback on all 38 `AtharTypography` base styles + 3 extensions | ✅ Complete | — (part of PR-THEME arc) | — |
| 3 | **PR2** | AdaptiveShell rename + iPad breakpoints + 4-tab nav + FAB pill | ✅ Complete | `athar-v2-pr2-complete` | — |
| 4 | **PR3** | Prayer card refresh — forest gradient, 44px countdown, calm states, 16/16 goldens | ✅ **Complete 2026-06-01** | — | — |
| 5 | **PR-ADHAN** | Bundle `adhan.mp3` + `adhan.caf`; build gate if absent | 🔲 Not started | — | Asset from designer |
| 6 | **PR4a** | Calendar visual refresh — tokens, RULE 1, today state, RTL | ✅ **Complete 2026-06-01** | `athar-v2-pr4a-complete` | — |
| 7 | **PR4b** | Calendar dual-display (`DualDate` VO + `CalendarCell` + `DualMonthSwitcher`) | ✅ **Complete 2026-06-01** | `65fc417` | — |
| 8 | **PR5** | Settings: Accessibility section (Reduce Motion, Gyroscope, Eastern Numerals) | ✅ **Complete 2026-06-01** | `6154565` | — |
| 9 | **PR6** | Stats redesign (`STATS_KPI_SPEC.md`) | ✅ **Complete 2026-06-01** | `2a6a46a` | — |
| 10 | **PR7** | Athkar feature net-new (curated sets v1; designer review before screens) | ✅ **Complete 2026-06-02** | `0b8fe34` | — |
| 11 | **PR8** | Focus screen oil-fill (`FOCUS_OIL_SPEC.md`; procedural colour carve-out) | ✅ **Complete 2026-06-02** | `2b10844` | — |
| 12 | **PR9** | iOS widgets visual refresh (infra complete; visuals only) | ✅ **Complete 2026-06-02** | — | — |
| 13 | **PR-ONBOARD-AB** | Four-variant onboarding A/B/C/D; Variant A must not regress | ✅ **Complete 2026-06-02** · INFRA `1f868f9` · UI `729c23d` | — | — |
| 14 | **PR-CLEANUP** | Hardcoded colour sweep (files untouched by other PRs) | 🔲 Not started | — | All others |

**Total PRs:** 14 (+ PR-FONT-FALLBACK as 2b) · **Complete:** 12 logical (PR1, PR-THEME arc incl PR-FONT-FALLBACK, PR2, PR3, PR4a, PR4b, PR5, PR6, PR7, PR8, PR9, PR-ONBOARD-AB) · **Blocked:** 2 (PR-ADHAN needs audio asset; PR-CLEANUP needs all others first)

---

## UI Coverage Refresh PRs — Required Before App Store Submission

> **UI design-system coverage: 24% (36/151 surfaces) — source: `design-context/_audit_ui_coverage.md` (2026-06-02)**
>
> These 8 PRs are additive to the 14-PR feature track above. They address the long tail of UI surfaces (dialogs, shared components, per-feature screens) not covered by any existing PR scope. All are **required before any App Store or external TestFlight submission** — see REL-1 in `docs/ai/KNOWN_PROBLEMS.md`.

| # | PR | Name | Status | Blocker |
| --- | ---- | ----- | -------- | --------- |
| 15 | **PR-DS-ATOMS** | App bar + legacy design-system atoms — cross-cutting | ✅ **Complete 2026-06-02** · `028f99f` | — |
| 16 | **PR-TASK-REFRESH** | Task feature UI design-system refresh | ✅ **Complete 2026-06-02** · `a1f28e0` | — |
| 17 | **PR-HABITS-REFRESH** | Habits feature UI design-system refresh | 🔲 Not started | PR-DS-ATOMS |
| 18 | **PR-HEALTH-REFRESH** | Health feature UI design-system refresh | 🔲 Not started | PR-DS-ATOMS |
| 19 | **PR-SPACE-REFRESH** | Space feature UI design-system refresh | 🔲 Not started | PR-DS-ATOMS |
| 20 | **PR-SETTINGS-REFRESH** | Settings feature UI design-system refresh | 🔲 Not started | PR-DS-ATOMS |
| 21 | **PR-PRAYER-DETAILS** | Prayer details screens UI design-system refresh | 🔲 Not started | PR-DS-ATOMS |
| 22 | **PR-SPLASH-ONBOARD-A** | Splash + Onboarding Variant A UI design-system refresh | 🔲 Not started | PR-DS-ATOMS |

---

## Completion Percentages

| Dimension | Complete | Total | % |
|-----------|---------|-------|---|
| Feature PRs complete (14-PR roadmap) | 12 (PR1, PR-THEME arc, PR2, PR3, PR4a, PR4b, PR5, PR6, PR7, PR8, PR9, PR-ONBOARD-AB) | 14 | **~86%** |
| UI surface coverage | 36 of 151 surfaces conformant — source: `design-context/_audit_ui_coverage.md` 2026-06-02 | 151 | **24%** |
| Design system token migration | ✅ Foundation done; design system themes now live in app | Component + screen migration pending | ~20% |
| Typography migration | Tokens + 88 theme fallbacks + 38 base styles — all correct | Component `.arabic`/`.english` callsites still use Cairo in some files | ~25% |
| Dark-mode migration | Tokens ✅ + ThemeMode ✅ + AtharDarkTheme now wired ✅ | Component-level color migration pending (PR5+) | ~70% |
| Component library | Prayer card (PR3 ✅) · Calendar refresh (PR4a ✅) | AdaptiveShell (PR2 ✅) + stats, focus, Athkar, widget visuals pending | ~25% |
| iOS widget visual refresh | Prayer ✅ · Habit ✅ · Task ✅ (token-only) | PR9 complete | 100% |

---

## Current Blocker List

| ID | Description | Severity | Blocks |
|----|-------------|----------|--------|
| B1 | **Calibri App Store licence** — designer must confirm before submission | Medium | App Store submission only (not dev/build) |
| B2 | Dark secondary gradient variants not in CSS spec | Low | Dark mode secondary gradient in PR-THEME or later — **part of REL-1** (dark mode launch requirement; must resolve before store submission) |
| ~~B3~~ | ~~Calendar dual-display requires dedicated designer spec~~ | **Closed** | PR4b shipped `65fc417` |
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
| ~~`oil_animation.dart` / `fluid_engine.dart` procedural colours~~ | **Closed** — both files deleted in PR8 (`2b10844`); replaced by procedural `oil_simulator.dart` with §7 file-private consts | ~~PR8~~ |
| Athkar widget rows are read-only | No `Button(intent:...)` in Athkar rows — by design. Verify this is still the correct decision when PR7 ships. | PR7 |
| Android widgets | 4 widget types exist; no v2 visual refresh planned yet. | After PR9 |

---

## Dangerous Future PRs

| PR | Risk | Why dangerous |
|----|------|--------------|
| ~~**PR4b**~~ | ~~High~~ | ✅ **Complete** (`65fc417`) — `DualDate` VO, `CalendarMonthCubit`, 5-source activity dots, Hijri boundary labels shipped. |
| **PR7** | High | Athkar is a net-new feature. Wrong scoping could accidentally merge Athkar into the habits domain. Must gate on designer spec + `isAthkarEnabled` flag. |
| ~~**PR8**~~ | ~~Medium~~ | ✅ **Complete** (`2b10844`) — `oil_animation.dart` + `fluid_engine.dart` deleted; replaced by `oil_simulator.dart` + `oil_background.dart` with §7 file-private consts. Designer-review gate cleared. |
| **PR-ONBOARD-AB** | Medium | Four-variant A/B/C/D onboarding requires strict non-regression on Variant A until the experiment ships. |

---

## Recommended Next PR

**PR-TASK-REFRESH ✅ complete.** `a1f28e0` — context.colors + Calibri + RTL on 20 task-feature files. 2/8 UI Coverage Refresh PRs done (PR-DS-ATOMS + PR-TASK-REFRESH).

**Remaining (feature track):**

| PR | Status | Blocker |
|----|--------|---------|
| **PR-ADHAN** | Not started | Audio asset delivery from designer (B4 open) |
| **PR-CLEANUP** | Not started | Must run after all other PRs complete |

**Remaining (UI coverage refresh):**

| PR | Status | Blocker |
|----|--------|---------|
| **PR-TASK-REFRESH** | ✅ Complete `a1f28e0` | — |
| **PR-HABITS-REFRESH** | Not started | — |
| **PR-HEALTH-REFRESH** | Not started | — |
| **PR-SPACE-REFRESH** | Not started | — |
| **PR-SETTINGS-REFRESH** | Not started | — |
| **PR-PRAYER-DETAILS** | Not started | — |
| **PR-SPLASH-ONBOARD-A** | Not started | — |

**Next:** PR-HABITS-REFRESH. See `docs/status/NEXT_STEPS.md` for next-arc guidance.

---

## Highest-Risk Remaining Phase

~~**PR-ONBOARD-AB — complete** (`729c23d`). Variants B/C/D pages + ARB + analytics wiring. Variant A untouched. ONBOARD-sweep device QA in deferred bucket.~~

**Next highest-risk:** PR-CLEANUP — hardcoded colour sweep across 88 files. Must run last.

~~**PR9 — complete** (`4718207`). Prayer+Habit+Task widget v2 refresh: forest palette, Calibri, prayer systemLarge, ring+7-day habit history, isPrayerEnabled gate, sunrise/sunset strip.~~  
~~**PR8 — complete** (`2b10844`). Focus oil-fill: procedural fluid sim, 4-band intensity tiers, gyro slosh, impact bubbles. `oil_animation.dart` + `fluid_engine.dart` deleted.~~  
~~**PR7 — complete** (`0b8fe34`). AthkarSetScreen, DhikrReaderScreen (focus+list), Dashboard card, DhikrComplete chokepoint, Settings reminders, 4 Athkar category tokens.~~  
~~**PR4b — complete** (`65fc417`). DualDate VO, CalendarMonthCubit, 5-source activity dots, Hijri boundary labels.~~

---

## Handoff Authority Reference

| Document | Purpose | Status |
|----------|---------|--------|
| `docs/design-specs/CLAUDE_CODE_PROMPT.md` | Full implementation rules; PR sequence authority | ✅ Read |
| `docs/design-specs/FINAL_PACKAGE_MANIFEST.md` | Canonical PR sequence + changelog | ✅ Read |
| `docs/design-specs/INVESTIGATION_RECONCILIATION.md` | 5 locked decisions (C1–C5) | ✅ Read |
| `docs/design-specs/DESIGN_SYSTEM_GAP_VALIDATION.md` | Typography authority lockdown | ✅ Read |
| `docs/design-specs/PACKAGE_A_DECISIONS.md` | Calibri, isHijriMode, AdaptiveShell, Stats | ✅ Read |
| `docs/design-specs/PACKAGE_C_DECISIONS.md` | Dark mode, 4-tab, calendar, Athkar, bottom-nav | ✅ Read |
| `docs/design-specs/THEME_DARK_SPEC.md` | Per-surface dark treatments | ✅ Read |
| `docs/design-specs/colors_and_type.css` | Canonical token target (light + dark) | ✅ Read |
| `docs/design-specs/INVESTIGATION_REPORT.md` | Full codebase investigation | ✅ Read (2026-05-09) — PR2 readiness closure |
| `docs/design-specs/REDESIGN_AUDIT.md` | Component audit | ✅ Read (2026-05-09) — PR2 readiness closure |
| `CALENDAR_FOCUS_REDESIGN.md` | Calendar dual-display spec (root copy) | ✅ Read — PR4b complete |
| `docs/design-specs/FOCUS_OIL_SPEC.md` | Focus oil-fill animation spec | ✅ Read — PR8 complete (`2b10844`) |
| `docs/design-specs/IPAD_OPTIMIZATION.md` | iPad breakpoints | ✅ Read (2026-05-09) — PR2 readiness closure |
| `docs/design-specs/ONBOARDING_AB_SPEC.md` | Onboarding A/B variants | ✅ Read — INFRA complete; UI PR pending OQ1 |

---

## Token Authority (Post-PR1)

| Token group | Canonical source |
|-------------|----------------|
| Light primary/secondary | `docs/design-specs/colors_and_type.css` |
| Light surfaces/text | `docs/design-specs/colors_and_type.css` |
| Dark primary/secondary | `docs/design-specs/colors_and_type.css` |
| Dark surfaces/text | `docs/design-specs/THEME_DARK_SPEC.md` (overrides CSS — DRIFT-2 decision) |
| Typography (font families) | `docs/design-specs/DESIGN_SYSTEM_GAP_VALIDATION.md` (Calibri sole canonical) |
| Prayer card gradient | `athar_colors.dart` static const — must not change |

---

## Security Review Status

- **PR1 security review:** Complete (`SECURITY_REVIEW_DEEP_PR1.md`)
- **Findings:** No security issues. Token changes are UI-only values; font files are static assets; no secrets, no API calls, no permissions changes.
- **Calibri licence note:** Confirmed in security review — requires App Store licence verification (B1).
