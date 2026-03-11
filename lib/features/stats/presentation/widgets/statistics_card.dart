import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../pages/stats_page.dart';

class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StatisticsPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: AtharSpacing.allXl,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AtharRadii.radiusLg,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                color: Colors.purple,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.statsCardTitle,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    l10n.statsCardSubtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../pages/stats_page.dart';

// class StatisticsCard extends StatelessWidget {
//   const StatisticsCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const StatisticsPage()),
//         );
//       },
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // أيقونة دائرية
//             Container(
//               padding: EdgeInsets.all(12.w),
//               decoration: BoxDecoration(
//                 color: Colors.purple.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.bar_chart_rounded,
//                 color: Colors.purple,
//                 size: 24.sp,
//               ),
//             ),
//             SizedBox(width: 16.w),

//             // النصوص
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "إحصائيات الأثر",
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   Text(
//                     "شاهد ملخص أدائك وتركيزك",
//                     style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),

//             // سهم
//             Icon(
//               Icons.arrow_forward_ios_rounded,
//               size: 16.sp,
//               color: Colors.grey,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
