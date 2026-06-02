import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
import 'package:athar/features/space/presentation/widgets/member_selector_sheet.dart';
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/iam/permission_service.dart';
import '../../../../features/task/data/models/task_model.dart';
import '../../../../features/task/presentation/pages/task_details_page.dart';
import '../../../../features/focus/presentation/screens/focus_screen.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final Function(bool?) onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onLongPress;
  final bool enableSwipe;
  final VoidCallback? onContentTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    this.onLongPress,
    this.enableSwipe = true,
    this.onContentTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final permissionService = getIt<PermissionService>();
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return FutureBuilder<bool>(
      future: permissionService.hasPermission(
        'update_core',
        spaceId: task.spaceId,
        resourceType: 'task',
        resourceOwnerId: task.userId,
      ),
      builder: (context, snapshot) {
        final bool canModify = snapshot.data ?? false;

        final isPoolTask = task.spaceId != null && task.assigneeId == null;
        final isAssignedToMe = task.assigneeId == currentUserId;

        final canAssign =
            canModify &&
            task.spaceId != null &&
            (task.userId == currentUserId ||
                (task.isReassignable && isAssignedToMe));

        Color? ribbonColor;
        String? ribbonText;

        if (!task.isCompleted) {
          if (task.status == TaskStatus.inProgress) {
            ribbonColor = colors.info;
            ribbonText = l10n.taskRibbonInProgress;
          } else if (task.status == TaskStatus.todo &&
              task.createdAt.difference(DateTime.now()).inHours.abs() < 24) {
            ribbonColor = colors.success;
            ribbonText = l10n.taskRibbonNew;
          }
        }

        // Card content
        Widget cardContent = Container(
          margin: EdgeInsets.symmetric(
            horizontal: AtharSpacing.lg,
            vertical: AtharSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AtharRadii.radiusMd,
            border: Border.all(
              color: isPoolTask
                  ? colors.warning.withValues(alpha: 0.5)
                  : (task.isUrgent && !task.isCompleted
                        ? colorScheme.error.withValues(alpha: 0.3)
                        : colorScheme.outlineVariant),
              width: isPoolTask ? 1.5 : 1,
            ),
            boxShadow: [
              if (!task.isCompleted)
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AtharRadii.radiusMd,
            child: Stack(
              children: [
                Padding(
                  padding: AtharSpacing.allMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Status button
                          IgnorePointer(
                            ignoring: !canModify,
                            child: Opacity(
                              opacity: canModify ? 1.0 : 0.5,
                              child: PopupMenuButton<String>(
                                tooltip: l10n.taskStatusOptions,
                                onSelected: (value) async {
                                  final cubit = context.read<TaskCubit>();
                                  if (value == 'status_todo') {
                                    cubit.updateTaskStatus(
                                      task,
                                      TaskStatus.todo,
                                    );
                                  } else if (value == 'status_progress') {
                                    cubit.updateTaskStatus(
                                      task,
                                      TaskStatus.inProgress,
                                    );
                                  } else if (value == 'status_done') {
                                    cubit.updateTaskStatus(
                                      task,
                                      TaskStatus.done,
                                    );
                                    if (!task.isCompleted) {
                                      context
                                          .read<CelebrationCubit>()
                                          .celebrate();
                                    }
                                  } else if (value == 'assign') {
                                    final result = await showModalBottomSheet(
                                      context: context,
                                      builder: (_) => MemberSelectorSheet(
                                        spaceId: task.spaceId!,
                                        currentAssigneeId: task.assigneeId,
                                      ),
                                    );
                                    if (result != null && context.mounted) {
                                      if (result == 'unassign') {
                                        cubit.unassignTask(task);
                                      } else {
                                        cubit.assignTaskToUser(task, result);
                                      }
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(AtharSpacing.sm),
                                  child: _buildStatusIcon(
                                    colorScheme,
                                    colors,
                                    task.status,
                                  ),
                                ),
                                itemBuilder: (context) => [
                                  _buildPopupItem(
                                    'status_todo',
                                    l10n.taskStatusWaiting,
                                    Icons.circle_outlined,
                                    colorScheme.outline,
                                  ),
                                  _buildPopupItem(
                                    'status_progress',
                                    l10n.taskStatusExecuting,
                                    Icons.hourglass_top,
                                    colors.info,
                                  ),
                                  _buildPopupItem(
                                    'status_done',
                                    l10n.taskStatusCompleted,
                                    Icons.check_circle,
                                    colors.success,
                                  ),
                                  if (canAssign) ...[
                                    const PopupMenuDivider(),
                                    _buildPopupItem(
                                      'assign',
                                      l10n.taskAssignToMember,
                                      Icons.person_add_alt_1,
                                      colorScheme.secondary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          // Title
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 15.sp,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onSurface,
                                fontWeight: (task.isUrgent || task.isImportant)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontFamily: 'Calibri',
                                fontFamilyFallback: AtharTypography.fontFallback,
                              ),
                            ),
                          ),

                          // Lock icon
                          if (!canModify)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AtharSpacing.xxs,
                              ),
                              child: Icon(
                                Icons.lock_person_outlined,
                                size: 14.sp,
                                color: colorScheme.outline.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),

                          // Pickup badge
                          if (isPoolTask && !task.isCompleted)
                            InkWell(
                              onTap: () {
                                context.read<TaskCubit>().pickupTask(task);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.taskPickedUp)),
                                );
                              },
                              child: _buildPickupBadge(colorScheme, colors, l10n),
                            ),

                          // Assignee avatar
                          if (!isPoolTask &&
                              task.spaceId != null &&
                              !task.isCompleted)
                            _buildAssigneeAvatar(
                              colorScheme,
                              isAssignedToMe,
                              l10n,
                            ),

                          // Timer button
                          if (!task.isCompleted)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FocusScreen(focusTarget: task.title),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AtharSpacing.sm,
                                ),
                                child: Icon(
                                  Icons.timer_outlined,
                                  color: colorScheme.primary,
                                  size: 22.sp,
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Bottom details
                      Padding(
                        padding: EdgeInsetsDirectional.only(end: AtharSpacing.md),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 10.sp,
                              color: colorScheme.outline,
                            ),
                            AtharGap.hXxs,
                            Text(
                              DateFormat('d MMM', 'ar').format(task.date),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: colorScheme.outline,
                                fontFamily: 'Calibri',
                                fontFamilyFallback: AtharTypography.fontFallback,
                              ),
                            ),
                            AtharGap.hSm,
                            if (task.isUrgent && !task.isCompleted)
                              Icon(
                                Icons.local_fire_department,
                                size: 14.sp,
                                color: colorScheme.error,
                              ),
                            if (task.isImportant && !task.isCompleted)
                              Icon(
                                Icons.star_rounded,
                                size: 16.sp,
                                color: colors.warning,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Ribbon
                if (ribbonText != null && !task.isCompleted)
                  _buildRibbon(colorScheme, ribbonText, ribbonColor),
              ],
            ),
          ),
        );

        // Tappable wrapper
        Widget tappableContent = GestureDetector(
          onTap: () {
            if (onContentTap != null) {
              onContentTap!();
            } else {
              final taskCubit = context.read<TaskCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: taskCubit,
                    child: TaskDetailsPage(task: task),
                  ),
                ),
              );
            }
          },
          onLongPress: onLongPress,
          child: cardContent,
        );

        // Swipe to delete
        if (enableSwipe && canModify) {
          return Dismissible(
            key: Key(task.id.toString()),
            direction: DismissDirection.endToStart,
            background: _buildDeleteBackground(colorScheme),
            onDismissed: (_) => onDelete(),
            child: tappableContent,
          );
        } else {
          return tappableContent;
        }
      },
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme, AtharColors colors, TaskStatus status) {
    switch (status) {
      case TaskStatus.done:
        return Icon(
          Icons.check_circle,
          color: colors.success,
          size: 24.sp,
        );
      case TaskStatus.inProgress:
        return Icon(Icons.hourglass_top, color: colors.info, size: 24.sp);
      case TaskStatus.todo:
        return Icon(
          Icons.circle_outlined,
          color: colorScheme.outline,
          size: 24.sp,
        );
    }
  }

  PopupMenuItem<String> _buildPopupItem(
    String value,
    String text,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          AtharGap.hSm,
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.bold,
              fontFamily: 'Calibri',
              fontFamilyFallback: AtharTypography.fontFallback,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupBadge(ColorScheme colorScheme, AtharColors colors, AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
      padding: EdgeInsets.symmetric(
        horizontal: AtharSpacing.sm,
        vertical: AtharSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.1),
        borderRadius: AtharRadii.radiusSm,
        border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.back_hand_rounded, size: 14.sp, color: colors.warning),
          AtharGap.hXxs,
          Text(
            l10n.taskPickupLabel,
            style: TextStyle(
              fontSize: 10.sp,
              color: colors.warning,
              fontWeight: FontWeight.bold,
              fontFamily: 'Calibri',
              fontFamilyFallback: AtharTypography.fontFallback,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssigneeAvatar(
    ColorScheme colorScheme,
    bool isAssignedToMe,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
      child: Tooltip(
        message: isAssignedToMe
            ? l10n.taskAssignedToYou
            : l10n.taskAssignedToOther,
        child: CircleAvatar(
          radius: 12.r,
          backgroundColor: isAssignedToMe
              ? colorScheme.primary
              : colorScheme.outlineVariant,
          child: Icon(Icons.person, size: 14.sp, color: colorScheme.onPrimary),
        ),
      ),
    );
  }

  Widget _buildRibbon(ColorScheme colorScheme, String text, Color? color) {
    return PositionedDirectional(
      top: 0,
      start: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AtharSpacing.sm,
          vertical: AtharSpacing.xxxs,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadiusDirectional.only(
            bottomEnd: Radius.circular(AtharSpacing.sm),
            topStart: Radius.circular(AtharSpacing.md),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 9.sp,
            fontFamily: 'Calibri',
            fontFamilyFallback: AtharTypography.fontFallback,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteBackground(ColorScheme colorScheme) {
    return Container(
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xl),
      margin: EdgeInsets.symmetric(
        vertical: AtharSpacing.xs,
        horizontal: AtharSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: AtharRadii.radiusMd,
      ),
      child: Icon(Icons.delete, color: colorScheme.onPrimary),
    );
  }
}
