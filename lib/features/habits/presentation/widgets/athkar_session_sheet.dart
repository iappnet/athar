// lib/features/habits/presentation/widgets/athkar_session_sheet.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Part 2 | File 1
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import '../../../../core/presentation/cubit/celebration_cubit.dart';
import '../../data/models/habit_model.dart';
import '../cubit/habit_cubit.dart';

/// Semantic colors (not in ColorScheme)
const _successColor = Color(0xFF00B894);

class AthkarSessionSheet extends StatefulWidget {
  final HabitModel habit;

  const AthkarSessionSheet({super.key, required this.habit});

  static void show(BuildContext context, HabitModel habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<HabitCubit>(),
        child: AthkarSessionSheet(habit: habit),
      ),
    );
  }

  @override
  State<AthkarSessionSheet> createState() => _AthkarSessionSheetState();
}

class _AthkarSessionSheetState extends State<AthkarSessionSheet> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentIndex = widget.habit.athkarItems.indexWhere((item) => !item.isDone);
    if (_currentIndex == -1) _currentIndex = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final items = habit.athkarItems;
    // ✅ Get colors & l10n
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    double totalProgress = items.isEmpty
        ? 0
        : habit.currentProgress / items.length;

    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        // ✅ Colors.white → colors.surface
        color: colorScheme.surface,
        // ✅ BorderRadius → AtharRadii
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // 1. رأس الصفحة
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              boxShadow: [
                BoxShadow(
                  // ✅ Colors.black.withOpacity → colors.shadow
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        habit.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ),
                    SizedBox(width: 48.w),
                    IconButton(
                      icon: const Icon(Icons.restore_page_outlined),
                      // ✅ l10n: "تحديث الأذكار"
                      tooltip: l10n.athkarResetTooltip,
                      onPressed: () =>
                          _showResetDialog(context, colorScheme, l10n),
                    ),
                  ],
                ),

                AtharGap.md,

                // شريط التقدم الخطي
                ClipRRect(
                  borderRadius: AtharRadii.radiusXxs,
                  child: LinearProgressIndicator(
                    value: totalProgress,
                    minHeight: 6.h,
                    backgroundColor: colorScheme.outlineVariant,
                    // ✅ AppColors.primary → colors.primary
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),

                AtharGap.sm,

                // نسبة الإنجاز
                Text(
                  // ✅ l10n: "XX% مكتمل"
                  l10n.athkarProgressPercent(
                    (totalProgress * 100).toInt().toString(),
                  ),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.5,
                  ).copyWith(color: colorScheme.outline),
                ),
                AtharGap.lg,
              ],
            ),
          ),

          // 2. محتوى الذكر (PageView)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (idx) => setState(() => _currentIndex = idx),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildAthkarCard(colorScheme, l10n, item, index);
              },
            ),
          ),

          // 3. مؤشر الصفحات السفلي
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${_currentIndex + 1} / ${items.length}",
                  style:
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ).copyWith(
                        fontWeight: FontWeight.bold,
                        // ✅ AppColors.dimmedText → colors.textSecondary
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // ✅ l10n: "تحديث قائمة الأذكار؟"
        title: Text(l10n.athkarResetDialogTitle),
        // ✅ l10n: long reset confirmation text
        content: Text(l10n.athkarResetDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            // ✅ l10n: "إلغاء"
            child: Text(l10n.athkarResetCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HabitCubit>().resetHabitAthkar(widget.habit);
              Navigator.pop(context);
            },
            // ✅ l10n: "تحديث" + Colors.red → colors.error
            child: Text(
              l10n.athkarResetConfirm,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAthkarCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    AthkarItem item,
    int index,
  ) {
    final itemProgress = item.targetCount > 0
        ? item.currentCount / item.targetCount
        : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // نص الذكر
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  item.text ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontFamily: 'Amiri',
                    height: 1.6,
                    // ✅ AppColors.textPrimary → colors.textPrimary
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 32.h),

          // دائرة التقدم والزر
          GestureDetector(
            onTap: () async {
              if (!item.isDone) {
                await context.read<HabitCubit>().incrementAthkarProgress(
                  widget.habit,
                  index,
                );
                setState(() {});

                if (item.currentCount >= item.targetCount) {
                  final isAllDone = widget.habit.athkarItems.every(
                    (i) => i.isDone,
                  );

                  if (isAllDone) {
                    if (mounted) {
                      context.read<CelebrationCubit>().celebrate();
                      Navigator.pop(context);
                    }
                  } else {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (_currentIndex < widget.habit.athkarItems.length - 1) {
                        _pageController.nextPage(
                          duration: AtharAnimations.slower,
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  }
                }
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // الدائرة الخلفية
                SizedBox(
                  width: 120.w,
                  height: 120.w,
                  child: CircularProgressIndicator(
                    value: itemProgress,
                    strokeWidth: 8.w,
                    backgroundColor: colorScheme.outlineVariant,
                    // ✅ AppColors.success / AppColors.primary → colors
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.isDone ? _successColor : colorScheme.primary,
                    ),
                  ),
                ),
                // الرقم أو علامة الصح
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: item.isDone ? _successColor : colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (item.isDone ? _successColor : colorScheme.primary)
                                .withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: item.isDone
                        ? Icon(Icons.check, color: Colors.white, size: 40.sp)
                        : Text(
                            "${item.targetCount - item.currentCount}",
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          AtharGap.lg,
          Text(
            // ✅ l10n: "أحسنت!" / "اضغط للعد"
            item.isDone ? l10n.athkarWellDone : l10n.athkarTapToCount,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ).copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
//-----------------------------------------------------------------------
// // lib/features/habits/presentation/widgets/athkar_session_sheet.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Part 2 | File 1
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ✅ OLD: import '../../../../core/design_system/themes/app_colors.dart';
// import '../../../../core/presentation/cubit/celebration_cubit.dart';
// import '../../data/models/habit_model.dart';
// import '../cubit/habit_cubit.dart';

// class AthkarSessionSheet extends StatefulWidget {
//   final HabitModel habit;

//   const AthkarSessionSheet({super.key, required this.habit});

//   static void show(BuildContext context, HabitModel habit) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => BlocProvider.value(
//         value: context.read<HabitCubit>(),
//         child: AthkarSessionSheet(habit: habit),
//       ),
//     );
//   }

//   @override
//   State<AthkarSessionSheet> createState() => _AthkarSessionSheetState();
// }

// class _AthkarSessionSheetState extends State<AthkarSessionSheet> {
//   late PageController _pageController;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     _currentIndex = widget.habit.athkarItems.indexWhere((item) => !item.isDone);
//     if (_currentIndex == -1) _currentIndex = 0;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_pageController.hasClients) {
//         _pageController.jumpToPage(_currentIndex);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final habit = widget.habit;
//     final items = habit.athkarItems;
//     // ✅ Get colors & l10n
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     double totalProgress = items.isEmpty
//         ? 0
//         : habit.currentProgress / items.length;

//     return Container(
//       height: 0.85.sh,
//       decoration: BoxDecoration(
//         // ✅ Colors.white → colors.surface
//         color: colors.surface,
//         // ✅ BorderRadius → AtharRadii
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: Column(
//         children: [
//           // 1. رأس الصفحة
//           Container(
//             padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
//             decoration: BoxDecoration(
//               color: colors.surface,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//               boxShadow: [
//                 BoxShadow(
//                   // ✅ Colors.black.withOpacity → colors.shadow
//                   color: colors.shadow.withValues(alpha: 0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Expanded(
//                       child: Text(
//                         habit.title,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 18.sp,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Amiri',
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 48.w),
//                     IconButton(
//                       icon: const Icon(Icons.restore_page_outlined),
//                       // ✅ l10n: "تحديث الأذكار"
//                       tooltip: l10n.athkarResetTooltip,
//                       onPressed: () => _showResetDialog(context, colors, l10n),
//                     ),
//                   ],
//                 ),

//                 AtharGap.md,

//                 // شريط التقدم الخطي
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(4),
//                   child: LinearProgressIndicator(
//                     value: totalProgress,
//                     minHeight: 6.h,
//                     backgroundColor: colors.borderLight,
//                     // ✅ AppColors.primary → colors.primary
//                     valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
//                   ),
//                 ),

//                 AtharGap.sm,

//                 // نسبة الإنجاز
//                 Text(
//                   // ✅ l10n: "XX% مكتمل"
//                   l10n.athkarProgressPercent(
//                     (totalProgress * 100).toInt().toString(),
//                   ),
//                   style: AtharTypography.labelSmall.copyWith(
//                     color: colors.textTertiary,
//                   ),
//                 ),
//                 AtharGap.lg,
//               ],
//             ),
//           ),

//           // 2. محتوى الذكر (PageView)
//           Expanded(
//             child: PageView.builder(
//               controller: _pageController,
//               itemCount: items.length,
//               onPageChanged: (idx) => setState(() => _currentIndex = idx),
//               itemBuilder: (context, index) {
//                 final item = items[index];
//                 return _buildAthkarCard(colors, l10n, item, index);
//               },
//             ),
//           ),

//           // 3. مؤشر الصفحات السفلي
//           Padding(
//             padding: EdgeInsets.symmetric(vertical: 20.h),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "${_currentIndex + 1} / ${items.length}",
//                   style: AtharTypography.titleSmall.copyWith(
//                     fontWeight: FontWeight.bold,
//                     // ✅ AppColors.dimmedText → colors.textSecondary
//                     color: colors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showResetDialog(
//     BuildContext context,
//     AtharColors colors,
//     AppLocalizations l10n,
//   ) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         // ✅ l10n: "تحديث قائمة الأذكار؟"
//         title: Text(l10n.athkarResetDialogTitle),
//         // ✅ l10n: long reset confirmation text
//         content: Text(l10n.athkarResetDialogContent),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             // ✅ l10n: "إلغاء"
//             child: Text(l10n.athkarResetCancel),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               context.read<HabitCubit>().resetHabitAthkar(widget.habit);
//               Navigator.pop(context);
//             },
//             // ✅ l10n: "تحديث" + Colors.red → colors.error
//             child: Text(
//               l10n.athkarResetConfirm,
//               style: TextStyle(color: colors.error),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAthkarCard(
//     AtharColors colors,
//     AppLocalizations l10n,
//     AthkarItem item,
//     int index,
//   ) {
//     final itemProgress = item.targetCount > 0
//         ? item.currentCount / item.targetCount
//         : 0.0;

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // نص الذكر
//           Expanded(
//             child: Center(
//               child: SingleChildScrollView(
//                 child: Text(
//                   item.text ?? "",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 24.sp,
//                     fontFamily: 'Amiri',
//                     height: 1.6,
//                     // ✅ AppColors.textPrimary → colors.textPrimary
//                     color: colors.textPrimary,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: 32.h),

//           // دائرة التقدم والزر
//           GestureDetector(
//             onTap: () async {
//               if (!item.isDone) {
//                 await context.read<HabitCubit>().incrementAthkarProgress(
//                   widget.habit,
//                   index,
//                 );
//                 setState(() {});

//                 if (item.currentCount >= item.targetCount) {
//                   final isAllDone = widget.habit.athkarItems.every(
//                     (i) => i.isDone,
//                   );

//                   if (isAllDone) {
//                     if (mounted) {
//                       context.read<CelebrationCubit>().celebrate();
//                       Navigator.pop(context);
//                     }
//                   } else {
//                     Future.delayed(const Duration(milliseconds: 300), () {
//                       if (_currentIndex < widget.habit.athkarItems.length - 1) {
//                         _pageController.nextPage(
//                           duration: AtharAnimations.slower,
//                           curve: Curves.easeInOut,
//                         );
//                       }
//                     });
//                   }
//                 }
//               }
//             },
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // الدائرة الخلفية
//                 SizedBox(
//                   width: 120.w,
//                   height: 120.w,
//                   child: CircularProgressIndicator(
//                     value: itemProgress,
//                     strokeWidth: 8.w,
//                     backgroundColor: colors.borderLight,
//                     // ✅ AppColors.success / AppColors.primary → colors
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       item.isDone ? colors.success : colors.primary,
//                     ),
//                   ),
//                 ),
//                 // الرقم أو علامة الصح
//                 Container(
//                   width: 100.w,
//                   height: 100.w,
//                   decoration: BoxDecoration(
//                     color: item.isDone ? colors.success : colors.primary,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: (item.isDone ? colors.success : colors.primary)
//                             .withValues(alpha: 0.3),
//                         blurRadius: 15,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: item.isDone
//                         ? Icon(Icons.check, color: Colors.white, size: 40.sp)
//                         : Text(
//                             "${item.targetCount - item.currentCount}",
//                             style: TextStyle(
//                               fontSize: 32.sp,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           AtharGap.lg,
//           Text(
//             // ✅ l10n: "أحسنت!" / "اضغط للعد"
//             item.isDone ? l10n.athkarWellDone : l10n.athkarTapToCount,
//             style: AtharTypography.bodyMedium.copyWith(
//               color: colors.textTertiary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../../../core/presentation/cubit/celebration_cubit.dart';
// import '../../data/models/habit_model.dart';
// import '../cubit/habit_cubit.dart';

// class AthkarSessionSheet extends StatefulWidget {
//   final HabitModel habit;

//   const AthkarSessionSheet({super.key, required this.habit});

//   static void show(BuildContext context, HabitModel habit) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => BlocProvider.value(
//         value: context.read<HabitCubit>(),
//         child: AthkarSessionSheet(habit: habit),
//       ),
//     );
//   }

//   @override
//   State<AthkarSessionSheet> createState() => _AthkarSessionSheetState();
// }

// class _AthkarSessionSheetState extends State<AthkarSessionSheet> {
//   late PageController _pageController;
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController();
//     // البحث عن أول ذكر غير مكتمل للبدء به
//     _currentIndex = widget.habit.athkarItems.indexWhere((item) => !item.isDone);
//     if (_currentIndex == -1) _currentIndex = 0;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_pageController.hasClients) {
//         _pageController.jumpToPage(_currentIndex);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final habit = widget.habit;
//     final items = habit.athkarItems;

//     // ✅ حساب نسبة التقدم الكلي (Total Progress)
//     double totalProgress = items.isEmpty
//         ? 0
//         : habit.currentProgress / items.length;

//     return Container(
//       height: 0.85.sh, // 85% من الشاشة
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: Column(
//         children: [
//           // 1. رأس الصفحة (العنوان + زر الإغلاق + شريط التقدم)
//           Container(
//             padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // الصف العلوي: إغلاق وعنوان
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Expanded(
//                       child: Text(
//                         habit.title,
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 18.sp,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Amiri',
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 48.w), // لموازنة زر الإغلاق
//                     // ✅ زر التحديث (Reset)
//                     IconButton(
//                       icon: const Icon(Icons.restore_page_outlined),
//                       tooltip: "تحديث الأذكار",
//                       onPressed: () => _showResetDialog(context),
//                     ),
//                   ],
//                 ),

//                 SizedBox(height: 12.h),

//                 // ✅ شريط التقدم الخطي (الإضافة الجديدة)
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(4),
//                   child: LinearProgressIndicator(
//                     value: totalProgress,
//                     minHeight: 6.h,
//                     backgroundColor: Colors.grey[200],
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       AppColors.primary,
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 8.h),

//                 // نص نسبة الإنجاز
//                 Text(
//                   "${(totalProgress * 100).toInt()}% مكتمل",
//                   style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//                 ),
//                 SizedBox(height: 16.h),
//               ],
//             ),
//           ),

//           // 2. محتوى الذكر (PageView)
//           Expanded(
//             child: PageView.builder(
//               controller: _pageController,
//               itemCount: items.length,
//               onPageChanged: (idx) => setState(() => _currentIndex = idx),
//               itemBuilder: (context, index) {
//                 final item = items[index];
//                 return _buildAthkarCard(item, index);
//               },
//             ),
//           ),

//           // 3. مؤشر الصفحات السفلي
//           Padding(
//             padding: EdgeInsets.symmetric(vertical: 20.h),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "${_currentIndex + 1} / ${items.length}",
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.dimmedText,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showResetDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("تحديث قائمة الأذكار؟"),
//         content: const Text(
//           "سيقوم هذا بتحديث نصوص الأذكار إلى النسخة الأصح والأحدث، ولكنه سيعيد تعيين تقدمك في هذا الورد إلى الصفر.\n\nهل أنت متأكد؟",
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("إلغاء"),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx); // إغلاق الدايالوج
//               // استدعاء التحديث
//               context.read<HabitCubit>().resetHabitAthkar(widget.habit);
//               // إغلاق الشيت أيضاً لأنه سيعاد تحميله
//               Navigator.pop(context);
//             },
//             child: const Text("تحديث", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAthkarCard(AthkarItem item, int index) {
//     // حساب تقدم الذكر الواحد (للدائرة)
//     final itemProgress = item.targetCount > 0
//         ? item.currentCount / item.targetCount
//         : 0.0;

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // نص الذكر (قابل للتمرير إذا كان طويلاً)
//           Expanded(
//             child: Center(
//               child: SingleChildScrollView(
//                 child: Text(
//                   item.text ?? "",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 24.sp,
//                     fontFamily: 'Amiri',
//                     height: 1.6,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: 32.h),

//           // دائرة التقدم والزر (زر التسبيح)
//           GestureDetector(
//             onTap: () async {
//               if (!item.isDone) {
//                 // زيادة العداد
//                 await context.read<HabitCubit>().incrementAthkarProgress(
//                   widget.habit,
//                   index,
//                 );
//                 setState(() {}); // تحديث الواجهة فوراً

//                 // إذا اكتمل الذكر الحالي
//                 if (item.currentCount >= item.targetCount) {
//                   // التحقق هل اكتملت كل الأذكار؟
//                   final isAllDone = widget.habit.athkarItems.every(
//                     (i) => i.isDone,
//                   );

//                   if (isAllDone) {
//                     if (context.mounted) {
//                       context.read<CelebrationCubit>().celebrate();
//                       Navigator.pop(context); // إغلاق الشيت
//                     }
//                   } else {
//                     // الانتقال للذكر التالي تلقائياً بعد مهلة قصيرة
//                     Future.delayed(const Duration(milliseconds: 300), () {
//                       if (_currentIndex < widget.habit.athkarItems.length - 1) {
//                         _pageController.nextPage(
//                           duration: const Duration(milliseconds: 400),
//                           curve: Curves.easeInOut,
//                         );
//                       }
//                     });
//                   }
//                 }
//               }
//             },
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 // الدائرة الخلفية
//                 SizedBox(
//                   width: 120.w,
//                   height: 120.w,
//                   child: CircularProgressIndicator(
//                     value: itemProgress,
//                     strokeWidth: 8.w,
//                     backgroundColor: Colors.grey.shade100,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       item.isDone ? AppColors.success : AppColors.primary,
//                     ),
//                   ),
//                 ),
//                 // الرقم أو علامة الصح
//                 Container(
//                   width: 100.w,
//                   height: 100.w,
//                   decoration: BoxDecoration(
//                     color: item.isDone ? AppColors.success : AppColors.primary,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color:
//                             (item.isDone
//                                     ? AppColors.success
//                                     : AppColors.primary)
//                                 .withValues(alpha: 0.3),
//                         blurRadius: 15,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: item.isDone
//                         ? Icon(Icons.check, color: Colors.white, size: 40.sp)
//                         : Text(
//                             "${item.targetCount - item.currentCount}",
//                             style: TextStyle(
//                               fontSize: 32.sp,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           SizedBox(height: 16.h),
//           Text(
//             item.isDone ? "أحسنت!" : "اضغط للعد",
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
