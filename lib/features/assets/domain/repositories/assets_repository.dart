import 'package:athar/features/assets/data/models/asset_model.dart';
import 'package:athar/features/assets/data/models/service_model.dart';
import 'package:athar/features/assets/data/models/service_log_model.dart';
// import 'package:athar/core/services/file_service.dart';

abstract class AssetsRepository {
  // --- 1. إدارة الأصول (Assets) ---
  // ✅ التعديل: إضافة spaceId اختياري لفلترة الأصول حسب المساحة
  // ✅ التعديل الجوهري: استبدال spaceId بـ moduleId
  // الآن المرجع الأساسي للفلترة هو الموديول
  Stream<List<AssetModel>> watchAssets({String? moduleId});

  Future<void> addAsset(AssetModel asset);
  Future<void> updateAsset(AssetModel asset);
  Future<void> deleteAsset(int id);
  Future<void> archiveAsset(int id, bool isArchived);

  // ✅ إضافة Methods جديدة للإشعارات
  Future<List<AssetModel>> getAssetsWithReminders();
  Future<AssetModel?> getAssetByUuid(String uuid);

  // --- 2. إدارة خدمات الصيانة (Services) ---
  Stream<List<ServiceModel>> watchServices(String assetUuid);
  Future<void> addService(ServiceModel service);
  Future<void> deleteService(int id);

  // --- 3. سجلات الصيانة (Logs) ---
  Stream<List<ServiceLogModel>> watchServiceLogs(String serviceUuid);

  // هذه الدالة الأهم: تضيف السجل وتحدث موعد الصيانة القادم تلقائياً
  Future<void> addServiceLog(ServiceLogModel log);

  Future<void> deleteServiceLog(int id);
}
