import 'package:athar/core/design_system/tokens/athar_typography.dart';
import 'package:athar/core/services/onboarding_analytics_service.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Variant C — short (2 slides). Forest palette + Calibri. Same 380ms easeInOut as A.
// Slide 1: brand icon + feature pills + Continue. Slide 2: CTA → /login.

class OnboardingShortPage extends StatefulWidget {
  const OnboardingShortPage({super.key});

  @override
  State<OnboardingShortPage> createState() => _OnboardingShortPageState();
}

class _OnboardingShortPageState extends State<OnboardingShortPage> {
  final _ctrl = PageController();
  DateTime? _startTime;
  String? _deviceId;

  static const _kForest = Color(0xFF0F3D2E);

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _initAnalytics();
  }

  Future<void> _initAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');
    OnboardingAnalyticsService(deviceId: _deviceId).onboardingStarted('short');
  }

  Future<void> _markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    await prefs.setString('onboarding_variant', 'short');
  }

  void _emitCompleted() {
    final ms = _startTime == null
        ? 0
        : DateTime.now().difference(_startTime!).inMilliseconds;
    OnboardingAnalyticsService(deviceId: _deviceId).onboardingCompleted(
      variant: 'short',
      durationMs: ms,
    );
  }

  Future<void> _finish() async {
    await _markSeen();
    _emitCompleted();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _kForest,
      body: PageView(
        controller: _ctrl,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _CWelcomeSlide(
            l10n: l10n,
            onContinue: () => _ctrl.nextPage(
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeInOut,
            ),
            onSkip: _finish,
          ),
          _CStartSlide(l10n: l10n, onGetStarted: _finish),
        ],
      ),
    );
  }
}

// ── Slide 1: Welcome ─────────────────────────────────────────────────────────

class _CWelcomeSlide extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  static const _kForest    = Color(0xFF0F3D2E);
  static const _kForestMid = Color(0xFF1A5A45);
  static const _kCream     = Color(0xFFEDE6C8);

  const _CWelcomeSlide({
    required this.l10n,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kForest, _kForestMid],
        ),
      ),
      child: SafeArea(
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
                      fontFamily: AtharTypography.fontFamily,
                      fontFamilyFallback: ['Cairo'],
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
            Container(
              width: 96, height: 96,
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
              child: const Icon(Icons.mosque_rounded, size: 52, color: _kCream),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                l10n.onboardingShortWelcomeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AtharTypography.fontFamily,
                  fontFamilyFallback: ['Cairo'],
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                l10n.onboardingShortWelcomeSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AtharTypography.fontFamily,
                  fontFamilyFallback: const ['Cairo'],
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CFeaturePill(
                  icon: Icons.checklist_rounded,
                  label: l10n.onboardingShortWelcomeFeatureTasks,
                ),
                const SizedBox(width: 12),
                _CFeaturePill(
                  icon: Icons.mosque_outlined,
                  label: l10n.onboardingShortWelcomeFeaturePrayer,
                ),
                const SizedBox(width: 12),
                _CFeaturePill(
                  icon: Icons.timer_outlined,
                  label: l10n.onboardingShortWelcomeFeatureFocus,
                ),
              ],
            ),
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: GestureDetector(
                onTap: onContinue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _kCream,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    l10n.next,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AtharTypography.fontFamily,
                      fontFamilyFallback: ['Cairo'],
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kForest,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CFeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  static const _kCream = Color(0xFFEDE6C8);

  const _CFeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: _kCream),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AtharTypography.fontFamily,
              fontFamilyFallback: ['Cairo'],
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _kCream,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide 2: Start ────────────────────────────────────────────────────────────

class _CStartSlide extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onGetStarted;

  static const _kForest    = Color(0xFF0F3D2E);
  static const _kForestMid = Color(0xFF1A5A45);
  static const _kCream     = Color(0xFFEDE6C8);

  const _CStartSlide({required this.l10n, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kForest, _kForestMid],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                l10n.onboardingShortStartTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AtharTypography.fontFamily,
                  fontFamilyFallback: ['Cairo'],
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Text(
                l10n.onboardingShortStartSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AtharTypography.fontFamily,
                  fontFamilyFallback: const ['Cairo'],
                  fontSize: 17,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
            ),
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: GestureDetector(
                onTap: onGetStarted,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _kCream,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Text(
                    l10n.onboardingShortStartCta,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AtharTypography.fontFamily,
                      fontFamilyFallback: ['Cairo'],
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kForest,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
