import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/space/data/models/space_model.dart';
import 'package:athar/features/space/presentation/cubit/space_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpaceSettingsDialog extends StatefulWidget {
  final SpaceModel space;

  const SpaceSettingsDialog({super.key, required this.space});

  @override
  State<SpaceSettingsDialog> createState() => _SpaceSettingsDialogState();
}

class _SpaceSettingsDialogState extends State<SpaceSettingsDialog> {
  late bool _allowDelegation;

  @override
  void initState() {
    super.initState();
    _allowDelegation = widget.space.allowMemberDelegation;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.admin_panel_settings, color: colorScheme.primary),
          AtharGap.hSm,
          Text(
            l10n.spaceSettingsDialogTitle,
            style: TextStyle(fontSize: 18.sp),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.spaceSettingsDialogDesc(widget.space.name),
            style: TextStyle(color: colorScheme.outline, fontSize: 12.sp),
          ),
          AtharGap.lg,
          SwitchListTile(
            title: Text(
              l10n.spaceSettingsDelegationToggle,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            subtitle: Text(
              _allowDelegation
                  ? l10n.spaceSettingsDelegationOnDesc
                  : l10n.spaceSettingsDelegationOffDesc,
              style: TextStyle(fontSize: 10.sp),
            ),
            value: _allowDelegation,
            activeThumbColor: colorScheme.primary,
            onChanged: (val) {
              setState(() {
                _allowDelegation = val;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final messenger = ScaffoldMessenger.of(context);

            context.read<SpaceCubit>().updateSpaceDelegation(
              widget.space.uuid,
              _allowDelegation,
            );

            Navigator.pop(context);

            messenger.showSnackBar(
              SnackBar(content: Text(l10n.spaceSettingsUpdateSuccess)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
//----------------------------------------------------------------------
// import 'package:athar/features/space/data/models/space_model.dart';
// import 'package:athar/features/space/presentation/cubit/space_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';

// class SpaceSettingsDialog extends StatefulWidget {
//   final SpaceModel space;

//   const SpaceSettingsDialog({super.key, required this.space});

//   @override
//   State<SpaceSettingsDialog> createState() => _SpaceSettingsDialogState();
// }

// class _SpaceSettingsDialogState extends State<SpaceSettingsDialog> {
//   late bool _allowDelegation;

//   @override
//   void initState() {
//     super.initState();
//     // نأخذ القيمة الأولية من المساحة الممررة
//     _allowDelegation = widget.space.allowMemberDelegation;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Row(
//         children: [
//           Icon(Icons.admin_panel_settings, color: AppColors.primary),
//           SizedBox(width: 8.w),
//           Text(
//             "إعدادات المساحة",
//             style: TextStyle(fontFamily: 'Tajawal', fontSize: 18.sp),
//           ),
//         ],
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             "التحكم في صلاحيات الأعضاء العامة داخل '${widget.space.name}'",
//             style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//           ),
//           SizedBox(height: 16.h),
//           SwitchListTile(
//             title: Text(
//               "السماح بالتفويض (Delegation)",
//               style: TextStyle(
//                 fontFamily: 'Tajawal',
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14.sp,
//               ),
//             ),
//             subtitle: Text(
//               _allowDelegation
//                   ? "يستطيع الأعضاء تمرير المهام لبعضهم"
//                   : "يمنع أي عضو من سحب أو تمرير المهام",
//               style: TextStyle(fontSize: 10.sp),
//             ),
//             value: _allowDelegation,
//             activeColor: AppColors.primary,
//             onChanged: (val) {
//               setState(() {
//                 _allowDelegation = val;
//               });
//             },
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("إلغاء"),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             // ✅ الحل الجذري لمشكلة السياق (Context Safety):

//             // 1. التقاط الـ Messenger قبل الإغلاق
//             final messenger = ScaffoldMessenger.of(context);

//             // 2. استدعاء التحديث (Fire & Forget)
//             context.read<SpaceCubit>().updateSpaceDelegation(
//               widget.space.uuid,
//               _allowDelegation,
//             );

//             // 3. إغلاق النافذة
//             Navigator.pop(context);

//             // 4. استخدام المتغير الملتقط لعرض الرسالة
//             messenger.showSnackBar(
//               const SnackBar(content: Text("تم تحديث إعدادات المساحة ✅")),
//             );
//           },
//           style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//           child: const Text("حفظ", style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }
// }
//----------------------------------------------------------------------
