import 'dart:async';
import 'package:athar/features/focus/presentation/cubit/focus_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/ticker.dart';
import '../../data/repositories/focus_repository.dart';

// --- Cubit ---
@injectable // لا تنس هذا لتسجيله
class FocusCubit extends Cubit<FocusState> {
  final Ticker _ticker;
  final FocusRepository _repository; // <--- إضافة المستودع
  StreamSubscription<int>? _tickerSubscription;

  // المدة الافتراضية: 25 دقيقة (1500 ثانية)
  static const int _defaultDuration = 25 * 60;
  //  25 * 60;

  FocusCubit(this._repository)
    : _ticker = const Ticker(),
      super(const FocusInitial(_defaultDuration));

  void startTimer() {
    // إذا بدأنا، نستخدم الوقت الحالي في الحالة، وإذا كان منتهياً نبدأ من جديد
    int duration = state.duration == 0 ? _defaultDuration : state.duration;

    emit(FocusRunning(duration));

    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: duration).listen((duration) {
      if (duration > 0) {
        emit(FocusRunning(duration));
      } else {
        // --- التعديل هنا: انتهى الوقت ---
        _completeSession();
        emit(const FocusCompleted());
        _tickerSubscription?.cancel();
      }
    });
  }

  // دالة لحفظ الجلسة
  Future<void> _completeSession() async {
    // نحفظ المدة الأصلية (25 دقيقة)
    // await _repository.saveSession(25 * 60);
    await _repository.saveSession(_defaultDuration);
  }

  void pauseTimer() {
    if (state is FocusRunning) {
      _tickerSubscription?.pause();
      emit(FocusPaused(state.duration));
    }
  }

  void resumeTimer() {
    if (state is FocusPaused) {
      _tickerSubscription?.resume();
      emit(FocusRunning(state.duration));
    }
  }

  void resetTimer() {
    _tickerSubscription?.cancel();
    emit(const FocusInitial(_defaultDuration));
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
