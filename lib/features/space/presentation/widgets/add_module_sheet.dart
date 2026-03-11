import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart';
import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/module_model.dart';
import '../cubit/module_cubit.dart';
import 'package:intl/intl.dart';

class AddModuleSheet extends StatefulWidget {
  final String? forcedType;
  final ModuleModel? moduleToEdit;
  final String? spaceId; // ✅ إضافة معرف المساحة لضمان الدقة

  const AddModuleSheet({
    super.key,
    this.forcedType,
    this.moduleToEdit,
    this.spaceId,
  });

  @override
  State<AddModuleSheet> createState() => _AddModuleSheetState();
}

class _AddModuleSheetState extends State<AddModuleSheet> {
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late int _selectedColor;
  DateTime? _endDate;

  // ✅ متغيرات التذكير الجديدة
  DateTime? _reminderTime;
  bool _isReminderEnabled = false;

  final List<Color> _colors = const [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF795548),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.moduleToEdit?.name);
    _descController = TextEditingController(
      text: widget.moduleToEdit?.description,
    );
    _selectedColor = widget.moduleToEdit?.color ?? _colors[0].value;
    _endDate = widget.moduleToEdit?.endDate;

    // ✅ تهيئة التذكير في حالة التعديل
    if (widget.moduleToEdit != null &&
        widget.moduleToEdit!.reminderTime != null) {
      _reminderTime = widget.moduleToEdit!.reminderTime;
      _isReminderEnabled = widget.moduleToEdit!.reminderEnabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isProject =
        (widget.forcedType ?? widget.moduleToEdit?.type) == 'project';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        left: AtharSpacing.xl,
        right: AtharSpacing.xl,
        top: 20.h,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.bottomSheet,
      ),
      child: SingleChildScrollView(
        // ✅ إضافة للسماح بالتمرير عند ظهور التذكير
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: AtharRadii.radiusFull,
                ),
              ),
            ),
            AtharGap.xl,
            Text(
              isProject
                  ? (widget.moduleToEdit != null
                        ? l10n.addModuleEditProject
                        : l10n.addModuleNewProject)
                  : l10n.addModuleTitle,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            AtharGap.xl,
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: isProject
                    ? l10n.addModuleProjectNameLabel
                    : l10n.addModuleNameLabel,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: AtharRadii.card,
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            if (isProject) ...[
              AtharGap.lg,
              _buildDatePicker(colorScheme, l10n),
              AtharGap.lg,

              // ✅ الخطوة الجوهرية: دمج مكون التذكير الموحد
              ReminderPickerWidget(
                reminderTime: _reminderTime,
                isEnabled: _isReminderEnabled,
                onToggle: (val) => setState(() => _isReminderEnabled = val),
                onTimeChanged: (newTime) =>
                    setState(() => _reminderTime = newTime),
              ),
            ],

            AtharGap.xxxl,
            _buildSaveButton(colorScheme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AtharRadii.card,
      ),
      child: ListTile(
        leading: Icon(Icons.calendar_month_rounded, color: colorScheme.primary),
        title: Text(
          _endDate == null
              ? l10n.addModuleDeadlineHint
              : DateFormat('yyyy-MM-dd').format(_endDate!),
          style: TextStyle(
            fontSize: 14.sp,
            color: _endDate == null
                ? colorScheme.outline
                : colorScheme.onSurface,
          ),
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _endDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
          );
          if (date != null) setState(() => _endDate = date);
        },
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: AtharRadii.card),
        ),
        child: Text(
          l10n.addModuleSave,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _save() {
    if (_nameController.text.isEmpty) return;

    final cubit = context.read<ModuleCubit>();
    final spaceId = widget.spaceId ?? "default_space";

    if (widget.moduleToEdit != null) {
      final updated = widget.moduleToEdit!
        ..name = _nameController.text
        ..description = _descController.text
        ..color = _selectedColor
        ..endDate = _endDate
        ..reminderEnabled = _isReminderEnabled
        ..reminderTime = _reminderTime;
      cubit.updateModule(updated);
    } else {
      cubit.createModule(
        spaceId,
        _nameController.text,
        widget.forcedType ?? 'project',
        description: _descController.text,
        endDate: _endDate,
        reminderEnabled: _isReminderEnabled,
        reminderTime: _reminderTime,
      );
    }
    Navigator.pop(context);
  }
}
//----------------------------------------------------------------------
// import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart'; // ✅ الاستيراد الجديد
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../data/models/module_model.dart';
// import '../cubit/module_cubit.dart';
// import 'package:intl/intl.dart';

// class AddModuleSheet extends StatefulWidget {
//   final String? forcedType;
//   final ModuleModel? moduleToEdit;
//   final String? spaceId; // ✅ إضافة معرف المساحة لضمان الدقة

//   const AddModuleSheet({
//     super.key,
//     this.forcedType,
//     this.moduleToEdit,
//     this.spaceId,
//   });

//   @override
//   State<AddModuleSheet> createState() => _AddModuleSheetState();
// }

// class _AddModuleSheetState extends State<AddModuleSheet> {
//   late TextEditingController _nameController;
//   late TextEditingController _descController;
//   late int _selectedColor;
//   DateTime? _endDate;

//   // ✅ متغيرات التذكير الجديدة
//   DateTime? _reminderTime;
//   bool _isReminderEnabled = false;

//   final List<Color> _colors = const [
//     Color(0xFF4CAF50),
//     Color(0xFF2196F3),
//     Color(0xFF9C27B0),
//     Color(0xFFFF9800),
//     Color(0xFFE91E63),
//     Color(0xFF795548),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: widget.moduleToEdit?.name);
//     _descController = TextEditingController(
//       text: widget.moduleToEdit?.description,
//     );
//     _selectedColor = widget.moduleToEdit?.color ?? _colors[0].value;
//     _endDate = widget.moduleToEdit?.endDate;

//     // ✅ تهيئة التذكير في حالة التعديل
//     if (widget.moduleToEdit != null &&
//         widget.moduleToEdit!.reminderTime != null) {
//       _reminderTime = widget.moduleToEdit!.reminderTime;
//       _isReminderEnabled = widget.moduleToEdit!.reminderEnabled;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isProject =
//         (widget.forcedType ?? widget.moduleToEdit?.type) == 'project';

//     return Container(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
//         left: 20.w,
//         right: 20.w,
//         top: 20.h,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: SingleChildScrollView(
//         // ✅ إضافة للسماح بالتمرير عند ظهور التذكير
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
//               isProject
//                   ? (widget.moduleToEdit != null
//                         ? "تعديل المشروع"
//                         : "مشروع جديد 🚀")
//                   : "إضافة موديول",
//               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20.h),
//             TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: "اسم ${isProject ? 'المشروع' : 'الموديول'}",
//                 filled: true,
//                 fillColor: AppColors.background,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),

//             if (isProject) ...[
//               SizedBox(height: 16.h),
//               _buildDatePicker(),
//               SizedBox(height: 16.h),

//               // ✅ الخطوة الجوهرية: دمج مكون التذكير الموحد
//               ReminderPickerWidget(
//                 reminderTime: _reminderTime,
//                 isEnabled: _isReminderEnabled,
//                 onToggle: (val) => setState(() => _isReminderEnabled = val),
//                 onTimeChanged: (newTime) =>
//                     setState(() => _reminderTime = newTime),
//               ),
//             ],

//             SizedBox(height: 30.h),
//             _buildSaveButton(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDatePicker() {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.background,
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: ListTile(
//         leading: const Icon(
//           Icons.calendar_month_rounded,
//           color: AppColors.primary,
//         ),
//         title: Text(
//           _endDate == null
//               ? "موعد التسليم (اختياري)"
//               : DateFormat('yyyy-MM-dd').format(_endDate!),
//           style: TextStyle(
//             fontSize: 14.sp,
//             color: _endDate == null ? Colors.grey : Colors.black,
//           ),
//         ),
//         onTap: () async {
//           final date = await showDatePicker(
//             context: context,
//             initialDate: _endDate ?? DateTime.now(),
//             firstDate: DateTime.now(),
//             lastDate: DateTime(2030),
//           );
//           if (date != null) setState(() => _endDate = date);
//         },
//       ),
//     );
//   }

//   Widget _buildSaveButton() {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _save,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           padding: EdgeInsets.symmetric(vertical: 14.h),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//         ),
//         child: const Text(
//           "حفظ",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }

//   void _save() {
//     if (_nameController.text.isEmpty) return;

//     final cubit = context.read<ModuleCubit>();
//     final spaceId = widget.spaceId ?? "default_space";

//     if (widget.moduleToEdit != null) {
//       final updated = widget.moduleToEdit!
//         ..name = _nameController.text
//         ..description = _descController.text
//         ..color = _selectedColor
//         ..endDate = _endDate
//         ..reminderEnabled = _isReminderEnabled
//         ..reminderTime = _reminderTime;
//       cubit.updateModule(updated);
//     } else {
//       cubit.createModule(
//         spaceId,
//         _nameController.text,
//         widget.forcedType ?? 'project',
//         description: _descController.text,
//         endDate: _endDate,
//         reminderEnabled: _isReminderEnabled,
//         reminderTime: _reminderTime,
//       );
//     }
//     Navigator.pop(context);
//   }
// }
