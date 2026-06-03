import 'package:athar/core/design_system/tokens/athar_colors.dart';
import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_typography.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/location_service.dart';
import 'package:athar/core/services/notification_service.dart';
import 'package:athar/core/services/onboarding_analytics_service.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:athar/features/settings/presentation/pages/location_settings_page.dart';
import 'package:athar/features/space/presentation/cubit/join_space_cubit.dart';
import 'package:athar/features/space/presentation/cubit/space_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Variant D — expanded onboarding (6-step PageView). Forest palette + Calibri.
// OQ1: Prayer+Dhikr real toggles; Tasks+Habits always-included chips; Health/Assets hidden.
// Step 03 (Location) skipped if Prayer is OFF.
// DO NOT add richer animation — pacing identical to Variant A (OQ5).

class OnboardingExpandedPage extends StatefulWidget {
  const OnboardingExpandedPage({super.key});

  @override
  State<OnboardingExpandedPage> createState() => _OnboardingExpandedPageState();
}

class _OnboardingExpandedPageState extends State<OnboardingExpandedPage>
    with WidgetsBindingObserver {
  final _ctrl = PageController();
  final _joinCodeController = TextEditingController();

  int _currentPage = 0;
  bool _prayerOn = true;
  bool _dhikrOn = false;
  bool _locationGranted = false;
  bool _notificationsGranted = false;
  bool _spaceCreated = false;
  bool _completed = false;
  bool _joinCodeExpanded = false;
  bool _locationLoading = false;
  bool _joinLoading = false;

  DateTime? _startTime;
  String? _deviceId;

  static const _kForest    = AtharColors.prayerCardShadowDeep;
  static const _kForestMid = AtharColors.prayerCardShadowMid;
  static const _kCream     = AtharColors.cream;

  static const _kLocationPage = 2;
  static const _kTotalPages   = 6;

  OnboardingAnalyticsService get _analytics =>
      OnboardingAnalyticsService(deviceId: _deviceId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTime = DateTime.now();
    _initAnalytics();
  }

  Future<void> _initAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');
    _analytics.onboardingStarted('expanded');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && !_completed) {
      _analytics.onboardingAbandoned(
        variant: 'expanded',
        lastStep: '0${_currentPage + 1}',
      );
    }
  }

  String _stepLabel(int pageIndex) => '0${pageIndex + 1}';

  Future<void> _goNext() async {
    if (_currentPage == _kTotalPages - 1) {
      await _finish();
      return;
    }

    _analytics.onboardingStepCompleted(
      variant: 'expanded',
      step: _stepLabel(_currentPage),
    );

    var next = _currentPage + 1;
    if (next == _kLocationPage && !_prayerOn) {
      _analytics.onboardingStepSkipped(
        variant: 'expanded',
        step: _stepLabel(next),
      );
      next++;
    }

    _ctrl.animateToPage(
      next,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    await prefs.setString('onboarding_variant', 'expanded');
  }

  Future<void> _finish() async {
    setState(() => _completed = true);

    if (!_spaceCreated) {
      try {
        await context.read<SpaceCubit>().createSpace('مساحتي', isShared: false);
      } catch (_) {}
    }

    await _markSeen();

    final ms = _startTime == null
        ? 0
        : DateTime.now().difference(_startTime!).inMilliseconds;
    _analytics.onboardingCompleted(
      variant: 'expanded',
      durationMs: ms,
      locationGranted: _locationGranted,
      notificationsGranted: _notificationsGranted,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _requestLocation() async {
    setState(() => _locationLoading = true);
    final cubit = context.read<SettingsCubit>();
    try {
      final pos = await getIt<LocationService>().getCurrentLocation();
      if (pos != null && mounted) {
        final city = await getIt<LocationService>()
            .getCityName(pos.latitude, pos.longitude);
        final state = cubit.state;
        if (state is SettingsLoaded && mounted) {
          final s = state.settings;
          s.latitude = pos.latitude;
          s.longitude = pos.longitude;
          s.cityName = city;
          await cubit.updateSettings(s);
          if (mounted) setState(() => _locationGranted = true);
        }
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  Future<void> _openManualLocation() async {
    final cubit = context.read<SettingsCubit>();
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LocationSettingsPage()),
    );
    if (!mounted) return;
    final state = cubit.state;
    if (state is SettingsLoaded) {
      final s = state.settings;
      if (s.cityName != null && s.cityName!.isNotEmpty) {
        setState(() => _locationGranted = true);
      }
    }
  }

  Future<void> _requestNotifications() async {
    final granted = await getIt<NotificationService>().requestPermissions();
    if (mounted) setState(() => _notificationsGranted = granted);
  }

  Future<void> _joinSpace() async {
    final token = _joinCodeController.text.trim();
    if (token.isEmpty) return;
    setState(() => _joinLoading = true);
    try {
      await getIt<JoinSpaceCubit>().joinSpace(token);
      if (mounted) setState(() => _spaceCreated = true);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _joinLoading = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ctrl.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kForest,
      body: PageView(
        controller: _ctrl,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: [
          _buildWelcome(context),
          _buildModules(context),
          _buildLocation(context),
          _buildNotifications(context),
          _buildSpace(context),
          _buildFinish(context),
        ],
      ),
    );
  }

  // ── Shared scaffold ────────────────────────────────────────────────────────

  Widget _stepScaffold({
    required Widget child,
    required VoidCallback onNext,
    required String nextLabel,
    String? skipLabel,
    VoidCallback? onSkip,
  }) {
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
            _StepIndicator(current: _currentPage, total: _kTotalPages),
            Expanded(child: child),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
              child: GestureDetector(
                onTap: onNext,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _kCream,
                    borderRadius: BorderRadius.circular(AtharRadii.full),
                  ),
                  child: Text(
                    nextLabel,
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
            if (skipLabel != null && onSkip != null)
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(foregroundColor: Colors.white54),
                child: Text(
                  skipLabel,
                  style: const TextStyle(
                    fontFamily: AtharTypography.fontFamily,
                    fontFamilyFallback: ['Cairo'],
                    fontSize: 14,
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── Step 01: Welcome ───────────────────────────────────────────────────────

  Widget _buildWelcome(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _stepScaffold(
      onNext: _goNext,
      nextLabel: l10n.next,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: const Icon(Icons.mosque_rounded, size: 48, color: _kCream),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Text(
              l10n.onboardingExpandedWelcomeTitle,
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
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 44),
            child: Text(
              l10n.onboardingExpandedWelcomeSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: const ['Cairo'],
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 02: Modules ───────────────────────────────────────────────────────

  Widget _buildModules(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _stepScaffold(
      onNext: _goNext,
      nextLabel: l10n.next,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              l10n.onboardingExpandedModulesTitle,
              style: const TextStyle(
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: ['Cairo'],
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.onboardingExpandedModulesSubtitle,
              style: TextStyle(
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: const ['Cairo'],
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 32),
            _ModuleToggleRow(
              label: l10n.onboardingExpandedModulesPrayerLabel,
              icon: Icons.mosque_outlined,
              value: _prayerOn,
              onChanged: (v) {
                setState(() => _prayerOn = v);
                context.read<SettingsCubit>().togglePrayerEnabled(v);
              },
            ),
            const SizedBox(height: 16),
            _ModuleToggleRow(
              label: l10n.onboardingExpandedModulesDhikrLabel,
              icon: Icons.auto_awesome_rounded,
              value: _dhikrOn,
              onChanged: (v) {
                setState(() => _dhikrOn = v);
                context.read<SettingsCubit>().toggleAthkarEnabled(v);
              },
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _AlwaysIncludedChip(label: l10n.onboardingExpandedModulesTasksLabel),
                _AlwaysIncludedChip(label: l10n.onboardingExpandedModulesHabitsLabel),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 03: Location ──────────────────────────────────────────────────────

  Widget _buildLocation(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _stepScaffold(
      onNext: _goNext,
      nextLabel: l10n.next,
      skipLabel: l10n.skip,
      onSkip: _goNext,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              l10n.onboardingExpandedLocationTitle,
              style: const TextStyle(
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: ['Cairo'],
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.onboardingExpandedLocationSubtitle,
              style: TextStyle(
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: const ['Cairo'],
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 32),
            if (_locationGranted)
              _GrantedBadge(icon: Icons.location_on_rounded)
            else ...[
              _DOutlineButton(
                label: l10n.onboardingExpandedLocationUseCurrent,
                icon: Icons.my_location_rounded,
                loading: _locationLoading,
                onTap: _requestLocation,
              ),
              const SizedBox(height: 12),
              _DOutlineButton(
                label: l10n.onboardingExpandedLocationEnterManual,
                icon: Icons.edit_outlined,
                onTap: _openManualLocation,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Step 04: Notifications ─────────────────────────────────────────────────

  Widget _buildNotifications(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _stepScaffold(
      onNext: _goNext,
      nextLabel: l10n.next,
      skipLabel: l10n.skip,
      onSkip: _goNext,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              l10n.onboardingExpandedNotificationsTitle,
              style: const TextStyle(
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: ['Cairo'],
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.onboardingExpandedNotificationsSubtitle,
              style: TextStyle(
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: const ['Cairo'],
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 32),
            if (_notificationsGranted)
              _GrantedBadge(icon: Icons.notifications_active_rounded)
            else
              _DOutlineButton(
                label: l10n.onboardingExpandedNotificationsAllow,
                icon: Icons.notifications_outlined,
                onTap: _requestNotifications,
              ),
          ],
        ),
      ),
    );
  }

  // ── Step 05: Space ─────────────────────────────────────────────────────────

  Widget _buildSpace(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _stepScaffold(
      onNext: _goNext,
      nextLabel: l10n.next,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              l10n.onboardingExpandedSpaceTitle,
              style: const TextStyle(
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: ['Cairo'],
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.onboardingExpandedSpaceSubtitle,
              style: TextStyle(
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: const ['Cairo'],
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: _kCream.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AtharRadii.lg),
                border: Border.all(color: _kCream.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_rounded, color: _kCream, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.onboardingExpandedSpaceJustForMe,
                      style: const TextStyle(
                        fontFamily: AtharTypography.fontFamily,
                        fontFamilyFallback: ['Cairo'],
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _kCream,
                      ),
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: _kCream, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (!_spaceCreated) ...[
              GestureDetector(
                onTap: () => setState(() => _joinCodeExpanded = !_joinCodeExpanded),
                child: Text(
                  l10n.onboardingExpandedSpaceJoinCode,
                  style: TextStyle(
                    fontFamily: AtharTypography.fontFamily,
                    fontFamilyFallback: const ['Cairo'],
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 260),
                crossFadeState: _joinCodeExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _joinCodeController,
                          style: const TextStyle(
                            fontFamily: AtharTypography.fontFamily,
                            fontFamilyFallback: ['Cairo'],
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.onboardingExpandedSpaceCodeHint,
                            hintStyle: TextStyle(color: Colors.white38),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AtharRadii.md),
                              borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AtharRadii.md),
                              borderSide: BorderSide(color: _kCream),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _joinLoading ? null : _joinSpace,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: _kCream,
                            borderRadius: BorderRadius.circular(AtharRadii.md),
                          ),
                          child: _joinLoading
                              ? const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _kForest,
                                  ),
                                )
                              : Text(
                                  l10n.onboardingExpandedSpaceJoin,
                                  style: const TextStyle(
                                    fontFamily: AtharTypography.fontFamily,
                                    fontFamilyFallback: ['Cairo'],
                                    fontSize: 14,
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
            ] else
              _GrantedBadge(icon: Icons.groups_rounded),
          ],
        ),
      ),
    );
  }

  // ── Step 06: Finish ────────────────────────────────────────────────────────

  Widget _buildFinish(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recaps = <String>[
      if (_prayerOn)           l10n.onboardingExpandedFinishRecapPrayer,
      if (_dhikrOn)            l10n.onboardingExpandedFinishRecapDhikr,
      if (_locationGranted)    l10n.onboardingExpandedFinishRecapLocation,
      if (_notificationsGranted) l10n.onboardingExpandedFinishRecapNotifications,
      l10n.onboardingExpandedFinishRecapSpace,
    ];
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            const Icon(Icons.check_circle_rounded, size: 64, color: _kCream),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                l10n.onboardingExpandedFinishTitle,
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
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Text(
                l10n.onboardingExpandedFinishSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AtharTypography.fontFamily,
                  fontFamilyFallback: const ['Cairo'],
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
            ),
            if (recaps.isNotEmpty) ...[
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Wrap(
                  spacing: 10, runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: recaps
                      .map((r) => _RecapChip(label: r))
                      .toList(),
                ),
              ),
            ],
            const Spacer(flex: 3),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: GestureDetector(
                onTap: _finish,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _kCream,
                    borderRadius: BorderRadius.circular(AtharRadii.full),
                  ),
                  child: Text(
                    l10n.onboardingExpandedFinishCta,
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

// ── Private widgets ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  static const _kCream = AtharColors.cream;

  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final active = i == current;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? _kCream : _kCream.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AtharRadii.xxs),
            ),
          );
        }),
      ),
    );
  }
}

class _ModuleToggleRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  static const _kCream = AtharColors.cream;

  const _ModuleToggleRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _kCream.withValues(alpha: 0.8), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AtharTypography.fontFamily,
              fontFamilyFallback: ['Cairo'],
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: _kCream,
          activeTrackColor: _kCream.withValues(alpha: 0.35),
          inactiveThumbColor: Colors.white38,
          inactiveTrackColor: Colors.white12,
        ),
      ],
    );
  }
}

class _AlwaysIncludedChip extends StatelessWidget {
  final String label;
  static const _kCream = AtharColors.cream;

  const _AlwaysIncludedChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AtharRadii.xl),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 14, color: _kCream.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AtharTypography.fontFamily,
              fontFamilyFallback: const ['Cairo'],
              fontSize: 13,
              color: _kCream.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _DOutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool loading;
  static const _kCream  = AtharColors.cream;
  static const _kForest = AtharColors.prayerCardShadowDeep;

  const _DOutlineButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: _kCream,
          borderRadius: BorderRadius.circular(AtharRadii.lg),
        ),
        child: loading
            ? const Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _kForest,
                  ),
                ),
              )
            : Row(
                children: [
                  Icon(icon, color: _kForest, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      fontFamily: AtharTypography.fontFamily,
                      fontFamilyFallback: ['Cairo'],
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _kForest,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GrantedBadge extends StatelessWidget {
  final IconData icon;
  static const _kCream = AtharColors.cream;

  const _GrantedBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AtharRadii.lg),
        border: Border.all(color: _kCream.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _kCream, size: 20),
          const SizedBox(width: 10),
          Icon(Icons.check_circle_rounded, color: _kCream, size: 18),
        ],
      ),
    );
  }
}

class _RecapChip extends StatelessWidget {
  final String label;
  static const _kCream = AtharColors.cream;

  const _RecapChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AtharRadii.xl),
        border: Border.all(color: _kCream.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 13, color: _kCream.withValues(alpha: 0.8)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AtharTypography.fontFamily,
              fontFamilyFallback: const ['Cairo'],
              fontSize: 13,
              color: _kCream.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
