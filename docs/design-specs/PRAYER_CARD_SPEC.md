# Prayer Card — Spec (PR3 reconciled)

> **Version:** v2.2 · reconciled against the real Flutter implementation
> **Reconciled:** 2026-06-01 — incorporates `PR3_DESIGN_RULINGS.md` (final) + the
> shadow 20/8 sign-off + RTL detail rescue.
> **Supersedes both repo copies:** the 104-line `handoff_v2-2` version (stale, 64px)
> AND the 313-line `/athar` root version (which carried a duplicated §8–§10 block).
> This is the single clean canonical — use it for `docs/design-specs/PRAYER_CARD_SPEC.md`.
> **Visual reference:** `preview/comp-prayer-card.html` (44px countdown — canonical)
> **Code reference:** `lib/core/design_system/molecules/cards/next_prayer_card.dart` + `smart_prayer_wrapper.dart`
>
> This spec replaces every earlier prayer-card description in the handoff.
> **Precedence is fixed: this file is the single source of truth.** The old
> "HTML wins on conflict" rule is retired — spec text and the canonical
> preview now agree. Any copy showing a **64px** countdown (e.g. `handoff_v2-2`)
> is **stale**; the locked size is **44px** (see `PR3_DESIGN_RULINGS.md §B`).
> Where any earlier doc says "64pt countdown", "ALLAHU AKBAR moment",
> "Start dhikr pill", or "adhanMoment state" — **this file + the rulings win**.

---

## 0 · Emotional brief (read first)

Athar's prayer card is **not a timer**. It is a calm, glanceable, spiritual
companion. The user should feel:

- **Aware**, not pressured
- **Grounded**, not rushed
- **Reverent**, not entertained

The card lives at the top of the Dashboard. It earns its space by being
**peaceful, balanced, and small enough that habits / tasks / focus stay
visible below it on every supported device.** If a design choice makes the
card louder, more urgent, or more dominant than the rest of the dashboard,
the choice is wrong — even if it looks "premium" in isolation.

Hard rules that follow from this brief:

- The countdown is information, not drama. **44pt, weight 300, mono numerals.**
- No pulsing, no continuous animation, no looping shimmer.
- No "ALLAHU AKBAR" cinematic moment. Adhan is the dramatic moment;
  the UI stays calm.
- The card never grows on prayer entry. State changes are color + label only.

---

## 1 · Surface

- **Shape:** rounded rectangle, `radius-xxl` (24pt). Full-bleed inside
  Dashboard horizontal padding (16pt phone / 24pt tablet).
- **Fill:** brand gradient `linear-gradient(135deg, #0F3D2E 0%, #1A5A45 100%)`
  (forest deep → forest mid). Same gradient light + dark — the card is the
  one place in the app where the surface stays "night sky" regardless of theme.
- **Glass overlay:** subtle radial highlights (top-right warm cream tint at
  6% opacity, bottom-left forest deepening) + 1pt inner hairline at 12%
  white. Single static layer — **no animated shimmer.**
- **Shadow:** two-layer forest shadow — `0 8px 20px rgba(15,61,46,.45)` (deep) +
  `0 2px 8px rgba(26,90,69,.20)` (mid). Same in dark mode. **blurRadius 20/8 is
  canonical as of the 2026-06-01 sign-off. Do not restore 42/12.**
- **Padding:** 20pt vertical, 22pt horizontal.

---

## 2 · Variants

Two visual variants. Selection is **widget-local state** (default `compact`)
— **not** a new `UserSettings` field. (Per Package A #4 + investigation
reconciliation: `UserSettings.prayerCardDisplayMode` already exists and
controls *where* the card surfaces, not *which variant* renders.)

### 2a · Compact (default)
Height ≈ 200pt. Content order top → bottom:
1. **Header row** — Hijri date (primary, Calibri 14pt/700, white) +
   Gregorian secondary (11pt, white 60%). Right side: city pill (11.5pt,
   white 70%, glass background, 1pt white-14% border).
2. **Hero block** (centered):
   - Label: "Next prayer" / "الصلاة القادمة" (11pt/600, letterspaced,
     white 55%).
   - Prayer name: 22pt/700 Calibri (Arabic uses RTL form, English shows
     bilingual e.g. "المغرب · Maghrib").
   - At time: 12pt mono, white 70%.
   - **Countdown: 44pt, weight 300, mono, white, letter-spacing -1pt.**
     Seconds render at 26pt/55% opacity, 6pt offset. Tabular numerals.
3. **Sunrise / Sunset markers** — single row, 10.5pt mono, white 55%,
   small icons. Sunrise on left (LTR) / right (RTL); Sunset opposite.
   Source: existing `PrayerType.sunrise` and `PrayerType.maghrib` values
   already returned by `PrayerCubit`. No new data source.
4. **Progress bar** — 5pt height, white-14% track, accent fill
   `linear-gradient(90deg, #7FE3DA, #fff)` at 60% opacity, soft glow.
   **RTL fix:** progress fills from the trailing edge; resolve via
   `Directionality.of(context)`, not a hardcoded `scaleX(-1)`.

### 2b · Expanded (opt-in)
Height ≈ 280pt. Same header + hero block (drops the sunrise row from the
hero — moves it below). Adds:
- **All-prayers strip** (5 cells, equal width, 6pt gap):
  - Past: opacity 0.45, time strikethrough at 30%.
  - Next: glass background `rgba(127,227,218,.18)`, 1pt accent border, soft
    glow shadow, name + time bold.
  - Future: glass background `rgba(255,255,255,.06)`.
  - Each cell: prayer name (10.5pt Calibri, white 60%) above time
    (13pt mono, white).
- **Sunrise / sunset row** beneath the strip (same treatment as compact).

The expanded variant is a **dashboard density choice**, not a different
feature. The compact variant remains the default; expanded is for users
who want all five times glanceable from the home screen.

---

## 3 · Tap behavior (single primary action)

The card has **one primary action**: tap anywhere on the card → push
`PrayerDetailsPage` (existing route, today/week/month tabs). This already
exists in production and is what users expect.

There is **no separate "Start dhikr" CTA on the card.** Post-prayer dhikr
surfaces through the existing temporal flow described in §4. Adding a
button to the card would create two competing CTAs and break the calm
hierarchy.

The whole card is the touch target. Use `InkWell` with the card's radius
clipped, not a bare `GestureDetector`, so the press state honors theme.

---

## 4 · Post-prayer dhikr (preserved behavior — DO NOT REDESIGN)

This flow is already correct in production and must not be altered by PR3.
Documenting it here so no later change accidentally breaks it.

- After a prayer's start time, a **post-prayer athkar surface** becomes
  active for a **per-prayer window**. Formula (canonical,
  `prayer_timer_service.dart:50–58`):
  `round(0.3 × minutesBetween(prevPrayer, nextPrayer))`, clamp(15, 45) min,
  with overrides after clamp: Fajr = 40 min, Maghrib = 20 min.
  (Earlier drafts said flat 40 min — oversimplified; the dynamic formula is
  canonical. The iOS widget mirrors it exactly.)
- During that window, the dashboard's calm-awareness state shifts: the
  prayer card's hero row swaps the countdown for a "After {prayer}"
  affordance that deep-links into the post-prayer athkar set. Visual
  treatment: same surface, same calm typography — only the label and
  destination change. **No animation transition.** State swaps on the
  next second-tick.
- After the window elapses, the card returns to its normal "next prayer"
  state automatically.
- The window is **per prayer**, not a session timer the user starts.
  Do not add controls for it.

PR3 implementation note: this swap is already wired through
`PrayerCubit` + `SmartPrayerCardWrapper`. PR3 should preserve the
behavior and only restyle the surface. If you find yourself adding state
machines to handle this, stop — it's already there.

---

## 5 · Nafl badges (preserved behavior — DO NOT REDESIGN)

The card surfaces **two contextual nafl indicators** that are already
wired in production. Treat them as small, low-emphasis chips that sit
inside the hero block (below the countdown, above sunrise/sunset).

| Nafl | Visible when | Label (AR · EN) |
|---|---|---|
| **Duha** (الضحى) | ~15 min after sunrise → ~15 min before Dhuhr | الضحى · Duha |
| **Qiyam / last third of night** (قيام / الثلث الأخير) | last third of the night, near Witr timing | قيام · Qiyam |

**Note from investigation:** earlier docs mentioned "Witr after Isha". The
real production logic surfaces **Qiyam during the last third of the night**,
not a simple post-Isha Witr badge. Use the existing `PrayerCubit`
boolean(s) — do not invent new ones.

Visual treatment:
- Pill, height 22pt, padding 4pt × 10pt.
- Background: `rgba(255,255,255,.10)` glass, 1pt white-14% border, no
  shadow.
- Text: 11pt Calibri, weight 600, white 85%, bilingual.
- Dot prefix: 5pt circle in `#7FE3DA` accent (calm, not bright).
- Max one nafl chip visible at a time. They never overlap each other.
- **Compact variant:** chip sits centered between countdown and
  sunrise/sunset row. Adds ~28pt to compact height when present.
- **Expanded variant:** chip sits to the right of the prayer name in the
  hero block (same row), so the all-prayers strip and chip don't compete
  for vertical space.
- **Visibility:** opt-in via existing `UserSettings` flag (already exists
  per investigation report — reuse, don't add). Hidden by default for
  users who haven't enabled nafl reminders.

---

## 6 · Prayer-start state (calm, not cinematic)

When a prayer's start time is reached, **no celebratory animation
fires**. The current production behavior already gives sufficient signal
through the adhan audio (which the user actually hears) and the
post-prayer dhikr swap described in §4.

Visual changes on prayer start:
- Hero label changes from "Next prayer" → "Now" / "الآن" (same typography,
  same position).
- Countdown is replaced by a 12pt mono "Started at HH:MM" stamp. The
  44pt clock area becomes the prayer name at 36pt/700 Calibri instead —
  promoting the *name* of what's happening over time-elapsed.
- All-prayers strip (expanded) marks the current prayer with the "next"
  treatment instead of advancing.
- Transition: 250ms cross-fade. No scale, no slide, no haptic.

Do not add: pulse rings, particle effects, full-screen takeovers,
"ALLAHU AKBAR" overlay, custom adhan visualizer, sound waves around the
card, screen-edge glow, or any animation tied to the audio. The audio
itself is the moment.

---

## 7 · Countdown sizing — final answer

After the visual density simulation in `PR3_VISUAL_DENSITY_SIMULATION.md`
the locked sizes are:

| Element | Size | Weight | Notes |
|---|---|---|---|
| Hours/minutes (`H:MM`) | **44pt** | 300 (light) | Mono, tabular, white, -1pt letter-spacing |
| Seconds (`:SS`) | 26pt | 300 | 55% opacity, 6pt offset, mono |

44pt was chosen because:
- 64pt creates emotional urgency (a productivity-app feeling) and pushes
  habits/tasks below the fold on iPhone SE / iPhone mini.
- 52pt is acceptable but begins to dominate on smaller devices.
- 44pt is glanceable, calm, and leaves headroom for habits/tasks/focus
  to share the first viewport.

**Tablet (iPad):** scales to 56pt. The card's max-width is capped at
480pt regardless of column width (per `IPAD_OPTIMIZATION.md`).

**Compact mode (small phones, height < 700pt):** drop to 40pt
automatically. Detect via `MediaQuery.sizeOf(context).height`.

---

## 8 · Localization & RTL

- All Arabic text in **Calibri** (per Package A #1 lockdown). Cairo, Inter,
  and Tajawal references in earlier drafts are deprecated.
- Bilingual prayer names in English locale render as `الفجر · Fajr`,
  `الظهر · Dhuhr`, etc. — Arabic name first, separator U+00B7, Latin name.
- City name from `PrayerCubit.locationName` (already populated).
- Hijri date from `AtharTimeCalculator.hijri()` (existing); Gregorian from
  `intl` `DateFormat.yMMMEd(locale)`. Both honor app locale, not device.
- Hindi-Arabic numerals (٠١٢٣٤٥٦٧٨٩) only when locale is Arabic AND
  `UserSettings.useArabicNumerals == true` (per Package A #2:
  `isHijriMode` controls primary numeral system).
- Progress bar fill anchors to the trailing edge in RTL (use a `Row`
  with `Directionality`, not a CSS `scaleX` flip in Flutter).
- **Header swap (RTL):** the city pill and date block mirror sides automatically
  via `EdgeInsetsDirectional` — do not hardcode left/right.
- **All-prayers strip (RTL):** cells read in natural reading order (Fajr at the
  start → Isha at the end); the strip reverses via `Directionality`, not a manual
  list reversal.
- **Countdown numerals stay Western (LTR)** even in Arabic locale UNLESS
  `Accessibility.easternNumerals == true` (PR5) — then they render Eastern. The
  clock digits never reorder; only the glyph set changes.
- **Prayer-name strings** come from ARB keys `prayer.fajr` … `prayer.isha`
  (the bilingual `الفجر · Fajr` form is composed in the widget); do not hardcode names.

---

## 9 · Accessibility

- Whole card is one semantic node: `Semantics(button: true, label:
  "Next prayer Maghrib in 1 hour 14 minutes. Tap to open prayer
  details.")`. Update label every minute, not every second — the
  countdown ticking is decorative.
- Min target: full card (always > 88pt tall, far above 44pt floor).
- Color contrast: white on forest gradient measures 9.8:1 (AAA). Accent
  `#7FE3DA` on forest gradient measures 5.4:1 (AA Large). Acceptable
  because accent only carries non-essential reinforcement (chip dot,
  progress fill).
- Reduce-motion (`MediaQuery.disableAnimations`): the 250ms prayer-start
  cross-fade collapses to instant. Countdown still ticks (it's
  information, not motion).
- VoiceOver / TalkBack reads the card as a single button; nafl chips
  read as separate semantic children with their own labels.

---

## 10 · States the card must handle

| State | Visual |
|---|---|
| Loading (cold start, no `PrayerLoaded` yet) | Skeleton: same surface, all text replaced with shimmer-free placeholder bars at 22% white. No animation. |
| No location permission | Surface unchanged. Hero replaced by "Set location" CTA (one-line, deep-links to Settings → Location). City pill hidden. |
| Location set, prayer times unavailable (network error first run) | Surface unchanged. Hero shows "—:—" with caption "Couldn't load prayer times" + retry icon (small, top-right of hero). |
| Prayer-start window (active prayer) | §6 calm state. |
| Post-prayer window (per-prayer formula — see §4) | §4 dhikr swap. |
| `isPrayerEnabled = false` | Card is hidden entirely (handled upstream by `SmartPrayerCardWrapper`). |
| `isPrayerCardEnabled = false` | Card hidden, prayer notifications still active. |
| `prayerCardDisplayMode = dashboardOnly` (default) | Card on Dashboard only. |
| `prayerCardDisplayMode = dashboardAndTasks` | Also on Tasks page header. |
| `prayerCardDisplayMode = allPages` | Also on every primary page header. |

---

## 11 · What changed vs. the previous spec

| Field | Was | Now |
|---|---|---|
| Countdown size | 64pt (one earlier draft) / 52pt (another) | **44pt** locked |
| "ALLAHU AKBAR" moment | Cinematic transition described | **Removed.** Calm color/label swap only |
| "Start dhikr" CTA | Pill button on card | **Removed.** Whole card → PrayerDetailsPage; dhikr surfaces via existing 40-min window |
| Pulse / shimmer / shimmer-on-active | Mentioned in earlier drafts | **Removed.** No continuous animation |
| Nafl badges | "Duha + Witr" (incorrect) | **Duha + Qiyam (last third of night)** — matches production |
| Sunrise/sunset data source | Earlier draft asked for new model field | **Reuse** existing `PrayerType.sunrise` / `.maghrib` from `PrayerCubit` |
| Variant routing | "Add `prayerCardVariant` to UserSettings" | **Widget-local state.** `UserSettings.prayerCardDisplayMode` controls placement, not visual variant |
| Post-prayer flow | Described as new design work | **Preserve existing behavior.** Per-prayer dynamic window already wired; PR3 only restyles the surface |
| Progress-bar RTL | `transform: scaleX(-1)` | **`Directionality`-aware** trailing-edge fill |
| Shadow blurRadius | 42/12 (earlier spec) | **20/8 canonical** — approved 2026-06-01; forest colors unchanged |
| Arabic font | Cairo (earlier drafts) | **Calibri only** (Package A lockdown) |

---

## 12 · Out of scope for PR3

- New animations of any kind.
- New `UserSettings` fields.
- Changes to `PrayerCubit` state shape or refresh cadence.
- Changes to the post-prayer window formula (dynamic; canonical in `prayer_timer_service.dart:50–58`).
- Adhan audio handling (covered by PR-ADHAN, separate).
- iOS widget visuals **and data sync** (covered by `IOS_WIDGETS_SPEC.md` +
  `docs/ai/WIDGET_INDEX.md`: App Group `UserDefaults` payload +
  `WidgetKit.reloadTimelines` trigger). The widget must mirror this card's calm
  hierarchy 1:1. If that sync behavior is not yet documented there, capture it in
  `WIDGET_INDEX.md` — it does **not** live in this spec.

If a request to PR3 falls into any of these, route it to a separate PR
and reference it from `FINAL_PACKAGE_MANIFEST.md`.
