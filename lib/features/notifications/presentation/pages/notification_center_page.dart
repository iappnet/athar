import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/deep_link_service.dart';
import 'package:athar/core/services/local_notification_service.dart';
import 'package:athar/features/notifications/data/models/notification_model.dart';
import 'package:athar/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:athar/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:athar/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:athar/core/design_system/tokens.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareInbox());
  }

  Future<void> _prepareInbox() async {
    // The global NotificationsCubit (from app.dart) is already watching the
    // Isar stream. Calling watchNotifications() again would flash a Loading
    // spinner. We only need to sync remote data and mark everything as read.
    final repository = getIt<NotificationsRepository>();
    await repository.syncNotifications();
    if (!mounted) return;
    await repository.markAllAsRead();
    await getIt<LocalNotificationService>().setAppBadge(0);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: true,
        title: Text(
          l10n.notificationsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => context.read<NotificationsCubit>().clearAll(),
            child: Text(
              l10n.notificationsClearAll,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState(colorScheme, l10n);
            }
            return RefreshIndicator(
              onRefresh: _prepareInbox,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 8.h, 0, 24.h),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final note = state.notifications[index];
                  return _buildNotificationTile(context, colorScheme, note);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    ColorScheme colorScheme,
    NotificationModel note,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface.withValues(alpha: note.isRead ? 0.92 : 0.98),
            colorScheme.surfaceContainerHighest.withValues(
              alpha: note.isRead ? 0.72 : 0.86,
            ),
          ],
        ),
        borderRadius: AtharRadii.cardLarge,
        border: Border.all(
          color: note.isRead
              ? colorScheme.outlineVariant.withValues(alpha: 0.35)
              : colorScheme.primary.withValues(alpha: 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        leading: _getIcon(colorScheme, note.type),
        title: Text(
          note.title,
          style: TextStyle(
            fontWeight: note.isRead ? FontWeight.w500 : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AtharGap.xxxs,
            Text(note.body),
            AtharGap.xxs,
            Text(
              DateFormat('EEE d MMM • jm', 'ar').format(note.createdAt),
              style: TextStyle(fontSize: 10.sp, color: colorScheme.outline),
            ),
          ],
        ),
        onTap: () {
          context.read<NotificationsCubit>().markAsRead(note.uuid);
          _handleNavigation(context, note.type, note.payload);
        },
      ),
    );
  }

  Widget _getIcon(ColorScheme colorScheme, String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'project':
        icon = Icons.folder_special;
        color = Colors.orange;
        break;
      case 'task':
        icon = Icons.check_circle;
        color = Colors.blue;
        break;
      case 'health':
        icon = Icons.favorite;
        color = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        color = colorScheme.primary;
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color, size: 20.sp),
    );
  }

  void _handleNavigation(BuildContext context, String type, String? payload) {
    DeepLinkService.handleNotificationClick(type, payload);
  }

  Widget _buildEmptyState(ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80.sp,
            color: colorScheme.outlineVariant,
          ),
          Text(
            l10n.notificationsEmpty,
            style: TextStyle(color: colorScheme.outline, fontSize: 16.sp),
          ),
          AtharGap.md,
          Text(
            'ستظهر هنا التنبيهات الجديدة عند وصولها.',
            style: TextStyle(color: colorScheme.outlineVariant),
          ),
        ],
      ),
    );
  }
}
