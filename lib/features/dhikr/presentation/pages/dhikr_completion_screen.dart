import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';

class DhikrCompletionScreen extends StatelessWidget {
  final int completedCount;
  final Duration duration;

  const DhikrCompletionScreen({
    super.key,
    required this.completedCount,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final mins = (duration.inSeconds / 60).ceil().clamp(1, 99);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88.w,
                  height: 88.w,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 48.sp,
                    color: colorScheme.primary,
                  ),
                ),
                AtharGap.xl,
                Text(
                  l10n.athkarCompletionTitle,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Calibri',
                    fontFamilyFallback: AtharTypography.fontFallback,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                AtharGap.md,
                Text(
                  l10n.athkarCompletionCountAndTime(completedCount, mins),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: colorScheme.onSurfaceVariant,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                  textAlign: TextAlign.center,
                ),
                AtharGap.xxxl,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: AtharRadii.radiusMd,
                      ),
                    ),
                    child: Text(
                      l10n.close,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
