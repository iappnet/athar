import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../features/focus/data/repositories/focus_repository.dart';
import 'stats_state.dart'; // استيراد ملف الحالة المنفصل

@injectable
class StatsCubit extends Cubit<StatsState> {
  final FocusRepository _focusRepository;

  StatsCubit(this._focusRepository) : super(const StatsInitial());

  void loadStats() async {
    emit(const StatsLoading());
    try {
      final weeklyData = await _focusRepository.getLast7DaysFocus();
      emit(StatsLoaded(weeklyData));
    } catch (e) {
      if (isClosed) return;
      emit(const StatsError("فشل تحميل الإحصائيات"));
    }
  }
}
