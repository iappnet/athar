# PR4a Verification — Calendar Visual Refresh

**Date:** 2026-06-01  
**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Status:** ✅ Code complete · Pending device/simulator screenshots  
**Commit:** (see git log)  
**flutter analyze:** 0 issues  
**flutter test:** 45/45 passed (all golden tests pass — no regressions)

---

## Files Modified

| File | Changes |
|------|---------|
| `lib/features/calendar/presentation/pages/calendar_page.dart` | RULE 1 fix, typography tokens, locale-aware date, removed responsive_helper import |
| `lib/features/calendar/presentation/widgets/dual_calendar_widget.dart` | Full P0–P3 implementation — LayoutBuilder, tokens, today state, RTL chevrons, flat bottom |

---

## P0 — RULE 1 Fixes (highest priority)

### `calendar_page.dart:52–57` — Width constraint (was device-based, now window-based)

**Before:**
```dart
ConstrainedBox(
  constraints: BoxConstraints(
    maxWidth: context.isTablet        // ← shortestSide-based, RULE 1 violation
        ? ResponsiveHelper.maxContentWidth
        : double.infinity,
  ),
```

**After:**
```dart
LayoutBuilder(
  builder: (context, constraints) => ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: constraints.maxWidth >= 600 ? 900.0 : double.infinity,
    ),
```

### `dual_calendar_widget.dart` — Cell aspect ratio (was hardcoded, now LayoutBuilder-driven)

**Before:**
```dart
gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 7,
  childAspectRatio: 0.85,  // ← constant, wrong on all non-375dp widths
),
```

**After:**
```dart
// inside LayoutBuilder(builder: (context, constraints) { ... })
final double targetCellHeight = constraints.maxWidth < 360 ? 54.0
    : constraints.maxWidth < 840 ? 64.0
    : 72.0;
final double cellWidth = (constraints.maxWidth - AtharSpacing.lg * 2) / 7;
final double cellAspectRatio = cellWidth / targetCellHeight;

gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 7,
  childAspectRatio: cellAspectRatio,
),
```

---

## P1 — Today State + Numeral Typography

### Today state

| Property | Before | After |
|----------|--------|-------|
| Background | `colorScheme.primary @ 0.1` | `colorScheme.primary @ 0.08` (light) / `0.13` (dark) |
| Border | `Border.all(color: colorScheme.primary)` | **None** |
| Numeral color | `colorScheme.onSurface` | `colorScheme.primary` |
| Numeral weight | `FontWeight.bold` (always) | `AtharTypography.bold` on today/selected; `AtharTypography.regular` otherwise |

### Typography tokens applied

| Location | Before | After |
|----------|--------|-------|
| AppBar title | `fontSize: 20.sp` hardcoded | `AtharTypography.sizeXl.sp` |
| Month header main title | `fontSize: 18.sp` hardcoded | `AtharTypography.sizeLg.sp` |
| Month header sub title | `fontSize: 12.sp` hardcoded | `AtharTypography.sizeXs.sp` |
| Weekday header | `fontSize: 14.sp` hardcoded | `AtharTypography.sizeSm.sp` |
| Primary cell numeral | `fontSize: 16.sp` hardcoded | `AtharTypography.sizeMd.sp` |
| Secondary cell numeral | `fontSize: 10.sp` hardcoded | `AtharTypography.sizeXxs.sp` |
| Day events header | `fontSize: 16.sp` hardcoded | `AtharTypography.sizeMd.sp` |
| Date display | `fontSize: 12.sp` hardcoded | `AtharTypography.sizeXs.sp` |

---

## P2 — Spacing + RTL + Locale Date

### Spacing tokens

| Location | Before | After |
|----------|--------|-------|
| Container padding | `EdgeInsets.all(16.w)` | `const EdgeInsets.all(AtharSpacing.lg)` |
| Weekday→grid gap | `SizedBox(height: 10.h)` | `AtharGap.md` |
| Cell margin | `EdgeInsets.all(2.w)` | `const EdgeInsets.all(AtharSpacing.xxxs)` |
| Header padding | `EdgeInsets.symmetric(horizontal: 16.w)` | `const EdgeInsets.symmetric(horizontal: AtharSpacing.lg)` |
| InkWell padding | `EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h)` | `const EdgeInsets.symmetric(horizontal: AtharSpacing.sm, vertical: AtharSpacing.xxs)` |

### RTL chevrons

**Before:** `Icons.arrow_back_ios` / `Icons.arrow_forward_ios` (always left/right regardless of locale)

**After:** `Icons.chevron_left` / `Icons.chevron_right` in a `Directionality`-respecting `Row`. In an RTL Row, `chevron_left` (semantic: earlier month) renders visually on the right — correct for Arabic calendar conventions. No `Transform.flipX`. No hardcoded left/right direction.

### Locale-aware date format

**Before:** `DateFormat('EEEE, d MMMM', 'ar').format(_selectedDate)` — always Arabic

**After:**
```dart
DateFormat(
  locale == 'ar' ? 'EEEE، d MMMM' : 'EEE, d MMM',
  locale,
).format(_selectedDate)
```

---

## P3 — Container Shape + Shadow

### Flat bottom (Q7 decision)

**Before:** `BorderRadius.vertical(bottom: Radius.circular(30.r))`  
**After:** No `borderRadius` on the container — flat bottom per spec. (`AtharRadii.card` still used on individual day cells.)

### Shadow update

**Before:** `blurRadius: 10, offset: Offset(0, 5), alpha: 0.05`  
**After:** `blurRadius: 8, offset: Offset(0, 3), alpha: 0.06`

---

## Removed Import

`import '../../../../core/utils/responsive_helper.dart'` — removed from `calendar_page.dart`. No remaining usage after RULE 1 fix.

---

## PR4a Forbidden Scope — Confirmed NOT Touched

| Forbidden item | Status |
|----------------|--------|
| DualDate value object | ✅ Not created |
| CalendarCell widget extraction | ✅ Not created |
| DualMonthSwitcher | ✅ Not created |
| isFirstOfHijriMonth hairline | ✅ Not implemented |
| Activity dots from real cubit data | ✅ Not wired |
| CalendarCubit architecture | ✅ Not changed |
| Domain entity changes | ✅ Not changed |
| Eastern numerals | ✅ Not added |
| HijriService.setLocal locale change | ✅ Not changed (Q1 deferred) |
| SettingsCubit routing for isHijriMode | ✅ Not changed (Q4 deferred to PR4b) |

---

## Tech Debt Logged (PR4b)

| Item | Comment in code |
|------|----------------|
| SettingsRepository direct write in `_toggleCalendarMode` | `// PR4b tech debt: route through SettingsCubit` |
| Secondary numeral placeholder | `// PR4b: replace with DualDate.activity` |
| Locale auto-derive for `_isGregorianPrimary` | Requires `UserSettings.hijriPrimary` nullable field (PR4b schema change) |

---

## Screenshot Gate — REQUIRED BEFORE SIGN-OFF

Screenshots must be captured on Simulator or device. Baseline (before this PR) not available — capture current state.

### Critical Gate (iPhone SE overflow check)

| Scenario | Target | Status |
|----------|--------|--------|
| iPhone SE 375×667 — 6-row month — light mode | Grid fills without vertical overflow; "Day events" header visible without scrolling | ⬜ Pending |
| iPhone SE 375×667 — 6-row month — dark mode | Same | ⬜ Pending |

### Full Screenshot Matrix

| Scenario | Phone AR Light | Phone AR Dark | Phone EN Light | Tablet AR Light |
|----------|---------------|---------------|----------------|----------------|
| Today highlighted, no selection | ⬜ | ⬜ | ⬜ | ⬜ |
| Selected date (non-today) | ⬜ | ⬜ | ⬜ | ⬜ |
| Today + selected (same cell) | ⬜ | ⬜ | ⬜ | ⬜ |
| Month navigation (prev/next) | ⬜ | — | ⬜ | — |
| Hijri primary mode (toggle tap) | ⬜ | — | ⬜ | — |
| Day events list populated | ⬜ | ⬜ | ⬜ | — |
| Day events empty state | ⬜ | ⬜ | ⬜ | — |
| iPhone SE 6-row overflow check | ⬜ | ⬜ | — | — |

---

## Open Items Deferred to PR4b

| # | Item |
|---|------|
| Q1 | Hijri month name localization (EN: "Dhul Hijjah" not "ذو الحجة") |
| Q4 | SettingsCubit routing for `_toggleCalendarMode` |
| Q5 | Auto-derive `_isGregorianPrimary` from locale when no stored preference (`UserSettings.hijriPrimary` nullable field) |

---

## Acceptance Criteria

- [x] `flutter analyze`: 0 issues
- [x] `flutter test`: 45/45 (all existing golden tests pass)
- [x] RULE 1 violation eliminated from `calendar_page.dart:52`
- [x] Cell aspect ratio is LayoutBuilder-computed (not hardcoded)
- [x] All 8 hardcoded font sizes replaced with `AtharTypography` tokens
- [x] All 5 hardcoded spacing values replaced with `AtharSpacing`/`AtharGap` tokens
- [x] Today state: no border, primary @ 8%/13%, numeral = primary
- [x] Flat bottom container
- [x] RTL-safe chevrons
- [x] Locale-aware date in day events header
- [x] No PR4b-forbidden items touched
- [ ] iPhone SE overflow check (simulator screenshot required)
- [ ] Today state visual QA in dark mode (screenshot required)
