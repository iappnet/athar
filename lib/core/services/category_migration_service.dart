// lib/core/services/category_migration_service.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 🔄 CATEGORY MIGRATION SERVICE - تهجير بيانات التصنيفات من iconCode إلى iconKey
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:athar/core/utils/icon_registry.dart';
import 'package:athar/features/settings/data/models/category_model.dart';

@lazySingleton
class CategoryMigrationService {
  final Isar _isar;

  CategoryMigrationService(this._isar);

  /// ✅ تشغيل عملية التهجير
  /// يجب استدعاء هذه الدالة مرة واحدة عند بدء التطبيق
  Future<void> runMigration() async {
    try {
      if (kDebugMode) {
        print('🔄 Starting category icon migration...');
      }

      final categories = await _isar.categoryModels.where().findAll();
      int migratedCount = 0;

      await _isar.writeTxn(() async {
        for (final category in categories) {
          // تحقق إذا كان يحتاج تهجير
          // ignore: deprecated_member_use_from_same_package
          if (_needsMigration(category)) {
            // ignore: deprecated_member_use_from_same_package
            final oldIconCode = category.iconCode;
            final newIconKey = IconRegistry.migrateFromIconCode(oldIconCode);

            // تحديث iconKey
            category.iconKey = newIconKey;

            await _isar.categoryModels.put(category);
            migratedCount++;

            if (kDebugMode) {
              print(
                  '  ✓ Migrated "${category.name}": iconCode=$oldIconCode → iconKey=$newIconKey');
            }
          }
        }
      });

      if (kDebugMode) {
        if (migratedCount > 0) {
          print('✅ Migration complete! Migrated $migratedCount categories.');
        } else {
          print('✅ No migration needed. All categories already use iconKey.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Category migration failed: $e');
      }
    }
  }

  /// ✅ تحقق إذا كان التصنيف يحتاج تهجير
  bool _needsMigration(CategoryModel category) {
    // يحتاج تهجير إذا:
    // 1. iconKey فارغ أو غير صالح
    // 2. و iconCode موجود
    final hasValidIconKey =
        category.iconKey.isNotEmpty && IconRegistry.isValidKey(category.iconKey);

    // ignore: deprecated_member_use_from_same_package
    final hasIconCode = category.iconCode != null;

    return !hasValidIconKey && hasIconCode;
  }

  /// ✅ إصلاح التصنيفات الافتراضية إذا كانت تستخدم iconCode
  Future<void> fixDefaultCategories() async {
    try {
      final categories = await _isar.categoryModels
          .filter()
          .isDefaultEqualTo(true)
          .findAll();

      await _isar.writeTxn(() async {
        for (final category in categories) {
          if (!IconRegistry.isValidKey(category.iconKey)) {
            // تعيين iconKey الصحيح بناءً على الاسم
            category.iconKey = _getDefaultIconKeyByName(category.name);
            await _isar.categoryModels.put(category);

            if (kDebugMode) {
              print(
                  '  ✓ Fixed default category "${category.name}" → iconKey=${category.iconKey}');
            }
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Fix default categories failed: $e');
      }
    }
  }

  /// ✅ الحصول على iconKey الافتراضي بناءً على اسم التصنيف
  String _getDefaultIconKeyByName(String name) {
    final Map<String, String> defaultIconKeys = {
      'عمل': 'work',
      'منزل': 'home',
      'شخصي': 'person',
      'عام': 'label',
      'work': 'work',
      'home': 'home',
      'personal': 'person',
      'general': 'label',
    };

    return defaultIconKeys[name.toLowerCase()] ?? 'label';
  }
}
