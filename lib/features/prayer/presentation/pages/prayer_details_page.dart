import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/design_system/tokens/athar_typography.dart';
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
                  fontFamily: AtharTypography.fontFamily,
                  fontFamilyFallback: AtharTypography.fontFallback,
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
