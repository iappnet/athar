import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:injectable/injectable.dart';
import '../models/category_model.dart';

@lazySingleton
class CategoryRepository {
  final Isar _isar;

  CategoryRepository(this._isar);

  // ✅ الدالة الذكية لاستعادة التصنيفات (تم تحديثها)
  Future<void> ensureDefaultCategories() async {
    final count = await _isar.categoryModels.count();

    // فحص: هل يوجد تصنيف باسم "عمل"؟ (استخدمنا name حسب الموديل الخاص بك)
    final hasWork =
        await _isar.categoryModels.filter().nameEqualTo("عمل").findFirst() !=
        null;

    // الشرط: إذا القاعدة فارغة تماماً، أو العدد قليل جداً ولا يوجد "عمل"
    if (count == 0 || (!hasWork && count < 2)) {
      await _isar.writeTxn(() async {
        // تنظيف للتأكد (اختياري)
        if (count > 0) {
          await _isar.categoryModels.clear();
        }
        // إضافة القائمة الافتراضية المعرفة في الموديل
        await _isar.categoryModels.putAll(CategoryModel.defaultCategories);
      });
      debugPrint("✅ تم استعادة التصنيفات الافتراضية");
    }
  }

  Stream<List<CategoryModel>> watchCategories() {
    return _isar.categoryModels.where().watch(fireImmediately: true);
  }

  Future<void> addCategory(CategoryModel category) async {
    await _isar.writeTxn(() async {
      await _isar.categoryModels.put(category);
    });
  }

  // ✅ تعديل دالة الحذف لمنح الحرية للمستخدم
  Future<void> deleteCategory(int id) async {
    await _isar.writeTxn(() async {
      // حذفنا شرط (!category.isDefault) لمنح المستخدم الحرية
      // إذا حذف المستخدم كل شيء، ستقوم ensureDefaultCategories باستعادتها في التشغيل القادم
      await _isar.categoryModels.delete(id);
    });
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _isar.writeTxn(() async {
      await _isar.categoryModels.put(category);
    });
  }
}
