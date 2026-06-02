// lib/features/health/presentation/widgets/add_vital_sheet.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 6 | Part 1 | File 2
// ═══════════════════════════════════════════════════════════════════════════════

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
import 'package:athar/features/health/data/models/vital_sign_model.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

class AddVitalSheet extends StatefulWidget {
  final String moduleId;
  final HealthCubit cubit;

  const AddVitalSheet({super.key, required this.moduleId, required this.cubit});

  @override
  State<AddVitalSheet> createState() => _AddVitalSheetState();
}

class _AddVitalSheetState extends State<AddVitalSheet> {
  final _valueController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _unitController = TextEditingController();
  final _titleController = TextEditingController();

  String _selectedCategory = 'vital';
  String _selectedVitalType = 'weight';

  @override
  void initState() {
    super.initState();
    _updateUnit();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _diastolicController.dispose();
    _unitController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _updateUnit() {
    if (_selectedCategory == 'vital') {
      setState(() {
        switch (_selectedVitalType) {
          case 'weight':
            _unitController.text = 'kg';
            break;
          case 'temp':
            _unitController.text = '°C';
            break;
          case 'pressure':
            _unitController.text = 'mmHg';
            break;
          case 'sugar':
            _unitController.text = 'mg/dL';
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(
        24.w,
        24.h,
        24.w,
        MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        // ✅ Colors.white → colors.surface
        color: colorScheme.surface,
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
                  color: colorScheme.outlineVariant,
                  borderRadius: AtharRadii.radiusXxxs,
                ),
              ),
            ),
            AtharGap.xl,
            Text(
              l10n.vitalSheetTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            AtharGap.xl,

            // 1. نوع السجل
            Row(
              children: [
                Expanded(
                  child: _buildSegmentButton(
                    colorScheme,
                    'vital',
                    l10n.vitalSheetVitalSign,
                    Icons.show_chart,
                  ),
                ),
                AtharGap.hMd,
                Expanded(
                  child: _buildSegmentButton(
                    colorScheme,
                    'document',
                    l10n.vitalSheetGeneralNote,
                    Icons.text_snippet,
                  ),
                ),
              ],
            ),
            AtharGap.xl,

            // 2. إذا كان مؤشر حيوي
            if (_selectedCategory == 'vital') ...[
              Text(
                l10n.vitalSheetVitalType,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ).copyWith(),
              ),
              AtharGap.sm,
              Wrap(
                spacing: 8.w,
                children: [
                  _buildVitalTypeChip(
                    colorScheme,
                    'weight',
                    l10n.vitalSheetWeight,
                  ),
                  _buildVitalTypeChip(
                    colorScheme,
                    'temp',
                    l10n.vitalSheetTemperature,
                  ),
                  _buildVitalTypeChip(
                    colorScheme,
                    'pressure',
                    l10n.vitalSheetPressure,
                  ),
                  _buildVitalTypeChip(
                    colorScheme,
                    'sugar',
                    l10n.vitalSheetSugar,
                  ),
                ],
              ),
              AtharGap.lg,
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _valueController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: _selectedVitalType == 'pressure'
                            ? 'الانقباضي (SYS)'
                            : l10n.vitalSheetValue,
                        hintText: l10n.vitalSheetValueHint,
                        border: OutlineInputBorder(
                          borderRadius: AtharRadii.radiusMd,
                        ),
                      ),
                    ),
                  ),
                  AtharGap.hMd,
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _unitController,
                      decoration: InputDecoration(
                        labelText: l10n.vitalSheetUnit,
                        border: OutlineInputBorder(
                          borderRadius: AtharRadii.radiusMd,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_selectedVitalType == 'pressure') ...[
                AtharGap.md,
                TextField(
                  controller: _diastolicController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'الانبساطي (DIA)',
                    hintText: 'مثال: 80',
                    border: OutlineInputBorder(
                      borderRadius: AtharRadii.radiusMd,
                    ),
                  ),
                ),
              ],
            ] else ...[
              // 3. إذا كان ملاحظة
              TextField(
                controller: _titleController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.vitalSheetNoteLabel,
                  hintText: l10n.vitalSheetNoteHint,
                  border: OutlineInputBorder(borderRadius: AtharRadii.radiusMd),
                ),
              ),
            ],

            AtharGap.xxl,

            ElevatedButton(
              onPressed: _saveRecord,
              style: ElevatedButton.styleFrom(
                // ✅ AppColors.primary → colors.primary
                backgroundColor: colorScheme.primary,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: AtharRadii.radiusMd,
                ),
              ),
              child: Text(
                l10n.vitalSheetSaveButton,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentButton(
    ColorScheme colorScheme,
    String key,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedCategory == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = key),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          // ✅ AppColors.primary / Colors.grey.shade100 → colors
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          borderRadius: AtharRadii.radiusMd,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.onPrimary : colorScheme.outline,
              size: 18.sp,
            ),
            AtharGap.hSm,
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalTypeChip(
    ColorScheme colorScheme,
    String key,
    String label,
  ) {
    final isSelected = _selectedVitalType == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      // ✅ AppColors.primary → colors.primary
      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        setState(() => _selectedVitalType = key);
        _updateUnit();
      },
    );
  }

  void _saveRecord() {
    if (_selectedCategory == 'vital' && _valueController.text.isEmpty) return;
    if (_selectedCategory == 'document' && _titleController.text.isEmpty) {
      return;
    }

    final record = VitalSignModel(
      uuid: const Uuid().v4(),
      moduleId: widget.moduleId,
      recordDate: DateTime.now(),
      category: _selectedCategory,
      vitalType: _selectedCategory == 'vital' ? _selectedVitalType : null,
      vitalValue: double.tryParse(_valueController.text),
      vitalValueSecondary: _selectedVitalType == 'pressure'
          ? double.tryParse(_diastolicController.text)
          : null,
      vitalUnit: _unitController.text,
      title: _selectedCategory == 'document' ? _titleController.text : null,
    );

    widget.cubit.addVital(record);
    Navigator.pop(context);
  }
}

