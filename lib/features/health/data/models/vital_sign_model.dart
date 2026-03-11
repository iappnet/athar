import 'package:isar/isar.dart';

part 'vital_sign_model.g.dart';

@Collection()
class VitalSignModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String moduleId;

  late DateTime recordDate;
  late String category; // 'vital', 'document'

  // للمؤشرات
  String? vitalType; // weight, temp, pressure
  double? vitalValue;
  String? vitalUnit; // kg, C

  // للوثائق
  String? title;
  String? attachmentPath;

  bool isSynced = false;
  DateTime createdAt = DateTime.now();

  VitalSignModel({
    required this.uuid,
    required this.moduleId,
    required this.recordDate,
    required this.category,
    this.vitalType,
    this.vitalValue,
    this.vitalUnit,
    this.title,
    this.attachmentPath,
    this.isSynced = false,
  });
}
