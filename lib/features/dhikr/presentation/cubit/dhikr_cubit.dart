import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:vibration/vibration.dart';
import '../../data/models/dhikr_model.dart';
import '../../data/repositories/dhikr_repository.dart';

// --- State ---
abstract class DhikrState {}

class DhikrInitial extends DhikrState {}

class DhikrLoading extends DhikrState {}

class DhikrLoaded extends DhikrState {
  final List<DhikrModel> athkar;
  final int currentIndex;

  DhikrLoaded(this.athkar, {this.currentIndex = 0});

  DhikrModel get currentDhikr => athkar[currentIndex];
  bool get isLast => currentIndex == athkar.length - 1;
  double get progress =>
      (currentIndex + (currentDhikr.currentCount / currentDhikr.count)) /
      athkar.length;
}

// --- Cubit ---
@injectable
class DhikrCubit extends Cubit<DhikrState> {
  final DhikrRepository _repository;

  DhikrCubit(this._repository) : super(DhikrInitial());

  Future<void> loadAthkar(DhikrCategory category) async {
    emit(DhikrLoading());
    await _repository.initDefaultAthkar();

    final athkar = await _repository.getAthkarByCategory(category);
    for (var d in athkar) {
      d.currentCount = 0;
    }

    emit(DhikrLoaded(athkar));
  }

  Future<void> incrementCount() async {
    if (state is DhikrLoaded) {
      final currentState = state as DhikrLoaded;
      final currentDhikr = currentState.currentDhikr;

      if (currentDhikr.currentCount < currentDhikr.count) {
        currentDhikr.currentCount++;

        if (currentDhikr.currentCount == currentDhikr.count) {
          // ✅ إصلاح: إزالة ?? false لأن المكتبة ترجع Future<bool?> أو Future<bool> حسب الإصدار
          // والتحقق الآمن
          if (await Vibration.hasVibrator() == true) {
            Vibration.vibrate(duration: 100);
          }

          if (!currentState.isLast) {
            await Future.delayed(const Duration(milliseconds: 300));
            emit(
              DhikrLoaded(
                currentState.athkar,
                currentIndex: currentState.currentIndex + 1,
              ),
            );
            return;
          }
        }

        emit(
          DhikrLoaded(
            currentState.athkar,
            currentIndex: currentState.currentIndex,
          ),
        );
      }
    }
  }

  void nextDhikr() {
    if (state is DhikrLoaded) {
      final s = state as DhikrLoaded;
      // ✅ إصلاح: إضافة الأقواس {}
      if (!s.isLast) {
        emit(DhikrLoaded(s.athkar, currentIndex: s.currentIndex + 1));
      }
    }
  }

  void previousDhikr() {
    if (state is DhikrLoaded) {
      final s = state as DhikrLoaded;
      // ✅ إصلاح: إضافة الأقواس {}
      if (s.currentIndex > 0) {
        emit(DhikrLoaded(s.athkar, currentIndex: s.currentIndex - 1));
      }
    }
  }
}
