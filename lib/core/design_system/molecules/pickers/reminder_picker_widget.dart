import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ReminderPickerWidget extends StatelessWidget {
  final DateTime? reminderTime;
  final bool isEnabled;
  final Function(bool) onToggle;
  final Function(DateTime) onTimeChanged;

  const ReminderPickerWidget({
    super.key,
    required this.reminderTime,
    required this.isEnabled,
    required this.onToggle,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.card,
        border: Border.all(
          color: isEnabled ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: isEnabled ? colorScheme.primary : colorScheme.outline,
              ),
              SizedBox(width: 8.w),
              Text(
                l10n.reminderToggleLabel,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              const Spacer(),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeThumbColor: colorScheme.primary,
              ),
            ],
          ),
          if (isEnabled) ...[
            const Divider(),
            InkWell(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                    reminderTime ?? DateTime.now(),
                  ),
                );
                if (time != null) {
                  final now = DateTime.now();
                  onTimeChanged(
                    DateTime(
                      now.year,
                      now.month,
                      now.day,
                      time.hour,
                      time.minute,
                    ),
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.reminderTimeLabel,
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    Text(
                      reminderTime != null
                          ? DateFormat('jm', 'ar').format(reminderTime!)
                          : l10n.reminderChooseTime,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:intl/intl.dart';

// class ReminderPickerWidget extends StatelessWidget {
//   final DateTime? reminderTime;
//   final bool isEnabled;
//   final Function(bool) onToggle;
//   final Function(DateTime) onTimeChanged;

//   const ReminderPickerWidget({
//     super.key,
//     required this.reminderTime,
//     required this.isEnabled,
//     required this.onToggle,
//     required this.onTimeChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(
//           color: isEnabled ? AppColors.primary : Colors.grey.shade200,
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.notifications_active_outlined,
//                 color: isEnabled ? AppColors.primary : Colors.grey,
//               ),
//               SizedBox(width: 8.w),
//               Text(
//                 "تفعيل التذكير",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
//               ),
//               const Spacer(),
//               Switch(
//                 value: isEnabled,
//                 onChanged: onToggle,
//                 activeColor: AppColors.primary,
//               ),
//             ],
//           ),
//           if (isEnabled) ...[
//             const Divider(),
//             InkWell(
//               onTap: () async {
//                 final time = await showTimePicker(
//                   context: context,
//                   initialTime: TimeOfDay.fromDateTime(
//                     reminderTime ?? DateTime.now(),
//                   ),
//                 );
//                 if (time != null) {
//                   final now = DateTime.now();
//                   onTimeChanged(
//                     DateTime(
//                       now.year,
//                       now.month,
//                       now.day,
//                       time.hour,
//                       time.minute,
//                     ),
//                   );
//                 }
//               },
//               child: Padding(
//                 padding: EdgeInsets.symmetric(vertical: 8.h),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("وقت التذكير", style: TextStyle(fontSize: 13.sp)),
//                     Text(
//                       reminderTime != null
//                           ? DateFormat('jm', 'ar').format(reminderTime!)
//                           : "اختر الوقت",
//                       style: TextStyle(
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
