# Prayer Card — Spec

> Visual reference: `preview/comp-prayer-card.html`. This file is the
> readable spec for Flutter implementation. Two variants: **compact** (default)
> and **expanded**. Compact/expanded is widget-local state; the
> existing `UserSettings.prayerCardDisplayMode` enum (`dashboardOnly |
> dashboardAndTasks | allPages`) controls *where* the card surfaces, not
> which variant. iOS widget renders the same variant the user last
> selected (persisted via shared `UserDefaults` in the App Group).

---

## 1 · Surface

- **Background**: gradient `AppColors.forest` → `AppColors.forestMid`
  (135°). Glass overlay: `Colors.white.withOpacity(0.06)` with 24pt blur
  (`BackdropFilter`).
- **Radius**: 24pt.
- **Padding**: 20pt all sides.
- **Shadow**: `0 12 28 rgba(0,0,0,0.18)`.
- **Min-width**: 320pt. **Max-width**: 480pt on iPad.

---

## 2 · Compact variant (default)

**Layout** (vertical stack, 12pt gaps):

1. **Header row**:
   - Left: Hijri date primary + Gregorian secondary (or reversed per `isHijriMode`).
   - Right: city + 12×12 location pin glyph.
2. **Status row**:
   - "Next prayer" label (`AppText.captionM`, `Colors.white60`).
   - Prayer name (`AppText.titleL`, `Colors.white`).
3. **Time + countdown row**:
   - Big time `HH:MM` (`AppText.numericMono` 56pt, white).
   - Below: live countdown `H:MM:SS` (`AppText.numericMono` 18pt, `Colors.white80`).
4. **Progress bar**:
   - 4pt tall, 8pt radius, bg `Colors.white10`, fill `Colors.cream`.
   - Width = elapsed / interval-to-next.
5. **CTA row**:
   - "Start dhikr" pill button (`AppColors.cream` bg, `AppColors.forest` ink).

---

## 3 · Expanded variant

Adds, after the progress bar (before CTA):

6. **Five-prayer strip**:
   - Horizontal row of 5 chips: Fajr, Dhuhr, Asr, Maghrib, Isha.
   - Each chip: prayer name (`AppText.captionS`), time (`numericMono` 14pt).
   - **States**:
     - past → `Colors.white24`, name struck-through faintly.
     - now → solid `AppColors.cream` bg, `forest` ink.
     - next → 1pt cream border, white text.
     - future → `Colors.white12`, white60.
7. **Sunrise/Sunset arc**:
   - Half-circle SVG, 100pt wide × 50pt tall, centered.
   - Sun glyph travels along the arc per current time-of-day.
   - "Sunrise 05:42" left, "Sunset 18:14" right (`AppText.captionS`, white60).

---

## 4 · Live countdown

- Format: `H:MM:SS` (mono, tabular).
- Updates every 1s via `Timer.periodic`.
- When < 60s: pulse the time text (1.0 → 0.85 opacity, 1s).
- When prayer is "now" (within ±2 min of adhan time):
  - Time replaced by "ALLAHU AKBAR" (`AppText.titleM`, cream).
  - Countdown line replaced by "Pray now" (`AppText.bodyS`, white).

---

## 5 · States

- **Loading**: skeleton — gray gradient, no text.
- **Permission denied**: shows "Enable location for accurate prayer times" + Settings link.
- **Network error**: cached times shown with `ErrorState.inline` row appended.
- **Disabled** (`isPrayerEnabled = false`): card not rendered. Dashboard
  recomputes layout.

---

## 6 · iOS widget

- Same variant as in-app (widget-local state, mirrored to the App Group's shared `UserDefaults` so the iOS widget can read it).
- Background: same gradient + glass.
- Radius: 22pt (iOS widget standard).
- Sizes: small (`compact` only), medium (`compact`), large (`expanded`).
- Updates on adhan boundary via `WidgetKit.reloadTimelines`.
- Tapping opens app to Prayer feature.

---

## 7 · RTL

- All EdgeInsets become `EdgeInsetsDirectional`.
- Header swaps: city moves to left, dual-date to right.
- Five-prayer strip reverses order (Isha → Fajr).
- Countdown numerals stay LTR (Western digits) unless Eastern Numerals
  toggle is ON.
- Arabic prayer names: use `app_ar.arb` keys `prayer.fajr` etc.
