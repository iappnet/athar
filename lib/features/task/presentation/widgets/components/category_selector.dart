// lib/features/task/presentation/widgets/components/category_selector.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 📁 CATEGORY SELECTOR - اختيار التصنيف مع دعم IconRegistry
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_dialog.dart';
import 'package:athar/core/utils/icon_registry.dart';
import 'package:athar/features/settings/data/models/category_model.dart';
import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class CategorySelector extends StatelessWidget {
  final CategoryModel? selectedCategory;
  final Function(CategoryModel) onSelected;
  final VoidCallback onAddPressed;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.categoryLabel,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12.sp,
          ),
        ),
        AtharGap.sm,
        BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoaded) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...state.categories.map((cat) {
                      final isSelected = selectedCategory?.id == cat.id;

                      // ✅ الحل النهائي: استخدام IconRegistry
                      final iconData = IconRegistry.getIcon(cat.iconKey);

                      return Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: InputChip(
                          showCheckmark: false,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                iconData,
                                size: 16.sp,
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : Color(cat.colorValue),
                              ),
                              AtharGap.hXxs,
                              Text(cat.name),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) onSelected(cat);
                          },
                          selectedColor: Color(cat.colorValue),
                          backgroundColor: colorScheme.surfaceContainerLowest,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: AtharRadii.radiusXl,
                          ),
                          onDeleted: cat.isDefault
                              ? null
                              : () => _confirmDelete(context, cat),
                          deleteIcon: cat.isDefault
                              ? null
                              : Icon(
                                  Icons.close,
                                  size: 14.sp,
                                  color: isSelected
                                      ? colorScheme.onPrimary.withValues(
                                          alpha: 0.7,
                                        )
                                      : colorScheme.onSurfaceVariant,
                                ),
                        ),
                      );
                    }),
                    ActionChip(
                      label: const Icon(Icons.add, size: 18),
                      onPressed: onAddPressed,
                      backgroundColor: colorScheme.outline,
                      side: BorderSide.none,
                      shape: const CircleBorder(),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel cat) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AtharDialog.confirm(
      context: context,
      title: l10n.deleteCategory,
      message: l10n.confirmDeleteCategory(cat.name),
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<CategoryCubit>().deleteCategory(cat);
    }
  }
}
//--------------------------------------------------------------------
// import 'package:athar/features/settings/data/models/category_model.dart';
// import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/tokens.dart';
// import 'package:athar/core/design_system/widgets/athar_dialog.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';

// class CategorySelector extends StatelessWidget {
//   final CategoryModel? selectedCategory;
//   final Function(CategoryModel) onSelected;
//   final VoidCallback onAddPressed;

//   const CategorySelector({
//     super.key,
//     required this.selectedCategory,
//     required this.onSelected,
//     required this.onAddPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final l10n = AppLocalizations.of(context);

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           l10n.categoryLabel,
//           style: TextStyle(
//             color: colorScheme.onSurfaceVariant,
//             fontSize: 12.sp,
//           ),
//         ),
//         AtharGap.sm,
//         BlocBuilder<CategoryCubit, CategoryState>(
//           builder: (context, state) {
//             if (state is CategoryLoaded) {
//               return SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     ...state.categories.map((cat) {
//                       final isSelected = selectedCategory?.id == cat.id;

//                       // ✅ إصلاح مشكلة الأيقونة
//                       IconData iconData;
//                       try {
//                         iconData = IconData(
//                           cat.iconCode ?? Icons.label_outline.codePoint,
//                           fontFamily: 'MaterialIcons',
//                         );
//                       } catch (e) {
//                         iconData = Icons.label_outline;
//                       }

//                       return Padding(
//                         padding: EdgeInsets.only(left: 8.w),
//                         child: InputChip(
//                           showCheckmark: false,
//                           label: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 iconData,
//                                 size: 16.sp,
//                                 color: isSelected
//                                     ? colorScheme.onPrimary
//                                     : Color(cat.colorValue),
//                               ),
//                               AtharGap.hXxs,
//                               Text(cat.name),
//                             ],
//                           ),
//                           selected: isSelected,
//                           onSelected: (selected) {
//                             if (selected) onSelected(cat);
//                           },
//                           selectedColor: Color(cat.colorValue),
//                           backgroundColor: colorScheme.surfaceContainerLowest,
//                           labelStyle: TextStyle(
//                             color: isSelected
//                                 ? colorScheme.onPrimary
//                                 : colorScheme.onSurface,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12.sp,
//                           ),
//                           side: BorderSide.none,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20.r),
//                           ),
//                           // ✅ زر الحذف (يظهر فقط للمخصص)
//                           onDeleted: cat.isDefault
//                               ? null
//                               : () {
//                                   _confirmDelete(context, cat);
//                                 },
//                           deleteIcon: cat.isDefault
//                               ? null
//                               : Icon(
//                                   Icons.close,
//                                   size: 14.sp,
//                                   color: isSelected
//                                       ? colorScheme.onPrimary.withValues(
//                                           alpha: 0.7,
//                                         )
//                                       : colorScheme.onSurfaceVariant,
//                                 ),
//                         ),
//                       );
//                     }),
//                     ActionChip(
//                       label: const Icon(Icons.add, size: 18),
//                       onPressed: onAddPressed,
//                       backgroundColor: colorScheme.outline,
//                       side: BorderSide.none,
//                       shape: const CircleBorder(),
//                     ),
//                   ],
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ],
//     );
//   }

//   void _confirmDelete(BuildContext context, CategoryModel cat) async {
//     final l10n = AppLocalizations.of(context);
//     final confirmed = await AtharDialog.confirm(
//       context: context,
//       title: l10n.deleteCategory,
//       message: l10n.confirmDeleteCategory(cat.name),
//       cancelLabel: l10n.cancel,
//       confirmLabel: l10n.delete,
//       isDestructive: true,
//     );
//     if (confirmed == true && context.mounted) {
//       context.read<CategoryCubit>().deleteCategory(cat);
//     }
//   }
// }
//-------------------------------------------------------------------
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/settings/data/models/category_model.dart';
// import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class CategorySelector extends StatelessWidget {
//   final CategoryModel? selectedCategory;
//   final Function(CategoryModel) onSelected;
//   final VoidCallback onAddPressed;

//   const CategorySelector({
//     super.key,
//     required this.selectedCategory,
//     required this.onSelected,
//     required this.onAddPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "التصنيف:",
//           style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//         ),
//         SizedBox(height: 8.h),
//         BlocBuilder<CategoryCubit, CategoryState>(
//           builder: (context, state) {
//             if (state is CategoryLoaded) {
//               return SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     ...state.categories.map((cat) {
//                       final isSelected = selectedCategory?.id == cat.id;

//                       // ✅ إصلاح مشكلة الأيقونة
//                       // نستخدم try-catch بسيط أو fallback في حال كان الكود خطأ
//                       IconData iconData;
//                       try {
//                         iconData = IconData(
//                           cat.iconCode ??
//                               Icons.label_outline.codePoint, // حماية من null
//                           fontFamily: 'MaterialIcons',
//                         );
//                       } catch (e) {
//                         iconData = Icons.label_outline; // أيقونة احتياطية
//                       }

//                       return Padding(
//                         padding: EdgeInsets.only(left: 8.w),
//                         child: InputChip(
//                           showCheckmark: false,
//                           label: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 iconData,
//                                 size: 16.sp,
//                                 color: isSelected
//                                     ? Colors.white
//                                     : Color(cat.colorValue),
//                               ),
//                               SizedBox(width: 4.w),
//                               Text(cat.name),
//                             ],
//                           ),
//                           selected: isSelected,
//                           onSelected: (selected) {
//                             if (selected) onSelected(cat);
//                           },
//                           selectedColor: Color(cat.colorValue),
//                           backgroundColor: AppColors.background,
//                           labelStyle: TextStyle(
//                             color: isSelected ? Colors.white : Colors.black87,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12.sp,
//                           ),
//                           side: BorderSide.none,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20.r),
//                           ),
//                           // ✅ زر الحذف (يظهر فقط للمخصص)
//                           onDeleted: cat.isDefault
//                               ? null
//                               : () {
//                                   _confirmDelete(context, cat);
//                                 },
//                           deleteIcon: cat.isDefault
//                               ? null
//                               : Icon(
//                                   Icons.close,
//                                   size: 14.sp,
//                                   color: isSelected
//                                       ? Colors.white70
//                                       : Colors.grey,
//                                 ),
//                         ),
//                       );
//                     }),
//                     ActionChip(
//                       label: const Icon(Icons.add, size: 18),
//                       onPressed: onAddPressed,
//                       backgroundColor: Colors.grey.shade200,
//                       side: BorderSide.none,
//                       shape: const CircleBorder(),
//                     ),
//                   ],
//                 ),
//               );
//             }
//             return const SizedBox();
//           },
//         ),
//       ],
//     );
//   }

//   void _confirmDelete(BuildContext context, CategoryModel cat) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("حذف التصنيف"),
//         content: Text("هل أنت متأكد من حذف تصنيف '${cat.name}'؟"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("إلغاء"),
//           ),
//           TextButton(
//             onPressed: () {
//               // ✅ استدعاء الحذف من الكيوبت
//               context.read<CategoryCubit>().deleteCategory(cat);
//               Navigator.pop(ctx);
//             },
//             child: const Text("حذف", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
// }
