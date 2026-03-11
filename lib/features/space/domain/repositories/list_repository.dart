import 'package:athar/features/space/data/models/list_item_model.dart';
import 'package:athar/features/space/data/models/list_log_model.dart';

abstract class ListRepository {
  // --- إدارة العناصر ---
  Stream<List<ListItemModel>> watchItems(String moduleId); // مراقبة حية للقائمة
  Future<void> addItem(ListItemModel item);
  Future<void> updateItem(ListItemModel item); // عند وضع علامة صح ✅
  Future<void> deleteItem(int id);

  // --- إدارة القوالب والاستنساخ ---
  // هذه الدالة السحرية تنسخ كل عناصر قائمة وتضعها في قائمة أخرى
  Future<void> cloneListItems({
    required String sourceModuleId,
    required String targetModuleId,
  });

  // --- إدارة السجلات والأرشيف ---
  Stream<List<ListLogModel>> watchLogs(String moduleId);
  Future<void> addLog(ListLogModel log);
}
