import 'package:flutter/material.dart';

import '../screens/admin/reports/reports_screen.dart';
import '../screens/admin/notifications/notifications_screen.dart';
import '../screens/admin/audit_logs/audit_logs_screen.dart';
import '../screens/admin/vehicles/vehicle_stock_screen.dart';
import '../screens/delivery/attendance/delivery_attendance_screen.dart';
import '../screens/delivery/dashboard/delivery_dashboard_screen.dart';
import '../screens/delivery/deliveries/assigned_deliveries_screen.dart';
import '../screens/delivery/deliveries/delivery_detail_screen.dart';
import '../screens/delivery/vehicle_stock/delivery_vehicle_stock_screen.dart';
import '../screens/role_home_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String login = '/';
  static const String home = '/home';
  static const String reports = '/reports';
  static const String notifications = '/notifications';
  static const String auditLogs = '/audit-logs';
  static const String adminVehicleStock = '/admin/vehicle-stock';
  static const String deliveryDashboard = '/delivery/dashboard';
  static const String deliveryDeliveries = '/delivery/deliveries';
  static const String deliveryVehicleStock = '/delivery/vehicle-stock';
  static const String deliveryAttendance = '/delivery/attendance';
  static const String deliveryLeaves = '/delivery/leaves';
  static const String deliveryExpenses = '/delivery/expenses';
  static const String deliveryEndOfDay = '/delivery/end-of-day';
  static const String deliveryVehicleLoading = '/delivery/vehicle-loading';

  static String deliveryDetail(String deliveryId) =>
      '$deliveryDeliveries/$deliveryId';
}

class AppRouter {
  const AppRouter._();

  static Map<String, WidgetBuilder> get routes {
    return {
      AppRoutes.home: (_) => const RoleHomeScreen(),
      AppRoutes.reports: (_) => const ReportsScreen(),
      AppRoutes.notifications: (_) => const NotificationsScreen(),
      AppRoutes.auditLogs: (_) => const AuditLogsScreen(),
      AppRoutes.adminVehicleStock: (_) => const VehicleStockScreen(),
      AppRoutes.deliveryDashboard: (_) => const DeliveryDashboardScreen(),
      AppRoutes.deliveryDeliveries: (_) => const AssignedDeliveriesScreen(),
      AppRoutes.deliveryAttendance: (_) => const DeliveryAttendanceScreen(),
      AppRoutes.deliveryVehicleStock: (_) => const DeliveryVehicleStockScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '';
    const detailPrefix = '${AppRoutes.deliveryDeliveries}/';
    if (routeName.startsWith(detailPrefix)) {
      final deliveryId = routeName.substring(detailPrefix.length).trim();
      if (deliveryId.isNotEmpty) {
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => DeliveryDetailScreen(deliveryId: deliveryId),
        );
      }
    }
    return null;
  }
}
