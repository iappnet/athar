// lib/features/task/presentation/widgets/components/category_selector.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 📁 CATEGORY SELECTOR - اختيار التصنيف مع دعم IconRegistry
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/core/design_system/widgets/athar_dialog.dart';
import 'package:athar/core/utils/icon_registry.dart';
import 'package:athar/features/settings/data/models/category_model.dart';
import 'package:athar/features/settings/presentation/cubit/category_cubit.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class CategorySelector extends StatelessWidget {
  final CategoryModel? selectedCategory;
  final Function(CategoryModel) onSelected;
  final VoidCallback onAddPressed;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.categoryLabel,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12.sp,
            fontFamily: AtharTypography.fontFamily,
            fontFamilyFallback: AtharTypography.fontFallback,
          ),
        ),
        AtharGap.sm,
        BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoaded) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...state.categories.map((cat) {
                      final isSelected = selectedCategory?.id == cat.id;

                      // ✅ الحل النهائي: استخدام IconRegistry
                      final iconData = IconRegistry.getIcon(cat.iconKey);

                      return Padding(
                        padding: EdgeInsetsDirectional.only(start: 8.w),
                        child: InputChip(
                          showCheckmark: false,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                iconData,
                                size: 16.sp,
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : Color(cat.colorValue),
                              ),
                              AtharGap.hXxs,
                              Text(cat.name),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) onSelected(cat);
                          },
                          selectedColor: Color(cat.colorValue),
                          backgroundColor: colorScheme.surfaceContainerLowest,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                            fontFamily: AtharTypography.fontFamily,
                            fontFamilyFallback: AtharTypography.fontFallback,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: AtharRadii.radiusXl,
                          ),
                          onDeleted: cat.isDefault
                              ? null
                              : () => _confirmDelete(context, cat),
                          deleteIcon: cat.isDefault
                              ? null
                              : Icon(
                                  Icons.close,
                                  size: 14.sp,
                                  color: isSelected
                                      ? colorScheme.onPrimary.withValues(
                                          alpha: 0.7,
                                        )
                                      : colorScheme.onSurfaceVariant,
                                ),
                        ),
                      );
                    }),
                    ActionChip(
                      label: const Icon(Icons.add, size: 18),
                      onPressed: onAddPressed,
                      backgroundColor: colorScheme.outline,
                      side: BorderSide.none,
                      shape: const CircleBorder(),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel cat) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await AtharDialog.confirm(
      context: context,
      title: l10n.deleteCategory,
      message: l10n.confirmDeleteCategory(cat.name),
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<CategoryCubit>().deleteCategory(cat);
    }
  }
}
