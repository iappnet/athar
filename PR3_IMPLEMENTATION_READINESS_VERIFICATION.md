# PR3 Implementation Readiness Verification

**Date:** 2026-05-13  
**Type:** Codebase truth audit — no code modified  
**Files inspected:** See PR3_DOMAIN_AND_STATE_AUDIT.md §0 for complete list

---

## 1 · Verification Summary Table

| Subsystem | Status | File | Notes |
|---|---|---|---|
| `isDuhaTime` / `isQiyamTime` logic | ✅ Implemented | `prayer_timer_service.dart:112–150` | Exact per-prayer window calculation. Correct. |
| Nafl badge rendering | ✅ Implemented | `next_prayer_card.dart:129–179` | Orange/indigo pills, conditional. Hardcoded colors (not tokens). |
| Full-card tap → PrayerDetailsPage | ✅ Implemented | `next_prayer_card.dart:110–114` | `InkWell.onTap`. Primary CTA confirmed. |
| `prayerCardDisplayMode` enum | ✅ Implemented | `user_settings.dart:16` | `dashboardOnly` default. |
| `isPrayerEnabled` gate | ✅ Implemented | `smart_prayer_wrapper.dart:30` | SmartPrayerWrapper checks this. |
| `isPrayerCardEnabled` gate | ✅ Implemented | `smart_prayer_wrapper.dart:33` | SmartPrayerWrapper checks this. |
| Dynamic active window | ✅ Implemented | `prayer_timer_service.dart:50–58` | Dynamic %; Fajr=40, Maghrib=20 overrides. |
| Dhikr button (conditional) | ✅ Implemented | `next_prayer_card.dart:401–439` | Shown only when `showDhikrButton == true`. |
| Bilingual prayer names | ✅ Implemented | `prayer_timer_status.dart:14–15` | `prayerNameAr` + `prayerNameEn` fields. |
| Hijri date formatting | ✅ Implemented | `prayer_timer_service.dart:230–247` | Uses hijri package, Arabic + English. |
| `_toArabicNumerals()` | ✅ Implemented | `prayer_timer_service.dart:293–300` | Always applied to Arabic strings. |
| App Group widget service | ✅ Implemented | `widget_data_service.dart` | v6 schema, Home Widget, all keys correct. |
| Nafl flags → iOS widget | ✅ Implemented | `prayer_cubit.dart:117–131` | `isDuhaTime`/`isQiyamTime` pushed via `pushPrayerData`. |
| Animation infrastructure | ✅ Implemented | `athar_animations.dart:283–290` | `createController()` factory exists. |
| `numericMono` token definition | ✅ Implemented | `athar_typography.dart:519–524` | `fontFamily: 'JetBrains Mono'`, tabular figures. |
| `AtharTypography.fontFamilyMono` | ✅ Defined | `athar_typography.dart:30` | `'JetBrains Mono'` |
| **JetBrainsMono font bundle** | ❌ **MISSING** | `pubspec.yaml:135–141` | Only Calibri bundled. JetBrainsMono NOT in assets. System fallback. |
| Countdown format (H:MM:SS colons) | ❌ **MISSING** | `prayer_timer_service.dart:249–258` | Current: `"١س ٥٤د ٣٢ث"` (unit suffixes). Spec: `"01:14:32"` (colons). |
| Hijri/Gregorian split fields | ❌ **MISSING** | `prayer_timer_status.dart` | Only combined `fullDate` / `fullDateEn`. |
| `adhanMoment` label | ❌ **MISSING** | `prayer_timer_status.dart:3–8` | Only 3 values in `PrayerTimerLabel` enum. |
| Compact/expanded state | ❌ **MISSING** | `next_prayer_card.dart` | No `_isExpanded` field. No toggle. |
| App Group key — card variant | ❌ **MISSING** | `widget_data_service.dart:21–81` | No `prayerCardVariant` key in WidgetKeys. |
| Glass overlay | ❌ **MISSING** | `next_prayer_card.dart:94–109` | Plain `BoxDecoration`. No Stack overlay. |
| Center-aligned hero layout | ❌ **MISSING** | `next_prayer_card.dart:182–232` | Side-by-side `Row(spaceBetween)`. |
| 64px countdown display | ❌ **MISSING** | `next_prayer_card.dart:371–382` | 12sp plain text countdown. |
| `.at` prayer time 12px sub-text | ❌ **MISSING** | `next_prayer_card.dart:216–225` | Prayer time is 26sp in side-by-side Row. |
| Sunrise/sunset row | ❌ **MISSING** | `next_prayer_card.dart` | Not rendered. Data available from `widget.allPrayers`. |
| 5-prayer strip | ❌ **MISSING** | `next_prayer_card.dart` | Not implemented. |
| Skeleton loading state | ❌ **MISSING** | `smart_prayer_wrapper.dart` | `CircularProgressIndicator` in 90pt container. |
| Pulse animation (< 60s) | ❌ **MISSING** | `next_prayer_card.dart` | No `AnimationController`. No `SingleTickerProviderStateMixin`. |
| `adhanMoment` "ALLAHU AKBAR" state | ❌ **MISSING** | `next_prayer_card.dart` | No such state or widget. |
| Frosted city pill | ❌ **MISSING** | `next_prayer_card.dart:301–355` | Plain `Text` + `IconButton`. No blur/border. |
| Two-line date header | ❌ **MISSING** | `next_prayer_card.dart:276–285` | Single combined `fullDate` string. |
| BackdropFilter city pill | ❌ **MISSING** | `next_prayer_card.dart` | No blur on city widget. |
| Teal gradient progress fill | ❌ **MISSING** | `next_prayer_card.dart:396` | `AlwaysStoppedAnimation(displayColor)` (state-colored). |
| RTL progress bar fix | ❌ **BUG** | `next_prayer_card.dart:386` | `Directionality(textDirection: ui.TextDirection.rtl)` hardcoded. |
| RTL city padding fix | ❌ **BUG** | `next_prayer_card.dart:316` | `EdgeInsets.only(left: AtharSpacing.xxxs)` — not directional. |
| Permission-denied specific state | ❌ **MISSING** | `smart_prayer_wrapper.dart` | Generic error message shown. |
| Error inline state | ❌ **MISSING** | `smart_prayer_wrapper.dart` | Generic error widget shown. |
| Eastern numerals opt-in toggle | ⚠️ **ALWAYS ON** | `prayer_timer_service.dart:293` | `_toArabicNumerals()` always applied for Arabic. No `isEasternNumeralsEnabled` check. |
| `prayerSunrise` l10n key | ✅ Exists | `app_ar.arb:1451` | `"الشروق"` |
| `prayerLabelUpcoming` l10n key | ✅ Exists | `app_ar.arb:1601` | `"الصلاة القادمة"` |
| `prayerCardDuhaTime` l10n key | ✅ Exists | `app_ar.arb:1597` | Full badge string. |
| `prayerCardQiyamTime` l10n key | ✅ Exists | `app_ar.arb:1598` | Full badge string. |
| `prayerCardSunset` l10n key | ❌ **MISSING** | `app_ar.arb` | No sunset label key. "غروب" must be added. |
| `prayerCardAdhanMoment` l10n key | ❌ **MISSING** | `app_ar.arb` | "الصلاة الآن" / "Pray now" keys missing. |
| Accessibility semantics | ⚠️ **ABSENT** | `next_prayer_card.dart` | No `Semantics` widgets. No `excludeSemantics`. |
| Dark mode handling | ✅ Intentionally N/A | `next_prayer_card.dart` | Card is permanently dark (fixed gradient). No dark-mode changes needed. |

---

## 2 · Subsystem Implementation Status

### 2a · Domain Layer

| Component | Status | Required Change |
|---|---|---|
| `PrayerTimerLabel` enum | ⚠️ Partial | Add `adhanMoment` — all switch expressions will break at compile time (good) |
| `PrayerTimerStatus` model | ⚠️ Partial | Add `hijriDate`, `gregorianDate` fields; add countdown H:MM:SS formatted fields OR use raw seconds; all additive only |
| `PrayerTimerService._emitStatus()` | ⚠️ Partial | Add `adhanMoment` detection; change `_formatDuration` to H:MM:SS colons; add split date computation |
| `PrayerTimerService._formatDuration` | ❌ Wrong format | Currently `"1h 54m 32s"` / `"١س ٥٤د ٣٢ث"` — must change to `"01:14:32"` H:MM:SS (breaking but only one consumer) |
| Sunrise/sunset availability | ✅ Available | Read from `widget.allPrayers` in card widget — NO service change needed |

### 2b · UI Layer — `next_prayer_card.dart`

| Section | Status | Change Required |
|---|---|---|
| Surface decoration | ⚠️ Partial | Upgrade shadow to two-shadow; add glass overlay Stack |
| Header date | ❌ Missing | Split `fullDate` → two `Text` widgets |
| Header city | ❌ Missing | Replace plain Text with frosted pill (`ClipRRect` + `BackdropFilter` + border) |
| City padding | ❌ Bug | Fix `EdgeInsets.only(left:)` |
| Hero layout | ❌ Missing | Restructure side-by-side Row → centered Column |
| Countdown | ❌ Missing | Add `RichText` with 64px H:MM + 34px :SS |
| Prayer time `.at` | ❌ Missing | Add 12px `Text` below prayer name in hero column |
| State label | ⚠️ Needs change | Currently state-dependent text; PR3 may use static "Next prayer" label |
| Nafl badge position | ⚠️ Needs review | Currently between header and status row; new layout disrupts natural position |
| Sunrise/sunset row | ❌ Missing | New `Row` widget reading from `widget.allPrayers` |
| Progress bar height | ❌ Wrong | 6pt → 5pt |
| Progress bar fill | ❌ Wrong | State-color → teal gradient with `ShaderMask` |
| Progress bar RTL | ❌ Bug | Hardcoded RTL → locale-aware `Transform.scale` |
| Dhikr button | ⚠️ Position | Move from progress Row to new position in vertical layout |
| Compact/expanded toggle | ❌ Missing | Add `_isExpanded`, persist via WidgetDataService |
| 5-prayer strip | ❌ Missing | `GridView`/`Row` of 5 chips |
| Pulse animation | ❌ Missing | `AnimationController` + `SingleTickerProviderStateMixin` + reactive to countdown |
| `adhanMoment` UI | ❌ Missing | Conditional display of "ALLAHU AKBAR" Arabic text |

### 2c · Gate/Wrapper Layer — `smart_prayer_wrapper.dart`

| Feature | Status | Change Required |
|---|---|---|
| `isPrayerEnabled` gate | ✅ Correct | No change |
| `isPrayerCardEnabled` gate | ✅ Correct | No change |
| `prayerCardDisplayMode` gate | ✅ Correct | No change |
| Loading skeleton | ❌ Missing | Replace `CircularProgressIndicator` with skeleton |
| Error inline state | ❌ Missing | Upgrade to ErrorState.inline |
| Permission-denied specific text | ❌ Missing | Add location-specific message |

### 2d · Widget Service Layer

| Feature | Status | Change Required |
|---|---|---|
| Prayer data push (all 6+ fields) | ✅ Correct | No change |
| `isDuhaTime`/`isQiyamTime` to widget | ✅ Correct | No change |
| `prayerCardVariant` key (compact/expanded) | ❌ Missing | Add new WidgetKeys constant for variant |
| Compact/expanded mirror to App Group | ❌ Missing | Call from `_NextPrayerCardState` on toggle |

---

## 3 · Countdown Format — Critical Finding

**Current Arabic format** (in-app): `"١س ٥٤د ٣٢ث"` (space-separated with Arabic unit labels س/د/ث)  
**Current English format** (in-app): `"1h 54m 32s"` (space-separated with unit suffixes h/m/s)  
**Spec/HTML target format**: `"01:14:32"` (colon-separated H:MM:SS, zero-padded, `var(--font-mono)`)  

**This is a format-breaking change in `PrayerTimerService._formatDuration()`.**

Consumers of `status.timeLeft` / `status.timeLeftEn`:
1. `next_prayer_card.dart:374` — the only in-app consumer
2. iOS widget uses `WidgetKeys.remainingSeconds` (int) — NOT `status.timeLeft`

Since iOS widget does NOT consume `status.timeLeft`, changing `_formatDuration()` to H:MM:SS only affects `next_prayer_card.dart`. **Safe to change.**

**New format required:**
```dart
// Must change _formatDuration output to:
// "$h:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}"
// e.g. "1:14:32" (no leading zero on hours)
// For RichText split: return H:MM portion and :SS portion separately
```

**Additional consideration:** The `timeLeft` string needs to split at the seconds boundary for the `RichText` with 64px + 34px sub-style. The service should provide both a full string AND separate parts, OR the widget should parse the string.

**Recommendation:** Add `secondsRemaining` (int) to `PrayerTimerStatus`. The widget handles formatting internally using `RichText` with the computed parts.

---

## 4 · JetBrainsMono Font — Critical Missing Asset

`AtharTypography.numericMono` references `fontFamily: 'JetBrains Mono'`.  
`pubspec.yaml` declares only:
```yaml
- family: Calibri
  fonts:
    - asset: assets/fonts/calibri-light.ttf
    - asset: assets/fonts/calibri-regular.ttf
    - asset: assets/fonts/calibri-bold.ttf
```

JetBrainsMono is NOT declared. No `.ttf` files exist in `assets/fonts/` for it.

**Runtime behavior:** Flutter silently falls back to the system monospace font (Menlo on iOS, Courier on older systems, system-mono on Android). The countdown will NOT use JetBrainsMono unless the font is bundled.

**Impact:** PR3 countdown at 64px will render in system mono, not JetBrainsMono. This affects digit width, rendering quality, and tabular figure behavior.

**Resolution required:** Either bundle JetBrainsMono TTF + add to pubspec, OR use Calibri for `numericMono` (in line with Package A Decision #1 "sole canonical font"). This is open question Q1 in `QUESTIONS_PR3.md`.

---

## 5 · Localization Gaps

| Key Needed | ARB Status | Notes |
|---|---|---|
| `prayerCardSunset` / `prayerCardSunrise` labels | ⚠️ Partial | `prayerSunrise` exists. `prayerSunset` / "غروب" label missing. |
| `prayerCardAdhanMoment` — "الصلاة الآن" | ❌ Missing | Need Arabic + English |
| `prayerCardPrayNow` — "Pray now" | ❌ Missing | English pair for adhan moment |
| `prayerCardAllahuAkbar` | ❌ Missing | The Arabic text key; should come from designer (see Q3) |
| `prayerCardExpand` / `prayerCardCollapse` | ❌ Missing | Accessibility labels for expand/collapse toggle |
| `prayerCardStartDhikr` | ❌ Missing | If CTA pill is implemented |
| `prayerCardEnableLocation` | ❌ Missing | Permission-denied specific message |

---

## 6 · Implementation Readiness Score

| Dimension | Score | Basis |
|---|---|---|
| Domain model readiness | 65% | Core fields exist; missing adhanMoment + split dates + seconds field |
| UI widget readiness | 20% | Surface, gates, taps exist; hero layout entirely missing |
| Animation infrastructure readiness | 60% | `AtharAnimations` exists; `NextPrayerCard` missing `SingleTickerProviderStateMixin` |
| Font readiness | 50% | Calibri bundled; JetBrainsMono NOT bundled but token defined |
| Localization readiness | 80% | Most prayer keys present; 5 new keys needed |
| Widget service readiness | 85% | All push infrastructure exists; only variant key missing |
| RTL readiness | 40% | 2 known bugs in active card code; rest of system RTL-safe |
| Loading/error state readiness | 20% | Generic states exist; skeleton and specific errors missing |
| **Overall PR3 readiness** | **~47%** | Core infrastructure solid; UI layer requires near-complete rebuild |
