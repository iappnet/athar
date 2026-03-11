abstract class SyncRepository {
  /// بدء عملية المزامنة الكاملة (مهام وعادات)
  Future<void> syncEverything();
}

class SyncSkippedException implements Exception {
  final String reason;
  SyncSkippedException(this.reason);
  @override
  String toString() => reason;
}
