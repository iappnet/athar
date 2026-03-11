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

// --- Cubit ---
@injectable
class InboxCubit extends Cubit<InboxState> {
  final InvitationRepository _repository;

  InboxCubit(this._repository) : super(InboxInitial());

  // تحميل الدعوات
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
      emit(InboxError("فشل تحميل الدعوات"));
    }
  }

  // قبول الدعوة
  Future<void> acceptInvite(String token) async {
    // نُظهر تحميل مؤقت (أو نبقي القائمة ونظهر مؤشر loading)
    // للتبسيط، سنبقي الحالة الحالية ونعيد التحميل بعد النجاح
    try {
      await _repository.acceptInvite(token);
      // بعد القبول، نعيد تحميل القائمة لإزالة الدعوة المقبولة
      await loadInvites();
    } catch (e) {
      // يمكن إرسال SnackBar من الـ UI عبر BlocListener
      // هنا سنعيد تحميل القائمة فقط
      loadInvites();
    }
  }
}
