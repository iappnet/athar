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
import 'package:athar/core/design_system/widgets/adaptive_shell.dart';
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
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 840) {
      // Expanded rail (840–1199dp): auto-expand in landscape, collapse in portrait
      final isLandscape = ResponsiveHelper.isLandscape(context);
      if (_isRailExpanded != isLandscape) {
        _isRailExpanded = isLandscape;
      }
    } else if (width >= 600) {
      // Compact rail (600–839dp): always start collapsed — icons only
      if (_isRailExpanded) _isRailExpanded = false;
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
            // AdaptiveShell: LayoutBuilder-based breakpoint decision.
            // Resolves phone / tabletCompact / tabletExpanded at render time
            // so Split View and Stage Manager width changes take effect
            // immediately without a full rebuild.
            child: AdaptiveShell(
              builder: (_, breakpoint) {
                return Scaffold(
                  extendBody: breakpoint.isPhone,
                  // ═══════════════════════════════════════════════════════
                  // الجسم
                  // ═══════════════════════════════════════════════════════
                  body: breakpoint.isTablet
                      ? _buildTabletLayout(colorScheme, l10n, breakpoint)
                      : _buildPhoneLayout(),

                  // ═══════════════════════════════════════════════════════
                  // شريط التنقل الزجاجي (للهاتف فقط)
                  // ═══════════════════════════════════════════════════════
                  bottomNavigationBar: breakpoint.isPhone
                      ? BlocBuilder<SettingsCubit, SettingsState>(
                          buildWhen: (prev, curr) =>
                              (prev is SettingsLoaded
                                  ? prev.settings.hideNavOnScroll
                                  : false) !=
                              (curr is SettingsLoaded
                                  ? curr.settings.hideNavOnScroll
                                  : false),
                          builder: (context, settingsState) {
                            final hideOnScroll = settingsState is SettingsLoaded
                                ? settingsState.settings.hideNavOnScroll
                                : false;

                            return LiquidGlassNavBar(
                              items: _buildNavItems(l10n),
                              currentIndex: _currentIndex,
                              onTap: _onTabTapped,
                              onFabPressed: () =>
                                  _handleFabPressed(newContext),
                              fabColor: colorScheme.primary,
                              hideOnScroll: hideOnScroll,
                              scrollController: _scrollController,
                              backgroundOpacity: 0.75,
                              blurSigma: 25.0,
                            );
                          },
                        )
                      : null,

                  // ═══════════════════════════════════════════════════════
                  // FAB للتابلت فقط
                  // ═══════════════════════════════════════════════════════
                  floatingActionButton: breakpoint.isTablet
                      ? _buildTabletFab(newContext, colorScheme)
                      : null,
                );
              },
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

  Widget _buildTabletLayout(ColorScheme colorScheme, AppLocalizations l10n, ShellBreakpoint breakpoint) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    // Compact rail (600–839dp): icon-only regardless of user toggle.
    // Expanded rail (≥840dp): user-togglable between 72pt and 240pt.
    final effectivelyExpanded = !breakpoint.usesCompactRail && _isRailExpanded;

    final rail = AnimatedContainer(
      duration: AtharAnimations.normal,
      width: effectivelyExpanded ? 200.w : 72.w,
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
          extended: effectivelyExpanded,
          minExtendedWidth: 200.w,
          minWidth: 72.w,
          labelType: effectivelyExpanded
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
          leading: _buildRailLeading(colorScheme, isRTL, effectivelyExpanded, breakpoint),
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

  Widget _buildRailLeading(
    ColorScheme colorScheme,
    bool isRTL,
    bool effectivelyExpanded,
    ShellBreakpoint breakpoint,
  ) {
    // Compact rail (600–839dp): no expand toggle — always icon-only at this width
    if (breakpoint.usesCompactRail) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: IconButton(
        onPressed: () => setState(() => _isRailExpanded = !_isRailExpanded),
        icon: AnimatedRotation(
          turns: isRTL
              ? (effectivelyExpanded ? 0.0 : 0.5)
              : (effectivelyExpanded ? 0.5 : 0.0),
          duration: AtharAnimations.fast,
          child: Icon(
            isRTL ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
          ),
        ),
        tooltip: effectivelyExpanded ? 'تصغير القائمة' : 'توسيع القائمة',
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
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;

                  await context.read<SpaceCubit>().createSpace(
                    controller.text.trim(),
                    isShared: isShared,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
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

