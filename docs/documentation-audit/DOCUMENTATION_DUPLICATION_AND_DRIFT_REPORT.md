# Documentation Duplication and Drift Report — Athar

**Date:** 2026-06-01  
**Auditor:** Claude Code  
**Risk level notation:** 🔴 High | 🟡 Medium | 🟢 Low

---

## SUMMARY

| Issue type | Count |
|-----------|-------|
| Exact or near-exact duplicates | 4 groups |
| Superseded-but-still-present files | 3 groups |
| Stale status / stale roadmap entries | 6 files |
| Conflicting PR state (says not-started when complete) | 2 files |
| Files referencing old handoff_v2 instead of handoff_v2-2 | 0 found |
| Files with stale "88 hardcoded files" stat (now migrating) | 2 files |
| Files with outdated "Stats cubit is stub" claim | 2 files |
| Files with outdated ThemeMode/B2 claim | 1 file |

---

## DRIFT GROUP 1 — Roadmap Status Drift 🔴

**Problem:** Multiple files carry PR status tables that contradict the declared SSOT (`IMPLEMENTATION_MASTER_STATUS.md`).

### 1a — PROGRAM_IMPLEMENTATION_STATUS.md
- **Location:** `/athar/PROGRAM_IMPLEMENTATION_STATUS.md`
- **Drift:** Table at Section 4 "Remaining Work" still lists `PR4a | Medium | CalendarCubit extension` as a remaining PR. PR4a is COMPLETE (tag `athar-v2-pr4a-complete`, 2026-06-01).
- **Risk:** 🔴 — A future Claude session reading this file could incorrectly believe PR4a is pending and attempt to redo it.
- **Fix required:** Update PR4a row to strike-through or remove it. Remaining count should be 10 → 9.

### 1b — current_project_status.md
- **Location:** `/athar/docs/progress/current_project_status.md`
- **Drift:**
  - "Next PR — PR5 / PR6 / PR8 / PR9" — PR5 is NOW COMPLETE, PR6 is IN PROGRESS
  - Does not mention PR5 completion or PR6 implementation
  - SocratiCode section says "2798 chunks, last updated 2026-05-03" — outdated
- **Risk:** 🟡 — Misleading "next PR" section; a session reading this without CHECKPOINT.md would miss PR5/PR6 state
- **Fix required:** Update "Next PR" section; update SocratiCode section; note PR5 complete, PR6 in progress.

### 1c — phase_tracker.md
- **Location:** `/athar/docs/progress/phase_tracker.md`
- **Drift:** Last updated 2026-05-09. Does not include PR3, PR-THEME FINAL, PR4a, PR5. Contains a roadmap table that was partially reduced per CHECKPOINT.md session but the Phase 0–3 sections still carry full detail for work that is now ancient history.
- **Risk:** 🟢 — Low impact because Claude Code doesn't read this file during implementation (it reads CHECKPOINT.md + IMPLEMENTATION_MASTER_STATUS.md). But it creates confusion in a manual review.
- **Fix required:** Mark as "Phase Track — historical record" and add pointer to IMPLEMENTATION_MASTER_STATUS.md.

### 1d — ROADMAP_AFTER_PR4A.md
- **Location:** `/athar/ROADMAP_AFTER_PR4A.md`
- **Drift:** "Active PR: PR5 — Dart complete, awaiting settings screenshot review before commit" — PR5 is now COMMITTED. PR6 is now active.
- **Risk:** 🟡 — Name of file is "After PR4a" but the content should reflect "after PR5 the active state is PR6"
- **Fix required:** Update Active PR section to reflect PR5 committed, PR6 implementing.

---

## DRIFT GROUP 2 — B2 / ThemeMode Bug Status Drift 🔴

**Problem:** `KNOWN_PROBLEMS.md` still lists B2 (`isAutoModeEnabled → ThemeMode not wired`) as OPEN, with target PR-THEME. PR-THEME is COMPLETE. This bug was fixed.

- **File:** `/athar/docs/ai/KNOWN_PROBLEMS.md` line 22–27
- **Says:** "B2: `isAutoModeEnabled` → `ThemeMode` not yet wired [...] Target PR: PR-THEME"
- **Reality:** PR-THEME is complete. `ThemePreference` enum replaced `isAutoModeEnabled`. `app.dart` now uses `AtharLightTheme`/`AtharDarkTheme`. This blocker is CLOSED.
- **Risk:** 🔴 — A future session reading KNOWN_PROBLEMS.md might attempt to "fix" B2, breaking existing PR-THEME work.
- **Fix required:** Mark B2 as RESOLVED (similar to P1/P2/P3 below the fold) with note: "Fixed in PR-THEME FINAL. `isAutoModeEnabled` field superseded by `ThemePreference` enum."

---

## DRIFT GROUP 3 — "Stats Cubit Is Stub" Drift 🟡

**Problem:** Two older files describe the Stats feature as a stub with no live data. This was true before PR6, but PR6 is now implementing the full stats redesign.

### 3a — design-context/_handoff_to_design_tool.md
- **Says:** "Stats: Cubit is essentially a stub. No live data aggregation."
- **Generated:** 2026-05-06
- **Reality:** `StatsRepositoryImpl` already had full Isar aggregation before PR6 (confirmed in _audit_stats.md). PR6 is now adding the visual layer.

### 3b — design-context/_project_design_context.md
- **Says:** "`lib/features/stats/` | Stub (cubit & repo mostly empty)"
- **Generated:** 2026-05-06
- **Reality:** Stats repository is fully implemented with task/habit/focus aggregation, TTL cache, and period-based queries.

**Risk:** 🟡 — These files may be read by Claude Design as part of understanding the current state. If Claude Design proposes a "build from scratch" approach for stats based on these files, it would be incorrect.
**Fix required:** Add stale notices to these files. Or supersede with current _audit_stats.md.

---

## DRIFT GROUP 4 — Duplicate Files (Exact or Near-Exact) 🔴

### 4a — INVESTIGATION_REPORT.md (exact duplicate)
- **Copy 1:** `/athar/INVESTIGATION_REPORT.md` (629 lines)
- **Copy 2:** `/athar/handoff_v2-2/INVESTIGATION_REPORT.md` (629 lines)
- **Status:** Exact duplicate. Same line count. Root copy serves no purpose.
- **Risk:** 🔴 — Two identical files creates confusion. If handoff_v2-2 version is ever updated, root copy drifts silently.
- **Recommended action:** Archive root copy. Canonical = handoff_v2-2.

### 4b — CLAUDE_CODE_PROMPT.md (near-duplicate)
- **Copy 1:** `/athar/CLAUDE_CODE_PROMPT.md` (129 lines)
- **Copy 2:** `/athar/handoff_v2-2/CLAUDE_CODE_PROMPT.md` (127 lines)
- **Status:** Near-duplicate (2-line difference). Root copy is the slightly longer one.
- **Risk:** 🟡 — Unclear which is authoritative. Two "implementation prompts" may give Claude Code different instructions.
- **Recommended action:** Reconcile. handoff_v2-2 should be canonical (it has INVESTIGATION_RECONCILIATION.md context). Archive root copy.

### 4c — FINAL_PACKAGE_MANIFEST.md (near-duplicate)
- **Copy 1:** `/athar/FINAL_PACKAGE_MANIFEST.md` (230 lines)
- **Copy 2:** `/athar/handoff_v2-2/FINAL_PACKAGE_MANIFEST.md` (229 lines)
- **Status:** Near-duplicate (1-line difference). Root copy is the slightly longer one.
- **Risk:** 🟡 — Same as 4b.
- **Recommended action:** Archive root copy. Canonical = handoff_v2-2.

### 4d — Design System root/ vs handoff_v2-2/ spec files
- **Problem:** 12 spec files exist in BOTH `/Athar Design System/` root AND `/handoff_v2-2/`. Three root-copy files are shorter (older) than their handoff_v2-2 counterparts:
  - `REDESIGN_AUDIT.md`: root 432 lines vs handoff_v2-2 485 lines ← root is older
  - `IPAD_OPTIMIZATION.md`: root 449 lines vs handoff_v2-2 451 lines ← root is older
  - `PRAYER_CARD_SPEC.md`: root 101 lines vs handoff_v2-2 104 lines ← root is older
- **Risk:** 🔴 — Claude Design reading the root versions would get an outdated spec. Specifically REDESIGN_AUDIT.md is 53 lines shorter — likely missing PR-related updates (bottom nav shape lock, FAB position, etc.).
- **Recommended action:** Designate `handoff_v2-2/` as canonical. Root/ spec files become archive.

---

## DRIFT GROUP 5 — PR3 Report Sprawl 🟡

**Problem:** PR3 has the most documentation of any completed PR — 13+ files in the root plus 3 in docs/pr3-artifacts/. Only `PR3_SIGNOFF.md` is a needed reference.

- Root files: `PR3_APPROVAL_REQUIRED_ITEMS.md`, `PR3_BEHAVIORAL_SOURCE_OF_TRUTH.md`, `PR3_BLOCKERS_AND_OPEN_ASSUMPTIONS.md`, `PR3_DESIGN_RULINGS.md`, `PR3_DOMAIN_AND_STATE_AUDIT.md`, `PR3_IMPLEMENTATION_PLAN.md`, `PR3_IMPLEMENTATION_READINESS_VERIFICATION.md`, `PR3_REQUIRED_DESIGN_CORRECTIONS.md`, `PR3_REUSE_AND_MIGRATION_MATRIX.md`, `PR3_RISK_REGISTER.md`, `PR3_SCREENSHOT_MATRIX.md`, `PR3_SIGNOFF.md`, `PR3_TECHNICAL_RECONCILIATION_REPORT.md`, `PR3_VISUAL_DENSITY_SIMULATION.md`, `PR3_VISUAL_READINESS_REPORT.md`, `CONSOLIDATED_REPORT_PR3.md`, `QUESTIONS_PR3.md`
- **Risk:** 🟡 — No active risk (PR3 complete), but 17 files for one completed PR is excessive noise that slows orientation.
- **Recommended action:** Archive all except `PR3_SIGNOFF.md`. Keep `docs/pr3-artifacts/` as the designated archive folder for PR3 history.

---

## DRIFT GROUP 6 — Stale Pre-PR1 Design-Context Files 🟡

**Problem:** Seven design-context files were generated in Phase 0 (2026-05-06) and describe a state of the app that predates ALL v2 work. They contain outdated:
- Font claims: "Cairo (AR) + Inter (EN)" — PR1 added Calibri
- Stats status: "cubit is stub"
- Calendar: "toggle only" (still true, but PR4a shipped)
- "88 files with hardcoded colors" — migration ongoing since PR1

Files:
- `_audit_current_flutter_ui.md` (348 lines, 2026-05-06)
- `_audit_design_system.md` (418 lines, 2026-05-06)
- `_design_gap_analysis.md` (362 lines, 2026-05-06)
- `_handoff_to_design_tool.md` (300 lines, 2026-05-06)
- `_implementation_strategy.md` (283 lines, 2026-05-06)
- `_pre_implementation_ui_audit.md` (450 lines, 2026-05-06)
- `_project_design_context.md` (213 lines, 2026-05-06)

**Risk:** 🟡 — If Claude Design reads `_handoff_to_design_tool.md` as the current handoff, it will have a stale picture. The file explicitly says "Phase 6 output, Generated: 2026-05-06."
**Recommended action:** Mark all 7 files with a stale header. Archive all except `_project_design_context.md` (which may still have useful context if updated).

---

## DRIFT GROUP 7 — Files Referencing Old handoff_v2 vs handoff_v2-2 🟢

**Finding:** Searched for references to `handoff_v2` (without `-2`) — did not find specific files pointing at the old location. The IMPLEMENTATION_MASTER_STATUS.md and CLAUDE.md both correctly reference `handoff_v2-2/`. No high-risk cross-reference drift detected here.

**Note:** The existence of the Design System root/ spec files (older versions) creates an implicit "old handoff" risk — any file that says "read REDESIGN_AUDIT.md" without specifying `handoff_v2-2/` could resolve to the shorter root version. HANDOFF.md at the root correctly references the files within the same directory (root/), so reading root/HANDOFF.md would lead to root/REDESIGN_AUDIT.md (older). Only reading `handoff_v2-2/HANDOFF.md` leads to the canonical versions.

---

## DRIFT GROUP 8 — Multiple "Next Session" Files 🟡

**Problem:** Four files each claim to describe what Claude Code should do next:
1. `CHECKPOINT.md` (canonical — always-read-first rule)
2. `ROADMAP_AFTER_PR4A.md` (active, but slightly stale — PR5 now committed)
3. `current_project_status.md` (stale — says "next PR: PR5/PR6/PR8/PR9")
4. `IMPLEMENTATION_MASTER_STATUS.md` (SSOT — "Recommended Next PR" section)

**Risk:** 🟡 — On session resume, a Claude session reads CHECKPOINT.md first (per AI_WORKFLOW.md). If it also reads ROADMAP_AFTER_PR4A.md or current_project_status.md, it encounters conflicting "current state" signals.
**Fix required:** ROADMAP_AFTER_PR4A.md and current_project_status.md "next PR" sections need updating.

---

## HIGHEST RISK ITEM

**B2 in KNOWN_PROBLEMS.md listing as OPEN when PR-THEME has FIXED it.** This is the single highest-risk drift because Claude Code is instructed to check KNOWN_PROBLEMS.md FIRST in the AI workflow funnel. A stale open bug could trigger incorrect remediation work on already-fixed code.

**Second highest risk:** PROGRAM_IMPLEMENTATION_STATUS.md listing PR4a as a remaining PR could trigger a duplicate PR4a implementation attempt.
