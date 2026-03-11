import 'dart:async';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/iam/permission_service.dart';
import 'package:athar/features/space/data/models/dto/search_result_dto.dart';
import 'package:athar/features/space/data/models/space_member_model.dart';
import 'package:athar/features/space/data/repositories/space_member_repository_impl.dart';
import 'package:athar/features/space/domain/repositories/invitation_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

abstract class SpaceMembersState {}

class SpaceMembersInitial extends SpaceMembersState {}

class SpaceMembersLoading extends SpaceMembersState {}

class SpaceMembersLoaded extends SpaceMembersState {
  final List<SpaceMemberModel> members;
  final bool isAdmin;
  SpaceMembersLoaded(this.members, {this.isAdmin = false});
}

class SpaceMembersSearching extends SpaceMembersState {}

class SpaceMembersSearchResults extends SpaceMembersState {
  final List<SearchResultDto> results;
  SpaceMembersSearchResults(this.results);
}

@injectable
class SpaceMembersCubit extends Cubit<SpaceMembersState> {
  final SpaceMemberRepository _memberRepository;
  final InvitationRepository _invitationRepository;
  final PermissionService _permissionService;
  StreamSubscription? _subscription;
  String? _currentSpaceId;

  SpaceMembersCubit(
    this._memberRepository,
    this._invitationRepository,
    this._permissionService,
  ) : super(SpaceMembersInitial());

  // تحميل الأعضاء
  Future<void> loadMembers(String spaceId) async {
    _currentSpaceId = spaceId;
    emit(SpaceMembersLoading());

    _subscription?.cancel();

    try {
      final isAdmin = await _permissionService.hasPermission(
        'manage_members',
        spaceId: spaceId,
      );

      _subscription = _memberRepository.watchSpaceMembers(spaceId).listen((
        members,
      ) {
        emit(SpaceMembersLoaded(members, isAdmin: isAdmin));
      });
    } catch (e) {
      // معالجة الخطأ
    }
  }

  // ✅ 1. دالة الطرد (Kick)
  Future<void> removeMember(String userId) async {
    if (_currentSpaceId == null) return;

    // التحقق من الصلاحية قبل تنفيذ الطرد
    final canKick = await _permissionService.hasPermission(
      'manage_members',
      spaceId: _currentSpaceId!,
    );
    if (!canKick) return;

    try {
      await _memberRepository.removeMember(
        _currentSpaceId!,
        userId,
      ); // إعادة تحميل القائمة
      // ✅ إجراء أمني: تنظيف الكاش فوراً لهذا المستخدم (أو للمساحة)
      getIt<PermissionService>().refreshPermissions(_currentSpaceId!);
      loadMembers(_currentSpaceId!);
    } catch (e) {
      // emit error if needed
    }
  }

  // ✅ 2. دالة تغيير الدور (Promote/Demote)
  Future<void> changeRole(String userId, String newRole) async {
    if (_currentSpaceId == null) return;
    try {
      await _memberRepository.updateMemberRole(
        _currentSpaceId!,
        userId,
        newRole,
      );
      // ✅ الإجراء الجوهري: تنظيف كاش الصلاحيات لهذه المساحة
      getIt<PermissionService>().refreshPermissions(_currentSpaceId!);
      loadMembers(_currentSpaceId!);
    } catch (e) {
      // emit error
    }
  }

  // البحث عن عضو جديد
  Future<void> searchUser(String query) async {
    if (query.length < 3) return;
    // لا نغير الـ state الرئيسية حتى لا تختفي القائمة الخلفية،
    // يمكننا استخدام Bloc منفصل للبحث أو state فرعية، للتبسيط سنستخدم Stream أو نرجع النتائج مباشرة
    // لكن هنا سنستخدم State مخصصة للنتائج
    emit(SpaceMembersSearching());
    final results = await _invitationRepository.searchUsers(query);
    emit(SpaceMembersSearchResults(results));
  }

  // إرسال دعوة
  Future<void> inviteUser(SearchResultDto user) async {
    if (_currentSpaceId == null) return;
    await _invitationRepository.sendDirectInvite(
      spaceId: _currentSpaceId!,
      userId: user.uuid,
      userEmail: user.username, // مؤقتاً نرسل اليوزرنيم أو نبحث عن الإيميل
    );
    // العودة لقائمة الأعضاء
    loadMembers(_currentSpaceId!);
  }

  // العودة من البحث للعرض
  void cancelSearch() {
    if (_currentSpaceId != null) loadMembers(_currentSpaceId!);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
