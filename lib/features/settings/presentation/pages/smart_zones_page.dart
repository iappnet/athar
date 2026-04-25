import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/core/utils/navigation_utils.dart';
import '../../data/models/time_range.dart';
import '../../data/models/category_model.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../cubit/category_cubit.dart';

class SmartZonesPage extends StatefulWidget {
  const SmartZonesPage({super.key});

  @override
  State<SmartZonesPage> createState() => _SmartZonesPageState();
}

class _SmartZonesPageState extends State<SmartZonesPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          l10n.smartZones,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: colorScheme.onSurface,
          onPressed: () => NavigationUtils.safeBack(context),
        ),
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        buildWhen: (prev, curr) =>
            (prev is CategoryLoaded ? prev.categories : <CategoryModel>[]) !=
            (curr is CategoryLoaded ? curr.categories : <CategoryModel>[]),
        builder: (context, categoryState) {
          List<CategoryModel> availableCategories = [];
          if (categoryState is CategoryLoaded) {
            availableCategories = categoryState.categories;
          }

          return BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (prev, curr) => prev != curr,
            builder: (context, state) {
              if (state is SettingsLoaded) {
                final settings = state.settings;
                return ListView(
                  padding: EdgeInsets.all(20.w),
                  children: [
                    _buildAutoModeSwitch(context, settings.isAutoModeEnabled),
                    SizedBox(height: 24.h),

                    if (settings.isAutoModeEnabled) ...[
                      // 2. بطاقة العمل
                      _buildZoneCard(
                        context: context,
                        title: l10n.workZone,
                        icon: Icons.work_outline_rounded,
                        color: Colors.blue,
                        periods: settings.workPeriodsSafe,
                        workDays: settings.workDaysSafe,
                        availableCategories: availableCategories,
                        onUpdatePeriods: (periods) {
                          context.read<SettingsCubit>().updateWorkPeriods(
                            periods,
                          );
                        },
                        onUpdateDays: (days) {
                          context.read<SettingsCubit>().updateWorkDays(days);
                        },
                      ),
                      SizedBox(height: 16.h),

                      // 3. وقت الأهل (المنزل)
                      _buildZoneCard(
                        context: context,
                        title: l10n.familyTimeHome,
                        icon: Icons.home_rounded,
                        color: Colors.green,
                        periods: settings.familyPeriodsSafe,
                        availableCategories: availableCategories,
                        onUpdatePeriods: (periods) => context
                            .read<SettingsCubit>()
                            .updateFamilyPeriods(periods),
                      ),
                      SizedBox(height: 16.h),

                      // 4. المنطقة الحرة
                      _buildZoneCard(
                        context: context,
                        title: l10n.freeTimeZone,
                        icon: Icons.rocket_launch_rounded,
                        color: Colors.purple,
                        periods: settings.freePeriodsSafe,
                        availableCategories: availableCategories,
                        onUpdatePeriods: (periods) => context
                            .read<SettingsCubit>()
                            .updateFreePeriods(periods),
                      ),
                      SizedBox(height: 16.h),

                      // 5. منطقة الهدوء
                      _buildZoneCard(
                        context: context,
                        title: l10n.quietZoneSettings,
                        icon: Icons.spa_outlined,
                        color: Colors.teal,
                        periods: settings.quietPeriodsSafe,
                        availableCategories: availableCategories,
                        onUpdatePeriods: (periods) {
                          context.read<SettingsCubit>().updateQuietPeriods(
                            periods,
                          );
                        },
                      ),
                      SizedBox(height: 16.h),

                      // 6. بطاقة النوم
                      _buildZoneCard(
                        context: context,
                        title: l10n.sleepZone,
                        icon: Icons.bedtime_outlined,
                        color: Colors.indigo,
                        periods: settings.sleepPeriodsSafe,
                        availableCategories: availableCategories,
                        onUpdatePeriods: (periods) {
                          context.read<SettingsCubit>().updateSleepPeriods(
                            periods,
                          );
                        },
                      ),
                      SizedBox(height: 16.h),
                    ] else ...[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100.h),
                          child: Column(
                            children: [
                              Icon(
                                Icons.smart_toy_outlined,
                                size: 64.sp,
                                color: colorScheme.outline,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                l10n.smartModeDisabled,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                l10n.enableSmartModeDesc,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }

  // (بقية الدوال المساعدة _buildAutoModeSwitch كما هي...)
  Widget _buildAutoModeSwitch(BuildContext context, bool isEnabled) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: colorScheme.surface, size: 28.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.enableAutoMode,
                  style: TextStyle(
                    color: colorScheme.surface,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.changeContextByTime,
                  style: TextStyle(
                    color: colorScheme.surface.withValues(alpha: 0.7),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.white24,
            onChanged: (val) {
              context.read<SettingsCubit>().toggleAutoMode(val);
            },
          ),
        ],
      ),
    );
  }

  // ✅ تم إزالة المعاملات غير المستخدمة: onCategoryChanged, selectedCategoryId
  Widget _buildZoneCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required List<TimeRange> periods,
    required Function(List<TimeRange>) onUpdatePeriods,
    required List<CategoryModel> availableCategories,
    List<int>? workDays,
    Function(List<int>)? onUpdateDays,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(width: 4.w),
              IconButton(
                onPressed: () async {
                  final newTime = await showTimePicker(
                    context: context,
                    initialTime: const TimeOfDay(hour: 6, minute: 0),
                    helpText: l10n.periodStartTime,
                  );
                  if (newTime != null) {
                    // ✅ التحقق من mounted قبل استخدام context
                    if (!context.mounted) return;

                    final newEndTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: newTime.hour + 1,
                        minute: newTime.minute,
                      ),
                      helpText: l10n.periodEndTime,
                    );
                    if (newEndTime != null) {
                      final newRange = TimeRange.fromTimeOfDay(
                        newTime,
                        newEndTime,
                      );
                      onUpdatePeriods([...periods, newRange]);
                    }
                  }
                },
                icon: Icon(Icons.add_circle_outline, color: color),
                tooltip: l10n.addPeriod,
              ),
            ],
          ),
          if (workDays != null && onUpdateDays != null) ...[
            Divider(height: 24.h),
            Text(
              l10n.workDays,
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            _buildDaySelector(workDays, onUpdateDays, color),
          ],
          Divider(height: 24.h),
          if (periods.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                l10n.noTimesSetYet,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            )
          else
            ...periods.asMap().entries.map((entry) {
              final index = entry.key;
              final period = entry.value;
              String categoryLabel = l10n.noCategory;
              Color categoryColor = Colors.grey;
              if (period.categoryId != null) {
                try {
                  final cat = availableCategories.firstWhere(
                    (c) => c.id == period.categoryId,
                  );
                  categoryLabel = cat.name;
                  categoryColor = Color(cat.colorValue);
                } catch (e) {
                  // التصنيف ربما حذف
                }
              }
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "${_formatTime(period.startHour, period.startMinute)} - ${_formatTime(period.endHour, period.endMinute)}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<int>(
                      tooltip: l10n.customizeCategory,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: categoryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.label_outline_rounded,
                              size: 12.sp,
                              color: categoryColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              categoryLabel,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: categoryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onSelected: (id) {
                        final updatedPeriods = List<TimeRange>.from(periods);
                        updatedPeriods[index] = TimeRange(
                          startHour: period.startHour,
                          startMinute: period.startMinute,
                          endHour: period.endHour,
                          endMinute: period.endMinute,
                          categoryId: id,
                        );
                        onUpdatePeriods(updatedPeriods);
                      },
                      itemBuilder: (context) {
                        return availableCategories.map((cat) {
                          return PopupMenuItem(
                            value: cat.id,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Color(cat.colorValue),
                                  size: 12,
                                ),
                                SizedBox(width: 8.w),
                                Text(cat.name),
                              ],
                            ),
                          );
                        }).toList();
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red.shade300,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        final updated = List<TimeRange>.from(periods);
                        updated.removeAt(index);
                        onUpdatePeriods(updated);
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // (بقيت الدوال _buildDaySelector و _formatTime كما هي، انسخها من ردي السابق إذا احتجت)
  Widget _buildDaySelector(
    List<int> selectedDays,
    Function(List<int>) onChanged,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final weekDays = [7, 1, 2, 3, 4, 5, 6];
    final dayLabels = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(weekDays.length, (index) {
        final dayId = weekDays[index];
        final isSelected = selectedDays.contains(dayId);
        return GestureDetector(
          onTap: () {
            final newSelection = List<int>.from(selectedDays);
            if (isSelected) {
              if (newSelection.length > 1) newSelection.remove(dayId);
            } else {
              newSelection.add(dayId);
            }
            onChanged(newSelection);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : colorScheme.outline,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              dayLabels[index],
              style: TextStyle(
                color: isSelected
                    ? colorScheme.surface
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        );
      }),
    );
  }

  String _formatTime(int hour, int minute) {
    final dt = DateTime(2024, 1, 1, hour, minute);
    return TimeOfDay.fromDateTime(dt).format(context);
  }
}

