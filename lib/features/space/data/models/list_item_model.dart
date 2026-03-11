import 'package:isar/isar.dart';

part 'list_item_model.g.dart';

@Collection()
class ListItemModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String moduleId; // ربط بالقائمة (Module)

  late String name;
  bool isChecked = false;

  double quantity = 1.0;
  String? unit; // kg, pcs, box
  String? category; // vegetables, tools

  // --- 🧠 الذكاء: التكرار ---
  int? repeatEveryDays; // مثلاً: كل 7 أيام
  bool autoUncheck = false; // إذا true: يعود للقائمة تلقائياً بعد المدة
  DateTime? lastBoughtAt; // تاريخ آخر شراء لحساب الموعد القادم

  String? notes;

  @Index()
  String? automationLinkId; // 🔗 للربط مع المهام

  // ✅ الإضافة الجديدة: لمعرفة منشئ العنصر
  @Index()
  String? createdBy;

  bool isSynced = false;
  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;

  ListItemModel({
    required this.uuid,
    required this.moduleId,
    required this.name,
    this.isChecked = false,
    this.quantity = 1.0,
    this.unit,
    this.category,
    this.repeatEveryDays,
    this.autoUncheck = false,
    this.lastBoughtAt,
    this.notes,
    this.createdBy, // ✅
    this.isSynced = false,
    this.automationLinkId, // ✅
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
}
