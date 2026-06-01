# PR3 Reuse and Migration Matrix

**Date:** 2026-05-13  
**Type:** Component-level reuse and migration assessment  
**Format:** For every component: current state → PR3 target → classification → risk

---

## Classification Legend

| Tag | Meaning |
|---|---|
| `REUSE` | Can be used as-is; zero changes needed |
| `EXTEND` | Additive change only; no breaking modifications |
| `MIGRATE` | Breaking change required; existing consumers affected |
| `REBUILD` | Near-complete rewrite of the component |
| `NEW` | Does not exist; must be created from scratch |
| `DELETE` | Must be removed; replacement provided |
| `DEFER` | Out of PR3 scope; do not touch |

---

## Section 1 — Domain Layer

### 1.1 · `PrayerTimerLabel` enum

| Dimension | Detail |
|---|---|
| **File** | `lib/features/prayer/domain/models/prayer_timer_status.dart` |
| **Current** | 3 values: `upcoming`, `justStarted`, `current` |
| **PR3 target** | 4 values: add `adhanMoment` between `upcoming` and `justStarted` |
| **Classification** | `MIGRATE` |
| **What changes** | Add one enum value |
| **Breaking impact** | ALL switch expressions on this enum will fail to compile (no default case). This is intentional — compile-time exhaustiveness enforcement catches all consumers. |
| **Switch consumers** | `next_prayer_card.dart:182`, `next_prayer_card.dart:230`, `next_prayer_card.dart:359`, `prayer_timer_service.dart` (internal) |
| **Migration strategy** | Add `adhanMoment` → compile → fix all switch breaks → one commit |
| **Do NOT change** | Existing 3 values, their string representations, any serialized usage |
| **Blocked on** | Q3 (adhanMoment boundary + Arabic text) |

---

### 1.2 · `PrayerTimerStatus` model

| Dimension | Detail |
|---|---|
| **File** | `lib/features/prayer/domain/models/prayer_timer_status.dart` |
| **Current** | 14 fields (see Domain Audit §2) |
| **PR3 target** | Add: `hijriDate`, `gregorianDate`, `secondsRemaining`, optionally `sunriseTime`/`sunsetTime` |
| **Classification** | `EXTEND` |
| **What changes** | Add new nullable fields; all existing fields remain unchanged |
| **Breaking impact** | None — additive only. All existing consumers still compile. |
| **Constructor** | Add named parameters with defaults or make nullable |
| **Do NOT remove** | `fullDate`, `fullDateEn` (may be used outside of next_prayer_card) |
| **Blocked on** | Nothing (purely additive) |

---

### 1.3 · `PrayerTimerService`

| Dimension | Detail |
|---|---|
| **File** | `lib/core/services/prayer_timer_service.dart` |
| **Current** | `@lazySingleton`, 1s timer, full state machine (301 lines) |
| **PR3 target** | Change `_formatDuration`, add split date fields, add `adhanMoment` detection, add `secondsRemaining` |
| **Classification** | `MIGRATE` |
| **Safe changes** | `_formatDuration` format change (only one consumer: `next_prayer_card.dart:374`). iOS widget uses int `remainingSeconds`, not the string. |
| **Risky changes** | Adding `adhanMoment` state changes the timer's 1s emission. Must not disturb `justStarted`/`current` transitions. |
| **What must NOT change** | `_calculateTimeline()` midnight crossing logic; Duha/Qiyam calculations; active window % calculation; `_toArabicNumerals()` application |
| **Migration strategy** | 1. Change `_formatDuration` to H:MM:SS (safest, isolated). 2. Add `secondsRemaining` to status. 3. Add split date fields. 4. Add `adhanMoment` detection (blocked on Q3). |
| **Blocked on** | Q3 for `adhanMoment` specifically; rest is unblocked |

---

### 1.4 · `PrayerCubit`

| Dimension | Detail |
|---|---|
| **File** | `lib/features/prayer/presentation/cubit/prayer_cubit.dart` |
| **Current** | `@injectable`, loads prayer times, pushes to widget, auto-refresh 1min |
| **PR3 target** | No changes needed |
| **Classification** | `REUSE` |
| **Notes** | The cubit correctly mirrors nafl flags to WidgetDataService. `prayersForProgress` sunrise exclusion is correct. Do NOT touch. |

---

### 1.5 · `UserSettings`

| Dimension | Detail |
|---|---|
| **File** | `lib/features/settings/data/models/user_settings.dart` |
| **Current** | All 4 prayer feature flags present; `prayerCardDisplayMode` present |
| **PR3 target** | No changes needed |
| **Classification** | `REUSE` |
| **Notes** | `isEasternNumeralsEnabled` addition deferred to PR-SETTINGS. Do not add in PR3. |

---

### 1.6 · `WidgetDataService`

| Dimension | Detail |
|---|---|
| **File** | `lib/core/services/widget_data_service.dart` |
| **Current** | v6 schema; `isDuhaTime`, `isQiyamTime` keys exist; no `prayerCardVariant` |
| **PR3 target** | Add `prayerCardVariant` key to `WidgetKeys`; add push method |
| **Classification** | `EXTEND` |
| **CRITICAL RULE** | The new key string `'athar_prayer_card_variant'` must be finalized before first production build. It can NEVER be renamed after deployed. |
| **Blocked on** | A6 (compact/expanded toggle approval) |

---

## Section 2 — UI Layer

### 2.1 · `next_prayer_card.dart` — full widget

| Dimension | Detail |
|---|---|
| **File** | `lib/core/design_system/molecules/cards/next_prayer_card.dart` |
| **Current** | `StatefulWidget`, 445 lines, side-by-side Row layout |
| **PR3 target** | Centered Column hero layout, 64px countdown, glass surface, all new elements |
| **Classification** | `REBUILD` |
| **Justification** | The hero layout restructure (Row → Column), countdown size change (12sp → 64px), and surface glass treatment are not line-edits. The widget's overall structure changes fundamentally. |
| **What CAN be reused** | `InkWell.onTap → PrayerDetailsPage` (line 110–114, verbatim). `_buildNaflBadge` logic. `_buildProgressRow` partial. Dhikr button gesture logic. |
| **What must NOT change** | Full-card InkWell navigation. `isPrayerEnabled`/`isPrayerCardEnabled` gate in `SmartPrayerWrapper`. Dhikr button conditional on `showDhikrButton`. |
| **Migration strategy** | Phase-by-phase rebuild per PR3 implementation plan. Each phase ships independently via feature flags or branch isolation. |

---

### 2.2 · Card surface decoration

| Dimension | Detail |
|---|---|
| **Current** | `BoxDecoration` with single shadow `(0, 8, 24, black12)` and `BorderRadius.circular(20)` |
| **PR3 target** | Two-shadow system: teal shadow + forest shadow (exact HTML values). Stack with `IgnorePointer` gradient containers for glass. |
| **Classification** | `MIGRATE` |
| **What changes** | Shadow values, add Stack wrapping, add 2 gradient overlay layers |
| **What stays** | `AtharColors.prayerCardGradient` background. `BorderRadius.circular(20)`. |
| **BackdropFilter** | NOT on card. Only on city pill. |

---

### 2.3 · Header: date display

| Dimension | Detail |
|---|---|
| **Current** | Single `Text(status.fullDate)` — combined Hijri+Gregorian string |
| **PR3 target** | Two `Text` widgets: `hijriDate` (14px bold, white) + `gregorianDate` (11px w400, white60) |
| **Classification** | `MIGRATE` |
| **Dependency** | Requires `hijriDate` + `gregorianDate` fields in `PrayerTimerStatus` (Domain §2) |
| **Source** | L1 (Arabic): Hijri primary; L2 (English): Gregorian primary — swap order based on locale |
| **Do NOT remove** | `fullDate` from model (used elsewhere) |

---

### 2.4 · Header: city pill

| Dimension | Detail |
|---|---|
| **Current** | Plain `Text(cityName)` + `IconButton(edit)` |
| **PR3 target** | `ClipRRect` → `BackdropFilter(blur 8)` → `Container(border, gradient)` → Row(pin icon, city name) |
| **Classification** | `REBUILD` (the city widget, not the full card) |
| **RTL bug** | Current `EdgeInsets.only(left: AtharSpacing.xxxs)` must change to `EdgeInsetsDirectional.only(start:)` |
| **BackdropFilter** | Required HERE (city pill only) — confirmed by HTML `backdrop-filter: blur(8px)` on `.loc` |

---

### 2.5 · Hero section (label + name + countdown)

| Dimension | Detail |
|---|---|
| **Current** | `Row(mainAxisAlignment: spaceBetween)` — prayer name left, prayer time right, 26sp both |
| **PR3 target** | Centered `Column`: label (11px w600) → name (22px bold) → prayer time (12px w400, white70, if compact) → countdown `RichText` (64px H:MM + 34px :SS) |
| **Classification** | `REBUILD` |
| **RichText split** | `secondsRemaining` int from `PrayerTimerStatus` → widget computes `h`, `m`, `s` → formats `H:MM` + `:SS` inline |
| **Prayer time in expanded** | ABSENT when `_isExpanded == true`. Conditional rendering: `if (!_isExpanded) Text(...)` |
| **Countdown font** | `AtharTypography.numericMono` — subject to Q1 (JetBrainsMono vs Calibri) |

---

### 2.6 · Countdown size token

| Dimension | Detail |
|---|---|
| **Current** | No 64px size token in `AtharTypography` |
| **PR3 target** | Add `sizeDisplay64 = 64.0` to `AtharTypography` |
| **Classification** | `EXTEND` (additive to typography tokens) |
| **Notes** | `sizeDisplayXxl = 56.0` exists but 64px is distinct per HTML spec |

---

### 2.7 · Sunrise/sunset row

| Dimension | Detail |
|---|---|
| **Current** | Not implemented |
| **PR3 target** | `Row(spaceBetween)`: sunrise (sun-up icon, time) ← → sunset (sun-down icon, time) |
| **Classification** | `NEW` |
| **Data source** | `widget.allPrayers.firstWhere(type == sunrise)` and `type == maghrib`. No service change needed. |
| **Present in** | BOTH compact AND expanded (per HTML `.arc` element in both variants) |
| **RTL** | Sunrise and sunset sides must swap in RTL. Use `Directionality.of(context)` to swap. |
| **Null safety** | If sunrise/sunset not found, row must not render (no crash). Guard with null check. |

---

### 2.8 · Progress bar

| Dimension | Detail |
|---|---|
| **Current** | `LinearProgressIndicator` at 6pt, `AlwaysStoppedAnimation(displayColor)` fill, hardcoded RTL `Directionality` |
| **PR3 target** | 5px height, teal→white gradient fill via `ShaderMask`, locale-aware RTL via `Transform.scale(scaleX: isRtl ? -1 : 1)` |
| **Classification** | `MIGRATE` |
| **RTL fix** | Remove hardcoded `Directionality(textDirection: ui.TextDirection.rtl)`. Use `Bidi.isRtlLanguage(locale)` or `Directionality.of(context) == TextDirection.rtl`. |
| **Gradient** | `LinearGradient(colors: [teal, white])` wrapped in `ShaderMask` |

---

### 2.9 · Pulse animation

| Dimension | Detail |
|---|---|
| **Current** | No animation infrastructure in `NextPrayerCard`. No `SingleTickerProviderStateMixin`. |
| **PR3 target** | Add `SingleTickerProviderStateMixin`. Add `AnimationController` (1s duration, repeat). Apply opacity animation to countdown when `secondsRemaining < 60`. |
| **Classification** | `NEW` |
| **Infrastructure** | `AtharAnimations.createController()` factory already exists (used in NavBar). Use this pattern. |
| **Risk** | Must `dispose()` controller in `_NextPrayerCardState.dispose()`. Memory leak if missed. |

---

### 2.10 · adhanMoment UI

| Dimension | Detail |
|---|---|
| **Current** | No "ALLAHU AKBAR" display. No adhan moment state. |
| **PR3 target** | When `status.label == PrayerTimerLabel.adhanMoment`: replace countdown area with Arabic sacred text |
| **Classification** | `NEW` |
| **Blocked on** | Q3 (exact Arabic Unicode, haptic, boundary) |
| **Do NOT implement** | Until Q3 resolved |

---

### 2.11 · Compact/expanded toggle

| Dimension | Detail |
|---|---|
| **Current** | No `_isExpanded` field. No toggle affordance. |
| **PR3 target** | `bool _isExpanded` local state. Toggle trigger TBD (Q8). Persist via `WidgetDataService.prayerCardVariant`. |
| **Classification** | `NEW` |
| **5-prayer strip** | Only visible when `_isExpanded == true`. Read from `widget.allPrayers`. |
| **Hit-test planning** | The full-card `InkWell` and the expand toggle must use `HitTestBehavior` or explicit tap zone separation to avoid conflicts. |
| **Blocked on** | A6 (compact/expanded toggle approval) + Q8 (toggle affordance) |

---

### 2.12 · Nafl badges (Duha / Qiyam)

| Dimension | Detail |
|---|---|
| **Current** | Implemented. Orange (Duha) / indigo (Qiyam) pills. Hardcoded `Colors.orange`/`Colors.indigo` (not design tokens). |
| **PR3 target** | Keep badges. Move to above-hero position in new layout. Tokenize colors. |
| **Classification** | `MIGRATE` (position + token fix) |
| **Blocked on** | A3 (nafl badge placement confirmation) |
| **Token fix needed** | Replace `Colors.orange` with `AtharColors.duha` and `Colors.indigo` with `AtharColors.qiyam` (or equivalent tokens) |

---

## Section 3 — Wrapper/Gate Layer

### 3.1 · `SmartPrayerCardWrapper`

| Dimension | Detail |
|---|---|
| **File** | `lib/core/design_system/molecules/cards/smart_prayer_wrapper.dart` |
| **Current** | Guards `isPrayerEnabled`, `isPrayerCardEnabled`, `prayerCardDisplayMode`. Loading: `CircularProgressIndicator`. Error: generic error widget. |
| **PR3 target** | Replace loading with skeleton shimmer. Upgrade error to `ErrorState.inline`. Add permission-denied specific message. |
| **Classification** | `MIGRATE` |
| **Gate logic** | MUST NOT CHANGE. The four-level gate hierarchy is non-negotiable. |
| **Loading state** | Replace `CircularProgressIndicator` in 90pt container with full-card skeleton shimmer matching card proportions |
| **ErrorState.inline** | Defined in `COMPONENT_SPECS.md §5`: single row, 16×16 glyph, body, retry button |

---

## Section 4 — Localization Layer

### 4.1 · `app_ar.arb` and `app_en.arb`

| Key | Classification | ARB Status |
|---|---|---|
| `prayerCardSunset` / "غروب" | `NEW` | Missing from both files |
| `prayerCardAdhanMoment` | `NEW` | Missing from both files |
| `prayerCardAllahuAkbar` | `NEW` | Missing (Q3 blocked) |
| `prayerCardEnableLocation` | `NEW` | Missing from both files |
| `prayerCardExpand` | `NEW` | Missing from both files |
| `prayerCardCollapse` | `NEW` | Missing from both files |
| All existing prayer keys | `REUSE` | Present and correct |

---

## Section 5 — Asset Layer

### 5.1 · JetBrainsMono font

| Dimension | Detail |
|---|---|
| **Current** | NOT in `pubspec.yaml`. NOT in `assets/fonts/`. |
| **PR3 target** | If Q1 resolves to JetBrainsMono: bundle `.ttf` files + add `pubspec.yaml` family declaration |
| **Classification** | `NEW` (if approved) / `DEFER` (if Calibri wins Q1) |
| **Risk** | If Q1 not resolved before Phase 3 implementation, countdown renders in system monospace |

### 5.2 · Calibri font

| Dimension | Detail |
|---|---|
| **Current** | 3 weights bundled: light, regular, bold |
| **PR3 target** | No change |
| **Classification** | `REUSE` |

---

## Section 6 — Migration Order (Dependency Graph)

```
PHASE 1 — Domain (no UI visible)
  1a. Add secondsRemaining to PrayerTimerStatus
  1b. Add hijriDate + gregorianDate to PrayerTimerStatus
  1c. Change _formatDuration to H:MM:SS
  1d. Add split date computation to PrayerTimerService
  1e. Add missing l10n keys (prayerCardSunset, prayerCardEnableLocation, prayerCardExpand, prayerCardCollapse)
  1f. Add sizeDisplay64 to AtharTypography

PHASE 2 — Surface (visual, no layout change)
  2a. Upgrade card shadow to two-shadow HTML values
  2b. Add Stack + gradient glass overlay layers (NO BackdropFilter on card)
  2c. Upgrade loading state to skeleton shimmer
  2d. Upgrade error state to ErrorState.inline
  2e. Add permission-denied specific text

PHASE 3 — Header (visual, additive)
  3a. Split fullDate → two Text widgets (uses hijriDate + gregorianDate from Phase 1)
  3b. Replace city Text with frosted pill (ClipRRect + BackdropFilter + border)
  3c. Fix city padding RTL bug (EdgeInsetsDirectional)

PHASE 4 — Hero layout (structural)
  4a. Replace Row(spaceBetween) with centered Column
  4b. Add 64px RichText countdown (uses secondsRemaining from Phase 1)
  4c. Add 12px prayer time sub-text below name
  4d. Fix progress bar height 6pt → 5px
  4e. Fix progress bar RTL (locale-aware Transform)
  4f. Add teal gradient fill to progress bar
  4g. Add sunrise/sunset row

PHASE 5 — Animations (additive)
  5a. Add SingleTickerProviderStateMixin
  5b. Add AnimationController
  5c. Add pulse opacity when secondsRemaining < 60

PHASE 6 — Expanded mode (BLOCKED on A6, Q8)
  6a. Add _isExpanded local state
  6b. Add expand toggle affordance
  6c. Add 5-prayer strip
  6d. Add prayerCardVariant to WidgetKeys
  6e. Mirror state to WidgetDataService

PHASE 7 — adhanMoment (BLOCKED on Q3)
  7a. Add adhanMoment to PrayerTimerLabel
  7b. Fix all switch expressions
  7c. Add adhanMoment detection in PrayerTimerService
  7d. Add adhanMoment UI (Arabic sacred text)
  7e. Add l10n keys for adhanMoment
```

---

## Section 7 — Reusability Summary

| Component | Classification | Reuse % | Notes |
|---|---|---|---|
| `PrayerTimerService` state machine | `MIGRATE` | 85% | Format + new fields only |
| `PrayerCubit` | `REUSE` | 100% | No changes |
| `PrayerTimerStatus` model | `EXTEND` | 100% | Additive only |
| `PrayerTimerLabel` enum | `MIGRATE` | 75% | One new value, all consumers break |
| `UserSettings` | `REUSE` | 100% | No changes |
| `WidgetDataService` | `EXTEND` | 95% | One new key |
| Card surface | `MIGRATE` | 70% | Shadow + glass overlay |
| Card header | `REBUILD` | 20% | Two-line date + frosted pill |
| Card hero | `REBUILD` | 10% | Row → Column, 64px countdown |
| Card progress bar | `MIGRATE` | 40% | Height, gradient, RTL fix |
| Card animation | `NEW` | 0% | Does not exist |
| Nafl badges | `MIGRATE` | 80% | Position + token fix |
| SmartPrayerWrapper | `MIGRATE` | 60% | Gate logic preserved; states upgraded |
| Sunrise/sunset row | `NEW` | 0% | Does not exist |
| 5-prayer strip | `NEW` | 0% | Does not exist |
| adhanMoment UI | `NEW` | 0% | Does not exist |

**Overall infrastructure reuse: ~68%**  
**New code required: ~32% of total PR3 scope**
