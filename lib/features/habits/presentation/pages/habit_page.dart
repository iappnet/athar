// lib/features/habits/presentation/pages/habit_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Part 1 | File 1
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/features/dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import '../../../../core/design_system/molecules/cards/smart_prayer_wrapper.dart';
import '../../../../core/design_system/molecules/headers/page_header_delegate.dart';
import '../../../../core/design_system/molecules/strips/calendar_strip.dart';

// --- Imports Features ---
import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
import '../../../../features/settings/presentation/cubit/settings_state.dart';
import '../../../../core/presentation/cubit/celebration_cubit.dart';
import '../cubit/habit_cubit.dart';
import '../cubit/habit_state.dart';
import '../../data/models/habit_model.dart';
import '../widgets/habit_section_list.dart';
import '../widgets/athkar_session_sheet.dart';

/// Semantic colors (not in ColorScheme)
const _successColor = Color(0xFF00B894);

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  DateTime _selectedDate = DateTime.now();
  late ConfettiController _confettiController;

  bool _isDetailedView = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    context.read<HabitCubit>().loadHabits();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Get colors & l10n from context
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return BlocListener<CelebrationCubit, void>(
      listener: (context, state) {
        _confettiController.play();
      },
      child: Scaffold(
        // ✅ AppColors.background → colors.background
        backgroundColor: colorScheme.surface,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            CustomScrollView(
              slivers: [
                // 1. الرأس المتحرك (التاريخ + العبارة)
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: MinimalHeaderDelegate(
                    dateStr: _formatHeaderDate(),
                    // ✅ l10n: Quran verse
                    quote: l10n.habitsHeaderQuote,
                  ),
                ),

                // 2. شريط التقويم
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: CalendarStrip(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() => _selectedDate = date);
                      },
                    ),
                  ),
                ),

                // 3. زر التبديل بين العرض المختصر والمفصل
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: _buildViewToggle(colorScheme, l10n),
                  ),
                ),

                // 4. بطاقة الصلاة الذكية
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: SmartPrayerCardWrapper(pageType: PageType.habits),
                  ),
                ),

                // 5. محتوى العادات (مقسم زمنياً)
                _buildHabitsContent(colorScheme, l10n),

                // مساحة سفلية
                SliverToBoxAdapter(child: SizedBox(height: 80.h)),
              ],
            ),

            // تأثير الاحتفال
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ويدجت زر التبديل
  Widget _buildViewToggle(ColorScheme colorScheme, AppLocalizations l) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        // ✅ Colors.white → colors.surface
        color: colorScheme.surface,
        // ✅ BorderRadius.circular(12.r) → AtharRadii.radiusMd
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          _buildToggleItem(
            colorScheme,
            // ✅ l10n: "مختصر"
            l.habitsViewCompact,
            !_isDetailedView,
            () => setState(() => _isDetailedView = false),
          ),
          _buildToggleItem(
            colorScheme,
            // ✅ l10n: "مفصل (أثر)"
            l.habitsViewDetailed,
            _isDetailedView,
            () => setState(() => _isDetailedView = true),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
    ColorScheme colorScheme,
    String text,
    bool isActive,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          // ✅ Duration(milliseconds: 200) → AtharAnimations.fast
          duration: AtharAnimations.fast,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            // ✅ AppColors.primary → colors.primary
            color: isActive
                ? colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            // ✅ BorderRadius.circular(8.r) → AtharRadii.radiusSm
            borderRadius: AtharRadii.radiusSm,
          ),
          child: Text(
            text,
            style:
                TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  letterSpacing: 0.5,
                ).copyWith(
                  fontWeight: FontWeight.bold,
                  // ✅ AppColors.primary / Colors.grey → colors
                  color: isActive ? colorScheme.primary : colorScheme.outline,
                ),
          ),
        ),
      ),
    );
  }

  // ✅ بناء المحتوى
  Widget _buildHabitsContent(ColorScheme colorScheme, AppLocalizations l) {
    return BlocBuilder<HabitCubit, HabitState>(
      builder: (context, state) {
        if (state is HabitLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is HabitLoaded) {
          final cardAthkar = state.cardAthkar;

          final dawn = state.dawnHabits;
          final bakur = state.bakurHabits;
          final morning = state.morningHabits;
          final noon = state.noonHabits;
          final afternoon = state.afternoonHabits;
          final maghrib = state.maghribHabits;
          final isha = state.ishaHabits;
          final night = state.nightHabits;
          final lastThird = state.lastThirdHabits;
          final anyTime = state.anyTimeHabits;

          if (state.habits.isEmpty) return _buildEmptyState(colorScheme, l);

          return SliverList(
            delegate: SliverChildListDelegate([
              // أ. البطاقات العلوية (أذكار مستقلة)
              if (cardAthkar.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    children: cardAthkar
                        .map(
                          (h) => _buildIndependentAthkarCard(colorScheme, l, h),
                        )
                        .toList(),
                  ),
                ),

              // ب. عرض القوائم حسب الوضع المختار
              if (_isDetailedView) ...[
                // --- الوضع المفصل (Athar Timeline) ---
                // ✅ l10n: Section titles
                if (dawn.isNotEmpty)
                  _buildSection(l.habitsSectionFajr, "🕌", dawn),
                if (bakur.isNotEmpty)
                  _buildSection(l.habitsSectionBakur, "🐦", bakur),
                if (morning.isNotEmpty)
                  _buildSection(l.habitsSectionMorning, "☀️", morning),
                if (noon.isNotEmpty)
                  _buildSection(l.habitsSectionNoon, "🌤️", noon),
                if (afternoon.isNotEmpty)
                  _buildSection(l.habitsSectionAsr, "🌥️", afternoon),
                if (maghrib.isNotEmpty)
                  _buildSection(l.habitsSectionMaghrib, "🌇", maghrib),
                if (isha.isNotEmpty)
                  _buildSection(l.habitsSectionIsha, "🌌", isha),
                if (night.isNotEmpty)
                  _buildSection(l.habitsSectionNightPrayer, "🌙", night),
                if (lastThird.isNotEmpty)
                  _buildSection(l.habitsSectionLastThird, "✨", lastThird),
                if (anyTime.isNotEmpty)
                  _buildSection(l.habitsSectionAnytime, "⏳", anyTime),
              ] else ...[
                // --- الوضع المختصر (Merged View) ---
                // ✅ l10n: Merged section titles
                _buildMergedSection(l.habitsSectionDayStart, "🌅", [
                  dawn,
                  bakur,
                  morning,
                ]),
                _buildMergedSection(l.habitsSectionProductivity, "☀️", [
                  noon,
                  afternoon,
                ]),
                _buildMergedSection(l.habitsSectionDayEnd, "🌙", [
                  maghrib,
                  isha,
                  night,
                  lastThird,
                ]),
                if (anyTime.isNotEmpty)
                  _buildSection(l.habitsSectionFlexible, "⏳", anyTime),
              ],
            ]),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildSection(String title, String emoji, List<HabitModel> habits) {
    return HabitSectionList(
      title: title,
      emoji: emoji,
      habits: habits,
      selectedDate: _selectedDate,
      onToggle: _handleHabitToggle,
      onTap: _handleHabitTap,
      onEdit: (habit) => _showEditHabitSheet(habit),
      onDelete: (habit) => _confirmDelete(habit),
    );
  }

  Widget _buildMergedSection(
    String title,
    String emoji,
    List<List<HabitModel>> lists,
  ) {
    final mergedList = lists.expand((x) => x).toList();
    if (mergedList.isEmpty) return const SizedBox.shrink();

    mergedList.sort((a, b) {
      if (a.isCompleted == b.isCompleted) return 0;
      return a.isCompleted ? 1 : -1;
    });

    return _buildSection(title, emoji, mergedList);
  }

  // ✅ ويدجت لبطاقة الأذكار المستقلة
  Widget _buildIndependentAthkarCard(
    ColorScheme colorScheme,
    AppLocalizations l,
    HabitModel habit,
  ) {
    // الحالة 1: منجزة
    if (habit.isCompleted) {
      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        // ✅ EdgeInsets.all(16.w) → AtharSpacing.allLg
        padding: AtharSpacing.allLg,
        decoration: BoxDecoration(
          // ✅ Colors.white → colors.surface
          color: colorScheme.surface,
          // ✅ BorderRadius.circular(16.r) → AtharRadii.radiusLg
          borderRadius: AtharRadii.radiusLg,
          // ✅ AppColors.success → colors.success
          border: Border.all(color: _successColor.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: _successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: _successColor,
                size: 24.sp,
              ),
            ),
            // ✅ SizedBox(width: 16.w) → AtharGap.hLg
            AtharGap.hLg,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // ✅ l10n: "أحسنت! 👏"
                    l.habitsWellDone,
                    style:
                        TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ).copyWith(
                          color: _successColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    // ✅ l10n: "أتممت {title}"
                    l.habitsCompletedHabit(habit.title),
                    style:
                        TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ).copyWith(
                          color: colorScheme.outline,
                          decoration: TextDecoration.lineThrough,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showAthkarSheet(habit),
              icon: Icon(Icons.refresh_rounded, color: colorScheme.outline),
            ),
          ],
        ),
      );
    }

    // الحالة 2: نشطة
    IconData icon;
    List<Color> gradientColors;
    Color shadowColor;

    // ✅ Note: contains() checks use model data, not displayed text - no l10n needed
    if (habit.title.contains("الصباح")) {
      icon = Icons.wb_sunny_rounded;
      gradientColors = const [Color(0xFFFF9966), Color(0xFFFF5E62)];
      shadowColor = Colors.orange.withValues(alpha: 0.3);
    } else if (habit.title.contains("المساء")) {
      icon = Icons.nights_stay_rounded;
      gradientColors = const [Color(0xFF141E30), Color(0xFF243B55)];
      shadowColor = Colors.blueGrey.withValues(alpha: 0.3);
    } else {
      icon = Icons.mosque_rounded;
      gradientColors = const [Color(0xFF6C63FF), Color(0xFF4834D4)];
      // ✅ AppColors.primary → colors.primary
      shadowColor = colorScheme.primary.withValues(alpha: 0.3);
    }

    return GestureDetector(
      onTap: () => _showAthkarSheet(habit),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: AtharSpacing.allLg,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AtharRadii.radiusLg,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: AtharSpacing.allSm,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24.sp),
                ),
                AtharGap.hMd,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      // ✅ l10n: "{current} / {target} منجز"
                      l.habitsProgressLabel(
                        habit.currentProgress.toString(),
                        habit.target.toString(),
                      ),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: AtharRadii.radiusXl,
              ),
              child: Text(
                // ✅ l10n: "ابدأ"
                l.habitsStartButton,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l) {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.spa_outlined, size: 60.sp, color: colorScheme.outline),
          AtharGap.lg,
          Text(
            // ✅ l10n: "ابدأ رحلة العادات"
            l.habitsEmptyTitle,
            style:
                TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ).copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          ),
          AtharGap.sm,
          Text(
            // ✅ l10n: "أضف عادة جديدة من الزر أدناه"
            l.habitsEmptySubtitle,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.6,
            ).copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  String _formatHeaderDate() {
    final settingsState = context.read<SettingsCubit>().state;
    final isHijri = (settingsState is SettingsLoaded)
        ? settingsState.settings.isHijriMode
        : false;

    if (isHijri) {
      return DateFormat('EEEE, d MMMM yyyy', 'ar').format(_selectedDate);
    } else {
      return DateFormat('EEEE, d MMMM', 'ar').format(_selectedDate);
    }
  }

  void _handleHabitTap(HabitModel habit) {
    if (habit.type == HabitType.athkar) {
      _showAthkarSheet(habit);
    }
  }

  void _handleHabitToggle(HabitModel habit) async {
    final l10n = AppLocalizations.of(context);

    if (_selectedDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        // ✅ l10n: "لا يمكن إنجاز عادات المستقبل!"
        SnackBar(content: Text(l10n.habitsCannotCompleteFuture)),
      );
      return;
    }

    if (habit.type == HabitType.athkar) {
      _showAthkarSheet(habit);
    } else {
      await context.read<HabitCubit>().toggleHabitOnDate(
        habit.id,
        _selectedDate,
      );

      if (!mounted) return;

      final habitCubit = context.read<HabitCubit>();
      final updatedHabit = habitCubit.state is HabitLoaded
          ? (habitCubit.state as HabitLoaded).habits.firstWhere(
              (h) => h.id == habit.id,
              orElse: () => habit,
            )
          : habit;

      final isCompletedNow = habitCubit.isHabitCompletedOnDate(
        updatedHabit,
        _selectedDate,
      );

      if (isCompletedNow) {
        context.read<CelebrationCubit>().celebrate();
      }
    }
  }

  void _showEditHabitSheet(HabitModel habit) {
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      // ✅ l10n: "تعديل العادة (قريباً)"
      SnackBar(content: Text(l.habitsEditComingSoon)),
    );
  }

  void _confirmDelete(HabitModel habit) {
    final l = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // ✅ l10n: "حذف العادة؟"
        title: Text(l.habitsDeleteTitle),
        // ✅ l10n: "هل أنت متأكد من حذف '{title}'؟"
        content: Text(l.habitsDeleteConfirm(habit.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            // ✅ l10n: "إلغاء"
            child: Text(l.habitsDeleteCancel),
          ),
          TextButton(
            onPressed: () {
              context.read<HabitCubit>().deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            // ✅ l10n: "حذف" + Colors.red → colors.error
            child: Text(
              l.habitsDeleteAction,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAthkarSheet(HabitModel habit) {
    final settingsState = context.read<SettingsCubit>().state;
    AthkarSessionViewMode viewMode = AthkarSessionViewMode.list;

    if (settingsState is SettingsLoaded) {
      viewMode = settingsState.settings.athkarSessionViewMode;
    }

    if (viewMode == AthkarSessionViewMode.list) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => BlocProvider.value(
          value: context.read<HabitCubit>(),
          child: DhikrBottomSheet(habit: habit),
        ),
      );
    } else {
      AthkarSessionSheet.show(context, habit);
    }
  }
}
//-----------------------------------------------------------------------
// // lib/features/habits/presentation/pages/habit_page.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Part 1 | File 1
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:athar/features/dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
// import 'package:athar/features/settings/data/models/user_settings.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:confetti/confetti.dart';
// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ✅ OLD: import '../../../../core/design_system/themes/app_colors.dart';
// import '../../../../core/design_system/molecules/cards/smart_prayer_wrapper.dart';
// import '../../../../core/design_system/molecules/headers/page_header_delegate.dart';
// import '../../../../core/design_system/molecules/strips/calendar_strip.dart';

// // --- Imports Features ---
// import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
// import '../../../../features/settings/presentation/cubit/settings_state.dart';
// import '../../../../core/presentation/cubit/celebration_cubit.dart';
// import '../cubit/habit_cubit.dart';
// import '../cubit/habit_state.dart';
// import '../../data/models/habit_model.dart';
// import '../widgets/habit_section_list.dart';
// import '../widgets/athkar_session_sheet.dart';

// class HabitsPage extends StatefulWidget {
//   const HabitsPage({super.key});

//   @override
//   State<HabitsPage> createState() => _HabitsPageState();
// }

// class _HabitsPageState extends State<HabitsPage> {
//   DateTime _selectedDate = DateTime.now();
//   late ConfettiController _confettiController;

//   bool _isDetailedView = false;

//   @override
//   void initState() {
//     super.initState();
//     _confettiController = ConfettiController(
//       duration: const Duration(seconds: 2),
//     );
//     context.read<HabitCubit>().loadHabits();
//   }

//   @override
//   void dispose() {
//     _confettiController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Get colors & l10n from context
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return BlocListener<CelebrationCubit, void>(
//       listener: (context, state) {
//         _confettiController.play();
//       },
//       child: Scaffold(
//         // ✅ AppColors.background → colors.background
//         backgroundColor: colors.background,
//         body: Stack(
//           alignment: Alignment.topCenter,
//           children: [
//             CustomScrollView(
//               slivers: [
//                 // 1. الرأس المتحرك (التاريخ + العبارة)
//                 SliverPersistentHeader(
//                   pinned: true,
//                   floating: true,
//                   delegate: MinimalHeaderDelegate(
//                     dateStr: _formatHeaderDate(),
//                     // ✅ l10n: Quran verse
//                     quote: l10n.habitsHeaderQuote,
//                   ),
//                 ),

//                 // 2. شريط التقويم
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.only(bottom: 16.h),
//                     child: CalendarStrip(
//                       selectedDate: _selectedDate,
//                       onDateSelected: (date) {
//                         setState(() => _selectedDate = date);
//                       },
//                     ),
//                   ),
//                 ),

//                 // 3. زر التبديل بين العرض المختصر والمفصل
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 8.h,
//                     ),
//                     child: _buildViewToggle(colors, l10n),
//                   ),
//                 ),

//                 // 4. بطاقة الصلاة الذكية
//                 const SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.only(bottom: 8.0),
//                     child: SmartPrayerCardWrapper(pageType: PageType.habits),
//                   ),
//                 ),

//                 // 5. محتوى العادات (مقسم زمنياً)
//                 _buildHabitsContent(colors, l10n),

//                 // مساحة سفلية
//                 SliverToBoxAdapter(child: SizedBox(height: 80.h)),
//               ],
//             ),

//             // تأثير الاحتفال
//             ConfettiWidget(
//               confettiController: _confettiController,
//               blastDirectionality: BlastDirectionality.explosive,
//               shouldLoop: false,
//               colors: const [
//                 Colors.green,
//                 Colors.blue,
//                 Colors.pink,
//                 Colors.orange,
//                 Colors.purple,
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ ويدجت زر التبديل
//   Widget _buildViewToggle(AtharColors colors, AppLocalizations l) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(4.w),
//       decoration: BoxDecoration(
//         // ✅ Colors.white → colors.surface
//         color: colors.surface,
//         // ✅ BorderRadius.circular(12.r) → AtharRadii.radiusMd
//         borderRadius: AtharRadii.radiusMd,
//         border: Border.all(color: colors.borderLight),
//       ),
//       child: Row(
//         children: [
//           _buildToggleItem(
//             colors,
//             // ✅ l10n: "مختصر"
//             l.habitsViewCompact,
//             !_isDetailedView,
//             () => setState(() => _isDetailedView = false),
//           ),
//           _buildToggleItem(
//             colors,
//             // ✅ l10n: "مفصل (أثر)"
//             l.habitsViewDetailed,
//             _isDetailedView,
//             () => setState(() => _isDetailedView = true),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToggleItem(
//     AtharColors colors,
//     String text,
//     bool isActive,
//     VoidCallback onTap,
//   ) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           // ✅ Duration(milliseconds: 200) → AtharAnimations.fast
//           duration: AtharAnimations.fast,
//           alignment: Alignment.center,
//           padding: EdgeInsets.symmetric(vertical: 8.h),
//           decoration: BoxDecoration(
//             // ✅ AppColors.primary → colors.primary
//             color: isActive
//                 ? colors.primary.withValues(alpha: 0.1)
//                 : Colors.transparent,
//             // ✅ BorderRadius.circular(8.r) → AtharRadii.radiusSm
//             borderRadius: AtharRadii.radiusSm,
//           ),
//           child: Text(
//             text,
//             style: AtharTypography.labelMedium.copyWith(
//               fontWeight: FontWeight.bold,
//               // ✅ AppColors.primary / Colors.grey → colors
//               color: isActive ? colors.primary : colors.textTertiary,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ✅ بناء المحتوى
//   Widget _buildHabitsContent(AtharColors colors, AppLocalizations l) {
//     return BlocBuilder<HabitCubit, HabitState>(
//       builder: (context, state) {
//         if (state is HabitLoading) {
//           return const SliverFillRemaining(
//             child: Center(child: CircularProgressIndicator()),
//           );
//         } else if (state is HabitLoaded) {
//           final cardAthkar = state.cardAthkar;

//           final dawn = state.dawnHabits;
//           final bakur = state.bakurHabits;
//           final morning = state.morningHabits;
//           final noon = state.noonHabits;
//           final afternoon = state.afternoonHabits;
//           final maghrib = state.maghribHabits;
//           final isha = state.ishaHabits;
//           final night = state.nightHabits;
//           final lastThird = state.lastThirdHabits;
//           final anyTime = state.anyTimeHabits;

//           if (state.habits.isEmpty) return _buildEmptyState(colors, l);

//           return SliverList(
//             delegate: SliverChildListDelegate([
//               // أ. البطاقات العلوية (أذكار مستقلة)
//               if (cardAthkar.isNotEmpty)
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.w,
//                     vertical: 8.h,
//                   ),
//                   child: Column(
//                     children: cardAthkar
//                         .map((h) => _buildIndependentAthkarCard(colors, l, h))
//                         .toList(),
//                   ),
//                 ),

//               // ب. عرض القوائم حسب الوضع المختار
//               if (_isDetailedView) ...[
//                 // --- الوضع المفصل (Athar Timeline) ---
//                 // ✅ l10n: Section titles
//                 if (dawn.isNotEmpty)
//                   _buildSection(l.habitsSectionFajr, "🕌", dawn),
//                 if (bakur.isNotEmpty)
//                   _buildSection(l.habitsSectionBakur, "🐦", bakur),
//                 if (morning.isNotEmpty)
//                   _buildSection(l.habitsSectionMorning, "☀️", morning),
//                 if (noon.isNotEmpty)
//                   _buildSection(l.habitsSectionNoon, "🌤️", noon),
//                 if (afternoon.isNotEmpty)
//                   _buildSection(l.habitsSectionAsr, "🌥️", afternoon),
//                 if (maghrib.isNotEmpty)
//                   _buildSection(l.habitsSectionMaghrib, "🌇", maghrib),
//                 if (isha.isNotEmpty)
//                   _buildSection(l.habitsSectionIsha, "🌌", isha),
//                 if (night.isNotEmpty)
//                   _buildSection(l.habitsSectionNightPrayer, "🌙", night),
//                 if (lastThird.isNotEmpty)
//                   _buildSection(l.habitsSectionLastThird, "✨", lastThird),
//                 if (anyTime.isNotEmpty)
//                   _buildSection(l.habitsSectionAnytime, "⏳", anyTime),
//               ] else ...[
//                 // --- الوضع المختصر (Merged View) ---
//                 // ✅ l10n: Merged section titles
//                 _buildMergedSection(l.habitsSectionDayStart, "🌅", [
//                   dawn,
//                   bakur,
//                   morning,
//                 ]),
//                 _buildMergedSection(l.habitsSectionProductivity, "☀️", [
//                   noon,
//                   afternoon,
//                 ]),
//                 _buildMergedSection(l.habitsSectionDayEnd, "🌙", [
//                   maghrib,
//                   isha,
//                   night,
//                   lastThird,
//                 ]),
//                 if (anyTime.isNotEmpty)
//                   _buildSection(l.habitsSectionFlexible, "⏳", anyTime),
//               ],
//             ]),
//           );
//         }
//         return const SliverToBoxAdapter(child: SizedBox.shrink());
//       },
//     );
//   }

//   Widget _buildSection(String title, String emoji, List<HabitModel> habits) {
//     return HabitSectionList(
//       title: title,
//       emoji: emoji,
//       habits: habits,
//       selectedDate: _selectedDate,
//       onToggle: _handleHabitToggle,
//       onTap: _handleHabitTap,
//       onEdit: (habit) => _showEditHabitSheet(habit),
//       onDelete: (habit) => _confirmDelete(habit),
//     );
//   }

//   Widget _buildMergedSection(
//     String title,
//     String emoji,
//     List<List<HabitModel>> lists,
//   ) {
//     final mergedList = lists.expand((x) => x).toList();
//     if (mergedList.isEmpty) return const SizedBox.shrink();

//     mergedList.sort((a, b) {
//       if (a.isCompleted == b.isCompleted) return 0;
//       return a.isCompleted ? 1 : -1;
//     });

//     return _buildSection(title, emoji, mergedList);
//   }

//   // ✅ ويدجت لبطاقة الأذكار المستقلة
//   Widget _buildIndependentAthkarCard(
//     AtharColors colors,
//     AppLocalizations l,
//     HabitModel habit,
//   ) {
//     // الحالة 1: منجزة
//     if (habit.isCompleted) {
//       return Container(
//         margin: EdgeInsets.only(bottom: 12.h),
//         // ✅ EdgeInsets.all(16.w) → AtharSpacing.allLg
//         padding: AtharSpacing.allLg,
//         decoration: BoxDecoration(
//           // ✅ Colors.white → colors.surface
//           color: colors.surface,
//           // ✅ BorderRadius.circular(16.r) → AtharRadii.radiusLg
//           borderRadius: AtharRadii.radiusLg,
//           // ✅ AppColors.success → colors.success
//           border: Border.all(color: colors.success.withValues(alpha: 0.2)),
//           boxShadow: [
//             BoxShadow(
//               color: colors.shadow.withValues(alpha: 0.02),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(10.w),
//               decoration: BoxDecoration(
//                 color: colors.success.withValues(alpha: 0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.check_rounded,
//                 color: colors.success,
//                 size: 24.sp,
//               ),
//             ),
//             // ✅ SizedBox(width: 16.w) → AtharGap.hLg
//             AtharGap.hLg,
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     // ✅ l10n: "أحسنت! 👏"
//                     l.habitsWellDone,
//                     style: AtharTypography.titleSmall.copyWith(
//                       color: colors.success,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     // ✅ l10n: "أتممت {title}"
//                     l.habitsCompletedHabit(habit.title),
//                     style: AtharTypography.bodySmall.copyWith(
//                       color: colors.textTertiary,
//                       decoration: TextDecoration.lineThrough,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             IconButton(
//               onPressed: () => _showAthkarSheet(habit),
//               icon: Icon(Icons.refresh_rounded, color: colors.textTertiary),
//             ),
//           ],
//         ),
//       );
//     }

//     // الحالة 2: نشطة
//     IconData icon;
//     List<Color> gradientColors;
//     Color shadowColor;

//     // ✅ Note: contains() checks use model data, not displayed text - no l10n needed
//     if (habit.title.contains("الصباح")) {
//       icon = Icons.wb_sunny_rounded;
//       gradientColors = const [Color(0xFFFF9966), Color(0xFFFF5E62)];
//       shadowColor = Colors.orange.withValues(alpha: 0.3);
//     } else if (habit.title.contains("المساء")) {
//       icon = Icons.nights_stay_rounded;
//       gradientColors = const [Color(0xFF141E30), Color(0xFF243B55)];
//       shadowColor = Colors.blueGrey.withValues(alpha: 0.3);
//     } else {
//       icon = Icons.mosque_rounded;
//       gradientColors = const [Color(0xFF6C63FF), Color(0xFF4834D4)];
//       // ✅ AppColors.primary → colors.primary
//       shadowColor = colors.primary.withValues(alpha: 0.3);
//     }

//     return GestureDetector(
//       onTap: () => _showAthkarSheet(habit),
//       child: Container(
//         margin: EdgeInsets.only(bottom: 12.h),
//         padding: AtharSpacing.allLg,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: gradientColors,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: AtharRadii.radiusLg,
//           boxShadow: [
//             BoxShadow(
//               color: shadowColor,
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: AtharSpacing.allSm,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withValues(alpha: 0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(icon, color: Colors.white, size: 24.sp),
//                 ),
//                 AtharGap.hMd,
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       habit.title,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16.sp,
//                         fontFamily: 'Cairo',
//                       ),
//                     ),
//                     SizedBox(height: 4.h),
//                     Text(
//                       // ✅ l10n: "{current} / {target} منجز"
//                       l.habitsProgressLabel(
//                         habit.currentProgress.toString(),
//                         habit.target.toString(),
//                       ),
//                       style: TextStyle(
//                         color: Colors.white.withValues(alpha: 0.9),
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//               decoration: BoxDecoration(
//                 color: Colors.white24,
//                 borderRadius: AtharRadii.radiusXl,
//               ),
//               child: Text(
//                 // ✅ l10n: "ابدأ"
//                 l.habitsStartButton,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState(AtharColors colors, AppLocalizations l) {
//     return SliverFillRemaining(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.spa_outlined, size: 60.sp, color: colors.textTertiary),
//           AtharGap.lg,
//           Text(
//             // ✅ l10n: "ابدأ رحلة العادات"
//             l.habitsEmptyTitle,
//             style: AtharTypography.titleMedium.copyWith(
//               color: colors.textSecondary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           AtharGap.sm,
//           Text(
//             // ✅ l10n: "أضف عادة جديدة من الزر أدناه"
//             l.habitsEmptySubtitle,
//             style: AtharTypography.bodyMedium.copyWith(
//               color: colors.textTertiary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- Helpers ---

//   String _formatHeaderDate() {
//     final settingsState = context.read<SettingsCubit>().state;
//     final isHijri = (settingsState is SettingsLoaded)
//         ? settingsState.settings.isHijriMode
//         : false;

//     if (isHijri) {
//       return DateFormat('EEEE, d MMMM yyyy', 'ar').format(_selectedDate);
//     } else {
//       return DateFormat('EEEE, d MMMM', 'ar').format(_selectedDate);
//     }
//   }

//   void _handleHabitTap(HabitModel habit) {
//     if (habit.type == HabitType.athkar) {
//       _showAthkarSheet(habit);
//     }
//   }

//   void _handleHabitToggle(HabitModel habit) async {
//     final l10n = AppLocalizations.of(context);

//     if (_selectedDate.isAfter(DateTime.now())) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         // ✅ l10n: "لا يمكن إنجاز عادات المستقبل!"
//         SnackBar(content: Text(l10n.habitsCannotCompleteFuture)),
//       );
//       return;
//     }

//     if (habit.type == HabitType.athkar) {
//       _showAthkarSheet(habit);
//     } else {
//       await context.read<HabitCubit>().toggleHabitOnDate(
//         habit.id,
//         _selectedDate,
//       );

//       if (!mounted) return;

//       final habitCubit = context.read<HabitCubit>();
//       final updatedHabit = habitCubit.state is HabitLoaded
//           ? (habitCubit.state as HabitLoaded).habits.firstWhere(
//               (h) => h.id == habit.id,
//               orElse: () => habit,
//             )
//           : habit;

//       final isCompletedNow = habitCubit.isHabitCompletedOnDate(
//         updatedHabit,
//         _selectedDate,
//       );

//       if (isCompletedNow) {
//         context.read<CelebrationCubit>().celebrate();
//       }
//     }
//   }

//   void _showEditHabitSheet(HabitModel habit) {
//     final l = AppLocalizations.of(context);
//     ScaffoldMessenger.of(context).showSnackBar(
//       // ✅ l10n: "تعديل العادة (قريباً)"
//       SnackBar(content: Text(l.habitsEditComingSoon)),
//     );
//   }

//   void _confirmDelete(HabitModel habit) {
//     final l = AppLocalizations.of(context);
//     final colors = context.colors;

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         // ✅ l10n: "حذف العادة؟"
//         title: Text(l.habitsDeleteTitle),
//         // ✅ l10n: "هل أنت متأكد من حذف '{title}'؟"
//         content: Text(l.habitsDeleteConfirm(habit.title)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             // ✅ l10n: "إلغاء"
//             child: Text(l.habitsDeleteCancel),
//           ),
//           TextButton(
//             onPressed: () {
//               context.read<HabitCubit>().deleteHabit(habit.id);
//               Navigator.pop(ctx);
//             },
//             // ✅ l10n: "حذف" + Colors.red → colors.error
//             child: Text(
//               l.habitsDeleteAction,
//               style: TextStyle(color: colors.error),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAthkarSheet(HabitModel habit) {
//     final settingsState = context.read<SettingsCubit>().state;
//     AthkarSessionViewMode viewMode = AthkarSessionViewMode.list;

//     if (settingsState is SettingsLoaded) {
//       viewMode = settingsState.settings.athkarSessionViewMode;
//     }

//     if (viewMode == AthkarSessionViewMode.list) {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (ctx) => BlocProvider.value(
//           value: context.read<HabitCubit>(),
//           child: DhikrBottomSheet(habit: habit),
//         ),
//       );
//     } else {
//       AthkarSessionSheet.show(context, habit);
//     }
//   }
// }
//-----------------------------------------------------------------------

// import 'package:athar/features/dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
// import 'package:athar/features/settings/data/models/user_settings.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:confetti/confetti.dart';

// // --- Imports Core ---
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../../../core/design_system/molecules/cards/smart_prayer_wrapper.dart';
// import '../../../../core/design_system/molecules/headers/page_header_delegate.dart';
// import '../../../../core/design_system/molecules/strips/calendar_strip.dart';

// // --- Imports Features ---
// import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
// import '../../../../features/settings/presentation/cubit/settings_state.dart';
// import '../../../../core/presentation/cubit/celebration_cubit.dart';
// import '../cubit/habit_cubit.dart';
// import '../cubit/habit_state.dart';
// import '../../data/models/habit_model.dart';
// import '../widgets/habit_section_list.dart';

// // تأكد من استيراد الـ Widgets الجديدة:
// import '../widgets/athkar_session_sheet.dart'; // للشيت الجديد

// class HabitsPage extends StatefulWidget {
//   const HabitsPage({super.key});

//   @override
//   State<HabitsPage> createState() => _HabitsPageState();
// }

// class _HabitsPageState extends State<HabitsPage> {
//   DateTime _selectedDate = DateTime.now();
//   late ConfettiController _confettiController;

//   // ✅ 1. متغير جديد للتحكم في وضع العرض (مختصر / مفصل)
//   bool _isDetailedView = false;

//   @override
//   void initState() {
//     super.initState();
//     _confettiController = ConfettiController(
//       duration: const Duration(seconds: 2),
//     );
//     // تحميل العادات عند البدء
//     context.read<HabitCubit>().loadHabits();
//   }

//   @override
//   void dispose() {
//     _confettiController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // استماع للاحتفال لتشغيل الكونفيتي
//     return BlocListener<CelebrationCubit, void>(
//       listener: (context, state) {
//         _confettiController.play();
//       },
//       child: Scaffold(
//         backgroundColor: AppColors.background, // الرمادي الفاتح جداً
//         body: Stack(
//           alignment: Alignment.topCenter,
//           children: [
//             // جسم الصفحة الرئيسي
//             CustomScrollView(
//               slivers: [
//                 // 1. الرأس المتحرك (التاريخ + العبارة)
//                 SliverPersistentHeader(
//                   pinned: true,
//                   floating: true,
//                   delegate: MinimalHeaderDelegate(
//                     dateStr: _formatHeaderDate(),
//                     quote: "وَأَن لَّيْسَ لِلْإِنسَانِ إِلَّا مَا سَعَىٰ",
//                   ),
//                 ),

//                 // 2. شريط التقويم
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.only(bottom: 16.h),
//                     child: CalendarStrip(
//                       selectedDate: _selectedDate,
//                       onDateSelected: (date) {
//                         setState(() => _selectedDate = date);
//                       },
//                     ),
//                   ),
//                 ),

//                 // ✅ 2. زر التبديل بين العرض المختصر والمفصل
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 16.w,
//                       vertical: 8.h,
//                     ),
//                     child: _buildViewToggle(),
//                   ),
//                 ),

//                 // 3. بطاقة الصلاة الذكية
//                 const SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.only(bottom: 8.0),
//                     child: SmartPrayerCardWrapper(pageType: PageType.habits),
//                   ),
//                 ),

//                 // 4. محتوى العادات (مقسم زمنياً)
//                 _buildHabitsContent(),

//                 // مساحة سفلية
//                 SliverToBoxAdapter(child: SizedBox(height: 80.h)),
//               ],
//             ),

//             // تأثير الاحتفال
//             ConfettiWidget(
//               confettiController: _confettiController,
//               blastDirectionality: BlastDirectionality.explosive,
//               shouldLoop: false,
//               colors: const [
//                 Colors.green,
//                 Colors.blue,
//                 Colors.pink,
//                 Colors.orange,
//                 Colors.purple,
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ✅ ويدجت زر التبديل
//   Widget _buildViewToggle() {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.all(4.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           _buildToggleItem(
//             "مختصر",
//             !_isDetailedView,
//             () => setState(() => _isDetailedView = false),
//           ),
//           _buildToggleItem(
//             "مفصل (أثر)",
//             _isDetailedView,
//             () => setState(() => _isDetailedView = true),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildToggleItem(String text, bool isActive, VoidCallback onTap) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           alignment: Alignment.center,
//           padding: EdgeInsets.symmetric(vertical: 8.h),
//           decoration: BoxDecoration(
//             color: isActive
//                 ? AppColors.primary.withValues(alpha: 0.1)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(8.r),
//           ),
//           child: Text(
//             text,
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.bold,
//               color: isActive ? AppColors.primary : Colors.grey,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ✅ بناء المحتوى (القلب النابض للصفحة)
//   Widget _buildHabitsContent() {
//     return BlocBuilder<HabitCubit, HabitState>(
//       builder: (context, state) {
//         if (state is HabitLoading) {
//           return const SliverFillRemaining(
//             child: Center(child: CircularProgressIndicator()),
//           );
//         } else if (state is HabitLoaded) {
//           // 1. البطاقات العلوية
//           final cardAthkar = state.cardAthkar;

//           // 2. القوائم التفصيلية من الكيوبت (Athar Timeline)
//           final dawn = state.dawnHabits;
//           final bakur = state.bakurHabits;
//           final morning = state.morningHabits;
//           final noon = state.noonHabits;
//           final afternoon = state.afternoonHabits;
//           final maghrib = state.maghribHabits;
//           final isha = state.ishaHabits;
//           final night = state.nightHabits;
//           final lastThird = state.lastThirdHabits;
//           final anyTime = state.anyTimeHabits;

//           if (state.habits.isEmpty) return _buildEmptyState();

//           return SliverList(
//             delegate: SliverChildListDelegate([
//               // أ. البطاقات العلوية (أذكار مستقلة)
//               if (cardAthkar.isNotEmpty)
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.w,
//                     vertical: 8.h,
//                   ),
//                   child: Column(
//                     children: cardAthkar
//                         .map((h) => _buildIndependentAthkarCard(h))
//                         .toList(),
//                   ),
//                 ),

//               // ب. عرض القوائم حسب الوضع المختار
//               if (_isDetailedView) ...[
//                 // --- 🌟 الوضع المفصل (Athar Timeline) ---
//                 if (dawn.isNotEmpty) _buildSection("الفجر", "🕌", dawn),
//                 if (bakur.isNotEmpty) _buildSection("البكور", "🐦", bakur),
//                 if (morning.isNotEmpty)
//                   _buildSection("الضحى والصباح", "☀️", morning),
//                 if (noon.isNotEmpty) _buildSection("الظهيرة", "🌤️", noon),
//                 if (afternoon.isNotEmpty)
//                   _buildSection("العصر", "🌥️", afternoon),
//                 if (maghrib.isNotEmpty) _buildSection("المغرب", "🌇", maghrib),
//                 if (isha.isNotEmpty) _buildSection("العشاء", "🌌", isha),
//                 if (night.isNotEmpty) _buildSection("قيام الليل", "🌙", night),
//                 if (lastThird.isNotEmpty)
//                   _buildSection("الثلث الأخير", "✨", lastThird),
//                 if (anyTime.isNotEmpty)
//                   _buildSection("في أي وقت", "⏳", anyTime),
//               ] else ...[
//                 // --- 📦 الوضع المختصر (Merged View) ---
//                 _buildMergedSection("بداية اليوم", "🌅", [
//                   dawn,
//                   bakur,
//                   morning,
//                 ]),
//                 _buildMergedSection("وقت الإنتاجية", "☀️", [noon, afternoon]),
//                 _buildMergedSection("ختام اليوم", "🌙", [
//                   maghrib,
//                   isha,
//                   night,
//                   lastThird,
//                 ]),
//                 if (anyTime.isNotEmpty)
//                   _buildSection("عادات مرنة", "⏳", anyTime),
//               ],
//             ]),
//           );
//         }
//         return const SliverToBoxAdapter(child: SizedBox.shrink());
//       },
//     );
//   }

//   // ✅ دالة مساعدة لبناء القسم المفرد (تم التصحيح هنا)
//   Widget _buildSection(String title, String emoji, List<HabitModel> habits) {
//     return HabitSectionList(
//       title: title,
//       emoji: emoji,
//       habits: habits,
//       selectedDate: _selectedDate,
//       onToggle: _handleHabitToggle,
//       onTap: _handleHabitTap,

//       // ✅ التصحيح: نمرر العادة للدالة
//       onEdit: (habit) => _showEditHabitSheet(habit),
//       onDelete: (habit) => _confirmDelete(habit),
//     );
//   }

//   // دالة مساعدة لدمج وبناء الأقسام المختصرة
//   Widget _buildMergedSection(
//     String title,
//     String emoji,
//     List<List<HabitModel>> lists,
//   ) {
//     // دمج القوائم في قائمة واحدة
//     final mergedList = lists.expand((x) => x).toList();

//     if (mergedList.isEmpty) return const SizedBox.shrink();

//     // إعادة ترتيب القائمة المدمجة (المنجز في الأسفل)
//     mergedList.sort((a, b) {
//       if (a.isCompleted == b.isCompleted) return 0;
//       return a.isCompleted ? 1 : -1;
//     });

//     return _buildSection(title, emoji, mergedList);
//   }

//   // ✅ ويدجت لبطاقة الأذكار المستقلة
//   Widget _buildIndependentAthkarCard(HabitModel habit) {
//     // الحالة 1: منجزة (تصميم هادئ ونظيف)
//     if (habit.isCompleted) {
//       return Container(
//         margin: EdgeInsets.only(bottom: 12.h),
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.02),
//               blurRadius: 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(10.w),
//               decoration: BoxDecoration(
//                 color: AppColors.success.withValues(alpha: 0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.check_rounded,
//                 color: AppColors.success,
//                 size: 24.sp,
//               ),
//             ),
//             SizedBox(width: 16.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "أحسنت! 👏",
//                     style: TextStyle(
//                       color: AppColors.success,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14.sp,
//                     ),
//                   ),
//                   Text(
//                     "أتممت ${habit.title}",
//                     style: TextStyle(
//                       color: Colors.grey.shade500,
//                       fontSize: 13.sp,
//                       decoration: TextDecoration.lineThrough,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             IconButton(
//               onPressed: () => _showAthkarSheet(habit),
//               icon: Icon(Icons.refresh_rounded, color: Colors.grey.shade300),
//             ),
//           ],
//         ),
//       );
//     }

//     // الحالة 2: نشطة
//     IconData icon;
//     List<Color> gradientColors;
//     Color shadowColor;

//     if (habit.title.contains("الصباح")) {
//       icon = Icons.wb_sunny_rounded;
//       gradientColors = const [Color(0xFFFF9966), Color(0xFFFF5E62)];
//       shadowColor = Colors.orange.withValues(alpha: 0.3);
//     } else if (habit.title.contains("المساء")) {
//       icon = Icons.nights_stay_rounded;
//       gradientColors = const [Color(0xFF141E30), Color(0xFF243B55)];
//       shadowColor = Colors.blueGrey.withValues(alpha: 0.3);
//     } else {
//       icon = Icons.mosque_rounded;
//       gradientColors = const [Color(0xFF6C63FF), Color(0xFF4834D4)];
//       shadowColor = AppColors.primary.withValues(alpha: 0.3);
//     }

//     return GestureDetector(
//       onTap: () => _showAthkarSheet(habit),
//       child: Container(
//         margin: EdgeInsets.only(bottom: 12.h),
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: gradientColors,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16.r),
//           boxShadow: [
//             BoxShadow(
//               color: shadowColor,
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(8.w),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withValues(alpha: 0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(icon, color: Colors.white, size: 24.sp),
//                 ),
//                 SizedBox(width: 12.w),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       habit.title,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16.sp,
//                         fontFamily: 'Cairo',
//                       ),
//                     ),
//                     SizedBox(height: 4.h),
//                     Text(
//                       "${habit.currentProgress} / ${habit.target} منجز",
//                       style: TextStyle(
//                         color: Colors.white.withValues(alpha: 0.9),
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//               decoration: BoxDecoration(
//                 color: Colors.white24,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: const Text(
//                 "ابدأ",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return SliverFillRemaining(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.spa_outlined, size: 60.sp, color: Colors.grey.shade300),
//           SizedBox(height: 16.h),
//           Text(
//             "ابدأ رحلة العادات",
//             style: TextStyle(
//               fontSize: 16.sp,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             "أضف عادة جديدة من الزر أدناه",
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- Helpers ---

//   String _formatHeaderDate() {
//     final settingsState = context.read<SettingsCubit>().state;
//     final isHijri = (settingsState is SettingsLoaded)
//         ? settingsState.settings.isHijriMode
//         : false;

//     if (isHijri) {
//       return DateFormat('EEEE, d MMMM yyyy', 'ar').format(_selectedDate);
//     } else {
//       return DateFormat('EEEE, d MMMM', 'ar').format(_selectedDate);
//     }
//   }

//   // 1. معالجة النقر (Tap)
//   void _handleHabitTap(HabitModel habit) {
//     if (habit.type == HabitType.athkar) {
//       _showAthkarSheet(habit);
//     } else {
//       // تفاصيل العادة العادية (مستقبلاً)
//     }
//   }

//   // 2. معالجة التبديل (Toggle - الدائرة)
//   void _handleHabitToggle(HabitModel habit) async {
//     if (_selectedDate.isAfter(DateTime.now())) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("لا يمكن إنجاز عادات المستقبل!")),
//       );
//       return;
//     }

//     if (habit.type == HabitType.athkar) {
//       _showAthkarSheet(habit);
//     } else {
//       await context.read<HabitCubit>().toggleHabitOnDate(
//         habit.id,
//         _selectedDate,
//       );

//       if (!mounted) return;

//       final habitCubit = context.read<HabitCubit>();
//       final updatedHabit = habitCubit.state is HabitLoaded
//           ? (habitCubit.state as HabitLoaded).habits.firstWhere(
//               (h) => h.id == habit.id,
//               orElse: () => habit,
//             )
//           : habit;

//       final isCompletedNow = habitCubit.isHabitCompletedOnDate(
//         updatedHabit,
//         _selectedDate,
//       );

//       if (isCompletedNow) {
//         context.read<CelebrationCubit>().celebrate();
//       }
//     }
//   }

//   // ✅ 2. دالة التعديل (السحب لليمين) - أصبحت مستخدمة الآن
//   void _showEditHabitSheet(HabitModel habit) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("تعديل العادة (قريباً)")));
//   }

//   // ✅ 3. دالة الحذف (السحب لليسار) - أصبحت مستخدمة الآن
//   void _confirmDelete(HabitModel habit) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("حذف العادة؟"),
//         content: Text("هل أنت متأكد من حذف '${habit.title}'؟"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("إلغاء"),
//           ),
//           TextButton(
//             onPressed: () {
//               context.read<HabitCubit>().deleteHabit(habit.id);
//               Navigator.pop(ctx);
//             },
//             child: const Text("حذف", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ دالة اختيار الشيت
//   void _showAthkarSheet(HabitModel habit) {
//     final settingsState = context.read<SettingsCubit>().state;
//     AthkarSessionViewMode viewMode = AthkarSessionViewMode.list;

//     if (settingsState is SettingsLoaded) {
//       viewMode = settingsState.settings.athkarSessionViewMode;
//     }

//     if (viewMode == AthkarSessionViewMode.list) {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (ctx) => BlocProvider.value(
//           value: context.read<HabitCubit>(),
//           child: DhikrBottomSheet(habit: habit),
//         ),
//       );
//     } else {
//       AthkarSessionSheet.show(context, habit);
//     }
//   }
// }
//-----------------------------------------------------------------------
  // ✅ ويدجت لعرض المنجزات (ExpansionTile)
  // ✅ ويدجت لعرض المنجزات (ExpansionTile)
  // Widget _buildCompletedHabitsSection(List<HabitModel> completedHabits) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  //     child: Theme(
  //       // إزالة الخطوط الفاصلة الافتراضية للـ ExpansionTile
  //       data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
  //       child: ExpansionTile(
  //         initiallyExpanded: false, // مغلق افتراضياً لتقليل الزحام
  //         collapsedBackgroundColor: Colors.white.withOpacity(0.5),
  //         backgroundColor: Colors.white.withOpacity(0.5),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16.r),
  //         ),
  //         collapsedShape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16.r),
  //         ),
  //         leading: Icon(Icons.check_circle_outline, color: AppColors.success),
  //         title: Text(
  //           "المنجزات (${completedHabits.length})",
  //           style: TextStyle(
  //             fontSize: 14.sp,
  //             fontWeight: FontWeight.bold,
  //             color: AppColors.dimmedText,
  //           ),
  //         ),
  //         children: completedHabits.map((habit) {
  //           return MinimalHabitTile(
  //             habit: habit,
  //             isCompletedOnSelectedDate: true,
  //             onToggle: () => _handleHabitToggle(habit),
  //             onTap: () {},

  //             // ✅ التصحيح هنا: استخدام () بدلاً من (_)
  //             onEdit: () {}, // دالة فارغة بدون معاملات
  //             onDelete: () => _confirmDelete(habit), // دالة فارغة تستدعي الحذف
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }

  // // 4. شيت الأذكار (استرجاع المنطق القديم)
  // void _showAthkarSheet(HabitModel habit) {
  //   // ✅ استخدام الشيت الموجود مسبقاً في مشروعك
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true, // مهم ليأخذ ارتفاع الشاشة المناسب
  //     backgroundColor: Colors.transparent,
  //     builder: (ctx) => BlocProvider.value(
  //       value: context.read<HabitCubit>(), // تمرير الكيوبت
  //       child: DhikrBottomSheet(habit: habit), // الودجت الموجود لديك
  //     ),
  //   );
  //   // هنا يجب استدعاء الويدجت القديم الذي يعرض الأذكار وزر "سبّح"
  //   // AthkarSessionSheet.show(context, habit);
  //   // سأزودك بكود مختصر له إذا لم يكن موجوداً
  // }


// import 'package:athar/core/design_system/molecules/cards/smart_prayer_wrapper.dart';
// import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // --- Imports ---
// import '../../../../core/di/injection.dart';
// import '../../../../core/design_system/theme/app_colors.dart';
// // import '../../../../core/design_system/molecules/cards/next_prayer_card.dart';
// import '../../../../core/design_system/organisms/app_bar/athar_app_bar.dart';
// import '../../../../core/presentation/cubit/celebration_cubit.dart';

// // import '../../../../features/prayer/presentation/cubit/prayer_cubit.dart';
// // import '../../../../features/prayer/presentation/cubit/prayer_state.dart';
// import '../../../../features/settings/presentation/cubit/settings_cubit.dart';
// import '../../../../features/settings/data/models/user_settings.dart';
// import '../../../../features/dhikr/presentation/widgets/dhikr_bottom_sheet.dart';

// import '../cubit/habit_cubit.dart';
// import '../cubit/habit_state.dart';
// import '../widgets/habit_tile.dart';
// import '../../data/models/habit_model.dart';
// import '../widgets/athkar_card.dart';
// // ✅ استيراد صفحة التفاصيل الجديدة
// import 'habit_details_page.dart';
// import '../widgets/habit_form_dialog.dart'; // ✅ استيراد الديالوج

// class HabitsPage extends StatefulWidget {
//   const HabitsPage({super.key});
//   @override
//   State<HabitsPage> createState() => _HabitsPageState();
// }

// class _HabitsPageState extends State<HabitsPage> {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: getIt<HabitCubit>()..loadHabits(),
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: const AtharAppBar(title: "عاداتي", subtitle: "استمر في التقدم"),
//         body: Column(
//           children: [
//             // 1. بطاقة الصلاة
//             // BlocBuilder<PrayerCubit, PrayerState>(
//             //   builder: (context, state) {
//             //     if (state is PrayerLoaded) {
//             //       return Padding(
//             //         padding: EdgeInsets.only(bottom: 8.h),
//             //         child: NextPrayerCard(allPrayers: state.allPrayers),
//             //       );
//             //     }
//             //     return const SizedBox.shrink();
//             //   },
//             // ),

//             // ✅ التعديل الجذري: استبدال BlocBuilder القديم بالغلاف الذكي
//             // نمرر له نوع الصفحة الحالية (Dashboard)
//             const SmartPrayerCardWrapper(pageType: PageType.habits),

//             SizedBox(height: 10.h),

//             // 2. المحتوى الرئيسي
//             Expanded(
              // child: BlocBuilder<SettingsCubit, SettingsState>(
              //   builder: (context, settingsState) {
              //     final settings = (settingsState is SettingsLoaded)
              //         ? settingsState.settings
              //         : UserSettings();

              //     final displayMode = settings.athkarDisplayMode;
              //     final isAthkarEnabled = settings.isAthkarEnabled;

//                   return BlocBuilder<HabitCubit, HabitState>(
//                     builder: (context, state) {
//                       if (state is HabitLoading) {
//                         return const Center(child: CircularProgressIndicator());
//                       } else if (state is HabitLoaded) {
//                         // --- الفرز والتقسيم ---
//                         // 1. الأذكار (للبطاقات العلوية) - فقط غير المكتملة
//                         final activeAthkarForCards = state.habits
//                             .where(
//                               (h) =>
//                                   h.type == HabitType.athkar && !h.isCompleted,
//                             )
//                             .toList();

                        // // 2. القائمة النشطة (Active List) - تشمل العادات العادية غير المكتملة
                        // // وإذا كان الوضع مدمجاً، تشمل الأذكار غير المكتملة أيضاً
                        // final activeList = state.habits.where((h) {
                        //   if (h.isCompleted) {
                        //     return false; // المكتمل يذهب للأسفل
                        //   }
                        //   if (displayMode == AthkarDisplayMode.independent &&
                        //       h.type == HabitType.athkar) {
                        //     return false; // الأذكار تذهب للبطاقات
                        //   }
                        //   return true;
                        // }).toList();

                        // // 3. القائمة المنجزة (Completed List) - كل شيء مكتمل اليوم
                        // final completedList = state.habits
                        //     .where((h) => h.isCompleted)
                        //     .toList();

                        // return ListView(
                        //   padding: EdgeInsets.symmetric(horizontal: 16.w),
                        //   children: [
                        //     // --- أ. البطاقات العلوية (فقط للأذكار غير المكتملة في الوضع المنفصل) ---
                        //     // 1. البطاقات العلوية (أذكار)
                        //     if (isAthkarEnabled &&
                        //         displayMode == AthkarDisplayMode.independent &&
                        //         activeAthkarForCards.isNotEmpty) ...[
                        //       ...activeAthkarForCards.map(
                        //         (habit) => AthkarCard(habit: habit),
                        //       ),
                        //       SizedBox(height: 16.h),
                        //     ],

                        //     // ✅ 2. بانر التحفيز (يظهر فقط إذا كان هناك أذكار ولكن لا توجد عادات عادية)
                        //     if (activeList.isEmpty &&
                        //         activeAthkarForCards.isNotEmpty)
                        //       _buildMotivationalBanner(context),

//                             // 3. العادات النشطة
//                             if (activeList.isNotEmpty) ...[
//                               _buildSectionTitle("عاداتي المتبقية"),
//                               ...activeList.map(
//                                 (habit) => _buildHabitItem(context, habit),
//                               ),
//                             ],

//                             // حالة فارغة تماماً
//                             if (activeList.isEmpty &&
//                                 activeAthkarForCards.isEmpty &&
//                                 completedList.isEmpty)
//                               _buildEmptyState(),

//                             // 4. المنجزات
//                             if (completedList.isNotEmpty) ...[
//                               SizedBox(height: 24.h),
//                               Theme(
//                                 data: Theme.of(
//                                   context,
//                                 ).copyWith(dividerColor: Colors.transparent),
//                                 child: ExpansionTile(
//                                   initiallyExpanded:
//                                       false, // مغلق افتراضياً لتقليل الضوضاء
//                                   tilePadding: EdgeInsets.zero,
//                                   title: Text(
//                                     "منجزات اليوم (${completedList.length})",
//                                     style: TextStyle(
//                                       fontSize: 14.sp,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                   children: completedList
//                                       .map(
//                                         (habit) =>
//                                             _buildHabitItem(context, habit),
//                                       )
//                                       .toList(),
//                                 ),
//                               ),
//                             ],

//                             SizedBox(height: 80.h),
//                           ],
//                         );
//                       } else if (state is HabitError) {
//                         return Center(child: Text(state.message));
//                       }
//                       return const SizedBox.shrink();
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),

//         floatingActionButton: FloatingActionButton(
//           heroTag: 'Habits_page_fab',
//           backgroundColor: AppColors.primary,
//           child: const Icon(Icons.add, color: Colors.white),
//           onPressed: () => _showAdvancedHabitDialog(context, null),
//         ),
//       ),
//     );
//   }

//   // ✅ ودجت البانر التحفيزي الجديد
//   Widget _buildMotivationalBanner(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 20.h),
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             AppColors.primary.withOpacity(0.8),
//             AppColors.primary.withOpacity(0.6),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primary.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(10.w),
//             decoration: const BoxDecoration(
//               color: Colors.white24,
//               shape: BoxShape.circle,
//             ),
//             child: Text("🚀", style: TextStyle(fontSize: 24.sp)),
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "بداية موفقة!",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16.sp,
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   "ابدأ عادة صغيرة اليوم، واصنع فرقاً كبيراً غداً.",
//                   style: TextStyle(
//                     color: Colors.white.withValues(alpha: 0.9),
//                     fontSize: 12.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(width: 8.w),
//           ElevatedButton(
//             onPressed: () => HabitFormDialog.show(context),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               foregroundColor: AppColors.primary,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
//               minimumSize: Size(0, 36.h),
//             ),
//             child: const Text("إضافة"),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 14.sp,
//           fontWeight: FontWeight.bold,
//           color: Colors.grey,
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.track_changes, size: 60.sp, color: Colors.grey.shade300),
//           SizedBox(height: 16.h),
//           Text(
//             "لا توجد عادات نشطة. أضف عادة جديدة!",
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHabitItem(BuildContext context, HabitModel habit) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 8.h),
//       child: GestureDetector(
//         // ✅ عند النقر على جسم البطاقة، نفتح التفاصيل (للتعديل ومشاهدة السجل)
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => HabitDetailsPage(habit: habit)),
//           );
//         },
//         child: HabitTile(
//           habit: habit,
//           readOnly: habit.type == HabitType.athkar,
//           onDelete: () => context.read<HabitCubit>().deleteHabit(habit.id),
//           // ✅ Toggle يبقى في الزر الجانبي (Checkbox)
//           onToggle: () {
//             if (habit.type == HabitType.athkar) {
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 backgroundColor: Colors.transparent,
//                 builder: (_) => DhikrBottomSheet(habit: habit),
//               );
//             } else {
//               // الاحتفال 🎉
//               if (!habit.isCompleted) {
//                 context.read<CelebrationCubit>().celebrate();
//               }
//               _toggleRegularHabit(context, habit);
//             }
//           },
//         ),
//       ),
//     );
//   }

//   void _toggleRegularHabit(BuildContext context, HabitModel habit) {
//     final updatedHabit = habit..isCompleted = !habit.isCompleted;
//     if (updatedHabit.isCompleted) {
//       updatedHabit.currentProgress = updatedHabit.target;
//       updatedHabit.lastCompletionDate = DateTime.now();

//       // إضافة لتاريخ اليوم
//       final now = DateTime.now();
//       if (!habit.completedDays.any(
//         (d) => d.year == now.year && d.month == now.month && d.day == now.day,
//       )) {
//         habit.completedDays.add(now);
//       }
//     } else {
//       updatedHabit.currentProgress = 0;
//       // إزالة من تاريخ اليوم عند الإلغاء
//       final now = DateTime.now();
//       habit.completedDays.removeWhere(
//         (d) => d.year == now.year && d.month == now.month && d.day == now.day,
//       );
//     }
//     updatedHabit.lastUpdated = DateTime.now();
//     context.read<HabitCubit>().updateHabit(updatedHabit);
//   }

//   // ... (دالة _showAdvancedHabitDialog تبقى كما هي من الرد السابق، لا تغيير عليها)
//   void _showAdvancedHabitDialog(
//     BuildContext parentContext,
//     HabitModel? habitToEdit,
//   ) {
//     // (انسخ الدالة من الرد السابق، فهي صحيحة تماماً)
//     // سأعيد كتابتها هنا لضمان الاكتمال في النسخ
//     final isEditing = habitToEdit != null;
//     final titleController = TextEditingController(
//       text: isEditing ? habitToEdit.title : "",
//     );
//     final targetController = TextEditingController(
//       text: isEditing ? habitToEdit.target.toString() : "1",
//     );

//     HabitFrequency selectedFreq = isEditing
//         ? habitToEdit.frequency
//         : HabitFrequency.daily;
//     HabitPeriod selectedPeriod = isEditing
//         ? habitToEdit.period
//         : HabitPeriod.allDay;

//     final habitCubit = parentContext.read<HabitCubit>();

//     showDialog(
//       context: parentContext,
//       builder: (ctx) => StatefulBuilder(
//         builder: (context, setState) {
//           return AlertDialog(
//             title: Text(isEditing ? "تعديل العادة" : "عادة جديدة"),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(
//                     controller: titleController,
//                     decoration: const InputDecoration(
//                       labelText: "اسم العادة",
//                       hintText: "مثلاً: قراءة، رياضة...",
//                       border: OutlineInputBorder(),
//                     ),
//                     autofocus: true,
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     "التكرار",
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   DropdownButton<HabitFrequency>(
//                     value: selectedFreq,
//                     isExpanded: true,
//                     items: const [
//                       DropdownMenuItem(
//                         value: HabitFrequency.daily,
//                         child: Text("يومي"),
//                       ),
//                       DropdownMenuItem(
//                         value: HabitFrequency.weekly,
//                         child: Text("أسبوعي"),
//                       ),
//                       DropdownMenuItem(
//                         value: HabitFrequency.monthly,
//                         child: Text("شهري"),
//                       ),
//                     ],
//                     onChanged: (val) => setState(() => selectedFreq = val!),
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     "الوقت المفضل",
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   DropdownButton<HabitPeriod>(
//                     value: selectedPeriod,
//                     isExpanded: true,
//                     items: const [
//                       DropdownMenuItem(
//                         value: HabitPeriod.allDay,
//                         child: Text("طوال اليوم"),
//                       ),
//                       DropdownMenuItem(
//                         value: HabitPeriod.morning,
//                         child: Text("صباحاً"),
//                       ),
//                       DropdownMenuItem(
//                         value: HabitPeriod.evening,
//                         child: Text("مساءً"),
//                       ),
//                     ],
//                     onChanged: (val) => setState(() => selectedPeriod = val!),
//                   ),
//                   SizedBox(height: 16.h),
//                   Text(
//                     "الهدف",
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   TextField(
//                     controller: targetController,
//                     keyboardType: TextInputType.number,
//                     decoration: const InputDecoration(
//                       hintText: "1",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(ctx),
//                 child: const Text("إلغاء"),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   if (titleController.text.isNotEmpty) {
//                     int target = int.tryParse(targetController.text) ?? 1;
//                     if (target < 1) target = 1;
//                     if (isEditing) {
//                       habitToEdit.title = titleController.text;
//                       habitToEdit.frequency = selectedFreq;
//                       habitToEdit.period = selectedPeriod;
//                       habitToEdit.target = target;
//                       habitToEdit.lastUpdated = DateTime.now();
//                       habitCubit.updateHabit(habitToEdit);
//                     } else {
//                       final newHabit = HabitModel(title: titleController.text)
//                         ..type = HabitType.regular
//                         ..frequency = selectedFreq
//                         ..period = selectedPeriod
//                         ..target = target
//                         ..createdAt = DateTime.now();
//                       habitCubit.addHabit(newHabit);
//                     }
//                     Navigator.pop(ctx);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                 ),
//                 child: Text(
//                   isEditing ? "حفظ" : "إضافة",
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
