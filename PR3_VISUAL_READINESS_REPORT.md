# PR3 Visual Readiness Report — Prayer Card Refresh

**Date:** 2026-05-09  
**Type:** Pre-implementation audit — NO code changed  
**Auditor:** AI session  
**Branch:** `feat/athar-v2-pr1-tokens-theme`

---

## 0 · Audit Scope

Files read:

| File | Type |
|---|---|
| `handoff_v2-2/PRAYER_CARD_SPEC.md` | Canonical spec |
| `handoff_v2-2/preview/comp-prayer-card.html` | Visual reference |
| `handoff_v2-2/COMPONENT_SPECS.md` | Supporting spec |
| `handoff_v2-2/PACKAGE_A_DECISIONS.md` | Locked decisions |
| `lib/core/design_system/molecules/cards/next_prayer_card.dart` | Current implementation |
| `lib/core/design_system/molecules/cards/smart_prayer_wrapper.dart` | Current gate logic |
| `lib/features/prayer/domain/models/prayer_timer_status.dart` | Current domain model |
| `lib/core/services/prayer_timer_service.dart` | Current timer service |

---

## 1 · Current PrayerCard Architecture

### Widget Tree
```
SmartPrayerCardWrapper (StatelessWidget)
  └── BlocBuilder<SettingsCubit>       ← gate: isPrayerEnabled + isPrayerCardEnabled + displayMode
        └── BlocBuilder<PrayerCubit>   ← state: Loading / Loaded / Error
              └── NextPrayerCard (StatefulWidget)
                    └── StreamBuilder<PrayerTimerStatus>
                          └── PrayerTimerService (@lazySingleton, Timer.periodic 1s)
```

### Current Compact Layout (top to bottom)
1. Header Row — `[calendar icon + date text] [city text + edit icon]`
2. Nafl Badge — conditional orange (Duha) or indigo (Qiyam) pill
3. Status/Time Row — `[status label + prayer name] [prayer time]` (side-by-side spaceBetween)
4. Progress Row — `[countdown text 12sp] [progress bar 6pt] [dhikr emoji button]`

### No Expanded Mode
Compact/expanded toggle does not exist in the current implementation. The card always renders in a single layout.

---

## 2 · Compact / Expanded Implementation Status

| Feature | Current Status |
|---|---|
| Compact mode | ✅ Exists (only mode) |
| Expanded mode | ❌ Not implemented |
| Toggle control (widget-local state) | ❌ Not implemented |
| UserSettings.prayerCardDisplayMode | ✅ Used (controls WHERE card appears, not which variant) |
| App Group UserDefaults variant mirror | ❌ Not implemented |

---

## 3 · Current Hierarchy Behavior

| Layer | Current | Priority |
|---|---|---|
| Date | Text (11sp, white54) — same visual weight as city | Low |
| City | Text (10sp, white54) — same visual weight as date | Low |
| Status label | 12sp, state-colored | Low |
| Prayer name | 26sp bold, white | HIGH |
| Prayer time | 26sp weight-300, white | HIGH (same as name) |
| Countdown | 12sp, white70 | LOW |
| Progress bar | 6pt, state-colored fill | Medium |
| Dhikr emoji | 22sp, conditional | Medium |

**Problem:** Countdown is the spiritually most important element but has the lowest visual weight (12sp). Prayer time and name compete equally at 26sp.

---

## 4 · Current CTA Behavior

- CTA is the `🤲` emoji button
- Only shown when `showDhikrButton = true` (i.e., `label == justStarted || label == current`)
- Tap → `HabitCubit.getOrCreatePostPrayerHabit()` → `DhikrBottomSheet`
- Not a pill button; no text label

---

## 5 · Current Countdown Format

| State | Format | Example |
|---|---|---|
| `upcoming` | `H:MM:SS` Arabic-Indic (via `_toArabicNumerals`) | `١:١٤:٣٢` |
| `justStarted` | `"الآن"` | static |
| `current` | `"منذ X د"` (elapsed minutes) | `"منذ ٧ د"` |
| English upcoming | `H:MM:SS` Latin | `1:14:32` |

No pulse animation. No "ALLAHU AKBAR" moment state. Countdown is 12sp text.

---

## 6 · Current Typography Structure

| Element | Font | Size | Weight | Token |
|---|---|---|---|---|
| Date | inherited (Calibri) | 11sp | regular | `TextStyle` direct |
| City | inherited (Calibri) | 10sp | regular | `TextStyle` direct |
| Status label | inherited | 12sp | regular | `TextStyle` direct |
| Prayer name | inherited | 26sp | bold | `TextStyle` direct |
| Prayer time | inherited | 26sp | w300 | `TextStyle` direct |
| Countdown | inherited | 12sp | regular | `TextStyle` direct |
| Dhikr emoji | system emoji | 22sp | — | `TextStyle` direct |
| Nafl badge | inherited | 11sp | bold | `TextStyle` direct |

No `numericMono` style used anywhere in the card. All sizes are `sp`-raw values, not via `AppText` tokens.

---

## 7 · Current Dark-Mode Rendering

The card uses a fixed gradient (`AtharColors.prayerCardGradient`) that is the same in light and dark modes — intentional for the Islamic green prayer aesthetic. All text colors are `Colors.white*` variants (hardcoded, not theme-aware). This is correct behavior — the card is always dark-background regardless of system theme.

**No dark-mode regression risk** here — the card is intentionally always dark.

---

## 8 · Current RTL Behavior

| Element | RTL Behavior |
|---|---|
| Header Row | `MainAxisAlignment.spaceBetween` — auto-mirrors in RTL ✅ |
| Status/Time Row | Same `MainAxisAlignment.spaceBetween` — mirrors ✅ |
| Progress bar | `Directionality(textDirection: ui.TextDirection.rtl)` — **hardcoded RTL** ❌ BUG |
| Dhikr button | Trailing element in Row — mirrors ✅ |
| City text | `Padding(EdgeInsets.only(left: AtharSpacing.xxxs))` — ❌ RTL BUG (`left` not directional) |
| Prayer name/time | `CrossAxisAlignment.start` in column — mirrors with row ✅ |

**RTL Bug 1:** Progress bar direction is hardcoded RTL. In English (LTR), the bar fills right-to-left (wrong).  
**RTL Bug 2:** City text has `EdgeInsets.only(left:)` — should be `EdgeInsetsDirectional.only(start:)`.

---

## 9 · Current Animation Behavior

| Animation | Current Status |
|---|---|
| Timer tick | 1s stream via `PrayerTimerService.timerStream` ✅ |
| State transition | `setState` rebuild via `StreamBuilder` ✅ |
| Pulse on < 60s | ❌ Not implemented |
| "ALLAHU AKBAR" moment | ❌ Not implemented |
| Expanded/compact toggle animation | ❌ Not implemented (no expanded mode) |

---

## 10 · Current Prayer Notification Coupling

Prayer notifications are managed exclusively by `PrayerNotificationScheduler`. The prayer card does NOT directly trigger or affect notification scheduling. The card reads from `PrayerTimerService` (timer stream) only.

**Safe to modify the card without touching notification logic.** ✅

---

## 11 · Current Athkar Coupling

The `🤲` CTA calls `HabitCubit.getOrCreatePostPrayerHabit()` then opens `DhikrBottomSheet`. This is the only Athkar coupling in the card.

**Dependency chain:**
```
NextPrayerCard._buildProgressRow
  → context.read<HabitCubit>().getOrCreatePostPrayerHabit()
  → DhikrBottomSheet(habit: postPrayerHabit)
```

`HabitCubit` is provided by `MainPage`'s local `BlocProvider`. If the card is used outside `MainPage` (e.g. Tasks page via SmartPrayerWrapper), the `HabitCubit` must be in scope. Verify before PR3 implementation.

---

## 12 · Current vs Target Comparison

### 12a · Surface / Background

| Dimension | Current | Target (spec + HTML) | Delta |
|---|---|---|---|
| Gradient | `AtharColors.prayerCardGradient` (forest→teal) | `#1A6B3C → #0D7377` 135° | Color likely matches; need to verify token values |
| Glass overlay | ❌ None | Radial highlights + `rgba(255,255,255,.10)` linear + inner hairline box-shadow | **MISSING** |
| BackdropFilter | ❌ None | 24pt blur | **MISSING** |
| Radius | `AtharRadii.radiusXxl` (24pt) | 24pt | ✅ Match |
| Padding | `AtharSpacing.lg` × `AtharSpacing.md` (~16×12) | 20pt all sides | Gap (target uses 20pt uniform) |
| Shadow | `0 4 10 rgba(0,0,0,.3)` | `0 18 42 rgba(13,115,119,.32) + 0 4 12 rgba(26,107,60,.18)` | **Weaker than spec** |

### 12b · Header Row

| Element | Current | Target | Delta |
|---|---|---|---|
| Hijri date | Single combined string (e.g. "٣ جمادى الآخرة ١٤٤٦") | **Primary**: Hijri bold 14pt + **Secondary**: Gregorian 11pt below | **Two-line date not implemented** |
| Date position | Start (left in LTR, right in RTL) | Same | ✅ |
| City | Plain text (10sp, white54) + edit icon | Frosted pill (white10 bg, blur 8px, 1px border, SVG pin 11pt) | **Frosted pill not implemented** |
| City tap | → LocationSettingsPage | Same | ✅ |
| Date tap | → CalendarPage | Not specified in spec (may remain) | Likely preserve |
| Location icon | `Icons.edit_location_alt_rounded` | SVG pin glyph | Different icon |

### 12c · Hero / Status Area

| Element | Current | Target | Delta |
|---|---|---|---|
| Layout direction | Side-by-side Row (name left, time right) | **Center-aligned vertical stack** | **LAYOUT RESTRUCTURE** |
| Label | "الصلاة القادمة" / "Next prayer" (12sp, state-colored) | 11pt uppercase 55% white (always) | Changed styling |
| Prayer name | 26sp bold | 22pt bold, centered, Arabic font | Smaller but centered — visual impact higher |
| Prayer time | 26sp w300 (same row as name) | 12pt 70% white, below name | Demoted from hero to sub-text |
| Countdown | **12sp text** (marginal) | **64pt numericMono weight-300** | **RADICAL CHANGE — countdown becomes dominant** |
| Seconds sub-style | None (same size as H:MM) | 34pt / 55% opacity | Spec adds visual hierarchy within countdown |

### 12d · Progress Bar

| Element | Current | Target | Delta |
|---|---|---|---|
| Height | 6pt | 5pt | Minor |
| Background | `Colors.white10` | `rgba(255,255,255,.14)` | Very close |
| Fill color | **State-based** (green/blue/amber) | **Fixed**: `linear-gradient(90deg,#7FE3DA,#fff)` with teal glow | **Semantic change** |
| RTL | Hardcoded `Directionality.rtl` | `transform:scaleX(-1)` in RTL | Fix RTL bug |

### 12e · Sunrise/Sunset Row

| Element | Current | Target | Delta |
|---|---|---|---|
| Sunrise display | ❌ None | Sunrise icon + time (left) | **MISSING** |
| Sunset display | ❌ None | Sunset icon + time (right) | **MISSING** |
| Placement | — | After progress bar, in both compact and expanded | Needs `PrayerTime.sunrise` data |

### 12f · CTA (Dhikr button)

| Element | Current | Target (spec text §2.5) | Target (HTML preview) | Delta |
|---|---|---|---|---|
| Shape | Circle emoji | Pill button (cream bg, forest ink) | **Not shown in HTML** | ⚠️ SPEC CONTRADICTION |
| Label | `🤲` emoji | "Start dhikr" text | Not shown | Unclear |
| Visibility | Conditional (current/justStarted only) | Implied always-visible | Not shown | Unclear |
| Behavior | → DhikrBottomSheet | Same | Same | ✅ |

**⚠️ CONTRADICTION:** PRAYER_CARD_SPEC.md §2 item 5 says "Start dhikr" pill button. The HTML preview (`comp-prayer-card.html`) does NOT render any CTA button in compact or expanded — only the progress bar and sunrise/sunset row. **This is a spec ambiguity that requires designer clarification before implementation.**

### 12g · Expanded Mode (Prayer Strip)

| Element | Current | Target | Delta |
|---|---|---|---|
| 5-prayer strip | ❌ Not implemented | Grid of 5 chips with past/now/next/future states | **MISSING** |
| Compact/expanded toggle | ❌ Not implemented | Widget-local state tap-to-expand | **MISSING** |
| App Group mirror | ❌ Not implemented | UserDefaults in App Group for iOS widget sync | **MISSING** |

### 12h · Special Prayer States

| State | Current | Target | Delta |
|---|---|---|---|
| Pulse < 60s | ❌ None | Opacity 1.0 → 0.85 oscillation, 1s | **MISSING** |
| "ALLAHU AKBAR" moment (±2 min of adhan) | ❌ None | Time replaced by "ALLAHU AKBAR" (titleM, cream) | **MISSING** |
| "Pray now" sub-text | ❌ None | Replaces countdown line in adhan-moment state | **MISSING** |

### 12i · Loading State

| Aspect | Current | Target | Delta |
|---|---|---|---|
| Loading indicator | `CircularProgressIndicator` (in SmartPrayerWrapper) | Skeleton: gray gradient, no text, same card shape | Different |
| Loading height | 90pt container | Same card footprint as loaded state | Different |

---

## 13 · Removed / Replaced Behaviors Table

| # | What Changes | Why | Replaces | Parity | Muscle Memory | Approval Required |
|---|---|---|---|---|---|---|
| R1 | Side-by-side [name+time] row → centered hero | Spec: countdown is the spiritual anchor, not time | Prayer name + time move to vertical center | Parity: both still shown | **BREAKS** — users expect time on right | YES |
| R2 | 12sp countdown → 64pt countdown | Spec: countdown is the dominant element | Same semantic but 5× larger | ✅ Same info | Low impact | No |
| R3 | State-colored progress fill → fixed teal gradient | Spec: fixed brand color, not status indicator | Dynamic color removed | Partially — users lose state color cue | Moderate | YES |
| R4 | `🤲` emoji CTA → "Start dhikr" pill (IF spec is adopted) | Spec text §2.5 | Emoji → text pill | Same behavior | Low | YES (spec is contradicted by HTML) |
| R5 | Combined date string → two-line Hijri primary + Gregorian secondary | Spec: Hijri date is primary | Redesigned header | ✅ Both dates shown | Low | No |
| R6 | Plain city text + edit icon → frosted glass pill with SVG pin | Spec: premium glassmorphism | Same destination on tap | ✅ Same function | Low | No |
| R7 | No glass overlay → radial highlight + hairline | Spec: glassmorphism surface | Nothing | Additive | None | No |
| R8 | No sunrise/sunset → sunrise/sunset row | Spec: expanded info | Nothing | Additive | None | Data availability (see Risk S1) |
| R9 | No "ALLAHU AKBAR" state → adhan moment state | Spec: emotional peak | No state existed | Additive | Low | YES (tone/voice decision) |
| R10 | No expanded mode → compact/expanded toggle | Spec: user can see all 5 prayers | Nothing | Additive | None | YES (implementation complexity) |
| R11 | RTL `Directionality` hardcoded → locale-aware | Bug fix | Broken RTL fill direction | ✅ Better | Improvement | No |

---

## 14 · Added Behaviors Table

| # | What Gets Added | Risk Level | Data Available |
|---|---|---|---|
| A1 | Glass overlay (radial highlights + hairline) | Low | — |
| A2 | BackdropFilter 24pt blur | Low | — |
| A3 | 64pt numericMono countdown as hero | Low | Timer service already provides H:MM:SS |
| A4 | Seconds in sub-style (34pt, 55% opacity) | Low | Already in H:MM:SS format |
| A5 | Pulse animation when < 60s | Low | Need countdown seconds |
| A6 | "ALLAHU AKBAR" moment state | HIGH | Requires new `PrayerTimerLabel.adhanMoment` |
| A7 | Two-line date (Hijri primary + Gregorian) | Low | `fullDate` already separates — need split |
| A8 | Frosted city pill | Low | — |
| A9 | Sunrise/sunset row with times | MEDIUM | Sunrise exists as `PrayerType.sunrise` in data |
| A10 | 5-prayer strip (expanded mode) | HIGH | All prayers available via `allPrayers` |
| A11 | Compact/expanded toggle with persistence | HIGH | Needs local state + App Group write |
| A12 | Skeleton loading state | Low | Replace CircularProgressIndicator in SmartWrapper |

---

## 15 · Visual Regression Risks

| Risk | Severity | Description |
|---|---|---|
| VR1 | **CRITICAL** | Countdown font change from 12sp → 64pt will completely restructure card height. Dashboard layout must absorb this change without breaking scroll rhythm. |
| VR2 | HIGH | Hero layout restructure (side-by-side → centered) changes user's eye-scan pattern. Prayer time is currently prominent on the right — it moves to a smaller supporting role. |
| VR3 | HIGH | Progress bar fill changes from state-coded color (green=now, blue=elapsed, amber=countdown) to fixed teal. Users lose a visual status cue. |
| VR4 | MEDIUM | Shadow becomes dramatically heavier (`0 18 42` vs `0 4 10`). May feel visually aggressive if cards stack. |
| VR5 | MEDIUM | Nafl badges (Duha/Qiyam) are not present in the HTML spec. If removed, users lose the contextual prayer window awareness. If kept, they need to integrate with the new centered hero layout. |
| VR6 | LOW | Date format change: combined string → two lines. Minor height increase in header. |
| VR7 | LOW | City icon change: `edit_location_alt_rounded` → SVG pin. Minor. |

---

## 16 · Emotional Regression Risks

| Risk | Severity | Description |
|---|---|---|
| ER1 | **CRITICAL** | If the countdown is implemented at 64pt but feels mechanical/counter-like, it can shift the spiritual tone from "awareness of prayer" to "racing against a timer." Must be soft-weight (w300) and calm — not aggressive. |
| ER2 | HIGH | "ALLAHU AKBAR" moment replaces the countdown text. If the font size or weight is wrong, this can feel either too loud (aggressive) or too small (insignificant). This is the spiritually highest-stakes UI text in the entire app. |
| ER3 | HIGH | Removing state-coded fill color (green for "pray now") loses the emotional reinforcement that "prayer has started." The teal gradient fill is aesthetically pleasing but semantically neutral. |
| ER4 | MEDIUM | If the glass overlay effect makes the card feel "techno" or "cold" (like Apple weather), it risks losing the warm Islamic aesthetic of the current gradient-only card. The overlay must stay subtle — not a heavy frosted glass effect. |
| ER5 | MEDIUM | Expanded mode prayer strip must not feel like a calendar schedule or enterprise dashboard. The 5 chips must feel like gentle awareness, not aggressive time-boxing. |

---

## 17 · UX Regression Risks

| Risk | Severity | Description |
|---|---|---|
| UR1 | **CRITICAL** | Dashboard height impact: 64pt countdown is ~96dp taller than current 12sp countdown. Combined with sunrise/sunset row and expanded mode, the card could take 60–70% of the visible dashboard height. This risks pushing task list below the fold. |
| UR2 | HIGH | CTA visibility regression: current CTA only shows during active prayer window. Spec text implies a persistent pill ("Start dhikr") in compact. If always-visible, the CTA may interrupt the countdown experience. If conditional, it's the same as now. **Needs spec clarification.** |
| UR3 | HIGH | The prayer time ("17:42") is currently the MOST prominent number. After redesign, it becomes a 12pt subordinate. Users who use the card as a quick-glance clock for prayer time will need to re-learn the hierarchy. |
| UR4 | MEDIUM | Compact/expanded toggle: if the trigger area is too small (e.g., only the card title), users won't discover expanded mode. Toggle affordance needs to be obvious. |
| UR5 | MEDIUM | Sunrise/sunset data: `PrayerType.sunrise` exists in domain entities. But does the service always include it? If sunrise is missing, the row must not crash or show empty. |
| UR6 | LOW | Expanded mode order in RTL: strip must reverse (Isha left → Fajr right). Spec confirms this. |

---

## 18 · Feature Parity Analysis

| Feature | Current | Target | Verdict |
|---|---|---|---|
| Live countdown | ✅ 1s tick | ✅ 1s tick | ✅ Preserve |
| Prayer name (AR + EN) | ✅ Bilingual | ✅ Bilingual | ✅ Preserve |
| Date display | ✅ Combined string | Hijri primary + Gregorian secondary | Change |
| City display | ✅ Tappable | ✅ Tappable (frosted pill) | Upgrade |
| Progress bar | ✅ | ✅ (color change) | Change |
| Dhikr CTA | ✅ Conditional emoji | Pill (spec) / Absent (HTML) | Clarify |
| Nafl badges | ✅ Duha + Qiyam | Not in spec/HTML | ⚠️ Decision required |
| Error state | ✅ | `ErrorState.inline` row | Upgrade |
| Loading state | ✅ Spinner | Skeleton | Change |
| Disabled gate | ✅ `isPrayerEnabled` | ✅ Same | ✅ Preserve |
| Display mode gate | ✅ `prayerCardDisplayMode` | ✅ Same | ✅ Preserve |
| Compact/expanded | ❌ | Widget-local state | Add |
| 5-prayer strip | ❌ | Expanded only | Add |
| Sunrise/sunset row | ❌ | Compact + Expanded | Add |
| Pulse animation | ❌ | < 60s | Add |
| "ALLAHU AKBAR" state | ❌ | ±2 min of adhan | Add |
| iOS widget variant sync | ❌ | App Group UserDefaults | Add |

---

## 19 · Dashboard Density Analysis

Current card approximate height breakdown:
- Header row: ~24pt
- Status/time row: ~36pt
- Progress row (with countdown): ~28pt
- **Total compact: ~88–96pt** (including padding)

Target card approximate height (compact):
- Header row (with 2-line date): ~44pt
- Hero section (64pt countdown + label + name + time): ~130pt
- Sunrise/sunset row: ~24pt
- Progress bar: ~16pt
- **Total compact estimate: ~214–230pt**

**Dashboard density impact: +120–140pt (130–150% increase in card height)**

This is significant. The dashboard's visible area without scroll is ~700pt (812pt minus nav bar ~70pt, status bar ~44pt). If the prayer card occupies 230pt, it consumes 33% of visible height. Combined with the "Today's Tasks" section header and a few task rows, the user may need to scroll immediately. **This must be addressed in the implementation plan — the 64pt countdown is the dominant driver of height.**

---

## 20 · Component Reuse Safety Analysis

| Component | Reuse Safe | Notes |
|---|---|---|
| `PrayerTimerService` | ✅ Yes | No changes needed for compact mode |
| `PrayerTimerStatus` domain model | ⚠️ Partial | Need new field for `adhanMoment` state OR extend `PrayerTimerLabel` enum |
| `SmartPrayerCardWrapper` | ✅ Yes | Gate logic unchanged |
| `AtharColors.prayerCardGradient` | ✅ Yes | Token already correct |
| `AtharRadii.radiusXxl` | ✅ Yes | 24pt matches spec |
| `HabitCubit` Athkar dependency | ⚠️ Risk | Must be in scope on all pages where card appears |
| `DhikrBottomSheet` | ✅ Yes | Reused as-is |

---

## 21 · Design Contradiction Analysis

### CONTRADICTION-1 (HIGH): CTA Button
- `PRAYER_CARD_SPEC.md §2.5`: "Start dhikr" pill button (cream bg, forest ink) — always-visible in compact
- `comp-prayer-card.html`: No CTA button rendered anywhere — neither compact nor expanded
- **Current behavior**: conditional emoji button (only shows in active prayer window)
- **Resolution required from designer before implementation**

### CONTRADICTION-2 (MEDIUM): Nafl Badges
- `PRAYER_CARD_SPEC.md`: No mention of Duha/Qiyam badges on the prayer card
- `IOS_WIDGETS_SPEC.md`: Has nafl badges
- **Current**: Duha (orange) and Qiyam (indigo) badges appear on the card
- **Resolution required**: Do nafl badges stay on the in-app card or move to widget-only?

### CONTRADICTION-3 (LOW): Date Format
- Spec says "Hijri date primary + Gregorian secondary (or reversed per `isHijriMode`)"
- Current: single combined string from `status.fullDate` — Hijri and Gregorian in one line
- `PrayerTimerStatus` does not split the two dates into separate fields
- **Resolution**: `PrayerTimerService._getFormattedDate()` must emit separate Hijri and Gregorian strings, OR `PrayerTimerStatus` must gain two new fields

---

## 22 · Spec Ambiguity Analysis

| Ambiguity | Spec Text | HTML Preview | Risk |
|---|---|---|---|
| AM1 | CTA is always a pill ("Start dhikr") | No CTA visible | HIGH — changes card always-on vs conditional |
| AM2 | "Sunrise/Sunset arc" (§3) calls it a half-circle SVG with sun glyph | HTML shows just text with SVG sunrise/sunset icons — no arc | MEDIUM — arc is complex; HTML is simpler |
| AM3 | Compact has sunrise/sunset (§2 lists it at step 4 of compact) | HTML compact does show sunrise/sunset row | LOW — both say yes |
| AM4 | "Compact/expanded is widget-local state" but persistence method not specified | — | MEDIUM — widget-local vs SharedPreferences vs App Group |
| AM5 | §6 says "iOS widget renders the same variant the user last selected" via App Group | — | HIGH — requires App Group write when toggle changes |

---

## 23 · Validated Locked Decisions

| Decision | Locked | Current Status | PR3 Status |
|---|---|---|---|
| Prayer CTA must never disappear | ⚠️ See contradiction above | Conditional emoji CTA | Needs clarification |
| Opt-in adhan only | ✅ Locked in notification scheduler | Not affected by PR3 | ✅ Safe |
| Unified countdown format H:MM:SS | ✅ Locked | ✅ Implemented | Preserve + upgrade to 64pt |
| No forced Dhikr behavior | ✅ Locked | ✅ Dhikr button is optional tap | ✅ Safe |
| Universal-by-default experience | ✅ Locked | ✅ Prayer features gate correctly | ✅ Safe |
| Emotional calmness | ✅ Locked | ✅ Calm design | Risk ER1–ER4 |
| No enterprise-heavy density | ✅ Locked | ✅ Current is low-density | Risk UR1 (height) |
| No aggressive gradients/glows | ✅ Locked | ✅ | Risk: teal glow on progress bar fill |
| No hierarchy regression | Partially violated | Countdown at 12sp is under-weighted | PR3 fixes this |
| No spiritual-tone degradation | ✅ Locked | ✅ | Risk ER1–ER4 |
| No generic productivity aesthetics | ✅ Locked | ✅ | Risk: 5-prayer strip chip row |
| isPrayerEnabled master gate | ✅ Locked | ✅ via SmartPrayerWrapper | ✅ Preserve |
| isPrayerCardEnabled gate | ✅ Locked | ✅ via SmartPrayerWrapper | ✅ Preserve |

---

## 24 · Architecture Risks

| Risk | Description | Mitigation |
|---|---|---|
| AR1 | `PrayerTimerStatus` is a plain class. Adding `adhanMoment` state requires extending `PrayerTimerLabel` enum (breaking change to all switch exhaustiveness checks) | Add `adhanMoment` to enum carefully; check all switch expressions in codebase |
| AR2 | `PrayerTimerService._getFormattedDate()` emits a combined date string. Splitting to two fields requires a service change that affects all consumers of `PrayerTimerStatus.fullDate` | Add new fields (`hijriDate`, `gregorianDate`) alongside `fullDate` — don't remove `fullDate` |
| AR3 | App Group write for compact/expanded variant adds a dependency on `widget_data_service.dart` from the UI layer | Accept: same pattern as existing widget sync |
| AR4 | `HabitCubit` read in `NextPrayerCard._buildProgressRow` — card is used across 4 pages. Verify `HabitCubit` is in scope on Tasks page (it's provided by `MainPage`'s local BlocProvider ✅) | Check all SmartPrayerWrapper usage sites |
| AR5 | Sunrise/sunset times: `PrayerType.sunrise` exists in `PrayerTime` domain model. But `PrayerTimerService` excludes sunrise from the `fard` timeline. Need to surface sunrise time separately | Add `sunriseTime` and `sunsetTime` (computed or passed) to `PrayerTimerStatus` |

---

## 25 · Missing Data / Edge Cases

| Edge Case | Current Handling | Risk |
|---|---|---|
| No sunrise data | Would crash `_getFirstPrayer(PrayerType.sunrise)` (try-catch exists ✅) | Safe |
| No sunset data | `PrayerTimerService` doesn't compute sunset at all | Spec requires sunset time — needs data |
| Midnight crossing (Isha → Fajr) | Handled in `_calculateTimeline` with day offset | ✅ |
| Adhan moment (±2 min) | No state — `justStarted` covers 0–10min window | Need new state or threshold |
| Empty prayers list | `SizedBox.shrink()` in `NextPrayerCard.build` | ✅ |
| Permission denied (location) | `PrayerError` state exists but shows generic error message | Should show specific "Enable location" text per spec |
| Network error with cached data | Not distinguished from fresh error | Spec: "cached times shown with ErrorState.inline" — needs distinction |

---

## 26 · Summary

### What Exists Today (Preserved)
- Green gradient background (token-based)
- Live countdown stream (1s tick)
- Prayer name + time display (bilingual)
- Date + city header (tappable)
- Progress bar with timing
- Dhikr CTA (conditional, emoji)
- Nafl badges (Duha/Qiyam)
- All loading/error/disabled states
- All display-mode gating

### What Gets Added (New)
- Glass overlay (radial highlights + hairlines)
- 64pt numericMono countdown as dominant hero element
- Two-line date (Hijri primary + Gregorian)
- Frosted glass city pill with SVG pin
- Sunrise/sunset row
- Pulse animation < 60s
- "ALLAHU AKBAR" adhan moment state
- Compact/expanded toggle
- 5-prayer strip (expanded)
- Skeleton loading state

### What Changes (Careful)
- Hero layout: side-by-side → center-aligned vertical stack
- Progress bar fill: dynamic state color → fixed teal gradient
- CTA: emoji circle → pill (PENDING designer clarification)
- Date: combined string → two-line hierarchy

### What Is Ambiguous (Needs Clarification)
- CTA: always-visible pill vs conditional emoji (spec vs HTML)
- Nafl badges: keep on card or move to widget-only
- Sunset time: data source (not in current service)
- "Sunrise/Sunset arc": full SVG arc or simple text row
