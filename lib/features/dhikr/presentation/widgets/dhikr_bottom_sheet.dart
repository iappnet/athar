import 'package:athar/core/presentation/cubit/celebration_cubit.dart';
import 'package:flutter/material.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ✅ الآن سيتم استخدام هذه المكتبة ولن يظهر تحذير Unused import
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../habits/data/models/habit_model.dart';
import '../../../habits/presentation/cubit/habit_cubit.dart';
import 'package:athar/core/design_system/tokens.dart';

class DhikrBottomSheet extends StatefulWidget {
  final HabitModel habit;

  // ✅ 1. إصلاح تحذير super parameter
  const DhikrBottomSheet({super.key, required this.habit});

  @override
  State<DhikrBottomSheet> createState() => _DhikrBottomSheetState();
}

class _DhikrBottomSheetState extends State<DhikrBottomSheet> {
  // ✅ استبدال ScrollController بـ ItemScrollController الخاص بالمكتبة
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();

    // التمرير التلقائي للذكر الذي توقف عنده المستخدم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFirstIncomplete();
    });
  }

  void _scrollToFirstIncomplete() {
    // البحث عن أول عنصر غير مكتمل
    int firstIncompleteIndex = widget.habit.athkarItems.indexWhere(
      (item) => !item.isDone,
    );

    // إذا وجد عنصر غير مكتمل، نقوم بالتمرير إليه بدقة
    if (firstIncompleteIndex != -1) {
      _itemScrollController.scrollTo(
        index: firstIncompleteIndex,
        duration: const Duration(milliseconds: 600), // مدة الحركة
        curve: Curves.easeInOutCubic, // نوع الحركة ناعم
      );
    }
  }

  // ✅ دالة حوار التأكيد للتحديث (مضافة)
  void _showResetDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.updateAthkarListTitle),
        content: Text(l10n.updateAthkarDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // إغلاق الدايالوج
              // استدعاء التحديث من الكيوبت
              context.read<HabitCubit>().resetHabitAthkar(widget.habit);
              // إغلاق الشيت لأنه سيعاد تحميله
              Navigator.pop(context);
            },
            child: Text(l10n.update, style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    // حساب نسبة الإنجاز الكلي
    double progress = widget.habit.athkarItems.isEmpty
        ? 0
        : widget.habit.currentProgress / widget.habit.athkarItems.length;

    return Container(
      height: 0.85.sh,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: AtharRadii.bottomSheet,
      ),
      child: Column(
        children: [
          // 1. رأس القائمة (العنوان + شريط التقدم)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // مقبض السحب
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: AtharRadii.radiusXxxs,
                  ),
                ),
                // ✅ الصف العلوي الجديد (إغلاق - عنوان - تحديث)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر الإغلاق
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      color: colorScheme.onSurfaceVariant,
                    ),

                    // العنوان
                    Expanded(
                      child: Text(
                        widget.habit.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),

                    // ✅ زر التحديث (Reset)
                    IconButton(
                      icon: const Icon(Icons.restore_page_outlined),
                      tooltip: l10n.updateAthkar,
                      onPressed: () => _showResetDialog(context),
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),

                AtharGap.sm,

                // شريط التقدم الخطي
                ClipRRect(
                  borderRadius: AtharRadii.radiusXxs,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8.h,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                AtharGap.sm,
                Text(
                  l10n.progressPercent((progress * 100).toInt()),
                  style: TextStyle(fontSize: 12.sp, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),

          // 2. قائمة الأذكار باستخدام ScrollablePositionedList
          Expanded(
            child: ScrollablePositionedList.builder(
              itemCount: widget.habit.athkarItems.length,
              itemScrollController: _itemScrollController, // ✅ ربط الكنترولر
              itemPositionsListener: _itemPositionsListener,
              padding: EdgeInsets.all(16.w),
              itemBuilder: (context, index) {
                final item = widget.habit.athkarItems[index];
                return _buildDhikrItem(context, item, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrItem(BuildContext context, AthkarItem item, int index) {
    bool isCompleted = item.isDone;
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isCompleted
          ? null
          : () async {
              // ✅ جعلناها async للتحقق بعد التحديث
              // استدعاء دالة الزيادة في الـ Cubit
              await context.read<HabitCubit>().incrementAthkarProgress(
                widget.habit,
                index,
              );

              // ✅ التحقق من الاكتمال الكلي للاحتفال
              // نحتاج للتحقق من النسخة المحدثة (أو نحسبها يدوياً)
              final isFullyCompleted = widget.habit.athkarItems.every(
                (i) => i.isDone,
              );

              if (isFullyCompleted) {
                // 🎉 إطلاق الاحتفال
                if (context.mounted) {
                  context.read<CelebrationCubit>().celebrate();
                  // اختياري: إغلاق النافذة بعد ثانية
                  Future.delayed(AtharAnimations.long, () {
                    if (context.mounted) Navigator.pop(context);
                  });
                }
              } else {
                // التمرير تلقائياً للعنصر التالي إذا اكتمل الحالي (حركة إضافية ذكية)
                if (item.currentCount + 1 >= item.targetCount) {
                  if (index + 1 < widget.habit.athkarItems.length) {
                    _itemScrollController.scrollTo(
                      index: index + 1,
                      duration: AtharAnimations.normalSlow,
                      curve: Curves.easeInOut,
                    );
                  }
                }
              }

              setState(() {});
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isCompleted
              ? context.colors.success.withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: AtharRadii.radiusMd,
          border: Border.all(
            color: isCompleted
                ? Colors.transparent
                : Theme.of(context).primaryColor.withValues(alpha: 0.2),
          ),
          boxShadow: isCompleted
              ? []
              : [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // نص الذكر
            Text(
              item.text ?? "",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            AtharGap.md,

            // عداد التكرار
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? context.colors.success
                        : Theme.of(context).primaryColor,
                    borderRadius: AtharRadii.radiusXl,
                  ),
                  child: Text(
                    isCompleted
                        ? l10n.achievementDone
                        : "${item.currentCount} / ${item.targetCount}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (!isCompleted)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  l10n.tapToCount,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.sp, color: colorScheme.outline),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

