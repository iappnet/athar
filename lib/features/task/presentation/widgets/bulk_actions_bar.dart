import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_dialog.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class BulkActionsBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onCompleteAll;
  final VoidCallback onDeleteAll;
  final VoidCallback? onPostponeAll;
  final VoidCallback? onAssignAll;

  const BulkActionsBar({
    super.key,
    required this.selectedCount,
    required this.onCancel,
    required this.onCompleteAll,
    required this.onDeleteAll,
    this.onPostponeAll,
    this.onAssignAll,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.close, color: colorScheme.onPrimary),
              onPressed: onCancel,
            ),
            AtharGap.hSm,
            Text(
              l10n.selectedCountLabel(selectedCount),
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),

            // إكمال الكل
            IconButton(
              icon: Icon(
                Icons.check_circle_outline,
                color: colorScheme.onPrimary,
              ),
              onPressed: onCompleteAll,
              tooltip: l10n.completeAll,
            ),

            // تأجيل الكل
            if (onPostponeAll != null)
              IconButton(
                icon: Icon(Icons.schedule, color: colorScheme.onPrimary),
                onPressed: onPostponeAll,
                tooltip: l10n.postponeAll,
              ),

            // إسناد الكل
            if (onAssignAll != null)
              IconButton(
                icon: Icon(Icons.person_add, color: colorScheme.onPrimary),
                onPressed: onAssignAll,
                tooltip: l10n.assignAll,
              ),

            // حذف الكل
            IconButton(
              icon: Icon(Icons.delete_outline, color: colorScheme.onPrimary),
              onPressed: () => _showDeleteConfirmation(context),
              tooltip: l10n.deleteAll,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AtharDialog.confirm(
      context: context,
      title: l10n.confirmDelete,
      message: l10n.confirmDeleteCount(selectedCount),
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed == true) {
      onDeleteAll();
    }
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/design_system.dart';

// class BulkActionsBar extends StatelessWidget {
//   final int selectedCount;
//   final VoidCallback onCancel;
//   final VoidCallback onCompleteAll;
//   final VoidCallback onDeleteAll;
//   final VoidCallback? onPostponeAll;
//   final VoidCallback? onAssignAll;

//   const BulkActionsBar({
//     super.key,
//     required this.selectedCount,
//     required this.onCancel,
//     required this.onCompleteAll,
//     required this.onDeleteAll,
//     this.onPostponeAll,
//     this.onAssignAll,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//       decoration: BoxDecoration(
//         color: colors.primary,
//         boxShadow: [
//           BoxShadow(
//             color: colors.shadow.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Row(
//           children: [
//             IconButton(
//               icon: Icon(Icons.close, color: colors.onPrimary),
//               onPressed: onCancel,
//             ),
//             AtharGap.hSm,
//             Text(
//               "$selectedCount محدد",
//               style: TextStyle(
//                 color: colors.onPrimary,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             const Spacer(),

//             // إكمال الكل
//             IconButton(
//               icon: Icon(Icons.check_circle_outline, color: colors.onPrimary),
//               onPressed: onCompleteAll,
//               tooltip: "إكمال الكل",
//             ),

//             // تأجيل الكل
//             if (onPostponeAll != null)
//               IconButton(
//                 icon: Icon(Icons.schedule, color: colors.onPrimary),
//                 onPressed: onPostponeAll,
//                 tooltip: "تأجيل الكل",
//               ),

//             // إسناد الكل
//             if (onAssignAll != null)
//               IconButton(
//                 icon: Icon(Icons.person_add, color: colors.onPrimary),
//                 onPressed: onAssignAll,
//                 tooltip: "إسناد الكل",
//               ),

//             // حذف الكل
//             IconButton(
//               icon: Icon(Icons.delete_outline, color: colors.onPrimary),
//               onPressed: () => _showDeleteConfirmation(context),
//               tooltip: "حذف الكل",
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDeleteConfirmation(BuildContext context) async {
//     final confirmed = await AtharDialog.confirm(
//       context: context,
//       title: "تأكيد الحذف",
//       message: "هل أنت متأكد من حذف $selectedCount عنصر؟",
//       cancelLabel: "إلغاء",
//       confirmLabel: "حذف",
//       isDestructive: true,
//     );
//     if (confirmed == true) {
//       onDeleteAll();
//     }
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/themes/app_colors.dart';

// class BulkActionsBar extends StatelessWidget {
//   final int selectedCount;
//   final VoidCallback onCancel;
//   final VoidCallback onCompleteAll;
//   final VoidCallback onDeleteAll;
//   final VoidCallback? onPostponeAll;
//   final VoidCallback? onAssignAll;

//   const BulkActionsBar({
//     super.key,
//     required this.selectedCount,
//     required this.onCancel,
//     required this.onCompleteAll,
//     required this.onDeleteAll,
//     this.onPostponeAll,
//     this.onAssignAll,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//       decoration: BoxDecoration(
//         color: AppColors.primary,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.close, color: Colors.white),
//               onPressed: onCancel,
//             ),
//             SizedBox(width: 8.w),
//             Text(
//               "$selectedCount محدد",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             const Spacer(),

//             // إكمال الكل
//             IconButton(
//               icon: const Icon(Icons.check_circle_outline, color: Colors.white),
//               onPressed: onCompleteAll,
//               tooltip: "إكمال الكل",
//             ),

//             // تأجيل الكل
//             if (onPostponeAll != null)
//               IconButton(
//                 icon: const Icon(Icons.schedule, color: Colors.white),
//                 onPressed: onPostponeAll,
//                 tooltip: "تأجيل الكل",
//               ),

//             // إسناد الكل
//             if (onAssignAll != null)
//               IconButton(
//                 icon: const Icon(Icons.person_add, color: Colors.white),
//                 onPressed: onAssignAll,
//                 tooltip: "إسناد الكل",
//               ),

//             // حذف الكل
//             IconButton(
//               icon: const Icon(Icons.delete_outline, color: Colors.white),
//               onPressed: () => _showDeleteConfirmation(context),
//               tooltip: "حذف الكل",
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDeleteConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("تأكيد الحذف"),
//         content: Text("هل أنت متأكد من حذف $selectedCount عنصر؟"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("إلغاء"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               onDeleteAll();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text("حذف"),
//           ),
//         ],
//       ),
//     );
//   }
// }
