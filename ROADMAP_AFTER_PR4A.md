# Roadmap After PR4a — Athar v2 Design System

**As of:** 2026-06-01  
**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Authoritative PR sequence:** `IMPLEMENTATION_MASTER_STATUS.md` (SINGLE SOURCE OF TRUTH for order, %, and status)

---

## Completed PRs

| PR | Commit | Tag | Date |
|----|--------|-----|------|
| PR1 — Tokens & Theme | `61d741a` | `athar-v2-pr1-complete` | 2026-05-09 |
| PR-THEME arc (initial + 3MODE + FONT-FALLBACK + FINAL) | `bfaf863` (final) | `athar-v2-prtheme-complete-final` | 2026-06-01 |
| PR2 — AdaptiveShell | `87ab36e` | `athar-v2-pr2-complete` | 2026-05-09 |
| PR3 — Prayer Card Refresh | `1cd4f80` | (in branch) | 2026-06-01 |
| **PR4a — Calendar Visual Refresh** | `85ada1e` | `athar-v2-pr4a-complete` | **2026-06-01** |

---

## Active PR

**None.** Clean state between PRs as of `1beff60`.

---

## Next Recommended PR

**PENDING designer confirmation — not started.**

All of the following are unblocked by PR2 ✅ and can be taken in any order:

| PR | Entry requirement | Risk |
|----|------------------|------|
| PR5 — Accessibility Settings | None | Low |
| PR6 — Stats Redesign | Read `STATS_KPI_SPEC.md` first | Medium |
| PR8 — Focus Oil-Fill | Read `FOCUS_OIL_SPEC.md` first; designer review for procedural colours | Medium |
| PR9 — iOS Widget Visual Refresh | None | Low-Medium |

**Recommended first:** PR5 (lowest risk, no spec read required) or PR9 (no spec, widget infra stable). To confirm, check `IMPLEMENTATION_MASTER_STATUS.md` "Recommended Next PR" section for current guidance.

---

## Blocked PRs

| PR | Blocker |
|----|---------|
| PR4b — Calendar Dual-Display | PR4a ✅ + dedicated `DualDate` designer spec (not yet written). Architecture feasibility question must be answered first — see below. |
| PR-ADHAN | Audio asset from designer (not received) |
| PR7 — Athkar Feature | Designer review required |
| PR-ONBOARD-AB | Designer approval + read `ONBOARDING_AB_SPEC.md` |
| PR-CLEANUP | All other PRs must complete first |

---

## PR4b — Architecture Feasibility + Responsibility Audit (MANDATORY BEFORE ANY PR4b WORK)

Before any PR4b visual or implementation work begins, the PR4b audit MUST answer this question:

> **"Should the existing `CalendarCubit` carry `DualDate` + month-level `activityByDate` + simultaneous Hijri/Gregorian display — or does that overload its single responsibility?"**

### Three options to evaluate

The audit must evaluate all three and **RECOMMEND one with written justification**. No Dart code until the designer approves the chosen option.

**(a) Extend `CalendarCubit`**  
Add `DualDate`, `activityByDate`, and dual-display state to the existing cubit.  
_Pros:_ Simplest — no new cubits, least churn.  
_Cons:_ God-cubit risk — CalendarCubit already owns day selection, month navigation, Hijri/Gregorian toggle, and now activityByDate. Violates SRP if state grows further.  
_When to choose:_ If the dual-display state is a thin display concern only (no async fetch, no business logic beyond conversion).

**(b) New `CalendarMonthCubit` for month-level aggregation**  
Keep `CalendarCubit` for day-selection and navigation. New `CalendarMonthCubit` owns `activityByDate` fan-in (from `TaskCubit` stream + `HabitCubit` stream + prayer times + stats).  
_Pros:_ Clean SRP separation — display state vs. aggregation state. `CalendarCubit` stays lean.  
_Cons:_ Higher cost — new cubit, new state class, new injection config entry. Two cubits for what currently is one.  
_When to choose:_ If `activityByDate` involves merging ≥2 async streams with non-trivial fan-in logic.

**(c) Data/use-case aggregation layer that cubit consumes**  
Introduce a `CalendarAggregationUseCase` (or repository method) that handles multi-source fan-in. `CalendarCubit` calls the use case and gets a ready-made model.  
_Pros:_ Cleanest against existing Clean Architecture — business logic stays in domain layer, cubit stays thin.  
_Cons:_ Most architectural change — new use case, possibly new repository method, new domain model. Highest upfront cost.  
_When to choose:_ If fan-in logic is complex enough to warrant domain-layer testing independently of UI state.

### Audit deliverable

A document at `design-context/_audit_pr4b_architecture.md` must contain:
1. Current `CalendarCubit` state shape (all fields)
2. Enumeration of all state sources that `activityByDate` must aggregate
3. Analysis of each option against the above criteria
4. **Recommendation** with one-sentence justification
5. Designer sign-off confirmation (name + date)

**No Dart changes until designer approves the chosen option.**

---

## Deferred QA Bucket

**Rule:** First real QA sweep occurs **AFTER PR6, BEFORE PR7**.  
**Hard ceiling:** If the bucket reaches **10 items before PR6 ships**, a forced intermediate sweep occurs immediately.

| ID | Description | Origin PR | Candidate fix |
|----|-------------|-----------|--------------|
| PR3-R1 | Forest gradient prayer card — physical device dark mode render | PR3 | Visual verify on device |
| PR3-R2 | 44pt countdown legibility on SE (375×667) | PR3 | Visual verify; font-size adjustment if needed |
| PR4a-G1 | iPhone SE calendar overflow (6-row month at 64pt) | PR4a | Widen compact tier: `width<360` → `width<390` |
| PR4a-G2 | Today-state dark alpha legibility (0.13 on dark surface) | PR4a | Raise alpha: `0.13` → `0.15` |
| DEVICE | Forest-dark surfaces, Cairo fallback, RTL drawer, countdown tick | PR-THEME/PR2 | Visual device pass |

**Current count:** 5 of 10. Ceiling not yet reached.

All fixes in this bucket are **UNVERIFIED** — logical hypotheses that must be confirmed on a physical device before applying. None are "pre-approved."

---

## Open Blockers

| ID | Description | Severity | Blocks |
|----|-------------|----------|--------|
| B1 | Calibri App Store licence — designer must confirm | Medium | App Store submission |
| B3 | `DualDate` / dual-display designer spec | Medium | PR4b |
| B4 | Adhan audio asset (not received) | Low | PR-ADHAN |
| Phase 5 | Physical device validation — all 3 iOS widgets | Release gate | Release |
