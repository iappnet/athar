# AI Architecture Alignment Audit — Athar
_Date: 2026-05-04 (v2 — post-fix state) | Auditor: Claude Code (claude-sonnet-4-6)_
_Scope: Full codebase + full AI layer (CLAUDE.md, docs/ai/*, .claude/commands/*)_
_Previous audit: v1 same date — 4 CRITICAL, 6 MEDIUM, 5 LOW gaps identified_
_This audit: evaluates current state after v1 fixes were applied_

---

## Section 1 — Executive Summary

**Overall Architecture Quality**: Strong. Clean Architecture applied consistently across 16 features. No structural violations. Isar/Supabase separation is clean. iOS widgets (interactive) and Android widgets (display-only) are correctly separated.

**AI Layer Maturity**: Significantly improved from v1. All 4 original CRITICAL gaps and all 6 MEDIUM gaps were fixed. However, this audit uncovered 3 new critical gaps that were not addressed in the v1 fix pass — all in command files.

**Key Strengths** (current state):
- CLAUDE.md `## AI Workflow` is now a stop-at-first-answer funnel ✓
- `analyze-feature.md` now has a max-2-reads cap ✓
- `fix-bug.md` now has an explicit cap ✓
- STATE_MANAGEMENT_INDEX.md now documents ModuleCubit + HealthCubit shadowing ✓
- FEATURE_INDEX.md now has Android Widgets entry + space sub-cubit paths ✓
- SUPABASE_INDEX.md created — supabase/ directory now documented ✓
- STATS_ENGINE_INDEX.md now includes the productivity formula ✓
- DATA_FLOW_INDEX.md remains 100% accurate ✓
- KNOWN_PROBLEMS.md is current and complete ✓

**Key Risks** (remaining after fixes):
1. `AI_WORKFLOW.md` Step 1 body still presents the original 4-step sequential checklist — this internally contradicts the `EXECUTION RULES` section at the top of the same file.
2. `audit-widget.md` has a 7-step procedure with 3+ source file reads — not capped, not aligned with max-2-reads rule.
3. `audit-stats.md` has a 6-step procedure with 4 source file reads — same problem.
4. `ARCHITECTURE_INDEX.md` global cubit count is stale ("18+"; actual count is 20+).

**Gap Count (current)**: 3 CRITICAL (all new) · 0 MEDIUM · 5 LOW (carried from v1)

---

## Section 2 — Codebase Architecture Summary

### Architecture (verified)

- **Pattern**: Clean Architecture, 16 feature modules. Each: `data/` → `domain/` → `presentation/`.
- **State**: flutter_bloc Cubit only. No Bloc events.
- **DI**: GetIt + Injectable. `injection.config.dart` is generated — never edit.
- **Local**: Isar v3. `@collection` models, `*.g.dart` generated.
- **Remote**: Supabase. `supabase/migrations/` + `supabase/functions/revenuecat-webhook/`.
- **Sync**: Isar → Supabase via `SyncService`; background `workmanager`; gated by subscription.
- **Navigation**: Named routes in `app.dart`. GoRouter in pubspec but entirely unused.

### State Management (verified from code, current documentation)

**Global MultiBlocProvider (app.dart)** — 16 BlocProvider calls, 20 cubits (some share a provider):
`AuthCubit`, `PrayerCubit`, `HabitCubit`, `CategoryCubit`, `SpaceCubit`, `ModuleCubit`, `TaskCubit`, `CalendarCubit`, `SettingsCubit`, `SyncCubit`, `SubscriptionCubit`, `LocaleCubit`, `DhikrCubit`, `FocusCubit`, `HealthCubit`, `StatsCubit`, `NotificationsCubit`, `CelebrationCubit`, `AssetsCubit`, `SpaceMembersCubit`, `ListCubit`.

**MainPage local providers (shadowing globals)**:
- `TaskCubit` (watchTasks — shadows global, documented ✓)
- `HabitCubit` (no loadHabits — shadows global, documented ✓)
- `ModuleCubit` (shadows global — NOW documented ✓)
- `HealthCubit` (shadows global — NOW documented ✓)
- `TimelineCubit` (loadGlobalTimeline — local only, documented ✓)

**UnifiedTasksPage local providers**:
- `TimelineCubit` (loadGlobalTimeline — canonical display path ✓)
- `TaskCubit` (no watchTasks — action dispatch only, NOT display — NOW documented ✓)

**onResume handler** (`app.dart` lines 81–88): uses `DeepLinkService.navigatorKey.currentContext` — resolves to MainPage subtree cubits. Guarded by `ctx != null && ctx.mounted`.

### Platform Layer (verified)

- **iOS**: 3 interactive widget extensions (AppIntentConfiguration, iOS 17.0+) ✓
- **Android**: 6 `.kt` files — 3 widget types (Task/Habit/Prayer) + 3 Receiver files. Display-only. No UUID parsed. No AppIntent. No pending-action queue. ✓
- **Supabase**: `functions/revenuecat-webhook/` + 2 migration files. NOW documented in SUPABASE_INDEX.md ✓

---

## Section 3 — AI Layer Evaluation (Current State)

### CLAUDE.md (186 lines) — IMPROVED

**`## EXECUTION SYSTEM`**: Correct. Caps, first-match rule, no-alternative-search, single-file preference all present. ✓

**`## DECISION LOCK (MANDATORY)`**: Correct. 6 bullets, concise, no redundancy. ✓

**`## AI Workflow`**: Fixed. Now a stop-at-first-answer funnel. Steps 3 and 4 are conditional ("only if"). ✓

**Remaining gap**: None critical. The `## AI Workflow` section now correctly differs from AI_WORKFLOW.md Step 1 body — but AI_WORKFLOW.md itself still has the old checklist (see Section 5).

---

### FEATURE_INDEX.md (416 lines) — IMPROVED

**GLOBAL DECISION RULE removed**: Confirmed (0 occurrences). Enforcement now owned by CLAUDE.md only. ✓

**task entry**: Correctly states UnifiedTasksPage TaskCubit is "action-only, not display." ✓

**space entry**: Now has 8-step execution path covering all 6 sub-cubits with note about ModuleCubit global shadowing. ✓

**Android Widgets entry**: Added. Accurate — display-only, file paths, no AppIntent, no UUID. ✓

**MANDATORY START FILE**: Present on all 18 feature entries (16 features + iOS widgets + Android widgets). ✓

**Remaining gap (LOW)**: `settings / localization` entry does not highlight that `LocaleCubit` lives at `lib/core/presentation/cubit/` not under `features/settings/` — this is noted in body text but not in the MANDATORY START FILE line.

---

### AI_WORKFLOW.md (114 lines) — PARTIALLY FIXED — CRITICAL GAP REMAINS

**`## EXECUTION RULES (MANDATORY)`** at top: Fixed. 5 numbered rules, caps enforced, first-match stated. ✓

**`## Step 1: Check docs/ai/ before touching code`** (lines 15–22): **NOT FIXED.** Still reads:

> "Before reading any source file, check these docs in order:
> 1. KNOWN_PROBLEMS.md — is this a known bug?
> 2. FEATURE_INDEX.md — which files does this feature use?
> 3. DATA_FLOW_INDEX.md — trace the flow end-to-end first; don't guess.
> 4. STATE_MANAGEMENT_INDEX.md — which cubit instance does this context use?"

This is the original sequential 4-step checklist. It directly contradicts `## EXECUTION RULES` at the top of the same file. The top says "select ONE → execute"; Step 1 says "check all 4 first." A sequential list with numbers reads as a procedure to complete, not a funnel to exit early.

**Impact**: This is the dominant pattern in the file. When Claude reads AI_WORKFLOW.md, the detailed, numbered Step 1 instruction overrides the brief EXECUTION RULES bullets. The contradiction is internal — two sections of the same file give opposing instructions.

---

### STATE_MANAGEMENT_INDEX.md (138 lines) — FIXED

- Typo corrected: `getIt<HabitCubit>()` ✓
- ModuleCubit + HealthCubit shadowing documented in MainPage section ✓
- Common Mistake #5 added ✓
- SpaceMembersCubit + ListCubit added to global table ✓
- onResume null guard (`ctx != null && ctx.mounted`) now documented ✓

**Remaining gap (LOW)**: Global cubit table now has 20 rows but ARCHITECTURE_INDEX.md still says "18+" globally. Cross-file count inconsistency. Not misleading but creates confusion.

---

### KNOWN_PROBLEMS.md (104 lines) — ACCURATE, NO CHANGES NEEDED

- P1/P2/P3 (Phase 5 open bugs) current and accurate ✓
- P4 (NavBar add issue) still "unconfirmed" — should be confirmed or closed ✓ (LOW)
- FIXED section correctly lists all resolved issues ✓
- Fragile Areas table accurate ✓

---

### DATA_FLOW_INDEX.md (177 lines) — ACCURATE, NO CHANGES NEEDED

All 8 flows verified against code. 100% accurate. The strongest AI layer file.

Locale Change flow correctly documents the bug: "MISSING: WidgetDataService is NOT called here" ✓

---

### WIDGET_INDEX.md (162 lines) — FIXED

- Android section replaced: "6 total — 3 widget types + 3 receivers" ✓
- File paths documented ✓
- Display-only, No AppIntent, No UUID parsed documented ✓
- Known gap note added: "platform capability gap, not a bug" ✓

---

### STATS_ENGINE_INDEX.md (82 lines) — FIXED

Productivity formula added:
```
score = 0.4 × taskScore + 0.4 × habitScore + 0.2 × focusScore
```
App weekday convention documented: `(dartWeekday % 7) + 1`. ✓

---

### FILE_INDEX.md (104 lines) — NOT CHANGED

**Remaining gaps (LOW)**:
- `core/iam/` (RBAC: RoleService, PermissionService, PermissionCache) not listed despite being high-risk.
- `core/time_engine/` (`AtharTimeCalculator`, `AtharTimePeriods`) not listed — used by WidgetDataService and TaskModel.
- Android widget files not listed.

---

### ARCHITECTURE_INDEX.md (107 lines) — NOT CHANGED

**Remaining gap (LOW)**: Line 29 lists 18 named cubits in the global section. Actual count is now 20+ (SpaceMembersCubit and ListCubit added to STATE_MANAGEMENT_INDEX but not reflected here).

---

### SUPABASE_INDEX.md (93 lines) — CREATED

New file. Covers:
- Directory layout with actual file names from disk ✓
- When to / when not to inspect ✓
- Feature-to-remote-datasource mapping table (16 features) ✓
- SyncService connection ✓
- RevenueCat webhook flow ✓
- Migration instructions ✓

---

### .claude/commands/analyze-feature.md — FIXED

Cap added, cubit+repository double-read removed, doc reads separated from file reads. ✓

---

### .claude/commands/fix-bug.md — FIXED

Cap added. "Target file identified → next action MUST be Read" enforced. ✓

---

### .claude/commands/audit-widget.md — NOT FIXED — CRITICAL GAP

7-step procedure. Steps 3, 4, and 5 are all source file reads:
- Step 3: read `widget_data_service.dart`
- Step 4: read the Swift widget file
- Step 5: read `task_cubit.dart` + `habit_cubit.dart` + `app.dart`

That is a minimum of 4 source file reads (3 distinct files in step 5 alone), plus step 6 is a report. No cap stated. No MANDATORY START FILE reference. No enforcement language.

**Impact**: Every `/audit-widget` invocation bypasses the 2-read cap completely and legitimately, per its own instructions.

---

### .claude/commands/audit-stats.md — NOT FIXED — CRITICAL GAP

6-step procedure. Steps 3, 4, 5, 6 are all source file reads:
- Step 3: read `stats_remote_source.dart`
- Step 4: read `stats_helpers.dart`
- Step 5: read `stats_repository_impl.dart`
- Step 6: read `stats_cubit.dart`

That is 4 mandatory source file reads. No cap stated. No MANDATORY START FILE reference.

**Impact**: Same as audit-widget — every `/audit-stats` invocation is a documented 4-read procedure.

---

### .claude/commands/update-ai-index.md — ACCEPTABLE

7-step maintenance procedure. Steps involve running SocratiCode and updating docs/ai/ files, not reading app source files. Acceptable for a maintenance command. No cap needed.

---

## Section 4 — Alignment Analysis (Code vs AI Documentation)

| Feature | Code Reality | AI Docs Status | Gaps |
|---|---|---|---|
| auth | AuthCubit, Supabase only, home/ has second auth impl | FEATURE_INDEX ✓ | None |
| home | MainPage: 5 local providers including ModuleCubit+HealthCubit | STATE_MANAGEMENT_INDEX now correct ✓ | None |
| prayer | PrayerCubit reads locale independently; v6 payload; nafl windows | All files accurate ✓ | None |
| dhikr | Fixed UUIDs; athkar_data.dart static data | FEATURE_INDEX ✓ | None |
| habits | HabitCubit cross-dep on PrayerRepository; uuid String? | FEATURE_INDEX ✓ | None |
| task | UnifiedTasksPage TaskCubit is action-only not dead | FEATURE_INDEX now correct ✓ | None |
| calendar | CalendarCubit, Supabase, AppointmentModel | FEATURE_INDEX ✓ | None |
| focus | FocusCubit, Pomodoro | FEATURE_INDEX ✓ | None |
| health | HealthCubit, HealthKit/HealthConnect; shadows global | STATE_MANAGEMENT_INDEX ✓ | None |
| assets | AssetsCubit, Supabase | FEATURE_INDEX ✓ | None |
| space | SpaceCubit + 5 sub-cubits; ModuleCubit global+local | FEATURE_INDEX now has 8-step path ✓ | None |
| stats | Supabase-only; StatsHelpers formula | STATS_ENGINE_INDEX ✓ | None |
| subscription | RevenueCat, gates tasks/sync | FEATURE_INDEX ✓ | None |
| sync | 4-state decision matrix; background workmanager | FEATURE_INDEX ✓ | None |
| settings | LocaleCubit at core/presentation/ not features/settings/ | FEATURE_INDEX notes path ✓ | None |
| notifications | FCM + in-app feed; 5 schedulers | FEATURE_INDEX ✓ | None |
| iOS widgets | All 3 interactive; v6 payload; pending-action queues | WIDGET_INDEX complete ✓ | None |
| Android widgets | 3 types + 3 receivers; display-only; no UUID | FEATURE_INDEX + WIDGET_INDEX ✓ | None |
| supabase/ | migrations + revenuecat-webhook function | SUPABASE_INDEX.md created ✓ | None |

---

## Section 5 — Critical Gaps (Current State)

### CRITICAL (3 — all newly discovered in v2 audit)

---

**C1 — AI_WORKFLOW.md: Step 1 body still presents original 4-step sequential checklist**

File: `docs/ai/AI_WORKFLOW.md`, lines 15–22

The `## EXECUTION RULES` section at the top was correctly updated to "select ONE → execute." However, the detailed `## Step 1: Check docs/ai/ before touching code` section immediately below still says:

> "1. KNOWN_PROBLEMS.md 2. FEATURE_INDEX.md 3. DATA_FLOW_INDEX.md 4. STATE_MANAGEMENT_INDEX.md"

Two sections in the same file give contradictory instructions. Claude's reasoning will follow the more specific, numbered instruction (Step 1) and treat all 4 docs as required pre-flight. The EXECUTION RULES above are overridden by the procedure below.

**Severity**: This is the root cause that was supposed to be fixed in v1 but was only fixed in CLAUDE.md, not in AI_WORKFLOW.md.

---

**C2 — audit-widget.md: 7-step procedure with 3–5 source file reads, no cap**

File: `.claude/commands/audit-widget.md`

Steps 3, 4, and 5 each require source file reads. Step 5 alone references three files (`task_cubit.dart`, `habit_cubit.dart`, `app.dart`). No cap stated. No enforcement language. No MANDATORY START FILE reference.

Every `/audit-widget` invocation is a documented 4–5 file read procedure. This directly contradicts the max-2-reads rule.

**Severity**: The command is used for a legitimate task (widget audit), but its procedure institutionalizes over-reading.

---

**C3 — audit-stats.md: 6-step procedure with 4 mandatory source file reads, no cap**

File: `.claude/commands/audit-stats.md`

Steps 3–6 each require reading a source file. No cap stated. No MANDATORY START FILE reference. No enforcement language.

Same problem as C2 — every `/audit-stats` invocation consumes 4 reads before reporting.

---

### MEDIUM (0)

All 6 MEDIUM gaps from v1 have been resolved.

---

### LOW (5 — carried from v1)

**L1 — KNOWN_PROBLEMS.md P4 status is "unconfirmed"**
P4 (NavBar add-task/habit not appearing) has been "unconfirmed" since Phase 4. Needs escalation or closure.

**L2 — FILE_INDEX.md missing core/iam/ and core/time_engine/**
Both directories contain high-risk code (RBAC and prayer time calculation). Neither listed.

**L3 — FILE_INDEX.md missing Android widget files**
Six `.kt` files are high-risk for widget data issues but absent from FILE_INDEX.

**L4 — ARCHITECTURE_INDEX.md global cubit count is stale**
States "18+" in the named cubit list (line 29). STATE_MANAGEMENT_INDEX now has 20 rows. Cross-file inconsistency is low risk but creates confusion.

**L5 — DATA_FLOW_INDEX.md missing Android widget data push flow**
The iOS widget push flow is documented. Android is not. Adding it would complete the picture.

---

## Section 6 — Behavior Analysis: Why Over-Searching Can Still Occur

### Active contradictions in the current AI layer

Three contradictions remain that allow over-searching to occur by following documented instructions:

**Contradiction A — AI_WORKFLOW.md internal conflict**

Top section says: "select ONE file → execute."
Step 1 section says: "check these 4 docs before reading source files."

When Claude reads AI_WORKFLOW.md and encounters two conflicting instructions, the more specific and detailed one wins. Step 1 has numbered items and specific file names. EXECUTION RULES has general principles. Result: Claude follows Step 1.

**Contradiction B — audit-widget.md explicitly requires 3+ source file reads**

The max-2-reads rule exists in EXECUTION SYSTEM, EXECUTION RULES, analyze-feature.md, and fix-bug.md. But audit-widget.md says to read widget_data_service.dart AND the Swift file AND the cubit file — all three are legitimate targets. When a command explicitly says "read X and Y," Claude cannot disobey the command and still fulfill its purpose.

**Contradiction C — audit-stats.md explicitly requires 4 source file reads**

Same pattern. The command itself is the source of the violation.

### Root cause that persists

Commands are instructions, not suggestions. When a slash command says "read X," Claude reads X — even if CLAUDE.md says "max 2 reads." Command-level instructions are more proximate to the task than document-level policies. The only fix is to embed the cap inside the command itself.

---

## Section 7 — Missing Enforcement Layer (Current State)

### 7.1 — Decision Lock

**Status**: Present and effective in CLAUDE.md and FEATURE_INDEX.md.

**Remaining weakness**: AI_WORKFLOW.md Step 1 body creates a 4-doc pre-flight that delays the lock. The lock is triggered after Step 1 completes, which requires 4 doc reads.

### 7.2 — Forced Entry Points

**Status**: Fully implemented. Every feature entry has MANDATORY START FILE with "no alternative entry allowed." Android Widgets entry added.

**Remaining weakness**: audit-widget.md does not use MANDATORY START FILE language. It builds its own entry point logic independently.

### 7.3 — First Match Execution

**Status**: Stated correctly in CLAUDE.md EXECUTION SYSTEM, DECISION LOCK, and AI_WORKFLOW.md EXECUTION RULES.

**Remaining weakness**: The EXECUTION RULES cap is overridden within AI_WORKFLOW.md itself by Step 1's 4-doc checklist.

### 7.4 — Anti-Overvalidation

**Status**: Present in CLAUDE.md and command files (analyze-feature.md, fix-bug.md).

**Remaining weakness**: audit-widget.md and audit-stats.md are structurally multi-read procedures. They are the two remaining institutionalized overvalidation workflows.

---

## Section 8 — Recommended Fix Plan

### Fix Priority 1 — AI_WORKFLOW.md Step 1 body (CRITICAL C1)

**File**: `docs/ai/AI_WORKFLOW.md`

Replace the `## Step 1: Check docs/ai/ before touching code` section body with a funnel that matches CLAUDE.md's AI Workflow section:

```
Before reading any source file, use this funnel — exit at the first step that answers your question:

1. `KNOWN_PROBLEMS.md` — known bug with a listed file? Go to that file. Stop here.
2. `FEATURE_INDEX.md` — find the MANDATORY START FILE. Once found: Read or Edit it. Stop here.
3. `DATA_FLOW_INDEX.md` — only if flow tracing is needed beyond the MANDATORY START FILE.
4. `STATE_MANAGEMENT_INDEX.md` — only for cubit instance disambiguation.

After step 2 gives you a file: your next action is a source file read, not another doc check.
```

---

### Fix Priority 2 — audit-widget.md: add cap and restructure (CRITICAL C2)

**File**: `.claude/commands/audit-widget.md`

Add at the top before Steps:
```
## Cap
Max 3 source file reads for a full audit. Prioritize by symptom:
- Data wrong → widget_data_service.dart (Read 1)
- Display wrong → Athar*Widget.swift (Read 2)
- Tap not working → cubit processWidgetPendingActions (Read 3)
Do not read all three unless the audit covers all three concerns.
```

Restructure steps 3–5 so they are conditional on the symptom, not always-required.

---

### Fix Priority 3 — audit-stats.md: add cap (CRITICAL C3)

**File**: `.claude/commands/audit-stats.md`

Add at the top before Steps:
```
## Cap
Max 2 source file reads. Start with stats_helpers.dart (computation) or
stats_remote_source.dart (data) depending on whether the issue is in the formula or the query.
Do not read all 4 source files unless each has a confirmed issue.
```

Restructure steps 3–6 as conditional paths, not a fixed sequence.

---

### Fix Priority 4 — ARCHITECTURE_INDEX.md cubit count (LOW L4)

Update line 29 from "18+" to "20+" and optionally list SpaceMembersCubit and ListCubit.

---

### Fix Priority 5 — FILE_INDEX.md: add core/iam/ and core/time_engine/ (LOW L2)

Add entries for `core/iam/` (RBAC, high-risk for space feature) and `core/time_engine/` (AtharTimeCalculator, used by WidgetDataService and TaskModel).

---

## Section 9 — Audit Metadata

### AI Layer Files Evaluated

| File | Status | Change Since v1 |
|---|---|---|
| `CLAUDE.md` | Improved | AI Workflow section collapsed to funnel |
| `docs/ai/AI_WORKFLOW.md` | Partial fix — C1 remains | EXECUTION RULES added; Step 1 body not updated |
| `docs/ai/FEATURE_INDEX.md` | Fixed | GLOBAL DECISION RULE removed; task/space/Android entries updated |
| `docs/ai/STATE_MANAGEMENT_INDEX.md` | Fixed | Typo, shadowing, missing cubits all corrected |
| `docs/ai/WIDGET_INDEX.md` | Fixed | Android section corrected |
| `docs/ai/STATS_ENGINE_INDEX.md` | Fixed | Productivity formula added |
| `docs/ai/SUPABASE_INDEX.md` | Created | New file |
| `docs/ai/DATA_FLOW_INDEX.md` | No change needed | Still 100% accurate |
| `docs/ai/KNOWN_PROBLEMS.md` | No change needed | Still current |
| `docs/ai/FILE_INDEX.md` | Not changed | L2, L3 still open |
| `docs/ai/ARCHITECTURE_INDEX.md` | Not changed | L4 still open |
| `docs/ai/PROJECT_MAP.md` | Not changed | Accurate |
| `.claude/commands/analyze-feature.md` | Fixed | Cap added |
| `.claude/commands/fix-bug.md` | Fixed | Cap added |
| `.claude/commands/audit-widget.md` | Not fixed — C2 | Multi-read procedure, no cap |
| `.claude/commands/audit-stats.md` | Not fixed — C3 | Multi-read procedure, no cap |
| `.claude/commands/update-ai-index.md` | No change needed | Maintenance only |

### Codebase Verification Method

All codebase facts confirmed via targeted `grep`/`sed` bash queries — no full source file reads. No source code modified.

### Gap Delta (v1 → v2)

| Category | v1 | v2 | Change |
|---|---|---|---|
| CRITICAL | 4 | 3 | −1 (4 fixed, 3 new discovered) |
| MEDIUM | 6 | 0 | −6 (all fixed) |
| LOW | 5 | 5 | 0 (carried) |
| **Total** | **15** | **8** | **−7** |
