// lib/core/design_system/molecules/skeletons/athar_skeleton.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 1 | File 1.12
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

class AtharSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AtharSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors from context
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      // ✅ Colors.grey.shade200 → colors.borderLight
      baseColor: colorScheme.outlineVariant,
      // ✅ Colors.grey.shade50 → colors.background
      highlightColor: colorScheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          // ✅ Colors.white → colors.surface
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ✅ إضافات مساعدة للـ Skeleton
// ═══════════════════════════════════════════════════════════════════════════════

/// Skeleton للنصوص
class AtharTextSkeleton extends StatelessWidget {
  final double? width;

  const AtharTextSkeleton({super.key, this.width});

  @override
  Widget build(BuildContext context) {
    return AtharSkeleton(
      width: width ?? 100.w,
      height: 14.h,
      borderRadius: AtharSpacing.xxs,
    );
  }
}

/// Skeleton للبطاقات
class AtharCardSkeleton extends StatelessWidget {
  const AtharCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AtharSkeleton(
      width: double.infinity,
      height: 80.h,
      borderRadius: AtharSpacing.md,
    );
  }
}

/// Skeleton للصور الدائرية (Avatar)
class AtharAvatarSkeleton extends StatelessWidget {
  final double size;

  const AtharAvatarSkeleton({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return AtharSkeleton(width: size.w, height: size.w, borderRadius: size / 2);
  }
}

/// Skeleton لقائمة عناصر
class AtharListSkeleton extends StatelessWidget {
  final int itemCount;

  const AtharListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: AtharSpacing.sm),
          child: Row(
            children: [
              const AtharAvatarSkeleton(size: 48),
              AtharGap.hMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AtharTextSkeleton(width: 150.w),
                    AtharGap.xs,
                    AtharTextSkeleton(width: 100.w),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//-----------------------------------------------------------------------

// // lib/core/design_system/molecules/skeletons/athar_skeleton.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 1 | File 1.12
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shimmer/shimmer.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// class AtharSkeleton extends StatelessWidget {
//   final double width;
//   final double height;
//   final double borderRadius;

//   const AtharSkeleton({
//     super.key,
//     required this.width,
//     required this.height,
//     this.borderRadius = 12,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;

//     return Shimmer.fromColors(
//       // ✅ Colors.grey.shade200 → colors.borderLight
//       baseColor: colors.borderLight,
//       // ✅ Colors.grey.shade50 → colors.background
//       highlightColor: colors.background,
//       child: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           // ✅ Colors.white → colors.surface
//           color: colors.surface,
//           borderRadius: BorderRadius.circular(borderRadius.r),
//         ),
//       ),
//     );
//   }
// }

// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ إضافات مساعدة للـ Skeleton
// // ═══════════════════════════════════════════════════════════════════════════════

// /// Skeleton للنصوص
// class AtharTextSkeleton extends StatelessWidget {
//   final double? width;

//   const AtharTextSkeleton({super.key, this.width});

//   @override
//   Widget build(BuildContext context) {
//     return AtharSkeleton(
//       width: width ?? 100.w,
//       height: 14.h,
//       borderRadius: AtharSpacing.xxs,
//     );
//   }
// }

// /// Skeleton للبطاقات
// class AtharCardSkeleton extends StatelessWidget {
//   const AtharCardSkeleton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return AtharSkeleton(
//       width: double.infinity,
//       height: 80.h,
//       borderRadius: AtharSpacing.md,
//     );
//   }
// }

// /// Skeleton للصور الدائرية (Avatar)
// class AtharAvatarSkeleton extends StatelessWidget {
//   final double size;

//   const AtharAvatarSkeleton({super.key, this.size = 40});

//   @override
//   Widget build(BuildContext context) {
//     return AtharSkeleton(width: size.w, height: size.w, borderRadius: size / 2);
//   }
// }

// /// Skeleton لقائمة عناصر
// class AtharListSkeleton extends StatelessWidget {
//   final int itemCount;

//   const AtharListSkeleton({super.key, this.itemCount = 5});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: List.generate(
//         itemCount,
//         (index) => Padding(
//           padding: EdgeInsets.only(bottom: AtharSpacing.sm),
//           child: Row(
//             children: [
//               const AtharAvatarSkeleton(size: 48),
//               AtharGap.hMd,
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AtharTextSkeleton(width: 150.w),
//                     AtharGap.xs,
//                     AtharTextSkeleton(width: 100.w),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shimmer/shimmer.dart';

// class AtharSkeleton extends StatelessWidget {
//   final double width;
//   final double height;
//   final double borderRadius;

//   const AtharSkeleton({
//     super.key,
//     required this.width,
//     required this.height,
//     this.borderRadius = 12,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade200,
//       highlightColor: Colors.grey.shade50,
//       child: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(borderRadius.r),
//         ),
//       ),
//     );
//   }
// }
