import 'package:isar/isar.dart';

part 'list_log_model.g.dart';

@Collection()
class ListLogModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String moduleId;

  @Index()
  String? itemId; // قد يكون null إذا حذف العنصر الأصلي

  late String itemName; // نحتفظ بالاسم للأرشيف
  late String actionType; // 'checked', 'unchecked', 'cloned'

  late DateTime performedAt;

  double? quantity;
  double? price; // للمستقبل (إحصائيات الصرف)

  bool isSynced = false;

  ListLogModel({
    required this.uuid,
    required this.moduleId,
    this.itemId,
    required this.itemName,
    required this.actionType,
    required this.performedAt,
    this.quantity,
    this.price,
    this.isSynced = false,
  });
}
