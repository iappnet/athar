import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
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
import '../../../../features/focus/presentation/pages/focus_page.dart';

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
            ribbonColor = Colors.blueAccent;
            ribbonText = l10n.taskRibbonInProgress;
          } else if (task.status == TaskStatus.todo &&
              task.createdAt.difference(DateTime.now()).inHours.abs() < 24) {
            ribbonColor = const Color(0xFF00B894);
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
                  ? Colors.orange.withValues(alpha: 0.5)
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
                                    Colors.blueAccent,
                                  ),
                                  _buildPopupItem(
                                    'status_done',
                                    l10n.taskStatusCompleted,
                                    Icons.check_circle,
                                    const Color(0xFF00B894),
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
                              child: _buildPickupBadge(colorScheme, l10n),
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
                                        FocusPage(focusTarget: task.title),
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
                        padding: EdgeInsets.only(right: AtharSpacing.md),
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
                                color: Colors.orange,
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

  Widget _buildStatusIcon(ColorScheme colorScheme, TaskStatus status) {
    switch (status) {
      case TaskStatus.done:
        return Icon(
          Icons.check_circle,
          color: const Color(0xFF00B894),
          size: 24.sp,
        );
      case TaskStatus.inProgress:
        return Icon(Icons.hourglass_top, color: Colors.blueAccent, size: 24.sp);
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupBadge(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
      padding: EdgeInsets.symmetric(
        horizontal: AtharSpacing.sm,
        vertical: AtharSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: AtharRadii.radiusSm,
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.back_hand_rounded, size: 14.sp, color: Colors.orange),
          AtharGap.hXxs,
          Text(
            l10n.taskPickupLabel,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
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
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AtharSpacing.sm,
          vertical: AtharSpacing.xxxs,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(AtharSpacing.sm),
            topLeft: Radius.circular(AtharSpacing.md),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 9.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteBackground(ColorScheme colorScheme) {
    return Container(
      alignment: Alignment.centerLeft,
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
//-----------------------------------------------------------------------
// // lib/core/design_system/molecules/tiles/task_tile.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 1 | File 1.8
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ❌ REMOVED: import '../../themes/app_colors.dart';

// import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
// import 'package:athar/features/space/presentation/widgets/member_selector_sheet.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/iam/permission_service.dart';
// import '../../../../features/task/data/models/task_model.dart';
// import '../../../../features/task/presentation/pages/task_details_page.dart';
// import '../../../../features/focus/presentation/pages/focus_page.dart';

// class TaskTile extends StatelessWidget {
//   final TaskModel task;
//   final Function(bool?) onToggle;
//   final VoidCallback onDelete;
//   final VoidCallback? onLongPress;
//   final bool enableSwipe;
//   final VoidCallback? onContentTap;

//   const TaskTile({
//     super.key,
//     required this.task,
//     required this.onToggle,
//     required this.onDelete,
//     this.onLongPress,
//     this.enableSwipe = true,
//     this.onContentTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;
//     final permissionService = getIt<PermissionService>();
//     final currentUserId = Supabase.instance.client.auth.currentUser?.id;

//     return FutureBuilder<bool>(
//       future: permissionService.hasPermission(
//         'update_core',
//         spaceId: task.spaceId,
//         resourceType: 'task',
//         resourceOwnerId: task.userId,
//       ),
//       builder: (context, snapshot) {
//         final bool canModify = snapshot.data ?? false;

//         final isPoolTask = task.spaceId != null && task.assigneeId == null;
//         final isAssignedToMe = task.assigneeId == currentUserId;

//         final canAssign =
//             canModify &&
//             task.spaceId != null &&
//             (task.userId == currentUserId ||
//                 (task.isReassignable && isAssignedToMe));

//         Color? ribbonColor;
//         String? ribbonText;

//         if (!task.isCompleted) {
//           if (task.status == TaskStatus.inProgress) {
//             // ✅ Colors.blue → colors.info
//             ribbonColor = colors.info;
//             ribbonText = "جاري العمل";
//           } else if (task.status == TaskStatus.todo &&
//               task.createdAt.difference(DateTime.now()).inHours.abs() < 24) {
//             // ✅ Colors.green → colors.success
//             ribbonColor = colors.success;
//             ribbonText = "جديد";
//           }
//         }

//         // بناء محتوى البطاقة
//         Widget cardContent = Container(
//           // ✅ EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h)
//           margin: EdgeInsets.symmetric(
//             horizontal: AtharSpacing.lg,
//             vertical: AtharSpacing.xs,
//           ),
//           decoration: BoxDecoration(
//             // ✅ Colors.white → colors.surface
//             color: colors.surface,
//             // ✅ BorderRadius.circular(12.r) → AtharRadii.md
//             borderRadius: AtharRadii.radiusMd,
//             border: Border.all(
//               color: isPoolTask
//                   ? colors.warning.withValues(alpha: 0.5)
//                   // ✅ AppColors.urgent → colors.error
//                   : (task.isUrgent && !task.isCompleted
//                         ? colors.error.withValues(alpha: 0.3)
//                         // ✅ Colors.grey.shade200 → colors.borderLight
//                         : colors.borderLight),
//               width: isPoolTask ? 1.5 : 1,
//             ),
//             boxShadow: [
//               if (!task.isCompleted)
//                 BoxShadow(
//                   // ✅ Colors.black.withValues(alpha: 0.03)
//                   color: colors.shadow.withValues(alpha: 0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: AtharRadii.radiusMd,
//             child: Stack(
//               children: [
//                 Padding(
//                   // ✅ EdgeInsets.all(12.w) → AtharSpacing.allMd
//                   padding: AtharSpacing.allMd,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           // زر الحالة
//                           IgnorePointer(
//                             ignoring: !canModify,
//                             child: Opacity(
//                               opacity: canModify ? 1.0 : 0.5,
//                               child: PopupMenuButton<String>(
//                                 tooltip: "خيارات الحالة",
//                                 onSelected: (value) async {
//                                   final cubit = context.read<TaskCubit>();
//                                   if (value == 'status_todo') {
//                                     cubit.updateTaskStatus(
//                                       task,
//                                       TaskStatus.todo,
//                                     );
//                                   } else if (value == 'status_progress') {
//                                     cubit.updateTaskStatus(
//                                       task,
//                                       TaskStatus.inProgress,
//                                     );
//                                   } else if (value == 'status_done') {
//                                     cubit.updateTaskStatus(
//                                       task,
//                                       TaskStatus.done,
//                                     );
//                                     if (!task.isCompleted) {
//                                       context
//                                           .read<CelebrationCubit>()
//                                           .celebrate();
//                                     }
//                                   } else if (value == 'assign') {
//                                     final result = await showModalBottomSheet(
//                                       context: context,
//                                       builder: (_) => MemberSelectorSheet(
//                                         spaceId: task.spaceId!,
//                                         currentAssigneeId: task.assigneeId,
//                                       ),
//                                     );
//                                     if (result != null && context.mounted) {
//                                       if (result == 'unassign') {
//                                         cubit.unassignTask(task);
//                                       } else {
//                                         cubit.assignTaskToUser(task, result);
//                                       }
//                                     }
//                                   }
//                                 },
//                                 child: Padding(
//                                   padding: EdgeInsets.all(AtharSpacing.sm),
//                                   child: _buildStatusIcon(colors, task.status),
//                                 ),
//                                 itemBuilder: (context) => [
//                                   _buildPopupItem(
//                                     colors,
//                                     'status_todo',
//                                     "الانتظار",
//                                     Icons.circle_outlined,
//                                     colors.textTertiary,
//                                   ),
//                                   _buildPopupItem(
//                                     colors,
//                                     'status_progress',
//                                     "التنفيذ",
//                                     Icons.hourglass_top,
//                                     colors.info,
//                                   ),
//                                   _buildPopupItem(
//                                     colors,
//                                     'status_done',
//                                     "مكتملة",
//                                     Icons.check_circle,
//                                     colors.success,
//                                   ),
//                                   if (canAssign) ...[
//                                     const PopupMenuDivider(),
//                                     _buildPopupItem(
//                                       colors,
//                                       'assign',
//                                       "إسناد لموظف",
//                                       Icons.person_add_alt_1,
//                                       colors.secondary,
//                                     ),
//                                   ],
//                                 ],
//                               ),
//                             ),
//                           ),

//                           // العنوان
//                           Expanded(
//                             child: Text(
//                               task.title,
//                               // ✅ AtharTypography
//                               style: AtharTypography.bodyLarge.copyWith(
//                                 decoration: task.isCompleted
//                                     ? TextDecoration.lineThrough
//                                     : null,
//                                 // ✅ AppColors.textSecondary / AppColors.textPrimary
//                                 color: task.isCompleted
//                                     ? colors.textSecondary
//                                     : colors.textPrimary,
//                                 fontWeight: (task.isUrgent || task.isImportant)
//                                     ? FontWeight.bold
//                                     : FontWeight.normal,
//                               ),
//                             ),
//                           ),

//                           // أيقونة القفل
//                           if (!canModify)
//                             Padding(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: AtharSpacing.xxs,
//                               ),
//                               child: Icon(
//                                 Icons.lock_person_outlined,
//                                 size: 14.sp,
//                                 color: colors.textTertiary.withValues(
//                                   alpha: 0.7,
//                                 ),
//                               ),
//                             ),

//                           // زر سحب المهمة
//                           if (isPoolTask && !task.isCompleted)
//                             InkWell(
//                               onTap: () {
//                                 context.read<TaskCubit>().pickupTask(task);
//                                 // ✅ يمكن استخدام AtharSnackbar لاحقاً
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text("💪 كفو! المهمة صارت عندك"),
//                                   ),
//                                 );
//                               },
//                               child: _buildPickupBadge(colors),
//                             ),

//                           // أيقونة المسند إليه
//                           if (!isPoolTask &&
//                               task.spaceId != null &&
//                               !task.isCompleted)
//                             _buildAssigneeAvatar(colors, isAssignedToMe),

//                           // زر المؤقت
//                           if (!task.isCompleted)
//                             InkWell(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         FocusPage(focusTarget: task.title),
//                                   ),
//                                 );
//                               },
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: AtharSpacing.sm,
//                                 ),
//                                 child: Icon(
//                                   Icons.timer_outlined,
//                                   // ✅ AppColors.primary → colors.primary
//                                   color: colors.primary,
//                                   size: 22.sp,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),

//                       // التفاصيل السفلية
//                       Padding(
//                         padding: EdgeInsets.only(right: AtharSpacing.md),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.calendar_today,
//                               size: 10.sp,
//                               color: colors.textTertiary,
//                             ),
//                             // ✅ SizedBox(width: 4.w) → AtharGap.hXxs
//                             AtharGap.hXxs,
//                             Text(
//                               DateFormat('d MMM', 'ar').format(task.date),
//                               // ✅ AtharTypography
//                               style: AtharTypography.labelSmall.copyWith(
//                                 color: colors.textTertiary,
//                               ),
//                             ),
//                             // ✅ SizedBox(width: 8.w) → AtharGap.hSm
//                             AtharGap.hSm,
//                             if (task.isUrgent && !task.isCompleted)
//                               Icon(
//                                 Icons.local_fire_department,
//                                 size: 14.sp,
//                                 // ✅ AppColors.urgent → colors.error
//                                 color: colors.error,
//                               ),
//                             if (task.isImportant && !task.isCompleted)
//                               Icon(
//                                 Icons.star_rounded,
//                                 size: 16.sp,
//                                 color: colors.warning,
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // الشريط الملون
//                 if (ribbonText != null && !task.isCompleted)
//                   _buildRibbon(colors, ribbonText, ribbonColor),
//               ],
//             ),
//           ),
//         );

//         // تغليف المحتوى بالتحكم في النقر
//         Widget tappableContent = GestureDetector(
//           onTap: () {
//             if (onContentTap != null) {
//               onContentTap!();
//             } else {
//               final taskCubit = context.read<TaskCubit>();
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => BlocProvider.value(
//                     value: taskCubit,
//                     child: TaskDetailsPage(task: task),
//                   ),
//                 ),
//               );
//             }
//           },
//           onLongPress: onLongPress,
//           child: cardContent,
//         );

//         // تفعيل السحب للحذف
//         if (enableSwipe && canModify) {
//           return Dismissible(
//             key: Key(task.id.toString()),
//             direction: DismissDirection.endToStart,
//             background: _buildDeleteBackground(colors),
//             onDismissed: (_) => onDelete(),
//             child: tappableContent,
//           );
//         } else {
//           return tappableContent;
//         }
//       },
//     );
//   }

//   // --- دوال بناء الواجهة المساعدة ---

//   Widget _buildStatusIcon(AtharColors colors, TaskStatus status) {
//     switch (status) {
//       case TaskStatus.done:
//         // ✅ Colors.green → colors.success
//         return Icon(Icons.check_circle, color: colors.success, size: 24.sp);
//       case TaskStatus.inProgress:
//         // ✅ Colors.blue → colors.info
//         return Icon(Icons.hourglass_top, color: colors.info, size: 24.sp);
//       case TaskStatus.todo:
//         // ✅ Colors.grey → colors.textTertiary
//         return Icon(
//           Icons.circle_outlined,
//           color: colors.textTertiary,
//           size: 24.sp,
//         );
//     }
//   }

//   PopupMenuItem<String> _buildPopupItem(
//     AtharColors colors,
//     String value,
//     String text,
//     IconData icon,
//     Color color,
//   ) {
//     return PopupMenuItem(
//       value: value,
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 20),
//           // ✅ SizedBox(width: 8) → AtharGap.hSm
//           AtharGap.hSm,
//           Text(
//             text,
//             // ✅ AtharTypography
//             style: AtharTypography.labelMedium.copyWith(
//               color: color,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPickupBadge(AtharColors colors) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
//       padding: EdgeInsets.symmetric(
//         horizontal: AtharSpacing.sm,
//         vertical: AtharSpacing.xxs,
//       ),
//       decoration: BoxDecoration(
//         color: colors.warning.withValues(alpha: 0.1),
//         // ✅ BorderRadius.circular(8) → AtharRadii.sm
//         borderRadius: AtharRadii.radiusSm,
//         border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.back_hand_rounded, size: 14.sp, color: colors.warning),
//           AtharGap.hXxs,
//           Text(
//             "أنا لها",
//             // ✅ AtharTypography
//             style: AtharTypography.labelSmall.copyWith(
//               color: colors.warning,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAssigneeAvatar(AtharColors colors, bool isAssignedToMe) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xxs),
//       child: Tooltip(
//         message: isAssignedToMe ? "مسندة إليك" : "مسندة لعضو آخر",
//         child: CircleAvatar(
//           radius: 12.r,
//           backgroundColor:
//               // ✅ AppColors.primary / Colors.grey.shade300
//               isAssignedToMe ? colors.primary : colors.borderLight,
//           // ✅ Colors.white → colors.onPrimary
//           child: Icon(Icons.person, size: 14.sp, color: colors.onPrimary),
//         ),
//       ),
//     );
//   }

//   Widget _buildRibbon(AtharColors colors, String text, Color? color) {
//     return Positioned(
//       top: 0,
//       left: 0,
//       child: Container(
//         padding: EdgeInsets.symmetric(
//           horizontal: AtharSpacing.sm,
//           vertical: AtharSpacing.xxxs,
//         ),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.only(
//             bottomRight: Radius.circular(AtharSpacing.sm),
//             topLeft: Radius.circular(AtharSpacing.md),
//           ),
//         ),
//         child: Text(
//           text,
//           // ✅ AtharTypography
//           style: AtharTypography.labelSmall.copyWith(
//             color: colors.onPrimary,
//             fontWeight: FontWeight.bold,
//             fontSize: 9.sp,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDeleteBackground(AtharColors colors) {
//     return Container(
//       alignment: Alignment.centerLeft,
//       padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xl),
//       margin: EdgeInsets.symmetric(
//         vertical: AtharSpacing.xs,
//         horizontal: AtharSpacing.lg,
//       ),
//       decoration: BoxDecoration(
//         // ✅ const Color(0xFFFE4A49) → colors.error
//         color: colors.error,
//         borderRadius: AtharRadii.radiusMd,
//       ),
//       // ✅ Colors.white → colors.onPrimary
//       child: Icon(Icons.delete, color: colors.onPrimary),
//     );
//   }
// }
//-----------------------------------------------------------------------
// import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
// import 'package:athar/features/space/presentation/widgets/member_selector_sheet.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/iam/permission_service.dart';
// import '../../../../features/task/data/models/task_model.dart';
// import '../../themes/app_colors.dart';
// import '../../../../features/task/presentation/pages/task_details_page.dart';
// import '../../../../features/focus/presentation/pages/focus_page.dart';

// class TaskTile extends StatelessWidget {
//   final TaskModel task;
//   final Function(bool?) onToggle;
//   final VoidCallback onDelete;
//   final VoidCallback? onLongPress;
//   final bool enableSwipe;
//   final VoidCallback? onContentTap;

//   const TaskTile({
//     super.key,
//     required this.task,
//     required this.onToggle,
//     required this.onDelete,
//     this.onLongPress,
//     this.enableSwipe = true,
//     this.onContentTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final permissionService = getIt<PermissionService>();
//     final currentUserId = Supabase.instance.client.auth.currentUser?.id;

//     // ✅ 1. فحص الصلاحيات الجوهري للتعديل
//     return FutureBuilder<bool>(
//       future: permissionService.hasPermission(
//         'update_core',
//         spaceId: task.spaceId,
//         resourceType: 'task',
//         resourceOwnerId: task.userId,
//       ),
//       builder: (context, snapshot) {
//         final bool canModify = snapshot.data ?? false;

//         // المهام الحرة والمسندة (منطق الواجهة)
//         final isPoolTask = task.spaceId != null && task.assigneeId == null;
//         final isAssignedToMe = task.assigneeId == currentUserId;

//         // هل أستطيع الإسناد؟ (المنشئ أو المسند إليه المسموح له)
//         final canAssign =
//             canModify &&
//             task.spaceId != null &&
//             (task.userId == currentUserId ||
//                 (task.isReassignable && isAssignedToMe));

//         Color? ribbonColor;
//         String? ribbonText;

//         if (!task.isCompleted) {
//           if (task.status == TaskStatus.inProgress) {
//             ribbonColor = Colors.blue;
//             ribbonText = "جاري العمل";
//           } else if (task.status == TaskStatus.todo &&
//               task.createdAt.difference(DateTime.now()).inHours.abs() < 24) {
//             ribbonColor = Colors.green;
//             ribbonText = "جديد";
//           }
//         }

//         // بناء محتوى البطاقة
//         Widget cardContent = Container(
//           margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: isPoolTask
//                   ? Colors.orange.withValues(alpha: 0.5)
//                   : (task.isUrgent && !task.isCompleted
//                         ? AppColors.urgent.withValues(alpha: 0.3)
//                         : Colors.grey.shade200),
//               width: isPoolTask ? 1.5 : 1,
//             ),
//             boxShadow: [
//               if (!task.isCompleted)
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.03),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12.r),
//             child: Stack(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(12.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           // ✅ زر الحالة: يُعطل إذا لم يكن لديه صلاحية تعديل
//                           IgnorePointer(
//                             ignoring: !canModify,
//                             child: Opacity(
//                               opacity: canModify ? 1.0 : 0.5,
//                               child: PopupMenuButton<String>(
//                                 tooltip: "خيارات الحالة",
//                                 onSelected: (value) async {
//                                   final cubit = context.read<TaskCubit>();
//                                   if (value == 'status_todo') {
//                                     cubit.updateTaskStatus(
//                                       task,
//                                       TaskStatus.todo,
//                                     );
//                                   } else if (value == 'status_progress') {
//                                     cubit.updateTaskStatus(
//                                       task,
//                                       TaskStatus.inProgress,
//                                     );
//                                   } else if (value == 'status_done') {
//                                     cubit.updateTaskStatus(
//                                       task,
//                                       TaskStatus.done,
//                                     );
//                                     if (!task.isCompleted) {
//                                       context
//                                           .read<CelebrationCubit>()
//                                           .celebrate();
//                                     }
//                                   } else if (value == 'assign') {
//                                     final result = await showModalBottomSheet(
//                                       context: context,
//                                       builder: (_) => MemberSelectorSheet(
//                                         spaceId: task.spaceId!,
//                                         currentAssigneeId: task.assigneeId,
//                                       ),
//                                     );
//                                     if (result != null && context.mounted) {
//                                       if (result == 'unassign') {
//                                         cubit.unassignTask(task);
//                                       } else {
//                                         cubit.assignTaskToUser(task, result);
//                                       }
//                                     }
//                                   }
//                                 },
//                                 child: Padding(
//                                   padding: EdgeInsets.all(8.w),
//                                   child: _buildStatusIcon(task.status),
//                                 ),
//                                 itemBuilder: (context) => [
//                                   _buildPopupItem(
//                                     'status_todo',
//                                     "الانتظار",
//                                     Icons.circle_outlined,
//                                     Colors.grey,
//                                   ),
//                                   _buildPopupItem(
//                                     'status_progress',
//                                     "التنفيذ",
//                                     Icons.hourglass_top,
//                                     Colors.blue,
//                                   ),
//                                   _buildPopupItem(
//                                     'status_done',
//                                     "مكتملة",
//                                     Icons.check_circle,
//                                     Colors.green,
//                                   ),
//                                   if (canAssign) ...[
//                                     const PopupMenuDivider(),
//                                     _buildPopupItem(
//                                       'assign',
//                                       "إسناد لموظف",
//                                       Icons.person_add_alt_1,
//                                       Colors.purple,
//                                     ),
//                                   ],
//                                 ],
//                               ),
//                             ),
//                           ),

//                           // العنوان
//                           Expanded(
//                             child: Text(
//                               task.title,
//                               style: Theme.of(context).textTheme.bodyLarge
//                                   ?.copyWith(
//                                     decoration: task.isCompleted
//                                         ? TextDecoration.lineThrough
//                                         : null,
//                                     color: task.isCompleted
//                                         ? AppColors.textSecondary
//                                         : AppColors.textPrimary,
//                                     fontWeight:
//                                         (task.isUrgent || task.isImportant)
//                                         ? FontWeight.bold
//                                         : FontWeight.normal,
//                                   ),
//                             ),
//                           ),

//                           // ✅ أيقونة القفل للمهمة للقراءة فقط
//                           if (!canModify)
//                             Padding(
//                               padding: EdgeInsets.symmetric(horizontal: 4.w),
//                               child: Icon(
//                                 Icons.lock_person_outlined,
//                                 size: 14.sp,
//                                 color: Colors.grey.withValues(alpha: 0.7),
//                               ),
//                             ),

//                           // زر سحب المهمة (فقط إذا كانت حرة)
//                           if (isPoolTask && !task.isCompleted)
//                             InkWell(
//                               onTap: () {
//                                 context.read<TaskCubit>().pickupTask(task);
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text("💪 كفو! المهمة صارت عندك"),
//                                   ),
//                                 );
//                               },
//                               child: _buildPickupBadge(),
//                             ),

//                           // أيقونة المسند إليه
//                           if (!isPoolTask &&
//                               task.spaceId != null &&
//                               !task.isCompleted)
//                             _buildAssigneeAvatar(isAssignedToMe),

//                           // زر المؤقت
//                           if (!task.isCompleted)
//                             InkWell(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         FocusPage(focusTarget: task.title),
//                                   ),
//                                 );
//                               },
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 8.w),
//                                 child: Icon(
//                                   Icons.timer_outlined,
//                                   color: AppColors.primary,
//                                   size: 22.sp,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),

//                       // التفاصيل السفلية
//                       Padding(
//                         padding: EdgeInsets.only(right: 12.w),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.calendar_today,
//                               size: 10.sp,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(width: 4.w),
//                             Text(
//                               DateFormat('d MMM', 'ar').format(task.date),
//                               style: TextStyle(
//                                 fontSize: 10.sp,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             SizedBox(width: 8.w),
//                             if (task.isUrgent && !task.isCompleted)
//                               Icon(
//                                 Icons.local_fire_department,
//                                 size: 14.sp,
//                                 color: AppColors.urgent,
//                               ),
//                             if (task.isImportant && !task.isCompleted)
//                               Icon(
//                                 Icons.star_rounded,
//                                 size: 16.sp,
//                                 color: const Color(0xFFF59E0B),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // الشريط الملون (جديد/جاري العمل)
//                 if (ribbonText != null && !task.isCompleted)
//                   _buildRibbon(ribbonText, ribbonColor),
//               ],
//             ),
//           ),
//         );

//         // تغليف المحتوى بالتحكم في النقر
//         Widget tappableContent = GestureDetector(
//           onTap: () {
//             if (onContentTap != null) {
//               onContentTap!();
//             } else {
//               final taskCubit = context.read<TaskCubit>();
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => BlocProvider.value(
//                     value: taskCubit,
//                     child: TaskDetailsPage(task: task),
//                   ),
//                 ),
//               );
//             }
//           },
//           onLongPress: onLongPress,
//           child: cardContent,
//         );

//         // تفعيل السحب للحذف فقط لمن يملك الصلاحية
//         if (enableSwipe && canModify) {
//           return Dismissible(
//             key: Key(task.id.toString()),
//             direction: DismissDirection.endToStart,
//             background: _buildDeleteBackground(),
//             onDismissed: (_) => onDelete(),
//             child: tappableContent,
//           );
//         } else {
//           return tappableContent;
//         }
//       },
//     );
//   }

//   // --- دوال بناء الواجهة المساعدة ---

//   Widget _buildStatusIcon(TaskStatus status) {
//     switch (status) {
//       case TaskStatus.done:
//         return Icon(Icons.check_circle, color: Colors.green, size: 24.sp);
//       case TaskStatus.inProgress:
//         return Icon(Icons.hourglass_top, color: Colors.blue, size: 24.sp);
//       case TaskStatus.todo:
//         return Icon(Icons.circle_outlined, color: Colors.grey, size: 24.sp);
//     }
//   }

//   PopupMenuItem<String> _buildPopupItem(
//     String value,
//     String text,
//     IconData icon,
//     Color color,
//   ) {
//     return PopupMenuItem(
//       value: value,
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 20),
//           SizedBox(width: 8),
//           Text(
//             text,
//             style: TextStyle(color: color, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPickupBadge() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 4.w),
//       padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//       decoration: BoxDecoration(
//         color: Colors.orange.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.orange.shade200),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.back_hand_rounded,
//             size: 14.sp,
//             color: Colors.orange.shade800,
//           ),
//           SizedBox(width: 4.w),
//           Text(
//             "أنا لها",
//             style: TextStyle(
//               fontSize: 10.sp,
//               color: Colors.orange.shade800,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAssigneeAvatar(bool isAssignedToMe) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 4.w),
//       child: Tooltip(
//         message: isAssignedToMe ? "مسندة إليك" : "مسندة لعضو آخر",
//         child: CircleAvatar(
//           radius: 12.r,
//           backgroundColor: isAssignedToMe
//               ? AppColors.primary
//               : Colors.grey.shade300,
//           child: Icon(Icons.person, size: 14.sp, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   Widget _buildRibbon(String text, Color? color) {
//     return Positioned(
//       top: 0,
//       left: 0,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.only(
//             bottomRight: Radius.circular(8.r),
//             topLeft: Radius.circular(12.r),
//           ),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 9.sp,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDeleteBackground() {
//     return Container(
//       alignment: Alignment.centerLeft,
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
//       decoration: BoxDecoration(
//         color: const Color(0xFFFE4A49),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: const Icon(Icons.delete, color: Colors.white),
//     );
//   }
// }

// import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../../../features/task/data/models/task_model.dart';
// import '../../theme/app_colors.dart';
// import '../../../../features/task/presentation/pages/task_details_page.dart';
// import '../../../../features/focus/presentation/pages/focus_page.dart';

// class TaskTile extends StatelessWidget {
//   final TaskModel task;
//   final Function(bool?) onToggle;
//   final VoidCallback onDelete;
//   final VoidCallback? onLongPress;

//   const TaskTile({
//     super.key,
//     required this.task,
//     required this.onToggle,
//     required this.onDelete,
//     this.onLongPress,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ❌ تم حذف كود استدعاء المشروع القديم لأنه لم يعد موجوداً

//     // تحديد لون وحالة الشريط (Ribbon)
//     Color? ribbonColor;
//     String? ribbonText;

//     if (!task.isCompleted) {
//       if (task.status == TaskStatus.inProgress) {
//         ribbonColor = Colors.blue;
//         ribbonText = "جاري العمل";
//       } else if (task.status == TaskStatus.todo &&
//           task.createdAt.difference(DateTime.now()).inHours.abs() < 24) {
//         // إذا كانت المهمة مضافة خلال 24 ساعة ولم يبدأ بها
//         ribbonColor = Colors.green;
//         ribbonText = "جديد";
//       }
//     }

//     return Dismissible(
//       key: Key(task.id.toString()),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         alignment: Alignment.centerLeft,
//         padding: EdgeInsets.symmetric(horizontal: 20.w),
//         margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFE4A49),
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       onDismissed: (_) => onDelete(),
//       child: GestureDetector(
//         onTap: () {
//           // 1. التقاط الكيوبت الحالي قبل الانتقال
//           final taskCubit = context.read<TaskCubit>();

//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => BlocProvider.value(
//                 // 2. تمرير الكيوبت للصفحة الجديدة لتجنب خطأ ProviderNotFound
//                 value: taskCubit,
//                 child: TaskDetailsPage(task: task),
//               ),
//             ),
//           );
//         },
//         onLongPress: onLongPress,
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: task.isUrgent && !task.isCompleted
//                   ? AppColors.urgent.withOpacity(0.3)
//                   : Colors.grey.shade200,
//               width: 1,
//             ),
//             boxShadow: [
//               if (!task.isCompleted)
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.03),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12.r),
//             child: Stack(
//               children: [
//                 // المحتوى الرئيسي
//                 Padding(
//                   padding: EdgeInsets.all(12.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ❌ تم حذف قسم عرض اسم المشروع القديم من هنا
//                       Row(
//                         children: [
//                           // 1. زر تغيير الحالة (PopupMenuButton)
//                           PopupMenuButton<TaskStatus>(
//                             tooltip: "تغيير الحالة",
//                             initialValue: task.status,
//                             onSelected: (status) {
//                               // نحتاج لاستدعاء دالة تحديث الحالة في الكيوبت
//                               context.read<TaskCubit>().updateTaskStatus(
//                                 task,
//                                 status,
//                               );

//                               // إذا اختار مكتمل، نشغل الاحتفال
//                               if (status == TaskStatus.done &&
//                                   !task.isCompleted) {
//                                 context.read<CelebrationCubit>().celebrate();
//                               }
//                             },
//                             child: Padding(
//                               padding: EdgeInsets.all(8.w),
//                               child: _buildStatusIcon(task.status),
//                             ),
//                             itemBuilder: (context) => [
//                               _buildPopupItem(
//                                 TaskStatus.todo,
//                                 "قائمة الانتظار",
//                                 Icons.circle_outlined,
//                                 Colors.grey,
//                               ),
//                               _buildPopupItem(
//                                 TaskStatus.inProgress,
//                                 "جاري التنفيذ",
//                                 Icons.hourglass_top,
//                                 Colors.blue,
//                               ),
//                               _buildPopupItem(
//                                 TaskStatus.done,
//                                 "مكتملة",
//                                 Icons.check_circle,
//                                 Colors.green,
//                               ),
//                             ],
//                           ),

//                           // العنوان
//                           Expanded(
//                             child: Text(
//                               task.title,
//                               style: Theme.of(context).textTheme.bodyLarge
//                                   ?.copyWith(
//                                     decoration: task.isCompleted
//                                         ? TextDecoration.lineThrough
//                                         : null,
//                                     color: task.isCompleted
//                                         ? AppColors.textSecondary
//                                         : AppColors.textPrimary,
//                                     fontWeight:
//                                         (task.isUrgent || task.isImportant)
//                                         ? FontWeight.bold
//                                         : FontWeight.normal,
//                                   ),
//                             ),
//                           ),

//                           // زر المؤقت (فقط إذا لم تكتمل)
//                           if (!task.isCompleted)
//                             InkWell(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         FocusPage(focusTarget: task.title),
//                                   ),
//                                 );
//                               },
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 8.w),
//                                 child: Icon(
//                                   Icons.timer_outlined,
//                                   color: AppColors.primary,
//                                   size: 22.sp,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),

//                       // تفاصيل سفلية (التاريخ والأيقونات)
//                       Padding(
//                         padding: EdgeInsets.only(right: 12.w), // محاذاة مع النص
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.calendar_today,
//                               size: 10.sp,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(width: 4.w),
//                             Text(
//                               DateFormat('d MMM', 'ar').format(task.date),
//                               style: TextStyle(
//                                 fontSize: 10.sp,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             SizedBox(width: 8.w),

//                             // عاجل / مهم
//                             if (task.isUrgent && !task.isCompleted)
//                               Icon(
//                                 Icons.local_fire_department,
//                                 size: 14.sp,
//                                 color: AppColors.urgent,
//                               ),
//                             if (task.isImportant && !task.isCompleted)
//                               Icon(
//                                 Icons.star_rounded,
//                                 size: 16.sp,
//                                 color: const Color(0xFFF59E0B),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // 2. الشريط الزاوي (Ribbon)
//                 if (ribbonText != null && !task.isCompleted)
//                   Positioned(
//                     top: 0,
//                     left: 0, // في الزاوية اليسرى العلوية (لأن التطبيق عربي RTL)
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 8.w,
//                         vertical: 2.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: ribbonColor,
//                         borderRadius: BorderRadius.only(
//                           bottomRight: Radius.circular(8.r),
//                           topLeft: Radius.circular(12.r), // تدوير يطابق الحاوية
//                         ),
//                       ),
//                       child: Text(
//                         ribbonText,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 9.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // دوال مساعدة داخل TaskTile
//   Widget _buildStatusIcon(TaskStatus status) {
//     switch (status) {
//       case TaskStatus.done:
//         return Icon(Icons.check_circle, color: Colors.green, size: 24.sp);
//       case TaskStatus.inProgress:
//         return Icon(Icons.hourglass_top, color: Colors.blue, size: 24.sp);
//       case TaskStatus.todo:
//         return Icon(Icons.circle_outlined, color: Colors.grey, size: 24.sp);
//     }
//   }

//   PopupMenuItem<TaskStatus> _buildPopupItem(
//     TaskStatus value,
//     String text,
//     IconData icon,
//     Color color,
//   ) {
//     return PopupMenuItem(
//       value: value,
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 20),
//           SizedBox(width: 8),
//           Text(
//             text,
//             style: TextStyle(color: color, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../../../features/task/data/models/task_model.dart';
// import '../../theme/app_colors.dart';
// import '../../../../features/task/presentation/pages/task_details_page.dart';
// import '../../../../features/focus/presentation/pages/focus_page.dart';

// class TaskTile extends StatelessWidget {
//   final TaskModel task;
//   final Function(bool?) onToggle;
//   final VoidCallback onDelete;
//   final VoidCallback? onLongPress;

//   const TaskTile({
//     super.key,
//     required this.task,
//     required this.onToggle,
//     required this.onDelete,
//     this.onLongPress,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // تحميل المشروع (Isar Link)
//     // final project = task.project.value;

//     // تحديد لون وحالة الشريط (Ribbon)
//     Color? ribbonColor;
//     String? ribbonText;

//     if (!task.isCompleted) {
//       if (task.status == TaskStatus.inProgress) {
//         ribbonColor = Colors.blue;
//         ribbonText = "جاري العمل";
//       } else if (task.status == TaskStatus.todo &&
//           task.createdAt.difference(DateTime.now()).inHours.abs() < 24) {
//         // إذا كانت المهمة مضافة خلال 24 ساعة ولم يبدأ بها
//         ribbonColor = Colors.green;
//         ribbonText = "جديد";
//       }
//     }

//     return Dismissible(
//       key: Key(task.id.toString()),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         alignment: Alignment.centerLeft,
//         padding: EdgeInsets.symmetric(horizontal: 20.w),
//         margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
//         decoration: BoxDecoration(
//           color: const Color(0xFFFE4A49),
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: const Icon(Icons.delete, color: Colors.white),
//       ),
//       onDismissed: (_) => onDelete(),
//       child: GestureDetector(
//         onTap: () {
//           // 1. التقاط الكيوبت الحالي قبل الانتقال
//           final taskCubit = context.read<TaskCubit>();

//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => BlocProvider.value(
//                 // 2. تمرير الكيوبت للصفحة الجديدة لتجنب خطأ ProviderNotFound
//                 value: taskCubit,
//                 child: TaskDetailsPage(task: task),
//               ),
//             ),
//           );
//         },
//         onLongPress: onLongPress,
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//               color: task.isUrgent && !task.isCompleted
//                   ? AppColors.urgent.withValues(alpha: 0.3)
//                   : Colors.grey.shade200,
//               width: 1,
//             ),
//             boxShadow: [
//               if (!task.isCompleted)
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.03),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12.r),
//             child: Stack(
//               children: [
//                 // المحتوى الرئيسي
//                 Padding(
//                   padding: EdgeInsets.all(12.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // 1. اسم المشروع (في الأعلى ومنفصل)
//                       if (project != null)
//                         Padding(
//                           padding: EdgeInsets.only(
//                             bottom: 6.h,
//                             left: 20.w,
//                           ), // ترك مسافة للشريط
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.folder_open_rounded,
//                                 size: 12.sp,
//                                 color: Color(project.colorValue ?? 0xFF4CAF50),
//                               ),
//                               SizedBox(width: 4.w),
//                               Text(
//                                 project.title,
//                                 style: TextStyle(
//                                   fontSize: 10.sp,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(
//                                     project.colorValue ?? 0xFF4CAF50,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                       Row(
//                         children: [
//                           // 1. زر تغيير الحالة (بديل أو مساعد للـ Checkbox)
//                           // بدلاً من Checkbox عادي، نستخدم PopupMenu لتغيير الحالة
//                           PopupMenuButton<TaskStatus>(
//                             tooltip: "تغيير الحالة",
//                             initialValue: task.status,
//                             onSelected: (status) {
//                               // نحتاج لاستدعاء دالة تحديث الحالة في الكيوبت
//                               context.read<TaskCubit>().updateTaskStatus(
//                                 task,
//                                 status,
//                               );

//                               // إذا اختار مكتمل، نشغل الاحتفال
//                               if (status == TaskStatus.done &&
//                                   !task.isCompleted) {
//                                 context.read<CelebrationCubit>().celebrate();
//                                 // وتحديث isCompleted أيضاً (الكيوبت سيتكفل بذلك بناء على تعديلنا السابق للريبوزيتوري)
//                               }
//                             },
//                             child: Padding(
//                               padding: EdgeInsets.all(8.w),
//                               child: _buildStatusIcon(task.status),
//                             ),
//                             itemBuilder: (context) => [
//                               _buildPopupItem(
//                                 TaskStatus.todo,
//                                 "قائمة الانتظار",
//                                 Icons.circle_outlined,
//                                 Colors.grey,
//                               ),
//                               _buildPopupItem(
//                                 TaskStatus.inProgress,
//                                 "جاري التنفيذ",
//                                 Icons.hourglass_top,
//                                 Colors.blue,
//                               ),
//                               _buildPopupItem(
//                                 TaskStatus.done,
//                                 "مكتملة",
//                                 Icons.check_circle,
//                                 Colors.green,
//                               ),
//                             ],
//                           ),
//                           // Checkbox
//                           // Transform.scale(
//                           //   scale: 1.1,
//                           //   child: Checkbox(
//                           //     value: task.isCompleted,
//                           //     activeColor: AppColors.secondary,
//                           //     shape: RoundedRectangleBorder(
//                           //       borderRadius: BorderRadius.circular(4),
//                           //     ),
//                           //     side: BorderSide(
//                           //       color: task.isUrgent && !task.isCompleted
//                           //           ? AppColors.urgent
//                           //           : Colors.grey.shade400,
//                           //       width: 1.5,
//                           //     ),
//                           //     onChanged: onToggle,
//                           //   ),
//                           // ),

//                           // العنوان
//                           Expanded(
//                             child: Text(
//                               task.title,
//                               style: Theme.of(context).textTheme.bodyLarge
//                                   ?.copyWith(
//                                     decoration: task.isCompleted
//                                         ? TextDecoration.lineThrough
//                                         : null,
//                                     color: task.isCompleted
//                                         ? AppColors.textSecondary
//                                         : AppColors.textPrimary,
//                                     fontWeight:
//                                         (task.isUrgent || task.isImportant)
//                                         ? FontWeight.bold
//                                         : FontWeight.normal,
//                                   ),
//                             ),
//                           ),

//                           // زر المؤقت (فقط إذا لم تكتمل)
//                           if (!task.isCompleted)
//                             InkWell(
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         FocusPage(focusTarget: task.title),
//                                   ),
//                                 );
//                               },
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 8.w),
//                                 child: Icon(
//                                   Icons.timer_outlined,
//                                   color: AppColors.primary,
//                                   size: 22.sp,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),

//                       // تفاصيل سفلية (التاريخ والأيقونات)
//                       Padding(
//                         padding: EdgeInsets.only(right: 12.w), // محاذاة مع النص
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.calendar_today,
//                               size: 10.sp,
//                               color: Colors.grey,
//                             ),
//                             SizedBox(width: 4.w),
//                             Text(
//                               DateFormat('d MMM', 'ar').format(task.date),
//                               style: TextStyle(
//                                 fontSize: 10.sp,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             SizedBox(width: 8.w),

//                             // عاجل / مهم
//                             if (task.isUrgent && !task.isCompleted)
//                               Icon(
//                                 Icons.local_fire_department,
//                                 size: 14.sp,
//                                 color: AppColors.urgent,
//                               ),
//                             if (task.isImportant && !task.isCompleted)
//                               Icon(
//                                 Icons.star_rounded,
//                                 size: 16.sp,
//                                 color: const Color(0xFFF59E0B),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // 2. الشريط الزاوي (Ribbon)
//                 if (ribbonText != null && !task.isCompleted)
//                   Positioned(
//                     top: 0,
//                     left: 0, // في الزاوية اليسرى العلوية (لأن التطبيق عربي RTL)
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 8.w,
//                         vertical: 2.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: ribbonColor,
//                         borderRadius: BorderRadius.only(
//                           bottomRight: Radius.circular(8.r),
//                           topLeft: Radius.circular(12.r), // تدوير يطابق الحاوية
//                         ),
//                       ),
//                       child: Text(
//                         ribbonText,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 9.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // دوال مساعدة داخل TaskTile
//   Widget _buildStatusIcon(TaskStatus status) {
//     switch (status) {
//       case TaskStatus.done:
//         return Icon(Icons.check_circle, color: Colors.green, size: 24.sp);
//       case TaskStatus.inProgress:
//         return Icon(Icons.hourglass_top, color: Colors.blue, size: 24.sp);
//       case TaskStatus.todo:
//         return Icon(Icons.circle_outlined, color: Colors.grey, size: 24.sp);
//     }
//   }

//   PopupMenuItem<TaskStatus> _buildPopupItem(
//     TaskStatus value,
//     String text,
//     IconData icon,
//     Color color,
//   ) {
//     return PopupMenuItem(
//       value: value,
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 20),
//           SizedBox(width: 8),
//           Text(
//             text,
//             style: TextStyle(color: color, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../../../features/task/data/models/task_model.dart';
// import '../../theme/app_colors.dart';
// // استيراد صفحة التركيز
// import '../../../../features/focus/presentation/pages/focus_page.dart';
// import '../../../../features/task/presentation/pages/task_details_page.dart';

// class TaskTile extends StatelessWidget {
//   final TaskModel task;
//   final Function(bool?) onToggle;
//   final VoidCallback onDelete;
//   final VoidCallback? onLongPress; // أعدنا الـ onLongPress

//   const TaskTile({
//     super.key,
//     required this.task,
//     required this.onToggle,
//     required this.onDelete,
//     this.onLongPress,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // 1. منطق الألوان والأولويات (من الكود القديم)
//     Color tileColor = AppColors.surface;
//     Color borderColor = Colors.transparent;

//     if (!task.isCompleted) {
//       if (task.isUrgent && task.isImportant) {
//         tileColor = const Color(0xFFFEF2F2);
//         borderColor = AppColors.urgent;
//       } else if (task.isUrgent) {
//         tileColor = const Color(0xFFFEF2F2);
//         borderColor = AppColors.urgent.withValues(alpha: 0.3);
//       } else if (task.isImportant) {
//         tileColor = const Color(0xFFFFFBEB);
//         borderColor = const Color(0xFFF59E0B).withValues(alpha: 0.3);
//       }
//     }

//     // ✅ التأكد من تحميل بيانات المشروع (لأن IsarLinks كسولة التحميل)
//     // ملاحظة: Isar يقوم بتحميل الرابط تلقائياً عند الوصول إليه إذا تم استخدام load()،
//     // ولكن في القوائم السريعة، نعتمد على أن البيانات قد تكون متوفرة.
//     final project = task.project.value;

//     return Opacity(
//       opacity: task.isCompleted ? 0.6 : 1.0, // شفافية أقل للإنجاز
//       child: Dismissible(
//         key: Key(task.id.toString()),
//         direction: DismissDirection.endToStart,
//         background: Container(
//           alignment: Alignment.centerLeft,
//           padding: EdgeInsets.symmetric(horizontal: 20.w),
//           margin: EdgeInsets.symmetric(vertical: 6.h), // محاذاة الخلفية
//           decoration: BoxDecoration(
//             color: const Color(0xFFFE4A49),
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           child: const Icon(Icons.delete, color: Colors.white),
//         ),
//         onDismissed: (_) => onDelete(),
//         child: Container(
//           margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
//           decoration: BoxDecoration(
//             color: tileColor,
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: borderColor, width: 1),
//             boxShadow: [
//               if (!task.isCompleted)
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.03),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//             ],
//           ),
//           child: ListTile(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => TaskDetailsPage(task: task),
//                 ),
//               );
//             },
//             onLongPress: onLongPress, // تفعيل الضغط الطويل
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 12.w,
//               vertical: 4.h,
//             ),

//             // Checkbox
//             leading: Transform.scale(
//               scale: 1.1,
//               child: Checkbox(
//                 value: task.isCompleted,
//                 activeColor: AppColors.secondary,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 side: BorderSide(
//                   color: task.isUrgent && !task.isCompleted
//                       ? AppColors.urgent
//                       : Colors.grey.shade400,
//                   width: 1.5,
//                 ),
//                 onChanged: onToggle,
//               ),
//             ),

//             // العنوان
//             title: Text(
//               task.title,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                 decoration: task.isCompleted
//                     ? TextDecoration.lineThrough
//                     : null,
//                 decorationColor: AppColors.urgent,
//                 decorationThickness: 2,
//                 color: task.isCompleted
//                     ? AppColors.textSecondary
//                     : AppColors.textPrimary,
//                 fontWeight: (task.isUrgent || task.isImportant)
//                     ? FontWeight.bold
//                     : FontWeight.normal,
//               ),
//             ),

//             // التفاصيل (التاريخ، التاقات)
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 6.h),
//                 // --- التعديل هنا: إضافة SingleChildScrollView ---
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal, // السماح بالتمرير الأفقي
//                   child: Row(
//                     children: [
//                       // 1. عرض المشروع (الإضافة الجديدة ✨)
//                       if (project != null) ...[
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 8.w,
//                             vertical: 2.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Color(
//                               project.colorValue ?? 0xFF4CAF50,
//                             ).withValues(alpha: 0.1),
//                             borderRadius: BorderRadius.circular(4.r),
//                             border: Border.all(
//                               color: Color(
//                                 project.colorValue ?? 0xFF4CAF50,
//                               ).withValues(alpha: 0.3),
//                               width: 0.5,
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(
//                                 Icons.folder_rounded,
//                                 size: 10.sp,
//                                 color: Color(project.colorValue ?? 0xFF4CAF50),
//                               ),
//                               SizedBox(width: 4.w),
//                               Text(
//                                 project.title,
//                                 style: TextStyle(
//                                   fontSize: 10.sp,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(
//                                     project.colorValue ?? 0xFF4CAF50,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(width: 6.w),
//                       ],
//                       // Date
//                       if (task.dueDate != null) ...[
//                         Icon(
//                           Icons.access_time,
//                           size: 12.sp,
//                           color: Colors.grey,
//                         ),
//                         SizedBox(width: 4.w),
//                         Text(
//                           DateFormat(
//                             'd MMM • h:mm a',
//                             'ar',
//                           ).format(task.dueDate!),
//                           style: Theme.of(
//                             context,
//                           ).textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
//                         ),
//                       ],
//                       SizedBox(width: 8.w),
//                       // ✅ الإضافة الجديدة: تاق "جاري العمل"
//                       if (task.status == TaskStatus.inProgress &&
//                           !task.isCompleted) ...[
//                         _buildTag(
//                           icon: Icons
//                               .hourglass_top_rounded, // أو play_circle_outline
//                           label: "جاري العمل",
//                           color: Colors.blue, // لون مميز للحالة
//                         ),
//                         SizedBox(width: 4.w),
//                       ],

//                       // Urgent Tag
//                       if (task.isUrgent && !task.isCompleted) ...[
//                         _buildTag(
//                           icon: Icons.local_fire_department,
//                           label: "عاجل",
//                           color: AppColors.urgent,
//                         ),
//                         // Container(
//                         //   padding: EdgeInsets.symmetric(
//                         //     horizontal: 6.w,
//                         //     vertical: 2.h,
//                         //   ),
//                         //   decoration: BoxDecoration(
//                         //     color: AppColors.urgent.withOpacity(0.1),
//                         //     borderRadius: BorderRadius.circular(4),
//                         //   ),
//                         //   child: Row(
//                         //     children: [
//                         //       Icon(
//                         //         Icons.local_fire_department,
//                         //         size: 12.sp,
//                         //         color: AppColors.urgent,
//                         //       ),
//                         //       SizedBox(width: 2.w),
//                         //       Text(
//                         //         "عاجل",
//                         //         style: TextStyle(
//                         //           color: AppColors.urgent,
//                         //           fontSize: 10.sp,
//                         //           fontWeight: FontWeight.bold,
//                         //         ),
//                         //       ),
//                         //     ],
//                         //   ),
//                         // ),
//                         SizedBox(width: 4.w),
//                       ],

//                       // Important Star
//                       if (task.isImportant && !task.isCompleted) ...[
//                         Icon(
//                           Icons.star,
//                           size: 14.sp,
//                           color: const Color(0xFFF59E0B),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 // ---------------------------------------------

//                 // Duration Indicator (if exists)
//                 if (task.durationMinutes != null && task.durationMinutes! > 0)
//                   Padding(
//                     padding: EdgeInsets.only(top: 4.h),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.timer_outlined,
//                           size: 12.sp,
//                           color: Colors.blueGrey,
//                         ),
//                         SizedBox(width: 4.w),
//                         Text(
//                           "${task.durationMinutes} دقيقة",
//                           style: TextStyle(
//                             color: Colors.blueGrey,
//                             fontSize: 10.sp,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),

//             // --- الجزء الجديد: زر المؤقت + أيقونة السياق ---
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min, // مهم جداً داخل ListTile
//               children: [
//                 // 1. زر المؤقت (يظهر فقط للمهام غير المكتملة)
//                 if (!task.isCompleted)
//                   Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       borderRadius: BorderRadius.circular(20),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 FocusPage(focusTarget: task.title),
//                           ),
//                         );
//                       },
//                       child: Padding(
//                         padding: EdgeInsets.all(8.w),
//                         child: Icon(
//                           Icons.timer_outlined,
//                           color: AppColors.primary,
//                           size: 24.sp,
//                         ),
//                       ),
//                     ),
//                   ),

//                 SizedBox(width: 4.w),

//                 // 2. مؤشر السياق (Context)
//                 _buildContextIndicator(task.context),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // دالة مساعدة لرسم التاق
//   Widget _buildTag({
//     required IconData icon,
//     required String label,
//     required Color color,
//   }) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min, // مهم جداً
//         children: [
//           Icon(icon, size: 10.sp, color: color),
//           SizedBox(width: 2.w),
//           Text(
//             label,
//             style: TextStyle(
//               color: color,
//               fontSize: 10.sp,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildContextIndicator(TaskContext context) {
//     Color color;
//     IconData icon;

//     switch (context) {
//       case TaskContext.work:
//         color = Colors.purpleAccent;
//         icon = Icons.work;
//         break;
//       case TaskContext.home:
//         color = Colors.orangeAccent;
//         icon = Icons.home;
//         break;
//       case TaskContext.personal:
//         color = Colors.teal;
//         icon = Icons.person;
//         break;
//       case TaskContext.freelance:
//         color = Colors.blueAccent;
//         icon = Icons.rocket_launch;
//         break;
//       default:
//         color = Colors.grey;
//         icon = Icons.circle;
//     }

//     return Container(
//       padding: EdgeInsets.all(8.w),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.1),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(icon, color: color, size: 18.sp),
//     );
//   }
// }
