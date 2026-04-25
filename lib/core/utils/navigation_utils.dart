import 'package:athar/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:athar/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationUtils {
  NavigationUtils._();

  static String fallbackRouteFor(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthUnauthenticated) {
      return '/login';
    }
    return '/home';
  }

  static Future<void> safeBack(
    BuildContext context, {
    String? fallbackRoute,
  }) async {
    final navigator = Navigator.of(context);
    final route = ModalRoute.of(context);
    final targetRoute = fallbackRoute ?? fallbackRouteFor(context);

    if (navigator.canPop() && !(route?.isFirst ?? false)) {
      navigator.pop();
      return;
    }

    await navigator.pushNamedAndRemoveUntil(targetRoute, (route) => false);
  }

  static Future<void> resetToUnauthenticated(BuildContext context) async {
    await Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }
}
