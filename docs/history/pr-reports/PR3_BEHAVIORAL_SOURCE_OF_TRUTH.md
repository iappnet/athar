# PR3 Behavioral Source of Truth

**Date:** 2026-05-09  
**Status:** Read-only behavioral audit — NO code modified  
**Authority:** Flutter codebase is the functional authority. Spec is the visual target.  
**Files inspected:**

| File | Purpose |
|---|---|
| `lib/core/design_system/molecules/cards/next_prayer_card.dart` | Card rendering + tap logic |
| `lib/core/design_system/molecules/cards/smart_prayer_wrapper.dart` | Visibility gate logic |
| `lib/core/services/prayer_timer_service.dart` | Timer logic, all window calculations |
| `lib/features/prayer/domain/models/prayer_timer_status.dart` | Domain model |
| `lib/features/prayer/domain/entities/prayer_time.dart` | Prayer entity + adhan adapter |
| `lib/features/prayer/data/repositories/prayer_repository_impl.dart` | Calculation source |
| `lib/features/prayer/presentation/pages/prayer_details_page.dart` | Tap destination |
| `lib/features/prayer/presentation/cubit/prayer_cubit.dart` | State loading |
| `lib/features/habits/presentation/cubit/habit_cubit.dart` | Dhikr habit logic |
| `lib/features/dhikr/presentation/widgets/dhikr_bottom_sheet.dart` | Dhikr sheet |
| `lib/features/home/presentation/pages/dashboard_page.dart` | Card placement in dashboard |

---

## 1 · Prayer Card Tap Behavior

### Primary Tap — Full Card

```
Tap anywhere on card body
  → Navigator.push(context, MaterialPageRoute(builder: (_) => PrayerDetailsPage()))
```

- **Mechanism:** `InkWell` wraps the entire card padding content
- **Navigation:** `push` (new route on the stack, back button returns to dashboard)
- **Destination:** `PrayerDetailsPage` — a `Scaffold` with:
  - `AtharAppBar(title: prayerTimesTitle)` + back button
  - `DefaultTabController(length: 3)` with Today / Week / Month tabs
  - Tab body: `PrayerDayView` / `PrayerWeekView` / `PrayerMonthView`
- **Transition:** Standard `MaterialPageRoute` slide (no custom transition)
- **Tab behavior:** Tab state is NOT preserved across push/pop. Each open of `PrayerDetailsPage` starts on the Today tab.

### Secondary Tap — Dhikr Button

```
Tap 🤲 button (visible only during active prayer window)
  → HabitCubit.getOrCreatePostPrayerHabit()
  → showModalBottomSheet → DhikrBottomSheet(habit: postPrayerHabit)
```

- **Mechanism:** `GestureDetector` — a separate hit area inside `_buildProgressRow`
- **Condition:** Only visible when `status.showDhikrButton == true` (see §2)
- **No conflict:** `GestureDetector` absorbs the tap; the full-card `InkWell` does NOT fire for dhikr taps

### Key Behavioral Fact
**The primary CTA of the prayer card is the FULL-CARD TAP → Prayer Times page.**  
The `🤲` button is a contextual secondary action — post-prayer dhikr shortcut.  
The card is NOT a multi-button component. It has two tap zones: the whole card, and one conditional icon.

---

## 2 · Post-Prayer Athkar Behavior

### Visibility Trigger

The dhikr button appears when `minutesSincePrev >= 0 AND minutesSincePrev < activeWindow`.

### Active Window — Real Timing (NOT 40 minutes universally)

```dart
// PrayerTimerService._emitStatus():
int activeWindow = (timeBetween * 0.3).round();   // 30% of interval to next prayer
if (activeWindow <= 0) activeWindow = 30;
activeWindow = activeWindow.clamp(15, 45);         // floor: 15 min, ceiling: 45 min

// Prayer-specific overrides:
if (prevPrayer.type == PrayerType.maghrib) activeWindow = 20;  // Maghrib: 20 min
if (prevPrayer.type == PrayerType.fajr) activeWindow = 40;    // Fajr: 40 min
```

**Real active window durations:**

| Prayer | Active Window | Calculation |
|---|---|---|
| **Fajr** | **40 min** (fixed override) | Overridden — sunrise is close |
| **Maghrib** | **20 min** (fixed override) | Overridden — Isha follows quickly |
| **Dhuhr** | 15–45 min (dynamic) | ~30% of Dhuhr→Asr interval |
| **Asr** | 15–45 min (dynamic) | ~30% of Asr→Maghrib interval |
| **Isha** | 15–45 min (dynamic) | ~30% of Isha→Fajr interval (night) |

**Note:** The commonly cited "40 minutes" applies ONLY to Fajr.

### Active Window State Phases

Within the active window, there are two phases:

| Phase | Time Since Prayer | Label Enum | Color | Button |
|---|---|---|---|---|
| `justStarted` | 0–9 min (labelWindow = 10) | `PrayerTimerLabel.justStarted` | `0xFF4CAF50` (green) | ✅ Shown |
| `current` | 10–(activeWindow-1) min | `PrayerTimerLabel.current` | `0xFF29B6F6` (blue) | ✅ Shown |
| `upcoming` (next) | ≥ activeWindow | `PrayerTimerLabel.upcoming` | `0xFFFFB300` (amber) | ❌ Hidden |

### Dhikr Button Disappearance

The button disappears AUTOMATICALLY when the timer service transitions from `justStarted`/`current` to `upcoming`. This happens at `minutesSincePrev == activeWindow`.

**There is no separate disappearance timer, no animation on disappearance, and no user action required.** The `StreamBuilder` rebuilds when the service emits the new state.

### Athkar Content — What Opens

`HabitCubit.getOrCreatePostPrayerHabit()`:
1. Searches `_cachedHabits` for any habit with `period == HabitPeriod.postPrayer`
2. If found: returns it (user's existing post-prayer athkar habit)
3. If not found: creates a new `HabitModel` with:
   - `type = HabitType.athkar`
   - `period = HabitPeriod.postPrayer`
   - `athkarItems` from `AthkarData.allAthkar` filtered by `DhikrTiming.prayer`
   - Saves to Isar via `_habitRepository.addHabit(newHabit)`

`DhikrBottomSheet`:
- Full-screen bottom sheet with scrollable list of athkar items
- Auto-scrolls to the first incomplete item on open
- Shows progress (count-based: tap to increment)
- Reset option via dialog

### Coupling with Prayer State

The dhikr button is coupled to `PrayerTimerService`, NOT to `PrayerCubit`. The card does not read `PrayerCubit` state — it only uses the timer stream. The `PrayerCubit` is consumed by `SmartPrayerCardWrapper` to decide whether to render the card and to pass `allPrayers` to `NextPrayerCard`.

---

## 3 · Nafl Badge Logic

### Duha Badge (Voluntary Morning Prayer)

```dart
// PrayerTimerService._emitStatus():
final sunrise = _getFirstPrayer(PrayerType.sunrise);
final dhuhr = _getFirstPrayer(PrayerType.dhuhr);
final start = sunrise.time.add(const Duration(minutes: 15));
final end = dhuhr.time.subtract(const Duration(minutes: 15));
isDuha = now.isAfter(start) && now.isBefore(end);
```

**Window:** `sunrise + 15 minutes` → `dhuhr - 15 minutes`  
**Badge color:** `Colors.orange` (hardcoded, not tokenized)  
**Icon:** `Icons.wb_sunny_rounded`  
**String key:** `l10n.prayerCardDuhaTime`  
**Not related to Witr.**

### Qiyam Badge (Night Vigil — Last Third of Night)

```dart
// PrayerTimerService._emitStatus():
final isha = _getLastPrayer(PrayerType.isha);
final fajr = _getFirstPrayer(PrayerType.fajr);

// Handles midnight crossing:
if (now.hour >= 12) {
  nightStart = isha.time;
  nightEnd = fajr.time.add(Duration(days: 1));  // tomorrow Fajr
} else {
  nightStart = isha.time.subtract(Duration(days: 1));
  nightEnd = fajr.time;
}

final duration = nightEnd.difference(nightStart);
final lastThirdStart = nightEnd.subtract(
  Duration(minutes: (duration.inMinutes / 3).round()),
);
isQiyam = now.isAfter(lastThirdStart) && now.isBefore(nightEnd);
```

**Window:** Last third of the night (between Isha and Fajr)  
**Badge color:** `Colors.indigo` (hardcoded, not tokenized)  
**Icon:** `Icons.nights_stay_rounded`  
**String key:** `l10n.prayerCardQiyamTime`

### No Witr Badge

There is **no separate Witr badge** in the current codebase. The Qiyam badge covers the voluntary night prayer window.

### Rendering Position

Both badges render BETWEEN the header row and the status/time row:
```
[Header: date + city]
[Nafl badge — if isDuhaTime || isQiyamTime]
[Status/time row: label + prayer name | prayer time]
[Progress row: countdown + bar + 🤲 button]
```

Only ONE badge can show at a time (Duha and Qiyam windows are mutually exclusive by time of day). The code renders whichever is true first.

### Data Sources

Duha/Qiyam are computed from `PrayerTimerService._todayPrayers` (the same list passed to `NextPrayerCard.allPrayers`). Both have `try/catch` wrappers that silence any errors — if sunrise or fajr is missing, the badge simply doesn't show.

`PrayerCubit.loadPrayerTimes()` computes the same flags independently to push to the iOS widget via `WidgetDataService`.

---

## 4 · Adhan/Sunrise/Sunset Sources

### Calculation Library

**Package:** `adhan` (imported as `adhan/adhan.dart`)  
**Method:** `adhan.CalculationMethod.umm_al_qura.getParameters()`  
**Madhab:** `adhan.Madhab.shafi`  
**Location:** User-stored lat/lng in `UserSettings`; defaults to Riyadh (24.7136, 46.6753)  
**Adjustment:** `settings.prayerTimeAdjustmentMinutes` applied to all five fard prayers

### Sunrise — Already in Domain Layer

**YES.** `PrayerTime.fromAdhanPrayerTimes()` explicitly includes:
```dart
PrayerTime.fromAdhan(adhan.Prayer.sunrise, prayerTimes.sunrise),
```

`PrayerType.sunrise` is a valid enum value. The `allPrayers` list passed to `NextPrayerCard` already contains the sunrise entry. **No additional architecture work needed to show sunrise time.**

### Sunset — Available via Maghrib

In the Umm al-Qura calculation method, **Maghrib time IS sunset** (astronomical sunset with a 2-minute buffer). The `PrayerType.maghrib` entry in `allPrayers` IS the sunset time in practice.

`adhan.PrayerTimes` does not separately expose a "sunset" property distinct from Maghrib in this method. There is no `PrayerType.sunset` in the domain model.

**Result:** Sunset time is available from `allPrayers.firstWhere((p) => p.type == PrayerType.maghrib).time`. **No additional architecture work needed.** PR3 just needs to read this existing value.

### No API Call for Sunrise/Sunset

All times (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha) are computed **locally** by the adhan library from coordinates + date. There is no network request for times. The `prayer_remote_source.dart` exists but `prayer_repository_impl.dart` does NOT use it — it uses the adhan library directly.

---

## 5 · Current Countdown Hierarchy

### Typography
- Size: `12.sp` (approximately 12 logical pixels)
- Weight: regular (no font weight specified — defaults to w400)
- Color: `Colors.white70`
- Font: inherited (Calibri after PR1)
- No tabular figures, no numericMono
- Position: first child in progress Row, before the progress bar

### Current Layout Hierarchy (visual weight, highest → lowest)

| Element | Size | Weight | Color | Visual Weight |
|---|---|---|---|---|
| Prayer name | 26sp | bold (w700) | white | ████████ Highest |
| Prayer time (HH:MM AM/PM) | 26sp | w300 | white | ████████ Tied highest |
| Status label | 12sp | regular | state-colored | ███ |
| **Countdown** | **12sp** | **regular** | **white70** | **██ Lowest** |
| Progress bar | 6pt bar | — | state-colored | █ |

**Current problem:** The countdown (`H:MM:SS`) has the LOWEST visual weight of any element, despite being the most time-sensitive information on the card.

### Dashboard Placement

The prayer card is the FIRST content element below the app bar on the dashboard:

```
[SliverAppBar — pinned, expandedHeight:144h, collapsedHeight:68h]
[SyncStatusHeader — optional, 0 or ~32pt]
[SmartPrayerCardWrapper] ← FIRST CONTENT
[StatisticsCard]
[SmartHabitsStrip]
[DailyTimelineWidget]
[156pt bottom clearance for nav bar]
```

### Current Card Dimensions (measured from code)

Outer margin: `horizontal: AtharSpacing.lg (16pt)`, `vertical: AtharSpacing.xxs (~4pt each side)`  
Inner padding: `horizontal: AtharSpacing.lg (16pt)`, `vertical: AtharSpacing.md (~12pt each side)`

| Section | Height (pt) |
|---|---|
| Top padding | 12 |
| Header row (icon 14sp + text 11sp) | ~20 |
| `AtharGap.md` | 12 |
| Nafl badge (if visible) | ~36 |
| Status/time row (26sp text, ~1.2× line-height) | ~36 |
| `AtharGap.md` | 12 |
| Countdown text (12sp) | ~16 |
| `AtharGap.xs` | 6 |
| Progress bar (6pt) | 6 |
| Bottom padding | 12 |
| **Total without nafl badge** | **~132pt** |
| **Total with nafl badge** | **~168pt** |
| **Total with margin** | **~140pt / ~176pt** |

---

## 6 · Real Prayer-State Lifecycle

```
App opens / foreground:
  PrayerCubit.loadPrayerTimes() called from app.dart onResume
    → PrayerLoading (SmartWrapper shows spinner)
    → fetch settings + calculate via adhan library
    → PrayerLoaded(allPrayers: [Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha])

NextPrayerCard.initState():
  PrayerTimerService.startTimer(allPrayers)
    → _ticker = Timer.periodic(1s, _emitStatus)
    → timerStream emits PrayerTimerStatus every second

Per-second tick:
  _calculateTimeline(now) → {prev, next}
  minutesSincePrev = now.difference(prev.time).inMinutes
  if 0 <= minutesSincePrev < activeWindow:
    label = justStarted (0–9 min) OR current (10–activeWindow min)
    displayPrayer = prevPrayer (the PAST prayer is shown)
    showDhikrButton = true
    progress = minutesSincePrev / activeWindow (0.0 → 1.0)
  else:
    label = upcoming
    displayPrayer = nextPrayer (the FUTURE prayer is shown)
    showDhikrButton = false
    progress = elapsedSeconds / totalSeconds (0.0 → 1.0, based on interval)
```

**Key:** When in the active window, the card shows the PREVIOUS prayer (the one just prayed). When upcoming, it shows the NEXT prayer. The card ALWAYS shows exactly one prayer.

---

## 7 · Real Countdown Lifecycle

### Upcoming State (most common):

`timeLeft` = `H:MM:SS` formatted Arabic-Indic (`١:١٤:٣٢`)  
`timeLeftEn` = `Hh MMm SSs` English  

The timer counts DOWN to the next prayer. Progress bar fills from 0 (just after previous prayer) to 1 (at adhan time).

### Active Window States:

`justStarted` (0–9 min after adhan):
- `timeLeft` = Arabic text: `"الآن"` (static, not ticking)
- `timeLeftEn` = `"Now"` (static)
- Progress bar: `minutesSincePrev / activeWindow` (fills up, showing time consumed)

`current` (10–activeWindow min):
- `timeLeft` = `"منذ X د"` Arabic (elapsed minutes, ticking every ~60s when minutes increment)
- `timeLeftEn` = `"Xm ago"` English
- Progress bar continues filling

### No Pulse, No "ALLAHU AKBAR"

The current implementation has **no** pulse animation when countdown < 60s.  
The current implementation has **no** adhan-moment state (no "ALLAHU AKBAR" text).  
These are SPEC ADDITIONS, not existing behaviors.

---

## 8 · Current Emotional Interaction Model

The current card communicates prayer time in a **calm, information-dense, always-visible** manner:

1. **Glanceable context:** Date and city at top — time-and-place grounding
2. **Prayer identity:** Large prayer name (26sp bold) — you know immediately what prayer
3. **Prayer time:** Large time display (26sp) — quick clock-style read
4. **Status:** Small colored label — "upcoming" / "now" / "elapsed"
5. **Progress:** Bar + countdown — shows where you are in the prayer interval
6. **Action:** Contextual dhikr shortcut — available ONLY when spiritually appropriate

The emotional tone is: **calm awareness, not urgency**. The user is informed, not pressured. The countdown being small reinforces this — it's there if you want to check it, but it doesn't dominate.

The card's full-tap destination (`PrayerDetailsPage`) is the "learn more / see all prayers" escape hatch. This keeps the card compact while offering depth on demand.

---

## 9 · Corrections to PR3_VISUAL_READINESS_REPORT.md

These items in the previous report were based on spec assumptions that differ from real code:

### CORRECTION-1 (CRITICAL): Primary CTA is the full card tap
**Previous report said:** "CTA is the `🤲` emoji button"  
**Real:** The PRIMARY CTA is the `InkWell` on the entire card → `PrayerDetailsPage`. The `🤲` is a SECONDARY contextual action. The card is NOT button-heavy.

**PR3 implication:** Do NOT make the card button-heavy. Do NOT replace the full-card tap. Do NOT add a persistent "Start dhikr" pill if it overshadows the primary navigation CTA.

### CORRECTION-2 (HIGH): Active window is NOT uniformly 40 minutes
**Previous report implied:** "40-minute window" generically  
**Real:** Dynamic calculation per prayer. Fajr=40, Maghrib=20, others=`(interval*0.3).clamp(15,45)`.

**PR3 implication:** Any UI labeling or spec reference to a "40-minute window" is only correct for Fajr.

### CORRECTION-3 (HIGH): Sunset data is already available
**Previous report said:** "Sunset time not in current codebase — needs architecture work"  
**Real:** Maghrib = sunset in Umm al-Qura. Already in `allPrayers`. Zero new architecture needed.

**PR3 implication:** Approval Item A4 (sunset data source) is RESOLVED. Use `allPrayers.firstWhere(type == maghrib).time` as sunset.

### CORRECTION-4 (MEDIUM): Sunrise data is already available
**Previous report said:** "Need to add sunriseTime field"  
**Real:** `PrayerType.sunrise` already in `allPrayers`. Already passed to `NextPrayerCard`.

**PR3 implication:** Sunrise/sunset row requires NO new service fields — just read from `allPrayers` in the card widget.

### CORRECTION-5 (MEDIUM): No Witr badge exists
**Previous report:** Listed "Witr" as a nafl state  
**Real:** No Witr badge exists. Only Duha and Qiyam. The user's request to document "Witr state" confirms there is no current Witr state to document.

### CORRECTION-6 (LOW): Nafl badge colors are hardcoded (not tokens)
Duha: `Colors.orange` / Qiyam: `Colors.indigo` — not design tokens. PR3 should tokenize these if the badges are kept.

---

## 10 · Behavior Preservation Requirements for PR3

The following must be preserved EXACTLY as-is:

| Behavior | Code Location | PR3 Constraint |
|---|---|---|
| Full-card tap → PrayerDetailsPage | `next_prayer_card.dart:111` | MUST NOT change routing |
| `isPrayerEnabled` gate | `smart_prayer_wrapper.dart:30` | MUST NOT remove |
| `isPrayerCardEnabled` gate | `smart_prayer_wrapper.dart:33` | MUST NOT remove |
| `prayerCardDisplayMode` gate | `smart_prayer_wrapper.dart:38–63` | MUST NOT change |
| Dynamic active window | `prayer_timer_service.dart:50–58` | MUST NOT change calculation |
| `justStarted`/`current` dhikr button | `prayer_timer_service.dart:69–83` | MUST NOT change conditions |
| `getOrCreatePostPrayerHabit()` | `habit_cubit.dart:313` | MUST NOT change habit creation logic |
| Duha window (sunrise+15 → dhuhr-15) | `prayer_timer_service.dart:113–123` | MUST NOT change |
| Qiyam window (last-third-of-night) | `prayer_timer_service.dart:126–150` | MUST NOT change |
| Arabic-Indic numerals via `_toArabicNumerals` | `prayer_timer_service.dart:293` | MUST NOT change |
| Midnight crossing in `_calculateTimeline` | `prayer_timer_service.dart:178–213` | MUST NOT change |
| Sunrise excluded from fard timeline | `prayer_cubit.dart:48` | MUST NOT change |
