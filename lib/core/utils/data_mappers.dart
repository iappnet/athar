import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/features/space/data/models/space_model.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/task/data/models/attachment_model.dart';
import 'package:athar/features/task/data/models/task_note_model.dart';

extension TaskNoteMapper on TaskNoteModel {
  Map<String, dynamic> toMap() {
    return {
      'id': uuid, // Supabase يستخدم id كـ UUID
      'task_id': taskId,
      'user_id': userId,
      'content': content,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  void updateFromMap(Map<String, dynamic> map) {
    uuid = map['id']; // تأكد أن الاسم يطابق العمود في SQL
    taskId = map['task_id'];
    userId = map['user_id'];
    content = map['content'];
    updatedAt = DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now();
    isSynced = true;
  }
}

extension TaskMapper on TaskModel {
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'created_by': userId,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'date': date.toIso8601String(),
      'time': time?.toIso8601String(),
      'duration': durationMinutes,
      'priority': priority.index,
      'is_urgent': isUrgent,
      'is_important': isImportant,
      'category_id': categoryId,
      'module_id': moduleId,
      'space_id': spaceId,
      'is_hidden': isHidden,
      'assigned_to': assignedTo,
      'completion_note': completionNote,
      // ✅ إضافة الحقل الجديد للترتيب اليدوي
      'position': position,

      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  void updateFromMap(Map<String, dynamic> map) {
    userId = map['created_by'] ?? map['user_id'] ?? '';
    title = map['title'] ?? '';
    description = map['description'];
    isCompleted = map['is_completed'] ?? false;
    date = DateTime.tryParse(map['date'] ?? '') ?? DateTime.now();
    time = map['time'] != null ? DateTime.tryParse(map['time']) : null;
    durationMinutes = map['duration'] ?? 30;
    priority = TaskPriority.values[map['priority'] ?? 1];
    isUrgent = map['is_urgent'] ?? false;
    isImportant = map['is_important'] ?? false;
    categoryId = map['category_id'];
    moduleId = map['module_id'];
    spaceId = map['space_id'];
    isHidden = map['is_hidden'] ?? false;
    assignedTo = map['assigned_to'];
    completionNote = map['completion_note'];

    // ✅ قراءة الترتيب من السيرفر (مع قيمة افتراضية لتجنب الخطأ)
    position = (map['position'] ?? 0.0).toDouble();

    updatedAt = map['updated_at'] != null
        ? DateTime.tryParse(map['updated_at']) ?? DateTime.now()
        : DateTime.now();
    deletedAt = map['deleted_at'] != null
        ? DateTime.tryParse(map['deleted_at'])
        : null;
    isSynced = true;
  }
}

extension HabitMapper on HabitModel {
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'user_id': userId,
      'title': title,
      'streak': streak,
      'target_days': targetDays,
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  void updateFromMap(Map<String, dynamic> map) {
    title = map['title'];
    streak = map['streak'] ?? 0;
    targetDays = map['target_days'];
    updatedAt = map['updated_at'] != null
        ? DateTime.tryParse(map['updated_at']) ?? DateTime.now()
        : DateTime.now();
    isSynced = true;
  }
}

extension SpaceMapper on SpaceModel {
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'type': type,
      'owner_id': ownerId == 'guest' ? null : ownerId,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  void updateFromMap(Map<String, dynamic> map) {
    name = map['name'];
    type = map['type'];
    ownerId = map['owner_id'] ?? '';
    updatedAt = map['updated_at'] != null
        ? DateTime.tryParse(map['updated_at']) ?? DateTime.now()
        : DateTime.now();
    isSynced = true;
  }
}

extension ModuleMapper on ModuleModel {
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'space_id': spaceId,
      'name': name,
      'type': type,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  void updateFromMap(Map<String, dynamic> map) {
    name = map['name'];
    type = map['type'];
    spaceId = map['space_id'];

    // ✅ قراءة الحقول الجديدة من السيرفر
    description = map['description'];
    startDate = map['start_date'] != null
        ? DateTime.tryParse(map['start_date'])
        : null;
    endDate = map['end_date'] != null
        ? DateTime.tryParse(map['end_date'])
        : null;
    status = map['status'] ?? 'active';
    position = (map['position'] ?? 0.0).toDouble();

    updatedAt = map['updated_at'] != null
        ? DateTime.tryParse(map['updated_at']) ?? DateTime.now()
        : DateTime.now();
    isSynced = true;
  }
}

// ✅ هذا الماحول الجديد صحيح 100%
extension AttachmentMapper on AttachmentModel {
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'task_id': taskId,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'storage_path': storagePath,
      'expires_at': expiresAt?.toIso8601String(),
      'is_deleted_from_cloud': isDeletedFromCloud,
      'uploader_id': uploaderId,
      'created_at': createdAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  void updateFromMap(Map<String, dynamic> map) {
    storagePath = map['storage_path'];
    expiresAt = map['expires_at'] != null
        ? DateTime.tryParse(map['expires_at'])
        : null;
    isDeletedFromCloud = map['is_deleted_from_cloud'] ?? false;
    uploaderId = map['uploader_id'];

    // ملاحظة: localPath لا يأتي من السيرفر، بل يبقى كما هو في الجهاز

    isSynced = true;
  }
}
