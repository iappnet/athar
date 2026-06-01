# Documentation Inventory Audit — Athar

**Date:** 2026-06-01  
**Auditor:** Claude Code  
**Scope:** All .md, .json, .yaml, .txt documentation files across 6 scan locations  
**Total files scanned:** 151  
**Note:** This is an audit only. No files were moved, renamed, deleted, or modified.

---

## SCAN LOCATIONS

| # | Path | Files Found |
|---|------|-------------|
| 1 | `/athar/.claude/` | 5 .md + 1 .json |
| 2 | `/athar/docs/` | 35 (14 AI index + 21 change-logs + 3 PR3 artifacts + 7 progress) |
| 3 | `/athar/design-context/` | 13 |
| 4 | `/athar/` root | ~63 (59 .md + 3 .yaml + 1 .txt) |
| 5 | `/Athar Design System/` root | 14 |
| 6 | `/Athar Design System/handoff_v2-2/` | 24 |
| **Total** | | **151** |

---

## CATEGORY 1 — ACTIVE GOVERNANCE

Files that must be kept, up-to-date, and always consulted.

---

### 1.1 CLAUDE.md
- **Path:** `/athar/CLAUDE.md`
- **Lines:** 309
- **Purpose:** Primary project instructions loaded into every Claude Code session
- **Content summary:**
  - App stack, setup, commands, architecture overview
  - Navigation, feature list, state management traps
  - Non-negotiable rules (WidgetKeys, App Group, no GoRouter, no page FABs)
  - Localization rules, design system rules
  - Execution system (hard caps, decision lock rules)
  - Design system implementation rules (audit-first, no Dart during audit, RTL, ARB, etc.)
- **Key decisions:** WidgetKeys immutability, single NavBar FAB, iOS 17 minimum, SSOT architecture
- **Status:** Active — loaded every session
- **Classification:** Canonical. Never archive.
- **Suggested location:** `/athar/CLAUDE.md` (current)

---

### 1.2 IMPLEMENTATION_MASTER_STATUS.md
- **Path:** `/athar/IMPLEMENTATION_MASTER_STATUS.md`
- **Lines:** 181
- **Purpose:** SINGLE SOURCE OF TRUTH for v2 design system PR sequence, completion %, blockers
- **Content summary:**
  - Legacy phase track (Phases 0–5 — iOS widget + stability) — all ✅ except Phase 5 (device-gated)
  - v2 PR track table: 14 PRs, 6 complete (PR1, PR-THEME arc, PR2, PR3, PR4a, PR-FONT-FALLBACK)
  - Completion percentages (~36% overall, ~20% token migration, ~25% typography, ~70% dark-mode)
  - Active blockers (B1 Calibri licence, B2 closed, B3 calendar spec, B4 adhan asset)
  - Accepted and deferred risks
  - Dangerous future PRs (PR4b, PR7, PR8, PR-ONBOARD-AB)
  - Handoff authority reference table (which handoff_v2-2 files have been read)
  - Token authority table
- **Key decisions:** SSOT declaration, "do not merge to main until migration complete", PR4a complete, PR5/6/8/9 unblocked
- **Status:** Active — last updated 2026-06-01
- **Classification:** Canonical. Never archive while migration is in progress.
- **Conflicting files:** PROGRAM_IMPLEMENTATION_STATUS.md (partially reduced, now points here), CURRENT_MIGRATION_STATE.md (partially reduced), current_project_status.md (has its own roadmap summary), phase_tracker.md (carries older PR sequence)
- **Suggested location:** `/athar/IMPLEMENTATION_MASTER_STATUS.md` (current)

---

### 1.3 CURRENT_MIGRATION_STATE.md
- **Path:** `/athar/CURRENT_MIGRATION_STATE.md`
- **Lines:** 182
- **Purpose:** Current branch state, tagged PRs, signed-off PRs, deferred QA bucket, RULE 1, RULE 2
- **Content summary:**
  - Canonical branch / main baseline
  - Completed and verified PRs with evidence (commits, tags, file evidence)
  - Active PR (currently none — between PRs)
  - Working tree state (analyze + test pass)
  - RULE 1 (window-based layout only) — locked 2026-06-01
  - RULE 2 (Layer 2 umbrella tracker) — locked 2026-06-01
  - Deferred QA Bucket (5 items, with candidate fixes marked unverified)
  - Open blockers
- **Key decisions:** RULE 1 locked, RULE 2 locked, Deferred QA Bucket governance (post-PR6 sweep, 10-item ceiling)
- **Status:** Active — last updated 2026-06-01
- **Classification:** Canonical for migration state, QA governance, and architectural rules. Keep.
- **Note:** Partially overlaps with IMPLEMENTATION_MASTER_STATUS.md on PR list (intentional — different focus: IMS = roadmap/%, CMD = evidence/rules/QA)
- **Suggested location:** `/athar/CURRENT_MIGRATION_STATE.md` (current)

---

### 1.4 ROADMAP_AFTER_PR4A.md
- **Path:** `/athar/ROADMAP_AFTER_PR4A.md`
- **Lines:** 101
- **Purpose:** Current next-step guidance — completed PRs, active PR, blocked PRs, PR4b locked decisions, deferred QA bucket
- **Content summary:**
  - Completed PR commit/tag table
  - Active PR (PR5 — awaiting review)
  - Next recommended PR order
  - Blocked PRs with gate conditions
  - PR4b architecture lock (CalendarMonthCubit, DualDate, 5 dot sources, etc.) — 11 locked decisions
  - Deferred QA Bucket mirror
  - Open blockers
- **Key decisions:** PR4b architecture locked — CalendarMonthCubit option (b); PR4b gated behind PR5→PR6→QA sweep
- **Status:** Active — last updated 2026-06-01. Will become stale after PR7 ships.
- **Classification:** Active governance. Archive after PR7 ships and a successor "ROADMAP_AFTER_PR6" is created.
- **Related:** IMPLEMENTATION_MASTER_STATUS.md (SSOT for %)
- **Suggested location:** `/athar/ROADMAP_AFTER_PR4A.md` (current)

---

### 1.5 docs/progress/CHECKPOINT.md
- **Path:** `/athar/docs/progress/CHECKPOINT.md`
- **Lines:** 97
- **Purpose:** Session resume point — always read first on any resume, updated as final session action
- **Content summary:**
  - Last updated timestamp and commit hash
  - Current PR + phase
  - Cumulative done list for this session arc
  - PR4b architecture lock confirmation
  - Next actions
  - Open decisions awaiting designer
  - Working tree state (analyze/test status)
- **Key decisions:** PR5 committed, PR6 audit done, PR4b gated
- **Status:** Active — updated 2026-06-01
- **Classification:** Canonical session state. Must remain active. Single file, never archive.
- **Suggested location:** `/athar/docs/progress/CHECKPOINT.md` (current)

---

### 1.6 docs/ai/KNOWN_PROBLEMS.md
- **Path:** `/athar/docs/ai/KNOWN_PROBLEMS.md`
- **Lines:** 117
- **Purpose:** Confirmed bugs, suspected issues, behavioral quirks, fragile areas
- **Content summary:**
  - Open: B1 Calibri licence, B2 ThemeMode not wired (note: B2 was fixed in PR-THEME — this file may be stale on B2), P4 NavBar add unconfirmed
  - Resolved: P1 widget locale, P2 task UUID cache miss, P3 habit UUID cache miss, HealthError crash, iOS target, entitlements, locale callback, initializeDateFormatting, StaticConfiguration, prayer widget, habit parity dedup
  - Behavioral quirks: Athkar excluded from widget, UnifiedTasksPage dead TaskCubit, etc.
  - Fragile areas table (5 items)
- **Key decisions:** B2 listed as open — note this is STALE: PR-THEME fixed it. File needs a B2 closure note.
- **Status:** Partially stale (B2 should be marked FIXED). Otherwise current.
- **Classification:** Canonical. Keep and update B2 closure.
- **Suggested location:** `/athar/docs/ai/KNOWN_PROBLEMS.md` (current)

---

### 1.7 docs/ai/AI_WORKFLOW.md
- **Path:** `/athar/docs/ai/AI_WORKFLOW.md`
- **Lines:** 139
- **Purpose:** Mandatory Claude Code operating rules — execution funnel, search caps, cubit tree caution
- **Content summary:**
  - 5 execution rules (FEATURE_INDEX funnel, first-match lock, 2-read cap, 70% confidence threshold)
  - 4-step workflow (KNOWN_PROBLEMS → FEATURE_INDEX → DATA_FLOW_INDEX → STATE_MANAGEMENT_INDEX)
  - SocratiCode search discipline
  - BlocProvider tree caution
  - Post-change checklist
  - Non-negotiable rules (WidgetKeys, g.dart, FABs, App Group, GoRouter)
  - New feature / new WidgetKey / widget bug / locale change workflows
  - Design system workflow (token authority, audit-first rule, post-PR checklist)
- **Key decisions:** Execution caps, search discipline, design-first rule
- **Status:** Active — current
- **Note:** CLAUDE.md contains a compressed version of this. Some overlap, but AI_WORKFLOW is more detailed. CLAUDE.md takes precedence at session start (always loaded); AI_WORKFLOW is the reference.
- **Classification:** Canonical. Keep.
- **Suggested location:** `/athar/docs/ai/AI_WORKFLOW.md` (current)

---

### 1.8 DUAL_DATE_SPEC.md
- **Path:** `/athar/DUAL_DATE_SPEC.md`
- **Lines:** 285
- **Purpose:** PR4b domain + integration spec — DualDate value object, conversion, caching, cubit contract
- **Content summary:**
  - Why PR4b exists (toggle → simultaneous display)
  - Scope split: visual spec in CALENDAR_CELL_SPEC.md, domain/data/integration spec here
  - Spec does NOT pick cubit wiring — that was decided in _audit_calendar_dual.md
  - DualDate value object, isHijriMode semantics, CalendarMonthCubit contract
- **Key decisions:** Locks alongside CALENDAR_CELL_SPEC.md for PR4b. Created 2026-06-01.
- **Status:** Active spec for a blocked PR (PR4b). Not stale — PR4b is gated, not cancelled.
- **Classification:** Active spec. Keep in root until PR4b is active, then move to design-context/.
- **Suggested location:** `/athar/design-context/DUAL_DATE_SPEC.md` (after PR4b starts)

---

## CATEGORY 2 — ROADMAP / PROGRESS TRACKING

Files that track project state over time.

---

### 2.1 docs/progress/current_project_status.md
- **Path:** `/athar/docs/progress/current_project_status.md`
- **Lines:** 197
- **Purpose:** Detailed completed work log — all phases, iOS widget changes, v2 PR summaries, widget payload schema
- **Content summary:**
  - Infrastructure & architecture changes (iOS 17, entitlements, locale, initializeDateFormatting, HijriCalendar)
  - Prayer widget Phases 0–7 complete (detailed per-phase log)
  - Habit, Task, Sync, Settings changes
  - v2 Design System: PR1 through PR4a summaries with commits/tags
  - "Next PR — PR5 / PR6 / PR8 / PR9" — slightly stale (PR5 is now complete)
  - Widget payload schema v5
  - SocratiCode index status (stale: "2798 chunks, last updated 2026-05-03")
- **Key decisions:** Historical record of all completed work
- **Status:** Partially stale — PR5 now complete, but not recorded here
- **Classification:** Keep as detailed historical record. Reduce to pointer for "Next PR" section. SocratiCode section stale.
- **Related:** IMPLEMENTATION_MASTER_STATUS.md (SSOT for PR status)
- **Suggested location:** `/athar/docs/progress/current_project_status.md` — archive after v2 migration complete

---

### 2.2 docs/progress/phase_tracker.md
- **Path:** `/athar/docs/progress/phase_tracker.md`
- **Lines:** 237 (read first 80)
- **Purpose:** Granular per-phase implementation log (Phase 0–5 widget development, v2 PR track)
- **Content summary:**
  - Phase 0–3 widget implementation logs (detailed per-phase items)
  - Phase 4 hardening items
  - Last updated: 2026-05-09 — predates PR3, PR4a, PR5
  - Contains its own roadmap table (now partially reduced to SSOT pointer per CHECKPOINT.md done list)
- **Key decisions:** Widget implementation history
- **Status:** STALE — does not include PR3, PR4a, PR5 work. Last updated 2026-05-09.
- **Classification:** Historical. Should be archived or marked read-only after migration complete.
- **Suggested location:** `docs/progress/phase_tracker.md` → archive after PR6

---

### 2.3 docs/progress/phase_checkpoint.md
- **Path:** `/athar/docs/progress/phase_checkpoint.md`
- **Lines:** 112
- **Purpose:** Per-session checkpoint snapshots during the widget development phase (May 2026)
- **Content summary:**
  - Phase checkpoints from 2026-05-03 through widget phases (Phase 0–4)
  - Per-session: files changed, files inspected, bugs fixed, verified state, remaining work
- **Key decisions:** Historical widget development record
- **Status:** Historical — all covered phases are complete. No entries after Phase 4.
- **Classification:** Archive candidate. Historical only.
- **Suggested location:** `docs/archive/phase_checkpoint.md`

---

### 2.4 docs/progress/BUGFIX_PHASE_STATUS.md
- **Path:** `/athar/docs/progress/BUGFIX_PHASE_STATUS.md`
- **Lines:** 258
- **Purpose:** Detailed bugfix phase log (phases 1–8.1) — root cause analysis, fix evidence, remaining work
- **Content summary:**
  - Phase 1: SubscriptionCubit @lazySingleton critical fix (root cause + code evidence)
  - Phases 2–8.1: NavBar habit add, prayer toggles, prayer card, prayer notifications, etc.
  - Each phase: root cause, files modified, bugs fixed/not fixed
- **Key decisions:** @lazySingleton fix for SubscriptionCubit (critical — must not be reversed)
- **Status:** Historical — all phases complete. Last updated 2026-05-06.
- **Classification:** Archive candidate. The @lazySingleton decision is already in KNOWN_PROBLEMS.md / CLAUDE.md.
- **Suggested location:** `docs/archive/BUGFIX_PHASE_STATUS.md`

---

### 2.5 docs/progress/prayer_widget_fix_checkpoint.md
- **Path:** `/athar/docs/progress/prayer_widget_fix_checkpoint.md`
- **Lines:** 245
- **Purpose:** Session-by-session prayer widget fix log (Phases 4–7 prayer widget rewrite)
- **Content summary:**
  - Detailed per-session logs for prayer widget v4, v5, v6 payload changes
  - Swift changes, Dart changes, test results
- **Key decisions:** Prayer widget payload schema v5/v6
- **Status:** Historical — prayer widget fully complete.
- **Classification:** Archive candidate.
- **Suggested location:** `docs/archive/prayer_widget_fix_checkpoint.md`

---

### 2.6 docs/progress/auto_checkpoint.md
- **Path:** `/athar/docs/progress/auto_checkpoint.md`
- **Lines:** 12
- **Purpose:** Auto-generated session snapshot (very brief)
- **Content summary:** A few lines noting PR3 work in progress
- **Status:** Superseded by CHECKPOINT.md
- **Classification:** Delete/archive — superseded.
- **Suggested location:** Archive or delete.

---

### 2.7 PROGRAM_IMPLEMENTATION_STATUS.md
- **Path:** `/athar/PROGRAM_IMPLEMENTATION_STATUS.md`
- **Lines:** 202
- **Purpose:** Risk analysis + architectural guidance for the v2 migration program
- **Content summary:**
  - Roadmap sections replaced with SSOT pointer (done per CHECKPOINT.md)
  - Completion % section replaced with SSOT pointer
  - Remaining work summary (10 PRs, estimated complexity, key risk per PR)
  - Remaining risky migrations (PR4b, PR7, PR-ONBOARD-AB)
  - Stale: "PR4a: Medium" listed as remaining — PR4a is COMPLETE
- **Key decisions:** Risk ratings per PR
- **Status:** Partially stale (PR4a row wrong). SSOT pointer added but PR count not corrected.
- **Classification:** Keep for risk analysis. Mark PR4a as complete in the table.
- **Conflicting files:** IMPLEMENTATION_MASTER_STATUS.md (canonical source)
- **Suggested location:** `/athar/PROGRAM_IMPLEMENTATION_STATUS.md` — update PR4a row

---

## CATEGORY 3 — PR REPORTS AND VERIFICATION REPORTS

---

### 3.1 PR3 Artifacts (docs/pr3-artifacts/)
- `docs/pr3-artifacts/PR3_FINAL_DECISION_MATRIX.md` (250 lines) — final decisions for PR3
- `docs/pr3-artifacts/SCREENSHOTS_PR3.md` (98 lines) — screenshot matrix reference
- `docs/pr3-artifacts/VERIFICATION_PR3.md` (621 lines) — full verification report
- **Status:** Historical — PR3 complete. Moved to docs/pr3-artifacts/ per CHECKPOINT record.
- **Classification:** Archive. Historical reference only.

---

### 3.2 PR Reports — Root Level (athar/)

| File | Lines | PR | Status |
|------|-------|----|--------|
| `PR1_FINAL_REPORT.md` | 216 | PR1 | Historical |
| `PR1_IMPLEMENTATION_PREVIEW.md` | 276 | PR1 | Historical |
| `PR2_CHECKPOINTS.md` | 146 | PR2 | Historical |
| `PR2_FINAL_READINESS_REPORT.md` | 162 | PR2 | Historical |
| `PR2_IMPLEMENTATION_PLAN.md` | 283 | PR2 | Historical |
| `PR2_PROGRESS_REPORT.md` | 76 | PR2 | Historical |
| `PR2_READINESS_PREVIEW.md` | 279 | PR2 | Historical |
| `PR2_SCOPE_RECONCILIATION_REPORT.md` | 146 | PR2 | Historical |
| `PR3_APPROVAL_REQUIRED_ITEMS.md` | 246 | PR3 | Historical |
| `PR3_BEHAVIORAL_SOURCE_OF_TRUTH.md` | 427 | PR3 | Historical |
| `PR3_BLOCKERS_AND_OPEN_ASSUMPTIONS.md` | 307 | PR3 | Historical |
| `PR3_DESIGN_RULINGS.md` | 165 | PR3 | Historical |
| `PR3_DOMAIN_AND_STATE_AUDIT.md` | 333 | PR3 | Historical |
| `PR3_IMPLEMENTATION_PLAN.md` | 454 | PR3 | Historical |
| `PR3_IMPLEMENTATION_READINESS_VERIFICATION.md` | 197 | PR3 | Historical |
| `PR3_REQUIRED_DESIGN_CORRECTIONS.md` | 304 | PR3 | Historical |
| `PR3_REUSE_AND_MIGRATION_MATRIX.md` | 394 | PR3 | Historical |
| `PR3_RISK_REGISTER.md` | 410 | PR3 | Historical |
| `PR3_SCREENSHOT_MATRIX.md` | 286 | PR3 | Historical |
| `PR3_SIGNOFF.md` | 81 | PR3 | Active reference |
| `PR3_TECHNICAL_RECONCILIATION_REPORT.md` | 427 | PR3 | Historical |
| `PR3_VISUAL_DENSITY_SIMULATION.md` | 250 | PR3 | Historical |
| `PR3_VISUAL_READINESS_REPORT.md` | 515 | PR3 | Historical |
| `CONSOLIDATED_REPORT_PR3.md` | 324 | PR3 | Historical |
| `QUESTIONS_PR3.md` | 205 | PR3 | Historical |
| `PR4A_FINAL_REPORT.md` | 140 | PR4a | Active reference |
| `PR4A_READINESS_SCOPE.md` | 297 | PR4a | Historical |
| `PR_THEME_FINAL_REPORT.md` | 124 | PR-THEME | Historical |
| `PR_THEME_IMPLEMENTATION_PREVIEW.md` | 419 | PR-THEME | Historical |
| `PR_THEME_READINESS_REPORT.md` | 324 | PR-THEME | Historical |
| `PR_THEME_3MODE_FINAL_REPORT.md` | 191 | PR-THEME-3MODE | Historical |
| `PR_THEME_3MODE_PREVIEW.md` | 539 | PR-THEME-3MODE | Historical |
| `VERIFICATION_PR_THEME.md` | 182 | PR-THEME FINAL | Active reference |
| `VERIFICATION_PR4A.md` | 226 | PR4a | Active reference |
| `CHANGE_LOG_2026-06-01_PR_THEME_COMPLETE.md` | 107 | PR-THEME | Historical |

**Classification summary:**
- Active reference (should keep for at least one more PR cycle): `PR3_SIGNOFF.md`, `PR4A_FINAL_REPORT.md`, `VERIFICATION_PR_THEME.md`, `VERIFICATION_PR4A.md`
- All others: **Archive candidates** — historical only once PR is signed off

---

### 3.3 Change Logs (docs/ai/change-logs/)
21 files from 2026-05-04 through 2026-05-09. All historical. Phases 3–8, PR1, PR2, PR-THEME.
- **Status:** Historical — all covered work is complete
- **Classification:** Archive. Keep as audit trail but do not load.

---

## CATEGORY 4 — DESIGN SYSTEM SPECS

---

### 4.1 handoff_v2-2/ Component Specs (CANONICAL)

These are the canonical, locked versions of all design specs:

| File | Lines | Purpose | Read required before |
|------|-------|---------|---------------------|
| `HANDOFF.md` | 160 | Entry contract — read order, architecture rules | Any design work |
| `SKILL.md` | 250 | Architecture laws, vocabulary, do-nots | Any design work |
| `REDESIGN_AUDIT.md` | 485 | Per-screen ticket list → Dart files | Any screen PR |
| `INVESTIGATION_RECONCILIATION.md` | 158 | 5 locked decisions — READ FIRST | Any design PR |
| `DESIGN_SYSTEM_GAP_VALIDATION.md` | 134 | Typography authority lockdown (Calibri sole canonical) | Any typography work |
| `PACKAGE_A_DECISIONS.md` | 25 | 8 designer decisions (Calibri, isHijriMode, AdaptiveShell, Stats) | Any feature PR |
| `PACKAGE_C_DECISIONS.md` | 28 | 12 follow-up decisions (dark mode, 4-tab, calendar, Athkar, bottom-nav) | Any feature PR |
| `THEME_DARK_SPEC.md` | 114 | Per-surface dark treatments (overrides colors_and_type.css) | Dark mode work |
| `FINAL_PACKAGE_MANIFEST.md` | 229 | PR sequence, entry points, required read order | Session start |
| `CLAUDE_CODE_PROMPT.md` | 127 | Implementation prompt with read order and locked decisions | Any PR |
| `STATS_KPI_SPEC.md` | 126 | Tier-1/2 KPIs, components, period selector | PR6 |
| `FOCUS_OIL_SPEC.md` | 153 | Oil-fill animation spec | PR8 |
| `CALENDAR_FOCUS_REDESIGN.md` | 194 | Calendar dual display + focus brief | PR4b |
| `CALENDAR_CELL_SPEC.md` | 128 | Pixel-exact dual-numeral cell + header | PR4b |
| `IPAD_OPTIMIZATION.md` | 451 | AdaptiveShell breakpoints, per-screen iPad layouts | Any screen PR |
| `COMPONENT_SPECS.md` | 148 | EmptyState, ErrorState, numericMono, ModuleFlags, etc. | Any component PR |
| `PRAYER_CARD_SPEC.md` | 104 | Prayer card compact + expanded spec | PR3 (done) / reference |
| `ATHKAR_SPEC.md` | 162 | Athkar net-new feature spec | PR7 |
| `IOS_WIDGETS_SPEC.md` | 114 | 3 widgets × 3 sizes spec | PR9 |
| `ONBOARDING_AB_SPEC.md` | 501 | Four-variant A/B/C/D onboarding | PR-ONBOARD-AB |
| `INVESTIGATION_REPORT.md` | 629 | Full codebase audit (read-only, 2026-05-09) | Reference |
| `design-context/_manifest.json` | 453 | Every Dart file grouped by feature | Any work |
| `README.md` | 134 | Package overview | Orientation |
| `ui_kits/athar_app/README.md` | 21 | UIKit overview | Orientation |

**Status:** All active. `handoff_v2-2/` is the CANONICAL design spec location.

---

### 4.2 Athar Design System Root/ Specs (OLDER VERSIONS — likely superseded)

These files exist at the Design System root and appear to be earlier versions of the same files in `handoff_v2-2/`. Line counts differ in some cases (e.g., REDESIGN_AUDIT.md root=432 vs handoff_v2-2=485).

| File | Root lines | handoff_v2-2 lines | Difference |
|------|-----------|---------------------|-----------|
| `HANDOFF.md` | 160 | 160 | Same |
| `SKILL.md` | 250 | 250 | Same |
| `REDESIGN_AUDIT.md` | 432 | 485 | **Root is OLDER (-53 lines)** |
| `STATS_KPI_SPEC.md` | 126 | 126 | Same |
| `FOCUS_OIL_SPEC.md` | 153 | 153 | Same |
| `CALENDAR_FOCUS_REDESIGN.md` | 194 | 194 | Same |
| `CALENDAR_CELL_SPEC.md` | 128 | 128 | Same |
| `IPAD_OPTIMIZATION.md` | 449 | 451 | **Root is OLDER (-2 lines)** |
| `COMPONENT_SPECS.md` | 148 | 148 | Same |
| `PRAYER_CARD_SPEC.md` | 101 | 104 | **Root is OLDER (-3 lines)** |
| `ATHKAR_SPEC.md` | 162 | 162 | Same |
| `IOS_WIDGETS_SPEC.md` | 114 | 114 | Same |
| `PACKAGE_A_DECISIONS.md` | 25 | 25 | Same |
| `README.md` | 134 | 134 | Same |

**Files ONLY in root/ (not in handoff_v2-2/):**
- None found.

**Files ONLY in handoff_v2-2/ (not in root/):**
- `INVESTIGATION_RECONCILIATION.md` — locked decisions (CRITICAL — read first)
- `DESIGN_SYSTEM_GAP_VALIDATION.md` — typography authority lockdown
- `INVESTIGATION_REPORT.md` — codebase audit
- `FINAL_PACKAGE_MANIFEST.md` — package manifest
- `CLAUDE_CODE_PROMPT.md` — implementation prompt
- `PACKAGE_C_DECISIONS.md` — 12 additional decisions
- `THEME_DARK_SPEC.md` — dark surface treatments
- `ONBOARDING_AB_SPEC.md` — onboarding A/B spec

**Status:** Root/ versions are older (smaller REDESIGN_AUDIT.md, IPAD_OPTIMIZATION.md, PRAYER_CARD_SPEC.md). handoff_v2-2/ is the authoritative canonical package.
**Classification:** Root/ spec files → archive candidates or superseded. Always use handoff_v2-2/ instead.

---

## CATEGORY 5 — AI INSTRUCTIONS / CLAUDE RULES / SKILLS

---

### 5.1 .claude/commands/ (5 files)

| File | Lines | Purpose | Status |
|------|-------|---------|--------|
| `analyze-feature.md` | 35 | `/analyze-feature` slash command | Active |
| `audit-stats.md` | 34 | `/audit-stats` slash command | Active |
| `audit-widget.md` | 35 | `/audit-widget` slash command | Active |
| `fix-bug.md` | 27 | `/fix-bug` slash command | Active |
| `update-ai-index.md` | 20 | `/update-ai-index` slash command | Active |

All active. These are part of the Claude Code slash command system.

---

### 5.2 .claude/settings.local.json
- **Lines:** 55
- **Purpose:** Local Claude Code settings (permissions, tool preferences)
- **Status:** Active. Do not archive.

---

### 5.3 Athar Design System/SKILL.md (root and handoff_v2-2)
- Duplicated in two locations (both 250 lines — appear identical)
- Used by Claude Design as the design-system operating rules

---

### 5.4 CLAUDE_CODE_PROMPT.md (root and handoff_v2-2)
- **Root:** `/athar/CLAUDE_CODE_PROMPT.md` (129 lines)
- **handoff_v2-2:** `handoff_v2-2/CLAUDE_CODE_PROMPT.md` (127 lines — 2 lines shorter)
- **Status:** DUPLICATE. Root version is a copy of (or slightly different from) the handoff_v2-2 version.
- **Classification:** Root version is redundant. handoff_v2-2 is authoritative.

---

## CATEGORY 6 — ARCHITECTURE DECISIONS

---

### 6.1 docs/ai/ARCHITECTURE_INDEX.md
- **Lines:** 108
- **Purpose:** Canonical code architecture reference — Clean Architecture, Cubit, DI, Isar, Supabase patterns
- **Status:** Active — likely current
- **Classification:** Keep

---

### 6.2 docs/ai/STATE_MANAGEMENT_INDEX.md
- **Lines:** 138
- **Purpose:** BlocProvider tree, all cubit instances, cubit disambiguation (3 TaskCubit instances)
- **Status:** Active — essential for PR work
- **Classification:** Keep

---

### 6.3 docs/ai/FEATURE_INDEX.md
- **Lines:** 416
- **Purpose:** Per-feature entry files, mandatory start files, file paths
- **Status:** Active — used in every Claude Code session
- **Classification:** Canonical. Keep.

---

### 6.4 docs/ai/DATA_FLOW_INDEX.md
- **Lines:** 176
- **Purpose:** Data flow traces (how data moves through layers per feature)
- **Status:** Active — used for flow-tracing
- **Classification:** Keep

---

### 6.5 docs/ai/STATS_ENGINE_INDEX.md
- **Lines:** 82
- **Purpose:** Stats engine architecture (StatsRepositoryImpl, data sources, cache, KPI fields)
- **Status:** Active — needed for PR6
- **Classification:** Keep

---

### 6.6 docs/ai/SUPABASE_INDEX.md
- **Lines:** 93
- **Purpose:** Supabase table schema, sync architecture, auth patterns
- **Status:** Active
- **Classification:** Keep

---

### 6.7 docs/ai/WIDGET_INDEX.md
- **Lines:** 159
- **Purpose:** iOS widget architecture, WidgetKeys, Swift files, known issues
- **Status:** Active — needed for PR9
- **Classification:** Keep

---

### 6.8 docs/ai/PROJECT_MAP.md
- **Lines:** 89
- **Purpose:** Project-level map — modules, key files, navigation paths
- **Status:** Active
- **Classification:** Keep

---

### 6.9 docs/ai/FILE_INDEX.md
- **Lines:** 103
- **Purpose:** File index (likely a directory listing or file-to-feature map)
- **Status:** Possibly stale — last modified date unknown. Overlaps with FEATURE_INDEX.md.
- **Classification:** Verify for staleness. Merge into FEATURE_INDEX if redundant.

---

### 6.10 ARCHITECTURE_STABILIZATION_REPORT.md
- **Path:** `/athar/ARCHITECTURE_STABILIZATION_REPORT.md`
- **Lines:** 243
- **Purpose:** Documentation of PR-THEME-3MODE architecture decisions (ThemePreference enum, ThemeMode wiring)
- **Status:** Historical — completed decision, now locked
- **Classification:** Archive candidate. Key decisions already captured in CLAUDE.md and KNOWN_PROBLEMS.md.

---

### 6.11 ADAPTIVESHELL_FOUNDATION_AUDIT.md / ADAPTIVESHELL_ROLLOUT_STATUS.md
- **Paths:** `/athar/ADAPTIVESHELL_FOUNDATION_AUDIT.md` (257 lines), `/athar/ADAPTIVESHELL_ROLLOUT_STATUS.md` (253 lines)
- **Purpose:** PR2 AdaptiveShell implementation audit and rollout status
- **Status:** Historical — PR2 complete
- **Classification:** Archive candidates.

---

### 6.12 IPAD_LAYER2_OWNERSHIP_MAP.md / IPAD_LAYER3_DEFERRED_AFFORDANCES.md
- **Lines:** 215, 154
- **Purpose:** Per-screen iPad Layer 2 ownership matrix; Layer 3 deferred features
- **Status:** Active — referenced in CURRENT_MIGRATION_STATE.md RULE 2
- **Classification:** Keep — needed for PR-IPAD-LAYER2 tracking

---

### 6.13 MIGRATION_BRANCH_STRATEGY.md
- **Lines:** 188
- **Purpose:** Git branch strategy for long-running migration branch
- **Status:** Active — strategy is in effect
- **Classification:** Keep

---

### 6.14 MIGRATION_ROADMAP_VERIFICATION.md
- **Lines:** 132
- **Purpose:** 2026-05-09 verification of roadmap (8 discrepancies corrected)
- **Status:** Historical — audit complete
- **Classification:** Archive candidate. Discrepancies already reflected in IMPLEMENTATION_MASTER_STATUS.md.

---

## CATEGORY 7 — QA / DEFERRED GATES

---

### 7.1 Deferred QA Bucket
- **Location:** Tracked in both `CURRENT_MIGRATION_STATE.md` and `ROADMAP_AFTER_PR4A.md`
- **Items:** 5 of 10 (PR3-R1, PR3-R2, PR4a-G1, PR4a-G2, DEVICE-1)
- **Status:** Active — items pending physical device validation
- **Classification:** Keep in CURRENT_MIGRATION_STATE.md as authoritative location

---

## CATEGORY 8 — HISTORICAL REPORTS

---

### 8.1 docs/ai/reports/
- `AI_ARCHITECTURE_ALIGNMENT_AUDIT_2026-05-04.md` (492 lines) — May 2026 architecture audit
- `ARCHITECTURE_DISCOVERY_AUDIT_2026-05-04.md` (837 lines) — May 2026 discovery audit
- **Status:** Historical — predates all PRs. Largely superseded by INVESTIGATION_REPORT.md in handoff_v2-2.
- **Classification:** Archive.

---

### 8.2 INVESTIGATION_REPORT.md (athar root)
- **Path:** `/athar/INVESTIGATION_REPORT.md`
- **Lines:** 629
- **Status:** This is a copy of `handoff_v2-2/INVESTIGATION_REPORT.md` (same 629 lines — exact duplicate)
- **Classification:** Root copy is redundant. Archive root copy. Keep handoff_v2-2 version.

---

### 8.3 FINAL_PACKAGE_MANIFEST.md (athar root)
- **Path:** `/athar/FINAL_PACKAGE_MANIFEST.md`
- **Lines:** 230
- **Status:** Root copy vs `handoff_v2-2/FINAL_PACKAGE_MANIFEST.md` (229 lines — near-duplicate, 1 line diff)
- **Classification:** Root copy is redundant. Archive root copy. Keep handoff_v2-2 version.

---

### 8.4 GIT_CHECKPOINT_REPORT.md
- **Path:** `/athar/GIT_CHECKPOINT_REPORT.md`
- **Lines:** 111
- **Purpose:** Git state snapshot from a specific session
- **Status:** Historical
- **Classification:** Archive.

---

### 8.5 SESSION_RECOVERY_REPORT.md
- **Path:** `/athar/SESSION_RECOVERY_REPORT.md`
- **Lines:** 284
- **Purpose:** Gap-list produced after session context loss (9 items, PR4a related)
- **Status:** Historical — gaps were addressed
- **Classification:** Archive.

---

### 8.6 IMPLEMENTATION_READINESS_REPORT.md
- **Path:** `/athar/IMPLEMENTATION_READINESS_REPORT.md`
- **Lines:** 236
- **Purpose:** Pre-PR1 readiness report
- **Status:** Historical — PR1 complete
- **Classification:** Archive.

---

### 8.7 IMPLEMENTATION_SESSION_STATE.md
- **Path:** `/athar/IMPLEMENTATION_SESSION_STATE.md`
- **Lines:** 66
- **Purpose:** Session state snapshot
- **Status:** Historical
- **Classification:** Archive.

---

### 8.8 IMPLEMENTATION_EXECUTION_PLAN.md
- **Path:** `/athar/IMPLEMENTATION_EXECUTION_PLAN.md`
- **Lines:** 446
- **Purpose:** Pre-PR1 execution plan
- **Status:** Historical
- **Classification:** Archive.

---

### 8.9 ROADMAP_RECONCILIATION_REPORT.md
- **Path:** `/athar/ROADMAP_RECONCILIATION_REPORT.md`
- **Lines:** 184
- **Purpose:** 2026-06-01 roadmap reconciliation (post-PR4a gap audit)
- **Status:** Historical — gaps corrected in IMPLEMENTATION_MASTER_STATUS.md
- **Classification:** Archive.

---

### 8.10 SECURITY_REVIEW_DEEP_PR1.md
- **Path:** `/athar/SECURITY_REVIEW_DEEP_PR1.md`
- **Lines:** 220
- **Purpose:** PR1 security review (token changes, font assets, no secrets)
- **Status:** Historical
- **Classification:** Archive. Result referenced in IMPLEMENTATION_MASTER_STATUS.md.

---

### 8.11 KNOWN_FUTURE_ASSETS.md
- **Path:** `/athar/KNOWN_FUTURE_ASSETS.md`
- **Lines:** 52
- **Purpose:** List of known future design assets not yet received (adhan audio, etc.)
- **Status:** Partially stale — some items may be resolved
- **Classification:** Review and merge into IMPLEMENTATION_MASTER_STATUS.md blocker list, then archive.

---

## CATEGORY 9 — TEMPORARY AUDITS

---

### 9.1 design-context/ Audit Files

These are the output of the audit-first workflow (per CLAUDE.md). Each represents a pre-implementation audit for a specific PR.

| File | Lines | PR | Status |
|------|-------|----|--------|
| `_audit_accessibility.md` | 354 | PR5 | Done — PR5 complete |
| `_audit_calendar_dual.md` | 403 | PR4b | Active — PR4b gated |
| `_audit_calendar.md` | 377 | PR4a | Done — PR4a complete |
| `_audit_current_flutter_ui.md` | 348 | Pre-PR1 | Historical |
| `_audit_design_system.md` | 418 | Pre-PR1 | Historical |
| `_audit_stats.md` | 335 | PR6 | Active — PR6 implementing |

---

### 9.2 design-context/ Strategy/Analysis Files

| File | Lines | Purpose | Status |
|------|-------|---------|--------|
| `_design_gap_analysis.md` | 362 | Pre-PR1 gap analysis | Historical |
| `_handoff_to_design_tool.md` | 300 | Pre-PR1 handoff to Claude Design | Historical / outdated |
| `_implementation_strategy.md` | 283 | Pre-PR1 implementation strategy | Historical |
| `_pre_implementation_ui_audit.md` | 450 | Pre-PR1 UI audit | Historical |
| `_project_design_context.md` | 213 | Phase 0 project context (2026-05-06) | Historical / partially stale |
| `_required_uikit_components.md` | 630 | Required UIKit components list | Historical |
| `Design_report_gap_analyze.md` | 342 | Gap analysis report | Historical |

**Status:** All Phase 0 outputs. _audit_calendar_dual.md and _audit_stats.md are the only active ones.
**Classification:** Active: `_audit_calendar_dual.md`, `_audit_stats.md`. Others are historical.

---

## CATEGORY 10 — SPEC FILES (root — likely duplicates)

---

### 10.1 PRAYER_CARD_SPEC.md (root)
- **Path:** `/athar/PRAYER_CARD_SPEC.md` (313 lines)
- **Design System version:** `handoff_v2-2/PRAYER_CARD_SPEC.md` (104 lines)
- **Note:** Root version is MUCH LONGER (313 vs 104 lines) — likely a different, expanded version
- **Status:** Unclear which is canonical. Needs human review.
- **Classification:** Needs review. May contain implementation details not in handoff_v2-2 version.

---

### 10.2 README.md
- **Path:** `/athar/README.md` (16 lines) — minimal project README
- **Status:** Minimal. Not a documentation file.
- **Classification:** Keep as-is.

---

### 10.3 missing_translations.txt
- **Path:** `/athar/missing_translations.txt` (0 lines — empty)
- **Status:** Empty file.
- **Classification:** Delete.

---

## CATEGORY 11 — DUPLICATE OR CONFLICTING FILES

See `DOCUMENTATION_DUPLICATION_AND_DRIFT_REPORT.md` for full analysis.

---

## CATEGORY 12 — ARCHIVE CANDIDATES

See `DOCUMENTATION_ARCHIVE_CANDIDATES.md` for full list.

---

## CATEGORY 13 — UNKNOWN / NEEDS HUMAN REVIEW

| File | Issue |
|------|-------|
| `PRAYER_CARD_SPEC.md` (root, 313 lines) | Much longer than handoff_v2-2 version (104 lines) — unclear which is canonical |
| `docs/ai/FILE_INDEX.md` (103 lines) | Unclear if up-to-date; overlaps with FEATURE_INDEX.md |
| `KNOWN_FUTURE_ASSETS.md` (52 lines) | May contain items now resolved — needs review |
| `handoff_v2-2/design-context/_manifest.json` (453 lines) | Design-side manifest — unknown if synchronized with Flutter repo |
