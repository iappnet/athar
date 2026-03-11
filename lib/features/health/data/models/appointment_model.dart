import 'package:isar/isar.dart';

part 'appointment_model.g.dart';

@Collection()
class AppointmentModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String moduleId;

  late String title;
  String? doctorName;
  String? locationName;

  late DateTime appointmentDate;
  String? type; // checkup, lab, vaccine
  String status = 'upcoming'; // upcoming, completed, cancelled

  String? notes;
  String? attachmentUrl;

  // ✅ إضافة حقول التذكير
  DateTime? reminderTime;
  bool reminderEnabled = true;
  // ✅ إضافة الحقول المفقودة للتذكيرات المتعددة
  int reminderDaysBefore = 1; // افتراضي: قبل يوم واحد
  int reminderHoursBefore = 1; // افتراضي: قبل ساعة واحدة
  int reminderMinutesBefore = 15; // افتراضي: قبل 15 دقيقة
  // ✅ الإضافة الجديدة: الملكية
  @Index()
  String? createdBy;

  bool isSynced = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  AppointmentModel({
    required this.uuid,
    required this.moduleId,
    required this.title,
    this.doctorName,
    this.locationName,
    required this.appointmentDate,
    this.type,
    this.status = 'upcoming',
    this.notes,
    this.attachmentUrl,
    this.createdBy,
    this.isSynced = false,
    this.reminderTime,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 1,
    this.reminderHoursBefore = 1,
    this.reminderMinutesBefore = 15,
  });

  // ═══════════════════════════════════════════════════════════
  // ✅ Helper Methods
  // ═══════════════════════════════════════════════════════════

  /// التحقق: هل الموعد قادم؟
  bool get isUpcoming =>
      status == 'upcoming' && appointmentDate.isAfter(DateTime.now());

  /// التحقق: هل الموعد اكتمل؟
  bool get isCompleted => status == 'completed';

  /// التحقق: هل الموعد ملغي؟
  bool get isCancelled => status == 'cancelled';

  /// حساب وقت التذكير الافتراضي (قبل ساعة من الموعد)
  DateTime get defaultReminderTime {
    return appointmentDate.subtract(Duration(minutes: reminderMinutesBefore));
  }

  /// نسخة من الموعد
  AppointmentModel copyWith({
    String? uuid,
    String? moduleId,
    String? title,
    String? doctorName,
    String? locationName,
    DateTime? appointmentDate,
    String? type,
    String? status,
    String? notes,
    String? attachmentUrl,
    DateTime? reminderTime,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    int? reminderHoursBefore,
    int? reminderMinutesBefore,
    String? createdBy,
    bool? isSynced,
  }) {
    return AppointmentModel(
      uuid: uuid ?? this.uuid,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      doctorName: doctorName ?? this.doctorName,
      locationName: locationName ?? this.locationName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      reminderHoursBefore: reminderHoursBefore ?? this.reminderHoursBefore,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdBy: createdBy ?? this.createdBy,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  // أضف هذه السطور داخل دالة toJson في AppointmentModel لضمان الرفع للسحابة
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'module_id': moduleId,
      'title': title,
      'doctor_name': doctorName,
      'location_name': locationName,
      'appointment_date': appointmentDate.toIso8601String(),
      'type': type,
      'status': status,
      'notes': notes,
      'reminder_time': reminderTime?.toIso8601String(), // ✅ إضافة
      'reminder_enabled': reminderEnabled, // ✅ إضافة
      'created_by': createdBy,
      'is_synced': isSynced,
    };
  }
}
