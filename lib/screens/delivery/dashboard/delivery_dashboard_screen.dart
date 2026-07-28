import 'package:flutter/material.dart';

import '../../shared/role_workspace_screen.dart';

class DeliveryDashboardScreen extends StatelessWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleWorkspaceScreen(
      title: 'Delivery',
      subtitle: 'Role workspace for deliveries, vehicle stock, collections, and expenses.',
      focusAreas: [
        'Assigned deliveries and status updates',
        'Vehicle load, returns, and stock variance',
        'Payment collection and daily expense recording',
      ],
    );
  }
}
