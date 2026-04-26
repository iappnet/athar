import 'package:athar/core/di/injection.dart';
import 'package:athar/features/sync/presentation/cubit/sync_cubit.dart';
import 'package:athar/features/sync/presentation/cubit/sync_state.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SyncPage extends StatelessWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (_) => getIt<SyncCubit>(),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(l10n.sync),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<SyncCubit, SyncState>(
          builder: (context, state) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIcon(state, colorScheme),
                    AtharGap.xxl,
                    Text(
                      _getTitle(state, l10n),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AtharGap.sm,
                    if (state is SyncError)
                      Text(
                        state.message,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    AtharGap.huge,
                    if (state is! SyncLoading)
                      FilledButton.icon(
                        onPressed: () => context
                            .read<SyncCubit>()
                            .triggerSync(isManual: true),
                        icon: const Icon(Icons.sync_rounded),
                        label: Text(l10n.sync),
                        style: FilledButton.styleFrom(
                          minimumSize: Size(200.w, 48.h),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIcon(SyncState state, ColorScheme colorScheme) {
    if (state is SyncLoading) {
      return SizedBox(
        width: 64.w,
        height: 64.w,
        child: CircularProgressIndicator(
            strokeWidth: 3, color: colorScheme.primary),
      );
    }
    if (state is SyncSuccess) {
      return Icon(Icons.check_circle_rounded,
          size: 64.sp, color: Colors.green);
    }
    if (state is SyncError) {
      return Icon(Icons.cloud_off_rounded,
          size: 64.sp, color: colorScheme.error);
    }
    return Icon(Icons.cloud_sync_outlined,
        size: 64.sp, color: colorScheme.primary);
  }

  String _getTitle(SyncState state, AppLocalizations l10n) {
    if (state is SyncLoading) return l10n.syncing;
    if (state is SyncSuccess) return l10n.syncSuccessful;
    if (state is SyncError) return l10n.syncAndData;
    return l10n.syncAndData;
  }
}
