import 'package:flutter/material.dart';

import '../core/roles/app_role.dart';
import '../providers/api_provider.dart';
import 'accountant/dashboard/accountant_dashboard_screen.dart';
import 'admin/dashboard/admin_dashboard_screen.dart';
import 'delivery/dashboard/delivery_dashboard_screen.dart';
import 'sales_manager/dashboard/sales_manager_dashboard_screen.dart';
import 'shared/role_workspace_screen.dart';

class RoleHomeScreen extends StatelessWidget {
  final String? role;

  const RoleHomeScreen({super.key, this.role});

  static Widget forRole(String? role) {
    return RoleHomeScreen(role: role);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedRole =
        role ?? ApiProviderScope.maybeOf(context)?.currentUser?.role;

    switch (AppRole.fromRaw(resolvedRole)) {
      case AppRole.admin:
        return const AdminDashboardScreen();
      case AppRole.salesManager:
        return const SalesManagerDashboardScreen();
      case AppRole.delivery:
        return const DeliveryDashboardScreen();
      case AppRole.accountant:
        return const AccountantDashboardScreen();
      case AppRole.unknown:
        return RoleWorkspaceScreen(
          title: 'Workspace',
          subtitle:
              'Role-specific modules are now organized by folder. This role does not have a dedicated dashboard mapping yet.',
          focusAreas: [
            'Current role: ${resolvedRole?.trim().isEmpty ?? true ? 'Unknown' : resolvedRole!.trim()}',
            'Add a dedicated screen under lib/screens/<role>/',
            'Wire that role into lib/core/roles/app_role.dart',
          ],
        );
    }
  }
}
