# /drift-check — Tier-0 Agreement Check

**Purpose:** Confirm the four Tier-0 files agree. Five reads, no writes. Run before any PR sign-off.

---

## What to check

Read these 5 things in order:

1. **`docs/progress/CHECKPOINT.md`** — note: current PR + last commit SHA
2. **`IMPLEMENTATION_MASTER_STATUS.md`** — note: which PRs are marked ✅ Complete
3. **`docs/ai/KNOWN_PROBLEMS.md`** — note: every item in the OPEN sections
4. **`CURRENT_MIGRATION_STATE.md`** — note: "Active PR" and "Last commit"
5. **`.claude/CONTEXT_TIERS.md`** — confirm Tier 0 list matches this command's expectation

---

## Pass conditions (ALL must be true)

| Check | Pass condition |
|-------|---------------|
| **Active PR agrees** | CHECKPOINT "Active PR" == IMPLEMENTATION_MASTER_STATUS active row |
| **No ghost open bugs** | Every KNOWN_PROBLEMS "OPEN" item is genuinely open (not fixed by a shipped PR) |
| **% consistent** | IMPLEMENTATION_MASTER_STATUS % is derivable from the ✅ rows in its own PR table |
| **No Tier-0 dead paths** | No Tier-0 file references a path that no longer exists or is now archived |
| **CHECKPOINT is freshest** | CHECKPOINT last-updated date >= IMPLEMENTATION_MASTER_STATUS last-updated date |

---

## Failure actions

| Failure | Action |
|---------|--------|
| CHECKPOINT and ROADMAP disagree on active PR | Update the lower-precedence file to point to CHECKPOINT; never average |
| Open bug already fixed by a shipped PR | Move it to RESOLVED in the same session |
| % doesn't match PR table | Recompute % from the table; update in place |
| Dead path in Tier-0 | Fix the reference; do not silently ignore |

---

## Report format

```
/drift-check result — <date>

Tier-0 files read:
  1. CHECKPOINT.md — current PR: <x>, last commit: <sha>
  2. IMPLEMENTATION_MASTER_STATUS.md — complete PRs: <list>
  3. KNOWN_PROBLEMS.md — open items: <list or "none besides B1/P4">
  4. CURRENT_MIGRATION_STATE.md — active PR: <x>, last commit: <sha>
  5. .claude/CONTEXT_TIERS.md — Tier 0 list: matches / MISMATCH

Checks:
  Active PR agrees:        PASS / FAIL (<detail>)
  No ghost open bugs:      PASS / FAIL (<detail>)
  % consistent:            PASS / FAIL (<detail>)
  No dead Tier-0 paths:    PASS / FAIL (<detail>)
  CHECKPOINT freshest:     PASS / FAIL (<detail>)

Gate status: PASS (proceed) / FAIL (fix listed items before continuing)
```
