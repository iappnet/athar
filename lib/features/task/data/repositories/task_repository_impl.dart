import 'package:athar/core/services/file_service.dart';
import 'package:athar/features/task/data/models/attachment_model.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/features/task/domain/repositories/task_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ نحتاجه للتحقق من Auth
// ... الاستيرادات
import 'package:athar/features/task/data/models/task_note_model.dart';
import 'package:athar/core/utils/data_mappers.dart';
import 'package:uuid/uuid.dart'; // تأكد من استيراد الماحول

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final Isar _isar;
  // ✅ استعدنا Supabase Client للتحقق من حالة المستخدم
  final SupabaseClient _supabase = Supabase.instance.client;

  TaskRepositoryImpl(this._isar);

  @override
  Future<void> addTask(TaskModel task) async {
    await _isar.writeTxn(() async {
      task.updatedAt = DateTime.now();
      task.isSynced = false;

      await _isar.taskModels.put(task);

      // ✅✅ ضروري: حفظ رابط التصنيف إذا كان موجوداً
      // (بما أننا أبقينا على IsarLink في الموديل الهجين)
      await task.category.save();
    });
  }

  @override
  Stream<List<TaskModel>> watchTasksByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // ✅ تصحيح 1: تحويل الـ null إلى نص فارغ لتجنب خطأ النوع
    final currentUserId = _supabase.auth.currentUser?.id ?? '';

    return _isar.taskModels
        .filter()
        .dateBetween(startOfDay, endOfDay)
        .deletedAtIsNull()
        .and()
        .group(
          (q) => q
              // 1. المهام التي أنشأتها أنا
              .userIdEqualTo(currentUserId) // ✅ الآن يقبلها لأنها String
              .or()
              // 2. المهام المسندة لي
              .assigneeIdEqualTo(currentUserId) // ✅ الآن يقبلها
              .or()
              // 3. المهام العامة (Public) في المساحات المشتركة
              .visibilityEqualTo('public'),
        )
        .sortByPriorityDesc()
        .watch(fireImmediately: true);
  }

  // ✅ الدالة الجديدة للموديولات
  @override
  Stream<List<TaskModel>> watchModuleTasks(String moduleId) {
    return _isar.taskModels
        .filter()
        .moduleIdEqualTo(moduleId)
        .deletedAtIsNull()
        .sortByIsCompleted()
        .thenByPriorityDesc()
        .watch(fireImmediately: true);
  }

  // ✅ الدالة الجديدة للمساحات
  @override
  Stream<List<TaskModel>> watchSpaceTasks(String spaceId) {
    return _isar.taskModels
        .filter()
        .spaceIdEqualTo(spaceId)
        .deletedAtIsNull()
        .watch(fireImmediately: true);
  }

  // ⚠️ تنبيه: هذه الدالة يجب حذفها من الـ Interface (domain layer)
  // لأن projectId لم يعد موجوداً في TaskModel.
  // إذا كنت مضطراً لإبقائها مؤقتاً لمنع الأخطاء، اجعلها ترجع Stream فارغ:
  @override
  Stream<List<TaskModel>> watchProjectTasks(int projectId) {
    // حل مؤقت: إرجاع قائمة فارغة لأن المشاريع القديمة انتهت
    return Stream.value([]);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    task.isSynced = false;
    task.updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.taskModels.put(task);
      // ✅ تحديث رابط التصنيف عند التعديل أيضاً
      await task.category.save();
    });
  }

  @override
  Future<void> updateTaskStatus(int taskId, TaskStatus status) async {
    await _isar.writeTxn(() async {
      final task = await _isar.taskModels.get(taskId);
      if (task != null) {
        task.status = status;
        task.isSynced = false;
        task.updatedAt = DateTime.now();
        await _isar.taskModels.put(task);
      }
    });
  }

  // ✅ تنفيذ دالة الإسناد الجديدة
  @override
  Future<void> assignTask({
    required String taskUuid,
    required String? userId,
  }) async {
    await _isar.writeTxn(() async {
      final task = await _isar.taskModels
          .filter()
          .uuidEqualTo(taskUuid)
          .findFirst();

      if (task != null) {
        task.assigneeId = userId; // تعيين المستخدم الجديد (أو null للإلغاء)
        task.isSynced = false;
        task.updatedAt = DateTime.now();
        await _isar.taskModels.put(task);
      }
    });
  }

  @override
  Future<void> toggleTaskCompletion(int taskId, bool isCompleted) async {
    await _isar.writeTxn(() async {
      final task = await _isar.taskModels.get(taskId);
      if (task != null) {
        task.isCompleted = isCompleted;
        task.completedAt = isCompleted ? DateTime.now() : null;
        task.isSynced = false;
        task.updatedAt = DateTime.now();
        await _isar.taskModels.put(task);
      }
    });
  }

  // ✅ استعدنا منطق الحذف الذكي (ضيوف vs أعضاء)
  @override
  Future<void> deleteTask(int id) async {
    final isUserLoggedIn = _supabase.auth.currentUser != null;

    await _isar.writeTxn(() async {
      if (!isUserLoggedIn) {
        // حذف نهائي للضيوف لتنظيف الجهاز
        await _isar.taskModels.delete(id);
      } else {
        // حذف ناعم للمسجلين للمزامنة
        final task = await _isar.taskModels.get(id);
        if (task != null) {
          task.deletedAt = DateTime.now();
          task.isSynced = false;
          task.updatedAt = DateTime.now();
          await _isar.taskModels.put(task);
        }
      }
    });
  }

  Future<void> undoDeleteTask(int id) async {
    await _isar.writeTxn(() async {
      final task = await _isar.taskModels.get(id);
      if (task != null) {
        task.deletedAt = null;
        task.isSynced = false;
        task.updatedAt = DateTime.now();
        await _isar.taskModels.put(task);
      }
    });
  }

  // ✅ ═══════════════════════════════════════════════════════════
  // 🔔 TASK REMINDERS IMPLEMENTATION - جديد!
  // ═══════════════════════════════════════════════════════════

  @override
  Future<List<TaskModel>> getActiveTasks() async {
    return await _isar.taskModels
        .filter()
        .isCompletedEqualTo(false)
        .and()
        .deletedAtIsNull()
        .findAll();
  }

  @override
  Future<List<TaskModel>> getTasksWithReminders() async {
    return await _isar.taskModels
        .filter()
        .reminderTimeIsNotNull()
        .and()
        .isCompletedEqualTo(false)
        .and()
        .deletedAtIsNull()
        .findAll();
  }

  @override
  Future<List<TaskModel>> getUpcomingTasksWithReminders({
    required int days,
  }) async {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));

    return await _isar.taskModels
        .filter()
        .reminderTimeIsNotNull()
        .and()
        .isCompletedEqualTo(false)
        .and()
        .deletedAtIsNull()
        .and()
        .reminderTimeGreaterThan(now)
        .and()
        .reminderTimeLessThan(future)
        .findAll();
  }

  // ✅ استعدنا هذه الدالة لأنها مطلوبة غالباً في الواجهة
  @override
  Future<TaskModel?> getTaskById(int id) async {
    return await _isar.taskModels.get(id);
  }

  // ✅ استعدنا هذه الدالة لأنها مطلوبة
  @override
  Future<List<TaskModel>> getTasksForDay(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await _isar.taskModels
        .filter()
        .dateBetween(startOfDay, endOfDay)
        .deletedAtIsNull()
        .findAll();
  }

  // ✅ 1. دالة إضافة/تعديل السبورة (Upsert)
  @override
  Future<void> upsertMyNote({
    required String taskId,
    required String content,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return; // حماية

    // أ. الحفظ المحلي الفوري (Optimistic UI)
    final now = DateTime.now();

    await _isar.writeTxn(() async {
      // نبحث هل توجد ملاحظة سابقة لي في هذه المهمة؟
      var myNote = await _isar.taskNoteModels
          .filter()
          .taskIdEqualTo(taskId)
          .userIdEqualTo(userId)
          .findFirst();

      if (myNote == null) {
        // إنشاء جديد
        myNote = TaskNoteModel()
          ..uuid = const Uuid()
              .v4() // مؤقت حتى المزامنة
          ..taskId = taskId
          ..userId = userId
          ..content = content
          ..updatedAt = now
          ..isSynced = false;
      } else {
        // تحديث موجود
        myNote.content = content;
        myNote.updatedAt = now;
        myNote.isSynced = false;
      }

      await _isar.taskNoteModels.put(myNote);
    });

    // ب. الرفع للسحابة (Upsert)
    try {
      // نستخدم upsert بناءً على القيد (task_id, user_id)
      final noteData = {
        'task_id': taskId,
        'user_id': userId,
        'content': content,
        'updated_at': now.toIso8601String(),
      };

      // ملاحظة: نستخدم onConflict لتحديث السجل إذا كان موجوداً
      await _supabase
          .from('task_member_notes')
          .upsert(noteData, onConflict: 'task_id, user_id');

      // تحديث الحالة محلياً أنها تزامنت
      await _isar.writeTxn(() async {
        final syncedNote = await _isar.taskNoteModels
            .filter()
            .taskIdEqualTo(taskId)
            .userIdEqualTo(userId)
            .findFirst();
        if (syncedNote != null) {
          syncedNote.isSynced = true;
          await _isar.taskNoteModels.put(syncedNote);
        }
      });
    } catch (e) {
      // خطأ في المزامنة (سيعالج لاحقاً عبر خدمة المزامنة الخلفية)
      debugPrint("Error pushing note: $e");
    }
  }

  // ✅ 2. مراقبة سبورات الفريق (Stream)
  @override
  Stream<List<TaskNoteModel>> watchTaskNotes(String taskId) {
    // نجلب الملاحظات من Isar
    return _isar.taskNoteModels
        .filter()
        .taskIdEqualTo(taskId)
        .watch(fireImmediately: true)
        .map((notes) {
          // ✅ تطبيق شرطك: لا تظهر إلا إذا كتب شيئاً
          return notes.where((n) => n.hasContent).toList();
        });
  }

  // ✅ 3. جلب تحديثات السبورات من السحابة (Sync Pull)
  // هذه الدالة تستدعى عند فتح صفحة المهمة
  @override
  Future<void> fetchRemoteNotes(String taskId) async {
    try {
      final response = await _supabase
          .from('task_member_notes')
          .select()
          .eq('task_id', taskId);

      await _isar.writeTxn(() async {
        for (var item in response) {
          final note = TaskNoteModel();
          note.updateFromMap(item); // استخدام الماحول

          // نستخدم المعرف المركب للبحث والحفظ
          final existing = await _isar.taskNoteModels
              .filter()
              .taskIdEqualTo(note.taskId)
              .userIdEqualTo(note.userId)
              .findFirst();

          if (existing != null) {
            note.id = existing.id; // الحفاظ على ID المحلي
          }

          await _isar.taskNoteModels.put(note);
        }
      });
    } catch (e) {
      debugPrint("Error fetching notes: $e");
    }
  }

  // ✅ 1. إضافة مرفق جديد
  @override
  Future<void> addAttachment(String taskId, FileProcessResult result) async {
    final userId = _supabase.auth.currentUser?.id; // قد يكون null إذا زائر

    final attachment = AttachmentModel()
      ..uuid = const Uuid().v4()
      ..taskId = taskId
      ..fileName = result.fileName
      ..fileType = result.fileType
      ..fileSize = result.fileSize
      ..localPath = result
          .localPath // المسار المحلي (دائماً موجود)
      ..storagePath = result
          .storagePath // المسار السحابي (قد يكون null)
      ..expiresAt = result.expiresAt
      ..uploaderId = userId
      ..createdAt = DateTime.now()
      ..isSynced = false;

    // أ. الحفظ المحلي
    await _isar.writeTxn(() async {
      await _isar.attachmentModels.put(attachment);
    });

    // ب. الرفع للسحابة (فقط إذا كان هناك مسار سحابي)
    if (result.storagePath != null) {
      try {
        final map = attachment.toMap();
        // إزالة الحقول المحلية قبل الرفع لضمان الأمان
        map.remove('local_path');

        await _supabase.from('attachments').insert(map);

        // تحديث حالة المزامنة
        await _isar.writeTxn(() async {
          attachment.isSynced = true;
          await _isar.attachmentModels.put(attachment);
        });
      } catch (e) {
        debugPrint("Error pushing attachment metadata: $e");
      }
    }
  }

  // ✅ 2. مراقبة مرفقات المهمة
  @override
  Stream<List<AttachmentModel>> watchAttachments(String taskId) {
    return _isar.attachmentModels
        .filter()
        .taskIdEqualTo(taskId)
        .deletedAtIsNull() // لا نعرض المحذوف
        .watch(fireImmediately: true);
  }

  // ✅ 3. حذف مرفق
  @override
  Future<void> deleteAttachment(String attachmentUuid) async {
    await _isar.writeTxn(() async {
      final attachment = await _isar.attachmentModels
          .filter()
          .uuidEqualTo(attachmentUuid)
          .findFirst();

      if (attachment != null) {
        attachment.deletedAt = DateTime.now();
        attachment.isSynced = false;
        await _isar.attachmentModels.put(attachment);
      }
    });
    // (المزامنة الخلفية ستتولى حذف السجل من Supabase لاحقاً)
  }

  // ✅ 1. دالة طلب إعادة الإحياء
  @override // تأكد من إضافتها للـ Interface أولاً
  Future<void> requestResurrection(String attachmentUuid) async {
    try {
      // نرسل إشارة للسيرفر (ليراها المالك)
      await _supabase
          .from('attachments')
          .update({'resurrection_requested': true})
          .eq('uuid', attachmentUuid);
    } catch (e) {
      debugPrint("Error requesting resurrection: $e");
      // يمكننا تجاهل الخطأ في حالة الأوفلاين، أو تخزينه في طابور
    }
  }

  // ✅ 2. دالة تحديث ترتيب مهمة (أو مجموعة مهام)
  @override
  Future<void> updateTaskPosition(String taskUuid, double newPosition) async {
    await _isar.writeTxn(() async {
      final task = await _isar.taskModels
          .filter()
          .uuidEqualTo(taskUuid)
          .findFirst();
      if (task != null) {
        task.position = newPosition;
        task.isSynced = false; // ليتم مزامنة الترتيب الجديد
        task.updatedAt = DateTime.now();
        await _isar.taskModels.put(task);
      }
    });
  }
}
// // import 'package:athar/features/project/data/models/project_model.dart';
// import 'package:isar/isar.dart';
// import 'package:injectable/injectable.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../domain/repositories/task_repository.dart';
// import '../models/task_model.dart';

// @LazySingleton(as: TaskRepository)
// class TaskRepositoryImpl implements TaskRepository {
//   final Isar _isar;
//   // ✅ نصل لـ Supabase مباشرة للتحقق من الحالة
//   final SupabaseClient _supabase = Supabase.instance.client;

//   TaskRepositoryImpl(this._isar);

//   @override
//   Stream<List<TaskModel>> watchTasksByDate(DateTime date) {
//     final startOfDay = DateTime(date.year, date.month, date.day);
//     final endOfDay = startOfDay.add(const Duration(days: 1));

//     return _isar.taskModels
//         .filter()
//         .dateGreaterThan(startOfDay, include: true)
//         .and()
//         .deletedAtIsNull() // ✅ إضافة هذا الشرط ضروري جداً
//         .dateLessThan(endOfDay)
//         .sortByIsCompleted()
//         .thenByPriorityDesc() // ترتيب حسب الأولوية
//         .thenByCreatedAtDesc() // ثم الأحدث
//         .watch(fireImmediately: true);
//   }

//   @override
//   Stream<List<TaskModel>> watchProjectTasks(int projectId) {
//     return _isar.taskModels
//         .filter()
//         // .project((q) => q.idEqualTo(projectId))
//         .deletedAtIsNull() // ✅✅ الحل الجذري 1: استبعاد المحذوفات هنا أيضاً
//         .watch(fireImmediately: true);
//   }

//   @override
//   Future<void> updateTaskStatus(int taskId, TaskStatus newStatus) async {
//     await _isar.writeTxn(() async {
//       final task = await _isar.taskModels.get(taskId);
//       if (task != null) {
//         task.status = newStatus;
//         if (newStatus == TaskStatus.done) {
//           task.isCompleted = true;
//           task.completedAt = DateTime.now();
//         } else {
//           task.isCompleted = false;
//           task.completedAt = null;
//         }
//         await _isar.taskModels.put(task);
//       }
//     });
//   }

//   // نفس الشيء عند التعديل لضمان عدم ضياع الرابط
//   @override
//   Future<void> updateTask(TaskModel task) async {
//     // عند التحديث، نعتبره تعديلاً محلياً جديداً ليتم مزامنته
//     task.isSynced = false;
//     task.updatedAt = DateTime.now();
//     await _isar.writeTxn(() async {
//       await _isar.taskModels.put(task);
//       // await task.project.save(); // ✅ تأكيد حفظ الرابط عند التعديل أيضاً
//     });
//   }

//   @override
//   Future<void> addTask(TaskModel task) async {
//     await _isar.writeTxn(() async {
//       await _isar.taskModels.put(task);
//       await task.category.save(); // ✅✅ هذا السطر هو الحل (حفظ الرابط)
//       // await task.project.save(); // وحفظ المشروع أيضاً
//     });
//   }

//   @override
//   Future<void> toggleTaskCompletion(int taskId, bool isCompleted) async {
//     await _isar.writeTxn(() async {
//       final task = await _isar.taskModels.get(taskId);
//       if (task != null) {
//         task.isCompleted = isCompleted;
//         task.status = isCompleted ? TaskStatus.done : TaskStatus.todo;
//         if (isCompleted) {
//           task.completedAt = DateTime.now();
//         } else {
//           task.completedAt = null;
//         }
//         await _isar.taskModels.put(task);
//       }
//     });
//   }

//   @override
//   Future<void> deleteTask(int id) async {
//     // 1. التحقق: هل المستخدم مسجل دخول؟
//     final isUserLoggedIn = _supabase.auth.currentUser != null;

//     await _isar.writeTxn(() async {
//       // 2. إذا كان مستخدم محلي فقط (غير مسجل) -> حذف نهائي
//       if (!isUserLoggedIn) {
//         await _isar.taskModels.delete(id);
//         return; // انتهينا
//       }

//       // 3. إذا كان مسجلاً -> حذف ناعم (Soft Delete) للمزامنة
//       final task = await _isar.taskModels.get(id);
//       if (task != null) {
//         task.deletedAt = DateTime.now();
//         task.isSynced = false;
//         // مهم جداً: تحديث وقت التعديل لضمان فوز الحذف في استراتيجية LWW
//         task.updatedAt = DateTime.now();
//         await _isar.taskModels.put(task);
//       }
//     });
//   }

//   // @override
//   // Future<void> deleteTask(int id) async {
//   //   await _isar.writeTxn(() async {
//   //     await _isar.taskModels.delete(id);
//   //   });
//   // }

//   @override
//   Future<TaskModel?> getTaskById(int id) async {
//     return await _isar.taskModels.get(id);
//   }

//   @override
//   Future<List<TaskModel>> getTasksForDay(DateTime date) async {
//     final startOfDay = DateTime(date.year, date.month, date.day);
//     final endOfDay = startOfDay.add(const Duration(days: 1));

//     return await _isar.taskModels
//         .filter()
//         .dateGreaterThan(startOfDay, include: true)
//         .and()
//         .deletedAtIsNull() // ✅✅ الإضافة الضرورية: استثناء المحذوفات ناعماً
//         .and() // لا تنسى ربط الشروط بـ and
//         .dateLessThan(endOfDay)
//         .findAll(); // ✅ استخدام findAll بدلاً من watch
//   }
// }
