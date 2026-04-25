// lib/features/health/presentation/pages/health_timeline_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 6 | Part 3 | File 1
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import 'package:athar/core/di/injection.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import 'package:athar/features/health/presentation/widgets/add_vital_sheet.dart';
import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/features/health/data/models/vital_sign_model.dart';

class TimelineEvent {
  final DateTime date;
  final String type;
  final dynamic originalData;

  TimelineEvent({
    required this.date,
    required this.type,
    required this.originalData,
  });
}

class HealthTimelinePage extends StatefulWidget {
  final String moduleId;
  final String moduleName;

  const HealthTimelinePage({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  State<HealthTimelinePage> createState() => _HealthTimelinePageState();
}

class _HealthTimelinePageState extends State<HealthTimelinePage> {
  late HealthCubit _cubit;
  String _filterType = 'all';

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HealthCubit>();
  }

  Stream<List<TimelineEvent>> get _combinedStream {
    final vitalsStream = _cubit.watchVitals(widget.moduleId);
    final appointmentsStream = _cubit.watchAppointments(widget.moduleId);

    return Rx.combineLatest2<
      List<VitalSignModel>,
      List<AppointmentModel>,
      List<TimelineEvent>
    >(vitalsStream, appointmentsStream, (vitals, appointments) {
      final List<TimelineEvent> events = [];

      for (var v in vitals) {
        events.add(
          TimelineEvent(date: v.recordDate, type: v.category, originalData: v),
        );
      }

      for (var a in appointments) {
        if (a.appointmentDate.isBefore(DateTime.now())) {
          events.add(
            TimelineEvent(
              date: a.appointmentDate,
              type: 'appointment',
              originalData: a,
            ),
          );
        }
      }

      events.sort((a, b) => b.date.compareTo(a.date));
      return events;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      // ✅ AppColors.background → colors.background
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          // ✅ l10n
          l10n.healthTimelineTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        // ✅ AppColors.textPrimary → colors.textPrimary
        foregroundColor: colorScheme.onSurface,
      ),
      body: Column(
        children: [
          _buildFilterBar(colorScheme, l10n),

          Expanded(
            child: StreamBuilder<List<TimelineEvent>>(
              stream: _combinedStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allEvents = snapshot.data ?? [];

                final events = allEvents.where((e) {
                  if (_filterType == 'all') return true;
                  return e.type == _filterType;
                }).toList();

                if (events.isEmpty) {
                  return _buildEmptyState(colorScheme, l10n);
                }

                return ListView.builder(
                  padding: AtharSpacing.allLg,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    if (event.type == 'appointment') {
                      return _buildAppointmentCard(
                        colorScheme,
                        l10n,
                        event.originalData as AppointmentModel,
                      );
                    } else {
                      return _buildVitalCard(
                        colorScheme,
                        l10n,
                        event.originalData as VitalSignModel,
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) =>
                AddVitalSheet(moduleId: widget.moduleId, cubit: _cubit),
          );
        },
        // ✅ AppColors.primary → colors.primary
        backgroundColor: colorScheme.primary,
        icon: const Icon(Icons.add),
        label: Text(
          // ✅ l10n
          l10n.healthTimelineAddRecord,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFilterBar(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          // ✅ l10n: filter labels
          _buildFilterChip(colorScheme, 'all', l10n.healthTimelineFilterAll),
          _buildFilterChip(
            colorScheme,
            'appointment',
            l10n.healthTimelineFilterVisits,
          ),
          _buildFilterChip(
            colorScheme,
            'vital',
            l10n.healthTimelineFilterVitals,
          ),
          _buildFilterChip(
            colorScheme,
            'document',
            l10n.healthTimelineFilterDocs,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ColorScheme colorScheme, String key, String label) {
    final isSelected = _filterType == key;
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        // ✅ AppColors.primary → colors.primary
        selectedColor: colorScheme.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? colorScheme.primary : colorScheme.outline,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (val) => setState(() => _filterType = key),
      ),
    );
  }

  Widget _buildAppointmentCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    AppointmentModel apt,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: AtharSpacing.allLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusMd,
        border: Border(
          right: BorderSide(color: Colors.purple, width: 4.w),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.medical_services,
                    color: Colors.purple,
                    size: 18,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    // ✅ l10n
                    l10n.healthTimelineMedicalVisit,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('yyyy/MM/dd').format(apt.appointmentDate),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  letterSpacing: 0.5,
                ).copyWith(color: colorScheme.outline),
              ),
            ],
          ),
          AtharGap.sm,
          Text(
            apt.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          if (apt.doctorName != null)
            Text(
              "${l10n.healthTimelineDoctorPrefix} ${apt.doctorName}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ).copyWith(color: colorScheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }

  Widget _buildVitalCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    VitalSignModel vital,
  ) {
    final isDoc = vital.category == 'document';
    Color color = isDoc ? Colors.orange : Colors.blue;
    IconData icon = isDoc ? Icons.description : Icons.monitor_heart;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: AtharSpacing.allLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusMd,
        border: Border(
          right: BorderSide(color: color, width: 4.w),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 18),
                    SizedBox(width: 8.w),
                    Text(
                      // ✅ l10n
                      isDoc
                          ? l10n.healthTimelineNoteDoc
                          : l10n.healthTimelineVitalSign,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                AtharGap.sm,
                if (isDoc)
                  Text(
                    vital.title ?? l10n.healthTimelineNoTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ).copyWith(fontWeight: FontWeight.bold),
                  )
                else
                  Text(
                    "${vital.vitalType}: ${vital.vitalValue} ${vital.vitalUnit}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          Text(
            DateFormat('yyyy/MM/dd').format(vital.recordDate),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 1.4,
              letterSpacing: 0.5,
            ).copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_edu,
            size: 60.sp,
            color: colorScheme.outlineVariant,
          ),
          AtharGap.lg,
          Text(
            // ✅ l10n
            l10n.healthTimelineEmpty,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ).copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import 'package:athar/features/health/presentation/widgets/add_vital_sheet.dart';
// import 'package:athar/features/health/data/models/appointment_model.dart';
// import 'package:athar/features/health/data/models/vital_sign_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:rxdart/rxdart.dart'; // ✅ نحتاج هذه المكتبة لدمج الـ Streams بسهولة

// // كلاس مساعد لتوحيد البيانات
// class TimelineEvent {
//   final DateTime date;
//   final String type; // 'vital', 'document', 'appointment'
//   final dynamic originalData; // الكائن الأصلي

//   TimelineEvent({
//     required this.date,
//     required this.type,
//     required this.originalData,
//   });
// }

// class HealthTimelinePage extends StatefulWidget {
//   final String moduleId;
//   final String moduleName;

//   const HealthTimelinePage({
//     super.key,
//     required this.moduleId,
//     required this.moduleName,
//   });

//   @override
//   State<HealthTimelinePage> createState() => _HealthTimelinePageState();
// }

// class _HealthTimelinePageState extends State<HealthTimelinePage> {
//   late HealthCubit _cubit;
//   String _filterType = 'all'; // all, appointment, vital, document

//   @override
//   void initState() {
//     super.initState();
//     _cubit = getIt<HealthCubit>();
//   }

//   // ✅ دالة الدمج الذكي: تجمع المواعيد والمؤشرات في قائمة واحدة مرتبة
//   Stream<List<TimelineEvent>> get _combinedStream {
//     final vitalsStream = _cubit.watchVitals(widget.moduleId);
//     final appointmentsStream = _cubit.watchAppointments(widget.moduleId);

//     return Rx.combineLatest2<
//       List<VitalSignModel>,
//       List<AppointmentModel>,
//       List<TimelineEvent>
//     >(vitalsStream, appointmentsStream, (vitals, appointments) {
//       final List<TimelineEvent> events = [];

//       // 1. تحويل المؤشرات والوثائق
//       for (var v in vitals) {
//         events.add(
//           TimelineEvent(
//             date: v.recordDate,
//             type: v.category, // 'vital' or 'document'
//             originalData: v,
//           ),
//         );
//       }

//       // 2. تحويل المواعيد (نأخذ فقط المواعيد السابقة أو المكتملة للأرشيف)
//       // أو نأخذ الكل إذا أردنا سجلاً كاملاً
//       for (var a in appointments) {
//         // نعتبر الموعد جزءاً من الأرشيف إذا كان تاريخه سابقاً
//         if (a.appointmentDate.isBefore(DateTime.now())) {
//           events.add(
//             TimelineEvent(
//               date: a.appointmentDate,
//               type: 'appointment',
//               originalData: a,
//             ),
//           );
//         }
//       }

//       // 3. الترتيب الزمني (الأحدث في الأعلى)
//       events.sort((a, b) => b.date.compareTo(a.date));

//       return events;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text(
//           "السجل الطبي الشامل",
//           style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: AppColors.textPrimary,
//       ),
//       body: Column(
//         children: [
//           // شريط الفلاتر
//           _buildFilterBar(),

//           Expanded(
//             child: StreamBuilder<List<TimelineEvent>>(
//               stream: _combinedStream,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final allEvents = snapshot.data ?? [];

//                 // تطبيق الفلتر المختار
//                 final events = allEvents.where((e) {
//                   if (_filterType == 'all') return true;
//                   return e.type == _filterType;
//                 }).toList();

//                 if (events.isEmpty) {
//                   return _buildEmptyState();
//                 }

//                 return ListView.builder(
//                   padding: EdgeInsets.all(16.w),
//                   itemCount: events.length,
//                   itemBuilder: (context, index) {
//                     final event = events[index];

//                     // نقوم برسم البطاقة المناسبة حسب نوع الحدث
//                     if (event.type == 'appointment') {
//                       return _buildAppointmentCard(
//                         event.originalData as AppointmentModel,
//                       );
//                     } else {
//                       return _buildVitalCard(
//                         event.originalData as VitalSignModel,
//                       );
//                     }
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       // زر عائم لإضافة (قراءة/ملاحظة) سريعة، أما الموعد فيضاف من مركز المواعيد
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (_) =>
//                 AddVitalSheet(moduleId: widget.moduleId, cubit: _cubit),
//           );
//         },
//         backgroundColor: AppColors.primary,
//         icon: const Icon(Icons.add),
//         label: const Text(
//           "إضافة سجل",
//           style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterBar() {
//     return Container(
//       height: 50.h,
//       margin: EdgeInsets.symmetric(vertical: 8.h),
//       child: ListView(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         children: [
//           _buildFilterChip('all', 'الكل'),
//           _buildFilterChip('appointment', 'زيارات'),
//           _buildFilterChip('vital', 'مؤشرات'),
//           _buildFilterChip('document', 'وثائق'),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChip(String key, String label) {
//     final isSelected = _filterType == key;
//     return Padding(
//       padding: EdgeInsets.only(left: 8.w),
//       child: ChoiceChip(
//         label: Text(label),
//         selected: isSelected,
//         selectedColor: AppColors.primary.withValues(alpha: 0.2),
//         labelStyle: TextStyle(
//           color: isSelected ? AppColors.primary : Colors.grey,
//           fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           fontFamily: 'Tajawal',
//         ),
//         onSelected: (val) => setState(() => _filterType = key),
//       ),
//     );
//   }

//   // --- بطاقة الموعد السابق (زيارة طبيب) ---
//   Widget _buildAppointmentCard(AppointmentModel apt) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border(
//           right: BorderSide(color: Colors.purple, width: 4.w),
//         ), // لون مميز للمواعيد
//         boxShadow: [
//           BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   const Icon(
//                     Icons.medical_services,
//                     color: Colors.purple,
//                     size: 18,
//                   ),
//                   SizedBox(width: 8.w),
//                   Text(
//                     "زيارة طبية",
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: Colors.purple,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               Text(
//                 DateFormat('yyyy/MM/dd').format(apt.appointmentDate),
//                 style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//               ),
//             ],
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             apt.title,
//             style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//           ),
//           if (apt.doctorName != null)
//             Text(
//               "د. ${apt.doctorName}",
//               style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
//             ),
//         ],
//       ),
//     );
//   }

//   // --- بطاقة المؤشر أو الوثيقة ---
//   Widget _buildVitalCard(VitalSignModel vital) {
//     final isDoc = vital.category == 'document';
//     Color color = isDoc ? Colors.orange : Colors.blue;
//     IconData icon = isDoc ? Icons.description : Icons.monitor_heart;

//     return Container(
//       margin: EdgeInsets.only(bottom: 12.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border(
//           right: BorderSide(color: color, width: 4.w),
//         ),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(icon, color: color, size: 18),
//                     SizedBox(width: 8.w),
//                     Text(
//                       isDoc ? "ملاحظة/وثيقة" : "مؤشر حيوي",
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: color,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 8.h),
//                 if (isDoc)
//                   Text(
//                     vital.title ?? "بدون عنوان",
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   )
//                 else
//                   Text(
//                     "${vital.vitalType}: ${vital.vitalValue} ${vital.vitalUnit}",
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Text(
//             DateFormat('yyyy/MM/dd').format(vital.recordDate),
//             style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.history_edu, size: 60.sp, color: Colors.grey.shade300),
//           SizedBox(height: 16.h),
//           Text(
//             "السجل الطبي فارغ",
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: 16.sp,
//               fontFamily: 'Tajawal',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
