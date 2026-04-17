import 'package:isar/isar.dart';

part 'invitation_model.g.dart';

enum InvitationStatus { pending, accepted, rejected, expired }

@Collection()
class InvitationModel {
  Id id = Isar.autoIncrement; // محلي

  @Index(unique: true, replace: true)
  late String uuid; // من Supabase

  @Index()
  late String spaceId;

  String? inviterId; // من أرسل الدعوة
  String? inviteeEmail; // لمن أرسلت (في حال المباشرة)

  @Index()
  late String token; // رمز الدعوة الفريد

  late String type; // 'link' or 'direct_user'

  @Index()
  // String status = 'pending'; // 'pending', 'accepted', 'expired'
  late String status;

  @ignore
  InvitationStatus get statusEnum {
    switch (status) {
      case 'accepted':
        return InvitationStatus.accepted;
      case 'rejected':
        return InvitationStatus.rejected;
      case 'expired':
        return InvitationStatus.expired;
      default:
        return InvitationStatus.pending;
    }
  }

  set statusEnum(InvitationStatus value) {
    status = value.name;
  }

  DateTime? expiresAt;
  DateTime? createdAt;

  String? spaceName;
  int? spaceColor;
  String? inviterName;
  String? inviterAvatar;

  bool isSynced = false;

  InvitationModel();

  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel()
      ..uuid = json['uuid']
      ..spaceId = json['space_id']
      ..inviterId = json['inviter_id']
      ..inviteeEmail = json['invitee_email']
      ..token = json['token']
      ..type = json['type'] ?? 'direct_user'
      ..status = json['status'] ?? 'pending'
      ..spaceName =
          json['space_name'] // ✅
      ..spaceColor =
          json['space_color'] // ✅
      ..inviterName =
          json['inviter_name'] // ✅
      ..inviterAvatar =
          json['inviter_avatar'] // ✅
      ..expiresAt = json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null
      ..createdAt = json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null
      ..isSynced = true;
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'space_id': spaceId,
      'inviter_id': inviterId,
      'invitee_email': inviteeEmail,
      'token': token,
      'type': type,
      'status': status,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
