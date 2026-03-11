import 'package:isar/isar.dart';

part 'attachment_model.g.dart';

@Collection()
class AttachmentModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  // 1️⃣ التعديل الأول: جعلنا taskId اختيارياً (String?) بدلاً من (late String)
  // لكي نتمكن من حفظ مرفق بدون مهمة (إذا كان تابعاً لأصل)
  @Index()
  String? taskId;

  // 2️⃣ التعديل الثاني: إضافة حقل assetId لربط المرفق بالأصل
  @Index()
  String? assetId;

  late String fileName;
  late String fileType; // image, pdf, etc.
  int? fileSize;

  // الاستراتيجية الهجينة
  String? localPath; // المسار الداخلي للجهاز
  String? storagePath; // المسار السحابي

  DateTime? expiresAt; // متى ينحذف من السحابة
  bool isDeletedFromCloud = false;

  @Index()
  String? uploaderId; // صاحب الملف الأصلي

  DateTime createdAt = DateTime.now();
  DateTime? deletedAt;

  bool isSynced = false;
}
