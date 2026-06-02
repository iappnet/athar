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
| `lib/features/settings/data/models/user_settings.dart` | (grep) | PR5 + new fields |
| `lib/features/settings/presentation/cubit/settings_cubit.dart` | (grep) | PR5 toggles |
| `lib/features/settings/presentation/cubit/settings_state.dart` | (grep) | PR5 props |
| `lib/features/settings/presentation/pages/general_settings_page.dart` | (grep) | PR5 UI |
| `lib/core/services/focus_mode_service.dart` | 30 | DND service (unrelated) |
| `pubspec.yaml` | (grep) | Dep check |

---

## §10 Spec Checklist

### 1 — Current FocusScreen widget structure

**Entry:** `focus_page.dart` — `StatefulWidget` + `_FocusPageState`.

**Widget tree:**

```
BlocProvider<FocusCubit>
  Builder
    BlocListener<FocusCubit>   ← captures _sessionTotalSeconds on first FocusRunning
      Scaffold(backgroundColor: Colors.black, extendBodyBehindAppBar: true)
        body: BlocBuilder<FocusCubit>
          Stack
            Positioned.fill → OilBottleAnimation(fillLevel, isRunning)
            SafeArea
              Column
                _TopBar            ← back + tune glass buttons (46pt circles)
                Spacer
                _FocusTargetBadge? ← task context pill (conditional on focusTarget)
                _DurationSelector  ← chips 15/25/45/60 min (FocusInitial only)
                _TimerDisplay      ← 70sp glass card + status label
                Spacer
                _Controls          ← state-switched (see table below)
                AtharGap.huge      ← ~40pt bottom clearance
```

**Controls by state:**

| State | Controls |
|-------|----------|
| `FocusInitial` | 88pt amber gradient circle (play icon) |
| `FocusRunning` | Pause (amber 60pt) + Stop (red 60pt) |
| `FocusPaused` | Resume (amber 72pt large) + Reset (grey 60pt) |
| `FocusCompleted` | Replay (amber 72pt) |

#### Control-contrast risk assessment

**_TimerDisplay:** `Colors.black @ alpha 0.45` backdrop + amber border + spread box-shadow. Timer numerals are solid white. **PASS** — satisfies spec §8 requirement. The glass card creates its own dark zone behind the numerals regardless of fill level.

**_TopBar glass buttons:** `white @ alpha 0.07` fill + icon `white @ alpha 0.75`. These live in the SafeArea top zone. Oil fills from the bottom, so top-bar glass buttons only overlay oil in the final ~15% of a session. White-on-black icons at alpha 0.75 remain readable. **LOW RISK.**

**Bottom controls (_CtrlBtn):** `color @ alpha 0.12` fill + `color @ alpha 0.4` border. When `fillLevel > 0.80` the oil surface crests near the bottom controls zone. The control backgrounds are nearly transparent against the dark oil body (`#1A0900`). The icon and label colours (amber, red, grey @ alpha 0.85) provide some contrast but the container boundary almost disappears. **MEDIUM RISK — flagged as OQ6 for designer decision.**

**Hardcoded Arabic strings (ARB gap, pre-existing):** `_showExitDialog`, `_showDurationSheet`, `_TimerDisplay` status labels, and `_Controls` "جلسة جديدة" are all hardcoded outside the ARB system. Not PR8's primary scope but PR8 will touch this file — worth sweeping during implementation.

---

### 2 — sensors_plus / flutter_shaders deps

| Package | Status | Action |
|---------|--------|--------|
| `sensors_plus: ^4.0.2` | ✅ Already in `pubspec.yaml:97` | No change |
| `flutter_shaders` | ❌ Not present | Deferred — see §6 |

`sensors_plus` is already imported and in active use in `oil_animation.dart:4` via `gyroscopeEventStream`. No pubspec change needed for sensor integration.

---

### 3 — FocusCubit state: `progress` and `timeRemaining`

**Current state class (`focus_state.dart`, 25 lines):**

```dart
abstract class FocusState {
  final int duration;   // seconds REMAINING (countdown)
}
class FocusRunning  extends FocusState { ... }
class FocusPaused   extends FocusState { ... }
class FocusCompleted extends FocusState { super(0); }
```

**What exists:**

- `state.duration` = `timeRemaining` in seconds ✅ (it IS timeRemaining, counting down)
- `progress` (0–1) = NOT in state. Computed in `_FocusPageState._fillLevel()` using the page-local `int _sessionTotalSeconds` field, which is set by the `BlocListener` on the first `FocusRunning` tick.
- `sessionDuration` (denominator) = NOT in state. Available only as `cubit._selectedDuration` (private) or via the public `cubit.currentDurationMinutes * 60`.

**Gap for PR8:** The painter needs `progress` for fill height AND `tier` for motion intensity. Tier requires `progress = 1 - timeRemaining / sessionDuration`. `sessionDuration` is not in the state.

**Minimal additive change — no state-class restructuring needed:**

Expose a public getter on `FocusCubit`:

```dart
int get sessionDuration => _selectedDuration;
```

Then in the focus screen:

```dart
final progress = _sessionTotalSeconds > 0
    ? (1.0 - state.duration / _sessionTotalSeconds).clamp(0.0, 1.0)
    : 0.0;
final tier = _intensityTierFor(progress, focusIntensity);
```

`FocusRunning`, `FocusPaused`, and `FocusCompleted` do not need new fields.

---

### 4 — PR5 flags: `reduceMotion` + `disableGyroscope` ✅ Confirmed

| Flag | UserSettings field | In SettingsLoaded.props | Toggle method | Settings UI |
|------|-------------------|------------------------|---------------|-------------|
| `reduceMotion` | line 203 ✅ | line 42 ✅ | `toggleReduceMotion(bool)` cubit:477 | general_settings_page.dart:272 |
| `disableGyroscope` | line 204 ✅ | line 43 ✅ | `toggleDisableGyroscope(bool)` cubit:483 | general_settings_page.dart:282 |

**Read path at PR8 consumer:**

```dart
final s = context.watch<SettingsCubit>().state;
final settings = s is SettingsLoaded ? s.settings : null;

// OR pattern per PR5 ruling:
final reduceMotion = (settings?.reduceMotion ?? false)
    || MediaQuery.of(context).disableAnimations;

// Independent gyro flag:
final gyroOff = settings?.disableGyroscope ?? false;
```

`SettingsCubit` is in the global `MultiBlocProvider` (`app.dart`) — accessible from any descendant context. No additional `BlocProvider` needed at the focus screen.

**Reduce-motion fallback (spec §8, designer-approved):**

- `reduceMotion == true`: drip column → static dim line; surface → flat fill bar; gyro frozen at 0,0.
- Time-pressure tier still drives opacity.
- Implementation: pass `reduceMotion` bool to `OilBackground`; cancel gyroscope stream in `oil_simulator.dart` when `gyroOff || reduceMotion`.

---

### 5 — Dynamic Island anchor

**Current code (`oil_animation.dart:225`):**

```dart
const islandW   = 120.0;
const islandH   = 34.0;
const islandTop = 18.0;   // hardcoded — does not detect real island
```

Always draws at `y = 18` regardless of device.

**Detection — no `device_info_plus` required:**

`MediaQuery.of(context).padding.top` reflects the true safe-area inset:

- iPhone 14 Pro / Pro Max (Dynamic Island): ~59 pt
- iPhone 14 / 14 Plus, 13, 12 (notch or no notch): 44–47 pt
- Heuristic: `padding.top >= 51` → real Dynamic Island present

**Anchor computation (computed in build, passed to painter):**

```dart
final topPad      = MediaQuery.of(context).padding.top;
final hasIsland   = topPad >= 51;
final islandTop   = hasIsland ? topPad - 12.0 : topPad + 11.0;
const islandW     = 120.0;
final islandH     = hasIsland ? 34.0 : 30.0;
```

For older devices the spec mandates a **virtual 110×30 pt rect at `top: safeAreaTop + 11`**, which this formula produces. Pass `islandTop`, `islandW`, `islandH` as parameters to `OilBackground`. No new package required.

---

### 6 — Performance budget

**Current animation loop:**

- `AnimationController(duration: Duration(seconds: 1))..repeat()` → vsync-driven ~60 fps ✅
- `addListener(_onFrame)` → each tick: integrate tilt, advance `_wavePhase`, spawn/update drops, `setState(() {})` ✅
- `_OilPainter.shouldRepaint` always returns `true` ✅ (correct for fluid sim)

**Per-frame painter work:**

| Step | Cost | Notes |
|------|------|-------|
| Background `drawRect` | trivial | |
| `_drawIsland` | low | 1–2 RRect |
| Island outer blur `MaskFilter.blur(outer, 10)` | medium | conditional on `isRunning && fillLevel > 0` |
| `_drawOil` — 48-segment path + linear gradient | low | acceptable segment count |
| `_drawSurface` — `MaskFilter.blur(normal, 5)` | medium ⚠️ | per-frame Gaussian pass |
| `_drawSubsurfaceSheen` — `MaskFilter.blur(normal, 8)` | medium ⚠️ | second per-frame Gaussian pass |
| Per drop (`drawOval` + `drawCircle`) ×≤30 | low | |
| `_drawEdges` — RadialGradient + 2× LinearGradient drawRect | low | |

**`MaskFilter.blur` in the hot path is the primary performance risk.** Two Gaussian blur passes per frame, applied during `paint()`. On Apple A14 (iPhone 12) this will likely sustain 60 fps, but it's not free and leaves no headroom for tier-scaling particle counts.

**Missing `RepaintBoundary`:** `OilBottleAnimation` is placed directly inside `Positioned.fill` with no `RepaintBoundary` wrapper. The `setState(() {})` in `_OilBottleAnimationState` rebuilds only the oil subtree (the `SafeArea` Column is a sibling and won't rebuild), but without `RepaintBoundary` the raster cache cannot promote the oil layer to its own GPU compositing layer. **Must add in PR8 per spec §6.**

**`fluid_engine.dart` is dead code.** Implements a purple/indigo metaball engine (`BlendMode.screen` per particle, 500-particle max) — never imported anywhere. A previous prototype, fully replaced by `oil_animation.dart`. **Delete in PR8.**

**`focus_body.dart` is a 2-line stub.** Imported nowhere. **Delete in PR8.**

**Recommendation: Start with CustomPainter + RepaintBoundary. Do NOT add `flutter_shaders` yet.**

Rationale:

- A14 handles 2–3 Gaussian blurs at 60 fps when the blend areas are narrow stripes (1.5 pt surface stroke, 12 pt sheen strip) rather than screen-wide.
- The blur risk is mitigable without shaders: replace `_drawSurface` and `_drawSubsurfaceSheen` blurred strokes with pre-computed gradient fills — removes both expensive passes from the hot path entirely.
- Adding `flutter_shaders` preemptively adds a `.glsl` asset compile step, fragile hot-reload, and a new package dependency — not justified without device perf measurements.
- **Decision gate:** if Xcode Instruments shows sustained < 55 fps on iPhone 12, escalate to `flutter_shaders` SDF approach at that point. Shader would receive `progress`, `t`, `tiltX`, `tiltY`, `tier` as uniforms.

---

## `focusIntensity` — Additive UserSettings Plan

**Designer ruling (locked):** A new `FocusIntensity` enum controls the motion intensity ceiling. Three tiers: Calm / Standard / Intense. Default: Standard. The §2 time-pressure table values are selected by tier.

### Tier table

| Time remaining | Calm | Standard | Intense |
|----------------|------|----------|---------|
| 100–66% | 1/4 s, 2 pt, calm, no bubbles | 1/4 s, 2 pt, calm, no bubbles | 1/4 s, 2 pt, calm, no bubbles |
| 66–33% | 1/4 s, 2 pt, calm, no bubbles | 1/1.5 s, 5 pt, medium, 1/8 s | 1/1.5 s, 5 pt, medium, 1/8 s |
| 33–10% | 1/4 s, 2–4 pt flat, calm, no bubbles | 2/s, 9 pt no chop, fast, 1/3 s | 2/s, 9 pt, fast, 1/3 s |
| < 10% | ≤ 1/2 s, 2–4 pt flat, calm, NO splash | 2/s, ~9 pt no chop, fast, small/dampened splash | continuous stream, 14 pt+chop, aggressive, 2/s burst |

Calm caps the experience at low drip rate and flat waves regardless of time remaining. Intense = the full original §2 spec. Standard = spec's 33–10% tier as the maximum ceiling.

### Additive implementation plan — isAthkar pattern

This follows the exact same pattern as `isAthkarEnabled` in PR7:

**Step 1 — UserSettings model** (`user_settings.dart`):

```dart
enum FocusIntensity { calm, standard, intense }

// In UserSettings @collection:
@enumerated
FocusIntensity focusIntensity = FocusIntensity.standard;
```

**Step 2 — build_runner pass:** Isar schema change requires `flutter pub run build_runner build --delete-conflicting-outputs`. `user_settings.g.dart` regenerates. No migration needed (new field with default).

**Step 3 — SettingsCubit** (`settings_cubit.dart`):

```dart
Future<void> updateFocusIntensity(FocusIntensity intensity) async {
  final s = ...; // load current settings
  s.focusIntensity = intensity;
  await _repository.saveSettings(s);
  emit(SettingsLoaded(settings: s));
}
```

**Step 4 — SettingsState** (`settings_state.dart`): Add `settings.focusIntensity` to `SettingsLoaded.props` for equality.

**Step 5 — Settings UI** (`general_settings_page.dart`): Add a Focus section (after Accessibility, before Sync & Account) containing a `SegmentedButton<FocusIntensity>` with three segments: Calm / Standard / Intense (Arabic + English ARB keys).

**Step 6 — ARB keys** (6 new keys):

| Key | EN | AR |
|-----|----|----|
| `focusIntensitySection` | "Focus Intensity" | "شدة التركيز" |
| `focusIntensityCalm` | "Calm" | "هادئ" |
| `focusIntensityStandard` | "Standard" | "معتدل" |
| `focusIntensityIntense` | "Intense" | "مكثف" |
| `focusIntensitySectionDesc` | "Controls animation and oil flow intensity during sessions" | "تتحكم في شدة الحركة وتدفق الزيت أثناء الجلسات" |

Note: 5 keys shown; section desc is optional. Run `flutter gen-l10n` after ARB edit.

**Step 7 — Consumer in focus screen:** Read from `SettingsCubit` the same way as `reduceMotion`:

```dart
final intensity = settings?.focusIntensity ?? FocusIntensity.standard;
```

Pass to `OilSimulator` which selects tier values from the table above based on both `progress` and `intensity`.

---

## Spec Gaps

| # | Gap | Severity | Source |
|---|-----|----------|--------|
| G1 | Oil color: current is amber-brown `#6B3800→#1A0900`; spec §7 = pure `#000000` interior | High | `oil_animation.dart:290` |
| G2 | Background: spec §7 = `#0d141a→#050709` vertical + radial vignette; current = flat `#040404` | Medium | `oil_animation.dart:200` |
| G3 | No time-pressure tier implemented — drip rate, wave amp, column pulse are static | High | `oil_animation.dart` (no tier logic) |
| G4 | No drip column (pulsing vertical streak from island) — only discrete drops spawned | High | spec §1 item 2 |
| G5 | No bubble particles when drops hit surface | Medium | spec §4 last bullet |
| G6 | No wall film (sheen on screen edges above fill line) | Low | spec §1 item 5 |
| G7 | No gyro low-pass filter or clamp (raw `e.y * 18.0`, no smoothed accumulator + clamp) | Medium | spec §5; `oil_animation.dart:68` |
| G8 | No Dynamic Island anchor detection (hardcoded `y=18`) | Medium | spec §1 item 1; `oil_animation.dart:227` |
| G9 | No `RepaintBoundary` wrapping the painter | Medium | spec §6 |
| G10 | `reduceMotion` fallback not wired to oil | High | spec §8 |
| G11 | `disableGyroscope` flag not wired to oil | High | spec §8 |
| G12 | `AnimationController` duration is `Duration(seconds: 1)` (repeating 0→1 in 1 s); spec §6 says `Duration(days: 1)` for monotonic `t` | Low | functionally equivalent via wall-clock dt; safe but flag |
| G13 | Hardcoded Arabic strings in dialog + status labels — outside ARB | Low | pre-existing; sweep during PR8 |
| G14 | `sessionDuration` not accessible from state (needed for tier + progress) | Medium | see §3 above |
| G15 | `focusIntensity` field not in `UserSettings`; not in `SettingsCubit`; no Settings UI | High | new — designer ruling |

Already present in `oil_animation.dart` (no gaps):

- `sensors_plus` gyroscope subscription (basic; needs low-pass filter — G7)
- `CustomPainter` + `AnimationController..repeat()` pattern
- Drop particles with gravity integration
- Tilt → surface wave lean
- Two-sine surface wave
- Drop spawn from island position
- Oil fill from bottom (`fillLevel`)
- `isRunning` gate on drop spawn
- `Positioned.fill` full-screen painter

---

## File Plan (Spec §9 vs Real Tree)

| Spec file | Real-tree verdict | Action |
|-----------|------------------|--------|
| `lib/features/focus/presentation/widgets/oil_background.dart` | Does not exist | **CREATE** — painter; receives `progress`, `t`, `tiltX`, `tiltY`, `tier`, `drops`, `bubbles`, `islandTop/W/H`, `reduceMotion` |
| `lib/features/focus/presentation/widgets/oil_simulator.dart` | Does not exist | **CREATE** — math (surfaceY, tier lookup, gyro low-pass/clamp), mutable drop/bubble lists, stream subscription management |
| `lib/features/focus/presentation/screens/focus_screen.dart` | Does not exist (`pages/focus_page.dart`) | **CREATE** under `screens/` matching PR2 naming convention; replace `FocusPage` route in `app.dart` |
| `lib/features/focus/presentation/pages/focus_page.dart` | Exists | **REPLACE** (delete after focus_screen.dart added) |
| `pubspec.yaml` — `sensors_plus` | Already present | **NO CHANGE** |
| `pubspec.yaml` — `flutter_shaders` | Not present | **DO NOT ADD** — deferred to device perf gate |
| `lib/features/settings/data/models/user_settings.dart` | Exists | **ADD** `FocusIntensity` enum + field + constructor default |
| `user_settings.g.dart` | Generated | **REGENERATE** via build_runner |
| `lib/features/settings/presentation/cubit/settings_cubit.dart` | Exists | **ADD** `updateFocusIntensity(FocusIntensity)` method |
| `lib/features/settings/presentation/cubit/settings_state.dart` | Exists | **ADD** `focusIntensity` to `SettingsLoaded.props` |
| `lib/features/settings/presentation/pages/general_settings_page.dart` | Exists | **ADD** Focus intensity section with `SegmentedButton` |
| `lib/l10n/app_ar.arb` + `app_en.arb` | Exists | **ADD** 5 ARB keys; run `flutter gen-l10n` |
| `lib/core/services/motion_preferences_service.dart` | Does not exist | **SKIP** — PR5's `SettingsCubit` covers this entirely |
| `lib/features/focus/presentation/widgets/oil_animation.dart` | Exists — active | **DELETE** after oil_background + oil_simulator absorb its logic |
| `lib/features/focus/presentation/widgets/fluid_engine.dart` | Exists — dead prototype | **DELETE** |
| `lib/features/focus/presentation/widgets/focus_body.dart` | Exists — 2-line stub | **DELETE** |

**Route change in `app.dart`:** update `'/focus'` route from `FocusPage` to `FocusScreen`.

---

## Open Questions

| # | Question | Blocks |
|---|----------|--------|
| OQ1 | Wall film (spec §1 item 5): "decays after ~6 s when the line drops." Fill is monotonically increasing in v1 — it never drops. Should wall film appear on first wetting (oil touches a spot for the first time) and persist until reset? Or defer entirely to v2? | `oil_simulator.dart` wall-film logic |
| OQ2 | Dynamic Island halo (spec §1 item 1): "Always present, even at 0% fill." Does the oil-rim halo appear in `FocusInitial` (idle, before session starts)? Or only once the timer is running? | Idle visual |
| OQ3 | Bubble `life` range (spec §4): "rgba(255,255,255, 0.06 × life)." Confirm `life` is 0→1 over bubble lifetime before fade-out. | Bubble alpha |
| OQ4 | Splash/flip (spec §5): "Sudden flip → splash up side wall at `|gammaDelta| > 25°/frame`." Required for v1 or defer to v2? | Gyro event handling |
| OQ5 | Drip column noise (spec §1 item 2): "width pulses 8–14 pt with slow noise." Sine approximation acceptable, or must it be Perlin/simplex? | `oil_simulator.dart` column impl |
| OQ6 | Bottom controls contrast: at fill > 80%, pause/stop circles float over dark oil body with only `alpha 0.12` container fill. Should the controls row have a guaranteed dark pill backing (e.g. `Colors.black @ 0.35`)? | `focus_screen.dart` controls layout |
| OQ7 | `focusIntensity` ARB copy: confirm the 5 EN/AR keys above before committing. (Provide corrected strings if any.) | ARB + `flutter gen-l10n` |

---

## Confirmed Design Decisions (do not relitigate)

- Material palette §7: APPROVED. Focus is a deliberate immersive dark surface (brand exception).
- Reduce-motion fallback §8: APPROVED. Static line + flat fill + gyro off; time-pressure → opacity only.
- Timer numerals: always solid `#FFF` above the oil mask. Never composited through.
- Oil color: pure `#000000` interior + `#0d141a→#050709` background (not the current amber-brown).
- `focusIntensity` enum (calm | standard | intense), default standard. New `UserSettings` field → build_runner pass + Settings UI segmented control. Follows isAthkar additive pattern exactly.
- Intensity top tier is swappable: Calm caps at ≤1 drop/2 s + flat waves; Standard caps at spec 33–10% tier; Intense = full §2 table.
