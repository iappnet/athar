# CLAUDE.md

**Athar (أثر)** — Islamic productivity Flutter app. iOS + Android. Arabic-first.
Stack: Flutter/Dart, Supabase (remote), Isar (local), Firebase FCM, RevenueCat.

> **For detailed references, use `docs/ai/`.**
> Start every session by checking `docs/ai/KNOWN_PROBLEMS.md` and `docs/ai/AI_WORKFLOW.md`.

---

## Setup

`.env` at project root is required:
```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

## Commands

```bash
flutter pub get
flutter run
flutter analyze                                              # must be zero issues before any commit
flutter test
flutter pub run build_runner build --delete-conflicting-outputs   # after @injectable or Isar model changes
flutter gen-l10n                                             # after editing lib/l10n/app_ar.arb or app_en.arb
cd ios && fastlane beta                                      # TestFlight build
```

---

## Architecture

**Clean Architecture** + feature modules. Each feature: `data/` → `domain/` → `presentation/`.
State: **Cubit** (flutter_bloc). DI: **GetIt + Injectable**.
Full details: `docs/ai/ARCHITECTURE_INDEX.md`.

### Key files
- `lib/main.dart` — startup sequence (Firebase → Supabase → RevenueCat → DI → runApp)
- `lib/app.dart` — global MultiBlocProvider (18+ cubits), routes, `onResume` widget action handler
- `lib/core/di/injection.config.dart` — generated, never edit
- `lib/core/services/widget_data_service.dart` — Flutter ↔ iOS widget bridge

### Navigation
Named routes in `app.dart`. No GoRouter (`core/config/routes.dart` is an unused stub).
Global navigator key: `DeepLinkService.navigatorKey`.

---

## Features

16 feature modules under `lib/features/`. Full list: `docs/ai/FEATURE_INDEX.md`.

Critical per-feature notes:
- **task**: No local Isar datasource class. Display is via `TimelineCubit` (Isar stream), NOT `TaskCubit`.
- **habits**: `HabitType.regular` only shown in widget. Athkar excluded by design.
- **home/MainPage**: Provides local `TaskCubit` and `HabitCubit` that shadow the global ones.

---

## iOS Native Widgets

Three extensions: `AtharPrayerWidget`, `AtharTaskWidget`, `AtharHabitWidget`.
All use App Group `group.com.iappsnet.athar`. iOS 17.0 minimum.
Full details: `docs/ai/WIDGET_INDEX.md`.

**WidgetKeys** (`widget_data_service.dart`) — constants map to UserDefaults keys on installed devices. **Never rename them.**

---

## State Management Traps

Three `TaskCubit` instances exist at runtime:
1. Global (app.dart) — shadowed by 2 and 3
2. MainPage (local) — used by add sheet, onResume action handler
3. UnifiedTasksPage (local, no `watchTasks()`) — effectively empty; display uses TimelineCubit

Full tree + all cubits: `docs/ai/STATE_MANAGEMENT_INDEX.md`.

---

## Non-Negotiable Rules

| Rule | Reason |
|------|--------|
| Never rename `WidgetKeys` constants | Breaks installed widgets on all user devices |
| Never change App Group ID `group.com.iappsnet.athar` | Breaks widget data on all installed devices |
| Never edit `*.g.dart` files | Overwritten on next `build_runner` run |
| Never add page-level FABs to TaskPage or HabitPage | Central NavBar `+` is the only add entry point |
| iOS deployment target stays 17.0 | Required for AppIntentConfiguration (interactive widgets) |
| Do not use GoRouter | Stub only; all routing in app.dart named routes |

---

## Localization

- Primary: `ar-SA`. Secondary: `en-US`.
- ARBs: `lib/l10n/app_ar.arb`, `lib/l10n/app_en.arb`. Run `flutter gen-l10n` after edits.
- `LocaleCubit` stores `'ar'`/`'en'` in `FlutterSecureStorage('preferred_locale')`; null = system.
- `MaterialApp` has `localeResolutionCallback`: ar→ar-SA, en→en-US, other→en-US.
- **Widget locale bug (Phase 5 open)**: `LocaleCubit.setLocale()` does not update `athar_app_locale` in UserDefaults. Fix documented in `docs/ai/KNOWN_PROBLEMS.md`.

---

## Design System

Token barrel: `import 'package:athar/core/design_system/tokens/tokens.dart'`
Design size: 375×812 (`ScreenUtilInit`). Font: **Calibri** (canonical brand font as of PR1).

**PR1 complete (2026-05-09, commit `61d741a`):**
- Color tokens: green brand palette (light) + warm green-tinted dark surfaces (`THEME_DARK_SPEC.md`)
- Typography: `fontFamilyAr/En = 'Calibri'`; `numericMono` TextStyle added
- Font assets: `calibri-light.ttf`, `calibri-regular.ttf`, `calibri-bold.ttf` in `assets/fonts/`
- Dark mode `ThemeMode` wiring: **NOT YET** — target PR-THEME

**Token authority:**
- Light tokens: `handoff_v2-2/colors_and_type.css`
- Dark surfaces/text: `handoff_v2-2/THEME_DARK_SPEC.md` (overrides CSS)
- Implementation: `lib/core/design_system/tokens/athar_colors.dart` + `athar_typography.dart`

**v2 implementation status:** See `IMPLEMENTATION_MASTER_STATUS.md` for full PR sequence (14 PRs, PR1 complete).

---

## Known Open Bugs

See `docs/ai/KNOWN_PROBLEMS.md` for full issue list.

Active open items:
- B1: Calibri App Store licence unconfirmed (submission gate — not a dev/build blocker)
- B2: `isAutoModeEnabled` → `ThemeMode` not wired (target: PR-THEME)
- P4: Task/Habit added via NavBar may not appear (unconfirmed; see KNOWN_PROBLEMS.md)

Previously fixed: P1 (widget locale), P2 (task UUID cache miss), P3 (habit UUID cache miss)

---

## EXECUTION SYSTEM

**Hard caps**: max 2 searches · max 2 reads · then execute without exception.

- `FEATURE_INDEX.md` → ONE feature → ONE entry file → implement. No reconfirmation.
- File identified from any index → execute. No alternative search. No extra reads.
- First valid SocratiCode result = accepted. Do NOT re-search for better matches.
- Can one file solve it? Read only that file. Multiple-file reads require explicit justification.
- 70% confidence = execution threshold. Over-validation is incorrect behavior.
- Do NOT compare multiple files, cubits, or paths. First match executes.

**Stop immediately when**: file identified from any index · SocratiCode confirmed a path · function location is known.

## DECISION LOCK (MANDATORY)

- Target file selected → decision is locked.
- No second opinion. No "let me also check" behavior.
- No alternative search after identification.
- Cap reached (2 searches / 2 reads) → stop, assume correctness, execute immediately.
- Over-validation = violation.
- First match executes.

---

## AI Workflow

Entry funnel — stop at the first doc that answers your question. Do NOT check all 4.

1. `KNOWN_PROBLEMS.md` — known bug with a listed file? Go to that file immediately. Stop.
2. `FEATURE_INDEX.md` — find the MANDATORY START FILE. Once you have it: your next action MUST be Read or Edit on that file. No further search allowed.
3. `DATA_FLOW_INDEX.md` — only if MANDATORY START FILE alone is insufficient for flow tracing.
4. `STATE_MANAGEMENT_INDEX.md` — only for cubit instance disambiguation.

Full workflow: `docs/ai/AI_WORKFLOW.md`.

## Slash Commands

- `/update-ai-index` — re-index SocratiCode + update docs/ai/ after large changes
- `/analyze-feature <name>` — end-to-end feature analysis
- `/fix-bug <description>` — structured bug investigation and fix
- `/audit-widget <prayer|task|habit>` — full widget audit
- `/audit-stats` — stats engine audit

## gstack
Use /browse from gstack for all web browsing.
Available skills: /office-hours, /plan-ceo-review, /plan-eng-review, /plan-design-review, /review, /ship, /qa, /cso, /autoplan, /investigate, /retro.
## Skill routing

When the user's request matches an available skill, ALWAYS invoke it using the Skill
tool as your FIRST action. Do NOT answer directly, do NOT use other tools first.
The skill has specialized workflows that produce better results than ad-hoc answers.

## CHANGE LOG USAGE RULE

- Change logs are used for file targeting only
- Do NOT read full change logs
- Extract file paths and issue titles only
- Treat logs as navigation hints, not documentation


Key routing rules:
- Product ideas, "is this worth building", brainstorming → invoke office-hours
- Bugs, errors, "why is this broken", 500 errors → invoke investigate
- Ship, deploy, push, create PR → invoke ship
- QA, test the site, find bugs → invoke qa
- Code review, check my diff → invoke review
- Update docs after shipping → invoke document-release
- Weekly retro → invoke retro
- Design system, brand → invoke design-consultation
- Visual audit, design polish → invoke design-review
- Architecture review → invoke plan-eng-review
- Save progress, checkpoint, resume → invoke checkpoint
- Code quality, health check → invoke health

---

## DESIGN SYSTEM IMPLEMENTATION RULES

### Source of Truth
- Design system: `/Users/itech/Development/new_projects/Athar Design System/`
- Contract: `HANDOFF.md` → read in full before any design work
- Read order (non-negotiable): SKILL.md → colors_and_type.css → REDESIGN_AUDIT.md → CALENDAR_FOCUS_REDESIGN.md → FOCUS_OIL_SPEC.md → IPAD_OPTIMIZATION.md → design-context/_manifest.json → design-context/_core_extract.dart
- Visual targets: `ui_kits/athar_app/*.jsx` and `preview/*.html` — reference only, do not port JS/HTML

### Audit-First Workflow
- Before touching any UI file, write `design-context/_audit_<feature>.md`
- Audit must list: files inspected, what's already there (✅), gaps (❌), open questions
- Push audit. Wait for designer sign-off. Then implement.
- No implementation without audit sign-off — this is not optional

### No Implementation Before Approval
- Do NOT modify Dart UI code during an audit session
- Do NOT refactor screens during an audit session
- Do NOT migrate tokens during an audit session
- The audit and implementation are separate phases, separate PRs

### No Dart Changes During Audit Phase
- Audit sessions: read files, write markdown docs only
- Implementation sessions: edit Dart files only after audit is approved
- Never mix audit and implementation in the same session

### Do-Not-Break Constraints
- Prayer toggle hierarchy: isPrayerEnabled → isPrayerCardEnabled → isPrayerNotificationsEnabled → enablePrayerReminders (Phase 8.1)
- SubscriptionCubit must remain @lazySingleton (Phase 1 critical fix)
- WidgetKeys constants must never be renamed
- App Group ID `group.com.iappsnet.athar` must never change
- injection.config.dart is generated — never edit directly
- Central NavBar `+` FAB is the ONLY add entry point (no page FABs)
- All prayer notifications via PrayerNotificationScheduler only
- All strings in app_ar.arb + app_en.arb only

### Prayer Architecture Caution
- Four-level toggle: master → card → notifications → 15-min reminder
- Save-ordering rule: updateSettings() BEFORE scheduler call
- Scheduler guard: !isPrayerEnabled || !isPrayerNotificationsEnabled
- Migration flag: didMigratePrayerFeatureSettings (one-time)
- DO NOT simplify to a single boolean without full Phase 6/8/8.1 review

### Athkar Is Not a Habit Clone
- HabitType.athkar is a separate type — fixed items, counter-based, no edit
- lib/features/dhikr/ is the dhikr domain; athkar_card.dart + athkar_session_sheet.dart are in habits presentation
- Gate by isAthkarEnabled
- Do NOT merge Athkar into habits feature
- Do NOT redesign Athkar without an explicit Athkar UX spec from the designer
- Athkar iOS widget rows are read-only (no Button(intent:...))

### Calendar Dual Hijri/Gregorian Preservation
- package:hijri is already a dep — do NOT remove
- HijriService exists at lib/core/services/hijri_service.dart — do NOT remove
- Current dual_calendar_widget.dart has a TOGGLE (Hijri ⇄ Gregorian)
- Design spec requires SIMULTANEOUS display (both numerals in every cell)
- This is a near-complete calendar rebuild — requires dedicated designer spec sign-off
- DualDate value object, CalendarCell, DualMonthSwitcher must all be created
- isHijriMode setting still needed for primary numeral RTL position

### iOS Widget / AppIntent Caution
- Never rename WidgetKeys constants (breaks installed widgets on user devices)
- Never change App Group ID (breaks widget data on all installed devices)
- iOS 17.0 deployment target must stay (required for AppIntentConfiguration)
- Widget locale resolution: use Locale.current.language.languageCode?.identifier (Phase 4 fix)
- Athkar in widget: read-only rows, tp field a/r (Phase 5 fix)
- Short labels in small widget (Phase 4 fix)
- Any Swift change requires device test

### RTL/LTR Rules
- Always EdgeInsetsDirectional — never EdgeInsets.only(left/right)
- Always AlignmentDirectional — never Alignment.centerLeft/centerRight
- Always start/end — never left/right in Row/Stack context
- Icons implying direction must flip in RTL
- Prayer card, Hijri date: Arabic-Indic numeral option per locale
- Calendar: in RTL, Hijri numeral is primary (top-right), Gregorian secondary (bottom-left)

### Arabic / English Rules
- All user-facing strings in app_ar.arb + app_en.arb — no exceptions
- Run flutter gen-l10n after any ARB edit
- Cairo (AR primary font, 4 weights loaded), Inter (EN), JetBrains Mono (numbers)
- Font decision: Calibri (design spec primary) vs Cairo (current Flutter) — UNRESOLVED. Do not ship Calibri without designer confirmation and pubspec update.
- Tabular figures (fontFeatures: [FontFeature.tabularFigures()]) on all counters, timers, stats

### Required Logging / Change-Log Rules
- Every design-related session must produce a change log at: docs/ai/change-logs/CHANGE_LOG_YYYY-MM-DD_HH-mm.md
- Change log must include: files read, files created/updated, audit scope, key conclusions
- Change log must confirm: no Dart code modified, no UI implementation started
- All audit output files go to design-context/ in the Flutter project root

### Required Evidence-Based Reporting
- Never claim a component is "covered" unless you have read the file
- Never claim a spec is "implemented" unless you have verified it in Dart code
- If a file was not read, classify as "Unclear" not "Covered"
- If a screen cannot be found, say "not found" clearly
- Every claim in an audit doc must cite the evidence file
