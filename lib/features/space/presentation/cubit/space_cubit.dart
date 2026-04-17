import 'dart:async';
import 'package:athar/features/space/data/repositories/space_repository_impl.dart';
import 'package:athar/features/space/domain/repositories/space_repository.dart';
import 'package:athar/features/space/presentation/cubit/space_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/space_model.dart';

// --- Cubit ---
@injectable
class SpaceCubit extends Cubit<SpaceState> {
  final SpaceRepository _repository;
  StreamSubscription? _subscription;

  SpaceCubit(this._repository) : super(SpaceInitial());

  // تحميل ومراقبة المساحات
  void loadSpaces() async {
    emit(SpaceLoading());

    // التأكد من وجود مساحة شخصية أولاً
    await _repository.ensurePersonalSpaceExists();

    _subscription?.cancel();
    _subscription = _repository.watchMySpaces().listen(
      (spaces) {
        // إذا كان لدينا مساحات ولم نحدد مساحة مختارة، نختار الأولى (الشخصية)
        SpaceModel? selected;
        if (state is SpaceLoaded) {
          selected = (state as SpaceLoaded).selectedSpace;
        }

        // إذا لم يكن هناك مساحة مختارة، أو المساحة المختارة حذفت، نختار الأولى
        if (selected == null && spaces.isNotEmpty) {
          // عادة المساحة الشخصية تكون الأولى بسبب ترتيب الإنشاء
          selected = spaces.firstWhere(
            (s) => s.type == 'personal',
            orElse: () => spaces.first,
          );
        }

        emit(SpaceLoaded(spaces, selectedSpace: selected));
      },
      onError: (e) {
        emit(SpaceError("فشل تحميل المساحات: $e"));
      },
    );
  }

  // تغيير المساحة النشطة (عند الضغط في الـ Drawer)
  void switchSpace(SpaceModel space) {
    if (state is SpaceLoaded) {
      final currentSpaces = (state as SpaceLoaded).spaces;
      emit(SpaceLoaded(currentSpaces, selectedSpace: space));
    }
  }

  // إنشاء مساحة جديدة
  // Future<void> createSpace(String name, {bool isShared = false}) async {
  //   try {
  //     await _repository.createSpace(
  //       name: name,
  //       type: isShared ? 'shared' : 'personal',
  //     );
  //     // لا نحتاج لعمل emit لأن الـ Stream سيحدث القائمة تلقائياً
  //   } catch (e) {
  //     emit(SpaceError("فشل إنشاء المساحة"));
  //     // نعيد تحميل الحالة السابقة
  //     loadSpaces();
  //   }
  // }

  Future<void> createSpace(String name, {bool isShared = false}) async {
    try {
      // ✅ التحقق من تسجيل الدخول للمساحات المشتركة
      if (isShared) {
        final currentUser = Supabase.instance.client.auth.currentUser;
        if (currentUser == null) {
          emit(SpaceError("يجب تسجيل الدخول لإنشاء مساحة مشتركة"));
          loadSpaces(); // إعادة تحميل الحالة السابقة
          return;
        }
      }

      await _repository.createSpace(
        name: name,
        type: isShared ? 'shared' : 'personal',
      );
      // لا نحتاج لعمل emit لأن الـ Stream سيحدث القائمة تلقائياً
    } catch (e) {
      if (e is SharedSpaceException) {
        emit(SpaceError(e.message));
      } else {
        emit(SpaceError("فشل إنشاء المساحة"));
      }
      loadSpaces();
    }
  }

  // ✅ دالة تحديث تفويض المساحة
  Future<void> updateSpaceDelegation(String uuid, bool allow) async {
    try {
      await _repository.updateSpaceDelegation(uuid, allow);
      // إعادة تحميل المساحات لتحديث الواجهة
      loadSpaces();
    } catch (e) {
      // handle error
    }
  }

  // ✅✅ أضف هذه الدالة لحل الخطأ
  Future<void> deleteSpace(String uuid) async {
    try {
      await _repository.deleteSpace(uuid);
      // لا نحتاج لإعادة التحميل يدوياً لأننا نستخدم stream (watchMySpaces)
      // التحديث سيحدث تلقائياً في الواجهة بمجرد الحذف من قاعدة البيانات
    } catch (e) {
      emit(SpaceError("فشل حذف المساحة"));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
