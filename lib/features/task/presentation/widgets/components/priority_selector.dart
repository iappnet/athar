import 'package:flutter/material.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

/// Semantic colors (not in ColorScheme)
const _warningColor = Color(0xFFFDCB6E);

class PrioritySelector extends StatelessWidget {
  final bool isUrgent;
  final bool isImportant;
  final Function(bool) onUrgentChanged;
  final Function(bool) onImportantChanged;

  const PrioritySelector({
    super.key,
    required this.isUrgent,
    required this.isImportant,
    required this.onUrgentChanged,
    required this.onImportantChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        _buildChip(
          context: context,
          label: l10n.urgentFire,
          isSelected: isUrgent,
          color: colorScheme.error,
          onSelected: onUrgentChanged,
        ),
        AtharGap.hSm,
        _buildChip(
          context: context,
          label: l10n.importantStar,
          isSelected: isImportant,
          color: _warningColor,
          onSelected: onImportantChanged,
        ),
      ],
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Color color,
    required Function(bool) onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      onSelected: onSelected,
      backgroundColor: colorScheme.surfaceContainerLowest,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class PrioritySelector extends StatelessWidget {
//   final bool isUrgent;
//   final bool isImportant;
//   final Function(bool) onUrgentChanged;
//   final Function(bool) onImportantChanged;

//   const PrioritySelector({
//     super.key,
//     required this.isUrgent,
//     required this.isImportant,
//     required this.onUrgentChanged,
//     required this.onImportantChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         _buildChip("عاجل 🔥", isUrgent, AppColors.urgent, onUrgentChanged),
//         SizedBox(width: 8.w),
//         _buildChip("مهم ⭐", isImportant, AppColors.warning, onImportantChanged),
//       ],
//     );
//   }

//   Widget _buildChip(
//     String label,
//     bool isSelected,
//     Color color,
//     Function(bool) onSelected,
//   ) {
//     return FilterChip(
//       label: Text(label),
//       selected: isSelected,
//       selectedColor: color.withValues(alpha: 0.2),
//       checkmarkColor: color,
//       onSelected: onSelected,
//       backgroundColor: AppColors.background,
//       side: BorderSide.none,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//     );
//   }
// }
