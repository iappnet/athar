import 'dart:async';
import 'dart:math' as math;
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/biometric_service.dart';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:athar/features/home/presentation/pages/onboarding_page.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SPLASH PAGE
// Shown only on return launches (first launch goes straight to OnboardingPage).
// Design: deep-dark cosmic background · self-drawing Islamic star · floating
// particles · "أثر" slides up · shimmer progress bar.
// ═══════════════════════════════════════════════════════════════════════════

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  bool _isTimerDone = false;
  AuthState? _lastState;

  // Star draw animation
  late final AnimationController _starCtrl;
  late final Animation<double> _starProgress;

  // Text entry
  late final AnimationController _textCtrl;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textSlide;
  late final Animation<double> _taglineOpacity;

  // Bottom progress shimmer
  late final AnimationController _progressCtrl;
  late final Animation<double> _progressWidth;

  // Ambient pulse on star glow
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowRadius;

  @override
  void initState() {
    super.initState();
    _lastState = context.read<AuthCubit>().state;

    // ── Star self-draw ────────────────────────────────────────────────────
    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _starProgress = CurvedAnimation(
      parent: _starCtrl,
      curve: Curves.easeInOut,
    );

    // ── Text ─────────────────────────────────────────────────────────────
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn);
    _textSlide = _textCtrl
        .drive(CurveTween(curve: Curves.easeOut))
        .drive(Tween(begin: 22.0, end: 0.0));
    _taglineOpacity = CurvedAnimation(
      parent: _textCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    // ── Progress bar ─────────────────────────────────────────────────────
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _progressWidth = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeInOut,
    );

    // ── Glow pulse ───────────────────────────────────────────────────────
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _glowRadius = _glowCtrl
        .drive(CurveTween(curve: Curves.easeInOut))
        .drive(Tween(begin: 0.7, end: 1.0));

    // ── Sequence ─────────────────────────────────────────────────────────
    _starCtrl.forward().then((_) {
      _textCtrl.forward();
    });
    _progressCtrl.forward();

    Timer(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      setState(() => _isTimerDone = true);
      if (_lastState != null) _navigate(_lastState!);
    });
  }

  @override
  void dispose() {
    _starCtrl.dispose();
    _textCtrl.dispose();
    _progressCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  void _navigate(AuthState authState) async {
    if (!mounted) return;

    if (authState is AuthAuthenticated) {
      final settingsState = context.read<SettingsCubit>().state;
      bool biometricEnabled = false;
      if (settingsState is SettingsLoaded) {
        biometricEnabled = settingsState.settings.isBiometricEnabled;
      } else {
        try {
          final s = await getIt<SettingsRepository>().getSettings();
          biometricEnabled = s.isBiometricEnabled;
        } catch (_) {}
      }
      if (!mounted) return;
      if (biometricEnabled) {
        try {
          final ok = await getIt<BiometricService>().authenticate();
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(ok ? '/home' : '/login');
        } catch (_) {
          if (mounted) Navigator.of(context).pushReplacementNamed('/login');
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else if (authState is AuthGuest) {
      await _toOnboarding();
    } else if (authState is AuthProfileIncomplete) {
      Navigator.of(context).pushReplacementNamed('/complete_profile');
    } else {
      await _toOnboarding();
    }
  }

  Future<void> _toOnboarding() async {
    final seen = await OnboardingPage.hasBeenSeen();
    if (!mounted) return;
    if (seen) {
      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const OnboardingPage(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        _lastState = state;
        if (_isTimerDone) _navigate(state);
      },
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, _) {
          if (_isTimerDone && _lastState != null) _navigate(_lastState!);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF07111A),
          body: AnimatedBuilder(
            animation: Listenable.merge(
                [_starCtrl, _textCtrl, _progressCtrl, _glowCtrl]),
            builder: (_, _) => _buildBody(context),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Background gradient ─────────────────────────────────────────
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF07111A), // deep navy
                Color(0xFF0A1C12), // deep forest
                Color(0xFF060E0A), // near black
              ],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),

        // ── Subtle arabesque lattice ────────────────────────────────────
        Positioned.fill(
          child: CustomPaint(painter: _LatticePainter()),
        ),

        // ── Floating star particles ─────────────────────────────────────
        ...List.generate(10, (i) => _FloatingParticle(seed: i * 37 + 11)),

        // ── Central ambient glow behind star ────────────────────────────
        Center(
          child: Container(
            width: 200 * _glowRadius.value,
            height: 200 * _glowRadius.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF22A05B).withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // ── Hero content ────────────────────────────────────────────────
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Self-drawing star
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _StarDrawPainter(progress: _starProgress.value),
              ),
            ),

            const SizedBox(height: 36),

            // "أثر" title
            Transform.translate(
              offset: Offset(0, _textSlide.value),
              child: Opacity(
                opacity: _textOpacity.value,
                child: const Text(
                  'أثر',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Tagline
            Opacity(
              opacity: _taglineOpacity.value,
              child: const Text(
                'حياة متوازنة · أثر مستدام',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Color(0xFF6EAF8A),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),

        // ── Bottom progress bar ─────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 64,
          child: Column(
            children: [
              SizedBox(
                width: 160,
                height: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: _progressWidth.value,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A6B3C), Color(0xFF4ADE80)],
                          ),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Self-drawing 8-pointed Islamic star ─────────────────────────────────────
class _StarDrawPainter extends CustomPainter {
  final double progress;
  _StarDrawPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final R = size.width * 0.44; // outer radius
    final r = R * 0.42; // inner radius
    const pts = 8;

    // Build the star path
    final path = Path();
    for (int i = 0; i < pts * 2; i++) {
      final angle = (i * math.pi / pts) - math.pi / 2;
      final radius = i.isEven ? R : r;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();

    // Draw the traced portion
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final drawLen = metric.length * progress;

    final tracePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    if (drawLen > 0) {
      canvas.drawPath(metric.extractPath(0, drawLen), tracePaint);
    }

    // Glow fill when nearly complete
    if (progress > 0.85) {
      final fillOpacity = ((progress - 0.85) / 0.15).clamp(0.0, 1.0);
      final fillPaint = Paint()
        ..color = const Color(0xFF22A05B).withValues(alpha: 0.08 * fillOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }

    // Centre dot (appears when drawing completes)
    if (progress > 0.7) {
      final dotOpacity = ((progress - 0.7) / 0.3).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(cx, cy),
        3.5,
        Paint()
          ..color = Colors.white.withValues(alpha: dotOpacity)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_StarDrawPainter old) => old.progress != progress;
}

// ─── Ultra-subtle arabesque lattice background ────────────────────────────────
class _LatticePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const spacing = 56.0;
    final cols = (size.width / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * spacing;
        final cy = r * spacing;
        _drawMiniStar(canvas, cx, cy, spacing * 0.28, paint);
      }
    }
  }

  void _drawMiniStar(
      Canvas canvas, double cx, double cy, double r, Paint paint) {
    final inner = r * 0.4;
    const pts = 4;
    final path = Path();
    for (int i = 0; i < pts * 2; i++) {
      final angle = (i * math.pi / pts) - math.pi / 4;
      final radius = i.isEven ? r : inner;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── Individual floating star particle ───────────────────────────────────────
class _FloatingParticle extends StatefulWidget {
  final int seed;
  const _FloatingParticle({required this.seed});

  @override
  State<_FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<_FloatingParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final double _x;
  late final double _startY;
  late final double _size;
  late final double _driftX;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(widget.seed);
    _x = rng.nextDouble();
    _startY = 0.3 + rng.nextDouble() * 0.6;
    _size = 1.5 + rng.nextDouble() * 2.0;
    _driftX = (rng.nextDouble() - 0.5) * 0.06;

    final duration = Duration(milliseconds: 3500 + rng.nextInt(3000));
    _ctrl = AnimationController(vsync: this, duration: duration)
      ..repeat();

    // stagger start
    final delay = Duration(milliseconds: rng.nextInt(3000));
    Future.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = _ctrl.value;
        final opacity =
            (t < 0.15 ? t / 0.15 : t > 0.75 ? (1 - t) / 0.25 : 1.0)
                .clamp(0.0, 1.0);
        final x = (_x + _driftX * t) * size.width;
        final y = (_startY - t * 0.35) * size.height;
        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: opacity * 0.7,
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ADE80).withValues(alpha: 0.6),
                    blurRadius: _size * 2,
                    spreadRadius: _size * 0.5,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
