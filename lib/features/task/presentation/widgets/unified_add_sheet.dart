//————-————— code start ————————-
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Core & DI
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/molecules/sections/athar_accordion_section.dart';
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
import 'package:athar/features/task/presentation/cubit/task_state.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import 'package:athar/features/health/presentation/cubit/health_state.dart';
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
  bool _isReminderEnabled = false;
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

  // Accordion keys — recreated on type change to reset Option-A state
  late GlobalKey<AtharAccordionSectionState> _whatKey;
  late GlobalKey<AtharAccordionSectionState> _section2Key;
  late GlobalKey<AtharAccordionSectionState> _section3Key;

  void _resetAccordionKeys() {
    _whatKey = GlobalKey<AtharAccordionSectionState>();
    _section2Key = GlobalKey<AtharAccordionSectionState>();
    _section3Key = GlobalKey<AtharAccordionSectionState>();
  }

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _resetAccordionKeys();
    if (_selectedType == EntityType.appointment) _isReminderEnabled = true;
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
      if (item.fixedTimeSlots != null && item.fixedTimeSlots!.isNotEmpty) {
        _fixedTimes.clear();
        for (var s in item.fixedTimeSlots!) {
          final parts = s.split(':');
          if (parts.length == 2) {
            _fixedTimes.add(
              TimeOfDay(
                  hour: int.parse(parts[0]), minute: int.parse(parts[1])),
            );
          }
        }
      }
    } else if (item is AppointmentModel) {
      _selectedType = EntityType.appointment;
      _titleController.text = item.title;
      _selectedDate = item.appointmentDate;
      _selectedTime = TimeOfDay.fromDateTime(item.appointmentDate);
      _apptType = item.type ?? 'checkup';
      _doctorController.text = item.doctorName ?? '';
      _locationController.text = item.locationName ?? '';
      _notesController.text = item.notes ?? '';
      _isReminderEnabled = item.reminderEnabled;
      if (item.reminderTime != null) _reminderTime = item.reminderTime;
    }
  }

  void _checkPrayerConflict() {
    if (_selectedType != EntityType.task) return;
    final prayerState = context.read<PrayerCubit>().state;
    final settingsState = context.read<SettingsCubit>().state;

    List<PrayerTime> prayers = [];
    if (prayerState is PrayerLoaded) prayers = prayerState.allPrayers;
    UserSettings currentSettings = UserSettings();
    if (settingsState is SettingsLoaded) currentSettings = settingsState.settings;

    final result = _prayerConflictService.checkConflict(
      taskStartTime: _selectedDate,
      taskDuration: Duration(minutes: _selectedDuration),
      prayers: prayers,
      settings: currentSettings,
    );
    setState(() => _prayerConflict = result);
  }

  // ─── Summary strings ─────────────────────────────────────────────────────

  String get _whatSummary {
    final t = _titleController.text.trim();
    if (_selectedType == EntityType.medicine && t.isNotEmpty) {
      final dose = _doseAmountController.text.trim();
      final unit = _doseUnitController.text.trim();
      return dose.isNotEmpty ? '$t · $dose $unit' : t;
    }
    if (_selectedType == EntityType.appointment && t.isNotEmpty) {
      return '$t · ${_apptTypeLabel(_selectedType)}';
    }
    return t;
  }

  String _apptTypeLabel(EntityType _) {
    // appointment type labels - inline since they're compound keys in l10n
    switch (_apptType) {
      case 'checkup': return 'فحص';
      case 'lab': return 'تحليل';
      case 'vaccine': return 'لقاح';
      case 'procedure': return 'إجراء';
      default: return '';
    }
  }

  String get _section2Summary {
    switch (_selectedType) {
      case EntityType.task:
      case EntityType.appointment:
        return '${DateFormat('EEE، d MMM', 'ar').format(_selectedDate)} · ${_selectedTime.format(context)}';
      case EntityType.medicine:
        if (_schedulingType == 'fixed') {
          return '${_fixedTimes.length} مواعيد ثابتة';
        }
        return 'كل $_intervalHours ساعة';
    }
  }

  String get _section3Summary {
    switch (_selectedType) {
      case EntityType.task:
        final parts = [
          if (_selectedCategory != null) _selectedCategory!.name,
          if (_isUrgent) 'عاجل',
          if (_isImportant) 'مهم',
        ];
        return parts.join(' · ');
      case EntityType.medicine:
        final qty = _quantityController.text.trim();
        final dur = _durationMode == 'days' && _durationController.text.isNotEmpty
            ? '${_durationController.text} يوم'
            : _selectedEndDate != null
                ? DateFormat('d/M').format(_selectedEndDate!)
                : '';
        return [if (qty.isNotEmpty) '$qty وحدة', if (dur.isNotEmpty) dur].join(' · ');
      case EntityType.appointment:
        return _isReminderEnabled ? 'تذكير مفعّل' : 'لا تذكير';
    }
  }

  String get _sheetTitle {
    final l10n = AppLocalizations.of(context);
    switch (_selectedType) {
      case EntityType.task: return l10n.task;
      case EntityType.medicine: return l10n.medicine;
      case EntityType.appointment: return l10n.appointment;
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AtharBottomSheet(
      title: _sheetTitle,
      showDragHandle: true,
      actions: [
        AtharButton(
          label: l10n.saveItem,
          onPressed: _isSaving ? null : _handleSave,
          isLoading: _isSaving,
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector stays at top of scrollable body
            _buildTypeSelector(l10n),
            AtharGap.lg,
            // ── WHAT (first-open, required) ──────────────────────────────
            AtharAccordionSection(
              key: _whatKey,
              icon: Icons.edit_outlined,
              title: _whatSectionTitle(l10n),
              summaryValue: _whatSummary,
              isRequired: true,
              initiallyExpanded: true,
              child: _buildWhatBody(l10n),
            ),
            // ── SECTION 2 ────────────────────────────────────────────────
            AtharAccordionSection(
              key: _section2Key,
              icon: _section2Icon,
              title: _section2Title(l10n),
              summaryValue: _section2Summary,
              initiallyExpanded: false,
              child: _buildSection2Body(l10n),
            ),
            // ── SECTION 3 ────────────────────────────────────────────────
            AtharAccordionSection(
              key: _section3Key,
              icon: _section3Icon,
              title: _section3Title(l10n),
              summaryValue: _section3Summary,
              initiallyExpanded: false,
              child: _buildSection3Body(l10n),
            ),
            AtharGap.sm,
          ],
        ),
      ),
    );
  }

  // ─── Section metadata ─────────────────────────────────────────────────────

  String _whatSectionTitle(AppLocalizations l10n) {
    switch (_selectedType) {
      case EntityType.task: return l10n.whatToAccomplish;
      case EntityType.medicine: return l10n.medicineName;
      case EntityType.appointment: return l10n.appointmentTitle;
    }
  }

  String _section2Title(AppLocalizations l10n) {
    switch (_selectedType) {
      case EntityType.task: return l10n.whenSection;
      case EntityType.medicine: return l10n.schedulePattern;
      case EntityType.appointment: return l10n.whenAndWhere;
    }
  }

  String _section3Title(AppLocalizations l10n) {
    switch (_selectedType) {
      case EntityType.task: return l10n.detailsSection;
      case EntityType.medicine: return l10n.medicineTreatmentDuration;
      case EntityType.appointment: return l10n.reminder;
    }
  }

  IconData get _section2Icon {
    switch (_selectedType) {
      case EntityType.task: return Icons.schedule_outlined;
      case EntityType.medicine: return Icons.timelapse_outlined;
      case EntityType.appointment: return Icons.event_outlined;
    }
  }

  IconData get _section3Icon {
    switch (_selectedType) {
      case EntityType.task: return Icons.tune_outlined;
      case EntityType.medicine: return Icons.inventory_2_outlined;
      case EntityType.appointment: return Icons.notifications_outlined;
    }
  }

  // ─── Type selector ────────────────────────────────────────────────────────

  Widget _buildTypeSelector(AppLocalizations l10n) {
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
        _isReminderEnabled = _selectedType == EntityType.appointment;
        _resetAccordionKeys(); // Option-A reset on type change
        _checkPrayerConflict();
      }),
    );
  }

  // ─── WHAT body ────────────────────────────────────────────────────────────

  Widget _buildWhatBody(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _titleController,
          onChanged: (_) => setState(() {}),
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
        if (_selectedType == EntityType.medicine) ...[
          AtharGap.md,
          _buildMedicineTypeChips(colorScheme, l10n),
          AtharGap.md,
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                    _doseAmountController, l10n.dosage, TextInputType.number),
              ),
              AtharGap.hSm,
              Expanded(
                child: _buildTextField(
                    _doseUnitController, l10n.unit, TextInputType.text),
              ),
            ],
          ),
          AtharGap.md,
          _buildInstructionsDropdown(colorScheme, l10n),
        ],
        if (_selectedType == EntityType.appointment) ...[
          AtharGap.md,
          _buildApptTypeChips(colorScheme, l10n),
        ],
      ],
    );
  }

  // ─── Section 2 body ───────────────────────────────────────────────────────

  Widget _buildSection2Body(AppLocalizations l10n) {
    switch (_selectedType) {
      case EntityType.task:
        return _buildTaskWhenBody(l10n);
      case EntityType.medicine:
        return _buildMedicineScheduleBody(l10n);
      case EntityType.appointment:
        return _buildApptWhenWhereBody(l10n);
    }
  }

  Widget _buildTaskWhenBody(AppLocalizations l10n) {
    return Column(
      children: [
        DateTimePicker(
          selectedDate: _selectedDate,
          isHijriMode: _isHijriMode,
          onDateTap: _pickDate,
          onTimeTap: _pickTime,
        ),
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
        RecurrencePicker(
          initialPattern: _selectedRecurrence,
          onChanged: (p) => setState(() => _selectedRecurrence = p),
        ),
      ],
    );
  }

  Widget _buildMedicineScheduleBody(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: _schedulingType,
          items: [
            DropdownMenuItem(value: 'fixed', child: Text(l10n.fixedTimes)),
            DropdownMenuItem(
                value: 'interval', child: Text(l10n.repeatByHours)),
          ],
          onChanged: (v) => setState(() => _schedulingType = v!),
          decoration: InputDecoration(
            labelText: l10n.schedulePattern,
            labelStyle: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontFamily: AtharTypography.fontFamily,
              fontFamilyFallback: AtharTypography.fontFallback,
            ),
            border:
                OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
          ),
        ),
        AtharGap.md,
        if (_schedulingType == 'fixed')
          _buildFixedTimeSelector(l10n)
        else
          _buildIntervalSelector(l10n),
      ],
    );
  }

  Widget _buildApptWhenWhereBody(AppLocalizations l10n) {
    return Column(
      children: [
        DateTimePicker(
          selectedDate: _selectedDate,
          isHijriMode: _isHijriMode,
          onDateTap: _pickDate,
          onTimeTap: _pickTime,
        ),
        AtharGap.md,
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                  _doctorController, l10n.doctor, TextInputType.text,
                  icon: Icons.person_outline),
            ),
            AtharGap.hMd,
            Expanded(
              child: _buildTextField(
                  _locationController, l10n.locationClinic,
                  TextInputType.text,
                  icon: Icons.location_on_outlined),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Section 3 body ───────────────────────────────────────────────────────

  Widget _buildSection3Body(AppLocalizations l10n) {
    switch (_selectedType) {
      case EntityType.task:
        return _buildTaskDetailsBody(l10n);
      case EntityType.medicine:
        return _buildMedicineSupplyBody(l10n);
      case EntityType.appointment:
        return _buildApptReminderBody(l10n);
    }
  }

  Widget _buildTaskDetailsBody(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAssigneeTile(l10n),
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

  Widget _buildMedicineSupplyBody(AppLocalizations l10n) {
    return Column(
      children: [
        _buildMedicineDurationSection(l10n),
        AtharGap.md,
        _buildAutoRefillSection(l10n),
      ],
    );
  }

  Widget _buildApptReminderBody(AppLocalizations l10n) {
    return Column(
      children: [
        ReminderPickerWidget(
          reminderTime: _reminderTime,
          isEnabled: _isReminderEnabled,
          onToggle: (v) => setState(() => _isReminderEnabled = v),
          onTimeChanged: (t) => setState(() => _reminderTime = t),
        ),
        AtharGap.md,
        _buildTextField(_notesController, l10n.appointmentNotes,
            TextInputType.multiline,
            icon: Icons.notes),
      ],
    );
  }

  // ─── Medicine helpers ─────────────────────────────────────────────────────

  Widget _buildMedicineTypeChips(
      ColorScheme colorScheme, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildMedicineTypeChip(colorScheme, l10n, 'pill', l10n.pills,
              Icons.circle_outlined),
          _buildMedicineTypeChip(colorScheme, l10n, 'syrup', l10n.syrup,
              Icons.local_drink),
          _buildMedicineTypeChip(colorScheme, l10n, 'injection',
              l10n.injection, Icons.vaccines),
          _buildMedicineTypeChip(
              colorScheme, l10n, 'drops', l10n.drops, Icons.water_drop),
          _buildMedicineTypeChip(colorScheme, l10n, 'ointment', l10n.ointment,
              Icons.sanitizer),
          _buildMedicineTypeChip(
              colorScheme, l10n, 'spray', l10n.spray, Icons.air),
        ],
      ),
    );
  }

  Widget _buildMedicineTypeChip(ColorScheme cs, AppLocalizations l10n,
      String key, String label, IconData icon) {
    final isSelected = _medType == key;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 8.w),
      child: ChoiceChip(
        label: Row(children: [
          Icon(icon, size: 14),
          AtharGap.hXxs,
          Text(label),
        ]),
        selected: isSelected,
        selectedColor: cs.primary,
        labelStyle: TextStyle(
          color: isSelected ? cs.surface : cs.onSurface,
          fontFamily: AtharTypography.fontFamily,
          fontFamilyFallback: AtharTypography.fontFallback,
        ),
        onSelected: (_) => setState(() => _medType = key),
      ),
    );
  }

  Widget _buildApptTypeChips(
      ColorScheme colorScheme, AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildApptTypeChip(
              colorScheme, l10n, 'checkup', l10n.checkup, Icons.medical_services),
          _buildApptTypeChip(
              colorScheme, l10n, 'lab', l10n.labTest, Icons.science),
          _buildApptTypeChip(
              colorScheme, l10n, 'vaccine', l10n.vaccine, Icons.vaccines),
          _buildApptTypeChip(
              colorScheme, l10n, 'procedure', l10n.procedure, Icons.healing),
        ],
      ),
    );
  }

  Widget _buildApptTypeChip(ColorScheme cs, AppLocalizations l10n,
      String key, String label, IconData icon) {
    final isSelected = _apptType == key;
    return Padding(
      padding: EdgeInsetsDirectional.only(start: 8.w),
      child: ChoiceChip(
        label: Row(children: [
          Icon(icon, size: 14),
          AtharGap.hXxs,
          Text(label),
        ]),
        selected: isSelected,
        selectedColor: cs.primary,
        labelStyle: TextStyle(
          color: isSelected ? cs.surface : cs.onSurface,
          fontFamily: AtharTypography.fontFamily,
          fontFamilyFallback: AtharTypography.fontFallback,
        ),
        onSelected: (_) => setState(() {
          _apptType = key;
        }),
      ),
    );
  }

  Widget _buildInstructionsDropdown(
      ColorScheme colorScheme, AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      initialValue: _instructions,
      decoration: InputDecoration(
        labelText: l10n.usageInstructions,
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontFamily: AtharTypography.fontFamily,
          fontFamilyFallback: AtharTypography.fontFallback,
        ),
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

  Widget _buildFixedTimeSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectIntakeTimes,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.outline,
            fontFamily: AtharTypography.fontFamily,
            fontFamilyFallback: AtharTypography.fontFallback,
          ),
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
                backgroundColor: context.colors.info.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: context.colors.info),
                deleteIconColor: context.colors.info,
              ),
            ),
            ActionChip(
              label: const Icon(Icons.add, size: 18),
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.1),
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

  Widget _buildIntervalSelector(AppLocalizations l10n) {
    return Row(
      children: [
        Icon(Icons.timelapse, color: context.colors.warning),
        AtharGap.hMd,
        Text(l10n.every,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: AtharTypography.fontFamily,
              fontFamilyFallback: AtharTypography.fontFallback,
            )),
        AtharGap.hMd,
        DropdownButton<int>(
          value: _intervalHours,
          items: [4, 6, 8, 12, 24]
              .map((h) => DropdownMenuItem(
                  value: h, child: Text(l10n.hoursCount(h))))
              .toList(),
          onChanged: (v) => setState(() => _intervalHours = v!),
        ),
      ],
    );
  }

  Widget _buildMedicineDurationSection(AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                  _quantityController, l10n.currentStock,
                  TextInputType.number,
                  icon: Icons.inventory),
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
          _buildTextField(_durationController, l10n.daysCount,
              TextInputType.number,
              icon: Icons.timer)
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
                  Icon(Icons.calendar_month,
                      color: colorScheme.onSurfaceVariant),
                  AtharGap.hSm,
                  Text(_selectedEndDate == null
                      ? l10n.selectEndDate
                      : DateFormat('yyyy-MM-dd').format(_selectedEndDate!)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAutoRefillSection(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.info.withValues(alpha: 0.1),
        borderRadius: AtharRadii.radiusMd,
      ),
      child: ExpansionTile(
        title: Text(l10n.smartRefill,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: AtharTypography.fontFamily,
              fontFamilyFallback: AtharTypography.fontFallback,
            )),
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
                        value: 'quantity', child: Text(l10n.byQuantity)),
                    DropdownMenuItem(
                        value: 'date', child: Text(l10n.beforeCourseEnd)),
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
                          value: 'list', child: Text(l10n.addToList)),
                      DropdownMenuItem(
                          value: 'task', child: Text(l10n.createTask)),
                      DropdownMenuItem(
                          value: 'both', child: Text(l10n.bothTaskAndList)),
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

  // ─── Shared helper widgets ────────────────────────────────────────────────

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

  Widget _buildAssigneeTile(AppLocalizations l10n) {
    if (widget.targetSpaceId == null) return const SizedBox.shrink();
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(Icons.person_add_alt_1, color: colorScheme.primary),
      title: Text(
        _selectedAssigneeId == null ? l10n.assignToMember : l10n.assigned,
      ),
      onTap: () async {
        final result = await showModalBottomSheet(
          context: context,
          builder: (_) =>
              MemberSelectorSheet(spaceId: widget.targetSpaceId!),
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
              style: TextStyle(
                color: _prayerConflict.color,
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  void _handleSave() async {
    // Guard #1: ensure What is expanded so errors are visible
    if (!_formKey.currentState!.validate()) {
      _whatKey.currentState?.expand();
      return;
    }

    final taskCubit = context.read<TaskCubit>();
    final healthCubit = context.read<HealthCubit>();
    final navigator = Navigator.of(context);

    if (_selectedType == EntityType.task) {
      final taskConflict = await taskCubit.validateTimeConflict(
        date: _selectedDate,
        startTime: TimeOfDay.fromDateTime(_selectedDate),
        durationMinutes: _selectedDuration,
        excludeTaskId: widget.itemToEdit is TaskModel
            ? (widget.itemToEdit as TaskModel).id
            : null,
      );
      if (!mounted) return;

      ConflictResult? finalConflict;
      if (taskConflict.hasConflict) {
        finalConflict = taskConflict;
      } else if (_prayerConflict.hasConflict) {
        finalConflict = _prayerConflict;
      }

      if (finalConflict != null) {
        final shouldProceed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => ConflictDialog(
            conflict: finalConflict!,
            onForceSave: () => Navigator.pop(ctx, true),
            onCancel: () => Navigator.pop(ctx, false),
            onDelay: () {
              final suggested = finalConflict!.suggestedTime;
              if (suggested != null) {
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
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );

    final validReminder = _isReminderEnabled
        ? (_reminderTime ??
            finalDateTime.subtract(
              _selectedType == EntityType.appointment
                  ? const Duration(minutes: 30)
                  : const Duration(minutes: 10),
            ))
        : null;

    try {
      if (_selectedType == EntityType.task) {
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
        if (!mounted) return;
        final postSaveState = taskCubit.state;
        if (postSaveState is TaskFreeLimitReached ||
            postSaveState is TaskError) {
          setState(() => _isSaving = false);
          return;
        }
      } else if (_selectedType == EntityType.medicine) {
        final timesList = _fixedTimes
            .map((t) =>
                "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}")
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
          refillThreshold:
              double.tryParse(_thresholdController.text) ?? 5.0,
          refillAction: _refillAction,
          startDate: finalDateTime,
          courseDurationDays: _durationMode == 'days'
              ? int.tryParse(_durationController.text)
              : null,
          treatmentEndDate: _selectedEndDate,
          schedulingType: _schedulingType,
          fixedTimeSlots:
              _schedulingType == 'fixed' ? timesList : null,
          intervalHours:
              _schedulingType == 'interval' ? _intervalHours : null,
          isActive: true,
        );
        await healthCubit.addMedicine(med);
        if (!mounted) return;
        if (healthCubit.state is HealthError) {
          setState(() => _isSaving = false);
          return;
        }
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
        await healthCubit.addAppointment(appt);
        if (!mounted) return;
        if (healthCubit.state is HealthError) {
          setState(() => _isSaving = false);
          return;
        }
      }

      if (mounted) navigator.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AtharSnackbar.error(
          context: context,
          message:
              AppLocalizations.of(context).errorOccurred(e.toString()),
        );
      }
    }
  }

  // ─── Pickers ──────────────────────────────────────────────────────────────

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
