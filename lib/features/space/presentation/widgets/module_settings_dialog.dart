import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/space/data/models/delegation_mode.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/space/presentation/cubit/module_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ModuleSettingsDialog extends StatefulWidget {
  final ModuleModel module;

  const ModuleSettingsDialog({super.key, required this.module});

  @override
  State<ModuleSettingsDialog> createState() => _ModuleSettingsDialogState();
}

class _ModuleSettingsDialogState extends State<ModuleSettingsDialog> {
  late DelegationMode _selectedMode;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.module.delegationMode;
  }

  String _getContextMessage(AppLocalizations l10n) {
    switch (widget.module.type) {
      case 'health':
        return l10n.moduleSettingsContextHealth;
      case 'assets':
        return l10n.moduleSettingsContextAssets;
      case 'list':
        return l10n.moduleSettingsContextList;
      case 'project':
      default:
        return l10n.moduleSettingsContextProject;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.settings, color: colorScheme.primary),
          AtharGap.hSm,
          Text(l10n.moduleSettingsTitle, style: TextStyle(fontSize: 18.sp)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.module.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            ),
            AtharGap.sm,
            Text(
              _getContextMessage(l10n),
              style: TextStyle(color: colorScheme.outline, fontSize: 12.sp),
            ),
            const Divider(),
            AtharGap.sm,
            Text(
              l10n.moduleSettingsDelegationLabel,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            AtharGap.sm,

            // ✅ الحل الصحيح للنسخة 3.38+:
            // 1. نغلف الخيارات بـ RadioGroup
            // 2. نستخدم groupValue هنا (وليس value)
            RadioGroup<DelegationMode>(
              groupValue: _selectedMode, // ✅ الاسم الصحيح للباراميتر
              onChanged: (DelegationMode? val) {
                if (val != null) {
                  setState(() => _selectedMode = val);
                }
              },
              child: Column(
                children: [
                  _buildRadioOption(
                    colorScheme: colorScheme,
                    value: DelegationMode.inherit,
                    title: l10n.moduleSettingsModeInherit,
                    subtitle: l10n.moduleSettingsModeInheritDesc,
                  ),
                  _buildRadioOption(
                    colorScheme: colorScheme,
                    value: DelegationMode.enabled,
                    title: l10n.moduleSettingsModeEnabled,
                    subtitle: l10n.moduleSettingsModeEnabledDesc,
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green,
                  ),
                  _buildRadioOption(
                    colorScheme: colorScheme,
                    value: DelegationMode.disabled,
                    title: l10n.moduleSettingsModeDisabled,
                    subtitle: l10n.moduleSettingsModeDisabledDesc,
                    icon: Icons.lock_outline,
                    iconColor: colorScheme.error,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.moduleSettingsCancel),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<ModuleCubit>().updateModuleDelegation(
              widget.module,
              _selectedMode,
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.moduleSettingsSaveSuccess)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: Text(l10n.moduleSettingsSave),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required ColorScheme colorScheme,
    required DelegationMode value,
    required String title,
    required String subtitle,
    IconData? icon,
    Color? iconColor,
  }) {
    // ✅ نستخدم InkWell مع Radio للحفاظ على التخصيص
    // ✅ نزيل groupValue و onChanged من Radio (لأن RadioGroup تكفلت بها)
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMode = value;
        });
      },
      borderRadius: AtharRadii.radiusSm,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<DelegationMode>(
              value: value,
              // ❌ تم حذف groupValue (موروث من RadioGroup)
              // ❌ تم حذف onChanged (موروث من RadioGroup)
              activeColor: colorScheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: _selectedMode == value
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (icon != null) ...[
                        AtharGap.hSm,
                        Icon(icon, size: 16.sp, color: iconColor),
                      ],
                    ],
                  ),
                  AtharGap.xxxs,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//----------------------------------------------------------------------

// import 'package:athar/features/space/data/models/delegation_mode.dart';
// import 'package:athar/features/space/data/models/module_model.dart';
// import 'package:athar/features/space/presentation/cubit/module_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';

// class ModuleSettingsDialog extends StatefulWidget {
//   final ModuleModel module;

//   const ModuleSettingsDialog({super.key, required this.module});

//   @override
//   State<ModuleSettingsDialog> createState() => _ModuleSettingsDialogState();
// }

// class _ModuleSettingsDialogState extends State<ModuleSettingsDialog> {
//   late DelegationMode _selectedMode;

//   @override
//   void initState() {
//     super.initState();
//     _selectedMode = widget.module.delegationMode;
//   }

//   String _getContextMessage() {
//     switch (widget.module.type) {
//       case 'health':
//         return "صلاحيات متابعة الأدوية والمهام الصحية";
//       case 'assets':
//         return "صلاحيات تعيين مسؤوليات الصيانة والجرد";
//       case 'list':
//         return "صلاحيات قائمة المشتريات والمهام";
//       case 'project':
//       default:
//         return "صلاحيات إسناد وتفويض مهام المشروع";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Row(
//         children: [
//           Icon(Icons.settings, color: AppColors.primary),
//           SizedBox(width: 8.w),
//           Text(
//             "إعدادات الموديول",
//             style: TextStyle(fontFamily: 'Tajawal', fontSize: 18.sp),
//           ),
//         ],
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.module.name,
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               _getContextMessage(),
//               style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//             ),
//             const Divider(),
//             SizedBox(height: 8.h),
//             Text(
//               "نظام التفويض (Delegation):",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
//             ),
//             SizedBox(height: 8.h),

//             // ✅ الحل الصحيح للنسخة 3.38+:
//             // 1. نغلف الخيارات بـ RadioGroup
//             // 2. نستخدم groupValue هنا (وليس value)
//             RadioGroup<DelegationMode>(
//               groupValue: _selectedMode, // ✅ الاسم الصحيح للباراميتر
//               onChanged: (DelegationMode? val) {
//                 if (val != null) {
//                   setState(() => _selectedMode = val);
//                 }
//               },
//               child: Column(
//                 children: [
//                   _buildRadioOption(
//                     value: DelegationMode.inherit,
//                     title: "افتراضي (يتبع المساحة)",
//                     subtitle: "تطبق إعدادات المساحة العامة",
//                   ),
//                   _buildRadioOption(
//                     value: DelegationMode.enabled,
//                     title: "مسموح دائماً",
//                     subtitle: "يستطيع الأعضاء سحب وإسناد المهام بحرية",
//                     icon: Icons.check_circle_outline,
//                     iconColor: Colors.green,
//                   ),
//                   _buildRadioOption(
//                     value: DelegationMode.disabled,
//                     title: "محمي (ممنوع)",
//                     subtitle: "لا يمكن للأعضاء تغيير المسؤولين (للمدراء فقط)",
//                     icon: Icons.lock_outline,
//                     iconColor: Colors.red,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("إلغاء"),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             context.read<ModuleCubit>().updateModuleDelegation(
//               widget.module,
//               _selectedMode,
//             );
//             Navigator.pop(context);
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("تم تحديث الصلاحيات بنجاح ✅")),
//             );
//           },
//           style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//           child: const Text("حفظ", style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }

//   Widget _buildRadioOption({
//     required DelegationMode value,
//     required String title,
//     required String subtitle,
//     IconData? icon,
//     Color? iconColor,
//   }) {
//     // ✅ نستخدم InkWell مع Radio للحفاظ على التخصيص
//     // ✅ نزيل groupValue و onChanged من Radio (لأن RadioGroup تكفلت بها)
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedMode = value;
//         });
//       },
//       borderRadius: BorderRadius.circular(8.r),
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 4.h),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Radio<DelegationMode>(
//               value: value,
//               // ❌ تم حذف groupValue (موروث من RadioGroup)
//               // ❌ تم حذف onChanged (موروث من RadioGroup)
//               activeColor: AppColors.primary,
//               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontFamily: 'Tajawal',
//                           fontWeight: _selectedMode == value
//                               ? FontWeight.bold
//                               : FontWeight.normal,
//                         ),
//                       ),
//                       if (icon != null) ...[
//                         SizedBox(width: 8.w),
//                         Icon(icon, size: 16.sp, color: iconColor),
//                       ],
//                     ],
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 10.sp,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//----------------------------------------------------------------------

// import 'package:athar/features/space/data/models/delegation_mode.dart';
// import 'package:athar/features/space/data/models/module_model.dart';
// import 'package:athar/features/space/presentation/cubit/module_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/theme/app_colors.dart';

// class ModuleSettingsDialog extends StatefulWidget {
//   final ModuleModel module;

//   const ModuleSettingsDialog({super.key, required this.module});

//   @override
//   State<ModuleSettingsDialog> createState() => _ModuleSettingsDialogState();
// }

// class _ModuleSettingsDialogState extends State<ModuleSettingsDialog> {
//   late DelegationMode _selectedMode;

//   @override
//   void initState() {
//     super.initState();
//     _selectedMode = widget.module.delegationMode;
//   }

//   String _getContextMessage() {
//     switch (widget.module.type) {
//       case 'health':
//         return "صلاحيات متابعة الأدوية والمهام الصحية";
//       case 'assets':
//         return "صلاحيات تعيين مسؤوليات الصيانة والجرد";
//       case 'list':
//         return "صلاحيات قائمة المشتريات والمهام";
//       case 'project':
//       default:
//         return "صلاحيات إسناد وتفويض مهام المشروع";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Row(
//         children: [
//           Icon(Icons.settings, color: AppColors.primary),
//           SizedBox(width: 8.w),
//           Text(
//             "إعدادات الموديول",
//             style: TextStyle(fontFamily: 'Tajawal', fontSize: 18.sp),
//           ),
//         ],
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.module.name,
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               _getContextMessage(),
//               style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//             ),
//             const Divider(),
//             SizedBox(height: 8.h),
//             Text(
//               "نظام التفويض (Delegation):",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
//             ),
//             SizedBox(height: 8.h),

//             // ✅ التصحيح: استبدال RadioGroup بـ Column عادي
//             // Flutter لا يحتوي على RadioGroup، التحكم يتم عبر المتغير _selectedMode
//             Column(
//               children: [
//                 _buildRadioOption(
//                   value: DelegationMode.inherit,
//                   title: "افتراضي (يتبع المساحة)",
//                   subtitle: "تطبق إعدادات المساحة العامة",
//                 ),
//                 _buildRadioOption(
//                   value: DelegationMode.enabled,
//                   title: "مسموح دائماً",
//                   subtitle: "يستطيع الأعضاء سحب وإسناد المهام بحرية",
//                   icon: Icons.check_circle_outline,
//                   iconColor: Colors.green,
//                 ),
//                 _buildRadioOption(
//                   value: DelegationMode.disabled,
//                   title: "محمي (ممنوع)",
//                   subtitle: "لا يمكن للأعضاء تغيير المسؤولين (للمدراء فقط)",
//                   icon: Icons.lock_outline,
//                   iconColor: Colors.red,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("إلغاء"),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             context.read<ModuleCubit>().updateModuleDelegation(
//               widget.module,
//               _selectedMode,
//             );
//             Navigator.pop(context);
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text("تم تحديث الصلاحيات بنجاح ✅")),
//             );
//           },
//           style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//           child: const Text("حفظ", style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }

//   Widget _buildRadioOption({
//     required DelegationMode value,
//     required String title,
//     required String subtitle,
//     IconData? icon,
//     Color? iconColor,
//   }) {
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedMode = value;
//         });
//       },
//       borderRadius: BorderRadius.circular(8.r),
//       child: Padding(
//         padding: EdgeInsets.symmetric(vertical: 4.h),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ✅ التصحيح: إعادة groupValue و onChanged للراديو القياسي
//             Radio<DelegationMode>(
//               value: value,
//               groupValue: _selectedMode,
//               onChanged: (val) {
//                 if (val != null) setState(() => _selectedMode = val);
//               },
//               activeColor: AppColors.primary,
//               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//             ),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         title,
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontFamily: 'Tajawal',
//                           fontWeight: _selectedMode == value
//                               ? FontWeight.bold
//                               : FontWeight.normal,
//                         ),
//                       ),
//                       if (icon != null) ...[
//                         SizedBox(width: 8.w),
//                         Icon(icon, size: 16.sp, color: iconColor),
//                       ],
//                     ],
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 10.sp,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
