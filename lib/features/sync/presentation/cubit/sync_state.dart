abstract class SyncState {}

class SyncInitial extends SyncState {}

class SyncLoading extends SyncState {}

class SyncSuccess extends SyncState {}

class SyncError extends SyncState {
  final String message;
  SyncError(this.message);
}
