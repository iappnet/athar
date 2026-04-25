import 'dart:async';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/iam/permission_service.dart';
import 'package:athar/features/space/data/models/dto/search_result_dto.dart';
import 'package:athar/features/space/data/models/invitation_model.dart';
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
  final String query;
  SpaceMembersSearchResults(this.results, {required this.query});
}

class SpaceMembersInviteSent extends SpaceMembersState {
  final String userName;
  SpaceMembersInviteSent(this.userName);
}

class SpacePendingInvitationsLoaded extends SpaceMembersState {
  final List<InvitationModel> invitations;
  SpacePendingInvitationsLoaded(this.invitations);
}

class SpaceMembersError extends SpaceMembersState {
  final String message;
  SpaceMembersError(this.message);
}

@injectable
class SpaceMembersCubit extends Cubit<SpaceMembersState> {
  final SpaceMemberRepository _memberRepository;
  final InvitationRepository _invitationRepository;
  final PermissionService _permissionService;
  StreamSubscription? _subscription;
  String? _currentSpaceId;
  List<SpaceMemberModel> _lastMembers = const [];
  bool _lastIsAdmin = false;

  SpaceMembersCubit(
    this._memberRepository,
    this._invitationRepository,
    this._permissionService,
  ) : super(SpaceMembersInitial());

  List<SpaceMemberModel> get lastMembers => _lastMembers;
  bool get lastIsAdmin => _lastIsAdmin;

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
      _lastIsAdmin = isAdmin;

      _subscription = _memberRepository
          .watchSpaceMembers(spaceId)
          .listen(
            (members) {
              _lastMembers = members;
              emit(SpaceMembersLoaded(members, isAdmin: isAdmin));
            },
            onError: (error) {
              emit(SpaceMembersError(error.toString()));
            },
          );
    } catch (e) {
      emit(SpaceMembersError(e.toString()));
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
      await _memberRepository.removeMember(_currentSpaceId!, userId);
      getIt<PermissionService>().refreshPermissions(_currentSpaceId!);
      loadMembers(_currentSpaceId!);
    } catch (e) {
      emit(SpaceMembersError(e.toString()));
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
      emit(SpaceMembersError(e.toString()));
    }
  }

  // البحث عن عضو جديد
  Future<void> searchUser(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.length < 3) {
      emit(SpaceMembersSearchResults(const [], query: normalizedQuery));
      return;
    }

    emit(SpaceMembersSearching());
    try {
      final existingMemberIds = _lastMembers
          .map((member) => member.userId)
          .toSet();
      final currentUserId = _permissionService.currentUserId;
      final results = await _invitationRepository.searchUsers(normalizedQuery);
      final filtered = results.where((user) {
        if (user.uuid.isEmpty) return false;
        if (user.uuid == currentUserId) return false;
        if (existingMemberIds.contains(user.uuid)) return false;
        return true;
      }).toList();

      emit(SpaceMembersSearchResults(filtered, query: normalizedQuery));
    } catch (e) {
      emit(SpaceMembersError(e.toString()));
    }
  }

  Future<bool> addMember(SearchResultDto user) async {
    if (_currentSpaceId == null) return false;

    try {
      await _invitationRepository.sendDirectInvite(
        spaceId: _currentSpaceId!,
        userId: user.uuid,
        userEmail: user.email ?? '',
      );
      return true;
    } catch (e) {
      emit(SpaceMembersError(e.toString()));
      return false;
    }
  }

  Future<bool> inviteByEmail(String email) async {
    if (_currentSpaceId == null) return false;

    try {
      await _invitationRepository.sendEmailInvite(
        spaceId: _currentSpaceId!,
        email: email,
      );
      loadMembers(_currentSpaceId!);
      return true;
    } catch (e) {
      emit(SpaceMembersError(e.toString()));
      return false;
    }
  }

  Future<String?> createInviteLink() async {
    if (_currentSpaceId == null) return null;

    try {
      return await _invitationRepository.generateInviteLink(_currentSpaceId!);
    } catch (e) {
      emit(SpaceMembersError(e.toString()));
      return null;
    }
  }

  // العودة من البحث للعرض
  void cancelSearch() {
    if (_currentSpaceId != null) loadMembers(_currentSpaceId!);
  }

  Future<void> loadPendingInvitations() async {
    emit(SpaceMembersLoading());

    try {
      final invites = await _invitationRepository.getMyPendingInvites();
      emit(SpacePendingInvitationsLoaded(invites));
    } catch (e) {
      emit(SpaceMembersError(e.toString()));
    }
  }

  Future<void> acceptInvite(String token) async {
    await _invitationRepository.acceptInvite(token);
    loadPendingInvitations();
  }

  Future<void> rejectInvite(String token) async {
    await _invitationRepository.rejectInvite(token);
    loadPendingInvitations();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
