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
      child: BlocListener<HealthCubit, HealthState>(
        listener: (context, state) {
          if (state is HealthOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.colors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is HealthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
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

              AtharGap.xxl,

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

              AtharGap.xxl,

              // 3. جدولي اليوم
              _buildTodayActionCenter(colorScheme, l10n),
            ],
          ),
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
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
            borderRadius: AtharRadii.radiusXl,
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
                    child: Icon(Icons.person, size: 35.sp, color: colorScheme.onPrimary),
                  ),
                  AtharGap.hLg,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.module.name,
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (profile?.bloodType != null)
                          Text(
                            l10n.healthBloodType(profile!.bloodType!),
                            style: TextStyle(
                              color: colorScheme.onPrimary.withValues(alpha: 0.9),
                              fontSize: 12.sp,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: colorScheme.onPrimary),
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
                    color: context.colors.error.withValues(alpha: 0.2),
                    borderRadius: AtharRadii.radiusMd,
                    border: Border.all(
                      color: context.colors.error.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: colorScheme.onPrimary,
                        size: 18.sp,
                      ),
                      AtharGap.hSm,
                      Expanded(
                        child: Text(
                          l10n.healthAllergy(profile.allergies!),
                          style: TextStyle(
                            color: colorScheme.onPrimary,
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
          color: context.colors.accentBlue,
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
          color: context.colors.accentPurple,
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
          color: context.colors.accentRed,
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
          color: context.colors.accentOrange,
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
          boxShadow: AtharShadows.card,
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
        border: BorderDirectional(
          start: BorderSide(color: context.colors.accentBlue, width: 4.w),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.medication, color: context.colors.accentBlue, size: 24.sp),
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
        color: context.colors.accentPurple.withValues(alpha: 0.1),
        borderRadius: AtharRadii.radiusMd,
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_filled, color: context.colors.accentPurple, size: 20.sp),
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
                        color: context.colors.accentPurple,
                      ),
                ),
                Text(
                  DateFormat('hh:mm a').format(apt.appointmentDate),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.5,
                  ).copyWith(color: context.colors.accentPurple),
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
              color: context.colors.success.withValues(alpha: 0.3),
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

