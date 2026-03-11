// lib/features/home/presentation/pages/dashboard_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.2
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

import '../../../../core/di/injection.dart';
import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
import 'package:athar/features/home/presentation/pages/smart_habits_strip.dart';
import 'package:athar/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:athar/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:athar/features/notifications/presentation/pages/notification_center_page.dart';
import '../../../habits/presentation/cubit/habit_cubit.dart';
import '../../../task/presentation/cubit/task_cubit.dart';
import '../../../stats/presentation/widgets/statistics_card.dart';
import 'package:athar/features/home/presentation/widgets/daily_timeline_widget.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import '../../../../features/sync/presentation/cubit/sync_cubit.dart';
import '../../../../features/sync/presentation/cubit/sync_state.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_state.dart';

/// Semantic colors (not in ColorScheme)
const _successColor = Color(0xFF00B894);

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _getSmartGreeting(AppLocalizations l10n, String? userName) {
    final hour = DateTime.now().hour;
    final name = (userName != null && userName.isNotEmpty)
        ? l10n.greetingName(userName)
        : "";

    if (hour >= 5 && hour < 12) {
      return l10n.goodMorning(name);
    } else if (hour >= 12 && hour < 17) {
      return l10n.goodAfternoon(name);
    } else if (hour >= 17 && hour < 21) {
      return l10n.goodEvening(name);
    } else {
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
        BlocProvider(
          create: (context) =>
              getIt<NotificationsCubit>()..watchNotifications(),
        ),
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
                backgroundColor: _successColor,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
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
              // ✅ AppColors.background → colors.background
              backgroundColor: colorScheme.surface,
              appBar: AtharAppBar(
                title: greeting,
                subtitle: dateStr,
                actions: [
                  BlocBuilder<NotificationsCubit, NotificationsState>(
                    builder: (context, state) {
                      int count = 0;
                      if (state is NotificationsLoaded) {
                        count = state.unreadCount;
                      }
                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationCenterPage(),
                              ),
                            ),
                          ),
                          if (count > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: EdgeInsets.all(AtharSpacing.xxs),
                                decoration: BoxDecoration(
                                  // ✅ Colors.red → colors.error
                                  color: colorScheme.error,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "$count",
                                  // ✅ AtharTypography
                                  style:
                                      TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                        letterSpacing: 0.5,
                                      ).copyWith(
                                        // ✅ Colors.white → colors.onPrimary
                                        color: colorScheme.onPrimary,
                                        fontSize: 8.sp,
                                      ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: AtharSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // شريط حالة المزامنة
                      _buildSyncStatusHeader(context, colorScheme),

                      // بطاقة الصلاة
                      const SmartPrayerCardWrapper(
                        pageType: PageType.dashboard,
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AtharSpacing.lg,
                        ),
                        child: Column(
                          children: [
                            // ✅ SizedBox(height: 12.h) → AtharGap.md
                            AtharGap.md,

                            // بطاقة الإحصائيات
                            const StatisticsCard(),

                            // ✅ SizedBox(height: 24.h) → AtharGap.xxl
                            AtharGap.xxl,

                            // شريط العادات الذكي
                            const SmartHabitsStrip(),

                            AtharGap.xxl,

                            // التايملاين اليومي
                            const DailyTimelineWidget(moduleId: null),

                            SizedBox(height: 80.h),
                          ],
                        ),
                      ),
                    ],
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
                                      ? _successColor
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
//--------------------------------------------------------------
// // lib/features/home/presentation/pages/dashboard_page.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 2 | File 2.2
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';

// import '../../../../core/di/injection.dart';
// import '../../../../core/design_system/organisms/app_bar/athar_app_bar.dart';
// import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
// import 'package:athar/features/home/presentation/pages/smart_habits_strip.dart';
// import 'package:athar/features/notifications/presentation/cubit/notifications_cubit.dart';
// import 'package:athar/features/notifications/presentation/cubit/notifications_state.dart';
// import 'package:athar/features/notifications/presentation/pages/notification_center_page.dart';
// import '../../../habits/presentation/cubit/habit_cubit.dart';
// import '../../../task/presentation/cubit/task_cubit.dart';
// import '../../../stats/presentation/widgets/statistics_card.dart';
// import 'package:athar/features/home/presentation/widgets/daily_timeline_widget.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import '../../../../features/sync/presentation/cubit/sync_cubit.dart';
// import '../../../../features/sync/presentation/cubit/sync_state.dart';
// import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
// import '../../../../features/auth/presentation/cubit/auth_state.dart';

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});

//   String _getSmartGreeting(AppLocalizations l10n, String? userName) {
//     final hour = DateTime.now().hour;
//     final name = (userName != null && userName.isNotEmpty)
//         ? l10n.greetingName(userName)
//         : "";

//     if (hour >= 5 && hour < 12) {
//       return l10n.goodMorning(name);
//     } else if (hour >= 12 && hour < 17) {
//       return l10n.goodAfternoon(name);
//     } else if (hour >= 17 && hour < 21) {
//       return l10n.goodEvening(name);
//     } else {
//       return l10n.goodNight(name);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => getIt<TaskCubit>()..watchTasks(DateTime.now()),
//         ),
//         BlocProvider(create: (context) => getIt<HabitCubit>()..loadHabits()),
//         BlocProvider(create: (context) => getIt<HealthCubit>()),
//         BlocProvider(
//           create: (context) =>
//               getIt<NotificationsCubit>()..watchNotifications(),
//         ),
//       ],
//       child: BlocListener<SyncCubit, SyncState>(
//         listener: (context, state) {
//           if (state is SyncError) {
//             // ✅ يمكن استخدام AtharSnackbar.error
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 // ✅ Colors.red → colors.error
//                 backgroundColor: colors.error,
//                 behavior: SnackBarBehavior.floating,
//                 duration: const Duration(seconds: 3),
//               ),
//             );
//           } else if (state is SyncSuccess) {
//             // ✅ يمكن استخدام AtharSnackbar.success
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(l10n.syncSuccessful),
//                 // ✅ Colors.green → colors.success
//                 backgroundColor: colors.success,
//                 behavior: SnackBarBehavior.floating,
//                 duration: const Duration(seconds: 2),
//               ),
//             );
//           }
//         },
//         child: BlocBuilder<AuthCubit, AuthState>(
//           builder: (context, authState) {
//             String? currentUserName;

//             if (authState is AuthAuthenticated) {
//               currentUserName = authState.fullName ?? authState.username;
//             }

//             final greeting = _getSmartGreeting(l10n, currentUserName);
//             final dateStr = DateFormat(
//               'EEEE, d MMMM',
//               'ar',
//             ).format(DateTime.now());

//             return Scaffold(
//               // ✅ AppColors.background → colors.background
//               backgroundColor: colors.background,
//               appBar: AtharAppBar(
//                 title: greeting,
//                 subtitle: dateStr,
//                 actions: [
//                   BlocBuilder<NotificationsCubit, NotificationsState>(
//                     builder: (context, state) {
//                       int count = 0;
//                       if (state is NotificationsLoaded) {
//                         count = state.unreadCount;
//                       }
//                       return Stack(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.notifications_none_rounded),
//                             onPressed: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const NotificationCenterPage(),
//                               ),
//                             ),
//                           ),
//                           if (count > 0)
//                             Positioned(
//                               right: 8,
//                               top: 8,
//                               child: Container(
//                                 padding: EdgeInsets.all(AtharSpacing.xxs),
//                                 decoration: BoxDecoration(
//                                   // ✅ Colors.red → colors.error
//                                   color: colors.error,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Text(
//                                   "$count",
//                                   // ✅ AtharTypography
//                                   style: AtharTypography.labelSmall.copyWith(
//                                     // ✅ Colors.white → colors.onPrimary
//                                     color: colors.onPrimary,
//                                     fontSize: 8.sp,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               body: SafeArea(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.only(bottom: AtharSpacing.xl),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // شريط حالة المزامنة
//                       _buildSyncStatusHeader(context, colors),

//                       // بطاقة الصلاة
//                       const SmartPrayerCardWrapper(
//                         pageType: PageType.dashboard,
//                       ),

//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: AtharSpacing.lg,
//                         ),
//                         child: Column(
//                           children: [
//                             // ✅ SizedBox(height: 12.h) → AtharGap.md
//                             AtharGap.md,

//                             // بطاقة الإحصائيات
//                             const StatisticsCard(),

//                             // ✅ SizedBox(height: 24.h) → AtharGap.xxl
//                             AtharGap.xxl,

//                             // شريط العادات الذكي
//                             const SmartHabitsStrip(),

//                             AtharGap.xxl,

//                             // التايملاين اليومي
//                             const DailyTimelineWidget(moduleId: null),

//                             SizedBox(height: 80.h),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSyncStatusHeader(BuildContext context, AtharColors colors) {
//     final l10n = AppLocalizations.of(context);
//     return BlocBuilder<AuthCubit, AuthState>(
//       builder: (context, authState) {
//         if (authState is AuthGuest || authState is AuthUnauthenticated) {
//           return const SizedBox.shrink();
//         }

//         return Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: AtharSpacing.lg,
//             vertical: AtharSpacing.sm,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               BlocBuilder<SyncCubit, SyncState>(
//                 builder: (context, state) {
//                   final isLoading = state is SyncLoading;

//                   return InkWell(
//                     onTap: () {
//                       context.read<SyncCubit>().triggerSync(isManual: true);
//                     },
//                     // ✅ BorderRadius.circular(20) → AtharRadii.radiusXl
//                     borderRadius: AtharRadii.radiusXl,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: AtharSpacing.md,
//                         vertical: AtharSpacing.xs,
//                       ),
//                       decoration: BoxDecoration(
//                         // ✅ Colors.white → colors.surface
//                         color: colors.surface,
//                         borderRadius: AtharRadii.radiusXl,
//                         // ✅ Colors.grey.shade200 → colors.borderLight
//                         border: Border.all(color: colors.borderLight),
//                         boxShadow: [
//                           BoxShadow(
//                             color: colors.shadow.withValues(alpha: 0.3),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             isLoading ? l10n.syncing : l10n.sync,
//                             // ✅ AtharTypography
//                             style: AtharTypography.labelMedium.copyWith(
//                               // ✅ AppColors.textPrimary → colors.textPrimary
//                               color: colors.textPrimary,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           // ✅ SizedBox(width: 8.w) → AtharGap.hSm
//                           AtharGap.hSm,
//                           isLoading
//                               ? SizedBox(
//                                   width: 14.sp,
//                                   height: 14.sp,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     // ✅ AppColors.primary → colors.primary
//                                     color: colors.primary,
//                                   ),
//                                 )
//                               : Icon(
//                                   Icons.cloud_sync_rounded,
//                                   size: 18.sp,
//                                   color: state is SyncError
//                                       // ✅ Colors.red → colors.error
//                                       ? colors.error
//                                       : state is SyncSuccess
//                                       // ✅ Colors.green → colors.success
//                                       ? colors.success
//                                       // ✅ AppColors.primary → colors.primary
//                                       : colors.primary,
//                                 ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

//----------------------------------------------------------


//   // ✅ دالة ذكية لتحديد التحية المناسبة بناءً على الوقت
//   // ✅ دالة ذكية لتحديد التحية المناسبة بناءً على الوقت واسم المستخدم
//     // إذا لم نجد اسماً، نستخدم "أيها القائد" أو "بك" كخيار احتياطي


//       providers: [
//         BlocProvider(
//         ),

//         // ✅ 3. إضافة HealthCubit لكي تعمل أزرار الأدوية داخل التايم لاين
//         // ✅ إضافة تفعيل مراقبة التنبيهات عند فتح الصفحة الرئيسية
//         BlocProvider(
//               getIt<NotificationsCubit>()..watchNotifications(),
//         ),
//       // الاستماع لحالة المزامنة
//       child: BlocListener<SyncCubit, SyncState>(
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//                 behavior: SnackBarBehavior.floating,
//                 duration: const Duration(seconds: 3),
//               ),
//             ScaffoldMessenger.of(context).showSnackBar(
//                 content: Text("تمت المزامنة بنجاح"),
//                 backgroundColor: Colors.green,
//                 behavior: SnackBarBehavior.floating,
//                 duration: Duration(seconds: 2),
//               ),
//         },
//         // داخل دالة build في DashboardPage
//         child: BlocBuilder<AuthCubit, AuthState>(
//             // ✅ تصحيح استخراج الاسم بناءً على هيكلية AuthAuthenticated الخاصة بك

//               // نستخدم fullName إذا وجد، وإلا نستخدم الـ username

//             // ✅ استدعاء التحية مع تمرير الاسم الصحيح
//               'EEEE, d MMMM',
//               'ar',
//             // تنسيق التاريخ للترحيب
//             //   'EEEE, d MMMM',
//             //   'ar',
//               backgroundColor: AppColors.background,
//               appBar: AtharAppBar(
//                 // title: "أهلاً بك 👋",
//                 // ✅ استخدام التحية الذكية بدلاً من "أهلاً بك" الثابتة
//                 title: greeting,
//                 subtitle: dateStr,
//                 actions: [
//                   BlocBuilder<NotificationsCubit, NotificationsState>(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.notifications_none_rounded),
//                               context,
//                               MaterialPageRoute(
//                               ),
//                             ),
//                           ),
//                             Positioned(
//                               right: 8,
//                               top: 8,
//                               child: Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: const BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Text(
//                                   "$count",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 8.sp,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                     },
//                   ),
//               ),
//               body: SafeArea(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.only(bottom: 20.h),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // شريط حالة المزامنة في الأعلى
//                       _buildSyncStatusHeader(context),

//                       // الغلاف الذكي للبطاقة
//                         pageType: PageType.dashboard,
//                       ),

//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16.w),
//                         child: Column(
//                           children: [
//                             SizedBox(height: 12.h),

//                             // بطاقة الإحصائيات

//                             SizedBox(height: 24.h),

//                             // شريط العادات الذكي

//                             SizedBox(height: 24.h),

//                             // ✅ 4. هنا الدمج الكبير: استبدال القائمة القديمة بالجديدة
//                             // نمرر moduleId: null ليعمل في الوضع العام (Global Mode)

//                             SizedBox(height: 80.h),
//                         ),
//                       ),
//                   ),
//                 ),
//               ),
//           },
//         ),
//       ),

//   // دالة بناء زر المزامنة
//         // إذا كان المستخدم ضيفاً، نخفي الزر

//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               BlocBuilder<SyncCubit, SyncState>(

//                     },
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12.w,
//                         vertical: 6.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: Colors.grey.shade200),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.03),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             isLoading ? "جاري المزامنة..." : "مزامنة",
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               color: AppColors.textPrimary,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(width: 8.w),
//                           isLoading
//                               ? SizedBox(
//                                   width: 14.sp,
//                                   height: 14.sp,
//                                   child: const CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: AppColors.primary,
//                                   ),
//                                 )
//                               : Icon(
//                                   Icons.cloud_sync_rounded,
//                                   size: 18.sp,
//                                   color: state is SyncError
//                                       ? Colors.red
//                                       : state is SyncSuccess
//                                       ? Colors.green
//                                       : AppColors.primary,
//                                 ),
//                       ),
//                     ),
//                 },
//               ),
//           ),
//       },
//------------------------------------------------------------------------
// lib/features/home/presentation/pages/dashboard_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.2
// ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ❌ REMOVED: import '../../../../core/design_system/themes/app_colors.dart';

// import '../../../../core/di/injection.dart';
// import '../../../../core/design_system/organisms/app_bar/athar_app_bar.dart';
// import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
// import 'package:athar/features/home/presentation/pages/smart_habits_strip.dart';
// import 'package:athar/features/notifications/presentation/cubit/notifications_cubit.dart';
// import 'package:athar/features/notifications/presentation/cubit/notifications_state.dart';
// import 'package:athar/features/notifications/presentation/pages/notification_center_page.dart';
// import '../../../habits/presentation/cubit/habit_cubit.dart';
// import '../../../task/presentation/cubit/task_cubit.dart';
// import '../../../stats/presentation/widgets/statistics_card.dart';
// import 'package:athar/features/home/presentation/widgets/daily_timeline_widget.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import '../../../../features/sync/presentation/cubit/sync_cubit.dart';
// import '../../../../features/sync/presentation/cubit/sync_state.dart';
// import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
// import '../../../../features/auth/presentation/cubit/auth_state.dart';

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});

//   String _getSmartGreeting(String? userName) {
//     final hour = DateTime.now().hour;
//     final name = (userName != null && userName.isNotEmpty) ? "، $userName" : "";

//     if (hour >= 5 && hour < 12) {
//       return "صباح الخير$name ☀️";
//     } else if (hour >= 12 && hour < 17) {
//       return "طاب يومك$name ✨";
//     } else if (hour >= 17 && hour < 21) {
//       return "مساء النور$name 🌙";
//     } else {
//       return "ليلة هادئة$name ⭐️";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;

//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => getIt<TaskCubit>()..watchTasks(DateTime.now()),
//         ),
//         BlocProvider(create: (context) => getIt<HabitCubit>()..loadHabits()),
//         BlocProvider(create: (context) => getIt<HealthCubit>()),
//         BlocProvider(
//           create: (context) =>
//               getIt<NotificationsCubit>()..watchNotifications(),
//         ),
//       ],
//       child: BlocListener<SyncCubit, SyncState>(
//         listener: (context, state) {
//           if (state is SyncError) {
//             // ✅ يمكن استخدام AtharSnackbar.error
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 // ✅ Colors.red → colors.error
//                 backgroundColor: colors.error,
//                 behavior: SnackBarBehavior.floating,
//                 duration: const Duration(seconds: 3),
//               ),
//             );
//           } else if (state is SyncSuccess) {
//             // ✅ يمكن استخدام AtharSnackbar.success
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: const Text("تمت المزامنة بنجاح"),
//                 // ✅ Colors.green → colors.success
//                 backgroundColor: colors.success,
//                 behavior: SnackBarBehavior.floating,
//                 duration: const Duration(seconds: 2),
//               ),
//             );
//           }
//         },
//         child: BlocBuilder<AuthCubit, AuthState>(
//           builder: (context, authState) {
//             String? currentUserName;

//             if (authState is AuthAuthenticated) {
//               currentUserName = authState.fullName ?? authState.username;
//             }

//             final greeting = _getSmartGreeting(currentUserName);
//             final dateStr = DateFormat(
//               'EEEE, d MMMM',
//               'ar',
//             ).format(DateTime.now());

//             return Scaffold(
//               // ✅ AppColors.background → colors.background
//               backgroundColor: colors.background,
//               appBar: AtharAppBar(
//                 title: greeting,
//                 subtitle: dateStr,
//                 actions: [
//                   BlocBuilder<NotificationsCubit, NotificationsState>(
//                     builder: (context, state) {
//                       int count = 0;
//                       if (state is NotificationsLoaded) {
//                         count = state.unreadCount;
//                       }
//                       return Stack(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.notifications_none_rounded),
//                             onPressed: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const NotificationCenterPage(),
//                               ),
//                             ),
//                           ),
//                           if (count > 0)
//                             Positioned(
//                               right: 8,
//                               top: 8,
//                               child: Container(
//                                 padding: EdgeInsets.all(AtharSpacing.xxs),
//                                 decoration: BoxDecoration(
//                                   // ✅ Colors.red → colors.error
//                                   color: colors.error,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Text(
//                                   "$count",
//                                   // ✅ AtharTypography
//                                   style: AtharTypography.labelSmall.copyWith(
//                                     // ✅ Colors.white → colors.onPrimary
//                                     color: colors.onPrimary,
//                                     fontSize: 8.sp,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               body: SafeArea(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.only(bottom: AtharSpacing.xl),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // شريط حالة المزامنة
//                       _buildSyncStatusHeader(context, colors),

//                       // بطاقة الصلاة
//                       const SmartPrayerCardWrapper(
//                         pageType: PageType.dashboard,
//                       ),

//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: AtharSpacing.lg,
//                         ),
//                         child: Column(
//                           children: [
//                             // ✅ SizedBox(height: 12.h) → AtharGap.md
//                             AtharGap.md,

//                             // بطاقة الإحصائيات
//                             const StatisticsCard(),

//                             // ✅ SizedBox(height: 24.h) → AtharGap.xxl
//                             AtharGap.xxl,

//                             // شريط العادات الذكي
//                             const SmartHabitsStrip(),

//                             AtharGap.xxl,

//                             // التايملاين اليومي
//                             const DailyTimelineWidget(moduleId: null),

//                             SizedBox(height: 80.h),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSyncStatusHeader(BuildContext context, AtharColors colors) {
//     return BlocBuilder<AuthCubit, AuthState>(
//       builder: (context, authState) {
//         if (authState is AuthGuest || authState is AuthUnauthenticated) {
//           return const SizedBox.shrink();
//         }

//         return Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: AtharSpacing.lg,
//             vertical: AtharSpacing.sm,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               BlocBuilder<SyncCubit, SyncState>(
//                 builder: (context, state) {
//                   final isLoading = state is SyncLoading;

//                   return InkWell(
//                     onTap: () {
//                       context.read<SyncCubit>().triggerSync(isManual: true);
//                     },
//                     // ✅ BorderRadius.circular(20) → AtharRadii.radiusXl
//                     borderRadius: AtharRadii.radiusXl,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: AtharSpacing.md,
//                         vertical: AtharSpacing.xs,
//                       ),
//                       decoration: BoxDecoration(
//                         // ✅ Colors.white → colors.surface
//                         color: colors.surface,
//                         borderRadius: AtharRadii.radiusXl,
//                         // ✅ Colors.grey.shade200 → colors.borderLight
//                         border: Border.all(color: colors.borderLight),
//                         boxShadow: [
//                           BoxShadow(
//                             color: colors.shadow.withValues(alpha: 0.3),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             isLoading ? "جاري المزامنة..." : "مزامنة",
//                             // ✅ AtharTypography
//                             style: AtharTypography.labelMedium.copyWith(
//                               // ✅ AppColors.textPrimary → colors.textPrimary
//                               color: colors.textPrimary,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           // ✅ SizedBox(width: 8.w) → AtharGap.hSm
//                           AtharGap.hSm,
//                           isLoading
//                               ? SizedBox(
//                                   width: 14.sp,
//                                   height: 14.sp,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     // ✅ AppColors.primary → colors.primary
//                                     color: colors.primary,
//                                   ),
//                                 )
//                               : Icon(
//                                   Icons.cloud_sync_rounded,
//                                   size: 18.sp,
//                                   color: state is SyncError
//                                       // ✅ Colors.red → colors.error
//                                       ? colors.error
//                                       : state is SyncSuccess
//                                       // ✅ Colors.green → colors.success
//                                       ? colors.success
//                                       // ✅ AppColors.primary → colors.primary
//                                       : colors.primary,
//                                 ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//------------------------------------------------------------------------
// import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
// import 'package:athar/features/home/presentation/pages/smart_habits_strip.dart';
// import 'package:athar/features/notifications/presentation/cubit/notifications_cubit.dart';
// import 'package:athar/features/notifications/presentation/cubit/notifications_state.dart';
// import 'package:athar/features/notifications/presentation/pages/notification_center_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/di/injection.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../../../core/design_system/organisms/app_bar/athar_app_bar.dart';
// import '../../../habits/presentation/cubit/habit_cubit.dart';
// import '../../../task/presentation/cubit/task_cubit.dart';
// import '../../../stats/presentation/widgets/statistics_card.dart';

// // ✅ 1. استيراد الويجت الجديد والكيوبت الصحي
// import 'package:athar/features/home/presentation/widgets/daily_timeline_widget.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';

// // ✅ 2. استيراد المزامنة والمصادقة
// import '../../../../features/sync/presentation/cubit/sync_cubit.dart';
// import '../../../../features/sync/presentation/cubit/sync_state.dart';
// import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
// import '../../../../features/auth/presentation/cubit/auth_state.dart';

// class DashboardPage extends StatelessWidget {
//   const DashboardPage({super.key});

//   // ✅ دالة ذكية لتحديد التحية المناسبة بناءً على الوقت
//   // ✅ دالة ذكية لتحديد التحية المناسبة بناءً على الوقت واسم المستخدم
//   String _getSmartGreeting(String? userName) {
//     final hour = DateTime.now().hour;
//     // إذا لم نجد اسماً، نستخدم "أيها القائد" أو "بك" كخيار احتياطي
//     final name = (userName != null && userName.isNotEmpty) ? "، $userName" : "";

//     if (hour >= 5 && hour < 12) {
//       return "صباح الخير$name ☀️";
//     } else if (hour >= 12 && hour < 17) {
//       return "طاب يومك$name ✨";
//     } else if (hour >= 17 && hour < 21) {
//       return "مساء النور$name 🌙";
//     } else {
//       return "ليلة هادئة$name ⭐️";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => getIt<TaskCubit>()..watchTasks(DateTime.now()),
//         ),
//         BlocProvider(create: (context) => getIt<HabitCubit>()..loadHabits()),

//         // ✅ 3. إضافة HealthCubit لكي تعمل أزرار الأدوية داخل التايم لاين
//         BlocProvider(create: (context) => getIt<HealthCubit>()),
//         // ✅ إضافة تفعيل مراقبة التنبيهات عند فتح الصفحة الرئيسية
//         BlocProvider(
//           create: (context) =>
//               getIt<NotificationsCubit>()..watchNotifications(),
//         ),
//       ],
//       // الاستماع لحالة المزامنة
//       child: BlocListener<SyncCubit, SyncState>(
//         listener: (context, state) {
//           if (state is SyncError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(state.message),
//                 backgroundColor: Colors.red,
//                 behavior: SnackBarBehavior.floating,
//                 duration: const Duration(seconds: 3),
//               ),
//             );
//           } else if (state is SyncSuccess) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text("تمت المزامنة بنجاح"),
//                 backgroundColor: Colors.green,
//                 behavior: SnackBarBehavior.floating,
//                 duration: Duration(seconds: 2),
//               ),
//             );
//           }
//         },
//         // داخل دالة build في DashboardPage
//         child: BlocBuilder<AuthCubit, AuthState>(
//           builder: (context, authState) {
//             // ✅ تصحيح استخراج الاسم بناءً على هيكلية AuthAuthenticated الخاصة بك
//             String? currentUserName;

//             if (authState is AuthAuthenticated) {
//               // نستخدم fullName إذا وجد، وإلا نستخدم الـ username
//               currentUserName = authState.fullName ?? authState.username;
//             }

//             // ✅ استدعاء التحية مع تمرير الاسم الصحيح
//             final greeting = _getSmartGreeting(currentUserName);
//             final dateStr = DateFormat(
//               'EEEE, d MMMM',
//               'ar',
//             ).format(DateTime.now());
//             // تنسيق التاريخ للترحيب
//             // final dateStr = DateFormat(
//             //   'EEEE, d MMMM',
//             //   'ar',
//             // ).format(DateTime.now());
//             return Scaffold(
//               backgroundColor: AppColors.background,
//               appBar: AtharAppBar(
//                 // title: "أهلاً بك 👋",
//                 // ✅ استخدام التحية الذكية بدلاً من "أهلاً بك" الثابتة
//                 title: greeting,
//                 subtitle: dateStr,
//                 actions: [
//                   BlocBuilder<NotificationsCubit, NotificationsState>(
//                     builder: (context, state) {
//                       int count = 0;
//                       if (state is NotificationsLoaded) {
//                         count = state.unreadCount;
//                       }
//                       return Stack(
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.notifications_none_rounded),
//                             onPressed: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const NotificationCenterPage(),
//                               ),
//                             ),
//                           ),
//                           if (count > 0)
//                             Positioned(
//                               right: 8,
//                               top: 8,
//                               child: Container(
//                                 padding: const EdgeInsets.all(4),
//                                 decoration: const BoxDecoration(
//                                   color: Colors.red,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Text(
//                                   "$count",
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 8.sp,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//               body: SafeArea(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.only(bottom: 20.h),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // شريط حالة المزامنة في الأعلى
//                       _buildSyncStatusHeader(context),

//                       // الغلاف الذكي للبطاقة
//                       const SmartPrayerCardWrapper(
//                         pageType: PageType.dashboard,
//                       ),

//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16.w),
//                         child: Column(
//                           children: [
//                             SizedBox(height: 12.h),

//                             // بطاقة الإحصائيات
//                             const StatisticsCard(),

//                             SizedBox(height: 24.h),

//                             // شريط العادات الذكي
//                             const SmartHabitsStrip(),

//                             SizedBox(height: 24.h),

//                             // ✅ 4. هنا الدمج الكبير: استبدال القائمة القديمة بالجديدة
//                             // نمرر moduleId: null ليعمل في الوضع العام (Global Mode)
//                             const DailyTimelineWidget(moduleId: null),

//                             SizedBox(height: 80.h),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // دالة بناء زر المزامنة
//   Widget _buildSyncStatusHeader(BuildContext context) {
//     return BlocBuilder<AuthCubit, AuthState>(
//       builder: (context, authState) {
//         // إذا كان المستخدم ضيفاً، نخفي الزر
//         if (authState is AuthGuest || authState is AuthUnauthenticated) {
//           return const SizedBox.shrink();
//         }

//         return Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               BlocBuilder<SyncCubit, SyncState>(
//                 builder: (context, state) {
//                   final isLoading = state is SyncLoading;

//                   return InkWell(
//                     onTap: () {
//                       context.read<SyncCubit>().triggerSync(isManual: true);
//                     },
//                     borderRadius: BorderRadius.circular(20),
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12.w,
//                         vertical: 6.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(color: Colors.grey.shade200),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: 0.03),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             isLoading ? "جاري المزامنة..." : "مزامنة",
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               color: AppColors.textPrimary,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(width: 8.w),
//                           isLoading
//                               ? SizedBox(
//                                   width: 14.sp,
//                                   height: 14.sp,
//                                   child: const CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                     color: AppColors.primary,
//                                   ),
//                                 )
//                               : Icon(
//                                   Icons.cloud_sync_rounded,
//                                   size: 18.sp,
//                                   color: state is SyncError
//                                       ? Colors.red
//                                       : state is SyncSuccess
//                                       ? Colors.green
//                                       : AppColors.primary,
//                                 ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
