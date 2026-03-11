import 'package:athar/features/health/domain/repositories/health_repository.dart';
import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/features/health/data/models/health_profile_model.dart';
import 'package:athar/features/health/data/models/medicine_log_model.dart';
import 'package:athar/features/health/data/models/medicine_model.dart';
import 'package:athar/features/health/data/models/vital_sign_model.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

@LazySingleton(as: HealthRepository)
class HealthRepositoryImpl implements HealthRepository {
  final Isar _isar;

  HealthRepositoryImpl(this._isar);

  // ===========================================================================
  // 1. الملف الشخصي
  // ===========================================================================
  @override
  Future<HealthProfileModel?> getProfile(String moduleId) async {
    return await _isar.healthProfileModels
        .filter()
        .moduleIdEqualTo(moduleId)
        .findFirst();
  }

  @override
  Future<void> saveProfile(HealthProfileModel profile) async {
    await _isar.writeTxn(() async {
      profile.updatedAt = DateTime.now();
      await _isar.healthProfileModels.put(profile);
    });
  }

  // ===========================================================================
  // 2. الأدوية
  // ===========================================================================
  @override
  Stream<List<MedicineModel>> watchMedicines(String moduleId) {
    return _isar.medicineModels
        .filter()
        .moduleIdEqualTo(moduleId)
        // نعرض الأدوية النشطة أولاً
        .sortByIsActiveDesc()
        .thenByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  /// ✅ الإضافة الجديدة
  @override
  Future<List<MedicineModel>> getAllActiveMedicines() async {
    return await _isar.medicineModels.filter().isActiveEqualTo(true).findAll();
  }

  @override
  Future<void> addMedicine(MedicineModel medicine) async {
    await _isar.writeTxn(() async {
      await _isar.medicineModels.put(medicine);
    });
  }

  @override
  Future<void> updateMedicine(MedicineModel medicine) async {
    await _isar.writeTxn(() async {
      await _isar.medicineModels.put(medicine);
    });
  }

  @override
  Future<void> deleteMedicine(int id) async {
    await _isar.writeTxn(() async {
      await _isar.medicineModels.delete(id);
    });
  }

  // ===========================================================================
  // 3. سجلات الأدوية (الذكاء في التوقيت)
  // ===========================================================================
  @override
  Future<MedicineLogModel?> getLastLogForMedicine(String medicineUuid) async {
    // نجلب آخر جرعة تم أخذها لحساب الموعد القادم
    return await _isar.medicineLogModels
        .filter()
        .medicineIdEqualTo(medicineUuid)
        .sortByTakenAtDesc()
        .findFirst();
  }

  @override
  Future<void> logDose(MedicineLogModel log) async {
    await _isar.writeTxn(() async {
      await _isar.medicineLogModels.put(log);

      // اختيارياً: يمكننا هنا إنقاص المخزون من الدواء الأصلي
      final medicine = await _isar.medicineModels
          .filter()
          .uuidEqualTo(log.medicineId)
          .findFirst();

      if (medicine != null && medicine.stockQuantity != null) {
        medicine.stockQuantity = (medicine.stockQuantity! - 1).clamp(0, 9999);
        await _isar.medicineModels.put(medicine);
      }
    });
  }

  // ===========================================================================
  // 4. المواعيد
  // ===========================================================================
  @override
  Stream<List<AppointmentModel>> watchAppointments(String moduleId) {
    return _isar.appointmentModels
        .filter()
        .moduleIdEqualTo(moduleId)
        .sortByAppointmentDate() // الأقرب فالأبعد
        .watch(fireImmediately: true);
  }

  @override
  Future<void> addAppointment(AppointmentModel appointment) async {
    await _isar.writeTxn(() async {
      await _isar.appointmentModels.put(appointment);
    });
  }

  @override
  Future<void> updateAppointment(AppointmentModel appointment) async {
    await _isar.writeTxn(() async {
      await _isar.appointmentModels.put(appointment);
    });
  }

  @override
  Future<void> deleteAppointment(int id) async {
    await _isar.writeTxn(() async {
      await _isar.appointmentModels.delete(id);
    });
  }

  @override
  Future<List<AppointmentModel>> getUpcomingAppointments() async {
    final now = DateTime.now();

    return await _isar.appointmentModels
        .filter()
        .appointmentDateGreaterThan(now)
        .and()
        .statusEqualTo('upcoming')
        .findAll();
  }

  @override
  Future<List<AppointmentModel>> getAppointmentsWithReminders() async {
    final now = DateTime.now();

    return await _isar.appointmentModels
        .filter()
        .reminderTimeIsNotNull()
        .and()
        .reminderEnabledEqualTo(true)
        .and()
        .appointmentDateGreaterThan(now)
        .and()
        .statusEqualTo('upcoming')
        .findAll();
  }

  // ===========================================================================
  // 5. المؤشرات والأرشيف
  // ===========================================================================
  @override
  Stream<List<VitalSignModel>> watchVitals(String moduleId) {
    return _isar.vitalSignModels
        .filter()
        .moduleIdEqualTo(moduleId)
        .sortByRecordDateDesc() // الأحدث في الأعلى
        .watch(fireImmediately: true);
  }

  @override
  Future<void> addVital(VitalSignModel vital) async {
    await _isar.writeTxn(() async {
      await _isar.vitalSignModels.put(vital);
    });
  }
}
