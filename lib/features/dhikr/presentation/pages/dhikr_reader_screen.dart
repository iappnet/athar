import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:athar/core/design_system/tokens.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:athar/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:athar/features/settings/presentation/cubit/settings_state.dart';
import 'package:athar/features/settings/data/models/user_settings.dart';
import '../../../dhikr/data/models/dhikr_model.dart';
import '../cubit/dhikr_cubit.dart';
import 'dhikr_completion_screen.dart';

class DhikrReaderScreen extends StatelessWidget {
  final DhikrCategory category;

  const DhikrReaderScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DhikrCubit, DhikrState>(
      listener: (context, state) {
        if (state is DhikrComplete) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => DhikrCompletionScreen(
                completedCount: state.completedCount,
                duration: state.duration,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DhikrLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is DhikrError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        if (state is DhikrLoaded) {
          final settingsState = context.watch<SettingsCubit>().state;
          final isFocusMode = settingsState is SettingsLoaded &&
              settingsState.settings.athkarSessionViewMode ==
                  AthkarSessionViewMode.focus;

          return isFocusMode
              ? _FocusReader(state: state)
              : _ListReader(state: state);
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

// ─── Focus mode: one dhikr at a time, 120pt counter ────────────────────────

class _FocusReader extends StatefulWidget {
  final DhikrLoaded state;
  const _FocusReader({required this.state});

  @override
  State<_FocusReader> createState() => _FocusReaderState();
}

class _FocusReaderState extends State<_FocusReader> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.state.currentIndex);
  }

  @override
  void didUpdateWidget(_FocusReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.currentIndex != widget.state.currentIndex &&
        _controller.hasClients) {
      _controller.animateToPage(
        widget.state.currentIndex,
        duration: AtharAnimations.normal,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          '${state.currentIndex + 1} / ${state.athkar.length}',
          style: TextStyle(
            fontSize: 14.sp,
            fontFeatures: [const FontFeature.tabularFigures()],
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.athkarResetTooltip,
            onPressed: () => context.read<DhikrCubit>().reset(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AtharSpacing.lg),
            child: ClipRRect(
              borderRadius: AtharRadii.radiusXxs,
              child: LinearProgressIndicator(
                value: state.progress,
                minHeight: 4.h,
                backgroundColor: colorScheme.outlineVariant,
                valueColor:
                    AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ),
          AtharGap.sm,
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (isRtl) {
                  if (v > 200) context.read<DhikrCubit>().nextDhikr();
                  if (v < -200) context.read<DhikrCubit>().previousDhikr();
                } else {
                  if (v > 200) context.read<DhikrCubit>().previousDhikr();
                  if (v < -200) context.read<DhikrCubit>().nextDhikr();
                }
              },
              child: PageView.builder(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.athkar.length,
                itemBuilder: (_, i) => _DhikrFocusCard(dhikr: state.athkar[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DhikrFocusCard extends StatelessWidget {
  final DhikrModel dhikr;
  const _DhikrFocusCard({required this.dhikr});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final remaining = dhikr.count - dhikr.currentCount;
    final isDone = dhikr.currentCount >= dhikr.count;
    final progress =
        dhikr.count > 0 ? dhikr.currentCount / dhikr.count : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  dhikr.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Calibri',
                    fontFamilyFallback: AtharTypography.fontFallback,
                    height: 1.7,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
          AtharGap.xxxl,
          GestureDetector(
            onTap: isDone
                ? null
                : () => context.read<DhikrCubit>().incrementCount(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120.w,
                  height: 120.w,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8.w,
                    backgroundColor: colorScheme.outlineVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? AppColors.success : colorScheme.primary,
                    ),
                  ),
                ),
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: isDone ? AppColors.success : colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isDone ? AppColors.success : colorScheme.primary)
                                .withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isDone
                        ? Icon(Icons.check_rounded,
                            color: Colors.white, size: 40.sp)
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$remaining',
                              style: TextStyle(
                                fontSize: 56.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily:
                                    AtharTypography.numericMono.fontFamily,
                                fontFamilyFallback: AtharTypography
                                    .numericMono.fontFamilyFallback,
                                fontFeatures: [
                                  const FontFeature.tabularFigures()
                                ],
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          AtharGap.xs,
          if (!isDone)
            Text(
              '× ${dhikr.count}',
              style: TextStyle(
                fontSize: 13.sp,
                color: colorScheme.onSurfaceVariant,
                fontFamily: AtharTypography.numericMono.fontFamily,
                fontFamilyFallback:
                    AtharTypography.numericMono.fontFamilyFallback,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
            ),
          AtharGap.sm,
          Text(
            isDone ? l10n.athkarWellDone : l10n.athkarTapToCount,
            style: TextStyle(
                fontSize: 14.sp, color: colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}

// ─── List mode: scrollable list ─────────────────────────────────────────────

class _ListReader extends StatelessWidget {
  final DhikrLoaded state;
  const _ListReader({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final progress = state.progress;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.athkarResetTooltip,
            onPressed: () => context.read<DhikrCubit>().reset(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AtharSpacing.lg, vertical: AtharSpacing.xs),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: AtharRadii.radiusXxs,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6.h,
                    backgroundColor: colorScheme.outlineVariant,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                ),
                AtharGap.xs,
                Text(
                  l10n.athkarProgressPercent(
                      (progress * 100).toInt().toString()),
                  style: TextStyle(
                      fontSize: 11.sp, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(AtharSpacing.lg),
              itemCount: state.athkar.length,
              itemBuilder: (context, i) {
                final dhikr = state.athkar[i];
                final isDone = dhikr.currentCount >= dhikr.count;
                return GestureDetector(
                  onTap: isDone
                      ? null
                      : () => context.read<DhikrCubit>().incrementCount(),
                  child: AnimatedContainer(
                    duration: AtharAnimations.fast,
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: isDone
                          ? AppColors.success.withValues(alpha: 0.08)
                          : colorScheme.surfaceContainerLow,
                      borderRadius: AtharRadii.radiusMd,
                      border: Border.all(
                        color: isDone
                            ? Colors.transparent
                            : colorScheme.primary.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          dhikr.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Calibri',
                            fontFamilyFallback: AtharTypography.fontFallback,
                            height: 1.6,
                            color: isDone
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurface,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        AtharGap.md,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? AppColors.success
                                    : colorScheme.primary,
                                borderRadius: AtharRadii.radiusXl,
                              ),
                              child: Text(
                                isDone
                                    ? l10n.achievementDone
                                    : '${dhikr.currentCount} / ${dhikr.count}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: [
                                    const FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!isDone)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              l10n.athkarTapToCount,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
