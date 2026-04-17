// lib/features/task/presentation/widgets/add_task_sheet.dart
// ✅ محدث مع دعم الأوقات الشرعية (TimeSlotPicker)

import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart';
import 'package:athar/core/design_system/widgets/time_slot_picker.dart';
import 'package:athar/core/time_engine/athar_time_periods.dart';
import 'package:athar/core/time_engine/time_slot_mixin.dart';
import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
import 'package:athar/features/space/presentation/widgets/member_selector_sheet.dart';
import 'package:athar/features/task/presentation/widgets/components/category_selector.dart';
import 'package:athar/features/task/presentation/widgets/components/duration_picker.dart';
import 'package:athar/features/task/presentation/widgets/components/priority_selector.dart';
import 'package:athar/features/task/presentation/widgets/dialogs/conflict_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/settings/data/models/category_model.dart';
import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/widgets/athar_dialog.dart';
import 'package:athar/core/design_system/widgets/athar_feedback.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import '../../data/models/task_model.dart';
import '../cubit/task_cubit.dart';
import '../../../../core/services/prayer_conflict_service.dart';
import '../../domain/models/conflict_result.dart';
import '../../../../features/prayer/presentation/cubit/prayer_cubit.dart';
import '../../../../features/prayer/presentation/cubit/prayer_state.dart';
import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../../../features/settings/presentation/cubit/settings_state.dart';
import '../../../../features/settings/data/models/user_settings.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

class AddTaskSheet extends StatefulWidget {
  final String? targetModuleId;
  final String? targetSpaceId;
  final TaskModel? taskToEdit;

  const AddTaskSheet({
    super.key,
    this.targetModuleId,
    this.targetSpaceId,
    this.taskToEdit,
  });

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final TextEditingController _titleController = TextEditingController();

  // ✅ التاريخ منفصل عن الوقت
  DateTime _selectedDate = DateTime.now();

  // ✅ الحقل الجديد: إعدادات الوقت الشرعي
  TimeSlotSettings? _timeSettings;

  bool _isUrgent = false;
  bool _isImportant = false;
  int _selectedDuration = 30;
  CategoryModel? _selectedCategory;
  String? _selectedAssigneeId;

  DateTime? _reminderTime;
  bool _isReminderEnabled = false;

  bool _isHijriMode = false;
  bool _isSaving = false;

  ConflictResult _prayerConflict = ConflictResult.none();
  final _prayerConflictService = getIt<PrayerConflictService>();

  @override
  void initState() {
    super.initState();
    _loadData();
    _initForm();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPrayerConflict());
  }

  void _loadData() async {
    if (mounted) {
      context.read<CategoryCubit>().loadCategories();
    }
    final settings = await getIt<SettingsRepository>().getSettings();

    if (mounted) {
      setState(() {
        _isHijriMode = settings.isHijriMode;
      });
    }
  }

  void _initForm() {
    if (widget.taskToEdit != null) {
      final t = widget.taskToEdit!;
      _titleController.text = t.title;
      _selectedDate = t.date;
      _isUrgent = t.isUrgent;
      _isImportant = t.isImportant;
      _selectedCategory = t.category.value;
      _selectedDuration = t.durationMinutes;
      _selectedAssigneeId = t.assigneeId;

      // ✅ تحميل إعدادات الوقت الشرعي
      _timeSettings = t.timeSlotSettings;

      if (t.reminderTime != null) {
        _reminderTime = t.reminderTime;
        _isReminderEnabled = true;
      }
    }
  }

  void _checkPrayerConflict() {
    // ✅ التحقق فقط إذا كان الوقت ثابتًا
    if (_timeSettings?.type != TimeSpecificationType.fixed) {
      setState(() {
        _prayerConflict = ConflictResult.none();
      });
      return;
    }

    final prayerState = context.read<PrayerCubit>().state;
    final settingsState = context.read<SettingsCubit>().state;

    List<PrayerTime> prayers = [];
    if (prayerState is PrayerLoaded) {
      prayers = prayerState.allPrayers;
    }
    UserSettings currentSettings = UserSettings();
    if (settingsState is SettingsLoaded) {
      currentSettings = settingsState.settings;
    }

    // حساب الوقت الفعلي
    final taskTime = _getActualTaskTime();
    if (taskTime == null) return;

    final result = _prayerConflictService.checkConflict(
      taskStartTime: taskTime,
      taskDuration: Duration(minutes: _selectedDuration),
      prayers: prayers,
      settings: currentSettings,
    );

    if (mounted) {
      setState(() {
        _prayerConflict = result;
      });
    }
  }

  DateTime? _getActualTaskTime() {
    if (_timeSettings == null) return null;

    if (_timeSettings!.type == TimeSpecificationType.fixed &&
        _timeSettings!.fixedTime != null) {
      return DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _timeSettings!.fixedTime!.hour,
        _timeSettings!.fixedTime!.minute,
      );
    }

    // للأوقات النسبية أو الفترات، نحتاج أوقات الصلاة
    // سيتم حسابها في الـ Backend
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        20.h,
        20.w,
        MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Handle ---
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: AtharRadii.radiusXxxs,
                ),
              ),
            ),
            AtharGap.xl,

            // --- العنوان ---
            Text(
              widget.taskToEdit != null ? l10n.editTask : l10n.newTask,
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(fontSize: 18.sp),
            ),
            AtharGap.lg,

            // --- حقل العنوان ---
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.whatToAccomplish,
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: AtharRadii.radiusMd,
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
            ),
            AtharGap.lg,

            // --- اختيار التاريخ ---
            _buildDateSelector(colorScheme, l10n),
            AtharGap.md,

            // ═══════════════════════════════════════════════════════════════
            // ✅✅✅ اختيار الوقت الشرعي (الجديد) ✅✅✅
            // ═══════════════════════════════════════════════════════════════
            Text(
              'وقت المهمة',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            AtharGap.sm,

            // عرض الوقت المختار
            if (_timeSettings != null)
              _buildTimeDisplay(colorScheme)
            else
              _buildTimePickerButton(colorScheme, l10n),

            // ═══════════════════════════════════════════════════════════════
            if (_prayerConflict.hasConflict) ...[
              AtharGap.md,
              _buildConflictWarning(),
            ],
            AtharGap.md,

            // --- المدة ---
            DurationPicker(
              selectedDuration: _selectedDuration,
              onDurationSelected: (val) {
                setState(() => _selectedDuration = val);
                _checkPrayerConflict();
              },
            ),
            AtharGap.lg,

            // --- التذكير ---
            ReminderPickerWidget(
              reminderTime: _reminderTime,
              isEnabled: _isReminderEnabled,
              onToggle: (val) {
                setState(() {
                  _isReminderEnabled = val;
                  if (val && _reminderTime == null) {
                    _reminderTime = _selectedDate.subtract(
                      const Duration(minutes: 10),
                    );
                  }
                });
              },
              onTimeChanged: (newTime) =>
                  setState(() => _reminderTime = newTime),
            ),
            AtharGap.md,

            // --- الإسناد (للمساحات فقط) ---
            if (widget.targetSpaceId != null ||
                (widget.taskToEdit?.spaceId != null)) ...[
              _buildAssigneeSelector(colorScheme, l10n),
              const Divider(),
              AtharGap.md,
            ],

            // --- الأولوية ---
            PrioritySelector(
              isUrgent: _isUrgent,
              isImportant: _isImportant,
              onUrgentChanged: (val) => setState(() => _isUrgent = val),
              onImportantChanged: (val) => setState(() => _isImportant = val),
            ),
            AtharGap.md,

            // --- التصنيف ---
            CategorySelector(
              selectedCategory: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
              onAddPressed: () => _showAddCategoryDialog(),
            ),
            AtharGap.xl,

            // --- زر الحفظ ---
            SizedBox(
              width: double.infinity,
              child: AtharButton(
                label: widget.taskToEdit != null
                    ? l10n.saveChanges
                    : l10n.addTask,
                onPressed: _isSaving ? null : _saveTask,
                isLoading: _isSaving,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ Widgets الجديدة للوقت
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDateSelector(ColorScheme colorScheme, AppLocalizations l10n) {
    final gregorianStr =
        DateFormat('EEEE, d MMMM yyyy', 'ar').format(_selectedDate);
    final dateStr = _isHijriMode
        ? HijriCalendar.fromDate(_selectedDate).toFormat('dd MMMM yyyy')
        : gregorianStr;

    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AtharRadii.radiusMd,
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: colorScheme.primary, size: 20.sp),
            AtharGap.hMd,
            Expanded(
              child: Text(
                dateStr,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(_getTimeIcon(), color: colorScheme.primary, size: 22.sp),
          AtharGap.hMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTimeTypeLabel(),
                  style: TextStyle(fontSize: 11.sp, color: colorScheme.outline),
                ),
                Text(
                  _getTimeDisplayString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.primary, size: 20.sp),
            onPressed: () => _showTimeSlotPicker(),
          ),
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.error, size: 20.sp),
            onPressed: () => setState(() => _timeSettings = null),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerButton(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return GestureDetector(
      onTap: _showTimeSlotPicker,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AtharRadii.radiusMd,
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, color: colorScheme.outline, size: 22.sp),
            AtharGap.hMd,
            Text(
              'اختر وقت المهمة',
              style: TextStyle(fontSize: 14.sp, color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTimeIcon() {
    if (_timeSettings == null) return Icons.access_time;

    switch (_timeSettings!.type) {
      case TimeSpecificationType.fixed:
        return Icons.access_time;
      case TimeSpecificationType.relativeToprayer:
        return Icons.mosque_outlined;
      case TimeSpecificationType.period:
        return Icons.wb_sunny_outlined;
    }
  }

  String _getTimeTypeLabel() {
    if (_timeSettings == null) return '';

    switch (_timeSettings!.type) {
      case TimeSpecificationType.fixed:
        return 'وقت محدد';
      case TimeSpecificationType.relativeToprayer:
        return 'نسبي للصلاة';
      case TimeSpecificationType.period:
        return 'فترة زمنية';
    }
  }

  String _getTimeDisplayString() {
    if (_timeSettings == null) return 'غير محدد';

    switch (_timeSettings!.type) {
      case TimeSpecificationType.fixed:
        if (_timeSettings!.fixedTime == null) return 'غير محدد';
        final time = _timeSettings!.fixedTime!;
        final hour = time.hour;
        final minute = time.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'م' : 'ص';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$hour12:$minute $period';

      case TimeSpecificationType.relativeToprayer:
        final prayerName = _getPrayerName(_timeSettings!.referencePrayer);
        if (_timeSettings!.offsetMinutes == 0) return prayerName;
        final relation =
            _timeSettings!.prayerRelation == PrayerRelativeTime.before
            ? 'قبل'
            : 'بعد';
        return '$relation $prayerName بـ ${_timeSettings!.offsetMinutes} د';

      case TimeSpecificationType.period:
        final periodName = _getPeriodName(_timeSettings!.period);
        switch (_timeSettings!.periodPosition) {
          case PeriodPosition.start:
            return 'بداية $periodName';
          case PeriodPosition.middle:
            return 'منتصف $periodName';
          case PeriodPosition.end:
            return 'نهاية $periodName';
          default:
            return periodName;
        }
    }
  }

  String _getPrayerName(ReferencePrayer? prayer) {
    switch (prayer) {
      case ReferencePrayer.fajr:
        return 'الفجر';
      case ReferencePrayer.sunrise:
        return 'الشروق';
      case ReferencePrayer.dhuhr:
        return 'الظهر';
      case ReferencePrayer.asr:
        return 'العصر';
      case ReferencePrayer.maghrib:
        return 'المغرب';
      case ReferencePrayer.isha:
        return 'العشاء';
      default:
        return 'غير محدد';
    }
  }

  String _getPeriodName(AtharTimePeriod? period) {
    switch (period) {
      case AtharTimePeriod.dawn:
        return 'الفجر';
      case AtharTimePeriod.bakur:
        return 'البكور';
      case AtharTimePeriod.morning:
        return 'الصباح';
      case AtharTimePeriod.noon:
        return 'الظهيرة';
      case AtharTimePeriod.afternoon:
        return 'العصر';
      case AtharTimePeriod.maghrib:
        return 'المغرب';
      case AtharTimePeriod.isha:
        return 'العشاء';
      case AtharTimePeriod.night:
        return 'الليل';
      case AtharTimePeriod.lastThird:
        return 'الثلث الأخير';
      default:
        return 'غير محدد';
    }
  }

  void _showTimeSlotPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AtharGap.lg,
            Text(
              'اختر وقت المهمة',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            AtharGap.lg,
            TimeSlotPicker(
              initialSettings: _timeSettings,
              showPeriodPosition: true,
              onChanged: (settings) {
                setState(() => _timeSettings = settings);
                Navigator.pop(ctx);
                _checkPrayerConflict();
              },
            ),
            SizedBox(height: MediaQuery.of(ctx).viewInsets.bottom + 20.h),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAssigneeSelector(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: AtharSpacing.allSm,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person_add_alt_1, color: colorScheme.primary),
      ),
      title: Text(
        _selectedAssigneeId == null
            ? l10n.assignToMemberOptional
            : l10n.memberSelected,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: _selectedAssigneeId != null
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
      trailing: _selectedAssigneeId != null
          ? IconButton(
              icon: Icon(Icons.clear, color: colorScheme.error),
              onPressed: () => setState(() => _selectedAssigneeId = null),
            )
          : Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.outline),
      onTap: () async {
        final spaceId = widget.targetSpaceId ?? widget.taskToEdit?.spaceId;
        if (spaceId != null) {
          final result = await showModalBottomSheet(
            context: context,
            builder: (_) => MemberSelectorSheet(
              spaceId: spaceId,
              currentAssigneeId: _selectedAssigneeId,
            ),
          );
          if (result != null) {
            setState(
              () => _selectedAssigneeId = result == 'unassign' ? null : result,
            );
          }
        }
      },
    );
  }

  Widget _buildConflictWarning() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: _prayerConflict.color.withValues(alpha: 0.1),
        border: Border.all(color: _prayerConflict.color),
        borderRadius: AtharRadii.radiusMd,
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_filled, color: _prayerConflict.color),
          AtharGap.hMd,
          Expanded(
            child: Text(
              _prayerConflict.message,
              style: TextStyle(
                color: _prayerConflict.color,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      locale: const Locale('ar', 'SA'),
    );
    if (date != null) {
      setState(() {
        _selectedDate = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
      _checkPrayerConflict();
    }
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final l10n = AppLocalizations.of(context);
    int selectedColor = 0xFF9C27B0;
    AtharDialog.show(
      context: context,
      title: l10n.newCategory,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: l10n.categoryName),
          ),
          AtharGap.sm,
        ],
      ),
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.add,
      onCancel: () => Navigator.pop(context),
      onConfirm: () {
        if (nameController.text.isNotEmpty) {
          context.read<CategoryCubit>().addCategory(
            name: nameController.text,
            colorValue: selectedColor,
            iconKey: 'bookmark',
          );
          Navigator.pop(context);
        }
      },
    );
  }

  void _saveTask() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    final taskCubit = context.read<TaskCubit>();

    try {
      // ✅ التحقق من تعارض المهام في نفس الوقت
      final taskConflict = await taskCubit.validateTimeConflict(
        date: _selectedDate,
        startTime: TimeOfDay.fromDateTime(_selectedDate),
        durationMinutes: _selectedDuration,
        excludeTaskId: widget.taskToEdit?.id,
      );

      ConflictResult? finalConflict;
      if (taskConflict.hasConflict) {
        finalConflict = taskConflict;
      } else if (_prayerConflict.hasConflict) {
        finalConflict = _prayerConflict;
      }

      if (finalConflict != null) {
        setState(() => _isSaving = false);
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ConflictDialog(
            conflict: finalConflict!,
            onDelay: () {
              Navigator.pop(context);
              if (finalConflict!.suggestedTime != null) {
                setState(() {
                  _selectedDate = finalConflict!.suggestedTime!;
                  _isSaving = true;
                });
                _checkPrayerConflict();
                _performSave();
              }
            },
            onForceSave: () {
              Navigator.pop(context);
              setState(() => _isSaving = true);
              _performSave();
            },
            onCancel: () {
              Navigator.pop(context);
              setState(() => _isSaving = false);
            },
          ),
        );
        return;
      }

      _performSave();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AtharSnackbar.error(
          context: context,
          message: AppLocalizations.of(context).errorOccurred(e.toString()),
        );
      }
    }
  }

  void _performSave() {
    if (!mounted) return;

    final cubit = context.read<TaskCubit>();

    if (widget.taskToEdit != null) {
      final updatedTask = widget.taskToEdit!
        ..title = _titleController.text
        ..date = _selectedDate
        ..isUrgent = _isUrgent
        ..isImportant = _isImportant
        ..durationMinutes = _selectedDuration
        ..assigneeId = _selectedAssigneeId
        ..reminderTime = _isReminderEnabled ? _reminderTime : null;

      // ✅ تطبيق إعدادات الوقت الشرعي
      if (_timeSettings != null) {
        updatedTask.applyTimeSettings(_timeSettings!);
      }

      if (_selectedCategory != null) {
        updatedTask.category.value = _selectedCategory;
      }

      cubit.updateTask(updatedTask);
    } else {
      // ✅ إضافة مهمة جديدة مع إعدادات الوقت
      cubit.addTaskWithTimeSlot(
        title: _titleController.text,
        date: _selectedDate,
        timeSettings: _timeSettings,
        isUrgent: _isUrgent,
        isImportant: _isImportant,
        category: _selectedCategory,
        duration: _selectedDuration,
        moduleId: widget.targetModuleId,
        spaceId: widget.targetSpaceId,
        assigneeId: _selectedAssigneeId,
        reminderTime: _isReminderEnabled ? _reminderTime : null,
      );
    }

    if (mounted) Navigator.pop(context);
  }
}

// ------------------------------------------------------------------------

// import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart'; // ✅ استيراد المكون الجديد
// import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:athar/features/space/presentation/widgets/member_selector_sheet.dart';
// import 'package:athar/features/task/presentation/widgets/components/category_selector.dart';
// import 'package:athar/features/task/presentation/widgets/components/date_time_picker.dart';
// import 'package:athar/features/task/presentation/widgets/components/duration_picker.dart';
// import 'package:athar/features/task/presentation/widgets/components/priority_selector.dart';
// import 'package:athar/features/task/presentation/widgets/dialogs/conflict_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/settings/data/models/category_model.dart';
// import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
// import 'package:athar/core/design_system/tokens.dart';
// import 'package:athar/core/design_system/widgets/athar_button.dart';
// import 'package:athar/core/design_system/widgets/athar_dialog.dart';
// import 'package:athar/core/design_system/widgets/athar_feedback.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';
// import '../../data/models/task_model.dart';
// import '../cubit/task_cubit.dart';
// import '../../../../core/services/prayer_conflict_service.dart';
// import '../../domain/models/conflict_result.dart';
// import '../../../../features/prayer/presentation/cubit/prayer_cubit.dart';
// import '../../../../features/prayer/presentation/cubit/prayer_state.dart';
// import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
// import '../../../../features/settings/presentation/cubit/settings_state.dart';
// import '../../../../features/settings/data/models/user_settings.dart';

// class AddTaskSheet extends StatefulWidget {
//   final String? targetModuleId;
//   final String? targetSpaceId;
//   final TaskModel? taskToEdit;

//   const AddTaskSheet({
//     super.key,
//     this.targetModuleId,
//     this.targetSpaceId,
//     this.taskToEdit,
//   });

//   @override
//   State<AddTaskSheet> createState() => _AddTaskSheetState();
// }

// class _AddTaskSheetState extends State<AddTaskSheet> {
//   final TextEditingController _titleController = TextEditingController();
//   DateTime _selectedDate = DateTime.now();
//   bool _isUrgent = false;
//   bool _isImportant = false;
//   int _selectedDuration = 30;
//   CategoryModel? _selectedCategory;
//   String? _selectedAssigneeId;

//   // ✅ الخطوة 1: تعريف متغيرات التذكير
//   DateTime? _reminderTime;
//   bool _isReminderEnabled = false;

//   bool _isHijriMode = false;
//   bool _isSaving = false;

//   ConflictResult _prayerConflict = ConflictResult.none();
//   final _prayerConflictService = getIt<PrayerConflictService>();

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//     _initForm();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _checkPrayerConflict());
//   }

//   void _loadData() async {
//     if (mounted) {
//       context.read<CategoryCubit>().loadCategories();
//     }
//     final settings = await getIt<SettingsRepository>().getSettings();

//     if (mounted) {
//       setState(() {
//         _isHijriMode = settings.isHijriMode;
//       });
//     }
//   }

//   void _initForm() {
//     if (widget.taskToEdit != null) {
//       final t = widget.taskToEdit!;
//       _titleController.text = t.title;
//       _selectedDate = t.date;
//       _isUrgent = t.isUrgent;
//       _isImportant = t.isImportant;
//       _selectedCategory = t.category.value;
//       _selectedDuration = t.durationMinutes;
//       _selectedAssigneeId = t.assigneeId;

//       // ✅ تحميل حالة التذكير عند التعديل
//       if (t.reminderTime != null) {
//         _reminderTime = t.reminderTime;
//         _isReminderEnabled = true;
//       }
//     }
//   }

//   void _checkPrayerConflict() {
//     final prayerState = context.read<PrayerCubit>().state;
//     final settingsState = context.read<SettingsCubit>().state;

//     List<PrayerTime> prayers = [];
//     if (prayerState is PrayerLoaded) {
//       prayers = prayerState.allPrayers;
//     }
//     UserSettings currentSettings = UserSettings();
//     if (settingsState is SettingsLoaded) {
//       currentSettings = settingsState.settings;
//     }

//     final result = _prayerConflictService.checkConflict(
//       taskStartTime: _selectedDate,
//       taskDuration: Duration(minutes: _selectedDuration),
//       prayers: prayers,
//       settings: currentSettings,
//     );

//     if (mounted) {
//       setState(() {
//         _prayerConflict = result;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final l10n = AppLocalizations.of(context);

//     return Container(
//       decoration: BoxDecoration(
//         color: colorScheme.surface,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       padding: EdgeInsets.fromLTRB(
//         20.w,
//         20.h,
//         20.w,
//         MediaQuery.of(context).viewInsets.bottom + 20.h,
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40.w,
//                 height: 4.h,
//                 decoration: BoxDecoration(
//                   color: colorScheme.outlineVariant,
//                   borderRadius: AtharRadii.radiusXxxs,
//                 ),
//               ),
//             ),
//             AtharGap.xl,
//             Text(
//               widget.taskToEdit != null ? l10n.editTask : l10n.newTask,
//               style: Theme.of(
//                 context,
//               ).textTheme.displayLarge?.copyWith(fontSize: 18.sp),
//             ),
//             AtharGap.lg,
//             TextField(
//               controller: _titleController,
//               autofocus: true,
//               decoration: InputDecoration(
//                 hintText: l10n.whatToAccomplish,
//                 filled: true,
//                 fillColor: colorScheme.surfaceContainerLowest,
//                 border: OutlineInputBorder(
//                   borderRadius: AtharRadii.radiusMd,
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16.w,
//                   vertical: 14.h,
//                 ),
//               ),
//             ),
//             AtharGap.lg,
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: DateTimePicker(
//                     selectedDate: _selectedDate,
//                     isHijriMode: _isHijriMode,
//                     onDateTap: _pickDate,
//                     onTimeTap: _pickTime,
//                   ),
//                 ),
//               ],
//             ),
//             if (_prayerConflict.hasConflict) ...[
//               AtharGap.md,
//               _buildConflictWarning(),
//             ],
//             AtharGap.md,
//             DurationPicker(
//               selectedDuration: _selectedDuration,
//               onDurationSelected: (val) {
//                 setState(() => _selectedDuration = val);
//                 _checkPrayerConflict();
//               },
//             ),
//             AtharGap.lg,

//             // ✅ الخطوة 2: حقن الـ ReminderPickerWidget
//             ReminderPickerWidget(
//               reminderTime: _reminderTime,
//               isEnabled: _isReminderEnabled,
//               onToggle: (val) {
//                 setState(() {
//                   _isReminderEnabled = val;
//                   // إذا تم التفعيل ولم يتم اختيار وقت، نضع وقت المهمة كافتراضي
//                   if (val && _reminderTime == null) {
//                     _reminderTime = _selectedDate.subtract(
//                       const Duration(minutes: 10),
//                     );
//                   }
//                 });
//               },
//               onTimeChanged: (newTime) =>
//                   setState(() => _reminderTime = newTime),
//             ),

//             AtharGap.md,

//             if (widget.targetSpaceId != null ||
//                 (widget.taskToEdit?.spaceId != null)) ...[
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: Container(
//                   padding: AtharSpacing.allSm,
//                   decoration: BoxDecoration(
//                     color: colorScheme.primary.withValues(alpha: 0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.person_add_alt_1,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//                 title: Text(
//                   _selectedAssigneeId == null
//                       ? l10n.assignToMemberOptional
//                       : l10n.memberSelected,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: _selectedAssigneeId != null
//                         ? FontWeight.bold
//                         : FontWeight.normal,
//                   ),
//                 ),
//                 trailing: _selectedAssigneeId != null
//                     ? IconButton(
//                         icon: Icon(Icons.clear, color: colorScheme.error),
//                         onPressed: () =>
//                             setState(() => _selectedAssigneeId = null),
//                       )
//                     : Icon(
//                         Icons.arrow_forward_ios,
//                         size: 16,
//                         color: colorScheme.outline,
//                       ),
//                 onTap: () async {
//                   final spaceId =
//                       widget.targetSpaceId ?? widget.taskToEdit?.spaceId;
//                   if (spaceId != null) {
//                     final result = await showModalBottomSheet(
//                       context: context,
//                       builder: (_) => MemberSelectorSheet(
//                         spaceId: spaceId,
//                         currentAssigneeId: _selectedAssigneeId,
//                       ),
//                     );
//                     if (result != null) {
//                       setState(
//                         () => _selectedAssigneeId = result == 'unassign'
//                             ? null
//                             : result,
//                       );
//                     }
//                   }
//                 },
//               ),
//               const Divider(),
//               AtharGap.md,
//             ],
//             PrioritySelector(
//               isUrgent: _isUrgent,
//               isImportant: _isImportant,
//               onUrgentChanged: (val) => setState(() => _isUrgent = val),
//               onImportantChanged: (val) => setState(() => _isImportant = val),
//             ),
//             AtharGap.md,
//             CategorySelector(
//               selectedCategory: _selectedCategory,
//               onSelected: (cat) => setState(() => _selectedCategory = cat),
//               onAddPressed: () => _showAddCategoryDialog(),
//             ),
//             AtharGap.xl,
//             SizedBox(
//               width: double.infinity,
//               child: AtharButton(
//                 label: widget.taskToEdit != null
//                     ? l10n.saveChanges
//                     : l10n.addTask,
//                 onPressed: _isSaving ? null : _saveTask,
//                 isLoading: _isSaving,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- Helpers ---

//   Widget _buildConflictWarning() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: AtharSpacing.allMd,
//       decoration: BoxDecoration(
//         color: _prayerConflict.color.withValues(alpha: 0.1),
//         border: Border.all(color: _prayerConflict.color),
//         borderRadius: AtharRadii.radiusMd,
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.access_time_filled, color: _prayerConflict.color),
//           AtharGap.hMd,
//           Expanded(
//             child: Text(
//               _prayerConflict.message,
//               style: TextStyle(
//                 color: _prayerConflict.color,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12.sp,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//       locale: const Locale('ar', 'SA'),
//     );
//     if (date != null) {
//       setState(
//         () => _selectedDate = DateTime(
//           date.year,
//           date.month,
//           date.day,
//           _selectedDate.hour,
//           _selectedDate.minute,
//         ),
//       );
//       _checkPrayerConflict();
//     }
//   }

//   Future<void> _pickTime() async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(_selectedDate),
//     );
//     if (time != null) {
//       setState(
//         () => _selectedDate = DateTime(
//           _selectedDate.year,
//           _selectedDate.month,
//           _selectedDate.day,
//           time.hour,
//           time.minute,
//         ),
//       );
//       _checkPrayerConflict();
//     }
//   }

//   void _showAddCategoryDialog() {
//     final nameController = TextEditingController();
//     final l10n = AppLocalizations.of(context);
//     int selectedColor = 0xFF9C27B0;
//     AtharDialog.show(
//       context: context,
//       title: l10n.newCategory,
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: nameController,
//             decoration: InputDecoration(hintText: l10n.categoryName),
//           ),
//           AtharGap.sm,
//         ],
//       ),
//       cancelLabel: l10n.cancel,
//       confirmLabel: l10n.add,
//       onCancel: () => Navigator.pop(context),
//       onConfirm: () {
//         if (nameController.text.isNotEmpty) {
//           // context.read<CategoryCubit>().addCategory(
//           //   nameController.text,
//           //   selectedColor,
//           //   Icons.bookmark.codePoint,
//           // );
//           context.read<CategoryCubit>().addCategory(
//             name: nameController.text,
//             colorValue: selectedColor,
//             iconKey: 'bookmark', // أو أي key من IconRegistry
//           );
//           Navigator.pop(context);
//         }
//       },
//     );
//   }

//   void _saveTask() async {
//     if (_titleController.text.trim().isEmpty) return;

//     setState(() => _isSaving = true);
//     final taskCubit = context.read<TaskCubit>();

//     try {
//       final taskConflict = await taskCubit.validateTimeConflict(
//         date: _selectedDate,
//         startTime: TimeOfDay.fromDateTime(_selectedDate),
//         durationMinutes: _selectedDuration,
//         excludeTaskId: widget.taskToEdit?.id,
//       );

//       ConflictResult? finalConflict;
//       if (taskConflict.hasConflict) {
//         finalConflict = taskConflict;
//       } else if (_prayerConflict.hasConflict) {
//         finalConflict = _prayerConflict;
//       }

//       if (finalConflict != null) {
//         setState(() => _isSaving = false);
//         if (!mounted) return;

//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => ConflictDialog(
//             conflict: finalConflict!,
//             onDelay: () {
//               Navigator.pop(context);
//               if (finalConflict!.suggestedTime != null) {
//                 setState(() {
//                   _selectedDate = finalConflict!.suggestedTime!;
//                   _isSaving = true;
//                 });
//                 _checkPrayerConflict();
//                 _performSave();
//               }
//             },
//             onForceSave: () {
//               Navigator.pop(context);
//               setState(() => _isSaving = true);
//               _performSave();
//             },
//             onCancel: () {
//               Navigator.pop(context);
//               setState(() => _isSaving = false);
//             },
//           ),
//         );
//         return;
//       }

//       _performSave();
//     } catch (e) {
//       // ✅ الخطوة 3: إصلاح Async Gap عند حدوث خطأ
//       if (mounted) {
//         setState(() => _isSaving = false);
//         AtharSnackbar.error(
//           context: context,
//           message: AppLocalizations.of(context).errorOccurred(e.toString()),
//         );
//       }
//     }
//   }

//   void _performSave() {
//     // التحقق من أن الـ State ما زال موجوداً في الشجرة قبل استخدام الـ Context
//     if (!mounted) return;

//     final cubit = context.read<TaskCubit>();

//     if (widget.taskToEdit != null) {
//       final updatedTask = widget.taskToEdit!
//         ..title = _titleController.text
//         ..date = _selectedDate
//         ..isUrgent = _isUrgent
//         ..isImportant = _isImportant
//         ..durationMinutes = _selectedDuration
//         ..assigneeId = _selectedAssigneeId
//         // ✅ الخطوة 4: تحديث التذكير في دالة التعديل
//         ..reminderTime = _isReminderEnabled ? _reminderTime : null;

//       if (_selectedCategory != null) {
//         updatedTask.category.value = _selectedCategory;
//       }

//       cubit.updateTask(updatedTask);
//     } else {
//       cubit.addTask(
//         title: _titleController.text,
//         date: _selectedDate,
//         isUrgent: _isUrgent,
//         isImportant: _isImportant,
//         category: _selectedCategory,
//         duration: _selectedDuration,
//         moduleId: widget.targetModuleId,
//         spaceId: widget.targetSpaceId,
//         assigneeId: _selectedAssigneeId,
//         // ✅ الخطوة 5: تمرير التذكير في دالة الإضافة
//         reminderTime: _isReminderEnabled ? _reminderTime : null,
//       );
//     }

//     if (mounted) Navigator.pop(context);
//   }
// }
// ------------------------------------------------------------------------



//       taskStartTime: _selectedDate,
//       taskDuration: Duration(minutes: _selectedDuration),
//       prayers: prayers,
//       settings: currentSettings,


//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       padding: EdgeInsets.fromLTRB(
//         20.w,
//         20.h,
//         20.w,
//         MediaQuery.of(context).viewInsets.bottom + 20.h,
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40.w,
//                 height: 4.h,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               widget.taskToEdit != null ? "تعديل المهمة" : "مهمة جديدة",
//               style: Theme.of(
//                 context,
//               ).textTheme.displayLarge?.copyWith(fontSize: 18.sp),
//             ),
//             SizedBox(height: 16.h),
//             TextField(
//               controller: _titleController,
//               autofocus: true,
//               decoration: InputDecoration(
//                 hintText: "ماذا تريد أن تنجز؟",
//                 filled: true,
//                 fillColor: AppColors.background,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16.w,
//                   vertical: 14.h,
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: DateTimePicker(
//                     selectedDate: _selectedDate,
//                     isHijriMode: _isHijriMode,
//                     onDateTap: _pickDate,
//                     onTimeTap: _pickTime,
//                   ),
//                 ),
//             ),
//               SizedBox(height: 12.h),
//               _buildConflictWarning(),
//             SizedBox(height: 12.h),
//             DurationPicker(
//               selectedDuration: _selectedDuration,
//               },
//             ),
//             SizedBox(height: 16.h),

//             // ✅ الخطوة 2: حقن الـ ReminderPickerWidget
//             ReminderPickerWidget(
//               reminderTime: _reminderTime,
//               isEnabled: _isReminderEnabled,
//                   // إذا تم التفعيل ولم يتم اختيار وقت، نضع وقت المهمة كافتراضي
//               },
//             ),

//             SizedBox(height: 12.h),

//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: Container(
//                   padding: EdgeInsets.all(8.w),
//                   decoration: BoxDecoration(
//                     color: Colors.purple.withValues(alpha: 0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.person_add_alt_1,
//                     color: Colors.purple,
//                   ),
//                 ),
//                 title: Text(
//                       ? "إسناد إلى عضو (اختياري)"
//                       : "تم اختيار عضو",
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                         ? FontWeight.bold
//                         : FontWeight.normal,
//                   ),
//                 ),
//                     ? IconButton(
//                         icon: const Icon(Icons.clear, color: Colors.red),
//                       )
//                     : const Icon(
//                         Icons.arrow_forward_ios,
//                         size: 16,
//                         color: Colors.grey,
//                       ),
//                       context: context,
//                         spaceId: spaceId,
//                         currentAssigneeId: _selectedAssigneeId,
//                       ),
//                             ? null
//                             : result,
//                 },
//               ),
//               SizedBox(height: 12.h),
//             PrioritySelector(
//               isUrgent: _isUrgent,
//               isImportant: _isImportant,
//               onUrgentChanged: (val) => setState(() => _isUrgent = val),
//               onImportantChanged: (val) => setState(() => _isImportant = val),
//             ),
//             SizedBox(height: 12.h),
//             CategorySelector(
//               selectedCategory: _selectedCategory,
//               onSelected: (cat) => setState(() => _selectedCategory = cat),
//             ),
//             SizedBox(height: 20.h),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isSaving ? null : _saveTask,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   padding: EdgeInsets.symmetric(vertical: 14.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 child: _isSaving
//                     ? SizedBox(
//                         width: 24.w,
//                         height: 24.w,
//                         child: const CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : Text(
//                             ? "حفظ التعديلات"
//                             : "إضافة المهمة",
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//               ),
//             ),
//         ),
//       ),

//   // --- Helpers ---

//       duration: const Duration(milliseconds: 300),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: _prayerConflict.color.withValues(alpha: 0.1),
//         border: Border.all(color: _prayerConflict.color),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.access_time_filled, color: _prayerConflict.color),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Text(
//               _prayerConflict.message,
//               style: TextStyle(
//                 color: _prayerConflict.color,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12.sp,
//               ),
//             ),
//           ),
//       ),

//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//       locale: const Locale('ar', 'SA'),
//           date.year,
//           date.month,
//           date.day,
//           _selectedDate.hour,
//           _selectedDate.minute,
//         ),

//       context: context,
//       initialTime: TimeOfDay.fromDateTime(_selectedDate),
//           _selectedDate.year,
//           _selectedDate.month,
//           _selectedDate.day,
//           time.hour,
//           time.minute,
//         ),

//     showDialog(
//       context: context,
//         title: const Text("تصنيف جديد"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(hintText: "اسم التصنيف"),
//             ),
//             SizedBox(height: 10.h),
//         ),
//         actions: [
//           TextButton(
//             child: const Text("إلغاء"),
//           ),
//           ElevatedButton(
//                   nameController.text,
//                   selectedColor,
//                   Icons.bookmark.codePoint,
//             },
//             child: const Text("إضافة"),
//           ),
//       ),



//         date: _selectedDate,
//         startTime: TimeOfDay.fromDateTime(_selectedDate),
//         durationMinutes: _selectedDuration,
//         excludeTaskId: widget.taskToEdit?.id,



//         showDialog(
//           context: context,
//           barrierDismissible: false,
//             conflict: finalConflict!,
//             },
//             },
//             },
//           ),

//       // ✅ الخطوة 3: إصلاح Async Gap عند حدوث خطأ
//         ScaffoldMessenger.of(
//           context,

//     // التحقق من أن الـ State ما زال موجوداً في الشجرة قبل استخدام الـ Context


//         // ✅ الخطوة 4: تحديث التذكير في دالة التعديل


//       cubit.addTask(
//         title: _titleController.text,
//         date: _selectedDate,
//         isUrgent: _isUrgent,
//         isImportant: _isImportant,
//         category: _selectedCategory,
//         duration: _selectedDuration,
//         moduleId: widget.targetModuleId,
//         spaceId: widget.targetSpaceId,
//         assigneeId: _selectedAssigneeId,
//         // ✅ الخطوة 5: تمرير التذكير في دالة الإضافة
//         reminderTime: _isReminderEnabled ? _reminderTime : null,


// ----------------------------------------





//   // تعارض الصلاة يبقى مفصولاً لأنه يعتمد على UI Feedback فوري (الرسالة الصفراء)


//   // ❌ حذفنا استدعاء الـ taskConflictService من هنا








//       taskStartTime: _selectedDate,
//       taskDuration: Duration(minutes: _selectedDuration),
//       prayers: prayers,
//       settings: currentSettings,


//     // ... (نفس كود التصميم السابق بدون تغيير)
//     // سأختصره هنا للتركيز على المنطق، لكنه يبقى كما هو في ملفك
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       padding: EdgeInsets.fromLTRB(
//         20.w,
//         20.h,
//         20.w,
//         MediaQuery.of(context).viewInsets.bottom + 20.h,
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40.w,
//                 height: 4.h,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),

//             Text(
//               widget.taskToEdit != null ? "تعديل المهمة" : "مهمة جديدة",
//               style: Theme.of(
//                 context,
//               ).textTheme.displayLarge?.copyWith(fontSize: 18.sp),
//             ),
//             SizedBox(height: 16.h),

//             // 1. حقل العنوان
//             TextField(
//               controller: _titleController,
//               autofocus: true,
//               decoration: InputDecoration(
//                 hintText: "ماذا تريد أن تنجز؟",
//                 filled: true,
//                 fillColor: AppColors.background,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16.w,
//                   vertical: 14.h,
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.h),

//             // 2. الصف العلوي (تاريخ، وقت، مشروع)
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 DateTimePicker(
//                   selectedDate: _selectedDate,
//                   isHijriMode: _isHijriMode,
//                   onDateTap: _pickDate,
//                   onTimeTap: _pickTime,
//                 ),
//                 SizedBox(width: 8.w),
//                 ProjectSelector(
//                   selectedProject: _selectedProject,
//                   availableProjects: _availableProjects,
//                   onSelected: (proj) => setState(() => _selectedProject = proj),
//                 ),
//             ),

//             // 3. تنبيه التعارض (يظهر فقط إذا وجد تعارض)
//               SizedBox(height: 12.h),
//               _buildConflictWarning(),

//             SizedBox(height: 12.h),

//             // 4. المدة
//             DurationPicker(
//               selectedDuration: _selectedDuration,
//               },
//             ),

//             SizedBox(height: 12.h),

//             // 5. الأولوية
//             PrioritySelector(
//               isUrgent: _isUrgent,
//               isImportant: _isImportant,
//               onUrgentChanged: (val) => setState(() => _isUrgent = val),
//               onImportantChanged: (val) => setState(() => _isImportant = val),
//             ),

//             SizedBox(height: 12.h),

//             // 6. التصنيف
//             CategorySelector(
//               selectedCategory: _selectedCategory,
//               onSelected: (cat) => setState(() => _selectedCategory = cat),
//             ),

//             SizedBox(height: 20.h),

//             // زر الحفظ
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isSaving ? null : _saveTask,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   padding: EdgeInsets.symmetric(vertical: 14.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 child: _isSaving
//                     ? SizedBox(
//                         width: 24.w,
//                         height: 24.w,
//                         child: const CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : Text(
//                             ? "حفظ التعديلات"
//                             : "إضافة المهمة",
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//               ),
//             ),
//         ),
//       ),

//   // ... (نفس الـ Helpers السابقة: _buildConflictWarning, _pickDate, _pickTime, _showAddCategoryDialog)
//       duration: const Duration(milliseconds: 300),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: _prayerConflict.color.withValues(alpha: 0.1),
//         border: Border.all(color: _prayerConflict.color),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.access_time_filled, color: _prayerConflict.color),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Text(
//               _prayerConflict.message,
//               style: TextStyle(
//                 color: _prayerConflict.color,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12.sp,
//               ),
//             ),
//           ),
//       ),

//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//       locale: const Locale('ar', 'SA'),
//           date.year,
//           date.month,
//           date.day,
//           _selectedDate.hour,
//           _selectedDate.minute,
//         ),

//       context: context,
//       initialTime: TimeOfDay.fromDateTime(_selectedDate),
//           _selectedDate.year,
//           _selectedDate.month,
//           _selectedDate.day,
//           time.hour,
//           time.minute,
//         ),

//     showDialog(
//       context: context,
//         title: const Text("تصنيف جديد"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(hintText: "اسم التصنيف"),
//             ),
//             SizedBox(height: 10.h),
//         ),
//         actions: [
//           TextButton(
//             child: const Text("إلغاء"),
//           ),
//           ElevatedButton(
//                   nameController.text,
//                   selectedColor,
//                   Icons.bookmark.codePoint,
//             },
//             child: const Text("إضافة"),
//           ),
//       ),

//   // ✅✅ التعديل الجوهري هنا: دالة الحفظ الجديدة


//       // ✅ 1. بدلاً من استدعاء Service خارجي، نسأل الكيوبت مباشرة
//       // ملاحظة: نفترض أنك أضفت دالة validateTimeConflict في TaskCubit كما اتفقنا سابقاً
//         date: _selectedDate, // نمرر التاريخ كاملاً
//         startTime: TimeOfDay.fromDateTime(_selectedDate),
//         durationMinutes: _selectedDuration,
//         excludeTaskId: widget.taskToEdit?.id,

//       // 2. تحديد التعارض الأهم

//         // إذا كان تعارض صلاة، نظهره للمستخدم ليقرر


//         showDialog(
//           context: context,
//           barrierDismissible: false,
//             conflict: finalConflict!,
//             },
//             },
//             },
//           ),

//       // لا توجد تعارضات، حفظ مباشر
//       // معالجة الأخطاء



//       cubit.addTask(
//         title: _titleController.text,
//         date: _selectedDate,
//         isUrgent: _isUrgent,
//         isImportant: _isImportant,
//         category: _selectedCategory,
//         duration: _selectedDuration,
//         // project: _selectedProject,

// // ignore_for_file: public_member_api_docs, sort_constructors_first



// // ✅ الاستيرادات الجديدة



//   // ✅ التعديل: جعل القيمة الافتراضية 30

//   // ✅ المتغير الجديد للتصنيف (بدلاً من Enum Context)

//   // ✅ متغير لتخزين تفضيل التقويم
//   // ✅ حالة التحميل لمنع التكرار

//   // ✅ 1. تعريف متغير التعارض

//   // ✅ 2. حقن خدمة حارس الصلاة
//   // ✅ حقن خدمة تعارض المهام

//   // --- متغيرات المشروع ---


//       _selectedCategory = t.category.value; // ✅ تحميل التصنيف المحفوظ
//       // ✅ إذا كانت المهمة القديمة لها مدة نستخدمها، وإلا 30

//     // ✅ فحص التعارض المبدئي عند الفتح

//   // ✅ 3. دالة التحقق من التعارض
//     // الحصول على البيانات الحالية


//     // ✅ التصحيح: استخراج الإعدادات بشكل آمن

//     // استدعاء الخدمة
//       taskDateTime: _selectedDate,
//       prayers: prayers.cast(),
//       settings: currentSettings, // ✅ نمرر المتغير المستخرج




//         ? "تعديل المهمة"
//               ? "مهمة في: ${widget.project!.title}"

//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
//         left: 20.w,
//         right: 20.w,
//         top: 20.h,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 1. المقبض
//           Center(
//             child: Container(
//               width: 40.w,
//               height: 4.h,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           SizedBox(height: 20.h),

//           // العنوان
//           Text(
//             sheetTitle,
//             style: Theme.of(
//               context,
//             ).textTheme.displayLarge?.copyWith(fontSize: 18.sp),
//           ),
//           SizedBox(height: 16.h),

//           // 2. حقل الإدخال
//           TextField(
//             controller: _titleController,
//             autofocus: true,
//             decoration: InputDecoration(
//               hintText: "ماذا تريد أن تنجز؟",
//               filled: true,
//               fillColor: AppColors.background,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.r),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w,
//                 vertical: 14.h,
//               ),
//             ),
//           ),
//           SizedBox(height: 16.h),

//           // 3. التاريخ والوقت
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildDateDisplay(),

//               SizedBox(width: 8.w),

//               // زر الوقت
//               Padding(
//                 padding: EdgeInsets.only(top: 0),
//                 child: _buildChip(
//                   icon: Icons.access_time,
//                   label: DateFormat('h:mm a', 'ar').format(_selectedDate),
//                       context: context,
//                       initialTime: TimeOfDay.fromDateTime(_selectedDate),
//                           _selectedDate.year,
//                           _selectedDate.month,
//                           _selectedDate.day,
//                           time.hour,
//                           time.minute,
//                       // ✅ تحديث الفحص عند تغيير الوقت
//                   },
//                 ),
//               ),

//               SizedBox(width: 8.w),

//               // اختيار المشروع
//               _buildProjectSelector(),
//           ),

//           // ✅ 4. عرض رسالة التعارض (الجديد)
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               margin: EdgeInsets.only(top: 12.h),
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 color: _prayerConflict.color.withValues(alpha: 0.1),
//                 border: Border.all(color: _prayerConflict.color),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.access_time_filled, color: _prayerConflict.color),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Text(
//                       _prayerConflict.message,
//                       style: TextStyle(
//                         color: _prayerConflict.color,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                   ),
//               ),
//             ),

//           SizedBox(height: 12.h),

//           // 5. المدة المتوقعة
//           Text(
//             "المدة المتوقعة:",
//             style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//           ),
//           SizedBox(height: 8.h),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _buildDurationChip("15 د", 15),
//                 SizedBox(width: 8.w),
//                 _buildDurationChip("30 د", 30),
//                 SizedBox(width: 8.w),
//                 _buildDurationChip("45 د", 45),
//                 SizedBox(width: 8.w),
//                 _buildDurationChip("1 س", 60),
//             ),
//           ),
//           SizedBox(height: 12.h),

//           // 6. الأولوية
//           Row(
//             children: [
//               FilterChip(
//                 label: const Text("عاجل 🔥"),
//                 selected: _isUrgent,
//                 selectedColor: AppColors.urgent.withValues(alpha: 0.2),
//                 checkmarkColor: AppColors.urgent,
//                 onSelected: (val) => setState(() => _isUrgent = val),
//                 backgroundColor: AppColors.background,
//                 side: BorderSide.none,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               FilterChip(
//                 label: const Text("مهم ⭐"),
//                 selected: _isImportant,
//                 selectedColor: AppColors.warning.withValues(alpha: 0.2),
//                 checkmarkColor: AppColors.warning,
//                 onSelected: (val) => setState(() => _isImportant = val),
//                 backgroundColor: AppColors.background,
//                 side: BorderSide.none,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//           ),
//           SizedBox(height: 12.h),

//           // 7. السياق (Context)
//           // ✅ قسم التصنيفات الجديد (الديناميكي)
//           Text(
//             "التصنيف:",
//             style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//           ),
//           SizedBox(height: 8.h),

//           BlocBuilder<CategoryCubit, CategoryState>(
//                 // اختيار تصنيف افتراضي إذا لم يتم الاختيار
//                   // محاولة اختيار "عام" أو "شخصي" أو الأول

//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       // عرض قائمة التصنيفات
//                           padding: EdgeInsets.only(left: 8.w),
//                           child: ChoiceChip(
//                             label: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   IconData(
//                                     cat.iconCode!,
//                                     fontFamily: 'MaterialIcons',
//                                   ),
//                                   size: 16.sp,
//                                   color: isSelected
//                                       ? Colors.white
//                                       : Color(cat.colorValue),
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(cat.name),
//                             ),
//                             selected: isSelected,
//                             },
//                             selectedColor: Color(cat.colorValue),
//                             backgroundColor: AppColors.background,
//                             labelStyle: TextStyle(
//                               color: isSelected ? Colors.white : Colors.black87,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12.sp,
//                             ),
//                             side: BorderSide.none,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20.r),
//                             ),
//                           ),
//                       }),

//                       // زر إضافة تصنيف جديد
//                       ActionChip(
//                         label: const Icon(Icons.add, size: 18),
//                         backgroundColor: Colors.grey.shade200,
//                         side: BorderSide.none,
//                         shape: const CircleBorder(),
//                       ),
//                   ),
//                 height: 30,
//                 child: Center(child: CircularProgressIndicator()),
//             },
//           ),
//           SizedBox(height: 20.h),

//           // 8. زر الحفظ
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _isSaving ? null : _saveTask, // تعطيل الزر أثناء الحفظ
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 padding: EdgeInsets.symmetric(vertical: 14.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//               ),
//               child: _isSaving
//                   ? SizedBox(
//                       width: 24.w,
//                       height: 24.w,
//                       child: const CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : Text(
//                           ? "حفظ التعديلات"
//                           : "إضافة المهمة",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//             ),
//           ),
//       ),

//   // --- Widget: زر اختيار المشروع ---
//     // ✅ تحسين: دمج المشروع المحدد حالياً مع القائمة لضمان ظهوره

//     // إذا كان لدينا مشروع محدد (من صفحة المشروع) وهو غير موجود في القائمة المحملة، نضيفه
//       tooltip: "اختر مشروعاً",
//       initialValue: _selectedProject ?? _noProjectSentinel,
//       },
//         items.add(
//           PopupMenuItem<ProjectModel?>(
//             value: _noProjectSentinel,
//             child: const Row(
//               children: [
//                 Icon(
//                   Icons.not_interested_rounded,
//                   color: Colors.grey,
//                   size: 18,
//                 ),
//                 SizedBox(width: 8),
//                 Text("بدون مشروع"),
//             ),
//           ),
//         // ✅ استخدام القائمة المحسنة displayList
//         items.addAll(
//               value: proj,
//               child: Row(
//                 children: [
//                   Icon(Icons.folder_rounded, color: color, size: 18),
//                   SizedBox(width: 8),
//                   // تمييز المشروع المحدد بنص عريض
//                   Text(
//                     proj.title,
//                     style: TextStyle(
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                   ),
//               ),
//           }),
//       },
//       //   items.addAll(
//       //         value: proj,
//       //         child: Row(
//       //           children: [
//       //             Icon(Icons.folder_rounded, color: color, size: 18),
//       //             SizedBox(width: 8),
//       //             Text(proj.title),
//       //         ),
//       //     }),
//       // },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         decoration: BoxDecoration(
//               ? Color(
//                   _selectedProject!.colorValue ?? 0xFF4CAF50,
//                 ).withValues(alpha: 0.1)
//               : AppColors.background,
//           borderRadius: BorderRadius.circular(20.r),
//           border: Border.all(
//                 ? Color(_selectedProject!.colorValue ?? 0xFF4CAF50)
//                 : Colors.grey.shade300,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//                   ? Icons.folder_rounded
//                   : Icons.folder_open_rounded,
//               size: 16.sp,
//                   ? Color(_selectedProject!.colorValue ?? 0xFF4CAF50)
//                   : Colors.grey,
//             ),
//             SizedBox(width: 4.w),
//             Text(
//               _selectedProject?.title ?? "مشروع",
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.bold,
//                     ? Color(_selectedProject!.colorValue ?? 0xFF4CAF50)
//                     : Colors.grey,
//               ),
//             ),
//         ),
//       ),

//   // --- Widgets مساعدة ---
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8.r),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         decoration: BoxDecoration(
//           color: AppColors.background,
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 16.sp, color: Colors.grey),
//             SizedBox(width: 6.w),
//             Text(label, style: TextStyle(fontSize: 12.sp)),
//         ),
//       ),

//       label: Text(label),
//       selected: isSelected,
//       selectedColor: AppColors.primary.withValues(alpha: 0.1),
//       backgroundColor: AppColors.background,
//       side: BorderSide.none,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

//   // دالة إضافة تصنيف جديد

//     showDialog(
//       context: context,
//         title: const Text("تصنيف جديد"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 hintText: "اسم التصنيف (مثلاً: رياضة)",
//               ),
//             ),
//             SizedBox(height: 16.h),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children:
//                     [
//                       0xFFE91E63,
//                       0xFF9C27B0,
//                       0xFF2196F3,
//                       0xFF009688,
//                       0xFFFF9800,
//                             c, // (ملاحظة: لتحديث الـ UI يحتاج stateful dialog)
//                         child: Container(
//                           margin: EdgeInsets.all(4.w),
//                           width: 24.w,
//                           height: 24.w,
//                           decoration: BoxDecoration(
//                             color: Color(c),
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                     }).toList(),
//               ),
//             ),
//         ),
//         actions: [
//           TextButton(
//             child: const Text("إلغاء"),
//           ),
//           ElevatedButton(
//                 // ✅ إضافة التصنيف عبر الكيوبت
//                   nameController.text,
//                   selectedColor,
//                   Icons.label_outline.codePoint,
//             },
//             child: const Text("إضافة"),
//           ),
//       ),

//       'd MMM yyyy',
//       'ar',

//         ? "الموافق: $gregorianString"

//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildChip(
//           icon: Icons.calendar_today,
//           label: mainDate,
//               context: context,
//               initialDate: _selectedDate,
//               firstDate: DateTime.now(),
//               lastDate: DateTime(2030),
//               locale: const Locale('ar', 'SA'),
//               // ✅ تحديث الفحص عند تغيير التاريخ
//           },
//         ),
//         Padding(
//           padding: EdgeInsets.only(right: 8.w, top: 4.h),
//           child: Text(
//             subDate,
//             style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//           ),
//         ),

//   // 1. تحديث دالة الحفظ الرئيسية
//       ScaffoldMessenger.of(context).showSnackBar(
//           content: Text("يرجى كتابة عنوان المهمة"),
//           duration: Duration(seconds: 2), // ✅ اختفاء سريع (ثانيتين)
//           behavior: SnackBarBehavior.floating, // يجعلها تطفو وشكلها أجمل)
//         ),

//     // التعارض الصارم (أحمر) - يمنع الحفظ
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.red,
//           content: Text(_prayerConflict.message),
//         ),


//       // فحص تعارض المهام
//         newTaskDate: _selectedDate,
//         durationMinutes: _selectedDuration ?? 30,
//         excludeTaskId: widget.taskToEdit?.id,

//       // ⚠️ أولوية التحذيرات:
//       // 1. إذا كان هناك تعارض مهام -> نظهر خيارات المهام
//       // 2. إذا لم يوجد تعارض مهام ولكن يوجد تحذير صلاة (أصفر) -> نظهر خيارات الصلاة



//         // ✅ استدعاء النافذة المحسنة
//         return; // الخروج لأن الديالوج سيتعامل مع الحفظ أو الإلغاء

//       // إذا لم يوجد أي تعارض
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("حدث خطأ: $e"),
//             duration: const Duration(seconds: 3), // ✅ 3 ثواني
//             behavior: SnackBarBehavior.floating,
//           ),

//   // 2. ✅ دالة عرض خيارات التعارض المحسنة
//         ? DateFormat('h:mm a', 'ar').format(conflict.suggestedTime!)

//       context: context,
//       barrierDismissible: false,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.r),
//         ),
//         elevation: 10,
//         backgroundColor: Colors.white,
//         child: Padding(
//           padding: EdgeInsets.all(20.w),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // الأيقونة والعنوان
//               Container(
//                 padding: EdgeInsets.all(12.w),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF7ED), // برتقالي فاتح جداً
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.warning_amber_rounded,
//                   color: Colors.orange,
//                   size: 32,
//                 ),
//               ),
//               SizedBox(height: 16.h),

//               Text(
//                 "انتبه، يوجد تداخل زمني",
//                 style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8.h),

//               Text(
//                 conflict.message,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
//               ),
//               SizedBox(height: 24.h),

//               // --- الخيارات الثلاثة ---

//               // الخيار 1: التأجيل (الأذكى)
//                 _buildDialogButton(
//                   icon: Icons.access_time_filled_rounded,
//                   color: AppColors.primary,
//                   textColor: Colors.white,
//                   title: "تأجيل لما بعد الانتهاء",
//                   subtitle: "نقل الموعد إلى $newTimeFormatted",
//                     _performSave(); // حفظ مباشر
//                   },
//                 ),


//               // الخيار 2: التجاهل
//               _buildDialogButton(
//                 icon: Icons.check_circle_outline_rounded,
//                 color: Colors.grey.shade100,
//                 textColor: Colors.black87,
//                 title: "حفظ على أي حال",
//                 subtitle: "إبقاء الوقت كما هو",
//                 },
//               ),

//               SizedBox(height: 12.h),

//               // الخيار 3: الإلغاء/التعديل اليدوي
//               TextButton(
//                 },
//                 child: Text(
//                   "إلغاء وتعديل الوقت يدوياً",
//                   style: TextStyle(color: Colors.grey, fontSize: 13.sp),
//                 ),
//               ),
//           ),
//         ),
//       ),

//   // ويدجت مساعدة لأزرار الديالوج
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12.r),
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(12.r),
//               ? Border.all(color: Colors.grey.shade300)
//               : null,
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: textColor, size: 22.sp),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       color: textColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13.sp,
//                     ),
//                   ),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       color: textColor.withValues(alpha: 0.8),
//                       fontSize: 11.sp,
//                     ),
//                   ),
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: textColor.withValues(alpha: 0.5),
//               size: 14.sp,
//             ),
//         ),
//       ),


//       task
//         ..durationMinutes = _selectedDuration ?? 30; // القيمة الافتراضية


//       cubit.addTask(
//         title: _titleController.text,
//         date: _selectedDate,
//         isUrgent: _isUrgent,
//         isImportant: _isImportant,
//         category: _selectedCategory, // ✅ تمرير التصنيف المختار
//         duration: _selectedDuration ?? 30, // القيمة الافتراضية
//         project: _selectedProject,

//     // إغلاق النافذة

//------------------------------------------------------------------------
// import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart'; // ✅ استيراد المكون الجديد
// import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:athar/features/space/presentation/widgets/member_selector_sheet.dart';
// import 'package:athar/features/task/presentation/widgets/components/category_selector.dart';
// import 'package:athar/features/task/presentation/widgets/components/date_time_picker.dart';
// import 'package:athar/features/task/presentation/widgets/components/duration_picker.dart';
// import 'package:athar/features/task/presentation/widgets/components/priority_selector.dart';
// import 'package:athar/features/task/presentation/widgets/dialogs/conflict_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/settings/data/models/category_model.dart';
// import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
// import 'package:athar/core/design_system/design_system.dart';
// import '../../data/models/task_model.dart';
// import '../cubit/task_cubit.dart';
// import '../../../../core/services/prayer_conflict_service.dart';
// import '../../domain/models/conflict_result.dart';
// import '../../../../features/prayer/presentation/cubit/prayer_cubit.dart';
// import '../../../../features/prayer/presentation/cubit/prayer_state.dart';
// import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
// import '../../../../features/settings/presentation/cubit/settings_state.dart';
// import '../../../../features/settings/data/models/user_settings.dart';

// class AddTaskSheet extends StatefulWidget {
//   final String? targetModuleId;
//   final String? targetSpaceId;
//   final TaskModel? taskToEdit;

//   const AddTaskSheet({
//     super.key,
//     this.targetModuleId,
//     this.targetSpaceId,
//     this.taskToEdit,
//   });

//   @override
//   State<AddTaskSheet> createState() => _AddTaskSheetState();
// }

// class _AddTaskSheetState extends State<AddTaskSheet> {
//   final TextEditingController _titleController = TextEditingController();
//   DateTime _selectedDate = DateTime.now();
//   bool _isUrgent = false;
//   bool _isImportant = false;
//   int _selectedDuration = 30;
//   CategoryModel? _selectedCategory;
//   String? _selectedAssigneeId;

//   // ✅ الخطوة 1: تعريف متغيرات التذكير
//   DateTime? _reminderTime;
//   bool _isReminderEnabled = false;

//   bool _isHijriMode = false;
//   bool _isSaving = false;

//   ConflictResult _prayerConflict = ConflictResult.none();
//   final _prayerConflictService = getIt<PrayerConflictService>();

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//     _initForm();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _checkPrayerConflict());
//   }

//   void _loadData() async {
//     if (mounted) {
//       context.read<CategoryCubit>().loadCategories();
//     }
//     final settings = await getIt<SettingsRepository>().getSettings();

//     if (mounted) {
//       setState(() {
//         _isHijriMode = settings.isHijriMode;
//       });
//     }
//   }

//   void _initForm() {
//     if (widget.taskToEdit != null) {
//       final t = widget.taskToEdit!;
//       _titleController.text = t.title;
//       _selectedDate = t.date;
//       _isUrgent = t.isUrgent;
//       _isImportant = t.isImportant;
//       _selectedCategory = t.category.value;
//       _selectedDuration = t.durationMinutes;
//       _selectedAssigneeId = t.assigneeId;

//       // ✅ تحميل حالة التذكير عند التعديل
//       if (t.reminderTime != null) {
//         _reminderTime = t.reminderTime;
//         _isReminderEnabled = true;
//       }
//     }
//   }

//   void _checkPrayerConflict() {
//     final prayerState = context.read<PrayerCubit>().state;
//     final settingsState = context.read<SettingsCubit>().state;

//     List<PrayerTime> prayers = [];
//     if (prayerState is PrayerLoaded) {
//       prayers = prayerState.allPrayers;
//     }
//     UserSettings currentSettings = UserSettings();
//     if (settingsState is SettingsLoaded) {
//       currentSettings = settingsState.settings;
//     }

//     final result = _prayerConflictService.checkConflict(
//       taskStartTime: _selectedDate,
//       taskDuration: Duration(minutes: _selectedDuration),
//       prayers: prayers,
//       settings: currentSettings,
//     );

//     if (mounted) {
//       setState(() {
//         _prayerConflict = result;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Container(
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       padding: EdgeInsets.fromLTRB(
//         20.w,
//         20.h,
//         20.w,
//         MediaQuery.of(context).viewInsets.bottom + 20.h,
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40.w,
//                 height: 4.h,
//                 decoration: BoxDecoration(
//                   color: colors.borderLight,
//                   borderRadius: AtharRadii.radiusXxxs,
//                 ),
//               ),
//             ),
//             AtharGap.xl,
//             Text(
//               widget.taskToEdit != null ? "تعديل المهمة" : "مهمة جديدة",
//               style: Theme.of(
//                 context,
//               ).textTheme.displayLarge?.copyWith(fontSize: 18.sp),
//             ),
//             AtharGap.lg,
//             TextField(
//               controller: _titleController,
//               autofocus: true,
//               decoration: InputDecoration(
//                 hintText: "ماذا تريد أن تنجز؟",
//                 filled: true,
//                 fillColor: colors.scaffoldBackground,
//                 border: OutlineInputBorder(
//                   borderRadius: AtharRadii.radiusMd,
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16.w,
//                   vertical: 14.h,
//                 ),
//               ),
//             ),
//             AtharGap.lg,
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: DateTimePicker(
//                     selectedDate: _selectedDate,
//                     isHijriMode: _isHijriMode,
//                     onDateTap: _pickDate,
//                     onTimeTap: _pickTime,
//                   ),
//                 ),
//               ],
//             ),
//             if (_prayerConflict.hasConflict) ...[
//               AtharGap.md,
//               _buildConflictWarning(),
//             ],
//             AtharGap.md,
//             DurationPicker(
//               selectedDuration: _selectedDuration,
//               onDurationSelected: (val) {
//                 setState(() => _selectedDuration = val);
//                 _checkPrayerConflict();
//               },
//             ),
//             AtharGap.lg,

//             // ✅ الخطوة 2: حقن الـ ReminderPickerWidget
//             ReminderPickerWidget(
//               reminderTime: _reminderTime,
//               isEnabled: _isReminderEnabled,
//               onToggle: (val) {
//                 setState(() {
//                   _isReminderEnabled = val;
//                   // إذا تم التفعيل ولم يتم اختيار وقت، نضع وقت المهمة كافتراضي
//                   if (val && _reminderTime == null) {
//                     _reminderTime = _selectedDate.subtract(
//                       const Duration(minutes: 10),
//                     );
//                   }
//                 });
//               },
//               onTimeChanged: (newTime) =>
//                   setState(() => _reminderTime = newTime),
//             ),

//             AtharGap.md,

//             if (widget.targetSpaceId != null ||
//                 (widget.taskToEdit?.spaceId != null)) ...[
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: Container(
//                   padding: AtharSpacing.allSm,
//                   decoration: BoxDecoration(
//                     color: colors.primary.withValues(alpha: 0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.person_add_alt_1, color: colors.primary),
//                 ),
//                 title: Text(
//                   _selectedAssigneeId == null
//                       ? "إسناد إلى عضو (اختياري)"
//                       : "تم اختيار عضو",
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: _selectedAssigneeId != null
//                         ? FontWeight.bold
//                         : FontWeight.normal,
//                   ),
//                 ),
//                 trailing: _selectedAssigneeId != null
//                     ? IconButton(
//                         icon: Icon(Icons.clear, color: colors.error),
//                         onPressed: () =>
//                             setState(() => _selectedAssigneeId = null),
//                       )
//                     : Icon(
//                         Icons.arrow_forward_ios,
//                         size: 16,
//                         color: colors.textTertiary,
//                       ),
//                 onTap: () async {
//                   final spaceId =
//                       widget.targetSpaceId ?? widget.taskToEdit?.spaceId;
//                   if (spaceId != null) {
//                     final result = await showModalBottomSheet(
//                       context: context,
//                       builder: (_) => MemberSelectorSheet(
//                         spaceId: spaceId,
//                         currentAssigneeId: _selectedAssigneeId,
//                       ),
//                     );
//                     if (result != null) {
//                       setState(
//                         () => _selectedAssigneeId = result == 'unassign'
//                             ? null
//                             : result,
//                       );
//                     }
//                   }
//                 },
//               ),
//               const Divider(),
//               AtharGap.md,
//             ],
//             PrioritySelector(
//               isUrgent: _isUrgent,
//               isImportant: _isImportant,
//               onUrgentChanged: (val) => setState(() => _isUrgent = val),
//               onImportantChanged: (val) => setState(() => _isImportant = val),
//             ),
//             AtharGap.md,
//             CategorySelector(
//               selectedCategory: _selectedCategory,
//               onSelected: (cat) => setState(() => _selectedCategory = cat),
//               onAddPressed: () => _showAddCategoryDialog(),
//             ),
//             AtharGap.xl,
//             SizedBox(
//               width: double.infinity,
//               child: AtharButton(
//                 label: widget.taskToEdit != null
//                     ? "حفظ التعديلات"
//                     : "إضافة المهمة",
//                 onPressed: _isSaving ? null : _saveTask,
//                 isLoading: _isSaving,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- Helpers ---

//   Widget _buildConflictWarning() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: AtharSpacing.allMd,
//       decoration: BoxDecoration(
//         color: _prayerConflict.color.withValues(alpha: 0.1),
//         border: Border.all(color: _prayerConflict.color),
//         borderRadius: AtharRadii.radiusMd,
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.access_time_filled, color: _prayerConflict.color),
//           AtharGap.hMd,
//           Expanded(
//             child: Text(
//               _prayerConflict.message,
//               style: TextStyle(
//                 color: _prayerConflict.color,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12.sp,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//       locale: const Locale('ar', 'SA'),
//     );
//     if (date != null) {
//       setState(
//         () => _selectedDate = DateTime(
//           date.year,
//           date.month,
//           date.day,
//           _selectedDate.hour,
//           _selectedDate.minute,
//         ),
//       );
//       _checkPrayerConflict();
//     }
//   }

//   Future<void> _pickTime() async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(_selectedDate),
//     );
//     if (time != null) {
//       setState(
//         () => _selectedDate = DateTime(
//           _selectedDate.year,
//           _selectedDate.month,
//           _selectedDate.day,
//           time.hour,
//           time.minute,
//         ),
//       );
//       _checkPrayerConflict();
//     }
//   }

//   void _showAddCategoryDialog() {
//     final nameController = TextEditingController();
//     int selectedColor = 0xFF9C27B0;
//     AtharDialog.show(
//       context: context,
//       title: "تصنيف جديد",
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: nameController,
//             decoration: const InputDecoration(hintText: "اسم التصنيف"),
//           ),
//           AtharGap.sm,
//         ],
//       ),
//       cancelLabel: "إلغاء",
//       confirmLabel: "إضافة",
//       onCancel: () => Navigator.pop(context),
//       onConfirm: () {
//         if (nameController.text.isNotEmpty) {
//           context.read<CategoryCubit>().addCategory(
//             nameController.text,
//             selectedColor,
//             Icons.bookmark.codePoint,
//           );
//           Navigator.pop(context);
//         }
//       },
//     );
//   }

//   void _saveTask() async {
//     if (_titleController.text.trim().isEmpty) return;

//     setState(() => _isSaving = true);
//     final taskCubit = context.read<TaskCubit>();

//     try {
//       final taskConflict = await taskCubit.validateTimeConflict(
//         date: _selectedDate,
//         startTime: TimeOfDay.fromDateTime(_selectedDate),
//         durationMinutes: _selectedDuration,
//         excludeTaskId: widget.taskToEdit?.id,
//       );

//       ConflictResult? finalConflict;
//       if (taskConflict.hasConflict) {
//         finalConflict = taskConflict;
//       } else if (_prayerConflict.hasConflict) {
//         finalConflict = _prayerConflict;
//       }

//       if (finalConflict != null) {
//         setState(() => _isSaving = false);
//         if (!mounted) return;

//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => ConflictDialog(
//             conflict: finalConflict!,
//             onDelay: () {
//               Navigator.pop(context);
//               if (finalConflict!.suggestedTime != null) {
//                 setState(() {
//                   _selectedDate = finalConflict!.suggestedTime!;
//                   _isSaving = true;
//                 });
//                 _checkPrayerConflict();
//                 _performSave();
//               }
//             },
//             onForceSave: () {
//               Navigator.pop(context);
//               setState(() => _isSaving = true);
//               _performSave();
//             },
//             onCancel: () {
//               Navigator.pop(context);
//               setState(() => _isSaving = false);
//             },
//           ),
//         );
//         return;
//       }

//       _performSave();
//     } catch (e) {
//       // ✅ الخطوة 3: إصلاح Async Gap عند حدوث خطأ
//       if (mounted) {
//         setState(() => _isSaving = false);
//         AtharSnackbar.error(context: context, message: "حدث خطأ: $e");
//       }
//     }
//   }

//   void _performSave() {
//     // التحقق من أن الـ State ما زال موجوداً في الشجرة قبل استخدام الـ Context
//     if (!mounted) return;

//     final cubit = context.read<TaskCubit>();

//     if (widget.taskToEdit != null) {
//       final updatedTask = widget.taskToEdit!
//         ..title = _titleController.text
//         ..date = _selectedDate
//         ..isUrgent = _isUrgent
//         ..isImportant = _isImportant
//         ..durationMinutes = _selectedDuration
//         ..assigneeId = _selectedAssigneeId
//         // ✅ الخطوة 4: تحديث التذكير في دالة التعديل
//         ..reminderTime = _isReminderEnabled ? _reminderTime : null;

//       if (_selectedCategory != null) {
//         updatedTask.category.value = _selectedCategory;
//       }

//       cubit.updateTask(updatedTask);
//     } else {
//       cubit.addTask(
//         title: _titleController.text,
//         date: _selectedDate,
//         isUrgent: _isUrgent,
//         isImportant: _isImportant,
//         category: _selectedCategory,
//         duration: _selectedDuration,
//         moduleId: widget.targetModuleId,
//         spaceId: widget.targetSpaceId,
//         assigneeId: _selectedAssigneeId,
//         // ✅ الخطوة 5: تمرير التذكير في دالة الإضافة
//         reminderTime: _isReminderEnabled ? _reminderTime : null,
//       );
//     }

//     if (mounted) Navigator.pop(context);
//   }
// }

// ------------------------------------------------------------------------
// import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart'; // ✅ استيراد المكون الجديد
// import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:athar/features/space/presentation/widgets/member_selector_sheet.dart';
// import 'package:athar/features/task/presentation/widgets/components/category_selector.dart';
// import 'package:athar/features/task/presentation/widgets/components/date_time_picker.dart';
// import 'package:athar/features/task/presentation/widgets/components/duration_picker.dart';
// import 'package:athar/features/task/presentation/widgets/components/priority_selector.dart';
// import 'package:athar/features/task/presentation/widgets/dialogs/conflict_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/settings/data/models/category_model.dart';
// import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../data/models/task_model.dart';
// import '../cubit/task_cubit.dart';
// import '../../../../core/services/prayer_conflict_service.dart';
// import '../../domain/models/conflict_result.dart';
// import '../../../../features/prayer/presentation/cubit/prayer_cubit.dart';
// import '../../../../features/prayer/presentation/cubit/prayer_state.dart';
// import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
// import '../../../../features/settings/presentation/cubit/settings_state.dart';
// import '../../../../features/settings/data/models/user_settings.dart';

// class AddTaskSheet extends StatefulWidget {
//   final String? targetModuleId;
//   final String? targetSpaceId;
//   final TaskModel? taskToEdit;

//   const AddTaskSheet({
//     super.key,
//     this.targetModuleId,
//     this.targetSpaceId,
//     this.taskToEdit,
//   });

//   @override
//   State<AddTaskSheet> createState() => _AddTaskSheetState();
// }

// class _AddTaskSheetState extends State<AddTaskSheet> {
//   final TextEditingController _titleController = TextEditingController();
//   DateTime _selectedDate = DateTime.now();
//   bool _isUrgent = false;
//   bool _isImportant = false;
//   int _selectedDuration = 30;
//   CategoryModel? _selectedCategory;
//   String? _selectedAssigneeId;

//   // ✅ الخطوة 1: تعريف متغيرات التذكير
//   DateTime? _reminderTime;
//   bool _isReminderEnabled = false;

//   bool _isHijriMode = false;
//   bool _isSaving = false;

//   ConflictResult _prayerConflict = ConflictResult.none();
//   final _prayerConflictService = getIt<PrayerConflictService>();

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//     _initForm();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _checkPrayerConflict());
//   }

//   void _loadData() async {
//     if (mounted) {
//       context.read<CategoryCubit>().loadCategories();
//     }
//     final settings = await getIt<SettingsRepository>().getSettings();

//     if (mounted) {
//       setState(() {
//         _isHijriMode = settings.isHijriMode;
//       });
//     }
//   }

//   void _initForm() {
//     if (widget.taskToEdit != null) {
//       final t = widget.taskToEdit!;
//       _titleController.text = t.title;
//       _selectedDate = t.date;
//       _isUrgent = t.isUrgent;
//       _isImportant = t.isImportant;
//       _selectedCategory = t.category.value;
//       _selectedDuration = t.durationMinutes;
//       _selectedAssigneeId = t.assigneeId;

//       // ✅ تحميل حالة التذكير عند التعديل
//       if (t.reminderTime != null) {
//         _reminderTime = t.reminderTime;
//         _isReminderEnabled = true;
//       }
//     }
//   }

//   void _checkPrayerConflict() {
//     final prayerState = context.read<PrayerCubit>().state;
//     final settingsState = context.read<SettingsCubit>().state;

//     List<PrayerTime> prayers = [];
//     if (prayerState is PrayerLoaded) {
//       prayers = prayerState.allPrayers;
//     }
//     UserSettings currentSettings = UserSettings();
//     if (settingsState is SettingsLoaded) {
//       currentSettings = settingsState.settings;
//     }

//     final result = _prayerConflictService.checkConflict(
//       taskStartTime: _selectedDate,
//       taskDuration: Duration(minutes: _selectedDuration),
//       prayers: prayers,
//       settings: currentSettings,
//     );

//     if (mounted) {
//       setState(() {
//         _prayerConflict = result;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       padding: EdgeInsets.fromLTRB(
//         20.w,
//         20.h,
//         20.w,
//         MediaQuery.of(context).viewInsets.bottom + 20.h,
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40.w,
//                 height: 4.h,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               widget.taskToEdit != null ? "تعديل المهمة" : "مهمة جديدة",
//               style: Theme.of(
//                 context,
//               ).textTheme.displayLarge?.copyWith(fontSize: 18.sp),
//             ),
//             SizedBox(height: 16.h),
//             TextField(
//               controller: _titleController,
//               autofocus: true,
//               decoration: InputDecoration(
//                 hintText: "ماذا تريد أن تنجز؟",
//                 filled: true,
//                 fillColor: AppColors.background,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16.w,
//                   vertical: 14.h,
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: DateTimePicker(
//                     selectedDate: _selectedDate,
//                     isHijriMode: _isHijriMode,
//                     onDateTap: _pickDate,
//                     onTimeTap: _pickTime,
//                   ),
//                 ),
//               ],
//             ),
//             if (_prayerConflict.hasConflict) ...[
//               SizedBox(height: 12.h),
//               _buildConflictWarning(),
//             ],
//             SizedBox(height: 12.h),
//             DurationPicker(
//               selectedDuration: _selectedDuration,
//               onDurationSelected: (val) {
//                 setState(() => _selectedDuration = val);
//                 _checkPrayerConflict();
//               },
//             ),
//             SizedBox(height: 16.h),

//             // ✅ الخطوة 2: حقن الـ ReminderPickerWidget
//             ReminderPickerWidget(
//               reminderTime: _reminderTime,
//               isEnabled: _isReminderEnabled,
//               onToggle: (val) {
//                 setState(() {
//                   _isReminderEnabled = val;
//                   // إذا تم التفعيل ولم يتم اختيار وقت، نضع وقت المهمة كافتراضي
//                   if (val && _reminderTime == null) {
//                     _reminderTime = _selectedDate.subtract(
//                       const Duration(minutes: 10),
//                     );
//                   }
//                 });
//               },
//               onTimeChanged: (newTime) =>
//                   setState(() => _reminderTime = newTime),
//             ),

//             SizedBox(height: 12.h),

//             if (widget.targetSpaceId != null ||
//                 (widget.taskToEdit?.spaceId != null)) ...[
//               ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: Container(
//                   padding: EdgeInsets.all(8.w),
//                   decoration: BoxDecoration(
//                     color: Colors.purple.withValues(alpha: 0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.person_add_alt_1,
//                     color: Colors.purple,
//                   ),
//                 ),
//                 title: Text(
//                   _selectedAssigneeId == null
//                       ? "إسناد إلى عضو (اختياري)"
//                       : "تم اختيار عضو",
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: _selectedAssigneeId != null
//                         ? FontWeight.bold
//                         : FontWeight.normal,
//                   ),
//                 ),
//                 trailing: _selectedAssigneeId != null
//                     ? IconButton(
//                         icon: const Icon(Icons.clear, color: Colors.red),
//                         onPressed: () =>
//                             setState(() => _selectedAssigneeId = null),
//                       )
//                     : const Icon(
//                         Icons.arrow_forward_ios,
//                         size: 16,
//                         color: Colors.grey,
//                       ),
//                 onTap: () async {
//                   final spaceId =
//                       widget.targetSpaceId ?? widget.taskToEdit?.spaceId;
//                   if (spaceId != null) {
//                     final result = await showModalBottomSheet(
//                       context: context,
//                       builder: (_) => MemberSelectorSheet(
//                         spaceId: spaceId,
//                         currentAssigneeId: _selectedAssigneeId,
//                       ),
//                     );
//                     if (result != null) {
//                       setState(
//                         () => _selectedAssigneeId = result == 'unassign'
//                             ? null
//                             : result,
//                       );
//                     }
//                   }
//                 },
//               ),
//               const Divider(),
//               SizedBox(height: 12.h),
//             ],
//             PrioritySelector(
//               isUrgent: _isUrgent,
//               isImportant: _isImportant,
//               onUrgentChanged: (val) => setState(() => _isUrgent = val),
//               onImportantChanged: (val) => setState(() => _isImportant = val),
//             ),
//             SizedBox(height: 12.h),
//             CategorySelector(
//               selectedCategory: _selectedCategory,
//               onSelected: (cat) => setState(() => _selectedCategory = cat),
//               onAddPressed: () => _showAddCategoryDialog(),
//             ),
//             SizedBox(height: 20.h),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isSaving ? null : _saveTask,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   padding: EdgeInsets.symmetric(vertical: 14.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 child: _isSaving
//                     ? SizedBox(
//                         width: 24.w,
//                         height: 24.w,
//                         child: const CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : Text(
//                         widget.taskToEdit != null
//                             ? "حفظ التعديلات"
//                             : "إضافة المهمة",
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- Helpers ---

//   Widget _buildConflictWarning() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: _prayerConflict.color.withValues(alpha: 0.1),
//         border: Border.all(color: _prayerConflict.color),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.access_time_filled, color: _prayerConflict.color),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Text(
//               _prayerConflict.message,
//               style: TextStyle(
//                 color: _prayerConflict.color,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12.sp,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//       locale: const Locale('ar', 'SA'),
//     );
//     if (date != null) {
//       setState(
//         () => _selectedDate = DateTime(
//           date.year,
//           date.month,
//           date.day,
//           _selectedDate.hour,
//           _selectedDate.minute,
//         ),
//       );
//       _checkPrayerConflict();
//     }
//   }

//   Future<void> _pickTime() async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(_selectedDate),
//     );
//     if (time != null) {
//       setState(
//         () => _selectedDate = DateTime(
//           _selectedDate.year,
//           _selectedDate.month,
//           _selectedDate.day,
//           time.hour,
//           time.minute,
//         ),
//       );
//       _checkPrayerConflict();
//     }
//   }

//   void _showAddCategoryDialog() {
//     final nameController = TextEditingController();
//     int selectedColor = 0xFF9C27B0;
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("تصنيف جديد"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(hintText: "اسم التصنيف"),
//             ),
//             SizedBox(height: 10.h),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("إلغاء"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (nameController.text.isNotEmpty) {
//                 context.read<CategoryCubit>().addCategory(
//                   nameController.text,
//                   selectedColor,
//                   Icons.bookmark.codePoint,
//                 );
//                 Navigator.pop(ctx);
//               }
//             },
//             child: const Text("إضافة"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _saveTask() async {
//     if (_titleController.text.trim().isEmpty) return;

//     setState(() => _isSaving = true);
//     final taskCubit = context.read<TaskCubit>();

//     try {
//       final taskConflict = await taskCubit.validateTimeConflict(
//         date: _selectedDate,
//         startTime: TimeOfDay.fromDateTime(_selectedDate),
//         durationMinutes: _selectedDuration,
//         excludeTaskId: widget.taskToEdit?.id,
//       );

//       ConflictResult? finalConflict;
//       if (taskConflict.hasConflict) {
//         finalConflict = taskConflict;
//       } else if (_prayerConflict.hasConflict) {
//         finalConflict = _prayerConflict;
//       }

//       if (finalConflict != null) {
//         setState(() => _isSaving = false);
//         if (!mounted) return;

//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => ConflictDialog(
//             conflict: finalConflict!,
//             onDelay: () {
//               Navigator.pop(context);
//               if (finalConflict!.suggestedTime != null) {
//                 setState(() {
//                   _selectedDate = finalConflict!.suggestedTime!;
//                   _isSaving = true;
//                 });
//                 _checkPrayerConflict();
//                 _performSave();
//               }
//             },
//             onForceSave: () {
//               Navigator.pop(context);
//               setState(() => _isSaving = true);
//               _performSave();
//             },
//             onCancel: () {
//               Navigator.pop(context);
//               setState(() => _isSaving = false);
//             },
//           ),
//         );
//         return;
//       }

//       _performSave();
//     } catch (e) {
//       // ✅ الخطوة 3: إصلاح Async Gap عند حدوث خطأ
//       if (mounted) {
//         setState(() => _isSaving = false);
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
//       }
//     }
//   }

//   void _performSave() {
//     // التحقق من أن الـ State ما زال موجوداً في الشجرة قبل استخدام الـ Context
//     if (!mounted) return;

//     final cubit = context.read<TaskCubit>();

//     if (widget.taskToEdit != null) {
//       final updatedTask = widget.taskToEdit!
//         ..title = _titleController.text
//         ..date = _selectedDate
//         ..isUrgent = _isUrgent
//         ..isImportant = _isImportant
//         ..durationMinutes = _selectedDuration
//         ..assigneeId = _selectedAssigneeId
//         // ✅ الخطوة 4: تحديث التذكير في دالة التعديل
//         ..reminderTime = _isReminderEnabled ? _reminderTime : null;

//       if (_selectedCategory != null) {
//         updatedTask.category.value = _selectedCategory;
//       }

//       cubit.updateTask(updatedTask);
//     } else {
//       cubit.addTask(
//         title: _titleController.text,
//         date: _selectedDate,
//         isUrgent: _isUrgent,
//         isImportant: _isImportant,
//         category: _selectedCategory,
//         duration: _selectedDuration,
//         moduleId: widget.targetModuleId,
//         spaceId: widget.targetSpaceId,
//         assigneeId: _selectedAssigneeId,
//         // ✅ الخطوة 5: تمرير التذكير في دالة الإضافة
//         reminderTime: _isReminderEnabled ? _reminderTime : null,
//       );
//     }

//     if (mounted) Navigator.pop(context);
//   }
// }

// ----------------------------------------
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';
// import 'package:athar/features/task/presentation/widgets/components/category_selector.dart';
// import 'package:athar/features/task/presentation/widgets/components/date_time_picker.dart';
// import 'package:athar/features/task/presentation/widgets/components/duration_picker.dart';
// import 'package:athar/features/task/presentation/widgets/components/priority_selector.dart';
// import 'package:athar/features/task/presentation/widgets/components/project_selector.dart';
// import 'package:athar/features/task/presentation/widgets/dialogs/conflict_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/features/project/data/models/project_model.dart';
// import 'package:athar/features/project/data/repositories/project_repository.dart';
// import 'package:athar/features/settings/data/models/category_model.dart';
// import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
// import '../../../../core/design_system/theme/app_colors.dart';
// import '../../data/models/task_model.dart';
// import '../cubit/task_cubit.dart';
// import '../../../../core/services/prayer_conflict_service.dart';
// import '../../domain/models/conflict_result.dart';
// import '../../../../features/prayer/presentation/cubit/prayer_cubit.dart';
// import '../../../../features/prayer/presentation/cubit/prayer_state.dart';
// import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
// import '../../../../features/settings/presentation/cubit/settings_state.dart';
// import '../../../../features/settings/data/models/user_settings.dart';
// import '../../../../features/task/data/models/prayer_item.dart';

// class AddTaskSheet extends StatefulWidget {
//   final ProjectModel? project;
//   final TaskModel? taskToEdit;
//   const AddTaskSheet({super.key, this.project, this.taskToEdit});

//   @override
//   State<AddTaskSheet> createState() => _AddTaskSheetState();
// }

// class _AddTaskSheetState extends State<AddTaskSheet> {
//   final TextEditingController _titleController = TextEditingController();
//   DateTime _selectedDate = DateTime.now();
//   bool _isUrgent = false;
//   bool _isImportant = false;
//   int _selectedDuration = 30;
//   CategoryModel? _selectedCategory;
//   ProjectModel? _selectedProject;

//   bool _isHijriMode = false;
//   bool _isSaving = false;

//   // تعارض الصلاة يبقى مفصولاً لأنه يعتمد على UI Feedback فوري (الرسالة الصفراء)
//   ConflictResult _prayerConflict = ConflictResult.none();

//   List<ProjectModel> _availableProjects = [];
//   final _prayerConflictService = getIt<PrayerConflictService>();

//   // ❌ حذفنا استدعاء الـ taskConflictService من هنا

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//     _initForm();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _checkPrayerConflict());
//   }

//   void _loadData() async {
//     if (mounted) {
//       context.read<CategoryCubit>().loadCategories();
//     }
//     final projects = await getIt<ProjectRepository>().getAllProjects();
//     final settings = await getIt<SettingsRepository>().getSettings();

//     if (mounted) {
//       setState(() {
//         _availableProjects = projects;
//         _isHijriMode = settings.isHijriMode;
//       });
//     }
//   }

//   void _initForm() {
//     if (widget.taskToEdit != null) {
//       final t = widget.taskToEdit!;
//       _titleController.text = t.title;
//       _selectedDate = t.date;
//       _isUrgent = t.isUrgent;
//       _isImportant = t.isImportant;
//       _selectedCategory = t.category.value;
//       _selectedDuration = t.durationMinutes;
//       // _selectedProject = t.project.value;
//     } else {
//       _selectedProject = widget.project;
//     }
//   }

//   void _checkPrayerConflict() {
//     final prayerState = context.read<PrayerCubit>().state;
//     final settingsState = context.read<SettingsCubit>().state;

//     List<PrayerItem> prayers = [];
//     if (prayerState is PrayerLoaded) {
//       prayers = prayerState.allPrayers;
//     }

//     UserSettings currentSettings = UserSettings();
//     if (settingsState is SettingsLoaded) {
//       currentSettings = settingsState.settings;
//     }

//     final result = _prayerConflictService.checkConflict(
//       taskStartTime: _selectedDate,
//       taskDuration: Duration(minutes: _selectedDuration),
//       prayers: prayers,
//       settings: currentSettings,
//     );

//     if (mounted) {
//       setState(() {
//         _prayerConflict = result;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ... (نفس كود التصميم السابق بدون تغيير)
//     // سأختصره هنا للتركيز على المنطق، لكنه يبقى كما هو في ملفك
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       padding: EdgeInsets.fromLTRB(
//         20.w,
//         20.h,
//         20.w,
//         MediaQuery.of(context).viewInsets.bottom + 20.h,
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40.w,
//                 height: 4.h,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),

//             Text(
//               widget.taskToEdit != null ? "تعديل المهمة" : "مهمة جديدة",
//               style: Theme.of(
//                 context,
//               ).textTheme.displayLarge?.copyWith(fontSize: 18.sp),
//             ),
//             SizedBox(height: 16.h),

//             // 1. حقل العنوان
//             TextField(
//               controller: _titleController,
//               autofocus: true,
//               decoration: InputDecoration(
//                 hintText: "ماذا تريد أن تنجز؟",
//                 filled: true,
//                 fillColor: AppColors.background,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16.w,
//                   vertical: 14.h,
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.h),

//             // 2. الصف العلوي (تاريخ، وقت، مشروع)
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 DateTimePicker(
//                   selectedDate: _selectedDate,
//                   isHijriMode: _isHijriMode,
//                   onDateTap: _pickDate,
//                   onTimeTap: _pickTime,
//                 ),
//                 SizedBox(width: 8.w),
//                 ProjectSelector(
//                   selectedProject: _selectedProject,
//                   availableProjects: _availableProjects,
//                   onSelected: (proj) => setState(() => _selectedProject = proj),
//                 ),
//               ],
//             ),

//             // 3. تنبيه التعارض (يظهر فقط إذا وجد تعارض)
//             if (_prayerConflict.hasConflict) ...[
//               SizedBox(height: 12.h),
//               _buildConflictWarning(),
//             ],

//             SizedBox(height: 12.h),

//             // 4. المدة
//             DurationPicker(
//               selectedDuration: _selectedDuration,
//               onDurationSelected: (val) {
//                 setState(() => _selectedDuration = val);
//                 _checkPrayerConflict();
//               },
//             ),

//             SizedBox(height: 12.h),

//             // 5. الأولوية
//             PrioritySelector(
//               isUrgent: _isUrgent,
//               isImportant: _isImportant,
//               onUrgentChanged: (val) => setState(() => _isUrgent = val),
//               onImportantChanged: (val) => setState(() => _isImportant = val),
//             ),

//             SizedBox(height: 12.h),

//             // 6. التصنيف
//             CategorySelector(
//               selectedCategory: _selectedCategory,
//               onSelected: (cat) => setState(() => _selectedCategory = cat),
//               onAddPressed: () => _showAddCategoryDialog(),
//             ),

//             SizedBox(height: 20.h),

//             // زر الحفظ
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _isSaving ? null : _saveTask,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   padding: EdgeInsets.symmetric(vertical: 14.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 child: _isSaving
//                     ? SizedBox(
//                         width: 24.w,
//                         height: 24.w,
//                         child: const CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : Text(
//                         widget.taskToEdit != null
//                             ? "حفظ التعديلات"
//                             : "إضافة المهمة",
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ... (نفس الـ Helpers السابقة: _buildConflictWarning, _pickDate, _pickTime, _showAddCategoryDialog)
//   Widget _buildConflictWarning() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: _prayerConflict.color.withValues(alpha: 0.1),
//         border: Border.all(color: _prayerConflict.color),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.access_time_filled, color: _prayerConflict.color),
//           SizedBox(width: 12.w),
//           Expanded(
//             child: Text(
//               _prayerConflict.message,
//               style: TextStyle(
//                 color: _prayerConflict.color,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12.sp,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//       locale: const Locale('ar', 'SA'),
//     );
//     if (date != null) {
//       setState(
//         () => _selectedDate = DateTime(
//           date.year,
//           date.month,
//           date.day,
//           _selectedDate.hour,
//           _selectedDate.minute,
//         ),
//       );
//       _checkPrayerConflict();
//     }
//   }

//   Future<void> _pickTime() async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(_selectedDate),
//     );
//     if (time != null) {
//       setState(
//         () => _selectedDate = DateTime(
//           _selectedDate.year,
//           _selectedDate.month,
//           _selectedDate.day,
//           time.hour,
//           time.minute,
//         ),
//       );
//       _checkPrayerConflict();
//     }
//   }

//   void _showAddCategoryDialog() {
//     final nameController = TextEditingController();
//     int selectedColor = 0xFF9C27B0;
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("تصنيف جديد"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(hintText: "اسم التصنيف"),
//             ),
//             SizedBox(height: 10.h),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("إلغاء"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (nameController.text.isNotEmpty) {
//                 context.read<CategoryCubit>().addCategory(
//                   nameController.text,
//                   selectedColor,
//                   Icons.bookmark.codePoint,
//                 );
//                 Navigator.pop(ctx);
//               }
//             },
//             child: const Text("إضافة"),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅✅ التعديل الجوهري هنا: دالة الحفظ الجديدة
//   void _saveTask() async {
//     if (_titleController.text.trim().isEmpty) return;

//     setState(() => _isSaving = true);
//     final taskCubit = context.read<TaskCubit>();

//     try {
//       // ✅ 1. بدلاً من استدعاء Service خارجي، نسأل الكيوبت مباشرة
//       // ملاحظة: نفترض أنك أضفت دالة validateTimeConflict في TaskCubit كما اتفقنا سابقاً
//       final taskConflict = await taskCubit.validateTimeConflict(
//         date: _selectedDate, // نمرر التاريخ كاملاً
//         startTime: TimeOfDay.fromDateTime(_selectedDate),
//         durationMinutes: _selectedDuration,
//         excludeTaskId: widget.taskToEdit?.id,
//       );

//       // 2. تحديد التعارض الأهم
//       ConflictResult? finalConflict;

//       if (taskConflict.hasConflict) {
//         finalConflict = taskConflict;
//       } else if (_prayerConflict.hasConflict) {
//         // إذا كان تعارض صلاة، نظهره للمستخدم ليقرر
//         finalConflict = _prayerConflict;
//       }

//       if (finalConflict != null) {
//         setState(() => _isSaving = false);
//         if (!mounted) return;

//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (_) => ConflictDialog(
//             conflict: finalConflict!,
//             onDelay: () {
//               Navigator.pop(context);
//               if (finalConflict!.suggestedTime != null) {
//                 setState(() {
//                   _selectedDate = finalConflict!.suggestedTime!;
//                   _isSaving = true;
//                 });
//                 _checkPrayerConflict();
//                 _performSave();
//               }
//             },
//             onForceSave: () {
//               Navigator.pop(context);
//               setState(() => _isSaving = true);
//               _performSave();
//             },
//             onCancel: () {
//               Navigator.pop(context);
//               setState(() => _isSaving = false);
//             },
//           ),
//         );
//         return;
//       }

//       // لا توجد تعارضات، حفظ مباشر
//       _performSave();
//     } catch (e) {
//       setState(() => _isSaving = false);
//       // معالجة الأخطاء
//     }
//   }

//   void _performSave() {
//     final cubit = context.read<TaskCubit>();
//     if (widget.taskToEdit != null) {
//       final updatedTask = widget.taskToEdit!
//         ..title = _titleController.text
//         ..date = _selectedDate
//         ..isUrgent = _isUrgent
//         ..isImportant = _isImportant
//         ..durationMinutes = _selectedDuration;

//       if (_selectedCategory != null) {
//         updatedTask.category.value = _selectedCategory;
//       }
//       if (_selectedProject != null) {
//         // updatedTask.project.value = _selectedProject;
//       }

//       cubit.updateTask(updatedTask);
//     } else {
//       cubit.addTask(
//         title: _titleController.text,
//         date: _selectedDate,
//         isUrgent: _isUrgent,
//         isImportant: _isImportant,
//         category: _selectedCategory,
//         duration: _selectedDuration,
//         // project: _selectedProject,
//       );
//     }
//     Navigator.pop(context);
//   }
// }

// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:hijri/hijri_calendar.dart'; // للتحويل الهجري
// import 'package:intl/intl.dart';

// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/services/time_conflict_service.dart';
// import 'package:athar/features/project/data/models/project_model.dart';
// import 'package:athar/features/project/data/repositories/project_repository.dart';
// import 'package:athar/features/settings/data/models/category_model.dart';

// import '../../../../core/design_system/theme/app_colors.dart';
// import '../../data/models/task_model.dart';
// import '../cubit/task_cubit.dart';

// // ✅ الاستيرادات الجديدة
// import '../../../../core/services/prayer_conflict_service.dart';
// import '../../domain/models/conflict_result.dart';
// import '../../../../features/prayer/presentation/cubit/prayer_cubit.dart';
// import '../../../../features/prayer/presentation/cubit/prayer_state.dart';
// import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
// import '../../../../features/settings/presentation/cubit/settings_state.dart';
// import '../../../../features/settings/data/repositories/settings_repository.dart';
// import '../../../../features/settings/data/models/user_settings.dart';

// class AddTaskSheet extends StatefulWidget {
//   final ProjectModel? project; // مشروع اختياري
//   final TaskModel? taskToEdit; // مهمة للتعديل
//   const AddTaskSheet({super.key, this.project, this.taskToEdit});

//   @override
//   State<AddTaskSheet> createState() => _AddTaskSheetState();
// }

// class _AddTaskSheetState extends State<AddTaskSheet> {
//   final TextEditingController _titleController = TextEditingController();
//   DateTime _selectedDate = DateTime.now();
//   bool _isUrgent = false;
//   bool _isImportant = false;
//   // ✅ التعديل: جعل القيمة الافتراضية 30
//   int? _selectedDuration = 30;

//   // ✅ المتغير الجديد للتصنيف (بدلاً من Enum Context)
//   CategoryModel? _selectedCategory;

//   // ✅ متغير لتخزين تفضيل التقويم
//   bool _isHijriMode = false;
//   // ✅ حالة التحميل لمنع التكرار
//   bool _isSaving = false;

//   // ✅ 1. تعريف متغير التعارض
//   ConflictResult _prayerConflict = ConflictResult.none();

//   // ✅ 2. حقن خدمة حارس الصلاة
//   final _prayerconflictService = getIt<PrayerConflictService>();
//   // ✅ حقن خدمة تعارض المهام
//   final _taskConflictService = getIt<TimeConflictService>();

//   // --- متغيرات المشروع ---
//   ProjectModel? _selectedProject;
//   List<ProjectModel> _availableProjects = [];
//   final ProjectModel _noProjectSentinel = ProjectModel()
//     ..id = -1
//     ..title = "None";

//   @override
//   void initState() {
//     super.initState();
//     _loadProjects();
//     _loadSettings();

//     if (widget.taskToEdit != null) {
//       final t = widget.taskToEdit!;
//       _titleController.text = t.title;
//       _selectedDate = t.dueDate ?? DateTime.now();
//       _isUrgent = t.isUrgent;
//       _isImportant = t.isImportant;
//       _selectedCategory = t.category.value; // ✅ تحميل التصنيف المحفوظ
//       // ✅ إذا كانت المهمة القديمة لها مدة نستخدمها، وإلا 30
//       _selectedDuration = t.durationMinutes;
//       _selectedProject = t.project.value;
//     } else {
//       _selectedProject = widget.project;
//     }

//     // ✅ فحص التعارض المبدئي عند الفتح
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _checkPrayerConflict();
//     });
//   }

//   // ✅ 3. دالة التحقق من التعارض
//   void _checkPrayerConflict() {
//     // الحصول على البيانات الحالية
//     final prayerState = context.read<PrayerCubit>().state;
//     final settingsState = context.read<SettingsCubit>().state;

//     List<dynamic> prayers = [];
//     if (prayerState is PrayerLoaded) {
//       prayers = prayerState.allPrayers;
//     }

//     // ✅ التصحيح: استخراج الإعدادات بشكل آمن
//     UserSettings currentSettings = UserSettings(); // قيمة افتراضية
//     if (settingsState is SettingsLoaded) {
//       currentSettings = settingsState.settings;
//     }

//     // استدعاء الخدمة
//     final result = _prayerconflictService.checkConflict(
//       taskDateTime: _selectedDate,
//       prayers: prayers.cast(),
//       settings: currentSettings, // ✅ نمرر المتغير المستخرج
//     );

//     if (mounted) {
//       setState(() {
//         _prayerConflict = result;
//       });
//     }
//   }

//   Future<void> _loadProjects() async {
//     final repo = getIt<ProjectRepository>();
//     final projects = await repo.getAllProjects();
//     if (mounted) setState(() => _availableProjects = projects);
//   }

//   Future<void> _loadSettings() async {
//     final settings = await getIt<SettingsRepository>().getSettings();
//     if (mounted) {
//       setState(() {
//         _isHijriMode = settings.isHijriMode;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String sheetTitle = widget.taskToEdit != null
//         ? "تعديل المهمة"
//         : (widget.project != null
//               ? "مهمة في: ${widget.project!.title}"
//               : "مهمة جديدة");

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
//         left: 20.w,
//         right: 20.w,
//         top: 20.h,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // 1. المقبض
//           Center(
//             child: Container(
//               width: 40.w,
//               height: 4.h,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           SizedBox(height: 20.h),

//           // العنوان
//           Text(
//             sheetTitle,
//             style: Theme.of(
//               context,
//             ).textTheme.displayLarge?.copyWith(fontSize: 18.sp),
//           ),
//           SizedBox(height: 16.h),

//           // 2. حقل الإدخال
//           TextField(
//             controller: _titleController,
//             autofocus: true,
//             decoration: InputDecoration(
//               hintText: "ماذا تريد أن تنجز؟",
//               filled: true,
//               fillColor: AppColors.background,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12.r),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: 16.w,
//                 vertical: 14.h,
//               ),
//             ),
//           ),
//           SizedBox(height: 16.h),

//           // 3. التاريخ والوقت
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildDateDisplay(),

//               SizedBox(width: 8.w),

//               // زر الوقت
//               Padding(
//                 padding: EdgeInsets.only(top: 0),
//                 child: _buildChip(
//                   icon: Icons.access_time,
//                   label: DateFormat('h:mm a', 'ar').format(_selectedDate),
//                   onTap: () async {
//                     final time = await showTimePicker(
//                       context: context,
//                       initialTime: TimeOfDay.fromDateTime(_selectedDate),
//                     );
//                     if (time != null) {
//                       setState(() {
//                         _selectedDate = DateTime(
//                           _selectedDate.year,
//                           _selectedDate.month,
//                           _selectedDate.day,
//                           time.hour,
//                           time.minute,
//                         );
//                       });
//                       // ✅ تحديث الفحص عند تغيير الوقت
//                       _checkPrayerConflict();
//                     }
//                   },
//                 ),
//               ),

//               SizedBox(width: 8.w),

//               // اختيار المشروع
//               _buildProjectSelector(),
//             ],
//           ),

//           // ✅ 4. عرض رسالة التعارض (الجديد)
//           if (_prayerConflict.hasConflict)
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 300),
//               margin: EdgeInsets.only(top: 12.h),
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 color: _prayerConflict.color.withValues(alpha: 0.1),
//                 border: Border.all(color: _prayerConflict.color),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.access_time_filled, color: _prayerConflict.color),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Text(
//                       _prayerConflict.message,
//                       style: TextStyle(
//                         color: _prayerConflict.color,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//           SizedBox(height: 12.h),

//           // 5. المدة المتوقعة
//           Text(
//             "المدة المتوقعة:",
//             style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//           ),
//           SizedBox(height: 8.h),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _buildDurationChip("15 د", 15),
//                 SizedBox(width: 8.w),
//                 _buildDurationChip("30 د", 30),
//                 SizedBox(width: 8.w),
//                 _buildDurationChip("45 د", 45),
//                 SizedBox(width: 8.w),
//                 _buildDurationChip("1 س", 60),
//               ],
//             ),
//           ),
//           SizedBox(height: 12.h),

//           // 6. الأولوية
//           Row(
//             children: [
//               FilterChip(
//                 label: const Text("عاجل 🔥"),
//                 selected: _isUrgent,
//                 selectedColor: AppColors.urgent.withValues(alpha: 0.2),
//                 checkmarkColor: AppColors.urgent,
//                 onSelected: (val) => setState(() => _isUrgent = val),
//                 backgroundColor: AppColors.background,
//                 side: BorderSide.none,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               FilterChip(
//                 label: const Text("مهم ⭐"),
//                 selected: _isImportant,
//                 selectedColor: AppColors.warning.withValues(alpha: 0.2),
//                 checkmarkColor: AppColors.warning,
//                 onSelected: (val) => setState(() => _isImportant = val),
//                 backgroundColor: AppColors.background,
//                 side: BorderSide.none,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12.h),

//           // 7. السياق (Context)
//           // ✅ قسم التصنيفات الجديد (الديناميكي)
//           Text(
//             "التصنيف:",
//             style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//           ),
//           SizedBox(height: 8.h),

//           BlocBuilder<CategoryCubit, CategoryState>(
//             builder: (context, state) {
//               if (state is CategoryLoaded) {
//                 // اختيار تصنيف افتراضي إذا لم يتم الاختيار
//                 if (_selectedCategory == null && state.categories.isNotEmpty) {
//                   // محاولة اختيار "عام" أو "شخصي" أو الأول
//                   _selectedCategory = state.categories.firstWhere(
//                     (c) => c.name.contains("شخصي") || c.name.contains("عام"),
//                     orElse: () => state.categories.first,
//                   );
//                 }

//                 return SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       // عرض قائمة التصنيفات
//                       ...state.categories.map((cat) {
//                         final isSelected = _selectedCategory?.id == cat.id;
//                         return Padding(
//                           padding: EdgeInsets.only(left: 8.w),
//                           child: ChoiceChip(
//                             label: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   IconData(
//                                     cat.iconCode!,
//                                     fontFamily: 'MaterialIcons',
//                                   ),
//                                   size: 16.sp,
//                                   color: isSelected
//                                       ? Colors.white
//                                       : Color(cat.colorValue),
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Text(cat.name),
//                               ],
//                             ),
//                             selected: isSelected,
//                             onSelected: (selected) {
//                               if (selected) {
//                                 setState(() => _selectedCategory = cat);
//                               }
//                             },
//                             selectedColor: Color(cat.colorValue),
//                             backgroundColor: AppColors.background,
//                             labelStyle: TextStyle(
//                               color: isSelected ? Colors.white : Colors.black87,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 12.sp,
//                             ),
//                             side: BorderSide.none,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20.r),
//                             ),
//                           ),
//                         );
//                       }),

//                       // زر إضافة تصنيف جديد
//                       ActionChip(
//                         label: const Icon(Icons.add, size: 18),
//                         onPressed: () => _showAddCategoryDialog(context),
//                         backgroundColor: Colors.grey.shade200,
//                         side: BorderSide.none,
//                         shape: const CircleBorder(),
//                       ),
//                     ],
//                   ),
//                 );
//               }
//               return const SizedBox(
//                 height: 30,
//                 child: Center(child: CircularProgressIndicator()),
//               );
//             },
//           ),
//           SizedBox(height: 20.h),

//           // 8. زر الحفظ
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _isSaving ? null : _saveTask, // تعطيل الزر أثناء الحفظ
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 padding: EdgeInsets.symmetric(vertical: 14.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//               ),
//               child: _isSaving
//                   ? SizedBox(
//                       width: 24.w,
//                       height: 24.w,
//                       child: const CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : Text(
//                       widget.taskToEdit != null
//                           ? "حفظ التعديلات"
//                           : "إضافة المهمة",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- Widget: زر اختيار المشروع ---
//   Widget _buildProjectSelector() {
//     // ✅ تحسين: دمج المشروع المحدد حالياً مع القائمة لضمان ظهوره
//     List<ProjectModel> displayList = List.from(_availableProjects);

//     // إذا كان لدينا مشروع محدد (من صفحة المشروع) وهو غير موجود في القائمة المحملة، نضيفه
//     if (_selectedProject != null &&
//         _selectedProject!.id != -1 &&
//         !displayList.any((p) => p.id == _selectedProject!.id)) {
//       displayList.insert(0, _selectedProject!);
//     }
//     return PopupMenuButton<ProjectModel?>(
//       tooltip: "اختر مشروعاً",
//       initialValue: _selectedProject ?? _noProjectSentinel,
//       onSelected: (project) {
//         setState(() {
//           if (project?.id == -1) {
//             _selectedProject = null;
//           } else {
//             _selectedProject = project;
//           }
//         });
//         if (kDebugMode) {
//           print("Selected Project: ${project?.title ?? 'None'}");
//         }
//       },
//       itemBuilder: (context) {
//         List<PopupMenuEntry<ProjectModel?>> items = [];
//         items.add(
//           PopupMenuItem<ProjectModel?>(
//             value: _noProjectSentinel,
//             child: const Row(
//               children: [
//                 Icon(
//                   Icons.not_interested_rounded,
//                   color: Colors.grey,
//                   size: 18,
//                 ),
//                 SizedBox(width: 8),
//                 Text("بدون مشروع"),
//               ],
//             ),
//           ),
//         );
//         items.add(const PopupMenuDivider());
//         // ✅ استخدام القائمة المحسنة displayList
//         items.addAll(
//           displayList.map((proj) {
//             final color = Color(proj.colorValue ?? 0xFF4CAF50);
//             return PopupMenuItem<ProjectModel?>(
//               value: proj,
//               child: Row(
//                 children: [
//                   Icon(Icons.folder_rounded, color: color, size: 18),
//                   SizedBox(width: 8),
//                   // تمييز المشروع المحدد بنص عريض
//                   Text(
//                     proj.title,
//                     style: TextStyle(
//                       fontWeight: _selectedProject?.id == proj.id
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }),
//         );
//         return items;
//       },
//       //   items.addAll(
//       //     _availableProjects.map((proj) {
//       //       final color = Color(proj.colorValue ?? 0xFF4CAF50);
//       //       return PopupMenuItem<ProjectModel?>(
//       //         value: proj,
//       //         child: Row(
//       //           children: [
//       //             Icon(Icons.folder_rounded, color: color, size: 18),
//       //             SizedBox(width: 8),
//       //             Text(proj.title),
//       //           ],
//       //         ),
//       //       );
//       //     }),
//       //   );
//       //   return items;
//       // },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         decoration: BoxDecoration(
//           color: _selectedProject != null
//               ? Color(
//                   _selectedProject!.colorValue ?? 0xFF4CAF50,
//                 ).withValues(alpha: 0.1)
//               : AppColors.background,
//           borderRadius: BorderRadius.circular(20.r),
//           border: Border.all(
//             color: _selectedProject != null
//                 ? Color(_selectedProject!.colorValue ?? 0xFF4CAF50)
//                 : Colors.grey.shade300,
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               _selectedProject != null
//                   ? Icons.folder_rounded
//                   : Icons.folder_open_rounded,
//               size: 16.sp,
//               color: _selectedProject != null
//                   ? Color(_selectedProject!.colorValue ?? 0xFF4CAF50)
//                   : Colors.grey,
//             ),
//             SizedBox(width: 4.w),
//             Text(
//               _selectedProject?.title ?? "مشروع",
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.bold,
//                 color: _selectedProject != null
//                     ? Color(_selectedProject!.colorValue ?? 0xFF4CAF50)
//                     : Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- Widgets مساعدة ---
//   Widget _buildChip({
//     required IconData icon,
//     required String label,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8.r),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         decoration: BoxDecoration(
//           color: AppColors.background,
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 16.sp, color: Colors.grey),
//             SizedBox(width: 6.w),
//             Text(label, style: TextStyle(fontSize: 12.sp)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDurationChip(String label, int minutes) {
//     final isSelected = _selectedDuration == minutes;
//     return ChoiceChip(
//       label: Text(label),
//       selected: isSelected,
//       onSelected: (selected) =>
//           setState(() => _selectedDuration = selected ? minutes : null),
//       selectedColor: AppColors.primary.withValues(alpha: 0.1),
//       backgroundColor: AppColors.background,
//       side: BorderSide.none,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//     );
//   }

//   // دالة إضافة تصنيف جديد
//   void _showAddCategoryDialog(BuildContext context) {
//     final nameController = TextEditingController();
//     int selectedColor = 0xFF9C27B0; // لون افتراضي

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("تصنيف جديد"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 hintText: "اسم التصنيف (مثلاً: رياضة)",
//               ),
//             ),
//             SizedBox(height: 16.h),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children:
//                     [
//                       0xFFE91E63,
//                       0xFF9C27B0,
//                       0xFF2196F3,
//                       0xFF009688,
//                       0xFFFF9800,
//                     ].map((c) {
//                       return GestureDetector(
//                         onTap: () => selectedColor =
//                             c, // (ملاحظة: لتحديث الـ UI يحتاج stateful dialog)
//                         child: Container(
//                           margin: EdgeInsets.all(4.w),
//                           width: 24.w,
//                           height: 24.w,
//                           decoration: BoxDecoration(
//                             color: Color(c),
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("إلغاء"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (nameController.text.isNotEmpty) {
//                 // ✅ إضافة التصنيف عبر الكيوبت
//                 context.read<CategoryCubit>().addCategory(
//                   nameController.text,
//                   selectedColor,
//                   Icons.label_outline.codePoint,
//                 );
//                 Navigator.pop(ctx);
//               }
//             },
//             child: const Text("إضافة"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateDisplay() {
//     final hijriDate = HijriCalendar.fromDate(_selectedDate);
//     final hijriString =
//         "${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear}";
//     final gregorianString = DateFormat(
//       'd MMM yyyy',
//       'ar',
//     ).format(_selectedDate);

//     final mainDate = _isHijriMode ? hijriString : gregorianString;
//     final subDate = _isHijriMode
//         ? "الموافق: $gregorianString"
//         : "الموافق: $hijriString";

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildChip(
//           icon: Icons.calendar_today,
//           label: mainDate,
//           onTap: () async {
//             final date = await showDatePicker(
//               context: context,
//               initialDate: _selectedDate,
//               firstDate: DateTime.now(),
//               lastDate: DateTime(2030),
//               locale: const Locale('ar', 'SA'),
//             );
//             if (date != null) {
//               setState(() => _selectedDate = date);
//               // ✅ تحديث الفحص عند تغيير التاريخ
//               _checkPrayerConflict();
//             }
//           },
//         ),
//         Padding(
//           padding: EdgeInsets.only(right: 8.w, top: 4.h),
//           child: Text(
//             subDate,
//             style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//           ),
//         ),
//       ],
//     );
//   }

//   // 1. تحديث دالة الحفظ الرئيسية
//   void _saveTask() async {
//     if (_titleController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("يرجى كتابة عنوان المهمة"),
//           duration: Duration(seconds: 2), // ✅ اختفاء سريع (ثانيتين)
//           behavior: SnackBarBehavior.floating, // يجعلها تطفو وشكلها أجمل)
//         ),
//       );
//       return;
//     }

//     // التعارض الصارم (أحمر) - يمنع الحفظ
//     if (_prayerConflict.hasConflict && _prayerConflict.isStrict) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           backgroundColor: Colors.red,
//           content: Text(_prayerConflict.message),
//         ),
//       );
//       return;
//     }

//     setState(() => _isSaving = true);

//     try {
//       // فحص تعارض المهام
//       final taskConflict = await _taskConflictService.checkTaskConflict(
//         newTaskDate: _selectedDate,
//         durationMinutes: _selectedDuration ?? 30,
//         excludeTaskId: widget.taskToEdit?.id,
//       );

//       // ⚠️ أولوية التحذيرات:
//       // 1. إذا كان هناك تعارض مهام -> نظهر خيارات المهام
//       // 2. إذا لم يوجد تعارض مهام ولكن يوجد تحذير صلاة (أصفر) -> نظهر خيارات الصلاة

//       ConflictResult? activeConflict;
//       if (taskConflict.hasConflict) {
//         activeConflict = taskConflict;
//       } else if (_prayerConflict.hasConflict && !_prayerConflict.isStrict) {
//         activeConflict = _prayerConflict;
//       }

//       if (activeConflict != null) {
//         setState(() => _isSaving = false); // إيقاف التحميل لعرض الرسالة
//         if (!mounted) return;

//         // ✅ استدعاء النافذة المحسنة
//         await _showConflictDialog(activeConflict);
//         return; // الخروج لأن الديالوج سيتعامل مع الحفظ أو الإلغاء
//       }

//       // إذا لم يوجد أي تعارض
//       _performSave();
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isSaving = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("حدث خطأ: $e"),
//             duration: const Duration(seconds: 3), // ✅ 3 ثواني
//             behavior: SnackBarBehavior.floating,
//           ),
//         );
//       }
//     }
//   }

//   // 2. ✅ دالة عرض خيارات التعارض المحسنة
//   Future<void> _showConflictDialog(ConflictResult conflict) async {
//     final newTimeFormatted = conflict.suggestedTime != null
//         ? DateFormat('h:mm a', 'ar').format(conflict.suggestedTime!)
//         : "";

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20.r),
//         ),
//         elevation: 10,
//         backgroundColor: Colors.white,
//         child: Padding(
//           padding: EdgeInsets.all(20.w),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // الأيقونة والعنوان
//               Container(
//                 padding: EdgeInsets.all(12.w),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF7ED), // برتقالي فاتح جداً
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.warning_amber_rounded,
//                   color: Colors.orange,
//                   size: 32,
//                 ),
//               ),
//               SizedBox(height: 16.h),

//               Text(
//                 "انتبه، يوجد تداخل زمني",
//                 style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8.h),

//               Text(
//                 conflict.message,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
//               ),
//               SizedBox(height: 24.h),

//               // --- الخيارات الثلاثة ---

//               // الخيار 1: التأجيل (الأذكى)
//               if (conflict.suggestedTime != null)
//                 _buildDialogButton(
//                   icon: Icons.access_time_filled_rounded,
//                   color: AppColors.primary,
//                   textColor: Colors.white,
//                   title: "تأجيل لما بعد الانتهاء",
//                   subtitle: "نقل الموعد إلى $newTimeFormatted",
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     setState(() {
//                       _selectedDate = conflict.suggestedTime!; // تحديث الوقت
//                       _isSaving = true; // إعادة تفعيل الحفظ
//                     });
//                     _performSave(); // حفظ مباشر
//                   },
//                 ),

//               if (conflict.suggestedTime != null) SizedBox(height: 12.h),

//               // الخيار 2: التجاهل
//               _buildDialogButton(
//                 icon: Icons.check_circle_outline_rounded,
//                 color: Colors.grey.shade100,
//                 textColor: Colors.black87,
//                 title: "حفظ على أي حال",
//                 subtitle: "إبقاء الوقت كما هو",
//                 onTap: () {
//                   Navigator.pop(ctx);
//                   setState(() => _isSaving = true);
//                   _performSave();
//                 },
//               ),

//               SizedBox(height: 12.h),

//               // الخيار 3: الإلغاء/التعديل اليدوي
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(ctx);
//                   setState(() => _isSaving = false); // العودة للتعديل
//                 },
//                 child: Text(
//                   "إلغاء وتعديل الوقت يدوياً",
//                   style: TextStyle(color: Colors.grey, fontSize: 13.sp),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ويدجت مساعدة لأزرار الديالوج
//   Widget _buildDialogButton({
//     required IconData icon,
//     required Color color,
//     required Color textColor,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12.r),
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(12.r),
//           border: color == Colors.grey.shade100
//               ? Border.all(color: Colors.grey.shade300)
//               : null,
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: textColor, size: 22.sp),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       color: textColor,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13.sp,
//                     ),
//                   ),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       color: textColor.withValues(alpha: 0.8),
//                       fontSize: 11.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: textColor.withValues(alpha: 0.5),
//               size: 14.sp,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _performSave() {
//     final cubit = context.read<TaskCubit>();

//     if (widget.taskToEdit != null) {
//       final task = widget.taskToEdit!;
//       task
//         ..title = _titleController.text
//         ..dueDate = _selectedDate
//         ..isUrgent = _isUrgent
//         ..isImportant = _isImportant
//         ..category.value = _selectedCategory
//         ..durationMinutes = _selectedDuration ?? 30; // القيمة الافتراضية

//       if (_selectedProject != null) {
//         task.project.value = _selectedProject;
//       } else {
//         task.project.value = null;
//       }

//       cubit.addTaskModel(task);
//     } else {
//       cubit.addTask(
//         title: _titleController.text,
//         date: _selectedDate,
//         isUrgent: _isUrgent,
//         isImportant: _isImportant,
//         category: _selectedCategory, // ✅ تمرير التصنيف المختار
//         duration: _selectedDuration ?? 30, // القيمة الافتراضية
//         project: _selectedProject,
//       );
//     }

//     // إغلاق النافذة
//     if (mounted) {
//       Navigator.pop(context);
//     }
//   }
// }
