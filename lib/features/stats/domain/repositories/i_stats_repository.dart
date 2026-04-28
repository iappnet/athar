import 'package:athar/features/stats/domain/models/stats_data.dart';

abstract class IStatsRepository {
  Future<StatsData> getStats({required int rangeDays, required String userId});

  /// Clears the in-memory TTL cache so the next [getStats] call recomputes
  /// from Isar. Call after any mutation that affects stats (task/habit toggle).
  void invalidateCache();
}
