// ————-————— code start ————————-
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/widgets/athar_feedback.dart';
import 'package:athar/core/design_system/widgets/athar_text_field.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:athar/features/task/presentation/widgets/attachments_widget.dart';
// ✅ استيراد ودجت السبورة
import 'package:athar/features/task/presentation/widgets/task_board_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// Semantic colors (not in ColorScheme)
const _warningColor = Color(0xFFFDCB6E);
const _successColor = Color(0xFF00B894);

class TaskDetailsPage extends StatefulWidget {
  final TaskModel task;
  const TaskDetailsPage({super.key, required this.task});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TaskStatus _currentStatus;

  // ✅ متغيرات التذكير الجديدة
  late bool _isReminderEnabled;
  DateTime? _reminderTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(
      text: widget.task.description ?? "",
    );
    _currentStatus = widget.task.status;

    // ✅ تهيئة التذكير
    _isReminderEnabled = widget.task.reminderTime != null;
    _reminderTime = widget.task.reminderTime;

    // تصحيح حالة الإكمال
    if (widget.task.isCompleted && _currentStatus != TaskStatus.done) {
      _currentStatus = TaskStatus.done;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final cubit = context.read<TaskCubit>();

    if (widget.task.title != _titleController.text ||
        widget.task.description != _descController.text ||
        widget.task.status != _currentStatus ||
        widget.task.reminderTime != _reminderTime) {
      widget.task.title = _titleController.text;
      widget.task.description = _descController.text;
      widget.task.status = _currentStatus;

      // ✅ تحديث التذكير
      widget.task.reminderTime = _isReminderEnabled ? _reminderTime : null;

      if (_currentStatus == TaskStatus.done) {
        widget.task.isCompleted = true;
        widget.task.completedAt = DateTime.now();
      } else {
        widget.task.isCompleted = false;
        widget.task.completedAt = null;
      }

      cubit.updateTask(widget.task);
    }
  }

  String _getSpaceType() {
    if (widget.task.spaceId != null && widget.task.spaceId!.isNotEmpty) {
      return 'shared';
    }
    return 'personal';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _saveChanges();
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            elevation: 0,
            leading: BackButton(
              color: colorScheme.onSurface,
              onPressed: () {
                _saveChanges();
                Navigator.pop(context);
              },
            ),
            title: Text(
              l10n.taskDetails,
              style: TextStyle(color: colorScheme.onSurface),
            ),
            centerTitle: true,
            actions: [
              AtharButton.icon(
                icon: Icons.delete_outline,
                onPressed: () {
                  context.read<TaskCubit>().deleteTask(widget.task.id);
                  Navigator.pop(context);
                },
              ),
            ],
            // ✅ شريط التبويبات
            bottom: TabBar(
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.outline,
              indicatorColor: colorScheme.primary,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
              tabs: [
                Tab(text: l10n.details),
                Tab(text: l10n.boardsAndTeam),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildDetailsTab(),
              TaskBoardWidget(taskId: widget.task.uuid),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        // 1. العنوان
        AtharTextField.borderless(
          controller: _titleController,
          hint: l10n.taskTitleHint,
          textStyle: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          maxLines: null,
        ),
        AtharGap.xl,

        // 2. شريط الحالة
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: AtharRadii.radiusMd,
          ),
          child: Row(
            children: [
              _buildStatusOption(
                TaskStatus.todo,
                l10n.statusWaiting,
                Icons.circle_outlined,
                colorScheme.outline,
              ),
              _buildStatusOption(
                TaskStatus.inProgress,
                l10n.statusInProgress,
                Icons.hourglass_top,
                Colors.blue,
              ),
              _buildStatusOption(
                TaskStatus.done,
                l10n.statusCompleted,
                Icons.check_circle,
                _successColor,
              ),
            ],
          ),
        ),
        AtharGap.xxl,

        // 3. البيانات الوصفية
        _buildMetaSection(),
        AtharGap.xxl,

        // 4. الوصف
        Text(
          l10n.descriptionAndNotes,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        AtharGap.sm,
        Container(
          padding: AtharSpacing.allLg,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: AtharRadii.radiusMd,
          ),
          child: AtharTextField(
            controller: _descController,
            variant: AtharTextFieldVariant.borderless,
            hint: l10n.addDetailsHint,
            maxLines: 8,
            customStyle: AtharTextFieldStyle(
              textStyle: TextStyle(height: 1.5, fontSize: 14.sp),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        AtharGap.xxl,

        // ✅ إضافة ودجت المرفقات
        AttachmentsWidget(taskId: widget.task.uuid, spaceType: _getSpaceType()),

        SizedBox(height: 40.h), // مسافة في الأسفل
      ],
    );
  }

  Widget _buildStatusOption(
    TaskStatus status,
    String label,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _currentStatus == status;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentStatus = status),
        child: AnimatedContainer(
          duration: AtharAnimations.fast,
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : colorScheme.outline,
                size: 20.sp,
              ),
              AtharGap.xxs,
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaSection() {
    final l10n = AppLocalizations.of(context);
    String categoryName = l10n.generalCategory;
    if (widget.task.category.value != null) {
      categoryName = widget.task.category.value!.name;
    }

    return Column(
      children: [
        _buildMetaRow(
          Icons.category_outlined,
          l10n.classification,
          categoryName,
        ),
        _buildMetaRow(
          Icons.calendar_today_outlined,
          l10n.dueDate,
          DateFormat('d MMM, h:mm a', 'ar').format(widget.task.date),
        ),
        _buildReminderSection(),
      ],
    );
  }

  /// ✅ قسم التذكيرات
  Widget _buildReminderSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: AtharSpacing.allLg,
      decoration: BoxDecoration(
        color: _isReminderEnabled
            ? _warningColor.withValues(alpha: 0.08)
            : colorScheme.surfaceContainerLowest,
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(
          color: _isReminderEnabled
              ? _warningColor.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان والـ Switch
          Row(
            children: [
              Icon(
                _isReminderEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_outlined,
                color: _isReminderEnabled ? _warningColor : colorScheme.outline,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reminder,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      _isReminderEnabled
                          ? l10n.willRemindBeforeDue
                          : l10n.noReminder,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isReminderEnabled,
                onChanged: (val) {
                  setState(() {
                    _isReminderEnabled = val;
                    if (!val) {
                      _reminderTime = null;
                    }
                  });
                },
                activeThumbColor: _warningColor,
              ),
            ],
          ),

          // وقت التذكير (إذا مفعل)
          if (_isReminderEnabled) ...[
            AtharGap.md,
            Divider(color: _warningColor.withValues(alpha: 0.2), height: 1),
            AtharGap.md,

            InkWell(
              onTap: () => _pickReminderTime(context),
              borderRadius: AtharRadii.radiusSm,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: AtharRadii.radiusSm,
                  border: Border.all(
                    color: _warningColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 18.sp,
                      color: _warningColor,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        _reminderTime != null
                            ? DateFormat(
                                'd MMM, h:mm a',
                                'ar',
                              ).format(_reminderTime!)
                            : l10n.selectReminderTime,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: _reminderTime != null
                              ? _warningColor
                              : colorScheme.outline,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 20.sp,
                      color: colorScheme.outline,
                    ),
                  ],
                ),
              ),
            ),

            // اقتراحات سريعة
            AtharGap.md,
            Text(
              l10n.quickSuggestions,
              style: TextStyle(
                fontSize: 11.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            AtharGap.sm,
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildQuickReminderChip(
                  l10n.tenMinutes,
                  const Duration(minutes: 10),
                ),
                _buildQuickReminderChip(
                  l10n.thirtyMinutes,
                  const Duration(minutes: 30),
                ),
                _buildQuickReminderChip(l10n.oneHour, const Duration(hours: 1)),
                _buildQuickReminderChip(l10n.oneDay, const Duration(days: 1)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// شريحة اقتراح سريع
  Widget _buildQuickReminderChip(String label, Duration beforeTask) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final suggestedTime = widget.task.date.subtract(beforeTask);
    final bool isValidTime = suggestedTime.isAfter(DateTime.now());
    final bool isSelected =
        _reminderTime != null &&
        _reminderTime!.difference(suggestedTime).inMinutes.abs() < 2;

    return InkWell(
      onTap: isValidTime
          ? () {
              setState(() {
                _reminderTime = suggestedTime;
              });
            }
          : null,
      borderRadius: AtharRadii.radiusLg,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: !isValidTime
              ? colorScheme.outline.withValues(alpha: 0.2)
              : isSelected
              ? _warningColor.withValues(alpha: 0.4)
              : _warningColor.withValues(alpha: 0.15),
          borderRadius: AtharRadii.radiusLg,
          border: isSelected
              ? Border.all(color: _warningColor, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(left: 4.w),
                child: Icon(
                  Icons.check_circle,
                  size: 14.sp,
                  color: _warningColor,
                ),
              ),
            Text(
              l10n.beforeDuration(label),
              style: TextStyle(
                fontSize: 11.sp,
                color: !isValidTime ? colorScheme.outline : _warningColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                decoration: !isValidTime ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ دالة اختيار وقت التذكير
  Future<void> _pickReminderTime(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final initialDate = _reminderTime ?? DateTime.now();

    // ✅ تخصيص ثيم DatePicker بألوان نظام أثر
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(DateTime.now())
          ? initialDate
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: widget.task.date,
      locale: const Locale('ar', 'SA'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorScheme.primary,
              onPrimary: colorScheme.surface,
              surface: colorScheme.surface,
              onSurface: colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null || !context.mounted) return;

    // ✅ تخصيص ثيم TimePicker بألوان نظام أثر
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime != null
          ? TimeOfDay.fromDateTime(_reminderTime!)
          : TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorScheme.primary,
              onPrimary: colorScheme.surface,
              surface: colorScheme.surface,
              onSurface: colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null || !context.mounted) return;
    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (selectedDateTime.isAfter(DateTime.now()) &&
        selectedDateTime.isBefore(widget.task.date)) {
      setState(() {
        _reminderTime = selectedDateTime;
      });
    } else {
      if (context.mounted) {
        String errorMessage;
        if (selectedDateTime.isBefore(DateTime.now())) {
          errorMessage = l10n.cannotPickPastTime;
        } else {
          errorMessage = l10n.reminderMustBeBeforeTask;
        }

        AtharSnackbar.warning(context: context, message: errorMessage);
      }
    }
  }

  /// ✅ دالة مساعدة لعرض صف البيانات
  Widget _buildMetaRow(IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: colorScheme.outline),
          AtharGap.hMd,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10.sp, color: colorScheme.outline),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
// ————-————— code end ————————-
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:athar/features/task/presentation/widgets/attachments_widget.dart';
// // ✅ استيراد ودجت السبورة
// import 'package:athar/features/task/presentation/widgets/task_board_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class TaskDetailsPage extends StatefulWidget {
//   final TaskModel task;
//   const TaskDetailsPage({super.key, required this.task});

//   @override
//   State<TaskDetailsPage> createState() => _TaskDetailsPageState();
// }

// class _TaskDetailsPageState extends State<TaskDetailsPage> {
//   late TextEditingController _titleController;
//   late TextEditingController _descController;
//   late TaskStatus _currentStatus;

//   // ✅ متغيرات التذكير الجديدة
//   late bool _isReminderEnabled;
//   DateTime? _reminderTime;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.task.title);
//     _descController = TextEditingController(
//       text: widget.task.description ?? "",
//     );
//     _currentStatus = widget.task.status;

//     // ✅ تهيئة التذكير
//     _isReminderEnabled = widget.task.reminderTime != null;
//     _reminderTime = widget.task.reminderTime;

//     // تصحيح حالة الإكمال
//     if (widget.task.isCompleted && _currentStatus != TaskStatus.done) {
//       _currentStatus = TaskStatus.done;
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descController.dispose();
//     super.dispose();
//   }

//   void _saveChanges() {
//     final cubit = context.read<TaskCubit>();

//     if (widget.task.title != _titleController.text ||
//         widget.task.description != _descController.text ||
//         widget.task.status != _currentStatus ||
//         widget.task.reminderTime != _reminderTime) {
//       widget.task.title = _titleController.text;
//       widget.task.description = _descController.text;
//       widget.task.status = _currentStatus;

//       // ✅ تحديث التذكير
//       widget.task.reminderTime = _isReminderEnabled ? _reminderTime : null;

//       if (_currentStatus == TaskStatus.done) {
//         widget.task.isCompleted = true;
//         widget.task.completedAt = DateTime.now();
//       } else {
//         widget.task.isCompleted = false;
//         widget.task.completedAt = null;
//       }

//       cubit.updateTask(widget.task);
//     }
//   }

//   String _getSpaceType() {
//     if (widget.task.spaceId != null && widget.task.spaceId!.isNotEmpty) {
//       return 'shared';
//     }
//     return 'personal';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return PopScope(
//       canPop: true,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) _saveChanges();
//       },
//       child: DefaultTabController(
//         length: 2,
//         child: Scaffold(
//           backgroundColor: colors.surface,
//           appBar: AppBar(
//             backgroundColor: colors.surface,
//             elevation: 0,
//             leading: BackButton(
//               color: colors.textPrimary,
//               onPressed: () {
//                 _saveChanges();
//                 Navigator.pop(context);
//               },
//             ),
//             title: Text(
//               l10n.taskDetails,
//               style: TextStyle(
//                 color: colors.textPrimary,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             centerTitle: true,
//             actions: [
//               AtharButton.icon(
//                 icon: Icons.delete_outline,
//                 onPressed: () {
//                   context.read<TaskCubit>().deleteTask(widget.task.id);
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//             // ✅ شريط التبويبات
//             bottom: TabBar(
//               labelColor: colors.primary,
//               unselectedLabelColor: colors.textTertiary,
//               indicatorColor: colors.primary,
//               labelStyle: TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14.sp,
//               ),
//               tabs: [
//                 Tab(text: l10n.details),
//                 Tab(text: l10n.boardsAndTeam),
//               ],
//             ),
//           ),
//           body: TabBarView(
//             children: [
//               _buildDetailsTab(),
//               TaskBoardWidget(taskId: widget.task.uuid),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailsTab() {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return ListView(
//       padding: EdgeInsets.all(20.w),
//       children: [
//         // 1. العنوان
//         AtharTextField.borderless(
//           controller: _titleController,
//           hint: l10n.taskTitleHint,
//           textStyle: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
//           maxLines: null,
//         ),
//         AtharGap.xl,

//         // 2. شريط الحالة
//         Container(
//           padding: EdgeInsets.all(4.w),
//           decoration: BoxDecoration(
//             color: colors.scaffoldBackground,
//             borderRadius: AtharRadii.radiusMd,
//           ),
//           child: Row(
//             children: [
//               _buildStatusOption(
//                 TaskStatus.todo,
//                 l10n.statusWaiting,
//                 Icons.circle_outlined,
//                 colors.textTertiary,
//               ),
//               _buildStatusOption(
//                 TaskStatus.inProgress,
//                 l10n.statusInProgress,
//                 Icons.hourglass_top,
//                 Colors.blue,
//               ),
//               _buildStatusOption(
//                 TaskStatus.done,
//                 l10n.statusCompleted,
//                 Icons.check_circle,
//                 colors.success,
//               ),
//             ],
//           ),
//         ),
//         AtharGap.xxl,

//         // 3. البيانات الوصفية
//         _buildMetaSection(),
//         AtharGap.xxl,

//         // 4. الوصف
//         Text(
//           l10n.descriptionAndNotes,
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//         ),
//         AtharGap.sm,
//         Container(
//           padding: AtharSpacing.allLg,
//           decoration: BoxDecoration(
//             color: colors.scaffoldBackground,
//             borderRadius: AtharRadii.radiusMd,
//           ),
//           child: AtharTextField(
//             controller: _descController,
//             variant: AtharTextFieldVariant.borderless,
//             hint: l10n.addDetailsHint,
//             maxLines: 8,
//             customStyle: AtharTextFieldStyle(
//               textStyle: TextStyle(height: 1.5, fontSize: 14.sp),
//               contentPadding: EdgeInsets.zero,
//             ),
//           ),
//         ),
//         AtharGap.xxl,

//         // ✅ إضافة ودجت المرفقات
//         AttachmentsWidget(taskId: widget.task.uuid, spaceType: _getSpaceType()),

//         SizedBox(height: 40.h), // مسافة في الأسفل
//       ],
//     );
//   }

//   Widget _buildStatusOption(
//     TaskStatus status,
//     String label,
//     IconData icon,
//     Color color,
//   ) {
//     final colors = context.colors;
//     final isSelected = _currentStatus == status;

//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _currentStatus = status),
//         child: AnimatedContainer(
//           duration: AtharAnimations.fast,
//           padding: EdgeInsets.symmetric(vertical: 10.h),
//           decoration: BoxDecoration(
//             color: isSelected ? colors.surface : Colors.transparent,
//             borderRadius: BorderRadius.circular(10.r),
//             boxShadow: isSelected
//                 ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
//                 : [],
//           ),
//           child: Column(
//             children: [
//               Icon(
//                 icon,
//                 color: isSelected ? color : colors.textTertiary,
//                 size: 20.sp,
//               ),
//               AtharGap.xxs,
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   color: isSelected ? color : colors.textTertiary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMetaSection() {
//     final l10n = AppLocalizations.of(context);
//     String categoryName = l10n.generalCategory;
//     if (widget.task.category.value != null) {
//       categoryName = widget.task.category.value!.name;
//     }

//     return Column(
//       children: [
//         _buildMetaRow(
//           Icons.category_outlined,
//           l10n.classification,
//           categoryName,
//         ),
//         _buildMetaRow(
//           Icons.calendar_today_outlined,
//           l10n.dueDate,
//           DateFormat('d MMM, h:mm a', 'ar').format(widget.task.date),
//         ),
//         _buildReminderSection(),
//       ],
//     );
//   }

//   /// ✅ قسم التذكيرات
//   Widget _buildReminderSection() {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return Container(
//       padding: AtharSpacing.allLg,
//       decoration: BoxDecoration(
//         color: _isReminderEnabled
//             ? colors.warning.withOpacity(0.08)
//             : colors.scaffoldBackground,
//         borderRadius: AtharRadii.radiusMd,
//         border: Border.all(
//           color: _isReminderEnabled
//               ? colors.warning.withOpacity(0.3)
//               : colors.textTertiary.withOpacity(0.2),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // العنوان والـ Switch
//           Row(
//             children: [
//               Icon(
//                 _isReminderEnabled
//                     ? Icons.notifications_active_rounded
//                     : Icons.notifications_off_outlined,
//                 color: _isReminderEnabled
//                     ? colors.warning
//                     : colors.textTertiary,
//                 size: 22.sp,
//               ),
//               SizedBox(width: 10.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       l10n.reminder,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14.sp,
//                         fontFamily: 'Tajawal',
//                       ),
//                     ),
//                     Text(
//                       _isReminderEnabled
//                           ? l10n.willRemindBeforeDue
//                           : l10n.noReminder,
//                       style: TextStyle(
//                         color: colors.textSecondary,
//                         fontSize: 11.sp,
//                         fontFamily: 'Tajawal',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Switch(
//                 value: _isReminderEnabled,
//                 onChanged: (val) {
//                   setState(() {
//                     _isReminderEnabled = val;
//                     if (!val) {
//                       _reminderTime = null;
//                     }
//                   });
//                 },
//                 activeThumbColor: colors.warning,
//               ),
//             ],
//           ),

//           // وقت التذكير (إذا مفعل)
//           if (_isReminderEnabled) ...[
//             AtharGap.md,
//             Divider(color: colors.warning.withOpacity(0.2), height: 1),
//             AtharGap.md,

//             InkWell(
//               onTap: () => _pickReminderTime(context),
//               borderRadius: AtharRadii.radiusSm,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//                 decoration: BoxDecoration(
//                   color: colors.surface,
//                   borderRadius: AtharRadii.radiusSm,
//                   border: Border.all(color: colors.warning.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.access_time_rounded,
//                       size: 18.sp,
//                       color: colors.warning,
//                     ),
//                     SizedBox(width: 10.w),
//                     Expanded(
//                       child: Text(
//                         _reminderTime != null
//                             ? DateFormat(
//                                 'd MMM, h:mm a',
//                                 'ar',
//                               ).format(_reminderTime!)
//                             : l10n.selectReminderTime,
//                         style: TextStyle(
//                           fontSize: 13.sp,
//                           fontFamily: 'Tajawal',
//                           color: _reminderTime != null
//                               ? colors.warning
//                               : colors.textTertiary,
//                         ),
//                       ),
//                     ),
//                     Icon(
//                       Icons.chevron_left_rounded,
//                       size: 20.sp,
//                       color: colors.textTertiary,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // اقتراحات سريعة
//             AtharGap.md,
//             Text(
//               l10n.quickSuggestions,
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 color: colors.textSecondary,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             AtharGap.sm,
//             Wrap(
//               spacing: 8.w,
//               runSpacing: 8.h,
//               children: [
//                 _buildQuickReminderChip(
//                   l10n.tenMinutes,
//                   const Duration(minutes: 10),
//                 ),
//                 _buildQuickReminderChip(
//                   l10n.thirtyMinutes,
//                   const Duration(minutes: 30),
//                 ),
//                 _buildQuickReminderChip(l10n.oneHour, const Duration(hours: 1)),
//                 _buildQuickReminderChip(l10n.oneDay, const Duration(days: 1)),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   /// شريحة اقتراح سريع
//   Widget _buildQuickReminderChip(String label, Duration beforeTask) {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);
//     final suggestedTime = widget.task.date.subtract(beforeTask);
//     final bool isValidTime = suggestedTime.isAfter(DateTime.now());
//     final bool isSelected =
//         _reminderTime != null &&
//         _reminderTime!.difference(suggestedTime).inMinutes.abs() < 2;

//     return InkWell(
//       onTap: isValidTime
//           ? () {
//               setState(() {
//                 _reminderTime = suggestedTime;
//               });
//             }
//           : null,
//       borderRadius: AtharRadii.radiusLg,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//         decoration: BoxDecoration(
//           color: !isValidTime
//               ? colors.textTertiary.withOpacity(0.2)
//               : isSelected
//               ? colors.warning.withOpacity(0.4)
//               : colors.warning.withOpacity(0.15),
//           borderRadius: AtharRadii.radiusLg,
//           border: isSelected
//               ? Border.all(color: colors.warning, width: 2)
//               : null,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (isSelected)
//               Padding(
//                 padding: EdgeInsets.only(left: 4.w),
//                 child: Icon(
//                   Icons.check_circle,
//                   size: 14.sp,
//                   color: colors.warning,
//                 ),
//               ),
//             Text(
//               l10n.beforeDuration(label),
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 color: !isValidTime ? colors.textTertiary : colors.warning,
//                 fontFamily: 'Tajawal',
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 decoration: !isValidTime ? TextDecoration.lineThrough : null,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ✅ دالة اختيار وقت التذكير
//   Future<void> _pickReminderTime(BuildContext context) async {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);
//     final initialDate = _reminderTime ?? DateTime.now();

//     // ✅ تخصيص ثيم DatePicker بألوان نظام أثر
//     final date = await showDatePicker(
//       context: context,
//       initialDate: initialDate.isAfter(DateTime.now())
//           ? initialDate
//           : DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: widget.task.date,
//       locale: const Locale('ar', 'SA'),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: colors.primary,
//               onPrimary: colors.surface,
//               surface: colors.surface,
//               onSurface: colors.textPrimary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (date == null || !context.mounted) return;

//     // ✅ تخصيص ثيم TimePicker بألوان نظام أثر
//     final time = await showTimePicker(
//       context: context,
//       initialTime: _reminderTime != null
//           ? TimeOfDay.fromDateTime(_reminderTime!)
//           : TimeOfDay.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: colors.primary,
//               onPrimary: colors.surface,
//               surface: colors.surface,
//               onSurface: colors.textPrimary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (time == null || !context.mounted) return;
//     final selectedDateTime = DateTime(
//       date.year,
//       date.month,
//       date.day,
//       time.hour,
//       time.minute,
//     );

//     if (selectedDateTime.isAfter(DateTime.now()) &&
//         selectedDateTime.isBefore(widget.task.date)) {
//       setState(() {
//         _reminderTime = selectedDateTime;
//       });
//     } else {
//       if (context.mounted) {
//         String errorMessage;
//         if (selectedDateTime.isBefore(DateTime.now())) {
//           errorMessage = l10n.cannotPickPastTime;
//         } else {
//           errorMessage = l10n.reminderMustBeBeforeTask;
//         }

//         AtharSnackbar.warning(context: context, message: errorMessage);
//       }
//     }
//   }

//   /// ✅ دالة مساعدة لعرض صف البيانات
//   Widget _buildMetaRow(IconData icon, String label, String value) {
//     final colors = context.colors;

//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Row(
//         children: [
//           Icon(icon, size: 20.sp, color: colors.textTertiary),
//           AtharGap.hMd,
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 10.sp, color: colors.textTertiary),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------


// // ✅ استيراد ودجت السبورة




//   // ✅ متغيرات التذكير الجديدة

//       text: widget.task.description ?? "",

//     // ✅ تهيئة التذكير

//     // تصحيح حالة الإكمال



//     // نتحقق هل حدث تغيير فعلياً
//       // ✅ إضافة فحص التذكير


//       // ✅ تحديث التذكير


//       cubit.updateTask(
//         widget.task,
//       ); // ✅ استخدم updateTask بدلاً من addTaskModel

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅✅✅ إصلاح TODO #1: دالة لتحديد نوع المساحة الحقيقي
//   // ═══════════════════════════════════════════════════════════════════════════
//     // إذا كانت المهمة تابعة لمساحة (spaceId موجود وغير فارغ)، فهي shared
//     // وإلا فهي personal

//       canPop: true,
//       },
//       child: DefaultTabController(
//         // ✅ 1. إضافة التحكم بالتبويبات
//         length: 2,
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             leading: BackButton(
//               color: Colors.black,
//               },
//             ),
//             title: const Text(
//               l10n.taskDetails,
//               style: TextStyle(color: Colors.black, fontFamily: 'Tajawal'),
//             ),
//             centerTitle: true,
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.delete_outline, color: Colors.red),
//                 },
//               ),
//             // ✅ 2. شريط التبويبات الجديد
//             bottom: TabBar(
//               labelColor: AppColors.primary,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: AppColors.primary,
//               labelStyle: TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14.sp,
//               ),
//               tabs: [
//                 Tab(text: l10n.details),
//                 Tab(text: l10n.boardsAndTeam),
//             ),
//           ),
//           body: TabBarView(
//             children: [
//               // ✅ 3. التبويب الأول: المحتوى القديم (التفاصيل)
//               _buildDetailsTab(),

//               // ✅ 4. التبويب الثاني: السبورات (Widget الجديد)
//               TaskBoardWidget(taskId: widget.task.uuid),
//           ),
//         ),
//       ),

//   // تم نقل المحتوى القديم هنا لترتيب الكود
//       padding: EdgeInsets.all(20.w),
//       children: [
//         // 1. العنوان
//         TextField(
//           controller: _titleController,
//           style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
//           decoration: const InputDecoration(
//             border: InputBorder.none,
//             hintText: "عنوان المهمة",
//           ),
//           maxLines: null,
//         ),
//         SizedBox(height: 20.h),

//         // 2. شريط الحالة
//         Container(
//           padding: EdgeInsets.all(4.w),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           child: Row(
//             children: [
//               _buildStatusOption(
//                 TaskStatus.todo,
//                 "قائمة الانتظار",
//                 Icons.circle_outlined,
//                 Colors.grey,
//               ),
//               _buildStatusOption(
//                 TaskStatus.inProgress,
//                 "جاري التنفيذ",
//                 Icons.hourglass_top,
//                 Colors.blue,
//               ),
//               _buildStatusOption(
//                 TaskStatus.done,
//                 "مكتملة",
//                 Icons.check_circle,
//                 Colors.green,
//               ),
//           ),
//         ),
//         SizedBox(height: 24.h),

//         // 3. البيانات الوصفية
//         _buildMetaSection(),
//         SizedBox(height: 24.h),

//         // 4. الوصف
//         Text(
//           "الوصف والملاحظات",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//         ),
//         SizedBox(height: 8.h),
//         Container(
//           padding: EdgeInsets.all(16.w),
//           decoration: BoxDecoration(
//             color: AppColors.background,
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           child: TextField(
//             controller: _descController,
//             decoration: const InputDecoration.collapsed(
//               hintText: "أضف تفاصيل، روابط، أو ملاحظات فرعية...",
//             ),
//             maxLines: 8,
//             style: TextStyle(height: 1.5, fontSize: 14.sp),
//           ),
//         ),
//         SizedBox(height: 24.h),

//         // ✅ إضافة ودجت المرفقات
//         // تمرير نوع المساحة الحقيقي
//         AttachmentsWidget(taskId: widget.task.uuid, spaceType: _getSpaceType()),

//         SizedBox(height: 40.h), // مسافة في الأسفل

//     TaskStatus status,
//     String label,
//     IconData icon,
//     Color color,
//       child: GestureDetector(
//         onTap: () => setState(() => _currentStatus = status),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: EdgeInsets.symmetric(vertical: 10.h),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.white : Colors.transparent,
//             borderRadius: BorderRadius.circular(10.r),
//             boxShadow: isSelected
//                 ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
//                 : [],
//           ),
//           child: Column(
//             children: [
//               Icon(icon, color: isSelected ? color : Colors.grey, size: 20.sp),
//               SizedBox(height: 4.h),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   color: isSelected ? color : Colors.grey,
//                 ),
//               ),
//           ),
//         ),
//       ),

//     // التحقق من أن الرابط ليس فارغاً وأن القيمة محملة

//       children: [
//         _buildMetaRow(Icons.category_outlined, "التصنيف", categoryName),
//         _buildMetaRow(
//           Icons.calendar_today_outlined,
//           "الموعد",
//           DateFormat('d MMM, h:mm a', 'ar').format(widget.task.date),
//         ),
//         // ✅ قسم التذكيرات الجديد
//         _buildReminderSection(),

//   /// ✅ قسم التذكيرات الجديد
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: _isReminderEnabled ? Colors.amber.shade50 : Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(
//           color: _isReminderEnabled
//               ? Colors.amber.shade200
//               : Colors.grey.shade200,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // العنوان والـ Switch
//           Row(
//             children: [
//               Icon(
//                 _isReminderEnabled
//                     ? Icons.notifications_active_rounded
//                     : Icons.notifications_off_outlined,
//                 color: _isReminderEnabled ? Colors.amber.shade700 : Colors.grey,
//                 size: 22.sp,
//               ),
//               SizedBox(width: 10.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "التذكير",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14.sp,
//                         fontFamily: 'Tajawal',
//                       ),
//                     ),
//                     Text(
//                       _isReminderEnabled
//                           ? l10n.willRemindBeforeDue
//                           : l10n.noReminder,
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 11.sp,
//                         fontFamily: 'Tajawal',
//                       ),
//                     ),
//                 ),
//               ),
//               Switch(
//                 value: _isReminderEnabled,
//                 },
//                 activeThumbColor: Colors.amber.shade700,
//               ),
//           ),

//           // وقت التذكير (إذا مفعل)
//             SizedBox(height: 12.h),
//             Divider(color: Colors.amber.shade100, height: 1),
//             SizedBox(height: 12.h),

//             InkWell(
//               borderRadius: BorderRadius.circular(8.r),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8.r),
//                   border: Border.all(color: Colors.amber.shade200),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.access_time_rounded,
//                       size: 18.sp,
//                       color: Colors.amber.shade700,
//                     ),
//                     SizedBox(width: 10.w),
//                     Expanded(
//                       child: Text(
//                             ? DateFormat(
//                                 'd MMM, h:mm a',
//                                 'ar',
//                               ).format(_reminderTime!)
//                             : l10n.selectReminderTime,
//                         style: TextStyle(
//                           fontSize: 13.sp,
//                           fontFamily: 'Tajawal',
//                               ? Colors.amber.shade800
//                               : Colors.grey,
//                         ),
//                       ),
//                     ),
//                     Icon(
//                       Icons.chevron_left_rounded,
//                       size: 20.sp,
//                       color: Colors.grey,
//                     ),
//                 ),
//               ),
//             ),

//             // اقتراحات سريعة
//             SizedBox(height: 12.h),
//             Text(
//               l10n.quickSuggestions,
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 color: Colors.grey.shade600,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Wrap(
//               spacing: 8.w,
//               runSpacing: 8.h,
//               children: [
//                 _buildQuickReminderChip(
//                   "10 دقائق",
//                 ),
//                 _buildQuickReminderChip(
//                   "30 دقيقة",
//                 ),
//                 _buildQuickReminderChip("ساعة", const Duration(hours: 1)),
//                 _buildQuickReminderChip("يوم", const Duration(days: 1)),
//             ),
//       ),

//   /// شريحة اقتراح سريع
//   // حساب وقت التذكير بناءً على وقت المهمة
//     // ✅ حساب الوقت المقترح بناءً على وقت المهمة

//     // ✅ التحقق من أن الوقت المقترح في المستقبل

//     // ✅ التحقق هل هذا الخيار محدد حالياً (مقارنة دقيقة بالدقائق)

//       onTap: isValidTime
//               // حساب الوقت وتحديث الحالة
//           : null, // ✅ تعطيل الزر إذا كان الوقت في الماضي
//       // },
//       borderRadius: BorderRadius.circular(16.r),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//         decoration: BoxDecoration(
//           color: !isValidTime
//               ? Colors
//                     .grey
//                     .shade200 // ✅ رمادي إذا كان الوقت في الماضي
//               : isSelected
//               ? Colors
//                     .amber
//                     .shade300 // ✅ أغمق إذا محدد
//               : Colors.amber.shade100,
//           borderRadius: BorderRadius.circular(16.r),
//           border: isSelected
//               ? Border.all(color: Colors.amber.shade700, width: 2)
//               : null,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ✅ أيقونة التحديد إذا كان الخيار محدداً
//               Padding(
//                 padding: EdgeInsets.only(left: 4.w),
//                 child: Icon(
//                   Icons.check_circle,
//                   size: 14.sp,
//                   color: Colors.amber.shade800,
//                 ),
//               ),
//             Text(
//               "قبل $label",
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 color: !isValidTime
//                     ? Colors
//                           .grey
//                           .shade500 // ✅ رمادي إذا كان في الماضي
//                     : Colors.amber.shade800,
//                 fontFamily: 'Tajawal',
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 // ✅ خط يتوسطه إذا كان غير متاح
//                 decoration: !isValidTime ? TextDecoration.lineThrough : null,
//               ),
//             ),
//         ),
//       ),

//   /// ✅ دالة اختيار وقت التذكير
//     // ✅ تحديد التاريخ الأولي بشكل ذكي
//       context: context,
//       initialDate: initialDate.isAfter(DateTime.now())
//           ? initialDate
//           : DateTime.now(),
//       firstDate: DateTime.now(),
//       // lastDate: DateTime(2030),
//       lastDate: widget.task.date, // ✅ لا يمكن اختيار تاريخ بعد المهمة
//       locale: const Locale('ar', 'SA'),


//       context: context,
//           ? TimeOfDay.fromDateTime(_reminderTime!)
//           : TimeOfDay.now(),

//       date.year,
//       date.month,
//       date.day,
//       time.hour,
//       time.minute,

//     // ✅ التحقق من أن الوقت المختار قبل وقت المهمة وفي المستقبل
//       // ✅ عرض رسالة خطأ مناسبة

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 SizedBox(width: 8.w),
//                 Text(
//                   errorMessage,
//                   style: const TextStyle(fontFamily: 'Tajawal'),
//                 ),
//             ),
//             backgroundColor: Colors.red.shade700,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             margin: EdgeInsets.all(16.w),
//           ),

//   /// ✅ دالة مساعدة لعرض صف البيانات
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Row(
//         children: [
//           Icon(icon, size: 20.sp, color: Colors.grey),
//           SizedBox(width: 12.w),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
//               ),
//           ),
//       ),





//       text: widget.task.description ?? "",

//     // تصحيح: إذا كانت مكتملة ولكن الستاتس لم يحدث


//   // حفظ التغييرات عند الخروج
//     // نستخدم copyWith أو نعدل الكائن (يفضل copyWith في التطبيقات الكبيرة)
//     // هنا سنعدل الكائن مباشرة للسهولة مع Isar

//     // تحديث الإكمال بناءً على الستاتس

//     cubit.addTaskModel(widget.task); // دالة التحديث

//       canPop: true, // نسمح بالرجوع
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: BackButton(
//             color: Colors.black,
//             },
//           ),
//           actions: [
//             IconButton(
//               icon: Icon(Icons.delete_outline, color: Colors.red),
//               },
//             ),
//         ),
//         body: ListView(
//           padding: EdgeInsets.all(20.w),
//           children: [
//             // 1. العنوان (قابل للتعديل)
//             TextField(
//               controller: _titleController,
//               style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 hintText: "عنوان المهمة",
//               ),
//               maxLines: null,
//             ),
//             SizedBox(height: 20.h),

//             // 2. شريط الحالة (Status Selector)
//             Container(
//               padding: EdgeInsets.all(4.w),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Row(
//                 children: [
//                   _buildStatusOption(
//                     TaskStatus.todo,
//                     "قائمة الانتظار",
//                     Icons.circle_outlined,
//                     Colors.grey,
//                   ),
//                   _buildStatusOption(
//                     TaskStatus.inProgress,
//                     "جاري التنفيذ",
//                     Icons.hourglass_top,
//                     Colors.blue,
//                   ),
//                   _buildStatusOption(
//                     TaskStatus.done,
//                     "مكتملة",
//                     Icons.check_circle,
//                     Colors.green,
//                   ),
//               ),
//             ),
//             SizedBox(height: 24.h),

//             // 3. البيانات الوصفية (المشروع، التصنيف، الوقت)
//             _buildMetaSection(),
//             SizedBox(height: 24.h),

//             // 4. الوصف (Description)
//             Text(
//               "الوصف والملاحظات",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//             ),
//             SizedBox(height: 8.h),
//             Container(
//               padding: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 color: AppColors.background,
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: TextField(
//                 controller: _descController,
//                 decoration: InputDecoration.collapsed(
//                   hintText: "أضف تفاصيل، روابط، أو ملاحظات فرعية...",
//                 ),
//                 maxLines: 8,
//                 style: TextStyle(height: 1.5, fontSize: 14.sp),
//               ),
//             ),
//         ),
//       ),

//     TaskStatus status,
//     String label,
//     IconData icon,
//     Color color,
//       child: GestureDetector(
//         onTap: () => setState(() => _currentStatus = status),
//         child: AnimatedContainer(
//           duration: Duration(milliseconds: 200),
//           padding: EdgeInsets.symmetric(vertical: 10.h),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.white : Colors.transparent,
//             borderRadius: BorderRadius.circular(10.r),
//             boxShadow: isSelected
//                 ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
//                 : [],
//           ),
//           child: Column(
//             children: [
//               Icon(icon, color: isSelected ? color : Colors.grey, size: 20.sp),
//               SizedBox(height: 4.h),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   color: isSelected ? color : Colors.grey,
//                 ),
//               ),
//           ),
//         ),
//       ),

//     // ✅ جلب اسم التصنيف من الرابط الديناميكي
//     // نتأكد أن القيمة تم تحميلها (IsarLink يقوم بالتحميل التلقائي عند الوصول للقيمة إذا كانت محملة، أو يمكن استخدام loadSync)

//       children: [
//         _buildMetaRow(
//           Icons.category_outlined,
//           "التصنيف",
//           categoryName, // ✅ الاسم الجديد
//         ),
//         //   _buildMetaRow(
//         //     Icons.folder_outlined,
//         //     "المشروع",
//         //     widget.task.project.value!.title,
//         //   ),
//         _buildMetaRow(
//           Icons.calendar_today_outlined,
//           "الموعد",
//           DateFormat('d MMM, h:mm a', 'ar').format(widget.task.date),
//         ),

//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Row(
//         children: [
//           Icon(icon, size: 20.sp, color: Colors.grey),
//           SizedBox(width: 12.w),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
//               ),
//           ),
//       ),

//------------------------------------------------------------------------
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:athar/features/task/presentation/widgets/attachments_widget.dart';
// // ✅ استيراد ودجت السبورة
// import 'package:athar/features/task/presentation/widgets/task_board_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class TaskDetailsPage extends StatefulWidget {
//   final TaskModel task;
//   const TaskDetailsPage({super.key, required this.task});

//   @override
//   State<TaskDetailsPage> createState() => _TaskDetailsPageState();
// }

// class _TaskDetailsPageState extends State<TaskDetailsPage> {
//   late TextEditingController _titleController;
//   late TextEditingController _descController;
//   late TaskStatus _currentStatus;

//   // ✅ متغيرات التذكير الجديدة
//   late bool _isReminderEnabled;
//   DateTime? _reminderTime;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.task.title);
//     _descController = TextEditingController(
//       text: widget.task.description ?? "",
//     );
//     _currentStatus = widget.task.status;

//     // ✅ تهيئة التذكير
//     _isReminderEnabled = widget.task.reminderTime != null;
//     _reminderTime = widget.task.reminderTime;

//     // تصحيح حالة الإكمال
//     if (widget.task.isCompleted && _currentStatus != TaskStatus.done) {
//       _currentStatus = TaskStatus.done;
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descController.dispose();
//     super.dispose();
//   }

//   void _saveChanges() {
//     final cubit = context.read<TaskCubit>();

//     if (widget.task.title != _titleController.text ||
//         widget.task.description != _descController.text ||
//         widget.task.status != _currentStatus ||
//         widget.task.reminderTime != _reminderTime) {
//       widget.task.title = _titleController.text;
//       widget.task.description = _descController.text;
//       widget.task.status = _currentStatus;

//       // ✅ تحديث التذكير
//       widget.task.reminderTime = _isReminderEnabled ? _reminderTime : null;

//       if (_currentStatus == TaskStatus.done) {
//         widget.task.isCompleted = true;
//         widget.task.completedAt = DateTime.now();
//       } else {
//         widget.task.isCompleted = false;
//         widget.task.completedAt = null;
//       }

//       cubit.updateTask(widget.task);
//     }
//   }

//   String _getSpaceType() {
//     if (widget.task.spaceId != null && widget.task.spaceId!.isNotEmpty) {
//       return 'shared';
//     }
//     return 'personal';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return PopScope(
//       canPop: true,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) _saveChanges();
//       },
//       child: DefaultTabController(
//         length: 2,
//         child: Scaffold(
//           backgroundColor: colors.surface,
//           appBar: AppBar(
//             backgroundColor: colors.surface,
//             elevation: 0,
//             leading: BackButton(
//               color: colors.textPrimary,
//               onPressed: () {
//                 _saveChanges();
//                 Navigator.pop(context);
//               },
//             ),
//             title: Text(
//               "تفاصيل المهمة",
//               style: TextStyle(
//                 color: colors.textPrimary,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             centerTitle: true,
//             actions: [
//               AtharButton.icon(
//                 icon: Icons.delete_outline,
//                 onPressed: () {
//                   context.read<TaskCubit>().deleteTask(widget.task.id);
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//             // ✅ شريط التبويبات
//             bottom: TabBar(
//               labelColor: colors.primary,
//               unselectedLabelColor: colors.textTertiary,
//               indicatorColor: colors.primary,
//               labelStyle: TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14.sp,
//               ),
//               tabs: const [
//                 Tab(text: "التفاصيل"),
//                 Tab(text: "السبورات & الفريق"),
//               ],
//             ),
//           ),
//           body: TabBarView(
//             children: [
//               _buildDetailsTab(),
//               TaskBoardWidget(taskId: widget.task.uuid),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailsTab() {
//     final colors = context.colors;

//     return ListView(
//       padding: EdgeInsets.all(20.w),
//       children: [
//         // 1. العنوان
//         AtharTextField.borderless(
//           controller: _titleController,
//           hint: "عنوان المهمة",
//           textStyle: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
//           maxLines: null,
//         ),
//         AtharGap.xl,

//         // 2. شريط الحالة
//         Container(
//           padding: EdgeInsets.all(4.w),
//           decoration: BoxDecoration(
//             color: colors.scaffoldBackground,
//             borderRadius: AtharRadii.radiusMd,
//           ),
//           child: Row(
//             children: [
//               _buildStatusOption(
//                 TaskStatus.todo,
//                 "قائمة الانتظار",
//                 Icons.circle_outlined,
//                 colors.textTertiary,
//               ),
//               _buildStatusOption(
//                 TaskStatus.inProgress,
//                 "جاري التنفيذ",
//                 Icons.hourglass_top,
//                 Colors.blue,
//               ),
//               _buildStatusOption(
//                 TaskStatus.done,
//                 "مكتملة",
//                 Icons.check_circle,
//                 colors.success,
//               ),
//             ],
//           ),
//         ),
//         AtharGap.xxl,

//         // 3. البيانات الوصفية
//         _buildMetaSection(),
//         AtharGap.xxl,

//         // 4. الوصف
//         Text(
//           "الوصف والملاحظات",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//         ),
//         AtharGap.sm,
//         Container(
//           padding: AtharSpacing.allLg,
//           decoration: BoxDecoration(
//             color: colors.scaffoldBackground,
//             borderRadius: AtharRadii.radiusMd,
//           ),
//           child: AtharTextField(
//             controller: _descController,
//             variant: AtharTextFieldVariant.borderless,
//             hint: "أضف تفاصيل، روابط، أو ملاحظات فرعية...",
//             maxLines: 8,
//             customStyle: AtharTextFieldStyle(
//               textStyle: TextStyle(height: 1.5, fontSize: 14.sp),
//               contentPadding: EdgeInsets.zero,
//             ),
//           ),
//         ),
//         AtharGap.xxl,

//         // ✅ إضافة ودجت المرفقات
//         AttachmentsWidget(taskId: widget.task.uuid, spaceType: _getSpaceType()),

//         SizedBox(height: 40.h), // مسافة في الأسفل
//       ],
//     );
//   }

//   Widget _buildStatusOption(
//     TaskStatus status,
//     String label,
//     IconData icon,
//     Color color,
//   ) {
//     final colors = context.colors;
//     final isSelected = _currentStatus == status;

//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _currentStatus = status),
//         child: AnimatedContainer(
//           duration: AtharAnimations.fast,
//           padding: EdgeInsets.symmetric(vertical: 10.h),
//           decoration: BoxDecoration(
//             color: isSelected ? colors.surface : Colors.transparent,
//             borderRadius: BorderRadius.circular(10.r),
//             boxShadow: isSelected
//                 ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
//                 : [],
//           ),
//           child: Column(
//             children: [
//               Icon(
//                 icon,
//                 color: isSelected ? color : colors.textTertiary,
//                 size: 20.sp,
//               ),
//               AtharGap.xxs,
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   color: isSelected ? color : colors.textTertiary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMetaSection() {
//     String categoryName = "عام";
//     if (widget.task.category.value != null) {
//       categoryName = widget.task.category.value!.name;
//     }

//     return Column(
//       children: [
//         _buildMetaRow(Icons.category_outlined, "التصنيف", categoryName),
//         _buildMetaRow(
//           Icons.calendar_today_outlined,
//           "الموعد",
//           DateFormat('d MMM, h:mm a', 'ar').format(widget.task.date),
//         ),
//         _buildReminderSection(),
//       ],
//     );
//   }

//   /// ✅ قسم التذكيرات
//   Widget _buildReminderSection() {
//     final colors = context.colors;

//     return Container(
//       padding: AtharSpacing.allLg,
//       decoration: BoxDecoration(
//         color: _isReminderEnabled
//             ? colors.warning.withOpacity(0.08)
//             : colors.scaffoldBackground,
//         borderRadius: AtharRadii.radiusMd,
//         border: Border.all(
//           color: _isReminderEnabled
//               ? colors.warning.withOpacity(0.3)
//               : colors.textTertiary.withOpacity(0.2),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // العنوان والـ Switch
//           Row(
//             children: [
//               Icon(
//                 _isReminderEnabled
//                     ? Icons.notifications_active_rounded
//                     : Icons.notifications_off_outlined,
//                 color: _isReminderEnabled
//                     ? colors.warning
//                     : colors.textTertiary,
//                 size: 22.sp,
//               ),
//               SizedBox(width: 10.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "التذكير",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14.sp,
//                         fontFamily: 'Tajawal',
//                       ),
//                     ),
//                     Text(
//                       _isReminderEnabled
//                           ? "سيتم تنبيهك قبل الموعد"
//                           : "لن يتم تنبيهك",
//                       style: TextStyle(
//                         color: colors.textSecondary,
//                         fontSize: 11.sp,
//                         fontFamily: 'Tajawal',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Switch(
//                 value: _isReminderEnabled,
//                 onChanged: (val) {
//                   setState(() {
//                     _isReminderEnabled = val;
//                     if (!val) {
//                       _reminderTime = null;
//                     }
//                   });
//                 },
//                 activeThumbColor: colors.warning,
//               ),
//             ],
//           ),

//           // وقت التذكير (إذا مفعل)
//           if (_isReminderEnabled) ...[
//             AtharGap.md,
//             Divider(color: colors.warning.withOpacity(0.2), height: 1),
//             AtharGap.md,

//             InkWell(
//               onTap: () => _pickReminderTime(context),
//               borderRadius: AtharRadii.radiusSm,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//                 decoration: BoxDecoration(
//                   color: colors.surface,
//                   borderRadius: AtharRadii.radiusSm,
//                   border: Border.all(color: colors.warning.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.access_time_rounded,
//                       size: 18.sp,
//                       color: colors.warning,
//                     ),
//                     SizedBox(width: 10.w),
//                     Expanded(
//                       child: Text(
//                         _reminderTime != null
//                             ? DateFormat(
//                                 'd MMM, h:mm a',
//                                 'ar',
//                               ).format(_reminderTime!)
//                             : "اختر وقت التذكير",
//                         style: TextStyle(
//                           fontSize: 13.sp,
//                           fontFamily: 'Tajawal',
//                           color: _reminderTime != null
//                               ? colors.warning
//                               : colors.textTertiary,
//                         ),
//                       ),
//                     ),
//                     Icon(
//                       Icons.chevron_left_rounded,
//                       size: 20.sp,
//                       color: colors.textTertiary,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // اقتراحات سريعة
//             AtharGap.md,
//             Text(
//               "اقتراحات سريعة:",
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 color: colors.textSecondary,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             AtharGap.sm,
//             Wrap(
//               spacing: 8.w,
//               runSpacing: 8.h,
//               children: [
//                 _buildQuickReminderChip(
//                   "10 دقائق",
//                   const Duration(minutes: 10),
//                 ),
//                 _buildQuickReminderChip(
//                   "30 دقيقة",
//                   const Duration(minutes: 30),
//                 ),
//                 _buildQuickReminderChip("ساعة", const Duration(hours: 1)),
//                 _buildQuickReminderChip("يوم", const Duration(days: 1)),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   /// شريحة اقتراح سريع
//   Widget _buildQuickReminderChip(String label, Duration beforeTask) {
//     final colors = context.colors;
//     final suggestedTime = widget.task.date.subtract(beforeTask);
//     final bool isValidTime = suggestedTime.isAfter(DateTime.now());
//     final bool isSelected =
//         _reminderTime != null &&
//         _reminderTime!.difference(suggestedTime).inMinutes.abs() < 2;

//     return InkWell(
//       onTap: isValidTime
//           ? () {
//               setState(() {
//                 _reminderTime = suggestedTime;
//               });
//             }
//           : null,
//       borderRadius: AtharRadii.radiusLg,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//         decoration: BoxDecoration(
//           color: !isValidTime
//               ? colors.textTertiary.withOpacity(0.2)
//               : isSelected
//               ? colors.warning.withOpacity(0.4)
//               : colors.warning.withOpacity(0.15),
//           borderRadius: AtharRadii.radiusLg,
//           border: isSelected
//               ? Border.all(color: colors.warning, width: 2)
//               : null,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (isSelected)
//               Padding(
//                 padding: EdgeInsets.only(left: 4.w),
//                 child: Icon(
//                   Icons.check_circle,
//                   size: 14.sp,
//                   color: colors.warning,
//                 ),
//               ),
//             Text(
//               "قبل $label",
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 color: !isValidTime ? colors.textTertiary : colors.warning,
//                 fontFamily: 'Tajawal',
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 decoration: !isValidTime ? TextDecoration.lineThrough : null,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ✅ دالة اختيار وقت التذكير
//   Future<void> _pickReminderTime(BuildContext context) async {
//     final colors = context.colors;
//     final initialDate = _reminderTime ?? DateTime.now();

//     // ✅ تخصيص ثيم DatePicker بألوان نظام أثر
//     final date = await showDatePicker(
//       context: context,
//       initialDate: initialDate.isAfter(DateTime.now())
//           ? initialDate
//           : DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: widget.task.date,
//       locale: const Locale('ar', 'SA'),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: colors.primary,
//               onPrimary: colors.surface,
//               surface: colors.surface,
//               onSurface: colors.textPrimary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (date == null || !context.mounted) return;

//     // ✅ تخصيص ثيم TimePicker بألوان نظام أثر
//     final time = await showTimePicker(
//       context: context,
//       initialTime: _reminderTime != null
//           ? TimeOfDay.fromDateTime(_reminderTime!)
//           : TimeOfDay.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: colors.primary,
//               onPrimary: colors.surface,
//               surface: colors.surface,
//               onSurface: colors.textPrimary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (time == null || !context.mounted) return;
//     final selectedDateTime = DateTime(
//       date.year,
//       date.month,
//       date.day,
//       time.hour,
//       time.minute,
//     );

//     if (selectedDateTime.isAfter(DateTime.now()) &&
//         selectedDateTime.isBefore(widget.task.date)) {
//       setState(() {
//         _reminderTime = selectedDateTime;
//       });
//     } else {
//       if (context.mounted) {
//         String errorMessage;
//         if (selectedDateTime.isBefore(DateTime.now())) {
//           errorMessage = "لا يمكن اختيار وقت في الماضي";
//         } else {
//           errorMessage = "يجب أن يكون التذكير قبل موعد المهمة";
//         }

//         AtharSnackbar.warning(context: context, message: errorMessage);
//       }
//     }
//   }

//   /// ✅ دالة مساعدة لعرض صف البيانات
//   Widget _buildMetaRow(IconData icon, String label, String value) {
//     final colors = context.colors;

//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Row(
//         children: [
//           Icon(icon, size: 20.sp, color: colors.textTertiary),
//           AtharGap.hMd,
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 10.sp, color: colors.textTertiary),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:athar/features/task/presentation/widgets/attachments_widget.dart';
// // ✅ استيراد ودجت السبورة
// import 'package:athar/features/task/presentation/widgets/task_board_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class TaskDetailsPage extends StatefulWidget {
//   final TaskModel task;
//   const TaskDetailsPage({super.key, required this.task});

//   @override
//   State<TaskDetailsPage> createState() => _TaskDetailsPageState();
// }

// class _TaskDetailsPageState extends State<TaskDetailsPage> {
//   late TextEditingController _titleController;
//   late TextEditingController _descController;
//   late TaskStatus _currentStatus;

//   // ✅ متغيرات التذكير الجديدة
//   late bool _isReminderEnabled;
//   DateTime? _reminderTime;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.task.title);
//     _descController = TextEditingController(
//       text: widget.task.description ?? "",
//     );
//     _currentStatus = widget.task.status;

//     // ✅ تهيئة التذكير
//     _isReminderEnabled = widget.task.reminderTime != null;
//     _reminderTime = widget.task.reminderTime;

//     // تصحيح حالة الإكمال
//     if (widget.task.isCompleted && _currentStatus != TaskStatus.done) {
//       _currentStatus = TaskStatus.done;
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descController.dispose();
//     super.dispose();
//   }

//   void _saveChanges() {
//     final cubit = context.read<TaskCubit>();

//     // نتحقق هل حدث تغيير فعلياً
//     if (widget.task.title != _titleController.text ||
//         widget.task.description != _descController.text ||
//         widget.task.status != _currentStatus ||
//         widget.task.reminderTime != _reminderTime) {
//       // ✅ إضافة فحص التذكير

//       widget.task.title = _titleController.text;
//       widget.task.description = _descController.text;
//       widget.task.status = _currentStatus;

//       // ✅ تحديث التذكير
//       widget.task.reminderTime = _isReminderEnabled ? _reminderTime : null;

//       if (_currentStatus == TaskStatus.done) {
//         widget.task.isCompleted = true;
//         widget.task.completedAt = DateTime.now();
//       } else {
//         widget.task.isCompleted = false;
//         widget.task.completedAt = null;
//       }

//       cubit.updateTask(
//         widget.task,
//       ); // ✅ استخدم updateTask بدلاً من addTaskModel
//     }
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅✅✅ إصلاح TODO #1: دالة لتحديد نوع المساحة الحقيقي
//   // ═══════════════════════════════════════════════════════════════════════════
//   String _getSpaceType() {
//     // إذا كانت المهمة تابعة لمساحة (spaceId موجود وغير فارغ)، فهي shared
//     // وإلا فهي personal
//     if (widget.task.spaceId != null && widget.task.spaceId!.isNotEmpty) {
//       return 'shared';
//     }
//     return 'personal';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: true,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) _saveChanges();
//       },
//       child: DefaultTabController(
//         // ✅ 1. إضافة التحكم بالتبويبات
//         length: 2,
//         child: Scaffold(
//           backgroundColor: Colors.white,
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             elevation: 0,
//             leading: BackButton(
//               color: Colors.black,
//               onPressed: () {
//                 _saveChanges();
//                 Navigator.pop(context);
//               },
//             ),
//             title: const Text(
//               "تفاصيل المهمة",
//               style: TextStyle(color: Colors.black, fontFamily: 'Tajawal'),
//             ),
//             centerTitle: true,
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.delete_outline, color: Colors.red),
//                 onPressed: () {
//                   context.read<TaskCubit>().deleteTask(widget.task.id);
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//             // ✅ 2. شريط التبويبات الجديد
//             bottom: TabBar(
//               labelColor: AppColors.primary,
//               unselectedLabelColor: Colors.grey,
//               indicatorColor: AppColors.primary,
//               labelStyle: TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14.sp,
//               ),
//               tabs: const [
//                 Tab(text: "التفاصيل"),
//                 Tab(text: "السبورات & الفريق"),
//               ],
//             ),
//           ),
//           body: TabBarView(
//             children: [
//               // ✅ 3. التبويب الأول: المحتوى القديم (التفاصيل)
//               _buildDetailsTab(),

//               // ✅ 4. التبويب الثاني: السبورات (Widget الجديد)
//               TaskBoardWidget(taskId: widget.task.uuid),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // تم نقل المحتوى القديم هنا لترتيب الكود
//   Widget _buildDetailsTab() {
//     return ListView(
//       padding: EdgeInsets.all(20.w),
//       children: [
//         // 1. العنوان
//         TextField(
//           controller: _titleController,
//           style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
//           decoration: const InputDecoration(
//             border: InputBorder.none,
//             hintText: "عنوان المهمة",
//           ),
//           maxLines: null,
//         ),
//         SizedBox(height: 20.h),

//         // 2. شريط الحالة
//         Container(
//           padding: EdgeInsets.all(4.w),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           child: Row(
//             children: [
//               _buildStatusOption(
//                 TaskStatus.todo,
//                 "قائمة الانتظار",
//                 Icons.circle_outlined,
//                 Colors.grey,
//               ),
//               _buildStatusOption(
//                 TaskStatus.inProgress,
//                 "جاري التنفيذ",
//                 Icons.hourglass_top,
//                 Colors.blue,
//               ),
//               _buildStatusOption(
//                 TaskStatus.done,
//                 "مكتملة",
//                 Icons.check_circle,
//                 Colors.green,
//               ),
//             ],
//           ),
//         ),
//         SizedBox(height: 24.h),

//         // 3. البيانات الوصفية
//         _buildMetaSection(),
//         SizedBox(height: 24.h),

//         // 4. الوصف
//         Text(
//           "الوصف والملاحظات",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//         ),
//         SizedBox(height: 8.h),
//         Container(
//           padding: EdgeInsets.all(16.w),
//           decoration: BoxDecoration(
//             color: AppColors.background,
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           child: TextField(
//             controller: _descController,
//             decoration: const InputDecoration.collapsed(
//               hintText: "أضف تفاصيل، روابط، أو ملاحظات فرعية...",
//             ),
//             maxLines: 8,
//             style: TextStyle(height: 1.5, fontSize: 14.sp),
//           ),
//         ),
//         SizedBox(height: 24.h),

//         // ✅ إضافة ودجت المرفقات
//         // تمرير نوع المساحة الحقيقي
//         AttachmentsWidget(taskId: widget.task.uuid, spaceType: _getSpaceType()),

//         SizedBox(height: 40.h), // مسافة في الأسفل
//       ],
//     );
//   }

//   Widget _buildStatusOption(
//     TaskStatus status,
//     String label,
//     IconData icon,
//     Color color,
//   ) {
//     final isSelected = _currentStatus == status;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _currentStatus = status),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: EdgeInsets.symmetric(vertical: 10.h),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.white : Colors.transparent,
//             borderRadius: BorderRadius.circular(10.r),
//             boxShadow: isSelected
//                 ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
//                 : [],
//           ),
//           child: Column(
//             children: [
//               Icon(icon, color: isSelected ? color : Colors.grey, size: 20.sp),
//               SizedBox(height: 4.h),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   color: isSelected ? color : Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMetaSection() {
//     String categoryName = "عام";
//     // التحقق من أن الرابط ليس فارغاً وأن القيمة محملة
//     if (widget.task.category.value != null) {
//       categoryName = widget.task.category.value!.name;
//     }

//     return Column(
//       children: [
//         _buildMetaRow(Icons.category_outlined, "التصنيف", categoryName),
//         _buildMetaRow(
//           Icons.calendar_today_outlined,
//           "الموعد",
//           DateFormat('d MMM, h:mm a', 'ar').format(widget.task.date),
//         ),
//         // ✅ قسم التذكيرات الجديد
//         _buildReminderSection(),
//       ],
//     );
//   }

//   /// ✅ قسم التذكيرات الجديد
//   Widget _buildReminderSection() {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: _isReminderEnabled ? Colors.amber.shade50 : Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(
//           color: _isReminderEnabled
//               ? Colors.amber.shade200
//               : Colors.grey.shade200,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // العنوان والـ Switch
//           Row(
//             children: [
//               Icon(
//                 _isReminderEnabled
//                     ? Icons.notifications_active_rounded
//                     : Icons.notifications_off_outlined,
//                 color: _isReminderEnabled ? Colors.amber.shade700 : Colors.grey,
//                 size: 22.sp,
//               ),
//               SizedBox(width: 10.w),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "التذكير",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14.sp,
//                         fontFamily: 'Tajawal',
//                       ),
//                     ),
//                     Text(
//                       _isReminderEnabled
//                           ? "سيتم تنبيهك قبل الموعد"
//                           : "لن يتم تنبيهك",
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: 11.sp,
//                         fontFamily: 'Tajawal',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Switch(
//                 value: _isReminderEnabled,
//                 onChanged: (val) {
//                   setState(() {
//                     _isReminderEnabled = val;
//                     if (!val) {
//                       _reminderTime = null;
//                     }
//                   });
//                 },
//                 activeThumbColor: Colors.amber.shade700,
//               ),
//             ],
//           ),

//           // وقت التذكير (إذا مفعل)
//           if (_isReminderEnabled) ...[
//             SizedBox(height: 12.h),
//             Divider(color: Colors.amber.shade100, height: 1),
//             SizedBox(height: 12.h),

//             InkWell(
//               onTap: () => _pickReminderTime(context),
//               borderRadius: BorderRadius.circular(8.r),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8.r),
//                   border: Border.all(color: Colors.amber.shade200),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.access_time_rounded,
//                       size: 18.sp,
//                       color: Colors.amber.shade700,
//                     ),
//                     SizedBox(width: 10.w),
//                     Expanded(
//                       child: Text(
//                         _reminderTime != null
//                             ? DateFormat(
//                                 'd MMM, h:mm a',
//                                 'ar',
//                               ).format(_reminderTime!)
//                             : "اختر وقت التذكير",
//                         style: TextStyle(
//                           fontSize: 13.sp,
//                           fontFamily: 'Tajawal',
//                           color: _reminderTime != null
//                               ? Colors.amber.shade800
//                               : Colors.grey,
//                         ),
//                       ),
//                     ),
//                     Icon(
//                       Icons.chevron_left_rounded,
//                       size: 20.sp,
//                       color: Colors.grey,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // اقتراحات سريعة
//             SizedBox(height: 12.h),
//             Text(
//               "اقتراحات سريعة:",
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 color: Colors.grey.shade600,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Wrap(
//               spacing: 8.w,
//               runSpacing: 8.h,
//               children: [
//                 _buildQuickReminderChip(
//                   "10 دقائق",
//                   const Duration(minutes: 10),
//                 ),
//                 _buildQuickReminderChip(
//                   "30 دقيقة",
//                   const Duration(minutes: 30),
//                 ),
//                 _buildQuickReminderChip("ساعة", const Duration(hours: 1)),
//                 _buildQuickReminderChip("يوم", const Duration(days: 1)),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   /// شريحة اقتراح سريع
//   // حساب وقت التذكير بناءً على وقت المهمة
//   Widget _buildQuickReminderChip(String label, Duration beforeTask) {
//     // ✅ حساب الوقت المقترح بناءً على وقت المهمة
//     final suggestedTime = widget.task.date.subtract(beforeTask);

//     // ✅ التحقق من أن الوقت المقترح في المستقبل
//     final bool isValidTime = suggestedTime.isAfter(DateTime.now());

//     // ✅ التحقق هل هذا الخيار محدد حالياً (مقارنة دقيقة بالدقائق)
//     final bool isSelected =
//         _reminderTime != null &&
//         _reminderTime!.difference(suggestedTime).inMinutes.abs() < 2;

//     return InkWell(
//       onTap: isValidTime
//           ? () {
//               // حساب الوقت وتحديث الحالة
//               setState(() {
//                 _reminderTime = suggestedTime;
//               });
//             }
//           : null, // ✅ تعطيل الزر إذا كان الوقت في الماضي
//       // onTap: () {
//       //   // setState(() {
//       //   //   _reminderTime = widget.task.date.subtract(beforeTask);
//       //   // });
//       // },
//       borderRadius: BorderRadius.circular(16.r),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//         decoration: BoxDecoration(
//           color: !isValidTime
//               ? Colors
//                     .grey
//                     .shade200 // ✅ رمادي إذا كان الوقت في الماضي
//               : isSelected
//               ? Colors
//                     .amber
//                     .shade300 // ✅ أغمق إذا محدد
//               : Colors.amber.shade100,
//           borderRadius: BorderRadius.circular(16.r),
//           border: isSelected
//               ? Border.all(color: Colors.amber.shade700, width: 2)
//               : null,
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // ✅ أيقونة التحديد إذا كان الخيار محدداً
//             if (isSelected)
//               Padding(
//                 padding: EdgeInsets.only(left: 4.w),
//                 child: Icon(
//                   Icons.check_circle,
//                   size: 14.sp,
//                   color: Colors.amber.shade800,
//                 ),
//               ),
//             Text(
//               "قبل $label",
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 color: !isValidTime
//                     ? Colors
//                           .grey
//                           .shade500 // ✅ رمادي إذا كان في الماضي
//                     : Colors.amber.shade800,
//                 fontFamily: 'Tajawal',
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 // ✅ خط يتوسطه إذا كان غير متاح
//                 decoration: !isValidTime ? TextDecoration.lineThrough : null,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// ✅ دالة اختيار وقت التذكير
//   Future<void> _pickReminderTime(BuildContext context) async {
//     // ✅ تحديد التاريخ الأولي بشكل ذكي
//     final initialDate = _reminderTime ?? DateTime.now();
//     final date = await showDatePicker(
//       context: context,
//       initialDate: initialDate.isAfter(DateTime.now())
//           ? initialDate
//           : DateTime.now(),
//       firstDate: DateTime.now(),
//       // lastDate: DateTime(2030),
//       lastDate: widget.task.date, // ✅ لا يمكن اختيار تاريخ بعد المهمة
//       locale: const Locale('ar', 'SA'),
//     );

//     if (date == null || !context.mounted) return;

//     final time = await showTimePicker(
//       context: context,
//       initialTime: _reminderTime != null
//           ? TimeOfDay.fromDateTime(_reminderTime!)
//           : TimeOfDay.now(),
//     );

//     if (time == null || !context.mounted) return;
//     final selectedDateTime = DateTime(
//       date.year,
//       date.month,
//       date.day,
//       time.hour,
//       time.minute,
//     );

//     // ✅ التحقق من أن الوقت المختار قبل وقت المهمة وفي المستقبل
//     if (selectedDateTime.isAfter(DateTime.now()) &&
//         selectedDateTime.isBefore(widget.task.date)) {
//       setState(() {
//         _reminderTime = selectedDateTime;
//       });
//     } else {
//       // ✅ عرض رسالة خطأ مناسبة
//       if (context.mounted) {
//         String errorMessage;
//         if (selectedDateTime.isBefore(DateTime.now())) {
//           errorMessage = "لا يمكن اختيار وقت في الماضي";
//         } else {
//           errorMessage = "يجب أن يكون التذكير قبل موعد المهمة";
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.warning_amber_rounded, color: Colors.white),
//                 SizedBox(width: 8.w),
//                 Text(
//                   errorMessage,
//                   style: const TextStyle(fontFamily: 'Tajawal'),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.red.shade700,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             margin: EdgeInsets.all(16.w),
//           ),
//         );
//       }
//     }
//   }

//   /// ✅ دالة مساعدة لعرض صف البيانات
//   Widget _buildMetaRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Row(
//         children: [
//           Icon(icon, size: 20.sp, color: Colors.grey),
//           SizedBox(width: 12.w),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/design_system/theme/app_colors.dart';
// import '../../data/models/task_model.dart';
// import '../cubit/task_cubit.dart';

// class TaskDetailsPage extends StatefulWidget {
//   final TaskModel task;
//   const TaskDetailsPage({super.key, required this.task});

//   @override
//   State<TaskDetailsPage> createState() => _TaskDetailsPageState();
// }

// class _TaskDetailsPageState extends State<TaskDetailsPage> {
//   late TextEditingController _titleController;
//   late TextEditingController _descController;
//   late TaskStatus _currentStatus;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.task.title);
//     _descController = TextEditingController(
//       text: widget.task.description ?? "",
//     );
//     _currentStatus = widget.task.status;

//     // تصحيح: إذا كانت مكتملة ولكن الستاتس لم يحدث
//     if (widget.task.isCompleted && _currentStatus != TaskStatus.done) {
//       _currentStatus = TaskStatus.done;
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descController.dispose();
//     super.dispose();
//   }

//   // حفظ التغييرات عند الخروج
//   void _saveChanges() {
//     final cubit = context.read<TaskCubit>();
//     // نستخدم copyWith أو نعدل الكائن (يفضل copyWith في التطبيقات الكبيرة)
//     // هنا سنعدل الكائن مباشرة للسهولة مع Isar
//     widget.task.title = _titleController.text;
//     widget.task.description = _descController.text;
//     widget.task.status = _currentStatus;

//     // تحديث الإكمال بناءً على الستاتس
//     if (_currentStatus == TaskStatus.done) {
//       widget.task.isCompleted = true;
//       widget.task.completedAt = DateTime.now();
//     } else {
//       widget.task.isCompleted = false;
//       widget.task.completedAt = null;
//     }

//     cubit.addTaskModel(widget.task); // دالة التحديث
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: true, // نسمح بالرجوع
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) _saveChanges();
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: BackButton(
//             color: Colors.black,
//             onPressed: () {
//               _saveChanges();
//               Navigator.pop(context);
//             },
//           ),
//           actions: [
//             IconButton(
//               icon: Icon(Icons.delete_outline, color: Colors.red),
//               onPressed: () {
//                 context.read<TaskCubit>().deleteTask(widget.task.id);
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//         body: ListView(
//           padding: EdgeInsets.all(20.w),
//           children: [
//             // 1. العنوان (قابل للتعديل)
//             TextField(
//               controller: _titleController,
//               style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 hintText: "عنوان المهمة",
//               ),
//               maxLines: null,
//             ),
//             SizedBox(height: 20.h),

//             // 2. شريط الحالة (Status Selector)
//             Container(
//               padding: EdgeInsets.all(4.w),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Row(
//                 children: [
//                   _buildStatusOption(
//                     TaskStatus.todo,
//                     "قائمة الانتظار",
//                     Icons.circle_outlined,
//                     Colors.grey,
//                   ),
//                   _buildStatusOption(
//                     TaskStatus.inProgress,
//                     "جاري التنفيذ",
//                     Icons.hourglass_top,
//                     Colors.blue,
//                   ),
//                   _buildStatusOption(
//                     TaskStatus.done,
//                     "مكتملة",
//                     Icons.check_circle,
//                     Colors.green,
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 24.h),

//             // 3. البيانات الوصفية (المشروع، التصنيف، الوقت)
//             _buildMetaSection(),
//             SizedBox(height: 24.h),

//             // 4. الوصف (Description)
//             Text(
//               "الوصف والملاحظات",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//             ),
//             SizedBox(height: 8.h),
//             Container(
//               padding: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 color: AppColors.background,
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: TextField(
//                 controller: _descController,
//                 decoration: InputDecoration.collapsed(
//                   hintText: "أضف تفاصيل، روابط، أو ملاحظات فرعية...",
//                 ),
//                 maxLines: 8,
//                 style: TextStyle(height: 1.5, fontSize: 14.sp),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusOption(
//     TaskStatus status,
//     String label,
//     IconData icon,
//     Color color,
//   ) {
//     final isSelected = _currentStatus == status;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _currentStatus = status),
//         child: AnimatedContainer(
//           duration: Duration(milliseconds: 200),
//           padding: EdgeInsets.symmetric(vertical: 10.h),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.white : Colors.transparent,
//             borderRadius: BorderRadius.circular(10.r),
//             boxShadow: isSelected
//                 ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
//                 : [],
//           ),
//           child: Column(
//             children: [
//               Icon(icon, color: isSelected ? color : Colors.grey, size: 20.sp),
//               SizedBox(height: 4.h),
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                   color: isSelected ? color : Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMetaSection() {
//     // ✅ جلب اسم التصنيف من الرابط الديناميكي
//     String categoryName = "عام";
//     // نتأكد أن القيمة تم تحميلها (IsarLink يقوم بالتحميل التلقائي عند الوصول للقيمة إذا كانت محملة، أو يمكن استخدام loadSync)
//     if (widget.task.category.value != null) {
//       categoryName = widget.task.category.value!.name;
//     }

//     return Column(
//       children: [
//         _buildMetaRow(
//           Icons.category_outlined,
//           "التصنيف",
//           categoryName, // ✅ الاسم الجديد
//         ),
//         // if (widget.task.project.value != null)
//         //   _buildMetaRow(
//         //     Icons.folder_outlined,
//         //     "المشروع",
//         //     widget.task.project.value!.title,
//         //   ),
//         _buildMetaRow(
//           Icons.calendar_today_outlined,
//           "الموعد",
//           DateFormat('d MMM, h:mm a', 'ar').format(widget.task.date),
//         ),
//       ],
//     );
//   }

//   Widget _buildMetaRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Row(
//         children: [
//           Icon(icon, size: 20.sp, color: Colors.grey),
//           SizedBox(width: 12.w),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//               ),
//               Text(
//                 value,
//                 style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
