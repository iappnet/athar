# DualDate — Domain & Integration Spec (PR4b)

> **Track 2 / PR4b unblock.** This clears blocker **B3** (no written DualDate
> designer spec). It defines the value object, conversion rules, `isHijriMode`
> migration semantics, and the cubit-integration contract.
>
> **Scope split — read this first:**
> - `CALENDAR_CELL_SPEC.md` = the **visual** spec (cell layout, header, day
>   sheet, states). Unchanged; still authoritative for pixels.
> - **This file** = the **domain + data + integration** spec. Authoritative for
>   the value object, conversion, caching, and the cubit contract.
>
> **This spec defines WHAT and the contract. It does NOT pick the cubit
> wiring approach** — that is the job of Claude Code's read-only
> architecture-feasibility audit (`_audit_calendar_dual.md`), which evaluates
> options (a)/(b)/(c) below and returns a recommendation for designer sign-off
> BEFORE any Dart is written.

Locked: 2026-06-01. Source of truth alongside `CALENDAR_CELL_SPEC.md`.

---

## 0 · Why PR4b exists

Today (`PR4a` shipped) the calendar is a **toggle**: `DualCalendarWidget`
holds `_isGregorianPrimary` and shows **one** calendar at a time, syncing
from `settings.isHijriMode`. The design target is **Apple-Calendar-style
simultaneous dual display** — both numerals visible in every cell, always.

PR4b is the rebuild that makes that real. It is **its own milestone**
(highest implementation risk in the app) and must not be folded into a
visual-refresh PR.

---

## 1 · The `DualDate` value object

A pure, immutable domain object. No Flutter imports, no widget concerns.

```dart
// lib/features/calendar/domain/entities/dual_date.dart
import 'package:hijri/hijri_calendar.dart';

class DualDate {
  /// Midnight-normalized Gregorian day (h/m/s/ms = 0). This is the identity key.
  final DateTime gregorian;

  /// Hijri conversion of [gregorian].
  final HijriCalendar hijri;

  /// True when this day is the 1st of a Hijri month (drives the boundary hairline
  /// + month-name swap in CALENDAR_CELL_SPEC §"Hijri-month boundary").
  final bool isFirstOfHijriMonth;

  const DualDate({
    required this.gregorian,
    required this.hijri,
    required this.isFirstOfHijriMonth,
  });
}
```

### Rules
- `gregorian` is **always midnight-normalized** (`DateTime(y, m, d)`), no
  time component. This is the map key for activity lookup — it must match the
  key PR4a already uses (`gregorian.copyWith(hour:0,minute:0,second:0)`).
- `hijri` comes from `package:hijri` (`HijriCalendar` — already a project
  dependency; verified present). **Do not add a new conversion lib.**
- `isFirstOfHijriMonth = hijri.hDay == 1`.
- `DualDate` is **Equatable** on `gregorian` only (the Hijri + boolean are
  derived, so two DualDates with the same Gregorian day are equal). Add
  `Equatable` to match the codebase's existing entity pattern.
- No `==`/`hashCode` hand-rolling — use `Equatable` props `[gregorian]`.

### Factory
```dart
factory DualDate.from(DateTime day) {
  final g = DateTime(day.year, day.month, day.day);
  final h = HijriCalendar.fromDate(g);
  return DualDate(gregorian: g, hijri: h, isFirstOfHijriMonth: h.hDay == 1);
}
```

---

## 2 · `isHijriMode` — migration semantics (LOCKED, Package A #2)

`UserSettings.isHijriMode` **already exists** (bool, default `false`). PR4b
**repurposes its meaning**, it does **not** add a field:

| Old meaning (pre-PR4b) | New meaning (PR4b onward) |
|---|---|
| Toggle: show Hijri-only **or** Gregorian-only | Both always shown; this picks which numeral is **primary** (large/top) vs **secondary** (small/bottom) |
| `true` → Hijri-only view | `true` → Hijri is the **primary** numeral; Gregorian secondary |
| `false` → Gregorian-only view | `false` → Gregorian primary; Hijri secondary |

**Existing-user behavior:** the app has **no users yet** (pre-launch), so
there is no compatibility concern. `isHijriMode` is repurposed in place —
**no `hijriPrimary` field is added** (an earlier draft proposed one purely
for migration safety; unnecessary pre-launch). The calendar binds
`primaryHijri = settings.isHijriMode` directly.

**Date-picker semantic split (accepted, temporary):** the task/habit date
pickers (`add_task_sheet.dart`, `unified_add_sheet.dart`,
`date_time_picker.dart`, `habit_page.dart`) currently read `isHijriMode` as
"show Hijri OR Gregorian (one only)." PR4b does **not** migrate them — they
keep reading the flag as-is. The split (calendar = primary/secondary;
pickers = show-one) is harmless with no users and gets resolved when the
date-picker component receives its own redesign pass. Deferred, not a
blocker.

**`DualCalendarWidget`'s internal `_isGregorianPrimary` is deleted** — the
primary/secondary choice now flows purely from `settings.isHijriMode`. There
is no in-widget toggle state anymore.

---

## 3 · Cubit integration contract (the WHAT — not the HOW)

**ARCHITECTURE DECISION (locked 2026-06-01):** Option **(b)** — a new
`CalendarMonthCubit` owns month-level aggregation + the `DualDate` cache;
the existing `CalendarCubit` keeps day-selection. Follows the
`TaskCubit`/`TimelineCubit` precedent. Within it the cache is a
`Map<DateTime, DualDate>` keyed midnight-normalized. (Audit
`_audit_calendar_dual.md` §5 — designer accepted, overriding the earlier
lean toward a use-case layer.)

PR4b must satisfy this contract:

1. **Per-month computation, cached.** When the visible month changes,
   `CalendarMonthCubit` computes `DualDate` for **visible month + 1-month
   buffer each side** and caches them in `Map<DateTime, DualDate>`. Cells
   never convert during paint.
2. **Activity fan-in is NOT inherited — PR4b builds it.** ⚠️ Correction:
   PR4a did **not** add a month-level activity map. `CalendarLoaded` holds
   only `{selectedDate, items}` for the *selected day*. PR4b builds the
   month-range `activityByDate` map from scratch inside
   `CalendarMonthCubit`. **Dot sources (locked):** **tasks + habits +
   appointments + medicines + prayer** — five sources. Tasks →
   `TaskRepository`; habits → `HabitRepository`; appointments + medicines
   → `HealthRepository`; prayer → `PrayerRepository` / adhan calc.

   **Prayer dot semantics (locked):** the prayer dot is **per-prayer, not
   one-per-day** — each of the five daily prayers is treated like a timed
   event ("appointment-style"), occupying its own time-spot on the day.
   When the day-sheet / timeline expands a day, the five prayers appear as
   discrete time-ordered entries interleaved with tasks/appointments/
   medicines/habits. On the month grid each prayer contributes to the
   day's dot cluster (cap the visible dots per `CALENDAR_CELL_SPEC §1`
   overflow rule; prayer uses the forest dot color).

   **Prayer dot gating (locked):** renders only when
   `isPrayerEnabled && showPrayerDotsOnCalendar`.
   - `isPrayerEnabled` (existing master) OFF → no prayer dots, and the
     sub-toggle is hidden entirely.
   - `showPrayerDotsOnCalendar` (NEW sub-toggle, additive `UserSettings`
     field, **default `true`**) appears in Settings → Prayer **only when**
     `isPrayerEnabled == true`, nested with the Phase 8.1 prayer
     sub-toggles (`isPrayerCardEnabled`, `isPrayerNotificationsEnabled`).
     User can switch the calendar prayer dots off and back on.
3. **State exposes:** `Map<DateTime, DualDate>` for the visible window, the
   current `primaryHijri` bool (= `settings.isHijriMode`, see §2), the
   focused month, and `Map<DateTime, ActivitySet>` (the 5-source dot map,
   prayer entries included only when the gate in point 2 is satisfied).
4. **No new Supabase change.** Conversion is pure/local. `HabitRepository`
   may need a new month-range completion query (additive).
5. **Subscription-awareness preserved.**
6. **`activityByDate` key = midnight-normalized Gregorian** (`DateTime(y,m,d)`)
   — same key as `DualDate.gregorian`, so the two maps align 1:1.

---

## 4b · Deferred from PR4b (locked)

- **`DualMonthSwitcher`** (dual-row pill switcher, `CALENDAR_CELL_SPEC §2`) —
  **deferred.** Keep the existing chevron `_changeMonth(±1)` navigation in
  PR4b. The pill switcher is its own later ticket.
- **Date-picker migration** (task/habit pickers off the repurposed
  `isHijriMode`) — deferred to the date-picker redesign pass.
- **Habit/medicine month-range queries** — in scope (they are dot sources),
  but if `HabitRepository` lacks a range query, adding one is additive and
  part of PR4b.

---

## 5 · Performance budget

- Month-scroll must not drop frames. Pre-compute the buffer so a swipe to the
  next month never converts on the paint path.
- `HijriCalendar.fromDate` is cheap but not free — **memoize**; never call it
  inside `build()`.
- Cells `const` where possible; rebuild only on selection / month change
  (matches `CALENDAR_CELL_SPEC §6`).

---

## 6 · Eastern numerals interaction (already specced)

Numeral rendering (Western vs Arabic-Indic ٠١٢٣) is governed by
`CALENDAR_CELL_SPEC §4` + the `Accessibility.easternNumerals` flag (PR5
stores it). PR4b **consumes** that flag for both numerals when locale is
Arabic; it does **not** own the flag. If PR5 hasn't shipped when PR4b starts,
PR4b reads the flag defensively (default OFF → Western digits) and the
behavior lights up once PR5 lands. Flag this dependency in the audit.

---

## 7 · Files PR4b is expected to touch (audit-confirmed)

- **New:** `lib/features/calendar/domain/entities/dual_date.dart`
- **New:** `lib/features/calendar/presentation/cubit/calendar_month_cubit.dart`
- **New:** `lib/features/calendar/presentation/cubit/calendar_month_state.dart`
- **New:** `lib/features/calendar/presentation/widgets/calendar_day_cell.dart`
  (per `CALENDAR_CELL_SPEC §1`)
- **New:** `lib/features/calendar/presentation/widgets/dual_calendar_header.dart`
  (per `CALENDAR_CELL_SPEC §2` — header only; pill switcher deferred)
- **Edit:** `calendar_page.dart` — add `BlocProvider<CalendarMonthCubit>`, split
  the grid / day-events BlocBuilders.
- **Edit:** `app.dart` — add `BlocProvider<CalendarMonthCubit>`.
- **Edit (maybe):** `HabitRepository` — additive month-range completion query.
- **Replace/delete:** `dual_calendar_widget.dart` — migrate consumers to the
  new cell + switcher, then delete; remove `_isGregorianPrimary`.
- **Edit:** the calendar page/body that hosts the grid.

**Do not touch** the PR4a activity fan-in, the prayer/habit/task cubits, or
any data/repository layer.

---

## 8 · Hard rules (carry forward)

- Tokens only (`AppColors` / `AppText` / `AppSpacing`); no hex/dp.
- Calibri primary + Cairo fallback on every Arabic-bearing style (the
  app-wide `AtharTypography` fallback already covers this — don't re-add per
  call site).
- `EdgeInsetsDirectional` / `BorderRadiusDirectional` everywhere; never
  `left/right`.
- AdaptiveShell + RULE 1 (window-based `LayoutBuilder`, never `isTablet`).
- Both numerals always render — there is no "Hijri-only" or "Gregorian-only"
  state anymore.
- Additive-only on `UserSettings` (no field added — `isHijriMode` repurposed).
- Do not regenerate the PR3 prayer-card goldens.

---

## 9 · Resolved decisions (locked 2026-06-01 — no longer open)

1. **`isHijriMode` vs `hijriPrimary`:** reuse `isHijriMode`, repurpose in
   place. **No `hijriPrimary` field** — app is pre-launch, no migration
   concern. Date pickers keep their show-one behavior (split deferred).
2. **Hijri month-name on boundary cell:** use a **3-letter abbreviation
   table** (not a hard char cut). Claude Code proposes the table in a PR4b
   follow-up; designer approves before use.
3. **Leading/trailing (other-month) days:** render as **disabled dual-numeral
   cells** (`text3`, both numerals dimmed). Not empty `SizedBox`.
4. **Primary numeral source:** `isHijriMode` is **purely user-set** in
   Settings. Locale does **not** auto-flip it.
5. **Dot sources:** **task + habit + appointment + medicine + prayer.**
   Prayer dot is **per-prayer (timed, appointment-style)**, gated behind
   `isPrayerEnabled && showPrayerDotsOnCalendar` (new sub-toggle, default
   ON, shown only when prayer is enabled).
6. **Numeral position authority:** `CALENDAR_CELL_SPEC.md` (top-center /
   bottom-center, named text styles). `CALENDAR_FOCUS_REDESIGN.md`'s
   "top-right / bottom-left" is the superseded older draft.
7. **Architecture:** Option (b) — `CalendarMonthCubit` + `Map<DateTime,
   DualDate>`.

---

## 10 · Definition of done (PR4b)

- Both numerals render in every cell, every state, both locales.
- `isHijriMode` flips primary/secondary (not visibility).
- First-of-Hijri-month hairline + month-name swap correct.
- Day-sheet header shows both dates joined by `·`, reorders when Hijri-primary.
- Month-scroll holds frame budget (no jank); conversions memoized.
- `dual_calendar_widget.dart` deleted; no `_isGregorianPrimary` remains.
- `activityByDate` built in `CalendarMonthCubit`; **task + habit + appointment
  + medicine** dots always correct on the new cells; **prayer** dots
  (per-prayer, timed) render only when `isPrayerEnabled &&
  showPrayerDotsOnCalendar`. New `showPrayerDotsOnCalendar` field added
  (additive, default true), surfaced as a Settings→Prayer sub-toggle.
- `flutter analyze` 0 issues; golden suite for the new cell (both locales,
  primary/secondary, today/selected/boundary states).
- PR3 goldens untouched.
