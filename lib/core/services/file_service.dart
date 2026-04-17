import 'dart:io';
import 'package:athar/core/models/upload_queue_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class FileService {
  final Isar _isar;
  final SupabaseClient _supabase = Supabase.instance.client;

  FileService(this._isar);

  Future<File?> pickFile({bool isImage = true}) async {
    if (isImage) {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      return image != null ? File(image.path) : null;
    } else {
      final result = await FilePicker.pickFiles(type: FileType.any);
      return result != null ? File(result.files.single.path!) : null;
    }
  }

  // المحرك المحدث: يعيد النتيجة فوراً ويجدول الرفع في الخلفية
  Future<FileProcessResult> processAndQueueFile({
    required File file,
    required String relatedEntityUuid,
    required String entityType,
    required String spaceType,
  }) async {
    final ext = path.extension(file.path).toLowerCase();
    final isImage = ['.jpg', '.jpeg', '.png', '.heic'].contains(ext);

    // 1. الحفظ المحلي الفوري (للعرض الفوري في التطبيق)
    final appDir = await getApplicationDocumentsDirectory();
    final localFolder = Directory('${appDir.path}/attachments');
    if (!await localFolder.exists()) await localFolder.create(recursive: true);

    final newLocalPath = '${localFolder.path}/${const Uuid().v4()}$ext';
    final localFile = await file.copy(newLocalPath);

    String? storagePath;

    // 2. جدولة الرفع في الخلفية للمساحات المشتركة
    if (spaceType == 'shared' || spaceType == 'work') {
      final storageName = '${const Uuid().v4()}$ext';
      storagePath = 'attachments/$storageName';

      final queueItem = UploadQueueModel()
        ..localPath = newLocalPath
        ..storagePath = storagePath
        ..fileType = isImage ? 'image' : 'document'
        ..relatedEntityUuid = relatedEntityUuid
        ..entityType = entityType;

      await _isar.writeTxn(() => _isar.uploadQueueModels.put(queueItem));

      // نبدأ معالجة الطابور بشكل صامت
      processUploadQueue();
    }

    return FileProcessResult(
      localPath: newLocalPath,
      storagePath: storagePath,
      fileName: path.basename(file.path),
      fileType: isImage ? 'image' : 'document',
      fileSize: await localFile.length(),
    );
  }

  // معالج الطابور (يدار في الخلفية)
  Future<void> processUploadQueue() async {
    final pendingItems = await _isar.uploadQueueModels
        .filter()
        .isProcessingEqualTo(false)
        .sortByCreatedAt()
        .findAll();

    for (var item in pendingItems) {
      try {
        await _isar.writeTxn(() async {
          item.isProcessing = true;
          await _isar.uploadQueueModels.put(item);
        });

        File fileToUpload = File(item.localPath);

        // ضغط الصورة إذا لزم الأمر
        if (item.fileType == 'image') {
          final compressed = await _compressImage(fileToUpload);
          if (compressed != null) fileToUpload = compressed;
        }

        // الرفع الفعلي
        await _supabase.storage
            .from('attachments')
            .upload(item.storagePath, fileToUpload);

        // نجاح: حذف من الطابور
        await _isar.writeTxn(() => _isar.uploadQueueModels.delete(item.id));
      } catch (e) {
        await _isar.writeTxn(() async {
          item.isProcessing = false;
          item.retryCount++;
          item.lastError = e.toString();
          await _isar.uploadQueueModels.put(item);
        });
      }
    }
  }

  Future<File?> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${const Uuid().v4()}.jpg';
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 1024,
      minHeight: 1024,
    );
    return result != null ? File(result.path) : null;
  }
}

class FileProcessResult {
  final String localPath;
  final String? storagePath;
  final DateTime? expiresAt; // ✅ إعادة الحقل المفقود
  final String fileName;
  final String fileType;
  final int fileSize;

  FileProcessResult({
    required this.localPath,
    this.storagePath,
    this.expiresAt, // ✅ إضافة للكونستركتور
    required this.fileName,
    required this.fileType,
    required this.fileSize,
  });
}
// import 'dart:io';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:injectable/injectable.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';

// @lazySingleton
// class FileService {
//   final SupabaseClient _supabase = Supabase.instance.client;

//   // 1. اختيار ملف (صورة أو مستند)
//   Future<File?> pickFile({bool isImage = true}) async {
//     if (isImage) {
//       final XFile? image = await ImagePicker().pickImage(
//         source: ImageSource.gallery,
//       );
//       return image != null ? File(image.path) : null;
//     } else {
//       final result = await FilePicker.platform.pickFiles(type: FileType.any);
//       return result != null ? File(result.files.single.path!) : null;
//     }
//   }

//   // 2. المحرك الرئيسي: حفظ الملف وتطبيق الاستراتيجية الهجينة
//   Future<FileProcessResult> processAndSaveFile({
//     required File file,
//     required String spaceType, // 'personal' or 'shared'
//   }) async {
//     final fileName = path.basename(file.path);
//     final ext = path.extension(file.path).toLowerCase();
//     final isImage = ['.jpg', '.jpeg', '.png', '.heic'].contains(ext);

//     // أ. الحفظ المحلي (دائماً) - Local First
//     final appDir = await getApplicationDocumentsDirectory();
//     final localFolder = Directory('${appDir.path}/attachments');
//     if (!await localFolder.exists()) {
//       await localFolder.create(recursive: true);
//     }

//     final newLocalPath = '${localFolder.path}/${const Uuid().v4()}$ext';
//     final localFile = await file.copy(newLocalPath);

//     String? storagePath;
//     DateTime? expiresAt;

//     // ب. الرفع السحابي (فقط للمساحات المشتركة)
//     if (spaceType == 'shared' || spaceType == 'work') {
//       File fileToUpload = localFile;

//       // 1. ضغط الصور قبل الرفع (توفير التكلفة)
//       if (isImage) {
//         final compressed = await _compressImage(localFile);
//         if (compressed != null) fileToUpload = compressed;
//       }

//       // 2. الرفع إلى Supabase Storage
//       final storageName = '${const Uuid().v4()}$ext';
//       final storageRef = 'attachments/$storageName';

//       await _supabase.storage
//           .from('attachments')
//           .upload(
//             storageRef,
//             fileToUpload,
//             fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
//           );

//       storagePath = storageRef;

//       // 3. تحديد مدة الصلاحية (100 ساعة)
//       expiresAt = DateTime.now().add(const Duration(hours: 100));
//     }

//     return FileProcessResult(
//       localPath: newLocalPath,
//       storagePath: storagePath,
//       expiresAt: expiresAt,
//       fileName: fileName,
//       fileType: isImage ? 'image' : 'document',
//       fileSize: await localFile.length(),
//     );
//   }

//   // دالة مساعدة لضغط الصور
//   Future<File?> _compressImage(File file) async {
//     final dir = await getTemporaryDirectory();
//     final targetPath = '${dir.path}/${const Uuid().v4()}.jpg';

//     var result = await FlutterImageCompress.compressAndGetFile(
//       file.absolute.path,
//       targetPath,
//       quality: 70, // جودة 70% ممتازة للمرفقات
//       minWidth: 1024, // تقليل الأبعاد
//       minHeight: 1024,
//     );

//     return result != null ? File(result.path) : null;
//   }
// }

// // كلاس بسيط لنقل النتيجة
// class FileProcessResult {
//   final String localPath;
//   final String? storagePath;
//   final DateTime? expiresAt;
//   final String fileName;
//   final String fileType;
//   final int fileSize;

//   FileProcessResult({
//     required this.localPath,
//     this.storagePath,
//     this.expiresAt,
//     required this.fileName,
//     required this.fileType,
//     required this.fileSize,
//   });
// }
