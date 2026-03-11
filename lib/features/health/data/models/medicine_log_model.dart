import 'package:isar/isar.dart';

part 'medicine_log_model.g.dart';

@Collection()
class MedicineLogModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String medicineId; // Foreign Key to MedicineModel

  @Index()
  late String moduleId;

  late DateTime takenAt;
  String status = 'taken'; // taken, skipped
  String? notes;

  bool isSynced = false;

  MedicineLogModel({
    required this.uuid,
    required this.medicineId,
    required this.moduleId,
    required this.takenAt,
    this.status = 'taken',
    this.notes,
    this.isSynced = false,
  });
}
