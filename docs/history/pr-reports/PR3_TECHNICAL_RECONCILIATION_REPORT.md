# PR3 Technical Reconciliation Report

**Date:** 2026-05-13  
**Status:** PRE-IMPLEMENTATION — no Dart code modified  
**Scope:** Full reconciliation of production code, HTML preview, spec text, design decisions, and spiritual UX  
**Precedence rule:** Per PRAYER_CARD_SPEC.md §0: "Visual reference: `preview/comp-prayer-card.html`. This file is the readable spec for Flutter implementation." → **HTML wins where spec text contradicts it.**

---

## 0 · Files Inspected

| File | Authority Level |
|---|---|
| `handoff_v2-2/preview/comp-prayer-card.html` | **PRIMARY** — visual source of truth |
| `handoff_v2-2/PRAYER_CARD_SPEC.md` | Secondary — written spec, HTML overrides on conflict |
| `handoff_v2-2/COMPONENT_SPECS.md` | Supporting — component definitions |
| `handoff_v2-2/PACKAGE_A_DECISIONS.md` | Locked designer decisions |
| `lib/core/design_system/molecules/cards/next_prayer_card.dart` | Production code (lines 1–445 active) |
| `lib/core/design_system/molecules/cards/smart_prayer_wrapper.dart` | Production gate logic |
| `lib/core/services/prayer_timer_service.dart` | Production timer logic |
| `lib/features/prayer/domain/models/prayer_timer_status.dart` | Production domain model |
| `lib/features/prayer/domain/entities/prayer_time.dart` | Prayer entity / adhan adapter |
| `lib/features/prayer/data/repositories/prayer_repository_impl.dart` | Calculation source |
| `lib/features/prayer/presentation/pages/prayer_details_page.dart` | Tap destination |
| `lib/features/habits/presentation/cubit/habit_cubit.dart` | Dhikr habit logic |
| `lib/features/home/presentation/pages/dashboard_page.dart` | Card placement |
| `PR3_BEHAVIORAL_SOURCE_OF_TRUTH.md` | Production behavioral audit |
| `PR3_VISUAL_DENSITY_SIMULATION.md` | Density analysis |

---

## 1 · Authoritative HTML Layout — Exact Structure

### Compact Variant (`div.prayer`, label: "A · Compact — next prayer only · live H:MM:SS countdown")

```
div.prayer {background: gradient #1A6B3C→#0D7377 135°; border-radius: radius-xxl; padding: 20px 22px}
  ::before  {glass radial highlights + linear white film}
  ::after   {inner hairline box-shadow}
  
  div.head
    div.date
      div.h    "١٥ رجب ١٤٤٦"       (14px bold, font-ar)
      div.g    "الأربعاء، 15 يناير 2025" (11px, white60)
    div.loc    "الرياض"             (frosted pill: white10 bg, blur 8px, 1px border)
  
  div.hero   {margin-top: 18px; text-align: center}
    div.lbl  "الصلاة القادمة"      (11px, uppercase, white55, letterSpacing 1.4px)
    div.name "المغرب"              (22px bold, font-ar)
    div.at   "17:42"               (12px, white70, tabular-nums)  ← PRAYER CLOCK TIME
    div.clock "01:14" + span.sm ":32"  (64px weight-300, span: 34px opacity.55)  ← COUNTDOWN H:MM:SS
  
  div.arc    {font-size: 10.5px; white55; space-between}
    "شروق 06:32"  ← Sunrise left
    "غروب 17:38"  ← Sunset right
  
  div.prog   {height: 5px; bg: rgba(255,255,255,.14)}
    div.fill {width: 38%; background: linear-gradient(90deg,#7FE3DA,#fff); glow: 0 0 12px rgba(127,227,218,.6)}
```

> **No CTA button rendered in compact HTML.** The spec text's "Start dhikr" pill (§2 step 5) is absent.

### Expanded Variant (`div.prayer`, label: "B · Expanded — all 5 prayers visible")

```
div.prayer
  div.head      (same as compact)
  
  div.hero      {text-align: center}
    div.lbl     "الصلاة القادمة"
    div.name    "المغرب"
    div.clock   "01:14" + span.sm ":32"  (NO div.at in expanded — prayer time removed)
  
  div.prog      (same as compact)
  
  div.all       {grid 5 columns, gap 6px}
    div.p.past  Fajr, Dhuhr, Asr (opacity 0.45, time struck-through)
    div.p.next  Maghrib (cream/teal highlight)
    div.p       Isha (future, muted)
  
  div.arc       {margin-top: 12px}  ← same sunrise/sunset row, below strip
```

> **Key difference:** expanded removes `.at` (prayer time). Prayer time is now implicit from the "next" chip in the strip. The countdown hero (64px) is still present.

---

## 2 · HTML vs Spec Text Contradictions

These are cases where the written spec text in PRAYER_CARD_SPEC.md disagrees with the HTML. **HTML is the authority.**

### CONFLICT-1 · CRITICAL: Information Hierarchy Is Reversed in Spec Text

| Element | Spec Text §2 | HTML (Authoritative) |
|---|---|---|
| Prayer TIME | "Big time HH:MM, numericMono 56pt, white" — dominant | `div.at` "17:42", 12px white70 — **sub-text** |
| Countdown | "H:MM:SS, numericMono 18pt, white80" — subordinate | `div.clock` 64px weight-300 — **dominant hero** |

**Spec text is WRONG.** The spec text describes a "big prayer time clock" as dominant with countdown subordinate. The HTML shows the OPPOSITE: **countdown is the 64px dominant element; prayer time is the 12px sub-text.**

**Impact on PR3:** All previous planning documents that referenced the "64pt countdown" were reading the HTML correctly. The density simulation is valid at 64px. The implementation plan Phase 3 is correct on this point.

---

### CONFLICT-2 · HIGH: Sunrise/Sunset Placement

| | Spec Text | HTML |
|---|---|---|
| In compact? | ❌ No — listed only in §3 (expanded) | ✅ YES — `div.arc` present in compact HTML |
| In expanded? | ✅ Yes | ✅ Yes |

**HTML wins:** Sunrise/sunset row is in **both compact and expanded**. Implementation plan Phase 4 (which placed sunrise/sunset in compact) was correct.

---

### CONFLICT-3 · HIGH: CTA Button

| | Spec Text | HTML |
|---|---|---|
| Present? | ✅ "Start dhikr" pill, cream bg, forest ink — listed as §2 step 5 | ❌ Absent from both compact and expanded |

**HTML wins:** No CTA pill is rendered. The current conditional `🤲` emoji approach is the closest to the HTML's intent (contextual, not persistent). The spec text's §2 step 5 appears to be a discarded design decision.

---

### CONFLICT-4 · MEDIUM: Progress Bar Fill Color

| | Spec Text | HTML |
|---|---|---|
| Fill | `Colors.cream` | `linear-gradient(90deg,#7FE3DA,#fff)` + teal glow |

**HTML wins:** Teal-to-white gradient with teal glow. The cream fill in spec text is wrong.

---

### CONFLICT-5 · MEDIUM: Shadow Values

| | Spec Text | HTML |
|---|---|---|
| Shadow | `0 12px 28px rgba(0,0,0,0.18)` | `0 18px 42px rgba(13,115,119,.32) + 0 4px 12px rgba(26,107,60,.18)` |

**HTML wins:** Two-shadow system, brand-colored (not neutral black). More expressive than spec text.

---

### CONFLICT-6 · MEDIUM: Sunrise/Sunset Form

| | Spec Text | HTML |
|---|---|---|
| Form | "Half-circle SVG, 100pt wide × 50pt tall; sun glyph travels along arc" | Simple text row with SVG sunrise/sunset icons, no arc, no moving glyph |

**HTML wins:** Simple text row. The SVG arc with animated sun is a discarded concept. Not in scope.

---

### CONFLICT-7 · LOW: Prayer Time in Expanded

| | Spec Text | HTML |
|---|---|---|
| `.at` in expanded? | Implied (as part of time+countdown row in §2) | Absent — expanded removes `.at` entirely |

**HTML wins:** Expanded removes the prayer time sub-text. The 5-prayer strip chip for "next" shows the time anyway.

---

## 3 · Production Code vs HTML Contradictions

These are behaviors in the production Flutter code that differ from the HTML design. These require implementation work in PR3.

### PROD-CONFLICT-1 · CRITICAL: Countdown Visual Weight

| | Production | HTML Target |
|---|---|---|
| Countdown size | 12sp (lowest weight element) | 64px (dominant hero) |
| Countdown position | First child in progress Row (before bar) | `div.hero` — center-aligned, below prayer name |
| Prayer time + name | Side-by-side Row (26sp each) | Vertical stack — name 22px, then time 12px, then countdown 64px |

**Required change:** Complete restructure of status/time area into center-aligned vertical hero.

---

### PROD-CONFLICT-2 · HIGH: Surface Quality

| | Production | HTML Target |
|---|---|---|
| Glass overlay | ❌ None | Radial highlights + linear white film via `::before` pseudo-element |
| Inner hairline | ❌ None | `inset 0 1px 0 rgba(255,255,255,.28)` + bottom/border via `::after` |
| BackdropFilter | ❌ None | `backdrop-filter: blur(8px)` on city pill only (NOT on full card — HTML does not blur the card) |
| Shadow | `0 4 10 rgba(0,0,0,.3)` | Two-shadow brand-colored system |

**Important correction:** The HTML's `backdrop-filter: blur(8px)` applies ONLY to the city pill (`div.loc`), NOT to the full card. The full card surface uses CSS pseudo-elements for the glass effect — NOT backdrop-filter. In Flutter, this means `BackdropFilter` is needed only for the frosted city pill, not for the card container itself.

---

### PROD-CONFLICT-3 · HIGH: Header Structure

| | Production | HTML Target |
|---|---|---|
| Date display | Combined single-line string | Two lines: `.h` (Hijri, 14px bold) + `.g` (Gregorian, 11px white60) |
| City widget | Plain `Text` + edit icon | Frosted pill: `div.loc` (white10 bg, blur 8px, 1px border, SVG pin) |
| City icon | `Icons.edit_location_alt_rounded` | SVG map-pin glyph (pinned circle) |

---

### PROD-CONFLICT-4 · HIGH: Progress Bar

| | Production | HTML Target |
|---|---|---|
| Height | 6pt | 5px |
| Fill | State-colored (green/blue/amber) | Teal→white gradient + `0 0 12px rgba(127,227,218,.6)` glow |
| RTL | Hardcoded `Directionality.rtl` ❌ | `transform: scaleX(-1)` on RTL — locale-aware |

---

### PROD-CONFLICT-5 · MEDIUM: Sunrise/Sunset Row Missing

| | Production | HTML Target |
|---|---|---|
| Row present? | ❌ No | ✅ In both compact and expanded |
| Data available? | ✅ Sunrise: PrayerType.sunrise in allPrayers. Sunset: Maghrib.time | ✅ Use existing data |

Zero new service architecture needed. Read from `allPrayers` in the widget.

---

### PROD-CONFLICT-6 · MEDIUM: Loading/Error States

| | Production | HTML/Spec Target |
|---|---|---|
| Loading | `CircularProgressIndicator` in 90pt container | Skeleton gradient, same footprint as loaded card |
| Network error | Generic `cloud_off` icon | `ErrorState.inline` row appended (per COMPONENT_SPECS.md §2b) |
| Permission denied | Generic error text | "Enable location for accurate prayer times" + Settings button |

---

## 4 · Confirmed Correct in Previous Planning

These items in previous planning documents were correctly derived from HTML and behavioral audit:

| Item | Previously Stated | Status |
|---|---|---|
| Countdown at 64px as hero | ✅ Phase 3 was correct | CONFIRMED |
| Prayer time at 12px below prayer name | ✅ Correct (corrected in behavioral audit) | CONFIRMED |
| Sunrise/sunset in compact card | ✅ Phase 4 correct | CONFIRMED |
| Prayer time acts as Maghrib for sunset | ✅ Behavioral audit correction A4 | CONFIRMED |
| No Witr badge in production | ✅ Behavioral audit correction A5 | CONFIRMED |
| Full-card InkWell as primary CTA | ✅ Behavioral audit correction A1 | CONFIRMED |
| Dynamic active window (not uniformly 40min) | ✅ Behavioral audit correction A2 | CONFIRMED |
| Sunrise data: PrayerType.sunrise already available | ✅ Behavioral audit correction A4 | CONFIRMED |

---

## 5 · Previously Stated Items That Are Wrong or Need Revision

### WRONG-1 · CRITICAL: BackdropFilter on Full Card

Previous planning (Phase 2) stated: "Add `BackdropFilter(filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24))`" wrapping the card container.

**Correction:** HTML does NOT apply backdrop-filter to the card. The glass effect is purely visual via `::before`/`::after` pseudo-elements (gradients + box-shadows). In Flutter, this must be reproduced with `Stack` + `Container` with gradient overlays and `BoxDecoration` inner shadows — NOT `BackdropFilter` on the card.

`BackdropFilter` is ONLY needed for the frosted city pill (`div.loc`).

---

### WRONG-2 · HIGH: Approval Item A4 Stated as "Needing Architecture Work"

PR3_APPROVAL_REQUIRED_ITEMS.md §A4 asked "Does the prayer API already return sunset time?"

**Correction (from behavioral audit):** The app does NOT use a prayer API at runtime. All times are computed locally by the adhan library. Maghrib time IS sunset in Umm al-Qura. `allPrayers` already contains both sunrise and Maghrib. **A4 is resolved — no architecture change needed.**

---

### WRONG-3 · HIGH: numericMono Description

Previous planning described countdown as using "Calibri numericMono". 

**Correction:** `COMPONENT_SPECS.md §5` defines `numericMono` with `fontFamily: 'JetBrainsMono'`. The HTML uses `var(--font-mono)`. However, `PACKAGE_A_DECISIONS.md #1` states "Calibri is the sole canonical brand font." This is an **unresolved font conflict** (see QUESTIONS_PR3.md Q1).

---

### WRONG-4 · MEDIUM: Density Simulation Size Recommendation

`PR3_VISUAL_DENSITY_SIMULATION.md` recommended 44pt countdown based on emotional tone analysis. This recommendation was reasonable but based on the assumption that 64pt was a risk. The HTML explicitly renders the countdown at 64px. **The designer has already made this decision. The implementation should use 64px and manage dashboard height through other means (max-height on iPad, scroll accommodation on SE).**

---

## 6 · Production Behaviors That Must Be Preserved

These are locked behaviors from the behavioral audit. None may change in PR3.

| # | Behavior | Code Location | Why Locked |
|---|---|---|---|
| B1 | Full-card tap → `PrayerDetailsPage` | `next_prayer_card.dart:111` | Primary CTA; not mentioned in spec (add, don't replace) |
| B2 | `isPrayerEnabled` master gate | `smart_prayer_wrapper.dart:30` | Package A Decision #6; all prayer surfaces gated |
| B3 | `isPrayerCardEnabled` gate | `smart_prayer_wrapper.dart:33` | Settings toggle |
| B4 | `prayerCardDisplayMode` controls WHERE card appears | `smart_prayer_wrapper.dart:38–63` | Package A Decision #8 |
| B5 | Dynamic active window per prayer | `prayer_timer_service.dart:50–58` | Spiritually correct timing |
| B6 | Fajr=40min, Maghrib=20min fixed overrides | `prayer_timer_service.dart:55–58` | Documented religious timing |
| B7 | Dhikr button shown ONLY during active window | `prayer_timer_service.dart:69–83` | Not shown when spiritually inappropriate |
| B8 | `getOrCreatePostPrayerHabit()` via HabitCubit | `habit_cubit.dart:313` | Creates post-prayer athkar habit once |
| B9 | Duha window: sunrise+15 → dhuhr-15 | `prayer_timer_service.dart:113–123` | Religious Duha timing |
| B10 | Qiyam window: last third of night | `prayer_timer_service.dart:126–150` | Religious Qiyam timing |
| B11 | Midnight crossing in `_calculateTimeline` | `prayer_timer_service.dart:178–213` | Correct night crossing |
| B12 | Arabic-Indic numerals via `_toArabicNumerals` | `prayer_timer_service.dart:293` | Eastern Numerals option |
| B13 | Sunrise excluded from fard prayer timeline | `prayer_cubit.dart:48` | Sunrise is not a fard prayer |
| B14 | adhan library umm_al_qura + shafi (local computation) | `prayer_repository_impl.dart` | All prayer times local, no API call |
| B15 | Tab state resets to Today on PrayerDetailsPage open | `prayer_details_page.dart` | MaterialPageRoute behavior |

---

## 7 · Safe Redesign Areas

These can be changed in PR3 without behavioral risk.

| Area | Safe Change |
|---|---|
| Card surface | Add glass overlay (`Stack` with gradient containers, NOT BackdropFilter on card) |
| Card shadow | Upgrade to two-shadow brand-colored system |
| Header date | Split combined string → two lines (Hijri bold + Gregorian small) |
| Header city | Upgrade plain text → frosted pill with SVG pin |
| City padding | Fix `EdgeInsets.only(left:)` → `EdgeInsetsDirectional.only(start:)` |
| Hero layout | Restructure side-by-side Row → center-aligned vertical Column |
| Countdown size | 12sp → 64px (spec/HTML authoritative) |
| Prayer time | 26sp side-by-side → 12px below prayer name |
| Progress bar height | 6pt → 5px |
| Progress bar fill | State-color → teal gradient + glow |
| Progress bar RTL | Hardcoded `Directionality.rtl` → locale-aware `Transform.scale(scaleX: isRTL ? -1 : 1)` |
| Sunrise/sunset row | Add after countdown, before progress bar |
| City icon | Change to SVG pin glyph |
| Loading state | CircularProgressIndicator → skeleton gradient |
| Error state inline | Generic → `ErrorState.inline` row (per COMPONENT_SPECS §2b) |
| Permission error | Generic → specific "Enable location" message + Settings button |

---

## 8 · Dangerous Redesign Areas

These carry regression risk and require extra care.

### DANGER-1 · Critical: Nafl Badge Integration Point
Nafl badges (Duha/Qiyam) render BETWEEN the header and the status/time area in production. The new hero layout has `div.hero` as a single centered block. Where do the badges appear in the new layout? The HTML does not show them — they are absent from the visual spec entirely. 

**Risk:** If nafl badge is kept, it must integrate naturally into the center-aligned hero without visually breaking the layout. If placed above `.lbl`, it interrupts the header→hero flow. If placed below the countdown, it is visually disconnected from the prayer context.

### DANGER-2 · High: `🤲` Button Position in New Layout
Current: `GestureDetector` in a `Row` alongside the progress bar.  
New layout: countdown is center-aligned hero, progress bar is below. Where does the dhikr button live?

**Risk:** The new layout doesn't have a natural Row to place the emoji button alongside the progress bar. The button needs a new home that doesn't conflict with the centered hero or sunrise/sunset row.

### DANGER-3 · High: Adhan Moment State Machine
Spec §4 says "within ±2 min of adhan time" triggers "ALLAHU AKBAR" state. Current code has:
- `upcoming`: counting down to next prayer (includes the -2 to 0 minute window)
- `justStarted`: 0 to 10 minutes AFTER prayer (includes the 0 to +2 minute window)

The ±2 minute adhan window overlaps BOTH existing states. A new `adhanMoment` enum value must be detected BEFORE the existing `justStarted`/`upcoming` checks. The state machine requires careful ordering.

**Risk:** If `adhanMoment` is not prioritized correctly, the ±2 minute window will continue to show normal countdown (approaching -2 min) or "الآن" / "Now" (at 0 min) instead of the "ALLAHU AKBAR" display.

### DANGER-4 · High: Active Window Countdown Display
The HTML shows the countdown (64px) as `H:MM:SS` format during the `upcoming` state. But the current production code shows:
- `justStarted`: "الآن" (static text, not a countdown)
- `current`: "منذ X د" (elapsed time, not a countdown)

The spec's live `H:MM:SS` countdown format for §4 (with pulse < 60s) implies a TICKING COUNTDOWN. But during `justStarted` and `current`, there's no countdown TO something — the prayer already started. 

**What should the 64px display show during active prayer window?**
- Option A: "الآن" (Now) at 64px — brief, spiritual, matches justStarted
- Option B: Elapsed time "منذ X د" at 64px — same as current but enlarged
- Option C: Show "ALLAHU AKBAR" for full active window (simplest but spec says ±2 min only)

**Risk:** No spec guidance on what 64px element shows during justStarted/current states.

### DANGER-5 · Medium: Dashboard Height on iPhone SE
At 64px countdown + all compact elements (header, hero, sunrise/sunset, progress), the card reaches ~274pt estimated height. On iPhone SE (496pt usable viewport), this is 55% — HabitsStrip pushed below fold. While the HTML spec is authoritative, the dashboard height impact on the smallest supported device needs explicit sign-off from the designer or product owner.

---

## 9 · Emotional UX Analysis

### What the HTML Design Gets Right
- Countdown at 64px weight-300 with white color reads as **calm time-awareness**, not a timer alarm
- The `.sm` (`:SS`) at 34px / 55% opacity creates visual depth without distracting from the H:MM
- Prayer name at 22px bold remains readable without competing with the countdown
- Prayer time "17:42" at 12px provides the "when" without dominating the "how long"
- Sunrise/sunset row at 10.5px / 55% is quiet, contextual, not distracting

### What the HTML Design Gets Wrong (or risks)
- 64px on iPhone SE may feel visually aggressive if it overflows or crowds the card
- No nafl badge accommodation in the hero creates a gap in the current feature set
- The absence of a persistent "Pray now" CTA (spec text) in the HTML may be intentional (contextual) or may be a design oversight

### What Production Does Better
- Nafl badges provide real-time awareness of voluntary prayer windows — spiritually valuable
- The dhikr button's conditional nature (only when active) is perfectly calibrated
- The emotional model of "calm awareness, not urgency" is well-established

---

## 10 · Architecture Decisions Confirmed Safe

| Decision | Status |
|---|---|
| `PrayerTimerService` unchanged (no new service calls) | ✅ Safe — sunrise/sunset from existing `allPrayers` |
| `PrayerTimerStatus` additions (new fields for date split, sunrise, sunsetTime) | ⚠️ Additive only — must not remove existing fields |
| `PrayerTimerLabel` adding `adhanMoment` | ⚠️ Breaking change — all switch expressions need updating |
| `SmartPrayerCardWrapper` gate logic unchanged | ✅ Safe |
| `HabitCubit` Athkar coupling unchanged | ✅ Safe (find new layout position for `🤲` button) |
| Full-card `InkWell` → `PrayerDetailsPage` unchanged | ✅ Safe |
| App Group write for compact/expanded state | ⚠️ Additive — follows existing `widget_data_service.dart` pattern |

---

## 11 · Approval Items Status Update

| Item | Previous Status | Updated Status | Reason |
|---|---|---|---|
| A4 — Sunset time data source | ⏳ PENDING | ✅ RESOLVED | Maghrib = sunset. Already in `allPrayers`. No architecture needed. |
| A1 — Hero layout restructure | ⏳ PENDING | ⏳ PENDING — confirmed HTML direction | HTML confirms center-aligned with 64px countdown. **Still needs designer confirmation of height trade-off.** |
| A2 — CTA pill vs absent | ⏳ PENDING | ⏳ PENDING — HTML says absent | HTML shows no CTA pill. Current `🤲` emoji remains the default. Awaiting explicit confirmation. |
| A3 — Nafl badges | ⏳ PENDING | ⏳ PENDING | HTML has no badges. Production has them. Explicit decision required. |
| A5 — ALLAHU AKBAR tone | ⏳ PENDING | ⏳ PENDING | Confirmed needed but state machine question unresolved (see QUESTIONS_PR3.md Q4). |
| A6 — Compact/expanded approach | ⏳ PENDING | ⏳ PENDING | HTML confirms widget-local state. Tap target and persistence still unspecified. |
| A7 — Progress bar semantic color | ⏳ PENDING | 🔄 CLARIFIED | HTML is definitive: teal gradient, no state color. Semantic color is intentionally removed. Awaiting explicit confirmation. |
| A8 — Sunrise arc vs text row | ⏳ PENDING | ✅ RESOLVED | HTML shows simple text row (not SVG arc). Use text row. |
| A9 — Dashboard height acceptance | ⏳ PENDING | ⏳ PENDING — more critical now | 274pt estimated on compact. 55% of SE viewport. Must have explicit sign-off. |
| A10 — HabitCubit scope | ⏳ PENDING | ⏳ PENDING | Existing bug, PR3 opportunity. |
