import 'package:flutter/material.dart';

import '../../core/roles/app_role.dart';
import '../../providers/api_provider.dart';
import '../../screens/admin/leads/admin_leads_screen.dart';
import '../../screens/admin/orders/admin_orders_screen.dart';
import '../../screens/admin/orders/new_admin_order_screen.dart';
import '../../screens/admin/quotations/admin_quotations_screen.dart';
import '../../screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart';
import '../../screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart';
import '../../screens/sales_manager/performance/sales_manager_performance_screen.dart';
import '../../screens/sales_manager/stock/sales_manager_stock_screen.dart';
import '../../screens/sales_manager/visits/sales_manager_visits_screen.dart';
import 'sales_manager_sidebar.dart';

bool isSalesManagerSession(BuildContext context) {
  final provider = ApiProviderScope.of(context);
  final user = provider.currentUser ?? provider.authMe?.user;
  return AppRole.fromRaw(user?.role) == AppRole.salesManager;
}

Widget buildSalesManagerDrawer({
  required BuildContext context,
  required String currentPage,
}) {
  return SalesManagerSidebarDrawer(
    currentPage: currentPage,
    onSelect: (action) => _openSalesManagerPage(context, action),
  );
}

void _openSalesManagerPage(BuildContext context, String action) {
  final destination = switch (action) {
    'Dashboard' => const SalesManagerDashboardScreen(),
    'Leads' => const AdminLeadsScreen(useSalesManagerShell: true),
    'Quotations' || 'Quotation' =>
      const AdminQuotationsScreen(useSalesManagerShell: true),
    'Sales Orders' => const AdminOrdersScreen(useSalesManagerShell: true),
    'Create Order' => const NewAdminOrderScreen(useSalesManagerShell: true),
    'Stock' => const SalesManagerStockScreen(),
    'Visits' => const SalesManagerVisitsScreen(),
    'Follow-Ups' || 'Follow-ups' => const SalesManagerFollowUpsScreen(),
    'My Performance' => const SalesManagerPerformanceScreen(),
    _ => null,
  };

  Navigator.of(context).pop();
  if (destination == null) return;
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => destination),
  );
}
