import 'dart:ui' show ImageFilter;

import 'package:athar/core/design_system/tokens/athar_colors.dart';
import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/design_system/tokens/athar_typography.dart';
import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:athar/core/services/prayer_timer_service.dart';
import '../../../../core/di/injection.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import '../../../../features/prayer/domain/models/prayer_timer_status.dart';
import '../../../../features/calendar/presentation/pages/calendar_page.dart';
import '../../../../features/prayer/presentation/pages/prayer_details_page.dart';
import '../../../../features/settings/presentation/pages/location_settings_page.dart';
import '../../../../features/dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
import 'package:athar/features/habits/presentation/cubit/habit_cubit.dart';

class NextPrayerCard extends StatefulWidget {
  final List<PrayerTime>? allPrayers;
  final bool expanded;

  const NextPrayerCard({super.key, this.allPrayers, this.expanded = false});

  @override
  State<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<NextPrayerCard> {
  late final PrayerTimerService _timerService;

  @override
  void initState() {
    super.initState();
    _timerService = getIt<PrayerTimerService>();
    if (widget.allPrayers != null && widget.allPrayers!.isNotEmpty) {
      _timerService.startTimer(widget.allPrayers!);
    }
  }

  @override
  void didUpdateWidget(covariant NextPrayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allPrayers != oldWidget.allPrayers && widget.allPrayers != null) {
      _timerService.startTimer(widget.allPrayers!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return StreamBuilder<PrayerTimerStatus>(
      stream: _timerService.timerStream,
      initialData: PrayerTimerStatus.initial(),
      builder: (context, snapshot) {
        final status = snapshot.data!;

        if (widget.allPrayers == null || widget.allPrayers!.isEmpty) {
          return const SizedBox.shrink();
        }

        final isActive = status.label == PrayerTimerLabel.justStarted ||
            status.label == PrayerTimerLabel.current;

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AtharSpacing.lg,
            vertical: AtharSpacing.xxs,
          ),
          decoration: BoxDecoration(
            gradient: AtharColors.prayerCardGradient,
            borderRadius: AtharRadii.radiusXxl,
            boxShadow: [
              BoxShadow(
                color: AtharColors.prayerCardShadowDeep.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AtharColors.prayerCardShadowMid.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AtharRadii.radiusXxl,
            child: Stack(
              children: [
                // Glass ::before highlight
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6],
                        ),
                      ),
                    ),
                  ),
                ),
                // Glass ::after inner hairline border.
                // Border.all (uniform color) is required when borderRadius is set.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: AtharRadii.radiusXxl,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                          width: 0.75,
                        ),
                      ),
                    ),
                  ),
                ),
                // Content
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrayerDetailsPage()),
                    ),
                    borderRadius: AtharRadii.radiusXxl,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AtharSpacing.lg,
                        vertical: AtharSpacing.md,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeader(context, status, l10n, isArabic),
                          const SizedBox(height: AtharSpacing.sm),
                          AnimatedCrossFade(
                            duration: MediaQuery.of(context).disableAnimations
                                ? Duration.zero
                                : const Duration(milliseconds: 250),
                            crossFadeState: isActive
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: _buildUpcomingHero(context, status, l10n, isArabic),
                            secondChild: _buildActiveHero(context, status, l10n, isArabic),
                          ),
                          if (!isActive) ...[
                            if (status.isDuhaTime || status.isQiyamTime) ...[
                              const SizedBox(height: AtharSpacing.xs),
                              Center(child: _buildNaflChip(status, l10n)),
                            ],
                            const SizedBox(height: AtharSpacing.sm),
                            _buildSunriseSunsetRow(status, isArabic),
                            const SizedBox(height: AtharSpacing.xs),
                            _buildProgressBar(context, status),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    PrayerTimerStatus status,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarPage()),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isArabic ? status.hijriDate : status.hijriDateEn,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    fontFamilyFallback: ['Cairo'],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isArabic ? status.gregorianDate : status.gregorianDateEn,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                    fontFamilyFallback: ['Cairo'],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AtharSpacing.sm),
        _buildCityPill(context, l10n),
      ],
    );
  }

  // The ONLY BackdropFilter on this card
  Widget _buildCityPill(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final cityName = (state is SettingsLoaded && state.settings.cityName != null)
            ? state.settings.cityName!
            : l10n.prayerCardSetLocation;
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LocationSettingsPage()),
          ),
          child: ClipRRect(
            borderRadius: AtharRadii.radiusFull,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AtharSpacing.sm,
                  vertical: AtharSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: AtharRadii.radiusFull,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 10.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: AtharSpacing.xxxs),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 80.w),
                      child: Text(
                        cityName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w400,
                          fontFamilyFallback: ['Cairo'],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingHero(
    BuildContext context,
    PrayerTimerStatus status,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final screenSize = MediaQuery.sizeOf(context);
    final isTablet = screenSize.shortestSide > 600;
    final countdownSize = isTablet
        ? AtharTypography.sizeDisplayXxl
        : (screenSize.height < 700 ? AtharTypography.sizeDisplayLg : AtharTypography.sizeDisplay44);

    final timeStr = isArabic ? status.timeLeft : status.timeLeftEn;
    final parts = timeStr.split(':');
    final String mainPart;
    final String secPart;
    if (parts.length >= 3) {
      mainPart = '${parts[0]}:${parts[1]}';
      secPart = ':${parts[2]}';
    } else if (parts.length == 2) {
      mainPart = parts[0];
      secPart = ':${parts[1]}';
    } else {
      mainPart = timeStr;
      secPart = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.prayerLabelUpcoming,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
            fontFamilyFallback: ['Cairo'],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AtharSpacing.xxxs),
        Text(
          isArabic ? status.prayerNameAr : status.prayerNameEn,
          style: TextStyle(
            color: Colors.white,
            fontSize: AtharTypography.sizeDisplayMd.sp,
            fontWeight: FontWeight.w700,
            height: 1.0,
            fontFamilyFallback: ['Cairo'],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (!widget.expanded) ...[
          const SizedBox(height: AtharSpacing.xxxs),
          Text(
            isArabic ? status.timeDisplay : status.timeDisplayEn,
            style: AtharTypography.numericMono.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.55),
              height: 1.2,
              fontFamilyFallback: ['Cairo'],
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AtharSpacing.xxs),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: mainPart,
                style: AtharTypography.numericMono.copyWith(
                  fontSize: countdownSize.sp,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                  height: 1.1,
                  fontFamilyFallback: ['Cairo'],
                ),
              ),
              TextSpan(
                text: secPart,
                style: AtharTypography.numericMono.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withValues(alpha: 0.55),
                  height: 1.1,
                  fontFamilyFallback: ['Cairo'],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveHero(
    BuildContext context,
    PrayerTimerStatus status,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.prayerCardNow,
          style: TextStyle(
            color: AtharColors.prayerCardAccent,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            fontFamilyFallback: ['Cairo'],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AtharSpacing.xxxs),
        Text(
          isArabic ? status.prayerNameAr : status.prayerNameEn,
          style: TextStyle(
            color: Colors.white,
            fontSize: AtharTypography.sizeDisplayMd.sp,
            fontWeight: FontWeight.w700,
            height: 1.0,
            fontFamilyFallback: ['Cairo'],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AtharSpacing.xxxs),
        Text(
          isArabic
              ? l10n.prayerCardStartedAt(status.timeDisplay)
              : l10n.prayerCardStartedAt(status.timeDisplayEn),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            fontFamilyFallback: ['Cairo'],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AtharSpacing.xxs),
        TextButton(
          onPressed: () async {
            final habitCubit = context.read<HabitCubit>();
            final postPrayerHabit = await habitCubit.getOrCreatePostPrayerHabit();
            if (context.mounted) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => DhikrBottomSheet(habit: postPrayerHabit),
              );
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: AtharColors.prayerCardAccent,
            padding: const EdgeInsets.symmetric(
              horizontal: AtharSpacing.md,
              vertical: AtharSpacing.xxs,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: Size.zero,
          ),
          child: Text(
            l10n.prayerCardPostPrayerAthkar,
            style: TextStyle(
              color: AtharColors.prayerCardAccent,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              fontFamilyFallback: ['Cairo'],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNaflChip(PrayerTimerStatus status, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AtharSpacing.sm,
        vertical: AtharSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: AtharRadii.radiusFull,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: AtharColors.prayerCardAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AtharSpacing.xs),
          Flexible(
            child: Text(
              status.isDuhaTime ? l10n.prayerCardDuhaTime : l10n.prayerCardQiyamTime,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                fontFamilyFallback: ['Cairo'],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunriseSunsetRow(PrayerTimerStatus status, bool isArabic) {
    final sunriseStr = isArabic
        ? (status.sunriseTime ?? '--:--')
        : (status.sunriseTimeEn ?? '--:--');
    final sunsetStr = isArabic
        ? (status.sunsetTime ?? '--:--')
        : (status.sunsetTimeEn ?? '--:--');

    final labelStyle = AtharTypography.numericMono.copyWith(
      fontSize: 11.sp,
      fontWeight: FontWeight.w300,
      color: Colors.white.withValues(alpha: 0.45),
      fontFamilyFallback: ['Cairo'],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wb_sunny_outlined, size: 12.sp, color: Colors.white.withValues(alpha: 0.45)),
            const SizedBox(width: AtharSpacing.xxxs),
            Text(sunriseStr, style: labelStyle),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(sunsetStr, style: labelStyle),
            const SizedBox(width: AtharSpacing.xxxs),
            Icon(Icons.nights_stay_outlined, size: 12.sp, color: Colors.white.withValues(alpha: 0.45)),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, PrayerTimerStatus status) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return LayoutBuilder(
      builder: (context, constraints) {
        final fillWidth = constraints.maxWidth * status.progress.clamp(0.0, 1.0);
        return ClipRRect(
          borderRadius: AtharRadii.radiusFull,
          child: SizedBox(
            height: 4.h,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(color: Colors.white.withValues(alpha: 0.1)),
                ),
                Positioned(
                  left: isRTL ? null : 0,
                  right: isRTL ? 0 : null,
                  top: 0,
                  bottom: 0,
                  width: fillWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AtharColors.prayerCardAccent,
                          Colors.white.withValues(alpha: 0.85),
                        ],
                        begin: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                        end: isRTL ? Alignment.centerLeft : Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
