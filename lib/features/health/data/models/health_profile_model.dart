import 'package:isar/isar.dart';

part 'health_profile_model.g.dart';

@Collection()
class HealthProfileModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index(unique: true, replace: true)
  late String moduleId;

  String? bloodType;
  String? allergies;
  String? emergencyContactName;
  String? emergencyContactPhone;
  String? insuranceNumber;

  bool isSynced = false;
  DateTime updatedAt = DateTime.now();

  HealthProfileModel({
    required this.uuid,
    required this.moduleId,
    this.bloodType,
    this.allergies,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.insuranceNumber,
    this.isSynced = false,
  });
}
