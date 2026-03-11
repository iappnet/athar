// ————-————— code start ————————-
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/widgets/athar_feedback.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
import 'package:athar/core/design_system/molecules/skeletons/athar_skeleton.dart';
import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
import 'package:athar/features/task/domain/models/filter_item.dart';
import 'package:athar/features/task/presentation/widgets/add_task_sheet.dart';
import 'package:athar/features/task/presentation/widgets/reflection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/design_system/molecules/tiles/task_tile.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../../../prayer/presentation/cubit/prayer_cubit.dart';
import '../widgets/app_drawer.dart';
import '../../../../core/presentation/cubit/celebration_cubit.dart';
import '../../../../core/design_system/molecules/bars/filter_bar.dart';
import '../../data/models/task_model.dart';

/// Semantic colors (not in ColorScheme)
const _warningColor = Color(0xFFFDCB6E);
const _successColor = Color(0xFF00B894);

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<PrayerCubit>()..loadPrayerTimes(),
      child: const TasksPageView(),
    );
  }
}

class TasksPageView extends StatefulWidget {
  const TasksPageView({super.key});

  @override
  State<TasksPageView> createState() => _TasksPageViewState();
}

class _TasksPageViewState extends State<TasksPageView> {
  bool _isKanbanView = false;
  final PageController _pageController = PageController(viewportFraction: 0.85);

  // ✅ الدالة المحسنة (مع حل مشكلة الإخفاء الفوري للسنيك بار)
  void _onDeletePressed(BuildContext context, TaskModel task) {
    // 1. حفظ نسخة من الكيوبت (لأن الـ context قد يتغير أو يختفي)
    final taskCubit = context.read<TaskCubit>();

    // ✅✅ الحل الجذري: حفظ مرجع للـ ScaffoldMessenger قبل الحذف
    // هذا يضمن أننا نملك "جهاز التحكم" بالسنيك بار حتى لو اختفى العنصر نفسه
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    // 2. تنفيذ الحذف (Soft Delete) -> هنا العنصر سيختفي من الشاشة والـ context سيموت
    taskCubit.deleteTask(task.id);

    // 3+4. إخفاء السنيك بار السابق وإظهار الجديد (يتولاها showWithMessenger)
    AtharSnackbar.showWithMessenger(
      messenger: messenger,
      message: l10n.itemDeleted,
      colorScheme: colorScheme,
      variant: AtharSnackbarVariant.info,
      icon: Icons.delete_outline_rounded,
      actionLabel: l10n.undo,
      onAction: () => taskCubit.undoDelete(),
      clearPrevious: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      drawer: const AppDrawer(),
      appBar: AtharAppBar(
        title: l10n.yourAtharToday,
        subtitle: l10n.focusOnWhatMatters,
        leading: Builder(
          builder: (context) => AtharButton.icon(
            icon: Icons.menu,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: null,
      ),
      body: Column(
        children: [
          const SmartPrayerCardWrapper(pageType: PageType.tasks),

          // شريط الفلاتر
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  // ✅ أضفنا BlocListener للاستماع للأخطاء الأمنية
                  child: BlocListener<TaskCubit, TaskState>(
                    listener: (context, state) {
                      if (state is TaskError &&
                          state.message == "PERMISSION_DENIED") {
                        AtharSnackbar.error(
                          context: context,
                          message: l10n.noPermissionDelete,
                        );
                      }
                    },
                    child: BlocBuilder<TaskCubit, TaskState>(
                      builder: (context, state) {
                        if (state is TaskLoaded) {
                          return FilterBar<FilterItem>(
                            items: state.availableFilters,
                            selectedItem: state.activeFilter,
                            onSelected: (filter) =>
                                context.read<TaskCubit>().changeFilter(filter),
                            labelBuilder: (filter) {
                              if (filter is CategoryFilter) {
                                return filter.category.name;
                              }
                              return filter.label
                                  .replaceAll(
                                    RegExp(r'[^\w\s\u0600-\u06FF]'),
                                    '',
                                  )
                                  .trim();
                            },
                            iconBuilder: (filter) {
                              if (filter is FixedFilterType) {
                                switch (filter) {
                                  case FixedFilterType.all:
                                    return Icons.all_inclusive_rounded;
                                  case FixedFilterType.urgent:
                                    return Icons.local_fire_department_rounded;
                                  case FixedFilterType.important:
                                    return Icons.star_rounded;
                                }
                              } else if (filter is CategoryFilter) {
                                try {
                                  return IconData(
                                    filter.category.iconCode ??
                                        Icons.label_outline.codePoint,
                                    fontFamily: 'MaterialIcons',
                                  );
                                } catch (_) {
                                  return Icons.label_outline;
                                }
                              }
                              return null;
                            },
                            colorBuilder: (filter) {
                              if (filter is FixedFilterType) {
                                switch (filter) {
                                  case FixedFilterType.urgent:
                                    return colorScheme.error;
                                  case FixedFilterType.important:
                                    return _warningColor;
                                  default:
                                    return colorScheme.primary;
                                }
                              } else if (filter is CategoryFilter) {
                                return Color(filter.category.colorValue);
                              }
                              return null;
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                AtharGap.hSm,
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: AtharRadii.radiusMd,
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isKanbanView
                          ? Icons.view_list_rounded
                          : Icons.view_kanban_rounded,
                      color: colorScheme.primary,
                    ),
                    tooltip: _isKanbanView ? l10n.listView : l10n.boardView,
                    onPressed: () {
                      setState(() {
                        _isKanbanView = !_isKanbanView;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return ListView.builder(
                    padding: AtharSpacing.allLg,
                    itemCount: 5,
                    itemBuilder: (_, __) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: AtharSkeleton(
                        width: double.infinity,
                        height: 80.h,
                      ),
                    ),
                  );
                } else if (state is TaskError) {
                  return Center(child: Text(state.message));
                } else if (state is TaskLoaded) {
                  final visibleTasks = state.filteredTasks;

                  if (visibleTasks.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  if (_isKanbanView) {
                    return _buildKanbanView(context, visibleTasks);
                  } else {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<TaskCubit>().syncData();
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 80.h),
                        itemCount: visibleTasks.length,
                        itemBuilder: (context, index) {
                          final task = visibleTasks[index];
                          return TaskTile(
                            task: task,
                            onToggle: (bool? value) {
                              if (!task.isCompleted) {
                                context.read<CelebrationCubit>().celebrate();
                              }
                              context.read<TaskCubit>().toggleTaskCompletion(
                                task,
                              );

                              if (!task.isCompleted) {
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () {
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => ReflectionDialog(
                                          taskTitle: task.title,
                                          onSave: (note) {
                                            context
                                                .read<TaskCubit>()
                                                .saveCompletionNote(task, note);
                                          },
                                        ),
                                      );
                                    }
                                  },
                                );
                              }
                            },
                            // ✅ استخدام دالة الحذف الجديدة
                            onDelete: () => _onDeletePressed(context, task),
                            onLongPress: () {
                              final taskCubit = context.read<TaskCubit>();
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor:
                                    Colors.transparent, // مهم للزوايا الدائرية
                                builder: (context) {
                                  // نمرر نفس الكيوبت للنافذة الجديدة
                                  return BlocProvider.value(
                                    value: taskCubit,
                                    child: AddTaskSheet(
                                      // ✅ نستخدم الشيت المتطور، ونمرر المهمة للتعديل
                                      taskToEdit: task,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tasks_page_fab',
        backgroundColor: colorScheme.primary,
        icon: Icon(Icons.add, color: colorScheme.surface),
        label: Text(l10n.newTask, style: TextStyle(color: colorScheme.surface)),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => BlocProvider.value(
              value: context.read<TaskCubit>(),
              child: const AddTaskSheet(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildKanbanView(BuildContext context, List<TaskModel> tasks) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final todoTasks = tasks.where((t) => t.status == TaskStatus.todo).toList();
    final inProgressTasks = tasks
        .where((t) => t.status == TaskStatus.inProgress)
        .toList();
    final doneTasks = tasks.where((t) => t.status == TaskStatus.done).toList();

    return PageView(
      controller: _pageController,
      children: [
        _buildKanbanColumn(
          l10n.todo,
          colorScheme.outline,
          todoTasks,
          TaskStatus.todo,
          context,
        ),
        _buildKanbanColumn(
          l10n.inProgress,
          Colors.blue,
          inProgressTasks,
          TaskStatus.inProgress,
          context,
        ),
        _buildKanbanColumn(
          l10n.completed,
          _successColor,
          doneTasks,
          TaskStatus.done,
          context,
        ),
      ],
    );
  }

  Widget _buildKanbanColumn(
    String title,
    Color color,
    List<TaskModel> tasks,
    TaskStatus status,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return DragTarget<TaskModel>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        context.read<TaskCubit>().updateTaskStatus(details.data, status);
        if (status == TaskStatus.done && !details.data.isCompleted) {
          context.read<CelebrationCubit>().celebrate();
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          padding: AtharSpacing.allMd,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AtharRadii.radiusLg,
            border: candidateData.isNotEmpty
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${tasks.length}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 24.h),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return LongPressDraggable<TaskModel>(
                      data: task,
                      feedback: SizedBox(
                        width: 300.w,
                        child: Material(
                          color: Colors.transparent,
                          child: TaskTile(
                            task: task,
                            onToggle: (_) {},
                            onDelete: () {},
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.3,
                        child: TaskTile(
                          task: task,
                          onToggle: (_) {},
                          onDelete: () {},
                        ),
                      ),
                      child: TaskTile(
                        task: task,
                        onToggle: (val) {
                          if (!task.isCompleted) {
                            context.read<CelebrationCubit>().celebrate();
                          }
                          context.read<TaskCubit>().toggleTaskCompletion(task);
                        },
                        // ✅ استدعاء دالة الحذف الموحدة في الكانبان أيضاً
                        onDelete: () => _onDeletePressed(context, task),
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
            l10n.dayClear,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
          ),
          Text(
            l10n.addTasksToStart,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
// ————-————— code end ————————-
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
// import 'package:athar/core/design_system/molecules/skeletons/athar_skeleton.dart';
// import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
// import 'package:athar/features/task/domain/models/filter_item.dart';
// import 'package:athar/features/task/presentation/widgets/add_task_sheet.dart';
// import 'package:athar/features/task/presentation/widgets/reflection_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/di/injection.dart';
// import '../../../../core/design_system/molecules/tiles/task_tile.dart';
// import '../cubit/task_cubit.dart';
// import '../cubit/task_state.dart';
// import '../../../prayer/presentation/cubit/prayer_cubit.dart';
// import '../widgets/app_drawer.dart';
// import '../../../../core/presentation/cubit/celebration_cubit.dart';
// import '../../../../core/design_system/molecules/bars/filter_bar.dart';
// import '../../data/models/task_model.dart';

// class TasksPage extends StatelessWidget {
//   const TasksPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => getIt<PrayerCubit>()..loadPrayerTimes(),
//       child: const TasksPageView(),
//     );
//   }
// }

// class TasksPageView extends StatefulWidget {
//   const TasksPageView({super.key});

//   @override
//   State<TasksPageView> createState() => _TasksPageViewState();
// }

// class _TasksPageViewState extends State<TasksPageView> {
//   bool _isKanbanView = false;
//   final PageController _pageController = PageController(viewportFraction: 0.85);

//   // ✅ الدالة المحسنة (مع حل مشكلة الإخفاء الفوري للسنيك بار)
//   void _onDeletePressed(BuildContext context, TaskModel task) {
//     // 1. حفظ نسخة من الكيوبت (لأن الـ context قد يتغير أو يختفي)
//     final taskCubit = context.read<TaskCubit>();

//     // ✅✅ الحل الجذري: حفظ مرجع للـ ScaffoldMessenger قبل الحذف
//     // هذا يضمن أننا نملك "جهاز التحكم" بالسنيك بار حتى لو اختفى العنصر نفسه
//     final messenger = ScaffoldMessenger.of(context);
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     // 2. تنفيذ الحذف (Soft Delete) -> هنا العنصر سيختفي من الشاشة والـ context سيموت
//     taskCubit.deleteTask(task.id);

//     // 3+4. إخفاء السنيك بار السابق وإظهار الجديد (يتولاها showWithMessenger)
//     AtharSnackbar.showWithMessenger(
//       messenger: messenger,
//       message: l10n.itemDeleted,
//       colors: colors,
//       variant: AtharSnackbarVariant.info,
//       icon: Icons.delete_outline_rounded,
//       actionLabel: l10n.undo,
//       onAction: () => taskCubit.undoDelete(),
//       clearPrevious: true,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return Scaffold(
//       backgroundColor: colors.scaffoldBackground,
//       drawer: const AppDrawer(),
//       appBar: AtharAppBar(
//         title: l10n.yourAtharToday,
//         subtitle: l10n.focusOnWhatMatters,
//         leading: Builder(
//           builder: (context) => AtharButton.icon(
//             icon: Icons.menu,
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         actions: null,
//       ),
//       body: Column(
//         children: [
//           const SmartPrayerCardWrapper(pageType: PageType.tasks),

//           // شريط الفلاتر
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//             child: Row(
//               children: [
//                 Expanded(
//                   // ✅ أضفنا BlocListener للاستماع للأخطاء الأمنية
//                   child: BlocListener<TaskCubit, TaskState>(
//                     listener: (context, state) {
//                       if (state is TaskError &&
//                           state.message == "PERMISSION_DENIED") {
//                         AtharSnackbar.error(
//                           context: context,
//                           message: l10n.noPermissionDelete,
//                         );
//                       }
//                     },
//                     child: BlocBuilder<TaskCubit, TaskState>(
//                       builder: (context, state) {
//                         if (state is TaskLoaded) {
//                           return FilterBar<FilterItem>(
//                             items: state.availableFilters,
//                             selectedItem: state.activeFilter,
//                             onSelected: (filter) =>
//                                 context.read<TaskCubit>().changeFilter(filter),
//                             labelBuilder: (filter) {
//                               if (filter is CategoryFilter) {
//                                 return filter.category.name;
//                               }
//                               return filter.label
//                                   .replaceAll(
//                                     RegExp(r'[^\w\s\u0600-\u06FF]'),
//                                     '',
//                                   )
//                                   .trim();
//                             },
//                             iconBuilder: (filter) {
//                               if (filter is FixedFilterType) {
//                                 switch (filter) {
//                                   case FixedFilterType.all:
//                                     return Icons.all_inclusive_rounded;
//                                   case FixedFilterType.urgent:
//                                     return Icons.local_fire_department_rounded;
//                                   case FixedFilterType.important:
//                                     return Icons.star_rounded;
//                                 }
//                               } else if (filter is CategoryFilter) {
//                                 try {
//                                   return IconData(
//                                     filter.category.iconCode ??
//                                         Icons.label_outline.codePoint,
//                                     fontFamily: 'MaterialIcons',
//                                   );
//                                 } catch (_) {
//                                   return Icons.label_outline;
//                                 }
//                               }
//                               return null;
//                             },
//                             colorBuilder: (filter) {
//                               if (filter is FixedFilterType) {
//                                 switch (filter) {
//                                   case FixedFilterType.urgent:
//                                     return colors.error;
//                                   case FixedFilterType.important:
//                                     return colors.warning;
//                                   default:
//                                     return colors.primary;
//                                 }
//                               } else if (filter is CategoryFilter) {
//                                 return Color(filter.category.colorValue);
//                               }
//                               return null;
//                             },
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                   ),
//                 ),
//                 AtharGap.hSm,
//                 Container(
//                   decoration: BoxDecoration(
//                     color: colors.surface,
//                     borderRadius: AtharRadii.radiusMd,
//                     border: Border.all(
//                       color: colors.textTertiary.withOpacity(0.3),
//                     ),
//                   ),
//                   child: IconButton(
//                     icon: Icon(
//                       _isKanbanView
//                           ? Icons.view_list_rounded
//                           : Icons.view_kanban_rounded,
//                       color: colors.primary,
//                     ),
//                     tooltip: _isKanbanView ? l10n.listView : l10n.boardView,
//                     onPressed: () {
//                       setState(() {
//                         _isKanbanView = !_isKanbanView;
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             child: BlocBuilder<TaskCubit, TaskState>(
//               builder: (context, state) {
//                 if (state is TaskLoading) {
//                   return ListView.builder(
//                     padding: AtharSpacing.allLg,
//                     itemCount: 5,
//                     itemBuilder: (_, __) => Padding(
//                       padding: EdgeInsets.only(bottom: 12.h),
//                       child: AtharSkeleton(
//                         width: double.infinity,
//                         height: 80.h,
//                       ),
//                     ),
//                   );
//                 } else if (state is TaskError) {
//                   return Center(child: Text(state.message));
//                 } else if (state is TaskLoaded) {
//                   final visibleTasks = state.filteredTasks;

//                   if (visibleTasks.isEmpty) {
//                     return _buildEmptyState(context);
//                   }

//                   if (_isKanbanView) {
//                     return _buildKanbanView(context, visibleTasks);
//                   } else {
//                     return RefreshIndicator(
//                       onRefresh: () async {
//                         await context.read<TaskCubit>().syncData();
//                       },
//                       child: ListView.builder(
//                         padding: EdgeInsets.only(bottom: 80.h),
//                         itemCount: visibleTasks.length,
//                         itemBuilder: (context, index) {
//                           final task = visibleTasks[index];
//                           return TaskTile(
//                             task: task,
//                             onToggle: (bool? value) {
//                               if (!task.isCompleted) {
//                                 context.read<CelebrationCubit>().celebrate();
//                               }
//                               context.read<TaskCubit>().toggleTaskCompletion(
//                                 task,
//                               );

//                               if (!task.isCompleted) {
//                                 Future.delayed(
//                                   const Duration(milliseconds: 500),
//                                   () {
//                                     if (context.mounted) {
//                                       showDialog(
//                                         context: context,
//                                         builder: (ctx) => ReflectionDialog(
//                                           taskTitle: task.title,
//                                           onSave: (note) {
//                                             context
//                                                 .read<TaskCubit>()
//                                                 .saveCompletionNote(task, note);
//                                           },
//                                         ),
//                                       );
//                                     }
//                                   },
//                                 );
//                               }
//                             },
//                             // ✅ استخدام دالة الحذف الجديدة
//                             onDelete: () => _onDeletePressed(context, task),
//                             onLongPress: () {
//                               final taskCubit = context.read<TaskCubit>();
//                               showModalBottomSheet(
//                                 context: context,
//                                 isScrollControlled: true,
//                                 backgroundColor:
//                                     Colors.transparent, // مهم للزوايا الدائرية
//                                 builder: (context) {
//                                   // نمرر نفس الكيوبت للنافذة الجديدة
//                                   return BlocProvider.value(
//                                     value: taskCubit,
//                                     child: AddTaskSheet(
//                                       // ✅ نستخدم الشيت المتطور، ونمرر المهمة للتعديل
//                                       taskToEdit: task,
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     );
//                   }
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         heroTag: 'tasks_page_fab',
//         backgroundColor: colors.primary,
//         icon: Icon(Icons.add, color: colors.surface),
//         label: Text(l10n.newTask, style: TextStyle(color: colors.surface)),
//         onPressed: () {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (ctx) => BlocProvider.value(
//               value: context.read<TaskCubit>(),
//               child: const AddTaskSheet(),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildKanbanView(BuildContext context, List<TaskModel> tasks) {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);
//     final todoTasks = tasks.where((t) => t.status == TaskStatus.todo).toList();
//     final inProgressTasks = tasks
//         .where((t) => t.status == TaskStatus.inProgress)
//         .toList();
//     final doneTasks = tasks.where((t) => t.status == TaskStatus.done).toList();

//     return PageView(
//       controller: _pageController,
//       children: [
//         _buildKanbanColumn(
//           l10n.todo,
//           colors.textTertiary,
//           todoTasks,
//           TaskStatus.todo,
//           context,
//         ),
//         _buildKanbanColumn(
//           l10n.inProgress,
//           Colors.blue,
//           inProgressTasks,
//           TaskStatus.inProgress,
//           context,
//         ),
//         _buildKanbanColumn(
//           l10n.completed,
//           colors.success,
//           doneTasks,
//           TaskStatus.done,
//           context,
//         ),
//       ],
//     );
//   }

//   Widget _buildKanbanColumn(
//     String title,
//     Color color,
//     List<TaskModel> tasks,
//     TaskStatus status,
//     BuildContext context,
//   ) {
//     final colors = context.colors;

//     return DragTarget<TaskModel>(
//       onWillAcceptWithDetails: (_) => true,
//       onAcceptWithDetails: (details) {
//         context.read<TaskCubit>().updateTaskStatus(details.data, status);
//         if (status == TaskStatus.done && !details.data.isCompleted) {
//           context.read<CelebrationCubit>().celebrate();
//         }
//       },
//       builder: (context, candidateData, rejectedData) {
//         return Container(
//           margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//           padding: AtharSpacing.allMd,
//           decoration: BoxDecoration(
//             color: colors.surface,
//             borderRadius: AtharRadii.radiusLg,
//             border: candidateData.isNotEmpty
//                 ? Border.all(color: colors.primary, width: 2)
//                 : null,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
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
//                   AtharGap.hSm,
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 8.w,
//                       vertical: 2.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: colors.surface,
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
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: tasks.length,
//                   itemBuilder: (context, index) {
//                     final task = tasks[index];
//                     return LongPressDraggable<TaskModel>(
//                       data: task,
//                       feedback: SizedBox(
//                         width: 300.w,
//                         child: Material(
//                           color: Colors.transparent,
//                           child: TaskTile(
//                             task: task,
//                             onToggle: (_) {},
//                             onDelete: () {},
//                           ),
//                         ),
//                       ),
//                       childWhenDragging: Opacity(
//                         opacity: 0.3,
//                         child: TaskTile(
//                           task: task,
//                           onToggle: (_) {},
//                           onDelete: () {},
//                         ),
//                       ),
//                       child: TaskTile(
//                         task: task,
//                         onToggle: (val) {
//                           if (!task.isCompleted) {
//                             context.read<CelebrationCubit>().celebrate();
//                           }
//                           context.read<TaskCubit>().toggleTaskCompletion(task);
//                         },
//                         // ✅ استدعاء دالة الحذف الموحدة في الكانبان أيضاً
//                         onDelete: () => _onDeletePressed(context, task),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
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
//             l10n.dayClear,
//             style: Theme.of(
//               context,
//             ).textTheme.bodyLarge?.copyWith(color: colors.textTertiary),
//           ),
//           Text(
//             l10n.addTasksToStart,
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
// import 'package:athar/core/design_system/molecules/skeletons/athar_skeleton.dart';
// import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
// import 'package:athar/features/task/domain/models/filter_item.dart';
// import 'package:athar/features/task/presentation/widgets/add_task_sheet.dart';
// import 'package:athar/features/task/presentation/widgets/reflection_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/di/injection.dart';
// import '../../../../core/design_system/molecules/tiles/task_tile.dart';
// import '../cubit/task_cubit.dart';
// import '../cubit/task_state.dart';
// import '../../../prayer/presentation/cubit/prayer_cubit.dart';
// import '../widgets/app_drawer.dart';
// import '../../../../core/presentation/cubit/celebration_cubit.dart';
// import '../../../../core/design_system/molecules/bars/filter_bar.dart';
// import '../../data/models/task_model.dart';

// class TasksPage extends StatelessWidget {
//   const TasksPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => getIt<PrayerCubit>()..loadPrayerTimes(),
//       child: const TasksPageView(),
//     );
//   }
// }

// class TasksPageView extends StatefulWidget {
//   const TasksPageView({super.key});

//   @override
//   State<TasksPageView> createState() => _TasksPageViewState();
// }

// class _TasksPageViewState extends State<TasksPageView> {
//   bool _isKanbanView = false;
//   final PageController _pageController = PageController(viewportFraction: 0.85);

//   // ✅ الدالة المحسنة (مع حل مشكلة الإخفاء الفوري للسنيك بار)
//   void _onDeletePressed(BuildContext context, TaskModel task) {
//     // 1. حفظ نسخة من الكيوبت (لأن الـ context قد يتغير أو يختفي)
//     final taskCubit = context.read<TaskCubit>();

//     // ✅✅ الحل الجذري: حفظ مرجع للـ ScaffoldMessenger قبل الحذف
//     // هذا يضمن أننا نملك "جهاز التحكم" بالسنيك بار حتى لو اختفى العنصر نفسه
//     final messenger = ScaffoldMessenger.of(context);
//     final colors = context.colors;

//     // 2. تنفيذ الحذف (Soft Delete) -> هنا العنصر سيختفي من الشاشة والـ context سيموت
//     taskCubit.deleteTask(task.id);

//     // 3+4. إخفاء السنيك بار السابق وإظهار الجديد (يتولاها showWithMessenger)
//     AtharSnackbar.showWithMessenger(
//       messenger: messenger,
//       message: "تم الحذف",
//       colors: colors,
//       variant: AtharSnackbarVariant.info,
//       icon: Icons.delete_outline_rounded,
//       actionLabel: "تراجع",
//       onAction: () => taskCubit.undoDelete(),
//       clearPrevious: true,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Scaffold(
//       backgroundColor: colors.scaffoldBackground,
//       drawer: const AppDrawer(),
//       appBar: AtharAppBar(
//         title: "أثرك اليوم",
//         subtitle: "ركز على ما يهم",
//         leading: Builder(
//           builder: (context) => AtharButton.icon(
//             icon: Icons.menu,
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         actions: null,
//       ),
//       body: Column(
//         children: [
//           const SmartPrayerCardWrapper(pageType: PageType.tasks),

//           // شريط الفلاتر
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//             child: Row(
//               children: [
//                 Expanded(
//                   // ✅ أضفنا BlocListener للاستماع للأخطاء الأمنية
//                   child: BlocListener<TaskCubit, TaskState>(
//                     listener: (context, state) {
//                       if (state is TaskError &&
//                           state.message == "PERMISSION_DENIED") {
//                         AtharSnackbar.error(
//                           context: context,
//                           message: "عذراً، لا تملك صلاحية حذف هذه المهمة",
//                         );
//                       }
//                     },
//                     child: BlocBuilder<TaskCubit, TaskState>(
//                       builder: (context, state) {
//                         if (state is TaskLoaded) {
//                           return FilterBar<FilterItem>(
//                             items: state.availableFilters,
//                             selectedItem: state.activeFilter,
//                             onSelected: (filter) =>
//                                 context.read<TaskCubit>().changeFilter(filter),
//                             labelBuilder: (filter) {
//                               if (filter is CategoryFilter) {
//                                 return filter.category.name;
//                               }
//                               return filter.label
//                                   .replaceAll(
//                                     RegExp(r'[^\w\s\u0600-\u06FF]'),
//                                     '',
//                                   )
//                                   .trim();
//                             },
//                             iconBuilder: (filter) {
//                               if (filter is FixedFilterType) {
//                                 switch (filter) {
//                                   case FixedFilterType.all:
//                                     return Icons.all_inclusive_rounded;
//                                   case FixedFilterType.urgent:
//                                     return Icons.local_fire_department_rounded;
//                                   case FixedFilterType.important:
//                                     return Icons.star_rounded;
//                                 }
//                               } else if (filter is CategoryFilter) {
//                                 try {
//                                   return IconData(
//                                     filter.category.iconCode ??
//                                         Icons.label_outline.codePoint,
//                                     fontFamily: 'MaterialIcons',
//                                   );
//                                 } catch (_) {
//                                   return Icons.label_outline;
//                                 }
//                               }
//                               return null;
//                             },
//                             colorBuilder: (filter) {
//                               if (filter is FixedFilterType) {
//                                 switch (filter) {
//                                   case FixedFilterType.urgent:
//                                     return colors.error;
//                                   case FixedFilterType.important:
//                                     return colors.warning;
//                                   default:
//                                     return colors.primary;
//                                 }
//                               } else if (filter is CategoryFilter) {
//                                 return Color(filter.category.colorValue);
//                               }
//                               return null;
//                             },
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                   ),
//                 ),
//                 AtharGap.hSm,
//                 Container(
//                   decoration: BoxDecoration(
//                     color: colors.surface,
//                     borderRadius: AtharRadii.radiusMd,
//                     border: Border.all(
//                       color: colors.textTertiary.withOpacity(0.3),
//                     ),
//                   ),
//                   child: IconButton(
//                     icon: Icon(
//                       _isKanbanView
//                           ? Icons.view_list_rounded
//                           : Icons.view_kanban_rounded,
//                       color: colors.primary,
//                     ),
//                     tooltip: _isKanbanView ? "عرض القائمة" : "عرض اللوحة",
//                     onPressed: () {
//                       setState(() {
//                         _isKanbanView = !_isKanbanView;
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             child: BlocBuilder<TaskCubit, TaskState>(
//               builder: (context, state) {
//                 if (state is TaskLoading) {
//                   return ListView.builder(
//                     padding: AtharSpacing.allLg,
//                     itemCount: 5,
//                     itemBuilder: (_, __) => Padding(
//                       padding: EdgeInsets.only(bottom: 12.h),
//                       child: AtharSkeleton(
//                         width: double.infinity,
//                         height: 80.h,
//                       ),
//                     ),
//                   );
//                 } else if (state is TaskError) {
//                   return Center(child: Text(state.message));
//                 } else if (state is TaskLoaded) {
//                   final visibleTasks = state.filteredTasks;

//                   if (visibleTasks.isEmpty) {
//                     return _buildEmptyState(context);
//                   }

//                   if (_isKanbanView) {
//                     return _buildKanbanView(context, visibleTasks);
//                   } else {
//                     return RefreshIndicator(
//                       onRefresh: () async {
//                         await context.read<TaskCubit>().syncData();
//                       },
//                       child: ListView.builder(
//                         padding: EdgeInsets.only(bottom: 80.h),
//                         itemCount: visibleTasks.length,
//                         itemBuilder: (context, index) {
//                           final task = visibleTasks[index];
//                           return TaskTile(
//                             task: task,
//                             onToggle: (bool? value) {
//                               if (!task.isCompleted) {
//                                 context.read<CelebrationCubit>().celebrate();
//                               }
//                               context.read<TaskCubit>().toggleTaskCompletion(
//                                 task,
//                               );

//                               if (!task.isCompleted) {
//                                 Future.delayed(
//                                   const Duration(milliseconds: 500),
//                                   () {
//                                     if (context.mounted) {
//                                       showDialog(
//                                         context: context,
//                                         builder: (ctx) => ReflectionDialog(
//                                           taskTitle: task.title,
//                                           onSave: (note) {
//                                             context
//                                                 .read<TaskCubit>()
//                                                 .saveCompletionNote(task, note);
//                                           },
//                                         ),
//                                       );
//                                     }
//                                   },
//                                 );
//                               }
//                             },
//                             // ✅ استخدام دالة الحذف الجديدة
//                             onDelete: () => _onDeletePressed(context, task),
//                             onLongPress: () {
//                               final taskCubit = context.read<TaskCubit>();
//                               showModalBottomSheet(
//                                 context: context,
//                                 isScrollControlled: true,
//                                 backgroundColor:
//                                     Colors.transparent, // مهم للزوايا الدائرية
//                                 builder: (context) {
//                                   // نمرر نفس الكيوبت للنافذة الجديدة
//                                   return BlocProvider.value(
//                                     value: taskCubit,
//                                     child: AddTaskSheet(
//                                       // ✅ نستخدم الشيت المتطور، ونمرر المهمة للتعديل
//                                       taskToEdit: task,
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     );
//                   }
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         heroTag: 'tasks_page_fab',
//         backgroundColor: colors.primary,
//         icon: Icon(Icons.add, color: colors.surface),
//         label: Text("مهمة جديدة", style: TextStyle(color: colors.surface)),
//         onPressed: () {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (ctx) => BlocProvider.value(
//               value: context.read<TaskCubit>(),
//               child: const AddTaskSheet(),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildKanbanView(BuildContext context, List<TaskModel> tasks) {
//     final colors = context.colors;
//     final todoTasks = tasks.where((t) => t.status == TaskStatus.todo).toList();
//     final inProgressTasks = tasks
//         .where((t) => t.status == TaskStatus.inProgress)
//         .toList();
//     final doneTasks = tasks.where((t) => t.status == TaskStatus.done).toList();

//     return PageView(
//       controller: _pageController,
//       children: [
//         _buildKanbanColumn(
//           "للقيام به",
//           colors.textTertiary,
//           todoTasks,
//           TaskStatus.todo,
//           context,
//         ),
//         _buildKanbanColumn(
//           "جاري العمل",
//           Colors.blue,
//           inProgressTasks,
//           TaskStatus.inProgress,
//           context,
//         ),
//         _buildKanbanColumn(
//           "مكتمل",
//           colors.success,
//           doneTasks,
//           TaskStatus.done,
//           context,
//         ),
//       ],
//     );
//   }

//   Widget _buildKanbanColumn(
//     String title,
//     Color color,
//     List<TaskModel> tasks,
//     TaskStatus status,
//     BuildContext context,
//   ) {
//     final colors = context.colors;

//     return DragTarget<TaskModel>(
//       onWillAcceptWithDetails: (_) => true,
//       onAcceptWithDetails: (details) {
//         context.read<TaskCubit>().updateTaskStatus(details.data, status);
//         if (status == TaskStatus.done && !details.data.isCompleted) {
//           context.read<CelebrationCubit>().celebrate();
//         }
//       },
//       builder: (context, candidateData, rejectedData) {
//         return Container(
//           margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//           padding: AtharSpacing.allMd,
//           decoration: BoxDecoration(
//             color: colors.surface,
//             borderRadius: AtharRadii.radiusLg,
//             border: candidateData.isNotEmpty
//                 ? Border.all(color: colors.primary, width: 2)
//                 : null,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
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
//                   AtharGap.hSm,
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 8.w,
//                       vertical: 2.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: colors.surface,
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
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: tasks.length,
//                   itemBuilder: (context, index) {
//                     final task = tasks[index];
//                     return LongPressDraggable<TaskModel>(
//                       data: task,
//                       feedback: SizedBox(
//                         width: 300.w,
//                         child: Material(
//                           color: Colors.transparent,
//                           child: TaskTile(
//                             task: task,
//                             onToggle: (_) {},
//                             onDelete: () {},
//                           ),
//                         ),
//                       ),
//                       childWhenDragging: Opacity(
//                         opacity: 0.3,
//                         child: TaskTile(
//                           task: task,
//                           onToggle: (_) {},
//                           onDelete: () {},
//                         ),
//                       ),
//                       child: TaskTile(
//                         task: task,
//                         onToggle: (val) {
//                           if (!task.isCompleted) {
//                             context.read<CelebrationCubit>().celebrate();
//                           }
//                           context.read<TaskCubit>().toggleTaskCompletion(task);
//                         },
//                         // ✅ استدعاء دالة الحذف الموحدة في الكانبان أيضاً
//                         onDelete: () => _onDeletePressed(context, task),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     final colors = context.colors;

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
//             "يومك صافي!",
//             style: Theme.of(
//               context,
//             ).textTheme.bodyLarge?.copyWith(color: colors.textTertiary),
//           ),
//           Text(
//             "أضف مهامك لتبدأ الأثر",
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//         ],
//       ),
//     );
//   }
// }
// import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
// import 'package:athar/core/design_system/molecules/skeletons/athar_skeleton.dart';
// import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
// import 'package:athar/features/task/domain/models/filter_item.dart';
// import 'package:athar/features/task/presentation/widgets/add_task_sheet.dart';
// import 'package:athar/features/task/presentation/widgets/reflection_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/di/injection.dart';
// import '../../../../core/design_system/molecules/tiles/task_tile.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../cubit/task_cubit.dart';
// import '../cubit/task_state.dart';
// import '../../../prayer/presentation/cubit/prayer_cubit.dart';
// import '../widgets/app_drawer.dart';
// import '../../../../core/presentation/cubit/celebration_cubit.dart';
// import '../../../../core/design_system/molecules/bars/filter_bar.dart';
// import '../../data/models/task_model.dart';

// class TasksPage extends StatelessWidget {
//   const TasksPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => getIt<PrayerCubit>()..loadPrayerTimes(),
//       child: const TasksPageView(),
//     );
//   }
// }

// class TasksPageView extends StatefulWidget {
//   const TasksPageView({super.key});

//   @override
//   State<TasksPageView> createState() => _TasksPageViewState();
// }

// class _TasksPageViewState extends State<TasksPageView> {
//   bool _isKanbanView = false;
//   final PageController _pageController = PageController(viewportFraction: 0.85);

//   // ✅ الدالة المحسنة (مع حل مشكلة الإخفاء الفوري للسنيك بار)
//   void _onDeletePressed(BuildContext context, TaskModel task) {
//     // 1. حفظ نسخة من الكيوبت (لأن الـ context قد يتغير أو يختفي)
//     final taskCubit = context.read<TaskCubit>();

//     // ✅✅ الحل الجذري: حفظ مرجع للـ ScaffoldMessenger قبل الحذف
//     // هذا يضمن أننا نملك "جهاز التحكم" بالسنيك بار حتى لو اختفى العنصر نفسه
//     final scaffoldMessenger = ScaffoldMessenger.of(context);

//     // 2. تنفيذ الحذف (Soft Delete) -> هنا العنصر سيختفي من الشاشة والـ context سيموت
//     taskCubit.deleteTask(task.id);

//     // 3. إخفاء أي سنيك بار سابق فوراً باستخدام المرجع المحفوظ
//     scaffoldMessenger.clearSnackBars();

//     // 4. إظهار السنيك بار الجديد
//     scaffoldMessenger.showSnackBar(
//       SnackBar(
//         duration: const Duration(seconds: 3),
//         backgroundColor: const Color(0xFF1E293B),
//         behavior: SnackBarBehavior.floating,
//         margin: EdgeInsets.all(16.w),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         dismissDirection: DismissDirection.horizontal,
//         content: Row(
//           children: [
//             const Icon(Icons.delete_outline_rounded, color: Colors.white70),
//             SizedBox(width: 12.w),
//             const Text(
//               "تم الحذف",
//               style: TextStyle(
//                 fontFamily: 'Tajawal',
//                 color: Colors.white,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         action: SnackBarAction(
//           label: "تراجع",
//           textColor: AppColors.primary,
//           onPressed: () {
//             // ✅✅ هنا التغيير المهم:
//             // بدلاً من استخدام ScaffoldMessenger.of(context) التي تسبب الخطأ
//             // نستخدم المتغير "scaffoldMessenger" الذي حفظناه في البداية
//             scaffoldMessenger.hideCurrentSnackBar();

//             // ثم ننفذ عملية التراجع
//             taskCubit.undoDelete();
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       drawer: const AppDrawer(),
//       appBar: AtharAppBar(
//         title: "أثرك اليوم",
//         subtitle: "ركز على ما يهم",
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.menu, color: AppColors.textPrimary),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         actions: null,
//       ),
//       body: Column(
//         children: [
//           const SmartPrayerCardWrapper(pageType: PageType.tasks),

//           // شريط الفلاتر
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//             child: Row(
//               children: [
//                 Expanded(
//                   // ✅ أضفنا BlocListener للاستماع للأخطاء الأمنية
//                   child: BlocListener<TaskCubit, TaskState>(
//                     listener: (context, state) {
//                       if (state is TaskError &&
//                           state.message == "PERMISSION_DENIED") {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Row(
//                               children: [
//                                 Icon(Icons.lock_outline, color: Colors.white),
//                                 SizedBox(width: 10.w),
//                                 Text("عذراً، لا تملك صلاحية حذف هذه المهمة"),
//                               ],
//                             ),
//                             backgroundColor: Colors.red.shade800,
//                             behavior: SnackBarBehavior.floating,
//                           ),
//                         );
//                       }
//                     },
//                     child: BlocBuilder<TaskCubit, TaskState>(
//                       builder: (context, state) {
//                         if (state is TaskLoaded) {
//                           return FilterBar<FilterItem>(
//                             items: state.availableFilters,
//                             selectedItem: state.activeFilter,
//                             onSelected: (filter) =>
//                                 context.read<TaskCubit>().changeFilter(filter),
//                             labelBuilder: (filter) {
//                               if (filter is CategoryFilter) {
//                                 return filter.category.name;
//                               }
//                               return filter.label
//                                   .replaceAll(
//                                     RegExp(r'[^\w\s\u0600-\u06FF]'),
//                                     '',
//                                   )
//                                   .trim();
//                             },
//                             iconBuilder: (filter) {
//                               if (filter is FixedFilterType) {
//                                 switch (filter) {
//                                   case FixedFilterType.all:
//                                     return Icons.all_inclusive_rounded;
//                                   case FixedFilterType.urgent:
//                                     return Icons.local_fire_department_rounded;
//                                   case FixedFilterType.important:
//                                     return Icons.star_rounded;
//                                 }
//                               } else if (filter is CategoryFilter) {
//                                 try {
//                                   return IconData(
//                                     filter.category.iconCode ??
//                                         Icons.label_outline.codePoint,
//                                     fontFamily: 'MaterialIcons',
//                                   );
//                                 } catch (_) {
//                                   return Icons.label_outline;
//                                 }
//                               }
//                               return null;
//                             },
//                             colorBuilder: (filter) {
//                               if (filter is FixedFilterType) {
//                                 switch (filter) {
//                                   case FixedFilterType.urgent:
//                                     return AppColors.urgent;
//                                   case FixedFilterType.important:
//                                     return AppColors.warning;
//                                   default:
//                                     return AppColors.primary;
//                                 }
//                               } else if (filter is CategoryFilter) {
//                                 return Color(filter.category.colorValue);
//                               }
//                               return null;
//                             },
//                           );
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12.r),
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   child: IconButton(
//                     icon: Icon(
//                       _isKanbanView
//                           ? Icons.view_list_rounded
//                           : Icons.view_kanban_rounded,
//                       color: AppColors.primary,
//                     ),
//                     tooltip: _isKanbanView ? "عرض القائمة" : "عرض اللوحة",
//                     onPressed: () {
//                       setState(() {
//                         _isKanbanView = !_isKanbanView;
//                       });
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             child: BlocBuilder<TaskCubit, TaskState>(
//               builder: (context, state) {
//                 if (state is TaskLoading) {
//                   // return const Center(child: CircularProgressIndicator());
//                   return ListView.builder(
//                     padding: EdgeInsets.all(16.w),
//                     itemCount: 5,
//                     itemBuilder: (_, _) => Padding(
//                       padding: EdgeInsets.only(bottom: 12.h),
//                       child: AtharSkeleton(
//                         width: double.infinity,
//                         height: 80.h,
//                       ),
//                     ),
//                   );
//                 } else if (state is TaskError) {
//                   return Center(child: Text(state.message));
//                 } else if (state is TaskLoaded) {
//                   final visibleTasks = state.filteredTasks;

//                   if (visibleTasks.isEmpty) {
//                     return _buildEmptyState(context);
//                   }

//                   if (_isKanbanView) {
//                     return _buildKanbanView(context, visibleTasks);
//                   } else {
//                     return RefreshIndicator(
//                       onRefresh: () async {
//                         await context.read<TaskCubit>().syncData();
//                       },
//                       child: ListView.builder(
//                         padding: EdgeInsets.only(bottom: 80.h),
//                         itemCount: visibleTasks.length,
//                         itemBuilder: (context, index) {
//                           final task = visibleTasks[index];
//                           return TaskTile(
//                             task: task,
//                             onToggle: (bool? value) {
//                               if (!task.isCompleted) {
//                                 context.read<CelebrationCubit>().celebrate();
//                               }
//                               context.read<TaskCubit>().toggleTaskCompletion(
//                                 task,
//                               );

//                               if (!task.isCompleted) {
//                                 Future.delayed(
//                                   const Duration(milliseconds: 500),
//                                   () {
//                                     if (context.mounted) {
//                                       showDialog(
//                                         context: context,
//                                         builder: (ctx) => ReflectionDialog(
//                                           taskTitle: task.title,
//                                           onSave: (note) {
//                                             context
//                                                 .read<TaskCubit>()
//                                                 .saveCompletionNote(task, note);
//                                           },
//                                         ),
//                                       );
//                                     }
//                                   },
//                                 );
//                               }
//                             },
//                             // ✅ استخدام دالة الحذف الجديدة
//                             onDelete: () => _onDeletePressed(context, task),
//                             onLongPress: () {
//                               final taskCubit = context.read<TaskCubit>();
//                               showModalBottomSheet(
//                                 context: context,
//                                 isScrollControlled: true,
//                                 backgroundColor:
//                                     Colors.transparent, // مهم للزوايا الدائرية
//                                 builder: (context) {
//                                   // نمرر نفس الكيوبت للنافذة الجديدة
//                                   return BlocProvider.value(
//                                     value: taskCubit,
//                                     // ✅ نستخدم الشيت المتطور، ونمرر المهمة للتعديل
//                                     child: AddTaskSheet(
//                                       // project: task
//                                       //     .project
//                                       //     .value, // تمرير المشروع الحالي إن وجد
//                                       taskToEdit: task, // تفعيل وضع التعديل
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     );
//                   }
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         heroTag: 'tasks_page_fab',
//         backgroundColor: AppColors.primary,
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text("مهمة جديدة", style: TextStyle(color: Colors.white)),
//         onPressed: () {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (ctx) => BlocProvider.value(
//               value: context.read<TaskCubit>(),
//               child: const AddTaskSheet(),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildKanbanView(BuildContext context, List<TaskModel> tasks) {
//     final todoTasks = tasks.where((t) => t.status == TaskStatus.todo).toList();
//     final inProgressTasks = tasks
//         .where((t) => t.status == TaskStatus.inProgress)
//         .toList();
//     final doneTasks = tasks.where((t) => t.status == TaskStatus.done).toList();

//     return PageView(
//       controller: _pageController,
//       children: [
//         _buildKanbanColumn(
//           "للقيام به",
//           Colors.grey,
//           todoTasks,
//           TaskStatus.todo,
//           context,
//         ),
//         _buildKanbanColumn(
//           "جاري العمل",
//           Colors.blue,
//           inProgressTasks,
//           TaskStatus.inProgress,
//           context,
//         ),
//         _buildKanbanColumn(
//           "مكتمل",
//           Colors.green,
//           doneTasks,
//           TaskStatus.done,
//           context,
//         ),
//       ],
//     );
//   }

//   Widget _buildKanbanColumn(
//     String title,
//     Color color,
//     List<TaskModel> tasks,
//     TaskStatus status,
//     BuildContext context,
//   ) {
//     return DragTarget<TaskModel>(
//       onWillAcceptWithDetails: (_) => true,
//       onAcceptWithDetails: (details) {
//         context.read<TaskCubit>().updateTaskStatus(details.data, status);
//         if (status == TaskStatus.done && !details.data.isCompleted) {
//           context.read<CelebrationCubit>().celebrate();
//         }
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
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
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
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: tasks.length,
//                   itemBuilder: (context, index) {
//                     final task = tasks[index];
//                     return LongPressDraggable<TaskModel>(
//                       data: task,
//                       feedback: SizedBox(
//                         width: 300.w,
//                         child: Material(
//                           color: Colors.transparent,
//                           child: TaskTile(
//                             task: task,
//                             onToggle: (_) {},
//                             onDelete: () {},
//                           ),
//                         ),
//                       ),
//                       childWhenDragging: Opacity(
//                         opacity: 0.3,
//                         child: TaskTile(
//                           task: task,
//                           onToggle: (_) {},
//                           onDelete: () {},
//                         ),
//                       ),
//                       child: TaskTile(
//                         task: task,
//                         onToggle: (val) {
//                           if (!task.isCompleted) {
//                             context.read<CelebrationCubit>().celebrate();
//                           }
//                           context.read<TaskCubit>().toggleTaskCompletion(task);
//                         },
//                         // ✅ استدعاء دالة الحذف الموحدة في الكانبان أيضاً
//                         onDelete: () => _onDeletePressed(context, task),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.task_alt, size: 80.sp, color: Colors.grey.shade300),
//           SizedBox(height: 16.h),
//           Text(
//             "يومك صافي!",
//             style: Theme.of(
//               context,
//             ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
//           ),
//           Text(
//             "أضف مهامك لتبدأ الأثر",
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//         ],
//       ),
//     );
//   }
// }
