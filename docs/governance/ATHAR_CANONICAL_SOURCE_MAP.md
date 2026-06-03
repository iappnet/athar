<!--
CANONICAL-FOR: Mapping of every living file to its future clean name (Stage B target), owner, and zone
OWNER:         Claude Design
PRECEDENCE:    off-ladder (governance reference)
LAST-UPDATED:  2026-06-01 · Stage A
LOADS-AT:      off-ladder (read when planning Stage B moves)
-->

# Athar — Canonical Source Map

**Author:** Claude Design
**Date:** 2026-06-01
**Status:** Proposal — planning only.
**Owns:** the **precedence ladder** (who wins when files disagree) and the **one-file-per-domain lookup**. This is the fast-reference card; the reasoning lives in `KNOWLEDGE_ARCHITECTURE.md`.

---

## 1. The precedence ladder (conflict resolution)

When any two files disagree about the truth, the **higher** file wins. This ladder is absolute and project-wide.

```
1.  CLAUDE.md                              ← session behavior, non-negotiable rules
2.  docs/progress/CHECKPOINT.md            ← current session state (what is happening NOW)
3.  docs/status/ROADMAP.md                 ← PR sequence + completion %
4.  docs/status/MIGRATION_STATE.md         ← branch evidence, RULE 1/2, Deferred QA
5.  docs/design-specs/INVESTIGATION_RECONCILIATION.md  ← locked design decisions
6.  docs/design-specs/*  (other specs)     ← design detail
7.  docs/ai/* indexes                      ← code-navigation reference
─────────────────────────────────────────────────────────────────────────
ANY file not on this ladder that contradicts a file on it is STALE by definition.
Stale ⇒ update it to point at the canonical file, or archive it. Never "average" two sources.
```

Two tie-breakers worth stating explicitly:

- **"Now" beats "plan."** `CHECKPOINT.md` (level 2) outranks `ROADMAP.md` (level 3) for *current state* — if CHECKPOINT says "PR6 complete," every "next PR: PR6" line elsewhere is stale. ROADMAP still owns the *full sequence and %*.
- **Design source beats repo mirror.** A spec at SOURCE (designer workspace) outranks the repo's `docs/design-specs/` mirror. The `_SYNC.md` stamp tells you if the mirror is behind.

---

## 2. One canonical file per domain

> If a domain is not in this table, it does not yet have an owner — register it (see Knowledge Architecture §5) before writing about it.

| # | Domain (the question) | Canonical file | Owner | Tier |
|---|---|---|---|---|
| 1 | What are the session rules? | `CLAUDE.md` | Human/Code | 0 |
| 2 | What is happening right now? | `docs/progress/CHECKPOINT.md` | Code | 0 |
| 3 | What is the PR order + %? | `docs/status/ROADMAP.md` | Code | 0 |
| 4 | What's the branch/evidence/RULE/QA state? | `docs/status/MIGRATION_STATE.md` | Code | 1 |
| 5 | What should we do next? | `docs/status/NEXT_STEPS.md` | Code | 1 |
| 6 | What bugs/fragile areas exist? | `docs/ai/KNOWN_PROBLEMS.md` | Code | 0 |
| 7 | How does Claude Code operate? | `docs/ai/AI_WORKFLOW.md` | Code | 1 |
| 8 | What are the locked design decisions? | `docs/design-specs/INVESTIGATION_RECONCILIATION.md` | Design | 1 |
| 9 | What are the color/type tokens? | `docs/design-specs/colors_and_type.css` | Design | 2 |
| 10 | What are dark-mode surfaces? | `docs/design-specs/THEME_DARK_SPEC.md` | Design | 2 |
| 11 | What is the typography authority? | `docs/design-specs/DESIGN_SYSTEM_GAP_VALIDATION.md` | Design | 2 |
| 12 | What's the spec for feature X? | `docs/design-specs/<FEATURE>_SPEC.md` | Design | 2 |
| 13 | What screens map to what Dart files? | `docs/design-specs/REDESIGN_AUDIT.md` | Design | 2 |
| 14 | Where does feature X live in code? | `docs/ai/FEATURE_INDEX.md` | Code | 2 |
| 15 | Which cubit is which? | `docs/ai/STATE_MANAGEMENT_INDEX.md` | Code | 2 |
| 16 | How does data flow? | `docs/ai/DATA_FLOW_INDEX.md` | Code | 2 |
| 17 | What is the code architecture? | `docs/ai/ARCHITECTURE_INDEX.md` | Code | 2 |
| 18 | What's the pre-impl audit for PR X? | `docs/design-context/_audit_<x>.md` | Code/Design | 1–2 |
| 19 | What did completed PR X decide? | `docs/history/pr-reports/` + `MIGRATION_STATE.md` sign-off table | Code | 3 |
| 20 | What's the risk per PR? | `PROGRAM_IMPLEMENTATION_STATUS.md` | Code | 3 |
| 21 | What files load, and when? | `docs/governance/AI_CONTEXT_STRATEGY.md` + `.claude/CONTEXT_TIERS.md` | Code | 0 |
| 22 | What's archived, and where? | `docs/history/ARCHIVE_INDEX.md` | Code | 3 |
| 23 | What's the design read-order/handoff? | `docs/design-specs/HANDOFF.md` | Design | 1 |

---

## 3. Resolved duplications (this map's rulings)

The audit surfaced six files claiming overlapping authority. Each is resolved to exactly one canonical owner; the rest become pointers or history.

| Conflict | Canonical winner | The losers become |
|---|---|---|
| Roadmap across 5 files (IMPLEMENTATION_MASTER_STATUS, CURRENT_MIGRATION_STATE, PROGRAM_IMPLEMENTATION_STATUS, current_project_status, phase_tracker) | `ROADMAP.md` | MIGRATION_STATE keeps evidence only; PROGRAM keeps risk only (pointer); current_project_status → history; phase_tracker → history |
| "Next step" across 4 files (CHECKPOINT, NEXT_STEPS, current_project_status, ROADMAP) | `CHECKPOINT.md` for *now*, `NEXT_STEPS.md` for *guidance* | current_project_status loses its "Next PR" section; ROADMAP's "recommended next" points to NEXT_STEPS |
| `INVESTIGATION_REPORT.md` (root vs mirror, exact dup) | mirror `docs/design-specs/INVESTIGATION_REPORT.md` | root copy → `docs/history/handoff-duplicates/` |
| `FINAL_PACKAGE_MANIFEST.md` / `CLAUDE_CODE_PROMPT.md` (root vs mirror) | mirror versions | root copies → history |
| Design specs root/ vs handoff_v2-2/ | the single `docs/design-specs/` mirror, re-synced from SOURCE | `/Athar Design System/` root copies → history |
| `FILE_INDEX.md` vs `FEATURE_INDEX.md` | `FEATURE_INDEX.md` | FILE_INDEX merged in, then archived |

### The three "needs-human-review" items (do not auto-resolve)
1. **`PRAYER_CARD_SPEC.md` — 313 (root) vs 104 (mirror) vs 308 (SOURCE).** Ruling: the **SOURCE** (designer workspace, reconciled v2, ~308 lines) is canonical. Re-sync the mirror from SOURCE; archive both repo copies. Do **not** pick the 104-line mirror — it is a compressed stale copy. Human/designer confirms the SOURCE version is the PR3-reconciled one before the old copies are retired.
2. **`_required_uikit_components.md` (630 lines).** May still be a useful component checklist. Human review before archiving.
3. **`KNOWN_FUTURE_ASSETS.md`.** Merge live items (e.g. B4 adhan audio) into `MIGRATION_STATE.md` blockers, then archive.

---

## 3b. Legacy aliases (tombstoned, not bare-renamed)

These files adopt clean canonical names via Tombstone Migration (Governance §2b). The old name is **retained in place as an immutable redirect**, so every historical reference still resolves.

| Canonical (new) | Tombstone (old, retained) |
|---|---|
| `docs/status/ROADMAP.md` | `IMPLEMENTATION_MASTER_STATUS.md` |
| `docs/status/MIGRATION_STATE.md` | `CURRENT_MIGRATION_STATE.md` |
| `docs/status/NEXT_STEPS.md` | `ROADMAP_AFTER_PR4A.md` |
| `docs/ai/FEATURE_INDEX.md` (merge target) | `docs/ai/FILE_INDEX.md` |
| `docs/design-specs/` | `/Athar Design System/handoff_v2-2/` + repo-root spec copies |

An agent that encounters an old name finds a one-line tombstone pointing here — never a dead link, never stale content. Until Stage B runs, these new names are *targets*; the current files remain canonical under their present names.

---

## 4. Pointer pattern (how a non-canonical file references the truth)

Every supporting file that used to carry duplicated content gets a standard pointer block at the top of the section it no longer owns:

```markdown
> **Not canonical for this domain.**
> Source of truth: docs/status/ROADMAP.md (PR sequence + %).
> This file holds only <risk commentary / next-step guidance / …>.
> Last reconciled: <date>.
```

A pointer block is the *only* allowed alternative to deletion. A supporting file may never silently re-state canonical content.

---

## 5. Quick lookup — "I need to know X, I read Y"

| I need… | Read |
|---|---|
| …whether to start work / what's in flight | `CHECKPOINT.md` |
| …the next PR and the % done | `ROADMAP.md` |
| …if a bug is already known/fixed | `KNOWN_PROBLEMS.md` |
| …the locked design rules | `design-specs/INVESTIGATION_RECONCILIATION.md` |
| …the spec for the PR I'm building | `design-specs/<FEATURE>_SPEC.md` + `design-context/_audit_<feature>.md` |
| …where a feature's code lives | `ai/FEATURE_INDEX.md` |
| …what a finished PR decided | `history/pr-reports/` via `ARCHIVE_INDEX.md` |
| …what to load this session | `.claude/CONTEXT_TIERS.md` |
