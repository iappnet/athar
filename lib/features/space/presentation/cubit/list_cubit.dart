import 'dart:async';
import 'package:athar/core/iam/permission_service.dart';
import 'package:athar/core/services/automation_service.dart';
import 'package:athar/features/space/data/models/list_item_model.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/space/domain/repositories/list_repository.dart';
import 'package:athar/features/space/presentation/cubit/list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

@injectable
class ListCubit extends Cubit<ListState> {
  final ListRepository _repository;
  // ✅ 1. حقن خدمة الصلاحيات
  final PermissionService _permissionService;

  // ✅ 1. حقن خدمة الأتمتة (أفضل من getIt المباشر)
  final AutomationService _automationService;

  StreamSubscription? _itemsSubscription;
  ModuleModel? _currentModule; // ✅ لتخزين سياق الموديول

  ListCubit(this._repository, this._permissionService, this._automationService)
    : super(ListInitial());

  // دالة لضبط السياق (يستدعيها UI)
  void setContext(ModuleModel? module) {
    _currentModule = module;
  }

  // مراقبة القائمة (Real-time)
  void watchListItems(String moduleId) {
    emit(ListLoading());
    _itemsSubscription?.cancel();
    _itemsSubscription = _repository
        .watchItems(moduleId)
        .listen(
          (items) {
            if (isClosed) return;
            _checkRecurringItems(items);
            emit(ListLoaded(items));
          },
          onError: (e) {
            if (isClosed) return;
            emit(ListError("فشل تحميل القائمة"));
          },
        );
  }

  // ✅ المنطق الذكي: فحص العناصر الدورية وإعادتها للقائمة
  Future<void> _checkRecurringItems(List<ListItemModel> items) async {
    final now = DateTime.now();
    for (var item in items) {
      if (item.isChecked &&
          item.autoUncheck &&
          item.repeatEveryDays != null &&
          item.lastBoughtAt != null) {
        final nextReset = item.lastBoughtAt!.add(
          Duration(days: item.repeatEveryDays!),
        );

        if (now.isAfter(nextReset)) {
          item.isChecked = false;
          await _repository.updateItem(item);
        }
      }
    }
  }

  // إضافة عنصر
  Future<void> addItem({
    required String moduleId,
    required String name,
    double quantity = 1.0,
    String? unit,
    int? repeatDays,
    bool autoUncheck = false,
  }) async {
    if (name.trim().isEmpty) return;

    // ✅ عملية تشغيلية (list_item_op): مسموحة للجميع عادةً
    // لكن نسجل المنشئ للتحكم بالحذف لاحقاً
    final userId = Supabase.instance.client.auth.currentUser?.id;

    final item = ListItemModel(
      uuid: const Uuid().v4(),
      moduleId: moduleId,
      name: name.trim(),
      quantity: quantity,
      unit: unit,
      repeatEveryDays: repeatDays,
      autoUncheck: autoUncheck,
      isChecked: false,
      createdBy: userId, // ✅ تسجيل الملكية
    );

    await _repository.addItem(item);
  }

  Future<void> toggleItem(ListItemModel item) async {
    item.isChecked = !item.isChecked;
    if (item.isChecked) {
      item.lastBoughtAt = DateTime.now();
    }
    await _repository.updateItem(item);

    // ✅ التزامن مع المهام (باستخدام النسخة المحقونة)
    if (item.automationLinkId != null) {
      _automationService.syncCompletion(item.automationLinkId!, item.isChecked);
    }
  }

  // ✅ الحماية هنا: الحذف
  Future<void> deleteItem(ListItemModel item) async {
    // ✅ التعديل هنا: إضافة await
    final canDelete = await _permissionService.hasPermission(
      'delete',
      spaceId: _currentModule?.spaceId,
      resourceType: 'list_core',
      module: _currentModule,
      resourceOwnerId: item.createdBy,
    );

    if (!canDelete) {
      emit(ListError("لا تملك صلاحية حذف هذا العنصر 🚫"));
      watchListItems(item.moduleId);
      return;
    }
    await _repository.deleteItem(item.id);
  }

  // ✅ الحماية هنا: التصفير الكامل
  Future<void> resetList(List<ListItemModel> items) async {
    // ✅ التعديل هنا: إضافة await
    final canReset = await _permissionService.hasPermission(
      'update',
      spaceId: _currentModule?.spaceId,
      resourceType: 'list_core',
      module: _currentModule,
    );

    if (!canReset) {
      emit(ListError("فقط المشرف يمكنه تصفير القائمة بالكامل 🚫"));
      return;
    }

    for (var item in items) {
      if (item.isChecked) {
        item.isChecked = false;
        await _repository.updateItem(item);
      }
    }
  }

  // ✅✅ دالة الاستنساخ الجديدة (تشغل المحرك الموجود في Repository)
  Future<void> copyList({
    required String sourceModuleId,
    required String targetModuleId,
  }) async {
    await _repository.cloneListItems(
      sourceModuleId: sourceModuleId,
      targetModuleId: targetModuleId,
    );
  }

  // ✅ دالة جديدة لتحديث بيانات العنصر (تعديل)
  Future<void> updateItemDetails({
    required ListItemModel item,
    required String name,
    double quantity = 1.0,
    String? unit,
    int? repeatDays,
    bool autoUncheck = false,
  }) async {
    // التعديل يتطلب صلاحية المالك أو المفوض
    final canEdit = await _permissionService.hasPermission(
      'update_core',
      spaceId: _currentModule?.spaceId,
      resourceType: 'list_core',
      module: _currentModule,
      resourceOwnerId: item.createdBy,
    );

    if (!canEdit) {
      emit(ListError("لا تملك صلاحية تعديل هذا العنصر"));
      return;
    }
    // تحديث القيم
    item.name = name.trim();
    item.quantity = quantity;
    item.unit = unit;
    item.repeatEveryDays = repeatDays;
    item.autoUncheck = autoUncheck;

    // الحفظ في قاعدة البيانات
    await _repository.updateItem(item);
  }

  @override
  Future<void> close() {
    _itemsSubscription?.cancel();
    return super.close();
  }
}
