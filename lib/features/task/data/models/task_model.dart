// lib/features/task/data/models/task_model.dart
// ✅ محدث مع دعم الأوقات الشرعية (متوافق مع Isar)

import 'package:athar/core/time_engine/time_slot_mixin.dart';
import 'package:athar/core/time_engine/athar_time_periods.dart';
import 'package:athar/features/settings/data/models/category_model.dart';
import 'package:athar/features/task/data/models/attachment_model.dart';
import 'package:athar/features/task/data/models/recurrence_pattern.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'task_model.g.dart';

enum TaskPriority { high, medium, low }

enum TaskStatus { todo, inProgress, done }

@Collection()
class TaskModel with TimeSlotMixin {
  Id id = Isar.autoIncrement;

  // --- 1. الهوية والمزامنة ---
  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String userId;

  bool isSynced = false;

  DateTime? updatedAt;
  DateTime? deletedAt;

  /// ✅ هل هذه مهمة تجريبية؟
  bool isSampleData = false;

  DateTime createdAt = DateTime.now();

  // ✅ حقول التكرار
  bool isRecurring = false;
  RecurrencePattern? recurrence;
  String? parentRecurrenceId;
  DateTime? occurrenceDate;
  String? templateId;

  @ignore
  bool isSelected = false;

  @Index()
  double position = 0.0;

  final attachments = IsarLinks<AttachmentModel>();

  String? createdBy;

  @Index()
  String visibility = 'public';

  @Index()
  String? assigneeId;

  bool isReassignable = true;

  List<String>? assigneesIds;

  // --- 2. الهيكلية المكانية ---
  @Index()
  String? spaceId;

  @Index()
  String? automationLinkId;

  @Index()
  String? moduleId;

  bool isHidden = false;
  String? assignedTo;

  // --- 3. التركيز والتصنيف ---
  @Index()
  int? categoryId;

  final category = IsarLink<CategoryModel>();

  // --- 4. البيانات الأساسية ---
  @Index(type: IndexType.value)
  late String title;

  String? description;

  @Index()
  late DateTime date;

  DateTime? time;

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅✅✅ الحقول الجديدة للأوقات الشرعية ✅✅✅
  // ⚠️ Isar لا يدعم nullable enums، لذا نخزنها كـ int?
  // ═══════════════════════════════════════════════════════════════════════════

  /// نوع تحديد الوقت (ثابت / نسبي للصلاة / فترة)
  /// 0 = fixed, 1 = relativeToPrayer, 2 = period
  int timeTypeIndex = 0;

  /// ✅ Getter للحصول على الـ enum
  @ignore
  TimeSpecificationType get timeType =>
      TimeSpecificationType.values[timeTypeIndex];

  /// ✅ Setter لتعيين الـ enum
  set timeType(TimeSpecificationType value) => timeTypeIndex = value.index;

  /// الوقت الثابت (ساعة) - يُستخدم مع timeType = fixed
  int? fixedHour;

  /// الوقت الثابت (دقيقة)
  int? fixedMinute;

  /// الصلاة المرجعية - مخزنة كـ int? (index)
  /// null = غير محدد، 0-4 = fajr, dhuhr, asr, maghrib, isha
  int? referencePrayerIndex;

  /// ✅ Getter
  @ignore
  ReferencePrayer? get referencePrayer => referencePrayerIndex != null
      ? ReferencePrayer.values[referencePrayerIndex!]
      : null;

  /// ✅ Setter
  set referencePrayer(ReferencePrayer? value) =>
      referencePrayerIndex = value?.index;

  /// العلاقة بالصلاة (قبل/بعد/إقامة) - مخزنة كـ int?
  int? prayerRelationIndex;

  /// ✅ Getter
  @ignore
  PrayerRelativeTime? get prayerRelation => prayerRelationIndex != null
      ? PrayerRelativeTime.values[prayerRelationIndex!]
      : null;

  /// ✅ Setter
  set prayerRelation(PrayerRelativeTime? value) =>
      prayerRelationIndex = value?.index;

  /// الفارق بالدقائق (قبل أو بعد الصلاة)
  int offsetMinutes = 0;

  /// الفترة الزمنية - مخزنة كـ int?
  int? timePeriodIndex;

  /// ✅ Getter
  @ignore
  AtharTimePeriod? get timePeriod =>
      timePeriodIndex != null ? AtharTimePeriod.values[timePeriodIndex!] : null;

  /// ✅ Setter
  set timePeriod(AtharTimePeriod? value) => timePeriodIndex = value?.index;

  /// موقع ضمن الفترة (بداية/منتصف/نهاية) - مخزنة كـ int?
  int? periodPositionIndex;

  /// ✅ Getter
  @ignore
  PeriodPosition? get periodPosition => periodPositionIndex != null
      ? PeriodPosition.values[periodPositionIndex!]
      : null;

  /// ✅ Setter
  set periodPosition(PeriodPosition? value) =>
      periodPositionIndex = value?.index;

  // ═══════════════════════════════════════════════════════════════════════════

  // --- 5. الحالة والأولوية ---
  @Enumerated(EnumType.ordinal)
  TaskPriority priority = TaskPriority.medium;

  @Enumerated(EnumType.ordinal)
  TaskStatus status = TaskStatus.todo;

  bool isCompleted = false;
  DateTime? completedAt;

  // --- 6. مميزات إضافية ---
  bool isUrgent = false;
  bool isImportant = false;
  int durationMinutes = 30;
  String? completionNote;

  // --- 7. نظام التذكيرات ---
  DateTime? reminderTime;

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ تنفيذ TimeSlotMixin
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  @ignore
  TimeSlotSettings? get timeSlotSettings {
    switch (timeType) {
      case TimeSpecificationType.fixed:
        if (fixedHour == null) {
          // Fallback للوقت القديم
          if (time != null) {
            return TimeSlotSettings.fixed(
              TimeOfDay(hour: time!.hour, minute: time!.minute),
            );
          }
          return null;
        }
        return TimeSlotSettings.fixed(
          TimeOfDay(hour: fixedHour!, minute: fixedMinute ?? 0),
        );

      case TimeSpecificationType.relativeToPrayer:
        if (referencePrayer == null) return null;
        return TimeSlotSettings.relativeToPrayer(
          prayer: referencePrayer!,
          relation: prayerRelation ?? PrayerRelativeTime.after,
          offsetMinutes: offsetMinutes,
        );

      case TimeSpecificationType.period:
        if (timePeriod == null) return null;
        return TimeSlotSettings.period(
          period: timePeriod!,
          position: periodPosition ?? PeriodPosition.start,
        );
    }
  }

  /// تطبيق إعدادات الوقت من TimeSlotPicker
  void applyTimeSettings(TimeSlotSettings settings) {
    timeType = settings.type;

    // مسح القيم القديمة
    fixedHour = null;
    fixedMinute = null;
    referencePrayerIndex = null;
    prayerRelationIndex = null;
    offsetMinutes = 0;
    timePeriodIndex = null;
    periodPositionIndex = null;

    // تطبيق القيم الجديدة
    switch (settings.type) {
      case TimeSpecificationType.fixed:
        fixedHour = settings.fixedTime?.hour;
        fixedMinute = settings.fixedTime?.minute;
        // تحديث time القديم للتوافق
        if (settings.fixedTime != null) {
          time = DateTime(
            date.year,
            date.month,
            date.day,
            settings.fixedTime!.hour,
            settings.fixedTime!.minute,
          );
        }
        break;

      case TimeSpecificationType.relativeToPrayer:
        referencePrayer = settings.referencePrayer;
        prayerRelation = settings.prayerRelation;
        offsetMinutes = settings.offsetMinutes;
        break;

      case TimeSpecificationType.period:
        timePeriod = settings.period;
        periodPosition = settings.periodPosition;
        break;
    }
  }

  /// تعيين وقت ثابت (Shortcut)
  void setFixedTime(TimeOfDay timeOfDay) {
    applyTimeSettings(TimeSlotSettings.fixed(timeOfDay));
  }

  /// تعيين وقت نسبي للصلاة (Shortcut)
  void setRelativeTime({
    required ReferencePrayer prayer,
    PrayerRelativeTime relation = PrayerRelativeTime.after,
    int offset = 0,
  }) {
    applyTimeSettings(
      TimeSlotSettings.relativeToPrayer(
        prayer: prayer,
        relation: relation,
        offsetMinutes: offset,
      ),
    );
  }

  /// تعيين فترة زمنية (Shortcut)
  void setPeriodTime({
    required AtharTimePeriod period,
    PeriodPosition position = PeriodPosition.start,
  }) {
    applyTimeSettings(
      TimeSlotSettings.period(period: period, position: position),
    );
  }

  /// ✅ الحصول على نص عرض الوقت
  @override
  String getTimeDisplayString() {
    final settings = timeSlotSettings;
    if (settings == null) return 'غير محدد';

    switch (settings.type) {
      case TimeSpecificationType.fixed:
        if (settings.fixedTime == null) return 'غير محدد';
        final h = settings.fixedTime!.hour.toString().padLeft(2, '0');
        final m = settings.fixedTime!.minute.toString().padLeft(2, '0');
        return '$h:$m';

      case TimeSpecificationType.relativeToPrayer:
        final prayerName = _getPrayerName(settings.referencePrayer);
        if (settings.offsetMinutes == 0) {
          return settings.prayerRelation == PrayerRelativeTime.iqama
              ? 'عند إقامة $prayerName'
              : (settings.prayerRelation == PrayerRelativeTime.before
                    ? 'قبل $prayerName'
                    : 'بعد $prayerName');
        }
        final relation = switch (settings.prayerRelation) {
          PrayerRelativeTime.before => 'قبل',
          PrayerRelativeTime.iqama => 'وقت إقامة',
          PrayerRelativeTime.after || null => 'بعد',
        };
        return '$relation $prayerName بـ ${settings.offsetMinutes} دقيقة';

      case TimeSpecificationType.period:
        return _getPeriodName(settings.period);
    }
  }

  String _getPrayerName(ReferencePrayer? prayer) {
    switch (prayer) {
      case ReferencePrayer.fajr:
        return 'الفجر';
      case ReferencePrayer.sunrise:
        return 'الشروق';
      case ReferencePrayer.dhuhr:
        return 'الظهر';
      case ReferencePrayer.asr:
        return 'العصر';
      case ReferencePrayer.maghrib:
        return 'المغرب';
      case ReferencePrayer.isha:
        return 'العشاء';
      case null:
        return '';
    }
  }

  String _getPeriodName(AtharTimePeriod? period) {
    switch (period) {
      case AtharTimePeriod.dawn:
        return 'الفجر';
      case AtharTimePeriod.bakur:
        return 'البكور';
      case AtharTimePeriod.duha:
        return 'الضحى';
      case AtharTimePeriod.morning:
        return 'الصباح';
      case AtharTimePeriod.noon:
        return 'الظهيرة';
      case AtharTimePeriod.afternoon:
        return 'العصر';
      case AtharTimePeriod.maghrib:
        return 'المغرب';
      case AtharTimePeriod.isha:
        return 'العشاء';
      case AtharTimePeriod.night:
        return 'الليل';
      case AtharTimePeriod.lastThird:
        return 'الثلث الأخير';
      case AtharTimePeriod.undefined:
      case null:
        return 'غير محدد';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════

  TaskModel({
    required this.title,
    required this.date,
    required this.uuid,
    required this.userId,
    this.description,
    this.time,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.isCompleted = false,
    this.isSynced = false,
    this.spaceId,
    this.moduleId,
    this.isHidden = false,
    this.assignedTo,
    this.categoryId,
    this.isUrgent = false,
    this.isImportant = false,
    this.durationMinutes = 30,
    this.completionNote,
    this.deletedAt,
    this.position = 0.0,
    DateTime? updatedAt,
    this.createdBy,
    this.visibility = 'public',
    this.assigneesIds,
    this.assigneeId,
    this.automationLinkId,
    this.isReassignable = true,
    this.reminderTime,
    this.isRecurring = false,
    this.recurrence,
    this.parentRecurrenceId,
    this.occurrenceDate,
    this.templateId,
    // ✅ الحقول الجديدة (كـ index)
    this.timeTypeIndex = 0,
    this.fixedHour,
    this.fixedMinute,
    this.referencePrayerIndex,
    this.prayerRelationIndex,
    this.offsetMinutes = 0,
    this.timePeriodIndex,
    this.periodPositionIndex,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    final task = TaskModel(
      uuid: json['uuid'],
      userId: json['created_by'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      date: DateTime.parse(json['date']),
      isCompleted: json['is_completed'] ?? false,
      isHidden: json['is_hidden'] ?? false,
      spaceId: json['space_id'],
      moduleId: json['module_id'],
      assignedTo: json['assigned_to'],
      categoryId: json['category_id'],
      priority: _priorityFromInt(json['priority']),
      isSynced: true,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      isUrgent: json['is_urgent'] ?? false,
      isImportant: json['is_important'] ?? false,
      durationMinutes: json['duration'] ?? 30,
      completionNote: json['completion_note'],
      position: (json['position'] ?? 0.0).toDouble(),
      assigneeId: json['assignee_id'],
      isReassignable: json['is_reassignable'] ?? true,
      visibility: json['visibility'] ?? 'public',
      reminderTime: json['reminder_time'] != null
          ? DateTime.parse(json['reminder_time'])
          : null,
      isRecurring: json['is_recurring'] ?? false,
      parentRecurrenceId: json['parent_recurrence_id'],
      occurrenceDate: json['occurrence_date'] != null
          ? DateTime.parse(json['occurrence_date'])
          : null,
      templateId: json['template_id'],
      // ✅ الحقول الجديدة (كـ int)
      timeTypeIndex: json['time_type'] ?? 0,
      fixedHour: json['fixed_hour'],
      fixedMinute: json['fixed_minute'],
      referencePrayerIndex: json['reference_prayer'],
      prayerRelationIndex: json['prayer_relation'],
      offsetMinutes: json['offset_minutes'] ?? 0,
      timePeriodIndex: json['time_period'],
      periodPositionIndex: json['period_position'],
    );

    // Fallback للوقت القديم
    if (json['time'] != null) {
      task.time = DateTime.parse(json['time']);
    }

    return task;
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time?.toIso8601String(),
      'is_completed': isCompleted,
      'is_hidden': isHidden,
      'space_id': spaceId,
      'module_id': moduleId,
      'assigned_to': assignedTo,
      'category_id': categoryId,
      'created_by': userId,
      'priority': priority.index,
      'updated_at':
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'is_urgent': isUrgent,
      'is_important': isImportant,
      'duration': durationMinutes,
      'completion_note': completionNote,
      'position': position,
      'assignee_id': assigneeId,
      'is_reassignable': isReassignable,
      'visibility': visibility,
      'reminder_time': reminderTime?.toIso8601String(),
      'is_recurring': isRecurring,
      'parent_recurrence_id': parentRecurrenceId,
      'occurrence_date': occurrenceDate?.toIso8601String(),
      'template_id': templateId,
      // ✅ الحقول الجديدة (كـ int)
      'time_type': timeTypeIndex,
      'fixed_hour': fixedHour,
      'fixed_minute': fixedMinute,
      'reference_prayer': referencePrayerIndex,
      'prayer_relation': prayerRelationIndex,
      'offset_minutes': offsetMinutes,
      'time_period': timePeriodIndex,
      'period_position': periodPositionIndex,
    };
  }

  TaskModel copyWith({
    String? title,
    DateTime? date,
    String? uuid,
    String? userId,
    String? description,
    DateTime? time,
    TaskPriority? priority,
    TaskStatus? status,
    bool? isCompleted,
    bool? isSynced,
    String? spaceId,
    String? moduleId,
    bool? isHidden,
    String? assignedTo,
    int? categoryId,
    bool? isUrgent,
    bool? isImportant,
    int? durationMinutes,
    String? completionNote,
    DateTime? deletedAt,
    double? position,
    DateTime? updatedAt,
    String? createdBy,
    String? visibility,
    List<String>? assigneesIds,
    String? assigneeId,
    String? automationLinkId,
    bool? isReassignable,
    DateTime? reminderTime,
    bool? isRecurring,
    RecurrencePattern? recurrence,
    String? parentRecurrenceId,
    DateTime? occurrenceDate,
    String? templateId,
    // ✅ الحقول الجديدة
    int? timeTypeIndex,
    int? fixedHour,
    int? fixedMinute,
    int? referencePrayerIndex,
    int? prayerRelationIndex,
    int? offsetMinutes,
    int? timePeriodIndex,
    int? periodPositionIndex,
  }) {
    return TaskModel(
      title: title ?? this.title,
      date: date ?? this.date,
      uuid: uuid ?? this.uuid,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      isCompleted: isCompleted ?? this.isCompleted,
      isSynced: isSynced ?? this.isSynced,
      spaceId: spaceId ?? this.spaceId,
      moduleId: moduleId ?? this.moduleId,
      isHidden: isHidden ?? this.isHidden,
      assignedTo: assignedTo ?? this.assignedTo,
      categoryId: categoryId ?? this.categoryId,
      isUrgent: isUrgent ?? this.isUrgent,
      isImportant: isImportant ?? this.isImportant,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completionNote: completionNote ?? this.completionNote,
      deletedAt: deletedAt ?? this.deletedAt,
      position: position ?? this.position,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      visibility: visibility ?? this.visibility,
      assigneesIds: assigneesIds ?? this.assigneesIds,
      assigneeId: assigneeId ?? this.assigneeId,
      automationLinkId: automationLinkId ?? this.automationLinkId,
      isReassignable: isReassignable ?? this.isReassignable,
      reminderTime: reminderTime ?? this.reminderTime,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrence: recurrence ?? this.recurrence,
      parentRecurrenceId: parentRecurrenceId ?? this.parentRecurrenceId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      templateId: templateId ?? this.templateId,
      // ✅ الحقول الجديدة
      timeTypeIndex: timeTypeIndex ?? this.timeTypeIndex,
      fixedHour: fixedHour ?? this.fixedHour,
      fixedMinute: fixedMinute ?? this.fixedMinute,
      referencePrayerIndex: referencePrayerIndex ?? this.referencePrayerIndex,
      prayerRelationIndex: prayerRelationIndex ?? this.prayerRelationIndex,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      timePeriodIndex: timePeriodIndex ?? this.timePeriodIndex,
      periodPositionIndex: periodPositionIndex ?? this.periodPositionIndex,
    )..id = id;
  }

  static TaskPriority _priorityFromInt(int? index) {
    if (index == null) return TaskPriority.medium;
    return TaskPriority.values[index];
  }
}

// import 'package:athar/features/settings/data/models/category_model.dart';
// import 'package:athar/features/task/data/models/attachment_model.dart';
// import 'package:athar/features/task/data/models/recurrence_pattern.dart';
// import 'package:isar/isar.dart';

// part 'task_model.g.dart';

// enum TaskPriority { high, medium, low }

// enum TaskStatus { todo, inProgress, done }

// @Collection()
// class TaskModel {
//   Id id = Isar.autoIncrement;

//   // --- 1. الهوية والمزامنة ---
//   @Index(unique: true, replace: true)
//   late String uuid;

//   @Index()
//   late String userId; // المنشئ (Creator)

//   bool isSynced = false;

//   DateTime? updatedAt;
//   DateTime? deletedAt;

//   DateTime createdAt = DateTime.now();

//   // ✅ حقول التكرار (جديدة)
//   bool isRecurring = false;
//   RecurrencePattern? recurrence;

//   // معرف المهمة الأصلية (إذا كانت هذه نسخة متكررة)
//   String? parentRecurrenceId;

//   // تاريخ التكرار (لهذه النسخة المحددة)
//   DateTime? occurrenceDate;

//   // ✅ معرف القالب (إذا أُنشئت من قالب)
//   String? templateId;

//   // ✅ للعمليات الجماعية
//   @ignore
//   bool isSelected = false; // لا يُحفظ في DB

//   @Index()
//   double position = 0.0;

//   final attachments = IsarLinks<AttachmentModel>();

//   // 🛡️ التحديثات الجديدة للصلاحيات
//   String? createdBy;

//   @Index()
//   String visibility = 'public'; // public, private, admins_only

//   // ✅ 1. الحقل الجديد: المسند إليه الحالي (Single Assignee for Pickup)
//   @Index()
//   String? assigneeId;

//   // ✅ 2. الحقل الجديد: هل يسمح بإعادة الإسناد؟
//   bool isReassignable = true;

//   // (سنبقي الحقول القديمة لعدم كسر الكود السابق، لكن سنعتمد assigneeId الجديد للمنطق)
//   List<String>? assigneesIds;

//   // --- 2. الهيكلية المكانية ---
//   @Index()
//   String? spaceId;

//   @Index()
//   String? automationLinkId; // 🔗 للربط مع القوائم

//   @Index()
//   String? moduleId;

//   bool isHidden = false;
//   String? assignedTo; // (قديم - يمكن تجاهله تدريجياً لصالح assigneeId)

//   // --- 3. التركيز والتصنيف ---
//   @Index()
//   int? categoryId;

//   final category = IsarLink<CategoryModel>();

//   // --- 4. البيانات الأساسية ---
//   @Index(type: IndexType.value)
//   late String title;

//   String? description;

//   @Index()
//   late DateTime date;

//   DateTime? time;

//   // --- 5. الحالة والأولوية ---
//   @Enumerated(EnumType.ordinal)
//   TaskPriority priority = TaskPriority.medium;

//   @Enumerated(EnumType.ordinal)
//   TaskStatus status = TaskStatus.todo;

//   bool isCompleted = false;
//   DateTime? completedAt;

//   // --- 6. مميزات إضافية ---
//   bool isUrgent = false;
//   bool isImportant = false;
//   int durationMinutes = 30;
//   String? completionNote;

//   // ✅ --- 7. نظام التذكيرات (جديد!) ---
//   /// وقت التذكير (يمكن أن يكون قبل المهمة أو في أي وقت)
//   DateTime? reminderTime;

//   TaskModel({
//     required this.title,
//     required this.date,
//     required this.uuid,
//     required this.userId,
//     this.description,
//     this.time,
//     this.priority = TaskPriority.medium,
//     this.status = TaskStatus.todo,
//     this.isCompleted = false,
//     this.isSynced = false,
//     this.spaceId,
//     this.moduleId,
//     this.isHidden = false,
//     this.assignedTo,
//     this.categoryId,
//     this.isUrgent = false,
//     this.isImportant = false,
//     this.durationMinutes = 30,
//     this.completionNote,
//     this.deletedAt,
//     this.position = 0.0,
//     DateTime? updatedAt,
//     this.createdBy,
//     this.visibility = 'public',
//     this.assigneesIds,
//     // ✅ إضافة الباراميترات الجديدة للكونستركتور
//     this.assigneeId,
//     this.automationLinkId, // ✅
//     this.isReassignable = true,
//     this.reminderTime, // ✅ إضافة هذا السطر
//     // ✅ المعاملات الناقصة التي تم إضافتها
//     this.isRecurring = false,
//     this.recurrence,
//     this.parentRecurrenceId,
//     this.occurrenceDate,
//     this.templateId,
//   }) : updatedAt = updatedAt ?? DateTime.now();

//   factory TaskModel.fromJson(Map<String, dynamic> json) {
//     return TaskModel(
//       uuid: json['uuid'],
//       userId: json['created_by'] ?? '',
//       title: json['title'] ?? '',
//       description: json['description'],
//       date: DateTime.parse(json['date']),
//       isCompleted: json['is_completed'] ?? false,
//       isHidden: json['is_hidden'] ?? false,
//       spaceId: json['space_id'],
//       moduleId: json['module_id'],
//       assignedTo: json['assigned_to'],
//       categoryId: json['category_id'],
//       priority: _priorityFromInt(json['priority']),
//       isSynced: true,
//       updatedAt: json['updated_at'] != null
//           ? DateTime.parse(json['updated_at'])
//           : null,
//       deletedAt: json['deleted_at'] != null
//           ? DateTime.parse(json['deleted_at'])
//           : null,
//       isUrgent: json['is_urgent'] ?? false,
//       isImportant: json['is_important'] ?? false,
//       durationMinutes: json['duration'] ?? 30,
//       completionNote: json['completion_note'],
//       position: (json['position'] ?? 0.0).toDouble(),
//       // ✅ قراءة الحقول الجديدة
//       assigneeId: json['assignee_id'],
//       isReassignable: json['is_reassignable'] ?? true,
//       visibility: json['visibility'] ?? 'public',
//       reminderTime:
//           json['reminder_time'] !=
//               null // ✅ إضافة هذه الأسطر
//           ? DateTime.parse(json['reminder_time'])
//           : null,
//       // ✅ حقول التكرار الجديدة
//       isRecurring: json['is_recurring'] ?? false,
//       parentRecurrenceId: json['parent_recurrence_id'],
//       occurrenceDate: json['occurrence_date'] != null
//           ? DateTime.parse(json['occurrence_date'])
//           : null,
//       templateId: json['template_id'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'uuid': uuid,
//       'title': title,
//       'description': description,
//       'date': date.toIso8601String(),
//       'is_completed': isCompleted,
//       'is_hidden': isHidden,
//       'space_id': spaceId,
//       'module_id': moduleId,
//       'assigned_to': assignedTo,
//       'category_id': categoryId,
//       'created_by': userId,
//       'priority': priority.index,
//       'updated_at':
//           updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
//       'deleted_at': deletedAt?.toIso8601String(),
//       'is_urgent': isUrgent,
//       'is_important': isImportant,
//       'duration': durationMinutes,
//       'completion_note': completionNote,
//       'position': position,
//       // ✅ إرسال الحقول الجديدة
//       'assignee_id': assigneeId,
//       'is_reassignable': isReassignable,
//       'visibility': visibility,
//       'reminder_time': reminderTime?.toIso8601String(), // ✅ إضافة هذا السطر
//       // ✅ حقول التكرار الجديدة
//       'is_recurring': isRecurring,
//       'parent_recurrence_id': parentRecurrenceId,
//       'occurrence_date': occurrenceDate?.toIso8601String(),
//       'template_id': templateId,
//     };
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅ copyWith للتسهيل
//   // ═══════════════════════════════════════════════════════════════════════════
//   TaskModel copyWith({
//     String? title,
//     DateTime? date,
//     String? uuid,
//     String? userId,
//     String? description,
//     DateTime? time,
//     TaskPriority? priority,
//     TaskStatus? status,
//     bool? isCompleted,
//     bool? isSynced,
//     String? spaceId,
//     String? moduleId,
//     bool? isHidden,
//     String? assignedTo,
//     int? categoryId,
//     bool? isUrgent,
//     bool? isImportant,
//     int? durationMinutes,
//     String? completionNote,
//     DateTime? deletedAt,
//     double? position,
//     DateTime? updatedAt,
//     String? createdBy,
//     String? visibility,
//     List<String>? assigneesIds,
//     String? assigneeId,
//     String? automationLinkId,
//     bool? isReassignable,
//     DateTime? reminderTime,
//     bool? isRecurring,
//     RecurrencePattern? recurrence,
//     String? parentRecurrenceId,
//     DateTime? occurrenceDate,
//     String? templateId,
//   }) {
//     return TaskModel(
//       title: title ?? this.title,
//       date: date ?? this.date,
//       uuid: uuid ?? this.uuid,
//       userId: userId ?? this.userId,
//       description: description ?? this.description,
//       time: time ?? this.time,
//       priority: priority ?? this.priority,
//       status: status ?? this.status,
//       isCompleted: isCompleted ?? this.isCompleted,
//       isSynced: isSynced ?? this.isSynced,
//       spaceId: spaceId ?? this.spaceId,
//       moduleId: moduleId ?? this.moduleId,
//       isHidden: isHidden ?? this.isHidden,
//       assignedTo: assignedTo ?? this.assignedTo,
//       categoryId: categoryId ?? this.categoryId,
//       isUrgent: isUrgent ?? this.isUrgent,
//       isImportant: isImportant ?? this.isImportant,
//       durationMinutes: durationMinutes ?? this.durationMinutes,
//       completionNote: completionNote ?? this.completionNote,
//       deletedAt: deletedAt ?? this.deletedAt,
//       position: position ?? this.position,
//       updatedAt: updatedAt ?? this.updatedAt,
//       createdBy: createdBy ?? this.createdBy,
//       visibility: visibility ?? this.visibility,
//       assigneesIds: assigneesIds ?? this.assigneesIds,
//       assigneeId: assigneeId ?? this.assigneeId,
//       automationLinkId: automationLinkId ?? this.automationLinkId,
//       isReassignable: isReassignable ?? this.isReassignable,
//       reminderTime: reminderTime ?? this.reminderTime,
//       isRecurring: isRecurring ?? this.isRecurring,
//       recurrence: recurrence ?? this.recurrence,
//       parentRecurrenceId: parentRecurrenceId ?? this.parentRecurrenceId,
//       occurrenceDate: occurrenceDate ?? this.occurrenceDate,
//       templateId: templateId ?? this.templateId,
//     )..id = id; // نسخ الـ id أيضاً
//   }

//   static TaskPriority _priorityFromInt(int? index) {
//     if (index == null) return TaskPriority.medium;
//     return TaskPriority.values[index];
//   }
// }

// import 'package:athar/features/project/data/models/project_model.dart';
// import 'package:athar/features/settings/data/models/category_model.dart';
// import 'package:isar/isar.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';

// part 'task_model.g.dart';

// enum TaskPriority { low, medium, high }

// enum TaskStatus { todo, inProgress, done }

// @Collection()
// class TaskModel {
//   Id id = Isar.autoIncrement;

//   // --- حقول المزامنة ---
//   // ✅ التعديل 1: جعل النوع String? ليتطابق مع الكونستركتور ويحل خطأ build_runner
//   @Index(unique: true, replace: true)
//   String? uuid;

//   @Index()
//   String? userId;

//   bool isSynced;

//   // ✅ التعديل 2: جعل النوع DateTime? لنفس السبب
//   DateTime? updatedAt;
//   DateTime? deletedAt;

//   int? categoryId;
//   int? projectId;
//   // --------------------

//   @Index(type: IndexType.value)
//   late String title;

//   String? description;
//   DateTime? time;
//   DateTime createdAt = DateTime.now();
//   DateTime date;

//   final category = IsarLink<CategoryModel>();

//   @Enumerated(EnumType.ordinal)
//   TaskPriority priority = TaskPriority.medium;

//   @Enumerated(EnumType.ordinal)
//   TaskStatus status = TaskStatus.todo;

//   bool isCompleted = false;
//   DateTime? completedAt;
//   bool isUrgent = false;
//   bool isImportant = false;
//   int durationMinutes = 30;
//   String? completionNote;

//   final project = IsarLink<ProjectModel>();

//   TaskModel({
//     required this.title,
//     required this.date,
//     this.description,
//     this.time,
//     this.priority = TaskPriority.medium,
//     this.status = TaskStatus.todo,
//     this.isCompleted = false,
//     this.isUrgent = false,
//     this.isImportant = false,
//     this.durationMinutes = 30,
//     this.categoryId,
//     this.projectId,
//     String? uuid, // النوع هنا String? والآن أصبح متطابقاً مع المتغير في الأعلى
//     this.userId,
//     this.isSynced = false,
//     DateTime? updatedAt,
//   }) : // نضمن هنا أن uuid لن يكون null أبداً عند الإنشاء
//        uuid = uuid ?? const Uuid().v4(),
//        updatedAt = updatedAt ?? DateTime.now();

//   static TaskModel create({
//     required String title,
//     required DateTime date,
//     String? description,
//     TaskPriority priority = TaskPriority.medium,
//     CategoryModel? category,
//     ProjectModel? project,
//     bool isUrgent = false,
//     bool isImportant = false,
//     int duration = 30,
//   }) {
//     final task = TaskModel(
//       title: title,
//       date: date,
//       description: description,
//       priority: priority,
//       isUrgent: isUrgent,
//       isImportant: isImportant,
//       durationMinutes: duration,
//     );

//     if (category != null) {
//       task.category.value = category;
//       task.categoryId = category.id;
//     }

//     if (project != null) {
//       task.project.value = project;
//       task.projectId = project.id;
//     }

//     return task;
//   }

//   // 1. دالة التحويل من Supabase (JSON) إلى التطبيق (Dart)
//   factory TaskModel.fromJson(Map<String, dynamic> json) {
//     return TaskModel(
//         title: json['title'] ?? '',
//         date: DateTime.parse(json['start_time']), // Supabase uses ISO string
//         // لاحظ: Isar ID لا يأتي من السيرفر، بل يتم توليده محلياً أو البحث عنه
//         isUrgent: json['is_urgent'] ?? false,
//         isImportant: json['is_important'] ?? false,
//         durationMinutes: json['duration'] ?? 30,
//         status: _statusFromString(json['status']),
//         isCompleted: json['is_completed'] ?? false,
//         uuid: json['uuid'], // ✅ المفتاح الأساسي للمزامنة
//         isSynced: true, // بما أنها جاءت من السيرفر فهي متزامنة
//       )
//       ..updatedAt = json['updated_at'] != null
//           ? DateTime.tryParse(json['updated_at'])
//           : null
//       ..deletedAt = json['deleted_at'] != null
//           ? DateTime.tryParse(json['deleted_at'])
//           : null
//       ..completionNote = json['completion_note'];
//   }

//   // 2. دالة التحويل من التطبيق (Dart) إلى Supabase (JSON)
//   Map<String, dynamic> toJson() {
//     return {
//       'uuid': uuid, // ✅ نستخدم الـ UUID كمعرف رئيسي في السيرفر
//       'user_id': Supabase.instance.client.auth.currentUser?.id,
//       'title': title,
//       'start_time': date.toIso8601String(),
//       'duration': durationMinutes,
//       'is_urgent': isUrgent,
//       'is_important': isImportant,
//       'status': status.name, // "todo", "done"...
//       'is_completed': isCompleted,
//       'completion_note': completionNote,
//       // نرسل التواريخ بصيغة نصية
//       'updated_at':
//           updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
//       'deleted_at': deletedAt?.toIso8601String(),
//     };
//   }

//   // دالة مساعدة لتحويل النص إلى Enum
//   static TaskStatus _statusFromString(String? status) {
//     switch (status) {
//       case 'done':
//         return TaskStatus.done;
//       case 'inProgress':
//         return TaskStatus.inProgress;
//       default:
//         return TaskStatus.todo;
//     }
//   }
// }
