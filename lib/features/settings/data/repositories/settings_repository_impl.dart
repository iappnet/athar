import 'package:athar/features/habits/data/models/habit_model.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:athar/core/constants/athkar_data.dart';

// ✅ استيراد الواجهة (Interface)
import '../../domain/repositories/settings_repository.dart';

// ✅ استيراد الموديلات
import '../models/user_settings.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final Isar _isar;

  SettingsRepositoryImpl(this._isar);

  @override
  Future<UserSettings> getSettings() async {
    final settings = await _isar.userSettings.where().findFirst();
    if (settings == null) {
      final defaultSettings = UserSettings();
      await _isar.writeTxn(() async {
        await _isar.userSettings.put(defaultSettings);
      });
      return defaultSettings;
    }
    return settings;
  }

  @override
  Future<void> updateSettings(UserSettings settings) async {
    await _isar.writeTxn(() async {
      await _isar.userSettings.put(settings);
    });
  }

  @override
  Stream<UserSettings> watchSettings() async* {
    yield* _isar.userSettings.where().watch(fireImmediately: true).map((
      results,
    ) {
      if (results.isNotEmpty) {
        return results.first;
      } else {
        return UserSettings();
      }
    });
  }

  @override
  Future<void> toggleAutoMode(bool isEnabled) async {
    final settings = await getSettings();
    settings.isAutoModeEnabled = isEnabled;
    await _isar.writeTxn(() async {
      await _isar.userSettings.put(settings);
    });
  }

  // ---------------------------------------------------------------------------
  // ✅ دالة حذف الحساب
  // ---------------------------------------------------------------------------
  // @override
  // Future<void> deleteAccount({required bool deleteLocalData}) async {
  //   final user = _supabase.auth.currentUser;

  //   if (user != null) {
  //     try {
  //       await _supabase.rpc('delete_user');
  //     } catch (e) {
  //       try {
  //         await _supabase.from('tasks').delete().eq('user_id', user.id);
  //         await _supabase.from('habits').delete().eq('user_id', user.id);
  //       } catch (_) {}
  //     }
  //   }

  //   await _isar.writeTxn(() async {
  //     if (deleteLocalData) {
  //       await _isar.taskModels.clear();
  //       await _isar.habitModels
  //           .filter()
  //           .typeEqualTo(HabitType.regular)
  //           .deleteAll();

  //       final systemHabits = await _isar.habitModels
  //           .filter()
  //           .typeEqualTo(HabitType.athkar)
  //           .findAll();

  //       for (var h in systemHabits) {
  //         h.userId = ''; // ✅ التعديل: تفريغ النص بدلاً من null
  //         h.isSynced = false;
  //         h.isCompleted = false;
  //         h.currentStreak = 0;
  //         h.longestStreak = 0;
  //         h.completedDays = [];
  //         for (var item in h.athkarItems) {
  //           item.currentCount = 0;
  //           item.isDone = false;
  //         }
  //         await _isar.habitModels.put(h);
  //       }

  //       await _isar.userSettings.clear();
  //       await _isar.userSettings.put(UserSettings());
  //     } else {
  //       final tasks = await _isar.taskModels.where().findAll();
  //       for (var t in tasks) {
  //         t.userId = ''; // ✅ التعديل: تفريغ النص بدلاً من null
  //         t.isSynced = false;
  //         await _isar.taskModels.put(t);
  //       }
  //       final habits = await _isar.habitModels.where().findAll();
  //       for (var h in habits) {
  //         h.userId = ''; // ✅ التعديل: تفريغ النص بدلاً من null
  //         h.isSynced = false;
  //         await _isar.habitModels.put(h);
  //       }
  //     }
  //   });

  //   await _supabase.auth.signOut();
  // }

  // ---------------------------------------------------------------------------
  // ✅ دالة "زراعة" الأذكار (Seeding) - النسخة المصححة
  // ---------------------------------------------------------------------------
  @override
  Future<void> ensureAthkarSeeding(String userId) async {
    // القائمة المرجعية للأذكار الثابتة
    // ⚠️ تم حذف أذكار الصلاة وأذكار النوم من هنا لأنها لا يجب أن تكون عادات (Habits)
    // ⚠️ تم استخدام الثوابت من AthkarData لضمان عدم التكرار
    final athkarConfigs = [
      {
        'uuid':
            AthkarData.morningAthkarId, // استخدام الثابت بدلاً من النص المباشر
        'title': 'أذكار الصباح',
        'timing': DhikrTiming.morning,
        'offset': 1000,
        'period': HabitPeriod.morning,
      },
      {
        'uuid':
            AthkarData.eveningAthkarId, // استخدام الثابت بدلاً من النص المباشر
        'title': 'أذكار المساء',
        'timing': DhikrTiming.evening,
        'offset': 2000,
        'period': HabitPeriod.afternoon,
      },
      // ✅✅ الإضافة الجديدة
      {
        'uuid': AthkarData.prayerAthkarId,
        'title': 'أذكار بعد الصلاة',
        'timing': DhikrTiming.prayer,
        'offset': 3000,
        'period': HabitPeriod.postPrayer,
      },
      {
        'uuid': AthkarData.sleepAthkarId,
        'title': 'أذكار النوم',
        'timing': DhikrTiming.sleep,
        'offset': 4000,
        'period': HabitPeriod.night,
      },
    ];

    await _isar.writeTxn(() async {
      for (var config in athkarConfigs) {
        // البحث بالـ UUID الثابت لضمان عدم التكرار عبر الأجهزة
        final existing = await _isar.habitModels
            .filter()
            .uuidEqualTo(config['uuid'] as String)
            .findFirst();

        if (existing == null) {
          // استخدام المحرك الجديد لبناء العادة
          final habit = _buildAthkarHabit(
            userId: userId,
            title: config['title'] as String,
            uuid: config['uuid'] as String,
            timing: config['timing'] as DhikrTiming,
            offset: config['offset'] as int,
            period: config['period'] as HabitPeriod,
          );
          await _isar.habitModels.put(habit);
        } else {
          // ✅ إصلاح: إذا كانت العادة موجودة ولكن غير مرتبطة بالمستخدم الحالي
          if (existing.userId != userId) {
            existing.userId = userId;
            existing.isSynced = false; // لإجبار المزامنة
            await _isar.habitModels.put(existing);
          }
        }
      }
    });
  }

  // ⚙️ المحرك الأساسي لبناء العادات بنظام المعرفات الثابتة
  HabitModel _buildAthkarHabit({
    required String userId,
    required String title,
    required String uuid,
    required DhikrTiming timing,
    required int offset,
    required HabitPeriod period,
  }) {
    List<AthkarItem> items = [];
    for (int i = 0; i < AthkarData.allAthkar.length; i++) {
      final source = AthkarData.allAthkar[i];
      if (source.timings.contains(timing)) {
        items.add(
          AthkarItem()
            ..itemId =
                offset +
                i // توليد ID فريد بناءً على النطاق
            ..text = source.text
            ..targetCount = source.count
            ..currentCount = 0
            ..isDone = false,
        );
      }
    }

    // المنطق الرياضي: حساب مجموع الأهداف الكلي لضمان دقة شريط الإنجاز
    int totalTarget = items.fold(0, (sum, item) => sum + item.targetCount);

    return HabitModel(
      title: title,
      uuid: uuid,
      userId: userId,
      type: HabitType.athkar,
      period: period,
      target: totalTarget,
      isSynced: false,
    )..athkarItems = items;
  }
}
