# Documentation Canonical Source Proposal — Athar

**Date:** 2026-06-01  
**Purpose:** One file per domain. No ambiguity about where the truth lives.

---

## PRINCIPLE

Every knowledge domain has exactly one canonical owner file.  
All other files that carry the same information are either:
- **Reduced** (replaced with a pointer to the canonical file)
- **Archived** (moved to docs/archive/ for history only)

---

## CANONICAL SOURCE MAP

---

### 1. Project Overview

**Canonical file:** `CLAUDE.md`  
**Location:** `/athar/CLAUDE.md`  
**Why:** Always loaded into Claude Code sessions. Contains app purpose, stack, key architecture, non-negotiable rules. Everything that must be known before touching any file.  
**Files to reduce:** `docs/ai/PROJECT_MAP.md` (pointer to CLAUDE.md), `design-context/_project_design_context.md` (stale Phase 0 output — archive)

---

### 2. Current Migration State

**Canonical file:** `CURRENT_MIGRATION_STATE.md`  
**Location:** `/athar/CURRENT_MIGRATION_STATE.md`  
**Why:** Contains: canonical branch, completed+tagged PRs with evidence, working tree state, RULE 1 + RULE 2 (locked), Deferred QA Bucket with governance rules. Purpose-built for "what is the exact state of the codebase right now."  
**Files to reduce:** `docs/progress/current_project_status.md` (detailed phase history — keep as history, remove "Next PR" section), `PROGRAM_IMPLEMENTATION_STATUS.md` (SSOT pointer already added for %, add for state too)

---

### 3. Roadmap (PR Sequence + Completion %)

**Canonical file:** `IMPLEMENTATION_MASTER_STATUS.md`  
**Location:** `/athar/IMPLEMENTATION_MASTER_STATUS.md`  
**Why:** Declared SSOT by governance closure. Contains all 14 PRs, completion %, blockers, accepted/deferred risks, token authority, handoff reference table.  
**Files to reduce:** `PROGRAM_IMPLEMENTATION_STATUS.md` (roadmap sections already replaced with pointers), `ROADMAP_AFTER_PR4A.md` (supplementary "next step" guidance — keep but mark as secondary), `phase_tracker.md` (archive)

---

### 4. Completed PRs (Evidence + Sign-offs)

**Canonical file:** `CURRENT_MIGRATION_STATE.md` (for commits + tags)  
**Sign-off artifacts:**
- PR2: `PR2_CHECKPOINTS.md` (keep in archive)
- PR3: `PR3_SIGNOFF.md` (keep, move to docs/pr3-artifacts/)
- PR-THEME FINAL: `VERIFICATION_PR_THEME.md`
- PR4a: `VERIFICATION_PR4A.md`  
**Index:** Add a "PR Sign-offs" table to `CURRENT_MIGRATION_STATE.md` pointing to each verification artifact  
**Files to archive:** All other PR*_*.md files not listed above

---

### 5. Active PR

**Canonical file:** `docs/progress/CHECKPOINT.md`  
**Why:** Always-read-first on session resume. Contains current PR, exact step, open decisions, working tree state. Updated as final action of every session.  
**Secondary:** `ROADMAP_AFTER_PR4A.md` "Active PR" section (supplementary)  
**Files to reduce:** `ROADMAP_AFTER_PR4A.md` "Active PR" section should point to CHECKPOINT.md

---

### 6. Deferred QA Bucket

**Canonical file:** `CURRENT_MIGRATION_STATE.md` (Deferred QA Bucket section)  
**Why:** Governance rules (post-PR6 sweep, 10-item ceiling) are defined here. Items already tracked here with IDs.  
**Files to reduce:** `ROADMAP_AFTER_PR4A.md` has a mirror of the QA bucket — this mirror should be replaced with a pointer to CURRENT_MIGRATION_STATE.md

---

### 7. Design Decisions (tokens, type, motion, do-nots)

**Canonical file:** `handoff_v2-2/SKILL.md` (design system rules)  
**Sub-canonical by domain:**
- Color + type tokens: `handoff_v2-2/colors_and_type.css`
- Dark surfaces override: `handoff_v2-2/THEME_DARK_SPEC.md`
- Typography authority: `handoff_v2-2/DESIGN_SYSTEM_GAP_VALIDATION.md`
- 5 locked decisions: `handoff_v2-2/INVESTIGATION_RECONCILIATION.md`
- 8 designer decisions: `handoff_v2-2/PACKAGE_A_DECISIONS.md`
- 12 follow-up decisions: `handoff_v2-2/PACKAGE_C_DECISIONS.md`

**Files to archive:** Design System root/ copies of these files (older versions — see REDESIGN_AUDIT.md 432 vs 485 lines)

---

### 8. Architecture Decisions

**Canonical files:**
- `docs/ai/AI_WORKFLOW.md` (operating rules, cubit discipline, workflow)
- `docs/ai/ARCHITECTURE_INDEX.md` (Clean Architecture, DI, Isar, Supabase patterns)
- `CURRENT_MIGRATION_STATE.md` RULE 1 + RULE 2 sections (locked layout rules)
- `CLAUDE.md` Non-Negotiable Rules section

**Files to archive:** `ARCHITECTURE_STABILIZATION_REPORT.md`, `ADAPTIVESHELL_FOUNDATION_AUDIT.md`, `ADAPTIVESHELL_ROLLOUT_STATUS.md` (all decisions absorbed into active governance)

---

### 9. Implementation Rules (tokens-only, audit-first, RTL, ARB)

**Canonical file:** `CLAUDE.md` (Design System Implementation Rules section)  
**Why:** These rules are in CLAUDE.md and therefore always loaded.  
**Secondary:** `docs/ai/AI_WORKFLOW.md` Design System Workflow section

---

### 10. Claude Code Operating Rules (execution caps, search discipline)

**Canonical file:** `CLAUDE.md` (EXECUTION SYSTEM + DECISION LOCK sections)  
**Secondary:** `docs/ai/AI_WORKFLOW.md` (EXECUTION RULES section — more detailed)  
**Relationship:** CLAUDE.md = compressed always-loaded version. AI_WORKFLOW.md = detailed reference.

---

### 11. Claude Design Handoff Rules

**Canonical file:** `handoff_v2-2/HANDOFF.md`  
**Why:** Explicitly addressed to Claude Design. Defines read order and architecture rules.  
**Secondary:** `handoff_v2-2/CLAUDE_CODE_PROMPT.md` (implementation entry point with locked decisions)  
**Files to archive:** `CLAUDE_CODE_PROMPT.md` root copy (near-duplicate of handoff version)

---

### 12. AI Context Loading

**Canonical file:** `docs/documentation-audit/AI_CONTEXT_LOADING_PROPOSAL.md` (new — see that file)  
**Pointer:** Add a section to `docs/ai/AI_WORKFLOW.md` pointing to the loading proposal

---

### 13. Archive Index

**Canonical file:** `docs/archive/ARCHIVE_INDEX.md` (to be created when archiving begins)  
**Current status:** No archive folder exists yet. See DOCUMENTATION_ARCHIVE_CANDIDATES.md for what would go there.

---

### 14. PR Reports Index

**Canonical file:** `CURRENT_MIGRATION_STATE.md` (Signed-Off PRs table)  
**Detail:** Each completed PR has a sign-off artifact. These are listed in CURRENT_MIGRATION_STATE.md.  
**Archive location:** `docs/archive/pr-reports/` (to be created)

---

### 15. Design System Source Map

**Canonical file:** `IMPLEMENTATION_MASTER_STATUS.md` (Token Authority section)  
**Summary of the map:**
- Light tokens → `handoff_v2-2/colors_and_type.css`
- Dark surfaces/text → `handoff_v2-2/THEME_DARK_SPEC.md`
- Typography → `handoff_v2-2/DESIGN_SYSTEM_GAP_VALIDATION.md`
- Prayer card gradient → `athar_colors.dart` static const

---

## VISUAL MAP — Files That Point to Each Other

```
CHECKPOINT.md
  ← always read first on resume
  ← points to: IMPLEMENTATION_MASTER_STATUS.md for PR sequence + %
  ← points to: ROADMAP_AFTER_PR4A.md for next-step guidance

IMPLEMENTATION_MASTER_STATUS.md (SSOT: roadmap + %)
  ← handoff reference table → handoff_v2-2/FINAL_PACKAGE_MANIFEST.md
  ← token authority → handoff_v2-2/colors_and_type.css + THEME_DARK_SPEC.md
  ← points to: CURRENT_MIGRATION_STATE.md for working-tree state

CURRENT_MIGRATION_STATE.md (SSOT: migration evidence + QA + RULE 1/2)
  ← verified PR evidence → commit hashes + file references
  ← Deferred QA Bucket → device-verified hypotheses
  ← RULE 1 + RULE 2 → layout discipline

CLAUDE.md (always loaded — project instructions)
  ← design system rules → handoff_v2-2/ read order
  ← execution caps → AI_WORKFLOW.md for detail
  ← known problems → KNOWN_PROBLEMS.md

handoff_v2-2/INVESTIGATION_RECONCILIATION.md (READ FIRST for any design PR)
  ← supersedes all older specs
  ← locked 5 decisions
  ← points to: PACKAGE_A/C_DECISIONS.md, REDESIGN_AUDIT.md, etc.
```

---

## KEY RULE

When two files disagree, precedence is:

1. `CLAUDE.md` — for session behavior
2. `IMPLEMENTATION_MASTER_STATUS.md` — for PR roadmap + %
3. `CURRENT_MIGRATION_STATE.md` — for migration evidence + rules
4. `handoff_v2-2/INVESTIGATION_RECONCILIATION.md` — for design decisions
5. `docs/progress/CHECKPOINT.md` — for current session state

Any file not in this list that contradicts these five is STALE and should be updated or archived.
