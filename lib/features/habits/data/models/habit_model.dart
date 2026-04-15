import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../features/settings/data/models/category_model.dart';
import '../../../../core/constants/athkar_data.dart'; // ✅ ضروري جداً لربط النصوص
import '../../../../core/time_engine/athar_time_periods.dart';
import 'habit_period_extension.dart';

part 'habit_model.g.dart';

// --- Enums ---
enum HabitType { regular, athkar }

enum HabitFrequency { daily, weekly, monthly }

enum HabitPeriod {
  dawn,
  bakur,
  morning,
  noon,
  afternoon,
  maghrib,
  isha,
  night,
  lastThird,
  anyTime,
  postPrayer,
}

@Collection()
class HabitModel {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String title;

  @Index(unique: true, replace: true)
  String? uuid;

  @Index()
  String? userId;

  bool isSynced;
  DateTime? updatedAt;
  DateTime? deletedAt;

  int streak;
  String? targetDays;

  DateTime createdAt = DateTime.now();

  final category = IsarLink<CategoryModel>();
  String? icon;

  int currentStreak = 0;
  int longestStreak = 0;

  List<DateTime> completedDays = [];

  @Enumerated(EnumType.name)
  HabitType type = HabitType.regular;

  @Enumerated(EnumType.name)
  HabitFrequency frequency = HabitFrequency.daily;

  @Enumerated(EnumType.name)
  HabitPeriod period = HabitPeriod.anyTime;

  DateTime? startDate;
  DateTime? endDate;
  DateTime? nextResetDate;

  int target = 1;
  int currentProgress = 0;

  bool isCompleted = false;
  DateTime? lastCompletionDate;
  DateTime? lastUpdated;

  List<AthkarItem> athkarItems = [];

  // ═══════════════════════════════════════════════════════════
  // ✅ حقول الإشعارات الجديدة
  // ═══════════════════════════════════════════════════════════

  /// وقت التذكير (للعادات اليومية)
  DateTime? reminderTime;

  /// تفعيل/تعطيل التذكير
  bool reminderEnabled = true;

  /// أيام التذكير (للعادات الأسبوعية)
  // ignore: unintended_html_in_doc_comment
  /// List<int> حيث 1=الأحد, 7=السبت
  /// مثال: [1, 3, 5] = الأحد، الثلاثاء، الخميس
  List<int>? reminderDays;

  HabitModel({
    required this.title,
    this.type = HabitType.regular,
    this.frequency = HabitFrequency.daily,
    this.period = HabitPeriod.anyTime,
    this.target = 1,
    this.streak = 0,
    this.targetDays,
    String? uuid,
    this.userId,
    this.isSynced = false,
    DateTime? updatedAt,
    this.reminderTime,
    this.reminderEnabled = true,
    this.reminderDays,
  }) : uuid = uuid ?? const Uuid().v4(),
       updatedAt = updatedAt ?? DateTime.now();

  bool get isAthkar => type == HabitType.athkar;

  // ✅ التحقق: هل العادة لها تذكير؟
  bool get hasReminder => reminderEnabled && reminderTime != null;

  // ✅ التحقق: هل العادة يومية؟
  bool get isDaily => frequency == HabitFrequency.daily;

  // ✅ التحقق: هل العادة أسبوعية؟
  bool get isWeekly => frequency == HabitFrequency.weekly;

  // ✅ التحقق: هل العادة شهرية؟
  bool get isMonthly => frequency == HabitFrequency.monthly;

  // ---------------------------------------------------------
  // ✅ دالة إعادة حساب التقدم
  // ---------------------------------------------------------
  void recalculateProgress() {
    if (type == HabitType.athkar && athkarItems.isNotEmpty) {
      target = athkarItems.length;
      currentProgress = athkarItems.where((item) => item.isDone).length;
      isCompleted = currentProgress >= target;
    }
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) =>
      HabitModel.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  // ---------------------------------------------------------
  // ✅ دالة التحويل من السحاب (المصنع الذكي)
  // ---------------------------------------------------------
  factory HabitModel.fromMap(Map<String, dynamic> map) {
    String title = map['title'] ?? '';
    String? incomingUuid = map['uuid'];

    // ✅ 1. توحيد الهوية لجميع أنواع الأذكار (بما في ذلك الصلاة والنوم)
    if (title.contains('الصباح')) {
      incomingUuid = AthkarData.morningAthkarId;
    } else if (title.contains('المساء')) {
      incomingUuid = AthkarData.eveningAthkarId;
    } else if (title.contains('الصلاة')) {
      incomingUuid = AthkarData.prayerAthkarId; // ✅ دعم الصلاة
    } else if (title.contains('النوم')) {
      incomingUuid = AthkarData.sleepAthkarId; // ✅ دعم النوم
    }

    var habit = HabitModel(
      title: title,
      uuid: incomingUuid,
      userId: map['user_id'],
      target: map['target'] ?? 1,
      streak: map['streak'] ?? 0,
      targetDays: map['target_days'],
      type: HabitType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => HabitType.regular,
      ),
      period: HabitPeriod.values.firstWhere(
        (e) => e.name == map['period'],
        orElse: () => HabitPeriod.anyTime,
      ),
      frequency: HabitFrequency.values.firstWhere(
        (e) => e.name == map['frequency'],
        orElse: () => HabitFrequency.daily,
      ),
      isSynced: true,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'])
          : null,
      // ✅ الحقول الجديدة
      reminderTime: map['reminder_time'] != null
          ? DateTime.tryParse(map['reminder_time'])
          : null,
      reminderEnabled: map['reminder_enabled'] ?? true,
      reminderDays: map['reminder_days'] != null
          ? List<int>.from(map['reminder_days'])
          : null,
    );

    // تعبئة الحقول الإضافية
    habit.currentStreak = map['current_streak'] ?? 0;
    habit.longestStreak = map['longest_streak'] ?? 0;
    habit.currentProgress = map['current_progress'] ?? 0;
    habit.isCompleted = map['is_completed'] ?? false;
    habit.icon = map['icon'];

    if (map['created_at'] != null) {
      habit.createdAt = DateTime.tryParse(map['created_at']) ?? DateTime.now();
    }

    if (map['completed_days'] != null) {
      habit.completedDays = (map['completed_days'] as List)
          .map((e) => DateTime.parse(e.toString()))
          .toList();
    }

    // ✅✅✅ 2. الإنعاش الذاتي (فك شفرة الأرقام) ✅✅✅
    if (map['athkar_items'] != null) {
      int offset = 0;

      // تحديد الإزاحة بناءً على نوع الذكر
      if (habit.uuid == AthkarData.morningAthkarId) {
        offset = 1000;
      } else if (habit.uuid == AthkarData.eveningAthkarId) {
        offset = 2000;
      } else if (habit.uuid == AthkarData.prayerAthkarId) {
        offset = 3000; // ✅ الصلاة
      } else if (habit.uuid == AthkarData.sleepAthkarId) {
        offset = 4000; // ✅ النوم
      }

      habit.athkarItems = (map['athkar_items'] as List).map((e) {
        var item = AthkarItem.fromMap(e);

        // إذا جاء من السحابة برقم فقط (بدون نص)، نستخدم الـ offset لاسترجاع النص
        if (item.itemId != null && offset > 0) {
          int index = item.itemId! - offset;
          // التأكد من أن الفهرس ضمن حدود قائمة البيانات الأصلية
          if (index >= 0 && index < AthkarData.allAthkar.length) {
            final source = AthkarData.allAthkar[index];
            item.text = source.text;
            item.targetCount = source.count;

            // تصحيح حالة الإنجاز بناءً على العداد المسترجع
            if (item.currentCount < item.targetCount) {
              item.isDone = false;
            } else {
              item.isDone = true;
            }
          }
        }
        return item;
      }).toList();

      habit.recalculateProgress();
    }

    return habit;
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'user_id': userId,
      'title': title,
      'type': type.name,
      'frequency': frequency.name,
      'period': period.name,
      'target': target,
      'streak': streak,
      'target_days': targetDays,
      'icon': icon,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'current_progress': currentProgress,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at':
          updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'athkar_items': athkarItems.map((e) => e.toMap()).toList(),
      'completed_days': completedDays.map((e) => e.toIso8601String()).toList(),
      // ✅ الحقول الجديدة
      'reminder_time': reminderTime?.toIso8601String(),
      'reminder_enabled': reminderEnabled,
      'reminder_days': reminderDays,
    };
  }

  HabitModel copyWith({
    String? title,
    HabitType? type,
    HabitFrequency? frequency,
    HabitPeriod? period,
    int? target,
    int? streak,
    String? targetDays,
    String? userId,
    bool? isSynced,
    DateTime? reminderTime,
    bool? reminderEnabled,
    List<int>? reminderDays,
  }) {
    return HabitModel(
      title: title ?? this.title,
      uuid: uuid,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      period: period ?? this.period,
      target: target ?? this.target,
      streak: streak ?? this.streak,
      targetDays: targetDays ?? this.targetDays,
      userId: userId ?? this.userId,
      isSynced: isSynced ?? this.isSynced,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDays: reminderDays ?? this.reminderDays,
    );
  }

  /// الفترة المرتبطة بنظام أثر الموحّد (للاستخدام مع TimeSlotMixin وحسابات المواقيت).
  AtharTimePeriod get atharPeriod => period.toAtharPeriod();

  /// هل الفترة مرتبطة بصلاة/وقت شرعي محدد؟
  bool get hasPrayerAnchorPeriod => period.hasPrayerAnchor;
}

// ---------------------------------------------------------
// ✅ كائن عناصر الأذكار (Embedded)
// ---------------------------------------------------------
@embedded
class AthkarItem {
  AthkarItem();

  int? itemId;
  String? text;
  int targetCount = 1;
  int currentCount = 0;
  bool isDone = false;

  Map<String, dynamic> toMap() => {
    'item_id': itemId,
    'text': text,
    'target_count': targetCount,
    'current_count': currentCount,
    'is_done': isDone,
  };

  // دالة المزامنة الخفيفة (للسحابة)
  Map<String, dynamic> toCloudMap() {
    return {
      'item_id': itemId,
      'current_count': currentCount,
      'is_done': isDone,
      // لا نرسل النص للسحابة توفيراً للمساحة
    };
  }

  factory AthkarItem.fromJson(Map<String, dynamic> json) =>
      AthkarItem.fromMap(json);

  static AthkarItem fromMap(Map<String, dynamic> map) {
    return AthkarItem()
      ..itemId = map['item_id']
      ..text = map['text']
      ..targetCount = map['target_count'] ?? 1
      ..currentCount = map['current_count'] ?? 0
      ..isDone = map['is_done'] ?? false;
  }
}
