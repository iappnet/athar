import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../features/settings/data/models/user_settings.dart';

// OilTierConfig — 4-band fill-pressure tiers.
// fill = 1 - (timeRemaining / sessionDuration)
//   calm   band: fill <  0.34  (100–66% remaining)
//   mid    band: fill >= 0.34  (66–33%)
//   low    band: fill >= 0.67  (33–10%)
//   CLIMAX band: fill >= 0.90  (<10% remaining)
class OilTierConfig {
  const OilTierConfig({
    required this.waveAmp,
    required this.waveChop,
    required this.columnPulse,
    required this.dripRate,
    required this.splashScale,
  });

  final double waveAmp;
  final double waveChop;   // 0 = no secondary wave
  final double columnPulse; // px extra height of column bob
  final double dripRate;    // drops/s
  final double splashScale; // 0=off  0.5=dampened  1=full

  static OilTierConfig resolve({
    required double fillFraction,
    required FocusIntensity intensity,
  }) {
    final bool climax = fillFraction >= 0.90;
    final bool low    = fillFraction >= 0.67;
    final bool mid    = fillFraction >= 0.34;

    switch (intensity) {
      // ── Calm: all bands capped — ≤0.5 drops/s, 2–4.5 pt, no splash.
      case FocusIntensity.calm:
        return OilTierConfig(
          waveAmp:     climax ? 4.5 : low ? 3.5 : mid ? 2.5 : 2.0,
          waveChop:    0.30,
          columnPulse: climax ? 6.0 : low ? 4.0 : mid ? 3.0 : 2.0,
          dripRate:    climax ? 0.5 : low ? 0.4 : mid ? 0.3 : 0.2,
          splashScale: 0.0,
        );
      // ── Standard: climax = 2/s, ~9 pt, NO chop, dampened splash.
      case FocusIntensity.standard:
        return OilTierConfig(
          waveAmp:     climax ? 9.0 : low ? 7.0 : mid ? 5.0 : 3.0,
          waveChop:    climax ? 0.0 : 0.50, // spec: no chop in climax
          columnPulse: climax ? 12.0 : low ? 9.0 : mid ? 6.0 : 4.0,
          dripRate:    climax ? 2.0 : low ? 1.0 : mid ? 0.7 : 0.4,
          splashScale: climax ? 0.5 : low ? 0.3 : 0.0,
        );
      // ── Intense: climax = continuous stream (12/s), 18 pt + chop, full splash.
      case FocusIntensity.intense:
        return OilTierConfig(
          waveAmp:     climax ? 18.0 : low ? 13.0 : mid ? 9.0 : 5.0,
          waveChop:    climax ? 0.75 : low ? 0.70 : mid ? 0.65 : 0.55,
          columnPulse: climax ? 22.0 : low ? 16.0 : mid ? 11.0 : 7.0,
          dripRate:    climax ? 12.0 : low ? 1.8 : mid ? 1.2 : 0.7,
          splashScale: climax ? 1.0 : low ? 0.5 : 0.0,
        );
    }
  }
}

// Rising bubble — spawned on drop-impact.
class OilBubble {
  OilBubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.vy,
    required double initialLife,
  }) : life = initialLife;

  final double x;
  double y;
  final double radius;
  final double vy; // px/s upward
  double life;     // 1.0 → 0.0
}

// Falling drip drop.
class OilDrop {
  OilDrop({required this.x, required this.y, required this.vy});

  final double x;
  double y;
  double vy;
  bool impacted = false; // true once the drop crosses surfaceY
}

class OilSimulator {
  OilSimulator({required this.seed});

  final int seed;
  final math.Random _rng = math.Random(42);

  double _t = 0.0;
  final List<OilBubble> _bubbles = [];
  final List<OilDrop> _drops = [];

  double _dripAcc = 0.0;
  double _columnX = 0.5; // normalised 0–1

  // Low-pass tilt state (driven by updateTilt each tick from OilBackground).
  double _tiltX = 0.0; // gamma — horizontal lean, degrees
  double _tiltY = 0.0; // beta  — vertical lean, degrees

  // Low-pass: smoothed = prev*0.85 + raw*0.15. Clamped before blending.
  void updateTilt(double rawX, double rawY) {
    _tiltX = _tiltX * 0.85 + rawX.clamp(-30.0, 30.0) * 0.15;
    _tiltY = _tiltY * 0.85 + rawY.clamp(-20.0, 20.0) * 0.15;
  }

  void tick(
    double dt,
    Size size,
    double fillFraction,
    OilTierConfig cfg,
    bool isRunning,
  ) {
    _t += dt;

    if (!isRunning) {
      _stepBubbles(dt);
      return;
    }

    _dripAcc += dt;
    final double dripInterval = cfg.dripRate > 0 ? 1.0 / cfg.dripRate : 1e9;
    while (_dripAcc >= dripInterval) {
      _dripAcc -= dripInterval;
      _spawnDrip(size, fillFraction, cfg);
    }

    _stepDrops(dt, size, fillFraction, cfg);
    _stepBubbles(dt);
  }

  // Spec §3 surface y at pixel-x.
  double surfaceY(
    double x,
    Size size,
    double fillFraction,
    OilTierConfig cfg,
  ) {
    final double screenH = size.height;
    final double screenW = size.width;
    final double fillHeight = fillFraction * screenH;

    // Tilt: already low-passed; no extra clamp needed (updateTilt clamps input).
    final double gammaRad = _tiltX * math.pi / 180.0;
    final double tiltOffset = math.tan(gammaRad) * (x - screenW / 2);

    // Summed sines — dart:math only.
    final double wave1 =
        math.sin(x * 0.018 + _t / 350.0 + seed.toDouble()) * cfg.waveAmp;
    final double wave2 =
        cfg.waveChop * math.sin(x * 0.04 + _t / 180.0) * cfg.waveAmp;

    final double bob = math.sin(_t / 2.3 + seed * 0.7) * 2.0;

    return (screenH - fillHeight) + tiltOffset + wave1 + wave2 + bob;
  }

  // Drip column centre-x in pixels.
  double columnXPx(Size size, OilTierConfig cfg) {
    _columnX = (_columnX +
            (math.sin(_t * 0.08) * 0.002).clamp(-0.01, 0.01))
        .clamp(0.25, 0.75);
    return _columnX * size.width + math.sin(_t * 0.5) * 4.0;
  }

  // Rectified sine pulse for column height.
  double columnPulse(OilTierConfig cfg) =>
      cfg.columnPulse * math.sin(_t * 3.0).abs();

  List<OilBubble> get bubbles => _bubbles;
  List<OilDrop> get drops => _drops;
  double get tiltX => _tiltX;
  double get t => _t;

  // ── private helpers ────────────────────────────────────────────────────────

  void _spawnDrip(Size size, double fillFraction, OilTierConfig cfg) {
    final double cx = _columnX * size.width + (_rng.nextDouble() - 0.5) * 8.0;
    final double sy = surfaceY(cx, size, fillFraction, cfg);
    // Start 6 px above surface so impact detection has headroom.
    _drops.add(OilDrop(x: cx, y: sy - 6.0, vy: 0.0));
    if (_drops.length > 30) _drops.removeAt(0);
  }

  // Bubble spawned at impact x on the surface.
  void _spawnBubble(double x, Size size, double fillFraction) {
    final double sy = size.height * (1.0 - fillFraction);
    _bubbles.add(OilBubble(
      x: x,
      y: sy,
      radius: 1.5 + _rng.nextDouble() * 2.5,
      vy: 20.0 + _rng.nextDouble() * 30.0,
      initialLife: 1.0,
    ));
    if (_bubbles.length > 60) _bubbles.removeAt(0);
  }

  // DEV3: on drop-impact (d.y crosses surfaceY), 40% chance spawn bubble.
  void _stepDrops(
      double dt, Size size, double fillFraction, OilTierConfig cfg) {
    const double gravity = 280.0;
    _drops.removeWhere((d) => d.y > size.height + 20);
    for (final d in List<OilDrop>.of(_drops)) {
      d.vy += gravity * dt;
      d.y += d.vy * dt;
      if (!d.impacted) {
        final double sy = surfaceY(d.x, size, fillFraction, cfg);
        if (d.y >= sy) {
          d.impacted = true;
          if (_rng.nextDouble() < 0.40) {
            _spawnBubble(d.x, size, fillFraction);
          }
        }
      }
    }
    _drops.removeWhere((d) => d.impacted);
  }

  void _stepBubbles(double dt) {
    const double fadeRate = 0.7; // life units/s
    _bubbles.removeWhere((b) => b.life <= 0);
    for (final b in _bubbles) {
      b.y -= b.vy * dt;
      b.life -= fadeRate * dt;
    }
  }
}
