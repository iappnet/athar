// import 'package:flutter/material.dart';

import '../../../settings/data/models/category_model.dart';

/// واجهة موحدة لأي عنصر يمكن استخدامه كفلتر
abstract class FilterItem {
  String get label;
  dynamic get id; // للتمييز (Enum value أو DB ID)
  bool get isDynamic; // هل هو تصنيف من القاعدة أم ثابت؟
}

/// 1. الفلاتر الثابتة (Enum)
enum FixedFilterType implements FilterItem {
  all("الكل"),
  task("المهام"),
  urgent("عاجل"),
  medicine("الدواء"),
  appointment("المواعيد");

  final String _label;
  const FixedFilterType(this._label);

  @override
  String get label => _label;

  @override
  dynamic get id => this; // الـ Enum نفسه هو المعرف

  @override
  bool get isDynamic => false;
}

/// 2. تغليف (Wrapper) للتصنيفات لتتوافق مع الواجهة
class CategoryFilter implements FilterItem {
  final CategoryModel category;

  CategoryFilter(this.category);

  @override
  String get label => category.name; // استخدام الاسم مباشرة

  // @override
  // String get label =>
  //     "${String.fromCharCode(category.iconCode ?? Icons.label.codePoint)} ${category.name}";

  @override
  dynamic get id => category.id;

  @override
  bool get isDynamic => true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryFilter &&
          runtimeType == other.runtimeType &&
          category.id == other.category.id;

  @override
  int get hashCode => category.id.hashCode;
}
