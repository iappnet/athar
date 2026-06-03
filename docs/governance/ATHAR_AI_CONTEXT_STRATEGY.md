<!--
CANONICAL-FOR: AI context tier reasoning, tier definitions, anti-patterns (authoritative reasoning for CONTEXT_TIERS.md)
OWNER:         Claude Design
PRECEDENCE:    off-ladder (governance authority, not a living operational file)
LAST-UPDATED:  2026-06-01 · Stage A
LOADS-AT:      off-ladder (read when revising context loading strategy)
-->

# Athar — AI Context Strategy

**Author:** Claude Design
**Date:** 2026-06-01
**Status:** Proposal — planning only.
**Owns:** which files an AI agent loads, and when. Builds on Claude Code's `AI_CONTEXT_LOADING_PROPOSAL.md` and makes it the binding model.
**Operational twin:** `.claude/CONTEXT_TIERS.md` (a terse copy of §2–§3 that loads fast). The two must always match.

---

## 1. Why tiers

151 files cannot all load every session — it would exhaust context and bury the truth under history. The model: **load the minimum that guarantees correctness, expand only for the active feature, never auto-load history.**

| Tier | When | Files | Budget |
|---|---|---|---|
| **0 — Invariants** | Every session, before any tool call | 4 | ~700 lines |
| **1 — Active PR** | During a PR, refreshed on resume | 4–6 | ~1,500 lines |
| **2 — Feature** | Only for the current feature's PR | 2–4 | varies |
| **3 — History** | Never auto-loaded; only on explicit human request | all others | — |

---

## 2. Tier 0 — always read (in this order)

| Order | File | Why it's an invariant |
|---|---|---|
| 1 | `CLAUDE.md` | Operating contract, non-negotiable rules, execution caps |
| 2 | `docs/progress/CHECKPOINT.md` | What is happening right now — wins on "current state" |
| 3 | `docs/ai/KNOWN_PROBLEMS.md` | Prevents re-breaking fragile code / re-fixing closed bugs |
| 4 | `docs/status/ROADMAP.md` | PR order + % — prevents duplicate or out-of-sequence work |

**Loading rule:** read in order. The moment `CHECKPOINT.md` states the current PR, **stop trusting any "next PR" section in lower-tier files** — CHECKPOINT wins (precedence level 2).

---

## 3. Tier 1 — active-PR context

Loaded once per PR arc, refreshed on resume:

| File | Load when |
|---|---|
| `docs/status/MIGRATION_STATE.md` | Any PR — branch state, RULE 1/2, Deferred QA |
| `docs/status/NEXT_STEPS.md` | Any PR — next-arc guidance |
| `docs/design-context/_audit_<feature>.md` | The audit for the current PR |
| `docs/design-specs/INVESTIGATION_RECONCILIATION.md` | Any design PR — 5 locked decisions |
| `docs/design-specs/PACKAGE_A_DECISIONS.md` | PRs touching Calibri / isHijriMode / AdaptiveShell / Stats |
| `docs/design-specs/PACKAGE_C_DECISIONS.md` | PRs touching dark mode / 4-tab / calendar / Athkar / bottom-nav |

---

## 4. Tier 2 — feature-specific (load only for that PR)

| PR | Load |
|---|---|
| Any screen PR | `ai/FEATURE_INDEX.md`, `design-specs/REDESIGN_AUDIT.md` |
| **PR4b — Calendar** | `design-specs/CALENDAR_CELL_SPEC.md`, `CALENDAR_FOCUS_REDESIGN.md`, `DUAL_DATE_SPEC.md`, `design-context/_audit_calendar_dual.md` |
| **PR6 — Stats** | `design-specs/STATS_KPI_SPEC.md`, `ai/STATS_ENGINE_INDEX.md`, `design-context/_audit_stats.md` |
| **PR7 — Athkar** | `design-specs/ATHKAR_SPEC.md` |
| **PR8 — Focus** | `design-specs/FOCUS_OIL_SPEC.md` |
| **PR9 — iOS Widgets** | `design-specs/IOS_WIDGETS_SPEC.md`, `ai/WIDGET_INDEX.md` |
| **PR2 — AdaptiveShell** | `design-specs/IPAD_OPTIMIZATION.md`, `IPAD_LAYER2_OWNERSHIP_MAP.md` |
| **PR-ONBOARD-AB** | `design-specs/ONBOARDING_AB_SPEC.md` |
| Any cubit change | `ai/STATE_MANAGEMENT_INDEX.md` |
| Any dark-mode work | `design-specs/THEME_DARK_SPEC.md` |
| Any typography work | `design-specs/DESIGN_SYSTEM_GAP_VALIDATION.md` |
| Any data-flow tracing | `ai/DATA_FLOW_INDEX.md` |
| Any Supabase work | `ai/SUPABASE_INDEX.md` |
| Component additions | `design-specs/COMPONENT_SPECS.md` |
| **Future: ActivityEvent / AI track** | `design-specs/ACTIVITY_EVENT_SPEC.md`, `ai/DATA_FLOW_INDEX.md` |
| **Future: HealthKit** | `design-specs/HEALTHKIT_SPEC.md`, `ai/HEALTH_INTEGRATION_INDEX.md` |

**Rule:** load the *minimum* set. One feature's files are never loaded while working on another.

---

## 5. Tier 3 — never auto-load

| Category | Examples |
|---|---|
| Completed PR reports | all `pr-reports/PR*` except the current cycle's verification |
| Pre-PR1 design-context | `phase0-audits/*` |
| Widget phase history | `widget-phase/*` |
| Session snapshots | `session-reports/*` |
| Change logs | `change-logs/*` |
| Root duplicates | `handoff-duplicates/*` |
| Superseded specs | older spec versions in history |

Load a Tier-3 file **only** when the human explicitly asks for historical context. `docs/history/**` is structurally excluded from auto-load.

---

## 6. Anti-patterns (do not do)

1. **Never read all of `docs/progress/` on resume** — only `CHECKPOINT.md`. The rest is history.
2. **Never read a `docs/history/**` file as context** for current work.
3. **Never read both `CLAUDE.md` and `AI_WORKFLOW.md` in full at start** — CLAUDE.md suffices; AI_WORKFLOW is an on-demand reference.
4. **Never read a design spec from a path other than `docs/design-specs/`** — the mirror is the only repo-canonical location.
5. **Never load one feature's Tier-2 files while building another feature.**
6. **Never trust a lower-tier "current state" over `CHECKPOINT.md`.**

---

## 7. Worked example — PR6 (Stats) session

```
Session start (Tier 0):
  1. CLAUDE.md
  2. docs/progress/CHECKPOINT.md          → "PR6 complete, AR verified"
  3. docs/ai/KNOWN_PROBLEMS.md
  4. docs/status/ROADMAP.md

Active PR (Tier 1):
  5. docs/status/MIGRATION_STATE.md
  6. docs/design-context/_audit_stats.md
  7. docs/design-specs/INVESTIGATION_RECONCILIATION.md

Touching the feature (Tier 2):
  8. docs/design-specs/STATS_KPI_SPEC.md
  9. docs/ai/STATS_ENGINE_INDEX.md
 10. docs/ai/FEATURE_INDEX.md → stats entry

Never: any pr-reports/*, any change-logs/*, any phase0-audits/*
Total: ~2,500–3,500 lines.
```

---

## 8. The directive to install in `CLAUDE.md`

Replace the current free-form "AI Workflow" funnel description with this explicit block:

```markdown
## Context Loading (see docs/governance/AI_CONTEXT_STRATEGY.md)

Tier 0 — ALWAYS, in order:
  CLAUDE.md → docs/progress/CHECKPOINT.md → docs/ai/KNOWN_PROBLEMS.md → docs/status/ROADMAP.md
Tier 1 — active PR:
  docs/status/MIGRATION_STATE.md + docs/design-context/_audit_<pr>.md
  + docs/design-specs/INVESTIGATION_RECONCILIATION.md
Tier 2 — feature only:
  see .claude/CONTEXT_TIERS.md
Tier 3 — NEVER auto-load:
  docs/history/** , change-logs, pr-reports, phase0-audits, root duplicates

Rule: CHECKPOINT.md wins on "current state." Design specs load ONLY from docs/design-specs/.
```

And the operational twin at `.claude/CONTEXT_TIERS.md` holds the same Tier 0/1 list plus the full Tier-2 table from §4 — kept terse so it costs almost nothing to load and is the one file `/drift-check` reads to know what "should" be in context.

---

## 9. Keeping the two copies in sync

`AI_CONTEXT_STRATEGY.md` (this file, full reasoning) and `.claude/CONTEXT_TIERS.md` (terse operational list) **must change together in one commit.** If they disagree, the terse operational copy is treated as authoritative for *what loads* and this file as authoritative for *why* — and the mismatch is a `/drift-check` failure.
