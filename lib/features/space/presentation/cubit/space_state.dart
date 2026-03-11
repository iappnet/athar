import '../../data/models/space_model.dart';

// --- States ---
abstract class SpaceState {}

class SpaceInitial extends SpaceState {}

class SpaceLoading extends SpaceState {}

class SpaceLoaded extends SpaceState {
  final List<SpaceModel> spaces;
  final SpaceModel? selectedSpace; // المساحة النشطة حالياً

  SpaceLoaded(this.spaces, {this.selectedSpace});
}

class SpaceError extends SpaceState {
  final String message;
  SpaceError(this.message);
}
