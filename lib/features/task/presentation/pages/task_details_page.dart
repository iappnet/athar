// ————-————— code start ————————-
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/widgets/athar_feedback.dart';
import 'package:athar/core/design_system/widgets/athar_text_field.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/features/task/data/models/recurrence_pattern.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:athar/features/task/presentation/widgets/attachments_widget.dart';
// ✅ استيراد ودجت السبورة
import 'package:athar/features/task/presentation/widgets/task_board_widget.dart';
import 'package:athar/core/utils/navigation_utils.dart';
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

  late bool _isUrgent;
  late bool _isImportant;

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
    _isUrgent = widget.task.isUrgent;
    _isImportant = widget.task.isImportant;

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
        widget.task.reminderTime != _reminderTime ||
        widget.task.isUrgent != _isUrgent ||
        widget.task.isImportant != _isImportant) {
      widget.task.title = _titleController.text;
      widget.task.description = _descController.text;
      widget.task.status = _currentStatus;
      widget.task.isUrgent = _isUrgent;
      widget.task.isImportant = _isImportant;

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
                NavigationUtils.safeBack(context);
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

        // 5. الأولوية
        _buildPrioritySection(),
        AtharGap.xxl,

        // 6. شارة التكرار (إن وجد)
        if (widget.task.recurrence != null) ...[
          _buildRecurrenceBadge(),
          AtharGap.xxl,
        ],

        // 7. ملاحظة الإكمال (إن اكتملت المهمة)
        if (widget.task.isCompleted &&
            widget.task.completionNote != null &&
            widget.task.completionNote!.isNotEmpty) ...[
          _buildCompletionNoteCard(),
          AtharGap.xxl,
        ],

        // ✅ إضافة ودجت المرفقات
        AttachmentsWidget(taskId: widget.task.uuid, spaceType: _getSpaceType()),

        SizedBox(height: 40.h), // مسافة في الأسفل
      ],
    );
  }

  Widget _buildPrioritySection() {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildToggleChip(
            label: l10n.urgent,
            icon: Icons.priority_high_rounded,
            activeColor: Colors.red,
            isActive: _isUrgent,
            onTap: () => setState(() => _isUrgent = !_isUrgent),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildToggleChip(
            label: l10n.important,
            icon: Icons.star_rounded,
            activeColor: Colors.orange,
            isActive: _isImportant,
            onTap: () => setState(() => _isImportant = !_isImportant),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleChip({
    required String label,
    required IconData icon,
    required Color activeColor,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.12)
              : colorScheme.surfaceContainerLowest,
          borderRadius: AtharRadii.radiusMd,
          border: Border.all(
            color: isActive
                ? activeColor.withValues(alpha: 0.4)
                : colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18.sp,
                color: isActive ? activeColor : colorScheme.outline),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight:
                    isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? activeColor : colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceBadge() {
    final colorScheme = Theme.of(context).colorScheme;
    final recurrence = widget.task.recurrence!;
    final l10n = AppLocalizations.of(context);
    String typeLabel;
    switch (recurrence.type) {
      case RecurrenceType.daily:
        typeLabel = l10n.recurrenceDaily;
        break;
      case RecurrenceType.weekly:
        typeLabel = l10n.recurrenceWeekly;
        break;
      case RecurrenceType.monthly:
        typeLabel = l10n.recurrenceMonthly;
        break;
      default:
        typeLabel = l10n.recurrence;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.repeat_rounded,
              size: 18.sp, color: colorScheme.primary),
          SizedBox(width: 8.w),
          Text(
            typeLabel,
            style: TextStyle(
              fontSize: 13.sp,
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionNoteCard() {
    return Container(
      width: double.infinity,
      padding: AtharSpacing.allLg,
      decoration: BoxDecoration(
        color: _successColor.withValues(alpha: 0.08),
        borderRadius: AtharRadii.radiusMd,
        border:
            Border.all(color: _successColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  size: 18.sp, color: _successColor),
              SizedBox(width: 8.w),
              Text(
                'ملاحظة الإكمال',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                  color: _successColor,
                ),
              ),
            ],
          ),
          AtharGap.sm,
          Text(
            widget.task.completionNote!,
            style:
                TextStyle(fontSize: 13.sp, height: 1.5),
          ),
        ],
      ),
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
