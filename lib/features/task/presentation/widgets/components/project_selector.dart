import 'package:athar/features/space/data/models/module_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class ProjectSelector extends StatelessWidget {
  final ModuleModel? selectedProject;
  final List<ModuleModel> availableProjects;
  final Function(ModuleModel?) onSelected;

  const ProjectSelector({
    super.key,
    required this.selectedProject,
    required this.availableProjects,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    // دمج المشروع الحالي إذا لم يكن في القائمة
    final displayList = List<ModuleModel>.from(availableProjects);
    if (selectedProject != null &&
        selectedProject!.uuid != 'no_project' &&
        !displayList.any((p) => p.uuid == selectedProject!.uuid)) {
      displayList.insert(0, selectedProject!);
    }

    // كائن وهمي لتمثيل "بدون مشروع"
    final noProject = ModuleModel()
      ..uuid = 'no_project'
      ..name = l10n.noProject;

    return PopupMenuButton<ModuleModel?>(
      tooltip: l10n.selectProject,
      initialValue: selectedProject ?? noProject,
      onSelected: (val) => onSelected(val?.uuid == 'no_project' ? null : val),
      itemBuilder: (context) {
        List<PopupMenuEntry<ModuleModel?>> items = [];
        items.add(
          PopupMenuItem(
            value: noProject,
            child: _ItemRow(
              icon: Icons.not_interested_rounded,
              text: l10n.noProject,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
        items.add(const PopupMenuDivider());
        items.addAll(
          displayList.map((proj) {
            return PopupMenuItem(
              value: proj,
              child: _ItemRow(
                icon: Icons.folder_rounded,
                text: proj.name,
                color: colorScheme.primary,
                isBold: selectedProject?.uuid == proj.uuid,
              ),
            );
          }),
        );
        return items;
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selectedProject != null
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selectedProject != null
                ? colorScheme.primary
                : colorScheme.outline,
          ),
        ),
        child: _ItemRow(
          icon: selectedProject != null
              ? Icons.folder_rounded
              : Icons.folder_open_rounded,
          text: selectedProject?.name ?? l10n.projectLabel,
          color: selectedProject != null
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
          isBold: true,
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isBold;

  const _ItemRow({
    required this.icon,
    required this.text,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.sp, color: color),
        AtharGap.hSm,
        Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            color: isBold ? color : colorScheme.onSurface,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/space/data/models/module_model.dart'; // ✅ الاستيراد الجديد
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class ProjectSelector extends StatelessWidget {
//   final ModuleModel? selectedProject; // ✅ استخدام ModuleModel
//   final List<ModuleModel> availableProjects; // ✅ القائمة أصبحت موديولات
//   final Function(ModuleModel?) onSelected;

//   const ProjectSelector({
//     super.key,
//     required this.selectedProject,
//     required this.availableProjects,
//     required this.onSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // دمج المشروع الحالي إذا لم يكن في القائمة (باستخدام uuid بدلاً من id)
//     final displayList = List<ModuleModel>.from(availableProjects);
//     if (selectedProject != null &&
//         selectedProject!.uuid != 'no_project' &&
//         !displayList.any((p) => p.uuid == selectedProject!.uuid)) {
//       displayList.insert(0, selectedProject!);
//     }

//     // كائن وهمي لتمثيل "بدون مشروع"
//     final noProject = ModuleModel()
//       ..uuid = 'no_project'
//       ..name = "بدون مشروع";

//     return PopupMenuButton<ModuleModel?>(
//       tooltip: "اختر مشروعاً",
//       initialValue: selectedProject ?? noProject,
//       onSelected: (val) => onSelected(val?.uuid == 'no_project' ? null : val),
//       itemBuilder: (context) {
//         List<PopupMenuEntry<ModuleModel?>> items = [];
//         items.add(
//           PopupMenuItem(
//             value: noProject,
//             child: const _ItemRow(
//               icon: Icons.not_interested_rounded,
//               text: "بدون مشروع",
//               color: Colors.grey,
//             ),
//           ),
//         );
//         items.add(const PopupMenuDivider());
//         items.addAll(
//           displayList.map((proj) {
//             return PopupMenuItem(
//               value: proj,
//               child: _ItemRow(
//                 icon: Icons.folder_rounded,
//                 text: proj.name, // ✅ استخدام name بدلاً من title
//                 color: AppColors
//                     .primary, // يمكن تطوير ModuleModel لاحقاً ليدعم الألوان
//                 isBold: selectedProject?.uuid == proj.uuid,
//               ),
//             );
//           }),
//         );
//         return items;
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         decoration: BoxDecoration(
//           color: selectedProject != null
//               ? AppColors.primary.withValues(alpha: 0.1)
//               : AppColors.background,
//           borderRadius: BorderRadius.circular(20.r),
//           border: Border.all(
//             color: selectedProject != null
//                 ? AppColors.primary
//                 : Colors.grey.shade300,
//           ),
//         ),
//         child: _ItemRow(
//           icon: selectedProject != null
//               ? Icons.folder_rounded
//               : Icons.folder_open_rounded,
//           text: selectedProject?.name ?? "مشروع",
//           color: selectedProject != null ? AppColors.primary : Colors.grey,
//           isBold: true,
//         ),
//       ),
//     );
//   }
// }

// // ويدجت _ItemRow يبقى كما هو مع تعديلات بسيطة في التصميم إذا أردت
// class _ItemRow extends StatelessWidget {
//   final IconData icon;
//   final String text;
//   final Color color;
//   final bool isBold;

//   const _ItemRow({
//     required this.icon,
//     required this.text,
//     required this.color,
//     this.isBold = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 18.sp, color: color),
//         SizedBox(width: 8.w),
//         Text(
//           text,
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: isBold ? color : Colors.black87,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
// }
