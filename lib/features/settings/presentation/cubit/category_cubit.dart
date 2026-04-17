// lib/features/settings/presentation/cubit/category_cubit.dart
// ═══════════════════════════════════════════════════════════════════════════════
// 📁 CATEGORY CUBIT - إدارة حالة التصنيفات
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// 📊 حالات التصنيفات
// ═══════════════════════════════════════════════════════════════════════════════

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  CategoryLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}

// ═══════════════════════════════════════════════════════════════════════════════
// 🎮 CATEGORY CUBIT
// ═══════════════════════════════════════════════════════════════════════════════

@injectable
class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;

  CategoryCubit(this._repository) : super(CategoryInitial());

  // ═══════════════════════════════════════════════════════════════════════════
  // 📥 تحميل التصنيفات
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> loadCategories() async {
    try {
      // 1. تأكد من وجود التصنيفات أولاً
      await _repository.ensureDefaultCategories();

      // 2. ابدأ المراقبة
      _repository.watchCategories().listen(
        (categories) {
          emit(CategoryLoaded(categories));
        },
        onError: (error) {
          emit(CategoryError(error.toString()));
        },
      );
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ➕ إضافة تصنيف جديد
  // ═══════════════════════════════════════════════════════════════════════════

  /// ✅ الطريقة الجديدة: استخدام iconKey
  Future<void> addCategory({
    required String name,
    required int colorValue,
    required String iconKey,
  }) async {
    try {
      final newCat = CategoryModel(
        name: name,
        colorValue: colorValue,
        iconKey: iconKey,
        isDefault: false,
      );
      await _repository.addCategory(newCat);
      // لا نحتاج لاستدعاء loadCategories لأن الـ watch سيحدث الواجهة تلقائياً
    } catch (e) {
      emit(CategoryError('فشل إضافة التصنيف: $e'));
    }
  }

  /// ❌ الطريقة القديمة: للتوافق مع الكود القديم (Deprecated)
  @Deprecated('Use addCategory with iconKey parameter instead')
  Future<void> addCategoryLegacy(String name, int color, int iconCode) async {
    // تحويل iconCode إلى iconKey
    final iconKey = _iconCodeToKey(iconCode);
    await addCategory(name: name, colorValue: color, iconKey: iconKey);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ✏️ تعديل تصنيف
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _repository.updateCategory(category);
    } catch (e) {
      emit(CategoryError('فشل تعديل التصنيف: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🗑️ حذف تصنيف
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> deleteCategory(CategoryModel category) async {
    try {
      await _repository.deleteCategory(category.id);
    } catch (e) {
      emit(CategoryError('فشل حذف التصنيف: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 دوال مساعدة
  // ═══════════════════════════════════════════════════════════════════════════

  /// تحويل iconCode القديم إلى iconKey
  String _iconCodeToKey(int iconCode) {
    // استخدام IconRegistry للتحويل
    const Map<int, String> legacyIconMap = {
      0xe8f9: 'work', // Icons.work
      0xe88a: 'home', // Icons.home
      0xe7fd: 'person', // Icons.person
      0xe3a3: 'fitness', // Icons.fitness_center
      0xe8e6: 'bookmark', // Icons.bookmark
      0xe867: 'label', // Icons.label
    };

    return legacyIconMap[iconCode] ?? 'label';
  }
}

// import 'package:bloc/bloc.dart';
// // import 'package:flutter/material.dart'; // للطباعة debugPrint
// import 'package:injectable/injectable.dart';
// import '../../data/models/category_model.dart';
// import '../../data/repositories/category_repository.dart';

// abstract class CategoryState {}

// class CategoryInitial extends CategoryState {}

// class CategoryLoading extends CategoryState {}

// class CategoryLoaded extends CategoryState {
//   final List<CategoryModel> categories;
//   CategoryLoaded(this.categories);
// }

// @injectable
// class CategoryCubit extends Cubit<CategoryState> {
//   final CategoryRepository _repository;

//   CategoryCubit(this._repository) : super(CategoryInitial());

//   // ✅ تم تحويل الدالة إلى async لضمان الترتيب
//   Future<void> loadCategories() async {
//     // 1. تأكد من وجود التصنيفات أولاً
//     await _repository.ensureDefaultCategories();

//     // 2. ابدأ المراقبة
//     _repository.watchCategories().listen((categories) {
//       emit(CategoryLoaded(categories));
//     });
//   }

//   void addCategory(String name, int color, int iconCode) async {
//     final newCat = CategoryModel(
//       name: name,
//       colorValue: color,
//       iconCode: iconCode,
//       isDefault: false,
//     );
//     await _repository.addCategory(newCat);
//     // لا نحتاج لاستدعاء loadCategories لأن الـ watch سيحدث الواجهة تلقائياً
//   }

//   void deleteCategory(CategoryModel category) async {
//     // ✅ السماح بحذف أي تصنيف (حرية المستخدم)
//     await _repository.deleteCategory(category.id);
//   }
// }
