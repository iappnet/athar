abstract class SyncRepository {
  /// بدء عملية المزامنة الكاملة — returns the number of item-level conflicts resolved.
  Future<int> syncEverything();
}

class SyncSkippedException implements Exception {
  final String reason;
  SyncSkippedException(this.reason);
  @override
  String toString() => reason;
}
