import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../../../features/settings/presentation/cubit/settings_state.dart';
import '../../../../features/settings/data/models/user_settings.dart';
import '../../../../features/prayer/presentation/cubit/prayer_cubit.dart';
import '../../../../features/prayer/presentation/cubit/prayer_state.dart';
import 'next_prayer_card.dart';
import 'package:athar/core/design_system/tokens.dart';

// ✅ تعريف أنواع الصفحات التي تستخدم البطاقة
enum PageType { dashboard, tasks, habits, projects }

class SmartPrayerCardWrapper extends StatelessWidget {
  final PageType pageType;

  const SmartPrayerCardWrapper({super.key, required this.pageType});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        // 1. التأكد من تحميل الإعدادات
        if (settingsState is! SettingsLoaded) return const SizedBox.shrink();

        final settings = settingsState.settings;

        // 2. التحقق من السويتش الرئيسي (تفعيل مواقيت الصلاة)
        if (!settings.isPrayerEnabled) {
          return const SizedBox.shrink(); // الميزة معطلة بالكامل
        }

        // 3. التحقق من مكان العرض (Display Mode)
        bool shouldShow = false;

        switch (pageType) {
          case PageType.dashboard:
            // الداشبورد يظهر دائماً طالما الميزة مفعلة
            shouldShow = true;
            break;

          case PageType.tasks:
            // يظهر إذا كان الخيار "داشبورد ومهام" أو "الكل"
            if (settings.prayerCardDisplayMode ==
                    PrayerCardDisplayMode.dashboardAndTasks ||
                settings.prayerCardDisplayMode ==
                    PrayerCardDisplayMode.allPages) {
              shouldShow = true;
            }
            break;

          case PageType.habits:
          case PageType.projects:
            // يظهر فقط إذا كان الخيار "الكل"
            if (settings.prayerCardDisplayMode ==
                PrayerCardDisplayMode.allPages) {
              shouldShow = true;
            }
            break;
        }

        if (!shouldShow) return const SizedBox.shrink();

        // 4. بناء البطاقة (إذا تحقق الشرط)
        return BlocBuilder<PrayerCubit, PrayerState>(
          builder: (context, prayerState) {
            if (prayerState is PrayerLoaded) {
              return NextPrayerCard(allPrayers: prayerState.allPrayers);
            }
            if (prayerState is PrayerLoading || prayerState is PrayerInitial) {
              final cs = Theme.of(context).colorScheme;
              return Container(
                height: 90.h,
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: AtharRadii.radiusLg,
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            if (prayerState is PrayerError) {
              final cs = Theme.of(context).colorScheme;
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: cs.errorContainer.withValues(alpha: 0.3),
                  borderRadius: AtharRadii.radiusLg,
                  border: Border.all(
                      color: cs.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off_rounded,
                        color: cs.error, size: 20.sp),
                    AtharGap.hSm,
                    Expanded(
                      child: Text(
                        prayerState.message,
                        style: TextStyle(
                            color: cs.error, fontSize: 12.sp),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          context.read<PrayerCubit>().loadPrayerTimes(),
                      child: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}
