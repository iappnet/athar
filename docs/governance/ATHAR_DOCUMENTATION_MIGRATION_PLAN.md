<!--
CANONICAL-FOR: Stage A/B migration plan — what changes when, tombstone procedure, gate conditions
OWNER:         Claude Design
PRECEDENCE:    off-ladder (governance authority)
LAST-UPDATED:  2026-06-01 · Rev 3; Stage A in progress
LOADS-AT:      off-ladder (read when planning a Stage B migration)
-->

# Athar — Documentation Migration Plan (Two-Stage, Gated, Tombstone-Based)

**Author:** Claude Design
**Date:** 2026-06-01 · **Rev:** 3 (clean names ADOPTED via tombstone migration, per Product-Owner direction)
**Status:** Proposal — planning only. **No file is moved, renamed, or deleted by this document.**
**Reads with:** all five companion files. Targets the structure in `DOCUMENTATION_ARCHITECTURE.md`.

---

## 0. Two principles that govern this revision

1. **Governance before structure.** All anti-drift *value* (canonical ownership, headers, precedence, tiered loading, drift fixes) is delivered **without moving or renaming a single file** (Stage A). Reorganization comes only after governance is proven (Stage B).

2. **Adopt clean names — but via tombstone, never bare rename.** The clean names are better: shorter, clearer, not tied to a moment, valid after PR10/PR20/PR50. But a bare rename + delete would break project memory (old PR reports, prompts, reviews, git history reference the current names). So every rename is a **Tombstone Migration**: the new name becomes canonical, the old name is *retained in place as an immutable redirect*. Future clarity **and** past continuity — both preserved.

> Execution is split into two stages with a hard gate. Stage B (which includes the tombstone migrations) does not begin until the Stage-A gate has passed.

---

## The Tombstone Migration Procedure (TMP) — reusable standard

Used for every file that adopts a cleaner name. Five steps:

1. **CREATE** the new canonical file at its target path/name, with full content + the mandatory header. The header adds two fields:
   `LEGACY-ALIASES: <old name(s)>` and `CANONICAL-SINCE: <date>`.
2. **TOMBSTONE** the old file *in place* (it is kept forever):
   ```
   # Moved
   Canonical file: docs/status/ROADMAP.md
   Legacy file retained for historical compatibility. Do not update this file.
   ```
3. **REPOINT** every *new/active* reference to the new name (grep-and-repoint). Historical artifacts are left untouched — they resolve through the live tombstone.
4. **RECORD** the mapping (old → new, date) in `docs/governance/MIGRATION_REPORT.md`.
5. **NEVER** delete the tombstone; it is Tier-3 and never auto-loaded.

---

# STAGE A — Governance Only (zero moves, zero renames)

Additive (new files) or edit-in-place (existing files keep path + name). Fully reversible. Safe to run immediately. **Stage A uses current filenames everywhere** — the clean names are introduced only in Stage B.

## A1 — Drift fixes (in place) 🔴 — urgent, do first
| # | Fix | File (unchanged) | Action |
|---|---|---|---|
| 1 | B2 closed | `docs/ai/KNOWN_PROBLEMS.md` | Move B2 → Resolved ("Fixed in PR-THEME; isAutoModeEnabled → ThemePreference enum") |
| 2 | PR4a complete | `PROGRAM_IMPLEMENTATION_STATUS.md` | Strike PR4a "remaining" row |
| 3 | Next-PR stale | `docs/progress/current_project_status.md` | Replace "Next PR" with pointer to SSOT; note PR5+PR6 complete |
| 4 | Active-PR stale | `ROADMAP_AFTER_PR4A.md` | Update "Active PR" → PR6 complete |
| 5–6 | Stale Phase-0 | pre-PR1 `design-context/*` | Add stale banner |

## A2 — Install governance (additive) 🟢
- Place the six governance files + an empty `MIGRATION_REPORT.md` in `docs/governance/`.
- Create `.claude/CONTEXT_TIERS.md`, `.claude/commands/drift-check.md`.

## A3 — Headers + pointers, in place, CURRENT names 🟢 — the core value
- Add the mandatory header to each of the ~20 LIVING files **at current paths/names**.
- Add pointer blocks to supporting files, referencing canonical files **by current name** (e.g. `IMPLEMENTATION_MASTER_STATUS.md`).

## A4 — Loading directive, current names 🟢
- Add the Context Loading block to `CLAUDE.md`; fill `.claude/CONTEXT_TIERS.md` — all with current names.

---

## 🚦 STAGE A GATE — do not proceed to Stage B until ALL pass
1. `/drift-check` passes — the four Tier-0 files agree.
2. **One full PR arc** (e.g. PR4b kickoff) runs under the new governance: no new drift, correct tiered loading, ≥1 real "which file wins?" resolved by the precedence ladder.
3. No historical reference broken (guaranteed — nothing moved/renamed yet).
4. Product Owner confirms the governance delivers value and the structural follow-up is worth it.

If the gate fails, **stop at Stage A** — it is a complete, stable end-state on its own.

---

# STAGE B — Structural Migration (only after the gate passes)

Grouping + tombstone renames + spec-mirror consolidation + archiving. One focused session, while no design PR is consuming the specs.

## B1 — Tombstone-migrate the core files to clean names 🟡
Apply the **TMP** to each:

| New canonical (created) | Tombstone (retained in place) |
|---|---|
| `docs/status/ROADMAP.md` | `IMPLEMENTATION_MASTER_STATUS.md` |
| `docs/status/MIGRATION_STATE.md` | `CURRENT_MIGRATION_STATE.md` |
| `docs/status/NEXT_STEPS.md` | `ROADMAP_AFTER_PR4A.md` |
| `docs/ai/FEATURE_INDEX.md` (merge into existing) | `docs/ai/FILE_INDEX.md` |

- grep-and-repoint all active references; verify zero un-redirected *new* references before closing.
- Update the governance files' own references (Canonical Source Map, headers, CONTEXT_TIERS) to the new names.
- Populate `MIGRATION_REPORT.md` with the mapping table.

## B2 — Design-spec source/mirror 🔴 (decision-heavy)
- One mirror `docs/design-specs/`, re-synced **wholesale from SOURCE** + `_SYNC.md` stamp. The old locations (`/Athar Design System/handoff_v2-2/`, repo-root spec copies) are tombstoned/archived to `docs/history/handoff-duplicates/`.
- **DIFF BEFORE SYNC.** Resolve `PRAYER_CARD_SPEC.md` (root 313 vs mirror 104 vs SOURCE ~308): rescue unique notes from the 313 root into SOURCE first, then sync, then archive both stale copies.

## B3 — Archive history 🟢
- Move the ~82 candidates in safety order (A/C/E + change-logs first; arch reports after decision-extraction; Group D after stale banner). Delete only Group F (`missing_translations.txt`, `auto_checkpoint.md`).
- Populate `ARCHIVE_INDEX.md` as files land. Extraction-before-archive enforced.

## B4 — Verify 🟢
`/drift-check` passes · zero un-redirected new references · every old core-file path resolves to a live tombstone · one spec mirror with `_SYNC.md` · PRAYER_CARD resolved · every LIVING file headed · every history file indexed · `MIGRATION_REPORT.md` complete · no `docs/history/**` referenced as live.

---

## Rulings on Claude Code's 6 open questions (Rev 3)

| # | Question | Ruling |
|---|---|---|
| 1 | `PRAYER_CARD_SPEC.md` 313 vs 104 — canonical? | **SOURCE reconciled (~308)** is canonical. Diff the 313 root for unique notes → fold into SOURCE → re-sync mirror → archive both copies. (B2) |
| 2 | root/ vs handoff_v2-2/ — deprecate root? | **Yes** — one mirror re-synced from SOURCE; old locations tombstoned/archived. (B2) |
| 3 | `ROADMAP_AFTER_PR4A.md` successor — rename? | **Adopt `NEXT_STEPS.md` via Tombstone Migration** (TMP). New name canonical; old name retained as immutable redirect. Same applies to `IMPLEMENTATION_MASTER_STATUS → ROADMAP` and `CURRENT_MIGRATION_STATE → MIGRATION_STATE`. (B1) |
| 4 | `FILE_INDEX` vs `FEATURE_INDEX` — merge? | **Merge** into FEATURE_INDEX; tombstone FILE_INDEX. (B1) |
| 5 | audit lifecycle — archive after ship? | **Archive after ship** (extract rulings first). |
| 6 | `missing_translations.txt` — delete? | **Delete** (empty) + `auto_checkpoint.md`. (B3) |

---

## Risk register (Rev 3)

| Risk | Stage | Mitigation |
|---|---|---|
| Rename breaks historical references | B1 | **Eliminated by tombstone** — old name retained as a live redirect; nothing dead-links |
| Stale content lingers in the tombstone | B1 | Tombstone body is a 3-line redirect only; "Do not update" rule; never auto-loaded |
| Un-redirected *new* reference to old name | B1 | grep-and-repoint; verify zero before closing |
| Spec re-sync overwrites a real repo edit | B2 | diff-before-sync; pause on suspicious diffs |
| Live decision archived by mistake | B3 | extraction-before-archive (Governance §1) |
| Governance adds overhead without payoff | A-gate | gate requires a proven full PR arc before any structure work |

---

## Sequencing
- **Stage A now** — A1 (drift fixes) is urgent and free; A2–A4 additive/in-place. Stop at the gate.
- **Live in Stage A for ≥1 PR arc** (PR4b kickoff = natural probation).
- **Stage B only after the gate passes**, as one focused session; never interleaved with an active design PR. B2 needs a human/designer on the PRAYER_CARD diff.
