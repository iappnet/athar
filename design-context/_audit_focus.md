<!--
AUDIT: PR8 — Focus Oil-Fill
AUDITOR: Claude Code
DATE: 2026-06-02
STATUS: Complete — awaiting designer sign-off
SPEC: docs/design-specs/FOCUS_OIL_SPEC.md
NO DART MODIFIED IN THIS SESSION
-->

# PR8 Focus Oil-Fill — Pre-Implementation Audit

---

## Files Read

| File | Lines | Purpose |
|------|-------|---------|
| `docs/design-specs/FOCUS_OIL_SPEC.md` | 154 | Full spec |
| `lib/features/focus/presentation/pages/focus_page.dart` | 585 | Main screen |
| `lib/features/focus/presentation/widgets/oil_animation.dart` | 444 | Active oil painter |
| `lib/features/focus/presentation/widgets/fluid_engine.dart` | 906 | Dead prototype (not used) |
| `lib/features/focus/presentation/widgets/focus_body.dart` | 2 | Dead stub (not used) |
| `lib/features/focus/presentation/cubit/focus_cubit.dart` | 323 | Timer cubit |
| `lib/features/focus/presentation/cubit/focus_state.dart` | 25 | State classes |
| `lib/features/settings/data/models/user_settings.dart` | (grep) | PR5 fields |
| `lib/features/settings/presentation/cubit/settings_cubit.dart` | (grep) | PR5 toggles |
| `lib/features/settings/presentation/cubit/settings_state.dart` | (grep) | PR5 props |
| `lib/features/settings/presentation/pages/general_settings_page.dart` | (grep) | PR5 UI |
| `lib/core/services/focus_mode_service.dart` | 30 | DND service (unrelated) |
| `pubspec.yaml` | (grep) | Dep check |

---

## §10 Spec Checklist

### 1 — Current FocusScreen widget structure ✅

**Entry:** `focus_page.dart` — `StatefulWidget` + `_FocusPageState`.

**Widget tree:**
```
BlocProvider<FocusCubit>
  Builder
    BlocListener<FocusCubit>   ← captures _sessionTotalSeconds on first FocusRunning
      Scaffold(backgroundColor: Colors.black, extendBodyBehindAppBar: true)
        body: BlocBuilder<FocusCubit>
          Stack
            Positioned.fill → OilBottleAnimation(fillLevel, isRunning)  ← oil layer
            SafeArea
              Column
                _TopBar          ← back + tune glass buttons (46pt circles)
                Spacer
                _FocusTargetBadge? ← task context pill (conditional)
                _DurationSelector  ← chips 15/25/45/60 min (FocusInitial only)
                _TimerDisplay      ← 70sp glass card + status label
                Spacer
                _Controls          ← state-switched: Start FAB / Pause+Stop / Resume+Reset / Replay
                AtharGap.huge      ← ~40pt bottom clearance
```

**States → controls rendered:**
| State | Controls rendered |
|-------|------------------|
| `FocusInitial` | 88pt amber gradient circle (play icon) |
| `FocusRunning` | Pause (amber) + Stop (red) circles, 60pt |
| `FocusPaused` | Resume (amber, 72pt, large) + Reset (grey, 60pt) |
| `FocusCompleted` | Replay (amber, 72pt) |

#### Control-contrast risk assessment

**Timer display** (`_TimerDisplay`): `Colors.black @ alpha 0.45` backdrop + amber border + spread box-shadow. Timer numerals solid white. **PASS** — satisfies spec §8 "timer numerals always above fill mask in solid #FFF".

**Top-bar glass buttons** (`_GlassButton`): `white @ alpha 0.07` fill, icon `white @ alpha 0.75`. These sit in the SafeArea top zone. Oil fills from the bottom, so the top bar overlays dark oil only in the final 20% of a session. At that point white-on-black icons at alpha 0.75 are still readable. **LOW RISK.**

**Bottom controls** (`_CtrlBtn`): `color @ alpha 0.12` fill + `color @ alpha 0.4` border. When `fillLevel > 0.80` the oil surface crests near the controls zone. The control backgrounds have almost no opacity against the dark oil body (`#1A0900`). **MEDIUM RISK** — circles will float on dark oil with very thin borders. The label text (`alpha 0.85`) should hold but the icon container itself may lack distinct boundary. **Flagged for designer review on implementation.**

**Hardcoded Arabic strings (ARB gap):** `_showExitDialog`, `_showDurationSheet`, `_TimerDisplay` status labels, `_Controls` "جلسة جديدة" — all hardcoded, outside the ARB system. Pre-existing issue, not PR8's primary scope, but PR8 will touch this file so worth sweeping during implementation.

---

### 2 — sensors_plus / flutter_shaders deps ✅ / ❌

| Package | Status | Action |
|---------|--------|--------|
| `sensors_plus: ^4.0.2` | ✅ **Already in pubspec.yaml:97** | No change |
| `flutter_shaders` | ❌ Not present | Deferred — see §6 perf recommendation |

`sensors_plus` is already imported and in use in `oil_animation.dart:4` via `gyroscopeEventStream`. No pubspec change needed for sensor integration.

---

### 3 — FocusCubit state: `progress` and `timeRemaining` ⚠️ Gap

**Current state class (`focus_state.dart`):**
```dart
abstract class FocusState {
  final int duration;   // seconds REMAINING (countdown)
}
class FocusRunning extends FocusState { ... }
class FocusPaused  extends FocusState { ... }
class FocusCompleted extends FocusState { super(0); }
```

**What exists:**
- `state.duration` = `timeRemaining` in seconds ✅ (it IS timeRemaining)
- `progress` (0–1) = NOT in state — computed in `_FocusPageState._fillLevel()` using a page-local `_sessionTotalSeconds` int captured on first `FocusRunning` tick.
- `sessionDuration` = NOT in state — only available as `cubit._selectedDuration` (private) or via `cubit.currentDurationMinutes * 60` (public getter exists).

**Gap for PR8:** The spec's tier logic requires `progress = 1 - timeRemaining / sessionDuration`. The painter needs `progress` AND the current intensity `tier`. Both require `sessionDuration` at paint time. Currently `sessionDuration` is page-local and not in any state class.

**Minimal additive change (no breaking change to existing state):**
1. Add public getter `int get sessionDuration => _selectedDuration` to `FocusCubit`. (Or reuse existing `currentDurationMinutes * 60`.)
2. In `focus_page.dart` (or future `focus_screen.dart`), compute: `final progress = _sessionTotalSeconds > 0 ? 1.0 - state.duration / _sessionTotalSeconds : 0.0;`
3. Pass `progress`, `timeRemaining` (= `state.duration`), and a `tier` enum (derived in page from progress) to the painter.

**No state class changes required.** `FocusRunning` and `FocusPaused` do not need new fields.

---

### 4 — PR5 flags: `reduceMotion` + `disableGyroscope` ✅ Confirmed

| Flag | UserSettings field | SettingsLoaded.props | Toggle method | Settings UI |
|------|-------------------|---------------------|---------------|-------------|
| `reduceMotion` | ✅ line 203 | ✅ line 42 | `toggleReduceMotion(bool)` cubit:477 | general_settings_page.dart:272 |
| `disableGyroscope` | ✅ line 204 | ✅ line 43 | `toggleDisableGyroscope(bool)` cubit:483 | general_settings_page.dart:282 |

**Read path (PR8 consumer):**
```dart
// In _OilBottleAnimationState (or oil_simulator.dart)
final settingsState = context.watch<SettingsCubit>().state;
final settings = settingsState is SettingsLoaded ? settingsState.settings : null;

// OR pattern per PR5 ruling:
final reduceMotion = (settings?.reduceMotion ?? false)
    || MediaQuery.of(context).disableAnimations;

// Independent gyro flag:
final disableGyroscope = settings?.disableGyroscope ?? false;
```

`SettingsCubit` is in the global `MultiBlocProvider` (app.dart) — accessible from any descendant context. No new injection or BlocProvider needed at the focus screen level.

**Reduce-motion fallback (spec §8, designer-approved):**
- `disableAnimations == true`: drip column → static dim line, surface → flat fill bar, gyro off
- Time-pressure still drives opacity change
- Gyro freeze: pass `tiltX = 0, tiltY = 0` to painter; cancel gyroscope stream subscription

---

### 5 — Dynamic Island anchor

**Current code** (`oil_animation.dart:225`): hardcoded constants in `paint()`:
```dart
const islandW = 120.0;
const islandH = 34.0;
const islandTop = 18.0;   // ← does not adapt to device
```
Always draws at `y=18`, regardless of real island presence.

**Detection — no `device_info_plus` required:**

Flutter's `MediaQuery.of(context).padding.top` reflects the true safe-area top inset:
- iPhone 14 Pro / Pro Max (Dynamic Island): ~59pt
- iPhone 14 / 14 Plus, 13, 12 (notch / no notch): ~44–47pt
- Heuristic: `padding.top >= 51` → Dynamic Island present

**Anchor computation (pass to painter as `islandAnchorY`):**
```dart
final topPadding = MediaQuery.of(context).padding.top;
final hasRealIsland = topPadding >= 51;
// Dynamic Island: pill sits just below status bar
final islandTop   = hasRealIsland ? topPadding - 12 : topPadding + 11;
final islandW     = 120.0;
final islandH     = hasRealIsland ? 34.0 : 30.0;
```

For older devices the spec mandates a **virtual 110×30pt rect at `top: safeAreaTop + 11`**. Pass computed `islandTop`, `islandW`, `islandH` as parameters to `OilBackground`. No new package required.

---

### 6 — Performance budget ⚠️ Recommendation

**Current animation loop:**
- `AnimationController(duration: Duration(seconds: 1))..repeat()` → vsync-driven, effectively 60fps ✅
- `addListener(_onFrame)` → each tick: integrate tilt, advance `_wavePhase`, spawn/update drops, `setState(() {})` ✅
- `_OilPainter.shouldRepaint` always returns `true` ✅

**What the painter does per frame:**
1. Fill background (`drawRect`) — trivial
2. `_drawIsland` — 1–2 RRect + conditional outer blur (`MaskFilter.blur(outer, 10)`) ⚠️
3. `_drawOil` → 48-segment path + linear gradient shader ✓
4. `_drawSurface` → 48-segment path + `MaskFilter.blur(normal, 5)` ⚠️ + 1.5pt stroke
5. `_drawSubsurfaceSheen` → 32-segment path + `MaskFilter.blur(normal, 8)` ⚠️
6. Per drop (≤ ~15 in practice): `drawOval` + `drawCircle` ✓
7. `_drawEdges` → `RadialGradient` + 2× linear gradient `drawRect` ✓

**`MaskFilter.blur` in the hot path is the primary risk.** Each blur forces the GPU to run a separate Gaussian pass on that layer. With 2–3 blurs per frame at 60fps on iPhone 12 (A14 Bionic), it should be achievable but is not free. Benchmarking on device is required.

**Missing `RepaintBoundary`:** `OilBottleAnimation` is placed directly inside `Positioned.fill` with no RepaintBoundary wrapper. Without it, the raster cache cannot isolate the oil layer, preventing GPU-layer promotion. The `Stack`'s sibling `SafeArea` column won't rebuild (different subtree), but the oil painter cannot be promoted to a separate GPU layer. **RepaintBoundary must be added in PR8.**

**`fluid_engine.dart` is DEAD code.** It implements a particle/metaball engine with purple/indigo colors not matching the spec, uses `BlendMode.screen` per particle (500 max), and is imported nowhere. It is a prototype that was replaced by `oil_animation.dart`. **Delete in PR8.**

**`focus_body.dart` is a 2-line stub.** Imported nowhere. **Delete in PR8.**

**Recommendation: Start with CustomPainter + RepaintBoundary. Do NOT add `flutter_shaders` yet.**

Rationale:
- A14 (iPhone 12) handles 2–3 Gaussian blurs at 60fps in practice when the blend area is narrow (a 1.5pt surface stroke glow + 12pt sheen strip). The painters are doing path-fill + strokes, not screen-wide filters.
- The MaskFilter risk can be mitigated WITHOUT shaders by replacing surface glow with a gradient-painted strip instead of a blurred stroke — eliminates the most expensive blur pass.
- If physical device profiling shows sustained < 55fps, escalate to `flutter_shaders` SDF approach. That decision requires a device and a Xcode perf trace, not speculation.
- Adding `flutter_shaders` preemptively adds a compile step, a `.glsl` asset pipeline, and fragile hot-reload behaviour — not worth it without measured evidence.

**If shaders ARE needed later:** Add `flutter_shaders: ^0.1.2` (current stable), write a single `.glsl` fragment shader for the oil fill + drip column, compile via `flutter build` asset pipeline. The shader receives `progress`, `t`, `tiltX`, `tiltY`, `tier` as uniforms.

---

## Spec Gap Summary

| # | Gap | Severity | Source |
|---|-----|----------|--------|
| G1 | Oil color: current is amber-brown `#6B3800→#1A0900`; spec §7 requires pure `#000000` interior | High | `oil_animation.dart:290` |
| G2 | Background: spec §7 requires `#0d141a → #050709` vertical gradient; current is flat `#040404` | Medium | `oil_animation.dart:200` |
| G3 | No time-pressure tier implemented — drip rate, wave amp, column pulse are static | High | `oil_animation.dart` (no tier logic) |
| G4 | No drip column (pulsing vertical streak from island) — only discrete drops | High | spec §1 item 2 |
| G5 | No bubble particles when drops hit surface | Medium | spec §4 last bullet |
| G6 | No wall film (sheen on screen edges) | Low | spec §1 item 5 |
| G7 | No gyro low-pass filter / clamp (raw `e.y * 18.0` only, no smoothed/clamped state) | Medium | spec §5, `oil_animation.dart:68` |
| G8 | No Dynamic Island anchor detection (hardcoded `y=18`) | Medium | spec §1 item 1, `oil_animation.dart:227` |
| G9 | No RepaintBoundary wrapping the painter | Medium | spec §6 |
| G10 | No reduce-motion fallback wired | High | spec §8 |
| G11 | No disableGyroscope flag wired | High | spec §8 |
| G12 | `_ctrl` duration is `Duration(seconds: 1)` (repeating 0→1 in 1s); spec §6 says `Duration(days: 1)` for monotonic `t` | Low | functional equivalent via wall-clock dt; safe to leave |
| G13 | Hardcoded Arabic strings in dialog + status labels — outside ARB | Low | pre-existing; sweep during PR8 |
| G14 | `sessionDuration` not accessible from state (needed for tier + progress computation) | Medium | see §3 above |

Spec items already present in `oil_animation.dart`:
- ✅ `sensors_plus` gyroscope subscription (basic, needs low-pass filter — G7)
- ✅ `CustomPainter` + `AnimationController..repeat()` pattern
- ✅ Drop particles with gravity (`vy += 0.25 * dt`, `y += vy * dt`)
- ✅ Tilt → oil surface wave tilt
- ✅ Two-sine surface wave
- ✅ Drop spawn from island position
- ✅ Oil fill from bottom (`fillLevel`)
- ✅ `isRunning` gate on drop spawn
- ✅ `Positioned.fill` / full-screen painter

---

## File Plan (Spec §9 vs Real Tree)

| Spec file | Real-tree verdict | Action |
|-----------|------------------|--------|
| `lib/features/focus/presentation/widgets/oil_background.dart` | Does not exist | **CREATE** — new painter receiving `progress`, `t`, `tiltX`, `tiltY`, `tier`, `drops`, `islandAnchorY` |
| `lib/features/focus/presentation/widgets/oil_simulator.dart` | Does not exist | **CREATE** — math (surfaceY, tier, gyro filter), State (drops/bubbles lists), stream sub management |
| `lib/features/focus/presentation/screens/focus_screen.dart` | Does not exist (file is `pages/focus_page.dart`) | **CREATE** new `screens/` path replacing `pages/focus_page.dart` — OR refactor in place and add `screens/` alias import |
| `lib/features/focus/presentation/pages/focus_page.dart` | Exists, 585 lines | **REPLACE** with new focus_screen.dart; update route in `app.dart` |
| `pubspec.yaml` — `sensors_plus` | Already present | **NO CHANGE** |
| `pubspec.yaml` — `flutter_shaders` | Not present | **DO NOT ADD** until device perf fails |
| `lib/core/services/motion_preferences_service.dart` | Does not exist; `focus_mode_service.dart` exists (DND, unrelated) | **SKIP** — PR5's `SettingsCubit.reduceMotion` / `disableGyroscope` cover this entirely |
| `lib/features/settings/...` toggles | PR5 complete | **SKIP** |
| `lib/features/focus/presentation/widgets/oil_animation.dart` | Exists — active painter | **DELETE** after oil_background.dart + oil_simulator.dart absorb its logic |
| `lib/features/focus/presentation/widgets/fluid_engine.dart` | Exists — dead prototype | **DELETE** |
| `lib/features/focus/presentation/widgets/focus_body.dart` | Exists — 2-line stub | **DELETE** |

**Route change:** `app.dart` routes map likely has `'/focus'` pointing to `FocusPage` — update to `FocusScreen` after rename.

---

## Open Questions (designer / product)

| # | Question | Blocks |
|---|----------|--------|
| OQ1 | Intensity tier: spec says "assume <10% tier may become a setting — structure the time-pressure table so the top tier is swappable." Should the top tier's drip rate / wave amp be driven by a `UserSettings.focusIntensity` enum (Calm/Standard/Intense) now, or hard-coded to the spec table and made configurable later? | Implementation of tier table |
| OQ2 | Wall film (spec §1 item 5): "decays after ~6s when the line drops." Fill is monotonically increasing — it never drops in v1. Should wall film appear only on the initial wetting (oil touches a spot for the first time) and then stay until reset? Or defer to v2? | oil_simulator.dart wall-film logic |
| OQ3 | Dynamic Island halo spec §1 item 1: "Always present, even at 0% fill." Does this halo appear in `FocusInitial` (idle, before start)? Or only once session starts? | Idle-state visual |
| OQ4 | Bubble `life` range (spec §4): "rgba(255,255,255, 0.06 * life)." Confirm: `life` is 0→1 over bubble lifetime before fade-out? | Bubble alpha calculation |
| OQ5 | Splash/flip (spec §5): "Sudden flip → splash up side wall at `|gammaDelta| > 25°/frame`." Required for v1 launch or can defer to v2 as a feel detail? | gyro event handling |
| OQ6 | Drip column noise: spec §1 item 2 says "width pulses 8–14pt with slow noise." Is this a sine wave on column width, or Perlin noise? If Perlin, is the `dart:math` sinusoidal approximation acceptable? | oil_simulator.dart column impl |
| OQ7 | Bottom controls contrast: at fill > 80%, pause/stop circles float over oil body with only `alpha 0.12` fill. Should the controls overlay have a guaranteed dark backing (e.g., a fixed `Colors.black @ 0.35` pill behind the control row)? | focus_screen.dart controls layout |

---

## Confirmed Decisions (do not relitigate)

- Material palette §7: APPROVED as written. Focus is a deliberate dark immersive surface.
- Reduce-motion fallback §8: APPROVED. Static line + flat fill + gyro off; time-pressure → opacity.
- Timer numerals: always solid #FFF above oil mask — never composited through.
- Oil color: pure `#000000` interior (not the current amber-brown).
- Intensity tiers: the <10% tier is the max; structure top tier as swappable constant.
