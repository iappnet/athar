import 'package:isar/isar.dart';
import 'time_range.dart';

part 'user_settings.g.dart';

// أضف هذا الـ Enum خارج الكلاس أو في ملف منفصل
enum AthkarDisplayMode {
  independent, // منفصلة (بطاقة خاصة)
  embedded, // مدمجة مع القائمة
}

// ✅ تأكد أن هذا موجود
enum AthkarSessionViewMode { list, focus }

// ✅ 1. تعريف Enum لأماكن العرض
enum PrayerCardDisplayMode { dashboardOnly, dashboardAndTasks, allPages }

@collection
class UserSettings {
  Id id = Isar.autoIncrement;
  bool isDarkMode;
  bool isAutoModeEnabled;

  // ✅ 2. إضافة إعدادات الصلاة الجديدة
  bool isPrayerEnabled = true; // السويتش الرئيسي
  bool enablePrayerReminders = true; // ✅ تفعيل التذكير قبل 15 دقيقة (جديد)

  // ✅✅ الإضافة الجديدة المطلوبة (المزامنة التلقائية)
  // القيمة الافتراضية true
  bool isAutoSyncEnabled = false;

  // ✅✅ إضافة حقل البصمة (الجديد)
  // القيمة الافتراضية false للأمان
  bool isBiometricEnabled = false;

  // تفضيل التقويم (true = هجري، false = ميلادي)
  bool isHijriMode;
  // تفضيل عرض المهام (true = كانبان، false = قائمة) - الافتراضي false
  bool isTasksKanbanView;
  // ✅ التعديل 1: جعلنا القوائم قابلة للقيم الفارغة (?) لإرضاء Isar Generator
  List<TimeRange>? workPeriods;
  List<TimeRange>? sleepPeriods;
  List<TimeRange>? quietPeriods;
  // ✅ 1. استعادة وقت الأهل وإضافة الوقت الحر
  List<TimeRange>? familyPeriods;
  List<TimeRange>? freePeriods;

  // --- ربط المناطق بالتصنيفات (IDs) ---
  int? workCategoryId;
  int? familyCategoryId; // لوقت الأهل (عادة يربط بالمنزل)
  int? freeCategoryId;
  int? quietCategoryId; // لوقت الهدوء (عادة يربط بالشخصي)
  int? sleepCategoryId;

  // ✅ الإضافة الجديدة: قائمة أيام العمل (أرقام من 1 إلى 7)
  List<int>? workDays;
  // --- إعدادات الموقع والصلاة ---
  double? latitude;
  double? longitude;
  String? cityName;

  // تعديل يدوي للوقت (بالدقائق) +/-
  int prayerTimeAdjustmentMinutes;

  // --- إعدادات الأذكار الجديدة ---
  bool isAthkarEnabled = true; // تفعيل/تعطيل الميزة
  bool isMedicationNotificationsEnabled = true; // ✅ الإضافة الجديدة

  /// تفعيل/تعطيل تذكيرات المهام بشكل عام
  bool isTaskRemindersEnabled = true;

  /// الوقت الافتراضي للتذكير قبل المهمة (بالدقائق)
  /// القيمة الافتراضية: 30 دقيقة قبل موعد المهمة
  int taskReminderMinutesBefore = 30;

  /// احترام الفترات الهادئة (عدم إرسال تذكيرات في أوقات الهدوء)
  /// إذا كان true، سيتم تأجيل التذكيرات إلى ما بعد الفترة الهادئة
  bool respectQuietPeriodsForTasks = true;

  // ✅ إعدادات تذكيرات المواعيد
  bool isAppointmentRemindersEnabled = true;
  int defaultAppointmentReminderMinutes = 60;
  bool appointmentMultipleReminders = true; // تذكيرات متعددة

  @Enumerated(EnumType.name)
  PrayerCardDisplayMode prayerCardDisplayMode =
      PrayerCardDisplayMode.dashboardOnly; // القيمة الافتراضية

  @Enumerated(EnumType.name)
  AthkarDisplayMode athkarDisplayMode = AthkarDisplayMode.independent;

  @Enumerated(EnumType.name)
  AthkarSessionViewMode athkarSessionViewMode = AthkarSessionViewMode.list;

  // ═══════════════════════════════════════════════════════════
  // 🎯 HABIT & ATHKAR REMINDERS
  // ═══════════════════════════════════════════════════════════

  /// تفعيل/تعطيل تذكيرات العادات
  bool isHabitRemindersEnabled = true;

  /// الوقت الافتراضي للعادات اليومية (إذا لم يحدد المستخدم)
  DateTime? defaultHabitReminderTime;

  /// تفعيل/تعطيل تذكيرات الأذكار
  bool isAthkarRemindersEnabled = true;

  /// وقت أذكار الصباح (الافتراضي: 06:00)
  String morningAthkarTime = '06:00';

  /// وقت أذكار المساء (الافتراضي: 17:00)
  String eveningAthkarTime = '17:00';

  /// وقت أذكار النوم (الافتراضي: 22:00)
  String sleepAthkarTime = '22:00';

  // ═══════════════════════════════════════════════════════════
  // 📦 ASSET REMINDERS
  // ═══════════════════════════════════════════════════════════

  /// تفعيل/تعطيل تذكيرات الأصول
  bool isAssetRemindersEnabled = true;

  /// عدد الأيام قبل التذكير بالصيانة/التأمين/الرخصة
  int assetReminderDaysBefore = 7;

  /// إرسال تذكير للضمان عند اقتراب الانتهاء
  bool assetWarrantyReminders = true;

  /// إرسال تذكير للصيانة الدورية
  bool assetMaintenanceReminders = true;

  /// إرسال تذكير لانتهاء التأمين
  bool assetInsuranceReminders = true;

  /// إرسال تذكير لانتهاء الرخصة
  bool assetLicenseReminders = true;

  // ═══════════════════════════════════════════════════════════
  // 📊 PROJECT REMINDERS
  // ═══════════════════════════════════════════════════════════

  /// تفعيل/تعطيل تذكيرات المشاريع
  bool isProjectRemindersEnabled = true;

  /// عدد الأيام قبل التذكير بموعد التسليم
  int projectReminderDaysBefore = 7;

  /// عدد الساعات قبل التذكير بموعد التسليم
  int projectReminderHoursBefore = 24;

  /// إرسال تذكير يومي للمشاريع النشطة
  bool projectDailyReminders = false;

  /// إرسال تذكير أسبوعي بملخص المشاريع
  bool projectWeeklySummary = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // 📦 SAMPLE DATA CONTROL
  // ═══════════════════════════════════════════════════════════════════════════

  /// هل تم عرض البيانات التجريبية من قبل؟
  bool sampleDataShown = false;

  /// هل رفض المستخدم البيانات التجريبية؟
  bool sampleDataDismissed = false;

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 NAVIGATION BAR
  // ═══════════════════════════════════════════════════════════════════════════

  /// إخفاء شريط التنقل عند التمرير
  bool hideNavOnScroll = false;

  UserSettings({
    this.isDarkMode = false,
    this.isAutoModeEnabled = false,
    this.isPrayerEnabled = true, // تأكد من إضافته للبناء
    this.enablePrayerReminders = true, // ✅ الإضافة الجديدة
    this.isAutoSyncEnabled = false, // ✅ تهيئة المزامنة التلقائية
    this.isBiometricEnabled = false, // ✅ تهيئة البصمة
    this.workPeriods,
    this.sleepPeriods,
    this.quietPeriods,
    this.familyPeriods, // ✅
    this.freePeriods, // ✅
    this.isHijriMode = false, // الافتراضي ميلادي
    this.isTasksKanbanView = false, // الافتراضي قائمة
    this.latitude,
    // ✅ Sample Data
    this.sampleDataShown = false,
    this.sampleDataDismissed = false,

    // ✅ Navigation Bar
    this.hideNavOnScroll = false,
    this.workDays, // ✅ إضافتها للبناء
    this.longitude,
    this.cityName,
    this.prayerTimeAdjustmentMinutes = 0,
    this.isAthkarEnabled = true,
    this.isMedicationNotificationsEnabled = true, // ✅ الإضافة الجديدة
    this.isTaskRemindersEnabled = true, // ✅ جديد
    this.taskReminderMinutesBefore = 30, // ✅ جديد
    this.respectQuietPeriodsForTasks = true, // ✅ جديد
    this.athkarDisplayMode = AthkarDisplayMode.independent, // الافتراضي: بطاقات
    this.prayerCardDisplayMode =
        PrayerCardDisplayMode.dashboardOnly, // إضافة القيمة الافتراضية للبناء
    this.athkarSessionViewMode = AthkarSessionViewMode.list,
    this.isAppointmentRemindersEnabled = true,
    this.defaultAppointmentReminderMinutes = 60,
    this.appointmentMultipleReminders = true,
    // ✅ Habit & Athkar
    this.isHabitRemindersEnabled = true,
    this.defaultHabitReminderTime,
    this.isAthkarRemindersEnabled = true,
    this.morningAthkarTime = '06:00',
    this.eveningAthkarTime = '17:00',
    this.sleepAthkarTime = '22:00',

    // ✅ Asset
    this.isAssetRemindersEnabled = true,
    this.assetReminderDaysBefore = 7,
    this.assetWarrantyReminders = true,
    this.assetMaintenanceReminders = true,
    this.assetInsuranceReminders = true,
    this.assetLicenseReminders = true,

    // ✅ Project
    this.isProjectRemindersEnabled = true,
    this.projectReminderDaysBefore = 7,
    this.projectReminderHoursBefore = 24,
    this.projectDailyReminders = false,
    this.projectWeeklySummary = false,
  });

  // ═══════════════════════════════════════════════════════════
  // ✅ Helper Methods
  // ═══════════════════════════════════════════════════════════

  /// تحويل وقت الأذكار (String) إلى DateTime
  DateTime getMorningAthkarDateTime() {
    return _parseTimeString(morningAthkarTime);
  }

  DateTime getEveningAthkarDateTime() {
    return _parseTimeString(eveningAthkarTime);
  }

  DateTime getSleepAthkarDateTime() {
    return _parseTimeString(sleepAthkarTime);
  }

  /// دالة مساعدة لتحويل "HH:mm" إلى DateTime
  DateTime _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    final hour = int.tryParse(parts[0]) ?? 6;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  // ✅ التعديل 3: إضافة Getters ذكية للتعامل مع القيم الافتراضية
  @ignore
  List<TimeRange> get familyPeriodsSafe => familyPeriods ?? [];

  @ignore
  List<TimeRange> get freePeriodsSafe => freePeriods ?? [];

  @ignore
  List<TimeRange> get workPeriodsSafe =>
      workPeriods ??
      [TimeRange(startHour: 7, startMinute: 0, endHour: 15, endMinute: 0)];

  @ignore
  List<TimeRange> get sleepPeriodsSafe =>
      sleepPeriods ??
      [TimeRange(startHour: 22, startMinute: 0, endHour: 5, endMinute: 0)];

  @ignore
  List<TimeRange> get quietPeriodsSafe => quietPeriods ?? [];

  // ✅ Getter ذكي لأيام العمل
  @ignore
  List<int> get workDaysSafe => workDays ?? [7, 1, 2, 3, 4];
}
