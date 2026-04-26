import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:athar/core/utils/navigation_utils.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/design_system/molecules/tiles/task_tile.dart';
import '../../../task/presentation/cubit/task_cubit.dart';
import '../../../task/presentation/cubit/task_state.dart';
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

    return BlocProvider(
      create: (context) => getIt<TaskCubit>()..watchTasks(_selectedDate),
      child: Scaffold(
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
            // Calendar widget
            Builder(
              builder: (context) {
                return DualCalendarWidget(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                    context.read<TaskCubit>().watchTasks(date);
                  },
                );
              },
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

            // Task list
            Expanded(
              child: BlocBuilder<TaskCubit, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TaskLoaded) {
                    if (state.tasks.isEmpty) {
                      return _buildEmptyState(colorScheme, l10n);
                    }
                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      itemCount: state.tasks.length,
                      separatorBuilder: (c, i) => AtharGap.md,
                      itemBuilder: (context, index) {
                        final task = state.tasks[index];
                        return TaskTile(
                          task: task,
                          onToggle: (val) => context
                              .read<TaskCubit>()
                              .toggleTaskCompletion(task),
                          onDelete: () =>
                              context.read<TaskCubit>().deleteTask(task.id),
                        );
                      },
                    );
                  } else if (state is TaskError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: colorScheme.error, size: 40),
                          AtharGap.sm,
                          Text(state.message,
                              style:
                                  TextStyle(color: colorScheme.error)),
                          TextButton.icon(
                            onPressed: () => context
                                .read<TaskCubit>()
                                .watchTasks(_selectedDate),
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(
                                AppLocalizations.of(context).retry),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
            ),
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
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/di/injection.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../../../core/design_system/molecules/tiles/task_tile.dart';
// import '../../../task/presentation/cubit/task_cubit.dart';
// import '../../../task/presentation/cubit/task_state.dart';
// import '../widgets/dual_calendar_widget.dart';

// class CalendarPage extends StatefulWidget {
//   const CalendarPage({super.key});

//   @override
//   State<CalendarPage> createState() => _CalendarPageState();
// }

// class _CalendarPageState extends State<CalendarPage> {
//   DateTime _selectedDate = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     // نستخدم BlocProvider محلي للصفحة لجلب مهام التاريخ المختار
//     return BlocProvider(
//       create: (context) => getIt<TaskCubit>()..watchTasks(_selectedDate),
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           title: const Text("التقويم"),
//           backgroundColor: Colors.white, // ليكون متصلاً مع الودجت الأبيض
//           elevation: 0,
//           leading: const BackButton(color: Colors.black),
//           titleTextStyle: TextStyle(
//             color: Colors.black,
//             fontSize: 20.sp,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Cairo',
//           ),
//         ),
//         body: Column(
//           children: [
//             // 1. ودجت التقويم المدمج
//             // نستخدم Builder للوصول للكيوبت داخل الـ BlocProvider الجديد
//             Builder(
//               builder: (context) {
//                 return DualCalendarWidget(
//                   selectedDate: _selectedDate,
//                   onDateSelected: (date) {
//                     setState(() {
//                       _selectedDate = date;
//                     });
//                     // تحديث الكيوبت لجلب مهام اليوم الجديد
//                     context.read<TaskCubit>().watchTasks(date);
//                   },
//                 );
//               },
//             ),

//             SizedBox(height: 16.h),

//             // 2. عنوان القائمة
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               child: Row(
//                 children: [
//                   Text(
//                     "أحداث هذا اليوم",
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     DateFormat('EEEE, d MMMM', 'ar').format(_selectedDate),
//                     style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 10.h),

//             // 3. قائمة المهام لليوم المختار
//             Expanded(
//               child: BlocBuilder<TaskCubit, TaskState>(
//                 builder: (context, state) {
//                   if (state is TaskLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (state is TaskLoaded) {
//                     if (state.tasks.isEmpty) {
//                       return _buildEmptyState();
//                     }
//                     return ListView.separated(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 16.w,
//                         vertical: 8.h,
//                       ),
//                       itemCount: state.tasks.length,
//                       separatorBuilder: (c, i) => SizedBox(height: 10.h),
//                       itemBuilder: (context, index) {
//                         final task = state.tasks[index];
//                         return TaskTile(
//                           task: task,
//                           onToggle: (val) => context
//                               .read<TaskCubit>()
//                               .toggleTaskCompletion(task),
//                           onDelete: () =>
//                               context.read<TaskCubit>().deleteTask(task.id),
//                         );
//                       },
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.event_busy, size: 50.sp, color: Colors.grey.shade300),
//           SizedBox(height: 10.h),
//           Text(
//             "لا توجد مهام في هذا اليوم",
//             style: TextStyle(color: Colors.grey.shade500),
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
