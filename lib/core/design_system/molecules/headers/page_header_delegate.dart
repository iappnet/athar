import 'dart:ui';

import 'package:athar/core/design_system/tokens/athar_spacing.dart';
import 'package:athar/core/design_system/tokens/athar_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MinimalHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String dateStr;
  final String quote;
  final Widget? trailing;

  MinimalHeaderDelegate({
    required this.dateStr,
    required this.quote,
    this.trailing,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final dateFontSize = lerpDouble(12.sp, 11.sp, progress) ?? 11.sp;
    final quoteFontSize = lerpDouble(18.sp, 15.sp, progress) ?? 15.sp;
    final spacing = lerpDouble(AtharSpacing.sm, 4.0, progress) ?? 4;
    final quoteOpacity = lerpDouble(0.82, 0.55, progress) ?? 0.55;

    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.symmetric(
        horizontal: AtharSpacing.xl,
        vertical: 10.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: dateFontSize,
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Calibri',
                    fontFamilyFallback: AtharTypography.fontFallback,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ...(trailing == null ? const <Widget>[] : <Widget>[trailing!]),
            ],
          ),
          SizedBox(height: spacing),
          Text(
            quote,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: quoteFontSize,
              fontWeight: FontWeight.w700,
              fontFamily: 'Amiri',
              color: colorScheme.onSurface.withValues(alpha: quoteOpacity),
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 118.h;

  @override
  double get minExtent => 72.h;

  @override
  bool shouldRebuild(covariant MinimalHeaderDelegate oldDelegate) {
    return oldDelegate.quote != quote ||
        oldDelegate.dateStr != dateStr ||
        oldDelegate.trailing != trailing;
  }
}
