import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
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
          Colors.blueAccent,
          inProgressTasks,
          TaskStatus.inProgress,
        ),
        _buildColumn(
          context,
          colorScheme,
          l10n.kanbanDone,
          const Color(0xFF00B894),
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
//-----------------------------------------------------------------------
// // lib/core/design_system/molecules/board/kanban_board.dart
// // ═══════════════════════════════════════════════════════════════════
// // ✅ MIGRATED TO ATHAR DESIGN SYSTEM - Phase 5 (Stage 1.1)
// // ═══════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Design System Import
// import 'package:athar/core/design_system/design_system.dart';
// // ❌ REMOVED: import 'package:athar/core/design_system/themes/app_colors.dart';

// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/core/design_system/molecules/tiles/task_tile.dart';

// class KanbanBoard extends StatefulWidget {
//   final List<TaskModel> tasks;
//   final Function(int taskId, TaskStatus newStatus) onStatusChanged;
//   final Function(TaskModel task) onTaskTap;
//   final Function(TaskModel task) onDelete;

//   const KanbanBoard({
//     super.key,
//     required this.tasks,
//     required this.onStatusChanged,
//     required this.onTaskTap,
//     required this.onDelete,
//   });

//   @override
//   State<KanbanBoard> createState() => _KanbanBoardState();
// }

// class _KanbanBoardState extends State<KanbanBoard> {
//   final PageController _pageController = PageController(viewportFraction: 0.85);

//   @override
//   Widget build(BuildContext context) {
//     // ✅ الحصول على الألوان من context
//     final colors = context.colors;

//     final todoTasks = widget.tasks
//         .where((t) => t.status == TaskStatus.todo)
//         .toList();
//     final inProgressTasks = widget.tasks
//         .where((t) => t.status == TaskStatus.inProgress)
//         .toList();
//     final doneTasks = widget.tasks
//         .where((t) => t.status == TaskStatus.done)
//         .toList();

//     return PageView(
//       controller: _pageController,
//       children: [
//         _buildColumn(
//           context,
//           colors,
//           "للقيام به",
//           colors.textTertiary, // ✅ بدلاً من Colors.grey
//           todoTasks,
//           TaskStatus.todo,
//         ),
//         _buildColumn(
//           context,
//           colors,
//           "جاري العمل",
//           colors.info, // ✅ بدلاً من Colors.blue
//           inProgressTasks,
//           TaskStatus.inProgress,
//         ),
//         _buildColumn(
//           context,
//           colors,
//           "مكتمل",
//           colors.success, // ✅ بدلاً من Colors.green
//           doneTasks,
//           TaskStatus.done,
//         ),
//       ],
//     );
//   }

//   Widget _buildColumn(
//     BuildContext context,
//     AtharColors colors,
//     String title,
//     Color color,
//     List<TaskModel> tasks,
//     TaskStatus status,
//   ) {
//     return DragTarget<int>(
//       onWillAcceptWithDetails: (_) => true,
//       onAcceptWithDetails: (details) {
//         widget.onStatusChanged(details.data, status);
//       },
//       builder: (context, candidateData, rejectedData) {
//         return Container(
//           // ✅ بدلاً من EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h)
//           margin: EdgeInsets.symmetric(
//             horizontal: AtharSpacing.sm,
//             vertical: AtharSpacing.xxs,
//           ),
//           // ✅ بدلاً من EdgeInsets.all(12.w)
//           padding: AtharSpacing.allMd,
//           decoration: BoxDecoration(
//             // ✅ بدلاً من Colors.grey.shade50
//             color: colors.background,
//             // ✅ BorderRadius.circular(16.r) → AtharRadii.radiusLg
//             borderRadius: AtharRadii.radiusLg,
//             border: candidateData.isNotEmpty
//                 // ✅ بدلاً من AppColors.primary
//                 ? Border.all(color: colors.primary, width: 2)
//                 : null,
//           ),
//           child: Column(
//             children: [
//               // Header
//               Row(
//                 children: [
//                   Container(
//                     width: 12.w,
//                     height: 12.w,
//                     decoration: BoxDecoration(
//                       color: color,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   // ✅ بدلاً من SizedBox(width: 8.w)
//                   AtharGap.hSm,
//                   Text(
//                     title,
//                     // ✅ بدلاً من TextStyle hardcoded
//                     style: AtharTypography.titleMedium.copyWith(
//                       color: colors.textPrimary,
//                     ),
//                   ),
//                   const Spacer(),
//                   Container(
//                     // ✅ بدلاً من EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h)
//                     padding: EdgeInsets.symmetric(
//                       horizontal: AtharSpacing.sm,
//                       vertical: AtharSpacing.xxxs,
//                     ),
//                     decoration: BoxDecoration(
//                       // ✅ بدلاً من Colors.white
//                       color: colors.surface,
//                       // ✅ BorderRadius.circular(10) → AtharRadii.radiusSm
//                       borderRadius: AtharRadii.radiusSm,
//                     ),
//                     child: Text(
//                       "${tasks.length}",
//                       // ✅ بدلاً من TextStyle hardcoded
//                       style: AtharTypography.labelMedium.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: colors.textPrimary,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               // ✅ بدلاً من Divider(height: 24.h)
//               Divider(height: AtharSpacing.xxl, color: colors.divider),

//               // Tasks List
//               Expanded(
//                 child: tasks.isEmpty
//                     ? Center(
//                         child: Text(
//                           "اسحب المهام هنا",
//                           // ✅ بدلاً من TextStyle hardcoded
//                           style: AtharTypography.bodySmall.copyWith(
//                             color: colors.textTertiary,
//                           ),
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: tasks.length,
//                         itemBuilder: (context, index) {
//                           final task = tasks[index];
//                           return Draggable<int>(
//                             data: task.id,
//                             feedback: SizedBox(
//                               width: 280.w,
//                               child: Material(
//                                 color: Colors.transparent,
//                                 child: Opacity(
//                                   opacity: 0.9,
//                                   child: IgnorePointer(
//                                     child: TaskTile(
//                                       task: task,
//                                       onToggle: (_) {},
//                                       onDelete: () {},
//                                       enableSwipe: false,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             childWhenDragging: Opacity(
//                               opacity: 0.3,
//                               child: TaskTile(
//                                 task: task,
//                                 onToggle: (_) {},
//                                 onDelete: () {},
//                                 enableSwipe: false,
//                               ),
//                             ),
//                             child: TaskTile(
//                               task: task,
//                               enableSwipe: false,
//                               onContentTap: () => widget.onTaskTap(task),
//                               onToggle: (_) => widget.onStatusChanged(
//                                 task.id,
//                                 TaskStatus.done,
//                               ),
//                               onDelete: () => widget.onDelete(task),
//                             ),
//                           );
//                         },
//                       ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//-----------------------------------------------------------------------
// ═══════════════════════════════════════════════════════════════════
// 📋 ملخص التغييرات:
// ═══════════════════════════════════════════════════════════════════
//
// 1. IMPORTS:
//    ❌ import 'package:athar/core/design_system/themes/app_colors.dart';
//    ✅ import 'package:athar/core/design_system/design_system.dart';
//
// 2. COLORS:
//    ❌ Colors.grey → ✅ colors.textTertiary
//    ❌ Colors.blue → ✅ colors.info
//    ❌ Colors.green → ✅ colors.success
//    ❌ Colors.grey.shade50 → ✅ colors.background
//    ❌ Colors.white → ✅ colors.surface
//    ❌ Colors.grey.shade400 → ✅ colors.textTertiary
//    ❌ AppColors.primary → ✅ colors.primary
//
// 3. SPACING:
//    ❌ EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h)
//    ✅ EdgeInsets.symmetric(horizontal: AtharSpacing.sm, vertical: AtharSpacing.xxs)
//
//    ❌ EdgeInsets.all(12.w) → ✅ AtharSpacing.allMd
//    ❌ SizedBox(width: 8.w) → ✅ AtharGap.hSm
//    ❌ Divider(height: 24.h) → ✅ Divider(height: AtharSpacing.xxl)
//
// 4. BORDERS:
//    ❌ BorderRadius.circular(16.r) → ✅ AtharRadii.radiusLg
//    ❌ BorderRadius.circular(10) → ✅ AtharRadii.radiusSm
//
// 5. TYPOGRAPHY:
//    ❌ TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, fontFamily: 'Tajawal')
//    ✅ AtharTypography.titleMedium.copyWith(color: colors.textPrimary)
//
//    ❌ TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)
//    ✅ AtharTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)
//
//    ❌ TextStyle(color: Colors.grey.shade400, fontSize: 12.sp, fontFamily: 'Tajawal')
//    ✅ AtharTypography.bodySmall.copyWith(color: colors.textTertiary)
//
// ═══════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/core/design_system/molecules/tiles/task_tile.dart';

// class KanbanBoard extends StatefulWidget {
//   final List<TaskModel> tasks;
//   final Function(int taskId, TaskStatus newStatus) onStatusChanged;
//   final Function(TaskModel task) onTaskTap; // للنقر (فتح التفاصيل)
//   final Function(TaskModel task) onDelete;

//   const KanbanBoard({
//     super.key,
//     required this.tasks,
//     required this.onStatusChanged,
//     required this.onTaskTap,
//     required this.onDelete,
//   });

//   @override
//   State<KanbanBoard> createState() => _KanbanBoardState();
// }

// class _KanbanBoardState extends State<KanbanBoard> {
//   final PageController _pageController = PageController(viewportFraction: 0.85);

//   @override
//   Widget build(BuildContext context) {
//     final todoTasks = widget.tasks
//         .where((t) => t.status == TaskStatus.todo)
//         .toList();
//     final inProgressTasks = widget.tasks
//         .where((t) => t.status == TaskStatus.inProgress)
//         .toList();
//     final doneTasks = widget.tasks
//         .where((t) => t.status == TaskStatus.done)
//         .toList();

//     return PageView(
//       controller: _pageController,
//       children: [
//         _buildColumn("للقيام به", Colors.grey, todoTasks, TaskStatus.todo),
//         _buildColumn(
//           "جاري العمل",
//           Colors.blue,
//           inProgressTasks,
//           TaskStatus.inProgress,
//         ),
//         _buildColumn("مكتمل", Colors.green, doneTasks, TaskStatus.done),
//       ],
//     );
//   }

//   Widget _buildColumn(
//     String title,
//     Color color,
//     List<TaskModel> tasks,
//     TaskStatus status,
//   ) {
//     return DragTarget<int>(
//       onWillAcceptWithDetails: (_) => true,
//       onAcceptWithDetails: (details) {
//         widget.onStatusChanged(details.data, status);
//       },
//       builder: (context, candidateData, rejectedData) {
//         return Container(
//           margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//           padding: EdgeInsets.all(12.w),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade50,
//             borderRadius: BorderRadius.circular(16.r),
//             border: candidateData.isNotEmpty
//                 ? Border.all(color: AppColors.primary, width: 2)
//                 : null,
//           ),
//           child: Column(
//             children: [
//               // Header
//               Row(
//                 children: [
//                   Container(
//                     width: 12.w,
//                     height: 12.w,
//                     decoration: BoxDecoration(
//                       color: color,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   SizedBox(width: 8.w),
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Tajawal',
//                     ),
//                   ),
//                   const Spacer(),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 8.w,
//                       vertical: 2.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       "${tasks.length}",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               Divider(height: 24.h),

//               // Tasks List
//               Expanded(
//                 child: tasks.isEmpty
//                     ? Center(
//                         child: Text(
//                           "اسحب المهام هنا",
//                           style: TextStyle(
//                             color: Colors.grey.shade400,
//                             fontSize: 12.sp,
//                             fontFamily: 'Tajawal',
//                           ),
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: tasks.length,
//                         itemBuilder: (context, index) {
//                           final task = tasks[index];
//                           // ✅ 1. استخدام Draggable للسحب السلس
//                           return Draggable<int>(
//                             data: task.id,
//                             feedback: SizedBox(
//                               width: 280.w,
//                               child: Material(
//                                 color: Colors.transparent,
//                                 child: Opacity(
//                                   opacity: 0.9,
//                                   // تعطيل التفاعل أثناء السحب
//                                   child: IgnorePointer(
//                                     child: TaskTile(
//                                       task: task,
//                                       onToggle: (_) {},
//                                       onDelete: () {},
//                                       enableSwipe: false,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             childWhenDragging: Opacity(
//                               opacity: 0.3,
//                               child: TaskTile(
//                                 task: task,
//                                 onToggle: (_) {},
//                                 onDelete: () {},
//                                 enableSwipe: false,
//                               ),
//                             ),
//                             child: TaskTile(
//                               task: task,
//                               // ✅ 2. تعطيل السحب الجانبي لمنع التعارض
//                               enableSwipe: false,

//                               // ✅ 3. تفعيل النقر لفتح التفاصيل
//                               onContentTap: () => widget.onTaskTap(task),

//                               onToggle: (_) => widget.onStatusChanged(
//                                 task.id,
//                                 TaskStatus.done,
//                               ),
//                               onDelete: () => widget.onDelete(task),
//                             ),
//                           );
//                         },
//                       ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
