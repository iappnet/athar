import 'dart:async';
import 'dart:math' as math;
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/biometric_service.dart';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SPLASH PAGE — brand-aligned animated entry screen
// ═══════════════════════════════════════════════════════════════════════════

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  bool _isTimerDone = false;
  AuthState? _lastState;

  late final AnimationController _logoCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _patternCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _taglineOpacity;
  late final Animation<double> _taglineSlide;
  late final Animation<double> _pulse;
  late final Animation<double> _patternAngle;

  @override
  void initState() {
    super.initState();
    _lastState = context.read<AuthCubit>().state;

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = _logoCtrl
        .drive(CurveTween(curve: Curves.elasticOut))
        .drive(Tween(begin: 0.4, end: 1.0));
    _logoOpacity = _logoCtrl
        .drive(CurveTween(curve: const Interval(0.0, 0.5, curve: Curves.easeIn)))
        .drive(Tween(begin: 0.0, end: 1.0));
    _taglineOpacity = _logoCtrl
        .drive(CurveTween(curve: const Interval(0.55, 1.0, curve: Curves.easeIn)))
        .drive(Tween(begin: 0.0, end: 1.0));
    _taglineSlide = _logoCtrl
        .drive(CurveTween(curve: const Interval(0.55, 1.0, curve: Curves.easeOut)))
        .drive(Tween(begin: 16.0, end: 0.0));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulse = _pulseCtrl
        .drive(CurveTween(curve: Curves.easeInOut))
        .drive(Tween(begin: 0.92, end: 1.08));

    _patternCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _patternAngle = _patternCtrl.drive(Tween(begin: 0.0, end: 2 * math.pi));

    _logoCtrl.forward();

    Timer(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _isTimerDone = true);
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _patternCtrl.dispose();
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
      _toOnboarding();
    } else if (authState is AuthProfileIncomplete) {
      Navigator.of(context).pushReplacementNamed('/complete_profile');
    } else {
      _toOnboarding();
    }
  }

  void _toOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const OnboardingPage(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
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
          body: AnimatedBuilder(
            animation: Listenable.merge([_logoCtrl, _pulseCtrl, _patternCtrl]),
            builder: (_, _) => _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D4A28),
            Color(0xFF1A6B3C),
            Color(0xFF22854C),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Slow-rotating geometric pattern
          Positioned.fill(
            child: Transform.rotate(
              angle: _patternAngle.value,
              child: Transform.scale(
                scale: _pulse.value,
                child: CustomPaint(painter: _IslamicPatternPainter()),
              ),
            ),
          ),

          // Radial glow
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Logo + text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: _LogoMark(),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _logoOpacity,
                child: const Text(
                  'أثر',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 52,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Transform.translate(
                offset: Offset(0, _taglineSlide.value),
                child: FadeTransition(
                  opacity: _taglineOpacity,
                  child: const Text(
                    'حياة متوازنة · أثر مستدام',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Bottom dots
          Positioned(
            bottom: 56,
            child: FadeTransition(
              opacity: _taglineOpacity,
              child: const _PulsingDots(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Logo circle ──────────────────────────────────────────────────────────────
class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(56, 56),
          painter: _AtharMarkPainter(),
        ),
      ),
    );
  }
}

// ─── Islamic 8-pointed star pattern ──────────────────────────────────────────
class _IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width * 0.8;

    for (int ring = 1; ring <= 4; ring++) {
      final r = maxR * ring / 4;
      _drawStar8(canvas, cx, cy, r, paint);
      canvas.drawCircle(Offset(cx, cy), r * 0.7, paint);
    }
  }

  void _drawStar8(Canvas canvas, double cx, double cy, double r, Paint paint) {
    final path = Path();
    const pts = 8;
    final inner = r * 0.4;
    for (int i = 0; i < pts * 2; i++) {
      final angle = (i * math.pi / pts) - math.pi / 2;
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

// ─── Stylised "أ" mark ───────────────────────────────────────────────────────
class _AtharMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    canvas.drawLine(Offset(w * 0.5, h * 0.1), Offset(w * 0.5, h * 0.75), stroke);

    final base = Path()
      ..moveTo(w * 0.15, h * 0.75)
      ..cubicTo(w * 0.15, h * 0.95, w * 0.85, h * 0.95, w * 0.85, h * 0.75);
    canvas.drawPath(base, stroke);

    canvas.drawCircle(
      Offset(w * 0.5, h * 0.25),
      3.5,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── Pulsing loading dots ────────────────────────────────────────────────────
class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true),
    );
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].forward();
      });
    }
    _anims = _controllers
        .map((c) => c
            .drive(CurveTween(curve: Curves.easeInOut))
            .drive(Tween(begin: 0.4, end: 1.0)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedBuilder(
            animation: _anims[i],
            builder: (_, _) => Opacity(
              opacity: _anims[i].value,
              child: const SizedBox(
                width: 6,
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ONBOARDING PAGE
// ═══════════════════════════════════════════════════════════════════════════

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _ctrl = PageController();
  int _current = 0;

  static const _pages = <_OnboardData>[
    _OnboardData(
      icon: Icons.checklist_rounded,
      color: Color(0xFF1A6B3C),
      accentColor: Color(0xFFD4EDDA),
    ),
    _OnboardData(
      icon: Icons.mosque_outlined,
      color: Color(0xFF1565C0),
      accentColor: Color(0xFFE3F2FD),
    ),
    _OnboardData(
      icon: Icons.timer_outlined,
      color: Color(0xFF6A1B9A),
      accentColor: Color(0xFFF3E5F5),
    ),
    _OnboardData(
      icon: Icons.favorite_outline_rounded,
      color: Color(0xFFC62828),
      accentColor: Color(0xFFFFEBEE),
    ),
  ];

  void _next() {
    if (_current < _pages.length - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() => Navigator.of(context).pushReplacementNamed('/login');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLast = _current == _pages.length - 1;
    final accentColor = _pages[_current].color;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    l10n.skip,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Color(0xFF636E72),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _current = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardSlide(data: _pages[i], index: i),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final active = i == _current;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? accentColor : const Color(0xFFDFE6E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isLast ? l10n.getStarted : l10n.next,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final IconData icon;
  final Color color;
  final Color accentColor;

  const _OnboardData({
    required this.icon,
    required this.color,
    required this.accentColor,
  });
}

class _OnboardSlide extends StatelessWidget {
  final _OnboardData data;
  final int index;

  const _OnboardSlide({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final titles = [
      l10n.onboardingTitle1,
      l10n.onboardingTitle2,
      l10n.onboardingTitle3,
      l10n.onboardingTitle4,
    ];
    final descs = [
      l10n.onboardingDesc1,
      l10n.onboardingDesc2,
      l10n.onboardingDesc3,
      l10n.onboardingDesc4,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: data.accentColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(data.icon, size: 88, color: data.color),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            titles[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: data.color,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            descs[index],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              color: Color(0xFF636E72),
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
