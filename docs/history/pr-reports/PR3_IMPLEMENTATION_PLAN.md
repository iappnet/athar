# PR3 Implementation Plan — Prayer Card Refresh

**Date:** 2026-05-09  
**Status:** PLANNING ONLY — awaiting approval of PR3_APPROVAL_REQUIRED_ITEMS.md  
**Branch:** `feat/athar-v2-pr1-tokens-theme`  
**Authority:** `PRAYER_CARD_SPEC.md` + `comp-prayer-card.html`

---

## Pre-Implementation Gate

**DO NOT begin Phase 1 until:**
1. All items in `PR3_APPROVAL_REQUIRED_ITEMS.md` are explicitly approved
2. CTA contradiction resolved (pill vs absent)
3. Nafl badge decision confirmed
4. Sunset time data source confirmed

---

## Phase 1 — Domain Model Extension

**Scope:** Extend `PrayerTimerStatus` and `PrayerTimerService` only. No UI changes.

### Step 1.1 — Extend `PrayerTimerLabel` enum

File: `lib/features/prayer/domain/models/prayer_timer_status.dart`

Add `adhanMoment` value:
```dart
enum PrayerTimerLabel {
  upcoming,
  justStarted,
  current,
  adhanMoment,  // NEW: within ±2 min of adhan time
}
```

**Rollback boundary:** All switch expressions on `PrayerTimerLabel` must handle `adhanMoment`. Run `flutter analyze` — exhaustiveness will catch all missing cases.

### Step 1.2 — Add split date fields to `PrayerTimerStatus`

File: `lib/features/prayer/domain/models/prayer_timer_status.dart`

Add fields alongside existing `fullDate`/`fullDateEn` (DO NOT remove existing fields):
```dart
final String hijriDate;     // e.g. "١٥ رجب ١٤٤٦"
final String hijriDateEn;   // e.g. "15 Rajab 1446"
final String gregorianDate;   // e.g. "الأربعاء، 15 يناير 2025"
final String gregorianDateEn; // e.g. "Wed, 15 Jan 2025"
final String? sunriseTime;  // "06:32" or null if unavailable
final String? sunriseTimeEn; // "06:32" or null
// Sunset: determine data source first (see Approval Item A4)
```

### Step 1.3 — Extend `PrayerTimerService` to compute new fields

File: `lib/core/services/prayer_timer_service.dart`

- Add `adhanMoment` detection: `minutesSincePrev >= -2 && minutesSincePrev <= 2`
- Split `_getFormattedDate()` into `_getHijriDate()` + `_getGregorianDate()` (keep existing for backward compat)
- Add `_getSunriseTime()` helper (reads from `_todayPrayers` where type == sunrise)
- Add `_computeTimeLeftEn` parity for adhanMoment state

**Checkpoint CP1:**
- [ ] `flutter analyze`: 0 issues
- [ ] `flutter test`: 29/29
- [ ] All switch expressions on `PrayerTimerLabel` updated
- [ ] No UI changes made

---

## Phase 2 — Surface + Header Refresh

**Scope:** Visual-only changes to `next_prayer_card.dart`. No behavior changes.  
**Rollback:** Revert the file — no domain changes in this phase.

### Step 2.1 — Glass surface

Replace plain `BoxDecoration` with:
```dart
// Same gradient (preserved)
gradient: AtharColors.prayerCardGradient,
// Upgraded shadow (per spec)
boxShadow: [
  BoxShadow(
    color: const Color(0xFF0D7377).withValues(alpha: 0.32),
    blurRadius: 42,
    offset: const Offset(0, 18),
  ),
  BoxShadow(
    color: const Color(0xFF1A6B3C).withValues(alpha: 0.18),
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
],
```

Add glass overlay as `Stack` with `IgnorePointer`:
```dart
Stack(children: [
  // Radial highlight + linear overlay (IgnorePointer)
  // Main content
])
```

Add `ClipRRect` around the card container.  
Add `BackdropFilter(filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24))`.  
Set padding to `EdgeInsetsDirectional.all(20.w)` (was horizontal lg / vertical md).

### Step 2.2 — Header: two-line date + frosted city pill

Replace header Row content:
- Date side: Two `Text` widgets — Hijri primary (14pt bold, white) + Gregorian secondary (11pt, white60)
- City side: `ClipRRect` + `BackdropFilter` frosted pill with SVG-style `Icon` pin (`Icons.location_on_rounded`, 11pt)
- Fix RTL bug: `EdgeInsetsDirectional.only(start: ...)` replaces `EdgeInsets.only(left: ...)`

**Screenshot checkpoint:** Take device screenshot with two-line header visible.

**Checkpoint CP2:**
- [ ] `flutter analyze`: 0 issues
- [ ] `flutter test`: 29/29
- [ ] Glass surface visible on phone
- [ ] Two-line date visible
- [ ] Frosted city pill visible
- [ ] RTL: date right, city left in Arabic ✓
- [ ] LTR: date left, city right in English ✓

---

## Phase 3 — Hero Countdown Restructure

**Scope:** Most impactful visual change. Restructure the status/time area into a center-aligned hero.  
**APPROVAL REQUIRED BEFORE THIS PHASE** — see Approval Item A1.  
**Rollback boundary:** This phase can be reverted independently.

### Step 3.1 — Replace status/time Row with centered hero Column

Replace the current `Row(spaceBetween)` with:
```dart
Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    // Label: "الصلاة القادمة" / "Next prayer"
    Text(labelText, style: /* 11pt, uppercase, white55 */),
    SizedBox(height: 4.h),
    // Prayer name
    Text(prayerName, style: /* 22pt bold, centered */),
    SizedBox(height: 2.h),
    // Prayer time (at HH:MM)
    Text(prayerTime, style: /* 12pt, white70 */),
    SizedBox(height: 10.h),
    // Countdown hero
    _buildCountdownHero(status),
  ],
)
```

### Step 3.2 — 64pt countdown with second sub-style

```dart
Widget _buildCountdownHero(PrayerTimerStatus status) {
  // Split H:MM and :SS for different weights
  final parts = timeLeft.split(':');
  // h:mm part at 64pt, :ss part at 34pt/55%
  return RichText(
    text: TextSpan(
      style: TextStyle(
        fontFamily: AtharTypography.fontFamilyEn, // numericMono
        fontFeatures: [FontFeature.tabularFigures()],
        fontWeight: FontWeight.w300,
        color: Colors.white,
        fontSize: 64.sp,
        letterSpacing: -2,
      ),
      children: [
        TextSpan(text: hmPart),
        TextSpan(
          text: ':$secPart',
          style: TextStyle(fontSize: 34.sp, color: Colors.white.withValues(alpha: 0.55)),
        ),
      ],
    ),
  );
}
```

### Step 3.3 — "ALLAHU AKBAR" moment state

When `status.label == PrayerTimerLabel.adhanMoment`:
```dart
Column(children: [
  Text('ٱللَّٰهُ أَكْبَرُ', style: /* titleM, cream */),
  Text(l10n.prayerNowLabel, style: /* bodyS, white70 */),
])
```

**Screenshot checkpoint:** Countdown visible at 64pt. Confirm no overflow on small screens (iPhone SE 375pt width).

**Checkpoint CP3:**
- [ ] `flutter analyze`: 0 issues
- [ ] `flutter test`: 29/29
- [ ] 64pt countdown renders without overflow on 375pt width
- [ ] "ALLAHU AKBAR" state triggered correctly (manual test: set time to ±2 min of adhan)
- [ ] Prayer name centered ✓
- [ ] Prayer time demoted to 12pt sub-text ✓
- [ ] Dashboard scroll: task list still visible below card ✓

---

## Phase 4 — Progress Bar + Sunrise/Sunset

**Scope:** Progress bar color update + sunrise/sunset row addition.

### Step 4.1 — Progress bar fill update

Replace `AlwaysStoppedAnimation(displayColor)` with:
```dart
gradient: LinearGradient(
  colors: [const Color(0xFF7FE3DA), Colors.white],
),
```
Use `ShaderMask` or custom `LinearProgressIndicator` with gradient.

Fix RTL bug: remove hardcoded `Directionality(rtl)`. Instead:
```dart
final isRTL = Directionality.of(context) == TextDirection.rtl;
Transform.scale(
  scaleX: isRTL ? -1 : 1,
  child: LinearProgressIndicator(...),
)
```

### Step 4.2 — Pulse animation < 60s

Add `AnimationController` (or `AnimatedOpacity`) that activates when countdown < 60s:
```dart
// Pulse: opacity 1.0 → 0.85, repeat, 1s duration
```
Wrap only the countdown `RichText`, not the whole hero.

### Step 4.3 — Sunrise/sunset row

```dart
if (status.sunriseTime != null) ...[
  const SizedBox(height: 16),
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _buildSunEvent(Icons.wb_sunny_outlined, sunriseLabel, status.sunriseTime!),
      _buildSunEvent(Icons.wb_twilight, sunsetLabel, status.sunsetTime ?? '--:--', trailing: true),
    ],
  ),
],
```

**Checkpoint CP4:**
- [ ] `flutter analyze`: 0 issues
- [ ] `flutter test`: 29/29
- [ ] Progress bar fill is teal gradient (not state-colored)
- [ ] RTL: progress bar fills left to right in LTR, right to left in RTL ✓
- [ ] Sunrise/sunset row visible
- [ ] Pulse activates at < 60s ✓
- [ ] No crash if sunriseTime is null ✓

---

## Phase 5 — Compact/Expanded Toggle + 5-Prayer Strip

**Scope:** New widget-local state + 5-prayer chip grid.  
**APPROVAL REQUIRED BEFORE THIS PHASE** — see Approval Item A2.

### Step 5.1 — Add _isExpanded state

Convert `NextPrayerCard` to add:
```dart
bool _isExpanded = false;
```

Add tap-to-toggle affordance (e.g., chevron icon or tap anywhere on card).

### Step 5.2 — Persist to App Group

On toggle: write to `UserDefaults` via `widget_data_service.dart`:
```dart
// Use existing FlutterSecureStorage or MethodChannel pattern
// Key: 'athar_prayer_card_expanded' (add to WidgetKeys)
```

### Step 5.3 — 5-prayer strip

```dart
AnimatedSize(
  duration: AtharAnimations.normal,
  child: _isExpanded
      ? _buildPrayerStrip(allPrayers, currentPrayer)
      : const SizedBox.shrink(),
)

Widget _buildPrayerStrip(List<PrayerTime> prayers, PrayerTime current) {
  final fard = prayers.where((p) => p.type != PrayerType.sunrise).toList();
  return GridView of 5 chips with past/now/next/future states;
}
```

**Checkpoint CP5:**
- [ ] `flutter analyze`: 0 issues
- [ ] `flutter test`: 29/29
- [ ] Expanded mode shows all 5 prayers
- [ ] Past prayers: 45% opacity, strikethrough ✓
- [ ] Next prayer: teal highlight ✓
- [ ] Toggle persists across hot-restart (via App Group key)
- [ ] iOS widget reads variant (if App Group write implemented)
- [ ] RTL: strip reversed in Arabic ✓

---

## Phase 6 — CTA + Loading State + Error State

**Scope:** Replace emoji CTA, upgrade loading to skeleton, upgrade error state.  
**CTA depends on approval of Approval Item A3.**

### Step 6.1 — CTA (pending approval decision)

**IF designer confirms "Start dhikr" pill always-visible:**
```dart
// Below progress bar, always:
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFAF7EC), // cream
    foregroundColor: const Color(0xFF1A6B3C), // forest
    shape: StadiumBorder(),
  ),
  onPressed: _onDhikrTap,
  child: Text(l10n.startDhikr),
)
```

**IF designer confirms conditional (current behavior):**
No change to CTA logic.

### Step 6.2 — Skeleton loading state

In `SmartPrayerCardWrapper` (PrayerLoading / PrayerInitial branch):
```dart
// Shimmer or animated gradient container
// Same height and shape as the loaded card
// No text, no icons
```

### Step 6.3 — Permission denied state

When `PrayerError` contains "location" / "permission":
```dart
// Show: lock icon + "Enable location for accurate prayer times" + Settings button
```

**Checkpoint CP6:**
- [ ] `flutter analyze`: 0 issues
- [ ] `flutter test`: 29/29
- [ ] Skeleton loading state visible (test by disabling mock data)
- [ ] CTA renders per approved decision ✓
- [ ] Permission denied state renders correctly ✓

---

## Phase 7 — RTL Validation + Dark Mode + Final

**Scope:** Full RTL audit, dark mode check, typography validation.

### RTL Validation Checklist
- [ ] All `EdgeInsets.only(left/right)` → `EdgeInsetsDirectional.only(start/end)` in active card code
- [ ] All `Alignment.centerLeft/Right` → `AlignmentDirectional` in card
- [ ] Header: Arabic → date right, city left; English → date left, city right ✓
- [ ] Progress bar fills in correct direction per locale ✓
- [ ] 5-prayer strip reverses in RTL (if expanded implemented) ✓
- [ ] Sunrise left / Sunset right in LTR; reversed in RTL ✓
- [ ] Prayer name right-aligned in RTL ✓

### Typography Validation
- [ ] Countdown uses `numericMono` (tabular figures) ✓
- [ ] Prayer time uses numericMono ✓
- [ ] Hijri date: Calibri/Arabic font, 14pt bold ✓
- [ ] Gregorian date: 11pt ✓
- [ ] Label: 11pt uppercase ✓
- [ ] Prayer name: 22pt bold ✓

### Emotional Design Validation
- [ ] Countdown at 64pt feels calm, not aggressive (visual test)
- [ ] "ALLAHU AKBAR" text is readable and feels reverent (test with product owner)
- [ ] Glass overlay is subtle, not cold/techno
- [ ] Card does not feel cluttered at full height

**Checkpoint CP7 (Final):**
- [ ] `flutter analyze`: 0 issues
- [ ] `flutter test`: 29/29
- [ ] Full RTL audit passed ✓
- [ ] Dashboard scroll: task list accessible without scroll on iPhone 14 Pro ✓
- [ ] Screenshot: compact LTR + compact RTL + expanded LTR + expanded RTL
- [ ] Adhan moment state tested ✓
- [ ] Pulse animation tested ✓
- [ ] All error/loading/disabled states tested ✓

---

## Commit / Tag Strategy

| Phase | Commit Message | Tag |
|---|---|---|
| CP1 | `feat(prayer): PR3 P1 — domain model: adhanMoment + split date + sunrise fields` | — |
| CP2 | `feat(prayer): PR3 P2 — glass surface + header refresh` | — |
| CP3 | `feat(prayer): PR3 P3 — 64pt hero countdown + ALLAHU AKBAR state` | — |
| CP4 | `feat(prayer): PR3 P4 — progress bar gradient + sunrise/sunset + pulse` | — |
| CP5 | `feat(prayer): PR3 P5 — compact/expanded toggle + 5-prayer strip` (IF approved) | — |
| CP6 | `feat(prayer): PR3 P6 — CTA + skeleton loading + permission denied` | — |
| CP7 | `feat(prayer): PR3 complete — full visual readiness` | `athar-v2-pr3-complete` |

---

## Widget Isolation Strategy

- `NextPrayerCard` is isolated from all other features except:
  - `PrayerTimerService` (read-only stream)
  - `HabitCubit` (Dhikr tap only — conditional)
  - `SettingsCubit` (city name only — in header)
- Each phase targets only `next_prayer_card.dart` + domain models
- Phase 1 (domain) is the only phase that touches `prayer_timer_service.dart`

---

## Testing Strategy

| Test Area | Strategy |
|---|---|
| Domain model | Extend existing timer tests for `adhanMoment` state |
| Header RTL | Widget test with Arabic locale |
| Progress bar direction | Widget test: verify fill direction in RTL vs LTR |
| 64pt countdown no overflow | Widget test: constrain to 320pt width (smallest iPhone) |
| Loading skeleton | Widget test: PrayerLoading state |
| Expanded toggle | Widget test: tap → verify strip visible |
| Adhan moment state | Unit test: inject time within ±2 min of adhan |

---

## Rollback Boundaries

| Phase | Rollback Scope |
|---|---|
| Phase 1 | Revert `prayer_timer_status.dart` + `prayer_timer_service.dart`. All UI unchanged. |
| Phase 2 | Revert `next_prayer_card.dart` header + surface changes. Domain unchanged. |
| Phase 3 | Revert hero restructure. Most impactful rollback — do CP2 before CP3. |
| Phase 4 | Revert progress bar + sunrise row. Low risk. |
| Phase 5 | Revert expanded mode. `_isExpanded` state can be removed cleanly. |
| Phase 6 | Revert CTA + loading. Independent of phases 1–5. |
