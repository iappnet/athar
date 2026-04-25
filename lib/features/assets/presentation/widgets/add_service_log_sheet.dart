import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class AddServiceLogSheet extends StatefulWidget {
  final String serviceId;
  final String serviceName;

  const AddServiceLogSheet({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<AddServiceLogSheet> createState() => _AddServiceLogSheetState();
}

class _AddServiceLogSheetState extends State<AddServiceLogSheet> {
  final _formKey = GlobalKey<FormState>();

  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _performedDate = DateTime.now();

  @override
  void dispose() {
    _odometerController.dispose();
    _costController.dispose();
    _notesController.dispose();
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
                l10n.addServiceLogTitle(widget.serviceName),
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              AtharGap.sm,
              Text(
                l10n.addServiceLogSubtitle,
                style: TextStyle(fontSize: 12.sp, color: colorScheme.outline),
              ),
              AtharGap.xl,

              // 1. Date
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _performedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _performedDate = picked);
                },
                borderRadius: AtharRadii.card,
                child: Container(
                  padding: AtharSpacing.allXl,
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: AtharRadii.card,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.primary),
                      SizedBox(width: 12.w),
                      Text(
                        l10n.addServiceLogDate(
                          DateFormat('yyyy-MM-dd').format(_performedDate),
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AtharGap.lg,

              // 2. Odometer & Cost
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _odometerController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        colorScheme,
                        l10n.addServiceLogOdometerLabel,
                        Icons.speed,
                      ).copyWith(helperText: l10n.addServiceLogOdometerHint),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextFormField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        colorScheme,
                        l10n.addServiceLogCostLabel,
                        Icons.attach_money,
                      ).copyWith(helperText: l10n.addServiceLogCostHint),
                    ),
                  ),
                ],
              ),
              AtharGap.lg,

              // 3. Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: _inputDecoration(
                  colorScheme,
                  l10n.addServiceLogNotesLabel,
                  Icons.notes,
                ),
              ),

              AtharGap.xxl,

              // Save button
              ElevatedButton(
                onPressed: _saveLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(borderRadius: AtharRadii.card),
                ),
                child: Text(
                  l10n.addServiceLogSaveButton,
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

  void _saveLog() {
    final l10n = AppLocalizations.of(context);

    if (_formKey.currentState!.validate()) {
      final odometer = int.tryParse(_odometerController.text);
      final cost = double.tryParse(_costController.text);

      context.read<AssetsCubit>().addServiceLog(
        serviceId: widget.serviceId,
        date: _performedDate,
        odometer: odometer,
        cost: cost,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addServiceLogSuccess)));
    }
  }
}
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class AddServiceLogSheet extends StatefulWidget {
//   final String serviceId;
//   final String serviceName;

//   const AddServiceLogSheet({
//     super.key,
//     required this.serviceId,
//     required this.serviceName,
//   });

//   @override
//   State<AddServiceLogSheet> createState() => _AddServiceLogSheetState();
// }

// class _AddServiceLogSheetState extends State<AddServiceLogSheet> {
//   final _formKey = GlobalKey<FormState>();

//   final _odometerController = TextEditingController();
//   final _costController = TextEditingController();
//   final _notesController = TextEditingController();

//   DateTime _performedDate = DateTime.now();

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
//                 "تسجيل تنفيذ: ${widget.serviceName} ✅",
//                 style: TextStyle(
//                   fontFamily: 'Tajawal',
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               Text(
//                 "سيتم تحديث موعد الصيانة القادم تلقائياً بناءً على هذه البيانات.",
//                 style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//               ),
//               SizedBox(height: 20.h),

//               // 1. التاريخ (إجباري)
//               InkWell(
//                 onTap: () async {
//                   final picked = await showDatePicker(
//                     context: context,
//                     initialDate: _performedDate,
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime.now(),
//                   );
//                   if (picked != null) setState(() => _performedDate = picked);
//                 },
//                 child: Container(
//                   padding: EdgeInsets.all(16.w),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.calendar_today, color: AppColors.primary),
//                       SizedBox(width: 12.w),
//                       Text(
//                         "تاريخ التنفيذ: ${DateFormat('yyyy-MM-dd').format(_performedDate)}",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14.sp,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.h),

//               // 2. قراءة العداد والتكلفة
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _odometerController,
//                       keyboardType: TextInputType.number,
//                       decoration: _inputDecoration(
//                         "قراءة العداد",
//                         Icons.speed,
//                       ).copyWith(helperText: "كم الحالي"),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _costController,
//                       keyboardType: TextInputType.number,
//                       decoration: _inputDecoration(
//                         "التكلفة",
//                         Icons.attach_money,
//                       ).copyWith(helperText: "اختياري"),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16.h),

//               // 3. ملاحظات
//               TextFormField(
//                 controller: _notesController,
//                 maxLines: 2,
//                 decoration: _inputDecoration(
//                   "ملاحظات (مثلاً: نوع الزيت)",
//                   Icons.notes,
//                 ),
//               ),

//               SizedBox(height: 24.h),

//               // زر الحفظ
//               ElevatedButton(
//                 onPressed: _saveLog,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   minimumSize: Size(double.infinity, 50.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 child: const Text(
//                   "حفظ وتحديث الموعد القادم",
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

//   void _saveLog() {
//     if (_formKey.currentState!.validate()) {
//       final odometer = int.tryParse(_odometerController.text);
//       final cost = double.tryParse(_costController.text);

//       context.read<AssetsCubit>().addServiceLog(
//         serviceId: widget.serviceId,
//         date: _performedDate,
//         odometer: odometer,
//         cost: cost,
//         notes: _notesController.text.isNotEmpty ? _notesController.text : null,
//       );

//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("تم تسجيل الصيانة وتحديث التوقعات ✅")),
//       );
//     }
//   }
// }
//-----------------------------------------------------------------------
