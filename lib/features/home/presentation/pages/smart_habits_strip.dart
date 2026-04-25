// lib/features/home/presentation/pages/smart_habits_strip.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.5
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

import '../../../habits/presentation/cubit/habit_cubit.dart';
import '../../../habits/presentation/cubit/habit_state.dart';
import '../../../habits/data/models/habit_model.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../../../settings/data/models/user_settings.dart';
import '../../../dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
import '../../../habits/presentation/widgets/athkar_session_sheet.dart';

/// Semantic colors (not in ColorScheme)
const _warningColor = Color(0xFFFDCB6E);
const _successColor = Color(0xFF00B894);

class SmartHabitsStrip extends StatelessWidget {
  const SmartHabitsStrip({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors from context
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
          child: Text(
            l10n.myHabitsToday,
            // ✅ AtharTypography
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ).copyWith(color: colorScheme.onSurface),
          ),
        ),
        // ✅ SizedBox(height: 12.h) → AtharGap.md
        AtharGap.md,
        SizedBox(
          height: 90.h,
          child: BlocBuilder<HabitCubit, HabitState>(
            builder: (context, state) {
              if (state is HabitLoaded) {
                final List<HabitModel> allVisibleHabits = [
                  ...state.cardAthkar,
                  ...state.dawnHabits,
                  ...state.bakurHabits,
                  ...state.morningHabits,
                  ...state.noonHabits,
                  ...state.afternoonHabits,
                  ...state.maghribHabits,
                  ...state.ishaHabits,
                  ...state.nightHabits,
                  ...state.lastThirdHabits,
                  ...state.anyTimeHabits,
                ];

                final activeHabits = allVisibleHabits
                    .where((h) => !h.isCompleted)
                    .toSet()
                    .toList();

                if (activeHabits.isEmpty) {
                  return _buildEmptyState(context, colorScheme);
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
                  itemCount: activeHabits.length,
                  // ✅ SizedBox(width: 12.w) → AtharGap.hMd
                  separatorBuilder: (context, index) => AtharGap.hMd,
                  itemBuilder: (context, index) {
                    final habit = activeHabits[index];
                    return _buildMiniHabitCard(context, colorScheme, habit);
                  },
                );
              }
              return Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMiniHabitCard(
    BuildContext context,
    ColorScheme colorScheme,
    HabitModel habit,
  ) {
    final isAthkar = habit.type == HabitType.athkar;

    return GestureDetector(
      onTap: () {
        if (isAthkar) {
          _openAthkarSheetCorrectly(context, habit);
        } else {
          context.read<HabitCubit>().toggleHabitOnDate(
            habit.id,
            DateTime.now(),
          );
        }
      },
      child: Container(
        width: 100.w,
        // ✅ EdgeInsets.all(12.w) → AtharSpacing.allMd
        padding: AtharSpacing.allMd,
        decoration: BoxDecoration(
          // ✅ AppColors.surface → colors.surface
          color: colorScheme.surface,
          // ✅ BorderRadius.circular(16.r) → AtharRadii.radiusLg
          borderRadius: AtharRadii.radiusLg,
          // ✅ AppColors.primary.withValues(alpha: 0.1)
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AtharSpacing.sm),
              decoration: BoxDecoration(
                // ✅ Colors.orange / AppColors.primary
                color: isAthkar
                    ? _warningColor.withValues(alpha: 0.1)
                    : colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAthkar ? Icons.wb_sunny_outlined : Icons.check,
                size: 18.sp,
                color: isAthkar ? _warningColor : colorScheme.primary,
              ),
            ),
            // ✅ SizedBox(height: 8.h) → AtharGap.sm
            AtharGap.sm,
            Text(
              habit.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // ✅ AtharTypography
              style:
                  TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.5,
                  ).copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      // ✅ EdgeInsets.all(12.w) → AtharSpacing.allMd
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        // ✅ Colors.green.withValues(alpha: 0.05) → colors.success
        color: _successColor.withValues(alpha: 0.05),
        // ✅ BorderRadius.circular(12.r) → AtharRadii.radiusMd
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: _successColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, color: _successColor, size: 20.sp),
          // ✅ SizedBox(width: 8.w) → AtharGap.hSm
          AtharGap.hSm,
          Text(
            l10n.greatJobCompletedCurrentTasks,
            // ✅ AtharTypography
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ).copyWith(color: _successColor),
          ),
        ],
      ),
    );
  }

  void _openAthkarSheetCorrectly(BuildContext context, HabitModel habit) {
    final settingsState = context.read<SettingsCubit>().state;
    AthkarSessionViewMode viewMode = AthkarSessionViewMode.list;

    if (settingsState is SettingsLoaded) {
      viewMode = settingsState.settings.athkarSessionViewMode;
    }

    if (viewMode == AthkarSessionViewMode.list) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => BlocProvider.value(
          value: context.read<HabitCubit>(),
          child: DhikrBottomSheet(habit: habit),
        ),
      );
    } else {
      AthkarSessionSheet.show(context, habit);
    }
  }
}
// // lib/features/home/presentation/pages/smart_habits_strip.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 2 | File 2.5
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';

// import '../../../habits/presentation/cubit/habit_cubit.dart';
// import '../../../habits/presentation/cubit/habit_state.dart';
// import '../../../habits/data/models/habit_model.dart';
// import '../../../settings/presentation/cubit/settings_cubit.dart';
// import '../../../settings/presentation/cubit/settings_state.dart';
// import '../../../settings/data/models/user_settings.dart';
// import '../../../dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
// import '../../../habits/presentation/widgets/athkar_session_sheet.dart';

// class SmartHabitsStrip extends StatelessWidget {
//   const SmartHabitsStrip({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
//           child: Text(
//             l10n.myHabitsToday,
//             // ✅ AtharTypography
//             style: AtharTypography.titleMedium.copyWith(
//               color: colors.textPrimary,
//             ),
//           ),
//         ),
//         // ✅ SizedBox(height: 12.h) → AtharGap.md
//         AtharGap.md,
//         SizedBox(
//           height: 90.h,
//           child: BlocBuilder<HabitCubit, HabitState>(
//             builder: (context, state) {
//               if (state is HabitLoaded) {
//                 final List<HabitModel> allVisibleHabits = [
//                   ...state.cardAthkar,
//                   ...state.dawnHabits,
//                   ...state.bakurHabits,
//                   ...state.morningHabits,
//                   ...state.noonHabits,
//                   ...state.afternoonHabits,
//                   ...state.maghribHabits,
//                   ...state.ishaHabits,
//                   ...state.nightHabits,
//                   ...state.lastThirdHabits,
//                   ...state.anyTimeHabits,
//                 ];

//                 final activeHabits = allVisibleHabits
//                     .where((h) => !h.isCompleted)
//                     .toSet()
//                     .toList();

//                 if (activeHabits.isEmpty) {
//                   return _buildEmptyState(context, colors);
//                 }

//                 return ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
//                   itemCount: activeHabits.length,
//                   // ✅ SizedBox(width: 12.w) → AtharGap.hMd
//                   separatorBuilder: (context, index) => AtharGap.hMd,
//                   itemBuilder: (context, index) {
//                     final habit = activeHabits[index];
//                     return _buildMiniHabitCard(context, colors, habit);
//                   },
//                 );
//               }
//               return Center(
//                 child: CircularProgressIndicator(color: colors.primary),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMiniHabitCard(
//     BuildContext context,
//     AtharColors colors,
//     HabitModel habit,
//   ) {
//     final isAthkar = habit.type == HabitType.athkar;

//     return GestureDetector(
//       onTap: () {
//         if (isAthkar) {
//           _openAthkarSheetCorrectly(context, habit);
//         } else {
//           context.read<HabitCubit>().toggleHabitOnDate(
//             habit.id,
//             DateTime.now(),
//           );
//         }
//       },
//       child: Container(
//         width: 100.w,
//         // ✅ EdgeInsets.all(12.w) → AtharSpacing.allMd
//         padding: AtharSpacing.allMd,
//         decoration: BoxDecoration(
//           // ✅ AppColors.surface → colors.surface
//           color: colors.surface,
//           // ✅ BorderRadius.circular(16.r) → AtharRadii.radiusLg
//           borderRadius: AtharRadii.radiusLg,
//           // ✅ AppColors.primary.withValues(alpha: 0.1)
//           border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
//           boxShadow: [
//             BoxShadow(
//               color: colors.primary.withValues(alpha: 0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(AtharSpacing.sm),
//               decoration: BoxDecoration(
//                 // ✅ Colors.orange / AppColors.primary
//                 color: isAthkar
//                     ? colors.warning.withValues(alpha: 0.1)
//                     : colors.primary.withValues(alpha: 0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isAthkar ? Icons.wb_sunny_outlined : Icons.check,
//                 size: 18.sp,
//                 color: isAthkar ? colors.warning : colors.primary,
//               ),
//             ),
//             // ✅ SizedBox(height: 8.h) → AtharGap.sm
//             AtharGap.sm,
//             Text(
//               habit.title,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               // ✅ AtharTypography
//               style: AtharTypography.labelMedium.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: colors.textPrimary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(BuildContext context, AtharColors colors) {
//     final l10n = AppLocalizations.of(context);

//     return Container(
//       width: double.infinity,
//       // ✅ EdgeInsets.all(12.w) → AtharSpacing.allMd
//       padding: AtharSpacing.allMd,
//       decoration: BoxDecoration(
//         // ✅ Colors.green.withValues(alpha: 0.05) → colors.success
//         color: colors.success.withValues(alpha: 0.05),
//         // ✅ BorderRadius.circular(12.r) → AtharRadii.radiusMd
//         borderRadius: AtharRadii.radiusMd,
//         border: Border.all(color: colors.success.withValues(alpha: 0.2)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.emoji_events, color: colors.success, size: 20.sp),
//           // ✅ SizedBox(width: 8.w) → AtharGap.hSm
//           AtharGap.hSm,
//           Text(
//             l10n.greatJobCompletedCurrentTasks,
//             // ✅ AtharTypography
//             style: AtharTypography.bodyMedium.copyWith(color: colors.success),
//           ),
//         ],
//       ),
//     );
//   }

//   void _openAthkarSheetCorrectly(BuildContext context, HabitModel habit) {
//     final settingsState = context.read<SettingsCubit>().state;
//     AthkarSessionViewMode viewMode = AthkarSessionViewMode.list;

//     if (settingsState is SettingsLoaded) {
//       viewMode = settingsState.settings.athkarSessionViewMode;
//     }

//     if (viewMode == AthkarSessionViewMode.list) {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (ctx) => BlocProvider.value(
//           value: context.read<HabitCubit>(),
//           child: DhikrBottomSheet(habit: habit),
//         ),
//       );
//     } else {
//       AthkarSessionSheet.show(context, habit);
//     }
//   }
// }
//--------------------------------------------------------------
// // --- Imports Core ---

// // --- Imports Features ---

// // --- Widgets Imports ---


//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 4.w),
//           child: Text(
//             "عاداتي اليوم",
//             style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//           ),
//         ),
//         SizedBox(height: 12.h),
//         SizedBox(
//           height: 90.h,
//           child: BlocBuilder<HabitCubit, HabitState>(
//                 // 🛑 الحل الجذري هنا:
//                 // بدلاً من أخذ كل العادات، نجمع فقط العادات النشطة حالياً بناءً على فلاتر الكيوبت الزمنية
//                 // نجمع كل القوائم التي جهزها الكيوبت (لأنها مفلترة زمنياً بالفعل)
//                   ...state.cardAthkar, // البطاقات (أذكار مستقلة)
//                   ...state.dawnHabits,
//                   ...state.bakurHabits,
//                   ...state.morningHabits,
//                   ...state.noonHabits,
//                   ...state.afternoonHabits,
//                   ...state.maghribHabits,
//                   ...state.ishaHabits,
//                   ...state.nightHabits,
//                   ...state.lastThirdHabits,
//                   ...state.anyTimeHabits,

//                 // ✅ الآن نفلتر المنجز فقط (لأن الشريط للمهام المتبقية)
//                 // ونزيل التكرار (احتياطاً، رغم أن الكيوبت يضمن عدم التكرار)
//                     .toSet() // لإزالة أي تكرار محتمل


//                   scrollDirection: Axis.horizontal,
//                   padding: EdgeInsets.symmetric(horizontal: 4.w),
//                   itemCount: activeHabits.length,
//                   },
//             },
//           ),
//         ),


//           // ✅ منطق فتح الشيت المتوافق مع الإعدادات (نفس HabitsPage)
//           // إنجاز العادة العادية
//           // نستخدم toggleHabitOnDate لضمان التعامل مع التاريخ بشكل صحيح
//           // (نفترض اليوم هو DateTime.now() لهذا الشريط)
//             habit.id,
//             DateTime.now(),
//       },
//       child: Container(
//         width: 100.w,
//         padding: EdgeInsets.all(12.w),
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.primary.withValues(alpha: 0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // أيقونة تتغير حسب النوع
//             Container(
//               padding: EdgeInsets.all(8.w),
//               decoration: BoxDecoration(
//                 color: isAthkar
//                     ? Colors.orange.withValues(alpha: 0.1)
//                     : AppColors.primary.withValues(alpha: 0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isAthkar ? Icons.wb_sunny_outlined : Icons.check,
//                 size: 18.sp,
//                 color: isAthkar ? Colors.orange : AppColors.primary,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               habit.title,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
//               textAlign: TextAlign.center,
//             ),
//         ),
//       ),

//       width: double.infinity,
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.green.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.emoji_events, color: Colors.green, size: 20.sp),
//           SizedBox(width: 8.w),
//           Text(
//             "أنت رائع! أكملت مهام الوقت الحالي.",
//             style: TextStyle(color: Colors.green.shade700, fontSize: 14.sp),
//           ),
//       ),

//   // ✅ دالة مساعدة لفتح الشيت الصحيح حسب الإعدادات


//       // الشيت القديم (القائمة)
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//           value: context.read<HabitCubit>(), // تمرير الكيوبت
//           child: DhikrBottomSheet(habit: habit),
//         ),
//       // الشيت الجديد (التركيز)

//------------------------------------------------------------------------
// lib/features/home/presentation/pages/smart_habits_strip.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.5
// ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ❌ REMOVED: import '../../../../core/design_system/themes/app_colors.dart';

// import '../../../habits/presentation/cubit/habit_cubit.dart';
// import '../../../habits/presentation/cubit/habit_state.dart';
// import '../../../habits/data/models/habit_model.dart';
// import '../../../settings/presentation/cubit/settings_cubit.dart';
// import '../../../settings/presentation/cubit/settings_state.dart';
// import '../../../settings/data/models/user_settings.dart';
// import '../../../dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
// import '../../../habits/presentation/widgets/athkar_session_sheet.dart';

// class SmartHabitsStrip extends StatelessWidget {
//   const SmartHabitsStrip({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
//           child: Text(
//             "عاداتي اليوم",
//             // ✅ AtharTypography
//             style: AtharTypography.titleMedium.copyWith(
//               color: colors.textPrimary,
//             ),
//           ),
//         ),
//         // ✅ SizedBox(height: 12.h) → AtharGap.md
//         AtharGap.md,
//         SizedBox(
//           height: 90.h,
//           child: BlocBuilder<HabitCubit, HabitState>(
//             builder: (context, state) {
//               if (state is HabitLoaded) {
//                 final List<HabitModel> allVisibleHabits = [
//                   ...state.cardAthkar,
//                   ...state.dawnHabits,
//                   ...state.bakurHabits,
//                   ...state.morningHabits,
//                   ...state.noonHabits,
//                   ...state.afternoonHabits,
//                   ...state.maghribHabits,
//                   ...state.ishaHabits,
//                   ...state.nightHabits,
//                   ...state.lastThirdHabits,
//                   ...state.anyTimeHabits,
//                 ];

//                 final activeHabits = allVisibleHabits
//                     .where((h) => !h.isCompleted)
//                     .toSet()
//                     .toList();

//                 if (activeHabits.isEmpty) {
//                   return _buildEmptyState(colors);
//                 }

//                 return ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
//                   itemCount: activeHabits.length,
//                   // ✅ SizedBox(width: 12.w) → AtharGap.hMd
//                   separatorBuilder: (context, index) => AtharGap.hMd,
//                   itemBuilder: (context, index) {
//                     final habit = activeHabits[index];
//                     return _buildMiniHabitCard(context, colors, habit);
//                   },
//                 );
//               }
//               return Center(
//                 child: CircularProgressIndicator(color: colors.primary),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMiniHabitCard(
//     BuildContext context,
//     AtharColors colors,
//     HabitModel habit,
//   ) {
//     final isAthkar = habit.type == HabitType.athkar;

//     return GestureDetector(
//       onTap: () {
//         if (isAthkar) {
//           _openAthkarSheetCorrectly(context, habit);
//         } else {
//           context.read<HabitCubit>().toggleHabitOnDate(
//             habit.id,
//             DateTime.now(),
//           );
//         }
//       },
//       child: Container(
//         width: 100.w,
//         // ✅ EdgeInsets.all(12.w) → AtharSpacing.allMd
//         padding: AtharSpacing.allMd,
//         decoration: BoxDecoration(
//           // ✅ AppColors.surface → colors.surface
//           color: colors.surface,
//           // ✅ BorderRadius.circular(16.r) → AtharRadii.radiusLg
//           borderRadius: AtharRadii.radiusLg,
//           // ✅ AppColors.primary.withValues(alpha: 0.1)
//           border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
//           boxShadow: [
//             BoxShadow(
//               color: colors.primary.withValues(alpha: 0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(AtharSpacing.sm),
//               decoration: BoxDecoration(
//                 // ✅ Colors.orange / AppColors.primary
//                 color: isAthkar
//                     ? colors.warning.withValues(alpha: 0.1)
//                     : colors.primary.withValues(alpha: 0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isAthkar ? Icons.wb_sunny_outlined : Icons.check,
//                 size: 18.sp,
//                 color: isAthkar ? colors.warning : colors.primary,
//               ),
//             ),
//             // ✅ SizedBox(height: 8.h) → AtharGap.sm
//             AtharGap.sm,
//             Text(
//               habit.title,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               // ✅ AtharTypography
//               style: AtharTypography.labelMedium.copyWith(
//                 fontWeight: FontWeight.w600,
//                 color: colors.textPrimary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(AtharColors colors) {
//     return Container(
//       width: double.infinity,
//       // ✅ EdgeInsets.all(12.w) → AtharSpacing.allMd
//       padding: AtharSpacing.allMd,
//       decoration: BoxDecoration(
//         // ✅ Colors.green.withValues(alpha: 0.05) → colors.success
//         color: colors.success.withValues(alpha: 0.05),
//         // ✅ BorderRadius.circular(12.r) → AtharRadii.radiusMd
//         borderRadius: AtharRadii.radiusMd,
//         border: Border.all(color: colors.success.withValues(alpha: 0.2)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.emoji_events, color: colors.success, size: 20.sp),
//           // ✅ SizedBox(width: 8.w) → AtharGap.hSm
//           AtharGap.hSm,
//           Text(
//             "أنت رائع! أكملت مهام الوقت الحالي.",
//             // ✅ AtharTypography
//             style: AtharTypography.bodyMedium.copyWith(color: colors.success),
//           ),
//         ],
//       ),
//     );
//   }

//   void _openAthkarSheetCorrectly(BuildContext context, HabitModel habit) {
//     final settingsState = context.read<SettingsCubit>().state;
//     AthkarSessionViewMode viewMode = AthkarSessionViewMode.list;

//     if (settingsState is SettingsLoaded) {
//       viewMode = settingsState.settings.athkarSessionViewMode;
//     }

//     if (viewMode == AthkarSessionViewMode.list) {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (ctx) => BlocProvider.value(
//           value: context.read<HabitCubit>(),
//           child: DhikrBottomSheet(habit: habit),
//         ),
//       );
//     } else {
//       AthkarSessionSheet.show(context, habit);
//     }
//   }
// }
//------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // --- Imports Core ---
// import '../../../../core/design_system/themes/app_colors.dart';

// // --- Imports Features ---
// import '../../../habits/presentation/cubit/habit_cubit.dart';
// import '../../../habits/presentation/cubit/habit_state.dart';
// import '../../../habits/data/models/habit_model.dart';
// import '../../../settings/presentation/cubit/settings_cubit.dart'; // ✅ نحتاجه لمعرفة نوع الشيت
// import '../../../settings/presentation/cubit/settings_state.dart';
// import '../../../settings/data/models/user_settings.dart'; // للـ Enum

// // --- Widgets Imports ---
// import '../../../dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
// import '../../../habits/presentation/widgets/athkar_session_sheet.dart'; // ✅ الشيت الجديد

// class SmartHabitsStrip extends StatelessWidget {
//   const SmartHabitsStrip({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 4.w),
//           child: Text(
//             "عاداتي اليوم",
//             style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//           ),
//         ),
//         SizedBox(height: 12.h),
//         SizedBox(
//           height: 90.h,
//           child: BlocBuilder<HabitCubit, HabitState>(
//             builder: (context, state) {
//               if (state is HabitLoaded) {
//                 // 🛑 الحل الجذري هنا:
//                 // بدلاً من أخذ كل العادات، نجمع فقط العادات النشطة حالياً بناءً على فلاتر الكيوبت الزمنية
//                 // نجمع كل القوائم التي جهزها الكيوبت (لأنها مفلترة زمنياً بالفعل)
//                 final List<HabitModel> allVisibleHabits = [
//                   ...state.cardAthkar, // البطاقات (أذكار مستقلة)
//                   ...state.dawnHabits,
//                   ...state.bakurHabits,
//                   ...state.morningHabits,
//                   ...state.noonHabits,
//                   ...state.afternoonHabits,
//                   ...state.maghribHabits,
//                   ...state.ishaHabits,
//                   ...state.nightHabits,
//                   ...state.lastThirdHabits,
//                   ...state.anyTimeHabits,
//                 ];

//                 // ✅ الآن نفلتر المنجز فقط (لأن الشريط للمهام المتبقية)
//                 // ونزيل التكرار (احتياطاً، رغم أن الكيوبت يضمن عدم التكرار)
//                 final activeHabits = allVisibleHabits
//                     .where((h) => !h.isCompleted)
//                     .toSet() // لإزالة أي تكرار محتمل
//                     .toList();

//                 if (activeHabits.isEmpty) {
//                   return _buildEmptyState();
//                 }

//                 return ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   padding: EdgeInsets.symmetric(horizontal: 4.w),
//                   itemCount: activeHabits.length,
//                   separatorBuilder: (context, index) => SizedBox(width: 12.w),
//                   itemBuilder: (context, index) {
//                     final habit = activeHabits[index];
//                     return _buildMiniHabitCard(context, habit);
//                   },
//                 );
//               }
//               return const Center(child: CircularProgressIndicator());
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMiniHabitCard(BuildContext context, HabitModel habit) {
//     final isAthkar = habit.type == HabitType.athkar;

//     return GestureDetector(
//       onTap: () {
//         if (isAthkar) {
//           // ✅ منطق فتح الشيت المتوافق مع الإعدادات (نفس HabitsPage)
//           _openAthkarSheetCorrectly(context, habit);
//         } else {
//           // إنجاز العادة العادية
//           // نستخدم toggleHabitOnDate لضمان التعامل مع التاريخ بشكل صحيح
//           // (نفترض اليوم هو DateTime.now() لهذا الشريط)
//           context.read<HabitCubit>().toggleHabitOnDate(
//             habit.id,
//             DateTime.now(),
//           );
//         }
//       },
//       child: Container(
//         width: 100.w,
//         padding: EdgeInsets.all(12.w),
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.primary.withValues(alpha: 0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // أيقونة تتغير حسب النوع
//             Container(
//               padding: EdgeInsets.all(8.w),
//               decoration: BoxDecoration(
//                 color: isAthkar
//                     ? Colors.orange.withValues(alpha: 0.1)
//                     : AppColors.primary.withValues(alpha: 0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isAthkar ? Icons.wb_sunny_outlined : Icons.check,
//                 size: 18.sp,
//                 color: isAthkar ? Colors.orange : AppColors.primary,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               habit.title,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.green.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.emoji_events, color: Colors.green, size: 20.sp),
//           SizedBox(width: 8.w),
//           Text(
//             "أنت رائع! أكملت مهام الوقت الحالي.",
//             style: TextStyle(color: Colors.green.shade700, fontSize: 14.sp),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ دالة مساعدة لفتح الشيت الصحيح حسب الإعدادات
//   void _openAthkarSheetCorrectly(BuildContext context, HabitModel habit) {
//     final settingsState = context.read<SettingsCubit>().state;
//     AthkarSessionViewMode viewMode = AthkarSessionViewMode.list;

//     if (settingsState is SettingsLoaded) {
//       viewMode = settingsState.settings.athkarSessionViewMode;
//     }

//     if (viewMode == AthkarSessionViewMode.list) {
//       // الشيت القديم (القائمة)
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (ctx) => BlocProvider.value(
//           value: context.read<HabitCubit>(), // تمرير الكيوبت
//           child: DhikrBottomSheet(habit: habit),
//         ),
//       );
//     } else {
//       // الشيت الجديد (التركيز)
//       AthkarSessionSheet.show(context, habit);
//     }
//   }
// }
