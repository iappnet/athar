import 'package:athar/features/notifications/data/models/notification_model.dart';
import 'package:athar/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@LazySingleton(as: NotificationsRepository) // ربط الواجهة بالتنفيذ لـ DI
class NotificationsRepositoryImpl implements NotificationsRepository {
  final Isar _isar;
  final SupabaseClient _supabase = Supabase.instance.client;

  NotificationsRepositoryImpl(this._isar);

  @override
  Stream<List<NotificationModel>> watchNotifications() {
    return _isar.notificationModels.where().sortByCreatedAtDesc().watch(
      fireImmediately: true,
    );
  }

  @override
  Future<void> syncNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<NotificationModel> remoteNotes = (response as List).map((
        json,
      ) {
        return NotificationModel()
          ..uuid = json['id']
          ..title = json['title']
          ..body = json['body']
          ..type = json['type']
          ..payload = json['payload']
          ..isRead = json['is_read']
          ..createdAt = DateTime.parse(json['created_at'])
          ..isSynced = true;
      }).toList();

      await _isar.writeTxn(() async {
        // تحديث الكاش المحلي: حذف القديم ووضع الجديد لضمان التطابق مع السحاب
        await _isar.notificationModels.clear();
        await _isar.notificationModels.putAll(remoteNotes);
      });
    } catch (e) {
      // التعامل مع الخطأ بصمت (يمكن إضافة Logger هنا)
    }
  }

  @override
  Future<void> markAsRead(String uuid) async {
    final localItem = await _isar.notificationModels
        .filter()
        .uuidEqualTo(uuid)
        .findFirst();
    if (localItem != null) {
      await _isar.writeTxn(() async {
        localItem.isRead = true;
        await _isar.notificationModels.put(localItem);
      });
    }
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', uuid);
  }

  @override
  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.notificationModels.clear();
    });
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _supabase.from('notifications').delete().eq('user_id', userId);
    }
  }

  @override
  Future<void> logNotification({
    required String title,
    required String body,
    required String type,
    String? payload,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. إرسال للسحاب للحصول على UUID الرسمي
      final response = await _supabase
          .from('notifications')
          .insert({
            'user_id': userId,
            'title': title,
            'body': body,
            'type': type,
            'payload': payload,
            'is_read': false,
          })
          .select()
          .single();

      // 2. التخزين في Isar
      final newNote = NotificationModel()
        ..uuid = response['id']
        ..title = title
        ..body = body
        ..type = type
        ..payload = payload
        ..createdAt = DateTime.now()
        ..isRead = false
        ..isSynced = true;

      await _isar.writeTxn(() async {
        await _isar.notificationModels.put(newNote);
      });
    } catch (e) {
      // إذا فشل السحاب (Offline)، نخزنها محلياً مع وسم غير متزامن
      final offlineNote = NotificationModel()
        ..uuid = 'off_${DateTime.now().millisecondsSinceEpoch}'
        ..title = title
        ..body = body
        ..type = type
        ..payload = payload
        ..createdAt = DateTime.now()
        ..isRead = false
        ..isSynced = false;

      await _isar.writeTxn(() async {
        await _isar.notificationModels.put(offlineNote);
      });
    }
  }
}
