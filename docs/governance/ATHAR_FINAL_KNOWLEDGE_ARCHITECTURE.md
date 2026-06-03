<!--
CANONICAL-FOR: Target knowledge zones (LIVING / SOURCE / HISTORY) and zone assignment for all docs
OWNER:         Claude Design
PRECEDENCE:    off-ladder (governance reference)
LAST-UPDATED:  2026-06-01 · Stage A
LOADS-AT:      off-ladder (read when assigning zone to a new document)
-->

# Athar — Final Knowledge Architecture

**Author:** Claude Design (design authority)
**Date:** 2026-06-01
**Status:** Proposal — planning only.
**Owns:** the **logical** decomposition of project knowledge into domains, and for each domain: the canonical file, supporting files, archive location, update owner, and update rules.
**Does not own:** the precedence ladder (see `CANONICAL_SOURCE_MAP.md`) or the physical tree (see `DOCUMENTATION_ARCHITECTURE.md`).

---

## 1. The unit of the system: the *domain*

A **knowledge domain** is one answerable question about the project (e.g. "what's the PR order?", "what are the locked design decisions?"). The entire anti-drift strategy reduces to one invariant:

> **Every domain has exactly one canonical file and exactly one update owner. Everything else about that domain is either a pointer or history.**

When two files can both answer the same question, they *will* eventually disagree. The knowledge architecture's job is to make sure that for every question, there is only ever one file allowed to answer.

---

## 2. Ownership model (who may write)

Three roles. Each domain is owned by exactly one.

| Role | Who | Owns (write authority) |
|---|---|---|
| **Product Owner** | The human | `CLAUDE.md`, scope/roadmap approval, blocker resolution, archive approval |
| **Claude Design** | Design-authority agent | All design specs, design decisions, sign-offs, audit rulings, this governance system |
| **Claude Code** | Implementation agent | Status/roadmap/checkpoint files, AI indexes, QA tracking, audit authoring, archiving execution |

**Write-authority rule:** an agent may *read* any LIVING/SOURCE file, but may only *edit* files in domains it owns. Claude Code proposes design-spec changes to Claude Design; it does not edit `docs/design-specs/`. Claude Design proposes roadmap implications to Claude Code; it does not edit `ROADMAP.md`. The human breaks ties and owns `CLAUDE.md`.

---

## 3. Domain register

For every major domain: **canonical file · supporting files (pointers only) · archive location · update owner · update rule.**

### 3.1 Roadmap (PR sequence + completion %)
- **Canonical:** `docs/status/ROADMAP.md` *(was IMPLEMENTATION_MASTER_STATUS.md)*
- **Supporting (pointer-only):** `PROGRAM_IMPLEMENTATION_STATUS.md` (risk notes → points here for sequence), `NEXT_STEPS.md` (next-arc guidance → points here for the full list)
- **Archive:** `docs/history/` (superseded roadmap snapshots, dated)
- **Owner:** Claude Code
- **Update rule:** updated **in the same change that completes or reorders a PR** — never reconciled later. A PR is not "done" until its row here is updated. % is recomputed from the PR table, never hand-typed elsewhere.

### 3.2 Current migration state (evidence + layout rules + QA)
- **Canonical:** `docs/status/MIGRATION_STATE.md` *(was CURRENT_MIGRATION_STATE.md)*
- **Supporting:** `ROADMAP.md` (links here for working-tree state); RULE 1 / RULE 2 are defined **only** here
- **Archive:** `docs/history/session-reports/` (old state snapshots)
- **Owner:** Claude Code
- **Update rule:** updated on every commit/tag and when RULE 1/2 or the QA bucket changes. Commit hashes and tags are recorded here as the evidence ledger.

### 3.3 Implementation status / risk analysis
- **Canonical:** `PROGRAM_IMPLEMENTATION_STATUS.md` (risk-per-PR only)
- **Supporting:** must carry an SSOT pointer to `ROADMAP.md` for sequence + % (it may **not** hold its own PR table)
- **Archive:** `docs/history/`
- **Owner:** Claude Code
- **Update rule:** holds *only* risk commentary. The moment it carries a PR status row, that row is drift — delete it, point to ROADMAP.

### 3.4 Active PR / session resume
- **Canonical:** `docs/progress/CHECKPOINT.md`
- **Supporting:** `NEXT_STEPS.md` "active PR" line → points to CHECKPOINT
- **Archive:** `docs/history/session-reports/` (old checkpoints never archived individually; CHECKPOINT is overwritten in place, its history lives in git)
- **Owner:** Claude Code (as the **final action of every session**)
- **Update rule:** single file, overwritten each session. On resume it is read **first** and wins over every other file's "current state" claim.

### 3.5 Next-step guidance
- **Canonical:** `docs/status/NEXT_STEPS.md` *(was ROADMAP_AFTER_PR4A.md — renamed to a stable name)*
- **Supporting:** none
- **Archive:** never (living, updated per arc). Old guidance is not archived — it is overwritten; git holds the history.
- **Owner:** Claude Code
- **Update rule:** refreshed at the end of each PR arc. **Never** version-stamped in its filename.

### 3.6 Deferred QA bucket
- **Canonical:** `docs/status/MIGRATION_STATE.md` → *Deferred QA Bucket* section
- **Supporting:** any other mention is a pointer here (e.g. NEXT_STEPS removes its mirror copy)
- **Archive:** items, once verified, move to a "QA closed" log in `docs/history/`
- **Owner:** Claude Code
- **Update rule:** governance (post-PR6 sweep timing, 10-item ceiling) defined only here; one row per hypothesis, marked verified/unverified.

### 3.7 Known bugs / fragile areas
- **Canonical:** `docs/ai/KNOWN_PROBLEMS.md` (Tier 0)
- **Supporting:** `CLAUDE.md` non-negotiables reference fragile invariants but do not list bugs
- **Archive:** resolved bugs stay in-file under a "Resolved" fold (audit trail) — they are **not** deleted, so a fix is never re-attempted
- **Owner:** Claude Code
- **Update rule:** when a bug is fixed, **immediately** move it to "Resolved" with the fixing PR named. (This is exactly the B2 failure — the fix shipped but the open entry stayed.)

### 3.8 Design decisions (tokens, type, motion, do-nots)
- **Canonical (entry):** `docs/design-specs/INVESTIGATION_RECONCILIATION.md` (locked decisions — read first)
- **Sub-canonical:** tokens → `colors_and_type.css`; dark surfaces → `THEME_DARK_SPEC.md`; typography authority → `DESIGN_SYSTEM_GAP_VALIDATION.md`; decision logs → `PACKAGE_A_DECISIONS.md`, `PACKAGE_C_DECISIONS.md`; laws/vocabulary/do-nots → `SKILL.md`
- **Archive:** `docs/history/handoff-duplicates/` (older root copies)
- **Owner:** Claude Design (authored at SOURCE, mirrored read-only)
- **Update rule:** edited only at SOURCE; mirror replaced wholesale + `_SYNC.md` stamped. Never edited in the repo.

### 3.9 Per-PR design specs
- **Canonical:** the relevant `*_SPEC.md` in `docs/design-specs/` (STATS_KPI, CALENDAR_CELL, DUAL_DATE, ATHKAR, FOCUS_OIL, IOS_WIDGETS, ONBOARDING_AB, PRAYER_CARD)
- **Supporting:** `REDESIGN_AUDIT.md` (per-screen ticket map) points into each spec
- **Archive:** superseded spec versions → `docs/history/` with date
- **Owner:** Claude Design
- **Update rule:** one spec per feature; PR numbers never appear in spec filenames (a spec outlives its PR).

### 3.10 Architecture decisions (code)
- **Canonical:** `docs/ai/ARCHITECTURE_INDEX.md` + `docs/ai/STATE_MANAGEMENT_INDEX.md`; locked layout rules (RULE 1/2) in `MIGRATION_STATE.md`; non-negotiables in `CLAUDE.md`
- **Supporting:** `DATA_FLOW_INDEX.md`, `STATS_ENGINE_INDEX.md`, `SUPABASE_INDEX.md`, `WIDGET_INDEX.md`, `PROJECT_MAP.md`
- **Archive:** `ARCHITECTURE_STABILIZATION_REPORT.md`, `ADAPTIVESHELL_*` → `docs/history/`
- **Owner:** Claude Code
- **Update rule:** decisions are absorbed into the index/governance file, then the originating report is archived. Reports are never the canonical home of a live decision.

### 3.11 Pre-implementation audits
- **Canonical (while active):** `docs/design-context/_audit_<feature>.md`
- **Supporting:** the PR's Tier-2 spec
- **Archive:** on PR sign-off → `docs/history/pr-audits/` (after rulings are extracted into the spec/decision log)
- **Owner:** Claude Code authors; Claude Design rules on open questions and signs off
- **Update rule:** exactly one active audit per in-flight PR; promoted to history the moment the PR commits.

### 3.12 PR history / reports / sign-offs
- **Canonical (index):** `docs/history/ARCHIVE_INDEX.md` + a *Signed-off PRs* table in `MIGRATION_STATE.md`
- **Supporting:** individual reports under `docs/history/pr-reports/`
- **Archive:** that folder **is** the archive
- **Owner:** Claude Code
- **Update rule:** at PR sign-off, the verification artifact is the only thing kept active for one further PR cycle, then it too lands in `pr-reports/`. All other PR docs archive immediately on sign-off.

### 3.13 AI instructions / Claude rules
- **Canonical:** `CLAUDE.md` (always loaded)
- **Supporting:** `docs/ai/AI_WORKFLOW.md` (detailed reference; CLAUDE.md is the compressed always-on version)
- **Archive:** none (living)
- **Owner:** Product Owner approves; Claude Code drafts
- **Update rule:** CLAUDE.md is the compressed contract; AI_WORKFLOW expands it. If they disagree, CLAUDE.md wins (it is always loaded).

### 3.14 Skills / slash commands
- **Canonical:** `.claude/commands/*.md`
- **Supporting:** `CONTEXT_TIERS.md` references when to use them
- **Archive:** retired commands → `docs/history/`
- **Owner:** Claude Code
- **Update rule:** one command file per command; behavior documented in-file.

### 3.15 Handoff material (design → implementation)
- **Canonical:** `docs/design-specs/HANDOFF.md` + `FINAL_PACKAGE_MANIFEST.md` + `CLAUDE_CODE_PROMPT.md`
- **Supporting:** all consumed via the mirror
- **Archive:** root duplicates → `docs/history/handoff-duplicates/`
- **Owner:** Claude Design (at SOURCE)
- **Update rule:** mirror-only in the repo; the three root duplicates are retired.

### 3.16 AI context-loading strategy
- **Canonical:** `docs/governance/AI_CONTEXT_STRATEGY.md` (full) + `.claude/CONTEXT_TIERS.md` (terse operational copy)
- **Supporting:** a short "Context Loading" section in `CLAUDE.md` pointing to both
- **Archive:** none
- **Owner:** Claude Code (operational), Claude Design (strategy)
- **Update rule:** the terse `.claude/CONTEXT_TIERS.md` must always match the full strategy file; when tiers change, both update in one commit.

---

## 4. Domain summary table

| Domain | Canonical file | Owner |
|---|---|---|
| Roadmap + % | `docs/status/ROADMAP.md` | Code |
| Migration state / evidence / RULE 1·2 | `docs/status/MIGRATION_STATE.md` | Code |
| Implementation risk | `PROGRAM_IMPLEMENTATION_STATUS.md` | Code |
| Active PR / resume | `docs/progress/CHECKPOINT.md` | Code |
| Next-step guidance | `docs/status/NEXT_STEPS.md` | Code |
| Deferred QA | `MIGRATION_STATE.md` §QA | Code |
| Known bugs | `docs/ai/KNOWN_PROBLEMS.md` | Code |
| Design decisions | `docs/design-specs/INVESTIGATION_RECONCILIATION.md` | Design |
| Per-PR design specs | `docs/design-specs/*_SPEC.md` | Design |
| Code architecture | `docs/ai/ARCHITECTURE_INDEX.md` | Code |
| Pre-impl audits | `docs/design-context/_audit_*.md` | Code + Design |
| PR history | `docs/history/ARCHIVE_INDEX.md` | Code |
| AI instructions | `CLAUDE.md` | Human + Code |
| Skills | `.claude/commands/*.md` | Code |
| Handoff material | `docs/design-specs/HANDOFF.md` | Design |
| Context loading | `docs/governance/AI_CONTEXT_STRATEGY.md` | Code + Design |

---

## 5. How a new domain is added (so the system scales)

When the project grows a new knowledge area (e.g. the upcoming **ActivityEvent / AI analytics** track), the procedure is fixed:

1. Name the domain as a single question.
2. Designate **one** canonical file and **one** owner.
3. Register it in `CANONICAL_SOURCE_MAP.md` (the lookup) and in §3 here.
4. Decide its loading tier in `AI_CONTEXT_STRATEGY.md`.
5. If specs are involved, they are authored at SOURCE and mirrored — never created directly in the repo.

This is the same procedure that will absorb `ACTIVITY_EVENT_SPEC.md`, `PR-ACTIVITY`, and `PR-HEALTHKIT` without a re-architecture: each spec lands in `docs/design-specs/`, each PR gets a `ROADMAP.md` row and an `_audit_*.md`, and HealthKit's external-data concern gets one new index (`docs/ai/HEALTH_INTEGRATION_INDEX.md`) under the Code-owned architecture domain.
