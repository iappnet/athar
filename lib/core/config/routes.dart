import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const Scaffold(body: Center(child: Text('Home')))),
    ],
  );
}
