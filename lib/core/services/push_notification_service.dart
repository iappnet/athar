import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ✅ خدمة إرسال الإشعارات السحابية عبر Supabase Edge Functions
@singleton
class PushNotificationService {
  final SupabaseClient _supabase;

  PushNotificationService(this._supabase);

  // ═══════════════════════════════════════════════════════════
  // 📤 SEND NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════

  /// ✅ إرسال إشعار لمستخدمين محددين
  Future<bool> sendToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-notification',
        body: {
          'userIds': userIds,
          'title': title,
          'body': body,
          'type': type,
          'data': data ?? {},
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );

      if (response.status == 200) {
        if (kDebugMode) {
          print('✅ Notification sent to ${userIds.length} users');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Error sending notification: ${response.data}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error invoking edge function: $e');
      }
      return false;
    }
  }

  /// ✅ إرسال إشعار لأعضاء مساحة
  Future<bool> sendToSpaceMembers({
    required String spaceId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
    String? excludeUserId, // لاستبعاد المرسل
  }) async {
    try {
      // الحصول على IDs الأعضاء
      final response = await _supabase
          .from('space_members')
          .select('user_id')
          .eq('space_id', spaceId);

      // ✅ في Supabase الحديث، response لا يكون null أبداً
      // فقط نتحقق من isEmpty
      if (response.isEmpty) {
        if (kDebugMode) {
          print('⚠️ No members found for space: $spaceId');
        }
        return false;
      }

      var userIds = (response as List)
          .map((m) => m['user_id'] as String)
          .toList();

      // استبعاد المرسل
      if (excludeUserId != null) {
        userIds = userIds.where((id) => id != excludeUserId).toList();
      }

      if (userIds.isEmpty) {
        if (kDebugMode) {
          print('⚠️ No users to notify after filtering');
        }
        return false;
      }

      return await sendToUsers(
        userIds: userIds,
        title: title,
        body: body,
        type: type,
        data: data,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending to space members: $e');
      }
      return false;
    }
  }

  /// ✅ إرسال إشعار لجميع المستخدمين (Admin only)
  Future<bool> sendToAllUsers({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-notification-to-all',
        body: {'title': title, 'body': body, 'type': type, 'data': data ?? {}},
      );

      if (response.status == 200) {
        if (kDebugMode) {
          print('✅ Notification sent to all users');
        }
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Error sending notification to all: ${response.data}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error invoking edge function: $e');
      }
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📢 NOTIFICATION TEMPLATES
  // ═══════════════════════════════════════════════════════════

  /// ✅ إشعار مشاركة مهمة
  Future<bool> notifyTaskShared({
    required String recipientUserId,
    required String senderName,
    required String taskTitle,
    required String taskId,
  }) async {
    return await sendToUsers(
      userIds: [recipientUserId],
      title: 'مهمة جديدة من $senderName',
      body: taskTitle,
      type: 'task_shared',
      data: {'taskId': taskId, 'senderName': senderName},
    );
  }

  /// ✅ إشعار دعوة لمساحة
  Future<bool> notifySpaceInvite({
    required String recipientUserId,
    required String spaceName,
    required String inviterName,
    required String spaceId,
  }) async {
    return await sendToUsers(
      userIds: [recipientUserId],
      title: 'دعوة لمساحة $spaceName',
      body: '$inviterName دعاك للانضمام',
      type: 'space_invite',
      data: {
        'spaceId': spaceId,
        'spaceName': spaceName,
        'inviterName': inviterName,
      },
    );
  }

  /// ✅ إشعار تعليق جديد
  Future<bool> notifyNewComment({
    required String taskOwnerId,
    required String commenterName,
    required String taskTitle,
    required String taskId,
    required String commentText,
  }) async {
    return await sendToUsers(
      userIds: [taskOwnerId],
      title: 'تعليق جديد من $commenterName',
      body: '$taskTitle: $commentText',
      type: 'new_comment',
      data: {'taskId': taskId, 'commenterName': commenterName},
    );
  }

  /// ✅ إشعار تذكير بمهمة
  Future<bool> notifyTaskReminder({
    required String userId,
    required String taskTitle,
    required String taskId,
    required int minutesBefore,
  }) async {
    return await sendToUsers(
      userIds: [userId],
      title: 'تذكير: $taskTitle',
      body: 'بعد $minutesBefore دقيقة',
      type: 'task_reminder',
      data: {'taskId': taskId, 'minutesBefore': minutesBefore},
    );
  }
}
