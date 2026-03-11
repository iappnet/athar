import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'delegation_mode.dart';
// ✅ استخدام الحالات لتوحيد منطق المشاريع
import '../../domain/entities/project_entity.dart';

part 'module_model.g.dart';

@Collection()
class ModuleModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String spaceId;

  late String name;
  String? description;
  int? color;
  int? iconCode;

  // 🗓️ التواريخ والمواعيد النهائية (من النظام القديم)
  DateTime? startDate;
  DateTime? endDate;
  DateTime? completedDate;

  String? creatorId;
  String visibility = 'public'; // public, private

  @Enumerated(EnumType.name)
  DelegationMode delegationMode = DelegationMode.inherit;

  @Index()
  String status = 'active'; // active, archived, completed, cancelled

  @Index()
  double position = 0.0;

  @Index()
  late String type; // 'project', 'list', 'health'

  bool isSynced = false;

  // 🔔 إعدادات الإشعارات والتقدم (جينات النظام القديم)
  bool reminderEnabled = true;
  DateTime? reminderTime; // ✅ أضف هذا السطر فوراً
  int reminderDaysBefore = 7;
  int reminderHoursBefore = 24;
  double progressPercentage = 0.0;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  DateTime? deletedAt;

  ModuleModel() {
    uuid = const Uuid().v4();
  }

  // ✅ الإصلاح النهائي: تعريف الخصائص كـ @Ignore لضمان عمل الـ Cubit والـ Scheduler
  @Ignore()
  bool get isProject => type == 'project';

  @Ignore()
  bool get isCompleted => status == ProjectStatus.completed.name;
  @Ignore()
  bool get isArchived => status == ProjectStatus.archived.name;
  @Ignore()
  bool get isCancelled => status == ProjectStatus.cancelled.name;

  // ═══════════════════════════════════════════════════════════
  // ✅ خصائص ذكية محسوبة (Computed Properties)
  // ═══════════════════════════════════════════════════════════

  @Ignore()
  bool get isOverdue {
    if (endDate == null || status == ProjectStatus.completed.name) return false;
    return DateTime.now().isAfter(endDate!);
  }

  @Ignore()
  bool get isDueSoon {
    if (endDate == null || status == ProjectStatus.completed.name) return false;
    final daysUntil = endDate!.difference(DateTime.now()).inDays;
    return daysUntil <= reminderDaysBefore && daysUntil >= 0;
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ التحويل البرمجي (Serialization)
  // ═══════════════════════════════════════════════════════════

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel()
      ..uuid = json['uuid']
      ..spaceId = json['space_id']
      ..name = json['name']
      ..description = json['description']
      ..color = json['color']
      ..iconCode = json['icon_code']
      ..startDate = json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null
      ..endDate = json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null
      ..completedDate = json['completed_date'] != null
          ? DateTime.parse(json['completed_date'])
          : null
      ..creatorId = json['creator_id']
      ..visibility = json['visibility'] ?? 'public'
      ..status = json['status'] ?? 'active'
      ..position = (json['position'] ?? 0.0).toDouble()
      ..type = json['type']
      ..reminderEnabled = json['reminder_enabled'] ?? true
      ..reminderTime = json['reminder_time'] != null
          ? DateTime.parse(json['reminder_time'])
          : null
      ..reminderDaysBefore = json['reminder_days_before'] ?? 7
      ..reminderHoursBefore = json['reminder_hours_before'] ?? 24
      ..progressPercentage = (json['progress_percentage'] ?? 0.0).toDouble()
      ..isSynced = true
      ..createdAt = DateTime.parse(json['created_at'])
      ..updatedAt = DateTime.parse(json['updated_at']);
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'space_id': spaceId,
      'name': name,
      'description': description,
      'color': color,
      'icon_code': iconCode,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'creator_id': creatorId,
      'visibility': visibility,
      'status': status,
      'position': position,
      'type': type,
      'reminder_enabled': reminderEnabled,
      'reminder_time': reminderTime?.toIso8601String(),
      'reminder_days_before': reminderDaysBefore,
      'reminder_hours_before': reminderHoursBefore,
      'progress_percentage': progressPercentage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
