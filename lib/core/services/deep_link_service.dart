import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:athar/core/di/injection.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/task/data/models/task_model.dart';
// ✅ تم تفعيل الاستخدام هنا
import 'package:athar/features/space/data/models/space_member_model.dart';
import 'package:isar/isar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// استيرادات الصفحات المطلوبة للتوجيه
import 'package:athar/features/space/presentation/pages/project_details_page.dart';
import 'package:athar/features/task/presentation/pages/task_details_page.dart';
import 'package:athar/features/space/presentation/pages/space_members_page.dart';

@lazySingleton
class DeepLinkService {
  final _appLinks = AppLinks();
  final SupabaseClient _supabase = Supabase.instance.client;
  final _storage = const FlutterSecureStorage(aOptions: AndroidOptions());

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  StreamSubscription? _linkSubscription;

  DeepLinkService();

  /// 1. تهيئة الاستماع للروابط الخارجية
  Future<void> init() async {
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleExternalLink(uri);
    });
  }

  /// 2. معالجة الروابط الخارجية (مثل روابط الانضمام)
  Future<void> _handleExternalLink(Uri uri) async {
    if (uri.path != '/join') return;

    final token = uri.queryParameters['code'];
    if (token == null || token.isEmpty) return;

    final user = _supabase.auth.currentUser;

    if (user != null) {
      _navigateToJoinScreen(token);
    } else {
      await _storage.write(key: 'pending_invite_token', value: token);
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );

      if (navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          const SnackBar(
            content: Text('الرجاء تسجيل الدخول أو إنشاء حساب لقبول الدعوة'),
          ),
        );
      }
    }
  }

  /// 3. معالجة النقر على التنبيهات (Notification Routing)
  /// تم تصحيح الأخطاء عبر جلب الكائنات من Isar قبل التنقل
  static Future<void> handleNotificationClick(
    String type,
    String? payload,
  ) async {
    if (payload == null) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    final isar = getIt<Isar>();

    switch (type) {
      case 'project':
        final module = await isar.moduleModels
            .filter()
            .uuidEqualTo(payload)
            .findFirst();
        if (module != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailsPage(module: module),
            ),
          );
        }
        break;

      case 'task':
        final task = await isar.taskModels
            .filter()
            .uuidEqualTo(payload)
            .findFirst();
        if (task != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskDetailsPage(task: task)),
          );
        }
        break;

      case 'space_invite':
        // ✅ توظيف الاستيراد: التحقق من وجود العضوية قبل فتح صفحة الأعضاء
        // هذا يضمن أن المستخدم لن يفتح صفحة مساحة هو ليس عضواً فيها فعلياً في الكاش
        final memberRecord = await isar.spaceMemberModels
            .filter()
            .spaceIdEqualTo(payload)
            .findFirst();

        if (memberRecord != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SpaceMembersPage(spaceId: memberRecord.spaceId),
            ),
          );
        } else {
          // إذا لم يجد العضوية في الكاش، نفتح الصفحة بالـ ID المباشر كحل أخير
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SpaceMembersPage(spaceId: payload),
              ),
            );
          }
        }
        break;

      default:
        debugPrint("Unknown notification type: $type");
    }
  }

  /// فحص الدعوات المؤجلة بعد تسجيل الدخول
  Future<void> checkPendingInvites() async {
    final token = await _storage.read(key: 'pending_invite_token');
    if (token != null) {
      await _storage.delete(key: 'pending_invite_token');
      _navigateToJoinScreen(token);
    }
  }

  void _navigateToJoinScreen(String token) {
    navigatorKey.currentState?.pushNamed('/join-space', arguments: token);
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}

// import 'dart:async';
// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:injectable/injectable.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// @lazySingleton
// class DeepLinkService {
//   // ❌ تم حذف InvitationRepository لأنه غير مستخدم هنا (يستخدم في الواجهة لاحقاً)

//   final _appLinks = AppLinks();
//   final SupabaseClient _supabase = Supabase.instance.client;

//   // ✅ التعديل: إزالة الخيار الملغي (deprecated)
//   // في الإصدار 10+، الخيار الافتراضي هو الآمن ولا يحتاج لإعدادات إضافية
//   final _storage = const FlutterSecureStorage(aOptions: AndroidOptions());

//   // مفتاح للتنقل (يجب ربطه بـ MaterialApp في main.dart)
//   static final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>();

//   StreamSubscription? _linkSubscription;

//   // ✅ التعديل: إزالة الحقن غير المستخدم من الكونستركتور
//   DeepLinkService();

//   /// 1. تهيئة الاستماع للروابط (يستدعى في main.dart)
//   Future<void> init() async {
//     // الاستماع للروابط القادمة (أثناء تشغيل التطبيق أو من الخلفية)
//     _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
//       _handleLink(uri);
//     });
//   }

//   /// 2. معالجة الرابط
//   Future<void> _handleLink(Uri uri) async {
//     // التأكد أن الرابط هو رابط انضمام: https://athar.app/join?code=xyz
//     if (uri.path != '/join') return;

//     final token = uri.queryParameters['code'];
//     if (token == null || token.isEmpty) return;

//     final user = _supabase.auth.currentUser;

//     if (user != null) {
//       // ✅ المستخدم مسجل -> نوجهه فوراً لشاشة قبول الدعوة
//       _navigateToJoinScreen(token);
//     } else {
//       // ❌ غير مسجل -> نخزن التوكن بأمان ونوجهه لتسجيل الدخول

//       // تخزين التوكن في التخزين الآمن
//       await _storage.write(key: 'pending_invite_token', value: token);

//       // توجيه لصفحة التسجيل
//       navigatorKey.currentState?.pushNamedAndRemoveUntil(
//         '/login',
//         (route) => false,
//       );

//       // عرض رسالة توضيحية
//       ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
//         const SnackBar(
//           content: Text('الرجاء تسجيل الدخول أو إنشاء حساب لقبول الدعوة'),
//         ),
//       );
//     }
//   }

//   /// 3. فحص الدعوات المؤجلة (يستدعى بعد نجاح تسجيل الدخول)
//   Future<void> checkPendingInvites() async {
//     // قراءة التوكن من التخزين الآمن
//     final token = await _storage.read(key: 'pending_invite_token');

//     if (token != null) {
//       // حذف التوكن بعد الاستخدام
//       await _storage.delete(key: 'pending_invite_token');

//       // التوجيه للقبول
//       _navigateToJoinScreen(token);
//     }
//   }

//   /// دالة مساعدة للتنقل
//   void _navigateToJoinScreen(String token) {
//     // نفترض وجود مسار اسمه /join-space يستقبل التوكن كـ arguments
//     navigatorKey.currentState?.pushNamed('/join-space', arguments: token);
//   }

//   void dispose() {
//     _linkSubscription?.cancel();
//   }
// }
