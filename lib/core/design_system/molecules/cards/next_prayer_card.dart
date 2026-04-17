// lib/core/design_system/molecules/cards/next_prayer_card.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ FIXED - حل مشكلة Row Overflow (245px)
// المشكلة: _buildHeaderRow كان يحتوي على Row بدون Flexible
// الحل: لف النصوص بـ Flexible + استخدام IntrinsicWidth للعناصر الداخلية
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:ui' as ui;
import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:athar/core/services/prayer_timer_service.dart';
import '../../../../core/di/injection.dart';

import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import '../../../../features/prayer/domain/models/prayer_timer_status.dart';
import '../../../../features/calendar/presentation/pages/calendar_page.dart';
import '../../../../features/prayer/presentation/pages/prayer_details_page.dart';
import '../../../../features/settings/presentation/pages/location_settings_page.dart';

import '../../../../features/dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
import 'package:athar/features/habits/presentation/cubit/habit_cubit.dart';

class NextPrayerCard extends StatefulWidget {
  final List<PrayerTime>? allPrayers;
  const NextPrayerCard({super.key, this.allPrayers});

  @override
  State<NextPrayerCard> createState() => _NextPrayerCardState();
}

class _NextPrayerCardState extends State<NextPrayerCard> {
  late final PrayerTimerService _timerService;

  @override
  void initState() {
    super.initState();
    _timerService = getIt<PrayerTimerService>();
    if (widget.allPrayers != null && widget.allPrayers!.isNotEmpty) {
      _timerService.startTimer(widget.allPrayers!);
    }
  }

  @override
  void didUpdateWidget(covariant NextPrayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allPrayers != oldWidget.allPrayers &&
        widget.allPrayers != null) {
      _timerService.startTimer(widget.allPrayers!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<PrayerTimerStatus>(
      stream: _timerService.timerStream,
      initialData: PrayerTimerStatus.initial(),
      builder: (context, snapshot) {
        final status = snapshot.data!;

        if (widget.allPrayers == null || widget.allPrayers!.isEmpty) {
          return const SizedBox.shrink();
        }

        // Color logic (Islamic card special design)
        Color displayColor = status.statusColor;
        String timePrefix = l10n.prayerCardTimePrefix;

        if (status.statusLabel.contains("حان الآن")) {
          displayColor = const Color(0xFF4CAF50);
          timePrefix = "";
        } else if (status.statusLabel.contains("الحالية")) {
          displayColor = const Color(0xFF29B6F6);
          timePrefix = "";
        }

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: AtharSpacing.lg,
            vertical: AtharSpacing.xxs,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AtharRadii.radiusXxl,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrayerDetailsPage()),
            ),
            borderRadius: AtharRadii.radiusLg,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AtharSpacing.lg,
                vertical: AtharSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderRow(context, status, l10n),

                  AtharGap.md,

                  // Nafl alert (Duha / Qiyam)
                  if (status.isDuhaTime || status.isQiyamTime) ...[
                    Container(
                      margin: EdgeInsets.only(bottom: AtharSpacing.sm),
                      padding: EdgeInsets.symmetric(
                        horizontal: AtharSpacing.md,
                        vertical: AtharSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: status.isDuhaTime
                            ? Colors.orange.withValues(alpha: 0.2)
                            : Colors.indigo.withValues(alpha: 0.3),
                        borderRadius: AtharRadii.radiusXl,
                        border: Border.all(
                          color: status.isDuhaTime
                              ? Colors.orange.withValues(alpha: 0.5)
                              : Colors.indigo.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            status.isDuhaTime
                                ? Icons.wb_sunny_rounded
                                : Icons.nights_stay_rounded,
                            color: status.isDuhaTime
                                ? Colors.orange
                                : Colors.indigoAccent,
                            size: 14.sp,
                          ),
                          AtharGap.hXs,
                          // ✅ FIX: Flexible حول Text
                          Flexible(
                            child: Text(
                              status.isDuhaTime
                                  ? l10n.prayerCardDuhaTime
                                  : l10n.prayerCardQiyamTime,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Status and time row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // ✅ FIX: Expanded حول Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status.statusLabel,
                              style: TextStyle(
                                color: displayColor,
                                fontSize: 12.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AtharGap.xxxs,
                            Text(
                              status.prayerName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      AtharGap.hSm,
                      Text(
                        status.timeDisplay,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w300,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),

                  AtharGap.md,

                  // Progress row with dhikr button
                  _buildProgressRow(context, status, displayColor, timePrefix),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ FIXED: _buildHeaderRow - الإصلاح الرئيسي للـ overflow (245px)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeaderRow(
    BuildContext context,
    PrayerTimerStatus status,
    AppLocalizations l10n,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ✅ FIX: Flexible حول InkWell التاريخ
        Flexible(
          flex: 1,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CalendarPage()),
            ),
            borderRadius: AtharRadii.radiusSm,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white24,
                  size: 14.sp,
                ),
                AtharGap.hXxs,
                // ✅ FIX: Flexible حول النص
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AtharSpacing.xxxs),
                    child: Text(
                      status.fullDate,
                      style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        AtharGap.hSm,

        // ✅ FIX: Flexible حول InkWell الموقع
        Flexible(
          flex: 1,
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              String cityName = l10n.prayerCardSetLocation;
              if (state is SettingsLoaded && state.settings.cityName != null) {
                cityName = state.settings.cityName!;
              }

              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LocationSettingsPage(),
                  ),
                ),
                borderRadius: AtharRadii.radiusSm,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // ✅ FIX: Flexible حول اسم المدينة
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(left: AtharSpacing.xxxs),
                        child: Text(
                          cityName,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LocationSettingsPage(),
                          ),
                        ),
                        icon: Icon(
                          Icons.edit_location_alt_rounded,
                          color: Colors.white30,
                          size: 16.sp,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: l10n.prayerCardChangeLocation,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRow(
    BuildContext context,
    PrayerTimerStatus status,
    Color displayColor,
    String timePrefix,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ✅ FIX: Flexible حول النص
            Flexible(
              child: Text(
                "$timePrefix${status.timeLeft}",
                style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        AtharGap.xs,
        Row(
          children: [
            Expanded(
              child: Directionality(
                textDirection: ui.TextDirection.rtl,
                child: ClipRRect(
                  borderRadius: AtharRadii.radiusXs,
                  child: LinearProgressIndicator(
                    value: status.progress,
                    minHeight: 6.h,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(displayColor),
                  ),
                ),
              ),
            ),

            // Dhikr button
            if (status.showDhikrButton) ...[
              AtharGap.hMd,
              GestureDetector(
                onTap: () async {
                  final habitCubit = context.read<HabitCubit>();
                  final postPrayerHabit = await habitCubit
                      .getOrCreatePostPrayerHabit();

                  if (context.mounted) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => DhikrBottomSheet(habit: postPrayerHabit),
                    );
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(AtharSpacing.xxxs),
                  decoration: BoxDecoration(
                    color: displayColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: displayColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '🤲',
                    style: TextStyle(fontSize: 22.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

//-----------------------------------------------------------------------
// import 'dart:ui' as ui;
// import 'package:athar/core/design_system/tokens/athar_radii.dart';
// import 'package:athar/core/design_system/tokens/athar_spacing.dart';
// import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'package:athar/core/services/prayer_timer_service.dart';
// import '../../../../core/di/injection.dart';

// import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
// import '../../../../features/prayer/domain/models/prayer_timer_status.dart';
// import '../../../../features/calendar/presentation/pages/calendar_page.dart';
// import '../../../../features/prayer/presentation/pages/prayer_details_page.dart';
// import '../../../../features/settings/presentation/pages/location_settings_page.dart';

// import '../../../../features/dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
// import 'package:athar/features/habits/presentation/cubit/habit_cubit.dart';

// class NextPrayerCard extends StatefulWidget {
//   final List<PrayerTime>? allPrayers;
//   const NextPrayerCard({super.key, this.allPrayers});

//   @override
//   State<NextPrayerCard> createState() => _NextPrayerCardState();
// }

// class _NextPrayerCardState extends State<NextPrayerCard> {
//   late final PrayerTimerService _timerService;

//   @override
//   void initState() {
//     super.initState();
//     _timerService = getIt<PrayerTimerService>();
//     if (widget.allPrayers != null && widget.allPrayers!.isNotEmpty) {
//       _timerService.startTimer(widget.allPrayers!);
//     }
//   }

//   @override
//   void didUpdateWidget(covariant NextPrayerCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.allPrayers != oldWidget.allPrayers &&
//         widget.allPrayers != null) {
//       _timerService.startTimer(widget.allPrayers!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context);

//     return StreamBuilder<PrayerTimerStatus>(
//       stream: _timerService.timerStream,
//       initialData: PrayerTimerStatus.initial(),
//       builder: (context, snapshot) {
//         final status = snapshot.data!;

//         if (widget.allPrayers == null || widget.allPrayers!.isEmpty) {
//           return const SizedBox.shrink();
//         }

//         // Color logic (Islamic card special design)
//         Color displayColor = status.statusColor;
//         String timePrefix = l10n.prayerCardTimePrefix;

//         // NOTE: These compare against domain-level Arabic values.
//         // Should be refactored to use enum comparison at domain level.
//         if (status.statusLabel.contains("حان الآن")) {
//           displayColor = const Color(0xFF4CAF50);
//           timePrefix = "";
//         } else if (status.statusLabel.contains("الحالية")) {
//           displayColor = const Color(0xFF29B6F6);
//           timePrefix = "";
//         }

//         return Container(
//           margin: EdgeInsets.symmetric(
//             horizontal: AtharSpacing.lg,
//             vertical: AtharSpacing.xxs,
//           ),
//           decoration: BoxDecoration(
//             // Islamic gradient — intentionally hardcoded
//             gradient: const LinearGradient(
//               colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: AtharRadii.radiusXxl,
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF0F172A).withValues(alpha: 0.3),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: InkWell(
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const PrayerDetailsPage()),
//             ),
//             borderRadius: AtharRadii.radiusLg,
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: AtharSpacing.lg,
//                 vertical: AtharSpacing.md,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildHeaderRow(context, status, l10n),

//                   AtharGap.md,

//                   // Nafl alert (Duha / Qiyam)
//                   if (status.isDuhaTime || status.isQiyamTime) ...[
//                     Container(
//                       margin: EdgeInsets.only(bottom: AtharSpacing.sm),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: AtharSpacing.md,
//                         vertical: AtharSpacing.xs,
//                       ),
//                       decoration: BoxDecoration(
//                         color: status.isDuhaTime
//                             ? Colors.orange.withValues(alpha: 0.2)
//                             : Colors.indigo.withValues(alpha: 0.3),
//                         borderRadius: AtharRadii.radiusXl,
//                         border: Border.all(
//                           color: status.isDuhaTime
//                               ? Colors.orange.withValues(alpha: 0.5)
//                               : Colors.indigo.withValues(alpha: 0.5),
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             status.isDuhaTime
//                                 ? Icons.wb_sunny_rounded
//                                 : Icons.nights_stay_rounded,
//                             color: status.isDuhaTime
//                                 ? Colors.orange
//                                 : Colors.indigoAccent,
//                             size: 14.sp,
//                           ),
//                           AtharGap.hXs,
//                           Text(
//                             status.isDuhaTime
//                                 ? l10n.prayerCardDuhaTime
//                                 : l10n.prayerCardQiyamTime,
//                             style: TextStyle(
//                               fontSize: 11.sp,
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],

//                   // Status and time row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             status.statusLabel,
//                             style: TextStyle(
//                               color: displayColor,
//                               fontSize: 12.sp,
//                             ),
//                           ),
//                           AtharGap.xxxs,
//                           Text(
//                             status.prayerName,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 26.sp,
//                               fontWeight: FontWeight.bold,
//                               height: 1.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         status.timeDisplay,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 26.sp,
//                           fontWeight: FontWeight.w300,
//                           height: 1.0,
//                         ),
//                       ),
//                     ],
//                   ),

//                   AtharGap.md,

//                   // Progress row with dhikr button
//                   _buildProgressRow(context, status, displayColor, timePrefix),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeaderRow(
//     BuildContext context,
//     PrayerTimerStatus status,
//     AppLocalizations l10n,
//   ) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // Date (right)
//         InkWell(
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const CalendarPage()),
//           ),
//           borderRadius: AtharRadii.radiusSm,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.calendar_today_rounded,
//                 color: Colors.white24,
//                 size: 14.sp,
//               ),
//               AtharGap.hXxs,
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: AtharSpacing.xxxs),
//                 child: Text(
//                   status.fullDate,
//                   style: TextStyle(color: Colors.white54, fontSize: 11.sp),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Location (left)
//         BlocBuilder<SettingsCubit, SettingsState>(
//           builder: (context, state) {
//             String cityName = l10n.prayerCardSetLocation;
//             if (state is SettingsLoaded && state.settings.cityName != null) {
//               cityName = state.settings.cityName!;
//             }

//             return InkWell(
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const LocationSettingsPage()),
//               ),
//               borderRadius: AtharRadii.radiusSm,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.only(left: AtharSpacing.xxxs),
//                     child: Text(
//                       cityName,
//                       style: TextStyle(color: Colors.white54, fontSize: 10.sp),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 24.w,
//                     height: 24.w,
//                     child: IconButton(
//                       onPressed: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const LocationSettingsPage(),
//                         ),
//                       ),
//                       icon: Icon(
//                         Icons.edit_location_alt_rounded,
//                         color: Colors.white30,
//                         size: 16.sp,
//                       ),
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                       tooltip: l10n.prayerCardChangeLocation,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildProgressRow(
//     BuildContext context,
//     PrayerTimerStatus status,
//     Color displayColor,
//     String timePrefix,
//   ) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "$timePrefix${status.timeLeft}",
//               style: TextStyle(color: Colors.white70, fontSize: 12.sp),
//             ),
//           ],
//         ),
//         AtharGap.xs,
//         Row(
//           children: [
//             Expanded(
//               child: Directionality(
//                 textDirection: ui.TextDirection.rtl,
//                 child: ClipRRect(
//                   borderRadius: AtharRadii.radiusXs,
//                   child: LinearProgressIndicator(
//                     value: status.progress,
//                     minHeight: 6.h,
//                     backgroundColor: Colors.white10,
//                     valueColor: AlwaysStoppedAnimation<Color>(displayColor),
//                   ),
//                 ),
//               ),
//             ),

//             // Dhikr button
//             if (status.showDhikrButton) ...[
//               AtharGap.hMd,
//               GestureDetector(
//                 onTap: () async {
//                   final habitCubit = context.read<HabitCubit>();
//                   final postPrayerHabit = await habitCubit
//                       .getOrCreatePostPrayerHabit();

//                   if (context.mounted) {
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       backgroundColor: Colors.transparent,
//                       builder: (_) => DhikrBottomSheet(habit: postPrayerHabit),
//                     );
//                   }
//                 },
//                 child: Container(
//                   alignment: Alignment.center,
//                   padding: EdgeInsets.all(AtharSpacing.xxxs),
//                   decoration: BoxDecoration(
//                     color: displayColor.withValues(alpha: 0.2),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: displayColor.withValues(alpha: 0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     '🤲',
//                     style: TextStyle(fontSize: 22.sp),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ],
//     );
//   }
// }
//-----------------------------------------------------------------------
// // lib/core/design_system/molecules/cards/next_prayer_card.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Stage 1 | File 1.3
// // ═══════════════════════════════════════════════════════════════════════════════
// // ⚠️ ملاحظة: هذه البطاقة لها تصميم خاص (إسلامي) مع gradient - تم ترحيل spacing فقط

// import 'dart:ui' as ui;
// import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // --- Imports Core & Services ---
// import 'package:athar/core/services/prayer_timer_service.dart';
// import '../../../../core/di/injection.dart';

// // --- Imports Features (Settings, Prayer, Calendar) ---
// import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
// import '../../../../features/prayer/domain/models/prayer_timer_status.dart';
// import '../../../../features/calendar/presentation/pages/calendar_page.dart';
// import '../../../../features/prayer/presentation/pages/prayer_details_page.dart';
// import '../../../../features/settings/presentation/pages/location_settings_page.dart';

// // --- Imports Dhikr & Habits ---
// import '../../../../features/dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
// import 'package:athar/features/habits/presentation/cubit/habit_cubit.dart';

// class NextPrayerCard extends StatefulWidget {
//   final List<PrayerTime>? allPrayers;
//   const NextPrayerCard({super.key, this.allPrayers});

//   @override
//   State<NextPrayerCard> createState() => _NextPrayerCardState();
// }

// class _NextPrayerCardState extends State<NextPrayerCard> {
//   late final PrayerTimerService _timerService;

//   @override
//   void initState() {
//     super.initState();
//     _timerService = getIt<PrayerTimerService>();
//     if (widget.allPrayers != null && widget.allPrayers!.isNotEmpty) {
//       _timerService.startTimer(widget.allPrayers!);
//     }
//   }

//   @override
//   void didUpdateWidget(covariant NextPrayerCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.allPrayers != oldWidget.allPrayers &&
//         widget.allPrayers != null) {
//       _timerService.startTimer(widget.allPrayers!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<PrayerTimerStatus>(
//       stream: _timerService.timerStream,
//       initialData: PrayerTimerStatus.initial(),
//       builder: (context, snapshot) {
//         final status = snapshot.data!;

//         if (widget.allPrayers == null || widget.allPrayers!.isEmpty) {
//           return const SizedBox.shrink();
//         }

//         // --- 🎨 منطق الألوان والنصوص (تصميم خاص للبطاقة الإسلامية) ---
//         Color displayColor = status.statusColor;
//         String timePrefix = "المتبقي: ";

//         if (status.statusLabel.contains("حان الآن")) {
//           displayColor = const Color(0xFF4CAF50); // 🟢 أخضر
//           timePrefix = "";
//         } else if (status.statusLabel.contains("الحالية")) {
//           displayColor = const Color(0xFF29B6F6); // 🔵 أزرق فاتح
//           timePrefix = "";
//         }

//         return Container(
//           // ✅ EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h)
//           margin: EdgeInsets.symmetric(
//             horizontal: AtharSpacing.lg,
//             vertical: AtharSpacing.xxs,
//           ),
//           decoration: BoxDecoration(
//             // ⚠️ Gradient خاص - تصميم إسلامي
//             gradient: const LinearGradient(
//               colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             // ✅ BorderRadius.circular(23.r) → AtharRadii.xxl
//             borderRadius: AtharRadii.radiusXxl,
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF0F172A).withValues(alpha: 0.3),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: InkWell(
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const PrayerDetailsPage()),
//             ),
//             // ✅ BorderRadius.circular(16.r) → AtharRadii.lg
//             borderRadius: AtharRadii.radiusLg,
//             child: Padding(
//               // ✅ EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h)
//               padding: EdgeInsets.symmetric(
//                 horizontal: AtharSpacing.lg,
//                 vertical: AtharSpacing.md,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // الصف الأول: التاريخ والموقع
//                   _buildHeaderRow(context, status),

//                   // ✅ SizedBox(height: 12.h) → AtharGap.md
//                   AtharGap.md,

//                   // ✅ تنبيه النوافل (الضحى / القيام)
//                   if (status.isDuhaTime || status.isQiyamTime) ...[
//                     Container(
//                       // ✅ EdgeInsets.only(bottom: 8.h)
//                       margin: EdgeInsets.only(bottom: AtharSpacing.sm),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: AtharSpacing.md,
//                         vertical: AtharSpacing.xs,
//                       ),
//                       decoration: BoxDecoration(
//                         color: status.isDuhaTime
//                             ? Colors.orange.withValues(alpha: 0.2)
//                             : Colors.indigo.withValues(alpha: 0.3),
//                         // ✅ BorderRadius.circular(20.r) → AtharRadii.xl
//                         borderRadius: AtharRadii.radiusXl,
//                         border: Border.all(
//                           color: status.isDuhaTime
//                               ? Colors.orange.withValues(alpha: 0.5)
//                               : Colors.indigo.withValues(alpha: 0.5),
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             status.isDuhaTime
//                                 ? Icons.wb_sunny_rounded
//                                 : Icons.nights_stay_rounded,
//                             color: status.isDuhaTime
//                                 ? Colors.orange
//                                 : Colors.indigoAccent,
//                             size: 14.sp,
//                           ),
//                           // ✅ SizedBox(width: 6.w)
//                           AtharGap.hXs,
//                           Text(
//                             status.isDuhaTime
//                                 ? "وقت صلاة الضحى متاح الآن"
//                                 : "وقت قيام الليل - الثلث الأخير",
//                             // ✅ AtharTypography
//                             style: AtharTypography.labelSmall.copyWith(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],

//                   // الصف الثاني: الحالة والوقت
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             status.statusLabel,
//                             // ✅ AtharTypography
//                             style: AtharTypography.bodySmall.copyWith(
//                               color: displayColor,
//                             ),
//                           ),
//                           // ✅ SizedBox(height: 2.h) → AtharGap.xxxs
//                           AtharGap.xxxs,
//                           Text(
//                             status.prayerName,
//                             // ✅ AtharTypography
//                             style: AtharTypography.displaySmall.copyWith(
//                               color: Colors.white,
//                               height: 1.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         status.timeDisplay,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 26.sp,
//                           fontWeight: FontWeight.w300,
//                           height: 1.0,
//                           fontFamily: 'Cairo',
//                         ),
//                       ),
//                     ],
//                   ),

//                   // ✅ SizedBox(height: 12.h) → AtharGap.md
//                   AtharGap.md,

//                   // الصف الثالث: العداد وشريط التقدم + زر الأذكار
//                   _buildProgressRow(context, status, displayColor, timePrefix),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHeaderRow(BuildContext context, PrayerTimerStatus status) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // --- التاريخ (يمين) ---
//         InkWell(
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const CalendarPage()),
//           ),
//           // ✅ BorderRadius.circular(8.r) → AtharRadii.sm
//           borderRadius: AtharRadii.radiusSm,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.calendar_today_rounded,
//                 color: Colors.white24,
//                 size: 14.sp,
//               ),
//               // ✅ SizedBox(width: 4.w) → AtharGap.hXxs
//               AtharGap.hXxs,
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: AtharSpacing.xxxs),
//                 child: Text(
//                   status.fullDate,
//                   // ✅ AtharTypography
//                   style: AtharTypography.labelSmall.copyWith(
//                     color: Colors.white54,
//                     fontFamily: 'Cairo',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // --- الموقع (يسار) ---
//         BlocBuilder<SettingsCubit, SettingsState>(
//           builder: (context, state) {
//             String cityName = "تحديد الموقع";
//             if (state is SettingsLoaded && state.settings.cityName != null) {
//               cityName = state.settings.cityName!;
//             }

//             return InkWell(
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const LocationSettingsPage()),
//               ),
//               borderRadius: AtharRadii.radiusSm,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.only(left: AtharSpacing.xxxs),
//                     child: Text(
//                       cityName,
//                       style: AtharTypography.labelSmall.copyWith(
//                         color: Colors.white54,
//                         fontFamily: 'Cairo',
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 24.w,
//                     height: 24.w,
//                     child: IconButton(
//                       onPressed: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const LocationSettingsPage(),
//                         ),
//                       ),
//                       icon: Icon(
//                         Icons.edit_location_alt_rounded,
//                         color: Colors.white30,
//                         size: 16.sp,
//                       ),
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                       tooltip: "تغيير الموقع",
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildProgressRow(
//     BuildContext context,
//     PrayerTimerStatus status,
//     Color displayColor,
//     String timePrefix,
//   ) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "$timePrefix${status.timeLeft}",
//               // ✅ AtharTypography
//               style: AtharTypography.bodySmall.copyWith(color: Colors.white70),
//             ),
//           ],
//         ),
//         // ✅ SizedBox(height: 6.h) → AtharGap.xs
//         AtharGap.xs,
//         Row(
//           children: [
//             Expanded(
//               child: Directionality(
//                 textDirection: ui.TextDirection.rtl,
//                 child: ClipRRect(
//                   // ✅ BorderRadius.circular(4) → AtharRadii.xs
//                   borderRadius: AtharRadii.radiusXs,
//                   child: LinearProgressIndicator(
//                     value: status.progress,
//                     minHeight: 6.h,
//                     backgroundColor: Colors.white10,
//                     valueColor: AlwaysStoppedAnimation<Color>(displayColor),
//                   ),
//                 ),
//               ),
//             ),

//             // ✅ زر الأذكار
//             if (status.showDhikrButton) ...[
//               // ✅ SizedBox(width: 12.w) → AtharGap.hMd
//               AtharGap.hMd,
//               GestureDetector(
//                 onTap: () async {
//                   final habitCubit = context.read<HabitCubit>();
//                   final postPrayerHabit = await habitCubit
//                       .getOrCreatePostPrayerHabit();

//                   if (context.mounted) {
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       backgroundColor: Colors.transparent,
//                       builder: (_) => DhikrBottomSheet(habit: postPrayerHabit),
//                     );
//                   }
//                 },
//                 child: Container(
//                   alignment: Alignment.center,
//                   padding: EdgeInsets.all(AtharSpacing.xxxs),
//                   decoration: BoxDecoration(
//                     color: displayColor.withValues(alpha: 0.2),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: displayColor.withValues(alpha: 0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     '🤲',
//                     style: TextStyle(fontSize: 22.sp),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ],
//     );
//   }
// }
//-----------------------------------------------------------------------
// import 'dart:ui' as ui;
// import 'package:athar/features/prayer/domain/entities/prayer_time.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // --- Imports Core & Services ---
// import 'package:athar/core/services/prayer_timer_service.dart';
// import '../../../../core/di/injection.dart';

// // --- Imports Features (Settings, Prayer, Calendar) ---
// import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
// import '../../../../features/prayer/domain/models/prayer_timer_status.dart';
// import '../../../../features/calendar/presentation/pages/calendar_page.dart';
// import '../../../../features/prayer/presentation/pages/prayer_details_page.dart';
// import '../../../../features/settings/presentation/pages/location_settings_page.dart';

// // --- Imports Dhikr & Habits ---
// import '../../../../features/dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
// import 'package:athar/features/habits/presentation/cubit/habit_cubit.dart';

// class NextPrayerCard extends StatefulWidget {
//   final List<PrayerTime>? allPrayers;
//   const NextPrayerCard({super.key, this.allPrayers});

//   @override
//   State<NextPrayerCard> createState() => _NextPrayerCardState();
// }

// class _NextPrayerCardState extends State<NextPrayerCard> {
//   late final PrayerTimerService _timerService;

//   @override
//   void initState() {
//     super.initState();
//     _timerService = getIt<PrayerTimerService>();
//     if (widget.allPrayers != null && widget.allPrayers!.isNotEmpty) {
//       _timerService.startTimer(widget.allPrayers!);
//     }
//   }

//   @override
//   void didUpdateWidget(covariant NextPrayerCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.allPrayers != oldWidget.allPrayers &&
//         widget.allPrayers != null) {
//       _timerService.startTimer(widget.allPrayers!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<PrayerTimerStatus>(
//       stream: _timerService.timerStream,
//       initialData: PrayerTimerStatus.initial(),
//       builder: (context, snapshot) {
//         final status = snapshot.data!;

//         if (widget.allPrayers == null || widget.allPrayers!.isEmpty) {
//           return const SizedBox.shrink();
//         }

//         // --- 🎨 منطق الألوان والنصوص ---
//         Color displayColor = status.statusColor;
//         String timePrefix = "المتبقي: ";

//         if (status.statusLabel.contains("حان الآن")) {
//           displayColor = const Color(0xFF4CAF50); // 🟢 أخضر
//           timePrefix = "";
//         } else if (status.statusLabel.contains("الحالية")) {
//           displayColor = const Color(0xFF29B6F6); // 🔵 أزرق فاتح
//           timePrefix = "";
//         }

//         return Container(
//           margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(23.r),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF0F172A).withValues(alpha: 0.3),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: InkWell(
//             onTap: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const PrayerDetailsPage()),
//             ),
//             borderRadius: BorderRadius.circular(16.r),
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // الصف الأول: التاريخ والموقع (تم إصلاحه في دالة منفصلة)
//                   _buildHeaderRow(context, status),

//                   SizedBox(height: 12.h),

//                   // ✅ تنبيه النوافل (الضحى / القيام)
//                   if (status.isDuhaTime || status.isQiyamTime) ...[
//                     Container(
//                       margin: EdgeInsets.only(bottom: 8.h),
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12.w,
//                         vertical: 6.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: status.isDuhaTime
//                             ? Colors.orange.withValues(alpha: 0.2)
//                             : Colors.indigo.withValues(alpha: 0.3),
//                         borderRadius: BorderRadius.circular(20.r),
//                         border: Border.all(
//                           color: status.isDuhaTime
//                               ? Colors.orange.withValues(alpha: 0.5)
//                               : Colors.indigo.withValues(alpha: 0.5),
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             status.isDuhaTime
//                                 ? Icons.wb_sunny_rounded
//                                 : Icons.nights_stay_rounded,
//                             color: status.isDuhaTime
//                                 ? Colors.orange
//                                 : Colors.indigoAccent,
//                             size: 14.sp,
//                           ),
//                           SizedBox(width: 6.w),
//                           Text(
//                             status.isDuhaTime
//                                 ? "وقت صلاة الضحى متاح الآن"
//                                 : "وقت قيام الليل - الثلث الأخير",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 11.sp,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],

//                   // الصف الثاني: الحالة والوقت
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             status.statusLabel,
//                             style: TextStyle(
//                               color: displayColor,
//                               fontSize: 12.sp,
//                               fontWeight: FontWeight.normal,
//                             ),
//                           ),
//                           SizedBox(height: 2.h),
//                           Text(
//                             status.prayerName,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 26.sp,
//                               fontWeight: FontWeight.bold,
//                               height: 1.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         status.timeDisplay,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 26.sp,
//                           fontWeight: FontWeight.w300,
//                           height: 1.0,
//                           fontFamily: 'Cairo',
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: 12.h),

//                   // الصف الثالث: العداد وشريط التقدم + زر الأذكار
//                   _buildProgressRow(context, status, displayColor, timePrefix),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ✅ تم إصلاح الخطأ هنا: إزالة التكرار
//   Widget _buildHeaderRow(BuildContext context, PrayerTimerStatus status) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // --- التاريخ (يمين) ---
//         InkWell(
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const CalendarPage()),
//           ),
//           borderRadius: BorderRadius.circular(8.r),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.calendar_today_rounded,
//                 color: Colors.white24,
//                 size: 14.sp,
//               ),
//               SizedBox(width: 4.w),
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: 2.h),
//                 child: Text(
//                   status.fullDate,
//                   style: TextStyle(
//                     color: Colors.white54,
//                     fontSize: 11.sp,
//                     fontFamily: 'Cairo',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // --- الموقع (يسار) ---
//         BlocBuilder<SettingsCubit, SettingsState>(
//           builder: (context, state) {
//             String cityName = "تحديد الموقع";
//             if (state is SettingsLoaded && state.settings.cityName != null) {
//               cityName = state.settings.cityName!;
//             }

//             return InkWell(
//               onTap: () => Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const LocationSettingsPage()),
//               ),
//               borderRadius: BorderRadius.circular(8.r),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.only(left: 2.w),
//                     child: Text(
//                       cityName,
//                       style: TextStyle(
//                         color: Colors.white54,
//                         fontSize: 10.sp,
//                         fontFamily: 'Cairo',
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                   SizedBox(
//                     width: 24.w,
//                     height: 24.w,
//                     child: IconButton(
//                       onPressed: () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const LocationSettingsPage(),
//                         ),
//                       ),
//                       icon: Icon(
//                         Icons.edit_location_alt_rounded,
//                         color: Colors.white30,
//                         size: 16.sp,
//                       ),
//                       padding: EdgeInsets.zero,
//                       constraints: const BoxConstraints(),
//                       tooltip: "تغيير الموقع",
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildProgressRow(
//     BuildContext context,
//     PrayerTimerStatus status,
//     Color displayColor,
//     String timePrefix,
//   ) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "$timePrefix${status.timeLeft}",
//               style: TextStyle(color: Colors.white70, fontSize: 12.sp),
//             ),
//           ],
//         ),
//         SizedBox(height: 6.h),
//         Row(
//           children: [
//             Expanded(
//               child: Directionality(
//                 textDirection: ui.TextDirection.rtl,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(4),
//                   child: LinearProgressIndicator(
//                     value: status.progress,
//                     minHeight: 6.h,
//                     backgroundColor: Colors.white10,
//                     valueColor: AlwaysStoppedAnimation<Color>(displayColor),
//                   ),
//                 ),
//               ),
//             ),

//             // ✅ زر الأذكار (تم ترتيب الأقواس بشكل صحيح)
//             if (status.showDhikrButton) ...[
//               SizedBox(width: 12.w),
//               GestureDetector(
//                 onTap: () async {
//                   // 1. استدعاء العادة المخزنة من الكيوبت
//                   final habitCubit = context.read<HabitCubit>();
//                   final postPrayerHabit = await habitCubit
//                       .getOrCreatePostPrayerHabit();

//                   // 2. فتح النافذة مع العادة المسترجعة
//                   if (context.mounted) {
//                     showModalBottomSheet(
//                       context: context,
//                       isScrollControlled: true,
//                       backgroundColor: Colors.transparent,
//                       builder: (_) => DhikrBottomSheet(habit: postPrayerHabit),
//                     );
//                   }
//                 },
//                 child: Container(
//                   alignment: Alignment.center,
//                   padding: EdgeInsets.all(2.w),
//                   decoration: BoxDecoration(
//                     color: displayColor.withValues(alpha: 0.2),
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: displayColor.withValues(alpha: 0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     '🤲',
//                     style: TextStyle(fontSize: 22.sp),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ],
//     );
//   }
// }
