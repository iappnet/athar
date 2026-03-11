import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/features/health/data/models/health_profile_model.dart';
import 'package:athar/features/health/data/models/medicine_log_model.dart';
import 'package:athar/features/health/data/models/medicine_model.dart';
import 'package:athar/features/health/data/models/vital_sign_model.dart';

abstract class HealthRepository {
  // --- 1. الملف الشخصي (Profile) ---
  Future<HealthProfileModel?> getProfile(String moduleId);
  Future<void> saveProfile(HealthProfileModel profile);

  // --- 2. الأدوية (Medicines) ---
  Stream<List<MedicineModel>> watchMedicines(String moduleId);
  Future<List<MedicineModel>> getAllActiveMedicines(); // ✅ الإضافة الجديدة
  Future<void> addMedicine(MedicineModel medicine);
  Future<void> updateMedicine(MedicineModel medicine);
  Future<void> deleteMedicine(int id);

  // --- 3. سجلات الأدوية (Logs) ---
  // نحتاجها لحساب الموعد القادم للمضادات
  Future<MedicineLogModel?> getLastLogForMedicine(String medicineUuid);
  Future<void> logDose(MedicineLogModel log);

  // --- 4. المواعيد (Appointments) ---
  Stream<List<AppointmentModel>> watchAppointments(String moduleId);
  Future<void> addAppointment(AppointmentModel appointment);
  Future<void> updateAppointment(AppointmentModel appointment);
  Future<void> deleteAppointment(int id);

  // --- 5. المؤشرات الحيوية والأرشيف (Vitals) ---
  Stream<List<VitalSignModel>> watchVitals(String moduleId);
  Future<void> addVital(VitalSignModel vital);
  // ✅ للمواعيد القادمة
  Future<List<AppointmentModel>> getUpcomingAppointments();
  Future<List<AppointmentModel>> getAppointmentsWithReminders();
}
