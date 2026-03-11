import 'package:isar/isar.dart';

part 'space_member_model.g.dart';

@Collection()
class SpaceMemberModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid; // ID من Supabase (space_member.id)

  @Index()
  late String spaceId;

  @Index()
  late String userId;

  late String role; // 'owner', 'admin', 'member'

  DateTime? joinedAt;

  // بيانات العرض (سنملؤها عند الجلب من البروفايل)
  String? tempDisplayName;
  String? tempAvatarUrl;

  bool isSynced = false;
}
