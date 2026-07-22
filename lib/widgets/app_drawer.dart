import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../screens/dashboard/admin_dashboard_screen.dart';
import '../screens/settings/admin_settings_screen.dart';
import '../screens/settings/company_settings_screen.dart';
import '../screens/users/admin_user_list_screen.dart';
import '../screens/users/admin_user_management_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/vehicles/vehicle_stock_screen.dart';

// Place this file at: lib/widgets/app_drawer.dart

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

/// Shared nav drawer used across every admin screen (Dashboard, Company
/// Settings, etc). Pass in the current screen's label via [activeItem] so it
/// gets highlighted; tapping any other item swaps to that screen.
class AppDrawer extends StatefulWidget {
  final String activeItem;
  final String? activeSubItem;

  const AppDrawer({super.key, required this.activeItem, this.activeSubItem});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isUserManagementExpanded = false;

  static const Color accent = AppColors.secondary;
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
    _NavItem('Suppliers', Icons.people_outline),
    _NavItem('Deliveries', Icons.local_shipping_outlined),
    _NavItem('Expenses', Icons.receipt_long_outlined),
    _NavItem('Invoices', Icons.description_outlined),
    _NavItem('Returns', Icons.replay_outlined),
    _NavItem('Leave Approvals', Icons.event_available_outlined),
    _NavItem('Reports', Icons.bar_chart_outlined),
    _NavItem('Notifications', Icons.notifications_none_rounded),
    _NavItem('Audit Logs', Icons.history_rounded),
    _NavItem('Settings', Icons.settings_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _isUserManagementExpanded = _shouldExpandUserManagement;
  }

  @override
  void didUpdateWidget(covariant AppDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldExpandUserManagement && !_isUserManagementExpanded) {
      _isUserManagementExpanded = true;
    }
  }

  bool get _shouldExpandUserManagement =>
      widget.activeItem == 'User Management' || widget.activeSubItem != null;

  void _handleTap(BuildContext context, _NavItem item) {
    Navigator.of(context).pop(); // close the drawer first
    if (item.label == widget.activeItem) return; // already on this screen

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
          MaterialPageRoute(builder: (_) => const AdminUserManagementScreen()),
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
      default:
        // TODO: wire up the remaining nav items to their screens, e.g.
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (_) => const ProductsScreen()),
        // );
        break;
    }
  }

  void _openUserManagement(BuildContext context, int tabIndex) {
    Navigator.of(context).pop();

    if (widget.activeItem == 'User Management') {
      if (tabIndex == 0 && widget.activeSubItem == 'Users') return;
      if (tabIndex == 1 &&
          (widget.activeSubItem == 'Roles' ||
              widget.activeSubItem == 'Permissions')) {
        return;
      }
    }

    if (tabIndex == 0) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AdminUserListScreen()),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AdminUserManagementScreen(initialTabIndex: tabIndex),
      ),
    );
  }

  Widget _buildNavRow(_NavItem item) {
    final active = item.label == widget.activeItem;
    final Color rowColor = active ? accent : textSecondary;

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
              color: active
                  ? accent.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: active
                  ? Border(left: BorderSide(color: accent, width: 3))
                  : const Border(
                      left: BorderSide(color: Colors.transparent, width: 3),
                    ),
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
  }

  Widget _buildUserManagementGroup() {
    final parentActive =
        widget.activeItem == 'User Management' || widget.activeSubItem != null;
    final parentColor = parentActive ? accent : textSecondary;

    Widget childRow({
      required String label,
      required int tabIndex,
      required bool selected,
      required IconData icon,
    }) {
      return Padding(
        padding: const EdgeInsets.only(left: 18, top: 4),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openUserManagement(context, tabIndex),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? accent.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: selected ? accent : textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: selected ? accent : textSecondary,
                        fontSize: 13.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(
                  () => _isUserManagementExpanded = !_isUserManagementExpanded,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: parentActive
                      ? accent.withValues(alpha: 0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: parentActive
                      ? Border(left: BorderSide(color: accent, width: 3))
                      : const Border(
                          left: BorderSide(color: Colors.transparent, width: 3),
                        ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_alt_outlined,
                      color: parentColor,
                      size: 21,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'User Management',
                        style: TextStyle(
                          color: parentColor,
                          fontSize: 14.5,
                          fontWeight: parentActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      _isUserManagementExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: parentColor,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: _isUserManagementExpanded
                  ? Column(
                      children: [
                        childRow(
                          label: 'User',
                          tabIndex: 0,
                          icon: Icons.person_outline_rounded,
                          selected:
                              widget.activeItem == 'User Management' &&
                              widget.activeSubItem == 'Users',
                        ),
                        childRow(
                          label: 'Roles',
                          tabIndex: 1,
                          icon: Icons.badge_outlined,
                          selected:
                              widget.activeItem == 'User Management' &&
                              widget.activeSubItem == 'Roles',
                        ),
                        childRow(
                          label: 'Permission',
                          tabIndex: 1,
                          icon: Icons.admin_panel_settings_outlined,
                          selected:
                              widget.activeItem == 'User Management' &&
                              widget.activeSubItem == 'Permissions',
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
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
                      color: accent,
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
                  if (item.label == 'User Management') {
                    return _buildUserManagementGroup();
                  }
                  return _buildNavRow(item);
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
                      color: accent.withValues(alpha: 0.15),
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
