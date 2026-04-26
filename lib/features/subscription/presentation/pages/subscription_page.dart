import 'package:athar/features/subscription/domain/entities/subscription_status.dart';
import 'package:athar/features/subscription/presentation/cubit/subscription_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        title: const Text('الاشتراكات', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listenWhen: (_, curr) =>
            curr is SubscriptionRestored || curr is SubscriptionError,
        listener: (context, state) {
          if (state is SubscriptionRestored) {
            final msg = state.status.isFullyFree
                ? 'لا يوجد اشتراك سابق للاستعادة'
                : 'تم استعادة مشترياتك بنجاح';
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
          } else if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              backgroundColor: colorScheme.error,
            ));
          }
        },
        builder: (context, state) {
          if (state is SubscriptionLoading || state is SubscriptionPurchasing) {
            return const Center(child: CircularProgressIndicator());
          }

          final status = state is SubscriptionLoaded
              ? state.status
              : SubscriptionStatus.free;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Spaces Pro ────────────────────────────────────────────
                _PackCard(
                  icon: Icons.group_work_rounded,
                  iconColor: Colors.indigo,
                  title: 'مساحات أثر برو',
                  subtitle: 'مساحات تعاونية + مزامنة + مهام وعادات غير محدودة',
                  features: const [
                    'مساحات مشتركة مع الفريق',
                    'مزامنة سحابية تلقائية مضمّنة',
                    'مهام غير محدودة (بدلاً من 20)',
                    'عادات غير محدودة (بدلاً من 5)',
                  ],
                  isOwned: status.hasSpacesPro,
                  isSubscription: true,
                  expirationDate: status.spacesProExpirationDate,
                  onUpgrade: () => context
                      .read<SubscriptionCubit>()
                      .presentSpacesPaywall(context),
                  onManage: () => context
                      .read<SubscriptionCubit>()
                      .presentCustomerCenter(context),
                ),
                SizedBox(height: 12.h),

                // ── Sync Pro (standalone) ─────────────────────────────────
                _PackCard(
                  icon: Icons.sync_rounded,
                  iconColor: Colors.teal,
                  title: 'مزامنة أثر',
                  subtitle: 'مزامنة سحابية بدون اشتراك المساحات',
                  features: const [
                    'مزامنة المهام والعادات عبر الأجهزة',
                    'نسخة احتياطية تلقائية',
                    'يعمل بدون مساحات مشتركة',
                  ],
                  isOwned: status.hasSyncAccess,
                  isSubscription: true,
                  expirationDate: status.hasSyncPro
                      ? status.syncProExpirationDate
                      : null,
                  onUpgrade: () => context
                      .read<SubscriptionCubit>()
                      .presentSyncPaywall(context),
                  onManage: status.hasSyncPro
                      ? () => context
                          .read<SubscriptionCubit>()
                          .presentCustomerCenter(context)
                      : null,
                ),
                SizedBox(height: 12.h),

                // ── Health Pack ───────────────────────────────────────────
                _PackCard(
                  icon: Icons.favorite_rounded,
                  iconColor: Colors.red,
                  title: 'وحدة الصحة',
                  subtitle: 'تتبع الصحة، الأدوية، المواعيد — شراء مرة واحدة',
                  features: const [
                    'تتبع القياسات الحيوية',
                    'جدول الأدوية',
                    'مواعيد الطبيب',
                    'لك للأبد بدون تجديد',
                  ],
                  isOwned: status.hasHealthPack,
                  isSubscription: false,
                  onUpgrade: () => context
                      .read<SubscriptionCubit>()
                      .presentHealthPaywall(context),
                  onManage: null,
                ),
                SizedBox(height: 12.h),

                // ── Assets Pack ───────────────────────────────────────────
                _PackCard(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: Colors.amber.shade700,
                  title: 'وحدة الأصول',
                  subtitle: 'إدارة الممتلكات والأصول — شراء مرة واحدة',
                  features: const [
                    'تتبع الممتلكات والأجهزة',
                    'سجل الصيانة',
                    'مرفقات ووثائق',
                    'لك للأبد بدون تجديد',
                  ],
                  isOwned: status.hasAssetsPack,
                  isSubscription: false,
                  onUpgrade: () => context
                      .read<SubscriptionCubit>()
                      .presentAssetsPaywall(context),
                  onManage: null,
                ),

                SizedBox(height: 24.h),

                // ── Restore ───────────────────────────────────────────────
                OutlinedButton.icon(
                  onPressed: () =>
                      context.read<SubscriptionCubit>().restorePurchases(),
                  icon: const Icon(Icons.restore_rounded),
                  label: const Text('استعادة المشتريات السابقة'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'إذا اشتريت سابقاً على هذا الحساب، اضغط لاستعادة مشترياتك.',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Pack card widget ──────────────────────────────────────────────────────────

class _PackCard extends StatelessWidget {
  const _PackCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.isOwned,
    required this.isSubscription,
    required this.onUpgrade,
    this.expirationDate,
    this.onManage,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<String> features;
  final bool isOwned;
  final bool isSubscription;
  final DateTime? expirationDate;
  final VoidCallback onUpgrade;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AtharRadii.radiusLg,
        side: BorderSide(
          color: isOwned
              ? iconColor.withValues(alpha: 0.6)
              : colorScheme.outlineVariant,
          width: isOwned ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: AtharRadii.radiusMd,
                  ),
                  child: Icon(icon, color: iconColor, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOwned)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: AtharRadii.radiusSm,
                    ),
                    child: Text(
                      'مفعّل',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            // ── Expiry (subscriptions only) ─────────────────────────
            if (isOwned && isSubscription && expirationDate != null) ...[
              SizedBox(height: 8.h),
              Text(
                'يتجدد في: ${DateFormat('d MMM y', 'ar').format(expirationDate!)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.outline,
                ),
              ),
            ],

            // ── Features ────────────────────────────────────────────
            SizedBox(height: 12.h),
            ...features.map(
              (f) => Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 14.sp,
                      color: isOwned ? iconColor : colorScheme.outlineVariant,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      f,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: isOwned
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // ── CTA ──────────────────────────────────────────────────
            if (isOwned && onManage != null)
              OutlinedButton(
                onPressed: onManage,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 44.h),
                ),
                child: const Text('إدارة الاشتراك'),
              )
            else if (!isOwned)
              FilledButton(
                onPressed: onUpgrade,
                style: FilledButton.styleFrom(
                  backgroundColor: iconColor,
                  minimumSize: Size(double.infinity, 44.h),
                ),
                child: Text(
                  isSubscription ? 'اشترك الآن' : 'اشترِ مرة واحدة',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
