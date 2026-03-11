import 'package:athar/features/space/data/models/list_item_model.dart';
import 'package:athar/features/space/data/models/list_log_model.dart';
import 'package:athar/features/space/domain/repositories/list_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: ListRepository)
class ListRepositoryImpl implements ListRepository {
  final Isar _isar;

  ListRepositoryImpl(this._isar);

  // ===========================================================================
  // 1. إدارة العناصر (CRUD) + الأرشفة الذكية
  // ===========================================================================

  @override
  Stream<List<ListItemModel>> watchItems(String moduleId) {
    return _isar.listItemModels
        .filter()
        .moduleIdEqualTo(moduleId)
        .sortByIsChecked() // غير المكتمل أولاً
        .thenByCreatedAtDesc() // ثم الأحدث
        .watch(fireImmediately: true);
  }

  @override
  Future<void> addItem(ListItemModel item) async {
    await _isar.writeTxn(() async {
      await _isar.listItemModels.put(item);
    });
  }

  @override
  Future<void> updateItem(ListItemModel item) async {
    await _isar.writeTxn(() async {
      // 1. حفظ التعديل
      item.updatedAt = DateTime.now();
      item.isSynced = false;
      await _isar.listItemModels.put(item);

      // 🧠 2. الذكاء: إذا تم الشراء (Checked)، نسجل في الأرشيف تلقائياً
      if (item.isChecked) {
        final log = ListLogModel(
          uuid: const Uuid().v4(),
          moduleId: item.moduleId,
          itemId: item.uuid,
          itemName: item.name,
          actionType: 'bought', // تم الشراء
          performedAt: DateTime.now(),
          quantity: item.quantity,
        );
        await _isar.listLogModels.put(log);
      }
    });
  }

  @override
  Future<void> deleteItem(int id) async {
    await _isar.writeTxn(() async {
      await _isar.listItemModels.delete(id);
    });
  }

  // ===========================================================================
  // 2. الاستنساخ (The Magic Cloning) 🐑
  // ===========================================================================

  @override
  Future<void> cloneListItems({
    required String sourceModuleId,
    required String targetModuleId,
  }) async {
    // 1. جلب العناصر الأصلية
    final sourceItems = await _isar.listItemModels
        .filter()
        .moduleIdEqualTo(sourceModuleId)
        .findAll();

    if (sourceItems.isEmpty) return;

    // 2. تجهيز النسخ الجديدة
    final newItems = sourceItems.map((original) {
      return ListItemModel(
        uuid: const Uuid().v4(), // هوية جديدة تماماً
        moduleId: targetModuleId, // نربطها بالقائمة الجديدة
        name: original.name,
        quantity: original.quantity,
        unit: original.unit,
        category: original.category,
        repeatEveryDays: original.repeatEveryDays,
        autoUncheck: original.autoUncheck,
        notes: original.notes,
        isChecked: false, // نبدأ غير مكتملة طبعاً
      );
    }).toList();

    // 3. الحفظ دفعة واحدة (Bulk Insert)
    await _isar.writeTxn(() async {
      await _isar.listItemModels.putAll(newItems);

      // نسجل في الأرشيف أننا قمنا بالاستنساخ
      final log = ListLogModel(
        uuid: const Uuid().v4(),
        moduleId: targetModuleId,
        itemName: "System",
        actionType: 'cloned_from_template',
        performedAt: DateTime.now(),
        quantity: newItems.length.toDouble(),
      );
      await _isar.listLogModels.put(log);
    });
  }

  // ===========================================================================
  // 3. السجلات (Logs)
  // ===========================================================================

  @override
  Stream<List<ListLogModel>> watchLogs(String moduleId) {
    return _isar.listLogModels
        .filter()
        .moduleIdEqualTo(moduleId)
        .sortByPerformedAtDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<void> addLog(ListLogModel log) async {
    await _isar.writeTxn(() async {
      await _isar.listLogModels.put(log);
    });
  }
}
