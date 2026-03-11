// lib/features/habits/presentation/pages/habit_details_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Part 3 | File 2
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import '../../data/models/habit_model.dart';
import '../widgets/habit_form_dialog.dart';

/// Semantic colors (not in ColorScheme)
const _successColor = Color(0xFF00B894);

class HabitDetailsPage extends StatelessWidget {
  final HabitModel habit;
  const HabitDetailsPage({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    final totalCompleted = habit.completedDays.length;
    final streak = habit.currentStreak;

    return Scaffold(
      // ✅ AppColors.background → colors.background
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          habit.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
        actions: [
          IconButton(
            // ✅ AppColors.primary → colors.primary
            icon: Icon(Icons.edit, color: colorScheme.primary),
            onPressed: () {
              HabitFormSheet.show(context, habitToEdit: habit);
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: AtharSpacing.allLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. بطاقة الملخص (Scorecard)
            Row(
              children: [
                _buildStatCard(
                  colorScheme,
                  // ✅ l10n: "السلسلة الحالية"
                  l10n.habitDetailsCurrentStreak,
                  // ✅ l10n: "{count} يوم"
                  l10n.habitDetailsStreakDays(streak.toString()),
                  Icons.local_fire_department,
                  Colors.orange,
                ),
                AtharGap.hMd,
                _buildStatCard(
                  colorScheme,
                  // ✅ l10n: "مجموع الإنجاز"
                  l10n.habitDetailsTotalCompleted,
                  // ✅ l10n: "{count} مرة"
                  l10n.habitDetailsCompletedTimes(totalCompleted.toString()),
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),

            SizedBox(height: 30.h),

            // 2. التقويم الحراري
            Text(
              // ✅ l10n: "سجل الالتزام (آخر 30 يوم)"
              l10n.habitDetailsCommitmentLog,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            AtharGap.md,
            _buildCalendarGrid(context, colorScheme),

            SizedBox(height: 30.h),

            // 3. قسم التحفيز
            Container(
              padding: AtharSpacing.allLg,
              decoration: BoxDecoration(
                // ✅ AppColors.primary.withOpacity(0.1) → colors.primary
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: AtharRadii.radiusLg,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: colorScheme.primary,
                    size: 30.sp,
                  ),
                  AtharGap.hMd,
                  Expanded(
                    child: Text(
                      // ✅ l10n: motivational message
                      l10n.habitDetailsMotivationalMessage,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ).copyWith(color: colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    ColorScheme colorScheme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: AtharSpacing.allLg,
        decoration: BoxDecoration(
          // ✅ Colors.white → colors.surface
          color: colorScheme.surface,
          borderRadius: AtharRadii.radiusLg,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30.sp),
            AtharGap.sm,
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: 0.5,
              ).copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, ColorScheme colorScheme) {
    final today = DateTime.now();
    final days = List.generate(30, (index) {
      return today.subtract(Duration(days: index));
    }).reversed.toList();

    return Container(
      padding: AtharSpacing.allLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 30,
        itemBuilder: (context, index) {
          final date = days[index];
          final isCompleted = habit.completedDays.any(
            (d) =>
                d.year == date.year &&
                d.month == date.month &&
                d.day == date.day,
          );

          final isMissed =
              !isCompleted &&
              date.isBefore(DateTime(today.year, today.month, today.day)) &&
              date.isAfter(habit.createdAt.subtract(const Duration(days: 1)));

          final isToday = date.day == today.day && date.month == today.month;

          // ✅ Colors → theme-aware
          Color bgColor = colorScheme.outlineVariant;
          if (isCompleted) {
            bgColor = _successColor;
          } else if (isMissed) {
            bgColor = colorScheme.error.withValues(alpha: 0.8);
          } else if (isToday) {
            bgColor = colorScheme.primary.withValues(alpha: 0.2);
          }

          return Container(
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: isToday
                  // ✅ AppColors.primary → colors.primary
                  ? Border.all(color: colorScheme.primary, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                DateFormat('d').format(date),
                style: TextStyle(
                  color: (isCompleted || isMissed)
                      ? Colors.white
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
//-----------------------------------------------------------------------
// // lib/features/habits/presentation/pages/habit_details_page.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Part 3 | File 2
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ✅ OLD: import '../../../../core/design_system/themes/app_colors.dart';
// import '../../data/models/habit_model.dart';
// import '../widgets/habit_form_dialog.dart';

// class HabitDetailsPage extends StatelessWidget {
//   final HabitModel habit;
//   const HabitDetailsPage({super.key, required this.habit});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     final totalCompleted = habit.completedDays.length;
//     final streak = habit.currentStreak;

//     return Scaffold(
//       // ✅ AppColors.background → colors.background
//       backgroundColor: colors.background,
//       appBar: AppBar(
//         title: Text(
//           habit.title,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: BackButton(color: colors.textPrimary),
//         actions: [
//           IconButton(
//             // ✅ AppColors.primary → colors.primary
//             icon: Icon(Icons.edit, color: colors.primary),
//             onPressed: () {
//               HabitFormSheet.show(context, habitToEdit: habit);
//             },
//           ),
//         ],
//       ),

//       body: SingleChildScrollView(
//         padding: AtharSpacing.allLg,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. بطاقة الملخص (Scorecard)
//             Row(
//               children: [
//                 _buildStatCard(
//                   colors,
//                   // ✅ l10n: "السلسلة الحالية"
//                   l10n.habitDetailsCurrentStreak,
//                   // ✅ l10n: "{count} يوم"
//                   l10n.habitDetailsStreakDays(streak.toString()),
//                   Icons.local_fire_department,
//                   Colors.orange,
//                 ),
//                 AtharGap.hMd,
//                 _buildStatCard(
//                   colors,
//                   // ✅ l10n: "مجموع الإنجاز"
//                   l10n.habitDetailsTotalCompleted,
//                   // ✅ l10n: "{count} مرة"
//                   l10n.habitDetailsCompletedTimes(totalCompleted.toString()),
//                   Icons.check_circle,
//                   Colors.green,
//                 ),
//               ],
//             ),

//             SizedBox(height: 30.h),

//             // 2. التقويم الحراري
//             Text(
//               // ✅ l10n: "سجل الالتزام (آخر 30 يوم)"
//               l10n.habitDetailsCommitmentLog,
//               style: AtharTypography.titleMedium.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             AtharGap.md,
//             _buildCalendarGrid(context, colors),

//             SizedBox(height: 30.h),

//             // 3. قسم التحفيز
//             Container(
//               padding: AtharSpacing.allLg,
//               decoration: BoxDecoration(
//                 // ✅ AppColors.primary.withOpacity(0.1) → colors.primary
//                 color: colors.primary.withValues(alpha: 0.1),
//                 borderRadius: AtharRadii.radiusLg,
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.emoji_events, color: colors.primary, size: 30.sp),
//                   AtharGap.hMd,
//                   Expanded(
//                     child: Text(
//                       // ✅ l10n: motivational message
//                       l10n.habitDetailsMotivationalMessage,
//                       style: AtharTypography.bodyMedium.copyWith(
//                         color: colors.primary,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(
//     AtharColors colors,
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Expanded(
//       child: Container(
//         padding: AtharSpacing.allLg,
//         decoration: BoxDecoration(
//           // ✅ Colors.white → colors.surface
//           color: colors.surface,
//           borderRadius: AtharRadii.radiusLg,
//           boxShadow: [
//             BoxShadow(
//               color: colors.shadow.withValues(alpha: 0.12),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 30.sp),
//             AtharGap.sm,
//             Text(
//               value,
//               style: AtharTypography.titleLarge.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(
//               title,
//               style: AtharTypography.labelSmall.copyWith(
//                 color: colors.textTertiary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCalendarGrid(BuildContext context, AtharColors colors) {
//     final today = DateTime.now();
//     final days = List.generate(30, (index) {
//       return today.subtract(Duration(days: index));
//     }).reversed.toList();

//     return Container(
//       padding: AtharSpacing.allLg,
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: AtharRadii.radiusLg,
//       ),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 7,
//           mainAxisSpacing: 8,
//           crossAxisSpacing: 8,
//         ),
//         itemCount: 30,
//         itemBuilder: (context, index) {
//           final date = days[index];
//           final isCompleted = habit.completedDays.any(
//             (d) =>
//                 d.year == date.year &&
//                 d.month == date.month &&
//                 d.day == date.day,
//           );

//           final isMissed =
//               !isCompleted &&
//               date.isBefore(DateTime(today.year, today.month, today.day)) &&
//               date.isAfter(habit.createdAt.subtract(const Duration(days: 1)));

//           final isToday = date.day == today.day && date.month == today.month;

//           // ✅ Colors → theme-aware
//           Color bgColor = colors.borderLight;
//           if (isCompleted) {
//             bgColor = colors.success;
//           } else if (isMissed) {
//             bgColor = colors.error.withValues(alpha: 0.8);
//           } else if (isToday) {
//             bgColor = colors.primary.withValues(alpha: 0.2);
//           }

//           return Container(
//             decoration: BoxDecoration(
//               color: bgColor,
//               shape: BoxShape.circle,
//               border: isToday
//                   // ✅ AppColors.primary → colors.primary
//                   ? Border.all(color: colors.primary, width: 2)
//                   : null,
//             ),
//             child: Center(
//               child: Text(
//                 DateFormat('d').format(date),
//                 style: TextStyle(
//                   color: (isCompleted || isMissed)
//                       ? Colors.white
//                       : colors.textSecondary,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12.sp,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../data/models/habit_model.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart'; // ✅ للإستدعاء
// import '../widgets/habit_form_dialog.dart'; // ✅ استيراد الديالوج الجديد

// class HabitDetailsPage extends StatelessWidget {
//   final HabitModel habit;
//   const HabitDetailsPage({super.key, required this.habit});

//   @override
//   Widget build(BuildContext context) {
//     // حساب الإحصائيات
//     final totalCompleted = habit.completedDays.length;
//     final streak = habit.currentStreak;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text(
//           habit.title,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         // ✅ زر التعديل في الأعلى
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit, color: AppColors.primary),
//             onPressed: () {
//               HabitFormSheet.show(context, habitToEdit: habit);
//             },
//           ),
//         ],
//       ),

//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 1. بطاقة الملخص (Scorecard)
//             Row(
//               children: [
//                 _buildStatCard(
//                   "السلسلة الحالية",
//                   "$streak يوم",
//                   Icons.local_fire_department,
//                   Colors.orange,
//                 ),
//                 SizedBox(width: 12.w),
//                 _buildStatCard(
//                   "مجموع الإنجاز",
//                   "$totalCompleted مرة",
//                   Icons.check_circle,
//                   Colors.green,
//                 ),
//               ],
//             ),

//             SizedBox(height: 30.h),

//             // 2. التقويم الحراري (Heatmap Calendar)
//             Text(
//               "سجل الالتزام (آخر 30 يوم)",
//               style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 12.h),
//             _buildCalendarGrid(context),

//             SizedBox(height: 30.h),

//             // 3. قسم التحفيز (يظهر دائماً)
//             Container(
//               padding: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(16.r),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.emoji_events,
//                     color: AppColors.primary,
//                     size: 30.sp,
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Text(
//                       "كل يوم تلتزم فيه هو خطوة نحو شخصيتك الجديدة. استمر يا بطل! 🚀",
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: AppColors.primary,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 30.sp),
//             SizedBox(height: 8.h),
//             Text(
//               value,
//               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               title,
//               style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // بناء تقويم بسيط يعرض آخر 30 يوم
//   Widget _buildCalendarGrid(BuildContext context) {
//     final today = DateTime.now();
//     // نولد آخر 30 يوم
//     final days = List.generate(30, (index) {
//       return today.subtract(Duration(days: index));
//     }).reversed.toList();

//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//       ),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 7, // 7 أيام في الصف
//           mainAxisSpacing: 8,
//           crossAxisSpacing: 8,
//         ),
//         itemCount: 30,
//         itemBuilder: (context, index) {
//           final date = days[index];
//           final isCompleted = habit.completedDays.any(
//             (d) =>
//                 d.year == date.year &&
//                 d.month == date.month &&
//                 d.day == date.day,
//           );

//           // هل هذا اليوم فائت (لم ينجز وكان في الماضي)؟
//           // الشرط: التاريخ قبل اليوم + لم ينجز + التاريخ بعد إنشاء العادة
//           final isMissed =
//               !isCompleted &&
//               date.isBefore(DateTime(today.year, today.month, today.day)) &&
//               date.isAfter(habit.createdAt.subtract(const Duration(days: 1)));

//           final isToday = date.day == today.day && date.month == today.month;

//           Color bgColor = Colors.grey.shade100;
//           if (isCompleted) {
//             bgColor = Colors.green; // ✅ أخضر للمنجز
//           } else if (isMissed) {
//             bgColor = Colors.redAccent.withValues(alpha: 0.8);
//           } // 🔴 أحمر للفائت
//           else if (isToday) {
//             bgColor = AppColors.primary.withValues(
//               alpha: 0.2,
//             ); // لون مميز لليوم
//           }

//           return Container(
//             decoration: BoxDecoration(
//               color: bgColor,
//               // isCompleted
//               //     ? Colors.green
//               //     : (isToday ? Colors.grey.shade200 : Colors.grey.shade100),
//               shape: BoxShape.circle,
//               border: isToday
//                   ? Border.all(color: AppColors.primary, width: 2)
//                   : null,
//             ),
//             child: Center(
//               child: Text(
//                 DateFormat('d').format(date),
//                 style: TextStyle(
//                   color: (isCompleted || isMissed)
//                       ? Colors.white
//                       : Colors.grey.shade700,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12.sp,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
