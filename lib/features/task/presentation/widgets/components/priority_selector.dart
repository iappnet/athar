import 'package:flutter/material.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

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
          color: context.colors.warning,
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
      shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusXl),
    );
  }
}
