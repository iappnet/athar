import 'package:isar/isar.dart';

part 'service_model.g.dart';

@Collection()
class ServiceModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String assetId; // الأصل (السيارة)

  late String name; // "غيار زيت"، "فحص دوري"

  // --- قواعد التكرار ---
  int? repeatEveryDays; // كل كم يوم؟ (مثلاً 180)
  int? repeatEveryKm; // كل كم كيلو؟ (مثلاً 5000)
  int notifyBeforeDays = 7; // التنبيه قبل الموعد

  // ✅ حقول التذكير الموحدة الجديدة
  bool reminderEnabled = true;
  DateTime? reminderTime;

  // --- البيانات التشغيلية (يتم تحديثها عند إضافة سجل Log) ---
  DateTime? lastServiceDate; // تاريخ آخر صيانة
  int? lastOdometerReading; // قراءة العداد عند آخر صيانة

  // ✅ الذكاء الاصطناعي (معدل الاستهلاك اليومي)
  // يتم حسابه في Repository بناءً على الفرق بين السجلات
  double? averageKmPerDay;

  // --- التوقعات المحسوبة (Next Due) ---
  DateTime? nextDueDate; // التاريخ المتوقع القادم
  int? nextDueOdometer; // قراءة العداد المتوقعة القادمة

  // --- الميتا داتا ---
  bool isSynced = false;
  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;
  DateTime? deletedAt;

  // --- المنطق: حساب الموعد القادم ---
  void calculateNextDue() {
    // إذا لم تتم الصيانة من قبل، لا يمكننا التوقع
    if (lastServiceDate == null) return;

    // 1. حساب العداد القادم (بسيط: العداد السابق + مسافة التكرار)
    if (lastOdometerReading != null && repeatEveryKm != null) {
      nextDueOdometer = lastOdometerReading! + repeatEveryKm!;
    }

    // 2. حساب التاريخ القادم (المعقد: يعتمد على الوقت أو الاستهلاك)
    DateTime? dateBasedDue;
    DateTime? kmBasedDue;

    // أ. التوقع بناءً على الوقت (مثلاً: بعد 6 شهور)
    if (repeatEveryDays != null) {
      dateBasedDue = lastServiceDate!.add(Duration(days: repeatEveryDays!));
    }

    // ب. التوقع بناءً على الكيلومترات (باستخدام الذكاء الاصطناعي/معدل الاستهلاك)
    // المعادلة: المسافة المتبقية ÷ الاستهلاك اليومي = عدد الأيام المتبقية
    if (repeatEveryKm != null &&
        averageKmPerDay != null &&
        averageKmPerDay! > 0) {
      final daysToCoverDistance = repeatEveryKm! / averageKmPerDay!;
      kmBasedDue = lastServiceDate!.add(
        Duration(days: daysToCoverDistance.round()),
      );
    }

    // ج. القرار النهائي: نأخذ التاريخ الأقرب (الأسبق)
    // مثال: موعد الزيت بعد 6 شهور، لكن حسب مشيك ستصل للمسافة بعد شهرين -> نختار شهرين
    if (dateBasedDue != null && kmBasedDue != null) {
      nextDueDate = dateBasedDue.isBefore(kmBasedDue)
          ? dateBasedDue
          : kmBasedDue;
    } else {
      // نأخذ المتوفر منهما
      nextDueDate = dateBasedDue ?? kmBasedDue;
    }
  }

  ServiceModel({
    required this.uuid,
    required this.assetId,
    required this.name,
    this.repeatEveryDays,
    this.repeatEveryKm,
    this.notifyBeforeDays = 7,
    this.reminderEnabled = true, // ✅ إضافة
    this.reminderTime, // ✅ إضافة
    this.lastServiceDate,
    this.lastOdometerReading,
    this.averageKmPerDay,
    this.nextDueDate,
    this.nextDueOdometer,
    this.isSynced = false,
    this.deletedAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
}
