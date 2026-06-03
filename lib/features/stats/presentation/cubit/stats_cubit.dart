import 'package:athar/features/stats/domain/repositories/i_stats_repository.dart';
import 'package:athar/features/stats/presentation/cubit/stats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'stats_state.dart';

@injectable
class StatsCubit extends Cubit<StatsState> {
  final IStatsRepository _repository;

  StatsPeriod _period = StatsPeriod.last7Days;
  StatsPeriod get currentPeriod => _period;

  StatsCubit(this._repository) : super(const StatsInitial());

  Future<void> loadStats() async {
    emit(StatsLoading(period: _period));
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final data = await _repository.getStats(
        rangeDays: _period.rangeDays,
        userId: userId,
      );
      if (!isClosed) emit(StatsLoaded(data: data, period: _period));
    } catch (e) {
      if (!isClosed) {
        emit(StatsError('فشل تحميل الإحصائيات', period: _period));
      }
    }
  }

  void setPeriod(StatsPeriod period) {
    if (_period == period) return;
    _period = period;
    loadStats();
  }
}
