import 'package:athar/core/design_system/tokens/athar_radii.dart';
import 'package:athar/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:athar/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:athar/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class NotificationCenterPage extends StatelessWidget {
  const NotificationCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
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
            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final note = state.notifications[index];
                return _buildNotificationTile(context, colorScheme, note);
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    ColorScheme colorScheme,
    dynamic note,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: note.isRead
            ? colorScheme.surface.withValues(alpha: 0.7)
            : colorScheme.surface,
        borderRadius: AtharRadii.card,
        border: note.isRead
            ? null
            : Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: _getIcon(colorScheme, note.type),
        title: Text(
          note.title,
          style: TextStyle(
            fontWeight: note.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.body),
            SizedBox(height: 4.h),
            Text(
              DateFormat('jm', 'ar').format(note.createdAt),
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
    if (payload == null) return;

    if (type == 'project') {
      // Navigation logic for project
    } else if (type == 'task') {
      // Navigation logic for task
    }
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
        ],
      ),
    );
  }
}
//-----------------------------------------------------------------------
// import 'package:athar/core/design_system/themes/app_colors.dart';
// import 'package:athar/features/notifications/presentation/cubit/notifications_cubit.dart';
// import 'package:athar/features/notifications/presentation/cubit/notifications_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';

// class NotificationCenterPage extends StatelessWidget {
//   const NotificationCenterPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text(
//           "مركز التنبيهات",
//           style: TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => context.read<NotificationsCubit>().clearAll(),
//             child: const Text("مسح الكل", style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//       body: BlocBuilder<NotificationsCubit, NotificationsState>(
//         builder: (context, state) {
//           if (state is NotificationsLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (state is NotificationsLoaded) {
//             if (state.notifications.isEmpty) return _buildEmptyState();
//             return ListView.builder(
//               itemCount: state.notifications.length,
//               itemBuilder: (context, index) {
//                 final note = state.notifications[index];
//                 return _buildNotificationTile(context, note);
//               },
//             );
//           }
//           return const SizedBox();
//         },
//       ),
//     );
//   }

//   Widget _buildNotificationTile(BuildContext context, dynamic note) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         color: note.isRead ? Colors.white.withOpacity(0.7) : Colors.white,
//         borderRadius: BorderRadius.circular(12.r),
//         border: note.isRead
//             ? null
//             : Border.all(color: AppColors.primary.withOpacity(0.3)),
//       ),
//       child: ListTile(
//         leading: _getIcon(note.type),
//         title: Text(
//           note.title,
//           style: TextStyle(
//             fontWeight: note.isRead ? FontWeight.normal : FontWeight.bold,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(note.body),
//             SizedBox(height: 4.h),
//             Text(
//               DateFormat('jm', 'ar').format(note.createdAt),
//               style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//             ),
//           ],
//         ),
//         onTap: () {
//           context.read<NotificationsCubit>().markAsRead(note.uuid);
//           _handleNavigation(context, note.type, note.payload);
//         },
//       ),
//     );
//   }

//   Widget _getIcon(String type) {
//     IconData icon;
//     Color color;
//     switch (type) {
//       case 'project':
//         icon = Icons.folder_special;
//         color = Colors.orange;
//         break;
//       case 'task':
//         icon = Icons.check_circle;
//         color = Colors.blue;
//         break;
//       case 'health':
//         icon = Icons.favorite;
//         color = Colors.red;
//         break;
//       default:
//         icon = Icons.notifications;
//         color = AppColors.primary;
//     }
//     return CircleAvatar(
//       backgroundColor: color.withOpacity(0.1),
//       child: Icon(icon, color: color, size: 20.sp),
//     );
//   }

//   void _handleNavigation(BuildContext context, String type, String? payload) {
//     // هنا سيتم استدعاء DeepLinkService لتوجيه المستخدم
//     // مثال: لو التنبيه لمشروع، نفتح صفحة ProjectDetailsPage
//     if (payload == null) return;

//     // 1. تحديد التنبيه كمقروء (تمت بالفعل في onTap)

//     // 2. التوجيه بناءً على النوع
//     if (type == 'project') {
//       // منطق فتح المشروع: سأقوم بتزويدك بكود جلب الموديول من المعرف لاحقاً
//       // Navigator.push(...)
//     } else if (type == 'task') {
//       // فتح المهمة
//     }

//     // ملاحظة: يفضل إظهار رسالة "جاري التحميل" إذا كان المورد يتطلب جلباً من السحاب
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.notifications_none_rounded,
//             size: 80.sp,
//             color: Colors.grey[300],
//           ),
//           Text(
//             "لا توجد تنبيهات حالياً",
//             style: TextStyle(color: Colors.grey, fontSize: 16.sp),
//           ),
//         ],
//       ),
//     );
//   }
// }
//-----------------------------------------------------------------------
