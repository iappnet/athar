// lib/features/habits/presentation/widgets/athkar_card.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Bonus | athkar_card.dart
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import '../../data/models/habit_model.dart';
import '../../../dhikr/presentation/widgets/dhikr_bottom_sheet.dart';

class AthkarCard extends StatelessWidget {
  final HabitModel habit;

  const AthkarCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isMorning = habit.period == HabitPeriod.morning;

    final cardColor = isMorning
        ? const Color(0xFFFFF8E1)
        : const Color(0xFFE8EAF6);

    final iconColor = isMorning ? Colors.orange : const Color(0xFF3F51B5);

    final iconData = isMorning
        ? Icons.wb_sunny_rounded
        : Icons.nights_stay_rounded;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DhikrBottomSheet(habit: habit),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
        decoration: BoxDecoration(
          color: cardColor,
          // ✅ BorderRadius.circular(16.r) → AtharRadii.radiusLg
          borderRadius: AtharRadii.radiusLg,
          boxShadow: [
            BoxShadow(
              // ✅ Colors.black.withOpacity → colors.shadow
              color: colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              habit.title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                // ✅ Colors.black87 → colors.textPrimary
                color: colorScheme.onSurface,
              ),
            ),
            Icon(iconData, size: 28.sp, color: iconColor),
          ],
        ),
      ),
    );
  }
}
//-----------------------------------------------------------------------
// // lib/features/habits/presentation/widgets/athkar_card.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Bonus | athkar_card.dart
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// import '../../data/models/habit_model.dart';
// import '../../../dhikr/presentation/widgets/dhikr_bottom_sheet.dart';

// class AthkarCard extends StatelessWidget {
//   final HabitModel habit;

//   const AthkarCard({super.key, required this.habit});

//   @override
//   Widget build(BuildContext context) {
//     final colors = context.colors;

//     final isMorning = habit.period == HabitPeriod.morning;

//     final cardColor = isMorning
//         ? const Color(0xFFFFF8E1)
//         : const Color(0xFFE8EAF6);

//     final iconColor = isMorning ? Colors.orange : const Color(0xFF3F51B5);

//     final iconData = isMorning
//         ? Icons.wb_sunny_rounded
//         : Icons.nights_stay_rounded;

//     return GestureDetector(
//       onTap: () {
//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           backgroundColor: Colors.transparent,
//           builder: (context) => DhikrBottomSheet(habit: habit),
//         );
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
//         padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
//         decoration: BoxDecoration(
//           color: cardColor,
//           // ✅ BorderRadius.circular(16.r) → AtharRadii.radiusLg
//           borderRadius: AtharRadii.radiusLg,
//           boxShadow: [
//             BoxShadow(
//               // ✅ Colors.black.withOpacity → colors.shadow
//               color: colors.shadow.withValues(alpha: 0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               habit.title,
//               style: TextStyle(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//                 // ✅ Colors.black87 → colors.textPrimary
//                 color: colors.textPrimary,
//                 fontFamily: 'Tajawal',
//               ),
//             ),
//             Icon(iconData, size: 28.sp, color: iconColor),
//           ],
//         ),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../data/models/habit_model.dart';
// import '../../../dhikr/presentation/widgets/dhikr_bottom_sheet.dart';

// class AthkarCard extends StatelessWidget {
//   final HabitModel habit;

//   const AthkarCard({super.key, required this.habit});

//   @override
//   Widget build(BuildContext context) {
//     // تحديد الأيقونة واللون بناءً على الفترة
//     final isMorning = habit.period == HabitPeriod.morning;

//     // ألوان هادئة وأنيقة (صباحي: برتقالي فاتح / مسائي: كحلي فاتح)
//     final cardColor = isMorning
//         ? const Color(0xFFFFF8E1) // لون صباحي هادئ
//         : const Color(0xFFE8EAF6); // لون مسائي هادئ

//     final iconColor = isMorning ? Colors.orange : const Color(0xFF3F51B5);

//     final iconData = isMorning
//         ? Icons.wb_sunny_rounded
//         : Icons.nights_stay_rounded;

//     return GestureDetector(
//       onTap: () {
//         // فتح نافذة الأذكار
//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: true, // للسماح بالتحكم في الطول
//           backgroundColor: Colors.transparent,
//           builder: (context) => DhikrBottomSheet(habit: habit),
//         );
//       },
//       child: Container(
//         margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
//         padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
//         decoration: BoxDecoration(
//           color: cardColor,
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             // العنوان
//             Text(
//               habit.title,
//               style: TextStyle(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//                 fontFamily: 'Tajawal', // أو الخط المستخدم في تطبيقك
//               ),
//             ),

//             // الأيقونة المعبرة فقط (بدون أي نصوص أو أرقام كما طلبت)
//             Icon(iconData, size: 28.sp, color: iconColor),
//           ],
//         ),
//       ),
//     );
//   }
// }

//-----------------------------------------------------------------------
