# Migration Roadmap Verification

**Date:** 2026-05-09  
**Source authorities:** `handoff_v2-2/CLAUDE_CODE_PROMPT.md` · `handoff_v2-2/FINAL_PACKAGE_MANIFEST.md` · `IMPLEMENTATION_EXECUTION_PLAN.md`  
**Status:** Verification complete — canonical roadmap confirmed and discrepancies documented

---

## Verification Result

The proposed roadmap submitted for verification is **incorrect in 8 places** against the canonical handoff documents. The canonical roadmap from `FINAL_PACKAGE_MANIFEST.md` (locked 2026-05-08) is authoritative.

---

## Proposed vs. Canonical — Discrepancy Table

| Proposed | Canonical | Match | Issue |
|----------|-----------|-------|-------|
| PR1 — Tokens + Typography | **PR1** — Tokens & Theme | ✅ | Correct |
| PR-THEME — ThemeMode wiring | **PR-THEME** — ThemeMode.system wiring | ✅ | Correct |
| PR2 — Layout / Shell | **PR2** — AdaptiveShell (rename + breakpoints) | ✅ | Correct |
| PR3 — Components | **PR3** — Prayer card refresh | ❌ | "Components" is wrong; canonical scope is prayer card only, per `PRAYER_CARD_SPEC.md` |
| *(missing)* | **PR-ADHAN** — Bundle adhan audio (Android + iOS) | ❌ | Entirely absent from proposed roadmap |
| PR4a — Calendar visual | **PR4a** — Calendar visual refresh | ✅ | Correct |
| PR4b — Dual calendar rebuild | **PR4b** — Calendar dual-display rebuild | ✅ | Correct |
| PR5 — Settings | **PR5** — Settings: Accessibility section | ✅ | Correct |
| PR6 — Onboarding | **PR6** — Stats redesign | ❌ | Onboarding is `PR-ONBOARD-AB` which comes 7 steps later; PR6 is Stats |
| PR7 — Stats | **PR7** — Athkar feature (net-new) | ❌ | Stats is PR6; PR7 is the net-new Athkar feature |
| PR8 — Spaces | **PR8** — Focus screen oil-fill | ❌ | "Spaces" does not exist as a redesign PR; Spaces feature is redesigned in-place as part of shell (PR2) and stats (PR6). PR8 is Focus screen oil-fill per `FOCUS_OIL_SPEC.md` |
| PR9 — Widgets | **PR9** — iOS widgets refresh | ✅ | Correct |
| PR10 — Athkar | *(= canonical PR7)* | ❌ | Athkar is PR7, not PR10. There is no PR10 in canonical sequence |
| PR11 — Cleanup | **PR-CLEANUP** | ✅ | Correct content, wrong number |
| PR12 — Accessibility | *(= canonical PR5)* | ❌ | Accessibility is PR5 (Settings section), not PR12. Placing it last would defer it 7 PRs too late |
| PR13 — Final QA | *(not a PR)* | ❌ | Final QA is a **process milestone**, not a PR. QA runs after every PR and again at migration merge gate |
| *(missing)* | **PR-ONBOARD-AB** — Four-variant onboarding | ❌ | Absent from proposed numbered sequence; comes between PR9 and PR-CLEANUP in canonical |

**Summary of proposal errors:**
- 1 PR entirely missing (PR-ADHAN)  
- 1 PR scope wrong (PR3 named "Components" vs. prayer-card-specific)  
- 3 PRs in wrong position (PR6/PR7/PR8 shuffled; Accessibility moved to last)  
- 1 phantom PR (PR8 "Spaces" has no canonical equivalent)  
- 1 PR missing (PR-ONBOARD-AB)  
- 1 milestone misclassified as a PR (PR13 "Final QA")

---

## Canonical PR Sequence — Verified

**Source:** `handoff_v2-2/FINAL_PACKAGE_MANIFEST.md` (locked 2026-05-08) + `CLAUDE_CODE_PROMPT.md` + `IMPLEMENTATION_EXECUTION_PLAN.md`

| # | PR ID | Name | Scope | Spec |
|---|-------|------|-------|------|
| 1 | **PR1** | Tokens & Theme | Port `colors_and_type.css` into Dart token files; Calibri font; `numericMono` | `colors_and_type.css`, `DESIGN_SYSTEM_GAP_VALIDATION.md` |
| 2 | **PR-THEME** | ThemeMode wiring | `isAutoModeEnabled` → `ThemeMode.system` in `app.dart:162–172`; disable manual dark toggle in settings | `INVESTIGATION_RECONCILIATION.md` decision B2 |
| 3 | **PR2** | AdaptiveShell | Rename `adaptive_scaffold.dart` → `adaptive_shell.dart`; iPad breakpoints; 4-tab nav bar; FAB pill outside bar (RTL/LTR) | `IPAD_OPTIMIZATION.md`, `REDESIGN_AUDIT.md`, `preview/comp-nav.html` |
| 4 | **PR3** | Prayer card refresh | Rebuild prayer card per spec; reuse `UserSettings.prayerCardDisplayMode`; compact/expanded as widget-local state; Phase 8.1 hierarchy must not regress | `PRAYER_CARD_SPEC.md` |
| 5 | **PR-ADHAN** | Bundle adhan audio | `adhan.mp3` → Android `res/raw/`; `adhan.caf` → iOS `Runner/Resources/`; build fails if absent | `FINAL_PACKAGE_MANIFEST.md` §Adhan |
| 6 | **PR4a** | Calendar visual refresh | Rebuild calendar chrome/headers/dots; keep existing toggle; extend `CalendarCubit.selectDate` to fan-in tasks + appointments + habits + prayer completions | `CALENDAR_CELL_SPEC.md`, `CALENDAR_FOCUS_REDESIGN.md` |
| 7 | **PR4b** | Calendar dual-display | `DualDate` VO + new `CalendarCell` + `DualMonthSwitcher`; simultaneous Hijri+Gregorian; delete `dual_calendar_widget.dart` | `CALENDAR_FOCUS_REDESIGN.md` |
| 8 | **PR5** | Accessibility settings | New Settings section: Reduce Motion, Disable Gyroscope, Eastern Numerals (default OFF) | `CLAUDE_CODE_PROMPT.md` §PR5 |
| 9 | **PR6** | Stats redesign | Refactor visuals + extend `StatsRepository`; KPI grid + insights + per-space breakdown + date range + export | `STATS_KPI_SPEC.md` |
| 10 | **PR7** | Athkar feature (net-new) | Curated sets v1; pause for designer review before screens; `isAthkarEnabled` gate; do not merge into habits domain | `ATHKAR_SPEC.md` |
| 11 | **PR8** | Focus screen oil-fill | Custom painter; respect Reduce Motion; `oil_animation.dart`/`fluid_engine.dart` carve-out (no flat-token migration without designer review) | `FOCUS_OIL_SPEC.md` |
| 12 | **PR9** | iOS widgets refresh | Visual-only update; App Group + WidgetKeys + Swift infra already complete; gated on `isPrayerEnabled` | `IOS_WIDGETS_SPEC.md` |
| 13 | **PR-ONBOARD-AB** | Onboarding A/B/C/D | Four variants; Variant A (existing) is behavioral baseline — DO NOT modify; `OnboardingVariantService` 25/25/25/25 routing | `ONBOARDING_AB_SPEC.md` |
| 14 | **PR-CLEANUP** | Hardcoded color sweep | Replace remaining `Color(0xFF…)` / `Colors.*` in files NOT touched by other PRs; carve-out: `oil_animation.dart`, `fluid_engine.dart` | — |

**Total PRs: 14**  
**Complete: 1 (PR1)**  
**Remaining: 13**

---

## Dependency Chain

```
PR1 ✅
  └── PR-THEME
        └── PR2
              ├── PR3
              │     └── PR-ADHAN (can also parallel PR3)
              ├── PR4a
              │     └── PR4b (requires designer spec)
              ├── PR5 (independent after PR2)
              ├── PR6 (independent after PR2)
              │
              └── PR7 (requires designer review)
                    └── PR8 (independent after PR2)
                          └── PR9 (independent after PR2)
                                └── PR-ONBOARD-AB (requires designer approval)
                                      └── PR-CLEANUP (last — all other PRs done)
```

Notes:
- PR-ADHAN can run in parallel with PR3 once PR2 is done (asset dependency is orthogonal to code)
- PR5, PR6, PR8, PR9 are independent of each other once PR2 is complete
- PR-CLEANUP is always last

---

## Process Milestones (NOT PRs)

The following are validation gates that run after PRs, not PRs themselves:

| Milestone | When | What |
|-----------|------|------|
| Designer screenshot review | After every PR | Before/after screenshots to designer; approval required before next PR |
| `flutter analyze` + `flutter test` | After every PR | Must be 0 issues and all tests green |
| Physical device validation (Phase 5) | Before migration merge | Interactive widget taps, locale switching, cold-start replay |
| Full visual regression pass | Before migration merge | All screens in light + dark |
| Full QA pass | Before migration merge | All features, all flows |
| Migration merge to `main` | After all above complete | Single merge of migration branch |

---

## Spec Files Required Per PR

| PR | Must read before starting |
|----|--------------------------|
| PR-THEME | `IMPLEMENTATION_EXECUTION_PLAN.md` §PR-THEME; `INVESTIGATION_RECONCILIATION.md` decision B2 |
| PR2 | `IPAD_OPTIMIZATION.md`, `REDESIGN_AUDIT.md`, `preview/comp-nav.html`, `INVESTIGATION_REPORT.md` |
| PR3 | `PRAYER_CARD_SPEC.md`, `COMPONENT_SPECS.md` |
| PR-ADHAN | `FINAL_PACKAGE_MANIFEST.md` §Adhan; `IMPLEMENTATION_EXECUTION_PLAN.md` §PR-ADHAN |
| PR4a | `CALENDAR_CELL_SPEC.md`, `CALENDAR_FOCUS_REDESIGN.md` |
| PR4b | `CALENDAR_FOCUS_REDESIGN.md` (full), designer spec for `DualDate` |
| PR5 | `CLAUDE_CODE_PROMPT.md` §PR5 |
| PR6 | `STATS_KPI_SPEC.md` |
| PR7 | `ATHKAR_SPEC.md`; designer review before screens |
| PR8 | `FOCUS_OIL_SPEC.md`; designer review for `oil_animation.dart` |
| PR9 | `IOS_WIDGETS_SPEC.md` |
| PR-ONBOARD-AB | `ONBOARDING_AB_SPEC.md`; designer approval before start |
| PR-CLEANUP | All previous PRs merged; review each substitution individually |
