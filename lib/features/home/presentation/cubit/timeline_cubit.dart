import 'dart:async';
import 'package:athar/core/utils/smart_zone_helper.dart';
import 'package:athar/features/health/domain/repositories/health_repository.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/task/domain/repositories/task_repository.dart';
import 'package:athar/features/health/data/models/medicine_model.dart';
import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/features/home/domain/entities/daily_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:isar/isar.dart';

abstract class TimelineState {}

class TimelineInitial extends TimelineState {}

class TimelineLoading extends TimelineState {}

class TimelineLoaded extends TimelineState {
  final List<DailyItem> items;
  final String activeZone; // للمنطقة الذكية (Work, Home...)
  final String activeFilter; // لنوع البيانات (All, Task, Med...)

  TimelineLoaded(
    this.items, {
    this.activeZone = 'free',
    this.activeFilter = 'all',
  });
}

class TimelineError extends TimelineState {
  final String message;
  TimelineError(this.message);
}

@injectable
class TimelineCubit extends Cubit<TimelineState> {
  final TaskRepository _taskRepository;
  final HealthRepository _healthRepository;
  final SettingsRepository _settingsRepository;
  final Isar _isar;

  StreamSubscription? _subscription;

  // ✅ الآن سنستخدم هذا المتغير للتحكم في الفلترة الفعلية
  String _currentFilter = 'all';

  TimelineCubit(
    this._taskRepository,
    this._healthRepository,
    this._settingsRepository,
    this._isar,
  ) : super(TimelineInitial());

  void loadDailyTimeline(String moduleId) {
    emit(TimelineLoading());
    _subscription?.cancel();

    _subscription =
        Rx.combineLatest4<
              List<TaskModel>,
              List<MedicineModel>,
              List<AppointmentModel>,
              UserSettings,
              List<DailyItem>
            >(
              _taskRepository.watchModuleTasks(moduleId).startWith([]),
              _healthRepository.watchMedicines(moduleId).startWith([]),
              _healthRepository.watchAppointments(moduleId).startWith([]),
              _settingsRepository.watchSettings(),
              (tasks, meds, appts, settings) {
                final zone = SmartZoneHelper.getCurrentZoneKey(settings);
                return _mergeAndSortWithSmartZone(tasks, meds, appts, zone);
              },
            )
            .listen((items) {
              _emitLoadedState(items);
            }, onError: (e) => emit(TimelineError("فشل تحميل الجدول الزمني")));
  }

  void loadGlobalTimeline({bool showLoading = true}) {
    if (showLoading) emit(TimelineLoading());
    _subscription?.cancel();

    _subscription =
        Rx.combineLatest4<
              List<TaskModel>,
              List<MedicineModel>,
              List<AppointmentModel>,
              UserSettings,
              List<DailyItem>
            >(
              _taskRepository.watchTasksByDate(DateTime.now()).startWith([]),
              _isar.medicineModels
                  .filter()
                  .isActiveEqualTo(true)
                  .watch(fireImmediately: true)
                  .startWith([]),
              _isar.appointmentModels
                  .filter()
                  .statusEqualTo('upcoming')
                  .watch(fireImmediately: true)
                  .startWith([]),
              _settingsRepository.watchSettings(),
              (tasks, meds, appts, settings) {
                final zone = SmartZoneHelper.getCurrentZoneKey(settings);
                return _mergeAndSortWithSmartZone(tasks, meds, appts, zone);
              },
            )
            .listen((items) {
              _emitLoadedState(items);
            }, onError: (e) => emit(TimelineError("فشل تحديث مركز العمليات")));
  }

  void setFilter(String filter) {
    if (_currentFilter == filter) return;
    _currentFilter = filter;
    loadGlobalTimeline(showLoading: false);
  }

  List<DailyItem> _mergeAndSortWithSmartZone(
    List<TaskModel> tasks,
    List<MedicineModel> meds,
    List<AppointmentModel> appts,
    String currentZone,
  ) {
    List<DailyItem> timeline = [];
    final now = DateTime.now();

    // 1. معالجة المهام
    if (_currentFilter == 'all' ||
        _currentFilter == 'task' ||
        _currentFilter == 'urgent') {
      for (var task in tasks) {
        if (task.isCompleted) continue;
        if (_currentFilter == 'urgent' && !task.isUrgent) continue;
        bool isFromCurrentZone = _checkTaskZoneMatch(task, currentZone);
        timeline.add(
          DailyItem(
            id: task.uuid,
            type: DailyItemType.task,
            time: task.date,
            title: task.title,
            subtitle: isFromCurrentZone
                ? "🎯 تركيزك الآن"
                : (task.isUrgent ? "🚨 عاجل" : null),
            isCompleted: task.isCompleted,
            hasReminder: task.reminderTime != null,
            originalData: task,
          ),
        );
      }
    }

    // 2. معالجة الأدوية (تضاف فقط إذا كان الفلتر 'all' أو 'medicine')
    if (_currentFilter == 'all' || _currentFilter == 'medicine') {
      for (var med in meds) {
        if (!med.isActive) continue;
        if (med.schedulingType == 'fixed' && med.fixedTimeSlots != null) {
          for (var timeStr in med.fixedTimeSlots!) {
            final parts = timeStr.split(':');
            final scheduledTime = DateTime(
              now.year,
              now.month,
              now.day,
              int.parse(parts[0]),
              int.parse(parts[1]),
            );
            timeline.add(
              DailyItem(
                id: "${med.uuid}_$timeStr",
                type: DailyItemType.medicine,
                time: scheduledTime,
                title: "💊 دواء: ${med.name}",
                subtitle: "${med.doseAmount ?? ''} ${med.doseUnit ?? ''}",
                isCompleted: false, // يمكن تحديثه من سجل الجرعات
                hasReminder: true, // ✅ الأدوية دائماً لها تذكير (لأنها مجدولة)
                originalData: med,
              ),
            );
          }
        }
        // ✅ إضافة: معالجة الأدوية بنظام الفترات (interval)
        else if (med.schedulingType == 'interval' &&
            med.intervalHours != null) {
          // حساب أوقات الجرعات بناءً على الفترة
          final startHour = med.startDate?.hour ?? 8; // افتراضي 8 صباحاً
          var currentHour = startHour;

          while (currentHour < 24) {
            final scheduledTime = DateTime(
              now.year,
              now.month,
              now.day,
              currentHour,
              0,
            );

            // فقط الأوقات المستقبلية أو الحالية
            if (scheduledTime.isAfter(now.subtract(const Duration(hours: 1)))) {
              timeline.add(
                DailyItem(
                  id: "${med.uuid}_interval_$currentHour",
                  type: DailyItemType.medicine,
                  time: scheduledTime,
                  title: "💊 دواء: ${med.name}",
                  subtitle: "${med.doseAmount ?? ''} ${med.doseUnit ?? ''}",
                  isCompleted: false,
                  hasReminder: true, // ✅ الأدوية دائماً لها تذكير
                  originalData: med,
                ),
              );
            }
            currentHour += med.intervalHours!;
          }
        }
      }
    }

    // 3. معالجة المواعيد (تضاف فقط إذا كان الفلتر 'all' || 'appointment')
    if (_currentFilter == 'all' || _currentFilter == 'appointment') {
      for (var apt in appts) {
        if (isSameDay(apt.appointmentDate, now)) {
          timeline.add(
            DailyItem(
              id: apt.uuid,
              type: DailyItemType.appointment,
              time: apt.appointmentDate,
              title: "🗓️ موعد: ${apt.title}",
              subtitle: apt.doctorName ?? apt.locationName,
              isCompleted: apt.status == 'completed',
              hasReminder: apt.reminderEnabled, // ✅ تم الإصلاح - من الموعد نفسه
              originalData: apt,
            ),
          );
        }
      }
    }

    // 4. الترتيب (أولوية المنطقة الذكية أولاً ثم الوقت)
    timeline.sort((a, b) {
      bool aIsPriority = a.subtitle == "🎯 تركيزك الآن";
      bool bIsPriority = b.subtitle == "🎯 تركيزك الآن";
      if (aIsPriority && !bIsPriority) return -1;
      if (!aIsPriority && bIsPriority) return 1;
      return a.time.compareTo(b.time);
    });

    return timeline;
  }

  void _emitLoadedState(List<DailyItem> items) {
    _settingsRepository.getSettings().then((s) {
      emit(
        TimelineLoaded(
          items,
          activeZone: SmartZoneHelper.getCurrentZoneKey(s),
          activeFilter: _currentFilter, // ✅ تمرير الفلتر الحالي للحالة
        ),
      );
    });
  }

  bool _checkTaskZoneMatch(TaskModel task, String zone) {
    if (zone == 'work' &&
        (task.title.contains('عمل') || task.title.contains('مكتب'))) {
      return true;
    }
    if (zone == 'home' &&
        (task.title.contains('بيت') || task.title.contains('منزل'))) {
      return true;
    }
    return false;
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

// import 'dart:async';
// import 'package:athar/features/health/domain/repositories/health_repository.dart';
// import 'package:athar/features/task/domain/repositories/task_repository.dart'; // ✅ صحيح
// import 'package:athar/features/health/data/models/medicine_model.dart';
// import 'package:athar/features/health/data/models/appointment_model.dart';
// import 'package:athar/features/task/data/models/task_model.dart'; // ✅ صحيح
// import 'package:athar/features/home/domain/entities/daily_item.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:injectable/injectable.dart';
// import 'package:rxdart/rxdart.dart';

// // حالات الكيوبت
// abstract class TimelineState {}

// class TimelineInitial extends TimelineState {}

// class TimelineLoading extends TimelineState {}

// class TimelineLoaded extends TimelineState {
//   final List<DailyItem> items;
//   TimelineLoaded(this.items);
// }

// class TimelineError extends TimelineState {
//   final String message;
//   TimelineError(this.message);
// }

// @injectable
// class TimelineCubit extends Cubit<TimelineState> {
//   final TaskRepository _taskRepository;
//   final HealthRepository _healthRepository;

//   StreamSubscription? _subscription;

//   TimelineCubit(this._taskRepository, this._healthRepository)
//     : super(TimelineInitial());

//   void loadDailyTimeline(String moduleId) {
//     emit(TimelineLoading());

//     // 1. ستريم المهام (استخدام الدالة الصحيحة من TaskRepository)
//     // نستخدم startWith لضمان أن الستريم يصدر قيمة أولية فارغة ولا يعطل الدمج
//     final tasksStream = _taskRepository
//         .watchModuleTasks(moduleId)
//         .startWith([]);

//     // 2. ستريم الأدوية
//     final medsStream = _healthRepository.watchMedicines(moduleId).startWith([]);

//     // 3. ستريم المواعيد
//     final apptStream = _healthRepository
//         .watchAppointments(moduleId)
//         .startWith([]);

//     // 4. الدمج الكبير
//     _subscription =
//         Rx.combineLatest3<
//               List<TaskModel>,
//               List<MedicineModel>,
//               List<AppointmentModel>,
//               List<DailyItem>
//             >(tasksStream, medsStream, apptStream, (tasks, meds, appts) {
//               return _mergeAndSort(tasks, meds, appts);
//             })
//             .listen(
//               (items) {
//                 emit(TimelineLoaded(items));
//               },
//               onError: (e) {
//                 emit(TimelineError("فشل تحميل الجدول اليومي"));
//               },
//             );
//   }

//   List<DailyItem> _mergeAndSort(
//     List<TaskModel> tasks,
//     List<MedicineModel> meds,
//     List<AppointmentModel> appts,
//   ) {
//     final List<DailyItem> timeline = [];
//     final now = DateTime.now();

//     // أ. معالجة المهام
//     for (var task in tasks) {
//       if (task.isCompleted) continue;

//       timeline.add(
//         DailyItem(
//           id: task.uuid,
//           type: DailyItemType.task,
//           // استخدام date الموجود في الموديل
//           time: task.date,
//           title: task.title,
//           // قد لا يوجد description في TaskModel، نستخدم title أو نتركه فارغاً
//           subtitle: task.isUrgent ? "عاجل" : null,
//           isCompleted: task.isCompleted,
//           originalData: task,
//         ),
//       );
//     }

//     // ب. معالجة المواعيد
//     for (var apt in appts) {
//       if (isSameDay(apt.appointmentDate, now)) {
//         timeline.add(
//           DailyItem(
//             id: apt.uuid,
//             type: DailyItemType.appointment,
//             time: apt.appointmentDate,
//             title: "موعد: ${apt.title}",
//             subtitle: apt.doctorName ?? apt.locationName,
//             originalData: apt,
//           ),
//         );
//       }
//     }

//     // ج. معالجة الأدوية
//     for (var med in meds) {
//       if (!med.isActive) continue;

//       if (med.schedulingType == 'fixed' && med.fixedTimeSlots != null) {
//         for (var timeStr in med.fixedTimeSlots!) {
//           final parts = timeStr.split(':');
//           final time = DateTime(
//             now.year,
//             now.month,
//             now.day,
//             int.parse(parts[0]),
//             int.parse(parts[1]),
//           );

//           timeline.add(
//             DailyItem(
//               id: "${med.uuid}_$timeStr",
//               type: DailyItemType.medicine,
//               time: time,
//               title: "تناول دواء: ${med.name}",
//               subtitle:
//                   "${med.doseAmount ?? ''} ${med.doseUnit ?? ''} ${med.instructions ?? ''}",
//               originalData: med,
//             ),
//           );
//         }
//       } else if (med.schedulingType == 'interval') {
//         timeline.add(
//           DailyItem(
//             id: med.uuid,
//             type: DailyItemType.medicine,
//             time: now,
//             title: "تناول دواء: ${med.name}",
//             subtitle: "كل ${med.intervalHours} ساعات",
//             originalData: med,
//           ),
//         );
//       }
//     }

//     timeline.sort((a, b) => a.time.compareTo(b.time));
//     return timeline;
//   }

//   bool isSameDay(DateTime a, DateTime b) =>
//       a.year == b.year && a.month == b.month && a.day == b.day;

//   @override
//   Future<void> close() {
//     _subscription?.cancel();
//     return super.close();
//   }
// }
