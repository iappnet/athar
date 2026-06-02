import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../features/settings/data/models/user_settings.dart';
import 'oil_simulator.dart';

// §7 — Focus Oil palette (file-private; Focus-specific, not in AtharColors).
const Color _oilBlack          = Color(0xFF000000);
const Color _bgTop             = Color(0xFF0D141A);
const Color _bgBottom          = Color(0xFF050709);
const Color _surfaceHighlight  = Color(0x12FFFFFF); // rgba(255,255,255,0.07)
const Color _surfaceHighlight2 = Color(0x06FFFFFF); // rgba(255,255,255,0.025)
const Color _columnFade        = Color(0xCC000000); // column gradient mid stop

// OilBackground
//
// Perf: RepaintBoundary + CustomPainter. No MaskFilter.blur on hot paths.
//       Gradient strips replace Gaussian blur.

class OilBackground extends StatefulWidget {
  const OilBackground({
    super.key,
    required this.fillFraction,
    required this.isRunning,
    required this.isCompleted,
    required this.intensity,
    required this.reduceMotion,
    required this.disableGyroscope,
    required this.tiltX,
    required this.tiltY,
  });

  final double fillFraction; // 0.0 → 1.0
  final bool isRunning;
  final bool isCompleted;
  final FocusIntensity intensity;
  final bool reduceMotion;
  final bool disableGyroscope;

  // Accumulated tilt angles in degrees, supplied by FocusScreen each frame.
  // OilSimulator applies the 0.85/0.15 low-pass inside updateTilt().
  // When disableGyroscope or reduceMotion, caller passes 0.0/0.0.
  final double tiltX; // gamma — horizontal lean (±30°)
  final double tiltY; // beta  — vertical lean   (±20°)

  @override
  State<OilBackground> createState() => _OilBackgroundState();
}

class _OilBackgroundState extends State<OilBackground>
    with SingleTickerProviderStateMixin {
  late final OilSimulator _sim;
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _sim = OilSimulator(seed: DateTime.now().millisecondsSinceEpoch & 0xFFFF);
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final double dt = _lastTick == Duration.zero
        ? 0.0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;

    if (dt <= 0 || dt > 0.1) return; // skip first frame + large gaps

    if (!widget.reduceMotion) {
      // DEV7: forward screen tilt → simulator low-pass each tick.
      _sim.updateTilt(widget.tiltX, widget.tiltY);
      final cfg = OilTierConfig.resolve(
        fillFraction: widget.fillFraction,
        intensity: widget.intensity,
      );
      _sim.tick(dt, _size, widget.fillFraction, cfg, widget.isRunning);
    }

    setState(() {}); // trigger repaint
  }

  Size _size = Size.zero;

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          _size = Size(constraints.maxWidth, constraints.maxHeight);
          final cfg = OilTierConfig.resolve(
            fillFraction: widget.fillFraction,
            intensity: widget.intensity,
          );
          return CustomPaint(
            painter: _OilPainter(
              sim: _sim,
              fillFraction: widget.fillFraction,
              isRunning: widget.isRunning,
              isCompleted: widget.isCompleted,
              cfg: cfg,
              reduceMotion: widget.reduceMotion,
              t: _sim.t,
            ),
            size: _size,
          );
        },
      ),
    );
  }
}

class _OilPainter extends CustomPainter {
  _OilPainter({
    required this.sim,
    required this.fillFraction,
    required this.isRunning,
    required this.isCompleted,
    required this.cfg,
    required this.reduceMotion,
    required this.t,
  });

  final OilSimulator sim;
  final double fillFraction;
  final bool isRunning;
  final bool isCompleted;
  final OilTierConfig cfg;
  final bool reduceMotion;
  final double t;

  @override
  bool shouldRepaint(_OilPainter old) => true; // fluid animation always repaints

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);

    if (reduceMotion) {
      _drawStaticFill(canvas, size);
      return;
    }

    _drawOilFill(canvas, size);
    if (isRunning) {
      _drawDripColumn(canvas, size);
    }
    _drawBubbles(canvas, size);
    if (cfg.splashScale > 0 && isRunning) {
      _drawSplashRipples(canvas, size);
    }
  }

  // ── Background: deep navy vignette ─────────────────────────────────────────

  void _drawBackground(Canvas canvas, Size size) {
    // Radial vignette: bright-ish centre (_bgTop), dark edges (_bgBottom).
    final Paint bg = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width / 2, size.height * 0.45),
        size.width * 0.7,
        [_bgTop, _bgBottom],
        [0.0, 1.0],
      );
    canvas.drawRect(Offset.zero & size, bg);
  }

  // ── Static fill (reduceMotion) ──────────────────────────────────────────────

  void _drawStaticFill(Canvas canvas, Size size) {
    final double fillTop = size.height * (1.0 - fillFraction);
    final Rect rect = Rect.fromLTWH(0, fillTop, size.width, size.height - fillTop);
    canvas.drawRect(rect, Paint()..color = _oilBlack);

    // single surface highlight strip
    final Paint strip = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, fillTop),
        Offset(0, fillTop + 8),
        [_surfaceHighlight, Colors.transparent],
      );
    canvas.drawRect(Rect.fromLTWH(0, fillTop, size.width, 8), strip);
  }

  // ── Animated oil fill ───────────────────────────────────────────────────────

  void _drawOilFill(Canvas canvas, Size size) {
    final Path path = Path();
    const int steps = 60;
    final double dx = size.width / steps;

    // build surface path
    path.moveTo(0, sim.surfaceY(0, size, fillFraction, cfg));
    for (int i = 1; i <= steps; i++) {
      final double x = i * dx;
      path.lineTo(x, sim.surfaceY(x, size, fillFraction, cfg));
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, Paint()..color = _oilBlack);

    // surface highlight: gradient strip instead of MaskFilter.blur
    _drawSurfaceHighlight(canvas, size, path);
  }

  void _drawSurfaceHighlight(Canvas canvas, Size size, Path oilPath) {
    // Primary 1.5pt highlight at surface — rgba(255,255,255,0.07)
    const double hH = 4.0;
    final Paint primary = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        const Offset(0, hH),
        [_surfaceHighlight, Colors.transparent],
      )
      ..blendMode = BlendMode.screen;

    // clip to just above fill
    canvas.save();
    canvas.clipPath(oilPath);
    // draw the strip at the oil top — approximate by offsetting path bounds
    // We draw it across the full width at each surface y point
    for (int i = 0; i < 60; i++) {
      final double x = i * (size.width / 60);
      final double sy = sim.surfaceY(x, size, fillFraction, cfg);
      canvas.drawRect(
        Rect.fromLTWH(x, sy, size.width / 60 + 1, hH),
        primary,
      );
    }
    canvas.restore();

    // Secondary 1pt highlight — rgba(255,255,255,0.025)
    final Paint secondary = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        const Offset(0, 8),
        [_surfaceHighlight2, Colors.transparent],
      )
      ..blendMode = BlendMode.screen;
    canvas.save();
    canvas.clipPath(oilPath);
    for (int i = 0; i < 60; i++) {
      final double x = i * (size.width / 60);
      final double sy = sim.surfaceY(x, size, fillFraction, cfg) + 4.0;
      canvas.drawRect(
        Rect.fromLTWH(x, sy, size.width / 60 + 1, 8.0),
        secondary,
      );
    }
    canvas.restore();
  }

  // ── Drip column ─────────────────────────────────────────────────────────────

  void _drawDripColumn(Canvas canvas, Size size) {
    final double colX = sim.columnXPx(size, cfg);
    final double pulse = sim.columnPulse(cfg);
    final double surfY = sim.surfaceY(colX, size, fillFraction, cfg);
    final double colTop = surfY - 30.0 - pulse;

    final double colWidth = 2.5 + pulse * 0.15;

    final Paint colPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(colX, colTop),
        Offset(colX, surfY),
        [Colors.transparent, _columnFade, _oilBlack],
        [0.0, 0.6, 1.0],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(colX - colWidth / 2, colTop, colWidth, surfY - colTop),
        const Radius.circular(2),
      ),
      colPaint,
    );

    // falling drops
    final Paint dropPaint = Paint()..color = _oilBlack;
    for (final OilDrop d in sim.drops) {
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(d.x, d.y), width: colWidth * 1.2, height: 6.0),
        dropPaint,
      );
    }
  }

  // ── Bubbles ─────────────────────────────────────────────────────────────────

  void _drawBubbles(Canvas canvas, Size size) {
    for (final OilBubble b in sim.bubbles) {
      final double alpha = (0.06 * b.life).clamp(0.0, 0.06);
      final Paint p = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7;
      canvas.drawCircle(Offset(b.x, b.y), b.radius, p);
    }
  }

  // ── Splash ripples (standard/intense only) ──────────────────────────────────

  void _drawSplashRipples(Canvas canvas, Size size) {
    // lightweight concentric oval ripples near surface at column anchor
    final double colX = sim.columnXPx(size, cfg);
    final double surfY = sim.surfaceY(colX, size, fillFraction, cfg);
    final double phase = (t * 1.8) % (2 * math.pi);

    for (int i = 0; i < 2; i++) {
      final double r =
          (10.0 + i * 14.0) * ((phase / (2 * math.pi) + i * 0.5) % 1.0);
      final double alpha = cfg.splashScale *
          0.08 *
          (1.0 - (r / 30.0).clamp(0.0, 1.0));
      if (alpha <= 0) continue;
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(colX, surfY), width: r * 2, height: r * 0.4),
        Paint()
          ..color = Colors.white.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    }
  }
}
