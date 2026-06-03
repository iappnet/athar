// lib/features/task/presentation/widgets/add_task_sheet.dart
// ✅ PR-SHEET-STANDARD: accordion sections + AtharBottomSheet container

import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart';
import 'package:athar/core/design_system/molecules/sections/athar_accordion_section.dart';
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
  final _titleController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
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

  // Accordion keys for Guard #1 (auto-expand on validation error)
  final _whatKey = GlobalKey<AtharAccordionSectionState>();
  final _whenKey = GlobalKey<AtharAccordionSectionState>();
  final _detailsKey = GlobalKey<AtharAccordionSectionState>();

  @override
  void initState() {
    super.initState();
    _loadData();
    _initForm();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPrayerConflict());
  }

  void _loadData() async {
    if (mounted) context.read<CategoryCubit>().loadCategories();
    final settings = await getIt<SettingsRepository>().getSettings();
    if (mounted) setState(() => _isHijriMode = settings.isHijriMode);
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
      _timeSettings = t.timeSlotSettings;
      if (t.reminderTime != null) {
        _reminderTime = t.reminderTime;
        _isReminderEnabled = true;
      }
    }
  }

  // ─── Summary strings ─────────────────────────────────────────────────────

  String get _whatSummary => _titleController.text.trim();

  String get _whenSummary {
    final l10n = AppLocalizations.of(context);
    final dateStr = _isHijriMode
        ? HijriCalendar.fromDate(_selectedDate).toFormat('dd MMMM yyyy')
        : DateFormat('EEE، d MMM', 'ar').format(_selectedDate);
    if (_timeSettings == null) return dateStr;
    return '$dateStr · ${_getTimeDisplayString(l10n)}';
  }

  String get _detailsSummary {
    final parts = <String>[
      if (_selectedCategory != null) _selectedCategory!.name,
      if (_isUrgent) 'عاجل',
      if (_isImportant) 'مهم',
    ];
    return parts.isEmpty ? '' : parts.join(' · ');
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return AtharBottomSheet(
      title: widget.taskToEdit != null ? l10n.editTask : l10n.newTask,
      showDragHandle: true,
      actions: [
        AtharButton(
          label: widget.taskToEdit != null ? l10n.saveChanges : l10n.addTask,
          onPressed: _isSaving ? null : _saveTask,
          isLoading: _isSaving,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── WHAT (first-open, required) ──────────────────────────────────
          AtharAccordionSection(
            key: _whatKey,
            icon: Icons.task_alt_outlined,
            title: l10n.whatToAccomplish,
            summaryValue: _whatSummary,
            isRequired: true,
            initiallyExpanded: true,
            child: _buildWhatBody(colorScheme, l10n),
          ),
          // ── WHEN ────────────────────────────────────────────────────────
          AtharAccordionSection(
            key: _whenKey,
            icon: Icons.schedule_outlined,
            title: l10n.whenSection,
            summaryValue: _whenSummary,
            initiallyExpanded: false,
            child: _buildWhenBody(colorScheme, l10n),
          ),
          // ── DETAILS ─────────────────────────────────────────────────────
          AtharAccordionSection(
            key: _detailsKey,
            icon: Icons.tune_outlined,
            title: l10n.detailsSection,
            summaryValue: _detailsSummary,
            initiallyExpanded: false,
            child: _buildDetailsBody(colorScheme, l10n),
          ),
          AtharGap.sm,
        ],
      ),
    );
  }

  // ─── Section bodies ───────────────────────────────────────────────────────

  Widget _buildWhatBody(ColorScheme colorScheme, AppLocalizations l10n) {
    return TextField(
      controller: _titleController,
      autofocus: true,
      onChanged: (_) => setState(() {}), // live red-dot update
      decoration: InputDecoration(
        hintText: l10n.taskTitleHint,
        filled: true,
        fillColor: colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: AtharRadii.radiusMd,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 14),
      ),
    );
  }

  Widget _buildWhenBody(ColorScheme colorScheme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateSelector(colorScheme, l10n),
        AtharGap.md,
        Text(
          l10n.taskTimeLabel,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurfaceVariant,
            fontFamily: AtharTypography.fontFamily,
            fontFamilyFallback: AtharTypography.fontFallback,
          ),
        ),
        AtharGap.sm,
        if (_timeSettings != null)
          _buildTimeDisplay(colorScheme, l10n)
        else
          _buildTimePickerButton(colorScheme, l10n),
        if (_prayerConflict.hasConflict) ...[
          AtharGap.md,
          _buildConflictWarning(),
        ],
        AtharGap.md,
        DurationPicker(
          selectedDuration: _selectedDuration,
          onDurationSelected: (val) {
            setState(() => _selectedDuration = val);
            _checkPrayerConflict();
          },
        ),
        AtharGap.md,
        ReminderPickerWidget(
          reminderTime: _reminderTime,
          isEnabled: _isReminderEnabled,
          onToggle: (val) {
            setState(() {
              _isReminderEnabled = val;
              if (val && _reminderTime == null) {
                _reminderTime =
                    _selectedDate.subtract(const Duration(minutes: 10));
              }
            });
          },
          onTimeChanged: (t) => setState(() => _reminderTime = t),
        ),
        if (widget.taskToEdit == null) ...[
          AtharGap.md,
          RecurrencePicker(
            initialPattern: _selectedRecurrence,
            onChanged: (p) => setState(() => _selectedRecurrence = p),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsBody(ColorScheme colorScheme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.targetSpaceId != null ||
            widget.taskToEdit?.spaceId != null) ...[
          _buildAssigneeSelector(colorScheme, l10n),
          const Divider(),
          AtharGap.sm,
        ],
        PrioritySelector(
          isUrgent: _isUrgent,
          isImportant: _isImportant,
          onUrgentChanged: (v) => setState(() => _isUrgent = v),
          onImportantChanged: (v) => setState(() => _isImportant = v),
        ),
        AtharGap.md,
        CategorySelector(
          selectedCategory: _selectedCategory,
          onSelected: (c) => setState(() => _selectedCategory = c),
          onAddPressed: _showAddCategoryDialog,
        ),
      ],
    );
  }

  // ─── Date / time widgets ─────────────────────────────────────────────────

  Widget _buildDateSelector(ColorScheme colorScheme, AppLocalizations l10n) {
    final gregorianStr =
        DateFormat('EEEE، d MMMM yyyy', 'ar').format(_selectedDate);
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
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: AtharTypography.fontFamily,
                  fontFamilyFallback: AtharTypography.fontFallback,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(ColorScheme colorScheme, AppLocalizations l10n) {
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
                  _getTimeTypeLabel(l10n),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colorScheme.outline,
                    fontFamily: AtharTypography.fontFamily,
                    fontFamilyFallback: AtharTypography.fontFallback,
                  ),
                ),
                Text(
                  _getTimeDisplayString(l10n),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontFamily: AtharTypography.fontFamily,
                    fontFamilyFallback: AtharTypography.fontFallback,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.primary, size: 20.sp),
            onPressed: _showTimeSlotPicker,
          ),
          IconButton(
            icon: Icon(Icons.close, color: colorScheme.error, size: 20.sp),
            onPressed: () => setState(() => _timeSettings = null),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerButton(ColorScheme colorScheme, AppLocalizations l10n) {
    return GestureDetector(
      onTap: _showTimeSlotPicker,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: AtharRadii.radiusMd,
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, color: colorScheme.outline, size: 22.sp),
            AtharGap.hMd,
            Text(
              l10n.taskTimeChoose,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.outline,
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
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

  String _getTimeTypeLabel(AppLocalizations l10n) {
    if (_timeSettings == null) return '';
    switch (_timeSettings!.type) {
      case TimeSpecificationType.fixed:
        return l10n.taskTimeTypeFixed;
      case TimeSpecificationType.relativeToPrayer:
        return l10n.taskTimeTypeRelativePrayer;
      case TimeSpecificationType.period:
        return l10n.taskTimeTypePeriod;
    }
  }

  String _getTimeDisplayString(AppLocalizations l10n) {
    if (_timeSettings == null) return l10n.taskTimeUnspecified;

    switch (_timeSettings!.type) {
      case TimeSpecificationType.fixed:
        if (_timeSettings!.fixedTime == null) return l10n.taskTimeUnspecified;
        final t = _timeSettings!.fixedTime!;
        final period = t.hour >= 12 ? 'م' : 'ص';
        final h12 = t.hour > 12
            ? t.hour - 12
            : (t.hour == 0 ? 12 : t.hour);
        return '$h12:${t.minute.toString().padLeft(2, '0')} $period';

      case TimeSpecificationType.relativeToPrayer:
        final pName = _getPrayerName(l10n, _timeSettings!.referencePrayer);
        if (_timeSettings!.offsetMinutes == 0) return pName;
        final mins = _timeSettings!.offsetMinutes;
        return _timeSettings!.prayerRelation == PrayerRelativeTime.before
            ? l10n.taskTimePrayerBefore(pName, mins)
            : l10n.taskTimePrayerAfter(pName, mins);

      case TimeSpecificationType.period:
        final pName = _getPeriodName(l10n, _timeSettings!.period);
        switch (_timeSettings!.periodPosition) {
          case PeriodPosition.start:
            return l10n.taskTimePeriodStart(pName);
          case PeriodPosition.middle:
            return l10n.taskTimePeriodMiddle(pName);
          case PeriodPosition.end:
            return l10n.taskTimePeriodEnd(pName);
          default:
            return pName;
        }
    }
  }

  String _getPrayerName(AppLocalizations l10n, ReferencePrayer? prayer) {
    switch (prayer) {
      case ReferencePrayer.fajr:
        return l10n.fajr;
      case ReferencePrayer.sunrise:
        return l10n.sunrise;
      case ReferencePrayer.dhuhr:
        return l10n.dhuhr;
      case ReferencePrayer.asr:
        return l10n.asr;
      case ReferencePrayer.maghrib:
        return l10n.maghrib;
      case ReferencePrayer.isha:
        return l10n.isha;
      default:
        return l10n.taskTimeUnspecified;
    }
  }

  String _getPeriodName(AppLocalizations l10n, AtharTimePeriod? period) {
    switch (period) {
      case AtharTimePeriod.dawn:
        return l10n.fajr;
      case AtharTimePeriod.bakur:
        return l10n.taskTimePeriodBakur;
      case AtharTimePeriod.morning:
        return l10n.taskTimePeriodMorning;
      case AtharTimePeriod.noon:
        return l10n.taskTimePeriodNoon;
      case AtharTimePeriod.afternoon:
        return l10n.asr;
      case AtharTimePeriod.maghrib:
        return l10n.maghrib;
      case AtharTimePeriod.isha:
        return l10n.isha;
      case AtharTimePeriod.night:
        return l10n.taskTimePeriodNight;
      case AtharTimePeriod.lastThird:
        return l10n.taskTimePeriodLastThird;
      default:
        return l10n.taskTimeUnspecified;
    }
  }

  void _showTimeSlotPicker() {
    AtharBottomSheet.show(
      context: context,
      title: AppLocalizations.of(context).taskTimeChoose,
      isScrollable: true,
      child: TimeSlotPicker(
        initialSettings: _timeSettings,
        showPeriodPosition: true,
        onChanged: (settings) {
          setState(() => _timeSettings = settings);
          Navigator.pop(context);
          _checkPrayerConflict();
        },
      ),
    );
  }

  // ─── Assignee / conflict ─────────────────────────────────────────────────

  Widget _buildAssigneeSelector(
      ColorScheme colorScheme, AppLocalizations l10n) {
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
          fontFamily: AtharTypography.fontFamily,
          fontFamilyFallback: AtharTypography.fontFallback,
        ),
      ),
      trailing: _selectedAssigneeId != null
          ? IconButton(
              icon: Icon(Icons.clear, color: colorScheme.error),
              onPressed: () => setState(() => _selectedAssigneeId = null),
            )
          : Icon(Icons.arrow_forward_ios,
              size: 16, color: colorScheme.outline),
      onTap: () async {
        final spaceId =
            widget.targetSpaceId ?? widget.taskToEdit?.spaceId;
        if (spaceId != null) {
          final result = await showModalBottomSheet(
            context: context,
            builder: (_) => MemberSelectorSheet(
              spaceId: spaceId,
              currentAssigneeId: _selectedAssigneeId,
            ),
          );
          if (result != null) {
            setState(() =>
                _selectedAssigneeId = result == 'unassign' ? null : result);
          }
        }
      },
    );
  }

  Widget _buildConflictWarning() {
    return AnimatedContainer(
      duration: AtharAnimations.normalSlow,
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
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Prayer conflict ─────────────────────────────────────────────────────

  void _checkPrayerConflict() {
    if (_timeSettings?.type != TimeSpecificationType.fixed) {
      if (mounted) setState(() => _prayerConflict = ConflictResult.none());
      return;
    }

    final prayerState = context.read<PrayerCubit>().state;
    final settingsState = context.read<SettingsCubit>().state;

    List<PrayerTime> prayers = [];
    if (prayerState is PrayerLoaded) prayers = prayerState.allPrayers;
    UserSettings currentSettings = UserSettings();
    if (settingsState is SettingsLoaded) currentSettings = settingsState.settings;

    final taskTime = _getActualTaskTime();
    if (taskTime == null) return;

    final result = _prayerConflictService.checkConflict(
      taskStartTime: taskTime,
      taskDuration: Duration(minutes: _selectedDuration),
      prayers: prayers,
      settings: currentSettings,
    );
    if (mounted) setState(() => _prayerConflict = result);
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
    return null;
  }

  // ─── Date picker ─────────────────────────────────────────────────────────

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
          date.year, date.month, date.day,
          _selectedDate.hour, _selectedDate.minute,
        );
      });
      _checkPrayerConflict();
    }
  }

  // ─── Add-category dialog ─────────────────────────────────────────────────

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final l10n = AppLocalizations.of(context);
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
                colorValue: 0xFF9C27B0,
                iconKey: 'bookmark',
              );
          Navigator.pop(context);
        }
      },
    );
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  void _saveTask() async {
    // Guard #1: expand What section if title is empty
    if (_titleController.text.trim().isEmpty) {
      _whatKey.currentState?.expand();
      return;
    }

    setState(() => _isSaving = true);
    final taskCubit = context.read<TaskCubit>();

    try {
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
      if (_timeSettings != null) {
        updatedTask.applyTimeSettings(_timeSettings!);
      }
      if (_selectedCategory != null) {
        updatedTask.category.value = _selectedCategory;
      }
      cubit.updateTask(updatedTask);
    } else {
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
