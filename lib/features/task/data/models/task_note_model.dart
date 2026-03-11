import 'package:isar/isar.dart';

part 'task_note_model.g.dart';

@Collection()
class TaskNoteModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid; // معرف الملاحظة (يأتي من السيرفر أو يولد محلياً)

  @Index()
  late String taskId;

  @Index()
  late String userId; // صاحب الملاحظة

  String? content;

  late DateTime updatedAt;

  // حقل للعرض فقط (لن يخزن في قاعدة البيانات، سنملؤه عند الجلب من البروفايل)
  @Ignore()
  String? authorName;
  @Ignore()
  String? authorAvatar;

  bool isSynced = false;

  // خاصية للتحقق مما إذا كانت الملاحظة فارغة (لتطبيق شرطك: لا تظهر إلا إذا كتب)
  bool get hasContent => content != null && content!.trim().isNotEmpty;
}
