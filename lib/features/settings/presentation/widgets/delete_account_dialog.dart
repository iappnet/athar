import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class DeleteAccountDialog extends StatelessWidget {
  final Function(bool deleteLocal) onConfirm;

  const DeleteAccountDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusLg),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.error,
            size: 28.sp,
          ),
          AtharGap.hSm,
          Text(
            l10n.deleteAccount,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.deleteAccountConfirmMessage,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 20.h),

          // الخيار الأول: حذف كل شيء
          _buildOption(
            context,
            title: l10n.deleteEverything,
            subtitle: l10n.deleteEverythingDesc,
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              onConfirm(true);
            },
          ),
          AtharGap.md,

          // الخيار الثاني: الاحتفاظ بالمحلي
          _buildOption(
            context,
            title: l10n.keepLocalData,
            subtitle: l10n.keepLocalDataDesc,
            isDestructive: false,
            onTap: () {
              Navigator.pop(context);
              onConfirm(false);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isDestructive,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AtharRadii.radiusMd,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive
                ? colorScheme.error.withValues(alpha: 0.3)
                : colorScheme.outline,
          ),
          borderRadius: AtharRadii.radiusMd,
          color: isDestructive
              ? colorScheme.error.withValues(alpha: 0.05)
              : colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(
              isDestructive
                  ? Icons.delete_forever_rounded
                  : Icons.save_alt_rounded,
              color: isDestructive ? colorScheme.error : colorScheme.primary,
              size: 24.sp,
            ),
            AtharGap.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDestructive
                          ? colorScheme.error
                          : colorScheme.onSurface,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: colorScheme.onSurfaceVariant,
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
//-----------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';

// class DeleteAccountDialog extends StatelessWidget {
//   final Function(bool deleteLocal) onConfirm;

//   const DeleteAccountDialog({super.key, required this.onConfirm});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusLg),
//       title: Row(
//         children: [
//           Icon(Icons.warning_amber_rounded, color: colors.error, size: 28.sp),
//           AtharGap.hSm,
//           Text(
//             l10n.deleteAccount,
//             style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             l10n.deleteAccountConfirmMessage,
//             style: TextStyle(
//               fontSize: 14.sp,
//               height: 1.5,
//               color: colors.textPrimary,
//             ),
//           ),
//           SizedBox(height: 20.h),

//           // الخيار الأول: حذف كل شيء
//           _buildOption(
//             context,
//             title: l10n.deleteEverything,
//             subtitle: l10n.deleteEverythingDesc,
//             isDestructive: true,
//             onTap: () {
//               Navigator.pop(context);
//               onConfirm(true);
//             },
//           ),
//           AtharGap.md,

//           // الخيار الثاني: الاحتفاظ بالمحلي
//           _buildOption(
//             context,
//             title: l10n.keepLocalData,
//             subtitle: l10n.keepLocalDataDesc,
//             isDestructive: false,
//             onTap: () {
//               Navigator.pop(context);
//               onConfirm(false);
//             },
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text(
//             l10n.cancel,
//             style: TextStyle(color: colors.textSecondary),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOption(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required bool isDestructive,
//     required VoidCallback onTap,
//   }) {
//     final colors = context.colors;

//     return InkWell(
//       onTap: onTap,
//       borderRadius: AtharRadii.radiusMd,
//       child: Container(
//         padding: EdgeInsets.all(12.w),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isDestructive
//                 ? colors.error.withOpacity(0.3)
//                 : colors.border,
//           ),
//           borderRadius: AtharRadii.radiusMd,
//           color: isDestructive
//               ? colors.error.withOpacity(0.05)
//               : colors.surface,
//         ),
//         child: Row(
//           children: [
//             Icon(
//               isDestructive
//                   ? Icons.delete_forever_rounded
//                   : Icons.save_alt_rounded,
//               color: isDestructive ? colors.error : colors.primary,
//               size: 24.sp,
//             ),
//             AtharGap.hMd,
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: isDestructive ? colors.error : colors.textPrimary,
//                       fontSize: 13.sp,
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       color: colors.textSecondary,
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
//-----------------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';

// class DeleteAccountDialog extends StatelessWidget {
//   final Function(bool deleteLocal) onConfirm;

//   const DeleteAccountDialog({super.key, required this.onConfirm});

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
//       title: Row(
//         children: [
//           Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28.sp),
//           SizedBox(width: 8.w),
//           Text(
//             "حذف الحساب",
//             style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             "هل أنت متأكد؟ سيتم حذف حسابك السحابي نهائياً.\nماذا تريد أن تفعل بالبيانات المحفوظة في جهازك؟",
//             style: TextStyle(
//               fontSize: 14.sp,
//               height: 1.5,
//               color: Colors.black87,
//             ),
//           ),
//           SizedBox(height: 20.h),

//           // الخيار الأول: حذف كل شيء
//           _buildOption(
//             context,
//             title: "حذف كل شيء (فرمته)",
//             subtitle: "حذف السحابة + حذف بيانات الجهاز والبدء من الصفر.",
//             isDestructive: true,
//             onTap: () {
//               Navigator.pop(context);
//               onConfirm(true); // true = delete local
//             },
//           ),
//           SizedBox(height: 12.h),

//           // الخيار الثاني: الاحتفاظ بالمحلي
//           _buildOption(
//             context,
//             title: "الاحتفاظ ببيانات الجهاز",
//             subtitle: "حذف السحابة فقط وتحويل الحساب لاستخدام محلي.",
//             isDestructive: false,
//             onTap: () {
//               Navigator.pop(context);
//               onConfirm(false); // false = keep local
//             },
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
//         ),
//       ],
//     );
//   }

//   Widget _buildOption(
//     BuildContext context, {
//     required String title,
//     required String subtitle,
//     required bool isDestructive,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12.r),
//       child: Container(
//         padding: EdgeInsets.all(12.w),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: isDestructive
//                 ? Colors.red.withOpacity(0.3)
//                 : Colors.grey.shade300,
//           ),
//           borderRadius: BorderRadius.circular(12.r),
//           color: isDestructive ? Colors.red.withOpacity(0.05) : Colors.white,
//         ),
//         child: Row(
//           children: [
//             Icon(
//               isDestructive
//                   ? Icons.delete_forever_rounded
//                   : Icons.save_alt_rounded,
//               color: isDestructive ? Colors.red : AppColors.primary,
//               size: 24.sp,
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: isDestructive ? Colors.red : Colors.black87,
//                       fontSize: 13.sp,
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       color: Colors.grey.shade700,
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
