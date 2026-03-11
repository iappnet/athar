import 'dart:async';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/iam/permission_service.dart'; // ✅ استيراد خدمة الصلاحيات
import 'package:athar/core/services/file_service.dart';
import 'package:athar/features/assets/data/models/asset_model.dart';
import 'package:athar/features/assets/data/models/service_log_model.dart';
import 'package:athar/features/assets/data/models/service_model.dart';
import 'package:athar/features/assets/domain/repositories/assets_repository.dart';
import 'package:athar/features/assets/presentation/cubit/assets_state.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/task/data/models/attachment_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@injectable
class AssetsCubit extends Cubit<AssetsState> {
  final AssetsRepository _repository;
  // ✅ 1. حقن خدمة الصلاحيات
  final PermissionService _permissionService;

  StreamSubscription? _assetsSubscription;
  // String? _currentSpaceId; // ✅ لتخزين سياق المساحة الحالي

  // ✅ تغيير المتغير لتخزين معرف الموديول بدلاً من المساحة
  String? _currentModuleId;

  // تحديث الـ Constructor
  AssetsCubit(this._repository, this._permissionService)
    : super(AssetsInitial());

  // ===========================================================================
  // 1. إدارة الأصول (Assets)
  // ===========================================================================

  // مراقبة القائمة الرئيسية (مع دعم المساحات)
  // مراقبة القائمة (حسب الموديول)
  void watchAssets({String? moduleId}) {
    _currentModuleId = moduleId;

    emit(AssetsLoading());
    _assetsSubscription?.cancel();

    _assetsSubscription = _repository
        .watchAssets(moduleId: moduleId)
        .listen(
          (assets) {
            emit(AssetsLoaded(assets));
          },
          onError: (e) {
            emit(AssetsError("فشل تحميل الأصول: $e"));
          },
        );
  }

  // إضافة أصل جديد
  Future<void> addAsset({
    required String name,
    required DateTime purchaseDate,
    required int warrantyMonths,
    String? category,
    String? vendor,
    String? serialNumber,
    double? price,
    String? notes,
    String? spaceId,
    String? moduleId,
  }) async {
    // 🔒 يمكن إضافة فحص صلاحية الإنشاء هنا أيضاً (اختياري، لأن الواجهة تخفي الزر)
    // if (!_permissionService.hasPermission('create', spaceId: spaceId, resourceType: 'asset')) return;

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? 'guest';

      final newAsset = AssetModel(
        uuid: const Uuid().v4(),
        userId: userId,
        name: name,
        purchaseDate: purchaseDate,
        warrantyMonths: warrantyMonths,
        category: category,
        vendor: vendor,
        serialNumber: serialNumber,
        price: price,
        notes: notes,
        spaceId: spaceId,
        moduleId: moduleId, // ✅ حفظ الربط
      );

      await _repository.addAsset(newAsset);
    } catch (e) {
      emit(AssetsError("فشل إضافة الأصل"));
      watchAssets(moduleId: moduleId);
    }
  }

  Future<void> pickAndAddAssetImage(
    AssetModel asset, {
    bool isCamera = true,
    required String spaceType,
  }) async {
    try {
      final fileService = getIt<FileService>();
      final file = await fileService.pickFile(isImage: true);
      if (file == null) return;

      // ✅ التحديث: استخدام الدالة الجديدة وتمرير الـ UUID لربط الملف بالخلفية
      final result = await fileService.processAndQueueFile(
        file: file,
        relatedEntityUuid: asset.uuid,
        entityType: 'asset',
        spaceType: spaceType,
      );

      final attachment = AttachmentModel()
        ..uuid = const Uuid().v4()
        ..fileName = result.fileName
        ..fileType = result.fileType
        ..localPath = result.localPath
        ..storagePath = result.storagePath
        ..createdAt = DateTime.now()
        ..assetId = asset.uuid;

      asset.attachments.add(attachment);
      await _repository.updateAsset(asset);
    } catch (e) {
      emit(AssetsError("فشل إضافة الصورة: $e"));
    }
  }

  // ✅ 2. تأمين دالة الحذف (Logic Layer Guard)
  // قمنا بتحديث التوقيع ليطلب ModuleModel للفحص الدقيق
  Future<void> deleteAsset(
    int id, {
    required String? spaceId,
    ModuleModel? module, // ✅ لتطبيق قواعد الموديول
  }) async {
    // استخدام الدالة المحدثة في PermissionService
    final canDelete = await _permissionService.hasPermission(
      'delete',
      spaceId: spaceId,
      resourceType: 'asset',
      module: module, // ✅ تمرير الموديول للفحص الهرمي
    );

    if (!canDelete) {
      emit(AssetsError("عذراً، لا تملك صلاحية حذف هذا الأصل 🚫"));
      watchAssets(moduleId: _currentModuleId);
      return;
    }

    await _repository.deleteAsset(id);
  }

  // ===========================================================================
  // 2. إدارة الخدمات والصيانة
  // ===========================================================================

  Stream<List<ServiceModel>> watchServices(String assetUuid) {
    return _repository.watchServices(assetUuid);
  }

  Future<void> addService({
    required String assetId,
    required String name,
    int? repeatDays,
    int? repeatKm,
    bool reminderEnabled = true,
    DateTime? reminderTime,
  }) async {
    final service = ServiceModel(
      uuid: const Uuid().v4(),
      assetId: assetId,
      name: name,
      repeatEveryDays: repeatDays,
      repeatEveryKm: repeatKm,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
    );
    await _repository.addService(service);
  }

  Future<void> addServiceLog({
    required String serviceId,
    required DateTime date,
    int? odometer,
    double? cost,
    String? notes,
  }) async {
    final log = ServiceLogModel(
      uuid: const Uuid().v4(),
      serviceId: serviceId,
      performedAt: date,
      odometerReading: odometer,
      cost: cost,
      notes: notes,
    );

    await _repository.addServiceLog(log);
  }

  Stream<List<ServiceLogModel>> watchLogs(String serviceUuid) {
    return _repository.watchServiceLogs(serviceUuid);
  }

  @override
  Future<void> close() {
    _assetsSubscription?.cancel();
    return super.close();
  }
}
