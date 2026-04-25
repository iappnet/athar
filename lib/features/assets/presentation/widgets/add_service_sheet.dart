import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart';
import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddServiceSheet extends StatefulWidget {
  final String assetId;

  const AddServiceSheet({super.key, required this.assetId});

  @override
  State<AddServiceSheet> createState() => _AddServiceSheetState();
}

class _AddServiceSheetState extends State<AddServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _daysController = TextEditingController();
  final _kmController = TextEditingController();

  DateTime? _reminderTime;
  bool _isReminderEnabled = true;

  @override
  void dispose() {
    _nameController.dispose();
    _daysController.dispose();
    _kmController.dispose();
    super.dispose();
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
              // Handle bar
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
              AtharGap.xl,

              Text(
                l10n.addServiceTitle,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              AtharGap.sm,
              Text(
                l10n.addServiceSubtitle,
                style: TextStyle(fontSize: 12.sp, color: colorScheme.outline),
              ),
              AtharGap.xl,

              // 1. Service name
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration(
                  colorScheme,
                  l10n.addServiceNameLabel,
                  Icons.build_circle_outlined,
                ),
                validator: (val) =>
                    val!.isEmpty ? l10n.addServiceNameRequired : null,
              ),
              AtharGap.lg,

              // 2. Repeat rules
              Text(
                l10n.addServiceRepeatLabel,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              AtharGap.sm,

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _daysController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        colorScheme,
                        l10n.addServiceDaysLabel,
                        Icons.calendar_today,
                      ).copyWith(suffixText: l10n.addServiceDaysSuffix),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextFormField(
                      controller: _kmController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        colorScheme,
                        l10n.addServiceKmLabel,
                        Icons.speed,
                      ).copyWith(suffixText: l10n.addServiceKmSuffix),
                    ),
                  ),
                ],
              ),
              AtharGap.sm,
              Text(
                l10n.addServiceRepeatHint,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.orange.shade800,
                ),
              ),

              AtharGap.xxl,

              // Reminder picker
              ReminderPickerWidget(
                reminderTime: _reminderTime,
                isEnabled: _isReminderEnabled,
                onToggle: (val) => setState(() => _isReminderEnabled = val),
                onTimeChanged: (newTime) =>
                    setState(() => _reminderTime = newTime),
              ),

              AtharGap.xxl,

              // Save button
              ElevatedButton(
                onPressed: _saveService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(borderRadius: AtharRadii.card),
                ),
                child: Text(
                  l10n.addServiceSaveButton,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    ColorScheme colorScheme,
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20.sp, color: colorScheme.outline),
      border: OutlineInputBorder(borderRadius: AtharRadii.card),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }

  void _saveService() {
    final l10n = AppLocalizations.of(context);

    if (_formKey.currentState!.validate()) {
      final days = int.tryParse(_daysController.text);
      final km = int.tryParse(_kmController.text);

      if (days == null && km == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.addServiceRepeatRequired)));
        return;
      }

      context.read<AssetsCubit>().addService(
        assetId: widget.assetId,
        name: _nameController.text,
        repeatDays: days,
        repeatKm: km,
        reminderTime: _reminderTime,
        reminderEnabled: _isReminderEnabled,
      );

      Navigator.pop(context);
    }
  }
}
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart';
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class AddServiceSheet extends StatefulWidget {
//   final String assetId;

//   const AddServiceSheet({super.key, required this.assetId});

//   @override
//   State<AddServiceSheet> createState() => _AddServiceSheetState();
// }

// class _AddServiceSheetState extends State<AddServiceSheet> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _daysController = TextEditingController();
//   final _kmController = TextEditingController();

//   // ✅ متغيرات التذكير الجديدة
//   DateTime? _reminderTime;
//   bool _isReminderEnabled = true;

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
//               // مؤشر السحب
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
//                 "تعريف خدمة صيانة جديدة 🛠️",
//                 style: TextStyle(
//                   fontFamily: 'Tajawal',
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               Text(
//                 "حدد نوع الصيانة وقواعد تكرارها ليقوم النظام بتذكيدك.",
//                 style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//               ),
//               SizedBox(height: 20.h),

//               // 1. اسم الخدمة
//               TextFormField(
//                 controller: _nameController,
//                 decoration: _inputDecoration(
//                   "اسم الخدمة (مثلاً: غيار زيت)",
//                   Icons.build_circle_outlined,
//                 ),
//                 validator: (val) => val!.isEmpty ? "الاسم مطلوب" : null,
//               ),
//               SizedBox(height: 16.h),

//               // 2. قواعد التكرار
//               Text(
//                 "تتكرر هذه الصيانة كل:",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
//               ),
//               SizedBox(height: 8.h),

//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _daysController,
//                       keyboardType: TextInputType.number,
//                       decoration: _inputDecoration(
//                         "عدد الأيام",
//                         Icons.calendar_today,
//                       ).copyWith(suffixText: "يوم"),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _kmController,
//                       keyboardType: TextInputType.number,
//                       decoration: _inputDecoration(
//                         "المسافة",
//                         Icons.speed,
//                       ).copyWith(suffixText: "كم"),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 8.h),
//               Text(
//                 "* يمكنك تعبئة الحقلين معاً، وسينبهك النظام أيهما يأتي أولاً.",
//                 style: TextStyle(
//                   fontSize: 11.sp,
//                   color: Colors.orange.shade800,
//                 ),
//               ),

//               SizedBox(height: 24.h),

//               // ✅ الخطوة الجوهرية: حقن مكون التذكير الموحد
//               ReminderPickerWidget(
//                 reminderTime: _reminderTime,
//                 isEnabled: _isReminderEnabled,
//                 onToggle: (val) => setState(() => _isReminderEnabled = val),
//                 onTimeChanged: (newTime) =>
//                     setState(() => _reminderTime = newTime),
//               ),

//               SizedBox(height: 24.h),

//               // زر الحفظ
//               ElevatedButton(
//                 onPressed: _saveService,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   minimumSize: Size(double.infinity, 50.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 child: const Text(
//                   "حفظ الخدمة",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String label, IconData icon) {
//     return InputDecoration(
//       labelText: label,
//       prefixIcon: Icon(icon, size: 20.sp, color: Colors.grey),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
//       contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//     );
//   }

//   void _saveService() {
//     if (_formKey.currentState!.validate()) {
//       final days = int.tryParse(_daysController.text);
//       final km = int.tryParse(_kmController.text);

//       if (days == null && km == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("يجب تحديد قاعدة تكرار واحدة على الأقل (أيام أو كم)"),
//           ),
//         );
//         return;
//       }

//       context.read<AssetsCubit>().addService(
//         assetId: widget.assetId,
//         name: _nameController.text,
//         repeatDays: days,
//         repeatKm: km,
//         reminderTime: _reminderTime, // ✅ تمرير الوقت
//         reminderEnabled: _isReminderEnabled, // ✅ تمرير الحالة
//       );

//       Navigator.pop(context);
//     }
//   }
// }
//-----------------------------------------------------------------------
