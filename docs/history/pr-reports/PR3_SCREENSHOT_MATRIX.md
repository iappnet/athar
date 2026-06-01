# PR3 Screenshot Matrix — Required Pre/Post Validation

**Date:** 2026-05-09  
**Status:** PRE-IMPLEMENTATION — reference for QA and PR3 sign-off  
**Purpose:** Define every screenshot required to validate PR3 implementation. Screenshots must be taken before and after implementation to confirm: (1) regressions absent, (2) spec behaviors present, (3) RTL correct, (4) all states reachable.

---

## Device Targets

| ID | Device | Size | Purpose |
|---|---|---|---|
| D1 | iPhone SE 3rd gen (sim) | 375 × 667 | Smallest supported — truncation/overflow regression |
| D2 | iPhone 14 / 15 (sim) | 390 × 844 | Reference phone size |
| D3 | iPhone 14 Pro Max (sim) | 430 × 932 | Large phone — generous viewport |
| D4 | iPad Air 11" (sim) | 820 × 1180 | Tablet breakpoint — rail visible |
| D5 | Physical device (optional) | — | Glass blur, haptic, animation validation |

Minimum required: D1 + D2. D4 required if Phase 5 expanded mode is implemented.

---

## Locale Targets

| ID | Locale | Dir | Notes |
|---|---|---|---|
| L1 | ar-SA | RTL | Arabic-Indic numerals in prayer name/time; Hijri date primary |
| L2 | en-US | LTR | Latin numerals; Gregorian date primary |

All screenshots must be taken in both L1 and L2 unless the state is locale-invariant.

---

## Theme Targets

| ID | Theme | Notes |
|---|---|---|
| T1 | Light | Current only; PR-THEME not yet implemented |
| T2 | Dark | Document as "pending" — dark mode wiring deferred to PR-THEME |

> Dark mode screenshots are INFORMATIONAL only for PR3. Do not block PR3 approval on T2.

---

## State Matrix

### Group 1 — Baseline (required before any PR3 code change)

| Screenshot ID | State | Locale | Device | Description | Pre-PR3 | Post-PR3 |
|---|---|---|---|---|---|---|
| S-01 | `upcoming` — normal countdown | L1 | D2 | Card in countdown mode, no badge, no dhikr button | REQUIRED | REQUIRED |
| S-02 | `upcoming` — normal countdown | L2 | D2 | Same, English | REQUIRED | REQUIRED |
| S-03 | `upcoming` — small device | L1 | D1 | Confirm no overflow at smallest screen | REQUIRED | REQUIRED |
| S-04 | `upcoming` — small device | L2 | D1 | English, small screen | REQUIRED | REQUIRED |
| S-05 | `justStarted` state | L1 | D2 | Prayer window just opened (0–10 min); "الآن" displayed | REQUIRED | REQUIRED |
| S-06 | `justStarted` state | L2 | D2 | English equivalent | REQUIRED | REQUIRED |
| S-07 | `current` state | L1 | D2 | Active prayer window (10 min → end); elapsed time shown | REQUIRED | REQUIRED |
| S-08 | `current` state | L2 | D2 | English | REQUIRED | REQUIRED |

---

### Group 2 — Countdown Hierarchy

| Screenshot ID | State | Locale | Device | Description |
|---|---|---|---|---|
| S-09 | `upcoming` — countdown dominant | L1 | D2 | Shows countdown as primary visual element post-PR3 |
| S-10 | `upcoming` — countdown dominant | L2 | D2 | English equivalent |
| S-11 | `upcoming` — pulse active (< 60s) | L1 | D2 | Countdown pulsing: capture mid-pulse (opacity ~0.85) |
| S-12 | `upcoming` — pulse active (< 60s) | L2 | D2 | English |
| S-13 | `adhanMoment` state (if implemented) | L1 | D2 | "ٱللَّٰهُ أَكْبَرُ" + "الصلاة الآن" visible; countdown area replaced |
| S-14 | `adhanMoment` state (if implemented) | L2 | D2 | English "Pray now" sub-text |

> S-11/S-12: Screenshot must be taken mid-pulse, not at full opacity. Use simulator slow-animations mode.  
> S-13/S-14: Gate on Approval Item A5 approval before including in matrix.

---

### Group 3 — Header

| Screenshot ID | Description | Locale | Device |
|---|---|---|---|
| S-15 | Two-line date header: Hijri (primary, bold) + Gregorian (secondary, 60% opacity) | L1 | D2 |
| S-16 | Two-line date header: Gregorian (primary) + Hijri (secondary) | L2 | D2 |
| S-17 | Frosted city pill: Arabic city name, pin icon, RTL layout | L1 | D2 |
| S-18 | Frosted city pill: English city name, pin icon, LTR layout | L2 | D2 |
| S-19 | Header RTL: date on right, city on left | L1 | D2 |
| S-20 | Header LTR: date on left, city on right | L2 | D2 |

---

### Group 4 — Post-Prayer Athkar / Dhikr Button

| Screenshot ID | State | Locale | Device | Description |
|---|---|---|---|---|
| S-21 | `justStarted`: dhikr button visible | L1 | D2 | `🤲` button rendered; tap → DhikrBottomSheet |
| S-22 | `justStarted`: dhikr button visible | L2 | D2 | English |
| S-23 | `current`: dhikr button visible | L1 | D2 | Active prayer window — button remains |
| S-24 | `upcoming`: dhikr button absent | L1 | D2 | No dhikr button — outside active window |
| S-25 | DhikrBottomSheet open (post-dhikr tap) | L1 | D2 | Sheet visible: athkar items, first incomplete auto-scrolled |
| S-26 | DhikrBottomSheet open | L2 | D2 | English |

> S-21–S-24: Confirm dhikr button state matches `showDhikrButton` field from `PrayerTimerStatus`.  
> Dhikr button must NOT be visible outside the active prayer window (`justStarted` or `current`).

---

### Group 5 — Nafl Badges

| Screenshot ID | State | Locale | Device | Description |
|---|---|---|---|---|
| S-27 | Duha badge active | L1 | D2 | Orange pill badge on card; `isDuhaTime == true` (sunrise+15min → dhuhr-15min) |
| S-28 | Duha badge active | L2 | D2 | English |
| S-29 | Qiyam badge active | L1 | D2 | Indigo pill badge; `isQiyamTime == true` (last third of Isha→Fajr night) |
| S-30 | Qiyam badge active | L2 | D2 | English |
| S-31 | No badge — normal | L1 | D2 | Outside both Duha and Qiyam windows; no badge rendered |
| S-32 | Duha + `justStarted` combined | L1 | D2 | Duha badge AND dhikr button simultaneously visible |

> Nafl badge screenshots require device clock manipulation or a mock `PrayerTimerStatus` injected via test harness.  
> Duha time window: approximately 7:30–11:45 in most cities. Schedule device time accordingly.  
> Qiyam time window: approximately 02:00–04:30. Schedule device time or use mock.

---

### Group 6 — Witr State

| Screenshot ID | State | Locale | Device | Description |
|---|---|---|---|---|
| S-33 | Witr window | L1 | D2 | **NOTE:** Current production code does NOT have a Witr-specific state. Confirm whether Witr should be added in PR3 (pending behavioral decision). If not implemented, document as "intentionally absent." |
| S-34 | Witr window | L2 | D2 | Same note as S-33 |

> Per `PR3_BEHAVIORAL_SOURCE_OF_TRUTH.md` §3: No Witr state exists in current production code. `isWitrTime` is not a field on `PrayerTimerStatus`. S-33/S-34 are CONDITIONAL on a Witr feature decision that has not yet been made. Do not implement Witr in PR3 without explicit approval.

---

### Group 7 — Last Third of Night (Qiyam)

| Screenshot ID | State | Locale | Device | Description |
|---|---|---|---|---|
| S-35 | Qiyam window — last third of night | L1 | D2 | Indigo badge visible; confirm badge text string in Arabic |
| S-36 | Qiyam window — last third of night | L2 | D2 | English badge text |
| S-37 | Qiyam + `upcoming` (Fajr approaching) | L1 | D2 | Qiyam badge AND Fajr countdown visible simultaneously |

> The Qiyam badge is the only indicator of last-third-of-night in the current design. No separate "last third" visual exists.

---

### Group 8 — Progress Bar

| Screenshot ID | State | Locale | Device | Description |
|---|---|---|---|---|
| S-38 | Progress bar — 0% fill | L1 | D2 | Start of upcoming window; bar nearly empty |
| S-39 | Progress bar — 50% fill | L1 | D2 | Mid-window |
| S-40 | Progress bar — 95% fill | L1 | D2 | Near end of active window |
| S-41 | RTL progress bar — 50% fill | L1 | D2 | Confirm bar fills right-to-left in Arabic |
| S-42 | LTR progress bar — 50% fill | L2 | D2 | Confirm bar fills left-to-right in English |

> S-41/S-42 are the RTL regression test. Current code has `Directionality(textDirection: rtl)` hardcoded — PR3 must fix this to locale-aware.

---

### Group 9 — Sunrise/Sunset Row

| Screenshot ID | State | Locale | Device | Description |
|---|---|---|---|---|
| S-43 | Sunrise/sunset row visible | L1 | D2 | Sun icon + Arabic time on both sides |
| S-44 | Sunrise/sunset row visible | L2 | D2 | Sun icon + English time |
| S-45 | RTL: sunrise right / sunset left | L1 | D2 | Confirm correct RTL order |
| S-46 | LTR: sunrise left / sunset right | L2 | D2 | Confirm correct LTR order |
| S-47 | Null sunrise — row absent | L1 | D2 | If `sunriseTime == null`, confirm row does not render (no crash) |

---

### Group 10 — Expanded Mode (Phase 5, conditional)

Gate: **Approval Item A2 (CTA) + A6 (compact/expanded approach) must be approved** before these screenshots are required.

| Screenshot ID | State | Locale | Device | Description |
|---|---|---|---|---|
| S-48 | Compact card | L1 | D2 | Default state — no 5-prayer strip |
| S-49 | Expanded card | L1 | D2 | 5-prayer strip visible |
| S-50 | 5-prayer strip — past prayers | L1 | D2 | Past prayers: 45% opacity, strikethrough |
| S-51 | 5-prayer strip — next prayer highlighted | L1 | D2 | Next prayer: teal highlight |
| S-52 | Expanded RTL | L1 | D2 | Strip reversed in Arabic |
| S-53 | Expanded LTR | L2 | D2 | Strip left-to-right |
| S-54 | Expanded — tablet layout | L1 | D4 | Card in rail layout; expanded mode does not conflict |

---

### Group 11 — Loading and Error States

| Screenshot ID | State | Locale | Device | Description |
|---|---|---|---|---|
| S-55 | Loading skeleton (Phase 6) | L1 | D2 | Shimmer container replaces card during `PrayerLoading`/`PrayerInitial` |
| S-56 | Loading skeleton | L2 | D2 | English |
| S-57 | Network error state | L1 | D2 | cloud_off icon + retry button |
| S-58 | Network error state | L2 | D2 | English |
| S-59 | Permission denied state | L1 | D2 | Lock icon + location enable prompt |
| S-60 | Permission denied state | L2 | D2 | English |
| S-61 | Prayer card disabled (`isPrayerCardEnabled == false`) | L1 | D2 | SmartPrayerCardWrapper returns SizedBox — no card visible |

---

### Group 12 — Tablet Layout

Gate: All Phase 5+ implementation complete.

| Screenshot ID | State | Locale | Device | Description |
|---|---|---|---|---|
| S-62 | Dashboard with rail — phone breakpoint | L1 | D2 | Bottom nav visible; prayer card in SliverList |
| S-63 | Dashboard with rail — tablet compact | L1 | D4 | Icon-only rail; prayer card still centered in content area |
| S-64 | Dashboard with rail — tablet expanded | L1 | D4 | Text rail; content area narrower — verify card max-width |

---

### Group 13 — Full Dashboard Fold Check

| Screenshot ID | State | Device | Description |
|---|---|---|---|
| S-65 | Dashboard — nothing scrolled, compact card | D2 | Confirm StatisticsCard and HabitsStrip visible below prayer card |
| S-66 | Dashboard — nothing scrolled | D1 | Same on iPhone SE — fold regression check |
| S-67 | Dashboard — nothing scrolled | D3 | Large phone — confirm no excess whitespace |

---

## Priority Order for Testing

### Must-have before PR3 merge (MVP)

1. S-01, S-02 — baseline upcoming (Arabic + English)
2. S-05, S-06 — justStarted state
3. S-07, S-08 — current state
4. S-19, S-20 — header RTL/LTR
5. S-21, S-24 — dhikr button present/absent
6. S-38, S-41, S-42 — progress bar + RTL fix
7. S-65, S-66 — dashboard fold check (iPhone 14 + SE)

### Should-have before PR3 merge

- S-03, S-04 — iPhone SE overflow
- S-27, S-28 — Duha badge
- S-29, S-30 — Qiyam badge
- S-43–S-46 — sunrise/sunset row
- S-55–S-60 — loading and error states

### Gated on approval

- S-13, S-14 — adhanMoment (gate: A5)
- S-48–S-54 — expanded mode (gate: A2, A6)
- S-33, S-34 — Witr (gate: Witr feature decision)

---

## How to Capture Required Screenshots

### Production states reachable via clock manipulation (simulator)

| State | Method |
|---|---|
| `upcoming` | Any time of day — default state |
| `justStarted` | Set simulator clock to within 0–9 min after adhan time for next prayer |
| `current` | Set simulator clock to within active window (10+ min after adhan, before end) |
| `adhanMoment` | Set simulator clock to within ±2 min of adhan time |
| Duha badge | Set clock to sunrise+15min (approx 07:30–11:45) |
| Qiyam badge | Set clock to last third of night (approx 02:00–04:30) |
| Pulse (< 60s) | Set clock to 59 seconds before adhan time |

### States requiring mock injection

| State | Method |
|---|---|
| Null sunriseTime | Temporarily return null from `_getSunriseTime()` in service |
| Loading skeleton | Comment out `startTimer()` call to stay in `PrayerInitial` |
| Permission denied | Mock `isPrayerEnabled == false` or revoke location permission |
| Progress bar at 50% | Inject a `PrayerTimerStatus` with `progress: 0.5` |

---

## Pre-PR3 Baseline Note

Screenshots S-01 through S-08, S-19/S-20, S-21/S-24, S-38–S-42, and S-65/S-66 MUST be taken from the current production build BEFORE any PR3 code changes are committed. These form the regression baseline.

Store baseline screenshots in: `docs/screenshots/pr3-baseline/` (create on device during testing).

---

*Document generated as part of PR3 pre-implementation behavioral lock. No code was modified.*
