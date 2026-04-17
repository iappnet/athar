import 'package:athar/features/space/data/models/dto/search_result_dto.dart';
import 'package:athar/features/space/data/models/invitation_model.dart';

abstract class InvitationRepository {
  /// البحث عن مستخدمين (آمن)
  Future<List<SearchResultDto>> searchUsers(String query);

  /// إرسال دعوة مباشرة لمستخدم
  Future<void> sendDirectInvite({
    required String spaceId,
    required String userId,
    required String userEmail,
  });

  /// إنشاء رابط دعوة جديد
  Future<String> generateInviteLink(String spaceId);

  /// جلب الدعوات المعلقة (لي كمستخدم)
  Future<List<InvitationModel>> getMyPendingInvites();

  Future<void> rejectInvite(String token);

  /// قبول دعوة
  Future<void> acceptInvite(String token);
}
