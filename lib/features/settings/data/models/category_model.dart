// lib/features/settings/data/models/category_model.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 📁 CATEGORY MODEL - نموذج التصنيف المُحدث مع دعم IconRegistry
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:athar/core/utils/icon_registry.dart';

part 'category_model.g.dart';

@Collection()
class CategoryModel {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name; // اسم التصنيف (عمل، دراسة، رياضة...)

  int colorValue; // لون التصنيف

  // ✅ جديد: مفتاح الأيقونة (بدلاً من iconCode)
  String iconKey;

  // ❌ قديم: للتوافق مع البيانات القديمة فقط - سيتم إزالته لاحقاً
  @Deprecated('Use iconKey instead. Will be removed in future versions.')
  int? iconCode;

  bool isDefault; // هل هو تصنيف أساسي (لا يحذف)؟

  CategoryModel({
    required this.name,
    required this.colorValue,
    this.iconKey = 'label', // ✅ القيمة الافتراضية
    @Deprecated('Use iconKey instead') this.iconCode,
    this.isDefault = false,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎨 الحصول على الأيقونة - الطريقة الجديدة الآمنة
  // ═══════════════════════════════════════════════════════════════════════════

  /// ✅ الحصول على الأيقونة مباشرة من IconRegistry
  @ignore
  IconData get icon {
    // أولاً: حاول استخدام iconKey الجديد
    if (iconKey.isNotEmpty && IconRegistry.isValidKey(iconKey)) {
      return IconRegistry.getIcon(iconKey);
    }

    // ثانياً: للتوافق - حاول تحويل iconCode القديم
    // ignore: deprecated_member_use_from_same_package
    if (iconCode != null) {
      // ignore: deprecated_member_use_from_same_package
      return IconRegistry.getIcon(IconRegistry.migrateFromIconCode(iconCode));
    }

    // ثالثاً: أرجع الأيقونة الافتراضية
    return IconRegistry.defaultIcon;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📦 التصنيفات الافتراضية
  // ═══════════════════════════════════════════════════════════════════════════

  static List<CategoryModel> get defaultCategories => [
    CategoryModel(
      name: "عمل",
      colorValue: 0xFF2196F3, // أزرق
      iconKey: 'work',
      isDefault: true,
    ),
    CategoryModel(
      name: "منزل",
      colorValue: 0xFF4CAF50, // أخضر
      iconKey: 'home',
      isDefault: true,
    ),
    CategoryModel(
      name: "شخصي",
      colorValue: 0xFFFF9800, // برتقالي
      iconKey: 'person',
      isDefault: true,
    ),
    CategoryModel(
      name: "عام",
      colorValue: 0xFFE91E63, // وردي
      iconKey: 'label',
      isDefault: true,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔄 دوال التحويل والتهجير
  // ═══════════════════════════════════════════════════════════════════════════

  /// ✅ تهجير البيانات القديمة: تحويل iconCode إلى iconKey
  void migrateIconCodeToKey() {
    // ignore: deprecated_member_use_from_same_package
    if (iconKey.isEmpty && iconCode != null) {
      // ignore: deprecated_member_use_from_same_package
      iconKey = IconRegistry.migrateFromIconCode(iconCode);
    }
  }

  /// ✅ إنشاء نسخة مع تحديثات
  CategoryModel copyWith({
    String? name,
    int? colorValue,
    String? iconKey,
    bool? isDefault,
  }) {
    return CategoryModel(
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconKey: iconKey ?? this.iconKey,
      isDefault: isDefault ?? this.isDefault,
    )..id = id;
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, iconKey: $iconKey, colorValue: $colorValue, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// import 'package:flutter/material.dart';
// import 'package:isar/isar.dart';

// part 'category_model.g.dart';

// @Collection()
// class CategoryModel {
//   Id id = Isar.autoIncrement;

//   @Index(type: IndexType.value)
//   late String name; // اسم التصنيف (عمل، دراسة، رياضة...)

//   int colorValue; // لون التصنيف
//   int? iconCode; // رمز الأيقونة (اختياري)

//   bool isDefault; // هل هو تصنيف أساسي (لا يحذف)؟

//   CategoryModel({
//     required this.name,
//     required this.colorValue,
//     this.iconCode,
//     this.isDefault = false,
//   });

//   // دوال مساعدة لإنشاء التصنيفات الافتراضية
//   static List<CategoryModel> get defaultCategories => [
//     CategoryModel(
//       name: "عمل",
//       colorValue: 0xFF2196F3,
//       iconCode: Icons.work.codePoint,
//       isDefault: true,
//     ), // Icons.work
//     CategoryModel(
//       name: "منزل",
//       colorValue: 0xFF4CAF50,
//       iconCode: Icons.home.codePoint,
//       isDefault: true,
//     ), // Icons.home
//     CategoryModel(
//       name: "شخصي",
//       colorValue: 0xFFFF9800,
//       iconCode: Icons.person.codePoint,
//       isDefault: true,
//     ), // Icons.person
//     CategoryModel(
//       name: "عام",
//       colorValue: 0xFFE91E63,
//       iconCode: Icons.fitness_center.codePoint,
//       isDefault: true,
//     ),
//   ];
// }
