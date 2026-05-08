# Program Implementation Status — Athar v2 Design System Migration

**Last updated:** 2026-05-09  
**Program:** Athar v2 Design System — Full Flutter Migration  
**Canonical handoff:** `handoff_v2-2/`  
**Canonical branch:** `feat/athar-v2-pr1-tokens-theme`  
**Authoritative PR sequence:** `handoff_v2-2/CLAUDE_CODE_PROMPT.md` + `handoff_v2-2/FINAL_PACKAGE_MANIFEST.md`

---

## 1. Full Implementation Roadmap

### Track A — App Stability & iOS Widgets (Legacy Phases 0–5)

| Phase | Name | Purpose | Status | Depends on |
|-------|------|---------|--------|------------|
| Phase 0 | Project Stabilization | iOS 17 target, entitlements, stale scaffold cleanup, locale defaults | ✅ Complete | — |
| Phase 1 | Core Workflow Fixes | HealthError crash, TaskError handling, HabitError handling, prayer widget v5 payload, language switching | ✅ Complete | Phase 0 |
| Phase 2 | Task Interactive Widget | `AtharTaskWidget.swift` → `AppIntentConfiguration`; `ToggleTaskIntent`; pending-action queue | ✅ Complete | Phase 1 |
| Phase 3 | Habit Interactive Widget | `AtharHabitWidget.swift` → `AppIntentConfiguration`; `CompleteHabitIntent` + `IncrementHabitIntent`; count-based progress | ✅ Complete | Phase 2 |
| Phase 4 | Hardening + Edge Cases | Safe UUID fallback; parity dedup; prayer window state; colour normalisation across 3 widgets | ✅ Complete | Phase 3 |
| Phase 5 | Device Validation | Physical device: interactive widget taps, locale switching, cold-start action replay, TestFlight checklist | 🔲 Pending | Physical device |

### Track B — v2 Design System PRs

| PR | Name | Purpose | Status | Depends on | Blockers |
|----|------|---------|--------|------------|---------|
| **PR1** | Tokens & Theme | Green brand palette (light + dark); Calibri font; `numericMono` TextStyle; dark surface tokens per `THEME_DARK_SPEC.md` | ✅ **Complete** `61d741a` | — | — |
| **PR-THEME** | Auto Dark Mode Wiring | Wire `UserSettings.isAutoModeEnabled` → `ThemeMode` in `app.dart:162–172` | 🟡 Ready | PR1 ✅ | None |
| **PR2** | AdaptiveShell | Rename `adaptive_scaffold` → `adaptive_shell`; iPad breakpoints; 4-tab nav bar shape; FAB pill outside bar (RTL/LTR) | 🔲 Not started | PR-THEME | Must read: `IPAD_OPTIMIZATION.md`, `REDESIGN_AUDIT.md`, `preview/comp-nav.html` |
| **PR3** | Prayer Card Refresh | Visual redesign per `PRAYER_CARD_SPEC.md`; four-level toggle must not regress | 🔲 Not started | PR2 | `PRAYER_CARD_SPEC.md` must be read |
| **PR-ADHAN** | Audio Asset Bundle | Bundle `adhan.mp3` / `.caf`; build gate for existing player | 🔲 Not started | Asset from designer | Asset not yet received |
| **PR4a** | Calendar Visual Refresh | Update calendar chrome, colours, typography; keep existing Hijri/Gregorian toggle; extend `CalendarCubit` | 🔲 Not started | PR2 | Must read: `CALENDAR_FOCUS_REDESIGN.md` |
| **PR4b** | Calendar Dual-Display Rebuild | Net-new: `DualDate` value object + `CalendarCell` + `DualMonthSwitcher`; simultaneous Hijri + Gregorian numerals | 🔲 Not started | PR4a + designer spec | Dedicated designer spec not yet written |
| **PR5** | Accessibility Settings | New section: Reduce Motion, Disable Gyroscope, Eastern Numerals toggles | 🔲 Not started | PR2 | None |
| **PR6** | Stats Redesign | New KPI layout per `STATS_KPI_SPEC.md`; adopt `numericMono` | 🔲 Not started | PR2 | `STATS_KPI_SPEC.md` must be read |
| **PR7** | Athkar Feature (Net-New) | New curated Athkar sets v1; `isAthkarEnabled` gate; must not merge into habits domain | 🔲 Not started | PR2 + designer review | Designer review required; `REDESIGN_AUDIT.md` unread |
| **PR8** | Focus Oil-Fill Animation | Oil-fill screen per `FOCUS_OIL_SPEC.md`; procedural colours must be reviewed before token migration | 🔲 Not started | PR2 | Must read: `FOCUS_OIL_SPEC.md`; designer review for `oil_animation.dart` colours |
| **PR9** | iOS Widget Visual Refresh | Visual-only update of all 3 iOS widgets to v2 design (infra and interactions already complete) | 🔲 Not started | PR2 | None |
| **PR-ONBOARD-AB** | Onboarding A/B/C/D | Four-variant onboarding experiment; Variant A must not regress until experiment ships | 🔲 Not started | PR2 + designer approval | Must read: `ONBOARDING_AB_SPEC.md`; designer approval required |
| **PR-CLEANUP** | Hardcoded Colour Sweep | Migrate remaining ~35 `Color(0xFF...)` and ~118 `Colors.*` callsites to design tokens | 🔲 Not started | All others | Cannot start until all component PRs are merged |

---

## 2. Current Implementation Progress

### Track A — Stability & Widgets

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 0 | ✅ Complete | Stable iOS target, clean entitlements |
| Phase 1 | ✅ Complete | All crashes fixed, language switching working |
| Phase 2 | ✅ Complete | Task widget fully interactive |
| Phase 3 | ✅ Complete | Habit widget fully interactive |
| Phase 4 | ✅ Complete | All edge cases hardened |
| **Phase 5** | 🔲 **Pending** | Requires physical device — no simulator support for `AppIntent` |

### Track B — v2 Design System PRs

| PR | Status |
|----|--------|
| PR1 | ✅ Complete |
| PR-THEME | 🟡 Ready — no blockers |
| PR2 | 🔲 Blocked on PR-THEME |
| PR3 | 🔲 Blocked on PR2 |
| PR-ADHAN | 🔲 Blocked on asset delivery |
| PR4a | 🔲 Blocked on PR2 |
| PR4b | 🔲 Blocked on PR4a + designer spec |
| PR5 | 🔲 Blocked on PR2 |
| PR6 | 🔲 Blocked on PR2 |
| PR7 | 🔲 Blocked on PR2 + designer review |
| PR8 | 🔲 Blocked on PR2 |
| PR9 | 🔲 Blocked on PR2 |
| PR-ONBOARD-AB | 🔲 Blocked on PR2 + designer approval |
| PR-CLEANUP | 🔲 Blocked on all others |

**In-progress phases:** None — clean state between PRs  
**Deferred phases:** Phase 5 (device-gated, not code-gated)  
**Blocked phases:** PR2 through PR-CLEANUP (all await PR-THEME or later)

---

## 3. Completion Percentages

> Percentages are grounded in file counts and work remaining. No inflation.

### Design-System Completion — **8%**

The design system has a correct token layer (PR1), but no components, screens, or layouts have been migrated to v2 spec.

| Sub-area | Done | Remaining | % |
|---------|------|-----------|---|
| Color tokens | ✅ All values correct | — | 100% |
| Typography tokens | ✅ Font families set | 12 files still hardcode `fontFamily: 'Cairo'` or `'Inter'` | 97% token / 0% component |
| Dark-mode ThemeMode wiring | ✗ Tokens correct, switch not wired | PR-THEME | 15% |
| Component library migration | 0 components migrated | All PR2+ | 0% |
| Screen-level redesign | 0 screens migrated | All PR2+ | 0% |
| Hardcoded colour elimination | ~35 `Color(0xFF...)` files + ~118 `Colors.*` files | PR-CLEANUP (last PR) | 0% |
| **Design-system overall** | Foundation layer only | 13 PRs remaining | **~8%** |

### Governance Completion — **65%**

| Sub-area | Done | Remaining | % |
|---------|------|-----------|---|
| Handoff docs read (critical) | 8 of 14 docs read | 6 unread (needed for PR2+) | 57% |
| AI workflow docs | ✅ Complete for current phase | Update needed after each PR | 85% |
| Progress tracking | ✅ Up to date | Rolling maintenance | 80% |
| Security review | ✅ PR1 complete | Required again for PR-THEME, PR2 | 10% |
| Master status | ✅ Created | Rolling maintenance | 80% |
| **Governance overall** | Strong foundation | Handoff docs partially unread | **~65%** |

### Flutter Implementation Completion — **12%**

Measures how much of the v2 Flutter implementation is done vs. the full 14-PR program.

| Milestone | Weight | Done |
|-----------|--------|------|
| Token foundation (PR1) | Low (enabler) | ✅ |
| ThemeMode wiring (PR-THEME) | Low | ✗ |
| Shell & nav redesign (PR2) | High | ✗ |
| Prayer card (PR3) | Medium | ✗ |
| Calendar (PR4a + PR4b) | High | ✗ |
| Accessibility (PR5) | Low | ✗ |
| Stats (PR6) | Medium | ✗ |
| Athkar net-new (PR7) | High | ✗ |
| Focus animation (PR8) | Medium | ✗ |
| Widget visuals (PR9) | Medium | ✗ |
| Onboarding A/B (PR-ONBOARD-AB) | High | ✗ |
| Colour sweep (PR-CLEANUP) | Medium | ✗ |
| **Flutter implementation overall** | | **~12%** |

### Theme Migration Completion — **15%**

Token values are correct (PR1), dark surface algorithm is canonical, but `ThemeMode` is not yet responding to `isAutoModeEnabled`. Users see light mode only regardless of device setting.

### Widget Migration Completion — **85%**

iOS interactive widget infrastructure is fully complete (Phases 2–4). What remains is visual-only refresh of all three widgets to v2 design (PR9). Functionality is stable.

### Calendar Migration Completion — **0%**

No calendar work has started. PR4a (visual refresh) and PR4b (dual-display rebuild) are both blocked on PR2. PR4b additionally requires a dedicated designer spec that does not yet exist.

### Onboarding Migration Completion — **0%**

Current onboarding (`onboarding_page.dart` Variant A) is in place and must not regress. The four-variant A/B/C/D experiment (PR-ONBOARD-AB) has not started and requires both PR2 and designer approval.

### Overall v2 Program Completion — **~10%**

| Track | Weight | % Done |
|-------|--------|--------|
| App stability (Phases 0–4) | 25% of total program | 100% → contributes 25% |
| v2 Design System (14 PRs) | 75% of total program | 8% → contributes 6% |
| **Program total** | | **~10%** |

The app is functional and stable. The v2 design migration is in its earliest stage — the token foundation has been laid, but no visible UI has changed yet.

---

## 4. Remaining Work Summary

### Remaining PRs (13 of 14)

| PR | Estimated complexity | Key risk |
|----|---------------------|----------|
| PR-THEME | Low — `app.dart` only | Confirming `isAutoModeEnabled` field path |
| PR2 | High — shell, nav, breakpoints, FAB | iPad layout + RTL FAB position |
| PR3 | Medium | Four-level prayer toggle must not regress |
| PR-ADHAN | Low | Asset dependency only |
| PR4a | Medium | CalendarCubit extension without breaking toggle |
| PR4b | Very high | Net-new value objects + dual-display state |
| PR5 | Low | New settings section, no existing regressions |
| PR6 | Medium | Stats engine already has tests; visual only |
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
| B2 | `isAutoModeEnabled` → `ThemeMode` not wired | Dark mode visible to users |
| B3 | Calendar dual-display spec not written | PR4b |
| B4 | Adhan audio asset not received from designer | PR-ADHAN |
| Phase 5 | Physical device required for widget validation | Device-gated, not code-gated |
| 6 unread handoff docs | `INVESTIGATION_REPORT.md`, `REDESIGN_AUDIT.md`, `CALENDAR_FOCUS_REDESIGN.md`, `FOCUS_OIL_SPEC.md`, `IPAD_OPTIMIZATION.md`, `ONBOARDING_AB_SPEC.md` | PR2, PR4b, PR7, PR8, PR-ONBOARD-AB |

### Remaining Architecture Work

| Area | Work needed | PR |
|------|-------------|-----|
| `AdaptiveShell` | Rename + iPad breakpoints + breakpoint system | PR2 |
| Nav bar | 4-tab shape, FAB pill outside bar, RTL/LTR pill position | PR2 |
| `DualDate` value object | New Hijri+Gregorian compound date type | PR4b |
| `CalendarCell` widget | New widget accepting `DualDate` | PR4b |
| `DualMonthSwitcher` | New month navigation widget | PR4b |
| Athkar domain isolation | New `lib/features/dhikr/` sub-feature or extension | PR7 |
| `isAthkarEnabled` flag | New `UserSettings` boolean | PR7 |
| Accessibility settings | `reduceMotion`, `disableGyroscope`, `useEasternNumerals` in `UserSettings` | PR5 |

### Remaining UX Validation Work

| Area | What must be validated | When |
|------|----------------------|------|
| Font switch Cairo → Calibri | Visual regression on all text-heavy screens | Before PR-THEME merge |
| Dark mode surfaces | Green-tinted dark surfaces in correct app contexts | After PR-THEME |
| Nav bar shape (PR2) | FAB pill position in RTL vs LTR | After PR2 |
| Prayer card redesign | Four-level toggle hierarchy still intact | After PR3 |
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
| Dark-mode wiring authority | `handoff_v2-2/INVESTIGATION_RECONCILIATION.md` (decision B2 locked 2026-05-07): `UserSettings.isAutoModeEnabled` boolean, not `theme: 'system'|'light'|'dark'` |
| Implementation token file | `lib/core/design_system/tokens/athar_colors.dart` |
| Implementation typography file | `lib/core/design_system/tokens/athar_typography.dart` |

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
| Prayer card gradient in dark mode | `prayerCardGradient` is navy `[0xFF1E293B, 0xFF0F172A]` against new dark background `0xFF0E1714`. Unreviewed contrast. | PR3 |
| `isHijriMode` setting field | Decision C3 from `INVESTIGATION_RECONCILIATION.md`: field exists. How it interacts with dual-display (PR4b) is unresolved. | PR4b |
| `THEME_DARK_SPEC.md` secondary gradient variants | Not in `colors_and_type.css`. Dark secondary gradient TBD. | PR-THEME or later |
| Android widgets | 4 types exist; no v2 refresh planned yet. | After PR9 |

---

## 7. Recommended Next Step — PR-THEME

### Why PR-THEME is next

PR-THEME is the only PR with no blockers. It was explicitly placed second in the canonical sequence (`handoff_v2-2/CLAUDE_CODE_PROMPT.md`) because the dark palette from PR1 is inert without it — users cannot see any dark-mode changes until `ThemeMode` is responsive. All subsequent PRs (PR2 onward) benefit from an active dark mode while being developed and tested.

### What PR-THEME affects

- **`lib/app.dart` lines 162–172 only** — the `MaterialApp` `themeMode:` argument
- Reads `UserSettings.isAutoModeEnabled` from the settings cubit/repository
- Maps: `isAutoModeEnabled == true` → `ThemeMode.system`; `false` → `ThemeMode.light`
- No new files. No new logic. No structural changes.

### Why it is isolated enough

PR-THEME is a single-argument change in `app.dart`. The dark theme extension (`AtharColors.dark`) and `ThemeData` are already wired — they just aren't being selected. No new cubits, no new routes, no new widgets. Reverting is a one-line change. Regression surface is `app.dart` only.

### What must be validated before approval

1. **Light mode unchanged:** App in light mode must look identical to pre-PR-THEME state.
2. **Dark mode activates:** Setting `isAutoModeEnabled = true` on a device with dark system appearance must switch the app to the dark token set.
3. **System follows device:** `ThemeMode.system` must respond to device appearance changes without app restart.
4. **Prayer card unchanged:** `prayerCardGradient` (navy static gradient) must render correctly against the new dark background `0xFF0E1714` — verify contrast is acceptable.
5. **B4 investigation:** Confirm which settings UI control drives `isAutoModeEnabled` — the settings page may need a corresponding toggle added or verified.

**Before starting PR-THEME:** Read `IMPLEMENTATION_EXECUTION_PLAN.md` § PR-THEME and confirm `UserSettings.isAutoModeEnabled` field path.

---

## Summary Table

| Metric | Value |
|--------|-------|
| **Total legacy phases** | 6 (Phases 0–5) |
| **Total v2 design system PRs** | 14 |
| **Total program milestones** | 20 |
| **Legacy phases complete** | 5 of 6 |
| **v2 PRs complete** | 1 of 14 (PR1) |
| **v2 PRs ready to start** | 1 (PR-THEME) |
| **v2 PRs blocked** | 12 |
| **v2 PRs awaiting asset/spec** | 2 (PR-ADHAN, PR4b) |
| **Design-system completion** | ~8% |
| **Flutter migration completion** | ~12% |
| **Theme migration completion** | ~15% |
| **Widget migration completion** | ~85% |
| **Calendar migration completion** | 0% |
| **Onboarding migration completion** | 0% |
| **Governance completion** | ~65% |
| **Overall v2 program completion** | **~10%** |
| **Highest-risk remaining PR** | PR4b (Calendar dual-display) |
| **Recommended next PR** | PR-THEME |
| **Active blockers** | B1 (Calibri licence), B2 (ThemeMode), B3 (calendar spec), B4 (adhan asset), Phase 5 (device) |
| **Current canonical branch** | `feat/athar-v2-pr1-tokens-theme` |
| **Current canonical handoff** | `handoff_v2-2/` |
