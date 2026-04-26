// lib/features/health/presentation/pages/appointments_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 6 | Part 3 | File 2
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import 'package:athar/core/di/injection.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import 'package:athar/features/health/presentation/widgets/add_appointment_sheet.dart';
import 'package:athar/features/health/data/models/appointment_model.dart';

class AppointmentsPage extends StatefulWidget {
  final String moduleId;
  final String moduleName;

  const AppointmentsPage({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HealthCubit _cubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cubit = getIt<HealthCubit>();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        // ✅ AppColors.background → colors.background
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            // ✅ l10n
            l10n.appointmentsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: colorScheme.surface,
          elevation: 0,
          // ✅ AppColors.textPrimary → colors.textPrimary
          foregroundColor: colorScheme.onSurface,
          bottom: TabBar(
            controller: _tabController,
            // ✅ AppColors.primary → colors.primary
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.outline,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            indicatorColor: colorScheme.primary,
            tabs: [
              // ✅ l10n
              Tab(text: l10n.appointmentsTabUpcoming),
              Tab(text: l10n.appointmentsTabArchive),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAppointmentsList(colorScheme, l10n, isUpcoming: true),
            _buildAppointmentsList(colorScheme, l10n, isUpcoming: false),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) =>
                  AddAppointmentSheet(moduleId: widget.moduleId, cubit: _cubit),
            );
          },
          // ✅ AppColors.primary → colors.primary
          backgroundColor: colorScheme.primary,
          icon: const Icon(Icons.add_alarm),
          label: Text(
            // ✅ l10n
            l10n.appointmentsNewButton,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(
    ColorScheme colorScheme,
    AppLocalizations l10n, {
    required bool isUpcoming,
  }) {
    return StreamBuilder<List<AppointmentModel>>(
      stream: _cubit.watchAppointments(widget.moduleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();
        final appointments =
            snapshot.data?.where((apt) {
              if (isUpcoming) {
                return apt.appointmentDate.isAfter(now) ||
                    isSameDay(apt.appointmentDate, now);
              } else {
                return apt.appointmentDate.isBefore(now) &&
                    !isSameDay(apt.appointmentDate, now);
              }
            }).toList() ??
            [];

        appointments.sort(
          (a, b) => isUpcoming
              ? a.appointmentDate.compareTo(b.appointmentDate)
              : b.appointmentDate.compareTo(a.appointmentDate),
        );

        if (appointments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isUpcoming ? Icons.event_available : Icons.history,
                  size: 60.sp,
                  color: colorScheme.outlineVariant,
                ),
                AtharGap.lg,
                Text(
                  // ✅ l10n
                  isUpcoming
                      ? l10n.appointmentsEmptyUpcoming
                      : l10n.appointmentsEmptyArchive,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ).copyWith(color: colorScheme.outline),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: AtharSpacing.allLg,
          itemCount: appointments.length,
          separatorBuilder: (c, i) => AtharGap.md,
          itemBuilder: (context, index) {
            return _buildAppointmentCard(
              colorScheme,
              l10n,
              appointments[index],
            );
          },
        );
      },
    );
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildAppointmentCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    AppointmentModel apt,
  ) {
    Color color;
    IconData icon;
    String typeText;

    switch (apt.type) {
      case 'lab':
        color = Colors.purple;
        icon = Icons.science_rounded;
        // ✅ l10n
        typeText = l10n.appointmentsTypeLab;
        break;
      case 'vaccine':
        color = Colors.teal;
        icon = Icons.vaccines_rounded;
        typeText = l10n.appointmentsTypeVaccine;
        break;
      case 'procedure':
        color = Colors.red;
        icon = Icons.healing_rounded;
        typeText = l10n.appointmentsTypeProcedure;
        break;
      default:
        color = Colors.blue;
        icon = Icons.medical_services_rounded;
        typeText = l10n.appointmentsTypeCheckup;
    }

    return Container(
      padding: AtharSpacing.allLg,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusLg,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          right: BorderSide(color: color, width: 4.w),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AtharRadii.radiusSm,
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 14.sp, color: color),
                    AtharGap.hXxs,
                    Text(
                      typeText,
                      style: TextStyle(
                        color: color,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(Icons.access_time, size: 14.sp, color: colorScheme.outline),
              AtharGap.hXxs,
              Text(
                DateFormat('yyyy/MM/dd  hh:mm a').format(apt.appointmentDate),
                style:
                    TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      letterSpacing: 0.5,
                    ).copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          AtharGap.md,
          Text(
            apt.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ).copyWith(fontWeight: FontWeight.bold),
          ),
          if (apt.doctorName != null || apt.locationName != null) ...[
            AtharGap.sm,
            Divider(color: colorScheme.outlineVariant),
            AtharGap.sm,
            Row(
              children: [
                if (apt.doctorName != null) ...[
                  Icon(
                    Icons.person_outline,
                    size: 16.sp,
                    color: colorScheme.outline,
                  ),
                  AtharGap.hXxs,
                  Text(
                    apt.doctorName!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      letterSpacing: 0.5,
                    ).copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  AtharGap.hLg,
                ],
                if (apt.locationName != null) ...[
                  Icon(
                    Icons.location_on_outlined,
                    size: 16.sp,
                    color: colorScheme.outline,
                  ),
                  AtharGap.hXxs,
                  Text(
                    apt.locationName!,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      letterSpacing: 0.5,
                    ).copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ],
          if (apt.notes != null && apt.notes!.isNotEmpty) ...[
            AtharGap.sm,
            Text(
              apt.notes!,
              style:
                  TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.5,
                  ).copyWith(
                    color: colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_horiz,
                size: 20.sp,
                color: colorScheme.outline,
              ),
              onSelected: (v) {
                if (v == 'delete') _cubit.deleteAppointment(apt);
              },
              itemBuilder: (c) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    // ✅ l10n
                    l10n.appointmentsDeleteAction,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ],
            ),
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
// import 'package:athar/features/health/presentation/widgets/add_appointment_sheet.dart';
// import 'package:athar/features/health/data/models/appointment_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class AppointmentsPage extends StatefulWidget {
//   final String moduleId;
//   final String moduleName;

//   const AppointmentsPage({
//     super.key,
//     required this.moduleId,
//     required this.moduleName,
//   });

//   @override
//   State<AppointmentsPage> createState() => _AppointmentsPageState();
// }

// class _AppointmentsPageState extends State<AppointmentsPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late HealthCubit _cubit;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _cubit = getIt<HealthCubit>();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: _cubit,
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           title: const Text(
//             "مركز المواعيد",
//             style: TextStyle(
//               fontFamily: 'Tajawal',
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           foregroundColor: AppColors.textPrimary,
//           bottom: TabBar(
//             controller: _tabController,
//             labelColor: AppColors.primary,
//             unselectedLabelColor: Colors.grey,
//             labelStyle: TextStyle(
//               fontFamily: 'Tajawal',
//               fontWeight: FontWeight.bold,
//               fontSize: 14.sp,
//             ),
//             indicatorColor: AppColors.primary,
//             tabs: const [
//               Tab(text: "القادمة"),
//               Tab(text: "السابقة (الأرشيف)"),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             _buildAppointmentsList(isUpcoming: true),
//             _buildAppointmentsList(isUpcoming: false),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: () {
//             showModalBottomSheet(
//               context: context,
//               isScrollControlled: true,
//               backgroundColor: Colors.transparent,
//               builder: (_) =>
//                   AddAppointmentSheet(moduleId: widget.moduleId, cubit: _cubit),
//             );
//           },
//           backgroundColor: AppColors.primary,
//           icon: const Icon(Icons.add_alarm),
//           label: const Text(
//             "موعد جديد",
//             style: TextStyle(
//               fontFamily: 'Tajawal',
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildAppointmentsList({required bool isUpcoming}) {
//     return StreamBuilder<List<AppointmentModel>>(
//       stream: _cubit.watchAppointments(widget.moduleId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final now = DateTime.now();
//         final appointments =
//             snapshot.data?.where((apt) {
//               if (isUpcoming) {
//                 return apt.appointmentDate.isAfter(now) ||
//                     isSameDay(apt.appointmentDate, now);
//               } else {
//                 return apt.appointmentDate.isBefore(now) &&
//                     !isSameDay(apt.appointmentDate, now);
//               }
//             }).toList() ??
//             [];

//         appointments.sort(
//           (a, b) => isUpcoming
//               ? a.appointmentDate.compareTo(b.appointmentDate)
//               : b.appointmentDate.compareTo(a.appointmentDate),
//         );

//         if (appointments.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   isUpcoming ? Icons.event_available : Icons.history,
//                   size: 60.sp,
//                   color: Colors.grey.shade300,
//                 ),
//                 SizedBox(height: 16.h),
//                 Text(
//                   isUpcoming ? "لا توجد مواعيد قادمة" : "سجل الزيارات فارغ",
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 14.sp,
//                     fontFamily: 'Tajawal',
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.separated(
//           padding: EdgeInsets.all(16.w),
//           itemCount: appointments.length,
//           separatorBuilder: (c, i) => SizedBox(height: 12.h),
//           itemBuilder: (context, index) {
//             return _buildAppointmentCard(appointments[index]);
//           },
//         );
//       },
//     );
//   }

//   bool isSameDay(DateTime a, DateTime b) =>
//       a.year == b.year && a.month == b.month && a.day == b.day;

//   Widget _buildAppointmentCard(AppointmentModel apt) {
//     Color color;
//     IconData icon;
//     String typeText;

//     switch (apt.type) {
//       case 'lab':
//         color = Colors.purple;
//         icon = Icons.science_rounded;
//         typeText = "تحليل";
//         break;
//       case 'vaccine':
//         color = Colors.teal;
//         icon = Icons.vaccines_rounded;
//         typeText = "تطعيم";
//         break;
//       case 'procedure':
//         color = Colors.red;
//         icon = Icons.healing_rounded;
//         typeText = "إجراء/جراحة";
//         break;
//       default:
//         color = Colors.blue;
//         icon = Icons.medical_services_rounded;
//         typeText = "كشف";
//     }

//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border(
//           right: BorderSide(color: color, width: 4.w),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//                 decoration: BoxDecoration(
//                   color: color.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(icon, size: 14.sp, color: color),
//                     SizedBox(width: 4.w),
//                     Text(
//                       typeText,
//                       style: TextStyle(
//                         color: color,
//                         fontSize: 12.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const Spacer(),
//               Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
//               SizedBox(width: 4.w),
//               Text(
//                 DateFormat('yyyy/MM/dd  hh:mm a').format(apt.appointmentDate),
//                 style: TextStyle(
//                   color: Colors.grey.shade700,
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h),
//           Text(
//             apt.title,
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Tajawal',
//             ),
//           ),
//           if (apt.doctorName != null || apt.locationName != null) ...[
//             SizedBox(height: 8.h),
//             Divider(color: Colors.grey.shade100),
//             SizedBox(height: 8.h),
//             Row(
//               children: [
//                 if (apt.doctorName != null) ...[
//                   Icon(Icons.person_outline, size: 16.sp, color: Colors.grey),
//                   SizedBox(width: 4.w),
//                   Text(
//                     apt.doctorName!,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: Colors.grey.shade800,
//                     ),
//                   ),
//                   SizedBox(width: 16.w),
//                 ],
//                 if (apt.locationName != null) ...[
//                   Icon(
//                     Icons.location_on_outlined,
//                     size: 16.sp,
//                     color: Colors.grey,
//                   ),
//                   SizedBox(width: 4.w),
//                   Text(
//                     apt.locationName!,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: Colors.grey.shade800,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ],
//           if (apt.notes != null && apt.notes!.isNotEmpty) ...[
//             SizedBox(height: 8.h),
//             Text(
//               apt.notes!,
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: Colors.grey.shade500,
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ],
//           Align(
//             alignment: Alignment.centerLeft,
//             child: PopupMenuButton<String>(
//               icon: Icon(
//                 Icons.more_horiz,
//                 size: 20.sp,
//                 color: Colors.grey.shade400,
//               ),
//               onSelected: (v) {
//                 // ✅ التصحيح هنا: نمرر الكائن apt كاملاً
//                 if (v == 'delete') _cubit.deleteAppointment(apt);
//               },
//               itemBuilder: (c) => [
//                 const PopupMenuItem(
//                   value: 'delete',
//                   child: Text(
//                     "حذف الموعد",
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
