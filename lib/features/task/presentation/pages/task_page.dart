// ————-————— code start ————————-
import 'package:athar/core/config/subscription_config.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/features/subscription/presentation/widgets/pro_gate_widget.dart';
import 'package:athar/core/utils/responsive_helper.dart';
import 'package:athar/core/design_system/widgets/athar_feedback.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
import 'package:athar/core/design_system/molecules/skeletons/athar_skeleton.dart';
import 'package:athar/core/design_system/organisms/app_bar/athar_app_bar.dart';
import 'package:athar/features/calendar/presentation/pages/calendar_page.dart';
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
const _successColor = AppColors.success;

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
        actions: null,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isTablet ? ResponsiveHelper.maxContentWidth : double.infinity,
          ),
          child: Column(
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
                      } else if (state is TaskFreeLimitReached) {
                        showUpgradeNudge(
                          context,
                          message: 'لقد وصلت إلى الحد المجاني للمهام. قم بالترقية للحصول على مهام غير محدودة',
                          entitlementId: SubscriptionConfig.entitlementSpacesPro,
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
                                  default:
                                    return Icons.label_outline;
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
                    itemBuilder: (_, _) => Padding(
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
        ),
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
                      borderRadius: AtharRadii.radiusMd,
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
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.task_alt_outlined,
              size: 44,
              color: colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          AtharGap.lg,
          Text(
            l10n.dayClear,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          AtharGap.xs,
          Text(
            l10n.addTasksToStart,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: colorScheme.outline,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
// ————-————— code end ————————-
