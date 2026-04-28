import 'package:athar/features/space/data/models/invitation_model.dart';
import 'package:athar/features/space/domain/repositories/invitation_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

// --- States ---
abstract class InboxState {}

class InboxInitial extends InboxState {}

class InboxLoading extends InboxState {}

class InboxLoaded extends InboxState {
  final List<InvitationModel> invitations;
  InboxLoaded(this.invitations);
}

class InboxEmpty extends InboxState {}

class InboxError extends InboxState {
  final String message;
  InboxError(this.message);
}

class InboxAcceptSuccess extends InboxState {
  final String spaceName;
  InboxAcceptSuccess(this.spaceName);
}

class InboxRejectSuccess extends InboxState {}

// --- Cubit ---
@injectable
class InboxCubit extends Cubit<InboxState> {
  final InvitationRepository _repository;

  InboxCubit(this._repository) : super(InboxInitial());

  Future<void> loadInvites() async {
    emit(InboxLoading());
    try {
      final invites = await _repository.getMyPendingInvites();
      if (invites.isEmpty) {
        emit(InboxEmpty());
      } else {
        emit(InboxLoaded(invites));
      }
    } catch (e) {
      emit(InboxError('فشل تحميل الدعوات'));
    }
  }

  Future<void> acceptInvite(String token, String spaceName) async {
    try {
      await _repository.acceptInvite(token);
      emit(InboxAcceptSuccess(spaceName));
      await loadInvites();
    } catch (e) {
      emit(InboxError('فشل قبول الدعوة'));
      await loadInvites();
    }
  }

  Future<void> rejectInvite(String token) async {
    try {
      await _repository.rejectInvite(token);
      emit(InboxRejectSuccess());
      await loadInvites();
    } catch (e) {
      emit(InboxError('فشل رفض الدعوة'));
      await loadInvites();
    }
  }
}
