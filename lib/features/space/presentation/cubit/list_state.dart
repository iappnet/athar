import 'package:athar/features/space/data/models/list_item_model.dart';

abstract class ListState {}

class ListInitial extends ListState {}

class ListLoading extends ListState {}

class ListLoaded extends ListState {
  final List<ListItemModel> items;
  // يمكننا إضافة إحصائيات هنا مستقبلاً (مثلاً: 5/10 مكتمل)
  ListLoaded(this.items);
}

class ListError extends ListState {
  final String message;
  ListError(this.message);
}
