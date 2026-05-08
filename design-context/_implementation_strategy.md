# Implementation Strategy — Athar Redesign

_Phase 5 output. Generated: 2026-05-06. No Dart code in this document._

**Status:** Audit complete. Implementation NOT started. This document requires designer sign-off before any Phase B work begins.

---

## 1. Recommended Implementation Order

### Phase A: Tokens / Theme Audit (prerequisite for everything)
**Before writing a single line of UI code.**

1. Resolve Calibri vs Cairo decision (designer decision required)
2. If Calibri: add to `pubspec.yaml`, update `AtharTypography.fontFamilyAr`
3. Add `numericMono` named style to `AtharTypography`
4. Add `tabularFigures` font feature to numeric styles
5. Audit all 88 hardcoded-color files — replace `Color(0x...)` with `AtharColors.*` tokens
6. Audit remaining `EdgeInsets.left/right` violations — replace with `EdgeInsetsDirectional`
7. Run `flutter analyze` — zero issues before Phase B

**Deliverable:** Token migration PR. No visual changes on screen — only code hygiene.

---

### Phase B: Shared UIKit Components
**After tokens are clean.**

1. `EmptyState` widget (feature-specific variants + generic)
2. `ErrorState` widget (full-page + inline + compact)
3. `AtharSheetHeader` (extract from unified_add_sheet)
4. `SettingsSection` + `SettingsToggleTile` (formalize from settings pages)
5. `AtharSectionHeader` (formalize from section headers)
6. `AdaptiveShell` — resolve with `AdaptiveScaffold` at `lib/core/layouts/adaptive_scaffold.dart`:
   - Decision: rename/move `AdaptiveScaffold` → `AdaptiveShell` or create new wrapper
   - Must use `LayoutBuilder`, not `MediaQuery.size.width`
   - FAB (`+`) must move to rail leading slot on tablet
7. Validate `AdaptiveShell` on Dashboard (phone + iPad portrait + iPad landscape)
8. `PrayerTimeRow` (extract from prayer_day_view.dart as standalone molecule)
9. Audit `app_button.dart` for gradient fill compliance; add loading state if missing
10. `SyncStatusCard` (new)

**Deliverable:** Shared UIKit library PR. All components have AR/EN, RTL/LTR, dark/light tested.

---

### Phase C: Dashboard
**Prerequisite: Phase A + B complete. Prayer card redesign requires designer sign-off.**

1. Merge 3 duplicate home pages → keep `dashboard_page.dart`, port unique code, delete others
2. De-dupe `home_header.dart` (remove pages/ copy)
3. Fix greeting to use `AtharTimeCalculator` instead of `DateTime.hour < 12`
4. Prayer card — compact/expanded variants (requires designer approval first)
   - **DO NOT TOUCH:** `SmartPrayerCardWrapper` toggle guards
5. Prayer card — mono countdown font, Hijri-prominent date
6. Smart habits strip — visual refresh (tokens only)
7. Daily timeline — visual refresh
8. Dashboard iPad 2-col layout (portrait)
9. Dashboard iPad 3-col layout (landscape)
10. Wrap body in `AdaptiveShell`

**Deliverable:** Dashboard redesign PR.

---

### Phase D: Tasks + Habits
**Prerequisite: Phase C complete.**

1. Task tile — visual token refresh
2. Task list — filter chips with tokens
3. Quick-add row (new widget using SmartTimeParser)
4. Smart-time chips (new, via SmartTimeParser)
5. Task iPad master-detail layout
6. Task detail iPad right-rail (3rd column at ≥1200)
7. Habit tile — grid variant
8. Habit streak ring — verify visual spec compliance
9. Habit streak chip — numericMono font
10. Habit heatmap — token colors (AppColors.success ramp)
11. Habit iPad 2-col grid (portrait) + 3-col + right pane (landscape)
12. Athkar card — **wait for designer Athkar UX spec before touching**

**Deliverable:** Tasks PR + Habits PR (separate PRs).

---

### Phase E: Prayer + Athkar
**Prerequisite: Phase D complete. Prayer spec must be signed off. Athkar spec must exist.**

1. Prayer card full visual spec (compact + expanded + arc + progress)
2. Prayer day/week/month views — visual refresh
3. Persist compact/expanded preference via `SettingsCubit`
4. Athkar — **ONLY after explicit designer Athkar UX spec**
5. Dhikr session — haptic feedback on counter increment
6. Gate dhikr by `isAthkarEnabled`

**Deliverable:** Prayer PR + Athkar PR (separate, Athkar blocked on spec).

---

### Phase F: Settings + Forms
**Prerequisite: Phase E complete.**

1. Settings phone layout — visual refresh (tokens, spacing)
2. Settings iPad two-pane layout
3. Formalize `ModuleFlags` object (refactor individual booleans — **requires careful migration**)
4. Add Reduce Motion toggle to SettingsCubit + UserSettings
5. Add Disable Gyroscope toggle
6. Add Eastern Numerals toggle
7. Settings — Modules section (unified block per design spec)
8. BottomSheetForm base widget extraction
9. All add sheets — visual refresh using BottomSheetForm base
10. `CupertinoTextField` for Pencil support on text inputs
11. Paywall card — visual audit + refresh

**Deliverable:** Settings PR + Forms PR (separate).

---

### Phase G: Calendar + Stats
**Prerequisite: Phase F complete. Calendar requires dedicated designer sign-off on simultaneous dual display spec.**

**Calendar (HIGH RISK — near-complete rebuild):**
1. `DualDate` value object in `calendar/domain/entities/`
2. `CalendarCell` widget (Gregorian + Hijri numerals simultaneously)
3. `DualMonthSwitcher` widget (independent Gregorian + Hijri pill rows)
4. First-of-Hijri-month hairline marker
5. RTL numeral position swap (Hijri primary in RTL)
6. `CalendarCubit` — add Hijri anchoring methods
7. `TimelineItem` entity in `calendar/domain/entities/`
8. `CalendarCubit` fan-in from Tasks, Habits, Prayer, Health (or MultiBlocBuilder approach)
9. Calendar iPad month grid + side timeline

**Stats (DATA LAYER + VISUAL):**
1. Define `StatsRepository` interface methods
2. Implement fan-in aggregation from Tasks, Habits, Focus, Prayer
3. `StatsLoaded(period, KPIs)` state
4. `StatsMetricCard` widget
5. `ChartCard` wrapper
6. Connect `fl_chart` charts with live data
7. Stats iPad responsive grid

**Deliverable:** Calendar PR (high risk) + Stats PR (data + visual).

---

### Phase H: iOS Widgets
**Prerequisite: Phase G complete. Requires widget design spec from designer (currently missing).**

1. **BLOCKED:** Designer must create widget visual spec (small/medium/large × Prayer/Task/Habit)
2. Fix widget locale bug (KNOWN_PROBLEMS P1): update `athar_app_locale` in UserDefaults when `LocaleCubit.setLocale()` is called
3. Fix `toggleTaskCompletionByUuid` cache miss (KNOWN_PROBLEMS P2)
4. Fix `completeHabitByUuid`/`incrementHabitProgressByUuid` cache miss (KNOWN_PROBLEMS P3)
5. Widget dark mode design (if spec provided)
6. Widget medium/large variants (if spec provided)

**Deliverable:** Widget fixes PR + widget visual update PR (blocked on spec).

---

### Phase I: Final Polish / Accessibility / Localization
**Prerequisite: All previous phases complete.**

1. Systematic Semantics audit (screen reader support)
2. Contrast ratio audit (WCAG AA minimum)
3. Dynamic Type support (iOS)
4. Hover states sweep (MouseRegion on all interactive cards/rows)
5. Keyboard shortcuts implementation (`AtharShortcuts`)
6. CupertinoContextMenu sweep
7. Drag-and-drop (task → calendar, task → space)
8. Eastern Arabic numerals via `NumberFormat`
9. Calibri font integration (if decided in Phase A)
10. Golden tests for key screens
11. RTL/LTR pixel check for all redesigned screens
12. iPad Split View / Slide Over / Stage Manager testing

**Deliverable:** Polish + accessibility PR.

---

## 2. What to Migrate First

Answer: **Tokens.** Nothing else is safe until the 88 hardcoded-color files are cleaned up. Visual redesign on top of hardcoded colors will just layer technical debt.

---

## 3. What Must Be Audited Again Before Coding

| Item | Why Re-audit? |
|---|---|
| `next_prayer_card.dart` | Full spec from `comp-prayer-card.html` (not read) needed |
| `focus_page.dart` + `oil_animation.dart` | Full spec audit against FOCUS_OIL_SPEC.md |
| `lib/features/dhikr/` | Internal structure unknown |
| `stats_page.dart` + cubit | Confirm stub depth |
| Subscription page | Visual unknown |
| All 88 hardcoded-color files | Token compliance sweep |
| `main_page.dart` | Central NavBar dispatch mechanism — critical before shell work |

---

## 4. What Must Not Be Touched Initially

| Item | Reason |
|---|---|
| Prayer toggle hierarchy (Phase 8.1) | Critical recent fix — save-ordering constraints |
| `SubscriptionCubit` `@lazySingleton` annotation | Phase 1 critical fix — reverts cause infinite hang |
| `WidgetKeys` constants | Breaks all installed widgets if renamed |
| App Group ID | Breaks widget data on all installed devices |
| `injection.config.dart` | Generated file — run build_runner only |
| `*.g.dart` files | Overwritten by build_runner |
| Central NavBar `+` FAB dispatch | Phase 1/2/3 critical save fixes wired here |
| `HabitType.athkar` model | iOS widget payload uses `tp` field — break causes widget crash |

---

## 5. Risk Matrix

| Risk | Severity | Likelihood | Mitigation |
|---|---|---|---|
| Calendar rebuild breaks toggle users | HIGH | CERTAIN | Dedicated migration + user communication |
| Prayer toggle architecture regression | CRITICAL | HIGH | No touch without full Phase 6/8/8.1 context |
| Font switch (Calibri) breaks text layout | HIGH | MEDIUM | Test all screens in AR + EN before merging |
| Stats data layer doesn't match repository contract | HIGH | MEDIUM | Define interface before implementing |
| 88 hardcoded files introduce token regressions | MEDIUM | HIGH | Automated test for token usage |
| AdaptiveShell breaks existing phone nav | HIGH | MEDIUM | Phase B validation on Dashboard only first |
| iOS widget code breaks WidgetKeys | CRITICAL | LOW | Never rename constants; test on device |
| SubscriptionCubit singleton regression | CRITICAL | LOW | Phase 1 fix must not be reverted |
| Athkar redesign merges with habits | HIGH | LOW | Designer spec required; explicit rule in CLAUDE.md |

---

## 6. Rollback Strategy

- Each phase is a separate PR — rollback is git revert of that PR
- Token migration (Phase A) is the riskiest rollback scenario — affects 88+ files
- Prayer architecture changes have explicit test: `flutter analyze` + device test
- iOS widget changes require device test before merging
- Calendar rebuild: maintain `dual_calendar_widget.dart` as-is until new components are proven

---

## 7. Test Strategy

Per SKILL.md §4 (Definition of Done) — every PR must tick:
- [ ] Builds clean, `flutter analyze` zero warnings
- [ ] Dark mode + light mode pixel-checked
- [ ] RTL (Arabic) + LTR (English) pixel-checked
- [ ] iPhone 12 + iPad 11" portrait + iPad 12.9" landscape
- [ ] No hardcoded hex / spacing / strings
- [ ] Every mutation permission-gated
- [ ] Every notification via scheduler
- [ ] Cubit unit tests for new state transitions
- [ ] Golden test for at least iPhone variant

Additional:
- [ ] Prayer toggle sequence test (enable master → verify scheduler called; disable master → verify notifications cancelled)
- [ ] Calendar dual display: Hijri date correct for known dates
- [ ] iOS widget: locale resolution on Arabic device + English device

---

## 8. Screenshot Comparison Strategy

1. Screenshot all current screens before Phase A (baseline)
2. After each phase PR, screenshot same screens
3. Compare with `comp-*.html` / `ui_kits/athar_app/*.jsx` targets (visual reference)
4. Flag any regression in the PR description with before/after images
5. Suggested tool: `flutter_test` golden tests for automated regression detection

---

## 9. Phase Summary

| Phase | Scope | Risk | Blocked On |
|---|---|---|---|
| A | Tokens + font + hardcoded color cleanup | MEDIUM | Calibri decision |
| B | Shared UIKit components | LOW-MEDIUM | Phase A |
| C | Dashboard | MEDIUM | Phase B + prayer card spec |
| D | Tasks + Habits | MEDIUM | Phase C |
| E | Prayer + Athkar | HIGH | Phase D + Athkar spec |
| F | Settings + Forms | LOW-MEDIUM | Phase E |
| G | Calendar + Stats | VERY HIGH | Phase F + calendar spec sign-off |
| H | iOS Widgets | HIGH | Phase G + widget visual spec |
| I | Polish + Accessibility | LOW | Phase H |
