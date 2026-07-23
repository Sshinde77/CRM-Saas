import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../screens/dashboard/admin_dashboard_screen.dart';
import '../screens/settings/admin_settings_screen.dart';
import '../screens/settings/company_settings_screen.dart';
import '../screens/users/admin_user_list_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/invoices/invoices_screen.dart';
import '../screens/deliveries/deliveries_screen.dart';
import '../screens/expenses/expenses_screen.dart';
import '../screens/vehicles/vehicle_stock_screen.dart';
import '../screens/inventory/inventory_screen.dart';
import '../screens/purchases/purchases_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/audit_logs/audit_logs_screen.dart';

// Place this file at: lib/widgets/app_drawer.dart

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

/// Shared nav drawer used across every admin screen (Dashboard, Company
/// Settings, etc). Pass in the current screen's label via [activeItem] so it
/// gets highlighted; tapping any other item swaps to that screen.
class AppDrawer extends StatelessWidget {
  final String activeItem;
  final String? activeSubItem;

  const AppDrawer({super.key, required this.activeItem, this.activeSubItem});

  static const Color purple = AppColors.purple;
  static const Color blue = AppColors.blue;
  static const Color accent = purple;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  static const List<_NavItem> _navItems = [
    _NavItem('Dashboard', Icons.dashboard_outlined),
    _NavItem('Company Settings', Icons.storefront_outlined),
    _NavItem('User Management', Icons.people_alt_outlined),
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

  void _handleTap(BuildContext context, _NavItem item) {
    Navigator.of(context).pop(); // close the drawer first
    if (item.label == activeItem) return; // already on this screen

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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primary,
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
                      gradient: const LinearGradient(colors: [purple, blue]),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: AppColors.primary,
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
                            color: textPrimary,
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
                    child: Icon(Icons.close, color: textSecondary, size: 22),
                  ),
                ],
              ),
            ),
            Divider(color: textPrimary.withValues(alpha: 0.08), height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                itemCount: _navItems.length,
                itemBuilder: (context, i) {
                  final item = _navItems[i];
                  final bool active = item.label == activeItem;
                  final Color rowColor = active ? purple : textSecondary;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _handleTap(context, item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: active ? purple.withValues(alpha: 0.10) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: active
                                ? Border(left: BorderSide(color: purple, width: 3))
                                : const Border(left: BorderSide(color: Colors.transparent, width: 3)),
                          ),
                          child: Row(
                            children: [
                              Icon(item.icon, color: rowColor, size: 21),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: rowColor,
                                    fontSize: 14.5,
                                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Divider(color: textPrimary.withValues(alpha: 0.08), height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: purple.withValues(alpha: 0.15),
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
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'admin@demo.com',
                          style: TextStyle(color: textSecondary, fontSize: 12),
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
