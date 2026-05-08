abstract class SyncState {}

class SyncInitial extends SyncState {}

class SyncLoading extends SyncState {}

class SyncSuccess extends SyncState {
  final DateTime syncedAt;
  final int conflictsResolved;

  SyncSuccess({DateTime? syncedAt, this.conflictsResolved = 0})
      : syncedAt = syncedAt ?? DateTime.now();
}

class SyncOffline extends SyncState {}

class SyncError extends SyncState {
  final String message;
  SyncError(this.message);
}
