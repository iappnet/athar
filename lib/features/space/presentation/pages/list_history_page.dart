import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/space/data/models/list_log_model.dart';
import 'package:athar/features/space/domain/repositories/list_repository.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:athar/core/di/injection.dart';

class ListHistoryPage extends StatelessWidget {
  final String moduleId;
  final String moduleName;

  const ListHistoryPage({
    super.key,
    required this.moduleId,
    required this.moduleName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.listHistoryTitle(moduleName)),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: StreamBuilder<List<ListLogModel>>(
        stream: getIt<ListRepository>().watchLogs(moduleId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return Center(
              child: Text(
                l10n.listHistoryEmpty,
                style: TextStyle(color: colorScheme.outline, fontSize: 16.sp),
              ),
            );
          }

          return ListView.separated(
            padding: AtharSpacing.allXl,
            itemCount: logs.length,
            separatorBuilder: (c, i) => Divider(height: 24.h),
            itemBuilder: (context, index) {
              final log = logs[index];
              return Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 16.sp, color: Colors.green),
                  ),
                  AtharGap.hMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.itemName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'yyyy-MM-dd – hh:mm a',
                          ).format(log.performedAt),
                          style: TextStyle(
                            color: colorScheme.outline,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (log.quantity != null)
                    Text(
                      "x${log.quantity}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
//----------------------------------------------------------------------
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/space/data/models/list_log_model.dart';
// import 'package:athar/features/space/domain/repositories/list_repository.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:athar/core/di/injection.dart';

// class ListHistoryPage extends StatelessWidget {
//   final String moduleId;
//   final String moduleName;

//   const ListHistoryPage({
//     super.key,
//     required this.moduleId,
//     required this.moduleName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // نستخدم StreamBuilder مباشرة مع Repository هنا للتبسيط
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text(
//           "سجل مشتريات: $moduleName",
//           style: const TextStyle(fontFamily: 'Tajawal'),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         foregroundColor: Colors.black,
//       ),
//       body: StreamBuilder<List<ListLogModel>>(
//         stream: getIt<ListRepository>().watchLogs(moduleId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final logs = snapshot.data ?? [];
//           if (logs.isEmpty) {
//             return Center(
//               child: Text(
//                 "السجل فارغ",
//                 style: TextStyle(color: Colors.grey, fontSize: 16.sp),
//               ),
//             );
//           }

//           return ListView.separated(
//             padding: EdgeInsets.all(16.w),
//             itemCount: logs.length,
//             separatorBuilder: (c, i) => Divider(height: 24.h),
//             itemBuilder: (context, index) {
//               final log = logs[index];
//               return Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(8.w),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade50,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.check, size: 16.sp, color: Colors.green),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           log.itemName,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14.sp,
//                           ),
//                         ),
//                         Text(
//                           DateFormat(
//                             'yyyy-MM-dd – hh:mm a',
//                           ).format(log.performedAt),
//                           style: TextStyle(color: Colors.grey, fontSize: 12.sp),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (log.quantity != null)
//                     Text(
//                       "x${log.quantity}",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                 ],
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
//----------------------------------------------------------------------
