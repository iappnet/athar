import 'package:athar/features/assets/data/models/asset_model.dart';

abstract class AssetsState {}

class AssetsInitial extends AssetsState {}

class AssetsLoading extends AssetsState {}

class AssetsLoaded extends AssetsState {
  final List<AssetModel> assets;

  // يمكننا إضافة فلاتر هنا لاحقاً (مثلاً: عرض المنتهية فقط)
  AssetsLoaded(this.assets);
}

class AssetsError extends AssetsState {
  final String message;
  AssetsError(this.message);
}

// حالة خاصة عند نجاح عملية (مثل الإضافة) لعرض رسالة نجاح
class AssetOperationSuccess extends AssetsState {
  final String message;
  AssetOperationSuccess(this.message);
}
