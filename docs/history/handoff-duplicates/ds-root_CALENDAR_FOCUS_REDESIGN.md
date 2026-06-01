# Calendar & Focus — Redesign Brief

> **Workflow:** Claude Code reads this **before** touching code. Step 1 is an audit
> of the existing screens against the spec below. Step 2 is producing a **gap
> report** (what already exists, what's missing, what's wrong) and handing it
> back here for review. Only after the gap is signed off does implementation
> begin in `lib/features/calendar/` and `lib/features/focus/`.

---

## A · Calendar — Dual Hijri + Gregorian (Apple-Calendar style)

### Goal
Both calendars are visible **simultaneously**, not toggled. The Hijri date is
not a footnote — it sits **inside every day cell** alongside the Gregorian
number, like Apple Calendar's secondary calendar overlay (Settings ▸ Calendar ▸
Alternate Calendars ▸ Islamic).

### Current state (what to audit)
- `ui_kits/athar_app/CalendarScreen.jsx` — has a single `Hijri ⇄ Gregorian`
  toggle button. The grid shows Gregorian numbers only.
- The Hijri month label appears under the Gregorian title only when toggled.

### Target behaviour

| Element | Spec |
|---|---|
| Header title | `January 2025` (Gregorian primary) with `جمادى الآخرة – رجب ١٤٤٦` (spanning Hijri months) below in `var(--font-ar)`, smaller. |
| Month switcher | Two parallel rows of pills — Gregorian months on top, Hijri months below — both scroll independently. Tapping either re-anchors the grid. |
| Day cell | Top-right corner: small Gregorian number (14px). Bottom-left corner: smaller Hijri numeral in Arabic-Indic digits (10px, `var(--text-tertiary)`). Activity dots row stays in the middle. |
| Today | Cell gets the forest tint background, both numbers go bold-forest. |
| Selected | Cell goes solid forest, both numbers cream. |
| First-of-Hijri-month | Day cell gets a **2px hairline** along its top edge in `var(--forest-light)` and the Hijri month name (e.g. `رجب`) replaces the Hijri numeral that day. |
| Day sheet | Header line shows both: `Wed, 15 Jan · ١٥ رجب`. |
| Locale flip | When `Directionality.of(context) == rtl`, Hijri swaps to top-right and Gregorian to bottom-left — Arabic readers see Hijri primary. |

### Flutter implementation notes
- Use `package:hijri/hijri_calendar.dart` (already in `pubspec.yaml` per
  manifest — verify) for conversion. **Audit must confirm.**
- Build a `DualDate` value object: `{ DateTime gregorian, HijriCalendar hijri,
  bool isFirstOfHijriMonth }`. Generate one per cell up front, don't
  re-convert on every paint.
- `CalendarCell` widget takes `DualDate` + state (today/selected/has-activity).
- All day-cell content must respect `EdgeInsetsDirectional` so the
  primary/secondary numerals flip in RTL automatically.
- Existing `activityFor(d)` in the JSX mock is just dummy data — wire to
  `CalendarCubit.state.activityByDate` (audit the real cubit signature).

### Files to touch (predict — verify in audit)
- `lib/features/calendar/presentation/widgets/calendar_grid.dart`
- `lib/features/calendar/presentation/widgets/calendar_cell.dart` (likely new)
- `lib/features/calendar/presentation/widgets/dual_month_switcher.dart` (new)
- `lib/features/calendar/domain/entities/dual_date.dart` (new)
- `lib/features/calendar/presentation/cubit/calendar_cubit.dart` — add Hijri
  anchoring methods if absent.
- `lib/features/calendar/presentation/screens/calendar_screen.dart` — header.

### Audit checklist (return to designer before coding)
1. Is `package:hijri` already a dep? If not, propose adding it.
2. Where does the existing `CalendarCubit` live and what's its state shape?
3. Is there already a `DualDate`-equivalent? (search for `Hijri`, `umAlQura`.)
4. Are activity dots driven by a stream or one-shot? Will dual-rendering
   require any extra fetches?
5. Is the existing month-switcher widget reusable or does it need a fork?

---

## B · Focus — "Liquid oil" timer with gyroscope physics

### Goal
Replace the current floating-blob ambient background with a **single
physics-simulated black oil** that drips from the Dynamic Island area downward
and fills the screen as the focus timer counts down. The whole phone reads as a
glass barrel filling with oil.

### Current state (what to audit)
- `ui_kits/athar_app/FocusScreen.jsx` — two CSS radial-blur orbs floating with
  keyframes. Static. No fill metaphor. No motion physics. No gyroscope.
- The progress is communicated only via the SVG ring around the timer.

### Target visual + motion spec

**Surface anatomy (top → bottom):**

1. **Dynamic Island halo** — a tight 1.5pt rim of glossy oil clinging to the
   pill's bottom edge. Always present, even at 0% fill.
2. **Drip column** — a vertical streak of oil descending from the Dynamic
   Island. Width pulses gently (8–14pt) with a slow noise. Tapers as it
   approaches the oil surface.
3. **Oil mass** — viscous black fluid that fills the screen from the bottom.
   Fill level = `1 - (timeRemaining / sessionDuration)`. **The less time
   remaining, the higher the surface and the faster everything moves.**
4. **Surface meniscus** — a horizontal wave at the oil/air boundary. Two
   sine waves (one slow + one fast) summed, plus subtle vertical bobbing.
   Reflects the timer ring above when fill is high enough to overlap.
5. **Wall film** — a thin sheen on the screen edges where oil has touched,
   above the current fill line. Decays after ~6s when below the new line.

**Time pressure → motion intensity (key relationship):**

| Time remaining | Drip rate | Surface wave amplitude | Drip column width pulse | Bubble rate |
|---|---|---|---|---|
| 100–66% | 1 drop / 4s | 2pt | calm | none |
| 66–33% | 1 drop / 1.5s | 5pt | medium | 1 / 8s |
| 33–10% | 2 drops / s | 9pt | fast | 1 / 3s |
| <10% | continuous stream | 14pt + chop | aggressive | 2 / s |

At `0` remaining the screen is fully filled and the surface settles into a
slow heavy bob — the "session complete" state.

**Gyroscope / gravity coupling:**

- Tilt the device → oil surface tilts the **opposite** direction (it stays
  level relative to gravity, like real liquid in a glass).
- Roll → mass of oil sloshes left/right, with inertia (lag ~120ms behind
  device motion, then rebounds).
- Sudden flip → splash up the side wall, briefly clinging then sliding back
  down.
- The drip column always falls straight down in **world space**, not screen
  space — when tilted it appears to drip diagonally relative to the UI.

### Implementation — Flutter

**Render path:** `CustomPainter` inside a `RepaintBoundary`, driven by a
`Ticker` (~60fps). Do **not** use stacked `AnimatedContainer`s — won't get the
fluid feel.

**Three sample-able fields, composited per frame:**

1. **Fill height** `h(t) = lerp(0, screenHeight, progress)` where `progress`
   ramps with the timer.
2. **Surface y(x, t)** — sum of two sines:
   `y = h + A·sin(k₁·x + ω₁·t) + 0.4·A·sin(k₂·x + ω₂·t + φ)`
   with `A`, `ω₁`, `ω₂` scaled by the time-pressure tier above.
3. **Tilt offset** from `accelerometerEvents` (package
   `sensors_plus`) — low-pass filtered (alpha ≈ 0.15) and used as both:
   - Rotation of the surface line about the screen centre.
   - Horizontal CoM offset of the oil mass (sloshing).

**Drip stream** — particle system, ≤30 live drops at any time. Each drop:
`{ x, y, radius, velocity }`. Spawn rate = time-pressure tier. Gravity in
world frame. Merges into the surface when `y >= surface(x)`.

**Oil look** — pure black `#000` interior, **subtle** sheen at top edge using a
linear gradient from `rgba(255,255,255,.05)` (top) to transparent (8pt down).
The Dynamic Island rim and drip column carry the same sheen so the oil reads
as a single connected body.

**Performance budget** — must hold 60fps on iPhone 12. If `CustomPainter`
proves too heavy, fall back to a Flutter `ShaderBuilder` fragment shader
(`flutter_shaders`) — single full-screen quad sampling SDFs of fill + drips.

### Accessibility / settings
- Setting: **Reduce Motion** → drip column becomes a static dim line, surface
  becomes a flat fill bar, gyro disabled. Time-pressure still affects opacity.
- Setting: **Disable gyroscope** independent of Reduce Motion (some users get
  motion sick from sloshing alone).
- Always-on text contrast: timer numerals stay solid `#FFF`, never composited
  through the oil — render them above the fill mask.

### Files to touch (predict — verify in audit)
- `lib/features/focus/presentation/widgets/oil_background.dart` (new — main painter)
- `lib/features/focus/presentation/widgets/oil_simulator.dart` (new — math)
- `lib/features/focus/presentation/screens/focus_screen.dart` — replace the
  current ambient widget.
- `pubspec.yaml` — add `sensors_plus`, optionally `flutter_shaders`.
- `lib/core/services/motion_preferences_service.dart` (new or extended).

### Audit checklist (return to designer before coding)
1. What does the current FocusScreen widget look like in real Dart? (the JSX
   is a recreation — confirm the Flutter version matches.)
2. Is `sensors_plus` already a dep?
3. Is there an existing motion-reduce flag in `SettingsCubit`?
4. Does `FocusCubit.state` expose `progress` (0–1) and `timeRemaining`
   independently? If not, add.
5. Confirm the Dynamic Island region size on target devices — needed for
   correctly anchoring the drip column on iPhone 14 Pro+ vs. iPhone SE
   (which has no Dynamic Island — fallback to a simple top-edge drip).

---

## Handoff format

When Claude Code completes the audit it writes
`design-context/_audit_calendar_focus.md` containing, for each section above:

1. **Files inspected** (paths + line ranges).
2. **What's already there** — green-tick items from the spec.
3. **Gaps** — red items, with the exact file/line where the change goes.
4. **Open questions** for the designer — anything ambiguous in the spec that
   needs a decision before implementation.

Designer reviews that file, answers the open questions inline, and only then
greenlights the actual code changes.
