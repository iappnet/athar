import 'package:isar/isar.dart';
import 'package:athar/features/settings/data/models/category_model.dart';

part 'task_template.g.dart';

@collection
class TaskTemplate {
  Id id = Isar.autoIncrement;

  late String uuid;
  late String userId;

  // معلومات القالب
  late String name; // اسم القالب (مثل: "اجتماع أسبوعي")
  String? description;
  String? icon; // emoji أو icon name

  // القيم الافتراضية للمهمة
  late String title;
  bool isUrgent = false;
  bool isImportant = false;
  int durationMinutes = 30;

  // العلاقة مع التصنيف
  int? categoryId;
  final category = IsarLink<CategoryModel>();

  // التذكير
  bool hasReminder = false;
  int? reminderMinutesBefore;

  // الملاحظات الافتراضية
  String? defaultNotes;

  // التكرار (إذا كان القالب للمهام المتكررة)
  bool isRecurring = false;
  String? recurrenceJson; // JSON serialized RecurrencePattern

  // Metadata
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  int usageCount = 0; // عدد مرات الاستخدام

  TaskTemplate();
}
