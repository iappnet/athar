import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/prayer/presentation/widgets/prayer_month_view.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/design_system/organisms/app_bar/athar_app_bar.dart';
import '../widgets/prayer_day_view.dart';
import '../widgets/prayer_week_view.dart';

class PrayerDetailsPage extends StatelessWidget {
  const PrayerDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AtharAppBar(
          title: l10n.prayerTimesTitle,
          subtitle: l10n.prayerTimesSubtitle,
          leading: BackButton(color: colorScheme.onSurface),
          actions: null,
        ),
        body: Column(
          children: [
            // Tab bar
            Container(
              margin: AtharSpacing.allXl,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: AtharRadii.card,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: TabBar(
                labelColor: colorScheme.onPrimary,
                unselectedLabelColor: colorScheme.outline,
                indicator: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: AtharRadii.radiusMd,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
                tabs: [
                  Tab(text: l10n.prayerTabToday),
                  Tab(text: l10n.prayerTabWeek),
                  Tab(text: l10n.prayerTabMonth),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  PrayerDayView(date: DateTime.now()),
                  const PrayerWeekView(),
                  const PrayerMonthView(),
                  // Center(child: Text(l10n.prayerMonthComingSoon)),
                ],
              ),
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
// import '../../../../core/design_system/organisms/app_bar/athar_app_bar.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../widgets/prayer_day_view.dart';
// import '../widgets/prayer_week_view.dart';

// class PrayerDetailsPage extends StatelessWidget {
//   const PrayerDetailsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3, // عدد التبويبات
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: const AtharAppBar(
//           title: "مواقيت الصلاة",
//           subtitle: "إن الصلاة كانت على المؤمنين كتاباً موقوتاً",
//           // ✅ إضافة زر الرجوع هنا
//           leading: BackButton(color: AppColors.textPrimary),
//           actions: null,
//           // (اختياري) يمكنك إخفاء أزرار الإجراءات في هذه الصفحة إذا أردت التركيز
//           // showActions: false,
//         ),
//         body: Column(
//           children: [
//             // شريط التبويبات
//             Container(
//               margin: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12.r),
//                 border: Border.all(color: Colors.grey.shade200),
//               ),
//               child: TabBar(
//                 labelColor: Colors.white,
//                 unselectedLabelColor: Colors.grey,
//                 indicator: BoxDecoration(
//                   color: AppColors.primary,
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//                 indicatorSize: TabBarIndicatorSize.tab,
//                 labelStyle: TextStyle(
//                   fontFamily: 'Cairo',
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14.sp,
//                 ),
//                 tabs: const [
//                   Tab(text: "اليوم"),
//                   Tab(text: "أسبوع"),
//                   Tab(text: "شهر"),
//                 ],
//               ),
//             ),

//             // محتوى التبويبات
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   // 1. تبويب اليوم
//                   PrayerDayView(date: DateTime.now()),

//                   // 2. تبويب الأسبوع (قائمة بسيطة للأيام القادمة)
//                   // ListView.builder(
//                   //   itemCount: 7,
//                   //   itemBuilder: (context, index) {
//                   //     final date = DateTime.now().add(Duration(days: index));
//                   //     return ExpansionTile(
//                   //       title: Text(
//                   //         "يوم ${index + 1}",
//                   //       ), // يمكن تحسينه ليعرض اسم اليوم
//                   //       children: [
//                   //         // نعيد استخدام ودجت اليوم ولكن بارتفاع محدد
//                   //         SizedBox(
//                   //           height: 400.h,
//                   //           child: PrayerDayView(date: date),
//                   //         ),
//                   //       ],
//                   //     );
//                   //   },
//                   // ),
//                   // 2. تبويب الأسبوع (الجديد)
//                   const PrayerWeekView(), // <--- هنا التغيير
//                   // 3. تبويب الشهر (مؤقت)
//                   const Center(child: Text("التقويم الشهري قادم قريباً")),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
