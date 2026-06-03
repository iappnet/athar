# AI Context Loading Proposal — Athar

**Date:** 2026-06-01  
**Purpose:** Define which documentation files Claude Code should load, and when.  
**Background:** 151 files exist. Loading all of them in every session would exhaust context and violate execution discipline. This proposal defines a 4-tier loading model.

---

## LOADING MODEL OVERVIEW

| Tier | When loaded | File count | Purpose |
|------|------------|-----------|---------|
| Tier 0 | Always — every session | 4 files | Session invariants |
| Tier 1 | Active PR — every session during a PR | 4–6 files | Current-work context |
| Tier 2 | Feature-specific — only for the relevant feature | 2–4 files | Feature-scoped specs |
| Tier 3 | Historical / archive — only when explicitly requested | All others | Audit trail, never auto-loaded |

---

## TIER 0 — Always Read (Every Session)

These files define invariants that apply to ALL work. Load before any tool call.

| File | Why always read |
|------|----------------|
| `CLAUDE.md` | Project instructions, non-negotiable rules, execution caps, design system rules — the operating contract |
| `docs/progress/CHECKPOINT.md` | Session resume: current PR, exact step, open decisions, working tree state |
| `docs/ai/KNOWN_PROBLEMS.md` | Confirmed bugs + fragile areas — prevents re-breaking known-fragile code |
| `IMPLEMENTATION_MASTER_STATUS.md` | SSOT for PR ordering, completion %, blockers — prevents duplicate or out-of-sequence work |

**Context budget:** ~700 lines total (~4 files)

**Loading rule:** Read in the order listed. If CHECKPOINT.md says "PR5 complete, PR6 implementing," stop reading the "Next PR" section of any other file — CHECKPOINT.md wins.

---

## TIER 1 — Active PR Context (Read at PR Start, Keep in Context)

These files provide the context for whatever PR is currently in flight. Load once per PR arc, refresh on resume.

| File | When to load |
|------|-------------|
| `CURRENT_MIGRATION_STATE.md` | Any PR — current branch state, RULE 1/2, QA bucket |
| `ROADMAP_AFTER_PR4A.md` | PR5–PR6 arc — next-step guidance, PR4b lock |
| `design-context/_audit_<feature>.md` | The audit for the current PR |
| `handoff_v2-2/INVESTIGATION_RECONCILIATION.md` | Any design PR — 5 locked decisions, supersedes older specs |
| `handoff_v2-2/PACKAGE_A_DECISIONS.md` | Any feature PR touching Calibri, isHijriMode, AdaptiveShell |
| `handoff_v2-2/PACKAGE_C_DECISIONS.md` | Any PR touching dark mode, 4-tab, calendar, Athkar, bottom-nav |

**Context budget:** ~1,500 lines typical (varies by audit size)

---

## TIER 2 — Feature-Specific (Load Only for That Feature's PR)

| PR | Load these files |
|----|----------------|
| Any screen PR | `docs/ai/FEATURE_INDEX.md` (entry files), `handoff_v2-2/REDESIGN_AUDIT.md` (screen ticket map) |
| PR4b — Calendar | `handoff_v2-2/CALENDAR_CELL_SPEC.md`, `handoff_v2-2/CALENDAR_FOCUS_REDESIGN.md`, `DUAL_DATE_SPEC.md`, `design-context/_audit_calendar_dual.md` |
| PR5 — Settings | `design-context/_audit_accessibility.md` |
| PR6 — Stats | `handoff_v2-2/STATS_KPI_SPEC.md`, `design-context/_audit_stats.md`, `docs/ai/STATS_ENGINE_INDEX.md` |
| PR7 — Athkar | `handoff_v2-2/ATHKAR_SPEC.md` |
| PR8 — Focus | `handoff_v2-2/FOCUS_OIL_SPEC.md` |
| PR9 — iOS Widgets | `handoff_v2-2/IOS_WIDGETS_SPEC.md`, `docs/ai/WIDGET_INDEX.md` |
| PR-ONBOARD-AB | `handoff_v2-2/ONBOARDING_AB_SPEC.md` |
| Any cubit change | `docs/ai/STATE_MANAGEMENT_INDEX.md` |
| Any dark-mode work | `handoff_v2-2/THEME_DARK_SPEC.md` |
| Any iPad layout | `handoff_v2-2/IPAD_OPTIMIZATION.md`, `IPAD_LAYER2_OWNERSHIP_MAP.md` |
| Any typography work | `handoff_v2-2/DESIGN_SYSTEM_GAP_VALIDATION.md` |
| Any data flow tracing | `docs/ai/DATA_FLOW_INDEX.md` |
| Any Supabase work | `docs/ai/SUPABASE_INDEX.md` |
| Component additions | `handoff_v2-2/COMPONENT_SPECS.md` |

**Loading rule:** Load the minimum set. One feature's files should not be loaded when working on a different feature.

---

## TIER 3 — Historical / Archive Only (Never Auto-Load)

Files that must NOT be loaded automatically. Load only if the user explicitly asks for historical context.

| Category | Files |
|----------|-------|
| Completed PR reports | All PR*_*.md files except sign-offs |
| Widget phase history | `phase_checkpoint.md`, `BUGFIX_PHASE_STATUS.md`, `prayer_widget_fix_checkpoint.md` |
| Pre-PR1 design-context | `_audit_current_flutter_ui.md`, `_audit_design_system.md`, `_design_gap_analysis.md`, `_handoff_to_design_tool.md`, `_implementation_strategy.md`, `_pre_implementation_ui_audit.md`, `_project_design_context.md` |
| Session reports | `GIT_CHECKPOINT_REPORT.md`, `SESSION_RECOVERY_REPORT.md`, `IMPLEMENTATION_SESSION_STATE.md`, `ROADMAP_RECONCILIATION_REPORT.md` |
| Change logs | All `docs/ai/change-logs/*.md` |
| Duplicate root files | `INVESTIGATION_REPORT.md` (root), `FINAL_PACKAGE_MANIFEST.md` (root), `CLAUDE_CODE_PROMPT.md` (root) |
| Older design specs | Design System root/ spec files (use handoff_v2-2/ instead) |
| Investigation reports | `docs/ai/reports/AI_ARCHITECTURE_ALIGNMENT_AUDIT_2026-05-04.md`, `docs/ai/reports/ARCHITECTURE_DISCOVERY_AUDIT_2026-05-04.md` |

---

## ANTI-PATTERNS TO AVOID

1. **Never read all docs/progress/ files** at session start. Only CHECKPOINT.md. Other progress files are historical.
2. **Never read Design System root/ spec files** — always prefer handoff_v2-2/ versions.
3. **Never read all PR3 files** for context on the current PR. PR3 is complete.
4. **Never read change-logs** as context. They are audit-trail only.
5. **Never read both CLAUDE.md and AI_WORKFLOW.md in full** at session start — CLAUDE.md is sufficient; AI_WORKFLOW.md is a reference when needed.

---

## CURRENT ACTIVE LOADING SEQUENCE (PR6 in progress)

```
Session start:
1. CLAUDE.md                                          [Tier 0]
2. docs/progress/CHECKPOINT.md                        [Tier 0]
3. docs/ai/KNOWN_PROBLEMS.md                          [Tier 0]
4. IMPLEMENTATION_MASTER_STATUS.md                    [Tier 0]
5. design-context/_audit_stats.md                     [Tier 1 — active audit]
6. handoff_v2-2/INVESTIGATION_RECONCILIATION.md       [Tier 1 — always for design PR]

When touching stats feature:
7. handoff_v2-2/STATS_KPI_SPEC.md                    [Tier 2 — PR6]
8. docs/ai/STATS_ENGINE_INDEX.md                      [Tier 2 — PR6]
9. docs/ai/FEATURE_INDEX.md → stats entry file        [Tier 2 — any feature]

When cubit disambiguation needed:
10. docs/ai/STATE_MANAGEMENT_INDEX.md                 [Tier 2 — on demand]
```

**Total Tier 0+1+2 context for PR6:** ~2,500–3,500 lines depending on audit depth.

---

## PROPOSED LOADING DIRECTIVE FOR CLAUDE.md

Replace the current "AI Workflow" section's funnel description with an explicit tier reference:

```markdown
## Context Loading

Tier 0 (always): CLAUDE.md → CHECKPOINT.md → KNOWN_PROBLEMS.md → IMPLEMENTATION_MASTER_STATUS.md
Tier 1 (active PR): CURRENT_MIGRATION_STATE.md + active _audit_*.md + INVESTIGATION_RECONCILIATION.md
Tier 2 (feature): see docs/documentation-audit/AI_CONTEXT_LOADING_PROPOSAL.md
Tier 3 (never auto): change-logs, PR reports, pre-PR1 design-context, root duplicates
```
