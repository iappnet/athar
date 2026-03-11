import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// الحالات بسيطة جداً
abstract class CelebrationState {}

class CelebrationInitial extends CelebrationState {}

class CelebrationTriggered extends CelebrationState {}

@lazySingleton // ليكون متاحاً عبر الحقن إذا احتجنا، أو عبر BlocProvider
class CelebrationCubit extends Cubit<CelebrationState> {
  CelebrationCubit() : super(CelebrationInitial());

  void celebrate() {
    // نطلق الحالة ثم نعود فوراً للوضع الطبيعي لنسمح بإطلاقها مرة أخرى
    emit(CelebrationTriggered());
    emit(CelebrationInitial());
  }
}
