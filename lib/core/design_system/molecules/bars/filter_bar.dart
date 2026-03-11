import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterBar<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final Function(T) onSelected;
  final String Function(T) labelBuilder;
  final IconData? Function(T)? iconBuilder;
  final Color? Function(T)? colorBuilder;

  const FilterBar({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
    required this.labelBuilder,
    this.iconBuilder,
    this.colorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((filter) {
          final isSelected = filter == selectedItem;

          IconData? icon;
          if (iconBuilder != null) {
            icon = iconBuilder!(filter);
          }

          Color? customColor;
          if (colorBuilder != null) {
            customColor = colorBuilder!(filter);
          }

          return Padding(
            padding: EdgeInsets.only(left: AtharSpacing.sm),
            child: ChoiceChip(
              avatar: icon != null
                  ? Icon(
                      icon,
                      size: 18.sp,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : (customColor ?? colorScheme.outline),
                    )
                  : null,
              label: Text(labelBuilder(filter)),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) onSelected(filter);
              },
              selectedColor: customColor ?? colorScheme.primary,
              backgroundColor: colorScheme.surface,
              labelStyle: TextStyle(
                fontSize: 12.sp,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: isSelected
                  ? BorderSide.none
                  : BorderSide(color: colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusXl),
              padding: EdgeInsets.symmetric(
                horizontal: AtharSpacing.xxs,
                vertical: AtharSpacing.xxxs,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
//-----------------------------------------------------------------------
// // lib/core/design_system/molecules/bars/filter_bar.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 1 | File 1.6
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ❌ REMOVED: import '../../themes/app_colors.dart';

// class FilterBar<T> extends StatelessWidget {
//   final List<T> items;
//   final T selectedItem;
//   final Function(T) onSelected;
//   final String Function(T) labelBuilder;
//   final IconData? Function(T)? iconBuilder;
//   final Color? Function(T)? colorBuilder;

//   const FilterBar({
//     super.key,
//     required this.items,
//     required this.selectedItem,
//     required this.onSelected,
//     required this.labelBuilder,
//     this.iconBuilder,
//     this.colorBuilder,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;

//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: items.map((filter) {
//           final isSelected = filter == selectedItem;

//           // استخراج الأيقونة واللون
//           IconData? icon;
//           if (iconBuilder != null) {
//             icon = iconBuilder!(filter);
//           }

//           Color? customColor;
//           if (colorBuilder != null) {
//             customColor = colorBuilder!(filter);
//           }

//           return Padding(
//             // ✅ EdgeInsets.only(left: 8.w)
//             padding: EdgeInsets.only(left: AtharSpacing.sm),
//             child: ChoiceChip(
//               avatar: icon != null
//                   ? Icon(
//                       icon,
//                       size: 18.sp,
//                       color: isSelected
//                           // ✅ Colors.white → colors.onPrimary
//                           ? colors.onPrimary
//                           // ✅ Colors.grey → colors.textTertiary
//                           : (customColor ?? colors.textTertiary),
//                     )
//                   : null,
//               label: Text(labelBuilder(filter)),
//               selected: isSelected,
//               onSelected: (bool selected) {
//                 if (selected) onSelected(filter);
//               },
//               // ✅ AppColors.primary → colors.primary
//               selectedColor: customColor ?? colors.primary,
//               // ✅ Colors.white → colors.surface
//               backgroundColor: colors.surface,
//               // ✅ AtharTypography
//               labelStyle: AtharTypography.labelMedium.copyWith(
//                 // ✅ Colors.white / Colors.black87
//                 color: isSelected ? colors.onPrimary : colors.textPrimary,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//               ),
//               side: isSelected
//                   ? BorderSide.none
//                   // ✅ Colors.grey.shade300 → colors.borderLight
//                   : BorderSide(color: colors.borderLight),
//               shape: RoundedRectangleBorder(
//                 // ✅ BorderRadius.circular(20.r) → AtharRadii.xl
//                 borderRadius: AtharRadii.radiusXl,
//               ),
//               // ✅ EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h)
//               padding: EdgeInsets.symmetric(
//                 horizontal: AtharSpacing.xxs,
//                 vertical: AtharSpacing.xxxs,
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../themes/app_colors.dart';

// class FilterBar<T> extends StatelessWidget {
//   final List<T> items; // قائمة الفلاتر
//   final T selectedItem; // الفلتر المختار حالياً
//   final Function(T) onSelected; // دالة عند الاختيار
//   final String Function(T) labelBuilder; // دالة لاستخراج النص من الفلتر

//   // ✅ إضافات جديدة
//   final IconData? Function(T)? iconBuilder; // دالة لاستخراج الأيقونة
//   final Color? Function(T)? colorBuilder; // دالة لاستخراج لون التصنيف

//   const FilterBar({
//     super.key,
//     required this.items,
//     required this.selectedItem,
//     required this.onSelected,
//     required this.labelBuilder,
//     this.iconBuilder, // ✅
//     this.colorBuilder, // ✅
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: items.map((filter) {
//           final isSelected = filter == selectedItem;

//           // استخراج الأيقونة واللون
//           IconData? icon;
//           if (iconBuilder != null) {
//             icon = iconBuilder!(filter);
//           }

//           Color? customColor;
//           if (colorBuilder != null) {
//             customColor = colorBuilder!(filter);
//           }
//           return Padding(
//             padding: EdgeInsets.only(left: 8.w),
//             child: ChoiceChip(
//               // ✅ استخدام Avatar للأيقونة
//               avatar: icon != null
//                   ? Icon(
//                       icon,
//                       size: 18.sp,
//                       color: isSelected
//                           ? Colors.white
//                           : (customColor ?? Colors.grey),
//                     )
//                   : null,
//               label: Text(labelBuilder(filter)),
//               selected: isSelected,
//               onSelected: (bool selected) {
//                 if (selected) onSelected(filter);
//               },
//               // تنسيق الألوان
//               // ✅ استخدام اللون المخصص إذا وجد
//               selectedColor: customColor ?? AppColors.primary,
//               backgroundColor: Colors.white,
//               labelStyle: TextStyle(
//                 color: isSelected ? Colors.white : Colors.black87,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 fontSize: 12.sp,
//               ),
//               side: isSelected
//                   ? BorderSide.none
//                   : BorderSide(color: Colors.grey.shade300),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
