# Documentation Restructure Input — For Claude Design

**Date:** 2026-06-01  
**From:** Claude Code (implementation agent)  
**To:** Claude Design (design architecture agent)  
**Subject:** Complete documentation state analysis + restructure recommendations

---

## EXECUTIVE SUMMARY

The Athar project has accumulated **151 documentation files** across 6 locations. The documentation was created organically during an intensive implementation sprint and has not been architecturally designed. The result is:

- A functional but bloated knowledge system
- Multiple files claiming authority over the same domain
- ~82 files that are historical artifacts and should be archived
- 6 active drift problems that could mislead future sessions
- A core of ~20 genuinely active, well-maintained files

The restructure goal is: **reduce the active documentation surface to ~20 canonical files, archive the rest, and make the authority hierarchy unambiguous.**

---

## CURRENT PROBLEM STATEMENT

### Problem 1: Too Many Files Claim Authority Over Roadmap

Five files all carry PR ordering and status information:
1. `IMPLEMENTATION_MASTER_STATUS.md` — declared SSOT
2. `CURRENT_MIGRATION_STATE.md` — also carries PR list (evidence-focused)
3. `PROGRAM_IMPLEMENTATION_STATUS.md` — carries roadmap sections (partially reduced)
4. `current_project_status.md` — carries completed work + next PR sections
5. `phase_tracker.md` — carries PR ordering (stale, last updated 2026-05-09)

Only `IMPLEMENTATION_MASTER_STATUS.md` should own the roadmap. The others need to be reduced to pointers or archived.

### Problem 2: Completed-PR Reports Scattered at Root

The `/athar/` root directory contains 40+ PR report files from completed PRs (PR1, PR2, PR3, PR-THEME, PR4a). These files are historical artifacts but they are in the same directory as active governance files. Orientation is difficult.

### Problem 3: Two Design System Locations — Unclear Which Is Canonical

**`/Athar Design System/` root** contains one set of spec files.  
**`/Athar Design System/handoff_v2-2/`** contains an updated set of the same files, plus 8 critical files that only exist in handoff_v2-2/:
- `INVESTIGATION_RECONCILIATION.md` (locked decisions — READ FIRST for any design PR)
- `DESIGN_SYSTEM_GAP_VALIDATION.md` (Calibri authority lockdown)
- `PACKAGE_C_DECISIONS.md` (12 follow-up decisions)
- `THEME_DARK_SPEC.md` (dark surface treatments)
- `ONBOARDING_AB_SPEC.md`
- `INVESTIGATION_REPORT.md`
- `CLAUDE_CODE_PROMPT.md`
- `FINAL_PACKAGE_MANIFEST.md`

Three spec files in the root/ are demonstrably older (fewer lines) than their handoff_v2-2 counterparts. Any agent reading the root/ directory instead of handoff_v2-2/ gets a stale spec.

### Problem 4: B2 Bug Listed as Open When It's Fixed

`docs/ai/KNOWN_PROBLEMS.md` still lists B2 ("isAutoModeEnabled → ThemeMode not wired") as open with "Target PR: PR-THEME." PR-THEME is complete. This is the highest-risk documentation drift — a session reading KNOWN_PROBLEMS.md first (as mandated) could attempt to re-implement a fix that already shipped.

### Problem 5: Pre-PR1 Design-Context Files Present as Current

7 files in `design-context/` were generated in Phase 0 (2026-05-06) and describe the app BEFORE any v2 work:
- They say "Cairo + Inter fonts" (PR1 added Calibri)
- They say "Stats cubit is stub" (Stats was always more complete)
- They have the old gap analysis (partially obsoleted by completed PRs)

If Claude Design reads `design-context/_handoff_to_design_tool.md` (created specifically to brief Claude Design), it would get a stale picture of the Flutter app.

### Problem 6: Three Root-Level Duplicates of handoff_v2-2 Files

Three files in the `/athar/` root are near-exact copies of canonical files in `handoff_v2-2/`:
- `INVESTIGATION_REPORT.md` (629 lines = exact duplicate)
- `FINAL_PACKAGE_MANIFEST.md` (230 vs 229 lines)
- `CLAUDE_CODE_PROMPT.md` (129 vs 127 lines)

---

## DOCUMENTATION STATISTICS

| Metric | Count |
|--------|-------|
| Total files scanned | 151 |
| Actively maintained files | ~20 |
| Archive candidates | ~82 |
| Exact or near-exact duplicate groups | 4 |
| Stale status files | 6 |
| Active drift problems | 6 |
| Files with authority conflict | 5 (roadmap domain) |

---

## FILE CATEGORIES AND COUNTS

| Category | Files | Action |
|----------|-------|--------|
| Active governance (always-read) | 7 | Keep |
| Active PR specs (read for current PR) | 6 | Keep active |
| Design spec canon (handoff_v2-2/) | 24 | Keep |
| Completed PR reports + sign-offs | ~37 | Archive all except 4 sign-offs |
| Widget phase history | 6 | Archive |
| Pre-PR1 design-context audits | 8 | Archive |
| One-off session reports | 12 | Archive |
| Change logs | 21 | Archive |
| Near-exact root duplicates | 3 | Archive root copy |
| AI index files (docs/ai/) | 11 | Keep |
| Claude commands (.claude/commands/) | 5 | Keep |
| Config files (.yaml, .json) | ~5 | Keep |

---

## MAJOR DRIFT PROBLEMS (ORDERED BY RISK)

1. **🔴 B2 in KNOWN_PROBLEMS.md listed as OPEN** — ThemeMode IS wired (PR-THEME complete)
2. **🔴 PR4a listed as remaining in PROGRAM_IMPLEMENTATION_STATUS.md** — PR4a is COMPLETE
3. **🔴 Design System root/ REDESIGN_AUDIT.md is 53 lines shorter than handoff_v2-2/** — older version
4. **🟡 current_project_status.md says "Next PR: PR5/PR6/PR8/PR9"** — PR5 committed, PR6 implementing
5. **🟡 ROADMAP_AFTER_PR4A.md says "Active PR: PR5 awaiting review"** — PR5 committed
6. **🟡 pre-PR1 design-context files describe app before Calibri, before token migration**

---

## RECOMMENDED CANONICAL FILE MAP

| Domain | Canonical file |
|--------|---------------|
| Session instructions | `CLAUDE.md` |
| Session resume state | `docs/progress/CHECKPOINT.md` |
| PR roadmap + % | `IMPLEMENTATION_MASTER_STATUS.md` |
| Migration evidence + RULE 1/2 + QA | `CURRENT_MIGRATION_STATE.md` |
| Next-step guidance | `ROADMAP_AFTER_PR4A.md` |
| Known bugs + fragile areas | `docs/ai/KNOWN_PROBLEMS.md` |
| Operating workflow | `docs/ai/AI_WORKFLOW.md` |
| Feature entry files | `docs/ai/FEATURE_INDEX.md` |
| Architecture | `docs/ai/ARCHITECTURE_INDEX.md` |
| Cubit disambiguation | `docs/ai/STATE_MANAGEMENT_INDEX.md` |
| Design spec entry | `handoff_v2-2/INVESTIGATION_RECONCILIATION.md` |
| Token source | `handoff_v2-2/colors_and_type.css` |
| Dark mode override | `handoff_v2-2/THEME_DARK_SPEC.md` |
| Per-screen tickets | `handoff_v2-2/REDESIGN_AUDIT.md` |
| PR4b spec | `DUAL_DATE_SPEC.md` + `handoff_v2-2/CALENDAR_CELL_SPEC.md` |
| PR6 spec | `handoff_v2-2/STATS_KPI_SPEC.md` |

---

## PROPOSED ARCHIVE CANDIDATES (82 files)

- ~51 completed PR reports + 21 change logs → `docs/archive/pr-reports/`
- 3 root duplicates → `docs/archive/handoff-duplicates/`
- 6 widget phase history → `docs/archive/widget-phase/`
- 8 pre-PR1 design-context → `docs/archive/phase0-audits/`
- 12 session reports → `docs/archive/session-reports/`
- 2 deletions (empty/superseded)

Full list: see `DOCUMENTATION_ARCHIVE_CANDIDATES.md`

---

## UNRESOLVED QUESTIONS FOR CLAUDE DESIGN

1. **PRAYER_CARD_SPEC.md disambiguation:**  
   `/athar/PRAYER_CARD_SPEC.md` is 313 lines. `handoff_v2-2/PRAYER_CARD_SPEC.md` is 104 lines.  
   The root version is 3× longer. Is the root version an earlier expanded spec, a draft, or does it contain implementation decisions not in the canonical version?  
   → **Claude Design decision required:** Which is canonical? Or should they be merged?

2. **Design System root/ vs handoff_v2-2/ resolution:**  
   The Design System root/ folder (`/Athar Design System/`) has files that appear to be predecessors of `handoff_v2-2/`. The root HANDOFF.md reads `REDESIGN_AUDIT.md` without specifying a subfolder — it would resolve to the root version (older).  
   → **Claude Design decision required:** Should the root/ spec files be explicitly deprecated? Should HANDOFF.md at root be updated to point to handoff_v2-2/ versions?

3. **ROADMAP_AFTER_PR4A.md successor:**  
   The current next-step guidance doc is named for PR4a. After PR6 ships and the post-PR6 QA sweep runs, this file will be significantly outdated.  
   → **Claude Design decision required:** Should a new `ROADMAP_AFTER_PR6.md` be created, or should the existing file be updated in place with a new title?

4. **docs/ai/FILE_INDEX.md vs FEATURE_INDEX.md:**  
   Both cover file-to-feature mapping (103 lines vs 416 lines). Unknown if FILE_INDEX.md is up-to-date.  
   → **Claude Design decision required:** Merge into FEATURE_INDEX.md, or does FILE_INDEX serve a different purpose?

5. **design-context/ active audits future:**  
   Currently: one audit per PR, stored in `design-context/`. After PR6 there will be audits for PR6, PR4b (plus the calendar dual audit), PR5 (complete). Over 14 PRs this folder will accumulate 14+ audit files.  
   → **Claude Design decision required:** Should completed PR audits be moved to `docs/archive/pr-audits/` after the PR ships? Or kept in `design-context/` for reference?

6. **missing_translations.txt:**  
   Empty file at project root. Should it be deleted?  
   → Simple cleanup — can be confirmed and deleted.

---

## PROPOSED DOCUMENTATION ARCHITECTURE (FOR CLAUDE DESIGN TO EVALUATE)

```
/athar/
├── CLAUDE.md                              ← always loaded (session contract)
├── IMPLEMENTATION_MASTER_STATUS.md        ← SSOT: roadmap + % + blockers
├── CURRENT_MIGRATION_STATE.md             ← SSOT: evidence + RULE 1/2 + QA bucket
├── ROADMAP_AFTER_PR4A.md                  ← next-step guidance (living, updated per arc)
├── DUAL_DATE_SPEC.md                      ← PR4b spec (move to design-context/ when active)
│
├── docs/
│   ├── ai/                                ← Claude Code reference (not session-auto-loaded)
│   │   ├── KNOWN_PROBLEMS.md              ← Tier 0 (bugs + fragile areas)
│   │   ├── AI_WORKFLOW.md                 ← operating rules reference
│   │   ├── FEATURE_INDEX.md               ← feature entry files
│   │   ├── ARCHITECTURE_INDEX.md          ← architecture reference
│   │   ├── STATE_MANAGEMENT_INDEX.md      ← cubit disambiguation
│   │   ├── DATA_FLOW_INDEX.md             ← flow tracing
│   │   ├── STATS_ENGINE_INDEX.md          ← stats feature (PR6)
│   │   ├── SUPABASE_INDEX.md              ← Supabase patterns
│   │   ├── WIDGET_INDEX.md                ← iOS widget reference (PR9)
│   │   └── PROJECT_MAP.md                 ← project orientation
│   │
│   ├── progress/
│   │   └── CHECKPOINT.md                  ← Tier 0 (session resume — single file)
│   │
│   ├── documentation-audit/               ← this audit's outputs
│   │   ├── DOCUMENTATION_INVENTORY_AUDIT.md
│   │   ├── DOCUMENTATION_DUPLICATION_AND_DRIFT_REPORT.md
│   │   ├── DOCUMENTATION_CANONICAL_SOURCE_PROPOSAL.md
│   │   ├── DOCUMENTATION_ARCHIVE_CANDIDATES.md
│   │   ├── AI_CONTEXT_LOADING_PROPOSAL.md
│   │   └── DOCUMENTATION_RESTRUCTURE_INPUT_FOR_CLAUDE_DESIGN.md
│   │
│   └── archive/                           ← historical only, never auto-loaded
│       ├── pr-reports/                    ← completed PR report files
│       ├── handoff-duplicates/            ← root copies of handoff_v2-2 files
│       ├── widget-phase/                  ← Phase 0–4 widget development history
│       ├── phase0-audits/                 ← pre-PR1 design-context files
│       └── session-reports/               ← one-off session snapshots
│
├── design-context/
│   ├── _audit_stats.md                    ← PR6 active audit
│   ├── _audit_calendar_dual.md            ← PR4b active audit
│   └── [completed audits move to archive after PR ships]
│
/Athar Design System/handoff_v2-2/         ← CANONICAL design specs (designer's domain)
│   ├── INVESTIGATION_RECONCILIATION.md    ← READ FIRST for any design PR
│   ├── colors_and_type.css                ← token source of truth (light + dark)
│   ├── THEME_DARK_SPEC.md                 ← dark surface override
│   ├── REDESIGN_AUDIT.md                  ← per-screen ticket map (canonical 485 lines)
│   ├── STATS_KPI_SPEC.md                  ← PR6 spec
│   ├── FOCUS_OIL_SPEC.md                  ← PR8 spec
│   ├── CALENDAR_CELL_SPEC.md              ← PR4b visual spec
│   ├── CALENDAR_FOCUS_REDESIGN.md         ← calendar brief
│   ├── ATHKAR_SPEC.md                     ← PR7 spec
│   ├── ONBOARDING_AB_SPEC.md              ← PR-ONBOARD-AB spec
│   ├── IOS_WIDGETS_SPEC.md                ← PR9 spec
│   ├── IPAD_OPTIMIZATION.md               ← iPad layouts
│   └── [all other canonical specs]
```

---

## WHAT CLAUDE DESIGN SHOULD DECIDE

1. **Approve or modify the proposed architecture above** — file locations, folder structure
2. **Resolve the PRAYER_CARD_SPEC.md (313 lines) question** — root vs handoff_v2-2 version
3. **Resolve the Design System root/ deprecation** — HANDOFF.md update, explicit pointer to handoff_v2-2/
4. **ROADMAP_AFTER_PR4A.md successor strategy** — update in place or versioned replacement
5. **design-context/ audit file lifecycle** — keep completed audits or archive after PR ships
6. **Approve archive candidates list** — confirm it's safe to archive the listed files

---

## WHAT CLAUDE CODE SHOULD DO AFTER APPROVAL

1. Fix the 6 active drift problems (priority: B2 in KNOWN_PROBLEMS.md first)
2. Move archive candidates to docs/archive/ folders
3. Update PROGRAM_IMPLEMENTATION_STATUS.md PR4a row
4. Update current_project_status.md "Next PR" section
5. Update ROADMAP_AFTER_PR4A.md "Active PR" section
6. Add stale notices to pre-PR1 design-context files
7. Add archive index at docs/archive/ARCHIVE_INDEX.md

---

## IS THIS READY TO SEND TO CLAUDE DESIGN?

Yes. This document contains:
- ✅ Current documentation problem (6 major issues)
- ✅ File categories with counts
- ✅ Summary statistics (151 files, 20 active, 82 archive candidates)
- ✅ Major drift problems with risk ratings
- ✅ Recommended canonical files
- ✅ Proposed archive candidates (with groupings)
- ✅ Unresolved questions requiring designer decisions
- ✅ Proposed target architecture
- ✅ No Dart code modified; no files moved or deleted
