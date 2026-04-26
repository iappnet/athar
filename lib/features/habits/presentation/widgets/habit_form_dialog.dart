// lib/features/habits/presentation/widgets/habit_form_dialog.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✅ MIGRATED - Phase 5 | Part 2 | File 2
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ✅ NEW: Unified Design System Import
import 'package:athar/core/design_system/tokens.dart';

import '../../data/models/habit_model.dart';
import '../cubit/habit_cubit.dart';

class HabitFormSheet extends StatefulWidget {
  final HabitModel? habitToEdit;

  const HabitFormSheet({super.key, this.habitToEdit});

  static void show(BuildContext context, {HabitModel? habitToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: context.read<HabitCubit>(),
        child: HabitFormSheet(habitToEdit: habitToEdit),
      ),
    );
  }

  @override
  State<HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends State<HabitFormSheet> {
  late TextEditingController titleController;
  late TextEditingController targetController;
  late HabitFrequency selectedFreq;
  late HabitPeriod selectedPeriod;

  DateTime? _reminderTime;
  bool _isReminderEnabled = true;

  @override
  void initState() {
    super.initState();
    final isEditing = widget.habitToEdit != null;
    titleController = TextEditingController(
      text: isEditing ? widget.habitToEdit!.title : "",
    );
    targetController = TextEditingController(
      text: isEditing ? widget.habitToEdit!.target.toString() : "1",
    );
    selectedFreq = isEditing
        ? widget.habitToEdit!.frequency
        : HabitFrequency.daily;
    selectedPeriod = isEditing
        ? widget.habitToEdit!.period
        : HabitPeriod.anyTime;

    if (isEditing) {
      _reminderTime = widget.habitToEdit!.reminderTime;
      _isReminderEnabled = widget.habitToEdit!.reminderEnabled;
    } else {
      _reminderTime = DateTime.now().add(const Duration(hours: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habitToEdit != null;
    // ✅ Get colors & l10n
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        // ✅ Colors.white → colors.surface
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: AtharRadii.radiusXxxs,
                ),
              ),
            ),
            AtharGap.xl,
            Text(
              // ✅ l10n: "تعديل العادة" / "إضافة عادة جديدة 💪"
              isEditing ? l10n.habitFormEditTitle : l10n.habitFormAddTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            AtharGap.xl,

            // 1. اسم العادة
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                // ✅ l10n: "ما هي عادتك القادمة؟"
                hintText: l10n.habitFormNameHint,
                filled: true,
                // ✅ AppColors.background → colors.background
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  // ✅ BorderRadius.circular(12.r) → AtharRadii.radiusMd
                  borderRadius: AtharRadii.radiusMd,
                  borderSide: BorderSide.none,
                ),
              ),
              autofocus: true,
            ),
            AtharGap.lg,

            // 2. التكرار والوقت في صف واحد
            Row(
              children: [
                // ✅ l10n: "التكرار"
                Expanded(
                  child: _buildDropdownLabel(
                    colorScheme,
                    l10n.habitFormFrequency,
                  ),
                ),
                AtharGap.hMd,
                // ✅ l10n: "الفترة المفضلة"
                Expanded(
                  child: _buildDropdownLabel(
                    colorScheme,
                    l10n.habitFormPreferredPeriod,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _buildFreqDropdown(colorScheme, l10n)),
                AtharGap.hMd,
                Expanded(child: _buildPeriodDropdown(colorScheme, l10n)),
              ],
            ),
            AtharGap.lg,

            // 3. الهدف التكراري
            Text(
              // ✅ l10n: "الهدف التكراري"
              l10n.habitFormTargetLabel,
              style:
                  TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: 0.5,
                  ).copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.outline,
                  ),
            ),
            AtharGap.sm,
            TextField(
              controller: targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.ads_click),
                // ✅ l10n: "عدد المرات"
                hintText: l10n.habitFormTargetHint,
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: AtharRadii.radiusMd,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            AtharGap.xl,

            // 4. مكون التذكير
            ReminderPickerWidget(
              reminderTime: _reminderTime,
              isEnabled: _isReminderEnabled,
              onToggle: (val) => setState(() => _isReminderEnabled = val),
              onTimeChanged: (newTime) =>
                  setState(() => _reminderTime = newTime),
            ),

            AtharGap.xxl,

            // 5. زر الحفظ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  // ✅ AppColors.primary → colors.primary
                  backgroundColor: colorScheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: AtharRadii.radiusMd,
                  ),
                ),
                child: Text(
                  // ✅ l10n: "حفظ التعديلات" / "ابدأ العادة الآن"
                  isEditing ? l10n.habitFormSaveEdits : l10n.habitFormStartNow,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- دوال بناء الواجهة الفرعية ---
  Widget _buildDropdownLabel(ColorScheme colorScheme, String text) => Padding(
    padding: EdgeInsetsDirectional.only(bottom: 8.h, end: 4.w),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
      ).copyWith(fontWeight: FontWeight.bold, color: colorScheme.outline),
    ),
  );

  Widget _buildFreqDropdown(ColorScheme colorScheme, AppLocalizations l10n) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          // ✅ AppColors.background → colors.background
          color: colorScheme.surface,
          borderRadius: AtharRadii.radiusMd,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<HabitFrequency>(
            value: selectedFreq,
            isExpanded: true,
            items: [
              // ✅ l10n: frequency options
              DropdownMenuItem(
                value: HabitFrequency.daily,
                child: Text(l10n.habitFormFreqDaily),
              ),
              DropdownMenuItem(
                value: HabitFrequency.weekly,
                child: Text(l10n.habitFormFreqWeekly),
              ),
              DropdownMenuItem(
                value: HabitFrequency.monthly,
                child: Text(l10n.habitFormFreqMonthly),
              ),
            ],
            onChanged: (val) => setState(() => selectedFreq = val!),
          ),
        ),
      );

  Widget _buildPeriodDropdown(ColorScheme colorScheme, AppLocalizations l10n) =>
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AtharRadii.radiusMd,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<HabitPeriod>(
            value: selectedPeriod,
            isExpanded: true,
            items: [
              // ✅ l10n: period options
              DropdownMenuItem(
                value: HabitPeriod.morning,
                child: Text(l10n.habitFormPeriodMorning),
              ),
              DropdownMenuItem(
                value: HabitPeriod.afternoon,
                child: Text(l10n.habitFormPeriodAfternoon),
              ),
              DropdownMenuItem(
                value: HabitPeriod.night,
                child: Text(l10n.habitFormPeriodNight),
              ),
              DropdownMenuItem(
                value: HabitPeriod.anyTime,
                child: Text(l10n.habitFormPeriodAnytime),
              ),
            ],
            onChanged: (val) => setState(() => selectedPeriod = val!),
          ),
        ),
      );

  void _saveHabit() {
    if (titleController.text.isNotEmpty) {
      int target = int.tryParse(targetController.text) ?? 1;
      final cubit = context.read<HabitCubit>();

      if (widget.habitToEdit != null) {
        final habit = widget.habitToEdit!.copyWith(
          title: titleController.text,
          frequency: selectedFreq,
          period: selectedPeriod,
          target: target,
          reminderEnabled: _isReminderEnabled,
          reminderTime: _isReminderEnabled ? _reminderTime : null,
        );
        cubit.updateHabit(habit);
      } else {
        final newHabit = HabitModel(title: titleController.text)
          ..frequency = selectedFreq
          ..period = selectedPeriod
          ..target = target
          ..reminderEnabled = _isReminderEnabled
          ..reminderTime = _isReminderEnabled ? _reminderTime : null
          ..createdAt = DateTime.now();
        cubit.addHabit(newHabit);
      }
      Navigator.pop(context);
    }
  }
}
//-----------------------------------------------------------------------
// // lib/features/habits/presentation/widgets/habit_form_dialog.dart
// // ═══════════════════════════════════════════════════════════════════════════════
// // ✅ MIGRATED - Phase 5 | Part 2 | File 2
// // ═══════════════════════════════════════════════════════════════════════════════

// import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart';
// import 'package:athar/l10n/generated/app_localizations.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// // ✅ NEW: Unified Design System Import
// import 'package:athar/core/design_system/design_system.dart';

// // ✅ OLD: import '../../../../core/design_system/themes/app_colors.dart';
// import '../../data/models/habit_model.dart';
// import '../cubit/habit_cubit.dart';

// class HabitFormSheet extends StatefulWidget {
//   final HabitModel? habitToEdit;

//   const HabitFormSheet({super.key, this.habitToEdit});

//   static void show(BuildContext context, {HabitModel? habitToEdit}) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => BlocProvider.value(
//         value: context.read<HabitCubit>(),
//         child: HabitFormSheet(habitToEdit: habitToEdit),
//       ),
//     );
//   }

//   @override
//   State<HabitFormSheet> createState() => _HabitFormSheetState();
// }

// class _HabitFormSheetState extends State<HabitFormSheet> {
//   late TextEditingController titleController;
//   late TextEditingController targetController;
//   late HabitFrequency selectedFreq;
//   late HabitPeriod selectedPeriod;

//   DateTime? _reminderTime;
//   bool _isReminderEnabled = true;

//   @override
//   void initState() {
//     super.initState();
//     final isEditing = widget.habitToEdit != null;
//     titleController = TextEditingController(
//       text: isEditing ? widget.habitToEdit!.title : "",
//     );
//     targetController = TextEditingController(
//       text: isEditing ? widget.habitToEdit!.target.toString() : "1",
//     );
//     selectedFreq = isEditing
//         ? widget.habitToEdit!.frequency
//         : HabitFrequency.daily;
//     selectedPeriod = isEditing
//         ? widget.habitToEdit!.period
//         : HabitPeriod.anyTime;

//     if (isEditing) {
//       _reminderTime = widget.habitToEdit!.reminderTime;
//       _isReminderEnabled = widget.habitToEdit!.reminderEnabled;
//     } else {
//       _reminderTime = DateTime.now().add(const Duration(hours: 1));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.habitToEdit != null;
//     // ✅ Get colors & l10n
//     final colors = context.colors;
//     final l10n = AppLocalizations.of(context);

//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         20.w,
//         12.h,
//         20.w,
//         MediaQuery.of(context).viewInsets.bottom + 20.h,
//       ),
//       decoration: BoxDecoration(
//         // ✅ Colors.white → colors.surface
//         color: colors.surface,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40.w,
//                 height: 4.h,
//                 decoration: BoxDecoration(
//                   color: colors.borderLight,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               // ✅ l10n: "تعديل العادة" / "إضافة عادة جديدة 💪"
//               isEditing ? l10n.habitFormEditTitle : l10n.habitFormAddTitle,
//               style: AtharTypography.titleLarge.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 20.h),

//             // 1. اسم العادة
//             TextField(
//               controller: titleController,
//               decoration: InputDecoration(
//                 // ✅ l10n: "ما هي عادتك القادمة؟"
//                 hintText: l10n.habitFormNameHint,
//                 filled: true,
//                 // ✅ AppColors.background → colors.background
//                 fillColor: colors.background,
//                 border: OutlineInputBorder(
//                   // ✅ BorderRadius.circular(12.r) → AtharRadii.radiusMd
//                   borderRadius: AtharRadii.radiusMd,
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               autofocus: true,
//             ),
//             AtharGap.lg,

//             // 2. التكرار والوقت في صف واحد
//             Row(
//               children: [
//                 // ✅ l10n: "التكرار"
//                 Expanded(
//                   child: _buildDropdownLabel(colors, l10n.habitFormFrequency),
//                 ),
//                 AtharGap.hMd,
//                 // ✅ l10n: "الفترة المفضلة"
//                 Expanded(
//                   child: _buildDropdownLabel(
//                     colors,
//                     l10n.habitFormPreferredPeriod,
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Expanded(child: _buildFreqDropdown(colors, l10n)),
//                 AtharGap.hMd,
//                 Expanded(child: _buildPeriodDropdown(colors, l10n)),
//               ],
//             ),
//             AtharGap.lg,

//             // 3. الهدف التكراري
//             Text(
//               // ✅ l10n: "الهدف التكراري"
//               l10n.habitFormTargetLabel,
//               style: AtharTypography.labelMedium.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: colors.textTertiary,
//               ),
//             ),
//             AtharGap.sm,
//             TextField(
//               controller: targetController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.ads_click),
//                 // ✅ l10n: "عدد المرات"
//                 hintText: l10n.habitFormTargetHint,
//                 filled: true,
//                 fillColor: colors.background,
//                 border: OutlineInputBorder(
//                   borderRadius: AtharRadii.radiusMd,
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),

//             // 4. مكون التذكير
//             ReminderPickerWidget(
//               reminderTime: _reminderTime,
//               isEnabled: _isReminderEnabled,
//               onToggle: (val) => setState(() => _isReminderEnabled = val),
//               onTimeChanged: (newTime) =>
//                   setState(() => _reminderTime = newTime),
//             ),

//             SizedBox(height: 24.h),

//             // 5. زر الحفظ
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _saveHabit,
//                 style: ElevatedButton.styleFrom(
//                   // ✅ AppColors.primary → colors.primary
//                   backgroundColor: colors.primary,
//                   padding: EdgeInsets.symmetric(vertical: 14.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: AtharRadii.radiusMd,
//                   ),
//                 ),
//                 child: Text(
//                   // ✅ l10n: "حفظ التعديلات" / "ابدأ العادة الآن"
//                   isEditing ? l10n.habitFormSaveEdits : l10n.habitFormStartNow,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- دوال بناء الواجهة الفرعية ---
//   Widget _buildDropdownLabel(AtharColors colors, String text) => Padding(
//     padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
//     child: Text(
//       text,
//       style: AtharTypography.labelMedium.copyWith(
//         fontWeight: FontWeight.bold,
//         color: colors.textTertiary,
//       ),
//     ),
//   );

//   Widget _buildFreqDropdown(AtharColors colors, AppLocalizations l10n) =>
//       Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w),
//         decoration: BoxDecoration(
//           // ✅ AppColors.background → colors.background
//           color: colors.background,
//           borderRadius: AtharRadii.radiusMd,
//         ),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<HabitFrequency>(
//             value: selectedFreq,
//             isExpanded: true,
//             items: [
//               // ✅ l10n: frequency options
//               DropdownMenuItem(
//                 value: HabitFrequency.daily,
//                 child: Text(l10n.habitFormFreqDaily),
//               ),
//               DropdownMenuItem(
//                 value: HabitFrequency.weekly,
//                 child: Text(l10n.habitFormFreqWeekly),
//               ),
//               DropdownMenuItem(
//                 value: HabitFrequency.monthly,
//                 child: Text(l10n.habitFormFreqMonthly),
//               ),
//             ],
//             onChanged: (val) => setState(() => selectedFreq = val!),
//           ),
//         ),
//       );

//   Widget _buildPeriodDropdown(AtharColors colors, AppLocalizations l10n) =>
//       Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w),
//         decoration: BoxDecoration(
//           color: colors.background,
//           borderRadius: AtharRadii.radiusMd,
//         ),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<HabitPeriod>(
//             value: selectedPeriod,
//             isExpanded: true,
//             items: [
//               // ✅ l10n: period options
//               DropdownMenuItem(
//                 value: HabitPeriod.morning,
//                 child: Text(l10n.habitFormPeriodMorning),
//               ),
//               DropdownMenuItem(
//                 value: HabitPeriod.afternoon,
//                 child: Text(l10n.habitFormPeriodAfternoon),
//               ),
//               DropdownMenuItem(
//                 value: HabitPeriod.night,
//                 child: Text(l10n.habitFormPeriodNight),
//               ),
//               DropdownMenuItem(
//                 value: HabitPeriod.anyTime,
//                 child: Text(l10n.habitFormPeriodAnytime),
//               ),
//             ],
//             onChanged: (val) => setState(() => selectedPeriod = val!),
//           ),
//         ),
//       );

//   void _saveHabit() {
//     if (titleController.text.isNotEmpty) {
//       int target = int.tryParse(targetController.text) ?? 1;
//       final cubit = context.read<HabitCubit>();

//       if (widget.habitToEdit != null) {
//         final habit = widget.habitToEdit!.copyWith(
//           title: titleController.text,
//           frequency: selectedFreq,
//           period: selectedPeriod,
//           target: target,
//           reminderEnabled: _isReminderEnabled,
//           reminderTime: _isReminderEnabled ? _reminderTime : null,
//         );
//         cubit.updateHabit(habit);
//       } else {
//         final newHabit = HabitModel(title: titleController.text)
//           ..frequency = selectedFreq
//           ..period = selectedPeriod
//           ..target = target
//           ..reminderEnabled = _isReminderEnabled
//           ..reminderTime = _isReminderEnabled ? _reminderTime : null
//           ..createdAt = DateTime.now();
//         cubit.addHabit(newHabit);
//       }
//       Navigator.pop(context);
//     }
//   }
// }
//-----------------------------------------------------------------------

// import 'package:athar/core/design_system/molecules/pickers/reminder_picker_widget.dart'; // ✅ الاستيراد الجديد
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/design_system/themes/app_colors.dart';
// import '../../data/models/habit_model.dart';
// import '../cubit/habit_cubit.dart';

// class HabitFormSheet extends StatefulWidget {
//   // ✅ تم تغيير الاسم ليعبر عن الوظيفة الجديدة
//   final HabitModel? habitToEdit;

//   const HabitFormSheet({super.key, this.habitToEdit});

//   static void show(BuildContext context, {HabitModel? habitToEdit}) {
//     showModalBottomSheet(
//       // ✅ التغيير من Dialog إلى BottomSheet ليتوافق مع AddTaskSheet
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => BlocProvider.value(
//         value: context.read<HabitCubit>(),
//         child: HabitFormSheet(habitToEdit: habitToEdit),
//       ),
//     );
//   }

//   @override
//   State<HabitFormSheet> createState() => _HabitFormSheetState();
// }

// class _HabitFormSheetState extends State<HabitFormSheet> {
//   late TextEditingController titleController;
//   late TextEditingController targetController;
//   late HabitFrequency selectedFreq;
//   late HabitPeriod selectedPeriod;

//   // ✅ متغيرات التذكير الجديدة
//   DateTime? _reminderTime;
//   bool _isReminderEnabled = true;

//   @override
//   void initState() {
//     super.initState();
//     final isEditing = widget.habitToEdit != null;
//     titleController = TextEditingController(
//       text: isEditing ? widget.habitToEdit!.title : "",
//     );
//     targetController = TextEditingController(
//       text: isEditing ? widget.habitToEdit!.target.toString() : "1",
//     );
//     selectedFreq = isEditing
//         ? widget.habitToEdit!.frequency
//         : HabitFrequency.daily;
//     selectedPeriod = isEditing
//         ? widget.habitToEdit!.period
//         : HabitPeriod.anyTime;

//     // ✅ تحميل بيانات التذكير عند التعديل
//     if (isEditing) {
//       _reminderTime = widget.habitToEdit!.reminderTime;
//       _isReminderEnabled = widget.habitToEdit!.reminderEnabled;
//     } else {
//       _reminderTime = DateTime.now().add(
//         const Duration(hours: 1),
//       ); // وقت افتراضي
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.habitToEdit != null;

//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         20.w,
//         12.h,
//         20.w,
//         MediaQuery.of(context).viewInsets.bottom + 20.h,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Container(
//                 width: 40.w,
//                 height: 4.h,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               isEditing ? "تعديل العادة" : "إضافة عادة جديدة 💪",
//               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20.h),

//             // 1. اسم العادة
//             TextField(
//               controller: titleController,
//               decoration: InputDecoration(
//                 hintText: "ما هي عادتك القادمة؟",
//                 filled: true,
//                 fillColor: AppColors.background,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               autofocus: true,
//             ),
//             SizedBox(height: 16.h),

//             // 2. التكرار والوقت في صف واحد
//             Row(
//               children: [
//                 Expanded(child: _buildDropdownLabel("التكرار")),
//                 SizedBox(width: 12.w),
//                 Expanded(child: _buildDropdownLabel("الفترة المفضلة")),
//               ],
//             ),
//             Row(
//               children: [
//                 Expanded(child: _buildFreqDropdown()),
//                 SizedBox(width: 12.w),
//                 Expanded(child: _buildPeriodDropdown()),
//               ],
//             ),
//             SizedBox(height: 16.h),

//             // 3. الهدف المالي/العددي
//             Text(
//               "الهدف التكراري",
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             TextField(
//               controller: targetController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(Icons.ads_click),
//                 hintText: "عدد المرات",
//                 filled: true,
//                 fillColor: AppColors.background,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),

//             // ✅ 4. حقن مكون التذكير الموحد
//             ReminderPickerWidget(
//               reminderTime: _reminderTime,
//               isEnabled: _isReminderEnabled,
//               onToggle: (val) => setState(() => _isReminderEnabled = val),
//               onTimeChanged: (newTime) =>
//                   setState(() => _reminderTime = newTime),
//             ),

//             SizedBox(height: 24.h),

//             // 5. زر الحفظ الاحترافي
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _saveHabit,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   padding: EdgeInsets.symmetric(vertical: 14.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 child: Text(
//                   isEditing ? "حفظ التعديلات" : "ابدأ العادة الآن",
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- دوال بناء الواجهة الفرعية ---
//   Widget _buildDropdownLabel(String text) => Padding(
//     padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
//     child: Text(
//       text,
//       style: TextStyle(
//         fontSize: 12.sp,
//         fontWeight: FontWeight.bold,
//         color: Colors.grey,
//       ),
//     ),
//   );

//   Widget _buildFreqDropdown() => Container(
//     padding: EdgeInsets.symmetric(horizontal: 12.w),
//     decoration: BoxDecoration(
//       color: AppColors.background,
//       borderRadius: BorderRadius.circular(12.r),
//     ),
//     child: DropdownButtonHideUnderline(
//       child: DropdownButton<HabitFrequency>(
//         value: selectedFreq,
//         isExpanded: true,
//         items: const [
//           DropdownMenuItem(value: HabitFrequency.daily, child: Text("يومي")),
//           DropdownMenuItem(value: HabitFrequency.weekly, child: Text("أسبوعي")),
//           DropdownMenuItem(value: HabitFrequency.monthly, child: Text("شهري")),
//         ],
//         onChanged: (val) => setState(() => selectedFreq = val!),
//       ),
//     ),
//   );

//   Widget _buildPeriodDropdown() => Container(
//     padding: EdgeInsets.symmetric(horizontal: 12.w),
//     decoration: BoxDecoration(
//       color: AppColors.background,
//       borderRadius: BorderRadius.circular(12.r),
//     ),
//     child: DropdownButtonHideUnderline(
//       child: DropdownButton<HabitPeriod>(
//         value: selectedPeriod,
//         isExpanded: true,
//         items: const [
//           DropdownMenuItem(value: HabitPeriod.morning, child: Text("صباحاً")),
//           DropdownMenuItem(value: HabitPeriod.afternoon, child: Text("عصراً")),
//           DropdownMenuItem(value: HabitPeriod.night, child: Text("ليلاً")),
//           DropdownMenuItem(value: HabitPeriod.anyTime, child: Text("أي وقت")),
//         ],
//         onChanged: (val) => setState(() => selectedPeriod = val!),
//       ),
//     ),
//   );

//   void _saveHabit() {
//     if (titleController.text.isNotEmpty) {
//       int target = int.tryParse(targetController.text) ?? 1;
//       final cubit = context.read<HabitCubit>();

//       if (widget.habitToEdit != null) {
//         final habit = widget.habitToEdit!.copyWith(
//           title: titleController.text,
//           frequency: selectedFreq,
//           period: selectedPeriod,
//           target: target,
//           reminderEnabled: _isReminderEnabled,
//           reminderTime: _isReminderEnabled ? _reminderTime : null,
//         );
//         cubit.updateHabit(habit);
//       } else {
//         final newHabit = HabitModel(title: titleController.text)
//           ..frequency = selectedFreq
//           ..period = selectedPeriod
//           ..target = target
//           ..reminderEnabled = _isReminderEnabled
//           ..reminderTime = _isReminderEnabled ? _reminderTime : null
//           ..createdAt = DateTime.now();
//         cubit.addHabit(newHabit);
//       }
//       Navigator.pop(context);
//     }
//   }
// }
//-----------------------------------------------------------------------
