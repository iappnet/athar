// lib/features/home/presentation/pages/home_page_responsive.dart
// ✅ مثال على الصفحة الرئيسية بالتصميم المتجاوب الجديد

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/layouts/adaptive_scaffold.dart';
import '../../../../core/layouts/responsive_page_wrapper.dart';
import '../../../../core/layouts/responsive_app_bar.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'package:athar/core/design_system/tokens.dart';
// استيراد الـ cubits والـ widgets الخاصة بك

/// الصفحة الرئيسية المحسنة للتابلت والموبايل
class HomePageResponsive extends StatefulWidget {
  const HomePageResponsive({super.key});

  @override
  State<HomePageResponsive> createState() => _HomePageResponsiveState();
}

class _HomePageResponsiveState extends State<HomePageResponsive> {
  int _currentIndex = 0;

  // قائمة عناصر التنقل
  final List<AdaptiveNavItem> _navItems = const [
    AdaptiveNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'الرئيسية',
      route: '/home',
    ),
    AdaptiveNavItem(
      icon: Icons.check_circle_outline,
      selectedIcon: Icons.check_circle_rounded,
      label: 'المهام',
      route: '/tasks',
    ),
    AdaptiveNavItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      label: 'العادات',
      route: '/habits',
    ),
    AdaptiveNavItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people_rounded,
      label: 'المساحات',
      route: '/spaces',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AdaptiveScaffold(
      currentIndex: _currentIndex,
      destinations: _navItems,
      onDestinationSelected: (index) {
        setState(() => _currentIndex = index);
        // يمكن إضافة navigation هنا
      },
      appBar: ResponsiveAppBar(
        title: _getGreeting(l10n),
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newTask),
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.primary,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ResponsivePageWrapper(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. بطاقة الصلاة
            _buildPrayerCard(context),
            
            AtharGap.lg,
            
            // 2. الإحصائيات (Grid في التابلت)
            _buildStatisticsSection(context),
            
            AtharGap.xxl,
            
            // 3. العادات اليومية
            ResponsiveSection(
              title: 'عاداتي اليوم',
              trailing: TextButton(
                onPressed: () {},
                child: const Text('عرض الكل'),
              ),
              child: _buildHabitsGrid(context),
            ),
            
            AtharGap.xxl,
            
            // 4. المهام القادمة
            ResponsiveSection(
              title: 'مهامي القادمة',
              trailing: TextButton(
                onPressed: () {},
                child: const Text('عرض الكل'),
              ),
              child: _buildTasksList(context),
            ),
            
            SizedBox(height: 100.h), // مسافة للـ FAB
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // بطاقة الصلاة
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildPrayerCard(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return ContentCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              const Color(0xFF1E293B),
              const Color(0xFF0F172A),
            ],
          ),
          borderRadius: AtharRadii.radiusLg,
        ),
        padding: EdgeInsets.all(isTablet ? 24 : 16.w),
        child: Column(
          children: [
            // الصف العلوي: التاريخ + تحديد الموقع
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // التاريخ
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.white70,
                      size: 16.sp,
                    ),
                    AtharGap.hSm,
                    Text(
                      'الاثنين، 18 شوال 1447 - 6 أبريل 2026',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isTablet ? 14 : 12.sp,
                      ),
                    ),
                  ],
                ),
                // زر الموقع
                TextButton.icon(
                  onPressed: () {},
                  icon: Icon(
                    Icons.edit_location_alt_outlined,
                    size: 16.sp,
                    color: Colors.white70,
                  ),
                  label: Text(
                    'تحديد الموقع',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isTablet ? 13 : 11.sp,
                    ),
                  ),
                ),
              ],
            ),
            
            AtharGap.lg,
            
            // الصلاة القادمة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // الوقت الحالي
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '6:12 م',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 42 : 36.sp,
                        fontWeight: FontWeight.w200,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                
                // معلومات الصلاة
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'الصلاة القادمة',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: isTablet ? 13 : 11.sp,
                      ),
                    ),
                    Text(
                      'المغرب',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 32 : 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'المتبقي: 13 د 58 ث',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isTablet ? 13 : 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            AtharGap.md,
            
            // شريط التقدم
            ClipRRect(
              borderRadius: AtharRadii.radiusXxs,
              child: LinearProgressIndicator(
                value: 0.7,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(AppColors.warning),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // قسم الإحصائيات
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStatisticsSection(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    final stats = [
      _StatItem('المهام المنجزة', '12', Icons.check_circle_outline, Colors.green),
      _StatItem('جلسات التركيز', '3', Icons.timer_outlined, Colors.blue),
      _StatItem('العادات اليوم', '5/8', Icons.trending_up, Colors.orange),
      _StatItem('أيام متتالية', '14', Icons.local_fire_department, Colors.red),
    ];

    if (isTablet) {
      // Grid في التابلت
      return ResponsiveCardGrid(
        tabletColumns: 4,
        mobileColumns: 2,
        childAspectRatio: 1.5,
        children: stats.map((stat) => _buildStatCard(stat)).toList(),
      );
    }

    // Horizontal scroll في الموبايل
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: stats.length,
        separatorBuilder: (_, _) => AtharGap.hMd,
        itemBuilder: (_, index) => SizedBox(
          width: 130.w,
          child: _buildStatCard(stats[index]),
        ),
      ),
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ContentCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(12.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: stat.color.withValues(alpha: 0.15),
                  borderRadius: AtharRadii.radiusSm,
                ),
                child: Icon(stat.icon, color: stat.color, size: 18.sp),
              ),
              const Spacer(),
              Text(
                stat.value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          AtharGap.sm,
          Text(
            stat.title,
            style: TextStyle(
              fontSize: 11.sp,
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // شبكة العادات
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildHabitsGrid(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);
    
    // بيانات تجريبية
    final habits = [
      _HabitItem('أذكار الصباح', Icons.wb_sunny_outlined, true),
      _HabitItem('قراءة القرآن', Icons.menu_book_outlined, true),
      _HabitItem('أذكار المساء', Icons.nights_stay_outlined, false),
      _HabitItem('رياضة', Icons.fitness_center, false),
    ];

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: habits.map((habit) {
        return SizedBox(
          width: isTablet 
              ? 180 
              : (MediaQuery.of(context).size.width - 48.w) / 2,
          child: _buildHabitCard(habit),
        );
      }).toList(),
    );
  }

  Widget _buildHabitCard(_HabitItem habit) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ContentCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(14.w),
      backgroundColor: habit.completed 
          ? colorScheme.primaryContainer.withValues(alpha: 0.5) 
          : null,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: habit.completed 
                  ? colorScheme.primary.withValues(alpha: 0.15) 
                  : colorScheme.surfaceContainerHighest,
              borderRadius: AtharRadii.radiusMd,
            ),
            child: Icon(
              habit.icon,
              color: habit.completed 
                  ? colorScheme.primary 
                  : colorScheme.outline,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              habit.title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
                decoration: habit.completed 
                    ? TextDecoration.lineThrough 
                    : null,
              ),
            ),
          ),
          if (habit.completed)
            Icon(
              Icons.check_circle,
              color: colorScheme.primary,
              size: 22.sp,
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // قائمة المهام
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildTasksList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // بيانات تجريبية
    final tasks = [
      _TaskItem('إنهاء تقرير المشروع', '10:00 ص', false, Colors.red),
      _TaskItem('اجتماع مع الفريق', '2:00 م', false, Colors.orange),
      _TaskItem('مراجعة الكود', '4:00 م', true, Colors.green),
    ];

    return Column(
      children: tasks.map((task) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: ContentCard(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.completed 
                          ? colorScheme.primary 
                          : colorScheme.outline,
                      width: 2,
                    ),
                    color: task.completed 
                        ? colorScheme.primary 
                        : Colors.transparent,
                  ),
                  child: task.completed
                      ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                      : null,
                ),
                
                AtharGap.hMd,
                
                // المحتوى
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          decoration: task.completed 
                              ? TextDecoration.lineThrough 
                              : null,
                          color: task.completed 
                              ? colorScheme.outline 
                              : colorScheme.onSurface,
                        ),
                      ),
                      AtharGap.xxs,
                      Text(
                        task.time,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // مؤشر الأولوية
                Container(
                  width: 4,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: task.priorityColor,
                    borderRadius: AtharRadii.radiusXxxs,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // الدوال المساعدة
  // ═══════════════════════════════════════════════════════════════════

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح النور ☀️';
    if (hour < 18) return 'مساء النور 🌤️';
    return 'مساء النور 🌙';
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Text('إضافة مهمة جديدة'),
        ),
      ),
    );
  }
}

// نماذج البيانات التجريبية
class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  _StatItem(this.title, this.value, this.icon, this.color);
}

class _HabitItem {
  final String title;
  final IconData icon;
  final bool completed;
  _HabitItem(this.title, this.icon, this.completed);
}

class _TaskItem {
  final String title;
  final String time;
  final bool completed;
  final Color priorityColor;
  _TaskItem(this.title, this.time, this.completed, this.priorityColor);
}
