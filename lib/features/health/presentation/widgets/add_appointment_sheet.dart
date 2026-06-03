import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart';
import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddAppointmentSheet extends StatefulWidget {
  final String moduleId;
  final HealthCubit cubit;

  const AddAppointmentSheet({
    super.key,
    required this.moduleId,
    required this.cubit,
  });

  @override
  State<AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

class _AddAppointmentSheetState extends State<AddAppointmentSheet> {
  final _titleController = TextEditingController();
  final _doctorController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedType = 'checkup';

  DateTime? _reminderTime;
  bool _isReminderEnabled = true;
  int _reminderDaysBefore = 1;
  int _reminderHoursBefore = 1;
  int _reminderMinutesBefore = 15;

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        24.w,
        24.h,
        24.w,
        MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AtharRadii.bottomSheet,
      ),
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
                  color: colors.outlineVariant,
                  borderRadius: AtharRadii.radiusXxxs,
                ),
              ),
            ),
            AtharGap.xl,
            Text(
              l10n.appointmentSheetTitle,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            AtharGap.xl,

            // 1. عنوان الموعد
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.appointmentTitleLabel,
                hintText: l10n.appointmentTitleHint,
                border: OutlineInputBorder(
                  borderRadius: AtharRadii.radiusMd,
                ),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            AtharGap.lg,

            // 2. نوع الموعد
            Text(l10n.appointmentVisitType, style: TextStyle(fontSize: 14.sp)),
            AtharGap.sm,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip(
                    'checkup',
                    l10n.appointmentTypeCheckup,
                    Icons.medical_services,
                  ),
                  AtharGap.hSm,
                  _buildTypeChip('lab', l10n.appointmentTypeLab, Icons.science),
                  AtharGap.hSm,
                  _buildTypeChip(
                    'vaccine',
                    l10n.appointmentTypeVaccine,
                    Icons.vaccines,
                  ),
                  AtharGap.hSm,
                  _buildTypeChip(
                    'procedure',
                    l10n.appointmentTypeProcedure,
                    Icons.healing,
                  ),
                ],
              ),
            ),
            AtharGap.lg,

            // 3. التاريخ والوقت
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: AtharSpacing.allMd,
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.outlineVariant),
                        borderRadius: AtharRadii.radiusMd,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.appointmentDateLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            DateFormat('yyyy-MM-dd').format(_selectedDate),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AtharGap.hMd,
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    child: Container(
                      padding: AtharSpacing.allMd,
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.outlineVariant),
                        borderRadius: AtharRadii.radiusMd,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.appointmentTimeLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _selectedTime.format(context),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AtharGap.lg,

            // 4. التفاصيل (اختياري)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _doctorController,
                    decoration: InputDecoration(
                      labelText: l10n.appointmentDoctorLabel,
                      border: OutlineInputBorder(
                        borderRadius: AtharRadii.radiusMd,
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                ),
                AtharGap.hMd,
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: l10n.appointmentLocationLabel,
                      border: OutlineInputBorder(
                        borderRadius: AtharRadii.radiusMd,
                      ),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                  ),
                ),
              ],
            ),
            AtharGap.lg,

            ReminderPickerWidget(
              reminderTime: _reminderTime,
              isEnabled: _isReminderEnabled,
              onToggle: (val) => setState(() => _isReminderEnabled = val),
              onTimeChanged: (newTime) =>
                  setState(() => _reminderTime = newTime),
            ),

            if (_isReminderEnabled) ...[
              AtharGap.md,
              Row(
                children: [
                  Expanded(
                    child: _buildReminderDropdown(
                      label: 'أيام',
                      value: _reminderDaysBefore,
                      items: [0, 1, 2, 3, 7],
                      onChanged: (v) =>
                          setState(() => _reminderDaysBefore = v!),
                    ),
                  ),
                  AtharGap.hSm,
                  Expanded(
                    child: _buildReminderDropdown(
                      label: 'ساعات',
                      value: _reminderHoursBefore,
                      items: [0, 1, 2, 3, 6, 12],
                      onChanged: (v) =>
                          setState(() => _reminderHoursBefore = v!),
                    ),
                  ),
                  AtharGap.hSm,
                  Expanded(
                    child: _buildReminderDropdown(
                      label: 'دقائق',
                      value: _reminderMinutesBefore,
                      items: [0, 5, 10, 15, 30],
                      onChanged: (v) =>
                          setState(() => _reminderMinutesBefore = v!),
                    ),
                  ),
                ],
              ),
            ],

            AtharGap.lg,

            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.appointmentNotesLabel,
                border: OutlineInputBorder(
                  borderRadius: AtharRadii.radiusMd,
                ),
                prefixIcon: const Icon(Icons.notes),
              ),
            ),

            AtharGap.xxl,

            ElevatedButton(
              onPressed: _saveAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: AtharRadii.radiusMd,
                ),
              ),
              child: Text(
                l10n.appointmentSaveButton,
                style: TextStyle(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String key, String label, IconData icon) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = _selectedType == key;

    return ChoiceChip(
      label: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
          ),
          AtharGap.hXxs,
          Text(label),
        ],
      ),
      selected: isSelected,
      selectedColor: colors.primary,
      labelStyle: TextStyle(
        color: isSelected ? colors.onPrimary : colors.onSurface,
      ),
      onSelected: (val) => setState(() => _selectedType = key),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Widget _buildReminderDropdown({
    required String label,
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
            borderRadius: AtharRadii.radiusSm),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      ),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text('$i')))
          .toList(),
      onChanged: onChanged,
    );
  }

  void _saveAppointment() {
    if (_titleController.text.isNotEmpty) {
      final DateTime finalDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (_isReminderEnabled && _reminderTime == null) {
        _reminderTime = finalDateTime.subtract(const Duration(minutes: 30));
      }

      final appointment = AppointmentModel(
        uuid: const Uuid().v4(),
        moduleId: widget.moduleId,
        title: _titleController.text,
        doctorName: _doctorController.text.isNotEmpty
            ? _doctorController.text
            : null,
        locationName: _locationController.text.isNotEmpty
            ? _locationController.text
            : null,
        appointmentDate: finalDateTime,
        type: _selectedType,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        reminderEnabled: _isReminderEnabled,
        reminderTime: _isReminderEnabled ? _reminderTime : null,
        reminderDaysBefore: _reminderDaysBefore,
        reminderHoursBefore: _reminderHoursBefore,
        reminderMinutesBefore: _reminderMinutesBefore,
      );

      widget.cubit.addAppointment(appointment);
      Navigator.pop(context);
    }
  }
}

