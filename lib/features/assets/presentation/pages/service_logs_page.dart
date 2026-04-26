import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/assets/data/models/service_log_model.dart';
import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ServiceLogsPage extends StatelessWidget {
  final String serviceId;
  final String serviceName;

  const ServiceLogsPage({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.serviceLogsTitle(serviceName),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: StreamBuilder<List<ServiceLogModel>>(
        stream: context.read<AssetsCubit>().watchLogs(serviceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 60.sp,
                    color: colorScheme.outlineVariant,
                  ),
                  AtharGap.lg,
                  Text(
                    l10n.serviceLogsEmpty,
                    style: TextStyle(
                      color: colorScheme.outline,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: AtharSpacing.allXl,
            itemCount: logs.length,
            separatorBuilder: (c, i) => AtharGap.md,
            itemBuilder: (context, index) {
              return _buildLogCard(context, logs[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, ServiceLogModel log) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: AtharSpacing.allXl,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AtharRadii.card,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(log.performedAt),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              if (log.cost != null)
                Text(
                  l10n.serviceLogsCost(log.cost!),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          AtharGap.sm,
          Row(
            children: [
              if (log.odometerReading != null) ...[
                Icon(Icons.speed, size: 16.sp, color: colorScheme.outline),
                AtharGap.hXxs,
                Text(
                  l10n.serviceLogsOdometer(log.odometerReading!),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                AtharGap.hLg,
              ],
              if (log.notes != null && log.notes!.isNotEmpty) ...[
                Icon(Icons.notes, size: 16.sp, color: colorScheme.outline),
                AtharGap.hXxs,
                Expanded(
                  child: Text(
                    log.notes!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/assets/data/models/service_log_model.dart';
// import 'package:athar/features/assets/presentation/cubit/assets_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class ServiceLogsPage extends StatelessWidget {
//   final String serviceId;
//   final String serviceName;

//   const ServiceLogsPage({
//     super.key,
//     required this.serviceId,
//     required this.serviceName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text(
//           "سجل: $serviceName",
//           style: const TextStyle(
//             fontFamily: 'Tajawal',
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: AppColors.textPrimary,
//       ),
//       body: StreamBuilder<List<ServiceLogModel>>(
//         stream: context.read<AssetsCubit>().watchLogs(serviceId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final logs = snapshot.data ?? [];

//           if (logs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.history_toggle_off,
//                     size: 60.sp,
//                     color: Colors.grey.shade300,
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     "لا توجد سجلات سابقة",
//                     style: TextStyle(color: Colors.grey, fontSize: 16.sp),
//                   ),
//                 ],
//               ),
//             );
//           }

//           return ListView.separated(
//             padding: EdgeInsets.all(16.w),
//             itemCount: logs.length,
//             separatorBuilder: (c, i) => SizedBox(height: 12.h),
//             itemBuilder: (context, index) {
//               return _buildLogCard(logs[index]);
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLogCard(ServiceLogModel log) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 DateFormat('yyyy-MM-dd').format(log.performedAt),
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
//               ),
//               if (log.cost != null)
//                 Text(
//                   "${log.cost} ريال",
//                   style: TextStyle(
//                     color: AppColors.primary,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//             ],
//           ),
//           SizedBox(height: 8.h),
//           Row(
//             children: [
//               if (log.odometerReading != null) ...[
//                 Icon(Icons.speed, size: 16.sp, color: Colors.grey),
//                 SizedBox(width: 4.w),
//                 Text(
//                   "${log.odometerReading} كم",
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 SizedBox(width: 16.w),
//               ],
//               if (log.notes != null && log.notes!.isNotEmpty) ...[
//                 Icon(Icons.notes, size: 16.sp, color: Colors.grey),
//                 SizedBox(width: 4.w),
//                 Expanded(
//                   child: Text(
//                     log.notes!,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
