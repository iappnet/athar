import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
// OilBottleAnimation
//
// Visual concept:
//   • The device screen IS the bottle / cup interior.
//   • A Dynamic-Island pill sits at the top as the oil source.
//   • Oil drops fall from the island and accumulate at the bottom.
//   • Fill level (0→1) drives how high the oil has risen.
//   • Gyroscope tilt makes the oil surface slosh left / right.
// ─────────────────────────────────────────────────────────────────────────────

class OilBottleAnimation extends StatefulWidget {
  final double fillLevel; // 0.0 = empty, 1.0 = full
  final bool isRunning;

  const OilBottleAnimation({
    super.key,
    required this.fillLevel,
    required this.isRunning,
  });

  @override
  State<OilBottleAnimation> createState() => _OilBottleAnimationState();
}

class _OilBottleAnimationState extends State<OilBottleAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Gyroscope integration
  StreamSubscription? _gyroSub;
  double _tiltAngle = 0.0;   // accumulated tilt (clamped)
  double _angularVel = 0.0;  // current angular velocity from gyro

  // Wave phase
  double _wavePhase = 0.0;

  // Oil drops falling from Dynamic Island
  final List<_OilDrop> _drops = [];
  final math.Random _rng = math.Random();
  double _dropTimer = 0.0;

  // Frame timing
  DateTime _lastFrame = DateTime.now();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
    _ctrl.addListener(_onFrame);
    _startGyroscope();
    // Pre-seed a few drops
    for (int i = 0; i < 3; i++) {
      _drops.add(_OilDrop.spawn(_rng, offset: i * 0.3));
    }
  }

  void _startGyroscope() {
    try {
      _gyroSub = gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval)
          .listen((GyroscopeEvent e) {
        // y-axis = left/right tilt when device is held portrait
        _angularVel = e.y * 18.0;
      }, onError: (_) {
        // Simulator or no gyroscope — idle animation only.
      });
    } catch (_) {}
  }

  void _onFrame() {
    final now = DateTime.now();
    final dt = (now.difference(_lastFrame).inMicroseconds / 1e6).clamp(0.0, 0.05);
    _lastFrame = now;

    // Integrate tilt from gyroscope velocity (like integrating angular position)
    _tiltAngle = (_tiltAngle + _angularVel * dt).clamp(-1.0, 1.0);
    // Viscous decay — oil dampens the motion
    _tiltAngle *= 0.97;
    _angularVel *= 0.85;

    // Advance wave
    _wavePhase += dt * 1.1;

    // Spawn / update drops (only while running)
    if (widget.isRunning) {
      _dropTimer += dt;
      if (_dropTimer > 0.6 + _rng.nextDouble() * 0.6) {
        _drops.add(_OilDrop.spawn(_rng));
        _dropTimer = 0.0;
      }
    }
    for (final d in _drops) {
      d.update(dt);
    }
    _drops.removeWhere((d) => d.dead(widget.fillLevel));

    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _gyroSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OilPainter(
        fillLevel: widget.fillLevel,
        tiltAngle: _tiltAngle,
        wavePhase: _wavePhase,
        drops: List.unmodifiable(_drops),
        isRunning: widget.isRunning,
      ),
      child: const SizedBox.expand(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Oil drop data
// ─────────────────────────────────────────────────────────────────────────────

class _OilDrop {
  double x;         // normalised [0,1]
  double y;         // normalised [0,1]  (0=top)
  double vy;        // vertical velocity (normalised/s)
  final double r;   // radius in pixels
  final double opacity;

  _OilDrop({
    required this.x,
    required this.y,
    required this.vy,
    required this.r,
    required this.opacity,
  });

  factory _OilDrop.spawn(math.Random rng, {double offset = 0.0}) {
    return _OilDrop(
      x: 0.38 + rng.nextDouble() * 0.24,
      y: 0.065 + offset * 0.05,
      vy: 0.06 + rng.nextDouble() * 0.04,
      r: 3.5 + rng.nextDouble() * 4.5,
      opacity: 0.65 + rng.nextDouble() * 0.35,
    );
  }

  void update(double dt) {
    vy += 0.25 * dt; // gravity
    y += vy * dt;
  }

  bool dead(double fillLevel) => y >= (1.0 - fillLevel - 0.02) || y > 1.1;
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _OilPainter extends CustomPainter {
  final double fillLevel;
  final double tiltAngle;
  final double wavePhase;
  final List<_OilDrop> drops;
  final bool isRunning;

  const _OilPainter({
    required this.fillLevel,
    required this.tiltAngle,
    required this.wavePhase,
    required this.drops,
    required this.isRunning,
  });

  // Compute the oil surface Y for a given normalised x position.
  double _surfaceY(double xNorm, double baseY, double h) {
    final tiltPx = tiltAngle * 45.0;
    final localTilt = (xNorm - 0.5) * tiltPx * 2.0;
    // Two overlapping sine waves give a more organic look
    final amp = math.min(18.0, fillLevel * 28.0);
    final wave = math.sin(xNorm * math.pi * 3.2 + wavePhase) * amp * 0.55 +
        math.sin(xNorm * math.pi * 5.7 - wavePhase * 0.8) * amp * 0.45;
    return baseY + localTilt + wave;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1 ── Pitch-black background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF040404),
    );

    // 2 ── Dynamic Island (simulated)
    _drawIsland(canvas, size);

    // 3 ── Oil body
    if (fillLevel > 0.002) {
      _drawOil(canvas, size);
    }

    // 4 ── Falling drops
    for (final drop in drops) {
      _drawDrop(canvas, size, drop);
    }

    // 5 ── Glass edge vignette
    _drawEdges(canvas, size);
  }

  void _drawIsland(Canvas canvas, Size size) {
    final w = size.width;
    const islandW = 120.0;
    const islandH = 34.0;
    const islandTop = 18.0;

    final islandRect = RRect.fromRectAndRadius(
      Rect.fromLTWH((w - islandW) / 2, islandTop, islandW, islandH),
      const Radius.circular(17),
    );

    // Base pill
    canvas.drawRRect(
      islandRect,
      Paint()..color = const Color(0xFF1C1208),
    );

    if (isRunning && fillLevel > 0) {
      // Amber glow when oil is flowing
      canvas.drawRRect(
        islandRect,
        Paint()
          ..color = const Color(0x35C46A00)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10),
      );
      // Small drip point at the bottom center
      final cx = w / 2;
      const dripTop = islandTop + islandH;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, dripTop + 5),
          width: 7,
          height: 9,
        ),
        Paint()..color = const Color(0xCC8B4500),
      );
    }
  }

  void _drawOil(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final baseSurfaceY = h * (1.0 - fillLevel);

    const segments = 48;
    final oilPath = Path();

    // Bottom-left → bottom-right
    oilPath.moveTo(0, h);
    oilPath.lineTo(w, h);

    // Right wall up to surface
    oilPath.lineTo(w, _surfaceY(1.0, baseSurfaceY, h));

    // Surface curve from right to left
    for (int i = segments - 1; i >= 0; i--) {
      final xNorm = i / segments;
      final x = xNorm * w;
      final y = _surfaceY(xNorm, baseSurfaceY, h);
      oilPath.lineTo(x, y);
    }

    // Left wall down
    oilPath.lineTo(0, h);
    oilPath.close();

    // Oil gradient — dark at bottom, slightly amber at surface
    final oilGrad = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xCC6B3800), // amber-brown at surface
        Color(0xE6401E00), // deep brown
        Color(0xFF1A0900), // near-black at bottom
      ],
      stops: const [0.0, 0.35, 1.0],
    ).createShader(Rect.fromLTWH(0, baseSurfaceY, w, h - baseSurfaceY));

    canvas.drawPath(
      oilPath,
      Paint()
        ..shader = oilGrad
        ..style = PaintingStyle.fill,
    );

    // Surface glow line
    _drawSurface(canvas, size, baseSurfaceY);

    // Subsurface shine strip
    _drawSubsurfaceSheen(canvas, size, baseSurfaceY);
  }

  void _drawSurface(Canvas canvas, Size size, double baseSurfaceY) {
    final w = size.width;
    const segments = 48;

    final path = Path();
    for (int i = 0; i <= segments; i++) {
      final xNorm = i / segments;
      final x = xNorm * w;
      final y = _surfaceY(xNorm, baseSurfaceY, size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Soft glow
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF8B5500)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    // Bright highlight
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xA0D4820A)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawSubsurfaceSheen(Canvas canvas, Size size, double baseSurfaceY) {
    final w = size.width;
    const segments = 32;
    const sheenDepth = 18.0;

    final path = Path();
    for (int i = 0; i <= segments; i++) {
      final xNorm = i / segments;
      final x = xNorm * w;
      final y = _surfaceY(xNorm, baseSurfaceY, size.height) + sheenDepth;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x25C46A00)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
  }

  void _drawDrop(Canvas canvas, Size size, _OilDrop drop) {
    final x = drop.x * size.width;
    final y = drop.y * size.height;

    // Teardrop body
    final paint = Paint()
      ..color = Color.fromRGBO(160, 80, 5, drop.opacity);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, y),
        width: drop.r * 1.5,
        height: drop.r * 2.0,
      ),
      paint,
    );

    // Specular highlight
    canvas.drawCircle(
      Offset(x - drop.r * 0.25, y - drop.r * 0.3),
      drop.r * 0.22,
      Paint()..color = const Color(0x55FFFFFF),
    );
  }

  void _drawEdges(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Radial vignette — looks like looking through glass walls
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.15,
          colors: const [
            Colors.transparent,
            Color(0x99000000),
          ],
        ).createShader(rect),
    );

    // Left glass sheen
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 3, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0x18FFFFFF), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, 3, size.height)),
    );

    // Right glass sheen
    canvas.drawRect(
      Rect.fromLTWH(size.width - 3, 0, 3, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0x18FFFFFF), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, 3, size.height)),
    );
  }

  @override
  bool shouldRepaint(_OilPainter old) => true;
}
