// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:athar/core/services/appointment_notification_scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:athar/core/iam/permission_service.dart';
import 'package:athar/core/services/automation_service.dart';
import 'package:athar/core/services/medication_notification_scheduler.dart';
import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/features/health/data/models/health_profile_model.dart';
import 'package:athar/features/health/data/models/medicine_log_model.dart';
import 'package:athar/features/health/data/models/medicine_model.dart';
import 'package:athar/features/health/data/models/vital_sign_model.dart';
import 'package:athar/features/health/domain/repositories/health_repository.dart';
import 'package:athar/features/health/presentation/cubit/health_state.dart';
import 'package:athar/features/space/data/models/module_model.dart';

@injectable
class HealthCubit extends Cubit<HealthState> {
  final HealthRepository _repository;
  final PermissionService _permissionService;
  final AutomationService _automationService;
  final MedicationNotificationScheduler _medicationScheduler;
  final AppointmentNotificationScheduler _appointmentScheduler;

  StreamSubscription? _medicinesSubscription;
  ModuleModel? _currentModule;

  HealthCubit(
    this._repository,
    this._permissionService,
    this._automationService,
    this._medicationScheduler,
    this._appointmentScheduler,
  ) : super(HealthInitial());

  // دالة مساعدة لتحديث السياق (يستدعيها UI عند الدخول)
  void setContext(ModuleModel? module) {
    _currentModule = module;
  }

  // ✅ دالة موحدة لتحديث كافة بيانات القسم (تستخدم لإعادة التحميل بعد العمليات)
  void loadHealthData(String moduleId) {
    loadProfile(moduleId);
    subscribeToMedicines(moduleId);
  }

  // ===========================================================================
  // 1. إدارة البروفايل
  Future<void> loadProfile(String moduleId) async {
    emit(HealthLoading());
    try {
      final profile = await _repository.getProfile(moduleId);
      emit(HealthProfileLoaded(profile));
    } catch (e) {
      emit(HealthError("فشل تحميل الملف الصحي"));
    }
  }

  Future<void> updateProfile(HealthProfileModel profile) async {
    final canUpdate = await _permissionService.hasPermission(
      'update',
      spaceId: _currentModule?.spaceId,
      resourceType: 'health_core',
      module: _currentModule,
    );

    if (!canUpdate) {
      emit(HealthError("عذراً، لا تملك صلاحية تعديل الملف الطبي 🚫"));
      emit(HealthProfileLoaded(profile));
      return;
    }

    try {
      await _repository.saveProfile(profile);
      emit(HealthProfileLoaded(profile));
      emit(HealthOperationSuccess("تم حفظ الملف بنجاح"));
    } catch (e) {
      emit(HealthError("فشل حفظ الملف"));
    }
  }

  // ===========================================================================
  // 2. إدارة الأدوية
  void subscribeToMedicines(String moduleId) {
    emit(HealthLoading());
    _medicinesSubscription?.cancel();

    _medicinesSubscription = _repository
        .watchMedicines(moduleId)
        .listen(
          (medicines) {
            emit(HealthMedicinesLoaded(medicines));
            Future.microtask(() => _checkAutoArchiving(List.from(medicines)));
          },
          onError: (error) {
            emit(HealthError("فشل تحميل الأدوية"));
          },
        );
  }

  Future<void> _checkAutoArchiving(List<MedicineModel> medicines) async {
    final now = DateTime.now();
    // bool needsUpdate = false;

    for (var medicine in medicines) {
      if (!medicine.isActive) continue;

      bool shouldArchive = false;
      DateTime? endDate = medicine.treatmentEndDate;
      if (endDate == null &&
          medicine.startDate != null &&
          medicine.courseDurationDays != null) {
        endDate = medicine.startDate!.add(
          Duration(days: medicine.courseDurationDays!),
        );
      }

      if (endDate != null && now.isAfter(endDate)) {
        shouldArchive = true;
      }

      if (medicine.stockQuantity != null && medicine.stockQuantity! <= 0) {
        shouldArchive = true;
      }

      if (shouldArchive) {
        medicine.isActive = false;
        await _repository.updateMedicine(medicine);
        // needsUpdate = true;
      }
    }
  }

  Stream<List<MedicineModel>> watchMedicines(String moduleId) {
    return _repository.watchMedicines(moduleId);
  }

  Future<void> addMedicine(MedicineModel medicine) async {
    medicine.createdBy = Supabase.instance.client.auth.currentUser?.id;

    final canCreate = await _permissionService.hasPermission(
      'create',
      spaceId: _currentModule?.spaceId,
      resourceType: 'health_core',
      module: _currentModule,
    );

    if (!canCreate) {
      emit(HealthError("لا تملك صلاحية إضافة دواء جديد"));
      return;
    }

    try {
      await _repository.addMedicine(medicine);
      // ✅ جدولة تنبيهات الدواء الجديد
      await _medicationScheduler.scheduleMedicine(medicine);
      emit(HealthOperationSuccess("تم إضافة الدواء وجدولة التنبيهات"));
    } catch (e) {
      emit(HealthError("فشل إضافة الدواء"));
    }
  }

  Future<void> updateMedicine(MedicineModel medicine) async {
    final canUpdate = await _permissionService.hasPermission(
      'update',
      spaceId: _currentModule?.spaceId,
      resourceType: 'health_core',
      module: _currentModule,
      resourceOwnerId: medicine.createdBy,
    );

    if (!canUpdate) {
      emit(HealthError("لا تملك صلاحية تعديل هذا الدواء"));
      return;
    }

    try {
      await _repository.updateMedicine(medicine);
      // ✅ إعادة جدولة التنبيهات (إلغاء القديم وجدولة الجديد)
      // await _medicationScheduler.cancelMedication(medicine.uuid);
      await _medicationScheduler.cancelMedicine(medicine.uuid);
      if (medicine.isActive) {
        await _medicationScheduler.scheduleMedicine(medicine);
      }
      emit(HealthOperationSuccess("تم تحديث بيانات الدواء"));
    } catch (e) {
      emit(HealthError("فشل تحديث الدواء"));
    }
  }

  Future<void> deleteMedicine(MedicineModel medicine) async {
    final canDelete = await _permissionService.hasPermission(
      'delete',
      spaceId: _currentModule?.spaceId,
      resourceType: 'health_core',
      module: _currentModule,
      resourceOwnerId: medicine.createdBy,
    );

    if (!canDelete) {
      emit(HealthError("لا تملك صلاحية حذف هذا الدواء"));
      return;
    }

    await _medicationScheduler.cancelMedication(medicine.uuid);
    await _repository.deleteMedicine(medicine.id);
    emit(HealthOperationSuccess("تم حذف الدواء"));
  }

  // ===========================================================================
  // 3. الجرعات والأتمتة
  Future<void> takeDose(String moduleId, MedicineModel medicine) async {
    final canOperate = await _permissionService.hasPermission(
      'create',
      spaceId: _currentModule?.spaceId,
      resourceType: 'health_op',
      module: _currentModule,
    );

    if (!canOperate) {
      emit(HealthError("غير مصرح بتسجيل الجرعات"));
      return;
    }

    try {
      final log = MedicineLogModel(
        uuid: const Uuid().v4(),
        medicineId: medicine.uuid,
        moduleId: moduleId,
        takenAt: DateTime.now(),
        status: 'taken',
      );

      await _repository.logDose(log);

      // ✅ الفحص الديناميكي للأتمتة
      if (medicine.autoRefillMode == 'quantity') {
        double currentStock = (medicine.stockQuantity ?? 0);

        if (currentStock <= medicine.refillThreshold && currentStock > 0) {
          if (!medicine.isRefillRequested) {
            final userId =
                Supabase.instance.client.auth.currentUser?.id ?? 'guest';
            await _automationService.triggerMedicineRefill(medicine, userId);
            medicine.isRefillRequested = true;
            await _repository.updateMedicine(medicine);
          }
        }
      }
    } catch (e) {
      emit(HealthError("فشل تسجيل الجرعة"));
    }
  }

  Future<MedicineLogModel?> getLastLog(String medicineUuid) {
    return _repository.getLastLogForMedicine(medicineUuid);
  }

  // ===========================================================================
  // 4. المواعيد (كاملة مع التنبيهات)
  Stream<List<AppointmentModel>> watchAppointments(String moduleId) {
    return _repository.watchAppointments(moduleId);
  }

  Future<void> addAppointment(AppointmentModel appointment) async {
    appointment.createdBy = Supabase.instance.client.auth.currentUser?.id;

    final canCreate = await _permissionService.hasPermission(
      'create',
      spaceId: _currentModule?.spaceId,
      resourceType: 'health_core',
      module: _currentModule,
    );

    if (!canCreate) {
      emit(HealthError("لا تملك صلاحية إضافة موعد"));
      return;
    }

    try {
      await _repository.addAppointment(appointment);

      // ✅ جدولة الإشعار للموعد الجديد
      if (appointment.reminderEnabled && appointment.reminderTime != null) {
        await _appointmentScheduler.scheduleAppointment(appointment);
      }

      emit(HealthOperationSuccess("تم حجز الموعد"));
      loadHealthData(appointment.moduleId); // تحديث القائمة
    } catch (e) {
      emit(HealthError("فشل حفظ الموعد"));
    }
  }

  Future<void> updateAppointment(AppointmentModel appointment) async {
    final canUpdate = await _permissionService.hasPermission(
      'update',
      spaceId: _currentModule?.spaceId,
      resourceType: 'health_core',
      module: _currentModule,
      resourceOwnerId: appointment.createdBy,
    );

    if (!canUpdate) {
      emit(HealthError("عذراً، لا تملك صلاحية تعديل هذا الموعد 🚫"));
      return;
    }

    try {
      emit(HealthLoading());
      await _repository.updateAppointment(appointment);

      // ✅ إعادة جدولة التذكير (إلغاء القديم وجدولة الجديد)
      await _appointmentScheduler.cancelAppointment(appointment.uuid);
      if (appointment.reminderEnabled && appointment.reminderTime != null) {
        await _appointmentScheduler.scheduleAppointment(appointment);
      }

      emit(HealthOperationSuccess("تم تحديث الموعد"));
      loadHealthData(appointment.moduleId);
    } catch (e) {
      emit(HealthError("فشل تحديث الموعد"));
    }
  }

  Future<void> deleteAppointment(AppointmentModel appointment) async {
    final canDelete = await _permissionService.hasPermission(
      'delete',
      spaceId: _currentModule?.spaceId,
      resourceType: 'health_core',
      module: _currentModule,
      resourceOwnerId: appointment.createdBy,
    );

    if (!canDelete) {
      emit(HealthError("لا تملك صلاحية حذف هذا الموعد"));
      return;
    }

    try {
      // ✅ إلغاء التذكير قبل الحذف
      await _appointmentScheduler.cancelAppointment(appointment.uuid);
      await _repository.deleteAppointment(appointment.id);
      emit(HealthOperationSuccess("تم حذف الموعد"));
    } catch (e) {
      emit(HealthError("فشل حذف الموعد"));
    }
  }

  // ===========================================================================
  // 5. المؤشرات الحيوية
  Stream<List<VitalSignModel>> watchVitals(String moduleId) {
    return _repository.watchVitals(moduleId);
  }

  Future<void> addVital(VitalSignModel vital) async {
    try {
      await _repository.addVital(vital);
      emit(HealthOperationSuccess("تم تسجيل القراءة"));
    } catch (e) {
      emit(HealthError("فشل تسجيل القراءة"));
    }
  }

  @override
  Future<void> close() {
    _medicinesSubscription?.cancel();
    return super.close();
  }

  @override
  String toString() {
    return 'HealthCubit(_repository: $_repository, _permissionService: $_permissionService, _automationService: $_automationService, _medicationScheduler: $_medicationScheduler, _appointmentScheduler: $_appointmentScheduler, _medicinesSubscription: $_medicinesSubscription, _currentModule: $_currentModule)';
  }
}
