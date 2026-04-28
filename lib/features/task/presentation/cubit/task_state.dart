import 'package:equatable/equatable.dart';
import '../../data/models/task_model.dart';
import '../../domain/models/filter_item.dart'; // ✅ استيراد الواجهة الجديدة

abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  // حذفنا PrayerItem Lists من هنا

  // ✅ استخدام النوع الموحد (الافتراضي هو FixedFilterType.all)
  final FilterItem activeFilter;
  final int completedCount;
  final int totalCount;

  // ✅ قائمة الفلاتر المتاحة (ثابتة + ديناميكية)
  final List<FilterItem> availableFilters;

  TaskLoaded({
    required this.tasks,
    this.activeFilter = FixedFilterType.all,
    this.availableFilters = const [
      FixedFilterType.all,
      FixedFilterType.urgent,
    ],
  }) : completedCount = tasks.where((t) => t.isCompleted).length,
       totalCount = tasks.length;

  // ✅ منطق الفلترة الجديد
  List<TaskModel> get filteredTasks {
    // 1. إذا كان فلتر ثابت
    if (activeFilter is FixedFilterType) {
      switch (activeFilter as FixedFilterType) {
        case FixedFilterType.urgent:
          return tasks.where((t) => t.isUrgent).toList();
        case FixedFilterType.all:
          return tasks;
        default:
          return tasks;
      }
    }
    // 2. إذا كان تصنيف (ديناميكي)
    else if (activeFilter is CategoryFilter) {
      final catId = (activeFilter as CategoryFilter).category.id;
      return tasks.where((t) {
        // التحقق من الرابط
        return t.category.value?.id == catId;
      }).toList();
    }

    return tasks;
  }

  TaskLoaded copyWith({
    List<TaskModel>? tasks,
    FilterItem? activeFilter,
    List<FilterItem>? availableFilters,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      activeFilter: activeFilter ?? this.activeFilter,
      availableFilters: availableFilters ?? this.availableFilters,
    );
  }

  @override
  List<Object?> get props => [
    tasks,
    activeFilter,
    availableFilters,
    completedCount,
  ];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Emitted when a free user tries to create a task beyond the free limit.
class TaskFreeLimitReached extends TaskState {}
