<!--
CANONICAL-FOR: AI context loading tiers (terse operational copy)
OWNER:         Claude Code
PRECEDENCE:    off-ladder
LAST-UPDATED:  2026-06-01 · Stage A install
LOADS-AT:      Tier 0 (read by /drift-check)
-->

# Context Tiers — Athar (operational copy)

**Authoritative reasoning:** `docs/governance/ATHAR_AI_CONTEXT_STRATEGY.md`  
**Rule:** This file and `AI_CONTEXT_STRATEGY.md` must change together in one commit. If they disagree, this file governs *what loads*; the strategy file governs *why*.

---

## Tier 0 — ALWAYS, in this order (every session, before any tool call)

1. `CLAUDE.md`
2. `docs/progress/CHECKPOINT.md`
3. `docs/ai/KNOWN_PROBLEMS.md`
4. `IMPLEMENTATION_MASTER_STATUS.md`

**Loading rule:** After reading CHECKPOINT.md, stop trusting any "next PR" claim in lower-tier files — CHECKPOINT wins on current state.

---

## Tier 1 — Active PR (load once per PR arc, refresh on resume)

| File | Load when |
|------|-----------|
| `CURRENT_MIGRATION_STATE.md` | Any PR — branch state, RULE 1/2, Deferred QA |
| `ROADMAP_AFTER_PR4A.md` | Any PR — next-arc guidance |
| `design-context/_audit_<feature>.md` | The audit for the current PR |
| `handoff_v2-2/INVESTIGATION_RECONCILIATION.md` | Any design PR — 5 locked decisions |
| `handoff_v2-2/PACKAGE_A_DECISIONS.md` | PRs touching Calibri / isHijriMode / AdaptiveShell / Stats |
| `handoff_v2-2/PACKAGE_C_DECISIONS.md` | PRs touching dark mode / 4-tab / calendar / Athkar / bottom-nav |

---

## Tier 2 — Feature-specific (load only for the current feature's PR)

| PR | Load |
|----|------|
| Any screen PR | `docs/ai/FEATURE_INDEX.md`, `handoff_v2-2/REDESIGN_AUDIT.md` |
| PR4b — Calendar | `handoff_v2-2/CALENDAR_CELL_SPEC.md`, `handoff_v2-2/CALENDAR_FOCUS_REDESIGN.md`, `DUAL_DATE_SPEC.md`, `design-context/_audit_calendar_dual.md` |
| PR7 — Athkar | `handoff_v2-2/ATHKAR_SPEC.md` |
| PR8 — Focus | `handoff_v2-2/FOCUS_OIL_SPEC.md` |
| PR9 — iOS Widgets | `handoff_v2-2/IOS_WIDGETS_SPEC.md`, `docs/ai/WIDGET_INDEX.md` |
| PR-ONBOARD-AB | `handoff_v2-2/ONBOARDING_AB_SPEC.md` |
| Any cubit change | `docs/ai/STATE_MANAGEMENT_INDEX.md` |
| Any dark-mode work | `handoff_v2-2/THEME_DARK_SPEC.md` |
| Any iPad layout | `handoff_v2-2/IPAD_OPTIMIZATION.md`, `IPAD_LAYER2_OWNERSHIP_MAP.md` |
| Any typography | `handoff_v2-2/DESIGN_SYSTEM_GAP_VALIDATION.md` |
| Any data-flow | `docs/ai/DATA_FLOW_INDEX.md` |
| Any Supabase | `docs/ai/SUPABASE_INDEX.md` |
| Component additions | `handoff_v2-2/COMPONENT_SPECS.md` |

---

## Tier 3 — NEVER auto-load

`docs/ai/change-logs/` · all `PR*_*.md` root files · `docs/progress/phase_tracker.md` · `docs/progress/BUGFIX_PHASE_STATUS.md` · `docs/progress/prayer_widget_fix_checkpoint.md` · `docs/progress/phase_checkpoint.md` · `design-context/_audit_current_flutter_ui.md` · `design-context/_audit_design_system.md` · `design-context/_design_gap_analysis.md` · `design-context/_handoff_to_design_tool.md` · `design-context/_implementation_strategy.md` · `design-context/_pre_implementation_ui_audit.md` · `design-context/_project_design_context.md` · `INVESTIGATION_REPORT.md` (root) · `FINAL_PACKAGE_MANIFEST.md` (root) · `CLAUDE_CODE_PROMPT.md` (root) · `docs/ai/reports/` · `GIT_CHECKPOINT_REPORT.md` · `SESSION_RECOVERY_REPORT.md` · `IMPLEMENTATION_SESSION_STATE.md`

---

## Anti-patterns (do not)

1. Never read all of `docs/progress/` on resume — only `CHECKPOINT.md`.
2. Never load one feature's Tier-2 files while building another feature.
3. Never trust a lower-tier "current state" over `CHECKPOINT.md`.
4. Never read design specs from root copies — use `handoff_v2-2/` (Stage A current path).
