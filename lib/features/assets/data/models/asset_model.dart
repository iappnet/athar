import 'package:isar/isar.dart';
import 'package:athar/features/task/data/models/attachment_model.dart'; // سنعيد استخدام المرفقات للفواتير

part 'asset_model.g.dart';

@Collection()
class AssetModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String userId;

  @Index()
  String? spaceId;

  // ✅ التعديل الجديد: إضافة moduleId للربط بنظام الصلاحيات
  @Index()
  String? moduleId;

  bool isSynced = false;
  DateTime? updatedAt;
  DateTime? deletedAt;
  DateTime createdAt = DateTime.now();

  // --- بيانات الأصل ---
  @Index(type: IndexType.value)
  late String name;

  String? category; // إلكترونيات، أثاث، سيارات...
  String? vendor; // جرير، إكسترا، أمازون...
  String? serialNumber; // S/N
  double? price;

  late DateTime purchaseDate;
  int warrantyMonths = 24; // الافتراضي سنتين (حسب نظام التجارة غالباً)

  String? notes;
  bool isArchived = false; // إذا بعت الجهاز أو رميته

  // ✅ العلاقة مع المرفقات (صورة الجهاز + صورة الفاتورة)
  // سنستخدم نفس جدول المرفقات الذي بنيناه للمهام!
  final attachments = IsarLinks<AttachmentModel>();

  // ═══════════════════════════════════════════════════════════
  // ✅ حقول الإشعارات الجديدة
  // ═══════════════════════════════════════════════════════════

  /// تاريخ الصيانة القادمة
  DateTime? nextMaintenanceDate;

  /// تاريخ انتهاء التأمين
  DateTime? insuranceExpiryDate;

  /// تاريخ انتهاء الرخصة (للسيارات مثلاً)
  DateTime? licenseExpiryDate;

  /// تفعيل/تعطيل التذكيرات
  bool reminderEnabled = true;

  /// عدد الأيام قبل التذكير (افتراضي: 7 أيام)
  int reminderDaysBefore = 7;

  // --- الخصائص الذكية (Computed Properties) ---

  // 1. تاريخ انتهاء الضمان
  // ✅ أضف @Ignore() هنا
  @Ignore()
  DateTime get warrantyExpiryDate {
    return purchaseDate.add(Duration(days: warrantyMonths * 30));
  }

  // 2. الأيام المتبقية
  // ✅ أضف @Ignore() هنا
  @Ignore()
  int get daysRemaining {
    return warrantyExpiryDate.difference(DateTime.now()).inDays;
  }

  // 3. حالة الضمان
  // ✅ أضف @Ignore() هنا
  @Ignore()
  AssetWarrantyStatus get status {
    final days = daysRemaining;
    if (days < 0) return AssetWarrantyStatus.expired;
    if (days <= 30) return AssetWarrantyStatus.expiringSoon; // تنبيه قبل شهر
    return AssetWarrantyStatus.active;
  }

  // ✅ التحقق: هل الأصل يحتاج صيانة قريباً؟
  @Ignore()
  bool get needsMaintenanceSoon {
    if (nextMaintenanceDate == null) return false;
    final daysUntil = nextMaintenanceDate!.difference(DateTime.now()).inDays;
    return daysUntil <= reminderDaysBefore && daysUntil >= 0;
  }

  // ✅ التحقق: هل التأمين سينتهي قريباً؟
  @Ignore()
  bool get insuranceExpiringSoon {
    if (insuranceExpiryDate == null) return false;
    final daysUntil = insuranceExpiryDate!.difference(DateTime.now()).inDays;
    return daysUntil <= reminderDaysBefore && daysUntil >= 0;
  }

  // ✅ التحقق: هل الرخصة ستنتهي قريباً؟
  @Ignore()
  bool get licenseExpiringSoon {
    if (licenseExpiryDate == null) return false;
    final daysUntil = licenseExpiryDate!.difference(DateTime.now()).inDays;
    return daysUntil <= reminderDaysBefore && daysUntil >= 0;
  }

  // ✅ التحقق: هل الأصل يحتاج أي تذكير؟
  @Ignore()
  bool get needsReminder {
    return reminderEnabled &&
        (needsMaintenanceSoon || insuranceExpiringSoon || licenseExpiringSoon);
  }

  AssetModel({
    required this.uuid,
    required this.userId,
    required this.name,
    required this.purchaseDate,
    this.spaceId,
    this.moduleId,
    this.category,
    this.vendor,
    this.serialNumber,
    this.price,
    this.warrantyMonths = 24,
    this.notes,
    this.isArchived = false,
    this.isSynced = false,
    DateTime? updatedAt,
    // ✅ الحقول الجديدة
    this.nextMaintenanceDate,
    this.insuranceExpiryDate,
    this.licenseExpiryDate,
    this.reminderEnabled = true,
    this.reminderDaysBefore = 7,
  }) : updatedAt = updatedAt ?? DateTime.now();

  // ═══════════════════════════════════════════════════════════
  // JSON Serialization
  // ═══════════════════════════════════════════════════════════

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      uuid: json['uuid'],
      userId: json['user_id'],
      name: json['name'],
      purchaseDate: DateTime.parse(json['purchase_date']),
      spaceId: json['space_id'],
      moduleId: json['module_id'],
      category: json['category'],
      vendor: json['vendor'],
      serialNumber: json['serial_number'],
      price: json['price']?.toDouble(),
      warrantyMonths: json['warranty_months'] ?? 24,
      notes: json['notes'],
      isArchived: json['is_archived'] ?? false,
      isSynced: json['is_synced'] ?? false,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      nextMaintenanceDate: json['next_maintenance_date'] != null
          ? DateTime.tryParse(json['next_maintenance_date'])
          : null,
      insuranceExpiryDate: json['insurance_expiry_date'] != null
          ? DateTime.tryParse(json['insurance_expiry_date'])
          : null,
      licenseExpiryDate: json['license_expiry_date'] != null
          ? DateTime.tryParse(json['license_expiry_date'])
          : null,
      reminderEnabled: json['reminder_enabled'] ?? true,
      reminderDaysBefore: json['reminder_days_before'] ?? 7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'user_id': userId,
      'name': name,
      'purchase_date': purchaseDate.toIso8601String(),
      'space_id': spaceId,
      'module_id': moduleId,
      'category': category,
      'vendor': vendor,
      'serial_number': serialNumber,
      'price': price,
      'warranty_months': warrantyMonths,
      'notes': notes,
      'is_archived': isArchived,
      'is_synced': isSynced,
      'updated_at': updatedAt?.toIso8601String(),
      'next_maintenance_date': nextMaintenanceDate?.toIso8601String(),
      'insurance_expiry_date': insuranceExpiryDate?.toIso8601String(),
      'license_expiry_date': licenseExpiryDate?.toIso8601String(),
      'reminder_enabled': reminderEnabled,
      'reminder_days_before': reminderDaysBefore,
    };
  }

  AssetModel copyWith({
    String? name,
    DateTime? purchaseDate,
    String? category,
    String? vendor,
    String? serialNumber,
    double? price,
    int? warrantyMonths,
    String? notes,
    bool? isArchived,
    DateTime? nextMaintenanceDate,
    DateTime? insuranceExpiryDate,
    DateTime? licenseExpiryDate,
    bool? reminderEnabled,
    int? reminderDaysBefore,
  }) {
    return AssetModel(
      uuid: uuid,
      userId: userId,
      name: name ?? this.name,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      spaceId: spaceId,
      moduleId: moduleId,
      category: category ?? this.category,
      vendor: vendor ?? this.vendor,
      serialNumber: serialNumber ?? this.serialNumber,
      price: price ?? this.price,
      warrantyMonths: warrantyMonths ?? this.warrantyMonths,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      isSynced: isSynced,
      updatedAt: DateTime.now(),
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      insuranceExpiryDate: insuranceExpiryDate ?? this.insuranceExpiryDate,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
    );
  }
}

// حالة الضمان (للتلوين في الواجهة)
enum AssetWarrantyStatus {
  active, // أخضر
  expiringSoon, // برتقالي
  expired, // أحمر/رمادي
}
