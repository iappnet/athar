import 'dart:math' as math;
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kOnboardingSeen = 'onboarding_seen';

// ═══════════════════════════════════════════════════════════════════════════
// ONBOARDING PAGE — shown only on first launch (not logged-in users)
// ═══════════════════════════════════════════════════════════════════════════

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static Future<bool> hasBeenSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingSeen) ?? false;
  }

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _ctrl = PageController();
  int _current = 0;

  static const _visual = [
    _SlideVisual(
      icon: Icons.checklist_rounded,
      gradientColors: [Color(0xFF0B4F2A), Color(0xFF1A6B3C), Color(0xFF2E8B5A)],
      accentColor: Color(0xFF66BB6A),
    ),
    _SlideVisual(
      icon: Icons.mosque_outlined,
      gradientColors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
      accentColor: Color(0xFF64B5F6),
    ),
    _SlideVisual(
      icon: Icons.timer_outlined,
      gradientColors: [Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF7B1FA2)],
      accentColor: Color(0xFFCE93D8),
    ),
    _SlideVisual(
      icon: Icons.stars_rounded,
      gradientColors: [Color(0xFF0D4A28), Color(0xFF1A6B3C), Color(0xFF22854C)],
      accentColor: Color(0xFF81C784),
    ),
  ];

  List<_SlideData> _buildSlides(AppLocalizations l10n) => [
        _SlideData(
          category: l10n.onboardingCategory1,
          title: l10n.onboardingTitle1,
          description: l10n.onboardingDesc1,
          chips: [l10n.onboardingChip11, l10n.onboardingChip12, l10n.onboardingChip13],
          visual: _visual[0],
        ),
        _SlideData(
          category: l10n.onboardingCategory2,
          title: l10n.onboardingTitle2,
          description: l10n.onboardingDesc2,
          chips: [l10n.onboardingChip21, l10n.onboardingChip22, l10n.onboardingChip23],
          visual: _visual[1],
        ),
        _SlideData(
          category: l10n.onboardingCategory3,
          title: l10n.onboardingTitle3,
          description: l10n.onboardingDesc3,
          chips: [l10n.onboardingChip31, l10n.onboardingChip32, l10n.onboardingChip33],
          visual: _visual[2],
        ),
        _SlideData(
          category: l10n.onboardingCategory4,
          title: l10n.onboardingTitle4,
          description: l10n.onboardingDesc4,
          chips: [l10n.onboardingChip41, l10n.onboardingChip42, l10n.onboardingChip43],
          visual: _visual[3],
        ),
      ];

  Future<void> _markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingSeen, true);
  }

  Future<void> _skip() async {
    await _markSeen();
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
    final bgColor = slides[_current].visual.gradientColors.last;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Swipeable + tappable slide area
          GestureDetector(
            onTapUp: (d) => _tapAdvance(d, slides.length),
            child: PageView.builder(
              controller: _ctrl,
              onPageChanged: (i) => setState(() => _current = i),
              itemCount: slides.length,
              itemBuilder: (_, i) => _OnboardSlidePage(
                data: slides[i],
                onSkip: _skip,
              ),
            ),
          ),
          // Bottom navigation bar overlaid at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomBar(
              current: _current,
              total: slides.length,
              bgColor: bgColor,
              isLast: isLast,
              onNext: () => _next(slides.length),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Visual config (const — locale-independent) ──────────────────────────────
class _SlideVisual {
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;

  const _SlideVisual({
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
  });
}

// ─── Slide data (built at render time with l10n) ──────────────────────────────
class _SlideData {
  final String category;
  final String title;
  final String description;
  final List<String> chips;
  final _SlideVisual visual;

  const _SlideData({
    required this.category,
    required this.title,
    required this.description,
    required this.chips,
    required this.visual,
  });
}

// ─── Individual slide — full-bleed gradient ───────────────────────────────────
class _OnboardSlidePage extends StatelessWidget {
  final _SlideData data;
  final VoidCallback onSkip;

  const _OnboardSlidePage({required this.data, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: data.visual.gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // Islamic geometric pattern overlay
          Positioned.fill(
            child: CustomPaint(painter: _IslamicPatternPainter()),
          ),
          // Radial glow centred on icon
          Center(
            child: Container(
              width: 320,
              height: 320,
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
          ),
          // Content column
          SafeArea(
            child: Column(
              children: [
                // Skip button — top end
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, top: 4),
                    child: TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white60,
                      ),
                      child: Text(
                        l10n.skip,
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                // Icon circle
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 36,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(data.visual.icon, size: 56, color: Colors.white),
                ),
                const Spacer(flex: 2),
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    data.category,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.7,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Feature chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: data.chips
                      .map((c) => _FeatureChip(label: c))
                      .toList(),
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

// ─── Feature chip ─────────────────────────────────────────────────────────────
class _FeatureChip extends StatelessWidget {
  final String label;

  const _FeatureChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int current;
  final int total;
  final Color bgColor;
  final bool isLast;
  final VoidCallback onNext;

  const _BottomBar({
    required this.current,
    required this.total,
    required this.bgColor,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      color: bgColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
          child: Row(
            children: [
              // Progress dots
              Row(
                children: List.generate(total, (i) {
                  final active = i == current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.only(left: 6),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const Spacer(),
              // Next / Get Started button
              GestureDetector(
                onTap: onNext,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    isLast ? l10n.getStarted : l10n.next,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: bgColor,
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
