# Focus — Oil-Fill Animation Spec

> The Focus screen is the **hero** of the redesign. The whole phone reads as a
> glass barrel slowly filling with thick black oil. The less time remaining,
> the faster and more aggressively the oil flows, eventually filling the
> entire screen. The animation responds to the device's gyroscope so the oil
> sloshes like a real liquid.

The visual target lives in `ui_kits/athar_app/FocusScreen.jsx` (a Canvas-based
React port of the metaphor). The Flutter implementation must reproduce the
**behavior**, not the JS code — port it idiomatically with `CustomPainter` +
`Ticker` + `sensors_plus`.

---

## 1 · Surface anatomy (top → bottom)

1. **Dynamic Island halo** — 1.5pt glossy oil rim clinging to the pill's
   bottom edge. Always present, even at 0% fill.
2. **Drip column** — vertical streak of oil descending from the Dynamic
   Island. Width pulses 8–14pt with slow noise. Tapers as it nears the surface.
3. **Oil mass** — viscous black fluid filling from the bottom.
   `fillHeight = lerp(0, screenHeight, 1 - timeRemaining/sessionDuration)`.
4. **Surface meniscus** — sum of two sines + slow vertical bob, tilted by
   gyroscope. See §3.
5. **Wall film** — thin sheen on the screen edges where oil has touched,
   above the current line. Decays after ~6 s when the line drops.

---

## 2 · Time-pressure → motion intensity

| Time remaining | Drip rate | Wave amp | Column pulse | Bubble rate |
|---|---|---|---|---|
| 100–66 % | 1 drop / 4 s | 2 pt | calm | none |
| 66–33 % | 1 drop / 1.5 s | 5 pt | medium | 1 / 8 s |
| 33–10 % | 2 drops / s | 9 pt | fast | 1 / 3 s |
| < 10 % | continuous stream | 14 pt + chop | aggressive | 2 / s |

At `0 s` the screen is fully filled; surface settles into a slow heavy bob —
session-complete state.

---

## 3 · Math (per frame, ~60 fps)

```
progress      = 1 - (timeRemaining / sessionDuration)
fillHeight    = screenHeight * progress
tiltRad       = degToRad(smoothedGamma)   // device left/right tilt
bob           = sin(t/600) * 1.5 + smoothedBeta * 0.3

surfaceY(x)   = (screenHeight - fillHeight)
              + tan(tiltRad) * (x - screenWidth/2)        // tilt
              + sin(x*0.018 + t/350 + seed) * waveAmp     // primary wave
              + 0.4 * sin(x*0.04  + t/180) * waveAmp      // secondary chop
              + bob
```

`waveAmp` and column-pulse magnitude come from the time-pressure tier.

---

## 4 · Drip particles

- Particle pool, ≤ 30 live drops.
- Each drop: `{ x, y, vy, r }`.
- Spawn at `(islandX ± colW/2, islandY + colHeight)` at the tier's rate.
- Per frame: `vy += 0.18`, `y += vy`, `x += sin(tiltRad) * 1.4` (tilt
  deflection — drops fall in **world space**, not screen space).
- When `y >= surfaceY(x)`: kill the drop, with 40 % chance spawn a bubble at
  the surface.
- Render as a teardrop bezier, solid `#000`.

---

## 5 · Gyroscope coupling

- Use `sensors_plus`'s `accelerometerEvents` (or `motionSensors` for Euler).
- Low-pass filter: `smoothed = smoothed*0.85 + raw*0.15`.
- Clamp gamma (left/right) to ±30° and beta (front/back) to ±20° around 30°
  rest.
- The drip column always falls **straight down in world space**. When the
  device is tilted, drops appear to fall diagonally relative to the UI.
- Sudden flip → splash up the side wall (briefly cling, then slide down).
  Implement as a one-shot particle burst at the high side when
  `|gammaDelta| > 25°/frame`.

---

## 6 · Render path (Flutter)

- Single `CustomPainter` inside a `RepaintBoundary`.
- `AnimationController(vsync: this, duration: const Duration(days: 1))..repeat()`
  — drives `t`, never stops.
- Painter inputs: `progress`, `tiltX`, `tiltY`, `t`, `tier`, plus a seedable
  RNG for drips/bubbles.
- Drops & bubbles live in `State` (mutable lists), not in the painter.
- **Do not** stack `AnimatedContainer`s — won't get the fluid feel.
- If `CustomPainter` can't hold 60 fps on iPhone 12, fall back to a
  full-screen quad fragment shader via `flutter_shaders`, sampling SDFs of
  fill + drips.

---

## 7 · Color & material

- Oil interior: pure `#000000`.
- Surface highlight: `rgba(255,255,255,0.07)`, 1.5 pt stroke along the
  meniscus.
- Secondary highlight: `rgba(255,255,255,0.025)`, 1 pt, 6 pt below meniscus.
- Wall film gradient: `transparent → rgba(0,0,0,0.09) → rgba(0,0,0,0.30)`,
  4 pt wide on each side.
- Bubble: `rgba(255,255,255, 0.06 * life)`.
- Bg behind oil: vertical gradient `#0d141a → #050709`, plus radial vignette
  `transparent → rgba(0,0,0,0.45)`.

---

## 8 · Accessibility

- **Reduce Motion** (`MediaQuery.disableAnimations` or
  `SettingsCubit.reduceMotion`): drip column → static dim line, surface →
  flat fill bar, gyro disabled. Time-pressure still affects opacity.
- **Disable gyroscope** (independent toggle): freeze `tiltX`/`tiltY` at 0.
- Timer numerals always render **above** the fill mask in solid `#FFF`.
  Never composite through the oil.

---

## 9 · Files to create / change (predict — verify in audit)

- `lib/features/focus/presentation/widgets/oil_background.dart` (new — painter)
- `lib/features/focus/presentation/widgets/oil_simulator.dart` (new — math + state)
- `lib/features/focus/presentation/screens/focus_screen.dart` — replace ambient widget
- `pubspec.yaml` — add `sensors_plus`, optionally `flutter_shaders`
- `lib/core/services/motion_preferences_service.dart` (new or extended)
- `lib/features/settings/...` — Reduce Motion + Disable Gyro toggles

---

## 10 · Audit checklist (return before coding)

1. Confirm the current FocusScreen Dart widget structure.
2. Is `sensors_plus` already a dep?
3. Does `FocusCubit.state` expose `progress` (0–1) and `timeRemaining`
   independently? If not, add.
4. Is there an existing `reduceMotion` flag in `SettingsCubit`?
5. Confirm Dynamic Island anchor: iPhone 14 Pro+ uses real island; older
   iPhones (no island) → drip emerges from a virtual 110×30 pt rect at
   `top: safeAreaTop + 11`.
6. Performance budget: lock 60 fps on iPhone 12. If not achievable with
   `CustomPainter`, escalate to `flutter_shaders`.
