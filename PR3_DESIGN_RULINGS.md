# PR3 Design Rulings — Final, Authoritative

**Date:** 2026-05-31
**Author:** Design authority (Athar Design System)
**Supersedes:** every "pending / blocked / awaiting designer" item in
`PR3_TECHNICAL_RECONCILIATION_REPORT.md`, `PR3_REQUIRED_DESIGN_CORRECTIONS.md`,
and `PR3_BLOCKERS_AND_OPEN_ASSUMPTIONS.md`.

> **Precedence is now fixed.** `PRAYER_CARD_SPEC.md` v2 is the SINGLE source
> of truth. The old "HTML wins where spec text contradicts" rule is
> **retired** — spec text and `preview/comp-prayer-card.html` have been
> reconciled to agree. If you are holding a copy of the preview that shows a
> **64px** countdown, it is **stale** (`handoff_v2-2`). The canonical preview
> in `handoff_v2/preview/comp-prayer-card.html` is **44px**. Use 44px.

---

## A · The six hard blockers — all resolved

| # | Blocker | RULING |
|---|---|---|
| **B1** | adhanMoment sacred Arabic Unicode | **DISSOLVED.** There is **no "ALLAHU AKBAR" / adhanMoment state** in the v2 design. The active-prayer state is a calm label swap only (see §C). No sacred-text rendering ⇒ no Unicode blocker. **Cancel Phase 7 entirely.** |
| **B2** | adhanMoment ±2-min boundary | **DISSOLVED** with B1. No adhanMoment window exists. The state transition is driven by the existing `justStarted` boundary already in `PrayerTimerService` — no new boundary logic. |
| **B3** | numericMono font: JetBrains Mono vs Calibri | **RULED: JetBrains Mono.** The countdown, all-prayer-strip times, sunrise/sunset times, and the `at` prayer time use **JetBrains Mono tabular**. This does **not** violate the Calibri lockdown — `DESIGN_SYSTEM_GAP_VALIDATION.md` and `SKILL.md §2.3` both explicitly reserve **JetBrains Mono for numerals where alignment matters**. Calibri = brand text; JetBrains Mono = numerals. Bundle the TTF in PR1. |
| **B4** | compact/expanded toggle affordance | **RULED: no on-card toggle.** Compact is the **only** variant on the Dashboard and on phone. Expanded renders **only** on the dedicated Prayer page and on iPad (where there is room). There is **no user gesture** that expands/collapses the card in place ⇒ **zero hit-test conflict** with the full-card tap. Drop the toggle-affordance question. |
| **B5** | nafl badge placement | **RULED: Option A.** One calm chip (Duha *or* Qiyam, never both), inside the hero block, **below the countdown, above the sunrise/sunset row** in compact; **beside the prayer name** in expanded. Opt-in via the existing nafl-visibility setting. See §D. |
| **B6** | iPhone SE height sign-off | **RULED: accepted at 44px.** At 44px (not 64px) the compact card is ≈ 257pt → ≈ 52% of SE viewport with HabitsStrip edge-visible. Acceptable. Auto-drop countdown to **40px** when `MediaQuery.sizeOf(context).height < 700`. No max-height constraint. |

---

## B · Countdown — the central ruling

**Locked: 44px, weight 300, JetBrains Mono tabular, white, −1px letter-spacing.**
Seconds: 26px / 55% opacity / 6px offset.

- 64px is **rejected.** It shifts the emotional register from "calm
  awareness" to "countdown pressure" and pushes habits/tasks below the fold
  on small phones. `PR3_VISUAL_DENSITY_SIMULATION.md` reached the same
  recommendation (44px) on emotional + density grounds; that recommendation
  **stands and is now binding**, overriding the stale 64px HTML.
- Tablet (iPad): scale to 56px (the card has a 480pt max-width and its own
  column there).
- Small phones (`height < 700pt`): 40px.

Hierarchy (highest → lowest visual weight): **countdown (44) → prayer name
(22/700) → prayer time `at` (12 mono) → "next prayer" label (11) → progress
→ sunrise/sunset → date → city**. Countdown is the hero; prayer time is
sub-text. (This matches Claude Code's CONFLICT-1 reading — countdown
dominant — just at 44 not 64.)

---

## C · Active-prayer state — calm, no cinema

When a prayer's start time is reached:
- Label "Next prayer" → **"Now" / "الآن"** (same position, same type scale).
- The 44px countdown is **replaced** by the prayer **name promoted to
  36px/700**, with a **"Started at HH:MM" / "بدأت ١٧:٤٢"** stamp (12px mono)
  beneath it.
- Transition: **250ms cross-fade. No scale, no pulse, no haptic, no overlay.**
- The adhan audio is the moment; the UI stays still.

This resolves **DANGER-4** (what the big numeral shows during the active
window): it shows nothing — the name takes over. There is no ticking
countdown during the active window, and no "ALLAHU AKBAR" element.

> Removes the need for `PrayerTimerLabel.adhanMoment`. **Do not add that enum
> value.** The existing `justStarted` / `current` / `upcoming` labels are
> sufficient. No switch-cascade expansion.

---

## D · Post-prayer dhikr affordance (replaces the "CTA pill" question)

- **No persistent "Start dhikr" pill.** (Confirms CONFLICT-3.)
- The whole card is the **only** primary tap target → existing
  `PrayerDetailsPage`. Preserve `next_prayer_card.dart:111` verbatim.
- The existing **conditional dhikr affordance** (shown only during the active
  post-prayer window via `showDhikrButton`) is **kept**, but:
  - Reposition it into the hero block, beneath the "Started at" stamp.
  - Change from the `🤲` emoji to a **text button**: "أذكار ما بعد الصلاة" /
    "Post-prayer athkar" (11pt Calibri, glass chip background) for
    accessibility.
  - Keep it conditional — never visible in `upcoming`.
- The 40-minute (Fajr) / 20-minute (Maghrib) / dynamic windows are **owned by
  `PrayerTimerService`** and must not change (B5–B11 in the behavioral audit).

---

## E · Surface & technical corrections (adopted from Claude Code)

These corrections from `PR3_REQUIRED_DESIGN_CORRECTIONS.md` are **accepted**
and now part of the spec:

1. **No `BackdropFilter` on the card.** The glass is a `Stack` of gradient
   overlay containers + `BoxDecoration` inner shadows. `BackdropFilter`
   (blur 8) is used **only** on the frosted city pill. (CORRECTION-A.)
2. **Shadow = two-layer, brand-colored — but forest, not teal.** Use the new
   brand:
   ```dart
   boxShadow: [
     BoxShadow(color: Color(0xFF0F3D2E).withValues(alpha: .32), blurRadius: 42, offset: Offset(0, 18)),
     BoxShadow(color: Color(0xFF1A5A45).withValues(alpha: .18), blurRadius: 12, offset: Offset(0, 4)),
   ],
   ```
   (CORRECTION-G, updated to forest palette — the cited teal `#0D7377`
   values are pre-rebrand and deprecated.)
3. **Surface gradient = forest** `#0F3D2E → #1A5A45` (135°). The cited
   `#1A6B3C → #0D7377` in the reconciliation report is the **old palette** —
   deprecated. Use forest.
4. **Progress fill = directionality-aware** (flex justify / `Row` honoring
   inherited `Directionality`), **not** `scaleX(-1)`, **not** hardcoded
   `Directionality.rtl`. Fill gradient teal→white at 60% (no heavy glow;
   the v2 surface is calmer than the stale HTML).
5. **Header date** splits into two lines (Hijri bold + Gregorian small).
   Add `hijriDate` + `gregorianDate` to `PrayerTimerStatus` **additively** —
   keep `fullDate` / `fullDateEn` (ASSUMPTION-4: never remove).
6. **Sunrise/sunset** in **both** compact and expanded; read from existing
   `PrayerType.sunrise` and `PrayerType.maghrib` in `allPrayers`. No new
   service fields, no API. (CONFLICT-2, A4 — resolved.)
7. **Expanded** hides the `at` prayer-time sub-text (the "next" chip in the
   5-prayer strip carries the time). (CORRECTION-D.)
8. **Loading** = skeleton (shimmer-free, same footprint). **Error inline** =
   `ErrorState.inline`. **Permission denied** = "Enable location for accurate
   prayer times" + Settings link.

---

## F · Open assumptions — confirmed

| Assumption | Ruling |
|---|---|
| A1 sunrise in `allPrayers` | Confirmed. Guard with null-check; hide row if absent. |
| A2 sunset = Maghrib | Confirmed. |
| A3 iOS widget uses int `remainingSeconds`, not `timeLeft` string | Confirmed safe to reformat to H:MM:SS. **Verify the one int key before committing** (cheap check). |
| A7 strip chips read-only | Confirmed. No tap-navigation from chips; whole card handles nav. |
| A8 colon not converted to Arabic-Indic | Confirmed. Only digits convert (existing `_toArabicNumerals`), and only when Arabic locale + Eastern Numerals on. |

---

## G · Revised phase gate (replaces Part 4–6 of the blockers doc)

| Phase | Status now |
|---|---|
| Phase 1 — domain (add `hijriDate`, `gregorianDate`, `secondsRemaining`; H:MM:SS format) | **GREEN** |
| Phase 2 — surface + loading/error (Stack glass, forest shadow, NO card BackdropFilter) | **GREEN** |
| Phase 3 — header (split date, frosted city pill, RTL pad fix) | **GREEN** |
| Phase 4 — hero (44px countdown, JetBrains Mono, name/time stack, nafl chip Option A) | **GREEN** — B3 + B5 + B6 resolved |
| Phase 5 — progress + sunrise/sunset (directionality-aware, gradient fill) | **GREEN** |
| Phase 6 — active-prayer calm state (label swap + name promote + dhikr text button) | **GREEN** — replaces old "animations" phase |
| Phase 7 — adhanMoment | **CANCELLED** — does not exist in v2 |
| Expanded variant | **GREEN, scoped to Prayer page + iPad only** (no on-card toggle) |

All six blockers cleared. **PR3 is fully unblocked.** No item remains
"awaiting designer."

---

## H · Behaviors still locked (unchanged — from behavioral audit B1–B15)

Full-card tap → PrayerDetailsPage · `isPrayerEnabled` / `isPrayerCardEnabled`
/ `prayerCardDisplayMode` gates · dynamic active windows (Fajr 40 / Maghrib
20 / others dynamic) · conditional dhikr affordance · Duha & Qiyam windows ·
midnight crossing · `_toArabicNumerals` · sunrise excluded from fard timeline
· local adhan-library computation. **None of these change in PR3.**
