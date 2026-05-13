# PR3 Required Design Corrections

**Date:** 2026-05-13  
**Status:** Pre-implementation corrections — must be applied before Phase 2 begins  
**Authority:** `PR3_TECHNICAL_RECONCILIATION_REPORT.md` + HTML primary source  
**Purpose:** Document exactly what the previous planning documents got wrong, what must change in the implementation plan, and what is safe to proceed with.

---

## Section 1 — Incorrect Assumptions in Previous Planning

### CORRECTION-A · CRITICAL: BackdropFilter Scope

**Previous plan stated:** "Add `BackdropFilter(filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24))` around the card container."

**Correction:**  
The HTML does NOT apply BackdropFilter to the card. The glass effect is purely a layered gradient overlay using `::before`/`::after` pseudo-elements. In Flutter this must be a `Stack` with `IgnorePointer` gradient containers + `DecoratedBox` inner shadows.

`BackdropFilter` is ONLY used for the frosted city pill (`div.loc` CSS has `backdrop-filter: blur(8px)`).

**Apply to Phase 2:** Remove `BackdropFilter` from card container. Apply only to the frosted city pill widget.

---

### CORRECTION-B · CRITICAL: numericMono Font Source

**Previous plan stated:** The countdown uses "Calibri numericMono."

**Correction:**  
`COMPONENT_SPECS.md §5` defines `numericMono` with `fontFamily: 'JetBrainsMono'`. The HTML uses `var(--font-mono)` for `.clock`. These both point to a dedicated monospace font for numbers, not Calibri.

However: `PACKAGE_A_DECISIONS.md #1` states "Calibri is the sole canonical brand font." This is an unresolved conflict (see QUESTIONS_PR3.md Q1). Until resolved:
- Use `AtharTypography.numericMono` as implemented in PR1 (Calibri) for the countdown
- Flag this as a pending font decision when the countdown is implemented

---

### CORRECTION-C · HIGH: Sunrise/Sunset Placement

**Previous plan Phase 4** placed the sunrise/sunset row in the compact card, then added it again in the expanded variant as a separate step.

**Correction (confirmed):**  
The HTML shows sunrise/sunset in BOTH compact and expanded. The Phase 4 placement of it in compact is correct. Phase 5 (expanded) does NOT need to add it again — it is already there from compact. The expanded variant adds the 5-prayer strip BETWEEN the progress bar and the sunrise/sunset row.

**Expanded layout order:**
1. Header  
2. Hero (label + name + countdown, NO `.at` prayer time in expanded)  
3. Progress bar  
4. Five-prayer strip  
5. Sunrise/sunset row  

**Compact layout order:**
1. Header  
2. Hero (label + name + `.at` prayer time + countdown)  
3. Sunrise/sunset row  
4. Progress bar  

---

### CORRECTION-D · HIGH: Prayer Time in Expanded Mode

**Previous plan** implied prayer time (`.at` at 12px) would be visible in both compact and expanded.

**Correction:**  
In the HTML expanded variant, `div.at` (the "17:42" prayer time element) is ABSENT. The expanded mode's 5-prayer strip contains the time in the highlighted "next" chip. The prayer time sub-text must be HIDDEN when expanded.

**Implementation:** Use conditional rendering: `if (!_isExpanded) Text(prayerTime, style: ...)`.

---

### CORRECTION-E · MEDIUM: Approval Item A4 is Already Resolved

**Previous planning:** Listed "Sunset time data source" as a Critical approval-blocked item (A4).

**Correction:**  
Sunset = Maghrib in Umm al-Qura method. Already in `allPrayers`. No API call. No new service fields needed. Read directly in the widget:

```dart
final sunset = allPrayers.firstWhere((p) => p.type == PrayerType.maghrib);
final sunrise = allPrayers.firstWhere((p) => p.type == PrayerType.sunrise);
```

**A4 is RESOLVED. Remove it from the blocker list.**

---

### CORRECTION-F · MEDIUM: Countdown Size Recommendation in Density Simulation

`PR3_VISUAL_DENSITY_SIMULATION.md` recommended 44pt countdown based on emotional tone analysis.

**Correction:**  
The HTML explicitly uses 64px. The designer has already made this decision. The 44pt recommendation was analyzing a risk that has a design answer. Use 64px. Address the dashboard height concern by:
1. Documenting the iPhone SE height impact for designer sign-off (still required — see A9)
2. Ensuring dashboard remains scroll-accessible — the card does not need a `maxHeight` constraint unless the designer requests one

**The density simulation document remains valid as documentation of trade-offs, but the recommendation section is superseded by HTML authority.**

---

### CORRECTION-G · LOW: Shadow Values

**Previous plan Phase 2** used HTML-extracted shadow values correctly. The spec text shadow (`0 12 28 rgba(0,0,0,0.18)`) is wrong.

**Confirmed correct values (from HTML):**
```dart
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

---

## Section 2 — Behaviors That Must Remain Unchanged

These are NON-NEGOTIABLE. Any PR3 implementation that changes these behaviors is incorrect.

| # | Behavior | Code | Rule |
|---|---|---|---|
| 1 | Full-card InkWell → PrayerDetailsPage | `next_prayer_card.dart:111` | Primary navigation CTA. Not in spec, must be ADDED to new layout, not replaced. |
| 2 | Dhikr button conditional on justStarted/current only | `prayer_timer_service.dart:69` | Spiritually calibrated — not appropriate outside active window |
| 3 | Dynamic active window (Fajr=40, Maghrib=20, others=dynamic) | `prayer_timer_service.dart:50–58` | Correct per Islamic timing |
| 4 | `isPrayerEnabled` master gate | `smart_prayer_wrapper.dart:30` | Package A Decision #6 |
| 5 | `isPrayerCardEnabled` gate | `smart_prayer_wrapper.dart:33` | User settings |
| 6 | `prayerCardDisplayMode` controls page visibility | `smart_prayer_wrapper.dart:38–63` | Package A Decision #8 — NOT variant |
| 7 | Duha window: sunrise+15 → dhuhr-15 | `prayer_timer_service.dart:113` | Established nafl timing |
| 8 | Qiyam window: last third of night | `prayer_timer_service.dart:126` | Established nafl timing |
| 9 | Midnight crossing in `_calculateTimeline` | `prayer_timer_service.dart:178` | Critical correctness |
| 10 | Arabic-Indic via `_toArabicNumerals` | `prayer_timer_service.dart:293` | Eastern Numerals opt-in |
| 11 | Sunrise excluded from fard timeline | `prayer_cubit.dart:48` | Sunrise is not a fard prayer |

---

## Section 3 — Behaviors Safe to Modernize

### 3a · Safe (no approval needed)

| Behavior | Change | Risk |
|---|---|---|
| Card surface | Add glass gradient overlay (`Stack` containers, not BackdropFilter) | Low |
| Card shadow | Upgrade to HTML two-shadow system | Low |
| Header date display | Split `fullDate` → `hijriDate` + `gregorianDate` fields | Low — additive |
| City widget | Upgrade to frosted pill with SVG pin | Low |
| City padding RTL bug | `EdgeInsets.only(left:)` → `EdgeInsetsDirectional.only(start:)` | Bug fix |
| Progress bar height | 6pt → 5px | Low |
| Progress bar RTL bug | `Directionality.rtl` hardcoded → locale-aware | Bug fix |
| Loading state | CircularProgressIndicator → skeleton gradient | Low |
| Error inline | Upgrade to `ErrorState.inline` row | Low |
| Permission denied | Specific "Enable location" text | Low |

### 3b · Safe (confirmed by HTML)

| Behavior | Change | Confirmed by |
|---|---|---|
| Hero layout | Side-by-side Row → center-aligned vertical Column | HTML `div.hero text-align:center` |
| Prayer time | 26sp side-by-side → 12px below prayer name | HTML `div.at` 12px |
| Countdown | 12sp → 64px weight-300 | HTML `div.clock` 64px |
| Seconds sub-style | None → 34px / 55% opacity | HTML `span.sm` |
| Sunrise/sunset | Add text row below hero | HTML `div.arc` in compact |
| Prayer time in expanded | Show → hide | HTML expanded removes `div.at` |
| Progress fill | State-color → teal→white gradient + glow | HTML `.fill` CSS |

### 3c · Safe but requires careful state machine work

| Behavior | Change | Risk |
|---|---|---|
| Adhan moment state | Add `PrayerTimerLabel.adhanMoment` | Medium — must update all switch expressions |
| Date fields | Add `hijriDate`, `gregorianDate`, `sunriseTime`, `sunsetTime` to `PrayerTimerStatus` | Medium — additive but must not remove `fullDate` |
| Pulse animation | Add opacity pulse when countdown < 60s | Low |

---

## Section 4 — Countdown Size Recommendation

### Final Recommendation: **64px as specified in HTML**

Reasoning:
1. HTML is the authoritative visual reference per the spec file's own statement
2. 64px weight-300 white reads as calm time-awareness, not alarm urgency
3. The prayer time (12px, white70) above it provides "when" context; the countdown provides "how long until"
4. The design has been visually validated in the HTML showcase

### Dashboard Height Management

Since 64px results in ~274pt card height (vs current ~140pt), the following mitigations are required in PR3:

1. **Do not add max-height constraints** on iPhone 14+ — the card naturally fits
2. **Document iPhone SE impact** (55% viewport) and get sign-off from designer/product owner (see Approval Item A9)
3. **Do not add Phase 5 (expanded mode) until Phase 2–4 compact height is validated on device**
4. **The 5-prayer strip in expanded adds another ~80pt** — expanded mode must be explicitly size-checked before shipping

---

## Section 5 — CTA Correction Recommendations

### Current State
- Production: conditional `🤲` emoji button (only during active window)
- Spec text §2 step 5: "Start dhikr" pill (cream/forest) — implies always-visible
- HTML: **NO CTA button rendered** in either compact or expanded

### Recommendation
**Follow HTML. No persistent CTA pill.** The conditional `🤲` is the closest to the HTML's intent.

For PR3, the only change needed is:
1. Move the `🤲` button from the progress Row to a better position in the new vertical layout
2. Consider making it a small text button ("أذكار ما بعد الصلاة" / "Post-prayer athkar") instead of an emoji, for accessibility
3. Keep it conditional — only during active window

**This makes Approval Item A2 simpler:** "Do we keep the conditional emoji button in a better position, or switch to a text label?" — not "Do we add a persistent pill?" The persistent pill approach conflicts with the HTML and should not be implemented unless the designer explicitly overrides the HTML.

---

## Section 6 — Navigation Correction Recommendations

No navigation corrections needed for the card itself. The full-card InkWell → PrayerDetailsPage must be preserved verbatim. 

**One integration question:** In the new expanded layout with a 5-prayer strip, does tapping a past/future prayer chip in the strip navigate to that prayer's day in PrayerDetailsPage? Or is the strip read-only? This is currently unspecified. **Default: strip is display-only. No tap navigation from chips.**

---

## Section 7 — Hierarchy Correction Recommendations

### Corrected visual hierarchy (highest → lowest)

| Rank | Element | Size | Weight | Color | Purpose |
|---|---|---|---|---|---|
| 1 | Countdown H:MM | 64px | 300 | white | How long until prayer |
| 2 | Seconds :SS | 34px | 300 | white55 | Sub-second precision |
| 3 | Prayer name | 22px | 700 | white | Which prayer |
| 4 | Prayer time | 12px | 400 | white70 | When the prayer is |
| 5 | "Next prayer" label | 11px | 600 | white55 | Context |
| 6 | Progress bar fill | 5px | — | teal gradient | Elapsed % |
| 7 | Sunrise/sunset | 10.5px | 400 | white55 | Daily celestial context |
| 8 | Date Hijri | 14px | 700 | white | Anchoring: Hijri calendar |
| 9 | Date Gregorian | 11px | 400 | white60 | Anchoring: civil calendar |
| 10 | City pill | 11.5px | 500 | white70 | Location |

**Key correction from current state:**
- Prayer time drops from #1 (26sp, same as name) to #4 (12px sub-text)
- Countdown rises from #last (12sp) to #1 (64px)
- This is the spec's intended hierarchy shift

---

## Section 8 — Dark Mode Correction Recommendations

**No changes needed for dark mode.** The prayer card uses a fixed gradient (`AtharColors.prayerCardGradient`, forest→teal) in both light and dark system themes. This is intentional — the Islamic green aesthetic is preserved regardless of system theme.

All text colors in the card are `Colors.white*` variants (hardcoded), which are correct against the dark gradient background.

**PR3 dark mode status:** The card is already "dark mode correct" — it is permanently a dark surface. PR-THEME does not affect the prayer card.

---

## Section 9 — Nafl Presentation Recommendations

Nafl badges (Duha/Qiyam) are present in production but absent from the spec/HTML. They have real religious value and must not be silently removed.

### Option A — Keep badges, integrate above hero (recommended)
```
[Header]
[Nafl badge: Duha or Qiyam pill — if active]
[Hero: label → name → prayer time → countdown]
[Sunrise/sunset]
[Progress]
```
This preserves the current position (above the status row) and doesn't disrupt the centered hero.

### Option B — Integrate badge into hero label row
```
[Header]
[Hero:
  Row(space-between): [nafl badge] [space] OR just badge above label
  label → name → prayer time → countdown]
```
More integrated but potentially cluttered.

### Option C — Remove badges from card, show in widget only
Aligns with spec/HTML (which don't show badges on card). But removes real-time voluntary prayer awareness from the app's primary prayer surface.

**Recommendation: Option A.** Badges are spiritually meaningful and the current placement (above the hero) works with the new vertical layout. Requires explicit designer sign-off on which option to use (Approval Item A3).

---

## Section 10 — Implementation Plan Phase Revisions

Based on all corrections above:

| Phase | Previous Plan | Required Revision |
|---|---|---|
| Phase 1 (domain) | Add `adhanMoment`, split dates, `sunriseTime` | Add `sunsetTime` (= Maghrib time). Keep `fullDate`/`fullDateEn` alongside new fields. |
| Phase 2 (surface + header) | `BackdropFilter` on card | **REMOVE BackdropFilter from card.** Use Stack with gradient containers. `BackdropFilter` only on city pill. |
| Phase 3 (hero) | 64pt countdown dominant, prayer time 12pt | Confirmed correct per HTML. Also: hide `div.at` (prayer time) in expanded mode. |
| Phase 4 (progress + sunrise) | Add sunrise/sunset, fix RTL, add pulse | Confirmed. Sunrise/sunset in COMPACT (not expanded-only). Gradient fill, not cream. |
| Phase 5 (expanded) | Add 5-prayer strip + sunrise again | Sunrise/sunset already from Phase 4. Expanded ADDS strip between progress and sunrise rows. Do NOT re-add sunrise row. |
| Phase 6 (CTA) | Pending approval; "Start dhikr" pill option | **HTML says no persistent pill.** Move `🤲` to correct position in new layout. No new pill unless explicitly approved. |
