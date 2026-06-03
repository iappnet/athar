// lib/features/home/presentation/pages/dashboard_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.2
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/utils/responsive_helper.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/features/calendar/presentation/pages/calendar_page.dart';
import 'package:athar/features/notifications/presentation/widgets/notification_center_button.dart';
import 'package:athar/features/settings/presentation/pages/general_settings_page.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/time_engine/athar_time_calculator.dart';
import '../../../../core/time_engine/athar_time_periods.dart';
import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
import 'package:athar/core/design_system/molecules/cards/athkar_dashboard_card.dart';
import 'package:athar/features/home/presentation/pages/smart_habits_strip.dart';
import '../../../habits/presentation/cubit/habit_cubit.dart';
import '../../../task/presentation/cubit/task_cubit.dart';
import '../../../stats/presentation/widgets/statistics_card.dart';
import 'package:athar/features/home/presentation/widgets/daily_timeline_widget.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import '../../../../features/sync/presentation/cubit/sync_cubit.dart';
import '../../../../features/sync/presentation/cubit/sync_state.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_state.dart';


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _getSmartGreeting(AppLocalizations l10n, String? userName) {
    final period = AtharTimeCalculator.approximatePeriod();
    final name = (userName != null && userName.isNotEmpty)
        ? l10n.greetingName(userName)
        : "";

    switch (period) {
      case AtharTimePeriod.dawn:
      case AtharTimePeriod.bakur:
      case AtharTimePeriod.morning:
      case AtharTimePeriod.duha:
        return l10n.goodMorning(name);
      case AtharTimePeriod.noon:
      case AtharTimePeriod.afternoon:
        return l10n.goodAfternoon(name);
      case AtharTimePeriod.maghrib:
      case AtharTimePeriod.isha:
        return l10n.goodEvening(name);
      case AtharTimePeriod.night:
      case AtharTimePeriod.lastThird:
      case AtharTimePeriod.undefined:
        return l10n.goodNight(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors from context
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<TaskCubit>()..watchTasks(DateTime.now()),
        ),
        BlocProvider(create: (context) => getIt<HabitCubit>()..loadHabits()),
        BlocProvider(create: (context) => getIt<HealthCubit>()),
      ],
      child: BlocListener<SyncCubit, SyncState>(
        listener: (context, state) {
          if (state is SyncError) {
            // ✅ يمكن استخدام AtharSnackbar.error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                // ✅ Colors.red → colors.error
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is SyncSuccess) {
            // ✅ يمكن استخدام AtharSnackbar.success
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.syncSuccessful),
                // ✅ Colors.green → colors.success
                backgroundColor: context.colors.success,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
          builder: (context, authState) {
            String? currentUserName;

            if (authState is AuthAuthenticated) {
              currentUserName = authState.fullName ?? authState.username;
            }

            final greeting = _getSmartGreeting(l10n, currentUserName);
            final dateStr = DateFormat(
              'EEEE, d MMMM',
              'ar',
            ).format(DateTime.now());

            return Scaffold(
              backgroundColor: colorScheme.surface,
              body: SafeArea(
                top: false,
                bottom: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.isTablet
                          ? ResponsiveHelper.maxContentWidth
                          : double.infinity,
                    ),
                    child: CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          stretch: true,
                          expandedHeight: 144.h,
                          collapsedHeight: 68.h,
                          toolbarHeight: 68.h,
                          automaticallyImplyLeading: false,
                          backgroundColor: colorScheme.surface.withValues(alpha: 0.96),
                          surfaceTintColor: Colors.transparent,
                          elevation: 0,
                          scrolledUnderElevation: 0,
                          leadingWidth: 56.w,
                          leading: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GeneralSettingsPage(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.settings_outlined,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          actions: [
                            const NotificationCenterButton(),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CalendarPage(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.calendar_month_rounded,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            AtharGap.hSm,
                          ],
                          flexibleSpace: LayoutBuilder(
                            builder: (context, constraints) {
                              final expandedRange = 144.h - 68.h;
                              final currentHeight = constraints.biggest.height;
                              final t = ((currentHeight - 68.h) / expandedRange).clamp(0.0, 1.0);

                              return ClipRect(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              colorScheme.surface.withValues(alpha: 0.96),
                                              colorScheme.surface.withValues(alpha: 0.84),
                                            ],
                                          ),
                                          border: Border(
                                            bottom: BorderSide(
                                              color: colorScheme.outlineVariant.withValues(alpha: 0.16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 16.w,
                                      right: 88.w,
                                      bottom: 14.h,
                                      child: Opacity(
                                        opacity: t,
                                        child: Transform.translate(
                                          offset: Offset(0, (1 - t) * -8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                greeting,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 23.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: colorScheme.onSurface,
                                                ),
                                              ),
                                              AtharGap.xxs,
                                              Text(
                                                dateStr,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 72.w,
                                      right: 88.w,
                                      bottom: 12.h,
                                      child: IgnorePointer(
                                        child: Opacity(
                                          opacity: 1 - t,
                                          child: Text(
                                            greeting,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.w700,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _buildSyncStatusHeader(context, colorScheme),
                        ),
                        const SliverToBoxAdapter(
                          child: SmartPrayerCardWrapper(
                            pageType: PageType.dashboard,
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AtharSpacing.lg,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              AtharGap.md,
                              const StatisticsCard(),
                              AtharGap.lg,
                              const AthkarDashboardCard(),
                              AtharGap.xxl,
                              const SmartHabitsStrip(),
                              AtharGap.xxl,
                              const DailyTimelineWidget(moduleId: null),
                              SizedBox(height: 156.h),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSyncStatusHeader(BuildContext context, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
      builder: (context, authState) {
        if (authState is AuthGuest || authState is AuthUnauthenticated) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AtharSpacing.lg,
            vertical: AtharSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BlocBuilder<SyncCubit, SyncState>(
                buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
                builder: (context, state) {
                  final isLoading = state is SyncLoading;

                  return InkWell(
                    onTap: () {
                      context.read<SyncCubit>().triggerSync(isManual: true);
                    },
                    // ✅ BorderRadius.circular(20) → AtharRadii.radiusXl
                    borderRadius: AtharRadii.radiusXl,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AtharSpacing.md,
                        vertical: AtharSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        // ✅ Colors.white → colors.surface
                        color: colorScheme.surface,
                        borderRadius: AtharRadii.radiusXl,
                        // ✅ Colors.grey.shade200 → colors.borderLight
                        border: Border.all(color: colorScheme.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLoading ? l10n.syncing : l10n.sync,
                            // ✅ AtharTypography
                            style:
                                TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  letterSpacing: 0.5,
                                ).copyWith(
                                  // ✅ AppColors.textPrimary → colors.textPrimary
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          // ✅ SizedBox(width: 8.w) → AtharGap.hSm
                          AtharGap.hSm,
                          isLoading
                              ? SizedBox(
                                  width: 14.sp,
                                  height: 14.sp,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    // ✅ AppColors.primary → colors.primary
                                    color: colorScheme.primary,
                                  ),
                                )
                              : Icon(
                                  Icons.cloud_sync_rounded,
                                  size: 18.sp,
                                  color: state is SyncError
                                      // ✅ Colors.red → colors.error
                                      ? colorScheme.error
                                      : state is SyncSuccess
                                      // ✅ Colors.green → colors.success
                                      ? context.colors.success
                                      // ✅ AppColors.primary → colors.primary
                                      : colorScheme.primary,
                                ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

