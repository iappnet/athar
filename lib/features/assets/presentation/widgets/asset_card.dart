import 'dart:io';
import 'package:athar/features/assets/data/models/asset_model.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';

class AssetCard extends StatelessWidget {
  final AssetModel asset;
  final VoidCallback onTap;

  const AssetCard({super.key, required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    // تحديد حالة الضمان والألوان
    final status = asset.status;
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case AssetWarrantyStatus.active:
        statusColor = Colors.green;
        statusText = l10n.assetStatusActive;
        statusIcon = Icons.verified_user;
        break;
      case AssetWarrantyStatus.expiringSoon:
        statusColor = Colors.orange;
        statusText = l10n.assetStatusExpiringSoon;
        statusIcon = Icons.warning_amber_rounded;
        break;
      case AssetWarrantyStatus.expired:
        statusColor = Colors.red.shade300;
        statusText = l10n.assetStatusExpired;
        statusIcon = Icons.no_encryption_gmailerrorred_outlined;
        break;
    }

    final imageAttachment = asset.attachments.firstOrNull;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // قسم الصورة
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                    child:
                        imageAttachment != null &&
                            imageAttachment.localPath != null &&
                            File(imageAttachment.localPath!).existsSync()
                        ? Image.file(
                            File(imageAttachment.localPath!),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.devices_other,
                              size: 40.sp,
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                  ),

                  // شارة الحالة
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.9),
                        borderRadius: AtharRadii.card,
                      ),
                      child: Row(
                        children: [
                          Icon(statusIcon, size: 12.sp, color: Colors.white),
                          AtharGap.hXxs,
                          Text(
                            asset.daysRemaining > 0
                                ? l10n.assetDaysRemaining(asset.daysRemaining)
                                : statusText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // قسم التفاصيل
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        if (asset.category != null)
                          Text(
                            asset.category!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: colorScheme.outline,
                            ),
                          ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (status == AssetWarrantyStatus.expiringSoon)
                          Icon(
                            Icons.build_circle_outlined,
                            size: 18.sp,
                            color: Colors.orange,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//-----------------------------------------------------------------------
// import 'dart:io';
// import 'package:athar/features/assets/data/models/asset_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:athar/core/design_system/theme/app_colors.dart';

// class AssetCard extends StatelessWidget {
//   final AssetModel asset;
//   final VoidCallback onTap;

//   const AssetCard({super.key, required this.asset, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     // 1. تحديد حالة الضمان والألوان
//     final status = asset.status;
//     Color statusColor;
//     String statusText;
//     IconData statusIcon;

//     switch (status) {
//       case AssetWarrantyStatus.active:
//         statusColor = Colors.green;
//         statusText = "ساري";
//         statusIcon = Icons.verified_user;
//         break;
//       case AssetWarrantyStatus.expiringSoon:
//         statusColor = Colors.orange;
//         statusText = "قارب على الانتهاء";
//         statusIcon = Icons.warning_amber_rounded;
//         break;
//       case AssetWarrantyStatus.expired:
//         statusColor = Colors.red.shade300;
//         statusText = "منتهي";
//         statusIcon = Icons.no_encryption_gmailerrorred_outlined;
//         break;
//     }

//     // 2. البحث عن صورة (أول صورة في المرفقات)
//     // نبحث عن مرفق نوعه 'image'
//     final imageAttachment = asset
//         .attachments
//         .firstOrNull; // سنحتاج لتحسين هذا لاحقاً للبحث عن الصور فقط

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // أ. قسم الصورة (مع شارة الضمان)
//             Expanded(
//               flex: 3,
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   // الصورة
//                   ClipRRect(
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(16.r),
//                     ),
//                     child:
//                         imageAttachment != null &&
//                             imageAttachment.localPath != null &&
//                             File(imageAttachment.localPath!).existsSync()
//                         ? Image.file(
//                             File(imageAttachment.localPath!),
//                             fit: BoxFit.cover,
//                           )
//                         : Container(
//                             color: Colors.grey.shade100,
//                             child: Icon(
//                               Icons.devices_other,
//                               size: 40.sp,
//                               color: Colors.grey.shade400,
//                             ),
//                           ),
//                   ),

//                   // شارة الحالة (Badge)
//                   Positioned(
//                     top: 8.h,
//                     left: 8.w,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 8.w,
//                         vertical: 4.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: statusColor.withValues(alpha: 0.9),
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(statusIcon, size: 12.sp, color: Colors.white),
//                           SizedBox(width: 4.w),
//                           Text(
//                             asset.daysRemaining > 0
//                                 ? "${asset.daysRemaining} يوم"
//                                 : statusText,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 10.sp,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: 'Tajawal',
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // ب. قسم التفاصيل
//             Expanded(
//               flex: 2,
//               child: Padding(
//                 padding: EdgeInsets.all(12.w),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           asset.name,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontFamily: 'Tajawal',
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14.sp,
//                           ),
//                         ),
//                         if (asset.category != null)
//                           Text(
//                             asset.category!,
//                             style: TextStyle(
//                               fontSize: 11.sp,
//                               color: Colors.grey,
//                               fontFamily: 'Tajawal',
//                             ),
//                           ),
//                       ],
//                     ),

//                     // شريط الصيانة (إذا كان مفعلاً)
//                     // هنا نضع أيقونة صغيرة تدل على وجود ملاحظات أو صيانة
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         if (status == AssetWarrantyStatus.expiringSoon)
//                           Icon(
//                             Icons.build_circle_outlined,
//                             size: 18.sp,
//                             color: Colors.orange,
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
