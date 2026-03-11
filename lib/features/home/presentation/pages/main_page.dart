// lib/features/home/presentation/pages/main_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.1
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

// --- Imports Core & DI ---
import '../../../../core/di/injection.dart';

// --- Imports Features ---
import 'package:athar/features/habits/presentation/widgets/habit_form_dialog.dart';
import 'package:athar/features/space/presentation/cubit/module_cubit.dart';
import 'package:athar/features/space/presentation/pages/space_list_page.dart';
import 'package:athar/features/space/presentation/widgets/add_module_sheet.dart';
import 'package:athar/features/task/presentation/pages/unified_tasks_page.dart';
import '../../../habits/presentation/cubit/habit_cubit.dart';
import '../../../habits/presentation/pages/habit_page.dart';
import '../../../task/presentation/cubit/task_cubit.dart';
import '../../../task/presentation/widgets/add_task_sheet.dart';
import 'dashboard_page.dart';

/// Semantic colors (not in ColorScheme)
const _warningColor = Color(0xFFFDCB6E);
const _infoColor = Color(0xFF74B9FF);

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const UnifiedTasksPage(),
    const HabitsPage(),
    const SpaceListPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors from context
    final colorScheme = Theme.of(context).colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<TaskCubit>()..watchTasks(DateTime.now()),
        ),
        BlocProvider(create: (context) => getIt<HabitCubit>()),
        BlocProvider(create: (context) => getIt<ModuleCubit>()),
      ],
      child: Builder(
        builder: (newContext) {
          return Scaffold(
            body: IndexedStack(index: _currentIndex, children: _pages),

            // ✅ يمكن استخدام AtharButton.fab لكن FAB العادي أفضل هنا
            floatingActionButton: FloatingActionButton(
              heroTag: 'main_fab',
              onPressed: () => _showQuickAddDialog(newContext),
              // ✅ AppColors.primary → colors.primary
              backgroundColor: colorScheme.primary,
              elevation: 4,
              shape: const CircleBorder(),
              // ✅ Colors.white → colors.onPrimary
              child: Icon(Icons.add, color: colorScheme.onPrimary, size: 30.sp),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,

            bottomNavigationBar: _buildBottomBar(colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            // ✅ Colors.black.withValues(alpha: 0.05)
            color: colorScheme.shadow.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        // ✅ Colors.white → colors.surface
        color: colorScheme.surface,
        elevation: 0,
        height: 70.h,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              colorScheme: colorScheme,
              icon: Icons.dashboard_rounded,
              label: l10n.home,
              index: 0,
            ),
            _buildNavItem(
              colorScheme: colorScheme,
              icon: Icons.check_circle_outline_rounded,
              label: l10n.tasks,
              index: 1,
            ),
            SizedBox(width: 40.w), // مسافة للزر العائم
            _buildNavItem(
              colorScheme: colorScheme,
              icon: Icons.track_changes_rounded,
              label: l10n.habits,
              index: 2,
            ),
            _buildNavItem(
              colorScheme: colorScheme,
              icon: Icons.workspaces_rounded,
              label: l10n.spaces,
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      // ✅ BorderRadius.circular(30) → AtharRadii.radiusXxxl
      borderRadius: AtharRadii.radiusXxxl,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AtharSpacing.md,
          vertical: AtharSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              // ✅ AppColors.primary / Colors.grey.shade400
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              size: 26.sp,
            ),
            // ✅ SizedBox(height: 4.h) → AtharGap.xxs
            AtharGap.xxs,
            AnimatedContainer(
              // ✅ Duration → AtharAnimations.fast
              duration: AtharAnimations.fast,
              height: 4.h,
              width: isSelected ? 4.h : 0,
              decoration: BoxDecoration(
                // ✅ AppColors.primary → colors.primary
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- منطق النوافذ المنبثقة ---

  void _showQuickAddDialog(BuildContext parentContext) {
    final colorScheme = Theme.of(parentContext).colorScheme;
    final l10n = AppLocalizations.of(parentContext);

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        // ✅ EdgeInsets.all(20.w) → AtharSpacing.allXl
        padding: AtharSpacing.allXl,
        // ✅ EdgeInsets.all(16.w) → AtharSpacing.allLg
        margin: AtharSpacing.allLg,
        decoration: BoxDecoration(
          // ✅ Colors.white → colors.surface
          color: colorScheme.surface,
          // ✅ BorderRadius.circular(24.r) → AtharRadii.radiusXxl
          borderRadius: AtharRadii.radiusXxl,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.whatToAdd,
              // ✅ AtharTypography
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ).copyWith(color: colorScheme.onSurface),
            ),
            // ✅ SizedBox(height: 24.h) → AtharGap.xxl
            AtharGap.xxl,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  colorScheme: colorScheme,
                  icon: Icons.check_circle_outline,
                  label: l10n.task,
                  // ✅ Colors.blueAccent → colors.info
                  color: _infoColor,
                  onTap: () {
                    Navigator.pop(ctx);
                    _openAddTaskSheet(parentContext);
                  },
                ),
                _buildQuickActionButton(
                  colorScheme: colorScheme,
                  icon: Icons.track_changes,
                  label: l10n.habit,
                  // ✅ Colors.purpleAccent → colors.secondary
                  color: colorScheme.secondary,
                  onTap: () {
                    Navigator.pop(ctx);
                    HabitFormSheet.show(parentContext);
                  },
                ),
                _buildQuickActionButton(
                  colorScheme: colorScheme,
                  icon: Icons.folder_open,
                  label: l10n.project,
                  // ✅ Colors.orangeAccent → colors.warning
                  color: _warningColor,
                  onTap: () {
                    Navigator.pop(ctx);
                    _openAddProjectSheet(parentContext);
                  },
                ),
              ],
            ),
            // ✅ SizedBox(height: 10.h) → AtharGap.sm
            AtharGap.sm,
          ],
        ),
      ),
    );
  }

  void _openAddTaskSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
          value: parentContext.read<TaskCubit>(),
          child: const AddTaskSheet(),
        );
      },
    );
  }

  void _openAddProjectSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
          value: parentContext.read<ModuleCubit>(),
          child: const AddModuleSheet(forcedType: 'project'),
        );
      },
    );
  }

  Widget _buildQuickActionButton({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            // ✅ EdgeInsets.all(16.w) → AtharSpacing.allLg
            padding: AtharSpacing.allLg,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          // ✅ SizedBox(height: 8.h) → AtharGap.sm
          AtharGap.sm,
          Text(
            label,
            // ✅ AtharTypography
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
              letterSpacing: 0.25,
            ).copyWith(color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
// --------------------------------------------------------------------------------------
// // lib/features/home/presentation/pages/main_page.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 2 | File 2.1
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';

// // --- Imports Core & DI ---
// import '../../../../core/di/injection.dart';

// // --- Imports Features ---
// import 'package:athar/features/habits/presentation/widgets/habit_form_dialog.dart';
// import 'package:athar/features/space/presentation/cubit/module_cubit.dart';
// import 'package:athar/features/space/presentation/pages/space_list_page.dart';
// import 'package:athar/features/space/presentation/widgets/add_module_sheet.dart';
// import 'package:athar/features/task/presentation/pages/unified_tasks_page.dart';
// import '../../../habits/presentation/cubit/habit_cubit.dart';
// import '../../../habits/presentation/pages/habit_page.dart';
// import '../../../task/presentation/cubit/task_cubit.dart';
// import '../../../task/presentation/widgets/add_task_sheet.dart';
// import 'dashboard_page.dart';

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   int _currentIndex = 0;

//   final List<Widget> _pages = [
//     const DashboardPage(),
//     const UnifiedTasksPage(),
//     const HabitsPage(),
//     const SpaceListPage(),
//   ];

//   void _onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
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
//         BlocProvider(create: (context) => getIt<HabitCubit>()),
//         BlocProvider(create: (context) => getIt<ModuleCubit>()),
//       ],
//       child: Builder(
//         builder: (newContext) {
//           return Scaffold(
//             body: IndexedStack(index: _currentIndex, children: _pages),

//             // ✅ يمكن استخدام AtharButton.fab لكن FAB العادي أفضل هنا
//             floatingActionButton: FloatingActionButton(
//               heroTag: 'main_fab',
//               onPressed: () => _showQuickAddDialog(newContext),
//               // ✅ AppColors.primary → colors.primary
//               backgroundColor: colors.primary,
//               elevation: 4,
//               shape: const CircleBorder(),
//               // ✅ Colors.white → colors.onPrimary
//               child: Icon(Icons.add, color: colors.onPrimary, size: 30.sp),
//             ),
//             floatingActionButtonLocation:
//                 FloatingActionButtonLocation.centerDocked,

//             bottomNavigationBar: _buildBottomBar(colors),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBottomBar(AtharColors colors) {
//     final l10n = AppLocalizations.of(context);
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             // ✅ Colors.black.withValues(alpha: 0.05)
//             color: colors.shadow.withValues(alpha: 0.5),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: BottomAppBar(
//         shape: CircularNotchedRectangle(),
//         notchMargin: 8.0,
//         // ✅ Colors.white → colors.surface
//         color: colors.surface,
//         elevation: 0,
//         height: 70.h,
//         padding: EdgeInsets.zero,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildNavItem(
//               colors: colors,
//               icon: Icons.dashboard_rounded,
//               label: l10n.home,
//               index: 0,
//             ),
//             _buildNavItem(
//               colors: colors,
//               icon: Icons.check_circle_outline_rounded,
//               label: l10n.tasks,
//               index: 1,
//             ),
//             SizedBox(width: 40.w), // مسافة للزر العائم
//             _buildNavItem(
//               colors: colors,
//               icon: Icons.track_changes_rounded,
//               label: l10n.habits,
//               index: 2,
//             ),
//             _buildNavItem(
//               colors: colors,
//               icon: Icons.workspaces_rounded,
//               label: l10n.spaces,
//               index: 3,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required AtharColors colors,
//     required IconData icon,
//     required String label,
//     required int index,
//   }) {
//     final isSelected = _currentIndex == index;
//     return InkWell(
//       onTap: () => _onTabTapped(index),
//       // ✅ BorderRadius.circular(30) → AtharRadii.radiusXxxl
//       borderRadius: AtharRadii.radiusXxxl,
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: AtharSpacing.md,
//           vertical: AtharSpacing.sm,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               // ✅ AppColors.primary / Colors.grey.shade400
//               color: isSelected ? colors.primary : colors.textTertiary,
//               size: 26.sp,
//             ),
//             // ✅ SizedBox(height: 4.h) → AtharGap.xxs
//             AtharGap.xxs,
//             AnimatedContainer(
//               // ✅ Duration → AtharAnimations.fast
//               duration: AtharAnimations.fast,
//               height: 4.h,
//               width: isSelected ? 4.h : 0,
//               decoration: BoxDecoration(
//                 // ✅ AppColors.primary → colors.primary
//                 color: colors.primary,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- منطق النوافذ المنبثقة ---

//   void _showQuickAddDialog(BuildContext parentContext) {
//     final colors = parentContext.colors;
//     final l10n = AppLocalizations.of(parentContext);

//     showModalBottomSheet(
//       context: parentContext,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => Container(
//         // ✅ EdgeInsets.all(20.w) → AtharSpacing.allXl
//         padding: AtharSpacing.allXl,
//         // ✅ EdgeInsets.all(16.w) → AtharSpacing.allLg
//         margin: AtharSpacing.allLg,
//         decoration: BoxDecoration(
//           // ✅ Colors.white → colors.surface
//           color: colors.surface,
//           // ✅ BorderRadius.circular(24.r) → AtharRadii.radiusXxl
//           borderRadius: AtharRadii.radiusXxl,
//           boxShadow: [
//             BoxShadow(
//               color: colors.shadow.withValues(alpha: 0.1),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               l10n.whatToAdd,
//               // ✅ AtharTypography
//               style: AtharTypography.titleLarge.copyWith(
//                 color: colors.textPrimary,
//               ),
//             ),
//             // ✅ SizedBox(height: 24.h) → AtharGap.xxl
//             AtharGap.xxl,
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildQuickActionButton(
//                   colors: colors,
//                   icon: Icons.check_circle_outline,
//                   label: l10n.task,
//                   // ✅ Colors.blueAccent → colors.info
//                   color: colors.info,
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _openAddTaskSheet(parentContext);
//                   },
//                 ),
//                 _buildQuickActionButton(
//                   colors: colors,
//                   icon: Icons.track_changes,
//                   label: l10n.habit,
//                   // ✅ Colors.purpleAccent → colors.secondary
//                   color: colors.secondary,
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     HabitFormSheet.show(parentContext);
//                   },
//                 ),
//                 _buildQuickActionButton(
//                   colors: colors,
//                   icon: Icons.folder_open,
//                   label: l10n.project,
//                   // ✅ Colors.orangeAccent → colors.warning
//                   color: colors.warning,
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _openAddProjectSheet(parentContext);
//                   },
//                 ),
//               ],
//             ),
//             // ✅ SizedBox(height: 10.h) → AtharGap.sm
//             AtharGap.sm,
//           ],
//         ),
//       ),
//     );
//   }

//   void _openAddTaskSheet(BuildContext parentContext) {
//     showModalBottomSheet(
//       context: parentContext,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return BlocProvider.value(
//           value: parentContext.read<TaskCubit>(),
//           child: const AddTaskSheet(),
//         );
//       },
//     );
//   }

//   void _openAddProjectSheet(BuildContext parentContext) {
//     showModalBottomSheet(
//       context: parentContext,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return BlocProvider.value(
//           value: parentContext.read<ModuleCubit>(),
//           child: const AddModuleSheet(forcedType: 'project'),
//         );
//       },
//     );
//   }

//   Widget _buildQuickActionButton({
//     required AtharColors colors,
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             // ✅ EdgeInsets.all(16.w) → AtharSpacing.allLg
//             padding: AtharSpacing.allLg,
//             decoration: BoxDecoration(
//               color: color.withValues(alpha: 0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: color, size: 28.sp),
//           ),
//           // ✅ SizedBox(height: 8.h) → AtharGap.sm
//           AtharGap.sm,
//           Text(
//             label,
//             // ✅ AtharTypography
//             style: AtharTypography.labelLarge.copyWith(
//               color: colors.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ---------------------------------------------------

//     // ✅ 2. استخدام MultiBlocProvider لتوفير TaskCubit و HabitCubit للزر العائم
//       providers: [
//         BlocProvider(
//         ),
//         // نحتاج HabitCubit هنا لأن HabitFormDialog يعتمد عليه
//         // ✅ إضافة ProjectCubit ليكون متاحاً للنافذة المنبثقة
//         // ✅ تغيير: توفير ModuleCubit بدلاً من ProjectCubit
//       child: Builder(
//             body: IndexedStack(index: _currentIndex, children: _pages),

//             floatingActionButton: FloatingActionButton(
//               heroTag: 'main_fab',
//                 // 3. نمرر newContext بدلاً من context القديم
//               },
//               backgroundColor: AppColors.primary,
//               elevation: 4,
//               shape: const CircleBorder(),
//               child: Icon(Icons.add, color: Colors.white, size: 30.sp),
//             ),
//             floatingActionButtonLocation:
//                 FloatingActionButtonLocation.centerDocked,

//             bottomNavigationBar: _buildBottomBar(),
//         },
//       ),

//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//       ),
//       child: BottomAppBar(
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 8.0,
//         color: Colors.white,
//         elevation: 0,
//         height: 70.h,
//         padding: EdgeInsets.zero,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildNavItem(
//               icon: Icons.dashboard_rounded,
//               label: "الرئيسية",
//               index: 0,
//             ),
//             _buildNavItem(
//               icon: Icons.check_circle_outline_rounded,
//               label: "المهام",
//               index: 1,
//             ),
//             SizedBox(width: 40.w), // مسافة للزر العائم
//             _buildNavItem(
//               icon: Icons.track_changes_rounded,
//               label: "العادات",
//               index: 2,
//             ),

//             // _buildNavItem(
//             //   icon: Icons.folder_copy_rounded,
//             //   label: "المشاريع",
//             //   index: 3,
//             // ),
//             _buildNavItem(
//               icon: Icons.workspaces_rounded,
//               label: "المساحات",
//               index: 3,
//             ),
//         ),
//       ),

//       borderRadius: BorderRadius.circular(30),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? AppColors.primary : Colors.grey.shade400,
//               size: 26.sp,
//             ),
//             SizedBox(height: 4.h),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               height: 4.h,
//               width: isSelected ? 4.h : 0,
//               decoration: BoxDecoration(
//                 color: AppColors.primary,
//                 shape: BoxShape.circle,
//               ),
//             ),
//         ),
//       ),

//   // --- منطق النوافذ المنبثقة ---

//     showModalBottomSheet(
//       context: parentContext,
//       backgroundColor: Colors.transparent,
//         padding: EdgeInsets.all(20.w),
//         margin: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.1),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               "ماذا تريد أن تضيف؟",
//               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 24.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildQuickActionButton(
//                   icon: Icons.check_circle_outline,
//                   label: "مهمة",
//                   color: Colors.blueAccent,
//                   },
//                 ),
//                 _buildQuickActionButton(
//                   icon: Icons.track_changes,
//                   label: "عادة",
//                   color: Colors.purpleAccent,
//                     // ✅ 3. استدعاء الديالوج الموحد وإغلاق الشيت الحالي
//                     // نستخدم parentContext لأنه يحتوي على HabitCubit
//                   },
//                 ),
//                 _buildQuickActionButton(
//                   icon: Icons.folder_open,
//                   label: "مشروع",
//                   color: Colors.orangeAccent,
//                     // ✅ 3. استدعاء نافذة إضافة المشروع
//                   },
//                 ),
//             ),
//             SizedBox(height: 10.h),
//         ),
//       ),

//     showModalBottomSheet(
//       context: parentContext,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//           value: parentContext.read<TaskCubit>(),
//           child: const AddTaskSheet(),
//       },

//   // ✅ 4. دالة مساعدة لفتح شيت المشاريع
//     showModalBottomSheet(
//       context: parentContext,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//           // value: parentContext.read<ProjectCubit>(),
//           // child:
//           value: parentContext.read<ModuleCubit>(),
//           // ✅ نستخدم AddModuleSheet ونحدد النوع 'project'
//           child: const AddModuleSheet(forcedType: 'project'),
//       },

//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(16.w),
//             decoration: BoxDecoration(
//               color: color.withValues(alpha: 0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: color, size: 28.sp),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             label,
//             style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
//           ),
//       ),

//------------------------------------------------------------------------
// // lib/features/home/presentation/pages/main_page.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 2 | File 2.1
// // ═══════════════════════════════════════════════════════════════════════════════
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';
// // --- Imports Core & DI ---
// import '../../../../core/di/injection.dart';
// // --- Imports Features ---
// import 'package:athar/features/habits/presentation/widgets/habit_form_dialog.dart';
// import 'package:athar/features/space/presentation/cubit/module_cubit.dart';
// import 'package:athar/features/space/presentation/pages/space_list_page.dart';
// import 'package:athar/features/space/presentation/widgets/add_module_sheet.dart';
// import 'package:athar/features/task/presentation/pages/unified_tasks_page.dart';
// import '../../../habits/presentation/cubit/habit_cubit.dart';
// import '../../../habits/presentation/pages/habit_page.dart';
// import '../../../task/presentation/cubit/task_cubit.dart';
// import '../../../task/presentation/widgets/add_task_sheet.dart';
// import 'dashboard_page.dart';

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   int _currentIndex = 0;

//   final List<Widget> _pages = [
//     const DashboardPage(),
//     const UnifiedTasksPage(),
//     const HabitsPage(),
//     const SpaceListPage(),
//   ];

//   void _onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
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
//         BlocProvider(create: (context) => getIt<HabitCubit>()),
//         BlocProvider(create: (context) => getIt<ModuleCubit>()),
//       ],
//       child: Builder(
//         builder: (newContext) {
//           return Scaffold(
//             body: IndexedStack(index: _currentIndex, children: _pages),

//             // ✅ يمكن استخدام AtharButton.fab لكن FAB العادي أفضل هنا
//             floatingActionButton: FloatingActionButton(
//               heroTag: 'main_fab',
//               onPressed: () => _showQuickAddDialog(newContext),
//               // ✅ AppColors.primary → colors.primary
//               backgroundColor: colors.primary,
//               elevation: 4,
//               shape: const CircleBorder(),
//               // ✅ Colors.white → colors.onPrimary
//               child: Icon(Icons.add, color: colors.onPrimary, size: 30.sp),
//             ),
//             floatingActionButtonLocation:
//                 FloatingActionButtonLocation.centerDocked,

//             bottomNavigationBar: _buildBottomBar(colors),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBottomBar(AtharColors colors) {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             // ✅ Colors.black.withValues(alpha: 0.05)
//             color: colors.shadow.withValues(alpha: 0.5),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: BottomAppBar(
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 8.0,
//         // ✅ Colors.white → colors.surface
//         color: colors.surface,
//         elevation: 0,
//         height: 70.h,
//         padding: EdgeInsets.zero,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildNavItem(
//               colors: colors,
//               icon: Icons.dashboard_rounded,
//               label: "الرئيسية",
//               index: 0,
//             ),
//             _buildNavItem(
//               colors: colors,
//               icon: Icons.check_circle_outline_rounded,
//               label: "المهام",
//               index: 1,
//             ),
//             SizedBox(width: 40.w), // مسافة للزر العائم
//             _buildNavItem(
//               colors: colors,
//               icon: Icons.track_changes_rounded,
//               label: "العادات",
//               index: 2,
//             ),
//             _buildNavItem(
//               colors: colors,
//               icon: Icons.workspaces_rounded,
//               label: "المساحات",
//               index: 3,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required AtharColors colors,
//     required IconData icon,
//     required String label,
//     required int index,
//   }) {
//     final isSelected = _currentIndex == index;
//     return InkWell(
//       onTap: () => _onTabTapped(index),
//       // ✅ BorderRadius.circular(30) → AtharRadii.radiusXxxl
//       borderRadius: AtharRadii.radiusXxxl,
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: AtharSpacing.md,
//           vertical: AtharSpacing.sm,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               // ✅ AppColors.primary / Colors.grey.shade400
//               color: isSelected ? colors.primary : colors.textTertiary,
//               size: 26.sp,
//             ),
//             // ✅ SizedBox(height: 4.h) → AtharGap.xxs
//             AtharGap.xxs,
//             AnimatedContainer(
//               // ✅ Duration → AtharAnimations.fast
//               duration: AtharAnimations.fast,
//               height: 4.h,
//               width: isSelected ? 4.h : 0,
//               decoration: BoxDecoration(
//                 // ✅ AppColors.primary → colors.primary
//                 color: colors.primary,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- منطق النوافذ المنبثقة ---

//   void _showQuickAddDialog(BuildContext parentContext) {
//     final colors = parentContext.colors;

//     showModalBottomSheet(
//       context: parentContext,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => Container(
//         // ✅ EdgeInsets.all(20.w) → AtharSpacing.allXl
//         padding: AtharSpacing.allXl,
//         // ✅ EdgeInsets.all(16.w) → AtharSpacing.allLg
//         margin: AtharSpacing.allLg,
//         decoration: BoxDecoration(
//           // ✅ Colors.white → colors.surface
//           color: colors.surface,
//           // ✅ BorderRadius.circular(24.r) → AtharRadii.radiusXxl
//           borderRadius: AtharRadii.radiusXxl,
//           boxShadow: [
//             BoxShadow(
//               color: colors.shadow.withValues(alpha: 0.1),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               "ماذا تريد أن تضيف؟",
//               // ✅ AtharTypography
//               style: AtharTypography.titleLarge.copyWith(
//                 color: colors.textPrimary,
//               ),
//             ),
//             // ✅ SizedBox(height: 24.h) → AtharGap.xxl
//             AtharGap.xxl,
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildQuickActionButton(
//                   colors: colors,
//                   icon: Icons.check_circle_outline,
//                   label: "مهمة",
//                   // ✅ Colors.blueAccent → colors.info
//                   color: colors.info,
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _openAddTaskSheet(parentContext);
//                   },
//                 ),
//                 _buildQuickActionButton(
//                   colors: colors,
//                   icon: Icons.track_changes,
//                   label: "عادة",
//                   // ✅ Colors.purpleAccent → colors.secondary
//                   color: colors.secondary,
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     HabitFormSheet.show(parentContext);
//                   },
//                 ),
//                 _buildQuickActionButton(
//                   colors: colors,
//                   icon: Icons.folder_open,
//                   label: "مشروع",
//                   // ✅ Colors.orangeAccent → colors.warning
//                   color: colors.warning,
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _openAddProjectSheet(parentContext);
//                   },
//                 ),
//               ],
//             ),
//             // ✅ SizedBox(height: 10.h) → AtharGap.sm
//             AtharGap.sm,
//           ],
//         ),
//       ),
//     );
//   }

//   void _openAddTaskSheet(BuildContext parentContext) {
//     showModalBottomSheet(
//       context: parentContext,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return BlocProvider.value(
//           value: parentContext.read<TaskCubit>(),
//           child: const AddTaskSheet(),
//         );
//       },
//     );
//   }

//   void _openAddProjectSheet(BuildContext parentContext) {
//     showModalBottomSheet(
//       context: parentContext,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return BlocProvider.value(
//           value: parentContext.read<ModuleCubit>(),
//           child: const AddModuleSheet(forcedType: 'project'),
//         );
//       },
//     );
//   }

//   Widget _buildQuickActionButton({
//     required AtharColors colors,
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             // ✅ EdgeInsets.all(16.w) → AtharSpacing.allLg
//             padding: AtharSpacing.allLg,
//             decoration: BoxDecoration(
//               color: color.withValues(alpha: 0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: color, size: 28.sp),
//           ),
//           // ✅ SizedBox(height: 8.h) → AtharGap.sm
//           AtharGap.sm,
//           Text(
//             label,
//             // ✅ AtharTypography
//             style: AtharTypography.labelLarge.copyWith(
//               color: colors.textPrimary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//------------------------------------------------------------------------
// import 'package:athar/features/habits/presentation/widgets/habit_form_dialog.dart';
// // import 'package:athar/features/project/presentation/cubit/project_cubit.dart';
// // import 'package:athar/features/project/presentation/widgets/add_project_sheet.dart';
// import 'package:athar/features/space/presentation/cubit/module_cubit.dart';
// import 'package:athar/features/space/presentation/pages/space_list_page.dart';
// import 'package:athar/features/space/presentation/widgets/add_module_sheet.dart';
// import 'package:athar/features/task/presentation/pages/unified_tasks_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // --- Imports Core & DI ---
// import '../../../../core/di/injection.dart';
// import '../../../../core/design_system/themes/app_colors.dart';

// // --- Imports Habits ---
// import '../../../habits/presentation/cubit/habit_cubit.dart';
// import '../../../habits/presentation/pages/habit_page.dart';

// // --- Imports Tasks ---
// import '../../../task/presentation/cubit/task_cubit.dart';
// import '../../../task/presentation/widgets/add_task_sheet.dart';
// // import '../../../task/presentation/pages/task_page.dart';

// // --- Imports Projects ---
// // import '../../../project/presentation/pages/project_page.dart';

// // --- Imports Dashboard ---
// import 'dashboard_page.dart';

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   int _currentIndex = 0;

//   final List<Widget> _pages = [
//     const DashboardPage(), // 0: الرئيسية
//     // const TasksPage(), // 1: المهام
//     const UnifiedTasksPage(), // ✅ التبويب 1: تم التبديل من TasksPage القديمة
//     const HabitsPage(), // 2: العادات
//     // const ProjectsPage(), // 3: المشاريع
//     const SpaceListPage(), // 🆕 كانت ProjectsPage سابقاً
//   ];

//   void _onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ✅ 2. استخدام MultiBlocProvider لتوفير TaskCubit و HabitCubit للزر العائم
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => getIt<TaskCubit>()..watchTasks(DateTime.now()),
//         ),
//         // نحتاج HabitCubit هنا لأن HabitFormDialog يعتمد عليه
//         BlocProvider(create: (context) => getIt<HabitCubit>()),
//         // ✅ إضافة ProjectCubit ليكون متاحاً للنافذة المنبثقة
//         // BlocProvider(create: (context) => getIt<ProjectCubit>()),
//         // ✅ تغيير: توفير ModuleCubit بدلاً من ProjectCubit
//         BlocProvider(create: (context) => getIt<ModuleCubit>()),
//       ],
//       child: Builder(
//         builder: (newContext) {
//           return Scaffold(
//             body: IndexedStack(index: _currentIndex, children: _pages),

//             floatingActionButton: FloatingActionButton(
//               heroTag: 'main_fab',
//               onPressed: () {
//                 // 3. نمرر newContext بدلاً من context القديم
//                 _showQuickAddDialog(newContext);
//               },
//               backgroundColor: AppColors.primary,
//               elevation: 4,
//               shape: const CircleBorder(),
//               child: Icon(Icons.add, color: Colors.white, size: 30.sp),
//             ),
//             floatingActionButtonLocation:
//                 FloatingActionButtonLocation.centerDocked,

//             bottomNavigationBar: _buildBottomBar(),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBottomBar() {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: BottomAppBar(
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 8.0,
//         color: Colors.white,
//         elevation: 0,
//         height: 70.h,
//         padding: EdgeInsets.zero,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildNavItem(
//               icon: Icons.dashboard_rounded,
//               label: "الرئيسية",
//               index: 0,
//             ),
//             _buildNavItem(
//               icon: Icons.check_circle_outline_rounded,
//               label: "المهام",
//               index: 1,
//             ),
//             SizedBox(width: 40.w), // مسافة للزر العائم
//             _buildNavItem(
//               icon: Icons.track_changes_rounded,
//               label: "العادات",
//               index: 2,
//             ),

//             // _buildNavItem(
//             //   icon: Icons.folder_copy_rounded,
//             //   label: "المشاريع",
//             //   index: 3,
//             // ),
//             _buildNavItem(
//               icon: Icons.workspaces_rounded,
//               label: "المساحات",
//               index: 3,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required IconData icon,
//     required String label,
//     required int index,
//   }) {
//     final isSelected = _currentIndex == index;
//     return InkWell(
//       onTap: () => _onTabTapped(index),
//       borderRadius: BorderRadius.circular(30),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? AppColors.primary : Colors.grey.shade400,
//               size: 26.sp,
//             ),
//             SizedBox(height: 4.h),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               height: 4.h,
//               width: isSelected ? 4.h : 0,
//               decoration: BoxDecoration(
//                 color: AppColors.primary,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- منطق النوافذ المنبثقة ---

//   void _showQuickAddDialog(BuildContext parentContext) {
//     showModalBottomSheet(
//       context: parentContext,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => Container(
//         padding: EdgeInsets.all(20.w),
//         margin: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(24.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.1),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               "ماذا تريد أن تضيف؟",
//               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 24.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildQuickActionButton(
//                   icon: Icons.check_circle_outline,
//                   label: "مهمة",
//                   color: Colors.blueAccent,
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _openAddTaskSheet(parentContext);
//                   },
//                 ),
//                 _buildQuickActionButton(
//                   icon: Icons.track_changes,
//                   label: "عادة",
//                   color: Colors.purpleAccent,
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     // ✅ 3. استدعاء الديالوج الموحد وإغلاق الشيت الحالي
//                     // نستخدم parentContext لأنه يحتوي على HabitCubit
//                     HabitFormSheet.show(parentContext);
//                   },
//                 ),
//                 _buildQuickActionButton(
//                   icon: Icons.folder_open,
//                   label: "مشروع",
//                   color: Colors.orangeAccent,
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     // ✅ 3. استدعاء نافذة إضافة المشروع
//                     _openAddProjectSheet(parentContext);
//                   },
//                 ),
//               ],
//             ),
//             SizedBox(height: 10.h),
//           ],
//         ),
//       ),
//     );
//   }

//   void _openAddTaskSheet(BuildContext parentContext) {
//     showModalBottomSheet(
//       context: parentContext,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return BlocProvider.value(
//           value: parentContext.read<TaskCubit>(),
//           child: const AddTaskSheet(),
//         );
//       },
//     );
//   }

//   // ✅ 4. دالة مساعدة لفتح شيت المشاريع
//   void _openAddProjectSheet(BuildContext parentContext) {
//     showModalBottomSheet(
//       context: parentContext,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return BlocProvider.value(
//           // value: parentContext.read<ProjectCubit>(),
//           // child:
//           //     const AddProjectSheet(), // نفترض أن الشيت جاهز ولا يحتاج بارامترات للإضافة
//           value: parentContext.read<ModuleCubit>(),
//           // ✅ نستخدم AddModuleSheet ونحدد النوع 'project'
//           child: const AddModuleSheet(forcedType: 'project'),
//         );
//       },
//     );
//   }

//   Widget _buildQuickActionButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             padding: EdgeInsets.all(16.w),
//             decoration: BoxDecoration(
//               color: color.withValues(alpha: 0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: color, size: 28.sp),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             label,
//             style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }
// }
