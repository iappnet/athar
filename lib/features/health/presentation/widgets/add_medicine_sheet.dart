// lib/features/health/presentation/widgets/add_medicine_sheet.dart
// ✅ PR-SHEET-STANDARD: accordion sections + AtharBottomSheet container

import 'package:athar/core/design_system/molecules/sections/athar_accordion_section.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_button.dart';
import 'package:athar/core/design_system/widgets/athar_dialog.dart';
import 'package:athar/features/health/data/models/medicine_model.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddMedicineSheet extends StatefulWidget {
  final String moduleId;
  final HealthCubit cubit;
  final MedicineModel? medicineToEdit;

  const AddMedicineSheet({
    super.key,
    required this.moduleId,
    required this.cubit,
    this.medicineToEdit,
  });

  @override
  State<AddMedicineSheet> createState() => _AddMedicineSheetState();
}

class _AddMedicineSheetState extends State<AddMedicineSheet> {
  final _formKey = GlobalKey<FormState>();
  final _whatKey = GlobalKey<AtharAccordionSectionState>();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _doseAmountController = TextEditingController();
  final _doseUnitController = TextEditingController();
  final _durationController = TextEditingController();

  DateTime? _selectedEndDate;
  String _selectedType = 'pill';
  String _schedulingType = 'fixed';
  String _instructions = 'after_meal';
  String _durationMode = 'days';
  int _intervalHours = 8;
  List<TimeOfDay> _fixedTimes = [];
  String _refillMode = 'off';
  final _thresholdController = TextEditingController(text: '5');
  String _refillAction = 'list';

  bool get isEditing => widget.medicineToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final m = widget.medicineToEdit!;
      _nameController.text = m.name;
      _quantityController.text = m.stockQuantity?.toString() ?? '';
      _doseAmountController.text = m.doseAmount?.toString() ?? '';
      _doseUnitController.text = m.doseUnit ?? '';
      if (m.treatmentEndDate != null) {
        _selectedEndDate = m.treatmentEndDate;
        _durationMode = 'date';
      } else if (m.courseDurationDays != null) {
        _durationController.text = m.courseDurationDays.toString();
        _durationMode = 'days';
      }
      _selectedType = m.type ?? 'pill';
      _schedulingType = m.schedulingType;
      _instructions = m.instructions ?? 'after_meal';
      if (m.intervalHours != null) _intervalHours = m.intervalHours!;
      if (m.fixedTimeSlots != null) {
        _fixedTimes = m.fixedTimeSlots!.map((t) {
          final parts = t.split(':');
          return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }).toList();
      }
      _refillMode = m.autoRefillMode;
      _thresholdController.text = m.refillThreshold.toString().replaceAll('.0', '');
      _refillAction = m.refillAction;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _doseAmountController.dispose();
    _doseUnitController.dispose();
    _durationController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  String get _whatSummary => _nameController.text.trim();

  String _scheduleSummary(AppLocalizations l10n) {
    if (_schedulingType == 'fixed') {
      return _fixedTimes.isEmpty ? '' : l10n.medicineFixedTimes;
    }
    return l10n.medicineIntervalHours;
  }

  String _supplySummary() {
    final qty = _quantityController.text.trim();
    return qty.isEmpty ? '' : qty;
  }

  void _save(AppLocalizations l10n) {
    if (_nameController.text.trim().isEmpty) {
      _whatKey.currentState?.expand();
      return;
    }
    _saveMedicine();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AtharBottomSheet(
      title: isEditing ? l10n.medicineEditTitle : l10n.medicineAddTitle,
      showDragHandle: true,
      actions: [
        AtharButton(
          label: isEditing ? l10n.medicineSaveEdits : l10n.medicineSave,
          isFullWidth: true,
          onPressed: () => _save(l10n),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: What ──────────────────────────────────────────
            AtharAccordionSection(
              key: _whatKey,
              icon: Icons.medication_outlined,
              title: l10n.medicineName,
              initiallyExpanded: true,
              isRequired: true,
              summaryValue: _whatSummary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: l10n.medicineName,
                      border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
                      prefixIcon: const Icon(Icons.medication),
                    ),
                    validator: (v) => v!.isEmpty ? l10n.medicineRequired : null,
                  ),
                  AtharGap.lg,
                  Text(
                    l10n.medicineDosageForm,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                  AtharGap.sm,
                  _buildTypeChipRow(context),
                  AtharGap.lg,
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _doseAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.medicineDoseAmount,
                            hintText: '5',
                            border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
                          ),
                        ),
                      ),
                      AtharGap.hSm,
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _doseUnitController,
                          decoration: InputDecoration(
                            labelText: l10n.medicineDoseUnit,
                            hintText: 'ml',
                            border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
                          ),
                        ),
                      ),
                    ],
                  ),
                  AtharGap.md,
                  DropdownButtonFormField<String>(
                    initialValue: _instructions,
                    decoration: InputDecoration(
                      labelText: l10n.medicineInstructions,
                      border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
                      prefixIcon: const Icon(Icons.restaurant),
                    ),
                    items: [
                      DropdownMenuItem(value: 'before_meal', child: Text(l10n.medicineBeforeMeal)),
                      DropdownMenuItem(value: 'after_meal', child: Text(l10n.medicineAfterMeal)),
                      DropdownMenuItem(value: 'with_meal', child: Text(l10n.medicineWithMeal)),
                      DropdownMenuItem(value: 'anytime', child: Text(l10n.medicineAnytime)),
                    ],
                    onChanged: (v) => setState(() => _instructions = v!),
                  ),
                ],
              ),
            ),

            // ── Section 2: Schedule ──────────────────────────────────────
            AtharAccordionSection(
              icon: Icons.timelapse_outlined,
              title: l10n.schedulePattern,
              summaryValue: _scheduleSummary(l10n),
              child: Column(
                children: [
                  _buildScheduleTabs(context),
                  AtharGap.lg,
                  if (_schedulingType == 'fixed')
                    _buildFixedTimeSelector(context)
                  else
                    _buildIntervalSelector(context),
                ],
              ),
            ),

            // ── Section 3: Supply ────────────────────────────────────────
            AtharAccordionSection(
              icon: Icons.inventory_2_outlined,
              title: l10n.medicineStock,
              summaryValue: _supplySummary(),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          onChanged: (_) => setState(() {}),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.medicineStock,
                            hintText: '20',
                            border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
                            prefixIcon: const Icon(Icons.inventory),
                          ),
                        ),
                      ),
                      AtharGap.hMd,
                      Expanded(flex: 2, child: _buildDurationPicker(context)),
                    ],
                  ),
                  AtharGap.lg,
                  _buildAutoRefillTile(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helper builders ──────────────────────────────────────────────────────

  Widget _buildTypeChipRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTypeChip(colorScheme, 'pill', l10n.medicineTypePill, Icons.circle_outlined),
          AtharGap.hSm,
          _buildTypeChip(colorScheme, 'syrup', l10n.medicineTypeSyrup, Icons.local_drink),
          AtharGap.hSm,
          _buildTypeChip(colorScheme, 'injection', l10n.medicineTypeInjection, Icons.vaccines),
          AtharGap.hSm,
          _buildTypeChip(colorScheme, 'drops', l10n.medicineTypeDrops, Icons.water_drop),
          AtharGap.hSm,
          _buildTypeChip(colorScheme, 'ointment', l10n.medicineTypeOintment, Icons.sanitizer),
          AtharGap.hSm,
          _buildTypeChip(colorScheme, 'spray', l10n.medicineTypeSpray, Icons.air),
        ],
      ),
    );
  }

  Widget _buildTypeChip(ColorScheme cs, String key, String label, IconData icon) {
    final isSelected = _selectedType == key;
    return ChoiceChip(
      label: Row(
        children: [
          Icon(icon, size: 16, color: isSelected ? cs.onPrimary : cs.outline),
          AtharGap.hXxs,
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: cs.primary,
      labelStyle: TextStyle(color: isSelected ? cs.onPrimary : cs.onSurface),
      onSelected: (_) => setState(() => _selectedType = key),
    );
  }

  Widget _buildScheduleTabs(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.outlineVariant,
        borderRadius: AtharRadii.radiusMd,
      ),
      child: Row(
        children: [
          _buildScheduleTab(colorScheme, 'fixed', l10n.medicineFixedTimes),
          _buildScheduleTab(colorScheme, 'interval', l10n.medicineIntervalHours),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(ColorScheme cs, String key, String label) {
    final isSelected = _schedulingType == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _schedulingType = key),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? cs.surface : Colors.transparent,
            borderRadius: AtharRadii.radiusSm,
            boxShadow: isSelected
                ? [BoxShadow(color: cs.shadow.withValues(alpha: 0.05), blurRadius: 4)]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? cs.primary : cs.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedTimeSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineSelectTimes,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0.5,
            color: colorScheme.outline,
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
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                labelStyle: TextStyle(color: colorScheme.primary),
                deleteIconColor: colorScheme.primary,
              ),
            ),
            ActionChip(
              label: const Icon(Icons.add, size: 18),
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

  Widget _buildIntervalSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Icon(Icons.timelapse, color: colorScheme.onSurfaceVariant),
        AtharGap.hMd,
        Text(l10n.medicineEvery),
        AtharGap.hMd,
        DropdownButton<int>(
          value: _intervalHours,
          items: [4, 6, 8, 12, 24]
              .map((h) => DropdownMenuItem(value: h, child: Text(l10n.medicineHoursUnit(h.toString()))))
              .toList(),
          onChanged: (v) => setState(() => _intervalHours = v!),
        ),
      ],
    );
  }

  Widget _buildDurationPicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.medicineTreatmentDuration,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: 0.5,
                color: colorScheme.outline,
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _durationMode = _durationMode == 'days' ? 'date' : 'days';
              }),
              child: Text(
                _durationMode == 'days' ? l10n.medicineSwitchToDate : l10n.medicineSwitchToDays,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                  letterSpacing: 0.5,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        AtharGap.xxs,
        if (_durationMode == 'days')
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.medicineDaysCount,
              hintText: '7',
              border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
              prefixIcon: const Icon(Icons.date_range),
            ),
          )
        else
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 7)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _selectedEndDate = picked);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: AtharRadii.radiusMd,
              ),
              child: Row(
                children: [
                  Icon(Icons.event_available, color: Theme.of(context).colorScheme.outline),
                  AtharGap.hSm,
                  Text(
                    _selectedEndDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedEndDate!)
                        : l10n.medicinePickEndDate,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: _selectedEndDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAutoRefillTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(Icons.autorenew, color: colorScheme.primary),
            AtharGap.hSm,
            Text(l10n.medicineAutoRefill, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _refillMode,
                  decoration: InputDecoration(labelText: l10n.medicineRefillWhen),
                  items: [
                    DropdownMenuItem(value: 'off', child: Text(l10n.medicineRefillOff)),
                    DropdownMenuItem(value: 'quantity', child: Text(l10n.medicineRefillOnLowStock)),
                    DropdownMenuItem(value: 'date', child: Text(l10n.medicineRefillBeforeEnd)),
                  ],
                  onChanged: (v) => setState(() => _refillMode = v!),
                ),
                AtharGap.md,
                if (_refillMode != 'off')
                  TextFormField(
                    controller: _thresholdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: _refillMode == 'quantity'
                          ? l10n.medicineRefillAtQuantity
                          : l10n.medicineRefillBeforeDays,
                      helperText: _refillMode == 'quantity'
                          ? l10n.medicineRefillQuantityHint
                          : l10n.medicineRefillDaysHint,
                    ),
                  ),
                AtharGap.md,
                if (_refillMode != 'off')
                  DropdownButtonFormField<String>(
                    initialValue: _refillAction,
                    decoration: InputDecoration(labelText: l10n.medicineRefillAction),
                    items: [
                      DropdownMenuItem(value: 'list', child: Text(l10n.medicineRefillActionList)),
                      DropdownMenuItem(value: 'task', child: Text(l10n.medicineRefillActionTask)),
                      DropdownMenuItem(value: 'both', child: Text(l10n.medicineRefillActionBoth)),
                    ],
                    onChanged: (v) => setState(() => _refillAction = v!),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveMedicine() {
    final timesList = _fixedTimes
        .map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .toList();

    final startDate = isEditing ? widget.medicineToEdit!.startDate! : DateTime.now();
    int? finalDuration;
    DateTime? finalEndDate;

    if (_durationMode == 'days' && _durationController.text.isNotEmpty) {
      finalDuration = int.parse(_durationController.text);
      finalEndDate = startDate.add(Duration(days: finalDuration));
    } else if (_durationMode == 'date' && _selectedEndDate != null) {
      finalEndDate = _selectedEndDate!;
      finalDuration = _selectedEndDate!.difference(startDate).inDays;
      if (finalDuration < 0) finalDuration = 0;
    }

    final threshold = double.tryParse(_thresholdController.text) ?? 0.0;

    final medicine = MedicineModel(
      uuid: isEditing ? widget.medicineToEdit!.uuid : const Uuid().v4(),
      moduleId: widget.moduleId,
      name: _nameController.text,
      type: _selectedType,
      schedulingType: _schedulingType,
      fixedTimeSlots: _schedulingType == 'fixed' ? timesList : null,
      intervalHours: _schedulingType == 'interval' ? _intervalHours : null,
      stockQuantity: double.tryParse(_quantityController.text),
      doseAmount: double.tryParse(_doseAmountController.text),
      doseUnit: _doseUnitController.text.isNotEmpty ? _doseUnitController.text : null,
      instructions: _instructions,
      startDate: startDate,
      courseDurationDays: finalDuration,
      treatmentEndDate: finalEndDate,
      isActive: true,
      autoRefillMode: _refillMode,
      refillThreshold: threshold,
      refillAction: _refillAction,
      isRefillRequested: false,
    );

    if (isEditing) medicine.id = widget.medicineToEdit!.id;

    if (isEditing) {
      widget.cubit.deleteMedicine(widget.medicineToEdit!);
      widget.cubit.addMedicine(medicine);
    } else {
      widget.cubit.addMedicine(medicine);
    }
    Navigator.pop(context);
  }
}
