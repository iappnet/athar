import 'dart:math' as math;
import 'package:athar/core/services/onboarding_analytics_service.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Variant B — forest tokens + Calibri. STRICT structural parity with OnboardingPage.
// Same slide count (4), same ARB keys, same 380ms easeInOut pacing, same nav.
// Only visuals differ: forest gradient (#0F3D2E→#1A5A45), Calibri, AppSpacing.
// DO NOT add richer animation — pacing/motion must be identical to Variant A (OQ5).

class OnboardingRestyledPage extends StatefulWidget {
  const OnboardingRestyledPage({super.key});

  @override
  State<OnboardingRestyledPage> createState() => _OnboardingRestyledPageState();
}

class _OnboardingRestyledPageState extends State<OnboardingRestyledPage> {
  final _ctrl = PageController();
  int _current = 0;
  DateTime? _startTime;
  String? _deviceId;

  static const _kForest = Color(0xFF0F3D2E);

  static const _kIcons = [
    Icons.checklist_rounded,
    Icons.mosque_outlined,
    Icons.timer_outlined,
    Icons.stars_rounded,
  ];

  static const _kAccents = [
    Color(0xFF81C784),
    Color(0xFFEDE6C8),
    Color(0xFFFFCC80),
    Color(0xFFA5D6A7),
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initAnalytics();
  }

  Future<void> _initAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');
    OnboardingAnalyticsService(deviceId: _deviceId)
        .onboardingStarted('existingRestyled');
  }

  List<_BSlideData> _buildSlides(AppLocalizations l10n) => [
    _BSlideData(
      category: l10n.onboardingCategory1,
      title: l10n.onboardingTitle1,
      description: l10n.onboardingDesc1,
      chips: [l10n.onboardingChip11, l10n.onboardingChip12, l10n.onboardingChip13],
      icon: _kIcons[0], accent: _kAccents[0],
    ),
    _BSlideData(
      category: l10n.onboardingCategory2,
      title: l10n.onboardingTitle2,
      description: l10n.onboardingDesc2,
      chips: [l10n.onboardingChip21, l10n.onboardingChip22, l10n.onboardingChip23],
      icon: _kIcons[1], accent: _kAccents[1],
    ),
    _BSlideData(
      category: l10n.onboardingCategory3,
      title: l10n.onboardingTitle3,
      description: l10n.onboardingDesc3,
      chips: [l10n.onboardingChip31, l10n.onboardingChip32, l10n.onboardingChip33],
      icon: _kIcons[2], accent: _kAccents[2],
    ),
    _BSlideData(
      category: l10n.onboardingCategory4,
      title: l10n.onboardingTitle4,
      description: l10n.onboardingDesc4,
      chips: [l10n.onboardingChip41, l10n.onboardingChip42, l10n.onboardingChip43],
      icon: _kIcons[3], accent: _kAccents[3],
    ),
  ];

  Future<void> _markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    await prefs.setString('onboarding_variant', 'existingRestyled');
  }

  void _emitCompleted() {
    final ms = _startTime == null
        ? 0
        : DateTime.now().difference(_startTime!).inMilliseconds;
    OnboardingAnalyticsService(deviceId: _deviceId).onboardingCompleted(
      variant: 'existingRestyled',
      durationMs: ms,
    );
  }

  Future<void> _skip() async {
    await _markSeen();
    _emitCompleted();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _next(int total) async {
    if (_current < total - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    } else {
      await _markSeen();
      _emitCompleted();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _tapAdvance(TapUpDetails details, int total) {
    final width = MediaQuery.sizeOf(context).width;
    if (details.globalPosition.dx > width * 0.5) {
      _next(total);
    } else if (_current > 0) {
      _ctrl.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = _buildSlides(l10n);
    final isLast = _current == slides.length - 1;

    return Scaffold(
      backgroundColor: _kForest,
      body: Stack(
        children: [
          GestureDetector(
            onTapUp: (d) => _tapAdvance(d, slides.length),
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (i) => setState(() => _current = i),
              itemCount: slides.length,
              itemBuilder: (_, i) => _BSlide(
                data: slides[i],
                onSkip: _skip,
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BBottomBar(
              current: _current,
              total: slides.length,
              isLast: isLast,
              onNext: () => _next(slides.length),
            ),
          ),
        ],
      ),
    );
  }
}

class _BSlideData {
  final String category, title, description;
  final List<String> chips;
  final IconData icon;
  final Color accent;
  const _BSlideData({
    required this.category, required this.title, required this.description,
    required this.chips, required this.icon, required this.accent,
  });
}

class _BSlide extends StatelessWidget {
  final _BSlideData data;
  final VoidCallback onSkip;
  static const _kForest    = Color(0xFF0F3D2E);
  static const _kForestMid = Color(0xFF1A5A45);

  const _BSlide({required this.data, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kForest, _kForestMid],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ForestPatternPainter())),
          Center(
            child: Container(
              width: 320, height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Colors.white.withValues(alpha: 0.07),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8, top: 4),
                    child: TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(foregroundColor: Colors.white60),
                      child: Text(
                        l10n.skip,
                        style: const TextStyle(
                          fontFamily: 'Calibri',
                          fontFamilyFallback: ['Cairo'],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 36, offset: const Offset(0, 12),
                    )],
                  ),
                  child: Icon(data.icon, size: 56, color: data.accent),
                ),
                const Spacer(flex: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    data.category,
                    style: const TextStyle(
                      fontFamily: 'Calibri',
                      fontFamilyFallback: ['Cairo'],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Calibri',
                      fontFamilyFallback: ['Cairo'],
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Calibri',
                      fontFamilyFallback: const ['Cairo'],
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.7,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: data.chips.map((c) => _BChip(label: c, accent: data.accent)).toList(),
                ),
                const Spacer(flex: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BChip extends StatelessWidget {
  final String label;
  final Color accent;
  const _BChip({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Calibri',
          fontFamilyFallback: const ['Cairo'],
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: accent,
        ),
      ),
    );
  }
}

class _BBottomBar extends StatelessWidget {
  final int current, total;
  final bool isLast;
  final VoidCallback onNext;
  static const _kForest    = Color(0xFF0F3D2E);
  static const _kForestMid = Color(0xFF1A5A45);
  static const _kCream     = Color(0xFFEDE6C8);

  const _BBottomBar({
    required this.current, required this.total,
    required this.isLast, required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      color: _kForestMid,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
          child: Row(
            children: [
              Row(
                children: List.generate(total, (i) {
                  final active = i == current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsetsDirectional.only(start: 6),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active ? _kCream : _kCream.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onNext,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: _kCream,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    isLast ? l10n.getStarted : l10n.next,
                    style: const TextStyle(
                      fontFamily: 'Calibri',
                      fontFamilyFallback: ['Cairo'],
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _kForest,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForestPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final cx = size.width / 2, cy = size.height / 2;
    final maxR = size.width * 0.8;
    for (int ring = 1; ring <= 4; ring++) {
      final r = maxR * ring / 4;
      _drawStar8(canvas, cx, cy, r, paint);
      canvas.drawCircle(Offset(cx, cy), r * 0.7, paint);
    }
  }

  void _drawStar8(Canvas canvas, double cx, double cy, double r, Paint paint) {
    final path = Path();
    final inner = r * 0.4;
    for (int i = 0; i < 16; i++) {
      final angle = (i * math.pi / 8) - math.pi / 2;
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
