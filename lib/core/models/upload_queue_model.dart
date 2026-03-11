import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'upload_queue_model.g.dart';

@Collection()
class UploadQueueModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String localPath;
  late String storagePath;
  late String fileType; // image, document

  // لربط الملف بالمورد الأصلي (مثل uuid الأصل أو المهمة)
  late String relatedEntityUuid;
  late String entityType; // asset, task, project

  int retryCount = 0;
  bool isProcessing = false;
  String? lastError;

  DateTime createdAt = DateTime.now();

  UploadQueueModel() {
    uuid = const Uuid().v4();
  }
}
