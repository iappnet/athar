# Calendar Cell + Header — Spec

> Visual reference: `ui_kits/athar_app/CalendarScreen.jsx`. This file is the
> readable spec for Flutter. Both numerals always render. `isHijriMode`
> chooses which is primary.

---

## 1 · `CalendarDayCell`

### Dimensions
- Width: `(grid_width - 6 * gap) / 7`. Gap: 2pt.
- Height: 54pt (compact) / 64pt (default) / 72pt (large) per breakpoint.
- Radius: 11pt.
- Padding: 0 (children absolute-positioned).

### Inputs
```dart
class DualDate {
  final DateTime gregorian;
  final HijriCalendar hijri;
  final bool isFirstOfHijriMonth;
}
```
+ `bool isToday`, `bool isSelected`, `Activity? activity`,
`bool primaryHijri` (from `isHijriMode`).

### Layout (default, primaryHijri = false)

| Slot | Content | Style |
|---|---|---|
| top-center, 4pt from top | Gregorian numeral | `AppText.bodyM` if `isToday` or `isSelected` → `bodyM.copyWith(fontWeight: 700)` |
| middle, 24pt from top | Activity dots row | 4×4 dots, 2pt gap |
| bottom-center, 3pt from bottom | Hijri numeral | `AppText.captionS` (10pt), Calibri (sole canonical font, Arabic + English), `AppColors.primary` |

When `primaryHijri = true`: swap. Hijri large on top, Gregorian small at bottom.

### States

| State | Background | Primary ink | Secondary ink |
|---|---|---|---|
| default | transparent | `AppColors.text` | `AppColors.primary` |
| today | `AppColors.primaryTint` (forest @ 8%) | `AppColors.primary` (700) | `AppColors.primary` |
| selected | `AppColors.primary` solid | `Colors.white` (700) | `Colors.white78` |
| disabled (other month) | transparent | `AppColors.text3` | `AppColors.text3` |

### Hijri-month boundary
When `isFirstOfHijriMonth` is true and not selected:
- 2pt rounded hairline along top edge, 4pt inset left+right, color
  `AppColors.primaryLight`.
- Hijri numeral position **replaced** by the Hijri month abbreviation for that
  single cell — use the form from `HIJRI_MONTH_ABBREVIATIONS.md` (Arabic compact
  when Arabic-primary, e.g. رجب / ربيع ١; Latin 3-char when Latin-primary, e.g.
  `Raj` / `Rb1`). Do **not** arbitrarily truncate.

### Activity dots
- Row of up to 5 dots, 4×4pt, 2pt gap, centered. **This cell spec is the dot-overflow authority:** if more sources are present than fit cleanly, show the first 4 in the fixed order below + a `+` overflow glyph.
- **Five sources, fixed order:** task, habit, appointment, medicine, prayer. Dot colors per `DUAL_DATE_SPEC.md` activity legend (task = `taskBlue`, habit = `success`, appointment = amber, medicine = teal, prayer = `primary`/forest).
- **Prayer dot is gated:** render only when `isPrayerEnabled && showPrayerDotsOnCalendar` (per `DUAL_DATE_SPEC.md`). Prayer is per-prayer/timed in the day view, but contributes a single clustered dot here on the month grid.
- Hidden on `isSelected` (white text only).

---

## 2 · `DualCalendarHeader`

Shows above the grid, contains title + dual month switcher.

### Title row
- Eyebrow: "Calendar" (`AppText.captionM`, `text3`).
- Primary title: `MMMM yyyy` (Gregorian) — `AppText.titleXL`, `text`.
- Secondary line: Hijri span — e.g. "رجب – شعبان ١٤٤٦" — `AppText.bodyS`,
  `AppColors.primary`, Calibri (sole canonical font), `direction: rtl`.

When `primaryHijri = true`: swap. Hijri title on top (Calibri, `titleXL`),
Gregorian span below.

### Month switcher (two parallel rows, 4pt gap)
- Row 1 — Gregorian: 12 pills, current = `primary` bg + white ink, others =
  transparent + `text2`. Pill: 6pt × 12pt, 99pt radius, `captionM 600`.
- Row 2 — Hijri (RTL): 12 pills, Calibri (sole canonical font), current = `primary` border + ink,
  others = `borderLt` border + `text3`.

Tapping either pill anchors the grid to that month boundary.

### Today button
- Floating top-end pill, "Today" / "اليوم" — only visible when not on
  current month.

---

## 3 · Day sheet header

When a day is selected, the day sheet below grid uses:

> `Wed, 15 Jan · ١٥ رجب`

Format: `EEE, d MMM` Gregorian + `· ` + Hijri day + Hijri month name (Arabic).
Style: `AppText.bodyM 600`. The `· ` and Hijri portion use `AppColors.primary`.

When `primaryHijri = true` and locale is Arabic, swap to Hijri-first:

> `الأربعاء، ١٥ رجب · 15 Jan`

---

## 4 · Eastern numerals

When `Accessibility.easternNumerals = true` AND locale is Arabic:
- Hijri numerals render as Eastern digits (default behavior).
- Gregorian numerals also render as Eastern digits.
- Day-sheet header uses Eastern digits on both sides.

When OFF: both render as Western digits regardless of locale.

---

## 5 · RTL

- Cell layout is symmetric — no changes needed in cell.
- Header: switcher row direction flips automatically.
- Day-sheet header reorders semantically (Hijri-first when primary).
- "Today" button moves to top-start.

---

## 6 · Performance

- Compute `DualDate` for visible month + 1-month buffer on month change,
  cache in `CalendarCubit.state`.
- Activity lookup: `Map<DateTime, Activity>` keyed by `gregorian.copyWith(h:0,m:0,s:0)`.
- Cells are `const` widgets where possible; rebuild only on selection change.
