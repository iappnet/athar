<!--
CANONICAL-FOR: Archive index of tombstone migrations
OWNER:         Claude Code
PRECEDENCE:    off-ladder
LAST-UPDATED:  2026-06-01 · B1 execute — 4 files tombstoned
LOADS-AT:      Tier 3
-->

# Migration Report — Tombstone Mapping

**Purpose:** Records every file rename executed via Tombstone Migration Procedure (TMP).  
**Rule:** One row per migration; never delete rows. Old names are retained in place as immutable redirects.

---

## Tombstone Log

| Old name (retained in place) | New canonical | Date | Stage | Notes |
|------------------------------|--------------|------|-------|-------|
| `IMPLEMENTATION_MASTER_STATUS.md` (root) | `docs/status/ROADMAP.md` | 2026-06-01 | B1 | SSOT for PR sequence, %, blockers |
| `CURRENT_MIGRATION_STATE.md` (root) | `docs/status/MIGRATION_STATE.md` | 2026-06-01 | B1 | Branch state, RULE 1/2, Deferred QA |
| `ROADMAP_AFTER_PR4A.md` (root) | `docs/status/NEXT_STEPS.md` | 2026-06-01 | B1 | Next-arc guidance, PR architecture |
| `docs/ai/FILE_INDEX.md` | merged → `docs/ai/FEATURE_INDEX.md` | 2026-06-01 | B1 | Entry Points, Core Services, Design System, Generated Files, Dead/Stub sections merged |

---

## Stage B progress

| Phase | Status | Commit |
|-------|--------|--------|
| B1 — Tombstone core files to clean names | ✅ Complete | (this commit) |
| B2 — Design-spec mirror | 🔲 Pending approval |  |
| B3 — Archive history | 🔲 Pending approval |  |
| B4 — Verify | 🔲 Pending approval |  |
