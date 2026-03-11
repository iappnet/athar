import 'package:athar/features/health/data/models/health_profile_model.dart';
import 'package:athar/features/health/data/models/medicine_model.dart'; // ✅ إضافة استيراد الموديل

abstract class HealthState {}

class HealthInitial extends HealthState {}

class HealthLoading extends HealthState {}

class HealthProfileLoaded extends HealthState {
  final HealthProfileModel? profile;
  HealthProfileLoaded(this.profile);
}

// ✅ حالة جديدة: تم تحميل الأدوية
class HealthMedicinesLoaded extends HealthState {
  final List<MedicineModel> medicines;
  HealthMedicinesLoaded(this.medicines);
}

class HealthOperationSuccess extends HealthState {
  final String message;
  HealthOperationSuccess(this.message);
}

class HealthError extends HealthState {
  final String message;
  HealthError(this.message);
}
