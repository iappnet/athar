# PR3 Domain and State Audit

**Date:** 2026-05-13  
**Type:** Codebase truth audit — no code modified  
**Scope:** Domain models, state machine, service layer, cubit, settings, widget service

---

## §0 · Files Inspected

| File | Lines Read | Purpose |
|---|---|---|
| `lib/features/prayer/domain/models/prayer_timer_status.dart` | Full | Core model + enum |
| `lib/core/services/prayer_timer_service.dart` | Full (301 lines) | Timer service, format logic |
| `lib/features/prayer/presentation/cubit/prayer_cubit.dart` | Full (155 lines) | BLoC layer, widget push |
| `lib/features/settings/data/models/user_settings.dart` | Full | Prayer feature flags |
| `lib/core/services/widget_data_service.dart` | Full | iOS widget bridge |
| `lib/core/design_system/molecules/cards/next_prayer_card.dart` | Full (445 lines) | UI consumer |
| `lib/l10n/app_ar.arb` | grep (prayer keys) | Localization |
| `pubspec.yaml` | grep (fonts) | Asset declarations |

---

## §1 · PrayerTimerLabel Enum — State Machine

### Current definition

```dart
enum PrayerTimerLabel {
  upcoming,
  justStarted,
  current,
}
```

### Required definition (PR3)

```dart
enum PrayerTimerLabel {
  upcoming,
  adhanMoment,    // ← NEW: ±2 min of adhan time
  justStarted,
  current,
}
```

### State transition diagram

```
                                         ─2 min
                ┌─────────────────────────────┐
 ... upcoming ──┤  adhanMoment (if approved)  ├──── justStarted (0–10 min) ──── current ────────────
                └─────────────────────────────┘     (0 min)                     (10 min → end)
```

### Switch expression impact

Every `switch (status.label)` expression in the codebase will fail to compile after adding `adhanMoment` if it is not exhaustive. This is intentional — the compile error will surface all callsites.

Known switch consumers:
- `next_prayer_card.dart:182` — status color logic
- `next_prayer_card.dart:230` — display text selection
- `next_prayer_card.dart:359` — progress row conditionals
- `prayer_timer_service.dart` — internal label assignment

**Action required:** Add `adhanMoment` to enum AND update all switch expressions simultaneously. Do not add the enum value without updating the switches.

---

## §2 · PrayerTimerStatus Model

### Current fields

```dart
class PrayerTimerStatus {
  final String prayerNameAr;
  final String prayerNameEn;
  final String timeDisplay;       // prayer clock time (Arabic-Indic: "١٢:٣٠")
  final String timeDisplayEn;     // prayer clock time (Latin: "12:30")
  final String timeLeft;          // countdown "١س ٥٤د ٣٢ث" (WRONG FORMAT — needs H:MM:SS)
  final String timeLeftEn;        // countdown "1h 54m 32s" (WRONG FORMAT)
  final double progress;          // 0.0–1.0
  final PrayerTimerLabel label;
  final Color statusColor;
  final bool showDhikrButton;
  final String fullDate;          // combined Hijri+Gregorian Arabic
  final String fullDateEn;        // combined Hijri+Gregorian English
  final bool isDuhaTime;
  final bool isQiyamTime;
}
```

### Missing fields for PR3

| Field | Type | Purpose | Source |
|---|---|---|---|
| `hijriDate` | `String` | Primary date header line (Arabic bold) | Compute in `PrayerTimerService._getFormattedDate()` |
| `gregorianDate` | `String` | Secondary date header line (60% opacity) | Compute alongside hijriDate |
| `secondsRemaining` | `int` | Raw seconds for RichText split H:MM vs :SS | Already computed in `_emitStatus()`, just not exposed |
| `sunriseTime` | `String?` | Sunrise row display (Arabic-Indic) | Read from `widget.allPrayers` in card |
| `sunsetTime` | `String?` | Sunset row display (Arabic-Indic) | Maghrib time from `widget.allPrayers` |

**Note on sunrise/sunset:** Per CORRECTION-E (A4 resolved), sunset = Maghrib is already in `allPrayers`. Reading directly in the card widget is architecturally preferred over adding service fields. `sunriseTime` and `sunsetTime` may remain as card-local lookups rather than model fields. Both approaches are valid; model fields reduce widget coupling but add service responsibility.

### Migration rule

`fullDate` and `fullDateEn` MUST remain in the model after PR3. They may be consumed by other parts of the app or iOS widget. Adding new fields is strictly additive — no removals.

---

## §3 · PrayerTimerService — Format Logic Audit

### `_formatDuration(int h, int m, int s)` — Current behavior

**File:** `prayer_timer_service.dart:249–258`

Current output:
- Arabic: `"${h}س ${m}د ${s}ث"` → then `_toArabicNumerals()` → `"١س ٥٤د ٣٢ث"`
- English: `"${h}h ${m}m ${s}s"` → `"1h 54m 32s"`

Required output:
- `"$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}"` → `"1:14:32"`
- No leading zero on hours
- No unit suffixes
- Single format for both Arabic and English (colons are universal)

**Consumer impact:**
- `next_prayer_card.dart:374` — only in-app consumer. Safe to change.
- iOS widget uses `WidgetKeys.remainingSeconds` (int) — NOT the `timeLeft` string. Zero impact.

### `_toArabicNumerals(String s)` — Current behavior

**File:** `prayer_timer_service.dart:293–300`

Applied unconditionally to all Arabic strings (digits in `timeLeft`, `timeDisplay`, `fullDate`). Package A Decision #7 requires Eastern Numerals to be opt-in with `isEasternNumeralsEnabled` default OFF.

**Status:** Always-on is a deviation from Package A Decision #7. Not blocking PR3 UI work, but noted as a compliance gap.

### `_emitStatus()` — adhanMoment detection gap

**File:** `prayer_timer_service.dart:50–110`

Current logic:
```dart
if (elapsed < 600) {
  label = PrayerTimerLabel.justStarted;
} else if (elapsed < activeWindowSeconds) {
  label = PrayerTimerLabel.current;
} else {
  label = PrayerTimerLabel.upcoming;
}
```

Required logic (conditional on Q3 approval):
```dart
if (elapsed >= -120 && elapsed < 120) {   // ±2 min of adhan time
  label = PrayerTimerLabel.adhanMoment;
} else if (elapsed >= 0 && elapsed < 600) {
  label = PrayerTimerLabel.justStarted;
} else if (elapsed >= 600 && elapsed < activeWindowSeconds) {
  label = PrayerTimerLabel.current;
} else {
  label = PrayerTimerLabel.upcoming;
}
```

The exact boundary (±2 min vs 0 to +2 min) is OPEN QUESTION Q3 — blocked on product owner.

### `_getFormattedDate()` — Split date gap

**File:** `prayer_timer_service.dart:230–247`

Currently outputs a single concatenated string: `"١٧ ذو القعدة ١٤٤٦ | ١٣ مايو ٢٠٢٦"`.

PR3 requires two separate fields:
- Hijri: `"١٧ ذو القعدة ١٤٤٦"` (bold, 14px)
- Gregorian: `"١٣ مايو ٢٠٢٦"` (60% opacity, 11px)

The hijri package is already a dep. Computation is straightforward split of existing logic.

---

## §4 · PrayerCubit — State Management

### Registration

`@injectable` (NOT `@lazySingleton`). A new instance is created per feature page that injects it. This is correct behavior — the cubit holds page-local prayer state.

### Data flow

```
PrayerTimerService (lazySingleton, 1s timer)
         ↓ Stream<PrayerTimerStatus>
    PrayerCubit.listen()
         ↓ emit(PrayerLoaded(status))
    NextPrayerCard (Consumer)
         ↓ render from status

PrayerCubit.loadPrayerTimes()
    → calculates nafl flags (duplicates PrayerTimerService logic)
    → pushes to WidgetDataService.pushPrayerData()
```

### Duplication: nafl flag calculation

`PrayerCubit.loadPrayerTimes()` (`prayer_cubit.dart:76–131`) independently recalculates `isDuhaTime` and `isQiyamTime`. This duplicates the logic in `PrayerTimerService._emitStatus()`. Both paths push to widget.

This is not a PR3 blocker — the duplication is stable. Do NOT remove either path in PR3.

### `prayersForProgress` sunrise exclusion

`prayer_cubit.dart:48`: `prayersForProgress` filters out sunrise. This is correct — sunrise is a celestial event, not a fard prayer. Do NOT modify.

---

## §5 · UserSettings — Prayer Feature Flags

### Four-level prayer toggle hierarchy

```
isPrayerEnabled (master)
    └── isPrayerCardEnabled
    └── isPrayerNotificationsEnabled
            └── enablePrayerReminders (15-min pre-prayer)
```

### PR3 relevant fields

| Field | Type | Default | PR3 Impact |
|---|---|---|---|
| `isPrayerEnabled` | `bool` | `false` | Master gate — no change |
| `isPrayerCardEnabled` | `bool` | `false` | Card visibility — no change |
| `prayerCardDisplayMode` | enum | `dashboardOnly` | WHERE card appears — no change |
| `isHijriMode` | `bool` | `true` | Calendar display — no change |

### Missing: Eastern Numerals opt-in

`Package A Decision #7` requires `isEasternNumeralsEnabled` in `UserSettings`. Not implemented. Currently `_toArabicNumerals()` always fires for Arabic. This is a compliance gap, not blocking PR3.

---

## §6 · WidgetDataService — App Group Bridge

### WidgetKeys schema (v6)

All keys confirmed present:

| Key | Constant | Status |
|---|---|---|
| `athar_prayer_name` | `WidgetKeys.prayerName` | ✅ |
| `athar_prayer_time` | `WidgetKeys.prayerTime` | ✅ |
| `athar_time_remaining` | `WidgetKeys.timeRemaining` | ✅ |
| `athar_remaining_seconds` | `WidgetKeys.remainingSeconds` | ✅ |
| `athar_progress` | `WidgetKeys.progress` | ✅ |
| `athar_is_duha_time` | `WidgetKeys.isDuhaTime` | ✅ |
| `athar_is_qiyam_time` | `WidgetKeys.isQiyamTime` | ✅ |
| `athar_prayer_card_variant` | — | ❌ MISSING |

### Missing: prayerCardVariant

The compact/expanded toggle state must be mirrored to the iOS widget via App Group. No key exists. Required action:

1. Add `static const String prayerCardVariant = 'athar_prayer_card_variant';` to `WidgetKeys`
2. Call `_widgetDataService.updatePrayerCardVariant()` from `_NextPrayerCardState` on toggle

**CRITICAL**: Per CLAUDE.md non-negotiable rules — `WidgetKeys` constants must NEVER be renamed once added to a real build. The new key name `'athar_prayer_card_variant'` must be chosen carefully before the first production push.

---

## §7 · State Machine Correctness Assessment

### Things that are correct and must not change

| Behavior | File | Rule |
|---|---|---|
| Dynamic active window % | `prayer_timer_service.dart:50–58` | Fajr=40, Maghrib=20, others dynamic |
| Duha window: sunrise+15 → dhuhr-15 | `prayer_timer_service.dart:113` | Correct nafl timing |
| Qiyam window: last third Isha→Fajr | `prayer_timer_service.dart:126` | Correct nafl timing |
| Midnight crossing | `prayer_timer_service.dart:178` | Critical correctness |
| Sunrise exclusion from fard | `prayer_cubit.dart:48` | Sunrise is not fard |
| `showDhikrButton` conditional | `prayer_timer_service.dart:69` | Only during active window |

### Things that are wrong and must change

| Behavior | File | Change |
|---|---|---|
| Countdown format | `prayer_timer_service.dart:249–258` | Unit suffixes → H:MM:SS |
| No `adhanMoment` state | `prayer_timer_service.dart:50–110` | Add state (Q3 approval needed) |
| No split date fields | `prayer_timer_service.dart:230–247` | Add hijriDate + gregorianDate |
| Eastern numerals always-on | `prayer_timer_service.dart:293` | Defer to PR-SETTINGS |
| No `secondsRemaining` field | `prayer_timer_status.dart` | Add int field |

---

## §8 · l10n Coverage Summary

### Existing keys (confirmed in app_ar.arb)

| Key | Arabic | English equivalent |
|---|---|---|
| `prayerSunrise` | الشروق | Sunrise |
| `prayerCardDuhaTime` | وقت صلاة الضحى متاح الآن | Duha prayer time is now available |
| `prayerCardQiyamTime` | وقت قيام الليل - الثلث الأخير | Night prayer - last third |
| `prayerLabelUpcoming` | الصلاة القادمة | Next prayer |
| `prayerLabelJustStarted` | حان الآن موعد الصلاة | Prayer time is now |
| `prayerLabelCurrent` | الصلاة الحالية | Current prayer |

### Missing keys (required for PR3)

| Key | Arabic | English | Notes |
|---|---|---|---|
| `prayerCardSunset` | غروب | Sunset | Needed for sunrise/sunset row |
| `prayerCardAdhanMoment` | الصلاة الآن | Pray now | adhanMoment state label |
| `prayerCardAllahuAkbar` | ٱللَّٰهُ أَكْبَرُ | — | Sacred text — must come from designer/PO (Q3) |
| `prayerCardEnableLocation` | فعّل خدمة الموقع | Enable location services | Permission-denied error |
| `prayerCardExpand` | — | Expand prayer card | Accessibility label |
| `prayerCardCollapse` | — | Collapse prayer card | Accessibility label |

**Note on `prayerCardAllahuAkbar`:** This is the most sacred UI text in the app. The exact Unicode codepoints for `ٱللَّٰهُ أَكْبَرُ` must be provided by an authoritative source (product owner or religious advisor). Do NOT infer from training data.

---

## §9 · Domain Layer Final Assessment

| Layer | Readiness | Blocking Issues |
|---|---|---|
| `PrayerTimerLabel` enum | 75% | Missing `adhanMoment` (Q3 approval) |
| `PrayerTimerStatus` model | 70% | Missing split dates + secondsRemaining |
| `PrayerTimerService` | 60% | Wrong countdown format; no adhanMoment; no split dates |
| `PrayerCubit` | 90% | No changes needed for core PR3 |
| `UserSettings` | 95% | No changes needed for PR3 (Eastern Numerals deferred) |
| `WidgetDataService` | 90% | Only prayerCardVariant key missing |
| **Domain overall** | **~80%** | Core infrastructure sound; format + enum + model gaps |
