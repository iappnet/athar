import 'package:isar/isar.dart';

part 'space_model.g.dart';

@Collection()
class SpaceModel {
  Id id = Isar.autoIncrement; // المعرف المحلي

  @Index(unique: true, replace: true)
  late String uuid; // المعرف السحابي (للمزامنة)

  late String name;

  @Index()
  String type = 'personal'; // ✅ التعديل 1: قيمة افتراضية بدلاً من late لتجنب الأخطاء

  @Index() // ✅ مفيد جداً للبحث السريع عن مساحات مستخدم معين
  String? ownerId; // Supabase User ID

  bool isSynced = false; // هل تم رفع التعديلات؟

  // ✅ الإعداد العام: هل يسمح بالتفويض في هذه المساحة بشكل عام؟
  bool allowMemberDelegation = true;

  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt; // للحذف الناعم للمساحة

  // ✅✅ هام جداً: هذا السطر هو الحل!
  // يعيد تعريف البناء الافتراضي ليتمكن Isar من استخدامه
  SpaceModel();

  // ===========================================================================
  // ✅ دوال التحويل (Serialization)
  // ===========================================================================
  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    final model = SpaceModel()
      ..uuid = json['uuid']
      ..name = json['name']
      ..type =
          json['type'] ??
          'personal' // حماية إضافية
      ..ownerId = json['owner_id']
      ..createdAt = json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null
      ..updatedAt = json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null
      ..deletedAt = json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null
      ..isSynced = true;

    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'type': type,
      'owner_id': ownerId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
