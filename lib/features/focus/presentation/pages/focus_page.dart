// lib/features/focus/presentation/pages/focus_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/focus_cubit.dart' hide Ticker;
import '../cubit/focus_state.dart';
import '../widgets/oil_animation.dart';
import 'package:athar/core/design_system/tokens.dart';

class FocusPage extends StatefulWidget {
  final String? focusTarget;

  const FocusPage({super.key, this.focusTarget});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  // Total duration at session start — needed to compute fill level.
  int _sessionTotalSeconds = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  double _fillLevel(FocusState state) {
    if (_sessionTotalSeconds == 0) return 0.0;
    final elapsed = _sessionTotalSeconds - state.duration;
    return (elapsed / _sessionTotalSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) {
        final cubit = getIt<FocusCubit>();
        if (widget.focusTarget != null) cubit.setTask(widget.focusTarget);
        return cubit;
      },
      child: Builder(
        // Builder gives us a context that IS inside the BlocProvider tree.
        builder: (ctx) {
          return BlocListener<FocusCubit, FocusState>(
            listener: (context, state) {
              if (state is FocusRunning && _sessionTotalSeconds == 0) {
                _sessionTotalSeconds = state.duration;
              }
              if (state is FocusInitial || state is FocusCompleted) {
                setState(() => _sessionTotalSeconds = 0);
              }
            },
            child: Scaffold(
              backgroundColor: Colors.black,
              extendBodyBehindAppBar: true,
              body: BlocBuilder<FocusCubit, FocusState>(
                builder: (context, state) {
                  final isRunning = state is FocusRunning;
                  final fill = _fillLevel(state);

                  return Stack(
                    children: [
                      // ── Oil bottle background ────────────────────────────
                      Positioned.fill(
                        child: OilBottleAnimation(
                          fillLevel: fill,
                          isRunning: isRunning,
                        ),
                      ),

                      // ── UI overlay ───────────────────────────────────────
                      SafeArea(
                        child: Column(
                          children: [
                            _TopBar(ctx: context, l10n: l10n),
                            const Spacer(),
                            if (widget.focusTarget != null)
                              _FocusTargetBadge(target: widget.focusTarget!),
                            _DurationSelector(ctx: context),
                            AtharGap.xl,
                            _TimerDisplay(state: state),
                            const Spacer(),
                            _Controls(ctx: context, state: state, l10n: l10n),
                            AtharGap.huge,
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final BuildContext ctx;
  final AppLocalizations l10n;

  const _TopBar({required this.ctx, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () {
              final state = ctx.read<FocusCubit>().state;
              if (state is FocusRunning || state is FocusPaused) {
                _showExitDialog(ctx);
              } else {
                Navigator.pop(ctx);
              }
            },
          ),
          _GlassButton(
            icon: Icons.tune_rounded,
            onTap: () => _showDurationSheet(ctx),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1208),
        title: const Text('إنهاء الجلسة؟',
            style: TextStyle(color: Colors.white)),
        content: const Text('سيتم فقدان تقدم هذه الجلسة',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('متابعة'),
          ),
          TextButton(
            onPressed: () {
              context.read<FocusCubit>().resetTimer();
              Navigator.pop(dlgCtx);
              Navigator.pop(context);
            },
            child: const Text('إنهاء',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showDurationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF140C04),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        final presets = [
          ('15 د', 'short'),
          ('25 د', 'pomodoro'),
          ('45 د', 'long'),
          ('60 د', 'hour'),
        ];
        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اختر مدة الجلسة',
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0x30C46A00),
                        borderRadius: AtharRadii.radiusXl,
                        border: Border.all(
                            color: const Color(0x60C46A00)),
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
// Glass icon button
// ─────────────────────────────────────────────────────────────────────────────

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({required this.icon, required this.onTap});

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
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
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
  final String target;
  const _FocusTargetBadge({required this.target});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0x25C46A00),
          borderRadius: AtharRadii.radiusXxl,
          border: Border.all(color: const Color(0x40C46A00)),
        ),
        child: Text(
          target,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Duration selector chips (shown when idle)
// ─────────────────────────────────────────────────────────────────────────────

class _DurationSelector extends StatelessWidget {
  final BuildContext ctx;
  const _DurationSelector({required this.ctx});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusCubit, FocusState>(
      builder: (context, state) {
        if (state is! FocusInitial) return const SizedBox.shrink();
        final cubit = context.read<FocusCubit>();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chip('15 د', 15, cubit, context),
            AtharGap.hMd,
            _chip('25 د', 25, cubit, context),
            AtharGap.hMd,
            _chip('45 د', 45, cubit, context),
            AtharGap.hMd,
            _chip('60 د', 60, cubit, context),
          ],
        );
      },
    );
  }

  Widget _chip(String label, int minutes, FocusCubit cubit,
      BuildContext context) {
    final selected = cubit.currentDurationMinutes == minutes;
    return GestureDetector(
      onTap: () {
        final preset = {15: 'short', 25: 'pomodoro', 45: 'long', 60: 'hour'}[minutes]!;
        cubit.setDuration(preset);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0x40C46A00)
              : Colors.white.withValues(alpha: 0.07),
          borderRadius: AtharRadii.radiusXl,
          border: Border.all(
            color: selected
                ? const Color(0xA0C46A00)
                : Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFFD4820A) : Colors.white60,
            fontSize: 13.sp,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timer display
// ─────────────────────────────────────────────────────────────────────────────

class _TimerDisplay extends StatelessWidget {
  final FocusState state;
  const _TimerDisplay({required this.state});

  @override
  Widget build(BuildContext context) {
    final minutes = state.duration ~/ 60;
    final seconds = state.duration % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final statusColor = state is FocusRunning
        ? const Color(0xFFD4820A)
        : state is FocusPaused
            ? Colors.amber
            : state is FocusCompleted
                ? Colors.greenAccent
                : Colors.white54;

    final statusLabel = state is FocusRunning
        ? 'تدفق الزيت...'
        : state is FocusPaused
            ? 'متوقف مؤقتاً'
            : state is FocusCompleted
                ? 'اكتملت الجلسة ✓'
                : 'جاهز للبدء';

    return Column(
      children: [
        // Time counter glass card
        Container(
          padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            borderRadius: AtharRadii.radiusXxxl,
            border: Border.all(
                color: const Color(0x50C46A00), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B4500).withValues(alpha: 0.25),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Text(
            timeStr,
            style: TextStyle(
              fontSize: 70.sp,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
              letterSpacing: -1,
              shadows: [
                Shadow(
                  color: const Color(0xFFC46A00).withValues(alpha: 0.6),
                  blurRadius: 18,
                ),
              ],
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
            fontWeight: FontWeight.w500,
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
  final BuildContext ctx;
  final FocusState state;
  final AppLocalizations l10n;

  const _Controls(
      {required this.ctx, required this.state, required this.l10n});

  @override
  Widget build(BuildContext context) {
    if (state is FocusRunning) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CtrlBtn(
            icon: Icons.pause_rounded,
            label: l10n.focusPause,
            color: Colors.amber,
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
            color: const Color(0xFFD4820A),
            large: true,
            onTap: () => context.read<FocusCubit>().resumeTimer(),
          ),
          AtharGap.hXxl,
          _CtrlBtn(
            icon: Icons.refresh_rounded,
            label: l10n.focusReset,
            color: Colors.grey,
            onTap: () => context.read<FocusCubit>().resetTimer(),
          ),
        ],
      );
    }
    if (state is FocusCompleted) {
      return _CtrlBtn(
        icon: Icons.replay_rounded,
        label: 'جلسة جديدة',
        color: const Color(0xFFD4820A),
        large: true,
        onTap: () => context.read<FocusCubit>().resetTimer(),
      );
    }
    // FocusInitial — big start button
    return GestureDetector(
      onTap: () => context.read<FocusCubit>().startTimer(),
      child: Container(
        width: 88.w,
        height: 88.w,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD4820A), Color(0xFF8B4500)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4820A).withValues(alpha: 0.45),
              blurRadius: 28,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 44.sp),
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool large;

  const _CtrlBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final sz = large ? 72.w : 60.w;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: sz,
            height: sz,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                  color: color.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: large ? 32.sp : 26.sp),
          ),
        ),
        AtharGap.sm,
        Text(label,
            style: TextStyle(
                fontSize: 12.sp,
                color: color.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
