import '../../data/models/dhikr_model.dart';

abstract class DhikrState {}

class DhikrInitial extends DhikrState {}

class DhikrLoading extends DhikrState {}

class DhikrLoaded extends DhikrState {
  final List<DhikrModel> athkar;
  final int currentIndex;
  final DhikrCategory category;

  DhikrLoaded(this.athkar, {this.currentIndex = 0, required this.category});

  DhikrModel get currentDhikr => athkar[currentIndex];
  bool get isLast => currentIndex == athkar.length - 1;
  double get progress =>
      (currentIndex + (currentDhikr.currentCount / currentDhikr.count)) /
      athkar.length;
}

class DhikrComplete extends DhikrState {
  final DhikrCategory category;
  final int completedCount;
  final Duration duration;

  DhikrComplete({
    required this.category,
    required this.completedCount,
    required this.duration,
  });
}

class DhikrError extends DhikrState {
  final String message;
  DhikrError(this.message);
}
