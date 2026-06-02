import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/core/design_system/molecules/tiles/task_tile.dart';

class KanbanBoard extends StatefulWidget {
  final List<TaskModel> tasks;
  final Function(int taskId, TaskStatus newStatus) onStatusChanged;
  final Function(TaskModel task) onTaskTap;
  final Function(TaskModel task) onDelete;

  const KanbanBoard({
    super.key,
    required this.tasks,
    required this.onStatusChanged,
    required this.onTaskTap,
    required this.onDelete,
  });

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    final todoTasks = widget.tasks
        .where((t) => t.status == TaskStatus.todo)
        .toList();
    final inProgressTasks = widget.tasks
        .where((t) => t.status == TaskStatus.inProgress)
        .toList();
    final doneTasks = widget.tasks
        .where((t) => t.status == TaskStatus.done)
        .toList();

    return PageView(
      controller: _pageController,
      children: [
        _buildColumn(
          context,
          colorScheme,
          l10n.kanbanTodo,
          colorScheme.outline,
          todoTasks,
          TaskStatus.todo,
        ),
        _buildColumn(
          context,
          colorScheme,
          l10n.kanbanInProgress,
          colors.info,
          inProgressTasks,
          TaskStatus.inProgress,
        ),
        _buildColumn(
          context,
          colorScheme,
          l10n.kanbanDone,
          colors.success,
          doneTasks,
          TaskStatus.done,
        ),
      ],
    );
  }

  Widget _buildColumn(
    BuildContext context,
    ColorScheme colorScheme,
    String title,
    Color color,
    List<TaskModel> tasks,
    TaskStatus status,
  ) {
    final l10n = AppLocalizations.of(context);

    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        widget.onStatusChanged(details.data, status);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: AtharSpacing.sm,
            vertical: AtharSpacing.xxs,
          ),
          padding: AtharSpacing.allMd,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: AtharRadii.radiusLg,
            border: candidateData.isNotEmpty
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AtharGap.hSm,
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontFamily: 'Calibri',
                      fontFamilyFallback: AtharTypography.fontFallback,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AtharSpacing.sm,
                      vertical: AtharSpacing.xxxs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: AtharRadii.radiusSm,
                    ),
                    child: Text(
                      "${tasks.length}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontFamily: 'Calibri',
                        fontFamilyFallback: AtharTypography.fontFallback,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                height: AtharSpacing.xxl,
                color: colorScheme.outlineVariant,
              ),

              // Tasks List
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Text(
                          l10n.kanbanDragHere,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colorScheme.outline,
                            fontFamily: 'Calibri',
                            fontFamilyFallback: AtharTypography.fontFallback,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Draggable<int>(
                            data: task.id,
                            feedback: SizedBox(
                              width: 280.w,
                              child: Material(
                                color: Colors.transparent,
                                child: Opacity(
                                  opacity: 0.9,
                                  child: IgnorePointer(
                                    child: TaskTile(
                                      task: task,
                                      onToggle: (_) {},
                                      onDelete: () {},
                                      enableSwipe: false,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: TaskTile(
                                task: task,
                                onToggle: (_) {},
                                onDelete: () {},
                                enableSwipe: false,
                              ),
                            ),
                            child: TaskTile(
                              task: task,
                              enableSwipe: false,
                              onContentTap: () => widget.onTaskTap(task),
                              onToggle: (_) => widget.onStatusChanged(
                                task.id,
                                TaskStatus.done,
                              ),
                              onDelete: () => widget.onDelete(task),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
