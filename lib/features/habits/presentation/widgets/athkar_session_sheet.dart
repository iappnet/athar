// lib/features/habits/presentation/widgets/athkar_session_sheet.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Part 2 | File 1
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import '../../../../core/presentation/cubit/celebration_cubit.dart';
import '../../data/models/habit_model.dart';
import '../cubit/habit_cubit.dart';

class AthkarSessionSheet extends StatefulWidget {
  final HabitModel habit;

  const AthkarSessionSheet({super.key, required this.habit});

  static void show(BuildContext context, HabitModel habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<HabitCubit>(),
        child: AthkarSessionSheet(habit: habit),
      ),
    );
  }

  @override
  State<AthkarSessionSheet> createState() => _AthkarSessionSheetState();
}

class _AthkarSessionSheetState extends State<AthkarSessionSheet> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentIndex = widget.habit.athkarItems.indexWhere((item) => !item.isDone);
    if (_currentIndex == -1) _currentIndex = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habit;
    final items = habit.athkarItems;
    // ✅ Get colors & l10n
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    double totalProgress = items.isEmpty
        ? 0
        : habit.currentProgress / items.length;

    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        // ✅ Colors.white → colors.surface
        color: colorScheme.surface,
        // ✅ BorderRadius → AtharRadii
        borderRadius: AtharRadii.bottomSheet,
      ),
      child: Column(
        children: [
          // 1. رأس الصفحة
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(AtharSpacing.lg, AtharSpacing.lg, AtharSpacing.lg, 0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: AtharRadii.bottomSheet,
              boxShadow: [
                BoxShadow(
                  // ✅ Colors.black.withOpacity → colors.shadow
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        habit.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amiri',
                        ),
                      ),
                    ),
                    AtharGap.hMassive,
                    IconButton(
                      icon: const Icon(Icons.restore_page_outlined),
                      // ✅ l10n: "تحديث الأذكار"
                      tooltip: l10n.athkarResetTooltip,
                      onPressed: () =>
                          _showResetDialog(context, colorScheme, l10n),
                    ),
                  ],
                ),

                AtharGap.md,

                // شريط التقدم الخطي
                ClipRRect(
                  borderRadius: AtharRadii.radiusXxs,
                  child: LinearProgressIndicator(
                    value: totalProgress,
                    minHeight: 6.h,
                    backgroundColor: colorScheme.outlineVariant,
                    // ✅ AppColors.primary → colors.primary
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),

                AtharGap.sm,

                // نسبة الإنجاز
                Text(
                  // ✅ l10n: "XX% مكتمل"
                  l10n.athkarProgressPercent(
                    (totalProgress * 100).toInt().toString(),
                  ),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.5,
                  ).copyWith(color: colorScheme.outline),
                ),
                AtharGap.lg,
              ],
            ),
          ),

          // 2. محتوى الذكر (PageView)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: items.length,
              onPageChanged: (idx) => setState(() => _currentIndex = idx),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildAthkarCard(colorScheme, l10n, item, index);
              },
            ),
          ),

          // 3. مؤشر الصفحات السفلي
          Padding(
            padding: EdgeInsets.symmetric(vertical: AtharSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${_currentIndex + 1} / ${items.length}",
                  style:
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ).copyWith(
                        fontWeight: FontWeight.bold,
                        // ✅ AppColors.dimmedText → colors.textSecondary
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // ✅ l10n: "تحديث قائمة الأذكار؟"
        title: Text(l10n.athkarResetDialogTitle),
        // ✅ l10n: long reset confirmation text
        content: Text(l10n.athkarResetDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            // ✅ l10n: "إلغاء"
            child: Text(l10n.athkarResetCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HabitCubit>().resetHabitAthkar(widget.habit);
              Navigator.pop(context);
            },
            // ✅ l10n: "تحديث" + Colors.red → colors.error
            child: Text(
              l10n.athkarResetConfirm,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAthkarCard(
    ColorScheme colorScheme,
    AppLocalizations l10n,
    AthkarItem item,
    int index,
  ) {
    final itemProgress = item.targetCount > 0
        ? item.currentCount / item.targetCount
        : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AtharSpacing.xxl, vertical: AtharSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // نص الذكر
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  item.text ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontFamily: 'Amiri',
                    height: 1.6,
                    // ✅ AppColors.textPrimary → colors.textPrimary
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),

          AtharGap.xxxl,

          // دائرة التقدم والزر
          GestureDetector(
            onTap: () async {
              if (!item.isDone) {
                await context.read<HabitCubit>().incrementAthkarProgress(
                  widget.habit,
                  index,
                );
                setState(() {});

                if (item.currentCount >= item.targetCount) {
                  final isAllDone = widget.habit.athkarItems.every(
                    (i) => i.isDone,
                  );

                  if (isAllDone) {
                    if (mounted) {
                      context.read<CelebrationCubit>().celebrate();
                      Navigator.pop(context);
                    }
                  } else {
                    Future.delayed(AtharAnimations.normalSlow, () {
                      if (_currentIndex < widget.habit.athkarItems.length - 1) {
                        _pageController.nextPage(
                          duration: AtharAnimations.slower,
                          curve: Curves.easeInOut,
                        );
                      }
                    });
                  }
                }
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // الدائرة الخلفية
                SizedBox(
                  width: 120.w,
                  height: 120.w,
                  child: CircularProgressIndicator(
                    value: itemProgress,
                    strokeWidth: 8.w,
                    backgroundColor: colorScheme.outlineVariant,
                    // ✅ AppColors.success / AppColors.primary → colors
                    valueColor: AlwaysStoppedAnimation<Color>(
                      item.isDone ? context.colors.success : colorScheme.primary,
                    ),
                  ),
                ),
                // الرقم أو علامة الصح
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: item.isDone ? context.colors.success : colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (item.isDone ? context.colors.success : colorScheme.primary)
                                .withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: item.isDone
                        ? Icon(Icons.check, color: Colors.white, size: 40.sp)
                        : Text(
                            "${item.targetCount - item.currentCount}",
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),

          AtharGap.lg,
          Text(
            // ✅ l10n: "أحسنت!" / "اضغط للعد"
            item.isDone ? l10n.athkarWellDone : l10n.athkarTapToCount,
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
}
