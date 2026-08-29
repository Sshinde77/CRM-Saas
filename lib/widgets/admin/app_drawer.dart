import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/auth_models.dart';
import '../../models/plan_model.dart';
import '../../screens/admin/audit_logs/audit_logs_screen.dart';
import '../../screens/admin/customers/customers_screen.dart';
import '../../screens/admin/dashboard/admin_dashboard_screen.dart';
import '../../screens/admin/deliveries/deliveries_screen.dart';
import '../../screens/admin/expenses/expenses_screen.dart';
import '../../screens/admin/inventory/inventory_screen.dart';
import '../../screens/admin/invoices/invoices_screen.dart';
import '../../screens/admin/leads/admin_leads_screen.dart';
import '../../screens/admin/notifications/notifications_screen.dart';
import '../../screens/admin/orders/admin_orders_screen.dart';
import '../../screens/admin/sales_returns/sales_returns_screen.dart';
import '../../screens/admin/products/products_screen.dart';
import '../../screens/admin/categories/categories_screen.dart';
import '../../screens/admin/attendance/attendance_screen.dart';
import '../../screens/admin/purchases/purchases_screen.dart';
import '../../screens/admin/reports/reports_screen.dart';
import '../../screens/admin/roles/roles_permissions_screen.dart';
import '../../screens/admin/settings/admin_settings_screen.dart';
import '../../screens/admin/settings/company_settings_screen.dart';
import '../../screens/admin/settings/plans_screen.dart';
import '../../screens/admin/suppliers/suppliers_screen.dart';
import '../../screens/admin/users/admin_user_list_screen.dart';
import '../../screens/admin/vehicles/vehicle_stock_screen.dart';
import '../../screens/admin/quotations/admin_quotations_screen.dart';
import '../../services/api_service.dart';

class _NavItem {
  final String label;
  final IconData icon;

  const _NavItem(this.label, this.icon);
}

class _NavSection {
  final String title;
  final List<_NavItem> items;

  const _NavSection(this.title, this.items);
}

class _DrawerMeta {
  final AuthMeResponse? authMe;
  final List<PlanModel> plans;

  const _DrawerMeta({required this.authMe, required this.plans});

  bool get shouldShowUpgradeCard {
    final organization = authMe?.organization;
    final currentPlan = organization?.plan;
    final currentPlanId = organization?.planId?.trim();
    if (organization == null || currentPlan == null) {
      return false;
    }

    if (currentPlanId == null || currentPlanId.isEmpty) {
      return false;
    }

    final matchedCurrentPlan = plans.any((plan) => plan.id == currentPlanId);
    if (!matchedCurrentPlan) {
      return false;
    }

    return _isFreePlan(currentPlan);
  }

  CurrentUserProfile? get user => authMe?.user;

  bool canViewNavItem(_NavItem item) {
    final auth = authMe;
    if (auth == null) return true;
    final module = _permissionModuleForLabel(item.label);
    if (module == null) return true;
    return auth.canView(module);
  }

  List<_NavSection> visibleSections(List<_NavSection> sections) {
    return sections
        .map(
          (section) => _NavSection(
            section.title,
            section.items.where(canViewNavItem).toList(),
          ),
        )
        .where((section) => section.items.isNotEmpty)
        .toList();
  }

  static String? _permissionModuleForLabel(String label) {
    switch (label) {
      case 'Dashboard':
        return 'dashboard';
      case 'Customers':
        return 'customers';
      case 'Leads':
        return 'leads';
      case 'Quotation':
        return 'quotations';
      case 'Suppliers':
        return 'suppliers';
      case 'Categories':
      case 'Products':
        return 'products';
      case 'Inventory':
        return 'inventory';
      case 'Orders':
        return 'sales_orders';
      case 'Vehicle Stock':
        return 'vehicle_stock';
      case 'Purchases':
        return 'purchases';
      case 'Deliveries':
        return 'deliveries';
      case 'Invoices':
        return 'invoices';
      case 'Expenses':
        return 'expenses';
      case 'Reports':
        return 'reports';
      case 'Staff':
      case 'Roles & Permissions':
        return 'users';
      case 'Attendance':
        return 'attendance';
      case 'Company Settings':
      case 'Plans':
      case 'Notifications':
      case 'Audit Logs':
      case 'Settings':
        return 'settings';
      default:
        return null;
    }
  }

  static bool _isFreePlan(PlanModel plan) {
    final planName = plan.name.trim().toLowerCase();
    return planName == 'free' ||
        planName.startsWith('free ') ||
        planName.endsWith(' free') ||
        planName.contains('free plan');
  }
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

  static const List<_NavSection> _sections = [
    _NavSection('Overview', [_NavItem('Dashboard', Icons.dashboard_outlined)]),
    _NavSection('Sales & Catalog', [
      _NavItem('Customers', Icons.groups_2_outlined),
      _NavItem('Leads', Icons.person_add_alt_1_outlined),
      _NavItem('Quotation', Icons.description_outlined),
      _NavItem('Suppliers', Icons.local_shipping_outlined),
      _NavItem('Categories', Icons.category_outlined),
      _NavItem('Products', Icons.inventory_2_outlined),
    ]),
    _NavSection('Operations', [
      _NavItem('Inventory', Icons.warehouse_outlined),
      _NavItem('Orders', Icons.shopping_cart_outlined),
      _NavItem('Sales Returns', Icons.keyboard_return_rounded),
      _NavItem('Vehicle Stock', Icons.local_shipping_outlined),
      _NavItem('Purchases', Icons.inventory_2_outlined),
      _NavItem('Deliveries', Icons.local_shipping_outlined),
    ]),
    _NavSection('Finance', [
      _NavItem('Invoices', Icons.description_outlined),
      _NavItem('Expenses', Icons.receipt_long_outlined),
      _NavItem('Reports', Icons.bar_chart_outlined),
    ]),
    _NavSection('Administration', [
      _NavItem('Company Settings', Icons.storefront_outlined),
      _NavItem('Plans', Icons.workspace_premium_outlined),
      _NavItem('Staff', Icons.people_outline_rounded),
      _NavItem('Roles & Permissions', Icons.admin_panel_settings_outlined),
      _NavItem('Attendance', Icons.fact_check_outlined),
      _NavItem('Notifications', Icons.notifications_none_rounded),
      _NavItem('Audit Logs', Icons.history_rounded),
      _NavItem('Settings', Icons.settings_outlined),
    ]),
  ];

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  static const Color accent = AppDrawer.accent;
  late final ApiService _apiService;
  late final Future<_DrawerMeta> _drawerMetaFuture;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _drawerMetaFuture = _loadDrawerMeta();
  }

  @override
  void dispose() {
    _apiService.close();
    super.dispose();
  }

  Future<_DrawerMeta> _loadDrawerMeta() async {
    AuthMeResponse? authMe;
    try {
      authMe = await _apiService.fetchAuthMeDetails();
    } catch (_) {
      authMe = null;
    }

    List<PlanModel> plans = const [];
    try {
      plans = await _apiService.fetchPlans();
    } catch (_) {
      plans = const [];
    }

    return _DrawerMeta(authMe: authMe, plans: plans);
  }

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
      case 'Staff':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminUserListScreen()),
        );
        break;
      case 'Roles & Permissions':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RolesPermissionsScreen()),
        );
        break;
      case 'Attendance':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AttendanceScreen()),
        );
        break;
      case 'Customers':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CustomersScreen()),
        );
        break;
      case 'Orders':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
        );
        break;
      case 'Sales Returns':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SalesReturnsScreen()),
        );
        break;
      case 'Leads':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminLeadsScreen()),
        );
        break;
      case 'Quotation':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminQuotationsScreen()),
        );
        break;
      case 'Suppliers':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SuppliersScreen()),
        );
        break;
      case 'Products':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProductsScreen()),
        );
        break;
      case 'Categories':
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CategoriesScreen()),
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
        break;
    }
  }

  Widget _buildNavRow(_NavItem item) {
    final isActive = item.label == widget.activeItem;
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(_NavSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: Text(
              section.title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF9AA0B1),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
          ...section.items.map(_buildNavRow),
        ],
      ),
    );
  }

  Widget _buildUpgradeCard(_DrawerMeta meta) {
    if (!meta.shouldShowUpgradeCard) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D3B07),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Upgrade Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Higher productivity with better organization',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const PlansScreen()),
                );
              },
              icon: const Icon(Icons.workspace_premium_outlined, size: 18),
              label: const Text('Upgrade'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomArea(_DrawerMeta meta) {
    final user = meta.user;
    final organization = meta.authMe?.organization;
    final displayName = user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'Admin';
    final email = user?.email?.trim().isNotEmpty == true
        ? user!.email!.trim()
        : 'admin@demo.com';
    final initials = _initials(displayName);
    final planLabel = organization?.plan?.name ?? 'Plan';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (planLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        planLabel,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildUpgradeCard(meta),
        ],
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
              child: FutureBuilder<_DrawerMeta>(
                future: _drawerMetaFuture,
                builder: (context, snapshot) {
                  final meta = snapshot.data;
                  final sections =
                      meta?.visibleSections(AppDrawer._sections) ??
                      AppDrawer._sections;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                    children: sections.map(_buildSection).toList(),
                  );
                },
              ),
            ),
            Divider(
              color: AppDrawer.textPrimary.withValues(alpha: 0.08),
              height: 1,
            ),
            FutureBuilder<_DrawerMeta>(
              future: _drawerMetaFuture,
              builder: (context, snapshot) {
                final meta =
                    snapshot.data ?? const _DrawerMeta(authMe: null, plans: []);
                return _buildBottomArea(meta);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'AD';
    }
    if (parts.length == 1) {
      final text = parts.first;
      return text.length >= 2
          ? text.substring(0, 2).toUpperCase()
          : text.toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
