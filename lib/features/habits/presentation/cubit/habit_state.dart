import 'package:equatable/equatable.dart';
import '../../data/models/habit_model.dart';

abstract class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object> get props => [];
}

class HabitInitial extends HabitState {}

class HabitLoading extends HabitState {}

class HabitLoaded extends HabitState {
  final List<HabitModel> habits; // القائمة الخام (للتوافق)

  // ✅ القوائم المصنفة (الجديد)
  final List<HabitModel> cardAthkar; // للبطاقات العلوية (الأذكار المستقلة)
  // final List<HabitModel> morningHabits; // قائمة الصباح
  // final List<HabitModel> prodHabits; // قائمة الإنتاجية (الظهر/العصر)
  // final List<HabitModel> eveningHabits; // قائمة المساء
  // final List<HabitModel> completedHabits; // للمنجزات (اختياري)

  final List<HabitModel> dawnHabits; // الفجر
  final List<HabitModel> bakurHabits; // البكور
  final List<HabitModel> morningHabits; // الصباح (والضحى)
  final List<HabitModel> noonHabits; // الظهيرة
  final List<HabitModel> afternoonHabits; // العصر
  final List<HabitModel> maghribHabits; // المغرب
  final List<HabitModel> ishaHabits; // العشاء
  final List<HabitModel> nightHabits; // الليل
  final List<HabitModel> lastThirdHabits; // السحر
  final List<HabitModel> anyTimeHabits; // مرن

  const HabitLoaded(
    this.habits, {
    this.cardAthkar = const [],
    this.dawnHabits = const [],
    this.bakurHabits = const [],
    this.morningHabits = const [],
    this.noonHabits = const [],
    this.afternoonHabits = const [],
    this.maghribHabits = const [],
    this.ishaHabits = const [],
    this.nightHabits = const [],
    this.lastThirdHabits = const [],
    this.anyTimeHabits = const [],
  });

  @override
  List<Object> get props => [
    habits,
    cardAthkar,
    dawnHabits,
    bakurHabits,
    morningHabits,
    noonHabits,
    afternoonHabits,
    maghribHabits,
    ishaHabits,
    nightHabits,
    lastThirdHabits,
    anyTimeHabits,
  ];
}

class HabitError extends HabitState {
  final String message;

  const HabitError(this.message);

  @override
  List<Object> get props => [message];
}

/// Emitted when a free user tries to create a habit beyond the free limit.
class HabitFreeLimitReached extends HabitState {}
