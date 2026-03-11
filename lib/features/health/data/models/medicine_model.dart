import 'package:isar/isar.dart';

part 'medicine_model.g.dart';

@Collection()
class MedicineModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String moduleId;

  late String name;
  String? type; // Pill, Syrup, Injection

  // --- منطق الجدولة ---
  late String schedulingType; // 'fixed' or 'interval'

  List<String>? fixedTimeSlots; // ["08:00", "20:00"]
  int? intervalHours; // 8, 6, 12...

  // --- ✅ الإضافات الجديدة ---
  double? doseAmount; // الكمية (مثلاً 5)
  String? doseUnit; // الوحدة (ml, mg, حبة)

  String? instructions; // before_meal, after_meal, with_meal, anytime

  // --- المخزون ---
  int? courseDurationDays; // مدة الكورس بالأيام (لحساب تاريخ الانتهاء)
  DateTime? startDate; // تاريخ البداية
  double? stockQuantity;
  DateTime? treatmentEndDate;

  bool isActive = true; // True = Current, False = Archived

  // ✅ الإضافة الجديدة: لمعرفة من أضاف الدواء (لتطبيق قاعدة الملكية)
  @Index()
  String? createdBy;

  // ✅✅ الإضافات الجديدة للأتمتة الديناميكية ✅✅

  // متى يتم التفعيل؟ ('off', 'quantity', 'date')
  String autoRefillMode = 'off';

  // الحد الفاصل (مثلاً 5.0 للكمية، أو 3.0 للأيام)
  double refillThreshold = 0.0;

  // ماذا نفعل؟ ('list', 'task', 'both')
  String refillAction = 'list';

  // لمنع التكرار: هل تم طلب التعبئة مسبقاً؟
  bool isRefillRequested = false;

  bool isSynced = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now(); // ✅ أضفنا تاريخ التحديث

  MedicineModel({
    required this.uuid,
    required this.moduleId,
    required this.name,
    this.type,
    required this.schedulingType,
    this.fixedTimeSlots,
    this.intervalHours,
    this.stockQuantity,
    this.treatmentEndDate,
    // القيم الجديدة
    this.doseAmount,
    this.doseUnit,
    this.instructions,
    this.courseDurationDays,
    this.startDate,
    this.isActive = true,
    this.createdBy, // ✅
    // القيم الافتراضية
    this.autoRefillMode = 'off',
    this.refillThreshold = 0.0,
    this.refillAction = 'list',
    this.isRefillRequested = false,
    this.isSynced = false,
  });

  // دالة مساعدة لمعرفة هل انتهى الكورس أم لا
  bool get isCourseFinished {
    if (startDate == null || courseDurationDays == null) return false;

    final endDate = startDate!.add(Duration(days: courseDurationDays!));
    final now = DateTime.now();

    // الكورس منتهي إذا كان تاريخ اليوم بعد تاريخ النهاية
    return now.isAfter(endDate);
  }

  // دالة مساعدة لحساب النسبة المئوية للتقدم
  double get courseProgress {
    if (startDate == null ||
        courseDurationDays == null ||
        courseDurationDays == 0) {
      return 0.0;
    }

    final now = DateTime.now();
    final passedDays = now.difference(startDate!).inDays;

    // النسبة = الأيام المنقضية / المدة الكلية
    // clamp(0, 1) تضمن أن النسبة تبقى بين 0 و 1
    return (passedDays / courseDurationDays!).clamp(0.0, 1.0);
  }
}
