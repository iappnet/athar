import 'package:athar/features/subscription/domain/entities/subscription_status.dart';
import 'package:athar/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Wraps [child] and shows a locked screen when the user lacks the required
/// entitlement.
///
/// [hasAccess] is a selector run against the current [SubscriptionStatus].
/// [onUpgrade] is called when the user taps "اشترك" — defaults to showing the
/// RevenueCat paywall for [entitlementId].
///
/// Examples:
/// ```dart
/// // Shared spaces
/// ProGateWidget(
///   hasAccess: (s) => s.hasSpacesPro,
///   entitlementId: SubscriptionConfig.entitlementSpacesPro,
///   featureName: 'المساحات التعاونية',
///   featureIcon: Icons.group_work_rounded,
///   child: SpacesPage(),
/// )
///
/// // Health module
/// ProGateWidget(
///   hasAccess: (s) => s.hasHealthPack,
///   entitlementId: SubscriptionConfig.entitlementHealthPack,
///   featureName: 'وحدة الصحة',
///   featureIcon: Icons.favorite_rounded,
///   child: HealthDashboardPage(...),
/// )
/// ```
class ProGateWidget extends StatelessWidget {
  const ProGateWidget({
    super.key,
    required this.child,
    required this.hasAccess,
    required this.entitlementId,
    required this.featureName,
    required this.featureIcon,
    this.featureDescription,
  });

  final Widget child;
  final bool Function(SubscriptionStatus) hasAccess;
  final String entitlementId;
  final String featureName;
  final IconData featureIcon;
  final String? featureDescription;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionCubit, SubscriptionState>(
      buildWhen: (prev, curr) {
        // Only rebuild when access changes.
        final prevAccess = prev is SubscriptionLoaded && hasAccess(prev.status);
        final currAccess = curr is SubscriptionLoaded && hasAccess(curr.status);
        return prevAccess != currAccess ||
            (prev is! SubscriptionLoaded && curr is SubscriptionLoaded);
      },
      builder: (context, state) {
        final granted =
            state is SubscriptionLoaded && hasAccess(state.status);
        if (granted) return child;
        return _LockedScreen(
          featureName: featureName,
          featureIcon: featureIcon,
          featureDescription: featureDescription,
          entitlementId: entitlementId,
        );
      },
    );
  }
}

class _LockedScreen extends StatelessWidget {
  const _LockedScreen({
    required this.featureName,
    required this.featureIcon,
    required this.entitlementId,
    this.featureDescription,
  });

  final String featureName;
  final IconData featureIcon;
  final String? featureDescription;
  final String entitlementId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96.r,
                height: 96.r,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  featureIcon,
                  size: 48.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                featureName,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                featureDescription ??
                    'هذه الميزة تحتاج إلى اشتراك أو شراء منفصل',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              FilledButton.icon(
                onPressed: () => context
                    .read<SubscriptionCubit>()
                    .presentPaywall(context, entitlementId),
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('فتح هذه الميزة'),
                style: FilledButton.styleFrom(
                  minimumSize: Size(double.infinity, 52.h),
                  textStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () =>
                    context.read<SubscriptionCubit>().restorePurchases(),
                child: Text(
                  'استعادة المشتريات السابقة',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ── Inline upgrade nudge ────────────────────────────────────────────────────

/// Shows a modal bottom sheet explaining the free limit and offering an
/// upgrade. Call this from a BlocListener when [TaskFreeLimitReached] or
/// [HabitFreeLimitReached] is emitted.
void showUpgradeNudge(
  BuildContext context, {
  required String message,
  String entitlementId = 'spaces_pro',
}) {
  showModalBottomSheet<void>(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) => _UpgradeNudge(
      message: message,
      entitlementId: entitlementId,
    ),
  );
}

class _UpgradeNudge extends StatelessWidget {
  const _UpgradeNudge({required this.message, required this.entitlementId});

  final String message;
  final String entitlementId;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 20.h),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: AtharRadii.radiusXxxs,
            ),
          ),
          Icon(
            Icons.lock_outline_rounded,
            size: 40.sp,
            color: colorScheme.primary,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            style: TextStyle(fontSize: 15.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<SubscriptionCubit>()
                  .presentPaywall(context, entitlementId);
            },
            icon: const Icon(Icons.workspace_premium_rounded),
            label: const Text('ترقية الآن'),
            style: FilledButton.styleFrom(
              minimumSize: Size(double.infinity, 48.h),
            ),
          ),
          SizedBox(height: 8.h),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ربما لاحقاً'),
          ),
        ],
      ),
    );
  }
}

/// Small inline banner — shown inside a list page as a soft reminder.
class FreeLimitBanner extends StatelessWidget {
  const FreeLimitBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        borderRadius: AtharRadii.radiusMd,
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: colorScheme.tertiary,
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13.sp,
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          TextButton(
            onPressed: () => context
                .read<SubscriptionCubit>()
                .presentSpacesPaywall(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
            ),
            child: Text(
              'ترقية',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
