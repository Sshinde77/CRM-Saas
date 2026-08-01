import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../screens/admin/audit_logs/audit_logs_screen.dart';
import '../../screens/admin/dashboard/admin_dashboard_screen.dart';
import '../../screens/admin/inventory/inventory_screen.dart';
import '../../screens/admin/notifications/notifications_screen.dart';
import '../../screens/admin/products/products_screen.dart';
import '../../screens/admin/purchases/purchases_screen.dart';
import '../../screens/admin/reports/reports_screen.dart';
import '../../screens/admin/settings/admin_settings_screen.dart';
import '../../screens/admin/settings/company_settings_screen.dart';
import '../../screens/admin/settings/plans_screen.dart';
import '../../screens/admin/users/admin_user_list_screen.dart';
import '../../screens/admin/invoices/invoices_screen.dart';
import '../../screens/admin/deliveries/deliveries_screen.dart';
import '../../screens/admin/expenses/expenses_screen.dart';
import '../../screens/admin/vehicles/vehicle_stock_screen.dart';

class _NavItem {
  final String label;
  final IconData icon;

  const _NavItem(this.label, this.icon);
}

/// Shared nav drawer used across every admin screen.
class AppDrawer extends StatefulWidget {
  final String activeItem;
  final String? activeSubItem;

  const AppDrawer({super.key, required this.activeItem, this.activeSubItem});

  static const Color blue = AppColors.blue;
  static const Color accent = AppColors.primary;
  static const Color drawerBackground = AppColors.adminSidebarBg;
  static const Color drawerSurface = AppColors.activeMenuBg;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  static const List<_NavItem> _navItems = [
    _NavItem('Dashboard', Icons.dashboard_outlined),
    _NavItem('Company Settings', Icons.storefront_outlined),
    _NavItem('Plans', Icons.workspace_premium_outlined),
    _NavItem('Staff', Icons.people_outline_rounded),
    _NavItem('Products', Icons.inventory_2_outlined),
    _NavItem('Inventory', Icons.warehouse_outlined),
    _NavItem('Vehicle Stock', Icons.local_shipping_outlined),
    _NavItem('Purchases', Icons.inventory_2_outlined),
    _NavItem('Deliveries', Icons.local_shipping_outlined),
    _NavItem('Expenses', Icons.receipt_long_outlined),
    _NavItem('Invoices', Icons.description_outlined),
    _NavItem('Reports', Icons.bar_chart_outlined),
    _NavItem('Notifications', Icons.notifications_none_rounded),
    _NavItem('Audit Logs', Icons.history_rounded),
    _NavItem('Settings', Icons.settings_outlined),
  ];

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  static const Color accent = AppDrawer.accent;

  void _handleTap(_NavItem item) {
    Navigator.of(context).pop();
    if (item.label == widget.activeItem) return;

    switch (item.label) {
      case 'Dashboard':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
        break;
      case 'Company Settings':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CompanySettingsScreen()),
        );
        break;
      case 'Plans':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PlansScreen()),
        );
        break;
      case 'Settings':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
        );
        break;
      case 'User Management':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminUserListScreen()),
        );
        break;
      case 'Products':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProductsScreen()),
        );
        break;
      case 'Vehicle Stock':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const VehicleStockScreen()),
        );
        break;
      case 'Inventory':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const InventoryScreen()),
        );
        break;
      case 'Purchases':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PurchasesScreen()),
        );
        break;
      case 'Invoices':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const InvoicesScreen()),
        );
        break;
      case 'Deliveries':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DeliveriesScreen()),
        );
        break;
      case 'Expenses':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ExpensesScreen()),
        );
        break;
      case 'Reports':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ReportsScreen()),
        );
        break;
      case 'Notifications':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
        break;
      case 'Audit Logs':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuditLogsScreen()),
        );
        break;
      default:
        // TODO: wire up the remaining nav items to their screens.
        break;
    }
  }

  Widget _buildNavRow(_NavItem item) {
    final isActive = item.label == widget.activeItem;
    final isUserManagementActive =
        item.label == 'User Management' && widget.activeSubItem != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleTap(item),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isActive ? AppDrawer.drawerSurface : Colors.transparent,
            ),
            child: Row(
              children: [
                if (isActive)
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                if (isActive) const SizedBox(width: 12),
                Icon(
                  item.icon,
                  size: 20,
                  color: isActive ? accent : AppDrawer.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isActive ? accent : AppDrawer.textSecondary,
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
                if (isUserManagementActive)
                  Text(
                    widget.activeSubItem!,
                    style: const TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppDrawer.drawerBackground,
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppDrawer.accent, AppDrawer.blue],
                      ),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SAAS CRM',
                          style: TextStyle(
                            color: AppDrawer.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Admin',
                          style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: AppDrawer.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: AppDrawer.textPrimary.withValues(alpha: 0.08),
              height: 1,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                children: AppDrawer._navItems.map(_buildNavRow).toList(),
              ),
            ),
            Divider(
              color: AppDrawer.textPrimary.withValues(alpha: 0.08),
              height: 1,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppDrawer.accent.withValues(alpha: 0.14),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'AS',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Anita Sharma',
                          style: TextStyle(
                            color: AppDrawer.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'admin@demo.com',
                          style: TextStyle(
                            color: AppDrawer.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
