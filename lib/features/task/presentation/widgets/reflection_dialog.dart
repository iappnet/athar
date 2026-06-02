import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class ReflectionDialog extends StatefulWidget {
  final String taskTitle;
  final Function(String) onSave;

  const ReflectionDialog({
    super.key,
    required this.taskTitle,
    required this.onSave,
  });

  @override
  State<ReflectionDialog> createState() => _ReflectionDialogState();
}

class _ReflectionDialogState extends State<ReflectionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AtharRadii.radiusLg),
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: AtharSpacing.allXl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة احتفالية
            Container(
              padding: AtharSpacing.allMd,
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                color: colors.success,
                size: 32.sp,
              ),
            ),
            AtharGap.lg,

            Text(
              l10n.wellDone,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: 'Calibri', fontFamilyFallback: AtharTypography.fontFallback),
            ),
            AtharGap.sm,
            Text(
              l10n.reflectionPrompt(widget.taskTitle),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
                fontFamily: 'Calibri',
                fontFamilyFallback: AtharTypography.fontFallback,
              ),
            ),
            AtharGap.xl,

            // حقل الكتابة
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.addNoteOptionalHint,
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.outline,
                  fontFamily: 'Calibri',
                  fontFamilyFallback: AtharTypography.fontFallback,
                ),
                fillColor: colorScheme.surfaceContainerLowest,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: AtharRadii.radiusMd,
                  borderSide: BorderSide.none,
                ),
                contentPadding: AtharSpacing.allMd,
              ),
            ),
            AtharGap.xl,

            // الأزرار
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      l10n.skip,
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontFamily: 'Calibri', fontFamilyFallback: AtharTypography.fontFallback),
                    ),
                  ),
                ),
                AtharGap.hMd,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        widget.onSave(_controller.text);
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: AtharRadii.radiusMd,
                      ),
                      padding: AtharSpacing.verticalMd,
                    ),
                    child: Text(
                      l10n.save,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Calibri',
                        fontFamilyFallback: AtharTypography.fontFallback,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
