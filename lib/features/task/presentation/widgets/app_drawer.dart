// lib/features/task/presentation/widgets/app_drawer.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 4 | Part 1 | File 1
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/features/focus/presentation/pages/focus_page.dart';
import 'package:athar/features/habits/presentation/pages/habit_page.dart';
import 'package:athar/features/stats/presentation/pages/stats_page.dart';
import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import '../../../settings/presentation/pages/smart_zones_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors & l10n from context
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Drawer(
      // ✅ AppColors.background → colors.background
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          // 1. الترويسة (Header)
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 60.h,
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
            ),
            decoration: BoxDecoration(
              // ✅ AppColors.surface → colors.surface
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30.r,
                  // ✅ AppColors.primary → colors.primary
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person,
                    size: 35.sp,
                    color: colorScheme.primary,
                  ),
                ),
                // ✅ SizedBox(height: 12.h) → AtharGap.md
                AtharGap.md,
                Text(
                  // ✅ l10n: "أهلاً بك 👋"
                  l10n.drawerWelcomeGreeting,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  // ✅ l10n: "لنجعل يومك مثمراً"
                  l10n.drawerMotivationalSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // 2. قائمة الخيارات
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              children: [
                _buildDrawerItem(
                  colorScheme: colorScheme,
                  icon: Icons.timelapse,
                  // ✅ l10n: "المناطق الذكية"
                  title: l10n.drawerSmartZones,
                  // ✅ l10n: "اضبط أوقات العمل والراحة"
                  subtitle: l10n.drawerSmartZonesSubtitle,
                  onTap: () async {
                    final taskCubit = context.read<TaskCubit>();
                    Navigator.pop(context);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SmartZonesPage(),
                      ),
                    );
                    taskCubit.refresh();
                  },
                ),
                _buildDrawerItem(
                  colorScheme: colorScheme,
                  icon: Icons.track_changes,
                  // ✅ l10n: "متتبع العادات"
                  title: l10n.drawerHabitTracker,
                  // ✅ l10n: "ابنِ عاداتك واستمر عليها"
                  subtitle: l10n.drawerHabitTrackerSubtitle,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HabitsPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  colorScheme: colorScheme,
                  icon: Icons.timer,
                  // ✅ l10n: "مؤقت التركيز"
                  title: l10n.drawerFocusTimer,
                  // ✅ l10n: "تقنية بومودورو (25 دقيقة)"
                  subtitle: l10n.drawerFocusTimerSubtitle,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FocusPage(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  colorScheme: colorScheme,
                  icon: Icons.bar_chart,
                  // ✅ l10n: "الإحصائيات"
                  title: l10n.drawerStatistics,
                  // ✅ l10n: "راقب إنجازك الأسبوعي"
                  subtitle: l10n.drawerStatisticsSubtitle,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StatisticsPage(),
                      ),
                    );
                  },
                ),
                Divider(
                  indent: 20,
                  endIndent: 20,
                  color: colorScheme.outlineVariant,
                ),
                _buildDrawerItem(
                  colorScheme: colorScheme,
                  icon: Icons.settings,
                  // ✅ l10n: "الإعدادات العامة"
                  title: l10n.drawerGeneralSettings,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // 3. التذييل (Footer)
          Padding(
            padding: AtharSpacing.allLg,
            child: Text(
              // ✅ l10n: "الإصدار {version}"
              l10n.drawerVersionLabel('1.0.0'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: 0.5,
              ).copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: AtharSpacing.allSm,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.05),
          // ✅ BorderRadius.circular(8.r) → AtharRadii.radiusSm
          borderRadius: AtharRadii.radiusSm,
        ),
        child: Icon(icon, color: colorScheme.primary, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ).copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ).copyWith(color: colorScheme.onSurfaceVariant),
            )
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
      shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusSm),
    );
  }
}
// import 'package:athar/features/focus/presentation/pages/focus_page.dart';
// import 'package:athar/features/habits/presentation/pages/habit_page.dart';
// import 'package:athar/features/stats/presentation/pages/stats_page.dart';
// import 'package:athar/features/task/presentation/cubit/task_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../../settings/presentation/pages/smart_zones_page.dart';

// class AppDrawer extends StatelessWidget {
//   const AppDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: AppColors.background,
//       child: Column(
//         children: [
//           // 1. الترويسة (Header)
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.only(
//               top: 60.h,
//               bottom: 20.h,
//               left: 20.w,
//               right: 20.w,
//             ),
//             decoration: const BoxDecoration(
//               color: AppColors.surface,
//               border: Border(bottom: BorderSide(color: Colors.black12)),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   radius: 30.r,
//                   backgroundColor: AppColors.primary.withValues(alpha: 0.1),
//                   child: Icon(
//                     Icons.person,
//                     size: 35.sp,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 SizedBox(height: 12.h),
//                 Text(
//                   "أهلاً بك 👋",
//                   style: Theme.of(
//                     context,
//                   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   "لنجعل يومك مثمراً",
//                   style: Theme.of(
//                     context,
//                   ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
//                 ),
//               ],
//             ),
//           ),

//           // 2. قائمة الخيارات
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.symmetric(vertical: 10.h),
//               children: [
//                 // _buildDrawerItem(
//                 //   icon: Icons.timelapse,
//                 //   title: "المناطق الذكية",
//                 //   subtitle: "اضبط أوقات العمل والراحة",
//                 //   onTap: () {
//                 //     Navigator.pop(context); // إغلاق القائمة الجانبية أولاً
//                 //     Navigator.push(
//                 //       context,
//                 //       MaterialPageRoute(
//                 //         builder: (context) => const SmartZonesPage(),
//                 //       ),
//                 //     );
//                 //   },
//                 // ),
//                 _buildDrawerItem(
//                   icon: Icons.timelapse,
//                   title: "المناطق الذكية",
//                   subtitle: "اضبط أوقات العمل والراحة",
//                   onTap: () async {
//                     // 1. التقط الكيوبت واحفظه في متغير هنا (والقائمة ما زالت مفتوحة)
//                     // هذا هو الحل السحري! 🪄
//                     final taskCubit = context.read<TaskCubit>();
//                     Navigator.pop(
//                       context,
//                     ); // إغلاق القائمة (الـ Context سيموت هنا)
//                     // 2. الذهاب لصفحة الإعدادات والانتظار
//                     await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const SmartZonesPage(),
//                       ),
//                     );
//                     // 3. استدعاء التحديث باستخدام المتغير المحفوظ
//                     // لاحظ أننا لم نعد نستخدم context هنا
//                     taskCubit.refresh();
//                   },
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.track_changes,
//                   title: "متتبع العادات",
//                   subtitle: "ابنِ عاداتك واستمر عليها",
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       // تأكد من استيراد HabitsPage
//                       MaterialPageRoute(
//                         builder: (context) => const HabitsPage(),
//                       ),
//                     );
//                   },
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.timer, // أيقونة المؤقت
//                   title: "مؤقت التركيز",
//                   subtitle: "تقنية بومودورو (25 دقيقة)",
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const FocusPage(),
//                       ),
//                     );
//                   },
//                 ),
//                 _buildDrawerItem(
//                   icon: Icons.bar_chart,
//                   title: "الإحصائيات",
//                   subtitle: "راقب إنجازك الأسبوعي",
//                   onTap: () {
//                     Navigator.pop(context);
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const StatisticsPage(),
//                       ),
//                     );
//                   },
//                 ),
//                 const Divider(indent: 20, endIndent: 20),
//                 _buildDrawerItem(
//                   icon: Icons.settings,
//                   title: "الإعدادات العامة",
//                   onTap: () {},
//                 ),
//               ],
//             ),
//           ),

//           // 3. التذييل (Footer)
//           Padding(
//             padding: EdgeInsets.all(20.w),
//             child: Text(
//               "الإصدار 1.0.0",
//               style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp),
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDrawerItem({
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Container(
//         padding: EdgeInsets.all(8.w),
//         decoration: BoxDecoration(
//           color: AppColors.primary.withValues(alpha: 0.05),
//           borderRadius: BorderRadius.circular(8.r),
//         ),
//         child: Icon(icon, color: AppColors.primary, size: 20.sp),
//       ),
//       title: Text(
//         title,
//         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
//       ),
//       subtitle: subtitle != null
//           ? Text(
//               subtitle,
//               style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//             )
//           : null,
//       onTap: onTap,
//       contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
//     );
//   }
// }
