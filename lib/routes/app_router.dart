import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/audit_logs/audit_logs_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String login = '/';
  static const String home = '/home';
  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String auditLogs = '/audit-logs';
}

class AppRouter {
  const AppRouter._();

  static Map<String, WidgetBuilder> get routes {
    return {
      AppRoutes.login: (_) => const LoginScreen(),
      AppRoutes.home: (_) => const HomeScreen(),
      AppRoutes.reports: (_) => const ReportsScreen(),
      AppRoutes.notifications: (_) => const NotificationsScreen(),
      AppRoutes.auditLogs: (_) => const AuditLogsScreen(),
    };
  }
}
