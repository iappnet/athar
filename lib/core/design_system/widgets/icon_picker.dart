// lib/core/design_system/widgets/icon_picker.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 🎨 ATHAR ICON PICKER - واجهة اختيار الأيقونات
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/utils/icon_registry.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class AtharIconPicker extends StatefulWidget {
  final String? selectedIconKey;
  final ValueChanged<String> onIconSelected;
  final Color? selectedColor;

  const AtharIconPicker({
    super.key,
    this.selectedIconKey,
    required this.onIconSelected,
    this.selectedColor,
  });

  @override
  State<AtharIconPicker> createState() => _AtharIconPickerState();

  /// ✅ عرض كـ Bottom Sheet
  static Future<String?> show(
    BuildContext context, {
    String? selectedIconKey,
    Color? selectedColor,
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return _IconPickerContent(
            selectedIconKey: selectedIconKey,
            selectedColor: selectedColor,
            scrollController: scrollController,
          );
        },
      ),
    );
  }
}

class _AtharIconPickerState extends State<AtharIconPicker> {
  late String _selectedKey;

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.selectedIconKey ?? IconRegistry.defaultIconKey;
  }

  @override
  Widget build(BuildContext context) {
    final icons = IconRegistry.iconPickerItems;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8.h,
        crossAxisSpacing: 8.w,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final item = icons[index];
        final isSelected = _selectedKey == item.key;

        return _IconItem(
          item: item,
          isSelected: isSelected,
          selectedColor: widget.selectedColor,
          onTap: () {
            setState(() => _selectedKey = item.key);
            widget.onIconSelected(item.key);
          },
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 📦 محتوى Icon Picker (للـ Bottom Sheet)
// ═══════════════════════════════════════════════════════════════════════════════

class _IconPickerContent extends StatefulWidget {
  final String? selectedIconKey;
  final Color? selectedColor;
  final ScrollController scrollController;

  const _IconPickerContent({
    this.selectedIconKey,
    this.selectedColor,
    required this.scrollController,
  });

  @override
  State<_IconPickerContent> createState() => _IconPickerContentState();
}

class _IconPickerContentState extends State<_IconPickerContent> {
  late String _selectedKey;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.selectedIconKey ?? IconRegistry.defaultIconKey;
  }

  List<IconPickerItem> get _filteredIcons {
    if (_searchQuery.isEmpty) {
      return IconRegistry.iconPickerItems;
    }
    return IconRegistry.iconPickerItems
        .where((item) => item.key.contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // ═══════════════════════════════════════════════════════════════
          // 🔘 المقبض
          // ═══════════════════════════════════════════════════════════════
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          AtharGap.md,

          // ═══════════════════════════════════════════════════════════════
          // 📝 العنوان
          // ═══════════════════════════════════════════════════════════════
          Text(
            l10n.chooseIcon,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          AtharGap.md,

          // ═══════════════════════════════════════════════════════════════
          // 🔍 البحث (اختياري)
          // ═══════════════════════════════════════════════════════════════
          TextField(
            decoration: InputDecoration(
              hintText: l10n.searchIcons,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
          AtharGap.md,

          // ═══════════════════════════════════════════════════════════════
          // 🎨 شبكة الأيقونات
          // ═══════════════════════════════════════════════════════════════
          Expanded(
            child: GridView.builder(
              controller: widget.scrollController,
              padding: EdgeInsets.only(bottom: 16.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
              ),
              itemCount: _filteredIcons.length,
              itemBuilder: (context, index) {
                final item = _filteredIcons[index];
                final isSelected = _selectedKey == item.key;

                return _IconItem(
                  item: item,
                  isSelected: isSelected,
                  selectedColor: widget.selectedColor,
                  onTap: () {
                    setState(() => _selectedKey = item.key);
                    Navigator.pop(context, item.key);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// 🔘 عنصر الأيقونة
// ═══════════════════════════════════════════════════════════════════════════════

class _IconItem extends StatelessWidget {
  final IconPickerItem item;
  final bool isSelected;
  final Color? selectedColor;
  final VoidCallback onTap;

  const _IconItem({
    required this.item,
    required this.isSelected,
    this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selectedColor ?? colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            item.icon,
            size: 24.sp,
            color: isSelected ? color : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
