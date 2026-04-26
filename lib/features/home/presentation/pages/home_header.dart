// lib/features/home/presentation/pages/home_header.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.4
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/time_engine/athar_time_calculator.dart';
import 'package:athar/core/time_engine/athar_time_periods.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors from context
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    // تحديد التحية حسب الفترة الزمنية
    final period = AtharTimeCalculator.approximatePeriod();
    final String greeting;
    switch (period) {
      case AtharTimePeriod.dawn:
      case AtharTimePeriod.bakur:
      case AtharTimePeriod.morning:
      case AtharTimePeriod.duha:
        greeting = l10n.goodMorningChamp;
      case AtharTimePeriod.noon:
      case AtharTimePeriod.afternoon:
        greeting = l10n.haveANiceDay;
      case AtharTimePeriod.maghrib:
      case AtharTimePeriod.isha:
      case AtharTimePeriod.night:
      case AtharTimePeriod.lastThird:
      case AtharTimePeriod.undefined:
        greeting = l10n.goodEveningSimple;
    }

    // تنسيق التاريخ
    final dateStr = DateFormat('EEEE, d MMMM', 'ar').format(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              // ✅ AtharTypography
              style:
                  TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ).copyWith(
                    // ✅ AppColors.textPrimary → colors.textPrimary
                    color: colorScheme.onSurface,
                  ),
            ),
            // ✅ SizedBox(height: 4.h) → AtharGap.xxs
            AtharGap.xxs,
            Text(
              dateStr,
              // ✅ AtharTypography
              style:
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.6,
                  ).copyWith(
                    // ✅ Colors.grey → colors.textTertiary
                    color: colorScheme.outline,
                  ),
            ),
          ],
        ),
        // زر الإعدادات
        Container(
          decoration: BoxDecoration(
            // ✅ Colors.white → colors.surface
            color: colorScheme.surface,
            shape: BoxShape.circle,
            // ✅ Colors.grey.shade200 → colors.borderLight
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                // ✅ Colors.black.withValues(alpha: 0.05) → colors.shadow
                color: colorScheme.shadow.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.settingsComingSoon)));
            },
            icon: Icon(
              Icons.settings_outlined,
              // ✅ Colors.black87 → colors.textPrimary
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
// ----------------------------------------------------------------------------
// // lib/features/home/presentation/pages/home_header.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 2 | File 2.4
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';

// class HomeHeader extends StatelessWidget {
//   const HomeHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     // تحديد التحية حسب الوقت
//     final hour = DateTime.now().hour;
//     String greeting = l10n.welcomeBack;
//     if (hour < 12) {
//       greeting = l10n.goodMorningChamp;
//     } else if (hour < 17) {
//       greeting = l10n.haveANiceDay;
//     } else {
//       greeting = l10n.goodEveningSimple;
//     }

//     // تنسيق التاريخ
//     final dateStr = DateFormat('EEEE, d MMMM', 'ar').format(DateTime.now());

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               greeting,
//               // ✅ AtharTypography
//               style: AtharTypography.headlineSmall.copyWith(
//                 // ✅ AppColors.textPrimary → colors.textPrimary
//                 color: colors.textPrimary,
//               ),
//             ),
//             // ✅ SizedBox(height: 4.h) → AtharGap.xxs
//             AtharGap.xxs,
//             Text(
//               dateStr,
//               // ✅ AtharTypography
//               style: AtharTypography.bodyMedium.copyWith(
//                 // ✅ Colors.grey → colors.textTertiary
//                 color: colors.textTertiary,
//               ),
//             ),
//           ],
//         ),
//         // زر الإعدادات
//         Container(
//           decoration: BoxDecoration(
//             // ✅ Colors.white → colors.surface
//             color: colors.surface,
//             shape: BoxShape.circle,
//             // ✅ Colors.grey.shade200 → colors.borderLight
//             border: Border.all(color: colors.borderLight),
//             boxShadow: [
//               BoxShadow(
//                 // ✅ Colors.black.withValues(alpha: 0.05) → colors.shadow
//                 color: colors.shadow.withValues(alpha: 0.5),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: IconButton(
//             onPressed: () {
//               ScaffoldMessenger.of(
//                 context,
//               ).showSnackBar(SnackBar(content: Text(l10n.settingsComingSoon)));
//             },
//             icon: Icon(
//               Icons.settings_outlined,
//               // ✅ Colors.black87 → colors.textPrimary
//               color: colors.textPrimary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
// ----------------------------------------------------------------------------

//     // تحديد التحية حسب الوقت

//     // تنسيق التاريخ (مثال: الثلاثاء، 17 ديسمبر)

//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               greeting,
//               style: TextStyle(
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               dateStr,
//               style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//             ),
//         ),
//         // زر الإعدادات (بديل القائمة الجانبية)
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.grey.shade200),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//           ),
//           child: IconButton(
//               ScaffoldMessenger.of(context).showSnackBar(
//             },
//             icon: const Icon(Icons.settings_outlined, color: Colors.black87),
//           ),
//         ),

//------------------------------------------------------------------------
// lib/features/home/presentation/pages/home_header.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Stage 2 | File 2.4
// ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ❌ REMOVED: import '../../../../core/design_system/themes/app_colors.dart';

// class HomeHeader extends StatelessWidget {
//   const HomeHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;

//     // تحديد التحية حسب الوقت
//     final hour = DateTime.now().hour;
//     String greeting = "أهلاً بك 👋";
//     if (hour < 12) {
//       greeting = "صباح الخير، يا بطل ☀️";
//     } else if (hour < 17) {
//       greeting = "طاب يومك 🌤️";
//     } else {
//       greeting = "مساء الخير 🌙";
//     }

//     // تنسيق التاريخ
//     final dateStr = DateFormat('EEEE, d MMMM', 'ar').format(DateTime.now());

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               greeting,
//               // ✅ AtharTypography
//               style: AtharTypography.headlineSmall.copyWith(
//                 // ✅ AppColors.textPrimary → colors.textPrimary
//                 color: colors.textPrimary,
//               ),
//             ),
//             // ✅ SizedBox(height: 4.h) → AtharGap.xxs
//             AtharGap.xxs,
//             Text(
//               dateStr,
//               // ✅ AtharTypography
//               style: AtharTypography.bodyMedium.copyWith(
//                 // ✅ Colors.grey → colors.textTertiary
//                 color: colors.textTertiary,
//               ),
//             ),
//           ],
//         ),
//         // زر الإعدادات
//         Container(
//           decoration: BoxDecoration(
//             // ✅ Colors.white → colors.surface
//             color: colors.surface,
//             shape: BoxShape.circle,
//             // ✅ Colors.grey.shade200 → colors.borderLight
//             border: Border.all(color: colors.borderLight),
//             boxShadow: [
//               BoxShadow(
//                 // ✅ Colors.black.withValues(alpha: 0.05) → colors.shadow
//                 color: colors.shadow.withValues(alpha: 0.5),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: IconButton(
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("الإعدادات قادمة قريباً...")),
//               );
//             },
//             icon: Icon(
//               Icons.settings_outlined,
//               // ✅ Colors.black87 → colors.textPrimary
//               color: colors.textPrimary,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//------------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../../../../core/design_system/themes/app_colors.dart';

// class HomeHeader extends StatelessWidget {
//   const HomeHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // تحديد التحية حسب الوقت
//     final hour = DateTime.now().hour;
//     String greeting = "أهلاً بك 👋";
//     if (hour < 12) {
//       greeting = "صباح الخير، يا بطل ☀️";
//     } else if (hour < 17) {
//       greeting = "طاب يومك 🌤️";
//     } else {
//       greeting = "مساء الخير 🌙";
//     }

//     // تنسيق التاريخ (مثال: الثلاثاء، 17 ديسمبر)
//     final dateStr = DateFormat('EEEE, d MMMM', 'ar').format(DateTime.now());

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               greeting,
//               style: TextStyle(
//                 fontSize: 20.sp,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               dateStr,
//               style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//             ),
//           ],
//         ),
//         // زر الإعدادات (بديل القائمة الجانبية)
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             shape: BoxShape.circle,
//             border: Border.all(color: Colors.grey.shade200),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: IconButton(
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("الإعدادات قادمة قريباً...")),
//               );
//             },
//             icon: const Icon(Icons.settings_outlined, color: Colors.black87),
//           ),
//         ),
//       ],
//     );
//   }
// }
