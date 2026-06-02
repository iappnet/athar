// lib/features/habits/presentation/pages/habit_page.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Part 1 | File 1
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/core/config/subscription_config.dart';
import 'package:athar/core/utils/responsive_helper.dart';
import 'package:athar/features/notifications/presentation/widgets/notification_center_button.dart';
import 'package:athar/features/dhikr/presentation/widgets/dhikr_bottom_sheet.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import 'package:athar/features/subscription/presentation/widgets/pro_gate_widget.dart';
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

    return MultiBlocListener(
      listeners: [
        BlocListener<CelebrationCubit, void>(
          listener: (context, _) => _confettiController.play(),
        ),
        BlocListener<HabitCubit, HabitState>(
          listener: (context, state) {
            if (state is HabitFreeLimitReached) {
              showUpgradeNudge(
                context,
                message: 'لقد وصلت إلى الحد المجاني للعادات. قم بالترقية للحصول على عادات غير محدودة',
                entitlementId: SubscriptionConfig.entitlementSpacesPro,
              );
            } else if (state is HabitError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        // ✅ AppColors.background → colors.background
        backgroundColor: colorScheme.surface,
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isTablet
                  ? ResponsiveHelper.maxContentWidth
                  : double.infinity,
            ),
            child: Stack(
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
                        // Future title action hook:
                        // if this page moves to AtharAppBar or a tappable
                        // title/header, point it to StatisticsPage or a
                        // dedicated habit history page.
                        // ✅ l10n: Quran verse
                        quote: l10n.habitsHeaderQuote,
                        trailing: const NotificationCenterButton(),
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
                        child: SmartPrayerCardWrapper(
                          pageType: PageType.habits,
                        ),
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
        ),
      ),
    );
  }

  // ✅ ويدجت زر التبديل
  Widget _buildViewToggle(ColorScheme colorScheme, AppLocalizations l) {
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: false,
          label: Text(l.habitsViewCompact,
              style: const TextStyle(fontFamily: AtharTypography.fontFamily, fontFamilyFallback: AtharTypography.fontFallback, fontSize: 13)),
          icon: const Icon(Icons.view_list_rounded, size: 16),
        ),
        ButtonSegment(
          value: true,
          label: Text(l.habitsViewDetailed,
              style: const TextStyle(fontFamily: AtharTypography.fontFamily, fontFamilyFallback: AtharTypography.fontFallback, fontSize: 13)),
          icon: const Icon(Icons.auto_awesome_outlined, size: 16),
        ),
      ],
      selected: {_isDetailedView},
      onSelectionChanged: (s) => setState(() => _isDetailedView = s.first),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.12);
          }
          return colorScheme.surface;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        side: WidgetStatePropertyAll(
          BorderSide(color: colorScheme.outlineVariant),
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
        if (state is HabitError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: Theme.of(context).colorScheme.error),
                  AtharGap.md,
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error),
                  ),
                  AtharGap.lg,
                  FilledButton.icon(
                    onPressed: () =>
                        context.read<HabitCubit>().loadHabits(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(AppLocalizations.of(context).retry),
                  ),
                ],
              ),
            ),
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
          border: Border.all(color: context.colors.success.withValues(alpha: 0.2)),
          boxShadow: AtharShadows.card,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: context.colors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: context.colors.success,
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
                          color: context.colors.success,
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
      gradientColors = const [Color(0xFF1A6B3C), Color(0xFF0F4828)];
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
            // ✅ FIX: Expanded حول الـ Row الداخلي لمنع overflow
            Expanded(
              child: Row(
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
                  // ✅ FIX: Expanded حول Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ FIX: maxLines + ellipsis
                        Text(
                          habit.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            fontFamily: AtharTypography.fontFamily,
                            fontFamilyFallback: AtharTypography.fontFallback,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AtharGap.xxs,
                        // ✅ FIX: maxLines + ellipsis
                        Text(
                          l.habitsProgressLabel(
                            habit.currentProgress.toString(),
                            habit.target.toString(),
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ✅ FIX: إضافة مسافة بين Row الداخلي وزر البدء
            AtharGap.hSm,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: AtharRadii.radiusXl,
              ),
              child: Text(
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
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.spa_outlined,
                size: 44,
                color: colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            AtharGap.lg,
            Text(
              l.habitsEmptyTitle,
              style: TextStyle(
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            AtharGap.xs,
            Text(
              l.habitsEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
                fontSize: 14,
                color: colorScheme.outline,
                height: 1.6,
              ),
            ),
          ],
        ),
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
