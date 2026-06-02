import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/design_system/tokens/athar_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FilterBar<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final Function(T) onSelected;
  final String Function(T) labelBuilder;
  final IconData? Function(T)? iconBuilder;
  final Color? Function(T)? colorBuilder;

  const FilterBar({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
    required this.labelBuilder,
    this.iconBuilder,
    this.colorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((filter) {
          final isSelected = filter == selectedItem;

          IconData? icon;
          if (iconBuilder != null) {
            icon = iconBuilder!(filter);
          }

          Color? customColor;
          if (colorBuilder != null) {
            customColor = colorBuilder!(filter);
          }

          return Padding(
            padding: EdgeInsetsDirectional.only(start: AtharSpacing.sm),
            child: ChoiceChip(
              avatar: icon != null
                  ? Icon(
                      icon,
                      size: 18.sp,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : (customColor ?? colorScheme.outline),
                    )
                  : null,
              label: Text(labelBuilder(filter)),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) onSelected(filter);
              },
              selectedColor: customColor ?? colorScheme.primary,
              backgroundColor: colorScheme.surface,
              labelStyle: TextStyle(
                fontSize: 12.sp,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Calibri',
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
              side: isSelected
                  ? BorderSide.none
                  : BorderSide(color: colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusXl),
              padding: EdgeInsets.symmetric(
                horizontal: AtharSpacing.xxs,
                vertical: AtharSpacing.xxxs,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
