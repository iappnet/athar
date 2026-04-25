//————-————— code start ————————-
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Core & DI
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/widgets/athar_dialog.dart';
import 'package:athar/core/design_system/widgets/athar_feedback.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart';
import 'package:athar/core/services/prayer_conflict_service.dart';

// Models
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/features/health/data/models/medicine_model.dart';
import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/features/settings/data/models/category_model.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
import 'package:athar/features/task/domain/models/conflict_result.dart';

// Cubits
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:athar/features/prayer/presentation/cubit/prayer_cubit.dart';
import 'package:athar/features/prayer/presentation/cubit/prayer_state.dart';

// Components
import 'package:athar/features/task/data/models/recurrence_pattern.dart';
import 'package:athar/features/task/presentation/widgets/components/category_selector.dart';
import 'package:athar/features/task/presentation/widgets/components/priority_selector.dart';
import 'package:athar/features/task/presentation/widgets/components/date_time_picker.dart';
import 'package:athar/features/task/presentation/widgets/components/duration_picker.dart';
import 'package:athar/features/task/presentation/widgets/dialogs/conflict_dialog.dart';
import 'package:athar/features/task/presentation/widgets/recurrence_picker.dart';
import 'package:athar/features/space/presentation/widgets/member_selector_sheet.dart';
import 'package:athar/features/settings/domain/repositories/settings_repository.dart';

enum EntityType { task, medicine, appointment }

/// Semantic colors (not in ColorScheme)
const _warningColor = Color(0xFFFDCB6E);
const _infoColor = Color(0xFF74B9FF);

class UnifiedAddSheet extends StatefulWidget {
  final EntityType initialType;
  final String? targetSpaceId;
  final String? targetModuleId;
  final dynamic itemToEdit;

  const UnifiedAddSheet({
    super.key,
    this.initialType = EntityType.task,
    this.targetSpaceId,
    this.targetModuleId,
    this.itemToEdit,
  });

  @override
  State<UnifiedAddSheet> createState() => _UnifiedAddSheetState();
}

class _UnifiedAddSheetState extends State<UnifiedAddSheet> {
  final _formKey = GlobalKey<FormState>();
  late EntityType _selectedType;

  // Controllers
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _doseAmountController = TextEditingController();
  final _doseUnitController = TextEditingController();
  final _quantityController = TextEditingController();
  final _durationController = TextEditingController();
  final _thresholdController = TextEditingController(text: '5');
  final _doctorController = TextEditingController();
  final _locationController = TextEditingController();

  // Common State
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime? _reminderTime;
  bool _isReminderEnabled =
      false; // ✅ FIX #1: افتراضياً false، سيتم تغييره في initState
  bool _isSaving = false;
  bool _isHijriMode = false;

  // Task Specific
  bool _isUrgent = false;
  bool _isImportant = false;
  int _selectedDuration = 30;
  CategoryModel? _selectedCategory;
  String? _selectedAssigneeId;
  RecurrencePattern? _selectedRecurrence;
  ConflictResult _prayerConflict = ConflictResult.none();

  // Medicine Specific
  String _medType = 'pill';
  String _instructions = 'after_meal';
  String _schedulingType = 'fixed';
  String _durationMode = 'days';
  String _refillMode = 'off';
  String _refillAction = 'list';
  final List<TimeOfDay> _fixedTimes = [];
  int _intervalHours = 8;
  DateTime? _selectedEndDate;

  // Appointment Specific
  String _apptType = 'checkup';

  final _prayerConflictService = getIt<PrayerConflictService>();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;

    // ✅ FIX #1: تفعيل التذكير افتراضياً للمواعيد فقط
    if (_selectedType == EntityType.appointment) {
      _isReminderEnabled = true;
    }

    _loadInitialData();
    _initFormIfEditing();
  }

  void _loadInitialData() async {
    context.read<CategoryCubit>().loadCategories();
    final settings = await getIt<SettingsRepository>().getSettings();
    if (mounted) {
      setState(() => _isHijriMode = settings.isHijriMode);
      _checkPrayerConflict();
    }
  }

  void _initFormIfEditing() {
    if (widget.itemToEdit == null) return;
    final item = widget.itemToEdit;

    if (item is TaskModel) {
      _selectedType = EntityType.task;
      _titleController.text = item.title;
      _selectedDate = item.date;
      _isUrgent = item.isUrgent;
      _isImportant = item.isImportant;
      _selectedCategory = item.category.value;
      _selectedDuration = item.durationMinutes;
      _selectedAssigneeId = item.assigneeId;
      if (item.reminderTime != null) {
        _reminderTime = item.reminderTime;
        _isReminderEnabled = true;
      }
    } else if (item is MedicineModel) {
      _selectedType = EntityType.medicine;
      _titleController.text = item.name;
      _quantityController.text = item.stockQuantity?.toString() ?? '';
      _doseAmountController.text = item.doseAmount?.toString() ?? '';
      _doseUnitController.text = item.doseUnit ?? '';
      _medType = item.type ?? 'pill';
      _instructions = item.instructions ?? 'after_meal';
      _refillMode = item.autoRefillMode;
      _refillAction = item.refillAction;
      _thresholdController.text = item.refillThreshold.toString();
      _schedulingType = item.schedulingType;
      if (item.courseDurationDays != null) {
        _durationController.text = item.courseDurationDays.toString();
        _durationMode = 'days';
      }
      if (item.intervalHours != null) _intervalHours = item.intervalHours!;

      // ✅ استرجاع Fixed Time Slots
      if (item.fixedTimeSlots != null && item.fixedTimeSlots!.isNotEmpty) {
        _fixedTimes.clear();
        for (var timeStr in item.fixedTimeSlots!) {
          final parts = timeStr.split(':');
          if (parts.length == 2) {
            _fixedTimes.add(
              TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
            );
          }
        }
      }
    } else if (item is AppointmentModel) {
      // ✅ FIX #6: إضافة دعم التعديل للمواعيد
      _selectedType = EntityType.appointment;
      _titleController.text = item.title;
      _selectedDate = item.appointmentDate;
      _selectedTime = TimeOfDay.fromDateTime(item.appointmentDate);
      _apptType = item.type ?? 'checkup';
      _doctorController.text = item.doctorName ?? '';
      _locationController.text = item.locationName ?? '';
      _notesController.text = item.notes ?? '';
      // ✅ FIX ERROR #1: إزالة ?? true
      _isReminderEnabled = item.reminderEnabled;

      if (item.reminderTime != null) {
        _reminderTime = item.reminderTime;
      }
    }
  }

  void _checkPrayerConflict() {
    if (_selectedType != EntityType.task) return;

    final prayerState = context.read<PrayerCubit>().state;
    final settingsState = context.read<SettingsCubit>().state;

    List<PrayerTime> prayers = [];
    if (prayerState is PrayerLoaded) prayers = prayerState.allPrayers;

    UserSettings currentSettings = UserSettings();
    if (settingsState is SettingsLoaded) {
      currentSettings = settingsState.settings;
    }

    final result = _prayerConflictService.checkConflict(
      taskStartTime: _selectedDate,
      taskDuration: Duration(minutes: _selectedDuration),
      prayers: prayers,
      settings: currentSettings,
    );
    setState(() => _prayerConflict = result);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(
        20.w,
        20.h,
        20.w,
        MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              AtharGap.lg,
              _buildTypeSelector(),
              AtharGap.xxl,
              _buildCommonHeader(),
              AtharGap.xl,
              if (_selectedType == EntityType.task) _buildTaskFields(),
              if (_selectedType == EntityType.medicine) _buildMedicineFields(),
              if (_selectedType == EntityType.appointment)
                _buildAppointmentFields(),
              AtharGap.xl,
              _buildReminderSection(),
              AtharGap.xxl,
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant,
        borderRadius: AtharRadii.radiusXxxs,
      ),
    );
  }

  Widget _buildTypeSelector() {
    final l10n = AppLocalizations.of(context);
    return SegmentedButton<EntityType>(
      segments: [
        ButtonSegment(
          value: EntityType.task,
          label: Text(l10n.task),
          icon: const Icon(Icons.assignment_outlined),
        ),
        ButtonSegment(
          value: EntityType.medicine,
          label: Text(l10n.medicine),
          icon: const Icon(Icons.medication_outlined),
        ),
        ButtonSegment(
          value: EntityType.appointment,
          label: Text(l10n.appointment),
          icon: const Icon(Icons.calendar_today_outlined),
        ),
      ],
      selected: {_selectedType},
      onSelectionChanged: (Set<EntityType> val) => setState(() {
        _selectedType = val.first;

        // ✅ FIX #1: تحديث حالة التذكير عند تبديل النوع
        if (_selectedType == EntityType.appointment) {
          _isReminderEnabled = true;
        } else {
          _isReminderEnabled = false;
        }

        _checkPrayerConflict();
      }),
    );
  }

  Widget _buildCommonHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: _selectedType == EntityType.medicine
                ? l10n.medicineName
                : _selectedType == EntityType.appointment
                ? l10n.appointmentTitle
                : l10n.taskTitleHint,
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
            border: OutlineInputBorder(
              borderRadius: AtharRadii.radiusMd,
              borderSide: BorderSide.none,
            ),
          ),
          validator: (v) => v!.isEmpty ? l10n.required : null,
        ),
        AtharGap.lg,
        DateTimePicker(
          selectedDate: _selectedDate,
          isHijriMode: _isHijriMode,
          onDateTap: _pickDate,
          onTimeTap: _pickTime,
        ),
        if (_selectedType == EntityType.task &&
            _prayerConflict.hasConflict) ...[
          AtharGap.md,
          _buildConflictWarning(),
        ],
      ],
    );
  }

  Widget _buildTaskFields() {
    return Column(
      children: [
        DurationPicker(
          selectedDuration: _selectedDuration,
          onDurationSelected: (val) {
            setState(() => _selectedDuration = val);
            _checkPrayerConflict();
          },
        ),
        AtharGap.lg,
        _buildAssigneeTile(),
        PrioritySelector(
          isUrgent: _isUrgent,
          isImportant: _isImportant,
          onUrgentChanged: (val) => setState(() => _isUrgent = val),
          onImportantChanged: (val) => setState(() => _isImportant = val),
        ),
        AtharGap.md,
        CategorySelector(
          selectedCategory: _selectedCategory,
          onSelected: (cat) => setState(() => _selectedCategory = cat),
          onAddPressed: _showAddCategoryDialog,
        ),
        AtharGap.md,
        RecurrencePicker(
          initialPattern: _selectedRecurrence,
          onChanged: (pattern) =>
              setState(() => _selectedRecurrence = pattern),
        ),
      ],
    );
  }

  Widget _buildMedicineFields() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMedicineTypeChip('pill', l10n.pills, Icons.circle_outlined),
              _buildMedicineTypeChip('syrup', l10n.syrup, Icons.local_drink),
              _buildMedicineTypeChip(
                'injection',
                l10n.injection,
                Icons.vaccines,
              ),
              _buildMedicineTypeChip('drops', l10n.drops, Icons.water_drop),
              _buildMedicineTypeChip(
                'ointment',
                l10n.ointment,
                Icons.sanitizer,
              ),
              _buildMedicineTypeChip('spray', l10n.spray, Icons.air),
            ],
          ),
        ),
        AtharGap.lg,

        // نظام الجدولة
        DropdownButtonFormField<String>(
          initialValue: _schedulingType,

          items: [
            DropdownMenuItem(value: 'fixed', child: Text(l10n.fixedTimes)),
            DropdownMenuItem(
              value: 'interval',
              child: Text(l10n.repeatByHours),
            ),
          ],
          onChanged: (v) => setState(() => _schedulingType = v!),
          decoration: InputDecoration(
            labelText: l10n.schedulePattern,
            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: AtharRadii.radiusMd,
              borderSide: BorderSide(color: colorScheme.outline),
            ),
          ),
        ),
        AtharGap.md,

        // ✅ FIX #3: إضافة Fixed Time Slots UI
        if (_schedulingType == 'fixed')
          _buildFixedTimeSelector()
        else
          _buildIntervalSelector(),

        AtharGap.lg,
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _doseAmountController,
                l10n.dosage,
                TextInputType.number,
              ),
            ),
            AtharGap.hSm,
            Expanded(
              child: _buildTextField(
                _doseUnitController,
                l10n.unit,
                TextInputType.text,
              ),
            ),
          ],
        ),
        AtharGap.md,
        _buildInstructionsDropdown(),
        AtharGap.lg,
        _buildMedicineDurationSection(),
        AtharGap.lg,
        _buildAutoRefillSection(),
      ],
    );
  }

  // ✅ FIX #3: إضافة دالة Fixed Time Selector
  Widget _buildFixedTimeSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectIntakeTimes,
          style: TextStyle(fontSize: 12.sp, color: colorScheme.outline),
        ),
        AtharGap.sm,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            ..._fixedTimes.map(
              (time) => Chip(
                label: Text(time.format(context)),
                onDeleted: () => setState(() => _fixedTimes.remove(time)),
                backgroundColor: _infoColor.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: _infoColor),
                deleteIconColor: _infoColor,
              ),
            ),
            ActionChip(
              label: const Icon(Icons.add, size: 18),
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              onPressed: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 8, minute: 0),
                );
                if (t != null && !_fixedTimes.contains(t)) {
                  setState(() => _fixedTimes.add(t));
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntervalSelector() {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Icon(Icons.timelapse, color: _warningColor),
        AtharGap.hMd,
        Text(l10n.every, style: TextStyle(fontSize: 14.sp)),
        AtharGap.hMd,
        DropdownButton<int>(
          value: _intervalHours,
          items: [4, 6, 8, 12, 24]
              .map(
                (h) =>
                    DropdownMenuItem(value: h, child: Text(l10n.hoursCount(h))),
              )
              .toList(),
          onChanged: (v) => setState(() => _intervalHours = v!),
        ),
      ],
    );
  }

  Widget _buildMedicineDurationSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _quantityController,
                l10n.currentStock,
                TextInputType.number,
                icon: Icons.inventory,
              ),
            ),
            AtharGap.hMd,
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _durationMode,
                items: [
                  DropdownMenuItem(value: 'days', child: Text(l10n.byDays)),
                  DropdownMenuItem(value: 'date', child: Text(l10n.byDate)),
                ],
                onChanged: (v) => setState(() => _durationMode = v!),
                decoration: InputDecoration(
                  labelText: l10n.treatmentDuration,
                  border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
                ),
              ),
            ),
          ],
        ),
        AtharGap.md,
        if (_durationMode == 'days')
          _buildTextField(
            _durationController,
            l10n.daysCount,
            TextInputType.number,
            icon: Icons.timer,
          )
        else
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => _selectedEndDate = picked);
            },
            child: Container(
              padding: AtharSpacing.allMd,
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: AtharRadii.radiusMd,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  AtharGap.hSm,
                  Text(
                    _selectedEndDate == null
                        ? l10n.selectEndDate
                        : DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAppointmentFields() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildApptTypeChip(
                'checkup',
                l10n.checkup,
                Icons.medical_services,
              ),
              _buildApptTypeChip('lab', l10n.labTest, Icons.science),
              _buildApptTypeChip('vaccine', l10n.vaccine, Icons.vaccines),
              _buildApptTypeChip('procedure', l10n.procedure, Icons.healing),
            ],
          ),
        ),
        AtharGap.lg,
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _doctorController,
                l10n.doctor,
                TextInputType.text,
                icon: Icons.person_outline,
              ),
            ),
            AtharGap.hMd,
            Expanded(
              child: _buildTextField(
                _locationController,
                l10n.locationClinic,
                TextInputType.text,
                icon: Icons.location_on_outlined,
              ),
            ),
          ],
        ),
        AtharGap.md,
        _buildTextField(
          _notesController,
          l10n.appointmentNotes,
          TextInputType.multiline,
          icon: Icons.notes,
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return ReminderPickerWidget(
      reminderTime: _reminderTime,
      isEnabled: _isReminderEnabled,
      onToggle: (val) => setState(() => _isReminderEnabled = val),
      onTimeChanged: (newTime) => setState(() => _reminderTime = newTime),
    );
  }

  // --- Logic Helpers ---

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type, {
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: type == TextInputType.multiline ? 3 : 1,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
      ),
    );
  }

  Widget _buildMedicineTypeChip(String key, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isSelected = _medType == key;
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: ChoiceChip(
        label: Row(
          children: [Icon(icon, size: 14), SizedBox(width: 4), Text(label)],
        ),
        selected: isSelected,
        selectedColor: colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? colorScheme.surface : colorScheme.onSurface,
        ),
        onSelected: (v) => setState(() => _medType = key),
      ),
    );
  }

  Widget _buildApptTypeChip(String key, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    bool isSelected = _apptType == key;
    return Padding(
      padding: EdgeInsets.only(left: 8.w),
      child: ChoiceChip(
        label: Row(
          children: [Icon(icon, size: 14), SizedBox(width: 4), Text(label)],
        ),
        selected: isSelected,
        selectedColor: colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected ? colorScheme.surface : colorScheme.onSurface,
        ),
        onSelected: (v) => setState(() => _apptType = key),
      ),
    );
  }

  Widget _buildInstructionsDropdown() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return DropdownButtonFormField<String>(
      initialValue: _instructions,
      decoration: InputDecoration(
        labelText: l10n.usageInstructions,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: AtharRadii.radiusMd,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
      ),
      items: [
        DropdownMenuItem(value: 'before_meal', child: Text(l10n.beforeMeal)),
        DropdownMenuItem(value: 'after_meal', child: Text(l10n.afterMeal)),
        DropdownMenuItem(value: 'with_meal', child: Text(l10n.withMeal)),
        DropdownMenuItem(value: 'anytime', child: Text(l10n.anytime)),
      ],
      onChanged: (v) => setState(() => _instructions = v!),
    );
  }

  Widget _buildAutoRefillSection() {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: _infoColor.withValues(alpha: 0.1),
        borderRadius: AtharRadii.radiusMd,
      ),
      child: ExpansionTile(
        title: Text(
          l10n.smartRefill,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: AtharSpacing.allMd,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _refillMode,
                  items: [
                    DropdownMenuItem(value: 'off', child: Text(l10n.off)),
                    DropdownMenuItem(
                      value: 'quantity',
                      child: Text(l10n.byQuantity),
                    ),
                    // ✅ FIX #5: إضافة الخيار المفقود
                    DropdownMenuItem(
                      value: 'date',
                      child: Text(l10n.beforeCourseEnd),
                    ),
                  ],
                  onChanged: (v) => setState(() => _refillMode = v!),
                  decoration: InputDecoration(labelText: l10n.autoOrderMode),
                ),
                if (_refillMode != 'off') ...[
                  AtharGap.md,
                  _buildTextField(
                    _thresholdController,
                    _refillMode == 'quantity'
                        ? l10n.alertOnLowStock
                        : l10n.alertBeforeCourseEndDays,
                    TextInputType.number,
                  ),
                  AtharGap.sm,
                  DropdownButtonFormField<String>(
                    initialValue: _refillAction,
                    items: [
                      DropdownMenuItem(
                        value: 'list',
                        child: Text(l10n.addToList),
                      ),
                      DropdownMenuItem(
                        value: 'task',
                        child: Text(l10n.createTask),
                      ),
                      // ✅ FIX #5: إضافة الخيار المفقود
                      DropdownMenuItem(
                        value: 'both',
                        child: Text(l10n.bothTaskAndList),
                      ),
                    ],
                    onChanged: (v) => setState(() => _refillAction = v!),
                    decoration: InputDecoration(labelText: l10n.action),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssigneeTile() {
    if (widget.targetSpaceId == null) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: Icon(Icons.person_add_alt_1, color: colorScheme.primary),
      title: Text(
        _selectedAssigneeId == null ? l10n.assignToMember : l10n.assigned,
      ),
      onTap: () async {
        final result = await showModalBottomSheet(
          context: context,
          builder: (_) => MemberSelectorSheet(spaceId: widget.targetSpaceId!),
        );
        if (result != null) setState(() => _selectedAssigneeId = result);
      },
    );
  }

  Widget _buildConflictWarning() {
    return Container(
      padding: AtharSpacing.allMd,
      decoration: BoxDecoration(
        color: _prayerConflict.color.withValues(alpha: 0.1),
        borderRadius: AtharRadii.radiusMd,
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: _prayerConflict.color),
          AtharGap.hSm,
          Expanded(
            child: Text(
              _prayerConflict.message,
              style: TextStyle(color: _prayerConflict.color),
            ),
          ),
        ],
      ),
    );
  }

  // --- Save Logic ---

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    // حفظ المراجع قبل أي async operations
    final taskCubit = context.read<TaskCubit>();
    final healthCubit = context.read<HealthCubit>();
    final navigator = Navigator.of(context);

    // ✅ FIX #4: إضافة فحص تعارضات المهام
    if (_selectedType == EntityType.task) {
      // فحص تعارض المهام أولاً
      final taskConflict = await taskCubit.validateTimeConflict(
        date: _selectedDate,
        startTime: TimeOfDay.fromDateTime(_selectedDate),
        durationMinutes: _selectedDuration,
        excludeTaskId: widget.itemToEdit is TaskModel
            ? (widget.itemToEdit as TaskModel).id
            : null,
      );

      // ✅ FIX: فحص mounted بعد await
      if (!mounted) return;

      // تحديد التعارض النهائي
      ConflictResult? finalConflict;
      if (taskConflict.hasConflict) {
        finalConflict = taskConflict;
      } else if (_prayerConflict.hasConflict) {
        finalConflict = _prayerConflict;
      }

      // إذا كان هناك تعارض، عرض الديالوج
      if (finalConflict != null) {
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => ConflictDialog(
            conflict: finalConflict!,
            onForceSave: () => Navigator.pop(ctx, true),
            onCancel: () => Navigator.pop(ctx, false),
            onDelay: () {
              // استخدام الوقت المقترح
              // ✅ capture القيمة في متغير محلي
              final suggested = finalConflict!.suggestedTime;

              if (suggested != null) {
                // ✅ الآن آمن - suggested is non-nullable DateTime
                setState(() => _selectedDate = suggested);
                _checkPrayerConflict();
              }
              Navigator.pop(ctx, true);
            },
          ),
        );

        if (shouldProceed != true) return;
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = true);

    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // ✅ FIX #2: تحديد وقت التذكير الافتراضي حسب النوع
    final validReminder = _isReminderEnabled
        ? (_reminderTime ??
              finalDateTime.subtract(
                _selectedType == EntityType.appointment
                    ? const Duration(minutes: 30) // للمواعيد: 30 دقيقة
                    : const Duration(minutes: 10), // للمهام: 10 دقائق
              ))
        : null;

    try {
      if (_selectedType == EntityType.task) {
        // ✅ FIX #7: حذف معامل isReminderEnabled
        await taskCubit.addTask(
          title: _titleController.text,
          date: finalDateTime,
          isUrgent: _isUrgent,
          isImportant: _isImportant,
          category: _selectedCategory,
          duration: _selectedDuration,
          spaceId: widget.targetSpaceId,
          moduleId: widget.targetModuleId,
          assigneeId: _selectedAssigneeId,
          reminderTime: validReminder,
          recurrence: _selectedRecurrence,
        );
      } else if (_selectedType == EntityType.medicine) {
        // ✅ بناء قائمة الأوقات الثابتة
        final timesList = _fixedTimes
            .map(
              (t) =>
                  "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}",
            )
            .toList();

        final med = MedicineModel(
          uuid: const Uuid().v4(),
          name: _titleController.text,
          moduleId: widget.targetModuleId ?? 'health',
          type: _medType,
          doseAmount: double.tryParse(_doseAmountController.text),
          doseUnit: _doseUnitController.text.isNotEmpty
              ? _doseUnitController.text
              : null,
          instructions: _instructions,
          stockQuantity: double.tryParse(_quantityController.text),
          autoRefillMode: _refillMode,
          refillThreshold: double.tryParse(_thresholdController.text) ?? 5.0,
          refillAction: _refillAction,
          startDate: finalDateTime,
          courseDurationDays: _durationMode == 'days'
              ? int.tryParse(_durationController.text)
              : null,
          treatmentEndDate: _selectedEndDate,
          schedulingType: _schedulingType,
          fixedTimeSlots: _schedulingType == 'fixed' ? timesList : null,
          intervalHours: _schedulingType == 'interval' ? _intervalHours : null,
          isActive: true,
        );
        healthCubit.addMedicine(med);
      } else {
        final appt = AppointmentModel(
          uuid: const Uuid().v4(),
          moduleId: widget.targetModuleId ?? 'health',
          title: _titleController.text,
          appointmentDate: finalDateTime,
          doctorName: _doctorController.text.isNotEmpty
              ? _doctorController.text
              : null,
          locationName: _locationController.text.isNotEmpty
              ? _locationController.text
              : null,
          type: _apptType,
          notes: _notesController.text.isNotEmpty
              ? _notesController.text
              : null,
          reminderEnabled: _isReminderEnabled,
          reminderTime: validReminder,
        );
        healthCubit.addAppointment(appt);
      }

      if (mounted) navigator.pop();
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

  Widget _buildSaveButton() {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: AtharButton(
        label: l10n.saveItem,
        onPressed: _isSaving ? null : _handleSave,
        isLoading: _isSaving,
      ),
    );
  }

  // --- Pickers ---
  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
      _checkPrayerConflict();
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
      _checkPrayerConflict();
    }
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final l10n = AppLocalizations.of(context);
    AtharDialog.show(
      context: context,
      title: l10n.newCategory,
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(hintText: l10n.categoryName),
      ),
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.add,
      onCancel: () => Navigator.pop(context),
      onConfirm: () {
        if (nameController.text.isNotEmpty) {
          // context.read<CategoryCubit>().addCategory(
          //   nameController.text,
          //   0xFF9C27B0,
          //   Icons.bookmark.codePoint,
          // );
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

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _doseAmountController.dispose();
    _doseUnitController.dispose();
    _quantityController.dispose();
    _durationController.dispose();
    _thresholdController.dispose();
    _doctorController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}


// // Core & DI

// // Models

// // Cubits

// // Components






//   // Controllers

//   // Common State
//       false; // ✅ FIX #1: افتراضياً false، سيتم تغييره في initState

//   // Task Specific

//   // Medicine Specific

//   // Appointment Specific



//     // ✅ FIX #1: تفعيل التذكير افتراضياً للمواعيد فقط





//       // ✅ استرجاع Fixed Time Slots
//             _fixedTimes.add(
//               TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
//       // ✅ FIX #6: إضافة دعم التعديل للمواعيد
//       // ✅ FIX ERROR #1: إزالة ?? true






//       taskStartTime: _selectedDate,
//       taskDuration: Duration(minutes: _selectedDuration),
//       prayers: prayers,
//       settings: currentSettings,

//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       padding: EdgeInsets.fromLTRB(
//         20.w,
//         20.h,
//         20.w,
//         MediaQuery.of(context).viewInsets.bottom + 20.h,
//       ),
//       child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHandle(),
//               SizedBox(height: 16.h),
//               _buildTypeSelector(),
//               SizedBox(height: 24.h),
//               _buildCommonHeader(),
//               SizedBox(height: 20.h),
//                 _buildAppointmentFields(),
//               SizedBox(height: 20.h),
//               _buildReminderSection(),
//               SizedBox(height: 24.h),
//               _buildSaveButton(),
//           ),
//         ),
//       ),

//       width: 40.w,
//       height: 4.h,
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(2),
//       ),

//       segments: const [
//         ButtonSegment(
//           value: EntityType.task,
//           label: Text("مهمة"),
//           icon: Icon(Icons.assignment_outlined),
//         ),
//         ButtonSegment(
//           value: EntityType.medicine,
//           label: Text("دواء"),
//           icon: Icon(Icons.medication_outlined),
//         ),
//         ButtonSegment(
//           value: EntityType.appointment,
//           label: Text("موعد"),
//           icon: Icon(Icons.calendar_today_outlined),
//         ),
//       selected: {_selectedType},

//         // ✅ FIX #1: تحديث حالة التذكير عند تبديل النوع

//       }),

//       children: [
//         TextFormField(
//           controller: _titleController,
//           decoration: InputDecoration(
//                 ? "اسم الدواء"
//                 ? "عنوان الموعد"
//                 : "عنوان المهمة",
//             filled: true,
//             fillColor: AppColors.background,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           validator: (v) => v!.isEmpty ? "مطلوب" : null,
//         ),
//         SizedBox(height: 16.h),
//         DateTimePicker(
//           selectedDate: _selectedDate,
//           isHijriMode: _isHijriMode,
//           onDateTap: _pickDate,
//           onTimeTap: _pickTime,
//         ),
//             _prayerConflict.hasConflict) ...[
//           SizedBox(height: 12.h),
//           _buildConflictWarning(),

//       children: [
//         DurationPicker(
//           selectedDuration: _selectedDuration,
//           },
//         ),
//         SizedBox(height: 16.h),
//         _buildAssigneeTile(),
//         PrioritySelector(
//           isUrgent: _isUrgent,
//           isImportant: _isImportant,
//           onUrgentChanged: (val) => setState(() => _isUrgent = val),
//           onImportantChanged: (val) => setState(() => _isImportant = val),
//         ),
//         SizedBox(height: 12.h),
//         CategorySelector(
//           selectedCategory: _selectedCategory,
//           onSelected: (cat) => setState(() => _selectedCategory = cat),
//           onAddPressed: _showAddCategoryDialog,
//         ),

//       children: [
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: [
//               _buildMedicineTypeChip('pill', "حبوب", Icons.circle_outlined),
//               _buildMedicineTypeChip('syrup', "شراب", Icons.local_drink),
//               _buildMedicineTypeChip('injection', "إبرة", Icons.vaccines),
//               _buildMedicineTypeChip('drops', "قطرة", Icons.water_drop),
//               _buildMedicineTypeChip('ointment', "مرهم", Icons.sanitizer),
//               _buildMedicineTypeChip('spray', "بخاخ", Icons.air),
//           ),
//         ),
//         SizedBox(height: 16.h),

//         // نظام الجدولة
//         DropdownButtonFormField<String>(
//           initialValue: _schedulingType,
//           items: const [
//             DropdownMenuItem(value: 'fixed', child: Text("أوقات ثابتة")),
//             DropdownMenuItem(value: 'interval', child: Text("تكرار بالساعات")),
//           onChanged: (v) => setState(() => _schedulingType = v!),
//           decoration: InputDecoration(
//             labelText: "نمط الجدولة",
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//           ),
//         ),
//         SizedBox(height: 12.h),

//         // ✅ FIX #3: إضافة Fixed Time Slots UI
//           _buildFixedTimeSelector()
//           _buildIntervalSelector(),

//         SizedBox(height: 16.h),
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 _doseAmountController,
//                 "الجرعة",
//                 TextInputType.number,
//               ),
//             ),
//             SizedBox(width: 8.w),
//             Expanded(
//               child: _buildTextField(
//                 _doseUnitController,
//                 "الوحدة",
//                 TextInputType.text,
//               ),
//             ),
//         ),
//         SizedBox(height: 12.h),
//         _buildInstructionsDropdown(),
//         SizedBox(height: 16.h),
//         _buildMedicineDurationSection(),
//         SizedBox(height: 16.h),
//         _buildAutoRefillSection(),

//   // ✅ FIX #3: إضافة دالة Fixed Time Selector
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "حدد أوقات التناول:",
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: Colors.grey,
//             fontFamily: 'Tajawal',
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Wrap(
//           spacing: 8.w,
//           runSpacing: 8.h,
//           children: [
//             ..._fixedTimes.map(
//                 label: Text(time.format(context)),
//                 backgroundColor: Colors.blue.shade50,
//                 labelStyle: const TextStyle(color: Colors.blue),
//                 deleteIconColor: Colors.blue,
//               ),
//             ),
//             ActionChip(
//               label: const Icon(Icons.add, size: 18),
//               backgroundColor: AppColors.primary.withValues(alpha: 0.1),
//                   context: context,
//                   initialTime: const TimeOfDay(hour: 8, minute: 0),
//               },
//             ),
//         ),

//       children: [
//         SizedBox(width: 12.w),
//         Text(
//           "كل",
//           style: TextStyle(fontSize: 14.sp, fontFamily: 'Tajawal'),
//         ),
//         SizedBox(width: 12.w),
//         DropdownButton<int>(
//           value: _intervalHours,
//           items: [4, 6, 8, 12, 24]
//               .toList(),
//           onChanged: (v) => setState(() => _intervalHours = v!),
//         ),

//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 _quantityController,
//                 "المخزون الحالي",
//                 TextInputType.number,
//                 icon: Icons.inventory,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: DropdownButtonFormField<String>(
//                 initialValue: _durationMode,
//                 items: const [
//                   DropdownMenuItem(value: 'days', child: Text("بالأيام")),
//                   DropdownMenuItem(value: 'date', child: Text("بالتاريخ")),
//                 onChanged: (v) => setState(() => _durationMode = v!),
//                 decoration: InputDecoration(
//                   labelText: "مدة العلاج",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//               ),
//             ),
//         ),
//         SizedBox(height: 12.h),
//           _buildTextField(
//             _durationController,
//             "عدد الأيام",
//             TextInputType.number,
//             icon: Icons.timer,
//           )
//           InkWell(
//                 context: context,
//                 initialDate: DateTime.now(),
//                 firstDate: DateTime.now(),
//                 lastDate: DateTime(2030),
//             },
//             child: Container(
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Row(
//                 children: [
//                   SizedBox(width: 8.w),
//                   Text(
//                         ? "حدد تاريخ النهاية"
//                         : DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
//                   ),
//               ),
//             ),
//           ),

//       children: [
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: [
//               _buildApptTypeChip('checkup', "كشف", Icons.medical_services),
//               _buildApptTypeChip('lab', "تحليل", Icons.science),
//               _buildApptTypeChip('vaccine', "تطعيم", Icons.vaccines),
//               _buildApptTypeChip('procedure', "إجراء", Icons.healing),
//           ),
//         ),
//         SizedBox(height: 16.h),
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 _doctorController,
//                 "الطبيب",
//                 TextInputType.text,
//                 icon: Icons.person_outline,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: _buildTextField(
//                 _locationController,
//                 "المكان/العيادة",
//                 TextInputType.text,
//                 icon: Icons.location_on_outlined,
//               ),
//             ),
//         ),
//         SizedBox(height: 12.h),
//         _buildTextField(
//           _notesController,
//           "ملاحظات الموعد",
//           TextInputType.multiline,
//           icon: Icons.notes,
//         ),

//       reminderTime: _reminderTime,
//       isEnabled: _isReminderEnabled,
//       onToggle: (val) => setState(() => _isReminderEnabled = val),
//       onTimeChanged: (newTime) => setState(() => _reminderTime = newTime),

//   // --- Logic Helpers ---

//     TextEditingController controller,
//     String label,
//     IconData? icon,
//       controller: controller,
//       keyboardType: type,
//       maxLines: type == TextInputType.multiline ? 3 : 1,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: icon != null ? Icon(icon) : null,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
//       ),

//       padding: EdgeInsets.only(left: 8.w),
//       child: ChoiceChip(
//         label: Row(
//           children: [Icon(icon, size: 14), SizedBox(width: 4), Text(label)],
//         ),
//         selected: isSelected,
//         selectedColor: AppColors.primary,
//         labelStyle: TextStyle(
//           color: isSelected ? Colors.white : Colors.black,
//           fontFamily: 'Tajawal',
//         ),
//         onSelected: (v) => setState(() => _medType = key),
//       ),

//       padding: EdgeInsets.only(left: 8.w),
//       child: ChoiceChip(
//         label: Row(
//           children: [Icon(icon, size: 14), SizedBox(width: 4), Text(label)],
//         ),
//         selected: isSelected,
//         selectedColor: AppColors.primary,
//         labelStyle: TextStyle(
//           color: isSelected ? Colors.white : Colors.black,
//           fontFamily: 'Tajawal',
//         ),
//         onSelected: (v) => setState(() => _apptType = key),
//       ),

//       initialValue: _instructions,
//       decoration: InputDecoration(
//         labelText: "تعليمات الاستخدام",
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
//       ),
//       items: const [
//         DropdownMenuItem(value: 'before_meal', child: Text("قبل الأكل")),
//         DropdownMenuItem(value: 'after_meal', child: Text("بعد الأكل")),
//         DropdownMenuItem(value: 'with_meal', child: Text("مع الأكل")),
//         DropdownMenuItem(value: 'anytime', child: Text("في أي وقت")),
//       onChanged: (v) => setState(() => _instructions = v!),

//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: ExpansionTile(
//         title: const Text(
//           "إعادة التعبئة الذكية",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         children: [
//           Padding(
//             padding: EdgeInsets.all(12.w),
//             child: Column(
//               children: [
//                 DropdownButtonFormField<String>(
//                   initialValue: _refillMode,
//                   items: const [
//                     DropdownMenuItem(value: 'off', child: Text("إيقاف")),
//                     DropdownMenuItem(
//                       value: 'quantity',
//                       child: Text("حسب الكمية"),
//                     ),
//                     // ✅ FIX #5: إضافة الخيار المفقود
//                     DropdownMenuItem(
//                       value: 'date',
//                       child: Text("قبل انتهاء الكورس"),
//                     ),
//                   onChanged: (v) => setState(() => _refillMode = v!),
//                   decoration: const InputDecoration(
//                     labelText: "وضع الطلب التلقائي",
//                   ),
//                 ),
//                   SizedBox(height: 12.h),
//                   _buildTextField(
//                     _thresholdController,
//                         ? "تنبيه عند نقص الكمية لـ"
//                         : "تنبيه قبل انتهاء الكورس بـ (أيام)",
//                     TextInputType.number,
//                   ),
//                   SizedBox(height: 8.h),
//                   DropdownButtonFormField<String>(
//                     initialValue: _refillAction,
//                     items: const [
//                       DropdownMenuItem(
//                         value: 'list',
//                         child: Text("إضافة للقائمة"),
//                       ),
//                       DropdownMenuItem(
//                         value: 'task',
//                         child: Text("إنشاء مهمة"),
//                       ),
//                       // ✅ FIX #5: إضافة الخيار المفقود
//                       DropdownMenuItem(
//                         value: 'both',
//                         child: Text("كلاهما (مهمة + قائمة)"),
//                       ),
//                     onChanged: (v) => setState(() => _refillAction = v!),
//                     decoration: const InputDecoration(labelText: "الإجراء"),
//                   ),
//             ),
//           ),
//       ),

//       leading: const Icon(Icons.person_add_alt_1, color: Colors.purple),
//       title: Text(_selectedAssigneeId == null ? "إسناد لعضو" : "تم الإسناد"),
//           context: context,
//       },

//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: _prayerConflict.color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.warning, color: _prayerConflict.color),
//           SizedBox(width: 8.w),
//           Expanded(
//             child: Text(
//               _prayerConflict.message,
//               style: TextStyle(color: _prayerConflict.color),
//             ),
//           ),
//       ),

//   // --- Save Logic ---


//     // حفظ المراجع قبل أي async operations

//     // ✅ FIX #4: إضافة فحص تعارضات المهام
//       // فحص تعارض المهام أولاً
//         date: _selectedDate,
//         startTime: TimeOfDay.fromDateTime(_selectedDate),
//         durationMinutes: _selectedDuration,
//         excludeTaskId: widget.itemToEdit is TaskModel
//             ? (widget.itemToEdit as TaskModel).id
//             : null,

//       // ✅ FIX: فحص mounted بعد await

//       // تحديد التعارض النهائي

//       // إذا كان هناك تعارض، عرض الديالوج
//           context: context,
//             conflict: finalConflict!,
//               // استخدام الوقت المقترح
//               // ✅ capture القيمة في متغير محلي

//                 // ✅ الآن آمن - suggested is non-nullable DateTime
//             },
//           ),



//       _selectedDate.year,
//       _selectedDate.month,
//       _selectedDate.day,
//       _selectedTime.hour,
//       _selectedTime.minute,

//     // ✅ FIX #2: تحديد وقت التذكير الافتراضي حسب النوع
//         ? (_reminderTime ??
//               finalDateTime.subtract(
//                     ? const Duration(minutes: 30) // للمواعيد: 30 دقيقة
//                     : const Duration(minutes: 10), // للمهام: 10 دقائق
//               ))

//         // ✅ FIX #7: حذف معامل isReminderEnabled
//           title: _titleController.text,
//           date: finalDateTime,
//           isUrgent: _isUrgent,
//           isImportant: _isImportant,
//           category: _selectedCategory,
//           duration: _selectedDuration,
//           spaceId: widget.targetSpaceId,
//           moduleId: widget.targetModuleId,
//           assigneeId: _selectedAssigneeId,
//           reminderTime: validReminder,
//         // ✅ بناء قائمة الأوقات الثابتة
//             .map(
//                   "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}",
//             )

//           uuid: const Uuid().v4(),
//           name: _titleController.text,
//           moduleId: widget.targetModuleId ?? 'health',
//           type: _medType,
//           doseAmount: double.tryParse(_doseAmountController.text),
//           doseUnit: _doseUnitController.text.isNotEmpty
//               ? _doseUnitController.text
//               : null,
//           instructions: _instructions,
//           stockQuantity: double.tryParse(_quantityController.text),
//           autoRefillMode: _refillMode,
//           refillThreshold: double.tryParse(_thresholdController.text) ?? 5.0,
//           refillAction: _refillAction,
//           startDate: finalDateTime,
//               ? int.tryParse(_durationController.text)
//               : null,
//           treatmentEndDate: _selectedEndDate,
//           schedulingType: _schedulingType,
//           fixedTimeSlots: _schedulingType == 'fixed' ? timesList : null,
//           intervalHours: _schedulingType == 'interval' ? _intervalHours : null,
//           isActive: true,
//           uuid: const Uuid().v4(),
//           moduleId: widget.targetModuleId ?? 'health',
//           title: _titleController.text,
//           appointmentDate: finalDateTime,
//           doctorName: _doctorController.text.isNotEmpty
//               ? _doctorController.text
//               : null,
//           locationName: _locationController.text.isNotEmpty
//               ? _locationController.text
//               : null,
//           type: _apptType,
//           notes: _notesController.text.isNotEmpty
//               ? _notesController.text
//               : null,
//           reminderEnabled: _isReminderEnabled,
//           reminderTime: validReminder,

//         ScaffoldMessenger.of(
//           context,

//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isSaving ? null : _handleSave,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           padding: EdgeInsets.symmetric(vertical: 14.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//         ),
//         child: _isSaving
//             ? const CircularProgressIndicator(color: Colors.white)
//             : const Text(
//                 "حفظ العنصر",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//       ),

//   // --- Pickers ---
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),

//       context: context,
//       initialTime: _selectedTime,

//     showDialog(
//       context: context,
//         title: const Text("تصنيف جديد"),
//         content: TextField(
//           controller: nameController,
//           decoration: const InputDecoration(hintText: "اسم التصنيف"),
//         ),
//         actions: [
//           TextButton(
//             child: const Text("إلغاء"),
//           ),
//           ElevatedButton(
//                   nameController.text,
//                   0xFF9C27B0,
//                   Icons.bookmark.codePoint,
//             },
//             child: const Text("إضافة"),
//           ),
//       ),

//---------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';

// // Core & DI
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart';
// import 'package:athar/core/services/prayer_conflict_service.dart';

// // Models
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/features/health/data/models/medicine_model.dart';
// import 'package:athar/features/health/data/models/appointment_model.dart';
// import 'package:athar/features/settings/data/models/category_model.dart';
// import 'package:athar/features/settings/data/models/user_settings.dart';
// import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
// import 'package:athar/features/task/domain/models/conflict_result.dart';

// // Cubits
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
// import 'package:athar/features/prayer/presentation/cubit/prayer_cubit.dart';
// import 'package:athar/features/prayer/presentation/cubit/prayer_state.dart';

// // Components
// import 'package:athar/features/task/presentation/widgets/components/category_selector.dart';
// import 'package:athar/features/task/presentation/widgets/components/priority_selector.dart';
// import 'package:athar/features/task/presentation/widgets/components/date_time_picker.dart';
// import 'package:athar/features/task/presentation/widgets/components/duration_picker.dart';
// import 'package:athar/features/task/presentation/widgets/dialogs/conflict_dialog.dart';
// import 'package:athar/features/space/presentation/widgets/member_selector_sheet.dart';
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';

// enum EntityType { task, medicine, appointment }

// class UnifiedAddSheet extends StatefulWidget {
//   final EntityType initialType;
//   final String? targetSpaceId;
//   final String? targetModuleId;
//   final dynamic itemToEdit;

//   const UnifiedAddSheet({
//     super.key,
//     this.initialType = EntityType.task,
//     this.targetSpaceId,
//     this.targetModuleId,
//     this.itemToEdit,
//   });

//   @override
//   State<UnifiedAddSheet> createState() => _UnifiedAddSheetState();
// }

// class _UnifiedAddSheetState extends State<UnifiedAddSheet> {
//   final _formKey = GlobalKey<FormState>();
//   late EntityType _selectedType;

//   // Controllers
//   final _titleController = TextEditingController();
//   final _notesController = TextEditingController();
//   final _doseAmountController = TextEditingController();
//   final _doseUnitController = TextEditingController();
//   final _quantityController = TextEditingController();
//   final _durationController = TextEditingController();
//   final _thresholdController = TextEditingController(text: '5');
//   final _doctorController = TextEditingController();
//   final _locationController = TextEditingController();

//   // Common State
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   DateTime? _reminderTime;
//   bool _isReminderEnabled =
//       false; // ✅ FIX #1: افتراضياً false، سيتم تغييره في initState
//   bool _isSaving = false;
//   bool _isHijriMode = false;

//   // Task Specific
//   bool _isUrgent = false;
//   bool _isImportant = false;
//   int _selectedDuration = 30;
//   CategoryModel? _selectedCategory;
//   String? _selectedAssigneeId;
//   ConflictResult _prayerConflict = ConflictResult.none();

//   // Medicine Specific
//   String _medType = 'pill';
//   String _instructions = 'after_meal';
//   String _schedulingType = 'fixed';
//   String _durationMode = 'days';
//   String _refillMode = 'off';
//   String _refillAction = 'list';
//   final List<TimeOfDay> _fixedTimes = [];
//   int _intervalHours = 8;
//   DateTime? _selectedEndDate;

//   // Appointment Specific
//   String _apptType = 'checkup';

//   final _prayerConflictService = getIt<PrayerConflictService>();

//   @override
//   void initState() {
//     super.initState();
//     _selectedType = widget.initialType;

//     // ✅ FIX #1: تفعيل التذكير افتراضياً للمواعيد فقط
//     if (_selectedType == EntityType.appointment) {
//       _isReminderEnabled = true;
//     }

//     _loadInitialData();
//     _initFormIfEditing();
//   }

//   void _loadInitialData() async {
//     context.read<CategoryCubit>().loadCategories();
//     final settings = await getIt<SettingsRepository>().getSettings();
//     if (mounted) {
//       setState(() => _isHijriMode = settings.isHijriMode);
//       _checkPrayerConflict();
//     }
//   }

//   void _initFormIfEditing() {
//     if (widget.itemToEdit == null) return;
//     final item = widget.itemToEdit;

//     if (item is TaskModel) {
//       _selectedType = EntityType.task;
//       _titleController.text = item.title;
//       _selectedDate = item.date;
//       _isUrgent = item.isUrgent;
//       _isImportant = item.isImportant;
//       _selectedCategory = item.category.value;
//       _selectedDuration = item.durationMinutes;
//       _selectedAssigneeId = item.assigneeId;
//       if (item.reminderTime != null) {
//         _reminderTime = item.reminderTime;
//         _isReminderEnabled = true;
//       }
//     } else if (item is MedicineModel) {
//       _selectedType = EntityType.medicine;
//       _titleController.text = item.name;
//       _quantityController.text = item.stockQuantity?.toString() ?? '';
//       _doseAmountController.text = item.doseAmount?.toString() ?? '';
//       _doseUnitController.text = item.doseUnit ?? '';
//       _medType = item.type ?? 'pill';
//       _instructions = item.instructions ?? 'after_meal';
//       _refillMode = item.autoRefillMode;
//       _refillAction = item.refillAction;
//       _thresholdController.text = item.refillThreshold.toString();
//       _schedulingType = item.schedulingType;
//       if (item.courseDurationDays != null) {
//         _durationController.text = item.courseDurationDays.toString();
//         _durationMode = 'days';
//       }
//       if (item.intervalHours != null) _intervalHours = item.intervalHours!;

//       // ✅ استرجاع Fixed Time Slots
//       if (item.fixedTimeSlots != null && item.fixedTimeSlots!.isNotEmpty) {
//         _fixedTimes.clear();
//         for (var timeStr in item.fixedTimeSlots!) {
//           final parts = timeStr.split(':');
//           if (parts.length == 2) {
//             _fixedTimes.add(
//               TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
//             );
//           }
//         }
//       }
//     } else if (item is AppointmentModel) {
//       // ✅ FIX #6: إضافة دعم التعديل للمواعيد
//       _selectedType = EntityType.appointment;
//       _titleController.text = item.title;
//       _selectedDate = item.appointmentDate;
//       _selectedTime = TimeOfDay.fromDateTime(item.appointmentDate);
//       _apptType = item.type ?? 'checkup';
//       _doctorController.text = item.doctorName ?? '';
//       _locationController.text = item.locationName ?? '';
//       _notesController.text = item.notes ?? '';
//       // ✅ FIX ERROR #1: إزالة ?? true
//       _isReminderEnabled = item.reminderEnabled;

//       if (item.reminderTime != null) {
//         _reminderTime = item.reminderTime;
//       }
//     }
//   }

//   void _checkPrayerConflict() {
//     if (_selectedType != EntityType.task) return;

//     final prayerState = context.read<PrayerCubit>().state;
//     final settingsState = context.read<SettingsCubit>().state;

//     List<PrayerTime> prayers = [];
//     if (prayerState is PrayerLoaded) prayers = prayerState.allPrayers;

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
//     setState(() => _prayerConflict = result);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Container(
//       decoration: BoxDecoration(
//         color: colors.surface,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       padding: EdgeInsets.fromLTRB(
//         20.w,
//         20.h,
//         20.w,
//         MediaQuery.of(context).viewInsets.bottom + 20.h,
//       ),
//       child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHandle(),
//               AtharGap.lg,
//               _buildTypeSelector(),
//               AtharGap.xxl,
//               _buildCommonHeader(),
//               AtharGap.xl,
//               if (_selectedType == EntityType.task) _buildTaskFields(),
//               if (_selectedType == EntityType.medicine) _buildMedicineFields(),
//               if (_selectedType == EntityType.appointment)
//                 _buildAppointmentFields(),
//               AtharGap.xl,
//               _buildReminderSection(),
//               AtharGap.xxl,
//               _buildSaveButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHandle() {
//     final colors = context.colors;

//     return Container(
//       width: 40.w,
//       height: 4.h,
//       decoration: BoxDecoration(
//         color: colors.borderLight,
//         borderRadius: AtharRadii.radiusXxxs,
//       ),
//     );
//   }

//   Widget _buildTypeSelector() {
//     return SegmentedButton<EntityType>(
//       segments: const [
//         ButtonSegment(
//           value: EntityType.task,
//           label: Text("مهمة"),
//           icon: Icon(Icons.assignment_outlined),
//         ),
//         ButtonSegment(
//           value: EntityType.medicine,
//           label: Text("دواء"),
//           icon: Icon(Icons.medication_outlined),
//         ),
//         ButtonSegment(
//           value: EntityType.appointment,
//           label: Text("موعد"),
//           icon: Icon(Icons.calendar_today_outlined),
//         ),
//       ],
//       selected: {_selectedType},
//       onSelectionChanged: (Set<EntityType> val) => setState(() {
//         _selectedType = val.first;

//         // ✅ FIX #1: تحديث حالة التذكير عند تبديل النوع
//         if (_selectedType == EntityType.appointment) {
//           _isReminderEnabled = true;
//         } else {
//           _isReminderEnabled = false;
//         }

//         _checkPrayerConflict();
//       }),
//     );
//   }

//   Widget _buildCommonHeader() {
//     final colors = context.colors;

//     return Column(
//       children: [
//         TextFormField(
//           controller: _titleController,
//           decoration: InputDecoration(
//             hintText: _selectedType == EntityType.medicine
//                 ? "اسم الدواء"
//                 : _selectedType == EntityType.appointment
//                 ? "عنوان الموعد"
//                 : "عنوان المهمة",
//             filled: true,
//             fillColor: colors.scaffoldBackground,
//             border: OutlineInputBorder(
//               borderRadius: AtharRadii.radiusMd,
//               borderSide: BorderSide.none,
//             ),
//           ),
//           validator: (v) => v!.isEmpty ? "مطلوب" : null,
//         ),
//         AtharGap.lg,
//         DateTimePicker(
//           selectedDate: _selectedDate,
//           isHijriMode: _isHijriMode,
//           onDateTap: _pickDate,
//           onTimeTap: _pickTime,
//         ),
//         if (_selectedType == EntityType.task &&
//             _prayerConflict.hasConflict) ...[
//           AtharGap.md,
//           _buildConflictWarning(),
//         ],
//       ],
//     );
//   }

//   Widget _buildTaskFields() {
//     return Column(
//       children: [
//         DurationPicker(
//           selectedDuration: _selectedDuration,
//           onDurationSelected: (val) {
//             setState(() => _selectedDuration = val);
//             _checkPrayerConflict();
//           },
//         ),
//         AtharGap.lg,
//         _buildAssigneeTile(),
//         PrioritySelector(
//           isUrgent: _isUrgent,
//           isImportant: _isImportant,
//           onUrgentChanged: (val) => setState(() => _isUrgent = val),
//           onImportantChanged: (val) => setState(() => _isImportant = val),
//         ),
//         AtharGap.md,
//         CategorySelector(
//           selectedCategory: _selectedCategory,
//           onSelected: (cat) => setState(() => _selectedCategory = cat),
//           onAddPressed: _showAddCategoryDialog,
//         ),
//       ],
//     );
//   }

//   Widget _buildMedicineFields() {
//     final colors = context.colors;

//     return Column(
//       children: [
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: [
//               _buildMedicineTypeChip('pill', "حبوب", Icons.circle_outlined),
//               _buildMedicineTypeChip('syrup', "شراب", Icons.local_drink),
//               _buildMedicineTypeChip('injection', "إبرة", Icons.vaccines),
//               _buildMedicineTypeChip('drops', "قطرة", Icons.water_drop),
//               _buildMedicineTypeChip('ointment', "مرهم", Icons.sanitizer),
//               _buildMedicineTypeChip('spray', "بخاخ", Icons.air),
//             ],
//           ),
//         ),
//         AtharGap.lg,

//         // نظام الجدولة
//         DropdownButtonFormField<String>(
//           initialValue: _schedulingType,
//           items: const [
//             DropdownMenuItem(value: 'fixed', child: Text("أوقات ثابتة")),
//             DropdownMenuItem(value: 'interval', child: Text("تكرار بالساعات")),
//           ],
//           onChanged: (v) => setState(() => _schedulingType = v!),
//           decoration: InputDecoration(
//             labelText: "نمط الجدولة",
//             labelStyle: TextStyle(color: colors.textSecondary),
//             border: OutlineInputBorder(
//               borderRadius: AtharRadii.radiusMd,
//               borderSide: BorderSide(color: colors.border),
//             ),
//           ),
//         ),
//         AtharGap.md,

//         // ✅ FIX #3: إضافة Fixed Time Slots UI
//         if (_schedulingType == 'fixed')
//           _buildFixedTimeSelector()
//         else
//           _buildIntervalSelector(),

//         AtharGap.lg,
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 _doseAmountController,
//                 "الجرعة",
//                 TextInputType.number,
//               ),
//             ),
//             AtharGap.hSm,
//             Expanded(
//               child: _buildTextField(
//                 _doseUnitController,
//                 "الوحدة",
//                 TextInputType.text,
//               ),
//             ),
//           ],
//         ),
//         AtharGap.md,
//         _buildInstructionsDropdown(),
//         AtharGap.lg,
//         _buildMedicineDurationSection(),
//         AtharGap.lg,
//         _buildAutoRefillSection(),
//       ],
//     );
//   }

//   // ✅ FIX #3: إضافة دالة Fixed Time Selector
//   Widget _buildFixedTimeSelector() {
//     final colors = context.colors;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "حدد أوقات التناول:",
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: colors.textTertiary,
//             fontFamily: 'Tajawal',
//           ),
//         ),
//         AtharGap.sm,
//         Wrap(
//           spacing: 8.w,
//           runSpacing: 8.h,
//           children: [
//             ..._fixedTimes.map(
//               (time) => Chip(
//                 label: Text(time.format(context)),
//                 onDeleted: () => setState(() => _fixedTimes.remove(time)),
//                 backgroundColor: colors.info.withValues(alpha: 0.1),
//                 labelStyle: TextStyle(color: colors.info),
//                 deleteIconColor: colors.info,
//               ),
//             ),
//             ActionChip(
//               label: const Icon(Icons.add, size: 18),
//               backgroundColor: colors.primary.withValues(alpha: 0.1),
//               onPressed: () async {
//                 final t = await showTimePicker(
//                   context: context,
//                   initialTime: const TimeOfDay(hour: 8, minute: 0),
//                 );
//                 if (t != null && !_fixedTimes.contains(t)) {
//                   setState(() => _fixedTimes.add(t));
//                 }
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildIntervalSelector() {
//     final colors = context.colors;

//     return Row(
//       children: [
//         Icon(Icons.timelapse, color: colors.warning),
//         AtharGap.hMd,
//         Text(
//           "كل",
//           style: TextStyle(fontSize: 14.sp, fontFamily: 'Tajawal'),
//         ),
//         AtharGap.hMd,
//         DropdownButton<int>(
//           value: _intervalHours,
//           items: [4, 6, 8, 12, 24]
//               .map((h) => DropdownMenuItem(value: h, child: Text("$h ساعات")))
//               .toList(),
//           onChanged: (v) => setState(() => _intervalHours = v!),
//         ),
//       ],
//     );
//   }

//   Widget _buildMedicineDurationSection() {
//     final colors = context.colors;

//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 _quantityController,
//                 "المخزون الحالي",
//                 TextInputType.number,
//                 icon: Icons.inventory,
//               ),
//             ),
//             AtharGap.hMd,
//             Expanded(
//               child: DropdownButtonFormField<String>(
//                 initialValue: _durationMode,
//                 items: const [
//                   DropdownMenuItem(value: 'days', child: Text("بالأيام")),
//                   DropdownMenuItem(value: 'date', child: Text("بالتاريخ")),
//                 ],
//                 onChanged: (v) => setState(() => _durationMode = v!),
//                 decoration: InputDecoration(
//                   labelText: "مدة العلاج",
//                   border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         AtharGap.md,
//         if (_durationMode == 'days')
//           _buildTextField(
//             _durationController,
//             "عدد الأيام",
//             TextInputType.number,
//             icon: Icons.timer,
//           )
//         else
//           InkWell(
//             onTap: () async {
//               final picked = await showDatePicker(
//                 context: context,
//                 initialDate: DateTime.now(),
//                 firstDate: DateTime.now(),
//                 lastDate: DateTime(2030),
//               );
//               if (picked != null) setState(() => _selectedEndDate = picked);
//             },
//             child: Container(
//               padding: AtharSpacing.allMd,
//               decoration: BoxDecoration(
//                 border: Border.all(color: colors.border),
//                 borderRadius: AtharRadii.radiusMd,
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.calendar_month, color: colors.textSecondary),
//                   AtharGap.hSm,
//                   Text(
//                     _selectedEndDate == null
//                         ? "حدد تاريخ النهاية"
//                         : DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildAppointmentFields() {
//     return Column(
//       children: [
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: [
//               _buildApptTypeChip('checkup', "كشف", Icons.medical_services),
//               _buildApptTypeChip('lab', "تحليل", Icons.science),
//               _buildApptTypeChip('vaccine', "تطعيم", Icons.vaccines),
//               _buildApptTypeChip('procedure', "إجراء", Icons.healing),
//             ],
//           ),
//         ),
//         AtharGap.lg,
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 _doctorController,
//                 "الطبيب",
//                 TextInputType.text,
//                 icon: Icons.person_outline,
//               ),
//             ),
//             AtharGap.hMd,
//             Expanded(
//               child: _buildTextField(
//                 _locationController,
//                 "المكان/العيادة",
//                 TextInputType.text,
//                 icon: Icons.location_on_outlined,
//               ),
//             ),
//           ],
//         ),
//         AtharGap.md,
//         _buildTextField(
//           _notesController,
//           "ملاحظات الموعد",
//           TextInputType.multiline,
//           icon: Icons.notes,
//         ),
//       ],
//     );
//   }

//   Widget _buildReminderSection() {
//     return ReminderPickerWidget(
//       reminderTime: _reminderTime,
//       isEnabled: _isReminderEnabled,
//       onToggle: (val) => setState(() => _isReminderEnabled = val),
//       onTimeChanged: (newTime) => setState(() => _reminderTime = newTime),
//     );
//   }

//   // --- Logic Helpers ---

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label,
//     TextInputType type, {
//     IconData? icon,
//   }) {
//     return TextField(
//       controller: controller,
//       keyboardType: type,
//       maxLines: type == TextInputType.multiline ? 3 : 1,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: icon != null ? Icon(icon) : null,
//         border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
//       ),
//     );
//   }

//   Widget _buildMedicineTypeChip(String key, String label, IconData icon) {
//     final colors = context.colors;
//     bool isSelected = _medType == key;
//     return Padding(
//       padding: EdgeInsets.only(left: 8.w),
//       child: ChoiceChip(
//         label: Row(
//           children: [Icon(icon, size: 14), SizedBox(width: 4), Text(label)],
//         ),
//         selected: isSelected,
//         selectedColor: colors.primary,
//         labelStyle: TextStyle(
//           color: isSelected ? colors.surface : colors.textPrimary,
//           fontFamily: 'Tajawal',
//         ),
//         onSelected: (v) => setState(() => _medType = key),
//       ),
//     );
//   }

//   Widget _buildApptTypeChip(String key, String label, IconData icon) {
//     final colors = context.colors;
//     bool isSelected = _apptType == key;
//     return Padding(
//       padding: EdgeInsets.only(left: 8.w),
//       child: ChoiceChip(
//         label: Row(
//           children: [Icon(icon, size: 14), SizedBox(width: 4), Text(label)],
//         ),
//         selected: isSelected,
//         selectedColor: colors.primary,
//         labelStyle: TextStyle(
//           color: isSelected ? colors.surface : colors.textPrimary,
//           fontFamily: 'Tajawal',
//         ),
//         onSelected: (v) => setState(() => _apptType = key),
//       ),
//     );
//   }

//   Widget _buildInstructionsDropdown() {
//     final colors = context.colors;

//     return DropdownButtonFormField<String>(
//       initialValue: _instructions,
//       decoration: InputDecoration(
//         labelText: "تعليمات الاستخدام",
//         labelStyle: TextStyle(color: colors.textSecondary),
//         border: OutlineInputBorder(
//           borderRadius: AtharRadii.radiusMd,
//           borderSide: BorderSide(color: colors.border),
//         ),
//       ),
//       items: const [
//         DropdownMenuItem(value: 'before_meal', child: Text("قبل الأكل")),
//         DropdownMenuItem(value: 'after_meal', child: Text("بعد الأكل")),
//         DropdownMenuItem(value: 'with_meal', child: Text("مع الأكل")),
//         DropdownMenuItem(value: 'anytime', child: Text("في أي وقت")),
//       ],
//       onChanged: (v) => setState(() => _instructions = v!),
//     );
//   }

//   Widget _buildAutoRefillSection() {
//     final colors = context.colors;

//     return Container(
//       decoration: BoxDecoration(
//         color: colors.info.withValues(alpha: 0.1),
//         borderRadius: AtharRadii.radiusMd,
//       ),
//       child: ExpansionTile(
//         title: const Text(
//           "إعادة التعبئة الذكية",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         children: [
//           Padding(
//             padding: AtharSpacing.allMd,
//             child: Column(
//               children: [
//                 DropdownButtonFormField<String>(
//                   initialValue: _refillMode,
//                   items: const [
//                     DropdownMenuItem(value: 'off', child: Text("إيقاف")),
//                     DropdownMenuItem(
//                       value: 'quantity',
//                       child: Text("حسب الكمية"),
//                     ),
//                     // ✅ FIX #5: إضافة الخيار المفقود
//                     DropdownMenuItem(
//                       value: 'date',
//                       child: Text("قبل انتهاء الكورس"),
//                     ),
//                   ],
//                   onChanged: (v) => setState(() => _refillMode = v!),
//                   decoration: const InputDecoration(
//                     labelText: "وضع الطلب التلقائي",
//                   ),
//                 ),
//                 if (_refillMode != 'off') ...[
//                   AtharGap.md,
//                   _buildTextField(
//                     _thresholdController,
//                     _refillMode == 'quantity'
//                         ? "تنبيه عند نقص الكمية لـ"
//                         : "تنبيه قبل انتهاء الكورس بـ (أيام)",
//                     TextInputType.number,
//                   ),
//                   AtharGap.sm,
//                   DropdownButtonFormField<String>(
//                     initialValue: _refillAction,
//                     items: const [
//                       DropdownMenuItem(
//                         value: 'list',
//                         child: Text("إضافة للقائمة"),
//                       ),
//                       DropdownMenuItem(
//                         value: 'task',
//                         child: Text("إنشاء مهمة"),
//                       ),
//                       // ✅ FIX #5: إضافة الخيار المفقود
//                       DropdownMenuItem(
//                         value: 'both',
//                         child: Text("كلاهما (مهمة + قائمة)"),
//                       ),
//                     ],
//                     onChanged: (v) => setState(() => _refillAction = v!),
//                     decoration: const InputDecoration(labelText: "الإجراء"),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAssigneeTile() {
//     if (widget.targetSpaceId == null) return const SizedBox.shrink();
//     final colors = context.colors;

//     return ListTile(
//       leading: Icon(Icons.person_add_alt_1, color: colors.primary),
//       title: Text(_selectedAssigneeId == null ? "إسناد لعضو" : "تم الإسناد"),
//       onTap: () async {
//         final result = await showModalBottomSheet(
//           context: context,
//           builder: (_) => MemberSelectorSheet(spaceId: widget.targetSpaceId!),
//         );
//         if (result != null) setState(() => _selectedAssigneeId = result);
//       },
//     );
//   }

//   Widget _buildConflictWarning() {
//     return Container(
//       padding: AtharSpacing.allMd,
//       decoration: BoxDecoration(
//         color: _prayerConflict.color.withValues(alpha: 0.1),
//         borderRadius: AtharRadii.radiusMd,
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.warning, color: _prayerConflict.color),
//           AtharGap.hSm,
//           Expanded(
//             child: Text(
//               _prayerConflict.message,
//               style: TextStyle(color: _prayerConflict.color),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- Save Logic ---

//   void _handleSave() async {
//     if (!_formKey.currentState!.validate()) return;

//     // حفظ المراجع قبل أي async operations
//     final taskCubit = context.read<TaskCubit>();
//     final healthCubit = context.read<HealthCubit>();
//     final navigator = Navigator.of(context);

//     // ✅ FIX #4: إضافة فحص تعارضات المهام
//     if (_selectedType == EntityType.task) {
//       // فحص تعارض المهام أولاً
//       final taskConflict = await taskCubit.validateTimeConflict(
//         date: _selectedDate,
//         startTime: TimeOfDay.fromDateTime(_selectedDate),
//         durationMinutes: _selectedDuration,
//         excludeTaskId: widget.itemToEdit is TaskModel
//             ? (widget.itemToEdit as TaskModel).id
//             : null,
//       );

//       // ✅ FIX: فحص mounted بعد await
//       if (!mounted) return;

//       // تحديد التعارض النهائي
//       ConflictResult? finalConflict;
//       if (taskConflict.hasConflict) {
//         finalConflict = taskConflict;
//       } else if (_prayerConflict.hasConflict) {
//         finalConflict = _prayerConflict;
//       }

//       // إذا كان هناك تعارض، عرض الديالوج
//       if (finalConflict != null) {
//         final shouldProceed = await showDialog<bool>(
//           context: context,
//           builder: (ctx) => ConflictDialog(
//             conflict: finalConflict!,
//             onForceSave: () => Navigator.pop(ctx, true),
//             onCancel: () => Navigator.pop(ctx, false),
//             onDelay: () {
//               // استخدام الوقت المقترح
//               // ✅ capture القيمة في متغير محلي
//               final suggested = finalConflict!.suggestedTime;

//               if (suggested != null) {
//                 // ✅ الآن آمن - suggested is non-nullable DateTime
//                 setState(() => _selectedDate = suggested);
//                 _checkPrayerConflict();
//               }
//               Navigator.pop(ctx, true);
//             },
//           ),
//         );

//         if (shouldProceed != true) return;
//       }
//     }

//     if (!mounted) return;
//     setState(() => _isSaving = true);

//     final finalDateTime = DateTime(
//       _selectedDate.year,
//       _selectedDate.month,
//       _selectedDate.day,
//       _selectedTime.hour,
//       _selectedTime.minute,
//     );

//     // ✅ FIX #2: تحديد وقت التذكير الافتراضي حسب النوع
//     final validReminder = _isReminderEnabled
//         ? (_reminderTime ??
//               finalDateTime.subtract(
//                 _selectedType == EntityType.appointment
//                     ? const Duration(minutes: 30) // للمواعيد: 30 دقيقة
//                     : const Duration(minutes: 10), // للمهام: 10 دقائق
//               ))
//         : null;

//     try {
//       if (_selectedType == EntityType.task) {
//         // ✅ FIX #7: حذف معامل isReminderEnabled
//         await taskCubit.addTask(
//           title: _titleController.text,
//           date: finalDateTime,
//           isUrgent: _isUrgent,
//           isImportant: _isImportant,
//           category: _selectedCategory,
//           duration: _selectedDuration,
//           spaceId: widget.targetSpaceId,
//           moduleId: widget.targetModuleId,
//           assigneeId: _selectedAssigneeId,
//           reminderTime: validReminder,
//         );
//       } else if (_selectedType == EntityType.medicine) {
//         // ✅ بناء قائمة الأوقات الثابتة
//         final timesList = _fixedTimes
//             .map(
//               (t) =>
//                   "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}",
//             )
//             .toList();

//         final med = MedicineModel(
//           uuid: const Uuid().v4(),
//           name: _titleController.text,
//           moduleId: widget.targetModuleId ?? 'health',
//           type: _medType,
//           doseAmount: double.tryParse(_doseAmountController.text),
//           doseUnit: _doseUnitController.text.isNotEmpty
//               ? _doseUnitController.text
//               : null,
//           instructions: _instructions,
//           stockQuantity: double.tryParse(_quantityController.text),
//           autoRefillMode: _refillMode,
//           refillThreshold: double.tryParse(_thresholdController.text) ?? 5.0,
//           refillAction: _refillAction,
//           startDate: finalDateTime,
//           courseDurationDays: _durationMode == 'days'
//               ? int.tryParse(_durationController.text)
//               : null,
//           treatmentEndDate: _selectedEndDate,
//           schedulingType: _schedulingType,
//           fixedTimeSlots: _schedulingType == 'fixed' ? timesList : null,
//           intervalHours: _schedulingType == 'interval' ? _intervalHours : null,
//           isActive: true,
//         );
//         healthCubit.addMedicine(med);
//       } else {
//         final appt = AppointmentModel(
//           uuid: const Uuid().v4(),
//           moduleId: widget.targetModuleId ?? 'health',
//           title: _titleController.text,
//           appointmentDate: finalDateTime,
//           doctorName: _doctorController.text.isNotEmpty
//               ? _doctorController.text
//               : null,
//           locationName: _locationController.text.isNotEmpty
//               ? _locationController.text
//               : null,
//           type: _apptType,
//           notes: _notesController.text.isNotEmpty
//               ? _notesController.text
//               : null,
//           reminderEnabled: _isReminderEnabled,
//           reminderTime: validReminder,
//         );
//         healthCubit.addAppointment(appt);
//       }

//       if (mounted) navigator.pop();
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isSaving = false);
//         AtharSnackbar.error(context: context, message: 'حدث خطأ: $e');
//       }
//     }
//   }

//   Widget _buildSaveButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: AtharButton(
//         label: "حفظ العنصر",
//         onPressed: _isSaving ? null : _handleSave,
//         isLoading: _isSaving,
//       ),
//     );
//   }

//   // --- Pickers ---
//   Future<void> _pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//     );
//     if (date != null) {
//       setState(() => _selectedDate = date);
//       _checkPrayerConflict();
//     }
//   }

//   Future<void> _pickTime() async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//     );
//     if (time != null) {
//       setState(() => _selectedTime = time);
//       _checkPrayerConflict();
//     }
//   }

//   void _showAddCategoryDialog() {
//     final nameController = TextEditingController();
//     AtharDialog.show(
//       context: context,
//       title: "تصنيف جديد",
//       content: TextField(
//         controller: nameController,
//         decoration: const InputDecoration(hintText: "اسم التصنيف"),
//       ),
//       cancelLabel: "إلغاء",
//       confirmLabel: "إضافة",
//       onCancel: () => Navigator.pop(context),
//       onConfirm: () {
//         if (nameController.text.isNotEmpty) {
//           context.read<CategoryCubit>().addCategory(
//             nameController.text,
//             0xFF9C27B0,
//             Icons.bookmark.codePoint,
//           );
//           Navigator.pop(context);
//         }
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _notesController.dispose();
//     _doseAmountController.dispose();
//     _doseUnitController.dispose();
//     _quantityController.dispose();
//     _durationController.dispose();
//     _thresholdController.dispose();
//     _doctorController.dispose();
//     _locationController.dispose();
//     super.dispose();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';

// // Core & DI
// import 'package:athar/core/di/injection.dart';
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart';
// import 'package:athar/core/services/prayer_conflict_service.dart';

// // Models
// import 'package:athar/features/task/data/models/task_model.dart';
// import 'package:athar/features/health/data/models/medicine_model.dart';
// import 'package:athar/features/health/data/models/appointment_model.dart';
// import 'package:athar/features/settings/data/models/category_model.dart';
// import 'package:athar/features/settings/data/models/user_settings.dart';
// import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
// import 'package:athar/features/task/domain/models/conflict_result.dart';

// // Cubits
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
// import 'package:athar/features/prayer/presentation/cubit/prayer_cubit.dart';
// import 'package:athar/features/prayer/presentation/cubit/prayer_state.dart';

// // Components
// import 'package:athar/features/task/presentation/widgets/components/category_selector.dart';
// import 'package:athar/features/task/presentation/widgets/components/priority_selector.dart';
// import 'package:athar/features/task/presentation/widgets/components/date_time_picker.dart';
// import 'package:athar/features/task/presentation/widgets/components/duration_picker.dart';
// import 'package:athar/features/task/presentation/widgets/dialogs/conflict_dialog.dart';
// import 'package:athar/features/space/presentation/widgets/member_selector_sheet.dart';
// import 'package:athar/features/settings/domain/repositories/settings_repository.dart';

// enum EntityType { task, medicine, appointment }

// class UnifiedAddSheet extends StatefulWidget {
//   final EntityType initialType;
//   final String? targetSpaceId;
//   final String? targetModuleId;
//   final dynamic itemToEdit;

//   const UnifiedAddSheet({
//     super.key,
//     this.initialType = EntityType.task,
//     this.targetSpaceId,
//     this.targetModuleId,
//     this.itemToEdit,
//   });

//   @override
//   State<UnifiedAddSheet> createState() => _UnifiedAddSheetState();
// }

// class _UnifiedAddSheetState extends State<UnifiedAddSheet> {
//   final _formKey = GlobalKey<FormState>();
//   late EntityType _selectedType;

//   // Controllers
//   final _titleController = TextEditingController();
//   final _notesController = TextEditingController();
//   final _doseAmountController = TextEditingController();
//   final _doseUnitController = TextEditingController();
//   final _quantityController = TextEditingController();
//   final _durationController = TextEditingController();
//   final _thresholdController = TextEditingController(text: '5');
//   final _doctorController = TextEditingController();
//   final _locationController = TextEditingController();

//   // Common State
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   DateTime? _reminderTime;
//   bool _isReminderEnabled =
//       false; // ✅ FIX #1: افتراضياً false، سيتم تغييره في initState
//   bool _isSaving = false;
//   bool _isHijriMode = false;

//   // Task Specific
//   bool _isUrgent = false;
//   bool _isImportant = false;
//   int _selectedDuration = 30;
//   CategoryModel? _selectedCategory;
//   String? _selectedAssigneeId;
//   ConflictResult _prayerConflict = ConflictResult.none();

//   // Medicine Specific
//   String _medType = 'pill';
//   String _instructions = 'after_meal';
//   String _schedulingType = 'fixed';
//   String _durationMode = 'days';
//   String _refillMode = 'off';
//   String _refillAction = 'list';
//   final List<TimeOfDay> _fixedTimes = [];
//   int _intervalHours = 8;
//   DateTime? _selectedEndDate;

//   // Appointment Specific
//   String _apptType = 'checkup';

//   final _prayerConflictService = getIt<PrayerConflictService>();

//   @override
//   void initState() {
//     super.initState();
//     _selectedType = widget.initialType;

//     // ✅ FIX #1: تفعيل التذكير افتراضياً للمواعيد فقط
//     if (_selectedType == EntityType.appointment) {
//       _isReminderEnabled = true;
//     }

//     _loadInitialData();
//     _initFormIfEditing();
//   }

//   void _loadInitialData() async {
//     context.read<CategoryCubit>().loadCategories();
//     final settings = await getIt<SettingsRepository>().getSettings();
//     if (mounted) {
//       setState(() => _isHijriMode = settings.isHijriMode);
//       _checkPrayerConflict();
//     }
//   }

//   void _initFormIfEditing() {
//     if (widget.itemToEdit == null) return;
//     final item = widget.itemToEdit;

//     if (item is TaskModel) {
//       _selectedType = EntityType.task;
//       _titleController.text = item.title;
//       _selectedDate = item.date;
//       _isUrgent = item.isUrgent;
//       _isImportant = item.isImportant;
//       _selectedCategory = item.category.value;
//       _selectedDuration = item.durationMinutes;
//       _selectedAssigneeId = item.assigneeId;
//       if (item.reminderTime != null) {
//         _reminderTime = item.reminderTime;
//         _isReminderEnabled = true;
//       }
//     } else if (item is MedicineModel) {
//       _selectedType = EntityType.medicine;
//       _titleController.text = item.name;
//       _quantityController.text = item.stockQuantity?.toString() ?? '';
//       _doseAmountController.text = item.doseAmount?.toString() ?? '';
//       _doseUnitController.text = item.doseUnit ?? '';
//       _medType = item.type ?? 'pill';
//       _instructions = item.instructions ?? 'after_meal';
//       _refillMode = item.autoRefillMode;
//       _refillAction = item.refillAction;
//       _thresholdController.text = item.refillThreshold.toString();
//       _schedulingType = item.schedulingType;
//       if (item.courseDurationDays != null) {
//         _durationController.text = item.courseDurationDays.toString();
//         _durationMode = 'days';
//       }
//       if (item.intervalHours != null) _intervalHours = item.intervalHours!;

//       // ✅ استرجاع Fixed Time Slots
//       if (item.fixedTimeSlots != null && item.fixedTimeSlots!.isNotEmpty) {
//         _fixedTimes.clear();
//         for (var timeStr in item.fixedTimeSlots!) {
//           final parts = timeStr.split(':');
//           if (parts.length == 2) {
//             _fixedTimes.add(
//               TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
//             );
//           }
//         }
//       }
//     } else if (item is AppointmentModel) {
//       // ✅ FIX #6: إضافة دعم التعديل للمواعيد
//       _selectedType = EntityType.appointment;
//       _titleController.text = item.title;
//       _selectedDate = item.appointmentDate;
//       _selectedTime = TimeOfDay.fromDateTime(item.appointmentDate);
//       _apptType = item.type ?? 'checkup';
//       _doctorController.text = item.doctorName ?? '';
//       _locationController.text = item.locationName ?? '';
//       _notesController.text = item.notes ?? '';
//       // ✅ FIX ERROR #1: إزالة ?? true
//       _isReminderEnabled = item.reminderEnabled;

//       if (item.reminderTime != null) {
//         _reminderTime = item.reminderTime;
//       }
//       // if (item.reminderTime != null) {
//       //   _reminderTime = item.reminderTime;
//       //   _isReminderEnabled = item.reminderEnabled;
//       // } else {
//       //   _isReminderEnabled = true; // افتراضياً للمواعيد
//       // }
//     }
//   }

//   void _checkPrayerConflict() {
//     if (_selectedType != EntityType.task) return;

//     final prayerState = context.read<PrayerCubit>().state;
//     final settingsState = context.read<SettingsCubit>().state;

//     List<PrayerTime> prayers = [];
//     if (prayerState is PrayerLoaded) prayers = prayerState.allPrayers;

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
//     setState(() => _prayerConflict = result);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       padding: EdgeInsets.fromLTRB(
//         20.w,
//         20.h,
//         20.w,
//         MediaQuery.of(context).viewInsets.bottom + 20.h,
//       ),
//       child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildHandle(),
//               SizedBox(height: 16.h),
//               _buildTypeSelector(),
//               SizedBox(height: 24.h),
//               _buildCommonHeader(),
//               SizedBox(height: 20.h),
//               if (_selectedType == EntityType.task) _buildTaskFields(),
//               if (_selectedType == EntityType.medicine) _buildMedicineFields(),
//               if (_selectedType == EntityType.appointment)
//                 _buildAppointmentFields(),
//               SizedBox(height: 20.h),
//               _buildReminderSection(),
//               SizedBox(height: 24.h),
//               _buildSaveButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHandle() {
//     return Container(
//       width: 40.w,
//       height: 4.h,
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(2),
//       ),
//     );
//   }

//   Widget _buildTypeSelector() {
//     return SegmentedButton<EntityType>(
//       segments: const [
//         ButtonSegment(
//           value: EntityType.task,
//           label: Text("مهمة"),
//           icon: Icon(Icons.assignment_outlined),
//         ),
//         ButtonSegment(
//           value: EntityType.medicine,
//           label: Text("دواء"),
//           icon: Icon(Icons.medication_outlined),
//         ),
//         ButtonSegment(
//           value: EntityType.appointment,
//           label: Text("موعد"),
//           icon: Icon(Icons.calendar_today_outlined),
//         ),
//       ],
//       selected: {_selectedType},
//       onSelectionChanged: (Set<EntityType> val) => setState(() {
//         _selectedType = val.first;

//         // ✅ FIX #1: تحديث حالة التذكير عند تبديل النوع
//         if (_selectedType == EntityType.appointment) {
//           _isReminderEnabled = true;
//         } else {
//           _isReminderEnabled = false;
//         }

//         _checkPrayerConflict();
//       }),
//     );
//   }

//   Widget _buildCommonHeader() {
//     return Column(
//       children: [
//         TextFormField(
//           controller: _titleController,
//           decoration: InputDecoration(
//             hintText: _selectedType == EntityType.medicine
//                 ? "اسم الدواء"
//                 : _selectedType == EntityType.appointment
//                 ? "عنوان الموعد"
//                 : "عنوان المهمة",
//             filled: true,
//             fillColor: AppColors.background,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//               borderSide: BorderSide.none,
//             ),
//           ),
//           validator: (v) => v!.isEmpty ? "مطلوب" : null,
//         ),
//         SizedBox(height: 16.h),
//         DateTimePicker(
//           selectedDate: _selectedDate,
//           isHijriMode: _isHijriMode,
//           onDateTap: _pickDate,
//           onTimeTap: _pickTime,
//         ),
//         if (_selectedType == EntityType.task &&
//             _prayerConflict.hasConflict) ...[
//           SizedBox(height: 12.h),
//           _buildConflictWarning(),
//         ],
//       ],
//     );
//   }

//   Widget _buildTaskFields() {
//     return Column(
//       children: [
//         DurationPicker(
//           selectedDuration: _selectedDuration,
//           onDurationSelected: (val) {
//             setState(() => _selectedDuration = val);
//             _checkPrayerConflict();
//           },
//         ),
//         SizedBox(height: 16.h),
//         _buildAssigneeTile(),
//         PrioritySelector(
//           isUrgent: _isUrgent,
//           isImportant: _isImportant,
//           onUrgentChanged: (val) => setState(() => _isUrgent = val),
//           onImportantChanged: (val) => setState(() => _isImportant = val),
//         ),
//         SizedBox(height: 12.h),
//         CategorySelector(
//           selectedCategory: _selectedCategory,
//           onSelected: (cat) => setState(() => _selectedCategory = cat),
//           onAddPressed: _showAddCategoryDialog,
//         ),
//       ],
//     );
//   }

//   Widget _buildMedicineFields() {
//     return Column(
//       children: [
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: [
//               _buildMedicineTypeChip('pill', "حبوب", Icons.circle_outlined),
//               _buildMedicineTypeChip('syrup', "شراب", Icons.local_drink),
//               _buildMedicineTypeChip('injection', "إبرة", Icons.vaccines),
//               _buildMedicineTypeChip('drops', "قطرة", Icons.water_drop),
//               _buildMedicineTypeChip('ointment', "مرهم", Icons.sanitizer),
//               _buildMedicineTypeChip('spray', "بخاخ", Icons.air),
//             ],
//           ),
//         ),
//         SizedBox(height: 16.h),

//         // نظام الجدولة
//         DropdownButtonFormField<String>(
//           initialValue: _schedulingType,
//           items: const [
//             DropdownMenuItem(value: 'fixed', child: Text("أوقات ثابتة")),
//             DropdownMenuItem(value: 'interval', child: Text("تكرار بالساعات")),
//           ],
//           onChanged: (v) => setState(() => _schedulingType = v!),
//           decoration: InputDecoration(
//             labelText: "نمط الجدولة",
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//           ),
//         ),
//         SizedBox(height: 12.h),

//         // ✅ FIX #3: إضافة Fixed Time Slots UI
//         if (_schedulingType == 'fixed')
//           _buildFixedTimeSelector()
//         else
//           _buildIntervalSelector(),

//         SizedBox(height: 16.h),
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 _doseAmountController,
//                 "الجرعة",
//                 TextInputType.number,
//               ),
//             ),
//             SizedBox(width: 8.w),
//             Expanded(
//               child: _buildTextField(
//                 _doseUnitController,
//                 "الوحدة",
//                 TextInputType.text,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12.h),
//         _buildInstructionsDropdown(),
//         SizedBox(height: 16.h),
//         _buildMedicineDurationSection(),
//         SizedBox(height: 16.h),
//         _buildAutoRefillSection(),
//       ],
//     );
//   }

//   // ✅ FIX #3: إضافة دالة Fixed Time Selector
//   Widget _buildFixedTimeSelector() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "حدد أوقات التناول:",
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: Colors.grey,
//             fontFamily: 'Tajawal',
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Wrap(
//           spacing: 8.w,
//           runSpacing: 8.h,
//           children: [
//             ..._fixedTimes.map(
//               (time) => Chip(
//                 label: Text(time.format(context)),
//                 onDeleted: () => setState(() => _fixedTimes.remove(time)),
//                 backgroundColor: Colors.blue.shade50,
//                 labelStyle: const TextStyle(color: Colors.blue),
//                 deleteIconColor: Colors.blue,
//               ),
//             ),
//             ActionChip(
//               label: const Icon(Icons.add, size: 18),
//               backgroundColor: AppColors.primary.withValues(alpha: 0.1),
//               onPressed: () async {
//                 final t = await showTimePicker(
//                   context: context,
//                   initialTime: const TimeOfDay(hour: 8, minute: 0),
//                 );
//                 if (t != null && !_fixedTimes.contains(t)) {
//                   setState(() => _fixedTimes.add(t));
//                 }
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildIntervalSelector() {
//     return Row(
//       children: [
//         const Icon(Icons.timelapse, color: Colors.orange),
//         SizedBox(width: 12.w),
//         Text(
//           "كل",
//           style: TextStyle(fontSize: 14.sp, fontFamily: 'Tajawal'),
//         ),
//         SizedBox(width: 12.w),
//         DropdownButton<int>(
//           value: _intervalHours,
//           items: [4, 6, 8, 12, 24]
//               .map((h) => DropdownMenuItem(value: h, child: Text("$h ساعات")))
//               .toList(),
//           onChanged: (v) => setState(() => _intervalHours = v!),
//         ),
//       ],
//     );
//   }

//   Widget _buildMedicineDurationSection() {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 _quantityController,
//                 "المخزون الحالي",
//                 TextInputType.number,
//                 icon: Icons.inventory,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: DropdownButtonFormField<String>(
//                 initialValue: _durationMode,
//                 items: const [
//                   DropdownMenuItem(value: 'days', child: Text("بالأيام")),
//                   DropdownMenuItem(value: 'date', child: Text("بالتاريخ")),
//                 ],
//                 onChanged: (v) => setState(() => _durationMode = v!),
//                 decoration: InputDecoration(
//                   labelText: "مدة العلاج",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12.h),
//         if (_durationMode == 'days')
//           _buildTextField(
//             _durationController,
//             "عدد الأيام",
//             TextInputType.number,
//             icon: Icons.timer,
//           )
//         else
//           InkWell(
//             onTap: () async {
//               final picked = await showDatePicker(
//                 context: context,
//                 initialDate: DateTime.now(),
//                 firstDate: DateTime.now(),
//                 lastDate: DateTime(2030),
//               );
//               if (picked != null) setState(() => _selectedEndDate = picked);
//             },
//             child: Container(
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.calendar_month, color: Colors.grey),
//                   SizedBox(width: 8.w),
//                   Text(
//                     _selectedEndDate == null
//                         ? "حدد تاريخ النهاية"
//                         : DateFormat('yyyy-MM-dd').format(_selectedEndDate!),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildAppointmentFields() {
//     return Column(
//       children: [
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: [
//               _buildApptTypeChip('checkup', "كشف", Icons.medical_services),
//               _buildApptTypeChip('lab', "تحليل", Icons.science),
//               _buildApptTypeChip('vaccine', "تطعيم", Icons.vaccines),
//               _buildApptTypeChip('procedure', "إجراء", Icons.healing),
//             ],
//           ),
//         ),
//         SizedBox(height: 16.h),
//         Row(
//           children: [
//             Expanded(
//               child: _buildTextField(
//                 _doctorController,
//                 "الطبيب",
//                 TextInputType.text,
//                 icon: Icons.person_outline,
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: _buildTextField(
//                 _locationController,
//                 "المكان/العيادة",
//                 TextInputType.text,
//                 icon: Icons.location_on_outlined,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12.h),
//         _buildTextField(
//           _notesController,
//           "ملاحظات الموعد",
//           TextInputType.multiline,
//           icon: Icons.notes,
//         ),
//       ],
//     );
//   }

//   Widget _buildReminderSection() {
//     return ReminderPickerWidget(
//       reminderTime: _reminderTime,
//       isEnabled: _isReminderEnabled,
//       onToggle: (val) => setState(() => _isReminderEnabled = val),
//       onTimeChanged: (newTime) => setState(() => _reminderTime = newTime),
//     );
//   }

//   // --- Logic Helpers ---

//   Widget _buildTextField(
//     TextEditingController controller,
//     String label,
//     TextInputType type, {
//     IconData? icon,
//   }) {
//     return TextField(
//       controller: controller,
//       keyboardType: type,
//       maxLines: type == TextInputType.multiline ? 3 : 1,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: icon != null ? Icon(icon) : null,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
//       ),
//     );
//   }

//   Widget _buildMedicineTypeChip(String key, String label, IconData icon) {
//     bool isSelected = _medType == key;
//     return Padding(
//       padding: EdgeInsets.only(left: 8.w),
//       child: ChoiceChip(
//         label: Row(
//           children: [Icon(icon, size: 14), SizedBox(width: 4), Text(label)],
//         ),
//         selected: isSelected,
//         selectedColor: AppColors.primary,
//         labelStyle: TextStyle(
//           color: isSelected ? Colors.white : Colors.black,
//           fontFamily: 'Tajawal',
//         ),
//         onSelected: (v) => setState(() => _medType = key),
//       ),
//     );
//   }

//   Widget _buildApptTypeChip(String key, String label, IconData icon) {
//     bool isSelected = _apptType == key;
//     return Padding(
//       padding: EdgeInsets.only(left: 8.w),
//       child: ChoiceChip(
//         label: Row(
//           children: [Icon(icon, size: 14), SizedBox(width: 4), Text(label)],
//         ),
//         selected: isSelected,
//         selectedColor: AppColors.primary,
//         labelStyle: TextStyle(
//           color: isSelected ? Colors.white : Colors.black,
//           fontFamily: 'Tajawal',
//         ),
//         onSelected: (v) => setState(() => _apptType = key),
//       ),
//     );
//   }

//   Widget _buildInstructionsDropdown() {
//     return DropdownButtonFormField<String>(
//       initialValue: _instructions,
//       decoration: InputDecoration(
//         labelText: "تعليمات الاستخدام",
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
//       ),
//       items: const [
//         DropdownMenuItem(value: 'before_meal', child: Text("قبل الأكل")),
//         DropdownMenuItem(value: 'after_meal', child: Text("بعد الأكل")),
//         DropdownMenuItem(value: 'with_meal', child: Text("مع الأكل")),
//         DropdownMenuItem(value: 'anytime', child: Text("في أي وقت")),
//       ],
//       onChanged: (v) => setState(() => _instructions = v!),
//     );
//   }

//   Widget _buildAutoRefillSection() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.blue[50],
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: ExpansionTile(
//         title: const Text(
//           "إعادة التعبئة الذكية",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         children: [
//           Padding(
//             padding: EdgeInsets.all(12.w),
//             child: Column(
//               children: [
//                 DropdownButtonFormField<String>(
//                   initialValue: _refillMode,
//                   items: const [
//                     DropdownMenuItem(value: 'off', child: Text("إيقاف")),
//                     DropdownMenuItem(
//                       value: 'quantity',
//                       child: Text("حسب الكمية"),
//                     ),
//                     // ✅ FIX #5: إضافة الخيار المفقود
//                     DropdownMenuItem(
//                       value: 'date',
//                       child: Text("قبل انتهاء الكورس"),
//                     ),
//                   ],
//                   onChanged: (v) => setState(() => _refillMode = v!),
//                   decoration: const InputDecoration(
//                     labelText: "وضع الطلب التلقائي",
//                   ),
//                 ),
//                 if (_refillMode != 'off') ...[
//                   SizedBox(height: 12.h),
//                   _buildTextField(
//                     _thresholdController,
//                     _refillMode == 'quantity'
//                         ? "تنبيه عند نقص الكمية لـ"
//                         : "تنبيه قبل انتهاء الكورس بـ (أيام)",
//                     TextInputType.number,
//                   ),
//                   SizedBox(height: 8.h),
//                   DropdownButtonFormField<String>(
//                     initialValue: _refillAction,
//                     items: const [
//                       DropdownMenuItem(
//                         value: 'list',
//                         child: Text("إضافة للقائمة"),
//                       ),
//                       DropdownMenuItem(
//                         value: 'task',
//                         child: Text("إنشاء مهمة"),
//                       ),
//                       // ✅ FIX #5: إضافة الخيار المفقود
//                       DropdownMenuItem(
//                         value: 'both',
//                         child: Text("كلاهما (مهمة + قائمة)"),
//                       ),
//                     ],
//                     onChanged: (v) => setState(() => _refillAction = v!),
//                     decoration: const InputDecoration(labelText: "الإجراء"),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAssigneeTile() {
//     if (widget.targetSpaceId == null) return const SizedBox.shrink();
//     return ListTile(
//       leading: const Icon(Icons.person_add_alt_1, color: Colors.purple),
//       title: Text(_selectedAssigneeId == null ? "إسناد لعضو" : "تم الإسناد"),
//       onTap: () async {
//         final result = await showModalBottomSheet(
//           context: context,
//           builder: (_) => MemberSelectorSheet(spaceId: widget.targetSpaceId!),
//         );
//         if (result != null) setState(() => _selectedAssigneeId = result);
//       },
//     );
//   }

//   Widget _buildConflictWarning() {
//     return Container(
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: _prayerConflict.color.withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.warning, color: _prayerConflict.color),
//           SizedBox(width: 8.w),
//           Expanded(
//             child: Text(
//               _prayerConflict.message,
//               style: TextStyle(color: _prayerConflict.color),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- Save Logic ---

//   void _handleSave() async {
//     if (!_formKey.currentState!.validate()) return;

//     // حفظ المراجع قبل أي async operations
//     final taskCubit = context.read<TaskCubit>();
//     final healthCubit = context.read<HealthCubit>();
//     final navigator = Navigator.of(context);

//     // ✅ FIX #4: إضافة فحص تعارضات المهام
//     if (_selectedType == EntityType.task) {
//       // فحص تعارض المهام أولاً
//       final taskConflict = await taskCubit.validateTimeConflict(
//         date: _selectedDate,
//         startTime: TimeOfDay.fromDateTime(_selectedDate),
//         durationMinutes: _selectedDuration,
//         excludeTaskId: widget.itemToEdit is TaskModel
//             ? (widget.itemToEdit as TaskModel).id
//             : null,
//       );

//       // ✅ FIX: فحص mounted بعد await
//       if (!mounted) return;

//       // تحديد التعارض النهائي
//       ConflictResult? finalConflict;
//       if (taskConflict.hasConflict) {
//         finalConflict = taskConflict;
//       } else if (_prayerConflict.hasConflict) {
//         finalConflict = _prayerConflict;
//       }

//       // إذا كان هناك تعارض، عرض الديالوج
//       if (finalConflict != null) {
//         final shouldProceed = await showDialog<bool>(
//           context: context,
//           builder: (ctx) => ConflictDialog(
//             conflict: finalConflict!,
//             onForceSave: () => Navigator.pop(ctx, true),
//             onCancel: () => Navigator.pop(ctx, false),
//             onDelay: () {
//               // استخدام الوقت المقترح
//               // ✅ capture القيمة في متغير محلي
//               final suggested = finalConflict!.suggestedTime;

//               if (suggested != null) {
//                 // ✅ الآن آمن - suggested is non-nullable DateTime
//                 setState(() => _selectedDate = suggested);
//                 _checkPrayerConflict();
//               }
//               Navigator.pop(ctx, true);
//             },
//           ),
//         );

//         if (shouldProceed != true) return;
//       }
//     }

//     if (!mounted) return;
//     setState(() => _isSaving = true);

//     final finalDateTime = DateTime(
//       _selectedDate.year,
//       _selectedDate.month,
//       _selectedDate.day,
//       _selectedTime.hour,
//       _selectedTime.minute,
//     );

//     // ✅ FIX #2: تحديد وقت التذكير الافتراضي حسب النوع
//     final validReminder = _isReminderEnabled
//         ? (_reminderTime ??
//               finalDateTime.subtract(
//                 _selectedType == EntityType.appointment
//                     ? const Duration(minutes: 30) // للمواعيد: 30 دقيقة
//                     : const Duration(minutes: 10), // للمهام: 10 دقائق
//               ))
//         : null;

//     try {
//       if (_selectedType == EntityType.task) {
//         // ✅ FIX #7: حذف معامل isReminderEnabled
//         await taskCubit.addTask(
//           title: _titleController.text,
//           date: finalDateTime,
//           isUrgent: _isUrgent,
//           isImportant: _isImportant,
//           category: _selectedCategory,
//           duration: _selectedDuration,
//           spaceId: widget.targetSpaceId,
//           moduleId: widget.targetModuleId,
//           assigneeId: _selectedAssigneeId,
//           reminderTime: validReminder,
//         );
//       } else if (_selectedType == EntityType.medicine) {
//         // ✅ بناء قائمة الأوقات الثابتة
//         final timesList = _fixedTimes
//             .map(
//               (t) =>
//                   "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}",
//             )
//             .toList();

//         final med = MedicineModel(
//           uuid: const Uuid().v4(),
//           name: _titleController.text,
//           moduleId: widget.targetModuleId ?? 'health',
//           type: _medType,
//           doseAmount: double.tryParse(_doseAmountController.text),
//           doseUnit: _doseUnitController.text.isNotEmpty
//               ? _doseUnitController.text
//               : null,
//           instructions: _instructions,
//           stockQuantity: double.tryParse(_quantityController.text),
//           autoRefillMode: _refillMode,
//           refillThreshold: double.tryParse(_thresholdController.text) ?? 5.0,
//           refillAction: _refillAction,
//           startDate: finalDateTime,
//           courseDurationDays: _durationMode == 'days'
//               ? int.tryParse(_durationController.text)
//               : null,
//           treatmentEndDate: _selectedEndDate,
//           schedulingType: _schedulingType,
//           fixedTimeSlots: _schedulingType == 'fixed' ? timesList : null,
//           intervalHours: _schedulingType == 'interval' ? _intervalHours : null,
//           isActive: true,
//         );
//         healthCubit.addMedicine(med);
//       } else {
//         final appt = AppointmentModel(
//           uuid: const Uuid().v4(),
//           moduleId: widget.targetModuleId ?? 'health',
//           title: _titleController.text,
//           appointmentDate: finalDateTime,
//           doctorName: _doctorController.text.isNotEmpty
//               ? _doctorController.text
//               : null,
//           locationName: _locationController.text.isNotEmpty
//               ? _locationController.text
//               : null,
//           type: _apptType,
//           notes: _notesController.text.isNotEmpty
//               ? _notesController.text
//               : null,
//           reminderEnabled: _isReminderEnabled,
//           reminderTime: validReminder,
//         );
//         healthCubit.addAppointment(appt);
//       }

//       if (mounted) navigator.pop();
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isSaving = false);
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
//       }
//     }
//   }

//   Widget _buildSaveButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isSaving ? null : _handleSave,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           padding: EdgeInsets.symmetric(vertical: 14.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//         ),
//         child: _isSaving
//             ? const CircularProgressIndicator(color: Colors.white)
//             : const Text(
//                 "حفظ العنصر",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//       ),
//     );
//   }

//   // --- Pickers ---
//   Future<void> _pickDate() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//     );
//     if (date != null) {
//       setState(() => _selectedDate = date);
//       _checkPrayerConflict();
//     }
//   }

//   Future<void> _pickTime() async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//     );
//     if (time != null) {
//       setState(() => _selectedTime = time);
//       _checkPrayerConflict();
//     }
//   }

//   void _showAddCategoryDialog() {
//     final nameController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("تصنيف جديد"),
//         content: TextField(
//           controller: nameController,
//           decoration: const InputDecoration(hintText: "اسم التصنيف"),
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
//                   0xFF9C27B0,
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

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _notesController.dispose();
//     _doseAmountController.dispose();
//     _doseUnitController.dispose();
//     _quantityController.dispose();
//     _durationController.dispose();
//     _thresholdController.dispose();
//     _doctorController.dispose();
//     _locationController.dispose();
//     super.dispose();
//   }
// }
