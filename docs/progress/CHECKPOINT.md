<!--
CANONICAL-FOR: Current session state — what is happening right now
OWNER:         Claude Code
PRECEDENCE:    2 (wins on "current state" over all plan/roadmap files)
LAST-UPDATED:  2026-06-02 · font name SSOT refactor committed · 44de6f8
LOADS-AT:      Tier 0
-->

# CHECKPOINT — Athar v2 Design System
**Rule:** Update this file as the FINAL action of every session and immediately after each commit or tag. On any resume, read this file FIRST, then verify against `git log` before acting.

---

## LAST UPDATED

**Timestamp:** 2026-06-02 (font-SSOT refactor · `44de6f8`)
**Commit:** `44de6f8` refactor(ds): font name single-source via AtharTypography.fontFamily (no literal Calibri)
**Prior:** `a1f28e0` refactor(PR-TASK-REFRESH): Tasks UI → context.colors + Calibri + RTL, dark-mode-correct; strip ~7.1k dead lines
**Note:** Inter-PR governance fix (no visual change). 162 `fontFamily: 'Calibri'` literals → `AtharTypography.fontFamily` across 35 files. `static const String fontFamily = fontFamilyAr` added to AtharTypography. flutter analyze: 0 issues. /drift-check PASS.

---

## CURRENT PR + PHASE

**Active PR:** PR-TASK-REFRESH ✅ COMPLETE  
**Last committed:** PR-TASK-REFRESH · `a1f28e0`  
**Phase:** Complete. /drift-check PASS. Pushed to remote.  
**Next:** PR-HABITS-REFRESH (next UI coverage refresh PR — same canonical DS recipe).

---

## DONE — PR-DS-ATOMS IMPLEMENTATION

- ✅ `lib/core/design_system/atoms/buttons/app_button.dart` — 3 semantic hex consts removed; danger/success/warning → colorScheme.error/colors.success/warning; Calibri on button + FAB label; 706-line commented block deleted; rename TODO added
- ✅ `lib/core/design_system/molecules/bars/filter_bar.dart` — RTL: EdgeInsets.only(left)→EdgeInsetsDirectional.only(start); Calibri on labelStyle; commented block deleted
- ✅ `lib/core/design_system/molecules/board/kanban_board.dart` — Colors.blueAccent→colors.info; Color(0xFF00B894)→colors.success; Calibri on 3 TextStyles; commented block deleted
- ✅ `lib/core/design_system/molecules/headers/page_header_delegate.dart` — Calibri on dateStr (Amiri on quote preserved intentionally); commented block deleted
- ✅ `lib/core/design_system/molecules/pickers/athar_date_picker.dart` — Calibri on 4 TextStyles; commented block deleted
- ✅ `lib/core/design_system/molecules/pickers/reminder_picker_widget.dart` — Calibri on 3 TextStyles; commented block deleted
- ✅ `lib/core/design_system/molecules/strips/calendar_strip.dart` — Calibri on 2 TextStyles; commented block deleted
- ✅ `lib/core/design_system/molecules/tiles/minimal_habit_tile.dart` — Colors.blueAccent→colors.info; Color(0xFF00B894)×2→colors.success; Colors.orange×3→colors.warning; 4 RTL fixes (EdgeInsetsDirectional + AlignmentDirectional); Calibri on 2 TextStyles; commented block deleted
- ✅ `lib/core/design_system/molecules/tiles/unified_timeline_tile.dart` — Colors.orange(medicine)→colors.warning; AlignmentDirectional.centerStart; EdgeInsetsDirectional.only(start); Border(right)→BorderDirectional(end); Calibri on 2 TextStyles; commented block deleted
- ✅ `flutter analyze` — 0 errors (2 pre-existing warnings)
- ✅ COMMITTED `028f99f` + pushed

---

## IN PROGRESS — PR-ONBOARD-AB-UI (HOLD — awaiting ARB review)

- ✅ `docs/design-specs/ONBOARDING_AB_SPEC.md` — corrected (3 OQ rulings: /login routing, joinSpace(token), OQ1 module step)
- ✅ `docs/design-specs/_SYNC.md` — sync log entry added
- ✅ `lib/l10n/app_en.arb` + `lib/l10n/app_ar.arb` — 37 new keys: 8 Variant C + 29 Variant D (EN+AR)
- ✅ `lib/features/home/presentation/pages/onboarding_restyled_page.dart` — Variant B (forest+Calibri, strict parity with A, 380ms, same ARB keys, `/login`)
- ✅ `lib/features/home/presentation/pages/onboarding_short_page.dart` — Variant C (2 slides, forest, Calibri, `/login`)
- ✅ `lib/features/home/presentation/pages/onboarding_expanded_page.dart` — Variant D (6 steps, PageView, WidgetsBindingObserver, OQ1 modules, location skip if prayer off, personal space created at finish, dynamic recap)
- ✅ `lib/app.dart` — 4-branch switch wired (B→RestyledPage, C→ShortPage, D→ExpandedPage)
- ✅ `flutter gen-l10n` — run; all 37 new keys generated
- ✅ `flutter analyze` — 0 errors (2 pre-existing warnings unrelated)
- ✅ Deferred QA bucket — ONBOARD-sweep entry added (MIGRATION_STATE.md, item 9/10)
- ✅ AR byte-verified: tanwin nasb (لاحقًا/شيئًا/مُنظَّم) clean; no direction marks; all 10 canonical values confirmed
- ✅ COMMITTED `729c23d` + pushed

---

## DONE — PR-ONBOARD-AB-INFRA IMPLEMENTATION

- ✅ Sign-off note + OQ rulings written into `design-context/_audit_onboarding.md`
- ✅ `lib/core/services/onboarding_variant_service.dart` — `OnboardingVariant` enum + `assignOrGet()` (25/25/25/25 by device_id.hashCode, dart-define override, reset())
- ✅ `lib/core/services/onboarding_analytics_service.dart` — 5 emitters (started/step_completed/step_skipped/completed/abandoned), Supabase anon insert, silent fail
- ✅ `lib/main.dart` — SharedPreferences.getInstance(), UUID v4 device_id seeding, `OnboardingVariantService.assignOrGet()`, pass variant to `AtharApp`
- ✅ `lib/app.dart` — `onboardingVariant` constructor param added; `home:` is now 4-branch switch (all → `OnboardingPage` for INFRA); variant pages land in UI PR
- ✅ `lib/features/settings/presentation/pages/general_settings_page.dart` — dev "Reset onboarding" tile (`kDebugMode` gate, clears `onboarding_seen` + `onboarding_variant`, SnackBar prompt)
- ✅ `supabase/migrations/20260602_onboarding_events.sql` — table + anon insert RLS policy + authenticated select
- ✅ `test/widget_test.dart` — updated with `onboardingVariant` param
- ✅ `flutter analyze`: 0 errors, 2 pre-existing warnings
- ✅ Bucket distribution verified: 25.7/21.6/27.6/25.1% across 1000 simulated device_ids
- ✅ dart-define override mapping verified: all 4 snake_case → camelCase conversions correct
- ✅ COMMITTED `1f868f9` + pushed

---

## DONE — PR-ONBOARD-AB AUDIT SESSION

- ✅ `docs/design-specs/ONBOARDING_AB_SPEC.md` — 502 lines fully read
- ✅ `lib/features/home/presentation/pages/onboarding_page.dart` — Variant A scaffold confirmed (4 slides, onboarding_seen key, RTL-safe skip)
- ✅ `lib/app.dart` — routing section read; current home: switch at ~line 200-202 (spec says 187-189)
- ✅ Infra grep — Supabase analytics: ABSENT (net-new). device_id: ABSENT (A/B split broken).
- ✅ UserSettings model — module flag inventory: Prayer + Athkar exist; Tasks/Habits/Health/Assets have NO master feature toggle
- ✅ JoinSpaceCubit, SpaceCubit, LocationSettingsPage, NotificationService, LocationService — all confirmed present with correct signatures
- ✅ `design-context/_audit_onboarding.md` — written (6 OQs, 2 blockers, scope recommendation, full dependency table)
- ✅ CHECKPOINT.md updated (audit-in-progress state)
- ⏸ NO DART MODIFIED THIS SESSION

---

## DONE THIS SESSION (cumulative)

- ✅ Produced `SESSION_RECOVERY_REPORT.md` — full evidence-based gap list (9 items)
- ✅ Pushed tag `athar-v2-pr4a-complete` to remote (was local-only)
- ✅ Created `PR4A_FINAL_REPORT.md` — files changed, arch changes, token migration, deferred gates
- ✅ Fixed stale PR4a row in `IMPLEMENTATION_MASTER_STATUS.md` (`🔲 Not started` → `✅ Complete`)
- ✅ Added SSOT header + CHECKPOINT pointer to `IMPLEMENTATION_MASTER_STATUS.md`
- ✅ Updated PR4a % in completion table (4 PRs → 5 PRs, ~29% → ~36%)
- ✅ Updated "Recommended Next PR" section in `IMPLEMENTATION_MASTER_STATUS.md`
- ✅ Reduced `PROGRAM_IMPLEMENTATION_STATUS.md` — replaced roadmap + % sections with SSOT pointers
- ✅ Reduced `phase_tracker.md` — replaced PR ordering table (lines 214–234) with pointer
- ✅ Updated `current_project_status.md` — PR4a added to completed work; Next PR updated
- ✅ `CURRENT_MIGRATION_STATE.md` — stripped PR-order sections; renamed "PR4a Deferred QA Gates" → "Deferred QA Bucket"; added governance rules (AFTER PR6 / BEFORE PR7, 10-item ceiling); relabelled gates "Deferred QA Candidate Fix (UNVERIFIED...)"
- ✅ Created `ROADMAP_AFTER_PR4A.md` — completed PRs, next options, PR4b architecture feasibility question with 3 options (a/b/c), deferred QA bucket
- ✅ Moved PR3 artefacts to `docs/pr3-artifacts/` (4 files)
- ✅ Committed all governance docs
- ✅ Created `docs/progress/CHECKPOINT.md` (this file)

---

## DONE — AUDIT SESSION

- ✅ `design-context/_audit_accessibility.md` — PR5 audit complete (11 files read, no Dart touched)
- ✅ `design-context/_audit_calendar_dual.md` — PR4b architecture feasibility audit complete (9 files read, no Dart touched)

## DONE — PR9 IMPLEMENTATION

- ✅ `design-context/_audit_widgets.md` — PR9 audit complete + OQ rulings written (OQ1–OQ8)
- ✅ `lib/core/services/widget_data_service.dart` — v7 keys (isPrayerEnabled, habitsHistory7d); v8 keys (sunriseTime, sunsetTime); pushPrayerData params wired
- ✅ `ios/AtharPrayerWidget/AtharPrayerWidget.swift` — forest v2 palette, Calibri, systemLarge (dual-date, 40pt countdown, 5-prayer strip, sunrise/sunset row, progress bar), isPrayerEnabled gate (Conflict A), 40-min window (OQ2), widgetURL, accessory sizes
- ✅ `ios/AtharHabitWidget/AtharHabitWidget.swift` — forest v2 palette, Calibri, ProgressRingView (AtharColors.success), 7-day history grid, medium/large/small all refreshed
- ✅ `ios/AtharTaskWidget/AtharTaskWidget.swift` — forest v2 gradient + Calibri tokens (OQ8 token-only scope)
- ✅ `lib/features/prayer/presentation/cubit/prayer_cubit.dart` — P9-B isPrayerEnabled wired; P9-A sunrise/sunset extracted + pushed
- ✅ P9-C: RESOLVED — widget adopts dynamic formula (`round(0.3×interval) clamp(15,45)`, Fajr=40/Maghrib=20 overrides); spec corrected in PRAYER_CARD_SPEC + IOS_WIDGETS_SPEC (`0247c2a`)
- ✅ `flutter analyze` 0 errors (2 pre-existing)
- ✅ PR9 committed + pushed; deferred QA bucket updated (7/10)

## DONE — PR5 IMPLEMENTATION

- ✅ Designer sign-off received — all 10 open questions resolved
- ✅ `design-context/_audit_accessibility.md` — sign-off note written
- ✅ `lib/features/settings/data/models/user_settings.dart` — 3 fields added: `reduceMotion`, `disableGyroscope`, `easternNumerals` (all default `false`); constructor params added
- ✅ `build_runner` — Isar schema regenerated (`user_settings.g.dart` updated, 326 outputs, 0 errors)
- ✅ `lib/features/settings/presentation/cubit/settings_cubit.dart` — 3 toggle methods added
- ✅ `lib/features/settings/presentation/cubit/settings_state.dart` — 3 fields added to `SettingsLoaded.props`
- ✅ `lib/features/settings/presentation/pages/general_settings_page.dart` — "Accessibility" section inserted after Security, before Sync & Account; 3 `_SwitchTile` widgets with `_Divider` separators
- ✅ `lib/l10n/app_ar.arb` — 6 ARB keys added (section header + 3 titles + 3 subtitles)
- ✅ `lib/l10n/app_en.arb` — 6 ARB keys added
- ✅ `flutter gen-l10n` — generated localization files
- ✅ `flutter analyze` — 0 issues
- ✅ ARB copy approved (2026-06-01): 5 EN + 4 AR strings updated to designer-approved wording; `flutter gen-l10n` + `flutter analyze` clean

## PR4b ARCHITECTURE LOCKED

- ✅ Design authority approved Option (b): new `CalendarMonthCubit` owns month aggregation + `DualDate` cache
- ✅ 5 dot sources locked (task, habit, appointment, medicine, prayer — per-prayer timed dots)
- ✅ `showPrayerDotsOnCalendar` UserSettings field to be added in PR4b's build_runner pass
- ✅ `isHijriMode` reused in place — no new field
- ✅ PR4b BLOCKED until after PR5 → PR6 → post-PR6 QA sweep

## STAGE A — COMPLETE

- ✅ A1: 6 drift fixes in-place (previous session)
- ✅ A2: Governance file installs — `MIGRATION_REPORT.md` committed; `.claude/` files local-only (correct, gitignored) — commit `df6bf87`
- ✅ A3: Mandatory headers on all ~20 living files + governance dir + documentation-audit dir installed — commit `077af7e`
- ✅ A4: Context Loading Directive added to CLAUDE.md — commit `ee39e43`
- ✅ /drift-check gate: 3 failures found and fixed (PR5+PR6 rows, %, CHECKPOINT internal drift)
- ✅ A5 (addendum): VCS policy — blanket `.claude/` ignore replaced with machine-local-only rules; 7 project-memory files now tracked — commit `510cb0a`

## DONE — UI COVERAGE AUDIT SESSION (2026-06-02)

- ✅ `design-context/_audit_ui_coverage.md` — full 3-pass coverage audit written
- ✅ Pass 1: 53 screens/pages classified (12 ✅ / 23 🟡 / 18 ❌)
- ✅ Pass 2: 71 widgets + DS components (24 ✅ / 32 🟡 / 15 ❌)
- ✅ Pass 3: 27 dialogs/sheets (0 ✅ / 5 🟡 / 22 ❌) + combined summary
- ✅ Grand total: 151 surfaces — 24% conformant, 40% partial, 36% not-migrated
- ✅ Key finding: 5 missing refresh PRs not in current roadmap (Task, Health, Space, Settings, DS-Atoms)
- ✅ Key finding: `add_task_sheet.dart` = 112 old refs (heaviest single file); `athar_app_bar.dart` = highest-ROI DS fix
- ⏸ NO DART CODE MODIFIED THIS SESSION

---

## NEXT ACTION

**PR-TASK-REFRESH complete.** 20 task-feature files migrated (context.colors + Calibri + RTL). Next:
- **PR-HABITS-REFRESH** — Habits feature UI DS refresh (same canonical DS recipe)
- **PR-ADHAN** — blocked on B4 (audio asset from designer)

**OPS-1 reminder:** `supabase/migrations/20260602_onboarding_events.sql` must be applied to live Supabase project before A/B test goes live. Until then, analytics inserts no-op silently.

Deferred QA sweep bucket: 8/10 items (ceiling: 10).

---

## OPEN DECISIONS AWAITING DESIGNER

| ID | Decision | Blocks |
|----|----------|--------|
| B1 | Calibri App Store licence confirmation | App Store / TestFlight submission |
| B4 | Adhan audio asset delivery | PR-ADHAN start |
| ~~PR4b-abbr~~ | ~~3-letter Hijri month abbreviation table~~ | ✅ Resolved — `HIJRI_MONTH_ABBREVIATIONS.md` used in PR4b |
| PR5-copy | ~~Review ARB copy for 3 accessibility tiles~~ | ✅ Resolved 2026-06-01 |

---

## WORKING TREE STATE

**Status:** Clean — font SSOT refactor committed + pushed  
**flutter analyze:** 0 issues  
**Last commit:** `44de6f8` refactor(ds): font name single-source via AtharTypography.fontFamily (no literal Calibri)
