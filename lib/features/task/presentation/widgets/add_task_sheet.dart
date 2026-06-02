// lib/features/task/presentation/widgets/add_task_sheet.dart
// ✅ محدث مع دعم الأوقات الشرعية (TimeSlotPicker)

import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart';
import 'package:athar/core/design_system/widgets/time_slot_picker.dart';
import 'package:athar/features/task/data/models/recurrence_pattern.dart';
import 'package:athar/features/task/presentation/widgets/recurrence_picker.dart';
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
  RecurrencePattern? _selectedRecurrence;

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

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
                fontFamily: 'Calibri',
                fontFamilyFallback: AtharTypography.fontFallback,
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

            // --- التكرار (للمهام الجديدة فقط) ---
            if (widget.taskToEdit == null) ...[
              RecurrencePicker(
                initialPattern: _selectedRecurrence,
                onChanged: (pattern) =>
                    setState(() => _selectedRecurrence = pattern),
              ),
              AtharGap.md,
            ],

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
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: colorScheme.primary, size: 20.sp),
            AtharGap.hMd,
            Expanded(
              child: Text(
                dateStr,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, fontFamily: 'Calibri', fontFamilyFallback: AtharTypography.fontFallback),
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
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.5)),
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
                  style: TextStyle(fontSize: 11.sp, color: colorScheme.outline, fontFamily: 'Calibri', fontFamilyFallback: AtharTypography.fontFallback),
                ),
                Text(
                  _getTimeDisplayString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontFamily: 'Calibri',
                    fontFamilyFallback: AtharTypography.fontFallback,
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
            color: colorScheme.outline.withValues(alpha: 0.3),
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
              style: TextStyle(fontSize: 14.sp, color: colorScheme.outline, fontFamily: 'Calibri', fontFamilyFallback: AtharTypography.fontFallback),
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
      case TimeSpecificationType.relativeToPrayer:
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
      case TimeSpecificationType.relativeToPrayer:
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

      case TimeSpecificationType.relativeToPrayer:
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
                  borderRadius: AtharRadii.radiusXxxs,
                ),
              ),
            ),
            AtharGap.lg,
            Text(
              'اختر وقت المهمة',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: 'Calibri', fontFamilyFallback: AtharTypography.fontFallback),
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
          fontFamily: 'Calibri',
          fontFamilyFallback: AtharTypography.fontFallback,
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
                fontFamily: 'Calibri',
                fontFamilyFallback: AtharTypography.fontFallback,
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
        recurrence: _selectedRecurrence,
      );
    }

    if (mounted) Navigator.pop(context);
  }
}
