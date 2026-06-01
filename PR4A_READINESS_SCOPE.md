# PR4a Readiness and Scope

**Date:** 2026-06-01  
**PR:** PR4a — Calendar Visual Refresh  
**Status:** READY TO START — with the scope restrictions documented below  
**No code modified in this document.**

---

## Files Inspected

| File | Lines | Notes |
|------|-------|-------|
| `CALENDAR_FOCUS_REDESIGN.md` | ~195 | Designer spec — describes PR4b end-state ONLY |
| `CALENDAR_CELL_SPEC.md` | ~128 | Cell + header spec — describes PR4b end-state ONLY |
| `lib/features/calendar/presentation/pages/calendar_page.dart` | 274 | Current page |
| `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart` | 306 | Current widget |
| `lib/features/calendar/presentation/cubit/calendar_cubit.dart` | 71 | Current cubit |
| `lib/features/calendar/presentation/cubit/calendar_state.dart` | 34 | Current state |
| `lib/features/calendar/domain/entities/calendar_item.dart` | 31 | Task + Appointment types |

---

## Critical Pre-Audit Finding

**CALENDAR_FOCUS_REDESIGN.md and CALENDAR_CELL_SPEC.md describe the PR4b end-state exclusively.** Neither document contains a "visual refresh only" section. Both specs assume `DualDate`, `CalendarCell`, and `DualMonthSwitcher` exist.

This means PR4a scope must be extracted from the specs by identifying which visual properties are achievable WITHOUT the DualDate/CalendarCell architecture, and which require it.

The separation below is derived from code inspection + spec analysis.

---

## Current Calendar State (Baseline)

### What exists today

| Component | Current implementation |
|-----------|----------------------|
| Calendar page | `calendar_page.dart` — own `Scaffold` with `AppBar`, `ConstrainedBox(maxWidth: 900 on tablet)` |
| Calendar widget | `dual_calendar_widget.dart` — monolithic `StatefulWidget` (306 lines) |
| Month navigation | Arrow `IconButton` left/right — simple `_changeMonth(±1)` |
| Header | `mainTitle` (primary date) + `subTitle` (secondary date) — toggled on tap; hardcoded `TextStyle(fontSize: 18.sp)` |
| Mode toggle | Tap on header → `_toggleCalendarMode()` → writes to `SettingsRepository` |
| Day cell | Inline `Container` in `GridView.builder` — hardcoded `fontSize: 16.sp` (primary), `fontSize: 10.sp` (secondary) |
| Today state | `colorScheme.primary.withValues(alpha: 0.1)` background + `Border.all(color: colorScheme.primary)` |
| Selected state | `colorScheme.primary` solid background, `colorScheme.onPrimary` text |
| Activity dots | NOT IMPLEMENTED — cells show numbers only |
| Dual display | Both numerals already shown (primary + secondary toggled per `_isGregorianPrimary`) — NOT a toggle between one/other |
| `isFirstOfHijriMonth` | NOT IMPLEMENTED — no hairline |
| RTL | Uses `DateFormat('MMMM yyyy', 'ar')` — partial; layout not verified |
| Dark mode | Uses `colorScheme.*` — partially token-driven but has hardcoded fallbacks |
| `hijri` package | Used via `HijriService` — `package:hijri` confirmed present |
| `CalendarCubit` | `selectDate(date)` only — emits tasks+appointments for selected day |
| `CalendarState` | `{selectedDate, items: List<CalendarItem>}` — no `activityByDate` map |

### Token gaps in current code

| Issue | Location | Gap |
|-------|----------|-----|
| Hardcoded `fontSize: 18.sp` in header | `dual_calendar_widget.dart:166` | Should use `AtharTypography` token |
| Hardcoded `fontSize: 12.sp` in subtitle | `dual_calendar_widget.dart:175` | Should use `AtharTypography` token |
| Hardcoded `fontSize: 14.sp` in weekday row | `dual_calendar_widget.dart:213` | Should use `AtharTypography` token |
| Hardcoded `fontSize: 16.sp` in primary cell | `dual_calendar_widget.dart:278` | Should use `AtharTypography` token |
| Hardcoded `fontSize: 10.sp` in secondary cell | `dual_calendar_widget.dart:288` | Should use `AtharTypography` token |
| Hardcoded `EdgeInsets.all(16.w)` | `dual_calendar_widget.dart:130` | Should use `AtharSpacing` token |
| Hardcoded `BorderRadius.vertical(bottom: Radius.circular(30.r))` | `dual_calendar_widget.dart:133` | Token or remove |
| Hardcoded `blurRadius: 10` | `dual_calendar_widget.dart:138` | Should use shadow token |
| Hardcoded `Offset(0, 5)` | `dual_calendar_widget.dart:139` | Should use shadow token |
| Hardcoded `SizedBox(height: 10.h)` between weekdays and grid | `dual_calendar_widget.dart:222` | `AtharGap.md` |
| `DateFormat('EEEE, d MMMM', 'ar')` in `calendar_page.dart:92` | `calendar_page.dart:92` | Always Arabic — needs locale-aware format |
| Hardcoded `fontSize: 16.sp` in day-events header | `calendar_page.dart:85` | Should use `AtharTypography` token |
| Hardcoded `fontSize: 12.sp` in date display | `calendar_page.dart:90` | Should use `AtharTypography` token |
| Hardcoded `fontSize: 20.sp` in AppBar title | `calendar_page.dart:44` | Should use `AtharTypography` token |

---

## PR4a Allowed Scope

These changes apply design tokens and visual polish to the EXISTING architecture. No new architectural classes created.

### ✅ Colors (allowed)

- Replace any `Color(0xFF...)` with tokens from `AtharColors`
- Verify `colorScheme.primary`, `colorScheme.surface`, `colorScheme.onSurface` are correctly applied per spec states (today, selected, disabled)
- Spec `today` state: `AppColors.primaryTint` (forest @ 8%) background → map to `colorScheme.primaryContainer.withValues(alpha: 0.08)` or equivalent token
- Spec `selected` state: `AppColors.primary` solid, `Colors.white` text → already `colorScheme.primary` + `colorScheme.onPrimary`
- Spec `disabled` (other-month cells): `AppColors.text3` → `colorScheme.onSurfaceVariant` or `colorScheme.outline`

### ✅ Typography (allowed)

- Replace all hardcoded `TextStyle(fontSize: ...)` with `AtharTypography` tokens
- Spec primary cell numeral: `AppText.bodyM` with `fontWeight: 700` when today/selected
- Spec secondary cell numeral: `AppText.captionS` (10pt), Cairo, `AppColors.primary`
- Spec header title: `AppText.titleXL` — both numerals use `AtharTypography` sizes
- Spec eyebrow: `AppText.captionM`, `text3` color

### ✅ Hierarchy / spacing (allowed)

- Replace hardcoded `EdgeInsets.all(16.w)` → `AtharSpacing` tokens
- Replace `SizedBox(height: 10.h)` → `AtharGap.md`
- Replace `AtharGap.xl` calls that are correct — keep
- Normalize cell padding per CALENDAR_CELL_SPEC.md §1 (height 54/64/72pt per breakpoint, 2pt margin, 11pt radius)
- Container bottom radius: `BorderRadius.vertical(bottom: Radius.circular(30.r))` → evaluate against spec; use token if applicable

### ✅ Calendar chrome / month switcher styling (allowed)

- Style the month navigation arrows per design tokens (icon size, color)
- Style the header container (surface color, shadow spec)
- Style the tap-to-toggle mode indicator (the `swap_vert_circle_outlined` icon)
- Header title layout: primary title large + secondary title smaller — improve positioning per CALENDAR_CELL_SPEC.md §2

### ✅ Selected state / today state (allowed)

- Apply CALENDAR_CELL_SPEC.md §1 states: today (primaryTint bg, primary text), selected (primary solid, white text), disabled (text3)
- Fix `isToday && !isSelected` to use correct border color token

### ✅ Activity indicators (visual only — partial)

- Can add activity dot placeholders as visual styling only (hardcoded dots for visual reference)
- **CANNOT** wire to real cubit data — `CalendarState` does not have `activityByDate` (PR4b adds this)
- **CANNOT** connect dots to real task/habit/prayer data per cell (requires `DualDate.activityFor()` architecture)

### ✅ Dark mode behavior (allowed)

- Verify all colors work in `AtharDarkTheme` context
- Replace any hardcoded dark-mode-unfriendly values

### ✅ RTL behavior (allowed)

- Verify `dual_calendar_widget.dart` layout is RTL-safe
- Replace any `EdgeInsets.only(left/right)` with `EdgeInsetsDirectional`
- Verify weekday header order in RTL (Sunday first vs Saturday first per locale)
- Fix `DateFormat('EEEE, d MMMM', 'ar')` in `calendar_page.dart:92` to be locale-aware

### ✅ iPhone + iPad layout — PR4a partial (allowed)

- For iPhone: existing column layout + content-width constraint stays
- For iPad: keep existing `ConstrainedBox(maxWidth: 900)` OR improve to use `ResponsiveLayout` with a slightly wider calendar — NO multi-column layout
- `AdaptiveShell` fit: calendar already fits correctly in existing shell

---

## PR4b Deferred Scope

These items CANNOT be touched in PR4a. They require architectural components that don't exist.

### ❌ DualDate value object (forbidden in PR4a)

```dart
// FORBIDDEN in PR4a
class DualDate {
  final DateTime gregorian;
  final HijriCalendar hijri;
  final bool isFirstOfHijriMonth;
}
```

- Requires `lib/features/calendar/domain/entities/dual_date.dart` — new file
- Requires pre-computing DualDate list in `CalendarCubit.state`
- Requires caching in `CalendarCubit` to avoid per-cell re-conversion

### ❌ CalendarCell widget extraction (forbidden in PR4a)

- `CalendarCell` takes `DualDate` — cannot create it without `DualDate`
- Spec: absolute-positioned Gregorian (top-right) + Hijri (bottom-left) within a 54/64/72pt cell
- Current inline `Container` in `GridView.builder` is acceptable for PR4a

### ❌ DualMonthSwitcher (forbidden in PR4a)

- Two parallel pill rows (Gregorian + Hijri months) — new widget
- Each row is a horizontal scrollable list of 12 pills
- Synced scrolling between rows
- Current arrow buttons are acceptable for PR4a

### ❌ isFirstOfHijriMonth hairline (forbidden in PR4a)

- Requires `DualDate.isFirstOfHijriMonth` — cannot implement without `DualDate`
- Spec: 2pt hairline along top edge of first-of-month cell, `primaryLight` color
- Requires: Hijri month name (e.g. "رجب") replaces Hijri numeral for that cell

### ❌ Activity dots from real cubit data (forbidden in PR4a)

- `CalendarCubit.state` is `{selectedDate, items}` — no `activityByDate: Map<DateTime, Activity>`
- Wiring real dots requires: `CalendarCubit.activityByDate` map + month-level data fetch + `DualDate` integration
- All PR4b

### ❌ Day sheet dual-format header (forbidden in PR4a)

- Spec: `"Wed, 15 Jan · ١٥ رجب"` or `"الأربعاء، ١٥ رجب · 15 Jan"` depending on locale
- Requires `DualDate` to have Hijri day number per selected date
- Current: `DateFormat('EEEE, d MMMM', 'ar')` Gregorian only — acceptable for PR4a

### ❌ Eastern numerals toggle (forbidden in PR4a)

- `Accessibility.easternNumerals` — `UserSettings` does not yet have this field
- Planned for PR5 (Accessibility Settings)
- Cannot implement in PR4a

### ❌ Today floating pill button (forbidden in PR4a)

- "Today / اليوم" pill — visible only when not on current month
- Acceptable to add in PR4a as a simple `TextButton` (no pill styling required)
- If added: must use `AtharTypography` token, `colorScheme.primary`, existing scroll-to-today logic

### ❌ CalendarCubit architecture changes (forbidden in PR4a)

- No new cubit methods in PR4a
- No new state fields in PR4a
- `selectDate()` unchanged

### ❌ Domain architecture changes (forbidden in PR4a)

- No new entities: no `DualDate`, no activity-map types
- No new use cases

---

## Calendar AdaptiveShell Fit Verdict

| Layout | Current fit | PR4a action needed |
|--------|------------|-------------------|
| Phone (< 600dp) | ✅ Calendar fills content area, `ConstrainedBox(maxWidth: infinity)` | Token migration only |
| Compact rail (600–839dp) | ✅ Calendar fills content area minus rail (72pt) | `ConstrainedBox(maxWidth: 900)` already present — fits |
| Expanded rail (840dp+) | ✅ Calendar fills content area minus rail (200pt) | Same |
| ≥1200dp desktop | ✅ Fills content area; `maxWidth: 900` cap already limits width | Acceptable |

**Calendar fits in AdaptiveShell across all breakpoints without any shell change.**

The `DualCalendarWidget` uses `shrinkWrap: true` on its `GridView` — this collapses correctly regardless of available width.

**No shell change required for PR4a.**

---

## Risks

### Highest Visual Risk

**Day cell height and aspect ratio.** The spec says 54/64/72pt height per breakpoint. Current: `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.85)`. Changing `childAspectRatio` to produce 54pt cells at phone width requires math: `cellWidth = availableWidth/7`, `aspectRatio = cellWidth/54`. If done without `LayoutBuilder`, it will be wrong on different screen sizes.

**Fix:** Use `GridView.builder` with a `LayoutBuilder`-computed `childAspectRatio` based on `constraints.maxWidth / 7 / targetHeight`. Safe for PR4a.

### Highest Architecture Risk

**Activity dots placeholder.** Adding a visual placeholder row of dots (hardcoded colors, no real data) looks correct on the surface. The risk is that PR4b's real data wiring may conflict with the placeholder if the cell widget shape is changed. Mitigation: add a comment `// PR4b: replace with DualDate.activity` so the wiring point is clearly marked.

---

## PR4a Verdict

| Check | Status |
|-------|--------|
| AdaptiveShell ready | ✅ |
| No shell changes required | ✅ |
| Clear PR4a / PR4b separation | ✅ (see above) |
| Design spec available for PR4a visual targets | ⚠️ Partial — both specs describe PR4b end-state; extract visual-only properties per §"PR4a Allowed Scope" above |
| `CalendarCubit` changes needed in PR4a | ❌ None |
| `DualDate` / `CalendarCell` / `DualMonthSwitcher` in PR4a | ❌ Forbidden |
| iPhone layout ready | ✅ — token migration of existing layout |
| iPad layout ready | ✅ Partial — keep existing `ConstrainedBox(maxWidth: 900)` OR improve with `ResponsiveLayout` for slightly different tablet chrome; no multi-column layout |

**PR4a is ready to start.** Scope = token migration + visual polish of existing architecture. No forbidden architecture changes.
