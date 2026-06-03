import 'dart:async';

import 'package:athar/core/design_system/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../core/di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../settings/data/models/user_settings.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../settings/presentation/cubit/settings_state.dart';
import '../cubit/focus_cubit.dart' hide Ticker;
import '../cubit/focus_state.dart';
import '../widgets/oil_background.dart';

// Entry point — replaces FocusPage.
class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key, this.focusTarget});

  final String? focusTarget;

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  // Captured on first FocusRunning tick — used to compute fill fraction.
  int _sessionTotalSeconds = 0;

  StreamSubscription<GyroscopeEvent>? _gyroSub;
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startGyro();
  }

  void _startGyro() {
    final settings = _currentSettings();
    // DEV7: stream not started when disabled or reduceMotion — tilt stays 0.
    if (settings?.disableGyroscope == true) return;
    if (settings?.reduceMotion == true) return;
    // Integrate angular velocity (rad/s × ~16ms dt) into accumulated angle.
    try {
      _gyroSub = gyroscopeEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen((e) {
        if (!mounted) return;
        setState(() {
          _tiltX = (_tiltX + e.x * 0.016).clamp(-30.0, 30.0);
          _tiltY = (_tiltY + e.y * 0.016).clamp(-20.0, 20.0);
        });
      });
    } catch (_) {
      // Simulator or unsupported device — tilt stays 0.
    }
  }

  UserSettings? _currentSettings() {
    try {
      final state = context.read<SettingsCubit>().state;
      if (state is SettingsLoaded) return state.settings;
    } catch (_) {}
    return null;
  }

  @override
  void dispose() {
    _gyroSub?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  double _fillFraction(FocusState state) {
    if (_sessionTotalSeconds == 0) return 0.0;
    final elapsed = _sessionTotalSeconds - state.duration;
    return (elapsed / _sessionTotalSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<FocusCubit>();
        if (widget.focusTarget != null) cubit.setTask(widget.focusTarget);
        return cubit;
      },
      child: Builder(
        builder: (ctx) {
          return BlocListener<FocusCubit, FocusState>(
            listener: (context, state) {
              if (state is FocusRunning && _sessionTotalSeconds == 0) {
                setState(() {
                  _sessionTotalSeconds = ctx.read<FocusCubit>().sessionDuration;
                });
              }
              if (state is FocusInitial || state is FocusCompleted) {
                setState(() => _sessionTotalSeconds = 0);
              }
            },
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                final settings = settingsState is SettingsLoaded
                    ? settingsState.settings
                    : null;
                final bool reduceMotion = (settings?.reduceMotion ?? false) ||
                    MediaQuery.disableAnimationsOf(context);
                final bool disableGyro = settings?.disableGyroscope ?? false;
                final FocusIntensity intensity =
                    settings?.focusIntensity ?? FocusIntensity.standard;

                return BlocBuilder<FocusCubit, FocusState>(
                  builder: (context, state) {
                    final bool isRunning = state is FocusRunning;
                    final bool isCompleted = state is FocusCompleted;
                    final double fill = _fillFraction(state);

                    return Scaffold(
                      backgroundColor: const Color(0xFF050709),
                      extendBodyBehindAppBar: true,
                      body: Stack(
                        children: [
                          // ── Oil background ─────────────────────────────────
                          Positioned.fill(
                            child: OilBackground(
                              fillFraction: fill,
                              isRunning: isRunning,
                              isCompleted: isCompleted,
                              intensity: intensity,
                              reduceMotion: reduceMotion,
                              disableGyroscope: disableGyro,
                              // DEV7: 0.0/0.0 when gyro or motion disabled.
                              tiltX: (disableGyro || reduceMotion) ? 0.0 : _tiltX,
                              tiltY: (disableGyro || reduceMotion) ? 0.0 : _tiltY,
                            ),
                          ),

                          // ── Dynamic Island halo (OQ2) ─────────────────────
                          // Shows in ALL states. Drip + oil mass only when running.
                          _IslandHalo(isRunning: isRunning),

                          // ── Bottom scrim for controls contrast (OQ6) ──────
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: 120,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0x59000000), // rgba(0,0,0,0.35)
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ── UI overlay ────────────────────────────────────
                          SafeArea(
                            child: Column(
                              children: [
                                _TopBar(ctx: ctx),
                                const Spacer(),
                                if (widget.focusTarget != null)
                                  _FocusTargetBadge(
                                      target: widget.focusTarget!),
                                _DurationChips(cubit: ctx.read<FocusCubit>()),
                                AtharGap.xl,
                                _TimerDisplay(state: state),
                                const Spacer(),
                                _Controls(
                                  ctx: ctx,
                                  state: state,
                                ),
                                AtharGap.huge,
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dynamic Island halo (OQ2)
// ─────────────────────────────────────────────────────────────────────────────

class _IslandHalo extends StatelessWidget {
  const _IslandHalo({required this.isRunning});

  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    final bool hasIsland = MediaQuery.paddingOf(context).top >= 51;
    if (!hasIsland) return const SizedBox.shrink();

    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 126,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AtharRadii.xl),
            border: Border.all(
              color: const Color(0x1EFFFFFF), // rgba(255,255,255,0.12)
              width: 1.5,
            ),
            // subtle inner glow when running
            boxShadow: isRunning
                ? [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.04),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.ctx});

  final BuildContext ctx;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () {
              final state = ctx.read<FocusCubit>().state;
              if (state is FocusRunning || state is FocusPaused) {
                _showExitDialog(ctx, l10n);
              } else {
                Navigator.pop(ctx);
              }
            },
          ),
          _GlassButton(
            icon: Icons.tune_rounded,
            onTap: () => _showDurationSheet(ctx, l10n),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: const Color(0xFF0d141a),
        title: Text(l10n.focusExitDialogTitle,
            style: const TextStyle(color: Colors.white)),
        content: Text(l10n.focusExitDialogBody,
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: Text(l10n.focusExitDialogContinue),
          ),
          TextButton(
            onPressed: () {
              context.read<FocusCubit>().resetTimer();
              Navigator.pop(dlgCtx);
              Navigator.pop(context);
            },
            child: Text(l10n.focusExitDialogEnd,
                style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showDurationSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0d141a),
      shape: const RoundedRectangleBorder(
        borderRadius: AtharRadii.bottomSheet,
      ),
      builder: (_) {
        const presets = [
          ('15 د', 'short'),
          ('25 د', 'pomodoro'),
          ('45 د', 'long'),
          ('60 د', 'hour'),
        ];
        return Padding(
          padding: EdgeInsetsDirectional.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.focusDurationSheetTitle,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold)),
              AtharGap.lg,
              Wrap(
                spacing: 12.w,
                children: presets.map((p) {
                  return GestureDetector(
                    onTap: () {
                      context.read<FocusCubit>().setDuration(p.$2);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0x30FFFFFF).withValues(alpha: 0.08),
                        borderRadius: AtharRadii.radiusXl,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18)),
                      ),
                      child: Text(p.$1,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 15)),
                    ),
                  );
                }).toList(),
              ),
              AtharGap.xl,
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glass icon button with highlight ring (OQ6 — 1.5pt rgba(255,255,255,0.18))
// ─────────────────────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: AtharRadii.radiusLg,
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.18), width: 1.5),
        ),
        child: Icon(icon,
            color: Colors.white.withValues(alpha: 0.75), size: 21.sp),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Focus target badge
// ─────────────────────────────────────────────────────────────────────────────

class _FocusTargetBadge extends StatelessWidget {
  const _FocusTargetBadge({required this.target});

  final String target;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(bottom: 16.h),
      child: Container(
        padding:
            EdgeInsetsDirectional.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: AtharRadii.radiusXxl,
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Text(
          target,
          style: AtharTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Duration chips (idle only)
// ─────────────────────────────────────────────────────────────────────────────

class _DurationChips extends StatelessWidget {
  const _DurationChips({required this.cubit});

  final FocusCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusCubit, FocusState>(
      builder: (context, state) {
        if (state is! FocusInitial) return const SizedBox.shrink();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chip(context, '15 د', 15),
            AtharGap.hMd,
            _chip(context, '25 د', 25),
            AtharGap.hMd,
            _chip(context, '45 د', 45),
            AtharGap.hMd,
            _chip(context, '60 د', 60),
          ],
        );
      },
    );
  }

  Widget _chip(BuildContext context, String label, int minutes) {
    final bool selected = cubit.currentDurationMinutes == minutes;
    final Map<int, String> presetMap = {
      15: 'short',
      25: 'pomodoro',
      45: 'long',
      60: 'hour',
    };
    return GestureDetector(
      onTap: () => context.read<FocusCubit>().setDuration(presetMap[minutes]!),
      child: Container(
        padding:
            EdgeInsetsDirectional.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: AtharRadii.radiusXl,
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.14),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white60,
            fontSize: 13.sp,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timer display — numericMono, 70sp, spec §7 colours
// ─────────────────────────────────────────────────────────────────────────────

class _TimerDisplay extends StatelessWidget {
  const _TimerDisplay({required this.state});

  final FocusState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final int mins = state.duration ~/ 60;
    final int secs = state.duration % 60;
    final String timeStr =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    final String statusLabel = switch (state) {
      FocusRunning() => l10n.focusStatusRunning,
      FocusPaused() => l10n.focusStatusPaused,
      FocusCompleted() => l10n.focusStatusCompleted,
      _ => l10n.focusStatusReady,
    };

    final Color statusColor = switch (state) {
      FocusRunning() => Colors.white70,
      FocusPaused() => Colors.white54,
      FocusCompleted() => const Color(0xFF66BB6A),
      _ => Colors.white38,
    };

    return Column(
      children: [
        // Glass card
        Container(
          padding:
              EdgeInsetsDirectional.symmetric(horizontal: 36.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: AtharRadii.radiusXxxl,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: Text(
            timeStr,
            style: AtharTypography.numericMono.copyWith(
              fontSize: 70.sp,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        AtharGap.md,
        Text(
          statusLabel,
          style: TextStyle(
            fontSize: 14.sp,
            color: statusColor,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Controls
// ─────────────────────────────────────────────────────────────────────────────

class _Controls extends StatelessWidget {
  const _Controls({required this.ctx, required this.state});

  final BuildContext ctx;
  final FocusState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state is FocusRunning) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CtrlBtn(
            icon: Icons.pause_rounded,
            label: l10n.focusPause,
            color: Colors.white70,
            onTap: () => context.read<FocusCubit>().pauseTimer(),
          ),
          AtharGap.hXxl,
          _CtrlBtn(
            icon: Icons.stop_rounded,
            label: l10n.focusStop,
            color: Colors.redAccent,
            onTap: () => context.read<FocusCubit>().resetTimer(),
          ),
        ],
      );
    }
    if (state is FocusPaused) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CtrlBtn(
            icon: Icons.play_arrow_rounded,
            label: l10n.focusResume,
            color: Colors.white,
            large: true,
            onTap: () => context.read<FocusCubit>().resumeTimer(),
          ),
          AtharGap.hXxl,
          _CtrlBtn(
            icon: Icons.refresh_rounded,
            label: l10n.focusReset,
            color: Colors.white54,
            onTap: () => context.read<FocusCubit>().resetTimer(),
          ),
        ],
      );
    }
    if (state is FocusCompleted) {
      return _CtrlBtn(
        icon: Icons.replay_rounded,
        label: l10n.focusNewSession,
        color: Colors.white,
        large: true,
        onTap: () => context.read<FocusCubit>().resetTimer(),
      );
    }
    // FocusInitial — start button
    return GestureDetector(
      onTap: () => context.read<FocusCubit>().startTimer(),
      child: Container(
        width: 88.w,
        height: 88.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          shape: BoxShape.circle,
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.28), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.06),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(Icons.play_arrow_rounded,
            color: Colors.white, size: 44.sp),
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  const _CtrlBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.large = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final double sz = large ? 72.w : 60.w;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: sz,
            height: sz,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                  color: color.withValues(alpha: 0.28), width: 1.5),
            ),
            child: Icon(icon,
                color: color, size: large ? 32.sp : 26.sp),
          ),
        ),
        AtharGap.sm,
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: color.withValues(alpha: 0.80),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
