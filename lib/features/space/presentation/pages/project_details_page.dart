import 'package:athar/core/di/injection.dart';
import 'package:athar/core/iam/permission_service.dart';
import 'package:athar/features/space/domain/repositories/space_repository.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:athar/features/task/presentation/cubit/task_state.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/core/design_system/molecules/tiles/task_tile.dart';
import 'package:athar/core/design_system/molecules/board/kanban_board.dart';
import '../../data/models/module_model.dart';
import '../../../task/presentation/widgets/add_task_sheet.dart';
import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
import 'package:athar/features/task/presentation/pages/task_details_page.dart';

/// Semantic colors (not in ColorScheme)
const _successColor = Color(0xFF00B894);

class ProjectDetailsPage extends StatefulWidget {
  final ModuleModel module;

  const ProjectDetailsPage({super.key, required this.module});

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late ModuleModel _module;
  bool _isKanbanView = false;
  bool _isExpanded = false;
  TaskSortMode _sortMode = TaskSortMode.manual;

  late Future<bool> _canEditFuture;
  late Future<bool> _canCreateTaskFuture;

  @override
  void initState() {
    super.initState();
    _module = widget.module;
    context.read<TaskCubit>().watchModuleTasks(_module.uuid);

    final permissionService = getIt<PermissionService>();
    _canEditFuture = permissionService.canEdit(
      'project',
      spaceId: _module.spaceId,
      module: _module,
      resourceOwnerId: _module.creatorId,
    );
    _canCreateTaskFuture = permissionService.hasPermission(
      'create',
      spaceId: _module.spaceId,
      resourceType: 'task',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme, l10n),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            final tasks = state.tasks;

            return Column(
              children: [
                _buildProjectDashboard(tasks, colorScheme, l10n),
                _buildFilterBar(tasks.length, colorScheme, l10n),
                SizedBox(height: 10.h),
                Expanded(
                  child: tasks.isEmpty
                      ? _buildEmptyState(colorScheme, l10n)
                      : _isKanbanView
                      ? KanbanBoard(
                          tasks: tasks,
                          onStatusChanged: (taskId, status) async {
                            final task = tasks.firstWhere(
                              (t) => t.id == taskId,
                            );
                            await context.read<TaskCubit>().updateTaskStatus(
                              task,
                              status,
                            );
                            if (status == TaskStatus.done &&
                                !task.isCompleted) {
                              if (context.mounted) {
                                context.read<CelebrationCubit>().celebrate();
                              }
                            }
                          },
                          onDelete: (task) => _confirmDelete(context, task),
                          onTaskTap: (task) =>
                              _navigateToTaskDetails(context, task),
                        )
                      : _buildReorderableList(tasks),
                ),
              ],
            );
          } else if (state is TaskError) {
            return Center(child: Text(l10n.projectDetailsError(state.message)));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: _canCreateTaskFuture,
        builder: (context, snapshot) {
          if (snapshot.data == true) {
            return FloatingActionButton.extended(
              onPressed: () => _openAddTaskSheet(),
              backgroundColor: colorScheme.primary,
              icon: Icon(Icons.add, color: colorScheme.surface),
              label: Text(
                l10n.projectDetailsNewTask,
                style: TextStyle(color: colorScheme.surface),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReorderableList(List<TaskModel> tasks) {
    return ReorderableListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
      itemCount: tasks.length,
      onReorder: (oldIndex, newIndex) {
        setState(() => _sortMode = TaskSortMode.manual);
        context.read<TaskCubit>().reorderTasks(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          key: ValueKey(task.uuid),
          margin: EdgeInsets.only(bottom: 12.h),
          child: TaskTile(
            task: task,
            onToggle: (val) {
              context.read<TaskCubit>().toggleTaskCompletion(task);
              if (!task.isCompleted) {
                context.read<CelebrationCubit>().celebrate();
              }
            },
            onDelete: () => _confirmDelete(context, task),
            onLongPress: () => _showEditSheet(context, task),
            enableSwipe: false,
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return AppBar(
      title: Text(
        _module.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: colorScheme.onSurface,
      actions: [
        IconButton(
          icon: Icon(
            _isKanbanView ? Icons.view_list_rounded : Icons.view_kanban_rounded,
          ),
          color: colorScheme.primary,
          tooltip: _isKanbanView
              ? l10n.projectDetailsViewList
              : l10n.projectDetailsViewBoard,
          onPressed: () => setState(() => _isKanbanView = !_isKanbanView),
        ),
        FutureBuilder<bool>(
          future: _canEditFuture,
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: l10n.projectDetailsSettings,
                onPressed: () => _showEditProjectDialog(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildFilterBar(
    int count,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Text(
            l10n.projectDetailsTaskCount(count),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: AtharRadii.radiusXl,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TaskSortMode>(
                value: _sortMode,
                isDense: true,
                icon: Icon(Icons.sort, size: 18.sp, color: colorScheme.primary),
                style: TextStyle(fontSize: 12.sp, color: colorScheme.onSurface),
                items: [
                  DropdownMenuItem(
                    value: TaskSortMode.manual,
                    child: Text(l10n.projectDetailsSortManual),
                  ),
                  DropdownMenuItem(
                    value: TaskSortMode.eisenhower,
                    child: Text(l10n.projectDetailsSortEisenhower),
                  ),
                  DropdownMenuItem(
                    value: TaskSortMode.time,
                    child: Text(l10n.projectDetailsSortTime),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _sortMode = val);
                    context.read<TaskCubit>().changeSortMode(val);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDashboard(
    List<TaskModel> tasks,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final total = tasks.length;
    final done = tasks
        .where((t) => t.isCompleted || t.status == TaskStatus.done)
        .length;
    final progress = total == 0 ? 0.0 : done / total;

    String? countdownText;
    Color countdownColor = colorScheme.outline;
    if (_module.endDate != null) {
      final diff = _module.endDate!.difference(DateTime.now());
      if (diff.isNegative) {
        countdownText = l10n.projectDetailsTimeExpired;
        countdownColor = colorScheme.error;
      } else {
        countdownText = l10n.projectDetailsDaysLeft(diff.inDays);
        countdownColor = diff.inDays <= 3 ? Colors.orange : colorScheme.primary;
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: AtharSpacing.allLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_module.description != null &&
              _module.description!.isNotEmpty) ...[
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _module.description!,
                    maxLines: _isExpanded ? 10 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!_isExpanded && _module.description!.length > 50)
                    Text(
                      l10n.projectDetailsShowMore,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12.sp,
                      ),
                    ),
                ],
              ),
            ),
            AtharGap.md,
          ],
          if (_module.startDate != null || _module.endDate != null)
            Row(
              children: [
                if (_module.startDate != null)
                  _buildDateChip(
                    Icons.calendar_today_rounded,
                    DateFormat('d MMM', 'ar').format(_module.startDate!),
                    colorScheme: colorScheme,
                  ),
                if (_module.startDate != null && _module.endDate != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 14.sp,
                      color: colorScheme.outline,
                    ),
                  ),
                if (_module.endDate != null)
                  _buildDateChip(
                    Icons.flag_rounded,
                    DateFormat('d MMM', 'ar').format(_module.endDate!),
                    isEnd: true,
                    colorScheme: colorScheme,
                  ),
                const Spacer(),
                if (countdownText != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: countdownColor.withValues(alpha: 0.1),
                      borderRadius: AtharRadii.radiusXl,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14.sp,
                          color: countdownColor,
                        ),
                        AtharGap.hXxs,
                        Text(
                          countdownText,
                          style: TextStyle(
                            color: countdownColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          AtharGap.lg,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.projectDetailsProgressLabel,
                style: TextStyle(fontSize: 12.sp, color: colorScheme.outline),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          AtharGap.xs,
          ClipRRect(
            borderRadius: AtharRadii.radiusXxs,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.outlineVariant,
              color: progress == 1.0 ? _successColor : colorScheme.primary,
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(
    IconData icon,
    String label, {
    bool isEnd = false,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14.sp,
          color: isEnd ? colorScheme.error : colorScheme.outline,
        ),
        AtharGap.hXxs,
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _showEditProjectDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController(text: _module.name);
    final descController = TextEditingController(text: _module.description);
    DateTime? tempStart = _module.startDate;
    DateTime? tempEnd = _module.endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (innerContext, setSheetState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              24.w,
              24.w,
              24.w,
              MediaQuery.of(innerContext).viewInsets.bottom + 24.w,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: AtharRadii.radiusXxxs,
                    ),
                  ),
                ),
                AtharGap.xxl,
                Text(
                  l10n.projectDetailsSettings,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                AtharGap.lg,
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: l10n.projectDetailsNameLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                AtharGap.md,
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.projectDetailsDescLabel,
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                AtharGap.lg,
                Row(
                  children: [
                    Expanded(
                      child: _buildDateSelector(
                        label: l10n.projectDetailsStartDate,
                        date: tempStart,
                        colorScheme: colorScheme,
                        l10n: l10n,
                        onTap: () async {
                          final d = await showDatePicker(
                            context: innerContext,
                            initialDate: tempStart ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (d != null) setSheetState(() => tempStart = d);
                        },
                      ),
                    ),
                    AtharGap.hMd,
                    Expanded(
                      child: _buildDateSelector(
                        label: l10n.projectDetailsEndDate,
                        date: tempEnd,
                        isError:
                            tempEnd != null &&
                            tempStart != null &&
                            tempEnd!.isBefore(tempStart!),
                        colorScheme: colorScheme,
                        l10n: l10n,
                        onTap: () async {
                          final d = await showDatePicker(
                            context: innerContext,
                            initialDate:
                                tempEnd ??
                                (tempStart?.add(const Duration(days: 7)) ??
                                    DateTime.now()),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (d != null) setSheetState(() => tempEnd = d);
                        },
                      ),
                    ),
                  ],
                ),
                AtharGap.xxl,
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(innerContext);

                      await getIt<SpaceRepository>().updateModule(
                        uuid: _module.uuid,
                        name: nameController.text,
                        description: descController.text,
                        startDate: tempStart,
                        endDate: tempEnd,
                      );

                      if (!mounted) return;

                      setState(() {
                        _module.name = nameController.text;
                        _module.description = descController.text;
                        _module.startDate = tempStart;
                        _module.endDate = tempEnd;
                      });

                      navigator.pop();

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(l10n.projectDetailsUpdateSuccess),
                          backgroundColor: _successColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    minimumSize: Size(double.infinity, 50.h),
                  ),
                  child: Text(
                    l10n.projectDetailsSaveChanges,
                    style: TextStyle(
                      color: colorScheme.surface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                AtharGap.lg,
                const Divider(),
                ListTile(
                  leading: Icon(
                    _module.status == 'archived'
                        ? Icons.unarchive
                        : Icons.archive,
                    color: _module.status == 'archived'
                        ? _successColor
                        : Colors.orange,
                  ),
                  title: Text(
                    _module.status == 'archived'
                        ? l10n.projectDetailsRestore
                        : l10n.projectDetailsArchive,
                  ),
                  subtitle: Text(
                    _module.status == 'archived'
                        ? l10n.projectDetailsRestoreDesc
                        : l10n.projectDetailsArchiveDesc,
                  ),
                  onTap: () async {
                    final newStatus = _module.status == 'archived'
                        ? 'active'
                        : 'archived';

                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final sheetNavigator = Navigator.of(innerContext);

                    await getIt<SpaceRepository>().updateModule(
                      uuid: _module.uuid,
                      status: newStatus,
                    );

                    if (!mounted) return;

                    setState(() => _module.status = newStatus);

                    sheetNavigator.pop();

                    if (newStatus == 'archived') {
                      navigator.pop();
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.projectDetailsArchived)),
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    DateTime? date,
    required VoidCallback onTap,
    bool isError = false,
    required ColorScheme colorScheme,
    required AppLocalizations l10n,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AtharRadii.radiusSm,
      child: Container(
        padding: AtharSpacing.allMd,
        decoration: BoxDecoration(
          border: Border.all(
            color: isError ? colorScheme.error : colorScheme.outlineVariant,
          ),
          borderRadius: AtharRadii.radiusSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: colorScheme.outline),
            ),
            AtharGap.xxs,
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14.sp,
                  color: isError ? colorScheme.error : colorScheme.primary,
                ),
                AtharGap.hSm,
                Text(
                  date != null
                      ? DateFormat('yyyy-MM-dd').format(date)
                      : l10n.projectDetailsNotSet,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: isError ? colorScheme.error : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, TaskModel task) async {
    final permissionService = getIt<PermissionService>();
    final l10n = AppLocalizations.of(context);

    final messenger = ScaffoldMessenger.of(context);
    final taskCubit = context.read<TaskCubit>();
    final isAdm = await _canEditFuture;

    final canDelete = permissionService.canDeleteTask(
      task: task,
      isSpaceAdmin: isAdm,
      isModuleAdmin: false,
    );

    if (!mounted) return;

    if (canDelete) {
      taskCubit.deleteTask(task.id);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.projectDetailsTaskDeleted)),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.projectDetailsNoDeletePermission)),
      );
    }
  }

  void _openAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTaskSheet(
        targetModuleId: _module.uuid,
        targetSpaceId: _module.spaceId,
      ),
    );
  }

  void _showEditSheet(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTaskSheet(
        taskToEdit: task,
        targetModuleId: _module.uuid,
        targetSpaceId: _module.spaceId,
      ),
    );
  }

  void _navigateToTaskDetails(BuildContext context, TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (innerCtx) => BlocProvider.value(
          value: context.read<TaskCubit>(),
          child: TaskDetailsPage(task: task),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rocket_launch_outlined,
            size: 60.sp,
            color: colorScheme.outlineVariant,
          ),
          AtharGap.lg,
          Text(
            l10n.projectDetailsEmptyState,
            style: TextStyle(fontSize: 16, color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
//----------------------------------------------------------------------
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/iam/permission_service.dart';
// import 'package:athar/features/space/domain/repositories/space_repository.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:athar/features/task/presentation/cubit/task_state.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/core/design_system/molecules/tiles/task_tile.dart';
// import 'package:athar/core/design_system/molecules/board/kanban_board.dart';
// import '../../data/models/module_model.dart';
// import '../../../task/presentation/widgets/add_task_sheet.dart';
// import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
// import 'package:athar/features/task/presentation/pages/task_details_page.dart';

// class ProjectDetailsPage extends StatefulWidget {
//   final ModuleModel module;

//   const ProjectDetailsPage({super.key, required this.module});

//   @override
//   State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
// }

// class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
//   late ModuleModel _module;
//   bool _isKanbanView = false;
//   bool _isExpanded = false;
//   TaskSortMode _sortMode = TaskSortMode.manual;

//   late Future<bool> _canEditFuture;
//   late Future<bool> _canCreateTaskFuture;

//   @override
//   void initState() {
//     super.initState();
//     _module = widget.module;
//     context.read<TaskCubit>().watchModuleTasks(_module.uuid);

//     final permissionService = getIt<PermissionService>();
//     _canEditFuture = permissionService.canEdit(
//       'project',
//       spaceId: _module.spaceId,
//       module: _module,
//       resourceOwnerId: _module.creatorId,
//     );
//     _canCreateTaskFuture = permissionService.hasPermission(
//       'create',
//       spaceId: _module.spaceId,
//       resourceType: 'task',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors =
//         Theme.of(context).extension<AtharColors>() ?? AtharColors.light;
//     final l10n = AppLocalizations.of(context);

//     return Scaffold(
//       backgroundColor: colors.surface,
//       appBar: _buildAppBar(colors, l10n),
//       body: BlocBuilder<TaskCubit, TaskState>(
//         builder: (context, state) {
//           if (state is TaskLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is TaskLoaded) {
//             final tasks = state.tasks;

//             return Column(
//               children: [
//                 _buildProjectDashboard(tasks, colors, l10n),
//                 _buildFilterBar(tasks.length, colors, l10n),
//                 SizedBox(height: 10.h),
//                 Expanded(
//                   child: tasks.isEmpty
//                       ? _buildEmptyState(colors, l10n)
//                       : _isKanbanView
//                       ? KanbanBoard(
//                           tasks: tasks,
//                           onStatusChanged: (taskId, status) async {
//                             final task = tasks.firstWhere(
//                               (t) => t.id == taskId,
//                             );
//                             await context.read<TaskCubit>().updateTaskStatus(
//                               task,
//                               status,
//                             );
//                             if (status == TaskStatus.done &&
//                                 !task.isCompleted) {
//                               if (context.mounted) {
//                                 context.read<CelebrationCubit>().celebrate();
//                               }
//                             }
//                           },
//                           onDelete: (task) => _confirmDelete(context, task),
//                           onTaskTap: (task) =>
//                               _navigateToTaskDetails(context, task),
//                         )
//                       : _buildReorderableList(tasks),
//                 ),
//               ],
//             );
//           } else if (state is TaskError) {
//             return Center(child: Text(l10n.projectDetailsError(state.message)));
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//       floatingActionButton: FutureBuilder<bool>(
//         future: _canCreateTaskFuture,
//         builder: (context, snapshot) {
//           if (snapshot.data == true) {
//             return FloatingActionButton.extended(
//               onPressed: () => _openAddTaskSheet(),
//               backgroundColor: colors.primary,
//               icon: Icon(Icons.add, color: colors.surface),
//               label: Text(
//                 l10n.projectDetailsNewTask,
//                 style: TextStyle(color: colors.surface, fontFamily: 'Tajawal'),
//               ),
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   Widget _buildReorderableList(List<TaskModel> tasks) {
//     return ReorderableListView.builder(
//       padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
//       itemCount: tasks.length,
//       onReorder: (oldIndex, newIndex) {
//         setState(() => _sortMode = TaskSortMode.manual);
//         context.read<TaskCubit>().reorderTasks(oldIndex, newIndex);
//       },
//       itemBuilder: (context, index) {
//         final task = tasks[index];
//         return Container(
//           key: ValueKey(task.uuid),
//           margin: EdgeInsets.only(bottom: 12.h),
//           child: TaskTile(
//             task: task,
//             onToggle: (val) {
//               context.read<TaskCubit>().toggleTaskCompletion(task);
//               if (!task.isCompleted) {
//                 context.read<CelebrationCubit>().celebrate();
//               }
//             },
//             onDelete: () => _confirmDelete(context, task),
//             onLongPress: () => _showEditSheet(context, task),
//             enableSwipe: false,
//           ),
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildAppBar(AtharColors colors, AppLocalizations l10n) {
//     return AppBar(
//       title: Text(
//         _module.name,
//         style: const TextStyle(
//           fontFamily: 'Tajawal',
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       centerTitle: true,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       foregroundColor: colors.textPrimary,
//       actions: [
//         IconButton(
//           icon: Icon(
//             _isKanbanView ? Icons.view_list_rounded : Icons.view_kanban_rounded,
//           ),
//           color: colors.primary,
//           tooltip: _isKanbanView
//               ? l10n.projectDetailsViewList
//               : l10n.projectDetailsViewBoard,
//           onPressed: () => setState(() => _isKanbanView = !_isKanbanView),
//         ),
//         FutureBuilder<bool>(
//           future: _canEditFuture,
//           builder: (context, snapshot) {
//             if (snapshot.data == true) {
//               return IconButton(
//                 icon: const Icon(Icons.settings_outlined),
//                 tooltip: l10n.projectDetailsSettings,
//                 onPressed: () => _showEditProjectDialog(),
//               );
//             }
//             return const SizedBox.shrink();
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildFilterBar(int count, AtharColors colors, AppLocalizations l10n) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       child: Row(
//         children: [
//           Text(
//             l10n.projectDetailsTaskCount(count),
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
//           ),
//           const Spacer(),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
//             decoration: BoxDecoration(
//               color: colors.surface,
//               borderRadius: BorderRadius.circular(20.r),
//               border: Border.all(color: colors.borderLight),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<TaskSortMode>(
//                 value: _sortMode,
//                 isDense: true,
//                 icon: Icon(Icons.sort, size: 18.sp, color: colors.primary),
//                 style: TextStyle(
//                   fontFamily: 'Tajawal',
//                   fontSize: 12.sp,
//                   color: colors.textPrimary,
//                 ),
//                 items: [
//                   DropdownMenuItem(
//                     value: TaskSortMode.manual,
//                     child: Text(l10n.projectDetailsSortManual),
//                   ),
//                   DropdownMenuItem(
//                     value: TaskSortMode.eisenhower,
//                     child: Text(l10n.projectDetailsSortEisenhower),
//                   ),
//                   DropdownMenuItem(
//                     value: TaskSortMode.time,
//                     child: Text(l10n.projectDetailsSortTime),
//                   ),
//                 ],
//                 onChanged: (val) {
//                   if (val != null) {
//                     setState(() => _sortMode = val);
//                     context.read<TaskCubit>().changeSortMode(val);
//                   }
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProjectDashboard(
//     List<TaskModel> tasks,
//     AtharColors colors,
//     AppLocalizations l10n,
//   ) {
//     final total = tasks.length;
//     final done = tasks
//         .where((t) => t.isCompleted || t.status == TaskStatus.done)
//         .length;
//     final progress = total == 0 ? 0.0 : done / total;

//     String? countdownText;
//     Color countdownColor = colors.textTertiary;
//     if (_module.endDate != null) {
//       final diff = _module.endDate!.difference(DateTime.now());
//       if (diff.isNegative) {
//         countdownText = l10n.projectDetailsTimeExpired;
//         countdownColor = colors.error;
//       } else {
//         countdownText = l10n.projectDetailsDaysLeft(diff.inDays);
//         countdownColor = diff.inDays <= 3 ? Colors.orange : colors.primary;
//       }
//     }

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       padding: AtharSpacing.allLg,
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: AtharRadii.radiusLg,
//         border: Border.all(color: colors.borderLight),
//         boxShadow: [
//           BoxShadow(
//             color: colors.shadow,
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (_module.description != null &&
//               _module.description!.isNotEmpty) ...[
//             InkWell(
//               onTap: () => setState(() => _isExpanded = !_isExpanded),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _module.description!,
//                     maxLines: _isExpanded ? 10 : 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontFamily: 'Tajawal',
//                       fontSize: 13.sp,
//                       color: colors.textSecondary,
//                     ),
//                   ),
//                   if (!_isExpanded && _module.description!.length > 50)
//                     Text(
//                       l10n.projectDetailsShowMore,
//                       style: TextStyle(color: colors.primary, fontSize: 12.sp),
//                     ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 12.h),
//           ],
//           if (_module.startDate != null || _module.endDate != null)
//             Row(
//               children: [
//                 if (_module.startDate != null)
//                   _buildDateChip(
//                     Icons.calendar_today_rounded,
//                     DateFormat('d MMM', 'ar').format(_module.startDate!),
//                     colors: colors,
//                   ),
//                 if (_module.startDate != null && _module.endDate != null)
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 8.w),
//                     child: Icon(
//                       Icons.arrow_forward,
//                       size: 14.sp,
//                       color: colors.textTertiary,
//                     ),
//                   ),
//                 if (_module.endDate != null)
//                   _buildDateChip(
//                     Icons.flag_rounded,
//                     DateFormat('d MMM', 'ar').format(_module.endDate!),
//                     isEnd: true,
//                     colors: colors,
//                   ),
//                 const Spacer(),
//                 if (countdownText != null)
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 10.w,
//                       vertical: 4.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: countdownColor.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(20.r),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.timer_outlined,
//                           size: 14.sp,
//                           color: countdownColor,
//                         ),
//                         SizedBox(width: 4.w),
//                         Text(
//                           countdownText,
//                           style: TextStyle(
//                             fontFamily: 'Tajawal',
//                             color: countdownColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12.sp,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           SizedBox(height: 16.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 l10n.projectDetailsProgressLabel,
//                 style: TextStyle(fontSize: 12.sp, color: colors.textTertiary),
//               ),
//               Text(
//                 "${(progress * 100).toInt()}%",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: colors.primary,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 6.h),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(4),
//             child: LinearProgressIndicator(
//               value: progress,
//               backgroundColor: colors.borderLight,
//               color: progress == 1.0 ? colors.success : colors.primary,
//               minHeight: 8.h,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateChip(
//     IconData icon,
//     String label, {
//     bool isEnd = false,
//     required AtharColors colors,
//   }) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 14.sp,
//           color: isEnd ? colors.error : colors.textTertiary,
//         ),
//         SizedBox(width: 4.w),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontFamily: 'Tajawal',
//             color: colors.textSecondary,
//           ),
//         ),
//       ],
//     );
//   }

//   void _showEditProjectDialog() {
//     final colors =
//         Theme.of(context).extension<AtharColors>() ?? AtharColors.light;
//     final l10n = AppLocalizations.of(context);
//     final nameController = TextEditingController(text: _module.name);
//     final descController = TextEditingController(text: _module.description);
//     DateTime? tempStart = _module.startDate;
//     DateTime? tempEnd = _module.endDate;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => StatefulBuilder(
//         builder: (innerContext, setSheetState) {
//           return Container(
//             padding: EdgeInsets.fromLTRB(
//               24.w,
//               24.w,
//               24.w,
//               MediaQuery.of(innerContext).viewInsets.bottom + 24.w,
//             ),
//             decoration: BoxDecoration(
//               color: colors.surface,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40.w,
//                     height: 4.h,
//                     decoration: BoxDecoration(
//                       color: colors.borderLight,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 24.h),
//                 Text(
//                   l10n.projectDetailsSettings,
//                   style: const TextStyle(
//                     fontFamily: 'Tajawal',
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 TextField(
//                   controller: nameController,
//                   decoration: InputDecoration(
//                     labelText: l10n.projectDetailsNameLabel,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 12.h),
//                 TextField(
//                   controller: descController,
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     labelText: l10n.projectDetailsDescLabel,
//                     border: const OutlineInputBorder(),
//                     alignLabelWithHint: true,
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildDateSelector(
//                         label: l10n.projectDetailsStartDate,
//                         date: tempStart,
//                         colors: colors,
//                         l10n: l10n,
//                         onTap: () async {
//                           final d = await showDatePicker(
//                             context: innerContext,
//                             initialDate: tempStart ?? DateTime.now(),
//                             firstDate: DateTime(2020),
//                             lastDate: DateTime(2030),
//                           );
//                           if (d != null) setSheetState(() => tempStart = d);
//                         },
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//                     Expanded(
//                       child: _buildDateSelector(
//                         label: l10n.projectDetailsEndDate,
//                         date: tempEnd,
//                         isError:
//                             tempEnd != null &&
//                             tempStart != null &&
//                             tempEnd!.isBefore(tempStart!),
//                         colors: colors,
//                         l10n: l10n,
//                         onTap: () async {
//                           final d = await showDatePicker(
//                             context: innerContext,
//                             initialDate:
//                                 tempEnd ??
//                                 (tempStart?.add(const Duration(days: 7)) ??
//                                     DateTime.now()),
//                             firstDate: DateTime(2020),
//                             lastDate: DateTime(2030),
//                           );
//                           if (d != null) setSheetState(() => tempEnd = d);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 24.h),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (nameController.text.isNotEmpty) {
//                       final messenger = ScaffoldMessenger.of(context);
//                       final navigator = Navigator.of(innerContext);

//                       await getIt<SpaceRepository>().updateModule(
//                         uuid: _module.uuid,
//                         name: nameController.text,
//                         description: descController.text,
//                         startDate: tempStart,
//                         endDate: tempEnd,
//                       );

//                       if (!mounted) return;

//                       setState(() {
//                         _module.name = nameController.text;
//                         _module.description = descController.text;
//                         _module.startDate = tempStart;
//                         _module.endDate = tempEnd;
//                       });

//                       navigator.pop();

//                       messenger.showSnackBar(
//                         SnackBar(
//                           content: Text(l10n.projectDetailsUpdateSuccess),
//                           backgroundColor: colors.success,
//                           behavior: SnackBarBehavior.floating,
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: colors.primary,
//                     minimumSize: Size(double.infinity, 50.h),
//                   ),
//                   child: Text(
//                     l10n.projectDetailsSaveChanges,
//                     style: TextStyle(
//                       color: colors.surface,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 const Divider(),
//                 ListTile(
//                   leading: Icon(
//                     _module.status == 'archived'
//                         ? Icons.unarchive
//                         : Icons.archive,
//                     color: _module.status == 'archived'
//                         ? colors.success
//                         : Colors.orange,
//                   ),
//                   title: Text(
//                     _module.status == 'archived'
//                         ? l10n.projectDetailsRestore
//                         : l10n.projectDetailsArchive,
//                   ),
//                   subtitle: Text(
//                     _module.status == 'archived'
//                         ? l10n.projectDetailsRestoreDesc
//                         : l10n.projectDetailsArchiveDesc,
//                   ),
//                   onTap: () async {
//                     final newStatus = _module.status == 'archived'
//                         ? 'active'
//                         : 'archived';

//                     final messenger = ScaffoldMessenger.of(context);
//                     final navigator = Navigator.of(context);
//                     final sheetNavigator = Navigator.of(innerContext);

//                     await getIt<SpaceRepository>().updateModule(
//                       uuid: _module.uuid,
//                       status: newStatus,
//                     );

//                     if (!mounted) return;

//                     setState(() => _module.status = newStatus);

//                     sheetNavigator.pop();

//                     if (newStatus == 'archived') {
//                       navigator.pop();
//                       messenger.showSnackBar(
//                         SnackBar(content: Text(l10n.projectDetailsArchived)),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDateSelector({
//     required String label,
//     DateTime? date,
//     required VoidCallback onTap,
//     bool isError = false,
//     required AtharColors colors,
//     required AppLocalizations l10n,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: AtharRadii.radiusSm,
//       child: Container(
//         padding: AtharSpacing.allMd,
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isError ? colors.error : colors.borderLight,
//           ),
//           borderRadius: AtharRadii.radiusSm,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(fontSize: 10.sp, color: colors.textTertiary),
//             ),
//             SizedBox(height: 4.h),
//             Row(
//               children: [
//                 Icon(
//                   Icons.calendar_today,
//                   size: 14.sp,
//                   color: isError ? colors.error : colors.primary,
//                 ),
//                 AtharGap.hSm,
//                 Text(
//                   date != null
//                       ? DateFormat('yyyy-MM-dd').format(date)
//                       : l10n.projectDetailsNotSet,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13.sp,
//                     color: isError ? colors.error : colors.textPrimary,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _confirmDelete(BuildContext context, TaskModel task) async {
//     final permissionService = getIt<PermissionService>();
//     final l10n = AppLocalizations.of(context);

//     final messenger = ScaffoldMessenger.of(context);
//     final taskCubit = context.read<TaskCubit>();
//     final isAdm = await _canEditFuture;

//     final canDelete = permissionService.canDeleteTask(
//       task: task,
//       isSpaceAdmin: isAdm,
//       isModuleAdmin: false,
//     );

//     if (!mounted) return;

//     if (canDelete) {
//       taskCubit.deleteTask(task.id);
//       messenger.showSnackBar(
//         SnackBar(content: Text(l10n.projectDetailsTaskDeleted)),
//       );
//     } else {
//       messenger.showSnackBar(
//         SnackBar(content: Text(l10n.projectDetailsNoDeletePermission)),
//       );
//     }
//   }

//   void _openAddTaskSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => AddTaskSheet(
//         targetModuleId: _module.uuid,
//         targetSpaceId: _module.spaceId,
//       ),
//     );
//   }

//   void _showEditSheet(BuildContext context, TaskModel task) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => AddTaskSheet(
//         taskToEdit: task,
//         targetModuleId: _module.uuid,
//         targetSpaceId: _module.spaceId,
//       ),
//     );
//   }

//   void _navigateToTaskDetails(BuildContext context, TaskModel task) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (innerCtx) => BlocProvider.value(
//           value: context.read<TaskCubit>(),
//           child: TaskDetailsPage(task: task),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(AtharColors colors, AppLocalizations l10n) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.rocket_launch_outlined,
//             size: 60.sp,
//             color: colors.borderLight,
//           ),
//           AtharGap.lg,
//           Text(
//             l10n.projectDetailsEmptyState,
//             style: TextStyle(
//               fontFamily: 'Tajawal',
//               fontSize: 16,
//               color: colors.textTertiary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//----------------------------------------------------------------------
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/iam/permission_service.dart'; // ✅ مستورد وصحيح
// import 'package:athar/features/space/domain/repositories/space_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:athar/features/task/presentation/cubit/task_state.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/core/design_system/molecules/tiles/task_tile.dart';
// import 'package:athar/core/design_system/molecules/board/kanban_board.dart';
// import '../../data/models/module_model.dart';
// import '../../../task/presentation/widgets/add_task_sheet.dart';
// import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
// import 'package:athar/features/task/presentation/pages/task_details_page.dart';

// class ProjectDetailsPage extends StatefulWidget {
//   final ModuleModel module;

//   const ProjectDetailsPage({super.key, required this.module});

//   @override
//   State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
// }

// class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
//   late ModuleModel _module;
//   bool _isKanbanView = false;
//   bool _isExpanded = false;
//   TaskSortMode _sortMode = TaskSortMode.manual;

//   // ✅ تهيئة المستقبلات للصلاحيات
//   late Future<bool> _canEditFuture;
//   late Future<bool> _canCreateTaskFuture;

//   @override
//   void initState() {
//     super.initState();
//     _module = widget.module;
//     context.read<TaskCubit>().watchModuleTasks(_module.uuid);

//     // ✅ تهيئة التحقق من الصلاحيات عند البدء لمرة واحدة
//     final permissionService = getIt<PermissionService>();
//     _canEditFuture = permissionService.canEdit(
//       'project',
//       spaceId: _module.spaceId,
//       module: _module,
//       resourceOwnerId: _module.creatorId,
//     );
//     _canCreateTaskFuture = permissionService.hasPermission(
//       'create',
//       spaceId: _module.spaceId,
//       resourceType: 'task',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: _buildAppBar(),
//       body: BlocBuilder<TaskCubit, TaskState>(
//         builder: (context, state) {
//           if (state is TaskLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is TaskLoaded) {
//             final tasks = state.tasks;

//             return Column(
//               children: [
//                 _buildProjectDashboard(tasks),
//                 _buildFilterBar(tasks.length),
//                 SizedBox(height: 10.h),
//                 Expanded(
//                   child: tasks.isEmpty
//                       ? _buildEmptyState()
//                       : _isKanbanView
//                       ? KanbanBoard(
//                           tasks: tasks,
//                           onStatusChanged: (taskId, status) async {
//                             final task = tasks.firstWhere(
//                               (t) => t.id == taskId,
//                             );
//                             await context.read<TaskCubit>().updateTaskStatus(
//                               task,
//                               status,
//                             );
//                             if (status == TaskStatus.done &&
//                                 !task.isCompleted) {
//                               if (context.mounted) {
//                                 context.read<CelebrationCubit>().celebrate();
//                               }
//                             }
//                           },
//                           onDelete: (task) => _confirmDelete(context, task),
//                           onTaskTap: (task) =>
//                               _navigateToTaskDetails(context, task),
//                         )
//                       : _buildReorderableList(tasks),
//                 ),
//               ],
//             );
//           } else if (state is TaskError) {
//             return Center(child: Text("خطأ: ${state.message}"));
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//       // ✅ استخدام FutureBuilder للزر العائم بناءً على الصلاحيات
//       floatingActionButton: FutureBuilder<bool>(
//         future: _canCreateTaskFuture,
//         builder: (context, snapshot) {
//           if (snapshot.data == true) {
//             return FloatingActionButton.extended(
//               onPressed: () => _openAddTaskSheet(),
//               backgroundColor: AppColors.primary,
//               icon: const Icon(Icons.add, color: Colors.white),
//               label: const Text(
//                 "مهمة جديدة",
//                 style: TextStyle(color: Colors.white, fontFamily: 'Tajawal'),
//               ),
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }

//   // ✅ بناء القائمة القابلة لإعادة الترتيب (تم فصلها للتنظيم)
//   Widget _buildReorderableList(List<TaskModel> tasks) {
//     return ReorderableListView.builder(
//       padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
//       itemCount: tasks.length,
//       onReorder: (oldIndex, newIndex) {
//         setState(() => _sortMode = TaskSortMode.manual);
//         context.read<TaskCubit>().reorderTasks(oldIndex, newIndex);
//       },
//       itemBuilder: (context, index) {
//         final task = tasks[index];
//         return Container(
//           key: ValueKey(task.uuid),
//           margin: EdgeInsets.only(bottom: 12.h),
//           child: TaskTile(
//             task: task,
//             onToggle: (val) {
//               context.read<TaskCubit>().toggleTaskCompletion(task);
//               if (!task.isCompleted) {
//                 context.read<CelebrationCubit>().celebrate();
//               }
//             },
//             onDelete: () => _confirmDelete(context, task),
//             onLongPress: () => _showEditSheet(context, task),
//             enableSwipe: false,
//           ),
//         );
//       },
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       title: Text(
//         _module.name,
//         style: const TextStyle(
//           fontFamily: 'Tajawal',
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       centerTitle: true,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       foregroundColor: AppColors.textPrimary,
//       actions: [
//         IconButton(
//           icon: Icon(
//             _isKanbanView ? Icons.view_list_rounded : Icons.view_kanban_rounded,
//           ),
//           color: AppColors.primary,
//           tooltip: _isKanbanView ? "عرض القائمة" : "عرض اللوحة",
//           onPressed: () => setState(() => _isKanbanView = !_isKanbanView),
//         ),
//         // ✅ تأمين زر الإعدادات بالـ FutureBuilder
//         FutureBuilder<bool>(
//           future: _canEditFuture,
//           builder: (context, snapshot) {
//             if (snapshot.data == true) {
//               return IconButton(
//                 icon: const Icon(Icons.settings_outlined),
//                 tooltip: "إعدادات المشروع",
//                 onPressed: () => _showEditProjectDialog(),
//               );
//             }
//             return const SizedBox.shrink();
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildFilterBar(int count) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       child: Row(
//         children: [
//           Text(
//             "المهام ($count)",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
//           ),
//           const Spacer(),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20.r),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<TaskSortMode>(
//                 value: _sortMode,
//                 isDense: true,
//                 icon: Icon(Icons.sort, size: 18.sp, color: AppColors.primary),
//                 style: TextStyle(
//                   fontFamily: 'Tajawal',
//                   fontSize: 12.sp,
//                   color: Colors.black87,
//                 ),
//                 items: const [
//                   DropdownMenuItem(
//                     value: TaskSortMode.manual,
//                     child: Text("ترتيب يدوي"),
//                   ),
//                   DropdownMenuItem(
//                     value: TaskSortMode.eisenhower,
//                     child: Text("الأهمية (ايزنهاور)"),
//                   ),
//                   DropdownMenuItem(
//                     value: TaskSortMode.time,
//                     child: Text("الأقرب وقتاً"),
//                   ),
//                 ],
//                 onChanged: (val) {
//                   if (val != null) {
//                     setState(() => _sortMode = val);
//                     context.read<TaskCubit>().changeSortMode(val);
//                   }
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProjectDashboard(List<TaskModel> tasks) {
//     final total = tasks.length;
//     final done = tasks
//         .where((t) => t.isCompleted || t.status == TaskStatus.done)
//         .length;
//     final progress = total == 0 ? 0.0 : done / total;

//     String? countdownText;
//     Color countdownColor = Colors.grey;
//     if (_module.endDate != null) {
//       final diff = _module.endDate!.difference(DateTime.now());
//       if (diff.isNegative) {
//         countdownText = "انتهى الوقت";
//         countdownColor = Colors.red;
//       } else {
//         countdownText = "باقي ${diff.inDays} يوم";
//         countdownColor = diff.inDays <= 3 ? Colors.orange : AppColors.primary;
//       }
//     }

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: Colors.grey.shade100),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (_module.description != null &&
//               _module.description!.isNotEmpty) ...[
//             InkWell(
//               onTap: () => setState(() => _isExpanded = !_isExpanded),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _module.description!,
//                     maxLines: _isExpanded ? 10 : 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontFamily: 'Tajawal',
//                       fontSize: 13.sp,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   if (!_isExpanded && _module.description!.length > 50)
//                     Text(
//                       "المزيد...",
//                       style: TextStyle(
//                         color: AppColors.primary,
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 12.h),
//           ],
//           if (_module.startDate != null || _module.endDate != null)
//             Row(
//               children: [
//                 if (_module.startDate != null)
//                   _buildDateChip(
//                     Icons.calendar_today_rounded,
//                     DateFormat('d MMM', 'ar').format(_module.startDate!),
//                   ),
//                 if (_module.startDate != null && _module.endDate != null)
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 8.w),
//                     child: Icon(
//                       Icons.arrow_forward,
//                       size: 14.sp,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 if (_module.endDate != null)
//                   _buildDateChip(
//                     Icons.flag_rounded,
//                     DateFormat('d MMM', 'ar').format(_module.endDate!),
//                     isEnd: true,
//                   ),
//                 const Spacer(),
//                 if (countdownText != null)
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 10.w,
//                       vertical: 4.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: countdownColor.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(20.r),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.timer_outlined,
//                           size: 14.sp,
//                           color: countdownColor,
//                         ),
//                         SizedBox(width: 4.w),
//                         Text(
//                           countdownText,
//                           style: TextStyle(
//                             fontFamily: 'Tajawal',
//                             color: countdownColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12.sp,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           SizedBox(height: 16.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "نسبة الإنجاز",
//                 style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//               ),
//               Text(
//                 "${(progress * 100).toInt()}%",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 6.h),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(4),
//             child: LinearProgressIndicator(
//               value: progress,
//               backgroundColor: Colors.grey.shade100,
//               color: progress == 1.0 ? Colors.green : AppColors.primary,
//               minHeight: 8.h,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateChip(IconData icon, String label, {bool isEnd = false}) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 14.sp,
//           color: isEnd ? Colors.red.shade300 : Colors.grey,
//         ),
//         SizedBox(width: 4.w),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontFamily: 'Tajawal',
//             color: Colors.grey.shade700,
//           ),
//         ),
//       ],
//     );
//   }

//   // ✅ تصحيح Navigator و ScaffoldMessenger عبر التحقق من mounted ومن الـ BuildContext
//   void _showEditProjectDialog() {
//     final nameController = TextEditingController(text: _module.name);
//     final descController = TextEditingController(text: _module.description);
//     DateTime? tempStart = _module.startDate;
//     DateTime? tempEnd = _module.endDate;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => StatefulBuilder(
//         builder: (innerContext, setSheetState) {
//           return Container(
//             padding: EdgeInsets.fromLTRB(
//               24.w,
//               24.w,
//               24.w,
//               MediaQuery.of(innerContext).viewInsets.bottom + 24.w,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40.w,
//                     height: 4.h,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 24.h),
//                 const Text(
//                   "إعدادات المشروع",
//                   style: TextStyle(
//                     fontFamily: 'Tajawal',
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 TextField(
//                   controller: nameController,
//                   decoration: const InputDecoration(
//                     labelText: "اسم المشروع",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 12.h),
//                 TextField(
//                   controller: descController,
//                   maxLines: 3,
//                   decoration: const InputDecoration(
//                     labelText: "وصف المشروع (اختياري)",
//                     border: OutlineInputBorder(),
//                     alignLabelWithHint: true,
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildDateSelector(
//                         label: "البداية",
//                         date: tempStart,
//                         onTap: () async {
//                           final d = await showDatePicker(
//                             context: innerContext,
//                             initialDate: tempStart ?? DateTime.now(),
//                             firstDate: DateTime(2020),
//                             lastDate: DateTime(2030),
//                           );
//                           if (d != null) setSheetState(() => tempStart = d);
//                         },
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//                     Expanded(
//                       child: _buildDateSelector(
//                         label: "النهاية (Deadline)",
//                         date: tempEnd,
//                         isError:
//                             tempEnd != null &&
//                             tempStart != null &&
//                             tempEnd!.isBefore(tempStart!),
//                         onTap: () async {
//                           final d = await showDatePicker(
//                             context: innerContext,
//                             initialDate:
//                                 tempEnd ??
//                                 (tempStart?.add(const Duration(days: 7)) ??
//                                     DateTime.now()),
//                             firstDate: DateTime(2020),
//                             lastDate: DateTime(2030),
//                           );
//                           if (d != null) setSheetState(() => tempEnd = d);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 24.h),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (nameController.text.isNotEmpty) {
//                       // ✅ 1. تخزين المراجع قبل الـ await لضمان استقرارها
//                       final messenger = ScaffoldMessenger.of(context);
//                       final navigator = Navigator.of(innerContext);

//                       await getIt<SpaceRepository>().updateModule(
//                         uuid: _module.uuid,
//                         name: nameController.text,
//                         description: descController.text,
//                         startDate: tempStart,
//                         endDate: tempEnd,
//                       );

//                       if (!mounted) return;

//                       setState(() {
//                         _module.name = nameController.text;
//                         _module.description = descController.text;
//                         _module.startDate = tempStart;
//                         _module.endDate = tempEnd;
//                       });

//                       // ✅ 2. إغلاق النافذة المنبثقة باستخدام المرجع المخزن
//                       navigator.pop();

//                       // ✅ 3. استخدام المرجع 'messenger' لإظهار رسالة نجاح (التوظيف المطلوب)
//                       messenger.showSnackBar(
//                         const SnackBar(
//                           content: Text("تم تحديث بيانات المشروع بنجاح ✅"),
//                           backgroundColor: Colors.green,
//                           behavior: SnackBarBehavior.floating,
//                         ),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     minimumSize: Size(double.infinity, 50.h),
//                   ),
//                   child: const Text(
//                     "حفظ التغييرات",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 const Divider(),
//                 ListTile(
//                   leading: Icon(
//                     _module.status == 'archived'
//                         ? Icons.unarchive
//                         : Icons.archive,
//                     color: _module.status == 'archived'
//                         ? Colors.green
//                         : Colors.orange,
//                   ),
//                   title: Text(
//                     _module.status == 'archived'
//                         ? "استعادة المشروع"
//                         : "أرشفة المشروع",
//                   ),
//                   subtitle: Text(
//                     _module.status == 'archived'
//                         ? "سيعود للقائمة الرئيسية"
//                         : "سيتم إخفاؤه من القائمة الرئيسية (نسبة الإنجاز محفوظة)",
//                   ),
//                   onTap: () async {
//                     final newStatus = _module.status == 'archived'
//                         ? 'active'
//                         : 'archived';

//                     // ✅ 1. تخزين المراجع الضرورية قبل الفجوة الزمنية
//                     final messenger = ScaffoldMessenger.of(context);
//                     final navigator = Navigator.of(
//                       context,
//                     ); // مرجع الصفحة الرئيسية
//                     final sheetNavigator = Navigator.of(
//                       innerContext,
//                     ); // مرجع الشيت

//                     await getIt<SpaceRepository>().updateModule(
//                       uuid: _module.uuid,
//                       status: newStatus,
//                     );

//                     if (!mounted) return;

//                     setState(() => _module.status = newStatus);

//                     // ✅ 2. تنفيذ العمليات باستخدام المراجع المستقرة
//                     sheetNavigator.pop(); // إغلاق الشيت

//                     if (newStatus == 'archived') {
//                       navigator.pop(); // العودة للخلف (إغلاق صفحة التفاصيل)
//                       messenger.showSnackBar(
//                         const SnackBar(content: Text("تم أرشفة المشروع")),
//                       );
//                     }
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDateSelector({
//     required String label,
//     DateTime? date,
//     required VoidCallback onTap,
//     bool isError = false,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: EdgeInsets.all(12.w),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isError ? Colors.red : Colors.grey.shade300,
//           ),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//             ),
//             SizedBox(height: 4.h),
//             Row(
//               children: [
//                 Icon(
//                   Icons.calendar_today,
//                   size: 14.sp,
//                   color: isError ? Colors.red : AppColors.primary,
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   date != null
//                       ? DateFormat('yyyy-MM-dd').format(date)
//                       : "غير محدد",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13.sp,
//                     color: isError ? Colors.red : Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ تصحيح دالة التأكيد والحذف عبر استخدام التحقق الآمن من الـ context
//   void _confirmDelete(BuildContext context, TaskModel task) async {
//     final permissionService = getIt<PermissionService>();

//     // ✅ 1. تخزين المراجع والبيانات قبل الـ await
//     final messenger = ScaffoldMessenger.of(context);
//     final taskCubit = context.read<TaskCubit>();
//     final isAdm = await _canEditFuture;

//     // التحقق من الصلاحية
//     final canDelete = permissionService.canDeleteTask(
//       task: task,
//       isSpaceAdmin: isAdm,
//       isModuleAdmin: false,
//     );

//     if (!mounted) return;

//     if (canDelete) {
//       // ✅ 2. استخدام المراجع المخزنة (آمن تماماً من الـ async gaps)
//       taskCubit.deleteTask(task.id);
//       messenger.showSnackBar(const SnackBar(content: Text("تم حذف المهمة")));
//     } else {
//       messenger.showSnackBar(
//         const SnackBar(
//           content: Text("عذراً، لا تملك صلاحية حذف هذه المهمة 🚫"),
//         ),
//       );
//     }
//   }

//   // ✅ إضافة دالة _openAddTaskSheet المفقودة
//   void _openAddTaskSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => AddTaskSheet(
//         targetModuleId: _module.uuid,
//         targetSpaceId: _module.spaceId,
//       ),
//     );
//   }

//   void _showEditSheet(BuildContext context, TaskModel task) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => AddTaskSheet(
//         taskToEdit: task,
//         targetModuleId: _module.uuid,
//         targetSpaceId: _module.spaceId,
//       ),
//     );
//   }

//   void _navigateToTaskDetails(BuildContext context, TaskModel task) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (innerCtx) => BlocProvider.value(
//           value: context.read<TaskCubit>(),
//           child: TaskDetailsPage(task: task),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.rocket_launch_outlined,
//             size: 60.sp,
//             color: Colors.grey.shade300,
//           ),
//           SizedBox(height: 16.h),
//           const Text(
//             "ابدأ مشروعك بإضافة مهمة",
//             style: TextStyle(
//               fontFamily: 'Tajawal',
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//----------------------------------------------------------------------
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/space/domain/repositories/space_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart'; // ✅ نحتاج هذه المكتبة لتنسيق التواريخ
// import 'package:athar/core/design_system/theme/app_colors.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:athar/features/task/presentation/cubit/task_state.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/core/design_system/molecules/tiles/task_tile.dart';
// import 'package:athar/core/design_system/molecules/board/kanban_board.dart';
// import '../../data/models/module_model.dart';
// import '../../../task/presentation/widgets/add_task_sheet.dart';
// import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
// import 'package:athar/features/task/presentation/pages/task_details_page.dart';

// class ProjectDetailsPage extends StatefulWidget {
//   final ModuleModel module;

//   const ProjectDetailsPage({super.key, required this.module});

//   @override
//   State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
// }

// class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
//   late ModuleModel _module; // ✅ نسخة محلية قابلة للتحديث عند التعديل
//   bool _isKanbanView = false;
//   bool _isExpanded = false; // لتوسيع الوصف

//   @override
//   void initState() {
//     super.initState();
//     _module = widget.module;
//     context.read<TaskCubit>().watchModuleTasks(_module.uuid);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: _buildAppBar(),
//       body: BlocBuilder<TaskCubit, TaskState>(
//         builder: (context, state) {
//           if (state is TaskLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is TaskLoaded) {
//             final tasks = state.tasks;

//             return Column(
//               children: [
//                 // ✅ 1. الداشبورد الجديد (العداد + الوصف + الإحصائيات)
//                 _buildProjectDashboard(tasks),

//                 SizedBox(height: 10.h),

//                 Expanded(
//                   child: tasks.isEmpty
//                       ? _buildEmptyState()
//                       : _isKanbanView
//                       ? KanbanBoard(
//                           tasks: tasks,
//                           onStatusChanged: (taskId, status) async {
//                             final task = tasks.firstWhere(
//                               (t) => t.id == taskId,
//                             );
//                             await context.read<TaskCubit>().updateTaskStatus(
//                               task,
//                               status,
//                             );
//                             if (status == TaskStatus.done &&
//                                 !task.isCompleted) {
//                               if (context.mounted)
//                                 context.read<CelebrationCubit>().celebrate();
//                             }
//                           },
//                           onDelete: (task) => _confirmDelete(context, task),
//                           onTaskTap: (task) {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => BlocProvider.value(
//                                   value: context.read<TaskCubit>(),
//                                   child: TaskDetailsPage(task: task),
//                                 ),
//                               ),
//                             );
//                           },
//                         )
//                       : ListView.separated(
//                           padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h),
//                           itemCount: tasks.length,
//                           separatorBuilder: (c, i) => SizedBox(height: 12.h),
//                           itemBuilder: (context, index) {
//                             final task = tasks[index];
//                             return TaskTile(
//                               task: task,
//                               onToggle: (val) {
//                                 context.read<TaskCubit>().toggleTaskCompletion(
//                                   task,
//                                 );
//                                 if (!task.isCompleted) {
//                                   context.read<CelebrationCubit>().celebrate();
//                                 }
//                               },
//                               onDelete: () => _confirmDelete(context, task),
//                               onLongPress: () => _showEditSheet(context, task),
//                               enableSwipe: true,
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             );
//           } else if (state is TaskError) {
//             return Center(child: Text("خطأ: ${state.message}"));
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (context) => AddTaskSheet(
//               targetModuleId: _module.uuid,
//               targetSpaceId: _module.spaceId,
//             ),
//           );
//         },
//         backgroundColor: AppColors.primary,
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text(
//           "مهمة جديدة",
//           style: TextStyle(color: Colors.white, fontFamily: 'Tajawal'),
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       title: Text(
//         _module.name,
//         style: const TextStyle(
//           fontFamily: 'Tajawal',
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//       centerTitle: true,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       foregroundColor: AppColors.textPrimary,
//       actions: [
//         // زر التبديل بين القائمة واللوحة
//         IconButton(
//           icon: Icon(
//             _isKanbanView ? Icons.view_list_rounded : Icons.view_kanban_rounded,
//           ),
//           color: AppColors.primary,
//           tooltip: _isKanbanView ? "عرض القائمة" : "عرض اللوحة",
//           onPressed: () => setState(() => _isKanbanView = !_isKanbanView),
//         ),
//         // ✅ زر إعدادات المشروع (تعديل)
//         IconButton(
//           icon: const Icon(Icons.settings_outlined),
//           tooltip: "إعدادات المشروع",
//           onPressed: () => _showEditProjectDialog(),
//         ),
//       ],
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // ✅ 1. قسم الداشبورد (الجديد كلياً)
//   // ---------------------------------------------------------------------------
//   Widget _buildProjectDashboard(List<TaskModel> tasks) {
//     // حساب الإحصائيات
//     final total = tasks.length;
//     final done = tasks
//         .where((t) => t.isCompleted || t.status == TaskStatus.done)
//         .length;
//     final progress = total == 0 ? 0.0 : done / total;

//     // حساب العداد التنازلي
//     String? countdownText;
//     Color countdownColor = Colors.grey;
//     if (_module.endDate != null) {
//       final diff = _module.endDate!.difference(DateTime.now());
//       if (diff.isNegative) {
//         countdownText = "انتهى الوقت";
//         countdownColor = Colors.red;
//       } else {
//         countdownText = "باقي ${diff.inDays} يوم";
//         if (diff.inDays <= 3)
//           countdownColor = Colors.orange; // تحذير
//         else
//           countdownColor = AppColors.primary;
//       }
//     }

//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(color: Colors.grey.shade100),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // أ. الوصف والتواريخ
//           if (_module.description != null &&
//               _module.description!.isNotEmpty) ...[
//             InkWell(
//               onTap: () => setState(() => _isExpanded = !_isExpanded),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _module.description!,
//                     maxLines: _isExpanded ? 10 : 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontFamily: 'Tajawal',
//                       fontSize: 13.sp,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   if (!_isExpanded && _module.description!.length > 50)
//                     Text(
//                       "المزيد...",
//                       style: TextStyle(
//                         color: AppColors.primary,
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 12.h),
//           ],

//           // ب. شريط المعلومات (التاريخ والعداد)
//           if (_module.startDate != null || _module.endDate != null)
//             Row(
//               children: [
//                 if (_module.startDate != null)
//                   _buildDateChip(
//                     Icons.calendar_today_rounded,
//                     DateFormat('d MMM', 'ar').format(_module.startDate!),
//                   ),

//                 if (_module.startDate != null && _module.endDate != null)
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 8.w),
//                     child: Icon(
//                       Icons.arrow_forward,
//                       size: 14.sp,
//                       color: Colors.grey,
//                     ),
//                   ),

//                 if (_module.endDate != null)
//                   _buildDateChip(
//                     Icons.flag_rounded,
//                     DateFormat('d MMM', 'ar').format(_module.endDate!),
//                     isEnd: true,
//                   ),

//                 const Spacer(),

//                 // 🔥 العداد التنازلي
//                 if (countdownText != null)
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 10.w,
//                       vertical: 4.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: countdownColor.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(20.r),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.timer_outlined,
//                           size: 14.sp,
//                           color: countdownColor,
//                         ),
//                         SizedBox(width: 4.w),
//                         Text(
//                           countdownText,
//                           style: TextStyle(
//                             fontFamily: 'Tajawal',
//                             color: countdownColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12.sp,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),

//           SizedBox(height: 16.h),

//           // ج. شريط التقدم
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "نسبة الإنجاز",
//                 style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//               ),
//               Text(
//                 "${(progress * 100).toInt()}%",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 6.h),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(4),
//             child: LinearProgressIndicator(
//               value: progress,
//               backgroundColor: Colors.grey.shade100,
//               color: progress == 1.0 ? Colors.green : AppColors.primary,
//               minHeight: 8.h,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateChip(IconData icon, String label, {bool isEnd = false}) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 14.sp,
//           color: isEnd ? Colors.red.shade300 : Colors.grey,
//         ),
//         SizedBox(width: 4.w),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontFamily: 'Tajawal',
//             color: Colors.grey.shade700,
//           ),
//         ),
//       ],
//     );
//   }

//   // ---------------------------------------------------------------------------
//   // ✅ 2. نافذة تعديل المشروع (المنطق الجديد)
//   // ---------------------------------------------------------------------------
//   void _showEditProjectDialog() {
//     final nameController = TextEditingController(text: _module.name);
//     final descController = TextEditingController(text: _module.description);
//     DateTime? tempStart = _module.startDate;
//     DateTime? tempEnd = _module.endDate;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => StatefulBuilder(
//         builder: (context, setSheetState) {
//           return Container(
//             padding: EdgeInsets.fromLTRB(
//               24.w,
//               24.w,
//               24.w,
//               MediaQuery.of(context).viewInsets.bottom + 24.w,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     width: 40.w,
//                     height: 4.h,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 24.h),

//                 Text(
//                   "إعدادات المشروع",
//                   style: TextStyle(
//                     fontFamily: 'Tajawal',
//                     fontSize: 18.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 16.h),

//                 // اسم المشروع
//                 TextField(
//                   controller: nameController,
//                   decoration: const InputDecoration(
//                     labelText: "اسم المشروع",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 12.h),

//                 // الوصف
//                 TextField(
//                   controller: descController,
//                   maxLines: 3,
//                   decoration: const InputDecoration(
//                     labelText: "وصف المشروع (اختياري)",
//                     border: OutlineInputBorder(),
//                     alignLabelWithHint: true,
//                   ),
//                 ),
//                 SizedBox(height: 16.h),

//                 // التواريخ
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildDateSelector(
//                         label: "البداية",
//                         date: tempStart,
//                         onTap: () async {
//                           final d = await showDatePicker(
//                             context: context,
//                             initialDate: tempStart ?? DateTime.now(),
//                             firstDate: DateTime(2020),
//                             lastDate: DateTime(2030),
//                           );
//                           if (d != null) setSheetState(() => tempStart = d);
//                         },
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//                     Expanded(
//                       child: _buildDateSelector(
//                         label: "النهاية (Deadline)",
//                         date: tempEnd,
//                         isError:
//                             tempEnd != null &&
//                             tempStart != null &&
//                             tempEnd!.isBefore(tempStart!),
//                         onTap: () async {
//                           final d = await showDatePicker(
//                             context: context,
//                             initialDate:
//                                 tempEnd ??
//                                 (tempStart?.add(const Duration(days: 7)) ??
//                                     DateTime.now()),
//                             firstDate: DateTime(2020),
//                             lastDate: DateTime(2030),
//                           );
//                           if (d != null) setSheetState(() => tempEnd = d);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),

//                 SizedBox(height: 24.h),

//                 // زر الحفظ
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (nameController.text.isNotEmpty) {
//                       // 1. تحديث في قاعدة البيانات
//                       await getIt<SpaceRepository>().updateModule(
//                         uuid: _module.uuid,
//                         name: nameController.text,
//                         description: descController.text,
//                         startDate: tempStart,
//                         endDate: tempEnd,
//                       );

//                       // 2. تحديث النسخة المحلية في الصفحة
//                       setState(() {
//                         _module.name = nameController.text;
//                         _module.description = descController.text;
//                         _module.startDate = tempStart;
//                         _module.endDate = tempEnd;
//                       });

//                       if (mounted) Navigator.pop(context);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     minimumSize: Size(double.infinity, 50.h),
//                   ),
//                   child: const Text(
//                     "حفظ التغييرات",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDateSelector({
//     required String label,
//     DateTime? date,
//     required VoidCallback onTap,
//     bool isError = false,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: EdgeInsets.all(12.w),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isError ? Colors.red : Colors.grey.shade300,
//           ),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//             ),
//             SizedBox(height: 4.h),
//             Row(
//               children: [
//                 Icon(
//                   Icons.calendar_today,
//                   size: 14.sp,
//                   color: isError ? Colors.red : AppColors.primary,
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   date != null
//                       ? DateFormat('yyyy-MM-dd').format(date)
//                       : "غير محدد",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 13.sp,
//                     color: isError ? Colors.red : Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- دوال مساعدة للحذف والتعديل ---
//   void _confirmDelete(BuildContext context, TaskModel task) {
//     context.read<TaskCubit>().deleteTask(task.id);
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("تم حذف المهمة")));
//   }

//   void _showEditSheet(BuildContext context, TaskModel task) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => AddTaskSheet(
//         taskToEdit: task,
//         targetModuleId: _module.uuid,
//         targetSpaceId: _module.spaceId,
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.rocket_launch_outlined,
//             size: 60.sp,
//             color: Colors.grey.shade300,
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             "ابدأ مشروعك بإضافة مهمة",
//             style: TextStyle(
//               fontFamily: 'Tajawal',
//               fontSize: 16.sp,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
