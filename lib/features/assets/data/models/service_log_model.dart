import 'package:isar/isar.dart';

part 'service_log_model.g.dart';

@Collection()
class ServiceLogModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String serviceId; // ربط بالخدمة

  late DateTime performedAt; // متى حدثت؟
  int? odometerReading; // كم كان العداد؟

  double? cost;
  String? notes;
  String? attachmentPath; // صورة الفاتورة

  bool isSynced = false;
  DateTime createdAt = DateTime.now();

  ServiceLogModel({
    required this.uuid,
    required this.serviceId,
    required this.performedAt,
    this.odometerReading,
    this.cost,
    this.notes,
    this.attachmentPath,
    this.isSynced = false,
  });
}
