// lib/core/services/appointment_notifier.dart
//
// Lightweight broadcast notifier for appointment mutations.
// HealthCubit calls notify() after add/update/delete; CalendarCubit
// subscribes and re-fetches the selected date when it fires.
// Avoids making HealthCubit global or coupling the two features directly.

import 'dart:async';
import 'package:injectable/injectable.dart';

@lazySingleton
class AppointmentNotifier {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notify() => _controller.add(null);
}
