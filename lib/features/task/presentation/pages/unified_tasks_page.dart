import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/widgets/athar_dialog.dart';
import 'package:athar/core/design_system/widgets/athar_feedback.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
import 'package:athar/features/calendar/presentation/pages/calendar_page.dart';
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
  bool _isSelectionMode = false;
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
        onTitleTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CalendarPage()),
          );
        },
        titleTapIcon: Icons.calendar_month_rounded,
        leading: Builder(
          builder: (context) => AtharButton.icon(
            icon: Icons.menu,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          AtharButton.icon(
            icon: _isSelectionMode ? Icons.close : Icons.checklist,
            onPressed: () {
              setState(() {
                _isSelectionMode = !_isSelectionMode;
                if (!_isSelectionMode) taskCubit.clearSelection();
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
                    return _buildErrorState(context, state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

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
      floatingActionButton: null,
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

          if (_isSelectionMode && item.type == DailyItemType.task) {
            final task = item.originalData as TaskModel;
            final isSelected = taskCubit.selectedTaskIds.contains(task.id);

            return CheckboxListTile(
              value: isSelected,
              onChanged: (val) => taskCubit.toggleTaskSelection(task.id),
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

    const filters = [
      FixedFilterType.all,
      FixedFilterType.task,
      FixedFilterType.urgent,
      FixedFilterType.medicine,
      FixedFilterType.appointment,
    ];

    const filterValues = {
      FixedFilterType.all: 'all',
      FixedFilterType.task: 'task',
      FixedFilterType.urgent: 'urgent',
      FixedFilterType.medicine: 'medicine',
      FixedFilterType.appointment: 'appointment',
    };

    const filterIcons = {
      FixedFilterType.all: Icons.apps_rounded,
      FixedFilterType.task: Icons.check_circle_outline_rounded,
      FixedFilterType.urgent: Icons.local_fire_department_rounded,
      FixedFilterType.medicine: Icons.medication_rounded,
      FixedFilterType.appointment: Icons.event_note_rounded,
    };

    return BlocBuilder<TimelineCubit, TimelineState>(
      builder: (context, state) {
        if (state is! TimelineLoaded) return const SizedBox.shrink();

        final selectedFilter = filters.firstWhere(
          (f) => filterValues[f] == state.activeFilter,
          orElse: () => FixedFilterType.all,
        );

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: FilterBar<FilterItem>(
            items: filters,
            selectedItem: selectedFilter,
            onSelected: (filter) {
              context
                  .read<TimelineCubit>()
                  .setFilter(filterValues[filter as FixedFilterType] ?? 'all');
            },
            labelBuilder: (f) => f.label,
            iconBuilder: (f) =>
                filterIcons[f as FixedFilterType] ?? Icons.apps_rounded,
            colorBuilder: (f) {
              if (f == FixedFilterType.urgent) return colorScheme.error;
              if (f == FixedFilterType.medicine) return const Color(0xFF009688);
              if (f == FixedFilterType.appointment) return colorScheme.tertiary;
              return colorScheme.primary;
            },
          ),
        );
      },
    );
  }

  Widget _buildUnifiedKanbanView(BuildContext context, List<DailyItem> items) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final todo = items.where((i) => !i.isCompleted).toList();
    final done = items.where((i) => i.isCompleted).toList();

    return PageView(
      controller: _pageController,
      children: [
        _buildKanbanColumn(l10n.dueAndOperations, colorScheme.primary, todo, context),
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

  void _handleToggle(BuildContext context, DailyItem item) {
    if (item.type == DailyItemType.task) {
      final task = item.originalData as TaskModel;
      final taskCubit = context.read<TaskCubit>();
      final celebrationCubit = context.read<CelebrationCubit>();

      if (!task.isCompleted) celebrationCubit.celebrate();
      taskCubit.toggleTaskCompletion(task);

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

  void _showReflectionDialogDelayed({
    required String taskTitle,
    required TaskCubit taskCubit,
    required TaskModel task,
  }) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (dialogContext) => ReflectionDialog(
          taskTitle: taskTitle,
          onSave: (note) => taskCubit.saveCompletionNote(task, note),
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
              context.read<TaskCubit>().postponeSelectedTasks(const Duration(days: 1));
              setState(() => _isSelectionMode = false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.date_range),
            title: Text(l10n.afterOneWeek),
            onTap: () {
              Navigator.pop(context);
              context.read<TaskCubit>().postponeSelectedTasks(const Duration(days: 7));
              setState(() => _isSelectionMode = false);
            },
          ),
        ],
      ),
    );
  }

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
                    fontSize: 12.sp,
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
        return _ZoneInfo(l10n.freeTime, colorScheme.primary, Icons.wb_sunny_outlined);
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
            size: 72.sp,
            color: colorScheme.primary.withValues(alpha: 0.25),
          ),
          AtharGap.lg,
          Text(
            l10n.dayClearIdeal,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          AtharGap.sm,
          Text(
            l10n.noTasksPending,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56.sp,
              color: colorScheme.error.withValues(alpha: 0.6),
            ),
            AtharGap.lg,
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            AtharGap.lg,
            AtharButton(
              label: 'إعادة المحاولة',
              variant: AtharButtonVariant.secondary,
              onPressed: () =>
                  context.read<TimelineCubit>().loadGlobalTimeline(),
            ),
          ],
        ),
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
