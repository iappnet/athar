import 'package:athar/core/design_system/tokens/athar_colors.dart';
import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../../../features/settings/presentation/cubit/settings_state.dart';
import '../../../../features/settings/data/models/user_settings.dart';
import '../../../../features/prayer/presentation/cubit/prayer_cubit.dart';
import '../../../../features/prayer/presentation/cubit/prayer_state.dart';
import 'next_prayer_card.dart';

enum PageType { dashboard, tasks, habits, projects }

class SmartPrayerCardWrapper extends StatelessWidget {
  final PageType pageType;

  const SmartPrayerCardWrapper({super.key, required this.pageType});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        if (settingsState is! SettingsLoaded) return const SizedBox.shrink();

        final settings = settingsState.settings;

        if (!settings.isPrayerEnabled) return const SizedBox.shrink();
        if (!settings.isPrayerCardEnabled) return const SizedBox.shrink();

        bool shouldShow = false;
        switch (pageType) {
          case PageType.dashboard:
            shouldShow = true;
          case PageType.tasks:
            shouldShow = settings.prayerCardDisplayMode == PrayerCardDisplayMode.dashboardAndTasks ||
                settings.prayerCardDisplayMode == PrayerCardDisplayMode.allPages;
          case PageType.habits:
          case PageType.projects:
            shouldShow = settings.prayerCardDisplayMode == PrayerCardDisplayMode.allPages;
        }

        if (!shouldShow) return const SizedBox.shrink();

        return BlocBuilder<PrayerCubit, PrayerState>(
          builder: (context, prayerState) {
            if (prayerState is PrayerLoaded) {
              return NextPrayerCard(allPrayers: prayerState.allPrayers);
            }

            if (prayerState is PrayerLoading || prayerState is PrayerInitial) {
              return _buildCardSkeleton();
            }

            if (prayerState is PrayerError) {
              // Location not configured — show inline prompt
              if (settings.cityName == null || settings.cityName!.isEmpty) {
                return _buildLocationPrompt(context);
              }
              return _buildErrorCard(context, prayerState.message);
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildCardSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AtharSpacing.lg,
        vertical: AtharSpacing.xxs,
      ),
      height: 148,
      decoration: BoxDecoration(
        gradient: AtharColors.prayerCardGradient,
        borderRadius: AtharRadii.radiusXxl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AtharSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShimmer(width: 110, height: 11),
                _buildShimmer(width: 64, height: 22, radius: AtharRadii.radiusFull),
              ],
            ),
            const Spacer(),
            Center(child: _buildShimmer(width: 80, height: 14)),
            const SizedBox(height: AtharSpacing.xxs),
            Center(child: _buildShimmer(width: 160, height: 42)),
            const Spacer(),
            _buildShimmer(width: double.infinity, height: 4, radius: AtharRadii.radiusFull),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(
    {required double width, required double height, BorderRadius? radius}) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: radius ?? AtharRadii.radiusSm,
      ),
    );
  }

  Widget _buildLocationPrompt(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AtharSpacing.lg,
        vertical: AtharSpacing.xxs,
      ),
      decoration: BoxDecoration(
        gradient: AtharColors.prayerCardGradient,
        borderRadius: AtharRadii.radiusXxl,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AtharSpacing.lg,
          vertical: AtharSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_off_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: 20.sp,
            ),
            const SizedBox(width: AtharSpacing.sm),
            Expanded(
              child: Text(
                l10n.prayerCardEnableLocation,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  fontFamilyFallback: ['Cairo'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AtharSpacing.lg,
        vertical: AtharSpacing.xxs,
      ),
      padding: const EdgeInsets.all(AtharSpacing.md),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: AtharRadii.radiusLg,
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_rounded, color: cs.error, size: 20.sp),
          const SizedBox(width: AtharSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: cs.error, fontSize: 12.sp, fontFamilyFallback: ['Cairo']),
            ),
          ),
          TextButton(
            onPressed: () => context.read<PrayerCubit>().loadPrayerTimes(),
            child: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}
