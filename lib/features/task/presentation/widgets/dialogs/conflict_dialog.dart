import 'package:athar/features/task/domain/models/conflict_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class ConflictDialog extends StatelessWidget {
  final ConflictResult conflict;
  final VoidCallback onDelay;
  final VoidCallback onForceSave;
  final VoidCallback onCancel;

  const ConflictDialog({
    super.key,
    required this.conflict,
    required this.onDelay,
    required this.onForceSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);
    final newTimeFormatted = conflict.suggestedTime != null
        ? DateFormat('h:mm a', 'ar').format(conflict.suggestedTime!)
        : "";

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusLg),
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: AtharSpacing.allXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AtharSpacing.allMd,
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: colors.warning,
                size: 32,
              ),
            ),
            AtharGap.lg,
            Text(
              l10n.conflictWarningTitle,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: AtharTypography.fontFamily, fontFamilyFallback: AtharTypography.fontFallback),
            ),
            AtharGap.sm,
            Text(
              conflict.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
                fontFamily: AtharTypography.fontFamily,
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
            ),
            AtharGap.xl,

            if (conflict.suggestedTime != null) ...[
              _buildButton(
                context: context,
                icon: Icons.access_time_filled_rounded,
                bg: colorScheme.primary,
                textC: colorScheme.onPrimary,
                title: l10n.delayAfterFinish,
                sub: l10n.moveTimeTo(newTimeFormatted),
                onTap: onDelay,
              ),
              AtharGap.md,
            ],

            _buildButton(
              context: context,
              icon: Icons.check_circle_outline_rounded,
              bg: colorScheme.surfaceContainer,
              textC: colorScheme.onSurface,
              title: l10n.saveAnyway,
              sub: l10n.keepTimeAsIs,
              onTap: onForceSave,
            ),

            AtharGap.md,
            TextButton(
              onPressed: onCancel,
              child: Text(
                l10n.cancelAndEditManually,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13.sp,
                  fontFamily: AtharTypography.fontFamily,
                  fontFamilyFallback: AtharTypography.fontFallback,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required IconData icon,
    required Color bg,
    required Color textC,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AtharRadii.radiusMd,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(color: bg, borderRadius: AtharRadii.radiusMd),
        child: Row(
          children: [
            Icon(icon, color: textC, size: 22.sp),
            AtharGap.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textC,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      fontFamily: AtharTypography.fontFamily,
                      fontFamilyFallback: AtharTypography.fontFallback,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      color: textC.withValues(alpha: 0.8),
                      fontSize: 11.sp,
                      fontFamily: AtharTypography.fontFamily,
                      fontFamilyFallback: AtharTypography.fontFallback,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textC.withValues(alpha: 0.5),
              size: 14.sp,
            ),
          ],
        ),
      ),
    );
  }
}
