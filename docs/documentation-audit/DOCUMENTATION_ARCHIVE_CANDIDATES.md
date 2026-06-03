# Documentation Archive Candidates — Athar

**Date:** 2026-06-01  
**Note:** These are candidates only. Do NOT move or delete until the designer approves the restructure plan.

---

## ARCHIVE DEFINITION

An archived file:
- Exists in read-only `docs/archive/` (or a subfolder)
- Is NOT loaded by Claude Code during normal work
- Is NOT edited
- Exists as a permanent audit trail
- Is accessible via `ARCHIVE_INDEX.md` if needed for historical lookups

---

## GROUP A — Completed PR Reports (Historical)

These files served their purpose during the PR they document. PR is complete, sign-off exists, key decisions absorbed into canonical files.

**Suggested destination:** `docs/archive/pr-reports/`

| File | Reason | Keep? |
|------|--------|-------|
| `PR1_FINAL_REPORT.md` | PR1 complete, history captured | Archive |
| `PR1_IMPLEMENTATION_PREVIEW.md` | Pre-implementation preview, superseded | Archive |
| `PR2_CHECKPOINTS.md` | PR2 complete, checkpoints historical | Archive |
| `PR2_FINAL_READINESS_REPORT.md` | PR2 complete | Archive |
| `PR2_IMPLEMENTATION_PLAN.md` | PR2 complete | Archive |
| `PR2_PROGRESS_REPORT.md` | PR2 complete | Archive |
| `PR2_READINESS_PREVIEW.md` | Pre-implementation preview, superseded | Archive |
| `PR2_SCOPE_RECONCILIATION_REPORT.md` | PR2 complete | Archive |
| `PR3_APPROVAL_REQUIRED_ITEMS.md` | PR3 complete | Archive |
| `PR3_BEHAVIORAL_SOURCE_OF_TRUTH.md` | PR3 complete — decisions in SIGNOFF | Archive |
| `PR3_BLOCKERS_AND_OPEN_ASSUMPTIONS.md` | PR3 complete | Archive |
| `PR3_DESIGN_RULINGS.md` | PR3 complete | Archive |
| `PR3_DOMAIN_AND_STATE_AUDIT.md` | PR3 complete | Archive |
| `PR3_IMPLEMENTATION_PLAN.md` | PR3 complete | Archive |
| `PR3_IMPLEMENTATION_READINESS_VERIFICATION.md` | PR3 complete | Archive |
| `PR3_REQUIRED_DESIGN_CORRECTIONS.md` | PR3 complete | Archive |
| `PR3_REUSE_AND_MIGRATION_MATRIX.md` | PR3 complete | Archive |
| `PR3_RISK_REGISTER.md` | PR3 complete | Archive |
| `PR3_SCREENSHOT_MATRIX.md` | PR3 complete | Archive |
| `PR3_SIGNOFF.md` | ✅ KEEP as reference — sign-off artifact | Keep in root or docs/ |
| `PR3_TECHNICAL_RECONCILIATION_REPORT.md` | PR3 complete | Archive |
| `PR3_VISUAL_DENSITY_SIMULATION.md` | PR3 complete | Archive |
| `PR3_VISUAL_READINESS_REPORT.md` | PR3 complete | Archive |
| `PR4A_READINESS_SCOPE.md` | PR4a complete, planning doc | Archive |
| `PR_THEME_IMPLEMENTATION_PREVIEW.md` | PR-THEME complete, preview superseded | Archive |
| `PR_THEME_READINESS_REPORT.md` | PR-THEME complete | Archive |
| `PR_THEME_3MODE_PREVIEW.md` | PR-THEME-3MODE complete, preview superseded | Archive |
| `CONSOLIDATED_REPORT_PR3.md` | PR3 complete | Archive |
| `QUESTIONS_PR3.md` | PR3 complete | Archive |
| `docs/pr3-artifacts/SCREENSHOTS_PR3.md` | Historical | Archive |
| `docs/pr3-artifacts/VERIFICATION_PR3.md` | Historical | Archive |
| `docs/ai/change-logs/` (all 21 files) | Historical session logs | Archive |

**Active reference files to keep:**
- `PR3_SIGNOFF.md`
- `PR4A_FINAL_REPORT.md`
- `PR_THEME_FINAL_REPORT.md`
- `PR_THEME_3MODE_FINAL_REPORT.md`
- `VERIFICATION_PR_THEME.md`
- `VERIFICATION_PR4A.md`

---

## GROUP B — Duplicate Files

Files that are exact or near-exact copies of canonical handoff_v2-2/ versions.

**Suggested destination:** `docs/archive/handoff-duplicates/`

| File | Canonical version | Reason |
|------|-----------------|--------|
| `/athar/INVESTIGATION_REPORT.md` | `handoff_v2-2/INVESTIGATION_REPORT.md` | Exact duplicate (629 lines each) |
| `/athar/FINAL_PACKAGE_MANIFEST.md` | `handoff_v2-2/FINAL_PACKAGE_MANIFEST.md` | Near-duplicate (230 vs 229 lines) |
| `/athar/CLAUDE_CODE_PROMPT.md` | `handoff_v2-2/CLAUDE_CODE_PROMPT.md` | Near-duplicate (129 vs 127 lines) |

**Design System root/ vs handoff_v2-2/ duplicates:**

| Design System root/ file | Canonical version | Note |
|--------------------------|------------------|-------|
| `REDESIGN_AUDIT.md` (root) | `handoff_v2-2/REDESIGN_AUDIT.md` | Root is 53 lines shorter — older |
| `IPAD_OPTIMIZATION.md` (root) | `handoff_v2-2/IPAD_OPTIMIZATION.md` | Root is 2 lines shorter — older |
| `PRAYER_CARD_SPEC.md` (root, 101 lines) | `handoff_v2-2/PRAYER_CARD_SPEC.md` (104 lines) | Root is older |
| `HANDOFF.md` (root) | `handoff_v2-2/HANDOFF.md` | Same size — verify content |
| `SKILL.md` (root) | `handoff_v2-2/SKILL.md` | Same size — verify content |
| `STATS_KPI_SPEC.md` (root) | `handoff_v2-2/STATS_KPI_SPEC.md` | Same size |
| `FOCUS_OIL_SPEC.md` (root) | `handoff_v2-2/FOCUS_OIL_SPEC.md` | Same size |
| `CALENDAR_FOCUS_REDESIGN.md` (root) | `handoff_v2-2/CALENDAR_FOCUS_REDESIGN.md` | Same size |
| `CALENDAR_CELL_SPEC.md` (root) | `handoff_v2-2/CALENDAR_CELL_SPEC.md` | Same size |
| `COMPONENT_SPECS.md` (root) | `handoff_v2-2/COMPONENT_SPECS.md` | Same size |
| `ATHKAR_SPEC.md` (root) | `handoff_v2-2/ATHKAR_SPEC.md` | Same size |
| `IOS_WIDGETS_SPEC.md` (root) | `handoff_v2-2/IOS_WIDGETS_SPEC.md` | Same size |
| `PACKAGE_A_DECISIONS.md` (root) | `handoff_v2-2/PACKAGE_A_DECISIONS.md` | Same size |

**Note:** Design System root files cannot be archived without designer approval — they are in the designer's workspace, not the Flutter repo.

---

## GROUP C — Historical Phase Track Files

Files from the widget-development phase (Phases 0–5), now complete.

**Suggested destination:** `docs/archive/widget-phase/`

| File | Last updated | Reason |
|------|-------------|--------|
| `docs/progress/phase_checkpoint.md` | 2026-05-03 area | Phase 0–4 checkpoints, all historical |
| `docs/progress/BUGFIX_PHASE_STATUS.md` | 2026-05-06 | All bugfix phases complete |
| `docs/progress/prayer_widget_fix_checkpoint.md` | 2026-05-06 area | Prayer widget phases complete |
| `docs/progress/auto_checkpoint.md` | Unknown | 12-line auto snapshot, superseded |
| `docs/ai/reports/AI_ARCHITECTURE_ALIGNMENT_AUDIT_2026-05-04.md` | 2026-05-04 | Pre-PR1 architecture audit |
| `docs/ai/reports/ARCHITECTURE_DISCOVERY_AUDIT_2026-05-04.md` | 2026-05-04 | Pre-PR1 discovery audit |

---

## GROUP D — Pre-PR1 Design-Context Files

Phase 0 outputs that describe the state of the app before any v2 work. Now stale.

**Suggested destination:** `docs/archive/phase0-audits/`

| File | Generated | Reason |
|------|-----------|--------|
| `design-context/_audit_current_flutter_ui.md` | 2026-05-06 | Pre-PR1, describes Cairo/Inter fonts — now migrated |
| `design-context/_audit_design_system.md` | 2026-05-06 | Pre-PR1 design system audit |
| `design-context/_design_gap_analysis.md` | 2026-05-06 | Pre-PR1 gap analysis |
| `design-context/_handoff_to_design_tool.md` | 2026-05-06 | Stale handoff doc — stats as "stub" |
| `design-context/_implementation_strategy.md` | 2026-05-06 | Pre-PR1 strategy, superseded by actual PRs |
| `design-context/_pre_implementation_ui_audit.md` | 2026-05-06 | Pre-PR1 UI audit |
| `design-context/_project_design_context.md` | 2026-05-06 | Phase 0 context — outdated |
| `design-context/Design_report_gap_analyze.md` | Unknown | Gap analysis report |

**Exception:** `design-context/_required_uikit_components.md` (630 lines) — may still have value as a component checklist even if outdated. **Needs human review before archiving.**

---

## GROUP E — One-Off Report Files (Athar Root)

Generated during specific sessions for specific purposes, now served their purpose.

**Suggested destination:** `docs/archive/session-reports/`

| File | Lines | Reason |
|------|-------|--------|
| `GIT_CHECKPOINT_REPORT.md` | 111 | One-off git snapshot |
| `SESSION_RECOVERY_REPORT.md` | 284 | One-off recovery after context loss |
| `IMPLEMENTATION_READINESS_REPORT.md` | 236 | Pre-PR1, superseded |
| `IMPLEMENTATION_SESSION_STATE.md` | 66 | Session state snapshot |
| `IMPLEMENTATION_EXECUTION_PLAN.md` | 446 | Pre-PR1 execution plan |
| `ROADMAP_RECONCILIATION_REPORT.md` | 184 | One-off reconciliation, corrections absorbed |
| `SECURITY_REVIEW_DEEP_PR1.md` | 220 | PR1 security review complete |
| `MIGRATION_ROADMAP_VERIFICATION.md` | 132 | 2026-05-09 roadmap verification complete |
| `ARCHITECTURE_STABILIZATION_REPORT.md` | 243 | PR-THEME-3MODE, decisions locked |
| `ADAPTIVESHELL_FOUNDATION_AUDIT.md` | 257 | PR2 foundation audit, complete |
| `ADAPTIVESHELL_ROLLOUT_STATUS.md` | 253 | PR2 rollout complete |
| `CHANGE_LOG_2026-06-01_PR_THEME_COMPLETE.md` | 107 | PR-THEME change log |

---

## GROUP F — Files To Delete (Not Archive)

| File | Reason |
|------|--------|
| `/athar/missing_translations.txt` | Empty file (0 lines) |
| `docs/progress/auto_checkpoint.md` | 12-line snapshot, superseded by CHECKPOINT.md |

---

## ARCHIVE PRIORITY ORDER

1. **Immediately safe to archive** (no decisions at risk): Group A (completed PR reports), Group C (widget phase history), Group E (one-off session reports)
2. **Archive after cross-check** (verify no unique decisions): Group B duplicates (check 2-line differences before archiving)
3. **Archive with stale notice first** (Claude Design may still use these): Group D (pre-PR1 design-context files)
4. **Needs human review before archiving**: `PRAYER_CARD_SPEC.md` root (313 lines — much longer than canonical 104 lines), `_required_uikit_components.md`, `docs/ai/FILE_INDEX.md`

---

## ARCHIVE TOTAL

| Group | Count | Lines (approx) |
|-------|-------|---------------|
| A — Completed PR reports + change-logs | ~51 files | ~8,000+ lines |
| B — Duplicates (Flutter repo) | 3 files | ~990 lines |
| C — Widget phase history | 6 files | ~1,200 lines |
| D — Pre-PR1 design-context | 8 files | ~2,700 lines |
| E — One-off session reports | 12 files | ~2,500 lines |
| F — Delete | 2 files | ~12 lines |
| **Total** | **~82 files** | **~15,000+ lines** |

After archiving, the active documentation footprint would reduce from ~151 files to approximately 69 files.
