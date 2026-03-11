import 'package:injectable/injectable.dart';
import '../../features/task/domain/repositories/task_repository.dart';
import '../../features/task/domain/models/conflict_result.dart';

@lazySingleton
class TimeConflictService {
  final TaskRepository _taskRepository;

  TimeConflictService(this._taskRepository);

  /// فحص التعارض الزمني مع مهام أخرى
  Future<ConflictResult> checkTaskConflict({
    required DateTime newTaskDate,
    required int durationMinutes,
    int? excludeTaskId, // لتجنب التعارض مع النفس عند التعديل
  }) async {
    // 1. جلب مهام اليوم المحدد
    final tasks = await _taskRepository.getTasksForDay(newTaskDate);

    // 2. حساب وقت البداية والنهاية للمهمة الجديدة
    final newStart = newTaskDate;
    final newEnd = newStart.add(Duration(minutes: durationMinutes));

    // 3. البحث عن أي تداخل
    for (var task in tasks) {
      // تجاهل المهمة نفسها (في حالة التعديل)
      if (excludeTaskId != null && task.id == excludeTaskId) continue;

      final taskStart = task.date;
      // نستخدم المدة المحفوظة أو 30 دقيقة كافتراضي
      final taskDuration = task.durationMinutes;
      final taskEnd = taskStart.add(Duration(minutes: taskDuration));

      // ⚠️ منطق التقاطع (Overlap Logic)
      // (StartA < EndB) and (EndA > StartB)
      if (newStart.isBefore(taskEnd) && newEnd.isAfter(taskStart)) {
        return ConflictResult.warning(
          "لديك مهمة أخرى في هذا الوقت: '${task.title}'",
          suggestedTime: taskEnd, // ✅ نقترح البدء فور انتهاء هذه المهمة
        );
      }
    }

    return ConflictResult.none();
  }
}
