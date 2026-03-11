import 'package:isar/isar.dart';

part 'module_permission_model.g.dart';

@Collection()
class ModulePermissionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String moduleId;

  @Index()
  late String userId;

  late String role; // 'admin', 'viewer'

  bool isSynced = false;
}
