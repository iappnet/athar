import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/habits/presentation/cubit/habit_state.dart';
import 'package:athar/features/stats/presentation/cubit/stats_state.dart';
import 'package:athar/features/stats/presentation/widgets/stats_bweekly_focus_chart.dartody.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../habits/presentation/cubit/habit_cubit.dart';
import '../../../habits/presentation/widgets/habit_heatmap.dart';
import '../cubit/stats_cubit.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<StatsCubit>()..loadStats()),
        BlocProvider.value(value: getIt<HabitCubit>()..loadHabits()),
      ],
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(l10n.statsPageTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User header
              _UserHeader(colorScheme: colorScheme, l10n: l10n),

              SizedBox(height: 30.h),

              // Focus section
              _SectionTitle(
                title: l10n.statsFocusPerformance,
                icon: Icons.timer,
                colorScheme: colorScheme,
              ),
              AtharGap.md,
              BlocBuilder<StatsCubit, StatsState>(
                builder: (context, state) {
                  if (state is StatsLoaded) {
                    return WeeklyFocusChart(weeklyData: state.weeklyFocus);
                  }
                  if (state is StatsError) {
                    return Column(
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: Theme.of(context).colorScheme.error),
                        SizedBox(height: 8.h),
                        Text(state.message,
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.error)),
                        TextButton.icon(
                          onPressed: () =>
                              context.read<StatsCubit>().loadStats(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(
                              AppLocalizations.of(context).retry),
                        ),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),

              SizedBox(height: 30.h),

              // Habits section
              _SectionTitle(
                title: l10n.statsHabitCommitment,
                icon: Icons.calendar_month,
                colorScheme: colorScheme,
              ),
              AtharGap.md,
              BlocBuilder<HabitCubit, HabitState>(
                builder: (context, state) {
                  if (state is HabitLoaded) {
                    final heatmapData = context
                        .read<HabitCubit>()
                        .getHeatmapData(state.habits);
                    return HabitHeatmap(datasets: heatmapData);
                  }
                  return const SizedBox();
                },
              ),

              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final ColorScheme colorScheme;

  const _SectionTitle({
    required this.title,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _UserHeader extends StatelessWidget {
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  const _UserHeader({required this.colorScheme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: AtharRadii.radiusXl,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: colorScheme.onPrimary,
            child: Icon(Icons.person, size: 35.sp, color: colorScheme.primary),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.statsWelcome,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                l10n.statsMotivation,
                style: TextStyle(
                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
//-----------------------------------------------------------------------
// import 'package:athar/features/habits/presentation/cubit/habit_state.dart';
// import 'package:athar/features/stats/presentation/cubit/stats_state.dart';
// import 'package:athar/features/stats/presentation/widgets/stats_bweekly_focus_chart.dartody.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/di/injection.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../../habits/presentation/cubit/habit_cubit.dart';
// import '../../../habits/presentation/widgets/habit_heatmap.dart';
// import '../cubit/stats_cubit.dart';

// class StatisticsPage extends StatelessWidget {
//   const StatisticsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => getIt<StatsCubit>()..loadStats()),
//         // نستخدم HabitCubit الموجود سابقاً أو ننشئ جديداً لجلب البيانات
//         // BlocProvider(create: (_) => getIt<HabitCubit>()..loadHabits()),
//         BlocProvider.value(value: getIt<HabitCubit>()..loadHabits()),
//       ],
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           title: const Text("لوحة الإنجاز"),
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//         ),
//         body: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 1. بطاقة المستخدم (Placeholder)
//               const _UserHeader(),

//               SizedBox(height: 30.h),

//               // 2. قسم التركيز
//               const _SectionTitle(title: "أداء التركيز", icon: Icons.timer),
//               SizedBox(height: 12.h),
//               BlocBuilder<StatsCubit, StatsState>(
//                 builder: (context, state) {
//                   if (state is StatsLoaded) {
//                     return WeeklyFocusChart(weeklyData: state.weeklyFocus);
//                   }
//                   return const Center(child: CircularProgressIndicator());
//                 },
//               ),

//               SizedBox(height: 30.h),

//               // 3. قسم العادات
//               const _SectionTitle(
//                 title: "التزام العادات",
//                 icon: Icons.calendar_month,
//               ),
//               SizedBox(height: 12.h),
//               BlocBuilder<HabitCubit, HabitState>(
//                 builder: (context, state) {
//                   if (state is HabitLoaded) {
//                     // نحسب البيانات هنا
//                     final heatmapData = context
//                         .read<HabitCubit>()
//                         .getHeatmapData(state.habits);
//                     return HabitHeatmap(datasets: heatmapData);
//                   }
//                   return const SizedBox();
//                 },
//               ),

//               SizedBox(height: 50.h),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // --- ويدجت فرعي للعنوان ---
// class _SectionTitle extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   const _SectionTitle({required this.title, required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, color: AppColors.primary, size: 20.sp),
//         SizedBox(width: 8.w),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//             color: AppColors.textPrimary,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // --- ويدجت فرعي لبطاقة المستخدم ---
// class _UserHeader extends StatelessWidget {
//   const _UserHeader();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         color: AppColors.primary, // خلفية ملونة
//         borderRadius: BorderRadius.circular(20.r),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withValues(alpha: 0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // صورة وهمية (أفاتار)
//           CircleAvatar(
//             radius: 30.r,
//             backgroundColor: Colors.white,
//             child: Icon(Icons.person, size: 35.sp, color: AppColors.primary),
//           ),
//           SizedBox(width: 16.w),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "مرحباً بك، يا بطل! 👋",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 4.h),
//               Text(
//                 "استمر في صناعة الأثر.",
//                 style: TextStyle(
//                   color: Colors.white.withValues(alpha: 0.9),
//                   fontSize: 14.sp,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
