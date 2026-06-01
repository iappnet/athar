# Program Implementation Status — Athar v2 Design System Migration

**Last updated:** 2026-06-01

**Program:** Athar v2 Design System — Full Flutter Migration  
**Canonical handoff:** `handoff_v2-2/`  
**Canonical migration branch:** `feat/athar-v2-pr1-tokens-theme` ← long-running; do NOT merge to `main` until migration complete  
**main:** stable legacy baseline at `32e59c3` — no touches until migration merge gate  
**Roadmap verification:** `MIGRATION_ROADMAP_VERIFICATION.md` (verified 2026-05-09; 8 discrepancies corrected)  
**Branch strategy:** `MIGRATION_BRANCH_STRATEGY.md`  
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
| **PR-THEME** | Design System Theme Wiring (full arc) | `ThemePreference` enum + 3-mode picker; PR-FONT-FALLBACK (38 base styles + 88 theme fallbacks); wire `AtharLightTheme`/`AtharDarkTheme`; RTL drawer. `flutter analyze`: 0 · `flutter test`: 45/45. Tag: `athar-v2-prtheme-complete-final`. | ✅ **Complete 2026-06-01** | PR1 ✅ | — |
| **PR2** | AdaptiveShell | Rename `adaptive_scaffold` → `adaptive_shell`; iPad breakpoints; 4-tab nav bar shape; FAB pill outside bar (RTL/LTR) | ✅ Complete | PR-THEME ✅ | — |
| **PR3** | Prayer Card Refresh | Forest gradient, 44px countdown, calm states, golden test suite 16/16. Tag: in branch. | ✅ **Complete 2026-06-01** | PR2 ✅ | — |
| **PR-ADHAN** | Audio Asset Bundle | Bundle `adhan.mp3` / `.caf`; build gate for existing player | 🔲 Not started | Asset from designer | Asset not yet received |
| **PR4a** | Calendar Visual Refresh | Update calendar chrome, colours, typography; keep existing Hijri/Gregorian toggle; extend `CalendarCubit` | 🔲 Not started | PR2 | Must read: `CALENDAR_FOCUS_REDESIGN.md` |
| **PR4b** | Calendar Dual-Display Rebuild | Net-new: `DualDate` value object + `CalendarCell` + `DualMonthSwitcher`; simultaneous Hijri + Gregorian numerals | 🔲 Not started | PR4a + designer spec | Dedicated designer spec not yet written |
| **PR5** | Accessibility Settings | New section: Reduce Motion, Disable Gyroscope, Eastern Numerals toggles | 🔲 Not started | PR2 | None |
| **PR6** | Stats Redesign | New KPI layout per `STATS_KPI_SPEC.md`; adopt `numericMono` | 🔲 Not started | PR2 | `STATS_KPI_SPEC.md` must be read |
| **PR7** | Athkar Feature (Net-New) | New curated Athkar sets v1; `isAthkarEnabled` gate; must not merge into habits domain | 🔲 Not started | PR2 + designer review | Designer review required; `REDESIGN_AUDIT.md` unread |
| **PR8** | Focus Oil-Fill Animation | Oil-fill screen per `FOCUS_OIL_SPEC.md`; procedural colours must be reviewed before token migration | 🔲 Not started | PR2 | Must read: `FOCUS_OIL_SPEC.md`; designer review for `oil_animation.dart` colours |
| **PR9** | iOS Widget Visual Refresh | Visual-only update of all 3 iOS widgets to v2 design (infra and interactions already complete) | 🔲 Not started | PR2 | None |
| **PR-ONBOARD-AB** | Onboarding A/B/C/D | Four-variant onboarding experiment; Variant A must not regress until experiment ships | 🔲 Not started | PR2 + designer approval | Must read: `ONBOARDING_AB_SPEC.md`; designer approval required |
| **PR-IPAD-LAYER2** | Per-Screen Tablet Layouts | Add tablet branches to Dashboard (2/3-col), Tasks (master-detail), Habits (grid+pane), Settings (two-pane), Focus (720pt cap), Spaces (detail pane). Calendar covered by PR4a/PR4b; Stats by PR6; Onboarding by PR-ONBOARD-AB. | 🔲 Not started | PR2 ✅ (infrastructure done) | Each screen is independent; can be added within its feature PR or batched here |
| **PR-IPAD-LAYER3** | iPad Affordances Sweep | Hover states (MouseRegion), keyboard shortcuts (`athar_shortcuts.dart`), CupertinoContextMenu, drag-and-drop (internal + external), Apple Pencil / Scribble | 🔲 Not started | PR-IPAD-LAYER2 | All Layer 2 layouts must exist first |
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
| PR1 | ✅ Complete — `athar-v2-pr1-complete` |
| PR-THEME (full arc: initial + 3MODE + FONT-FALLBACK + FINAL) | ✅ Complete — `athar-v2-prtheme-complete-final` |
| PR2 (AdaptiveShell) | ✅ Complete — `athar-v2-pr2-complete` |
| PR3 (Prayer Card) | ✅ Complete — commit `1cd4f80` |
| PR-ADHAN | 🔲 Blocked on asset delivery |
| PR4a (Calendar visual refresh) | 🔲 Ready — unblocked by PR2 ✅ |
| PR4b (Calendar dual-display) | 🔲 Blocked on PR4a + designer spec |
| PR5 (Accessibility Settings) | 🔲 Ready — unblocked by PR2 ✅ |
| PR6 (Stats redesign) | 🔲 Ready — unblocked by PR2 ✅ |
| PR7 (Athkar feature) | 🔲 Blocked on PR2 + designer review |
| PR8 (Focus oil-fill) | 🔲 Ready — unblocked by PR2 ✅ |
| PR9 (iOS widget visual refresh) | 🔲 Ready — unblocked by PR2 ✅ |
| PR-ONBOARD-AB | 🔲 Blocked on PR2 + designer approval |
| PR-CLEANUP | 🔲 Blocked on all others |

**In-progress phases:** None — clean state between PRs
**Deferred phases:** Phase 5 (device-gated, not code-gated)
**Completed:** PR1, PR-THEME arc, PR2, PR3 = 4 logical PRs (29% of 14)
**Ready to start:** PR4a, PR5, PR6, PR8, PR9 (all unblocked by PR2 ✅)

---

## 3. Completion Percentages

> Percentages are grounded in file counts and work remaining. No inflation.

### Design-System Completion — **~22%**

The design system token layer is correct (PR1); design system themes are now live in app (PR-THEME FINAL); shell/nav/breakpoints are migrated (PR2); prayer card is redesigned (PR3).

| Sub-area | Done | Remaining | % |
|---------|------|-----------|---|
| Color tokens | ✅ All values correct | — | 100% |
| Typography tokens | ✅ All 38 base styles + 88 theme-level styles carry Cairo fallback | Component callsites still use some Cairo/Inter | ~75% |
| Dark-mode ThemeMode wiring | ✅ `AtharDarkTheme` now wired to `app.dart`; `ThemePreference` enum drives `ThemeMode` | — | 100% |
| Component library migration | Prayer card (PR3 ✅) · AdaptiveShell (PR2 ✅) | Calendar, Stats, Focus, Athkar, iOS widget visuals pending | ~15% |
| Screen-level redesign | 0 full screens migrated | PR4a+ | 0% |
| Hardcoded colour elimination | ~35 `Color(0xFF...)` files + ~118 `Colors.*` files | PR-CLEANUP (last PR) | 0% |
| **Design-system overall** | Token + theme + shell + prayer card | 10 PRs remaining | **~22%** |

### Governance Completion — **65%**

| Sub-area | Done | Remaining | % |
|---------|------|-----------|---|
| Handoff docs read (critical) | 11 of 14 docs read (IPAD_OPTIMIZATION, INVESTIGATION_REPORT, REDESIGN_AUDIT now read) | 3 unread (CALENDAR, FOCUS_OIL, ONBOARDING_AB) | 79% |
| AI workflow docs | ✅ Complete for current phase | Update needed after each PR | 85% |
| Progress tracking | ✅ Up to date | Rolling maintenance | 80% |
| Security review | ✅ PR1 complete | Required again for PR-THEME, PR2 | 10% |
| Master status | ✅ Created | Rolling maintenance | 80% |
| **Governance overall** | Strong foundation | Handoff docs partially unread | **~65%** |

### Flutter Implementation Completion — **~29%**

Measures how much of the v2 Flutter implementation is done vs. the full 14-PR program.

| Milestone | Weight | Done |
|-----------|--------|------|
| Token foundation (PR1) | Low (enabler) | ✅ |
| ThemeMode wiring (PR-THEME arc) | Low | ✅ |
| Shell & nav redesign (PR2) | High | ✅ `81af052` |
| Prayer card (PR3) | Medium | ✅ `1cd4f80` |
| Calendar (PR4a + PR4b) | High | ✗ |
| Accessibility (PR5) | Low | ✗ |
| Stats (PR6) | Medium | ✗ |
| Athkar net-new (PR7) | High | ✗ |
| Focus animation (PR8) | Medium | ✗ |
| Widget visuals (PR9) | Medium | ✗ |
| Onboarding A/B (PR-ONBOARD-AB) | High | ✗ |
| Colour sweep (PR-CLEANUP) | Medium | ✗ |
| **Flutter implementation overall** | | **~29%** |

### Theme Migration Completion — **~100%**

Token values correct (PR1); dark surface algorithm canonical; `AtharLightTheme`/`AtharDarkTheme` fully wired to `app.dart` (PR-THEME FINAL); `ThemePreference` enum drives `ThemeMode` correctly. No remaining theme wiring work.

### Widget Migration Completion — **85%**

iOS interactive widget infrastructure is fully complete (Phases 2–4). What remains is visual-only refresh of all three widgets to v2 design (PR9). Functionality is stable.

### Calendar Migration Completion — **0%**

No calendar work has started. PR4a (visual refresh) and PR4b (dual-display rebuild) are both blocked on PR2. PR4b additionally requires a dedicated designer spec that does not yet exist.

### Onboarding Migration Completion — **0%**

Current onboarding (`onboarding_page.dart` Variant A) is in place and must not regress. The four-variant A/B/C/D experiment (PR-ONBOARD-AB) has not started and requires both PR2 and designer approval.

### Overall v2 Program Completion — **~29%**

| Track | Weight | % Done |
|-------|--------|--------|
| App stability (Phases 0–4) | 25% of total program | 100% → contributes 25% |
| v2 Design System (14 PRs) | 75% of total program | ~29% → contributes ~22% |
| **Program total** | | **~29%** |

The app is functional and stable. PR1 (tokens), PR-THEME (theme wiring + font fallback + ThemePreference), PR2 (AdaptiveShell + nav), and PR3 (prayer card) are all complete. 10 component PRs remain.

---

## 4. Remaining Work Summary

### Remaining PRs (10 of 14)

| PR | Estimated complexity | Key risk |
|----|---------------------|----------|
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

## 7. Recommended Next Step — PR4a

### Why PR4a is next

PR1, PR-THEME (full arc), PR2, and PR3 are all complete. PR4a (Calendar Visual Refresh) is the highest-value unblocked PR. It has no code prerequisites remaining (PR2 ✅ unblocked it). PR4b (dual-display rebuild) must not start until PR4a is stable and a dedicated designer spec for `DualDate` semantics exists.

### What PR4a requires before starting

- Read `CALENDAR_FOCUS_REDESIGN.md` in full (first read — not yet read this session)
- Audit: write `design-context/_audit_calendar.md` before touching any Dart

### What PR4a affects (expected scope)

- Calendar chrome: colours, typography, header; keep existing Hijri/Gregorian toggle
- Extend `CalendarCubit` if needed — do not change `CalendarCell` architecture
- Do NOT start dual-display work in PR4a; that is PR4b

### Ready alternatives (also unblocked by PR2 ✅)

| PR | Entry point |
|----|-------------|
| PR5 (Accessibility Settings) | No spec required; add 3 new toggles to `UserSettings` + Settings page |
| PR6 (Stats redesign) | Read `STATS_KPI_SPEC.md` first |
| PR8 (Focus oil-fill) | Read `FOCUS_OIL_SPEC.md` first |
| PR9 (iOS widget visual refresh) | No spec required; widget infra is complete |

**To start PR4a:** Say "Implement PR4a" after reading `CALENDAR_FOCUS_REDESIGN.md`.

---

## Summary Table

| Metric | Value |
|--------|-------|
| **Total legacy phases** | 6 (Phases 0–5) |
| **Total v2 design system PRs** | 16 (14 original + PR-IPAD-LAYER2 + PR-IPAD-LAYER3 added by PR2 scope audit) |
| **Total program milestones** | 22 |
| **Legacy phases complete** | 5 of 6 (Phase 5 device-gated) |
| **v2 PRs complete** | 4 of 14 (PR1 + PR-THEME arc + PR2 + PR3) |
| **v2 PRs ready to start** | 5 (PR4a, PR5, PR6, PR8, PR9) |
| **v2 PRs blocked** | 4 (PR4b, PR7, PR-ONBOARD-AB, PR-CLEANUP) |
| **v2 PRs awaiting asset/spec** | 1 (PR-ADHAN) |
| **Design-system completion** | ~22% |
| **Flutter migration completion** | ~29% |
| **Theme migration completion** | ~100% (ThemePreference + AtharLightTheme/AtharDarkTheme wired) |
| **Widget migration completion** | ~85% |
| **Calendar migration completion** | 0% |
| **Onboarding migration completion** | 0% |
| **Governance completion** | ~75% |
| **Overall v2 program completion** | **~29%** |
| **Highest-risk remaining PR** | PR4b (Calendar dual-display) |
| **Recommended next PR** | PR4a (Calendar visual refresh) |
| **Active blockers** | B1 (Calibri licence), B3 (calendar dual-display spec), B4 (adhan asset), Phase 5 (device) |
| **Current canonical branch** | `feat/athar-v2-pr1-tokens-theme` |
| **Current canonical handoff** | `handoff_v2-2/` |
