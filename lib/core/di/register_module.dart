import 'package:athar/features/assets/data/models/asset_model.dart';
import 'package:athar/features/assets/data/models/service_log_model.dart';
import 'package:athar/features/assets/data/models/service_model.dart';
import 'package:athar/features/focus/data/models/focus_session.dart';
import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:athar/features/health/data/models/appointment_model.dart';
import 'package:athar/features/health/data/models/health_profile_model.dart';
import 'package:athar/features/health/data/models/medicine_log_model.dart';
import 'package:athar/features/health/data/models/medicine_model.dart';
import 'package:athar/features/health/data/models/vital_sign_model.dart';
import 'package:athar/features/notifications/data/models/notification_model.dart';
import 'package:athar/features/settings/data/models/category_model.dart';
import 'package:athar/features/space/data/models/list_item_model.dart';
import 'package:athar/features/space/data/models/list_log_model.dart';
import 'package:athar/features/space/data/models/module_model.dart';
import 'package:athar/features/space/data/models/module_permission_model.dart';
import 'package:athar/features/space/data/models/invitation_model.dart';
import 'package:athar/features/space/data/models/space_member_model.dart';
import 'package:athar/features/space/data/models/space_model.dart';
import 'package:athar/features/task/data/models/attachment_model.dart';
import 'package:athar/features/task/data/models/task_model.dart';
import 'package:athar/features/task/data/models/task_note_model.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/settings/data/models/user_settings.dart';
// import '../../features/project/data/models/project_model.dart'; // <--- استيراد هذا الملف ضروري
import '../../features/dhikr/data/models/dhikr_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ 1. استيراد هام جداً

@module
abstract class RegisterModule {
  // ✅ 2. هذا هو السطر المفقود الذي سبب المشكلة!
  // نقوم بتسجيل SupabaseClient لكي يستطيع النظام حقنه في AuthRepository
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
  // دالة لفتح قاعدة البيانات وتوفيرها للتطبيق كاملاً
  @preResolve // تعني انتظر حتى تنتهي الدالة قبل تشغيل التطبيق
  Future<Isar> get isar async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([
      TaskModelSchema,
      UserSettingsSchema,
      HabitModelSchema,
      FocusSessionSchema,
      // ProjectModelSchema,
      DhikrModelSchema, // ✅ 2. تمت إضافة المخطط المفقود هنا!
      CategoryModelSchema, // ✅✅ أضف هذا السطر لحل الخطأ الأول
      SpaceModelSchema, // 🆕 تم الإضافة
      ModuleModelSchema, // 🆕 تم الإضافة
      SpaceMemberModelSchema,
      InvitationModelSchema,
      ModulePermissionModelSchema,
      // ✅ 2. أضف الـ Schemas الجديدة هنا
      AttachmentModelSchema,
      TaskNoteModelSchema,
      // ✅ إضافة Schema الأصول
      AssetModelSchema,
      ServiceModelSchema,
      ServiceLogModelSchema, // ✅ جديد
      ListItemModelSchema, // ✅ جديد
      ListLogModelSchema, // ✅ جديد
      HealthProfileModelSchema,
      MedicineModelSchema,
      MedicineLogModelSchema,
      AppointmentModelSchema,
      VitalSignModelSchema,
      NotificationModelSchema,
    ], directory: dir.path);
  }
}
