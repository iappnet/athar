// lib/features/health/presentation/pages/health_dashboard_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 6 | Part 1 | File 1
// ═══════════════════════════════════════════════════════════════════════════════

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import 'package:athar/core/di/injection.dart';
import 'package:athar/features/auth/presentation/pages/complete_profile_page.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import 'package:athar/features/health/presentation/cubit/health_state.dart';
import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/features/health/data/models/health_profile_model.dart';
import 'package:athar/features/health/data/models/medicine_model.dart';
import 'package:athar/features/health/presentation/pages/appointments_page.dart';
import 'package:athar/features/health/presentation/pages/health_timeline_page.dart';
import 'package:athar/features/health/presentation/pages/medicines_page.dart';
import 'package:athar/features/health/presentation/pages/vitals_page.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/space/presentation/widgets/module_settings_dialog.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// Semantic colors (not in ColorScheme)
const _successColor = Color(0xFF00B894);

class HealthDashboardPage extends StatefulWidget {
  final ModuleModel module;

  const HealthDashboardPage({super.key, required this.module});

  @override
  State<HealthDashboardPage> createState() => _HealthDashboardPageState();
}

class _HealthDashboardPageState extends State<HealthDashboardPage> {
  late HealthCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HealthCubit>();
    _cubit.setContext(widget.module);
    _cubit.loadProfile(widget.module.uuid);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
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
            widget.module.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          // ✅ AppColors.textPrimary → colors.textPrimary
          foregroundColor: colorScheme.onSurface,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (_) => ModuleSettingsDialog(module: widget.module),
                );
                setState(() {});
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. البطاقة الذكية
              _buildSmartHeader(colorScheme, l10n),

              SizedBox(height: 24.h),

              // 2. شبكة الوصول السريع
              Text(
                l10n.healthQuickAccess,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              AtharGap.md,
              _buildQuickAccessGrid(colorScheme, l10n),

              SizedBox(height: 24.h),

              // 3. جدولي اليوم
              _buildTodayActionCenter(colorScheme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  // 1. البطاقة الذكية 🪪
  Widget _buildSmartHeader(ColorScheme colorScheme, AppLocalizations l10n) {
    return BlocBuilder<HealthCubit, HealthState>(
      builder: (context, state) {
        HealthProfileModel? profile;
        if (state is HealthProfileLoaded) {
          profile = state.profile;
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Icon(Icons.person, size: 35.sp, color: Colors.white),
                  ),
                  AtharGap.hLg,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.module.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (profile?.bloodType != null)
                          Text(
                            l10n.healthBloodType(profile!.bloodType!),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompleteProfilePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // تنبيه الحساسية 🚨
              if (profile?.allergies != null &&
                  profile!.allergies!.isNotEmpty) ...[
                AtharGap.lg,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.red.shade100, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 18.sp,
                      ),
                      AtharGap.hSm,
                      Expanded(
                        child: Text(
                          l10n.healthAllergy(profile.allergies!),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // 2. شبكة الوصول السريع 📂
  Widget _buildQuickAccessGrid(ColorScheme colorScheme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildAccessCard(
          colorScheme: colorScheme,
          title: l10n.healthMedicines,
          icon: Icons.medication_rounded,
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicinesPage(
                  moduleId: widget.module.uuid,
                  moduleName: widget.module.name,
                ),
              ),
            );
          },
        ),
        _buildAccessCard(
          colorScheme: colorScheme,
          title: l10n.healthAppointments,
          icon: Icons.calendar_month_rounded,
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentsPage(
                  moduleId: widget.module.uuid,
                  moduleName: widget.module.name,
                ),
              ),
            );
          },
        ),
        _buildAccessCard(
          colorScheme: colorScheme,
          title: l10n.healthVitals,
          icon: Icons.monitor_heart_rounded,
          color: Colors.red,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VitalsPage(
                  moduleId: widget.module.uuid,
                  moduleName: widget.module.name,
                ),
              ),
            );
          },
        ),
        _buildAccessCard(
          colorScheme: colorScheme,
          title: l10n.healthRecords,
          icon: Icons.history_edu_rounded,
          color: Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HealthTimelinePage(
                  moduleId: widget.module.uuid,
                  moduleName: widget.module.name,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAccessCard({
    required ColorScheme colorScheme,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AtharRadii.radiusLg,
      child: Container(
        width: 80.w,
        height: 90.h,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AtharRadii.radiusLg,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            AtharGap.sm,
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: 0.5,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // 3. مركز العمليات اليومي ⚡
  Widget _buildTodayActionCenter(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.healthTodaySchedule,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              DateFormat('EEEE, d MMM', 'ar').format(DateTime.now()),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: 0.5,
              ).copyWith(color: colorScheme.outline),
            ),
          ],
        ),
        AtharGap.md,

        StreamBuilder<List<MedicineModel>>(
          stream: _cubit.watchMedicines(widget.module.uuid),
          builder: (context, snapshot) {
            final meds = snapshot.data?.where((m) => m.isActive).toList() ?? [];
            if (meds.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...meds.map(
                  (medicine) => _buildMedicineTile(colorScheme, l10n, medicine),
                ),
                AtharGap.md,
              ],
            );
          },
        ),

        StreamBuilder<List<AppointmentModel>>(
          stream: _cubit.watchAppointments(widget.module.uuid),
          builder: (context, snapshot) {
            final today = DateTime.now();
            final appointments =
                snapshot.data?.where((apt) {
                  return apt.appointmentDate.year == today.year &&
                      apt.appointmentDate.month == today.month &&
                      apt.appointmentDate.day == today.day;
                }).toList() ??
                [];

            if (appointments.isEmpty &&
                (snapshot.data == null || snapshot.data!.isEmpty)) {
              return _buildEmptyState(colorScheme, l10n);
            }

            return Column(
              children: appointments
                  .map((apt) => _buildAppointmentTile(colorScheme, apt))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMedicineTile(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    MedicineModel medicine,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.radiusMd,
        border: Border(
          left: BorderSide(color: Colors.blue, width: 4.w),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.medication, color: Colors.blue, size: 24.sp),
          AtharGap.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  medicine.schedulingType == 'fixed'
                      ? l10n.healthFixedTimes
                      : l10n.healthEveryHours(
                          medicine.intervalHours.toString(),
                        ),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.5,
                  ).copyWith(color: colorScheme.outline),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.check_circle_outline, color: colorScheme.outline),
            onPressed: () {
              _cubit.takeDose(widget.module.uuid, medicine);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTile(ColorScheme colorScheme, AppointmentModel apt) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: AtharRadii.radiusMd,
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_filled, color: Colors.purple, size: 20.sp),
          AtharGap.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apt.title,
                  style:
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.6,
                      ).copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade900,
                      ),
                ),
                Text(
                  DateFormat('hh:mm a').format(apt.appointmentDate),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.5,
                  ).copyWith(color: Colors.purple.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20.h),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 40.sp,
              color: _successColor.withValues(alpha: 0.3),
            ),
            AtharGap.sm,
            Text(
              l10n.healthNoAppointmentsToday,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: 0.5,
              ).copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import 'package:athar/features/health/presentation/cubit/health_state.dart';
// import 'package:athar/features/health/data/models/appointment_model.dart';
// import 'package:athar/features/health/data/models/health_profile_model.dart';
// import 'package:athar/features/health/data/models/medicine_model.dart';
// import 'package:athar/features/health/presentation/pages/appointments_page.dart';
// import 'package:athar/features/health/presentation/pages/health_timeline_page.dart';
// import 'package:athar/features/health/presentation/pages/medicines_page.dart';
// import 'package:athar/features/health/presentation/pages/vitals_page.dart';
// import 'package:athar/features/space/data/models/module_model.dart';
// import 'package:athar/features/space/presentation/widgets/module_settings_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class HealthDashboardPage extends StatefulWidget {
//   final ModuleModel module;

//   const HealthDashboardPage({super.key, required this.module});

//   @override
//   State<HealthDashboardPage> createState() => _HealthDashboardPageState();
// }

// class _HealthDashboardPageState extends State<HealthDashboardPage> {
//   // نستخدم كيوبت خاص بهذه الصفحة (أو نستخدم global إذا تم حقنه في app.dart)
//   // هنا سنستخدم getIt لإنشاء نسخة جديدة خاصة بهذه الصفحة لإدارة حالتها
//   late HealthCubit _cubit;

//   @override
//   void initState() {
//     super.initState();
//     _cubit = getIt<HealthCubit>();
//     // ✅ ضروري جداً: تهيئة سياق الصلاحيات في الكيوبت
//     _cubit.setContext(widget.module);
//     _cubit.loadProfile(widget.module.uuid);
//   }

//   @override
//   void dispose() {
//     _cubit.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: _cubit,
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           title: Text(
//             widget.module.name,
//             style: const TextStyle(
//               fontFamily: 'Tajawal',
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           foregroundColor: AppColors.textPrimary,
//           actions: [
//             // ✅ 2. تفعيل زر الإعدادات
//             IconButton(
//               icon: const Icon(Icons.settings_outlined),
//               onPressed: () async {
//                 // فتح نافذة التحكم بصلاحيات الموديول
//                 await showDialog(
//                   context: context,
//                   builder: (_) => ModuleSettingsDialog(module: widget.module),
//                 );

//                 // (اختياري) بعد العودة، قد نحتاج لتحديث حالة الكيوبت
//                 // إذا تغيرت الصلاحيات، لكن PermissionService يقرأ من DB مباشرة غالباً
//                 // أو يمكن تحديث widget.module إذا كنت تستخدم State Management للموديولات
//                 setState(() {}); // تحديث الواجهة لتعكس أي تغييرات فورية
//               },
//             ),
//           ],
//         ),
//         body: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 1. البطاقة الذكية (Header)
//               _buildSmartHeader(),

//               SizedBox(height: 24.h),

//               // 2. شبكة الوصول السريع (Quick Access)
//               Text(
//                 "الوصول السريع",
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//               SizedBox(height: 12.h),
//               _buildQuickAccessGrid(),

//               SizedBox(height: 24.h),

//               // 3. جدولي اليوم (Action Center)
//               _buildTodayActionCenter(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ===========================================================================
//   // 1. البطاقة الذكية (Smart Header) 🪪
//   // ===========================================================================
//   Widget _buildSmartHeader() {
//     return BlocBuilder<HealthCubit, HealthState>(
//       builder: (context, state) {
//         HealthProfileModel? profile;
//         if (state is HealthProfileLoaded) {
//           profile = state.profile;
//         }

//         return Container(
//           width: double.infinity,
//           padding: EdgeInsets.all(20.w),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(20.r),
//             boxShadow: [
//               BoxShadow(
//                 color: AppColors.primary.withOpacity(0.3),
//                 blurRadius: 15,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 30.r,
//                     backgroundColor: Colors.white.withOpacity(0.2),
//                     child: Icon(Icons.person, size: 35.sp, color: Colors.white),
//                   ),
//                   SizedBox(width: 16.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.module.name, // اسم الملف (علي، الوالد..)
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18.sp,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: 'Tajawal',
//                           ),
//                         ),
//                         if (profile?.bloodType != null)
//                           Text(
//                             "فصيلة الدم: ${profile!.bloodType}",
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.9),
//                               fontSize: 12.sp,
//                               fontFamily: 'Tajawal',
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.edit, color: Colors.white),
//                     onPressed: () {
//                     },
//                   ),
//                 ],
//               ),

//               // تنبيه الحساسية الذكي 🚨
//               if (profile?.allergies != null &&
//                   profile!.allergies!.isNotEmpty) ...[
//                 SizedBox(height: 16.h),
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 12.w,
//                     vertical: 8.h,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(10.r),
//                     border: Border.all(color: Colors.red.shade100, width: 0.5),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.warning_amber_rounded,
//                         color: Colors.white,
//                         size: 18.sp,
//                       ),
//                       SizedBox(width: 8.w),
//                       Expanded(
//                         child: Text(
//                           "حساسية: ${profile.allergies}",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 12.sp,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ===========================================================================
//   // 2. شبكة الوصول السريع (Quick Access Grid) 📂
//   // ===========================================================================
//   Widget _buildQuickAccessGrid() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildAccessCard(
//           title: "الأدوية",
//           icon: Icons.medication_rounded,
//           color: Colors.blue,
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => MedicinesPage(
//                   moduleId: widget.module.uuid,
//                   moduleName: widget.module.name,
//                 ),
//               ),
//             );
//           },
//         ),
//         _buildAccessCard(
//           title: "المواعيد",
//           icon: Icons.calendar_month_rounded,
//           color: Colors.purple,
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => AppointmentsPage(
//                   moduleId: widget.module.uuid,
//                   moduleName: widget.module.name,
//                 ),
//               ),
//             );
//           },
//         ),
//         _buildAccessCard(
//           title: "المؤشرات",
//           icon: Icons.monitor_heart_rounded,
//           color: Colors.red,
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => VitalsPage(
//                   moduleId: widget.module.uuid,
//                   moduleName: widget.module.name,
//                 ),
//               ),
//             );
//           },
//         ),
//         _buildAccessCard(
//           title: "السجل",
//           icon: Icons.history_edu_rounded,
//           color: Colors.orange,
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => HealthTimelinePage(
//                   // ✅ يفتح الأرشيف الشامل
//                   moduleId: widget.module.uuid,
//                   moduleName: widget.module.name,
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildAccessCard({
//     required String title,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16.r),
//       child: Container(
//         width: 80.w,
//         height: 90.h,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(10.w),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: color, size: 24.sp),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ===========================================================================
//   // 3. مركز العمليات اليومي (Action Center) ⚡
//   // ===========================================================================
//   Widget _buildTodayActionCenter() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "جدولي اليوم",
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             Text(
//               DateFormat('EEEE, d MMM', 'ar').format(DateTime.now()),
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: Colors.grey,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12.h),

//         // أ. قسم الأدوية الحالية
//         StreamBuilder<List<MedicineModel>>(
//           stream: _cubit.watchMedicines(widget.module.uuid),
//           builder: (context, snapshot) {
//             final meds = snapshot.data?.where((m) => m.isActive).toList() ?? [];

//             if (meds.isEmpty)
//               return const SizedBox.shrink(); // لا نعرض شيئاً إذا لا يوجد أدوية

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ...meds.map((medicine) => _buildMedicineTile(medicine)),
//                 SizedBox(height: 12.h),
//               ],
//             );
//           },
//         ),

//         // ب. قسم مواعيد اليوم
//         StreamBuilder<List<AppointmentModel>>(
//           stream: _cubit.watchAppointments(widget.module.uuid),
//           builder: (context, snapshot) {
//             // نفلتر فقط مواعيد اليوم
//             final today = DateTime.now();
//             final appointments =
//                 snapshot.data?.where((apt) {
//                   return apt.appointmentDate.year == today.year &&
//                       apt.appointmentDate.month == today.month &&
//                       apt.appointmentDate.day == today.day;
//                 }).toList() ??
//                 [];

//             if (appointments.isEmpty &&
//                 (snapshot.data == null || snapshot.data!.isEmpty)) {
//               return _buildEmptyState();
//             }

//             return Column(
//               children: appointments
//                   .map((apt) => _buildAppointmentTile(apt))
//                   .toList(),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildMedicineTile(MedicineModel medicine) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8.h),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border(
//           left: BorderSide(color: Colors.blue, width: 4.w),
//         ),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.medication, color: Colors.blue, size: 24.sp),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   medicine.name,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   medicine.schedulingType == 'fixed'
//                       ? "أوقات ثابتة"
//                       : "كل ${medicine.intervalHours} ساعات",
//                   style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.check_circle_outline, color: Colors.grey),
//             onPressed: () {
//               _cubit.takeDose(widget.module.uuid, medicine);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppointmentTile(AppointmentModel apt) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8.h),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.purple.shade50,
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.access_time_filled, color: Colors.purple, size: 20.sp),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   apt.title,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.purple.shade900,
//                   ),
//                 ),
//                 Text(
//                   DateFormat('hh:mm a').format(apt.appointmentDate),
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.purple.shade700,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Container(
//         padding: EdgeInsets.all(20.h),
//         child: Column(
//           children: [
//             Icon(
//               Icons.check_circle_rounded,
//               size: 40.sp,
//               color: Colors.green.shade100,
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               "لا توجد مواعيد اليوم، صحتك تمام! 🌟",
//               style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
