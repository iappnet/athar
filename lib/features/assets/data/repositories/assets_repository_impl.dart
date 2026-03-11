import 'package:athar/features/assets/data/models/asset_model.dart';
import 'package:athar/features/assets/data/models/service_log_model.dart';
import 'package:athar/features/assets/data/models/service_model.dart';
import 'package:athar/features/assets/domain/repositories/assets_repository.dart';
// import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: AssetsRepository)
class AssetsRepositoryImpl implements AssetsRepository {
  final Isar _isar;
  final SupabaseClient _supabase = Supabase.instance.client;

  AssetsRepositoryImpl(this._isar);

  // ===========================================================================
  // 1. إدارة الأصول (Assets)
  // ===========================================================================

  @override
  // ✅ التعديل: دعم الفلترة حسب spaceId
  Stream<List<AssetModel>> watchAssets({String? moduleId}) {
    final userId = _supabase.auth.currentUser?.id ?? 'guest';

    // بناء الاستعلام الأساسي (النشط وغير المحذوف)
    var query = _isar.assetModels.filter().deletedAtIsNull().isArchivedEqualTo(
      false,
    );

    if (moduleId != null) {
      // 🏢 سيناريو مساحة مشتركة:
      // اجلب كل أصول هذه المساحة (بغض النظر عن من أضافها)
      return query
          .spaceIdEqualTo(moduleId)
          .sortByCreatedAtDesc()
          .watch(fireImmediately: true);
    } else {
      // 🏠 سيناريو شخصي (أصولي الخاصة):
      // اجلب الأصول المرتبطة بمعرفي والتي لا تتبع أي مساحة
      return query
          .userIdEqualTo(userId)
          .spaceIdIsNull() // مهم جداً لعدم خلط أصول العمل مع البيت
          .sortByCreatedAtDesc()
          .watch(fireImmediately: true);
    }
  }

  @override
  Future<void> addAsset(AssetModel asset) async {
    await _isar.writeTxn(() async {
      await _isar.assetModels.put(asset);
    });
    // (لاحقاً سنضيف كود المزامنة مع Supabase هنا)
  }

  @override
  Future<void> updateAsset(AssetModel asset) async {
    asset.updatedAt = DateTime.now();
    asset.isSynced = false;
    await _isar.writeTxn(() async {
      await _isar.assetModels.put(asset);
    });
  }

  @override
  Future<void> deleteAsset(int id) async {
    await _isar.writeTxn(() async {
      final asset = await _isar.assetModels.get(id);
      if (asset != null) {
        asset.deletedAt = DateTime.now();
        asset.isSynced = false;
        await _isar.assetModels.put(asset);
      }
    });
  }

  @override
  Future<void> archiveAsset(int id, bool isArchived) async {
    await _isar.writeTxn(() async {
      final asset = await _isar.assetModels.get(id);
      if (asset != null) {
        asset.isArchived = isArchived;
        asset.updatedAt = DateTime.now();
        asset.isSynced = false;
        await _isar.assetModels.put(asset);
      }
    });
  }

  // ✅ إضافة الدوال الجديدة للإشعارات
  @override
  Future<List<AssetModel>> getAssetsWithReminders() async {
    return await _isar.assetModels
        .filter()
        .reminderEnabledEqualTo(true)
        .and()
        .isArchivedEqualTo(false)
        .and()
        .deletedAtIsNull()
        .and()
        .group(
          (q) => q
              .nextMaintenanceDateIsNotNull()
              .or()
              .insuranceExpiryDateIsNotNull()
              .or()
              .licenseExpiryDateIsNotNull(),
        )
        .findAll();
  }

  @override
  Future<AssetModel?> getAssetByUuid(String uuid) async {
    return await _isar.assetModels
        .filter()
        .uuidEqualTo(uuid)
        .and()
        .deletedAtIsNull()
        .findFirst();
  }

  // ===========================================================================
  // 2. إدارة الخدمات (Services)
  // ===========================================================================

  @override
  Stream<List<ServiceModel>> watchServices(String assetUuid) {
    return _isar.serviceModels
        .filter()
        .assetIdEqualTo(assetUuid)
        .watch(fireImmediately: true);
  }

  @override
  Future<void> addService(ServiceModel service) async {
    await _isar.writeTxn(() async {
      await _isar.serviceModels.put(service);
    });
  }

  @override
  Future<void> deleteService(int id) async {
    await _isar.writeTxn(() async {
      await _isar.serviceModels.delete(id);
    });
  }

  // ===========================================================================
  // 3. سجلات الصيانة (Logs)
  // ===========================================================================

  @override
  Stream<List<ServiceLogModel>> watchServiceLogs(String serviceUuid) {
    return _isar.serviceLogModels
        .filter()
        .serviceIdEqualTo(serviceUuid)
        .sortByPerformedAtDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<void> addServiceLog(ServiceLogModel log) async {
    await _isar.writeTxn(() async {
      await _isar.serviceLogModels.put(log);

      final service = await _isar.serviceModels
          .filter()
          .uuidEqualTo(log.serviceId)
          .findFirst();

      if (service != null) {
        service.lastServiceDate = log.performedAt;
        if (log.odometerReading != null) {
          service.lastOdometerReading = log.odometerReading;
        }

        _calculateNextDue(service);

        service.updatedAt = DateTime.now();
        service.isSynced = false;
        await _isar.serviceModels.put(service);
      }
    });
  }

  @override
  Future<void> deleteServiceLog(int id) async {
    await _isar.writeTxn(() async {
      await _isar.serviceLogModels.delete(id);
    });
  }

  void _calculateNextDue(ServiceModel service) {
    service.calculateNextDue();
  }
}
