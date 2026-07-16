import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String login = '/';
  static const String home = '/home';
}

class AppRouter {
  const AppRouter._();

  static Map<String, WidgetBuilder> get routes {
    return {
      AppRoutes.login: (_) => const LoginScreen(),
      AppRoutes.home: (_) => const HomeScreen(),
    };
  }
}
