import 'package:athar/core/services/file_service.dart';
import 'package:athar/features/task/data/models/attachment_model.dart';
import 'package:athar/features/task/data/models/task_note_model.dart';

import '../../data/models/task_model.dart';

abstract class TaskRepository {
  /// مراقبة المهام ليوم محدد
  Stream<List<TaskModel>> watchTasksByDate(DateTime date);

  /// إضافة مهمة جديدة
  Future<void> addTask(TaskModel task);

  /// تحديث مهمة موجودة
  Future<void> updateTask(TaskModel task);

  /// حذف مهمة
  Future<void> deleteTask(int id);

  /// جلب مهمة بالمعرف
  Future<TaskModel?> getTaskById(int id);

  /// تبديل حالة الإنجاز
  Future<void> toggleTaskCompletion(int id, bool isCompleted);

  /// تحديث حالة المهمة
  Future<void> updateTaskStatus(int taskId, TaskStatus newStatus);

  /// جلب مهام يوم محدد
  Future<List<TaskModel>> getTasksForDay(DateTime date);
  // ✅✅ الإضافة الضرورية لحل الخطأ
  /// مراقبة مهام موديول معين (مشروع أو قائمة)
  Stream<List<TaskModel>> watchModuleTasks(String moduleId);

  /// مراقبة مهام مساحة كاملة
  Stream<List<TaskModel>> watchSpaceTasks(String spaceId);
  // دالة المشاريع القديمة (يمكنك إبقاؤها مؤقتاً أو حذفها)
  Stream<List<TaskModel>> watchProjectTasks(int projectId);
  // ✅✅ الدوال الجديدة التي كانت ناقصة (الحل الجذري للأخطاء)
  Future<void> upsertMyNote({required String taskId, required String content});
  Stream<List<TaskNoteModel>> watchTaskNotes(String taskId);
  Future<void> fetchRemoteNotes(String taskId);
  // ✅✅ الدوال الجديدة للمرفقات (يجب إضافتها هنا لتكون متاحة للـ Cubit)
  Future<void> addAttachment(String taskId, FileProcessResult result);
  Stream<List<AttachmentModel>> watchAttachments(String taskId);
  Future<void> deleteAttachment(String attachmentUuid);
  Future<void> requestResurrection(String attachmentUuid);
  Future<void> updateTaskPosition(String taskUuid, double newPosition);
  // ✅ الدالة الجديدة لإسناد المهمة
  Future<void> assignTask({required String taskUuid, required String? userId});

  // ✅ ═══════════════════════════════════════════════════════════
  // 🔔 TASK REMINDERS - جديد!
  // ═══════════════════════════════════════════════════════════

  /// جلب جميع المهام النشطة (غير المكتملة وغير المحذوفة)
  Future<List<TaskModel>> getActiveTasks();

  /// جلب المهام التي لها تذكيرات مجدولة
  Future<List<TaskModel>> getTasksWithReminders();

  /// جلب المهام القادمة ذات التذكيرات (في الأيام القادمة)
  Future<List<TaskModel>> getUpcomingTasksWithReminders({required int days});
}
