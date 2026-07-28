import 'package:flutter/material.dart';

import '../../shared/role_workspace_screen.dart';

class SalesManagerDashboardScreen extends StatelessWidget {
  const SalesManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleWorkspaceScreen(
      title: 'Sales Manager',
      subtitle: 'Role workspace for customer coverage, follow-ups, and sales performance.',
      focusAreas: [
        'Assigned customers and visit planning',
        'Sales orders and follow-up tracking',
        'Targets, collections, and field performance',
      ],
    );
  }
}
