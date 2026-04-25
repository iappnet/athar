import 'dart:ui';

import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MinimalHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String dateStr;
  final String quote;
  final Widget? trailing;

  MinimalHeaderDelegate({
    required this.dateStr,
    required this.quote,
    this.trailing,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final dateFontSize = lerpDouble(12.sp, 11.sp, progress) ?? 11.sp;
    final quoteFontSize = lerpDouble(18.sp, 15.sp, progress) ?? 15.sp;
    final spacing = lerpDouble(AtharSpacing.sm, 4.0, progress) ?? 4;
    final quoteOpacity = lerpDouble(0.82, 0.55, progress) ?? 0.55;

    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.symmetric(
        horizontal: AtharSpacing.xl,
        vertical: 10.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: dateFontSize,
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...(trailing == null ? const <Widget>[] : <Widget>[trailing!]),
            ],
          ),
          SizedBox(height: spacing),
          Text(
            quote,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: quoteFontSize,
              fontWeight: FontWeight.w700,
              fontFamily: 'Amiri',
              color: colorScheme.onSurface.withValues(alpha: quoteOpacity),
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 118.h;

  @override
  double get minExtent => 72.h;

  @override
  bool shouldRebuild(covariant MinimalHeaderDelegate oldDelegate) {
    return oldDelegate.quote != quote ||
        oldDelegate.dateStr != dateStr ||
        oldDelegate.trailing != trailing;
  }
}
//-----------------------------------------------------------------------
// // lib/core/design_system/molecules/headers/page_header_delegate.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 1 | File 1.11
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ❌ REMOVED: import '../../themes/app_colors.dart';

// class MinimalHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final String dateStr;
//   final String quote;

//   MinimalHeaderDelegate({required this.dateStr, required this.quote});

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     // ✅ Get colors from context
//     final colors = context.colors;

//     // منطق التلاشي عند التمرير
//     final double opacity = (1 - shrinkOffset / maxExtent).clamp(0.0, 1.0);

//     return Container(
//       // ✅ AppColors.background → colors.background
//       color: colors.background,
//       padding: EdgeInsets.symmetric(
//         horizontal: AtharSpacing.xl,
//         vertical: AtharSpacing.sm,
//       ),
//       child: Opacity(
//         opacity: opacity,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             // التاريخ الصغير
//             Text(
//               dateStr,
//               // ✅ AtharTypography
//               style: AtharTypography.bodySmall.copyWith(
//                 // ✅ Colors.grey → colors.textTertiary
//                 color: colors.textTertiary,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             // ✅ SizedBox(height: 8.h) → AtharGap.sm
//             AtharGap.sm,
//             // العبارة الملهمة الكبيرة (Serif)
//             Text(
//               quote,
//               // ✅ AtharTypography - استخدام displaySmall للعناوين الكبيرة
//               style: AtharTypography.displaySmall.copyWith(
//                 fontFamily: 'Amiri', // خط Serif عربي
//                 // ✅ AppColors.textSerif → colors.textPrimary (أو يمكن إضافة لون خاص)
//                 color: colors.textPrimary,
//                 height: 1.3,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   double get maxExtent => 150.h;

//   @override
//   double get minExtent => 80.h;

//   @override
//   bool shouldRebuild(covariant MinimalHeaderDelegate oldDelegate) {
//     return oldDelegate.quote != quote || oldDelegate.dateStr != dateStr;
//   }
// }
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../themes/app_colors.dart';

// class MinimalHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final String dateStr;
//   final String quote;

//   MinimalHeaderDelegate({required this.dateStr, required this.quote});

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     // منطق التلاشي عند التمرير (اختياري)
//     final double opacity = (1 - shrinkOffset / maxExtent).clamp(0.0, 1.0);

//     return Container(
//       color: AppColors.background, // لون الخلفية نفسه ليدمج
//       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
//       child: Opacity(
//         opacity: opacity,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             // التاريخ الصغير
//             Text(
//               dateStr,
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             // العبارة الملهمة الكبيرة (Serif)
//             Text(
//               quote,
//               style: TextStyle(
//                 fontSize: 22.sp,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Amiri', // أو أي خط Serif عربي
//                 color: AppColors.textSerif,
//                 height: 1.3,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   double get maxExtent => 150.h; // ارتفاع الرأس عند الفتح

//   @override
//   double get minExtent => 80.h; // ارتفاع الرأس عند الطي

//   @override
//   bool shouldRebuild(covariant MinimalHeaderDelegate oldDelegate) {
//     return oldDelegate.quote != quote || oldDelegate.dateStr != dateStr;
//   }
// }
