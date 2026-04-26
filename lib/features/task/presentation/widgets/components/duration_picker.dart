import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class DurationPicker extends StatelessWidget {
  final int? selectedDuration;
  final Function(int) onDurationSelected;

  const DurationPicker({
    super.key,
    required this.selectedDuration,
    required this.onDurationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.expectedDuration,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12.sp,
          ),
        ),
        AtharGap.sm,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [15, 30, 45, 60, 90, 120].map((minutes) {
              return Padding(
                padding: EdgeInsetsDirectional.only(start: 8.w),
                child: ChoiceChip(
                  label: Text(
                    minutes >= 60
                        ? l10n.durationHours(minutes ~/ 60)
                        : l10n.durationMinutesShort(minutes),
                  ),
                  selected: selectedDuration == minutes,
                  onSelected: (selected) {
                    if (selected) onDurationSelected(minutes);
                  },
                  selectedColor: colorScheme.primary.withValues(alpha: 0.1),
                  backgroundColor: colorScheme.surfaceContainerLowest,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: AtharRadii.radiusXl,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class DurationPicker extends StatelessWidget {
//   final int? selectedDuration;
//   final Function(int) onDurationSelected;

//   const DurationPicker({
//     super.key,
//     required this.selectedDuration,
//     required this.onDurationSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "المدة المتوقعة:",
//           style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//         ),
//         SizedBox(height: 8.h),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: [15, 30, 45, 60, 90, 120].map((minutes) {
//               return Padding(
//                 padding: EdgeInsets.only(left: 8.w),
//                 child: ChoiceChip(
//                   label: Text(
//                     minutes >= 60 ? "${minutes ~/ 60} س" : "$minutes د",
//                   ),
//                   selected: selectedDuration == minutes,
//                   onSelected: (selected) {
//                     if (selected) onDurationSelected(minutes);
//                   },
//                   selectedColor: AppColors.primary.withValues(alpha: 0.1),
//                   backgroundColor: AppColors.background,
//                   side: BorderSide.none,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
// }
