import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:vibration/vibration.dart';
import '../../data/models/dhikr_model.dart';
import '../../data/repositories/dhikr_repository.dart';
import 'dhikr_state.dart';

export 'dhikr_state.dart';

@injectable
class DhikrCubit extends Cubit<DhikrState> {
  final DhikrRepository _repository;
  DateTime? _sessionStart;

  DhikrCubit(this._repository) : super(DhikrInitial());

  Future<void> loadAthkar(DhikrCategory category) async {
    emit(DhikrLoading());
    _sessionStart = DateTime.now();
    try {
      await _repository.initDefaultAthkar();
      final athkar = await _repository.getAthkarByCategory(category);
      for (var d in athkar) {
        d.currentCount = 0;
      }
      if (isClosed) return;
      emit(DhikrLoaded(athkar, category: category));
    } catch (e) {
      if (isClosed) return;
      emit(DhikrError("فشل تحميل الأذكار"));
    }
  }

  Future<void> incrementCount() async {
    if (state is! DhikrLoaded) return;
    final currentState = state as DhikrLoaded;
    final currentDhikr = currentState.currentDhikr;

    if (currentDhikr.currentCount >= currentDhikr.count) return;

    currentDhikr.currentCount++;

    if (currentDhikr.currentCount == currentDhikr.count) {
      if (await Vibration.hasVibrator() == true) {
        Vibration.vibrate(duration: 100);
      }

      if (!currentState.isLast) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!isClosed) {
          emit(DhikrLoaded(
            currentState.athkar,
            currentIndex: currentState.currentIndex + 1,
            category: currentState.category,
          ));
        }
        return;
      } else {
        // Last dhikr of the last item — set complete. Chokepoint for PR-ACTIVITY.
        final duration = _sessionStart != null
            ? DateTime.now().difference(_sessionStart!)
            : Duration.zero;
        emit(DhikrLoaded(
          currentState.athkar,
          currentIndex: currentState.currentIndex,
          category: currentState.category,
        ));
        await Future.delayed(const Duration(milliseconds: 400));
        if (!isClosed) {
          emit(DhikrComplete(
            category: currentState.category,
            completedCount: currentState.athkar.length,
            duration: duration,
          ));
        }
        return;
      }
    }

    emit(DhikrLoaded(
      currentState.athkar,
      currentIndex: currentState.currentIndex,
      category: currentState.category,
    ));
  }

  void nextDhikr() {
    if (state is! DhikrLoaded) return;
    final s = state as DhikrLoaded;
    if (!s.isLast) {
      emit(DhikrLoaded(s.athkar,
          currentIndex: s.currentIndex + 1, category: s.category));
    }
  }

  void previousDhikr() {
    if (state is! DhikrLoaded) return;
    final s = state as DhikrLoaded;
    if (s.currentIndex > 0) {
      emit(DhikrLoaded(s.athkar,
          currentIndex: s.currentIndex - 1, category: s.category));
    }
  }

  void reset() {
    if (state is! DhikrLoaded) return;
    final s = state as DhikrLoaded;
    for (var d in s.athkar) {
      d.currentCount = 0;
    }
    _sessionStart = DateTime.now();
    emit(DhikrLoaded(s.athkar, currentIndex: 0, category: s.category));
  }
}
