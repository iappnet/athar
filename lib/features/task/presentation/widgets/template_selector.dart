import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_feedback.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/features/task/data/models/task_template.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Semantic colors (not in ColorScheme)
const _warningColor = Color(0xFFFDCB6E);

class TemplateSelector extends StatelessWidget {
  final List<TaskTemplate> templates;
  final Function(TaskTemplate) onTemplateSelected;
  final VoidCallback onCreateNew;
  final Function(TaskTemplate)? onSaveAsTemplate;

  const TemplateSelector({
    super.key,
    required this.templates,
    required this.onTemplateSelected,
    required this.onCreateNew,
    this.onSaveAsTemplate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: _warningColor.withValues(alpha: 0.1),
        borderRadius: AtharRadii.radiusMd,
        border: Border.all(color: _warningColor.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.stars, color: _warningColor),
        title: Text(
          l10n.readyTemplates,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: templates.isEmpty
            ? Text(l10n.noTemplatesSaved)
            : Text(l10n.templatesAvailable(templates.length)),
        children: [
          if (templates.isEmpty)
            Padding(
              padding: AtharSpacing.allLg,
              child: Column(
                children: [
                  Icon(
                    Icons.inbox,
                    size: 48.sp,
                    color: colorScheme.outlineVariant,
                  ),
                  AtharGap.sm,
                  Text(
                    l10n.noTemplatesYet,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  AtharGap.md,
                  if (onSaveAsTemplate != null)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt),
                      label: Text(l10n.saveTaskAsTemplate),
                      onPressed: () => _showSaveTemplateDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                ],
              ),
            )
          else
            SizedBox(
              height: 150.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                itemCount: templates.length + 1,
                itemBuilder: (context, index) {
                  if (index == templates.length) {
                    return _buildCreateNewCard(context);
                  }
                  return _buildTemplateCard(context, templates[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, TaskTemplate template) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.only(right: 12.w),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AtharRadii.radiusMd,
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () => onTemplateSelected(template),
        borderRadius: AtharRadii.radiusMd,
        child: Container(
          width: 140.w,
          padding: AtharSpacing.allMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    template.icon ?? '📋',
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.outline,
                      borderRadius: AtharRadii.radiusSm,
                    ),
                    child: Text(
                      '${template.usageCount}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              AtharGap.sm,
              Text(
                template.name,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (template.description != null) ...[
                AtharGap.xxs,
                Text(
                  template.description!,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  if (template.isUrgent)
                    Icon(Icons.flag, size: 12.sp, color: colorScheme.error),
                  if (template.isImportant)
                    Icon(Icons.star, size: 12.sp, color: _warningColor),
                  const Spacer(),
                  Icon(Icons.schedule, size: 12.sp, color: colorScheme.outline),
                  AtharGap.hXxs,
                  Text(
                    l10n.durationMinutesShort(template.durationMinutes),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateNewCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.only(right: 12.w),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: AtharRadii.radiusMd,
        side: BorderSide(
          color: colorScheme.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onTap: onCreateNew,
        borderRadius: AtharRadii.radiusMd,
        child: Container(
          width: 140.w,
          padding: AtharSpacing.allMd,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 32.sp,
                color: colorScheme.primary,
              ),
              AtharGap.sm,
              Text(
                l10n.createNewTemplate,
                style: TextStyle(fontSize: 12.sp, color: colorScheme.primary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✅ الدالة المصححة - مع Isar Collection pattern الصحيح (Cascade Operator)
  // ═══════════════════════════════════════════════════════════════════════════
  void _showSaveTemplateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final titleController = TextEditingController();

    // ✅ قائمة الأيقونات المتاحة
    final List<String> availableIcons = [
      '📋',
      '📝',
      '✅',
      '📌',
      '🎯',
      '💼',
      '📊',
      '📈',
      '🏠',
      '🛒',
      '💪',
      '📚',
      '💻',
      '🎨',
      '🎵',
      '⚡',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        // ✅ المتغيرات داخل builder لاستخدامها مع StatefulBuilder
        String selectedIcon = '📋';
        bool isUrgent = false;
        bool isImportant = false;
        int durationMinutes = 30;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colorScheme = Theme.of(context).colorScheme;
            final l10n = AppLocalizations.of(context);

            return AlertDialog(
              title: Text(l10n.saveAsTemplate),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم القالب
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.templateNameRequired,
                        hintText: l10n.templateNameHint,
                      ),
                    ),
                    AtharGap.md,

                    // عنوان المهمة الافتراضي
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: l10n.defaultTaskTitleRequired,
                        hintText: l10n.defaultTitleHint,
                      ),
                    ),
                    AtharGap.md,

                    // الوصف
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: l10n.descriptionOptional,
                      ),
                      maxLines: 2,
                    ),
                    AtharGap.lg,

                    // ✅ محدد الأيقونة
                    Text(
                      l10n.selectIcon,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    AtharGap.sm,
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: availableIcons.map((icon) {
                        final isSelected = icon == selectedIcon;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedIcon = icon;
                            });
                          },
                          child: Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary.withValues(alpha: 0.2)
                                  : colorScheme.surfaceContainer,
                              borderRadius: AtharRadii.radiusSm,
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                icon,
                                style: TextStyle(fontSize: 20.sp),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    AtharGap.lg,

                    // ✅ خيارات الأولوية
                    Text(
                      l10n.priorityLabel,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    AtharGap.sm,
                    Row(
                      children: [
                        FilterChip(
                          label: Text(l10n.urgent),
                          selected: isUrgent,
                          onSelected: (val) {
                            setDialogState(() => isUrgent = val);
                          },
                          selectedColor: colorScheme.error.withValues(
                            alpha: 0.15,
                          ),
                          avatar: Icon(
                            Icons.flag,
                            size: 16.sp,
                            color: isUrgent
                                ? colorScheme.error
                                : colorScheme.outline,
                          ),
                        ),
                        AtharGap.hSm,
                        FilterChip(
                          label: Text(l10n.important),
                          selected: isImportant,
                          onSelected: (val) {
                            setDialogState(() => isImportant = val);
                          },
                          selectedColor: _warningColor.withValues(alpha: 0.15),
                          avatar: Icon(
                            Icons.star,
                            size: 16.sp,
                            color: isImportant
                                ? _warningColor
                                : colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    AtharGap.lg,

                    // ✅ المدة
                    Text(
                      l10n.defaultDurationMinutes(durationMinutes),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Slider(
                      value: durationMinutes.toDouble(),
                      min: 5,
                      max: 180,
                      divisions: 35,
                      label: l10n.durationMinutesShort(durationMinutes),
                      onChanged: (val) {
                        setDialogState(() => durationMinutes = val.toInt());
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    // ✅ التحقق من الحقول المطلوبة
                    if (nameController.text.isEmpty ||
                        titleController.text.isEmpty) {
                      AtharSnackbar.error(
                        context: context,
                        message: l10n.fillRequiredFields,
                      );
                      return;
                    }

                    if (onSaveAsTemplate != null) {
                      // ══════════════════════════════════════════════════════
                      // ✅ الحل الصحيح: Isar Collection يستخدم Cascade Operator
                      // ══════════════════════════════════════════════════════
                      final newTemplate = TaskTemplate()
                        ..uuid = const Uuid().v4()
                        ..userId =
                            Supabase.instance.client.auth.currentUser?.id ?? ''
                        ..name = nameController.text
                        ..title = titleController.text
                        ..description = descController.text.isEmpty
                            ? null
                            : descController.text
                        ..icon = selectedIcon
                        ..isUrgent = isUrgent
                        ..isImportant = isImportant
                        ..durationMinutes = durationMinutes
                        ..createdAt = DateTime.now()
                        ..updatedAt = DateTime.now()
                        ..usageCount = 0;

                      onSaveAsTemplate!(newTemplate);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/task/data/models/task_template.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:uuid/uuid.dart';

// class TemplateSelector extends StatelessWidget {
//   final List<TaskTemplate> templates;
//   final Function(TaskTemplate) onTemplateSelected;
//   final VoidCallback onCreateNew;
//   final Function(TaskTemplate)? onSaveAsTemplate;

//   const TemplateSelector({
//     super.key,
//     required this.templates,
//     required this.onTemplateSelected,
//     required this.onCreateNew,
//     this.onSaveAsTemplate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.amber.shade50,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: Colors.amber.shade200),
//       ),
//       child: ExpansionTile(
//         leading: const Icon(Icons.stars, color: Colors.amber),
//         title: const Text(
//           "القوالب الجاهزة",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: templates.isEmpty
//             ? const Text("لا توجد قوالب محفوظة")
//             : Text("${templates.length} قالب متاح"),
//         children: [
//           if (templates.isEmpty)
//             Padding(
//               padding: EdgeInsets.all(16.w),
//               child: Column(
//                 children: [
//                   Icon(Icons.inbox, size: 48.sp, color: Colors.grey.shade300),
//                   SizedBox(height: 8.h),
//                   Text(
//                     "لم تقم بحفظ أي قوالب بعد",
//                     style: TextStyle(color: Colors.grey.shade600),
//                   ),
//                   SizedBox(height: 12.h),
//                   if (onSaveAsTemplate != null)
//                     ElevatedButton.icon(
//                       icon: const Icon(Icons.save_alt),
//                       label: const Text("احفظ هذه المهمة كقالب"),
//                       onPressed: () => _showSaveTemplateDialog(context),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                 ],
//               ),
//             )
//           else
//             SizedBox(
//               height: 150.h,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                 itemCount: templates.length + 1,
//                 itemBuilder: (context, index) {
//                   if (index == templates.length) {
//                     return _buildCreateNewCard(context);
//                   }
//                   return _buildTemplateCard(context, templates[index]);
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTemplateCard(BuildContext context, TaskTemplate template) {
//     return Card(
//       margin: EdgeInsets.only(right: 12.w),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.r),
//         side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
//       ),
//       child: InkWell(
//         onTap: () => onTemplateSelected(template),
//         borderRadius: BorderRadius.circular(12.r),
//         child: Container(
//           width: 140.w,
//           padding: EdgeInsets.all(12.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     template.icon ?? '📋',
//                     style: TextStyle(fontSize: 24.sp),
//                   ),
//                   const Spacer(),
//                   Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 6.w,
//                       vertical: 2.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade200,
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                     child: Text(
//                       '${template.usageCount}',
//                       style: TextStyle(
//                         fontSize: 10.sp,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 8.h),
//               Text(
//                 template.name,
//                 style: TextStyle(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Tajawal',
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               if (template.description != null) ...[
//                 SizedBox(height: 4.h),
//                 Text(
//                   template.description!,
//                   style: TextStyle(
//                     fontSize: 10.sp,
//                     color: Colors.grey.shade600,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//               const Spacer(),
//               Row(
//                 children: [
//                   if (template.isUrgent)
//                     Icon(Icons.flag, size: 12.sp, color: Colors.red),
//                   if (template.isImportant)
//                     Icon(Icons.star, size: 12.sp, color: Colors.orange),
//                   const Spacer(),
//                   Icon(Icons.schedule, size: 12.sp, color: Colors.grey),
//                   SizedBox(width: 4.w),
//                   Text(
//                     '${template.durationMinutes}د',
//                     style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCreateNewCard(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.only(right: 12.w),
//       elevation: 1,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.r),
//         side: BorderSide(color: Colors.grey.shade300, style: BorderStyle.solid),
//       ),
//       child: InkWell(
//         onTap: onCreateNew,
//         borderRadius: BorderRadius.circular(12.r),
//         child: Container(
//           width: 140.w,
//           padding: EdgeInsets.all(12.w),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.add_circle_outline,
//                 size: 32.sp,
//                 color: AppColors.primary,
//               ),
//               SizedBox(height: 8.h),
//               Text(
//                 "إنشاء قالب جديد",
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: AppColors.primary,
//                   fontFamily: 'Tajawal',
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ═══════════════════════════════════════════════════════════════════════════
//   // ✅ الدالة المصححة - مع Isar Collection pattern الصحيح (Cascade Operator)
//   // ═══════════════════════════════════════════════════════════════════════════
//   void _showSaveTemplateDialog(BuildContext context) {
//     final nameController = TextEditingController();
//     final descController = TextEditingController();
//     final titleController = TextEditingController();

//     // ✅ قائمة الأيقونات المتاحة
//     final List<String> availableIcons = [
//       '📋',
//       '📝',
//       '✅',
//       '📌',
//       '🎯',
//       '💼',
//       '📊',
//       '📈',
//       '🏠',
//       '🛒',
//       '💪',
//       '📚',
//       '💻',
//       '🎨',
//       '🎵',
//       '⚡',
//     ];

//     showDialog(
//       context: context,
//       builder: (ctx) {
//         // ✅ المتغيرات داخل builder لاستخدامها مع StatefulBuilder
//         String selectedIcon = '📋';
//         bool isUrgent = false;
//         bool isImportant = false;
//         int durationMinutes = 30;

//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               title: const Text("حفظ كقالب"),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // اسم القالب
//                     TextField(
//                       controller: nameController,
//                       decoration: const InputDecoration(
//                         labelText: "اسم القالب *",
//                         hintText: "مثال: اجتماع أسبوعي",
//                       ),
//                     ),
//                     SizedBox(height: 12.h),

//                     // عنوان المهمة الافتراضي
//                     TextField(
//                       controller: titleController,
//                       decoration: const InputDecoration(
//                         labelText: "عنوان المهمة الافتراضي *",
//                         hintText: "مثال: اجتماع الفريق",
//                       ),
//                     ),
//                     SizedBox(height: 12.h),

//                     // الوصف
//                     TextField(
//                       controller: descController,
//                       decoration: const InputDecoration(
//                         labelText: "وصف (اختياري)",
//                       ),
//                       maxLines: 2,
//                     ),
//                     SizedBox(height: 16.h),

//                     // ✅ محدد الأيقونة
//                     Text(
//                       "اختر أيقونة:",
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     Wrap(
//                       spacing: 8.w,
//                       runSpacing: 8.h,
//                       children: availableIcons.map((icon) {
//                         final isSelected = icon == selectedIcon;
//                         return GestureDetector(
//                           onTap: () {
//                             setDialogState(() {
//                               selectedIcon = icon;
//                             });
//                           },
//                           child: Container(
//                             width: 40.w,
//                             height: 40.w,
//                             decoration: BoxDecoration(
//                               color: isSelected
//                                   ? AppColors.primary.withOpacity(0.2)
//                                   : Colors.grey.shade100,
//                               borderRadius: BorderRadius.circular(8.r),
//                               border: Border.all(
//                                 color: isSelected
//                                     ? AppColors.primary
//                                     : Colors.grey.shade300,
//                                 width: isSelected ? 2 : 1,
//                               ),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 icon,
//                                 style: TextStyle(fontSize: 20.sp),
//                               ),
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                     SizedBox(height: 16.h),

//                     // ✅ خيارات الأولوية
//                     Text(
//                       "الأولوية:",
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     Row(
//                       children: [
//                         FilterChip(
//                           label: const Text("عاجل"),
//                           selected: isUrgent,
//                           onSelected: (val) {
//                             setDialogState(() => isUrgent = val);
//                           },
//                           selectedColor: Colors.red.shade100,
//                           avatar: Icon(
//                             Icons.flag,
//                             size: 16.sp,
//                             color: isUrgent ? Colors.red : Colors.grey,
//                           ),
//                         ),
//                         SizedBox(width: 8.w),
//                         FilterChip(
//                           label: const Text("مهم"),
//                           selected: isImportant,
//                           onSelected: (val) {
//                             setDialogState(() => isImportant = val);
//                           },
//                           selectedColor: Colors.orange.shade100,
//                           avatar: Icon(
//                             Icons.star,
//                             size: 16.sp,
//                             color: isImportant ? Colors.orange : Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16.h),

//                     // ✅ المدة
//                     Text(
//                       "المدة الافتراضية: $durationMinutes دقيقة",
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                     Slider(
//                       value: durationMinutes.toDouble(),
//                       min: 5,
//                       max: 180,
//                       divisions: 35,
//                       label: "$durationMinutes د",
//                       onChanged: (val) {
//                         setDialogState(() => durationMinutes = val.toInt());
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(ctx),
//                   child: const Text("إلغاء"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     // ✅ التحقق من الحقول المطلوبة
//                     if (nameController.text.isEmpty ||
//                         titleController.text.isEmpty) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("يرجى ملء الحقول المطلوبة"),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                       return;
//                     }

//                     if (onSaveAsTemplate != null) {
//                       // ══════════════════════════════════════════════════════
//                       // ✅ الحل الصحيح: Isar Collection يستخدم Cascade Operator
//                       // ══════════════════════════════════════════════════════
//                       final newTemplate = TaskTemplate()
//                         ..uuid = const Uuid().v4()
//                         ..userId =
//                             Supabase.instance.client.auth.currentUser?.id ?? ''
//                         ..name = nameController.text
//                         ..title = titleController.text
//                         ..description = descController.text.isEmpty
//                             ? null
//                             : descController.text
//                         ..icon = selectedIcon
//                         ..isUrgent = isUrgent
//                         ..isImportant = isImportant
//                         ..durationMinutes = durationMinutes
//                         ..createdAt = DateTime.now()
//                         ..updatedAt = DateTime.now()
//                         ..usageCount = 0;

//                       onSaveAsTemplate!(newTemplate);
//                       Navigator.pop(ctx);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     foregroundColor: Colors.white,
//                   ),
//                   child: const Text("حفظ"),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
