import 'package:flutter/material.dart';

import '../../shared/role_workspace_screen.dart';

class AccountantDashboardScreen extends StatelessWidget {
  const AccountantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleWorkspaceScreen(
      title: 'Accountant',
      subtitle: 'Role workspace for invoices, reconciliation, payables, and reports.',
      focusAreas: [
        'Purchase and sales invoice management',
        'Customer receipts, supplier payments, and reconciliation',
        'Expenses, GST review, and financial reporting',
      ],
    );
  }
}
