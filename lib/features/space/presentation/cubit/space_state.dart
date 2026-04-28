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
  // Carried so the listener can retry creation after a successful paywall.
  final String? pendingSpaceName;
  final bool pendingIsShared;

  SpaceError(
    this.message, {
    this.pendingSpaceName,
    this.pendingIsShared = false,
  });
}
