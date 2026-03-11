import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';
import '../models/dhikr_model.dart';
import '../../../../core/constants/athkar_data.dart'; // تأكد من المسار

@lazySingleton
class DhikrRepository {
  final Isar _isar;

  DhikrRepository(this._isar);

  // جلب الأذكار حسب التصنيف
  Future<List<DhikrModel>> getAthkarByCategory(DhikrCategory category) async {
    return await _isar.dhikrModels
        .filter()
        .categoryEqualTo(category)
        .sortByOrder()
        .findAll();
  }

  // ✅ تهيئة البيانات الأولية (تحديث جذري)
  // تقوم بقراءة AthkarData.allAthkar وتوزيعها على الفئات
  Future<void> initDefaultAthkar() async {
    final count = await _isar.dhikrModels.count();

    // نقوم بالتهيئة فقط إذا كانت قاعدة البيانات فارغة
    if (count == 0) {
      final List<DhikrModel> dhikrList = [];
      int orderCounter = 1;

      // المرور على كل مصدر ذكر في الملف الثابت
      for (var source in AthkarData.allAthkar) {
        // المصدر قد يحتوي على عدة أوقات (مثلاً صباح ومساء)
        // نقوم بإنشاء صف في قاعدة البيانات لكل وقت
        for (var timing in source.timings) {
          final category = _mapTimingToCategory(timing);

          if (category != null) {
            final dhikrModel = DhikrModel()
              ..text = source.text
              ..count = source.count
              ..virtue = source
                  .virtue // إضافة الفضل إذا وجد
              ..category = category
              ..order =
                  orderCounter++ // ترتيب تلقائي
              ..isCustom = false
              ..currentCount = 0;

            dhikrList.add(dhikrModel);
          }
        }
      }

      // الحفظ دفعة واحدة في قاعدة البيانات
      await _isar.writeTxn(() async {
        await _isar.dhikrModels.putAll(dhikrList);
      });
    }
  }

  // ✅ دالة مساعدة لربط توقيت المصدر بتصنيف الموديل
  DhikrCategory? _mapTimingToCategory(DhikrTiming timing) {
    switch (timing) {
      case DhikrTiming.morning:
        return DhikrCategory.morning;
      case DhikrTiming.evening:
        return DhikrCategory.evening;
      case DhikrTiming.prayer:
        return DhikrCategory.prayer;
      case DhikrTiming.sleep:
        // تأكد من إضافة sleep إلى DhikrCategory في ملف dhikr_model.dart
        // إذا لم تكن مضافة، يمكنك إضافتها للـ Enum هناك
        return DhikrCategory.values.firstWhere(
          (e) => e.name == 'sleep',
          orElse: () => DhikrCategory.custom,
        );
      // default:
      //   return null;
    }
  }

  // إضافة ذكر مخصص
  Future<void> addCustomDhikr(
    String text,
    int count,
    DhikrCategory category,
  ) async {
    final newDhikr = DhikrModel()
      ..text = text
      ..count = count
      ..category = category
      ..isCustom = true
      ..order = 999; // نضعه في الأخير

    await _isar.writeTxn(() async {
      await _isar.dhikrModels.put(newDhikr);
    });
  }

  // تعديل الترتيب
  Future<void> updateOrder(List<DhikrModel> athkar) async {
    await _isar.writeTxn(() async {
      for (int i = 0; i < athkar.length; i++) {
        athkar[i].order = i;
        await _isar.dhikrModels.put(athkar[i]);
      }
    });
  }
}
