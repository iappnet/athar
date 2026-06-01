# PR3 Prayer Card — Screenshot Matrix

Golden PNGs live at `test/golden/pr3/`. Generated via:
```
flutter test --update-goldens test/golden/prayer_card_pr3_test.dart
```

16 images — 8 states × 2 locales (Arabic RTL / English LTR), 375×812 px each (iPhone 14 logical).

---

## State 1 — Upcoming compact

| Locale | File | Notes |
|--------|------|-------|
| Arabic (RTL) | [`test/golden/pr3/01_upcoming_ar.png`](test/golden/pr3/01_upcoming_ar.png) | Countdown 2:15:30, progress 25%, Hijri + Gregorian header |
| English (LTR) | [`test/golden/pr3/01_upcoming_en.png`](test/golden/pr3/01_upcoming_en.png) | Latin numerals, LTR layout |

---

## State 2 — Active prayer (current)

| Locale | File | Notes |
|--------|------|-------|
| Arabic (RTL) | [`test/golden/pr3/02_active_ar.png`](test/golden/pr3/02_active_ar.png) | Label=current, dhikr button visible, no countdown |
| English (LTR) | [`test/golden/pr3/02_active_en.png`](test/golden/pr3/02_active_en.png) | "Started at" hero, LTR |

---

## State 3 — Nafl chip (Duha time)

| Locale | File | Notes |
|--------|------|-------|
| Arabic (RTL) | [`test/golden/pr3/03_nafl_duha_ar.png`](test/golden/pr3/03_nafl_duha_ar.png) | isDuhaTime=true, teal dot + glass pill |
| English (LTR) | [`test/golden/pr3/03_nafl_duha_en.png`](test/golden/pr3/03_nafl_duha_en.png) | Nafl chip in English |

---

## State 4 — Expanded variant

| Locale | File | Notes |
|--------|------|-------|
| Arabic (RTL) | [`test/golden/pr3/04_expanded_ar.png`](test/golden/pr3/04_expanded_ar.png) | expanded=true, extra rows visible |
| English (LTR) | [`test/golden/pr3/04_expanded_en.png`](test/golden/pr3/04_expanded_en.png) | Expanded LTR |

---

## State 5 — Loading skeleton

| Locale | File | Notes |
|--------|------|-------|
| Arabic (RTL) | [`test/golden/pr3/05_loading_ar.png`](test/golden/pr3/05_loading_ar.png) | SmartPrayerCardWrapper, PrayerLoading state, shimmer bars |
| English (LTR) | [`test/golden/pr3/05_loading_en.png`](test/golden/pr3/05_loading_en.png) | Loading skeleton LTR |

---

## State 6 — Permission denied (no city configured)

| Locale | File | Notes |
|--------|------|-------|
| Arabic (RTL) | [`test/golden/pr3/06_permission_denied_ar.png`](test/golden/pr3/06_permission_denied_ar.png) | PrayerError + cityName=null → location prompt |
| English (LTR) | [`test/golden/pr3/06_permission_denied_en.png`](test/golden/pr3/06_permission_denied_en.png) | "Enable location" prompt LTR |

---

## State 7 — iPhone SE (375×667)

| Locale | File | Notes |
|--------|------|-------|
| Arabic (RTL) | [`test/golden/pr3/07_se_ar.png`](test/golden/pr3/07_se_ar.png) | Compact viewport, countdown font drops to sizeDisplayLg (40sp) |
| English (LTR) | [`test/golden/pr3/07_se_en.png`](test/golden/pr3/07_se_en.png) | SE LTR |

---

## State 8 — Progress bar ~50%

| Locale | File | Notes |
|--------|------|-------|
| Arabic (RTL) | [`test/golden/pr3/08_progress50_ar.png`](test/golden/pr3/08_progress50_ar.png) | progress=0.5, bar fills half from trailing edge in RTL |
| English (LTR) | [`test/golden/pr3/08_progress50_en.png`](test/golden/pr3/08_progress50_en.png) | Bar fills from leading edge in LTR |

---

## Test infrastructure

File: `test/golden/prayer_card_pr3_test.dart`

| Class | Role |
|-------|------|
| `_FakeTimerService` | Extends `PrayerTimerService`, overrides `timerStream` with a controllable broadcast `StreamController`; `push(status)` injects state per test |
| `_StubPrayerRepo` | Implements `PrayerRepository` with no-op stubs |
| `_StubSettingsRepo` | Implements `SettingsRepository`; serves a configured `UserSettings` |
| `_StubHabitRepo` | Implements all 13 `HabitRepository` methods as empty stubs |
| `_StubSettingsCubit` | Extends `SettingsCubit`; emits `SettingsLoaded` synchronously in constructor |
| `_StubPrayerCubit` | Extends `PrayerCubit`; factory constructors for `loaded / loading / error` states |
| `_StubHabitCubit` | Extends `HabitCubit`; stays in `HabitInitial` |

No production code was modified to generate these screenshots.
