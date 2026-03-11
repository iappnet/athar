import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'category_model.g.dart';

@Collection()
class CategoryModel {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name; // اسم التصنيف (عمل، دراسة، رياضة...)

  int colorValue; // لون التصنيف
  int? iconCode; // رمز الأيقونة (اختياري)

  bool isDefault; // هل هو تصنيف أساسي (لا يحذف)؟

  CategoryModel({
    required this.name,
    required this.colorValue,
    this.iconCode,
    this.isDefault = false,
  });

  // دوال مساعدة لإنشاء التصنيفات الافتراضية
  static List<CategoryModel> get defaultCategories => [
    CategoryModel(
      name: "عمل",
      colorValue: 0xFF2196F3,
      iconCode: Icons.work.codePoint,
      isDefault: true,
    ), // Icons.work
    CategoryModel(
      name: "منزل",
      colorValue: 0xFF4CAF50,
      iconCode: Icons.home.codePoint,
      isDefault: true,
    ), // Icons.home
    CategoryModel(
      name: "شخصي",
      colorValue: 0xFFFF9800,
      iconCode: Icons.person.codePoint,
      isDefault: true,
    ), // Icons.person
    CategoryModel(
      name: "عام",
      colorValue: 0xFFE91E63,
      iconCode: Icons.fitness_center.codePoint,
      isDefault: true,
    ),
  ];
}
