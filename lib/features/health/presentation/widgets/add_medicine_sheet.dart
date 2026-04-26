// lib/features/health/presentation/widgets/add_medicine_sheet.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 6 | Part 2 | File 1
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/core/design_system/tokens.dart';
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
          return TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }).toList();
      }

      _refillMode = m.autoRefillMode;
      _thresholdController.text = m.refillThreshold.toString().replaceAll(
        '.0',
        '',
      );
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

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors & l10n
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        24.h,
        24.w,
        MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        // ✅ Colors.white → colors.surface
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    // ✅ Colors.grey.shade300 → colors.borderLight
                    color: colorScheme.outlineVariant,
                    borderRadius: AtharRadii.radiusXxxs,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                // ✅ l10n
                isEditing ? l10n.medicineEditTitle : l10n.medicineAddTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.h),

              // 1. الاسم
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  // ✅ l10n
                  labelText: l10n.medicineName,
                  border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
                  prefixIcon: const Icon(Icons.medication),
                ),
                // ✅ l10n
                validator: (v) => v!.isEmpty ? l10n.medicineRequired : null,
              ),
              AtharGap.lg,

              // 2. الشكل الدوائي
              Text(
                // ✅ l10n
                l10n.medicineDosageForm,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ).copyWith(),
              ),
              AtharGap.sm,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTypeChip(
                      colorScheme,
                      l10n,
                      'pill',
                      l10n.medicineTypePill,
                      Icons.circle_outlined,
                    ),
                    AtharGap.hSm,
                    _buildTypeChip(
                      colorScheme,
                      l10n,
                      'syrup',
                      l10n.medicineTypeSyrup,
                      Icons.local_drink,
                    ),
                    AtharGap.hSm,
                    _buildTypeChip(
                      colorScheme,
                      l10n,
                      'injection',
                      l10n.medicineTypeInjection,
                      Icons.vaccines,
                    ),
                    AtharGap.hSm,
                    _buildTypeChip(
                      colorScheme,
                      l10n,
                      'drops',
                      l10n.medicineTypeDrops,
                      Icons.water_drop,
                    ),
                    AtharGap.hSm,
                    _buildTypeChip(
                      colorScheme,
                      l10n,
                      'ointment',
                      l10n.medicineTypeOintment,
                      Icons.sanitizer,
                    ),
                    AtharGap.hSm,
                    _buildTypeChip(
                      colorScheme,
                      l10n,
                      'spray',
                      l10n.medicineTypeSpray,
                      Icons.air,
                    ),
                  ],
                ),
              ),
              AtharGap.lg,

              // 3. الجرعة والتعليمات
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _doseAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        // ✅ l10n
                        labelText: l10n.medicineDoseAmount,
                        hintText: "5",
                        border: OutlineInputBorder(
                          borderRadius: AtharRadii.radiusMd,
                        ),
                      ),
                    ),
                  ),
                  AtharGap.hSm,
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _doseUnitController,
                      decoration: InputDecoration(
                        // ✅ l10n
                        labelText: l10n.medicineDoseUnit,
                        hintText: "ml",
                        border: OutlineInputBorder(
                          borderRadius: AtharRadii.radiusMd,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AtharGap.md,
              DropdownButtonFormField<String>(
                initialValue: _instructions,
                decoration: InputDecoration(
                  // ✅ l10n
                  labelText: l10n.medicineInstructions,
                  border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
                  prefixIcon: const Icon(Icons.restaurant),
                ),
                items: [
                  // ✅ l10n - removed const
                  DropdownMenuItem(
                    value: 'before_meal',
                    child: Text(l10n.medicineBeforeMeal),
                  ),
                  DropdownMenuItem(
                    value: 'after_meal',
                    child: Text(l10n.medicineAfterMeal),
                  ),
                  DropdownMenuItem(
                    value: 'with_meal',
                    child: Text(l10n.medicineWithMeal),
                  ),
                  DropdownMenuItem(
                    value: 'anytime',
                    child: Text(l10n.medicineAnytime),
                  ),
                ],
                onChanged: (v) => setState(() => _instructions = v!),
              ),
              AtharGap.lg,

              // 4. الجدولة
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: AtharRadii.radiusMd,
                ),
                child: Row(
                  children: [
                    _buildScheduleTab(
                      colorScheme,
                      l10n,
                      'fixed',
                      l10n.medicineFixedTimes,
                    ),
                    _buildScheduleTab(
                      colorScheme,
                      l10n,
                      'interval',
                      l10n.medicineIntervalHours,
                    ),
                  ],
                ),
              ),
              AtharGap.lg,
              if (_schedulingType == 'fixed')
                _buildFixedTimeSelector(colorScheme, l10n)
              else
                _buildIntervalSelector(colorScheme, l10n),

              SizedBox(height: 24.h),

              // 5. المخزون والمدة
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        // ✅ l10n
                        labelText: l10n.medicineStock,
                        hintText: "20",
                        border: OutlineInputBorder(
                          borderRadius: AtharRadii.radiusMd,
                        ),
                        prefixIcon: const Icon(Icons.inventory),
                      ),
                    ),
                  ),
                  AtharGap.hMd,
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              // ✅ l10n
                              l10n.medicineTreatmentDuration,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                                letterSpacing: 0.5,
                              ).copyWith(color: colorScheme.outline),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _durationMode = _durationMode == 'days'
                                      ? 'date'
                                      : 'days';
                                });
                              },
                              child: Text(
                                // ✅ l10n
                                _durationMode == 'days'
                                    ? l10n.medicineSwitchToDate
                                    : l10n.medicineSwitchToDays,
                                style:
                                    TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                      letterSpacing: 0.5,
                                    ).copyWith(
                                      // ✅ AppColors.primary → colors.primary
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        if (_durationMode == 'days')
                          TextField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              // ✅ l10n
                              labelText: l10n.medicineDaysCount,
                              hintText: "7",
                              border: OutlineInputBorder(
                                borderRadius: AtharRadii.radiusMd,
                              ),
                              prefixIcon: const Icon(Icons.date_range),
                            ),
                          )
                        else
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(
                                  const Duration(days: 7),
                                ),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setState(() => _selectedEndDate = picked);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 16.h,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: colorScheme.outline),
                                borderRadius: AtharRadii.radiusMd,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_available,
                                    color: colorScheme.outline,
                                  ),
                                  AtharGap.hSm,
                                  Text(
                                    _selectedEndDate != null
                                        ? DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(_selectedEndDate!)
                                        // ✅ l10n
                                        : l10n.medicinePickEndDate,
                                    style:
                                        TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          height: 1.6,
                                        ).copyWith(
                                          color: _selectedEndDate != null
                                              ? colorScheme.onSurface
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // ✅ 6. قسم الأتمتة الذكية
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: AtharRadii.radiusMd,
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      // ✅ AppColors.primary → colors.primary
                      Icon(Icons.autorenew, color: colorScheme.primary),
                      AtharGap.hSm,
                      Text(
                        // ✅ l10n
                        l10n.medicineAutoRefill,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _refillMode,
                            decoration: InputDecoration(
                              // ✅ l10n
                              labelText: l10n.medicineRefillWhen,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'off',
                                child: Text(l10n.medicineRefillOff),
                              ),
                              DropdownMenuItem(
                                value: 'quantity',
                                child: Text(l10n.medicineRefillOnLowStock),
                              ),
                              DropdownMenuItem(
                                value: 'date',
                                child: Text(l10n.medicineRefillBeforeEnd),
                              ),
                            ],
                            onChanged: (v) => setState(() => _refillMode = v!),
                          ),
                          AtharGap.md,
                          if (_refillMode != 'off')
                            TextFormField(
                              controller: _thresholdController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                // ✅ l10n
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
                              decoration: InputDecoration(
                                // ✅ l10n
                                labelText: l10n.medicineRefillAction,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'list',
                                  child: Text(l10n.medicineRefillActionList),
                                ),
                                DropdownMenuItem(
                                  value: 'task',
                                  child: Text(l10n.medicineRefillActionTask),
                                ),
                                DropdownMenuItem(
                                  value: 'both',
                                  child: Text(l10n.medicineRefillActionBoth),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _refillAction = v!),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              ElevatedButton(
                onPressed: _saveMedicine,
                style: ElevatedButton.styleFrom(
                  // ✅ AppColors.primary → colors.primary
                  backgroundColor: colorScheme.primary,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: AtharRadii.radiusMd,
                  ),
                ),
                child: Text(
                  // ✅ l10n
                  isEditing ? l10n.medicineSaveEdits : l10n.medicineSave,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- دوال مساعدة ---
  Widget _buildTypeChip(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    String key,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedType == key;
    return ChoiceChip(
      label: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : colorScheme.outline,
          ),
          SizedBox(width: 4.w),
          Text(label),
        ],
      ),
      selected: isSelected,
      // ✅ AppColors.primary → colors.primary
      selectedColor: colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : colorScheme.onSurface,
      ),
      onSelected: (val) => setState(() => _selectedType = key),
    );
  }

  Widget _buildScheduleTab(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    String key,
    String label,
  ) {
    final isSelected = _schedulingType == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _schedulingType = key),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: AtharRadii.radiusSm,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              // ✅ AppColors.primary → colors.primary
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedTimeSelector(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // ✅ l10n
          l10n.medicineSelectTimes,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: 0.5,
          ).copyWith(color: colorScheme.outline),
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

  Widget _buildIntervalSelector(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        const Icon(Icons.timelapse, color: Colors.orange),
        AtharGap.hMd,
        Text(
          // ✅ l10n
          l10n.medicineEvery,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.6,
          ).copyWith(),
        ),
        AtharGap.hMd,
        DropdownButton<int>(
          value: _intervalHours,
          items: [4, 6, 8, 12, 24]
              // ✅ l10n
              .map(
                (h) => DropdownMenuItem(
                  value: h,
                  child: Text(l10n.medicineHoursUnit(h.toString())),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _intervalHours = v!),
        ),
      ],
    );
  }

  void _saveMedicine() {
    if (_nameController.text.isNotEmpty) {
      final timesList = _fixedTimes
          .map(
            (t) =>
                "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}",
          )
          .toList();

      final startDate = isEditing
          ? widget.medicineToEdit!.startDate!
          : DateTime.now();
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
        doseUnit: _doseUnitController.text.isNotEmpty
            ? _doseUnitController.text
            : null,
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
}
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/health/data/models/medicine_model.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';

// class AddMedicineSheet extends StatefulWidget {
//   final String moduleId;
//   final HealthCubit cubit;
//   final MedicineModel? medicineToEdit;

//   const AddMedicineSheet({
//     super.key,
//     required this.moduleId,
//     required this.cubit,
//     this.medicineToEdit,
//   });

//   @override
//   State<AddMedicineSheet> createState() => _AddMedicineSheetState();
// }

// class _AddMedicineSheetState extends State<AddMedicineSheet> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _quantityController = TextEditingController();

//   // للجرعة
//   final _doseAmountController = TextEditingController();
//   final _doseUnitController = TextEditingController();

//   // للكورس
//   final _durationController = TextEditingController();
//   DateTime? _selectedEndDate;

//   String _selectedType = 'pill';
//   String _schedulingType = 'fixed';
//   String _instructions = 'after_meal';
//   String _durationMode = 'days';

//   int _intervalHours = 8;
//   List<TimeOfDay> _fixedTimes = [];

//   // ✅ متغيرات الأتمتة الجديدة
//   String _refillMode = 'off';
//   final _thresholdController = TextEditingController(text: '5');
//   String _refillAction = 'list';

//   bool get isEditing => widget.medicineToEdit != null;

//   @override
//   void initState() {
//     super.initState();
//     if (isEditing) {
//       final m = widget.medicineToEdit!;
//       _nameController.text = m.name;
//       _quantityController.text = m.stockQuantity?.toString() ?? '';
//       _doseAmountController.text = m.doseAmount?.toString() ?? '';
//       _doseUnitController.text = m.doseUnit ?? '';

//       if (m.treatmentEndDate != null) {
//         _selectedEndDate = m.treatmentEndDate;
//         _durationMode = 'date';
//       } else if (m.courseDurationDays != null) {
//         _durationController.text = m.courseDurationDays.toString();
//         _durationMode = 'days';
//       }

//       _selectedType = m.type ?? 'pill';
//       _schedulingType = m.schedulingType;
//       _instructions = m.instructions ?? 'after_meal';

//       if (m.intervalHours != null) _intervalHours = m.intervalHours!;

//       if (m.fixedTimeSlots != null) {
//         _fixedTimes = m.fixedTimeSlots!.map((t) {
//           final parts = t.split(':');
//           return TimeOfDay(
//             hour: int.parse(parts[0]),
//             minute: int.parse(parts[1]),
//           );
//         }).toList();
//       }

//       // ✅ استرجاع إعدادات الأتمتة
//       _refillMode = m.autoRefillMode;
//       _thresholdController.text = m.refillThreshold.toString().replaceAll(
//         '.0',
//         '',
//       );
//       _refillAction = m.refillAction;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         24.w,
//         24.h,
//         24.w,
//         MediaQuery.of(context).viewInsets.bottom + 24.h,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40.w,
//                   height: 4.h,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 20.h),
//               Text(
//                 isEditing ? "تعديل الدواء ✏️" : "إضافة دواء جديد 💊",
//                 style: TextStyle(
//                   fontFamily: 'Tajawal',
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 20.h),

//               // 1. الاسم
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: "اسم الدواء",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   prefixIcon: const Icon(Icons.medication),
//                 ),
//                 validator: (v) => v!.isEmpty ? "مطلوب" : null,
//               ),
//               SizedBox(height: 16.h),

//               // 2. الشكل الدوائي
//               Text(
//                 "الشكل الدوائي:",
//                 style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.sp),
//               ),
//               SizedBox(height: 8.h),
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     _buildTypeChip('pill', "حبوب", Icons.circle_outlined),
//                     SizedBox(width: 8.w),
//                     _buildTypeChip('syrup', "شراب", Icons.local_drink),
//                     SizedBox(width: 8.w),
//                     _buildTypeChip('injection', "إبرة", Icons.vaccines),
//                     SizedBox(width: 8.w),
//                     _buildTypeChip('drops', "قطرة", Icons.water_drop),
//                     SizedBox(width: 8.w),
//                     _buildTypeChip('ointment', "مرهم", Icons.sanitizer),
//                     SizedBox(width: 8.w),
//                     _buildTypeChip('spray', "بخاخ", Icons.air),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 16.h),

//               // 3. الجرعة والتعليمات
//               Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: TextField(
//                       controller: _doseAmountController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: "مقدار الجرعة",
//                         hintText: "5",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 8.w),
//                   Expanded(
//                     flex: 2,
//                     child: TextField(
//                       controller: _doseUnitController,
//                       decoration: InputDecoration(
//                         labelText: "الوحدة",
//                         hintText: "ml",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 12.h),
//               DropdownButtonFormField<String>(
//                 initialValue:
//                     _instructions, // استخدام value بدلاً من initialValue
//                 decoration: InputDecoration(
//                   labelText: "تعليمات الاستخدام",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   prefixIcon: const Icon(Icons.restaurant),
//                 ),
//                 items: const [
//                   DropdownMenuItem(
//                     value: 'before_meal',
//                     child: Text("قبل الأكل"),
//                   ),
//                   DropdownMenuItem(
//                     value: 'after_meal',
//                     child: Text("بعد الأكل"),
//                   ),
//                   DropdownMenuItem(value: 'with_meal', child: Text("مع الأكل")),
//                   DropdownMenuItem(value: 'anytime', child: Text("في أي وقت")),
//                 ],
//                 onChanged: (v) => setState(() => _instructions = v!),
//               ),
//               SizedBox(height: 16.h),

//               // 4. الجدولة
//               Container(
//                 padding: EdgeInsets.all(4.w),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: Row(
//                   children: [
//                     _buildScheduleTab('fixed', "أوقات ثابتة"),
//                     _buildScheduleTab('interval', "تكرار بالساعات"),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 16.h),
//               if (_schedulingType == 'fixed')
//                 _buildFixedTimeSelector()
//               else
//                 _buildIntervalSelector(),

//               SizedBox(height: 24.h),

//               // 5. المخزون والمدة
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _quantityController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: "المخزون",
//                         hintText: "20",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         prefixIcon: const Icon(Icons.inventory),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     flex: 2,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               "مدة العلاج:",
//                               style: TextStyle(
//                                 fontSize: 12.sp,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   _durationMode = _durationMode == 'days'
//                                       ? 'date'
//                                       : 'days';
//                                 });
//                               },
//                               child: Text(
//                                 _durationMode == 'days'
//                                     ? "تحديد بالتاريخ؟"
//                                     : "تحديد بالأيام؟",
//                                 style: TextStyle(
//                                   fontSize: 11.sp,
//                                   color: AppColors.primary,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 4.h),
//                         if (_durationMode == 'days')
//                           TextField(
//                             controller: _durationController,
//                             keyboardType: TextInputType.number,
//                             decoration: InputDecoration(
//                               labelText: "عدد الأيام",
//                               hintText: "7",
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12.r),
//                               ),
//                               prefixIcon: const Icon(Icons.date_range),
//                             ),
//                           )
//                         else
//                           InkWell(
//                             onTap: () async {
//                               final picked = await showDatePicker(
//                                 context: context,
//                                 initialDate: DateTime.now().add(
//                                   const Duration(days: 7),
//                                 ),
//                                 firstDate: DateTime.now(),
//                                 lastDate: DateTime.now().add(
//                                   const Duration(days: 365),
//                                 ),
//                               );
//                               if (picked != null) {
//                                 setState(() => _selectedEndDate = picked);
//                               }
//                             },
//                             child: Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 12.w,
//                                 vertical: 16.h,
//                               ),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.grey),
//                                 borderRadius: BorderRadius.circular(12.r),
//                               ),
//                               child: Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.event_available,
//                                     color: Colors.grey,
//                                   ),
//                                   SizedBox(width: 8.w),
//                                   Text(
//                                     _selectedEndDate != null
//                                         ? DateFormat(
//                                             'yyyy-MM-dd',
//                                           ).format(_selectedEndDate!)
//                                         : "اختر تاريخ النهاية",
//                                     style: TextStyle(
//                                       fontSize: 14.sp,
//                                       color: _selectedEndDate != null
//                                           ? Colors.black
//                                           : Colors.grey.shade600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: 24.h),

//               // ✅ 6. قسم الأتمتة الذكية (مدمج ومحسن)
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(12.r),
//                   border: Border.all(color: Colors.blue.shade100),
//                 ),
//                 child: ExpansionTile(
//                   title: Row(
//                     children: [
//                       Icon(Icons.autorenew, color: AppColors.primary),
//                       SizedBox(width: 8.w),
//                       const Text(
//                         "إعادة التعبئة التلقائية",
//                         style: TextStyle(
//                           fontFamily: 'Tajawal',
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.all(12.w),
//                       child: Column(
//                         children: [
//                           DropdownButtonFormField<String>(
//                             initialValue: _refillMode,
//                             decoration: const InputDecoration(
//                               labelText: "متى يتم الطلب؟",
//                             ),
//                             items: const [
//                               DropdownMenuItem(
//                                 value: 'off',
//                                 child: Text("إيقاف (يدوي)"),
//                               ),
//                               DropdownMenuItem(
//                                 value: 'quantity',
//                                 child: Text("عند نقص الكمية"),
//                               ),
//                               DropdownMenuItem(
//                                 value: 'date',
//                                 child: Text("قبل انتهاء الكورس"),
//                               ),
//                             ],
//                             onChanged: (v) => setState(() => _refillMode = v!),
//                           ),
//                           SizedBox(height: 12.h),
//                           if (_refillMode != 'off')
//                             TextFormField(
//                               controller: _thresholdController,
//                               keyboardType: TextInputType.number,
//                               decoration: InputDecoration(
//                                 labelText: _refillMode == 'quantity'
//                                     ? "عند الوصول لـ (كمية)"
//                                     : "قبل الانتهاء بـ (أيام)",
//                                 helperText: _refillMode == 'quantity'
//                                     ? "مثال: اطلب عندما يتبقى 5 حبات"
//                                     : "مثال: اطلب قبل 3 أيام من النهاية",
//                               ),
//                             ),
//                           SizedBox(height: 12.h),
//                           if (_refillMode != 'off')
//                             DropdownButtonFormField<String>(
//                               initialValue: _refillAction,
//                               decoration: const InputDecoration(
//                                 labelText: "الإجراء المطلوب",
//                               ),
//                               items: const [
//                                 DropdownMenuItem(
//                                   value: 'list',
//                                   child: Text("إضافة لقائمة المشتريات"),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 'task',
//                                   child: Text("إنشاء مهمة متابعة"),
//                                 ),
//                                 DropdownMenuItem(
//                                   value: 'both',
//                                   child: Text("كلاهما (مهمة + قائمة)"),
//                                 ),
//                               ],
//                               onChanged: (v) =>
//                                   setState(() => _refillAction = v!),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: 24.h),

//               ElevatedButton(
//                 onPressed: _saveMedicine,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   minimumSize: Size(double.infinity, 50.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 child: Text(
//                   isEditing ? "حفظ التعديلات" : "حفظ الدواء",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Tajawal',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // --- دوال مساعدة ---
//   Widget _buildTypeChip(String key, String label, IconData icon) {
//     final isSelected = _selectedType == key;
//     return ChoiceChip(
//       label: Row(
//         children: [
//           Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
//           SizedBox(width: 4.w),
//           Text(label),
//         ],
//       ),
//       selected: isSelected,
//       selectedColor: AppColors.primary,
//       labelStyle: TextStyle(
//         color: isSelected ? Colors.white : Colors.black,
//         fontFamily: 'Tajawal',
//       ),
//       onSelected: (val) => setState(() => _selectedType = key),
//     );
//   }

//   Widget _buildScheduleTab(String key, String label) {
//     final isSelected = _schedulingType == key;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _schedulingType = key),
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 10.h),
//           decoration: BoxDecoration(
//             color: isSelected ? Colors.white : Colors.transparent,
//             borderRadius: BorderRadius.circular(10.r),
//             boxShadow: isSelected
//                 ? [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.05),
//                       blurRadius: 4,
//                     ),
//                   ]
//                 : [],
//           ),
//           alignment: Alignment.center,
//           child: Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? AppColors.primary : Colors.grey,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Tajawal',
//             ),
//           ),
//         ),
//       ),
//     );
//   }

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

//   void _saveMedicine() {
//     if (_nameController.text.isNotEmpty) {
//       final timesList = _fixedTimes
//           .map(
//             (t) =>
//                 "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}",
//           )
//           .toList();

//       final startDate = isEditing
//           ? widget.medicineToEdit!.startDate!
//           : DateTime.now();
//       int? finalDuration;
//       DateTime? finalEndDate;

//       if (_durationMode == 'days' && _durationController.text.isNotEmpty) {
//         finalDuration = int.parse(_durationController.text);
//         finalEndDate = startDate.add(Duration(days: finalDuration));
//       } else if (_durationMode == 'date' && _selectedEndDate != null) {
//         finalEndDate = _selectedEndDate!;
//         finalDuration = _selectedEndDate!.difference(startDate).inDays;
//         if (finalDuration < 0) finalDuration = 0;
//       }

//       // ✅ بيانات الأتمتة
//       final threshold = double.tryParse(_thresholdController.text) ?? 0.0;

//       final medicine = MedicineModel(
//         uuid: isEditing ? widget.medicineToEdit!.uuid : const Uuid().v4(),
//         moduleId: widget.moduleId,
//         name: _nameController.text,
//         type: _selectedType,
//         schedulingType: _schedulingType,
//         fixedTimeSlots: _schedulingType == 'fixed' ? timesList : null,
//         intervalHours: _schedulingType == 'interval' ? _intervalHours : null,
//         stockQuantity: double.tryParse(_quantityController.text),
//         doseAmount: double.tryParse(_doseAmountController.text),
//         doseUnit: _doseUnitController.text.isNotEmpty
//             ? _doseUnitController.text
//             : null,
//         instructions: _instructions,
//         startDate: startDate,
//         courseDurationDays: finalDuration,
//         treatmentEndDate: finalEndDate,
//         isActive: true,
//         // ✅ حقول الأتمتة الجديدة
//         autoRefillMode: _refillMode,
//         refillThreshold: threshold,
//         refillAction: _refillAction,
//         isRefillRequested:
//             false, // نعيد تفعيل الطلب في حال عدل المستخدم الإعدادات
//       );

//       if (isEditing) medicine.id = widget.medicineToEdit!.id;

//       if (isEditing) {
//         // widget.cubit.updateMedicine(medicine); // تفعيل التحديث
//         // مؤقتاً نحذف ونضيف للتجربة أو ننشئ دالة update في الكيوبت
//         widget.cubit.deleteMedicine(widget.medicineToEdit!);
//         widget.cubit.addMedicine(medicine);
//       } else {
//         widget.cubit.addMedicine(medicine);
//       }
//       Navigator.pop(context);
//     }
//   }
// }
//-----------------------------------------------------------------------
