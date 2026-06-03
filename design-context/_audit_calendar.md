# Calendar Audit — PR4a Pre-Implementation

**Date:** 2026-06-01  
**Scope:** PR4a — Calendar Visual Refresh only. No Dart code modified.  
**Governance:** RULE 1 (window-based layout via LayoutBuilder) enforced throughout.  
**Awaiting sign-off before any implementation begins.**

---

## 1 — Files Inspected

| File | Lines | Role |
|------|-------|------|
| `lib/features/calendar/presentation/pages/calendar_page.dart` | 274 | Page scaffold + event list |
| `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart` | 306 | Calendar grid + header + toggle |
| `lib/features/calendar/presentation/cubit/calendar_cubit.dart` | 71 | State machine: selectDate → items |
| `lib/features/calendar/presentation/cubit/calendar_state.dart` | 34 | CalendarLoading / CalendarLoaded / CalendarError |
| `lib/features/calendar/domain/entities/calendar_item.dart` | 31 | CalendarTask + CalendarAppointment (sealed) |
| `lib/core/services/hijri_service.dart` | 29 | HijriCalendar wrapper (@lazySingleton) |
| `CALENDAR_FOCUS_REDESIGN.md` | ~195 | Designer spec — PR4b end-state |
| `CALENDAR_CELL_SPEC.md` | ~128 | Cell + header spec — PR4b end-state |
| `ADAPTIVESHELL_FOUNDATION_AUDIT.md` | audit | Shell foundation — Layer 1 complete |
| `PR4A_READINESS_SCOPE.md` | audit | Allowed/forbidden scope |
| `lib/core/utils/responsive_helper.dart` | 706 | Device detection (shortestSide-based) |
| `lib/core/design_system/widgets/adaptive_shell.dart` | 79 | Shell (LayoutBuilder-based) |

**No existing calendar golden or widget tests found.**

---

## 2 — Current Implementation State

### 2a — Architecture

```
CalendarPage (StatefulWidget)
  └── Scaffold
        ├── AppBar (title: l10n.calendarTitle)
        └── body: Align + ConstrainedBox(maxWidth: 900 on tablet*)
              └── Column
                    ├── BlocSelector<SettingsCubit> → DualCalendarWidget
                    ├── AtharGap.lg
                    ├── Day-events header row (l10n.calendarDayEvents + date)
                    ├── AtharGap.md
                    └── Expanded → BlocListener<TaskCubit> + BlocBuilder<CalendarCubit>
                          └── ListView.separated (TaskTile | _AppointmentTile)

DualCalendarWidget (StatefulWidget — 306 lines)
  State: _focusedMonth, _isGregorianPrimary, _isLoading
  ├── _loadCalendarPreference() → reads SettingsRepository directly
  ├── _changeMonth(±1) → setState
  ├── _toggleCalendarMode() → setState + writes SettingsRepository directly
  └── build() → Container
        ├── Header row (back arrow | title+subtitle+toggle icon | forward arrow)
        ├── AtharGap.xl
        ├── Weekday headers row (Row, spaceAround)
        ├── SizedBox(height: 10.h)
        └── GridView.builder (7-col, childAspectRatio: 0.85)
              └── per-cell: GestureDetector → Container (margin 2.w, AtharRadii.card)
                    └── Column(center) [primary text, secondary text]

CalendarCubit
  selectDate(date) → CalendarLoaded({selectedDate, items: List<CalendarItem>})
  — items contain tasks + appointments for the SELECTED DAY only
  — no month-level data, no activityByDate map

HijriService (@lazySingleton)
  — toHijri(date) → HijriCalendar.fromDate(date)
  — HijriCalendar.setLocal('ar') in constructor — ALWAYS Arabic locale
  — called ONCE PER CELL inline in GridView.builder → no caching
```

*`⚠️ RULE 1 VIOLATION` at `calendar_page.dart:53–56`: uses `context.isTablet` (shortestSide-based) for `ConstrainedBox`. Must be replaced with `LayoutBuilder` in PR4a.*

### 2b — What Is Already Correct

| Item | Evidence | Status |
|------|----------|--------|
| `AtharRadii.card` on cell corners | `dual_calendar_widget.dart:155,265` | ✅ Token |
| `AtharGap.xl` between header and weekdays | `dual_calendar_widget.dart:199` | ✅ Token |
| `AtharGap.md` in page event list | `calendar_page.dart:100` | ✅ Token |
| `AtharGap.lg` between calendar and list | `calendar_page.dart:74` | ✅ Token |
| `AtharGap.sm` in event list separator | `calendar_page.dart:155` | ✅ Token |
| `colorScheme.surface` for container bg | `dual_calendar_widget.dart:131` | ✅ Themed |
| `colorScheme.shadow.withValues(alpha:0.05)` | `dual_calendar_widget.dart:137` | ✅ Themed |
| `colorScheme.primary` for selected bg | `dual_calendar_widget.dart:260–261` | ✅ Themed |
| `colorScheme.onPrimary` for selected text | `dual_calendar_widget.dart:279` | ✅ Themed |
| `colorScheme.onSurface` for primary text | `dual_calendar_widget.dart:280` | ✅ Themed |
| `colorScheme.outline` for weekday labels | `dual_calendar_widget.dart:214` | ✅ Themed |
| `BlocSelector` passes `isHijriMode` from SettingsCubit | `calendar_page.dart:61–72` | ✅ Correct pattern |
| `BlocListener<TaskCubit>` refreshes on Isar update | `calendar_page.dart:111–117` | ✅ Correct |
| `AppointmentNotifier` subscription in cubit | `calendar_cubit.dart:25–28` | ✅ Correct |
| Both numerals always shown (not toggled) | `dual_calendar_widget.dart:246–295` | ✅ Partially per spec |
| `package:hijri` in use | `hijri_service.dart:1` | ✅ Confirmed |

---

## 3 — Gap Tables

### 3a — Token Gaps (hardcoded values that must become tokens)

| Location | Current | Required | Severity |
|----------|---------|----------|----------|
| `dual_calendar_widget.dart:130` | `EdgeInsets.all(16.w)` | `AtharSpacing.md` or equivalent token | Medium |
| `dual_calendar_widget.dart:133` | `BorderRadius.vertical(bottom: Radius.circular(30.r))` | Evaluate — no matching token exists; see Open Q7 | Medium |
| `dual_calendar_widget.dart:138` | `blurRadius: 10` | Design shadow token (PR3 used `blurRadius: 20/8`) | Low |
| `dual_calendar_widget.dart:139` | `Offset(0, 5)` | Shadow token | Low |
| `dual_calendar_widget.dart:166` | `fontSize: 18.sp, fontWeight: bold` | `AtharTypography` title token | High |
| `dual_calendar_widget.dart:175` | `fontSize: 12.sp, fontWeight: w600` | `AtharTypography` label token | High |
| `dual_calendar_widget.dart:209-215` | `fontSize: 14.sp, fontWeight: bold` (weekday) | `AtharTypography` label token | Medium |
| `dual_calendar_widget.dart:222` | `SizedBox(height: 10.h)` | `AtharGap.sm` | Low |
| `dual_calendar_widget.dart:229` | `childAspectRatio: 0.85` (hardcoded) | `LayoutBuilder`-computed per RULE 1 | High — see §4 |
| `dual_calendar_widget.dart:278-282` | `fontSize: 16.sp, fontWeight: bold` (primary cell) | `AtharTypography` body token | High |
| `dual_calendar_widget.dart:288-294` | `fontSize: 10.sp, fontWeight: w600` (secondary cell) | `AtharTypography` caption token | High |
| `dual_calendar_widget.dart:130` | `EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h)` (toggle Padding) | `AtharSpacing` token | Low |
| `calendar_page.dart:44-48` | `fontSize: 20.sp, fontWeight: bold` (AppBar title) | AppBar theme already handles this via `AtharLightTheme`; verify theme covers it | Low |
| `calendar_page.dart:83-88` | `fontSize: 16.sp, fontWeight: bold` (day-events header) | `AtharTypography` token | Medium |
| `calendar_page.dart:89-93` | `fontSize: 12.sp` (date string) | `AtharTypography` token | Medium |

### 3b — Visual / Spec Gaps (fixable in PR4a without architecture change)

| Gap | Spec | Current | Fix (PR4a) |
|-----|------|---------|-----------|
| **Today state** | `primaryTint` bg (8% forest), primary text color, NO border | `colorScheme.primary.withValues(0.1)` bg + `Border.all(colorScheme.primary)` | Remove border; use `colorScheme.primaryContainer.withValues(alpha: 0.08)` — see Open Q3 |
| **Today text color** | `AppColors.primary` (700) | Falls through to `colorScheme.onSurface` (not primary) | Conditionally use `colorScheme.primary` for today+non-selected |
| **Cell numeral position** | Primary: top-center (4pt from top). Secondary: bottom-center (3pt from bottom) | Both centered via `Column(mainAxisAlignment: center)` | Use `Column(mainAxisAlignment: spaceBetween)` + `Padding` top/bottom |
| **Cell dimensions** | 54/64/72pt height (compact/default/large breakpoints) | `childAspectRatio: 0.85` — varies by screen | `LayoutBuilder` computed per RULE 1 — see §4 |
| **Cell radius** | 11pt | `AtharRadii.card` — verify value | Check token value = 11pt; if not, pass explicit `Radius.circular(11.r)` |
| **Disabled cells (other month)** | `AppColors.text3` ink, transparent bg | Not rendered (only current month cells built) | Pre-existing: `GridView` starts at `firstWeekday` — correct behavior for now |
| **Month header: eyebrow** | `AppText.captionM`, `text3` ("Calendar") | Not present | Optional in PR4a: add `l10n.calendar` eyebrow in `TextStyle(color: colorScheme.onSurfaceVariant)` |
| **Toggle icon** | Not specified as `swap_vert_circle_outlined` | `Icons.swap_vert_circle_outlined, alpha: 0.5` | Acceptable; no spec conflict |
| **Container bottom curve** | Not explicitly specified | `BorderRadius.vertical(bottom: Radius.circular(30.r))` | See Open Q7 |
| **Cell margin** | 2pt | `EdgeInsets.all(2.w)` | ✅ Matches spec |

### 3c — RTL Gaps

| Gap | Location | Fix (PR4a) |
|-----|----------|-----------|
| Month nav arrows don't flip in RTL | `dual_calendar_widget.dart:148,193` (`Icons.arrow_back_ios` / `Icons.arrow_forward_ios`) | Use `Directionality`-aware icons: `Icons.arrow_back_ios` / `Icons.arrow_forward_ios` with `Transform.flip(flipX: isRTL)` OR `context.directionality == rtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios` |
| Day-events header date always in Arabic format | `calendar_page.dart:92` `DateFormat('EEEE, d MMMM', 'ar')` | `DateFormat('EEEE, d MMMM', Localizations.localeOf(context).languageCode)` |
| Header Gregorian date always `'ar'` locale | `dual_calendar_widget.dart:111` `DateFormat('MMMM yyyy', 'ar')` | `DateFormat('MMMM yyyy', Localizations.localeOf(context).languageCode)` |
| `HijriCalendar.setLocal('ar')` hardcoded | `hijri_service.dart:8` | ⚠️ Global state — see Open Q1. Deferred; no change in PR4a. |
| Primary/secondary numeral auto-flip for RTL | Spec: in RTL, Hijri is primary automatically | Current: manual `_isGregorianPrimary` toggle only | PR4a: read `Directionality.of(context)` and auto-set initial `_isGregorianPrimary` based on locale. NOTE: this must still allow user override. |

### 3d — Dark Mode Gaps

| Gap | Risk | Fix |
|-----|------|-----|
| `colorScheme.primary.withValues(alpha: 0.1)` for today bg | May be too faint in dark mode (dark primary color on dark surface) | Replace with `colorScheme.primaryContainer.withValues(alpha: 0.08)` — more visible in dark |
| `colorScheme.primary.withValues(alpha: 0.7)` for selected secondary | Likely fine | Verify in dark mode; `onPrimary` at 70% opacity is acceptable |
| Container `BoxShadow` `alpha: 0.05` | Near-invisible in dark mode | Replace with design system shadow that adapts, or use `colorScheme.shadow.withValues(alpha: 0.15)` |
| AppBar `backgroundColor: colorScheme.surface` | ✅ Correct | No change |
| `colorScheme.onSurface` / `colorScheme.outline` for text | ✅ Correct | No change |

---

## 4 — RULE 1 Application: Window-Based Layout

**RULE 1:** All layout decisions use `LayoutBuilder` (`constraints.maxWidth`) or `ShellBreakpoint.fromWidth()`. Never `ResponsiveHelper.isTablet()` / `context.isTablet` for layout branching.

### Violation in calendar_page.dart

```dart
// CURRENT — calendar_page.dart:53–56 — RULE 1 VIOLATION
ConstrainedBox(
  constraints: BoxConstraints(
    maxWidth: context.isTablet        // ← shortestSide-based, NOT window-based
        ? ResponsiveHelper.maxContentWidth
        : double.infinity,
  ),
```

**PR4a fix:**
```dart
// CORRECTED — RULE 1 compliant
LayoutBuilder(
  builder: (context, constraints) {
    final maxWidth = constraints.maxWidth > 840
        ? 900.0      // ResponsiveHelper.maxContentWidth equivalent
        : double.infinity;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ... 
    );
  },
)
```

### Cell Aspect Ratio (RULE 1 + spec compliance)

**CURRENT:** `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.85)`

**PROBLEM:** `childAspectRatio: 0.85` produces different pixel heights on different screen widths. On a 375pt phone, each cell is `(375 - 2*16) / 7 ≈ 49pt` wide → height = `49 / 0.85 ≈ 58pt`. On a 600pt window (compact rail), cell width ≈ `(600-72 - 2*16) / 7 ≈ 71pt` → height = `71 / 0.85 ≈ 84pt`. Neither matches the spec targets of 54/64/72pt.

**PR4a fix** (RULE 1 compliant):
```dart
// Inside LayoutBuilder in the GridView section
final cellWidth = (constraints.maxWidth - 32) / 7; // 32 = container padding*2
final bp = ShellBreakpoint.fromWidth(constraints.maxWidth);
final targetCellHeight = bp.isPhone ? 64.0 : 72.0;  // default/large per spec
final ratio = cellWidth / targetCellHeight;

GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 7,
    childAspectRatio: ratio,
  ),
  ...
)
```

*Note: spec defines compact=54pt, default=64pt, large=72pt. PR4a uses default (64pt) for phone and large (72pt) for tablet — pending Open Q8 clarification.*

---

## 5 — iPad / AdaptiveShell Fit Analysis

| Breakpoint | Width available to calendar | Current behavior | PR4a change |
|------------|----------------------------|-----------------|-------------|
| Phone `<600dp` | Full width | ConstrainedBox(infinity) | Replace with LayoutBuilder fix |
| Compact rail `600–839dp` | Full width - 72pt rail | ConstrainedBox(900dp cap) | LayoutBuilder: `constraints.maxWidth > 840` → false at 600–839 → no cap. Consider cap at 840+ only. |
| Expanded rail `840–1199dp` | Full width - 200pt rail | ConstrainedBox(900dp cap) | LayoutBuilder: `constraints.maxWidth > 840` → cap at 900 |
| Desktop `≥1200dp` | Full width - 200pt rail | ConstrainedBox(900dp cap) | Same |

**No multi-column iPad layout in PR4a.** The calendar is a single-column layout at all breakpoints. The existing `ConstrainedBox(maxWidth: 900)` is the correct iPad treatment for PR4a — just needs to be LayoutBuilder-based (RULE 1).

**No shell changes required.** `DualCalendarWidget` uses `shrinkWrap: true` + `NeverScrollableScrollPhysics` — collapses correctly at any content width.

---

## 6 — PR4a Allowed Changes Summary

| Change | File | Priority |
|--------|------|----------|
| Fix RULE 1 violation — replace `context.isTablet` with `LayoutBuilder` | `calendar_page.dart:53–56` | P0 |
| Fix cell aspect ratio — `LayoutBuilder`-computed per RULE 1 | `dual_calendar_widget.dart:226–233` | P0 |
| Replace all hardcoded `TextStyle(fontSize:...)` with AtharTypography tokens | `dual_calendar_widget.dart:166,175,213,278,288` + `calendar_page.dart:83,89` | P1 |
| Fix today state — remove border, use `primaryContainer` bg, primary text | `dual_calendar_widget.dart:260–268` | P1 |
| Fix cell numeral positioning — `spaceBetween` + padding | `dual_calendar_widget.dart:270–295` | P1 |
| Replace hardcoded `EdgeInsets.all(16.w)` with spacing token | `dual_calendar_widget.dart:130` | P2 |
| Replace `SizedBox(height: 10.h)` with `AtharGap.sm` | `dual_calendar_widget.dart:222` | P2 |
| Fix RTL arrow icons | `dual_calendar_widget.dart:148,193` | P2 |
| Fix date format to locale-aware | `calendar_page.dart:92`, `dual_calendar_widget.dart:111` | P2 |
| Auto-set `_isGregorianPrimary` from `Directionality` on init | `dual_calendar_widget.dart:initState` | P2 |
| Shadow token replacement | `dual_calendar_widget.dart:137–140` | P3 |
| Container bottom radius — evaluate/resolve (Open Q7) | `dual_calendar_widget.dart:133` | P3 |
| AppBar title token verification | `calendar_page.dart:44–48` | P3 |
| Optional Today button (simple `TextButton` only) | `dual_calendar_widget.dart` header | P3 |
| Dark mode today bg adjustment | `dual_calendar_widget.dart:263` | P3 |

---

## 7 — PR4a Forbidden Changes

| Forbidden item | Reason |
|----------------|--------|
| `DualDate` value object | PR4b architecture |
| `CalendarCell` widget extraction (taking `DualDate`) | PR4b architecture |
| `DualMonthSwitcher` (two pill rows) | PR4b architecture |
| `isFirstOfHijriMonth` hairline | Requires `DualDate.isFirstOfHijriMonth` |
| Real activity dots from cubit data | `CalendarState` has no `activityByDate` map |
| `CalendarCubit` new methods or state fields | PR4b architecture |
| Domain entity changes | No new `DualDate`, no new use cases |
| Month-level data fetch | Requires cubit architecture change |
| Simultaneous Hijri+Gregorian in SEPARATE corner positions (absolute) | PR4b `CalendarCell` spec |
| Eastern numerals toggle | `UserSettings` field doesn't exist — PR5 |
| iPad month+side-timeline layout | PR4b |
| Anything that makes PR4b harder to layer on top | |

---

## 8 — Risk Register

| Risk | Severity | Mitigation |
|------|----------|------------|
| **Cell height change breaks visual expectations** — changing `childAspectRatio` resizes all cells; significant visual change | HIGH | Introduce LayoutBuilder-computed ratio; take screenshot before/after; verify grid fits in viewport without scroll |
| **Today state change** — removing border + new bg color changes recognizable visual cue | MEDIUM | Keep behavior identical; only change color values to match spec |
| **RTL date format** — `DateFormat` locale change may produce unexpected string for some locales | LOW | Test `ar` and `en` explicitly; verify `intl` locale registration |
| **Auto `_isGregorianPrimary` from Directionality** — changes default calendar mode for RTL users | MEDIUM | Load user preference first; only use Directionality as default if no stored preference. Ensure `_loadCalendarPreference()` overrides |
| **`HijriCalendar.setLocal('ar')`** — global state in `HijriService` constructor | LOW | Do not change in PR4a; document in audit as Open Q1 |
| **No golden tests** — no existing goldens to catch regressions | MEDIUM | Create PR4a screenshot checklist; run `flutter test` to ensure no analyzer regressions |
| **`SettingsRepository` direct write in `_toggleCalendarMode()`** — bypasses SettingsCubit | LOW | Flag as technical debt; do NOT fix in PR4a (out of scope) |

---

## 9 — Likely-Affected Files

| File | Change type | Required in PR4a |
|------|-------------|-----------------|
| `lib/features/calendar/presentation/pages/calendar_page.dart` | RULE 1 fix, RTL date format, typography tokens | YES |
| `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart` | Typography, spacing, today state, cell layout, RTL arrows, LayoutBuilder aspect ratio | YES |
| `lib/features/calendar/presentation/cubit/calendar_cubit.dart` | NONE | No change |
| `lib/features/calendar/presentation/cubit/calendar_state.dart` | NONE | No change |
| `lib/features/calendar/domain/entities/calendar_item.dart` | NONE | No change |
| `lib/core/services/hijri_service.dart` | NONE (locale deferred to Open Q1) | No change |
| `lib/l10n/app_ar.arb` + `app_en.arb` | Optional: "اليوم" / "Today" string if Today button added | Maybe |
| `lib/l10n/generated/app_localizations*.dart` | Generated by `flutter gen-l10n` | Only if ARBs change |

**No new files required for PR4a.** All changes are in-place.

---

## 10 — Suggested Implementation Sequence

1. **P0 — RULE 1 + LayoutBuilder aspect ratio** (`calendar_page.dart:53–56`, `dual_calendar_widget.dart:226–233`)  
   Establishes correct sizing foundation before any visual work. Do first so all subsequent changes are evaluated at correct sizes.

2. **P1 — Today state + cell numeral positioning** (`dual_calendar_widget.dart:260–295`)  
   Most visible visual fix. Validates against spec states immediately.

3. **P1 — Typography tokens** (all `TextStyle(fontSize:...)` replacements in both files)  
   Pure token substitution, no behavioral change.

4. **P2 — Spacing tokens** (`EdgeInsets.all(16.w)` → token, `SizedBox(height: 10.h)` → `AtharGap.sm`)

5. **P2 — RTL fixes** (arrow icons, locale-aware date formats, auto-Directionality init)

6. **P3 — Shadow token, container radius resolution (Open Q7), AppBar verification**

7. **P3 — Optional Today button** (only if `_focusedMonth != currentMonth` detection is trivial)

8. **P3 — Dark mode verification** (manual: toggle to dark, check all states)

9. **Analyzer + test run** (`flutter analyze --no-fatal-infos` → 0 issues; `flutter test` → 45/45)

---

## 11 — Validation + Screenshot Checklist

**Before starting implementation:** capture screenshots of current state (phone + tablet simulator, light + dark, AR + EN).

**After PR4a implementation:**

| Scenario | What to check |
|----------|--------------|
| Phone — light — AR | Grid fills viewport; today cell correct bg (no border); selected cell forest solid; secondary numeral visible; month nav arrows flip in RTL |
| Phone — light — EN | Gregorian primary; English date format in day-events header; arrows correct direction |
| Phone — dark — AR | All cells visible; today bg visible on dark surface; shadow visible |
| Phone — dark — EN | Same as dark AR but EN format |
| Compact rail (≥600dp) | Grid reflows to narrower content area; cells correct size via LayoutBuilder |
| Expanded rail (≥840dp) | Grid capped at 900dp; cells correct size |
| Month navigation | Back/forward changes month; grid rebuilds correctly |
| Mode toggle (tap title) | Swaps primary/secondary numeral; writes setting |
| Date selection | Tapping day fires `onDateSelected`; day-events list refreshes |
| Empty state | No items → empty state widget visible |
| Error state | `CalendarError` shows error + retry button |
| `flutter analyze --no-fatal-infos` | 0 issues |
| `flutter test` | 45/45 (no regressions in non-calendar tests) |

---

## 12 — Open Questions (require designer / product owner answers before or during implementation)

| ID | Question | Blocks |
|----|----------|--------|
| **Q1** | `HijriService` sets `HijriCalendar.setLocal('ar')` globally in its constructor — always Arabic. When English locale is active, should Hijri month names still render in Arabic (e.g. "رمضان") or in transliterated English ("Ramadan")? This is global state; changing it affects all HijriService callers. | RTL fix; deferred if answer is "always Arabic" |
| **Q2** | Cell height breakpoints: spec says 54pt (compact) / 64pt (default) / 72pt (large). What is the mapping? PR4a assumption: phone = 64pt, tablet = 72pt. Confirm or correct. | Cell aspect ratio computation |
| **Q3** | Today state: spec says `AppColors.primaryTint` = "forest @ 8%". In the current token set (`athar_colors.dart`), what is the exact token or formula for this tint? Is it `colorScheme.primaryContainer.withValues(alpha: 0.08)`? Or is there a dedicated surface token? | Today bg fix |
| **Q4** | Mode toggle writes `SettingsRepository` directly (bypasses `SettingsCubit`). This is technically debt — should PR4a route it through `SettingsCubit.updateSettings()`? Or leave it as-is for PR4a? | Optional cleanup |
| **Q5** | Auto-`_isGregorianPrimary` from `Directionality`: RTL spec says Hijri is primary for Arabic users. Should this auto-flip only on first launch (before any stored preference), or should it always override the stored preference? Recommendation: auto-flip on first launch only; stored preference wins thereafter. | RTL init logic |
| **Q6** | Arrow icon RTL: `Icons.arrow_back_ios` (←) should go right (→) in RTL for "next month". Preferred approach: (a) use `Transform.flipX` on the icon, (b) swap icon names based on `Directionality`, or (c) use `Icons.chevron_left`/`chevron_right` which have less visual directionality ambiguity. | RTL arrow fix |
| **Q7** | Container bottom radius `BorderRadius.vertical(bottom: Radius.circular(30.r))` — creates a rounded bottom edge on the calendar widget (card-like appearance). Is this intentional per the design? No token in `AtharRadii` matches 30dp. Options: keep as-is with inline comment, promote to a token, or remove. | Token migration of container |
| **Q8** | Is there a spec for the month-navigation control? CALENDAR_CELL_SPEC.md §2 describes the dual-pill-row `DualMonthSwitcher` (PR4b). For PR4a, are the simple arrow buttons acceptable, or does the designer want a styled pill navigation without the dual-row (which is PR4b)? | Month nav scope |

---

## 13 — Sign-Off Gate

**Do NOT begin any Dart implementation until this audit is reviewed and the following confirmed:**

- [ ] Open Q3 answered (today tint token)
- [ ] Open Q2 answered (cell height breakpoints) — or PR4a assumption confirmed
- [ ] Open Q7 answered (container radius)
- [ ] Open Q8 answered (month nav scope)
- [ ] Q1, Q4, Q5, Q6 answered OR deferred to PR4b explicitly

**May implementation start after sign-off?** YES — once above gates are cleared.
