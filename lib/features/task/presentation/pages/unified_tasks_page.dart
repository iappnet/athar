//————-————— code start ————————-
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/widgets/athar_dialog.dart';
import 'package:athar/core/design_system/widgets/athar_feedback.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
import 'package:athar/features/task/domain/models/filter_item.dart';
import 'package:athar/features/task/presentation/widgets/reflection_dialog.dart';
import 'package:athar/core/design_system/molecules/tiles/unified_timeline_tile.dart';
import 'package:athar/core/design_system/molecules/bars/filter_bar.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/home/presentation/cubit/timeline_cubit.dart';
import 'package:athar/features/home/domain/entities/daily_item.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import 'package:athar/features/health/data/models/medicine_model.dart';
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:athar/features/task/presentation/cubit/task_state.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/features/task/presentation/widgets/app_drawer.dart';
import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
import 'package:athar/features/task/presentation/widgets/unified_add_sheet.dart';
import 'package:athar/features/task/presentation/widgets/bulk_actions_bar.dart';
import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnifiedTasksPage extends StatelessWidget {
  const UnifiedTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<TimelineCubit>()..loadGlobalTimeline(),
        ),
        BlocProvider(create: (context) => getIt<HealthCubit>()),
        BlocProvider(create: (context) => getIt<TaskCubit>()),
      ],
      child: const UnifiedTasksView(),
    );
  }
}

class UnifiedTasksView extends StatefulWidget {
  const UnifiedTasksView({super.key});

  @override
  State<UnifiedTasksView> createState() => _UnifiedTasksViewState();
}

class _UnifiedTasksViewState extends State<UnifiedTasksView> {
  bool _isKanbanView = false;
  bool _isSelectionMode = false; // ✅ وضع التحديد
  final PageController _pageController = PageController(viewportFraction: 0.85);

  void _onDeletePressed(BuildContext context, DailyItem item) {
    final messenger = ScaffoldMessenger.of(context);
    final taskCubit = context.read<TaskCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    if (item.type == DailyItemType.task) {
      final task = item.originalData as TaskModel;
      taskCubit.deleteTask(task.id);

      AtharSnackbar.showWithMessenger(
        messenger: messenger,
        message: l10n.deletedItem(item.title),
        colorScheme: colorScheme,
        variant: AtharSnackbarVariant.info,
        icon: Icons.delete_outline_rounded,
        actionLabel: l10n.undo,
        onAction: () => taskCubit.undoDelete(),
        clearPrevious: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final taskCubit = context.watch<TaskCubit>();
    final selectedCount = taskCubit.selectedTaskIds.length;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      drawer: const AppDrawer(),
      appBar: AtharAppBar(
        title: l10n.unifiedOpsCenter,
        subtitle: l10n.allInOnePlace,
        leading: Builder(
          builder: (context) => AtharButton.icon(
            icon: Icons.menu,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // ✅ زر وضع التحديد
          AtharButton.icon(
            icon: _isSelectionMode ? Icons.close : Icons.checklist,
            onPressed: () {
              setState(() {
                _isSelectionMode = !_isSelectionMode;
                if (!_isSelectionMode) {
                  taskCubit.clearSelection();
                }
              });
            },
          ),
        ],
      ),
      body: BlocListener<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskError && state.message == "PERMISSION_DENIED") {
            AtharSnackbar.error(
              context: context,
              message: l10n.noPermissionEdit,
            );
          }
        },
        child: Column(
          children: [
            const SmartPrayerCardWrapper(pageType: PageType.tasks),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(child: _buildSmartZoneBanner()),
                  AtharGap.hSm,
                  _buildViewToggle(),
                ],
              ),
            ),

            _buildUnifiedFilterBar(context),

            Expanded(
              child: BlocBuilder<TimelineCubit, TimelineState>(
                builder: (context, state) {
                  if (state is TimelineLoading) {
                    return const AtharLoading.centered();
                  } else if (state is TimelineLoaded) {
                    if (state.items.isEmpty) return _buildEmptyState(context);

                    return _isKanbanView
                        ? _buildUnifiedKanbanView(context, state.items)
                        : _buildListView(state.items);
                  } else if (state is TimelineError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // ✅ شريط العمليات الجماعية
            if (_isSelectionMode && selectedCount > 0)
              BulkActionsBar(
                selectedCount: selectedCount,
                onCancel: () {
                  setState(() => _isSelectionMode = false);
                  taskCubit.clearSelection();
                },
                onCompleteAll: () async {
                  await taskCubit.completeSelectedTasks();
                  setState(() => _isSelectionMode = false);
                },
                onDeleteAll: () async {
                  await taskCubit.deleteSelectedTasks();
                  setState(() => _isSelectionMode = false);
                },
                onPostponeAll: () => _showPostponeDialog(context),
                onAssignAll: () => _showAssignDialog(context),
              ),
          ],
        ),
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              heroTag: 'unified_tasks_fab',
              backgroundColor: colorScheme.primary,
              icon: Icon(Icons.add, color: colorScheme.surface),
              label: Text(
                l10n.newTask,
                style: TextStyle(color: colorScheme.surface),
              ),
              onPressed: () => _showAddTaskSheet(context),
            ),
    );
  }

  Widget _buildListView(List<DailyItem> items) {
    return RefreshIndicator(
      onRefresh: () async => context.read<TimelineCubit>().loadGlobalTimeline(),
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: 80.h),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final taskCubit = context.read<TaskCubit>();

          // ✅ للمهام فقط: عرض Checkbox في وضع التحديد
          if (_isSelectionMode && item.type == DailyItemType.task) {
            final task = item.originalData as TaskModel;
            final isSelected = taskCubit.selectedTaskIds.contains(task.id);

            return CheckboxListTile(
              value: isSelected,
              onChanged: (val) {
                taskCubit.toggleTaskSelection(task.id);
              },
              title: UnifiedTimelineTile(
                item: item,
                onToggle: () => _handleToggle(context, item),
                onDelete: () => _onDeletePressed(context, item),
                onTap: () => _handleDetails(context, item),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            );
          }

          return UnifiedTimelineTile(
            item: item,
            onToggle: () => _handleToggle(context, item),
            onDelete: () => _onDeletePressed(context, item),
            onTap: () => _handleDetails(context, item),
          );
        },
      ),
    );
  }

  Widget _buildUnifiedFilterBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<TimelineCubit, TimelineState>(
      builder: (context, state) {
        if (state is TimelineLoaded) {
          final List<FilterItem> availableFilters = [
            FixedFilterType.all,
            FixedFilterType.urgent,
          ];

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: FilterBar<FilterItem>(
              items: availableFilters,
              selectedItem: state.activeFilter == 'urgent'
                  ? FixedFilterType.urgent
                  : FixedFilterType.all,
              onSelected: (filter) {
                String filterValue = filter == FixedFilterType.urgent
                    ? 'urgent'
                    : 'all';
                context.read<TimelineCubit>().setFilter(filterValue);
              },
              labelBuilder: (f) => f.label
                  .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '')
                  .trim(),
              iconBuilder: (f) => f == FixedFilterType.all
                  ? Icons.grid_view_rounded
                  : Icons.local_fire_department_rounded,
              colorBuilder: (f) => f == FixedFilterType.urgent
                  ? colorScheme.error
                  : colorScheme.primary,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildUnifiedKanbanView(BuildContext context, List<DailyItem> items) {
    final l10n = AppLocalizations.of(context);
    final todo = items.where((i) => !i.isCompleted).toList();
    final done = items.where((i) => i.isCompleted).toList();

    return PageView(
      controller: _pageController,
      children: [
        _buildKanbanColumn(l10n.dueAndOperations, Colors.blue, todo, context),
        _buildKanbanColumn(l10n.completedToday, context.colors.success, done, context),
      ],
    );
  }

  Widget _buildKanbanColumn(
    String title,
    Color color,
    List<DailyItem> items,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              AtharGap.hSm,
              Text(
                title,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                "${items.length}",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => UnifiedTimelineTile(
                item: items[index],
                onToggle: () => _handleToggle(context, items[index]),
                onDelete: () => _onDeletePressed(context, items[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ الدالة المصححة نهائياً - حل مشكلة BuildContext across async gaps
  // ═══════════════════════════════════════════════════════════════════════════
  void _handleToggle(BuildContext context, DailyItem item) {
    if (item.type == DailyItemType.task) {
      final task = item.originalData as TaskModel;

      // ✅ 1. حفظ جميع الـ references قبل أي async operation
      final taskCubit = context.read<TaskCubit>();
      final celebrationCubit = context.read<CelebrationCubit>();

      // ✅ 2. تنفيذ العمليات المتزامنة
      if (!task.isCompleted) {
        celebrationCubit.celebrate();
      }

      taskCubit.toggleTaskCompletion(task);

      // ✅ 3. عرض dialog التأمل بعد الإكمال
      if (!task.isCompleted) {
        _showReflectionDialogDelayed(
          taskTitle: task.title,
          taskCubit: taskCubit,
          task: task,
        );
      }
    } else if (item.type == DailyItemType.medicine) {
      final med = item.originalData as MedicineModel;
      context.read<HealthCubit>().takeDose(med.moduleId, med);
    }
  }

  // ✅ دالة منفصلة لعرض الـ Dialog بشكل آمن
  void _showReflectionDialogDelayed({
    required String taskTitle,
    required TaskCubit taskCubit,
    required TaskModel task,
  }) {
    Future.delayed(const Duration(milliseconds: 500), () {
      // ✅ فحص mounted قبل أي شيء
      if (!mounted) return;

      // ✅ استخدام context بشكل آمن بعد mounted check
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (dialogContext) => ReflectionDialog(
          taskTitle: taskTitle,
          onSave: (note) {
            // ✅ استخدام الـ cubit المحفوظ مسبقاً (آمن 100%)
            taskCubit.saveCompletionNote(task, note);
          },
        ),
      );
    });
  }

  void _handleDetails(BuildContext context, DailyItem item) {
    if (item.type == DailyItemType.task) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<TaskCubit>()),
            BlocProvider.value(value: context.read<HealthCubit>()),
            BlocProvider.value(value: context.read<CategoryCubit>()),
            BlocProvider.value(value: context.read<SettingsCubit>()),
            BlocProvider.value(value: context.read<PrayerCubit>()),
          ],
          child: UnifiedAddSheet(
            initialType: EntityType.task,
            itemToEdit: item.originalData,
          ),
        ),
      );
    }
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<TaskCubit>()),
          BlocProvider.value(value: context.read<HealthCubit>()),
          BlocProvider.value(value: context.read<CategoryCubit>()),
          BlocProvider.value(value: context.read<SettingsCubit>()),
          BlocProvider.value(value: context.read<PrayerCubit>()),
        ],
        child: const UnifiedAddSheet(initialType: EntityType.task),
      ),
    );
  }

  // ✅ حوار التأجيل
  void _showPostponeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    AtharDialog.show(
      context: context,
      title: l10n.postponeSelectedTasks,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.today),
            title: Text(l10n.tomorrow),
            onTap: () {
              Navigator.pop(context);
              context.read<TaskCubit>().postponeSelectedTasks(
                const Duration(days: 1),
              );
              setState(() => _isSelectionMode = false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: Text(l10n.afterOneWeek),
            onTap: () {
              Navigator.pop(context);
              context.read<TaskCubit>().postponeSelectedTasks(
                const Duration(days: 7),
              );
              setState(() => _isSelectionMode = false);
            },
          ),
        ],
      ),
    );
  }

  // ✅ حوار الإسناد
  void _showAssignDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    AtharDialog.alert(
      context: context,
      title: l10n.assignSelectedTasks,
      message: l10n.featureUnderDevelopment,
    );
  }

  Widget _buildViewToggle() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: IconButton(
        icon: Icon(
          _isKanbanView ? Icons.view_list_rounded : Icons.view_kanban_rounded,
          color: colorScheme.primary,
        ),
        onPressed: () => setState(() => _isKanbanView = !_isKanbanView),
      ),
    );
  }

  Widget _buildSmartZoneBanner() {
    return BlocBuilder<TimelineCubit, TimelineState>(
      builder: (context, state) {
        if (state is TimelineLoaded) {
          final info = _getZoneInfo(state.activeZone);
          return Container(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: info.color.withValues(alpha: 0.1),
              borderRadius: AtharRadii.radiusSm,
            ),
            child: Row(
              children: [
                Icon(info.icon, size: 14.sp, color: info.color),
                AtharGap.hSm,
                Text(
                  info.label,
                  style: TextStyle(
                    color: info.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  _ZoneInfo _getZoneInfo(String zone) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    switch (zone) {
      case 'work':
        return _ZoneInfo(l10n.workZone, Colors.blue, Icons.work_outline);
      case 'home':
        return _ZoneInfo(l10n.homeZone, Colors.orange, Icons.home_outlined);
      case 'quiet':
        return _ZoneInfo(l10n.quietZone, Colors.indigo, Icons.bedtime_outlined);
      default:
        return _ZoneInfo(
          l10n.freeTime,
          colorScheme.primary,
          Icons.wb_sunny_outlined,
        );
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80.sp,
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
          AtharGap.lg,
          Text(
            l10n.dayClearIdeal,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
          ),
          Text(
            l10n.noTasksPending,
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _ZoneInfo {
  final String label;
  final Color color;
  final IconData icon;
  _ZoneInfo(this.label, this.color, this.icon);
}

// ————-————— code end ————————-
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
// import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
// import 'package:athar/features/task/domain/models/filter_item.dart';
// import 'package:athar/features/task/presentation/widgets/reflection_dialog.dart';
// import 'package:athar/core/design_system/molecules/tiles/unified_timeline_tile.dart';
// import 'package:athar/core/design_system/molecules/bars/filter_bar.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/home/presentation/cubit/timeline_cubit.dart';
// import 'package:athar/features/home/domain/entities/daily_item.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import 'package:athar/features/health/data/models/medicine_model.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:athar/features/task/presentation/cubit/task_state.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/features/task/presentation/widgets/app_drawer.dart';
// import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
// import 'package:athar/features/task/presentation/widgets/unified_add_sheet.dart';
// import 'package:athar/features/task/presentation/widgets/bulk_actions_bar.dart';
// import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
// import 'package:athar/features/prayer/presentation/cubit/prayer_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class UnifiedTasksPage extends StatelessWidget {
//   const UnifiedTasksPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => getIt<TimelineCubit>()..loadGlobalTimeline(),
//         ),
//         BlocProvider(create: (context) => getIt<HealthCubit>()),
//         BlocProvider(create: (context) => getIt<TaskCubit>()),
//       ],
//       child: const UnifiedTasksView(),
//     );
//   }
// }

// class UnifiedTasksView extends StatefulWidget {
//   const UnifiedTasksView({super.key});

//   @override
//   State<UnifiedTasksView> createState() => _UnifiedTasksViewState();
// }

// class _UnifiedTasksViewState extends State<UnifiedTasksView> {
//   bool _isKanbanView = false;
//   bool _isSelectionMode = false; // ✅ وضع التحديد
//   final PageController _pageController = PageController(viewportFraction: 0.85);

//   void _onDeletePressed(BuildContext context, DailyItem item) {
//     final messenger = ScaffoldMessenger.of(context);
//     final taskCubit = context.read<TaskCubit>();
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     if (item.type == DailyItemType.task) {
//       final task = item.originalData as TaskModel;
//       taskCubit.deleteTask(task.id);

//       AtharSnackbar.showWithMessenger(
//         messenger: messenger,
//         message: l10n.deletedItem(item.title),
//         colors: colors,
//         variant: AtharSnackbarVariant.info,
//         icon: Icons.delete_outline_rounded,
//         actionLabel: l10n.undo,
//         onAction: () => taskCubit.undoDelete(),
//         clearPrevious: true,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);
//     final taskCubit = context.watch<TaskCubit>();
//     final selectedCount = taskCubit.selectedTaskIds.length;

//     return Scaffold(
//       backgroundColor: colors.scaffoldBackground,
//       drawer: const AppDrawer(),
//       appBar: AtharAppBar(
//         title: l10n.unifiedOpsCenter,
//         subtitle: l10n.allInOnePlace,
//         leading: Builder(
//           builder: (context) => AtharButton.icon(
//             icon: Icons.menu,
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         actions: [
//           // ✅ زر وضع التحديد
//           AtharButton.icon(
//             icon: _isSelectionMode ? Icons.close : Icons.checklist,
//             onPressed: () {
//               setState(() {
//                 _isSelectionMode = !_isSelectionMode;
//                 if (!_isSelectionMode) {
//                   taskCubit.clearSelection();
//                 }
//               });
//             },
//           ),
//         ],
//       ),
//       body: BlocListener<TaskCubit, TaskState>(
//         listener: (context, state) {
//           if (state is TaskError && state.message == "PERMISSION_DENIED") {
//             AtharSnackbar.error(
//               context: context,
//               message: l10n.noPermissionEdit,
//             );
//           }
//         },
//         child: Column(
//           children: [
//             const SmartPrayerCardWrapper(pageType: PageType.tasks),

//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//               child: Row(
//                 children: [
//                   Expanded(child: _buildSmartZoneBanner()),
//                   AtharGap.hSm,
//                   _buildViewToggle(),
//                 ],
//               ),
//             ),

//             _buildUnifiedFilterBar(context),

//             Expanded(
//               child: BlocBuilder<TimelineCubit, TimelineState>(
//                 builder: (context, state) {
//                   if (state is TimelineLoading) {
//                     return const AtharLoading.centered();
//                   } else if (state is TimelineLoaded) {
//                     if (state.items.isEmpty) return _buildEmptyState(context);

//                     return _isKanbanView
//                         ? _buildUnifiedKanbanView(context, state.items)
//                         : _buildListView(state.items);
//                   } else if (state is TimelineError) {
//                     return Center(child: Text(state.message));
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),

//             // ✅ شريط العمليات الجماعية
//             if (_isSelectionMode && selectedCount > 0)
//               BulkActionsBar(
//                 selectedCount: selectedCount,
//                 onCancel: () {
//                   setState(() => _isSelectionMode = false);
//                   taskCubit.clearSelection();
//                 },
//                 onCompleteAll: () async {
//                   await taskCubit.completeSelectedTasks();
//                   setState(() => _isSelectionMode = false);
//                 },
//                 onDeleteAll: () async {
//                   await taskCubit.deleteSelectedTasks();
//                   setState(() => _isSelectionMode = false);
//                 },
//                 onPostponeAll: () => _showPostponeDialog(context),
//                 onAssignAll: () => _showAssignDialog(context),
//               ),
//           ],
//         ),
//       ),
//       floatingActionButton: _isSelectionMode
//           ? null
//           : FloatingActionButton.extended(
//               heroTag: 'unified_tasks_fab',
//               backgroundColor: colors.primary,
//               icon: Icon(Icons.add, color: colors.surface),
//               label: Text(
//                 l10n.newTask,
//                 style: TextStyle(color: colors.surface),
//               ),
//               onPressed: () => _showAddTaskSheet(context),
//             ),
//     );
//   }

//   Widget _buildListView(List<DailyItem> items) {
//     return RefreshIndicator(
//       onRefresh: () async => context.read<TimelineCubit>().loadGlobalTimeline(),
//       child: ListView.builder(
//         padding: EdgeInsets.only(bottom: 80.h),
//         itemCount: items.length,
//         itemBuilder: (context, index) {
//           final item = items[index];
//           final taskCubit = context.read<TaskCubit>();

//           // ✅ للمهام فقط: عرض Checkbox في وضع التحديد
//           if (_isSelectionMode && item.type == DailyItemType.task) {
//             final task = item.originalData as TaskModel;
//             final isSelected = taskCubit.selectedTaskIds.contains(task.id);

//             return CheckboxListTile(
//               value: isSelected,
//               onChanged: (val) {
//                 taskCubit.toggleTaskSelection(task.id);
//               },
//               title: UnifiedTimelineTile(
//                 item: item,
//                 onToggle: () => _handleToggle(context, item),
//                 onDelete: () => _onDeletePressed(context, item),
//                 onTap: () => _handleDetails(context, item),
//               ),
//               controlAffinity: ListTileControlAffinity.leading,
//             );
//           }

//           return UnifiedTimelineTile(
//             item: item,
//             onToggle: () => _handleToggle(context, item),
//             onDelete: () => _onDeletePressed(context, item),
//             onTap: () => _handleDetails(context, item),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildUnifiedFilterBar(BuildContext context) {
//     final colors = context.colors;

//     return BlocBuilder<TimelineCubit, TimelineState>(
//       builder: (context, state) {
//         if (state is TimelineLoaded) {
//           final List<FilterItem> availableFilters = [
//             FixedFilterType.all,
//             FixedFilterType.urgent,
//           ];

//           return Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//             child: FilterBar<FilterItem>(
//               items: availableFilters,
//               selectedItem: state.activeFilter == 'urgent'
//                   ? FixedFilterType.urgent
//                   : FixedFilterType.all,
//               onSelected: (filter) {
//                 String filterValue = filter == FixedFilterType.urgent
//                     ? 'urgent'
//                     : 'all';
//                 context.read<TimelineCubit>().setFilter(filterValue);
//               },
//               labelBuilder: (f) => f.label
//                   .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '')
//                   .trim(),
//               iconBuilder: (f) => f == FixedFilterType.all
//                   ? Icons.grid_view_rounded
//                   : Icons.local_fire_department_rounded,
//               colorBuilder: (f) =>
//                   f == FixedFilterType.urgent ? colors.error : colors.primary,
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildUnifiedKanbanView(BuildContext context, List<DailyItem> items) {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);
//     final todo = items.where((i) => !i.isCompleted).toList();
//     final done = items.where((i) => i.isCompleted).toList();

//     return PageView(
//       controller: _pageController,
//       children: [
//         _buildKanbanColumn(l10n.dueAndOperations, Colors.blue, todo, context),
//         _buildKanbanColumn(l10n.completedToday, colors.success, done, context),
//       ],
//     );
//   }

//   Widget _buildKanbanColumn(
//     String title,
//     Color color,
//     List<DailyItem> items,
//     BuildContext context,
//   ) {
//     final colors = context.colors;

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//       padding: AtharSpacing.allMd,
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: AtharRadii.radiusLg,
//         border: Border.all(color: colors.textTertiary.withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 12.w,
//                 height: 12.w,
//                 decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//               ),
//               AtharGap.hSm,
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
//               ),
//               const Spacer(),
//               Text(
//                 "${items.length}",
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.bold,
//                   color: colors.textTertiary,
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 24),
//           Expanded(
//             child: ListView.builder(
//               itemCount: items.length,
//               itemBuilder: (context, index) => UnifiedTimelineTile(
//                 item: items[index],
//                 onToggle: () => _handleToggle(context, items[index]),
//                 onDelete: () => _onDeletePressed(context, items[index]),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅ الدالة المصححة نهائياً - حل مشكلة BuildContext across async gaps
//   // ═══════════════════════════════════════════════════════════════════════════
//   void _handleToggle(BuildContext context, DailyItem item) {
//     if (item.type == DailyItemType.task) {
//       final task = item.originalData as TaskModel;

//       // ✅ 1. حفظ جميع الـ references قبل أي async operation
//       final taskCubit = context.read<TaskCubit>();
//       final celebrationCubit = context.read<CelebrationCubit>();

//       // ✅ 2. تنفيذ العمليات المتزامنة
//       if (!task.isCompleted) {
//         celebrationCubit.celebrate();
//       }

//       taskCubit.toggleTaskCompletion(task);

//       // ✅ 3. عرض dialog التأمل بعد الإكمال
//       if (!task.isCompleted) {
//         _showReflectionDialogDelayed(
//           taskTitle: task.title,
//           taskCubit: taskCubit,
//           task: task,
//         );
//       }
//     } else if (item.type == DailyItemType.medicine) {
//       final med = item.originalData as MedicineModel;
//       context.read<HealthCubit>().takeDose(med.moduleId, med);
//     }
//   }

//   // ✅ دالة منفصلة لعرض الـ Dialog بشكل آمن
//   void _showReflectionDialogDelayed({
//     required String taskTitle,
//     required TaskCubit taskCubit,
//     required TaskModel task,
//   }) {
//     Future.delayed(const Duration(milliseconds: 500), () {
//       // ✅ فحص mounted قبل أي شيء
//       if (!mounted) return;

//       // ✅ استخدام context بشكل آمن بعد mounted check
//       // ignore: use_build_context_synchronously
//       showDialog(
//         context: context,
//         builder: (dialogContext) => ReflectionDialog(
//           taskTitle: taskTitle,
//           onSave: (note) {
//             // ✅ استخدام الـ cubit المحفوظ مسبقاً (آمن 100%)
//             taskCubit.saveCompletionNote(task, note);
//           },
//         ),
//       );
//     });
//   }

//   void _handleDetails(BuildContext context, DailyItem item) {
//     if (item.type == DailyItemType.task) {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (ctx) => MultiBlocProvider(
//           providers: [
//             BlocProvider.value(value: context.read<TaskCubit>()),
//             BlocProvider.value(value: context.read<HealthCubit>()),
//             BlocProvider.value(value: context.read<CategoryCubit>()),
//             BlocProvider.value(value: context.read<SettingsCubit>()),
//             BlocProvider.value(value: context.read<PrayerCubit>()),
//           ],
//           child: UnifiedAddSheet(
//             initialType: EntityType.task,
//             itemToEdit: item.originalData,
//           ),
//         ),
//       );
//     }
//   }

//   void _showAddTaskSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => MultiBlocProvider(
//         providers: [
//           BlocProvider.value(value: context.read<TaskCubit>()),
//           BlocProvider.value(value: context.read<HealthCubit>()),
//           BlocProvider.value(value: context.read<CategoryCubit>()),
//           BlocProvider.value(value: context.read<SettingsCubit>()),
//           BlocProvider.value(value: context.read<PrayerCubit>()),
//         ],
//         child: const UnifiedAddSheet(initialType: EntityType.task),
//       ),
//     );
//   }

//   // ✅ حوار التأجيل
//   void _showPostponeDialog(BuildContext context) {
//     final l10n = AppLocalizations.of(context);

//     AtharDialog.show(
//       context: context,
//       title: l10n.postponeSelectedTasks,
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.today),
//             title: Text(l10n.tomorrow),
//             onTap: () {
//               Navigator.pop(context);
//               context.read<TaskCubit>().postponeSelectedTasks(
//                 const Duration(days: 1),
//               );
//               setState(() => _isSelectionMode = false);
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.date_range),
//             title: Text(l10n.afterOneWeek),
//             onTap: () {
//               Navigator.pop(context);
//               context.read<TaskCubit>().postponeSelectedTasks(
//                 const Duration(days: 7),
//               );
//               setState(() => _isSelectionMode = false);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ حوار الإسناد
//   void _showAssignDialog(BuildContext context) {
//     final l10n = AppLocalizations.of(context);

//     AtharDialog.alert(
//       context: context,
//       title: l10n.assignSelectedTasks,
//       message: l10n.featureUnderDevelopment,
//     );
//   }

//   Widget _buildViewToggle() {
//     final colors = context.colors;

//     return Container(
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: AtharRadii.radiusMd,
//         border: Border.all(color: colors.textTertiary.withOpacity(0.2)),
//       ),
//       child: IconButton(
//         icon: Icon(
//           _isKanbanView ? Icons.view_list_rounded : Icons.view_kanban_rounded,
//           color: colors.primary,
//         ),
//         onPressed: () => setState(() => _isKanbanView = !_isKanbanView),
//       ),
//     );
//   }

//   Widget _buildSmartZoneBanner() {
//     return BlocBuilder<TimelineCubit, TimelineState>(
//       builder: (context, state) {
//         if (state is TimelineLoaded) {
//           final info = _getZoneInfo(state.activeZone);
//           return Container(
//             padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
//             decoration: BoxDecoration(
//               color: info.color.withOpacity(0.1),
//               borderRadius: AtharRadii.radiusSm,
//             ),
//             child: Row(
//               children: [
//                 Icon(info.icon, size: 14.sp, color: info.color),
//                 AtharGap.hSm,
//                 Text(
//                   info.label,
//                   style: TextStyle(
//                     color: info.color,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 11.sp,
//                     fontFamily: 'Tajawal',
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   _ZoneInfo _getZoneInfo(String zone) {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     switch (zone) {
//       case 'work':
//         return _ZoneInfo(l10n.workZone, Colors.blue, Icons.work_outline);
//       case 'home':
//         return _ZoneInfo(l10n.homeZone, Colors.orange, Icons.home_outlined);
//       case 'quiet':
//         return _ZoneInfo(l10n.quietZone, Colors.indigo, Icons.bedtime_outlined);
//       default:
//         return _ZoneInfo(
//           l10n.freeTime,
//           colors.primary,
//           Icons.wb_sunny_outlined,
//         );
//     }
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.task_alt,
//             size: 80.sp,
//             color: colors.textTertiary.withOpacity(0.3),
//           ),
//           AtharGap.lg,
//           Text(
//             l10n.dayClearIdeal,
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//               color: colors.textTertiary,
//               fontFamily: 'Tajawal',
//             ),
//           ),
//           Text(
//             l10n.noTasksPending,
//             style: TextStyle(color: colors.textTertiary),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ZoneInfo {
//   final String label;
//   final Color color;
//   final IconData icon;
//   _ZoneInfo(this.label, this.color, this.icon);
// }
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
// import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
// import 'package:athar/features/task/domain/models/filter_item.dart';
// import 'package:athar/features/task/presentation/widgets/reflection_dialog.dart';
// import 'package:athar/core/design_system/molecules/tiles/unified_timeline_tile.dart';
// import 'package:athar/core/design_system/molecules/bars/filter_bar.dart';
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/home/presentation/cubit/timeline_cubit.dart';
// import 'package:athar/features/home/domain/entities/daily_item.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import 'package:athar/features/health/data/models/medicine_model.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:athar/features/task/presentation/cubit/task_state.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/features/task/presentation/widgets/app_drawer.dart';
// import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
// import 'package:athar/features/task/presentation/widgets/unified_add_sheet.dart';
// import 'package:athar/features/task/presentation/widgets/bulk_actions_bar.dart';
// import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
// import 'package:athar/features/prayer/presentation/cubit/prayer_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class UnifiedTasksPage extends StatelessWidget {
//   const UnifiedTasksPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(
//           create: (context) => getIt<TimelineCubit>()..loadGlobalTimeline(),
//         ),
//         BlocProvider(create: (context) => getIt<HealthCubit>()),
//         BlocProvider(create: (context) => getIt<TaskCubit>()),
//       ],
//       child: const UnifiedTasksView(),
//     );
//   }
// }

// class UnifiedTasksView extends StatefulWidget {
//   const UnifiedTasksView({super.key});

//   @override
//   State<UnifiedTasksView> createState() => _UnifiedTasksViewState();
// }

// class _UnifiedTasksViewState extends State<UnifiedTasksView> {
//   bool _isKanbanView = false;
//   bool _isSelectionMode = false; // ✅ وضع التحديد
//   final PageController _pageController = PageController(viewportFraction: 0.85);

//   void _onDeletePressed(BuildContext context, DailyItem item) {
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     final taskCubit = context.read<TaskCubit>();

//     if (item.type == DailyItemType.task) {
//       final task = item.originalData as TaskModel;
//       taskCubit.deleteTask(task.id);

//       scaffoldMessenger.clearSnackBars();
//       scaffoldMessenger.showSnackBar(
//         SnackBar(
//           duration: const Duration(seconds: 3),
//           backgroundColor: const Color(0xFF1E293B),
//           behavior: SnackBarBehavior.floating,
//           margin: EdgeInsets.all(16.w),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           content: Row(
//             children: [
//               const Icon(Icons.delete_outline_rounded, color: Colors.white70),
//               SizedBox(width: 12.w),
//               Text(
//                 "تم حذف: ${item.title}",
//                 style: const TextStyle(
//                   fontFamily: 'Tajawal',
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           action: SnackBarAction(
//             label: "تراجع",
//             textColor: AppColors.primary,
//             onPressed: () {
//               scaffoldMessenger.hideCurrentSnackBar();
//               taskCubit.undoDelete();
//             },
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final taskCubit = context.watch<TaskCubit>();
//     final selectedCount = taskCubit.selectedTaskIds.length;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       drawer: const AppDrawer(),
//       appBar: AtharAppBar(
//         title: "مركز العمليات الموحد",
//         subtitle: "كل ما يهمك في مكان واحد",
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.menu, color: AppColors.textPrimary),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         actions: [
//           // ✅ زر وضع التحديد
//           IconButton(
//             icon: Icon(
//               _isSelectionMode ? Icons.close : Icons.checklist,
//               color: AppColors.textPrimary,
//             ),
//             onPressed: () {
//               setState(() {
//                 _isSelectionMode = !_isSelectionMode;
//                 if (!_isSelectionMode) {
//                   taskCubit.clearSelection();
//                 }
//               });
//             },
//           ),
//         ],
//       ),
//       body: BlocListener<TaskCubit, TaskState>(
//         listener: (context, state) {
//           if (state is TaskError && state.message == "PERMISSION_DENIED") {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Row(
//                   children: [
//                     const Icon(Icons.lock_outline, color: Colors.white),
//                     SizedBox(width: 10.w),
//                     const Text("عذراً، لا تملك صلاحية تعديل هذا العنصر"),
//                   ],
//                 ),
//                 backgroundColor: Colors.red.shade800,
//                 behavior: SnackBarBehavior.floating,
//               ),
//             );
//           }
//         },
//         child: Column(
//           children: [
//             const SmartPrayerCardWrapper(pageType: PageType.tasks),

//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//               child: Row(
//                 children: [
//                   Expanded(child: _buildSmartZoneBanner()),
//                   SizedBox(width: 8.w),
//                   _buildViewToggle(),
//                 ],
//               ),
//             ),

//             _buildUnifiedFilterBar(context),

//             Expanded(
//               child: BlocBuilder<TimelineCubit, TimelineState>(
//                 builder: (context, state) {
//                   if (state is TimelineLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (state is TimelineLoaded) {
//                     if (state.items.isEmpty) return _buildEmptyState(context);

//                     return _isKanbanView
//                         ? _buildUnifiedKanbanView(context, state.items)
//                         : _buildListView(state.items);
//                   } else if (state is TimelineError) {
//                     return Center(child: Text(state.message));
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),

//             // ✅ شريط العمليات الجماعية
//             if (_isSelectionMode && selectedCount > 0)
//               BulkActionsBar(
//                 selectedCount: selectedCount,
//                 onCancel: () {
//                   setState(() => _isSelectionMode = false);
//                   taskCubit.clearSelection();
//                 },
//                 onCompleteAll: () async {
//                   await taskCubit.completeSelectedTasks();
//                   setState(() => _isSelectionMode = false);
//                 },
//                 onDeleteAll: () async {
//                   await taskCubit.deleteSelectedTasks();
//                   setState(() => _isSelectionMode = false);
//                 },
//                 onPostponeAll: () => _showPostponeDialog(context),
//                 onAssignAll: () => _showAssignDialog(context),
//               ),
//           ],
//         ),
//       ),
//       floatingActionButton: _isSelectionMode
//           ? null
//           : FloatingActionButton.extended(
//               heroTag: 'unified_tasks_fab',
//               backgroundColor: AppColors.primary,
//               icon: const Icon(Icons.add, color: Colors.white),
//               label: const Text(
//                 "مهمة جديدة",
//                 style: TextStyle(color: Colors.white),
//               ),
//               onPressed: () => _showAddTaskSheet(context),
//             ),
//     );
//   }

//   Widget _buildListView(List<DailyItem> items) {
//     return RefreshIndicator(
//       onRefresh: () async => context.read<TimelineCubit>().loadGlobalTimeline(),
//       child: ListView.builder(
//         padding: EdgeInsets.only(bottom: 80.h),
//         itemCount: items.length,
//         itemBuilder: (context, index) {
//           final item = items[index];
//           final taskCubit = context.read<TaskCubit>();

//           // ✅ للمهام فقط: عرض Checkbox في وضع التحديد
//           if (_isSelectionMode && item.type == DailyItemType.task) {
//             final task = item.originalData as TaskModel;
//             final isSelected = taskCubit.selectedTaskIds.contains(task.id);

//             return CheckboxListTile(
//               value: isSelected,
//               onChanged: (val) {
//                 taskCubit.toggleTaskSelection(task.id);
//               },
//               title: UnifiedTimelineTile(
//                 item: item,
//                 onToggle: () => _handleToggle(context, item),
//                 onDelete: () => _onDeletePressed(context, item),
//                 onTap: () => _handleDetails(context, item),
//               ),
//               controlAffinity: ListTileControlAffinity.leading,
//             );
//           }

//           return UnifiedTimelineTile(
//             item: item,
//             onToggle: () => _handleToggle(context, item),
//             onDelete: () => _onDeletePressed(context, item),
//             onTap: () => _handleDetails(context, item),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildUnifiedFilterBar(BuildContext context) {
//     return BlocBuilder<TimelineCubit, TimelineState>(
//       builder: (context, state) {
//         if (state is TimelineLoaded) {
//           final List<FilterItem> availableFilters = [
//             FixedFilterType.all,
//             FixedFilterType.urgent,
//           ];

//           return Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//             child: FilterBar<FilterItem>(
//               items: availableFilters,
//               selectedItem: state.activeFilter == 'urgent'
//                   ? FixedFilterType.urgent
//                   : FixedFilterType.all,
//               onSelected: (filter) {
//                 String filterValue = filter == FixedFilterType.urgent
//                     ? 'urgent'
//                     : 'all';
//                 context.read<TimelineCubit>().setFilter(filterValue);
//               },
//               labelBuilder: (f) => f.label
//                   .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '')
//                   .trim(),
//               iconBuilder: (f) => f == FixedFilterType.all
//                   ? Icons.grid_view_rounded
//                   : Icons.local_fire_department_rounded,
//               colorBuilder: (f) => f == FixedFilterType.urgent
//                   ? AppColors.urgent
//                   : AppColors.primary,
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   Widget _buildUnifiedKanbanView(BuildContext context, List<DailyItem> items) {
//     final todo = items.where((i) => !i.isCompleted).toList();
//     final done = items.where((i) => i.isCompleted).toList();

//     return PageView(
//       controller: _pageController,
//       children: [
//         _buildKanbanColumn("المستحق والعمليات", Colors.blue, todo, context),
//         _buildKanbanColumn("المكتمل اليوم", Colors.green, done, context),
//       ],
//     );
//   }

//   Widget _buildKanbanColumn(
//     String title,
//     Color color,
//     List<DailyItem> items,
//     BuildContext context,
//   ) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 12.w,
//                 height: 12.w,
//                 decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//               ),
//               SizedBox(width: 8.w),
//               Text(
//                 title,
//                 style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
//               ),
//               const Spacer(),
//               Text(
//                 "${items.length}",
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 24),
//           Expanded(
//             child: ListView.builder(
//               itemCount: items.length,
//               itemBuilder: (context, index) => UnifiedTimelineTile(
//                 item: items[index],
//                 onToggle: () => _handleToggle(context, items[index]),
//                 onDelete: () => _onDeletePressed(context, items[index]),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅ الدالة المصححة نهائياً - حل مشكلة BuildContext across async gaps
//   // ═══════════════════════════════════════════════════════════════════════════
//   void _handleToggle(BuildContext context, DailyItem item) {
//     if (item.type == DailyItemType.task) {
//       final task = item.originalData as TaskModel;

//       // ✅ 1. حفظ جميع الـ references قبل أي async operation
//       final taskCubit = context.read<TaskCubit>();
//       final celebrationCubit = context.read<CelebrationCubit>();

//       // ✅ 2. تنفيذ العمليات المتزامنة
//       if (!task.isCompleted) {
//         celebrationCubit.celebrate();
//       }

//       taskCubit.toggleTaskCompletion(task);

//       // ✅ 3. عرض dialog التأمل بعد الإكمال
//       if (!task.isCompleted) {
//         _showReflectionDialogDelayed(
//           taskTitle: task.title,
//           taskCubit: taskCubit,
//           task: task,
//         );
//       }
//     } else if (item.type == DailyItemType.medicine) {
//       final med = item.originalData as MedicineModel;
//       context.read<HealthCubit>().takeDose(med.moduleId, med);
//     }
//   }

//   // ✅ دالة منفصلة لعرض الـ Dialog بشكل آمن
//   void _showReflectionDialogDelayed({
//     required String taskTitle,
//     required TaskCubit taskCubit,
//     required TaskModel task,
//   }) {
//     Future.delayed(const Duration(milliseconds: 500), () {
//       // ✅ فحص mounted قبل أي شيء
//       if (!mounted) return;

//       // ✅ استخدام context بشكل آمن بعد mounted check
//       // ignore: use_build_context_synchronously
//       showDialog(
//         context: context,
//         builder: (dialogContext) => ReflectionDialog(
//           taskTitle: taskTitle,
//           onSave: (note) {
//             // ✅ استخدام الـ cubit المحفوظ مسبقاً (آمن 100%)
//             taskCubit.saveCompletionNote(task, note);
//           },
//         ),
//       );
//     });
//   }

//   void _handleDetails(BuildContext context, DailyItem item) {
//     if (item.type == DailyItemType.task) {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (ctx) => MultiBlocProvider(
//           providers: [
//             BlocProvider.value(value: context.read<TaskCubit>()),
//             BlocProvider.value(value: context.read<HealthCubit>()),
//             BlocProvider.value(value: context.read<CategoryCubit>()),
//             BlocProvider.value(value: context.read<SettingsCubit>()),
//             BlocProvider.value(value: context.read<PrayerCubit>()),
//           ],
//           child: UnifiedAddSheet(
//             initialType: EntityType.task,
//             itemToEdit: item.originalData,
//           ),
//         ),
//       );
//     }
//   }

//   void _showAddTaskSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => MultiBlocProvider(
//         providers: [
//           BlocProvider.value(value: context.read<TaskCubit>()),
//           BlocProvider.value(value: context.read<HealthCubit>()),
//           BlocProvider.value(value: context.read<CategoryCubit>()),
//           BlocProvider.value(value: context.read<SettingsCubit>()),
//           BlocProvider.value(value: context.read<PrayerCubit>()),
//         ],
//         child: const UnifiedAddSheet(initialType: EntityType.task),
//       ),
//     );
//   }

//   // ✅ حوار التأجيل
//   void _showPostponeDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("تأجيل المهام المحددة"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.today),
//               title: const Text("غداً"),
//               onTap: () {
//                 Navigator.pop(ctx);
//                 context.read<TaskCubit>().postponeSelectedTasks(
//                   const Duration(days: 1),
//                 );
//                 setState(() => _isSelectionMode = false);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.date_range),
//               title: const Text("بعد أسبوع"),
//               onTap: () {
//                 Navigator.pop(ctx);
//                 context.read<TaskCubit>().postponeSelectedTasks(
//                   const Duration(days: 7),
//                 );
//                 setState(() => _isSelectionMode = false);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ حوار الإسناد
//   void _showAssignDialog(BuildContext context) {
//     // يمكن فتح MemberSelectorSheet هنا
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("إسناد المهام المحددة"),
//         content: const Text("الميزة قيد التطوير"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("إغلاق"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildViewToggle() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: IconButton(
//         icon: Icon(
//           _isKanbanView ? Icons.view_list_rounded : Icons.view_kanban_rounded,
//           color: AppColors.primary,
//         ),
//         onPressed: () => setState(() => _isKanbanView = !_isKanbanView),
//       ),
//     );
//   }

//   Widget _buildSmartZoneBanner() {
//     return BlocBuilder<TimelineCubit, TimelineState>(
//       builder: (context, state) {
//         if (state is TimelineLoaded) {
//           final info = _getZoneInfo(state.activeZone);
//           return Container(
//             padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
//             decoration: BoxDecoration(
//               color: info.color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             child: Row(
//               children: [
//                 Icon(info.icon, size: 14.sp, color: info.color),
//                 SizedBox(width: 8.w),
//                 Text(
//                   info.label,
//                   style: TextStyle(
//                     color: info.color,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 11.sp,
//                     fontFamily: 'Tajawal',
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }

//   _ZoneInfo _getZoneInfo(String zone) {
//     switch (zone) {
//       case 'work':
//         return _ZoneInfo("منطقة العمل", Colors.blue, Icons.work_outline);
//       case 'home':
//         return _ZoneInfo("وقت المنزل", Colors.orange, Icons.home_outlined);
//       case 'quiet':
//         return _ZoneInfo("وقت الهدوء", Colors.indigo, Icons.bedtime_outlined);
//       default:
//         return _ZoneInfo(
//           "وقتك الحر",
//           AppColors.primary,
//           Icons.wb_sunny_outlined,
//         );
//     }
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.task_alt, size: 80.sp, color: Colors.grey.shade300),
//           SizedBox(height: 16.h),
//           Text(
//             "يومك صافي ومثالي!",
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//               color: Colors.grey,
//               fontFamily: 'Tajawal',
//             ),
//           ),
//           const Text(
//             "لا يوجد مهام أو عمليات معلقة حالياً",
//             style: TextStyle(color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ZoneInfo {
//   final String label;
//   final Color color;
//   final IconData icon;
//   _ZoneInfo(this.label, this.color, this.icon);
// }
