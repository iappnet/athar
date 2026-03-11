// lib/features/home/presentation/pages/home_header.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.4
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors from context
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    // تحديد التحية حسب الوقت
    final hour = DateTime.now().hour;
    String greeting = l10n.welcomeBack;
    if (hour < 12) {
      greeting = l10n.goodMorningChamp;
    } else if (hour < 17) {
      greeting = l10n.haveANiceDay;
    } else {
      greeting = l10n.goodEveningSimple;
    }

    // تنسيق التاريخ
    final dateStr = DateFormat('EEEE, d MMMM', 'ar').format(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              // ✅ AtharTypography
              style:
                  TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ).copyWith(
                    // ✅ AppColors.textPrimary → colors.textPrimary
                    color: colorScheme.onSurface,
                  ),
            ),
            // ✅ SizedBox(height: 4.h) → AtharGap.xxs
            AtharGap.xxs,
            Text(
              dateStr,
              // ✅ AtharTypography
              style:
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ).copyWith(
                    // ✅ Colors.grey → colors.textTertiary
                    color: colorScheme.outline,
                  ),
            ),
          ],
        ),
        // زر الإعدادات
        Container(
          decoration: BoxDecoration(
            // ✅ Colors.white → colors.surface
            color: colorScheme.surface,
            shape: BoxShape.circle,
            // ✅ Colors.grey.shade200 → colors.borderLight
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                // ✅ Colors.black.withValues(alpha: 0.05) → colors.shadow
                color: colorScheme.shadow.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.settingsComingSoon)));
            },
            icon: Icon(
              Icons.settings_outlined,
              // ✅ Colors.black87 → colors.textPrimary
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
// ----------------------------------------------------------------------------
// // lib/features/home/presentation/pages/my_day_list.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 2 | File 2.6
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/core/design_system/molecules/tiles/task_tile.dart';
// import 'package:athar/features/task/presentation/cubit/task_state.dart';
// import '../../../task/presentation/cubit/task_cubit.dart';

// class MyDayList extends StatelessWidget {
//   const MyDayList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "مهامي اليوم",
//                 // ✅ AtharTypography
//                 style: AtharTypography.titleMedium.copyWith(
//                   color: colors.textPrimary,
//                 ),
//               ),
//               // زر إضافة
//               TextButton(
//                 onPressed: () {
//                   /* فتح حوار الإضافة */
//                 },
//                 child: Text("إضافة +", style: TextStyle(color: colors.primary)),
//               ),
//             ],
//           ),
//         ),
//         // ✅ SizedBox(height: 8.h) → AtharGap.sm
//         AtharGap.sm,

//         BlocBuilder<TaskCubit, TaskState>(
//           builder: (context, state) {
//             if (state is TaskLoading) {
//               return Center(
//                 child: CircularProgressIndicator(color: colors.primary),
//               );
//             } else if (state is TaskLoaded) {
//               final tasks = state.tasks.where((t) => !t.isCompleted).toList();

//               if (tasks.isEmpty) {
//                 return Center(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(vertical: AtharSpacing.xl),
//                     child: Text(
//                       "لا توجد مهام اليوم، استمتع بوقتك! ☕",
//                       // ✅ Colors.grey → colors.textTertiary
//                       style: AtharTypography.bodyMedium.copyWith(
//                         color: colors.textTertiary,
//                       ),
//                     ),
//                   ),
//                 );
//               }

//               return ListView.separated(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: tasks.length,
//                 // ✅ SizedBox(height: 12.h) → AtharGap.md
//                 separatorBuilder: (context, index) => AtharGap.md,
//                 itemBuilder: (context, index) {
//                   return TaskTile(
//                     task: tasks[index],
//                     onToggle: (_) => context
//                         .read<TaskCubit>()
//                         .toggleTaskCompletion(tasks[index]),
//                     onDelete: () =>
//                         context.read<TaskCubit>().deleteTask(tasks[index].id),
//                   );
//                 },
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ],
//     );
//   }
// }
// ----------------------------------------------------------------------------

// import 'package:athar/core/design_system/molecules/tiles/task_tile.dart';
// import 'package:athar/features/task/presentation/cubit/task_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../task/presentation/cubit/task_cubit.dart';

// class MyDayList extends StatelessWidget {
//   const MyDayList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 4.w),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "مهامي اليوم",
//                 style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//               ),
//               // زر صغير لإضافة مهمة سريعاً
//               TextButton(
//                 onPressed: () {
//                   /* فتح حوار الإضافة */
//                 },
//                 child: const Text("إضافة +"),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(height: 8.h),

//         BlocBuilder<TaskCubit, TaskState>(
//           builder: (context, state) {
//             if (state is TaskLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is TaskLoaded) {
//               // فلترة: المهام غير المكتملة (يمكن إضافة فلتر التاريخ لاحقاً)
//               final tasks = state.tasks.where((t) => !t.isCompleted).toList();

//               if (tasks.isEmpty) {
//                 return Center(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(vertical: 20.h),
//                     child: Text(
//                       "لا توجد مهام اليوم، استمتع بوقتك! ☕",
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ),
//                 );
//               }

//               // نستخدم ListView.separated داخل العمود (ShrinkWrap)
//               return ListView.separated(
//                 shrinkWrap: true, // مهم جداً داخل SingleChildScrollView
//                 physics:
//                     const NeverScrollableScrollPhysics(), // تعطيل السكرول الداخلي
//                 itemCount: tasks.length,
//                 separatorBuilder: (context, index) => SizedBox(height: 12.h),
//                 itemBuilder: (context, index) {
//                   return TaskTile(
//                     task: tasks[index],
//                     // أضفنا (_) لتقبل القيمة الراجعة من التغيير
//                     onToggle: (_) => context
//                         .read<TaskCubit>()
//                         .toggleTaskCompletion(tasks[index]),
//                     onDelete: () =>
//                         context.read<TaskCubit>().deleteTask(tasks[index].id),
//                   );
//                 },
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ],
//     );
//   }
// }
