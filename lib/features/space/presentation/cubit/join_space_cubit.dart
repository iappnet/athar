import 'package:athar/features/space/domain/repositories/invitation_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

abstract class JoinSpaceState {}

class JoinSpaceInitial extends JoinSpaceState {}

class JoinSpaceLoading extends JoinSpaceState {}

class JoinSpaceSuccess extends JoinSpaceState {}

class JoinSpaceError extends JoinSpaceState {
  final String message;
  JoinSpaceError(this.message);
}

@injectable
class JoinSpaceCubit extends Cubit<JoinSpaceState> {
  final InvitationRepository _invitationRepository;

  JoinSpaceCubit(this._invitationRepository) : super(JoinSpaceInitial());

  Future<void> joinSpace(String token) async {
    emit(JoinSpaceLoading());
    try {
      await _invitationRepository.acceptInvite(token);
      emit(JoinSpaceSuccess());
    } catch (e) {
      emit(
        JoinSpaceError('حدث خطأ أثناء قبول الدعوة أو أن الرابط منتهي الصلاحية'),
      );
    }
  }
}
