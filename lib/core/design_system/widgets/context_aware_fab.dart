// lib/core/design_system/widgets/context_aware_fab.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 🎯 Context-Aware Floating Action Button
// زر إضافة ذكي يتغير سلوكه حسب الصفحة الحالية
// ═══════════════════════════════════════════════════════════════════════════════
// السلوكيات:
// ✅ Dashboard: قائمة خيارات (مهمة/موعد/دواء/عادة/مساحة)
// ✅ Tasks: يفتح UnifiedAddSheet مباشرة
// ✅ Habits: يفتح HabitFormSheet مباشرة
// ✅ Spaces: يفتح إنشاء مساحة جديدة
// ✅ داخل المساحة: إضافة موديول
// ═══════════════════════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// أنواع السياقات
// ═══════════════════════════════════════════════════════════════════════════════

enum FabContext {
  dashboard,    // الرئيسية - قائمة خيارات
  tasks,        // المهام - إضافة مهمة مباشرة
  habits,       // العادات - إضافة عادة مباشرة
  spaces,       // المساحات - إنشاء مساحة
  insideSpace,  // داخل مساحة - إضافة موديول
}

/// خيار في قائمة الإضافة
class QuickAddOption {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickAddOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// مدير سلوك زر الإضافة
// ═══════════════════════════════════════════════════════════════════════════════

class ContextAwareFabController {
  final BuildContext context;
  final FabContext fabContext;
  
  // Callbacks للعمليات المختلفة
  final VoidCallback? onAddTask;
  final VoidCallback? onAddAppointment;
  final VoidCallback? onAddMedicine;
  final VoidCallback? onAddHabit;
  final VoidCallback? onAddSpace;
  final VoidCallback? onAddModule;
  
  // بيانات المساحة (لداخل المساحة)
  final String? spaceId;
  final String? spaceName;

  ContextAwareFabController({
    required this.context,
    required this.fabContext,
    this.onAddTask,
    this.onAddAppointment,
    this.onAddMedicine,
    this.onAddHabit,
    this.onAddSpace,
    this.onAddModule,
    this.spaceId,
    this.spaceName,
  });

  /// تنفيذ الإجراء حسب السياق
  void execute() {
    switch (fabContext) {
      case FabContext.dashboard:
        _showDashboardOptions();
        break;
      case FabContext.tasks:
        onAddTask?.call();
        break;
      case FabContext.habits:
        onAddHabit?.call();
        break;
      case FabContext.spaces:
        onAddSpace?.call();
        break;
      case FabContext.insideSpace:
        _showModuleOptions();
        break;
    }
  }

  /// قائمة خيارات الداشبورد
  void _showDashboardOptions() {
    _showGlassBottomSheet(
      title: 'ماذا تريد أن تضيف؟',
      options: [
        QuickAddOption(
          icon: Icons.check_circle_outline_rounded,
          label: 'مهمة',
          color: const Color(0xFF1A6B3C), // brand primary
          onTap: () {
            Navigator.pop(context);
            onAddTask?.call();
          },
        ),
        QuickAddOption(
          icon: Icons.event_rounded,
          label: 'موعد',
          color: const Color(0xFF74B9FF), // token info
          onTap: () {
            Navigator.pop(context);
            onAddAppointment?.call();
          },
        ),
        QuickAddOption(
          icon: Icons.medication_rounded,
          label: 'دواء',
          color: const Color(0xFF00B894), // token success
          onTap: () {
            Navigator.pop(context);
            onAddMedicine?.call();
          },
        ),
        QuickAddOption(
          icon: Icons.track_changes_rounded,
          label: 'عادة',
          color: const Color(0xFFFDCB6E), // token warning
          onTap: () {
            Navigator.pop(context);
            onAddHabit?.call();
          },
        ),
        QuickAddOption(
          icon: Icons.workspaces_rounded,
          label: 'مساحة',
          color: const Color(0xFF0D7377), // brand secondary
          onTap: () {
            Navigator.pop(context);
            onAddSpace?.call();
          },
        ),
      ],
    );
  }

  /// قائمة خيارات الموديولات (داخل المساحة)
  void _showModuleOptions() {
    _showGlassBottomSheet(
      title: 'إضافة إلى ${spaceName ?? "المساحة"}',
      options: [
        QuickAddOption(
          icon: Icons.favorite_rounded,
          label: 'ملف صحي',
          color: const Color(0xFFFF7675), // token error
          onTap: () {
            Navigator.pop(context);
            _addModule('health');
          },
        ),
        QuickAddOption(
          icon: Icons.folder_rounded,
          label: 'مشروع',
          color: const Color(0xFF1A6B3C), // brand primary
          onTap: () {
            Navigator.pop(context);
            _addModule('project');
          },
        ),
        QuickAddOption(
          icon: Icons.checklist_rounded,
          label: 'قائمة',
          color: const Color(0xFF00B894), // token success
          onTap: () {
            Navigator.pop(context);
            _addModule('checklist');
          },
        ),
        QuickAddOption(
          icon: Icons.account_balance_wallet_rounded,
          label: 'أصول',
          color: const Color(0xFFFDCB6E), // token warning
          onTap: () {
            Navigator.pop(context);
            _addModule('assets');
          },
        ),
      ],
    );
  }

  void _addModule(String type) {
    onAddModule?.call();
    // TODO: تمرير النوع للـ callback
  }

  /// عرض Bottom Sheet زجاجي
  void _showGlassBottomSheet({
    required String title,
    required List<QuickAddOption> options,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: AtharRadii.radiusXxxs,
                  ),
                ),
                SizedBox(height: 20.h),
                
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Options Grid
                Wrap(
                  spacing: 16.w,
                  runSpacing: 16.h,
                  alignment: WrapAlignment.center,
                  children: options.map((option) {
                    return _buildOptionButton(option, colorScheme, isDark);
                  }).toList(),
                ),
                
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    QuickAddOption option,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        option.onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // الأيقونة
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: option.color.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: AtharRadii.radiusXl,
              border: Border.all(
                color: option.color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              option.icon,
              color: option.color,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 8.h),
          // النص
          Text(
            option.label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Widget مساعد لاستخدام سهل
// ═══════════════════════════════════════════════════════════════════════════════

/// Widget لتحديد سياق FAB في الشجرة
class FabContextProvider extends InheritedWidget {
  final FabContext fabContext;
  final String? spaceId;
  final String? spaceName;

  const FabContextProvider({
    super.key,
    required this.fabContext,
    this.spaceId,
    this.spaceName,
    required super.child,
  });

  static FabContextProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FabContextProvider>();
  }

  @override
  bool updateShouldNotify(FabContextProvider oldWidget) {
    return fabContext != oldWidget.fabContext ||
        spaceId != oldWidget.spaceId ||
        spaceName != oldWidget.spaceName;
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Extension للحصول على السياق بسهولة
// ═══════════════════════════════════════════════════════════════════════════════

extension FabContextExtension on BuildContext {
  FabContext get currentFabContext {
    return FabContextProvider.of(this)?.fabContext ?? FabContext.dashboard;
  }

  String? get currentSpaceId {
    return FabContextProvider.of(this)?.spaceId;
  }

  String? get currentSpaceName {
    return FabContextProvider.of(this)?.spaceName;
  }
}
