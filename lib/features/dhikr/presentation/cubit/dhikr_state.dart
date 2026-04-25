import '../../data/models/dhikr_model.dart';

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

class DhikrError extends DhikrState {
  final String message;
  DhikrError(this.message);
}
