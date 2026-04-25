import 'dart:async';
import 'package:athar/core/di/injection.dart';
import 'package:athar/core/services/local_notification_service.dart';
import 'package:athar/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/notifications_repository.dart';

@injectable
class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationsRepository _repository;
  StreamSubscription? _subscription;

  NotificationsCubit(this._repository) : super(NotificationsInitial());

  void watchNotifications() {
    emit(NotificationsLoading());
    _subscription?.cancel();
    _subscription = _repository.watchNotifications().listen((list) {
      final unread = list.where((n) => !n.isRead).length;
      if (isClosed) return;
      emit(NotificationsLoaded(list, unread));
      // Keep the app icon badge in sync with actual unread count
      getIt<LocalNotificationService>().setAppBadge(unread);
    });
    _repository.syncNotifications(); // background sync
  }

  Future<void> markAsRead(String uuid) async =>
      await _repository.markAsRead(uuid);

  Future<void> clearAll() async => await _repository.clearAll();

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
