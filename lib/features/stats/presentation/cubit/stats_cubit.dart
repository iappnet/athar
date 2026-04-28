import 'package:athar/features/stats/domain/repositories/i_stats_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'stats_state.dart';

@injectable
class StatsCubit extends Cubit<StatsState> {
  final IStatsRepository _repository;

  int _rangeDays = 7;

  StatsCubit(this._repository) : super(const StatsInitial());

  Future<void> loadStats() async {
    emit(const StatsLoading());
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final data = await _repository.getStats(
        rangeDays: _rangeDays,
        userId: userId,
      );
      if (!isClosed) emit(StatsLoaded(data: data, rangeDays: _rangeDays));
    } catch (e) {
      if (!isClosed) emit(const StatsError('فشل تحميل الإحصائيات'));
    }
  }

  void setRange(int days) {
    assert(days == 7 || days == 30, 'range must be 7 or 30');
    _rangeDays = days;
    loadStats();
  }
}
