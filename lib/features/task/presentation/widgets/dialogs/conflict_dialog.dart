import 'package:athar/features/task/domain/models/conflict_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

/// Semantic colors (not in ColorScheme)
const _warningColor = AppColors.warning;

class ConflictDialog extends StatelessWidget {
  final ConflictResult conflict;
  final VoidCallback onDelay;
  final VoidCallback onForceSave;
  final VoidCallback onCancel;

  const ConflictDialog({
    super.key,
    required this.conflict,
    required this.onDelay,
    required this.onForceSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final newTimeFormatted = conflict.suggestedTime != null
        ? DateFormat('h:mm a', 'ar').format(conflict.suggestedTime!)
        : "";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusLg),
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: AtharSpacing.allXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AtharSpacing.allMd,
              decoration: BoxDecoration(
                color: _warningColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: _warningColor,
                size: 32,
              ),
            ),
            AtharGap.lg,
            Text(
              l10n.conflictWarningTitle,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            AtharGap.sm,
            Text(
              conflict.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            AtharGap.xl,

            if (conflict.suggestedTime != null) ...[
              _buildButton(
                context: context,
                icon: Icons.access_time_filled_rounded,
                bg: colorScheme.primary,
                textC: colorScheme.onPrimary,
                title: l10n.delayAfterFinish,
                sub: l10n.moveTimeTo(newTimeFormatted),
                onTap: onDelay,
              ),
              AtharGap.md,
            ],

            _buildButton(
              context: context,
              icon: Icons.check_circle_outline_rounded,
              bg: colorScheme.surfaceContainer,
              textC: colorScheme.onSurface,
              title: l10n.saveAnyway,
              sub: l10n.keepTimeAsIs,
              onTap: onForceSave,
            ),

            AtharGap.md,
            TextButton(
              onPressed: onCancel,
              child: Text(
                l10n.cancelAndEditManually,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required Color bg,
    required Color textC,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AtharRadii.radiusMd,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(color: bg, borderRadius: AtharRadii.radiusMd),
        child: Row(
          children: [
            Icon(icon, color: textC, size: 22.sp),
            AtharGap.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textC,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color: textC.withValues(alpha: 0.8),
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textC.withValues(alpha: 0.5),
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/task/domain/models/conflict_result.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class ConflictDialog extends StatelessWidget {
//   final ConflictResult conflict;
//   final VoidCallback onDelay;
//   final VoidCallback onForceSave;
//   final VoidCallback onCancel;

//   const ConflictDialog({
//     super.key,
//     required this.conflict,
//     required this.onDelay,
//     required this.onForceSave,
//     required this.onCancel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final newTimeFormatted = conflict.suggestedTime != null
//         ? DateFormat('h:mm a', 'ar').format(conflict.suggestedTime!)
//         : "";

//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
//       backgroundColor: Colors.white,
//       child: Padding(
//         padding: EdgeInsets.all(20.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFF7ED),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.warning_amber_rounded,
//                 color: Colors.orange,
//                 size: 32,
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               "انتبه، يوجد تداخل زمني",
//               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               conflict.message,
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
//             ),
//             SizedBox(height: 24.h),

//             if (conflict.suggestedTime != null) ...[
//               _buildButton(
//                 Icons.access_time_filled_rounded,
//                 AppColors.primary,
//                 Colors.white,
//                 "تأجيل لما بعد الانتهاء",
//                 "نقل الموعد إلى $newTimeFormatted",
//                 onDelay,
//               ),
//               SizedBox(height: 12.h),
//             ],

//             _buildButton(
//               Icons.check_circle_outline_rounded,
//               Colors.grey.shade100,
//               Colors.black87,
//               "حفظ على أي حال",
//               "إبقاء الوقت كما هو",
//               onForceSave,
//             ),

//             SizedBox(height: 12.h),
//             TextButton(
//               onPressed: onCancel,
//               child: Text(
//                 "إلغاء وتعديل الوقت يدوياً",
//                 style: TextStyle(color: Colors.grey, fontSize: 13.sp),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildButton(
//     IconData icon,
//     Color bg,
//     Color textC,
//     String title,
//     String sub,
//     VoidCallback onTap,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12.r),
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: textC, size: 22.sp),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: TextStyle(
//                       color: textC,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 13.sp,
//                     ),
//                   ),
//                   Text(
//                     sub,
//                     style: TextStyle(
//                       color: textC.withValues(alpha: 0.8),
//                       fontSize: 11.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               color: textC.withValues(alpha: 0.5),
//               size: 14.sp,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
