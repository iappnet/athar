import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/calendar/domain/entities/calendar_item.dart';
import 'package:athar/features/calendar/presentation/cubit/calendar_cubit.dart';
import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:athar/features/task/presentation/cubit/task_state.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:athar/core/utils/navigation_utils.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import '../../../../core/design_system/molecules/tiles/task_tile.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../widgets/dual_calendar_widget.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.calendarTitle),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: BackButton(
          color: colorScheme.onSurface,
          onPressed: () => NavigationUtils.safeBack(context),
        ),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.isTablet
                ? ResponsiveHelper.maxContentWidth
                : double.infinity,
          ),
          child: Column(
            children: [
              // Calendar widget — pass isHijriMode to fix the reactive gap.
              BlocSelector<SettingsCubit, SettingsState, bool?>(
                selector: (state) =>
                    state is SettingsLoaded ? state.settings.isHijriMode : null,
                builder: (context, isHijriMode) => DualCalendarWidget(
                  selectedDate: _selectedDate,
                  isHijriMode: isHijriMode,
                  onDateSelected: (date) {
                    setState(() => _selectedDate = date);
                    context.read<CalendarCubit>().selectDate(date);
                  },
                ),
              ),

              AtharGap.lg,

              // List header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Text(
                      l10n.calendarDayEvents,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('EEEE, d MMMM', 'ar').format(_selectedDate),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              AtharGap.md,

              // Items list.
              //
              // TASK REFRESH: fires only when transitioning TaskLoaded →
              // TaskLoaded (Isar stream update after a confirmed mutation).
              // The initial TaskLoading → TaskLoaded transition is excluded,
              // so there is no redundant re-fetch on first navigation.
              //
              // APPOINTMENT REFRESH: handled inside CalendarCubit via
              // AppointmentNotifier subscription — no BlocListener needed here.
              Expanded(
                child: BlocListener<TaskCubit, TaskState>(
                  listenWhen: (prev, curr) =>
                      prev is TaskLoaded && curr is TaskLoaded,
                  listener: (context, _) =>
                      context.read<CalendarCubit>().selectDate(_selectedDate),
                  child: BlocBuilder<CalendarCubit, CalendarState>(
                    builder: (context, state) {
                      if (state is CalendarLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is CalendarError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline_rounded,
                                  color: colorScheme.error, size: 40),
                              AtharGap.sm,
                              Text(state.message,
                                  style: TextStyle(color: colorScheme.error)),
                              TextButton.icon(
                                onPressed: () => context
                                    .read<CalendarCubit>()
                                    .selectDate(_selectedDate),
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(l10n.retry),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is CalendarLoaded) {
                        if (state.items.isEmpty) {
                          return _buildEmptyState(colorScheme, l10n);
                        }
                        return ListView.separated(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          itemCount: state.items.length,
                          separatorBuilder: (context, index) => AtharGap.md,
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return switch (item) {
                              CalendarTask(:final task) => TaskTile(
                                  task: task,
                                  onToggle: (_) => context
                                      .read<TaskCubit>()
                                      .toggleTaskCompletion(task),
                                  onDelete: () => context
                                      .read<TaskCubit>()
                                      .deleteTask(task.id),
                                ),
                              CalendarAppointment(:final appointment) =>
                                _AppointmentTile(appointment: appointment),
                            };
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 50.sp,
            color: colorScheme.outlineVariant,
          ),
          AtharGap.md,
          Text(
            l10n.calendarNoTasks,
            style: TextStyle(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline appointment tile — no separate file needed for a single use.
// ---------------------------------------------------------------------------

class _AppointmentTile extends StatelessWidget {
  const _AppointmentTile({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeStr =
        DateFormat('hh:mm a', 'ar').format(appointment.appointmentDate);

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(Icons.medical_services_outlined,
                color: colorScheme.primary, size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (appointment.doctorName != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      appointment.doctorName!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
