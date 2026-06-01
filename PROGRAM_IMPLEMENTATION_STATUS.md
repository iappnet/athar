# Program Implementation Status — Athar v2 Design System Migration

**Last updated:** 2026-06-01  
**SSOT pointer:** Roadmap, PR ordering, and completion % live in `IMPLEMENTATION_MASTER_STATUS.md` only. This file contains risk analysis and architectural guidance only.

**Program:** Athar v2 Design System — Full Flutter Migration  
**Canonical handoff:** `handoff_v2-2/`  
**Canonical migration branch:** `feat/athar-v2-pr1-tokens-theme` ← long-running; do NOT merge to `main` until migration complete  
**main:** stable legacy baseline at `32e59c3` — no touches until migration merge gate  
**Roadmap verification:** `MIGRATION_ROADMAP_VERIFICATION.md` (verified 2026-05-09; 8 discrepancies corrected)  
**Branch strategy:** `MIGRATION_BRANCH_STRATEGY.md`  
**Authoritative PR sequence:** `handoff_v2-2/CLAUDE_CODE_PROMPT.md` + `handoff_v2-2/FINAL_PACKAGE_MANIFEST.md`

---

## 1. Full Implementation Roadmap

> **Roadmap and PR ordering live in `IMPLEMENTATION_MASTER_STATUS.md` (SINGLE SOURCE OF TRUTH). Do not restate PR statuses or ordering here.**

---

## 2. Current Implementation Progress

> **PR status lives in `IMPLEMENTATION_MASTER_STATUS.md` (SINGLE SOURCE OF TRUTH). Do not restate PR statuses here.**

**In-progress phases:** None — clean state between PRs  
**Deferred phases:** Phase 5 (device-gated, not code-gated)  
**Last completed PR:** PR4a (`athar-v2-pr4a-complete`) · 2 device-QA gates in Deferred QA Bucket  
**Ready to start:** PR5, PR6, PR8, PR9 (all unblocked by PR2 ✅)

---

## 3. Completion Percentages

> **Completion % lives in `IMPLEMENTATION_MASTER_STATUS.md` (SINGLE SOURCE OF TRUTH). Do not restate % figures here.**

---

## 4. Remaining Work Summary

### Remaining PRs (10 of 14)

| PR | Estimated complexity | Key risk |
|----|---------------------|----------|
| PR-ADHAN | Low | Asset dependency only |
| ~~PR4a~~ | ~~Medium~~ | ~~CalendarCubit extension~~ — **COMPLETE** (`athar-v2-pr4a-complete`) |
| PR4b | Very high | Net-new value objects + dual-display state |
| ~~PR5~~ | ~~Low~~ | ~~New settings section~~ — **COMPLETE** (`6154565`) |
| ~~PR6~~ | ~~Medium~~ | ~~Stats redesign~~ — **COMPLETE** (`2a6a46a`) |
| PR7 | High | Net-new feature, Athkar domain isolation |
| PR8 | Medium | Procedural colours need designer review first |
| PR9 | Low-Medium | Widget visual only, infra stable |
| PR-ONBOARD-AB | High | Must not regress Variant A |
| PR-CLEANUP | Medium | 153+ files with hardcoded colours |

### Remaining Risky Migrations

1. **Calendar dual-display (PR4b)** — requires new architecture (`DualDate`, `CalendarCell`, `DualMonthSwitcher`) layered onto an existing cubit. No designer spec yet.
2. **Athkar net-new (PR7)** — must stay isolated from the habits domain. Architectural boundary is fragile.
3. **Onboarding A/B (PR-ONBOARD-AB)** — four variants active simultaneously; Variant A regression is a real risk.
4. **Hardcoded colour sweep (PR-CLEANUP)** — 35 files with `Color(0xFF...)` + 118 files with `Colors.*`. Mechanical sweep across 153 files is high surface area for subtle regressions.

### Remaining Blockers

| ID | Description | What it unblocks |
|----|-------------|-----------------|
| B1 | Calibri App Store licence — designer confirmation | App Store / TestFlight submission |
| B2 | ~~`isAutoModeEnabled` → `ThemeMode` not wired~~ | **Closed** — `ThemePreference` enum wired (PR-THEME-3MODE) |
| B3 | Calendar dual-display spec not written | PR4b |
| B4 | Adhan audio asset not received from designer | PR-ADHAN |
| Phase 5 | Physical device required for widget validation | Device-gated, not code-gated |
| 3 unread handoff docs | `CALENDAR_FOCUS_REDESIGN.md`, `FOCUS_OIL_SPEC.md`, `ONBOARDING_AB_SPEC.md` | PR4b, PR8, PR-ONBOARD-AB |

### Remaining Architecture Work

| Area | Work needed | PR |
|------|-------------|-----|
| `DualDate` value object | New Hijri+Gregorian compound date type | PR4b |
| `CalendarCell` widget | New widget accepting `DualDate` | PR4b |
| `DualMonthSwitcher` | New month navigation widget | PR4b |
| Athkar domain isolation | New `lib/features/dhikr/` sub-feature or extension | PR7 |
| `isAthkarEnabled` flag | New `UserSettings` boolean | PR7 |
| Accessibility settings | `reduceMotion`, `disableGyroscope`, `useEasternNumerals` in `UserSettings` | PR5 |

### Remaining UX Validation Work

| Area | What must be validated | When |
|------|----------------------|------|
| Font switch Cairo → Calibri | Visual regression on all text-heavy screens | Device QA (post-merge) |
| Dark mode surfaces | Green-tinted dark surfaces in correct app contexts | Device QA (post-merge) |
| Nav bar shape RTL | FAB pill position in RTL vs LTR | Device QA (post-merge) |
| Prayer card forest gradient | Four-level toggle hierarchy still intact; forest dark on device | Device QA (post-merge) |
| Calendar dual-display | Hijri primary + Gregorian secondary in RTL | After PR4b |
| Onboarding Variant A | No regression after PR-ONBOARD-AB | After PR-ONBOARD-AB |

### Remaining QA Work

| Area | Tests needed | When |
|------|-------------|------|
| iOS widget interactive taps (Phase 5) | Physical device — all three widgets | Now (device-gated) |
| Dark mode ThemeMode switching | Verify light ↔ dark ↔ system all paths | After PR-THEME |
| Stats numericMono rendering | Tabular figures, Arabic-Indic option | After PR6 |
| Calendar Hijri/Gregorian toggle | No state loss on toggle | After PR4a |
| Dual-display simultaneous | Both numeral systems visible at same time | After PR4b |
| Onboarding A/B variant routing | All four variants reachable | After PR-ONBOARD-AB |

---

## 5. Highest-Risk Future Phases

### Risk Rankings

#### Highest Implementation Risk — PR4b (Calendar Dual-Display)

**Why:** Requires creating three new architectural components (`DualDate` value object, `CalendarCell`, `DualMonthSwitcher`) that do not exist anywhere in the codebase. Must be layered onto an existing `CalendarCubit` that currently manages a simpler Hijri/Gregorian toggle. The dual-display spec (`CALENDAR_FOCUS_REDESIGN.md`) has not been read. No designer spec for `DualDate` semantics exists yet. Very high chance of needing a full rework if the spec is misunderstood on the first pass.

**Mitigation:** PR4a (visual refresh first, touch no architecture) before PR4b. Read `CALENDAR_FOCUS_REDESIGN.md` in full before PR4a. Require designer sign-off on `DualDate` spec before PR4b begins.

#### Highest Regression Risk — PR-CLEANUP (Hardcoded Colour Sweep)

**Why:** Touching 153 files across all features in a single pass is the largest blast radius of any PR in the program. Mechanical colour substitution is error-prone: some `Color(0xFF...)` values are used for opacity calculations, gradients, or procedural effects that are not direct analogues of design tokens. A wrong substitution in a prayer schedule view or focus animation could silently break a feature.

**Mitigation:** PR-CLEANUP is intentionally the last PR. All component PRs run first so patterns are established. Do not do PR-CLEANUP until all other PRs are merged and tested. Review each substitution individually — do not batch-replace blindly.

#### Highest Architecture Risk — PR7 (Athkar Net-New Feature)

**Why:** Athkar currently lives in a grey zone — the domain is in `lib/features/dhikr/` but the presentation (athkar cards, session sheets) bleeds into `lib/features/habits/presentation/`. Adding curated Athkar sets v1 risks blurring this boundary further. If the feature is accidentally merged into the habits domain, the `HabitType.athkar` assumption throughout the codebase becomes wrong.

**Mitigation:** Read `REDESIGN_AUDIT.md` before PR7. Define explicit architectural boundaries in a pre-PR audit document. Gate on `isAthkarEnabled` from day one. Do not touch `habit_cubit.dart` during PR7.

#### Highest UX Risk — PR-ONBOARD-AB (Four-Variant Onboarding)

**Why:** Four simultaneously active onboarding variants increase the failure surface by 4×. Variant A is the production-shipped flow and must remain regression-free while B/C/D are added. The routing logic that assigns users to variants is trivially easy to get wrong (e.g., always routing to Variant B silently). No `ONBOARDING_AB_SPEC.md` has been read, so the variant routing contract is currently unknown.

**Mitigation:** Read `ONBOARDING_AB_SPEC.md` before starting. Write a unit test for the variant routing function before the first line of onboarding UI code. Variant A must be verified against the current `onboarding_page.dart` as a baseline before merging.

---

## 6. Current Project State

### Canonical References

| Reference | Value |
|-----------|-------|
| Canonical branch | `feat/athar-v2-pr1-tokens-theme` |
| Canonical handoff package | `handoff_v2-2/` |
| Approved design authority | `handoff_v2-2/FINAL_PACKAGE_MANIFEST.md` + `CLAUDE_CODE_PROMPT.md` |
| Typography authority | `handoff_v2-2/DESIGN_SYSTEM_GAP_VALIDATION.md` — Calibri sole canonical |
| Light token authority | `handoff_v2-2/colors_and_type.css` |
| Dark-mode surface authority | `handoff_v2-2/THEME_DARK_SPEC.md` (overrides `colors_and_type.css` — DRIFT-2) |
| Dark-mode wiring authority | `ThemePreference` enum (`system`/`light`/`dark`) in `UserSettings`; exhaustive switch in `app.dart` drives `ThemeMode`. `isAutoModeEnabled` field superseded by `ThemePreference` (PR-THEME-3MODE). |
| Implementation token file | `lib/core/design_system/tokens/athar_colors.dart` |
| Implementation typography file | `lib/core/design_system/tokens/athar_typography.dart` |

### Locked Governance Rules

| Rule | Locked | Scope |
|------|--------|-------|
| **RULE 1 — Window-based layout only.** All screen-level layout branching uses `LayoutBuilder(constraints.maxWidth)` or `ShellBreakpoint.fromWidth()`. **Never `ResponsiveHelper.isTablet()`** for layout decisions. Reason: AdaptiveShell is window-based; `ResponsiveHelper` is device-based (`shortestSide`); they disagree in Split View / Stage Manager. | 2026-06-01 | All PRs from PR4a onward |
| **RULE 2 — Layer 2 umbrella tracker only.** `PR-IPAD-LAYER2` is a tracking label, not a mega-PR. Each screen ships its tablet layout in its owning feature PR. `PR-DASHBOARD-TABLET` is a placeholder that MUST be re-evaluated to fold into a future Dashboard redesign PR. No new standalone screen tablet PRs (Tasks/Habits/Spaces) without documented justification. | 2026-06-01 | PR-IPAD-LAYER2 tracking |

---

### Current Accepted Risks

| Risk | Accepted | Reason | Expires when |
|------|----------|--------|-------------|
| Calibri App Store licence unconfirmed | 2026-05-08 | Designer has not confirmed. Font wired for dev; submission gate. | Designer confirms licence |
| Cairo/Inter font families remain in `pubspec.yaml` | 2026-05-09 | 12 files still reference them; cannot remove until all hardcoded refs are swept | PR-CLEANUP merges |
| Dark surfaces use `THEME_DARK_SPEC.md` over `colors_and_type.css` | 2026-05-08 | DRIFT-2: CSS has stale neutral values; THEME_DARK_SPEC.md is the green-tinted design intent | Permanent — confirmed correct |
| `prayerCardGradient` not migrated to new palette | Ongoing | Navy gradient is the intended prayer card look; it must stay navy regardless of brand palette | Until explicit prayer card redesign spec ships |

### Current Deferred Risks

| Risk | Notes | Must address by |
|------|-------|----------------|
| `oil_animation.dart` + `fluid_engine.dart` procedural colours | Not token-driven. Designer review required before migration. | PR8 |
| Prayer card forest gradient on device | PR3 redesigned gradient to forest `[0xFF0F3D2E → 0xFF1A5A45]`. Accepted by golden tests (16/16). Physical device render not yet validated. | Device QA |
| `isHijriMode` setting field | Decision C3 from `INVESTIGATION_RECONCILIATION.md`: field exists. How it interacts with dual-display (PR4b) is unresolved. | PR4b |
| `THEME_DARK_SPEC.md` secondary gradient variants | Not in `colors_and_type.css`. Dark secondary gradient TBD. | PR-THEME or later |
| Android widgets | 4 types exist; no v2 refresh planned yet. | After PR9 |

---

## 7. Recommended Next Step

**PR4a ✅ complete** (`athar-v2-pr4a-complete`). See `ROADMAP_AFTER_PR4A.md` for full next-step guidance and `IMPLEMENTATION_MASTER_STATUS.md` for current PR ordering.

Ready to start (unblocked by PR2 ✅): **PR5, PR6, PR8, PR9.** Recommended lowest-risk: PR5 (no spec read required).

---

## Summary Table

> **All % figures and PR ordering live in `IMPLEMENTATION_MASTER_STATUS.md` (SINGLE SOURCE OF TRUTH).**

| Metric | Value |
|--------|-------|
| **Canonical branch** | `feat/athar-v2-pr1-tokens-theme` |
| **Canonical handoff** | `handoff_v2-2/` |
| **Highest-risk remaining PR** | PR4b (Calendar dual-display) |
| **Active blockers** | B1 (Calibri licence), B3 (calendar dual-display spec), B4 (adhan asset), Phase 5 (device) |
