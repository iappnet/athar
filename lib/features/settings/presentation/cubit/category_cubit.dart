import 'package:bloc/bloc.dart';
// import 'package:flutter/material.dart'; // للطباعة debugPrint
import 'package:injectable/injectable.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  CategoryLoaded(this.categories);
}

@injectable
class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repository;

  CategoryCubit(this._repository) : super(CategoryInitial());

  // ✅ تم تحويل الدالة إلى async لضمان الترتيب
  Future<void> loadCategories() async {
    // 1. تأكد من وجود التصنيفات أولاً
    await _repository.ensureDefaultCategories();

    // 2. ابدأ المراقبة
    _repository.watchCategories().listen((categories) {
      emit(CategoryLoaded(categories));
    });
  }

  void addCategory(String name, int color, int iconCode) async {
    final newCat = CategoryModel(
      name: name,
      colorValue: color,
      iconCode: iconCode,
      isDefault: false,
    );
    await _repository.addCategory(newCat);
    // لا نحتاج لاستدعاء loadCategories لأن الـ watch سيحدث الواجهة تلقائياً
  }

  void deleteCategory(CategoryModel category) async {
    // ✅ السماح بحذف أي تصنيف (حرية المستخدم)
    await _repository.deleteCategory(category.id);
  }
}
