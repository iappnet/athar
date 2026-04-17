// lib/features/settings/presentation/widgets/add_category_dialog.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ➕ ADD CATEGORY DIALOG - حوار إضافة تصنيف جديد مع Icon Picker
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/icon_picker.dart';
import 'package:athar/core/utils/icon_registry.dart';
import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  /// ✅ عرض الحوار
  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  String _selectedIconKey = IconRegistry.defaultIconKey;
  int _selectedColor = 0xFF9C27B0; // بنفسجي افتراضي

  // ألوان متاحة للاختيار
  static const List<int> _availableColors = [
    0xFF2196F3, // أزرق
    0xFF4CAF50, // أخضر
    0xFFFF9800, // برتقالي
    0xFFE91E63, // وردي
    0xFF9C27B0, // بنفسجي
    0xFF00BCD4, // سماوي
    0xFFFF5722, // برتقالي داكن
    0xFF795548, // بني
    0xFF607D8B, // رمادي أزرق
    0xFF3F51B5, // نيلي
    0xFFCDDC39, // أصفر أخضر
    0xFF009688, // تركواز
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _selectIcon() async {
    final selectedKey = await AtharIconPicker.show(
      context,
      selectedIconKey: _selectedIconKey,
      selectedColor: Color(_selectedColor),
    );

    if (selectedKey != null) {
      setState(() => _selectedIconKey = selectedKey);
    }
  }

  void _addCategory() {
    if (_nameController.text.trim().isEmpty) return;

    context.read<CategoryCubit>().addCategory(
          name: _nameController.text.trim(),
          colorValue: _selectedColor,
          iconKey: _selectedIconKey,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.newCategory),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════════════════
            // 📝 اسم التصنيف
            // ═══════════════════════════════════════════════════════════════
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: l10n.categoryName,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addCategory(),
            ),
            AtharGap.lg,

            // ═══════════════════════════════════════════════════════════════
            // 🎨 اختيار الأيقونة
            // ═══════════════════════════════════════════════════════════════
            Text(
              l10n.icon,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            AtharGap.sm,
            InkWell(
              onTap: _selectIcon,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Color(_selectedColor).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        IconRegistry.getIcon(_selectedIconKey),
                        color: Color(_selectedColor),
                        size: 24.sp,
                      ),
                    ),
                    AtharGap.hMd,
                    Expanded(
                      child: Text(
                        l10n.tapToChangeIcon,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            AtharGap.lg,

            // ═══════════════════════════════════════════════════════════════
            // 🌈 اختيار اللون
            // ═══════════════════════════════════════════════════════════════
            Text(
              l10n.color,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            AtharGap.sm,
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color(color).withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18.sp,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _nameController.text.trim().isEmpty ? null : _addCategory,
          child: Text(l10n.add),
        ),
      ],
    );
  }
}
