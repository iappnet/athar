import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class DeleteAccountDialog extends StatelessWidget {
  final Function(bool deleteLocal) onConfirm;

  const DeleteAccountDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusLg),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.error,
            size: 28.sp,
          ),
          AtharGap.hSm,
          Text(
            l10n.deleteAccount,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.deleteAccountConfirmMessage,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: colorScheme.onSurface,
            ),
          ),
          AtharGap.xl,

          // الخيار الأول: حذف كل شيء
          _buildOption(
            context,
            title: l10n.deleteEverything,
            subtitle: l10n.deleteEverythingDesc,
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              onConfirm(true);
            },
          ),
          AtharGap.md,

          // الخيار الثاني: الاحتفاظ بالمحلي
          _buildOption(
            context,
            title: l10n.keepLocalData,
            subtitle: l10n.keepLocalDataDesc,
            isDestructive: false,
            onTap: () {
              Navigator.pop(context);
              onConfirm(false);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isDestructive,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AtharRadii.radiusMd,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive
                ? colorScheme.error.withValues(alpha: 0.3)
                : colorScheme.outline,
          ),
          borderRadius: AtharRadii.radiusMd,
          color: isDestructive
              ? colorScheme.error.withValues(alpha: 0.05)
              : colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(
              isDestructive
                  ? Icons.delete_forever_rounded
                  : Icons.save_alt_rounded,
              color: isDestructive ? colorScheme.error : colorScheme.primary,
              size: 24.sp,
            ),
            AtharGap.hMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDestructive
                          ? colorScheme.error
                          : colorScheme.onSurface,
                      fontSize: 13.sp,
                    ),
                  ),
                  AtharGap.xxs,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
