import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class DateTimePicker extends StatelessWidget {
  final DateTime selectedDate;
  final bool isHijriMode;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const DateTimePicker({
    super.key,
    required this.selectedDate,
    required this.isHijriMode,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final hijriDate = HijriCalendar.fromDate(selectedDate);
    final hijriString =
        "${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear}";
    final gregorianString = DateFormat('d MMM yyyy', 'ar').format(selectedDate);
    final timeString = DateFormat('h:mm a', 'ar').format(selectedDate);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // التاريخ
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChip(
              context,
              Icons.calendar_today,
              isHijriMode ? hijriString : gregorianString,
              onDateTap,
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.w, top: 4.h),
              child: Text(
                l10n.correspondingDate(
                  isHijriMode ? gregorianString : hijriString,
                ),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        AtharGap.hSm,
        // الوقت
        _buildChip(context, Icons.access_time, timeString, onTimeTap),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AtharRadii.radiusSm,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: AtharRadii.radiusSm,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: colorScheme.onSurfaceVariant),
            AtharGap.hXs,
            Text(label, style: TextStyle(fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }
}
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:hijri/hijri_calendar.dart';

// class DateTimePicker extends StatelessWidget {
//   final DateTime selectedDate;
//   final bool isHijriMode;
//   final VoidCallback onDateTap;
//   final VoidCallback onTimeTap;

//   const DateTimePicker({
//     super.key,
//     required this.selectedDate,
//     required this.isHijriMode,
//     required this.onDateTap,
//     required this.onTimeTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final hijriDate = HijriCalendar.fromDate(selectedDate);
//     final hijriString =
//         "${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear}";
//     final gregorianString = DateFormat('d MMM yyyy', 'ar').format(selectedDate);
//     final timeString = DateFormat('h:mm a', 'ar').format(selectedDate);

//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // التاريخ
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildChip(
//               Icons.calendar_today,
//               isHijriMode ? hijriString : gregorianString,
//               onDateTap,
//             ),
//             Padding(
//               padding: EdgeInsets.only(right: 8.w, top: 4.h),
//               child: Text(
//                 isHijriMode
//                     ? "الموافق: $gregorianString"
//                     : "الموافق: $hijriString",
//                 style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(width: 8.w),
//         // الوقت
//         Padding(
//           padding: EdgeInsets.only(top: 0),
//           child: _buildChip(Icons.access_time, timeString, onTimeTap),
//         ),
//       ],
//     );
//   }

//   Widget _buildChip(IconData icon, String label, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8.r),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         decoration: BoxDecoration(
//           color: AppColors.background,
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 16.sp, color: Colors.grey),
//             SizedBox(width: 6.w),
//             Text(label, style: TextStyle(fontSize: 12.sp)),
//           ],
//         ),
//       ),
//     );
//   }
// }
