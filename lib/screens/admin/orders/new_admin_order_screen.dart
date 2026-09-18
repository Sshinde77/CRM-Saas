import 'package:flutter/material.dart';

import '../../../widgets/admin/app_drawer.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../delivery/orders/create_delivery_order_screen.dart';
import '../../sales_manager/attendance/sales_manager_attendance_screen.dart';
import '../../sales_manager/dashboard/sales_manager_dashboard_screen.dart';
import '../../sales_manager/follow_ups/sales_manager_follow_ups_screen.dart';
import '../../sales_manager/performance/sales_manager_performance_screen.dart';
import '../../sales_manager/stock/sales_manager_stock_screen.dart';
import '../../sales_manager/visits/sales_manager_visits_screen.dart';
import '../customers/customers_screen.dart';
import '../leads/admin_leads_screen.dart';
import '../quotations/admin_quotations_screen.dart';
import 'admin_orders_screen.dart';

/// The shared order form used by Admin and Sales Manager.
/// It uses the same preview, stock checks, and create request as Delivery.
class NewAdminOrderScreen extends StatelessWidget {
  final bool useSalesManagerShell;

  const NewAdminOrderScreen({super.key, this.useSalesManagerShell = false});

  void _handleSalesManagerSelection(BuildContext context, String action) {
    Navigator.of(context).pop(); // Close the sidebar.
    if (action == 'Create Order') return;

    final Widget? destination = switch (action) {
      'Dashboard' => const SalesManagerDashboardScreen(),
      'Customers' => const CustomersScreen(useSalesManagerShell: true),
      'Leads' => const AdminLeadsScreen(useSalesManagerShell: true),
      'Sales Orders' => const AdminOrdersScreen(useSalesManagerShell: true),
      'Quotations' ||
      'Quotation' => const AdminQuotationsScreen(useSalesManagerShell: true),
      'Stock' => const SalesManagerStockScreen(),
      'Follow-ups' || 'Follow-Ups' => const SalesManagerFollowUpsScreen(),
      'Attendance' => const SalesManagerAttendanceScreen(),
      'Visits' => const SalesManagerVisitsScreen(),
      'My Performance' => const SalesManagerPerformanceScreen(),
      _ => null,
    };
    if (destination != null) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => destination));
    }
  }

  @override
  Widget build(BuildContext context) => CreateDeliveryOrderScreen(
    assignDeliveryPartner: true,
    drawer: useSalesManagerShell
        ? SalesManagerSidebarDrawer(
            currentPage: 'Create Order',
            onSelect: (action) => _handleSalesManagerSelection(context, action),
          )
        : const AppDrawer(activeItem: 'Orders'),
  );
}
