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
  final _unitController = TextEditingController();
  final _titleController = TextEditingController();

  String _selectedCategory = 'vital';
  String _selectedVitalType = 'weight';

  @override
  void initState() {
    super.initState();
    _updateUnit();
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
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.vitalSheetTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),

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
            SizedBox(height: 20.h),

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
                        labelText: l10n.vitalSheetValue,
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

            SizedBox(height: 24.h),

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
                style: const TextStyle(
                  color: Colors.white,
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
              color: isSelected ? Colors.white : colorScheme.outline,
              size: 18.sp,
            ),
            AtharGap.hSm,
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
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
      vitalUnit: _unitController.text,
      title: _selectedCategory == 'document' ? _titleController.text : null,
    );

    widget.cubit.addVital(record);
    Navigator.pop(context);
  }
}
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/health/presentation/cubit/health_cubit.dart';
// import 'package:athar/features/health/data/models/vital_sign_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:uuid/uuid.dart';

// class AddVitalSheet extends StatefulWidget {
//   final String moduleId;
//   final HealthCubit cubit;

//   const AddVitalSheet({super.key, required this.moduleId, required this.cubit});

//   @override
//   State<AddVitalSheet> createState() => _AddVitalSheetState();
// }

// class _AddVitalSheetState extends State<AddVitalSheet> {
//   final _valueController = TextEditingController();
//   final _unitController = TextEditingController();
//   final _titleController = TextEditingController(); // للملاحظات

//   String _selectedCategory = 'vital'; // vital, document
//   String _selectedVitalType = 'weight'; // weight, temp, pressure, sugar

//   @override
//   void initState() {
//     super.initState();
//     _updateUnit(); // تعبئة الوحدة الافتراضية
//   }

//   void _updateUnit() {
//     if (_selectedCategory == 'vital') {
//       setState(() {
//         switch (_selectedVitalType) {
//           case 'weight':
//             _unitController.text = 'kg';
//             break;
//           case 'temp':
//             _unitController.text = '°C';
//             break;
//           case 'pressure':
//             _unitController.text = 'mmHg';
//             break;
//           case 'sugar':
//             _unitController.text = 'mg/dL';
//             break;
//         }
//       });
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
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
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
//               "تسجيل جديد 📈",
//               style: TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 20.h),

//             // 1. نوع السجل (مؤشر حيوي أم ملاحظة)
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildSegmentButton(
//                     'vital',
//                     "مؤشر حيوي",
//                     Icons.show_chart,
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: _buildSegmentButton(
//                     'document',
//                     "ملاحظة عامة",
//                     Icons.text_snippet,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20.h),

//             // 2. إذا كان مؤشر حيوي
//             if (_selectedCategory == 'vital') ...[
//               Text(
//                 "نوع المؤشر:",
//                 style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.sp),
//               ),
//               SizedBox(height: 8.h),
//               Wrap(
//                 spacing: 8.w,
//                 children: [
//                   _buildVitalTypeChip('weight', "وزن"),
//                   _buildVitalTypeChip('temp', "حرارة"),
//                   _buildVitalTypeChip('pressure', "ضغط"),
//                   _buildVitalTypeChip('sugar', "سكر"),
//                 ],
//               ),
//               SizedBox(height: 16.h),
//               Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: TextField(
//                       controller: _valueController,
//                       keyboardType: TextInputType.number,
//                       autofocus: true,
//                       decoration: InputDecoration(
//                         labelText: "القيمة",
//                         hintText: "مثلاً: 70",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     flex: 1,
//                     child: TextField(
//                       controller: _unitController,
//                       decoration: InputDecoration(
//                         labelText: "الوحدة",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ] else ...[
//               // 3. إذا كان ملاحظة
//               TextField(
//                 controller: _titleController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: "نص الملاحظة",
//                   hintText: "اكتب ملاحظاتك الطبية هنا...",
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//               ),
//             ],

//             SizedBox(height: 24.h),

//             ElevatedButton(
//               onPressed: _saveRecord,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primary,
//                 minimumSize: Size(double.infinity, 50.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//               ),
//               child: const Text(
//                 "حفظ السجل",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Tajawal',
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSegmentButton(String key, String label, IconData icon) {
//     final isSelected = _selectedCategory == key;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedCategory = key),
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 12.h),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.primary : Colors.grey.shade100,
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? Colors.white : Colors.grey,
//               size: 18.sp,
//             ),
//             SizedBox(width: 8.w),
//             Text(
//               label,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.grey.shade700,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildVitalTypeChip(String key, String label) {
//     final isSelected = _selectedVitalType == key;
//     return ChoiceChip(
//       label: Text(label),
//       selected: isSelected,
//       selectedColor: AppColors.primary.withOpacity(0.2),
//       labelStyle: TextStyle(
//         color: isSelected ? AppColors.primary : Colors.black,
//         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//       ),
//       onSelected: (val) {
//         setState(() => _selectedVitalType = key);
//         _updateUnit();
//       },
//     );
//   }

//   void _saveRecord() {
//     // التحقق البسيط
//     if (_selectedCategory == 'vital' && _valueController.text.isEmpty) return;
//     if (_selectedCategory == 'document' && _titleController.text.isEmpty)
//       return;

//     final record = VitalSignModel(
//       uuid: const Uuid().v4(),
//       moduleId: widget.moduleId,
//       recordDate: DateTime.now(),
//       category: _selectedCategory,

//       // للمؤشرات
//       vitalType: _selectedCategory == 'vital' ? _selectedVitalType : null,
//       vitalValue: double.tryParse(_valueController.text),
//       vitalUnit: _unitController.text,

//       // للملاحظات
//       title: _selectedCategory == 'document' ? _titleController.text : null,
//     );

//     widget.cubit.addVital(record);
//     Navigator.pop(context);
//   }
// }
//-----------------------------------------------------------------------
