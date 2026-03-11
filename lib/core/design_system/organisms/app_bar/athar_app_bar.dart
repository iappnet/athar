import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../features/focus/presentation/pages/focus_page.dart';
import '../../../../features/calendar/presentation/pages/calendar_page.dart';
import '../../../../features/settings/presentation/pages/general_settings_page.dart';

class AtharAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final bool showActions;

  const AtharAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.showActions = true,
    required actions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final canPop = Navigator.canPop(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,

      leading:
          leading ??
          (canPop
              ? BackButton(
                  color: colorScheme.onSurface,
                  onPressed: () => Navigator.pop(context),
                )
              : IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GeneralSettingsPage(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.settings_outlined,
                    color: colorScheme.onSurface,
                    size: 24.sp,
                  ),
                  tooltip: l10n.appBarSettingsTooltip,
                )),

      title: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalendarPage()),
          );
        },
        borderRadius: AtharRadii.radiusMd,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AtharSpacing.lg,
            vertical: AtharSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  AtharGap.hXxs,
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14.sp,
                    color: colorScheme.primary.withValues(alpha: 0.7),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                AtharGap.xxs,
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      actions: showActions
          ? [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CalendarPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.calendar_month_rounded,
                  color: colorScheme.onSurface,
                  size: 22.sp,
                ),
                tooltip: l10n.appBarCalendarTooltip,
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FocusPage()),
                  );
                },
                icon: Icon(
                  Icons.timer_outlined,
                  color: colorScheme.onSurface,
                  size: 22.sp,
                ),
                tooltip: l10n.appBarFocusTooltip,
              ),
              AtharGap.hSm,
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.h);
}
//-----------------------------------------------------------------------
// // lib/core/design_system/organisms/app_bar/athar_app_bar.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 2 | File 2.8
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ❌ REMOVED: import '../../themes/app_colors.dart';

// import '../../../../features/focus/presentation/pages/focus_page.dart';
// import '../../../../features/calendar/presentation/pages/calendar_page.dart';
// import '../../../../features/settings/presentation/pages/general_settings_page.dart';

// class AtharAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final String? subtitle;
//   final Widget? leading;
//   final bool showActions;

//   const AtharAppBar({
//     super.key,
//     required this.title,
//     this.subtitle,
//     this.leading,
//     this.showActions = true,
//     required actions,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors from context
//     final colors = context.colors;
//     final canPop = Navigator.canPop(context);

//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       centerTitle: true,

//       // المنطق الذكي للزر الأيمن
//       leading:
//           leading ??
//           (canPop
//               ? BackButton(
//                   // ✅ AppColors.textPrimary → colors.textPrimary
//                   color: colors.textPrimary,
//                   onPressed: () => Navigator.pop(context),
//                 )
//               : IconButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const GeneralSettingsPage(),
//                       ),
//                     );
//                   },
//                   icon: Icon(
//                     Icons.settings_outlined,
//                     // ✅ AppColors.textPrimary → colors.textPrimary
//                     color: colors.textPrimary,
//                     size: 24.sp,
//                   ),
//                   tooltip: "الإعدادات",
//                 )),

//       // الوسط (Title)
//       title: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const CalendarPage()),
//           );
//         },
//         // ✅ BorderRadius.circular(12.r) → AtharRadii.radiusMd
//         borderRadius: AtharRadii.radiusMd,
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: AtharSpacing.lg,
//             vertical: AtharSpacing.sm,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     title,
//                     // ✅ AtharTypography
//                     style: AtharTypography.titleLarge.copyWith(
//                       // ✅ AppColors.textPrimary → colors.textPrimary
//                       color: colors.textPrimary,
//                     ),
//                   ),
//                   // ✅ SizedBox(width: 4.w) → AtharGap.hXxs
//                   AtharGap.hXxs,
//                   Icon(
//                     Icons.keyboard_arrow_down_rounded,
//                     size: 14.sp,
//                     // ✅ AppColors.primary.withOpacity(0.7)
//                     color: colors.primary.withValues(alpha: 0.7),
//                   ),
//                 ],
//               ),
//               if (subtitle != null) ...[
//                 // ✅ SizedBox(height: 4.h) → AtharGap.xxs
//                 AtharGap.xxs,
//                 Text(
//                   subtitle!,
//                   // ✅ AtharTypography
//                   style: AtharTypography.bodySmall.copyWith(
//                     // ✅ Colors.grey[700] → colors.textSecondary
//                     color: colors.textSecondary,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),

//       // يسار العنوان (Actions)
//       actions: showActions
//           ? [
//               IconButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const CalendarPage(),
//                     ),
//                   );
//                 },
//                 icon: Icon(
//                   Icons.calendar_month_rounded,
//                   // ✅ AppColors.textPrimary → colors.textPrimary
//                   color: colors.textPrimary,
//                   size: 22.sp,
//                 ),
//                 tooltip: "التقويم",
//               ),
//               IconButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const FocusPage()),
//                   );
//                 },
//                 icon: Icon(
//                   Icons.timer_outlined,
//                   // ✅ AppColors.textPrimary → colors.textPrimary
//                   color: colors.textPrimary,
//                   size: 22.sp,
//                 ),
//                 tooltip: "وضع التركيز",
//               ),
//               // ✅ SizedBox(width: 8.w) → AtharGap.hSm
//               AtharGap.hSm,
//             ]
//           : null,
//     );
//   }

//   @override
//   Size get preferredSize => Size.fromHeight(70.h);
// }
//-----------------------------------------------------------------------
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../themes/app_colors.dart';
// import '../../../../features/focus/presentation/pages/focus_page.dart';
// import '../../../../features/calendar/presentation/pages/calendar_page.dart';
// import '../../../../features/settings/presentation/pages/general_settings_page.dart';

// class AtharAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final String? subtitle;
//   final Widget? leading;
//   final bool showActions;

//   const AtharAppBar({
//     super.key,
//     required this.title,
//     this.subtitle,
//     this.leading,
//     this.showActions = true,
//     required actions,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // ✅ 1. التحقق هل يمكن الرجوع؟
//     final canPop = Navigator.canPop(context);

//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       centerTitle: true,

//       // ✅ 2. المنطق الذكي للزر الأيمن (Leading)
//       // الأولوية:
//       // 1. إذا مررت leading مخصص -> استخدمه.
//       // 2. إذا كان يمكن الرجوع (صفحة فرعية) -> اعرض زر رجوع.
//       // 3. إذا كانت الصفحة الرئيسية -> اعرض زر الإعدادات.
//       leading:
//           leading ??
//           (canPop
//               ? BackButton(
//                   color: AppColors.textPrimary,
//                   onPressed: () => Navigator.pop(context),
//                 )
//               : IconButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const GeneralSettingsPage(),
//                       ),
//                     );
//                   },
//                   icon: Icon(
//                     Icons.settings_outlined,
//                     color: AppColors.textPrimary,
//                     size: 24.sp,
//                   ),
//                   tooltip: "الإعدادات",
//                 )),

//       // 3. الوسط (Title)
//       title: InkWell(
//         onTap: () {
//           // إذا كنا بالفعل في صفحة التقويم، لا نعيد فتحها
//           // يمكن إضافة تحقق هنا، لكن الوضع الحالي مقبول
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const CalendarPage()),
//           );
//         },
//         borderRadius: BorderRadius.circular(12.r),
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     title,
//                     style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                       fontSize: 18.sp,
//                       color: AppColors.textPrimary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(width: 4.w),
//                   Icon(
//                     Icons.keyboard_arrow_down_rounded,
//                     size: 14.sp,
//                     color: AppColors.primary.withOpacity(0.7),
//                   ),
//                 ],
//               ),
//               if (subtitle != null) ...[
//                 SizedBox(height: 4.h),
//                 Text(
//                   subtitle!,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.grey[700],
//                     fontSize: 10.sp,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),

//       // 4. يسار العنوان (Actions)
//       actions: showActions
//           ? [
//               IconButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const CalendarPage(),
//                     ),
//                   );
//                 },
//                 icon: Icon(
//                   Icons.calendar_month_rounded,
//                   color: AppColors.textPrimary,
//                   size: 22.sp,
//                 ),
//                 tooltip: "التقويم",
//               ),
//               IconButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const FocusPage()),
//                   );
//                 },
//                 icon: Icon(
//                   Icons.timer_outlined,
//                   color: AppColors.textPrimary,
//                   size: 22.sp,
//                 ),
//                 tooltip: "وضع التركيز",
//               ),
//               SizedBox(width: 8.w),
//             ]
//           : null,
//     );
//   }

//   @override
//   Size get preferredSize => Size.fromHeight(70.h);
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../theme/app_colors.dart';
// import '../../../../features/focus/presentation/pages/focus_page.dart';
// import '../../../../features/calendar/presentation/pages/calendar_page.dart';
// import '../../../../features/settings/presentation/pages/general_settings_page.dart';

// class AtharAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final String? subtitle;
//   // ✅ التصحيح 1: تعريف المتغير هنا ليكون متاحاً للكلاس كاملًا
//   final Widget? leading;
//   // ألغينا leading القادم من الخارج لأننا سنثبت الإعدادات مكانه
//   final bool showActions;

//   const AtharAppBar({
//     super.key,
//     required this.title,
//     this.subtitle,
//     // ✅ التصحيح 2: استخدام this.leading لربطه بالمتغير أعلاه
//     this.leading,
//     this.showActions = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       centerTitle: true,

//       // 1. يمين العنوان (Leading): زر الإعدادات بدلاً من القائمة
//       // نستخدم leading الممرر (مثل زر الرجوع)، وإذا كان null نستخدم زر الإعدادات الافتراضي
//       leading:
//           leading ??
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const GeneralSettingsPage(),
//                 ),
//               );
//             },
//             icon: Icon(
//               Icons.settings_outlined,
//               color: AppColors.textPrimary,
//               size: 24.sp,
//             ),
//             tooltip: "الإعدادات",
//           ),

//       // 2. الوسط (Title): تفاعلي ويفتح التقويم
//       title: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const CalendarPage()),
//           );
//         },
//         borderRadius: BorderRadius.circular(12.r),
//         child: Padding(
//           // مساحة علوية وسفلية كما طلبت
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // العنوان الرئيسي مع أيقونة صغيرة تدل على النقر
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     title,
//                     style: Theme.of(context).textTheme.displayLarge?.copyWith(
//                       fontSize: 18.sp,
//                       color: AppColors.textPrimary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(width: 4.w),
//                   // أيقونة صغيرة جداً توحي بأن العنوان قابل للضغط
//                   Icon(
//                     Icons.keyboard_arrow_down_rounded,
//                     size: 14.sp,
//                     color: AppColors.primary.withValues(alpha: 0.7),
//                   ),
//                 ],
//               ),

//               // العنوان الفرعي مع مسافة
//               if (subtitle != null) ...[
//                 SizedBox(height: 4.h),
//                 Text(
//                   subtitle!,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.grey[700],
//                     fontSize: 10.sp, // تصغير الخط قليلاً ليكون أنيقاً
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),

//       // 3. يسار العنوان (Actions)
//       actions: showActions
//           ? [
//               // زر التقويم (وصول سريع) - تم تصغيره
//               IconButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const CalendarPage(),
//                     ),
//                   );
//                 },
//                 icon: Icon(
//                   Icons.calendar_month_rounded,
//                   color: AppColors.textPrimary,
//                   size: 22.sp, // تصغير الحجم
//                 ),
//                 tooltip: "التقويم",
//               ),

//               // زر التركيز - تم تصغيره
//               IconButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const FocusPage()),
//                   );
//                 },
//                 icon: Icon(
//                   Icons.timer_outlined,
//                   color: AppColors.textPrimary,
//                   size: 22.sp, // تصغير الحجم
//                 ),
//                 tooltip: "وضع التركيز",
//               ),

//               SizedBox(width: 8.w),
//             ]
//           : null,
//     );
//   }

//   @override
//   // قمت بزيادة الارتفاع قليلاً لاستيعاب المساحات العلوية والسفلية براحة
//   Size get preferredSize => Size.fromHeight(70.h);
// }
