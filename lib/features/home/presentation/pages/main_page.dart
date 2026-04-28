// lib/features/home/presentation/pages/main_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 🏠 Main Page - مع Liquid Glass Navigation Bar
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ LiquidGlassNavBar بتأثير glass
// ✅ ContextAwareFab ذكي حسب الصفحة
// ✅ NavigationRail للتابلت
// ✅ دعم إخفاء الشريط عند التمرير
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Core
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/utils/responsive_helper.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

// Widgets
import 'package:athar/core/design_system/widgets/liquid_glass_nav_bar.dart';
import 'package:athar/core/design_system/widgets/context_aware_fab.dart';

// Features - Pages
import 'package:athar/features/task/presentation/pages/unified_tasks_page.dart';
import 'package:athar/features/space/presentation/pages/space_list_page.dart';
import 'package:athar/features/habits/presentation/pages/habit_page.dart';
import 'dashboard_page.dart';

// Features - Sheets & Widgets
// ✅ UnifiedAddSheet يحتوي على EntityType
import 'package:athar/features/task/presentation/widgets/unified_add_sheet.dart';
import 'package:athar/features/space/presentation/widgets/add_module_sheet.dart';
import 'package:athar/features/habits/presentation/widgets/habit_form_dialog.dart';

// Cubits
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:athar/features/space/presentation/cubit/module_cubit.dart';
import 'package:athar/features/space/presentation/cubit/space_cubit.dart';
import 'package:athar/features/habits/presentation/cubit/habit_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:athar/features/settings/presentation/pages/settings_page.dart';
import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isRailExpanded = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Auto-expand rail in landscape on iPad, collapse in portrait
    if (ResponsiveHelper.isTablet(context)) {
      final isLandscape = ResponsiveHelper.isLandscape(context);
      if (_isRailExpanded != isLandscape) {
        _isRailExpanded = isLandscape;
      }
    }
  }

  // الصفحات
  late final List<Widget> _pages;

  // أسماء الصفحات للسياق
  final List<FabContext> _pageContexts = [
    FabContext.dashboard,
    FabContext.tasks,
    FabContext.habits,
    FabContext.spaces,
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardPage(),
      const UnifiedTasksPage(),
      const HabitsPage(),
      const SpaceListPage(),
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<TaskCubit>()..watchTasks(DateTime.now()),
        ),
        BlocProvider(create: (context) => getIt<HabitCubit>()),
        BlocProvider(create: (context) => getIt<ModuleCubit>()),
        BlocProvider(create: (context) => getIt<HealthCubit>()),
      ],
      child: Builder(
        builder: (newContext) {
          return FabContextProvider(
            fabContext: _pageContexts[_currentIndex],
            child: Scaffold(
              extendBody: !isTablet,
              // ═════════════════════════════════════════════════════════════
              // الجسم
              // ═════════════════════════════════════════════════════════════
              body: isTablet
                  ? _buildTabletLayout(colorScheme, l10n)
                  : _buildPhoneLayout(),

              // ═════════════════════════════════════════════════════════════
              // شريط التنقل الزجاجي (للهاتف فقط)
              // ═════════════════════════════════════════════════════════════
              bottomNavigationBar: isTablet
                  ? null
                  // ✅ FIX: استخدام BlocBuilder للوصول الصحيح لـ hideNavOnScroll
                  : BlocBuilder<SettingsCubit, SettingsState>(
                      buildWhen: (prev, curr) =>
                          (prev is SettingsLoaded ? prev.settings.hideNavOnScroll : false) !=
                          (curr is SettingsLoaded ? curr.settings.hideNavOnScroll : false),
                      builder: (context, settingsState) {
                        // ✅ FIX: الوصول الصحيح عبر SettingsLoaded.settings
                        final hideOnScroll = settingsState is SettingsLoaded
                            ? settingsState.settings.hideNavOnScroll
                            : false;

                        return LiquidGlassNavBar(
                          items: _buildNavItems(l10n),
                          currentIndex: _currentIndex,
                          onTap: _onTabTapped,
                          onFabPressed: () => _handleFabPressed(newContext),
                          fabColor: colorScheme.primary,
                          hideOnScroll: hideOnScroll,
                          scrollController: _scrollController,
                          backgroundOpacity: 0.75,
                          blurSigma: 25.0,
                        );
                      },
                    ),

              // ═════════════════════════════════════════════════════════════
              // FAB للتابلت فقط
              // ═════════════════════════════════════════════════════════════
              floatingActionButton: isTablet
                  ? _buildTabletFab(newContext, colorScheme)
                  : null,
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // بناء عناصر التنقل
  // ═══════════════════════════════════════════════════════════════════════════

  List<LiquidNavItem> _buildNavItems(AppLocalizations l10n) {
    return [
      LiquidNavItem(
        icon: AtharNavIcons.homeOutline,
        selectedIcon: AtharNavIcons.homeFilled,
        label: l10n.home,
      ),
      LiquidNavItem(
        icon: AtharNavIcons.tasksOutline,
        selectedIcon: AtharNavIcons.tasksFilled,
        label: l10n.tasks,
      ),
      LiquidNavItem(
        icon: AtharNavIcons.habitsOutline,
        selectedIcon: AtharNavIcons.habitsFilled,
        label: l10n.habits,
      ),
      LiquidNavItem(
        icon: AtharNavIcons.spacesOutline,
        selectedIcon: AtharNavIcons.spacesFilled,
        label: l10n.spaces,
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Layout الهاتف
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildPhoneLayout() {
    return PrimaryScrollController(
      controller: _scrollController,
      child: IndexedStack(index: _currentIndex, children: _pages),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Layout التابلت مع NavigationRail
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTabletLayout(ColorScheme colorScheme, AppLocalizations l10n) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    final rail = AnimatedContainer(
      duration: AtharAnimations.normal,
      width: _isRailExpanded ? 200.w : 72.w,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: isRTL
              ? BorderSide.none
              : BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
          right: isRTL
              ? BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                )
              : BorderSide.none,
        ),
      ),
      child: SafeArea(
        child: NavigationRail(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          extended: _isRailExpanded,
          minExtendedWidth: 200.w,
          minWidth: 72.w,
          labelType: _isRailExpanded
              ? NavigationRailLabelType.none
              : NavigationRailLabelType.all,
          backgroundColor: Colors.transparent,
          indicatorColor: colorScheme.primaryContainer,
          selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 24),
          unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),
          selectedLabelTextStyle: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13.sp,
          ),
          leading: _buildRailLeading(colorScheme, isRTL),
          trailing: _buildRailTrailing(colorScheme),
          destinations: [
            NavigationRailDestination(
              icon: const Icon(AtharNavIcons.homeOutline),
              selectedIcon: const Icon(AtharNavIcons.homeFilled),
              label: Text(l10n.home),
            ),
            NavigationRailDestination(
              icon: const Icon(AtharNavIcons.tasksOutline),
              selectedIcon: const Icon(AtharNavIcons.tasksFilled),
              label: Text(l10n.tasks),
            ),
            NavigationRailDestination(
              icon: const Icon(AtharNavIcons.habitsOutline),
              selectedIcon: const Icon(AtharNavIcons.habitsFilled),
              label: Text(l10n.habits),
            ),
            NavigationRailDestination(
              icon: const Icon(AtharNavIcons.spacesOutline),
              selectedIcon: const Icon(AtharNavIcons.spacesFilled),
              label: Text(l10n.spaces),
            ),
          ],
        ),
      ),
    );

    final content = Expanded(
      child: SafeArea(
        left: !isRTL,
        right: isRTL,
        child: _pages[_currentIndex],
      ),
    );

    // Rail on the trailing edge (right in RTL, left in LTR)
    return Row(
      children: isRTL ? [content, rail] : [rail, content],
    );
  }

  Widget _buildRailLeading(ColorScheme colorScheme, bool isRTL) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: IconButton(
        onPressed: () => setState(() => _isRailExpanded = !_isRailExpanded),
        icon: AnimatedRotation(
          // In RTL: chevron_right collapses to the right, in LTR: chevron_left collapses left
          turns: isRTL
              ? (_isRailExpanded ? 0.0 : 0.5)
              : (_isRailExpanded ? 0.5 : 0.0),
          duration: AtharAnimations.fast,
          child: Icon(
            isRTL ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
          ),
        ),
        tooltip: _isRailExpanded ? 'تصغير القائمة' : 'توسيع القائمة',
      ),
    );
  }

  Widget _buildRailTrailing(ColorScheme colorScheme) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: 24.h),
          child: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
            icon: const Icon(Icons.settings_outlined),
            color: colorScheme.onSurfaceVariant,
            tooltip: 'الإعدادات',
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FAB للتابلت
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTabletFab(BuildContext context, ColorScheme colorScheme) {
    return FloatingActionButton.large(
      heroTag: 'tablet_fab',
      onPressed: () => _handleFabPressed(context),
      backgroundColor: colorScheme.primary,
      child: Icon(Icons.add, color: colorScheme.onPrimary, size: 32.sp),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // معالجة الضغط على FAB حسب السياق
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleFabPressed(BuildContext parentContext) {
    final controller = ContextAwareFabController(
      context: parentContext,
      fabContext: _pageContexts[_currentIndex],
      onAddTask: () => _openAddTaskSheet(parentContext),
      onAddAppointment: () => _openAddAppointmentSheet(parentContext),
      onAddMedicine: () => _openAddMedicineSheet(parentContext),
      onAddHabit: () => _openAddHabitSheet(parentContext),
      // ✅ FIX: استخدام Dialog بدلاً من AddSpaceSheet غير الموجود
      onAddSpace: () => _showCreateSpaceDialog(parentContext),
      onAddModule: (_) => _openAddModuleSheet(parentContext),
    );

    controller.execute();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // فتح الـ Sheets المختلفة
  // ═══════════════════════════════════════════════════════════════════════════

  void _openAddTaskSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: parentContext.read<TaskCubit>()),
            BlocProvider.value(value: parentContext.read<HealthCubit>()),
          ],
          child: const UnifiedAddSheet(initialType: EntityType.task),
        );
      },
    );
  }

  void _openAddAppointmentSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: parentContext.read<TaskCubit>()),
            BlocProvider.value(value: parentContext.read<HealthCubit>()),
          ],
          child: const UnifiedAddSheet(initialType: EntityType.appointment),
        );
      },
    );
  }

  void _openAddMedicineSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: parentContext.read<TaskCubit>()),
            BlocProvider.value(value: parentContext.read<HealthCubit>()),
          ],
          child: const UnifiedAddSheet(initialType: EntityType.medicine),
        );
      },
    );
  }

  void _openAddHabitSheet(BuildContext parentContext) {
    HabitFormSheet.show(parentContext);
  }

  // ✅ FIX: استخدام Dialog بدلاً من AddSpaceSheet غير الموجود
  void _showCreateSpaceDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    bool isShared = false;

    // التحقق من حالة المستخدم
    final authState = context.read<AuthCubit>().state;
    final bool isAuthenticated = authState is AuthAuthenticated;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.spaceListCreateTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: l10n.spaceListNameLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                AtharGap.lg,

                // Switch للمساحة المشتركة
                if (isAuthenticated)
                  SwitchListTile(
                    title: Text(l10n.spaceListSharedQuestion),
                    subtitle: Text(
                      isShared
                          ? l10n.spaceListSharedSubtitle
                          : l10n.spaceListPrivateSubtitle,
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    value: isShared,
                    onChanged: (val) => setState(() => isShared = val),
                    activeThumbColor: colorScheme.primary,
                  )
                else
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 
                        0.5,
                      ),
                      borderRadius: AtharRadii.radiusMd,
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.group_off, color: colorScheme.outline),
                        AtharGap.hMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.spaceListSharedQuestion,
                                style: TextStyle(
                                  color: colorScheme.outline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'سجل دخولك لإنشاء مساحات مشتركة',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: colorScheme.outline.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  if (controller.text.trim().isEmpty) return;

                  context.read<SpaceCubit>().createSpace(
                    controller.text.trim(),
                    isShared: isShared,
                  );
                  Navigator.pop(ctx);
                },
                child: Text(l10n.spaceListCreate),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openAddModuleSheet(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
          value: parentContext.read<ModuleCubit>(),
          child: const AddModuleSheet(),
        );
      },
    );
  }
}

// --------------------------------------------------------------------------------------
// // lib/features/home/presentation/pages/main_page.dart
// import 'package:athar/core/utils/responsive_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/tokens.dart';
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

// /// Semantic colors (not in ColorScheme)
// const _warningColor = Color(0xFFFDCB6E);
// const _infoColor = Color(0xFF74B9FF);

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   int _currentIndex = 0;

//   bool _isRailExpanded = true;

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
//     final colorScheme = Theme.of(context).colorScheme;

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
//           final isTablet = context.isTablet;

//           return Shortcuts(
//             shortcuts: {
//               LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.digit1):
//                   const ActivateIntent(),
//               LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.digit2):
//                   const ActivateIntent(),
//               LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.digit3):
//                   const ActivateIntent(),
//               LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.digit4):
//                   const ActivateIntent(),
//             },
//             child: Actions(
//               actions: {
//                 ActivateIntent: CallbackAction<ActivateIntent>(
//                   onInvoke: (intent) {
//                     // بسيط: نلف بين التابات
//                     setState(() {
//                       _currentIndex = (_currentIndex + 1) % 4;
//                     });
//                     return null;
//                   },
//                 ),
//               },
//               child: Scaffold(
//                 body: isTablet
//                     ? _buildTabletLayout(colorScheme)
//                     : IndexedStack(index: _currentIndex, children: _pages),

//                 floatingActionButton: FloatingActionButton(
//                   heroTag: 'main_fab',
//                   onPressed: () => _showQuickAddDialog(newContext),
//                   backgroundColor: colorScheme.primary,
//                   elevation: 4,
//                   shape: const CircleBorder(),
//                   child: Icon(
//                     Icons.add,
//                     color: colorScheme.onPrimary,
//                     size: 30.sp,
//                   ),
//                 ),

//                 floatingActionButtonLocation: isTablet
//                     ? FloatingActionButtonLocation.endContained
//                     : FloatingActionButtonLocation.centerDocked,

//                 bottomNavigationBar: isTablet
//                     ? null
//                     : _buildBottomBar(colorScheme),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBottomBar(ColorScheme colorScheme) {
//     final l10n = AppLocalizations.of(context);
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             // ✅ Colors.black.withValues(alpha: 0.05)
//             color: colorScheme.shadow.withValues(alpha: 0.5),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: BottomAppBar(
//         shape: CircularNotchedRectangle(),
//         notchMargin: 8.0,
//         // ✅ Colors.white → colors.surface
//         color: colorScheme.surface,
//         elevation: 0,
//         height: 70.h,
//         padding: EdgeInsets.zero,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             _buildNavItem(
//               colorScheme: colorScheme,
//               icon: Icons.dashboard_rounded,
//               label: l10n.home,
//               index: 0,
//             ),
//             _buildNavItem(
//               colorScheme: colorScheme,
//               icon: Icons.check_circle_outline_rounded,
//               label: l10n.tasks,
//               index: 1,
//             ),
//             // مسافة للزر العائم
//             Spacer(),
//             SizedBox(width: 20),
//             Spacer(),
//             _buildNavItem(
//               colorScheme: colorScheme,
//               icon: Icons.track_changes_rounded,
//               label: l10n.habits,
//               index: 2,
//             ),
//             _buildNavItem(
//               colorScheme: colorScheme,
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
//     required ColorScheme colorScheme,
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
//               color: isSelected ? colorScheme.primary : colorScheme.outline,
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
//                 color: colorScheme.primary,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabletLayout(ColorScheme colorScheme) {
//     final l10n = AppLocalizations.of(context);

//     return Row(
//       children: [
//         SizedBox(
//           child: Column(
//             children: [
//               // 🔘 زر التوسعة/التصغير
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: IconButton(
//                   icon: Icon(
//                     _isRailExpanded ? Icons.chevron_left : Icons.chevron_right,
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _isRailExpanded = !_isRailExpanded;
//                     });
//                   },
//                 ),
//               ),

//               Expanded(
//                 child: NavigationRail(
//                   selectedIndex: _currentIndex,
//                   onDestinationSelected: _onTabTapped,
//                   labelType: context.isLandscape
//                       ? NavigationRailLabelType.all
//                       : NavigationRailLabelType.selected,
//                   backgroundColor: colorScheme.surface,
//                   selectedIconTheme: IconThemeData(color: colorScheme.primary),
//                   unselectedIconTheme: IconThemeData(
//                     color: colorScheme.outline,
//                   ),
//                   destinations: [
//                     NavigationRailDestination(
//                       icon: Icon(Icons.dashboard_rounded),
//                       label: Text(l10n.home),
//                     ),
//                     NavigationRailDestination(
//                       icon: Icon(Icons.check_circle_outline_rounded),
//                       label: Text(l10n.tasks),
//                     ),
//                     NavigationRailDestination(
//                       icon: Icon(Icons.track_changes_rounded),
//                       label: Text(l10n.habits),
//                     ),
//                     NavigationRailDestination(
//                       icon: Icon(Icons.workspaces_rounded),
//                       label: Text(l10n.spaces),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const VerticalDivider(width: 1),

//         // ✅ المحتوى
//         Expanded(
//           child: Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 maxWidth: 900, // يعطيك UX ممتاز
//               ),
//               child: IndexedStack(index: _currentIndex, children: _pages),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // --- منطق النوافذ المنبثقة ---

//   void _showQuickAddDialog(BuildContext parentContext) {
//     final colorScheme = Theme.of(parentContext).colorScheme;
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
//           color: colorScheme.surface,
//           // ✅ BorderRadius.circular(24.r) → AtharRadii.radiusXxl
//           borderRadius: AtharRadii.radiusXxl,
//           boxShadow: [
//             BoxShadow(
//               color: colorScheme.shadow.withValues(alpha: 0.1),
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
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 height: 1.4,
//               ).copyWith(color: colorScheme.onSurface),
//             ),
//             // ✅ SizedBox(height: 24.h) → AtharGap.xxl
//             AtharGap.xxl,
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildQuickActionButton(
//                   colorScheme: colorScheme,
//                   icon: Icons.check_circle_outline,
//                   label: l10n.task,
//                   // ✅ Colors.blueAccent → colors.info
//                   color: _infoColor,
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _openAddTaskSheet(parentContext);
//                   },
//                 ),
//                 _buildQuickActionButton(
//                   colorScheme: colorScheme,
//                   icon: Icons.track_changes,
//                   label: l10n.habit,
//                   // ✅ Colors.purpleAccent → colors.secondary
//                   color: colorScheme.secondary,
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     HabitFormSheet.show(parentContext);
//                   },
//                 ),
//                 _buildQuickActionButton(
//                   colorScheme: colorScheme,
//                   icon: Icons.folder_open,
//                   label: l10n.project,
//                   // ✅ Colors.orangeAccent → colors.warning
//                   color: _warningColor,
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
//     required ColorScheme colorScheme,
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
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               height: 1.4,
//               letterSpacing: 0.25,
//             ).copyWith(color: colorScheme.onSurface),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
