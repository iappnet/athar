import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

/// Semantic colors (not in ColorScheme)
const _successColor = Color(0xFF00B894);

class ReflectionDialog extends StatefulWidget {
  final String taskTitle;
  final Function(String) onSave;

  const ReflectionDialog({
    super.key,
    required this.taskTitle,
    required this.onSave,
  });

  @override
  State<ReflectionDialog> createState() => _ReflectionDialogState();
}

class _ReflectionDialogState extends State<ReflectionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusLg),
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: AtharSpacing.allXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة احتفالية
            Container(
              padding: AtharSpacing.allMd,
              decoration: BoxDecoration(
                color: _successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: _successColor,
                size: 32.sp,
              ),
            ),
            AtharGap.lg,

            Text(
              l10n.wellDone,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            AtharGap.sm,
            Text(
              l10n.reflectionPrompt(widget.taskTitle),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
            AtharGap.xl,

            // حقل الكتابة
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.addNoteOptionalHint,
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.outline,
                ),
                fillColor: colorScheme.surfaceContainerLowest,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: AtharRadii.radiusMd,
                  borderSide: BorderSide.none,
                ),
                contentPadding: AtharSpacing.allMd,
              ),
            ),
            AtharGap.xl,

            // الأزرار
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.skip,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
                AtharGap.hMd,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        widget.onSave(_controller.text);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: AtharRadii.radiusMd,
                      ),
                      padding: AtharSpacing.verticalMd,
                    ),
                    child: Text(
                      l10n.save,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';

// class ReflectionDialog extends StatefulWidget {
//   final String taskTitle;
//   final Function(String) onSave;

//   const ReflectionDialog({
//     super.key,
//     required this.taskTitle,
//     required this.onSave,
//   });

//   @override
//   State<ReflectionDialog> createState() => _ReflectionDialogState();
// }

// class _ReflectionDialogState extends State<ReflectionDialog> {
//   final TextEditingController _controller = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
//       backgroundColor: Colors.white,
//       child: Padding(
//         padding: EdgeInsets.all(20.w),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // أيقونة احتفالية
//             Container(
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 color: Colors.green.withValues(alpha: 0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.check_rounded,
//                 color: Colors.green,
//                 size: 32.sp,
//               ),
//             ),
//             SizedBox(height: 16.h),

//             Text(
//               "أحسنت! 🎉",
//               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               "لقد أنجزت \"${widget.taskTitle}\". كيف كان ذلك؟",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey, fontSize: 14.sp),
//             ),
//             SizedBox(height: 20.h),

//             // حقل الكتابة
//             TextField(
//               controller: _controller,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 hintText: "أضف ملاحظة (اختياري)...",
//                 hintStyle: TextStyle(
//                   fontSize: 12.sp,
//                   color: Colors.grey.shade400,
//                 ),
//                 fillColor: AppColors.background,
//                 filled: true,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: EdgeInsets.all(12.w),
//               ),
//             ),
//             SizedBox(height: 20.h),

//             // الأزرار
//             Row(
//               children: [
//                 Expanded(
//                   child: TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text(
//                       "تخطي",
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       if (_controller.text.isNotEmpty) {
//                         widget.onSave(_controller.text);
//                       }
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primary,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       padding: EdgeInsets.symmetric(vertical: 12.h),
//                     ),
//                     child: const Text(
//                       "حفظ",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
