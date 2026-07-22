import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/soft_action_button.dart';
import '../profile/admin_profile_screen.dart';
import '../settings/admin_settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  final List<_StatItem> _stats = const [
    _StatItem(
      "Today's Sales",
      'Rs. 23,242',
      Icons.currency_rupee,
      AppColors.green,
    ),
    _StatItem(
      'Monthly Sales',
      'Rs. 66,160',
      Icons.calendar_month,
      AppColors.purple,
    ),
    _StatItem('Yearly Sales', 'Rs. 66,160', Icons.event, AppColors.blue),
    _StatItem(
      'Purchases This Month',
      'Rs. 1,89,215',
      Icons.inventory_2,
      AppColors.teal,
    ),
    _StatItem(
      'Low Stock Items',
      '5',
      Icons.warning_amber_rounded,
      AppColors.amber,
    ),
    _StatItem('Pending Orders', '6', Icons.schedule, AppColors.blue),
  ];

  final List<_ProductRevenue> _topProducts = const [
    _ProductRevenue('Water Jar Refill (20L)', 14400),
    _ProductRevenue('Water Dispenser - Normal', 11200),
    _ProductRevenue('Water Dispenser - Hot & Cold', 9000),
    _ProductRevenue('Packaged Drinking Water (1L)', 6400),
  ];

  final List<_OrderItem> _orders = const [
    _OrderItem('SO-2026-1016', 'Silver Oak Apartments', 'Draft'),
    _OrderItem('SO-2026-1015', 'Rajdhani Sweets & Snacks', 'Draft'),
    _OrderItem('SO-2026-1014', 'Prime Legal Associates', 'Draft'),
    _OrderItem('SO-2026-1013', 'Cloud Nine Cafe', 'Confirmed'),
    _OrderItem('SO-2026-1011', 'TechNova Solutions Pvt Ltd', 'Confirmed'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _query.isEmpty
        ? _orders
        : _orders
              .where(
                (order) =>
                    order.orderNo.toLowerCase().contains(
                      _query.toLowerCase(),
                    ) ||
                    order.customer.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(activeItem: 'Dashboard'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Dashboard',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
              trailingAvatar: _buildAccountMenu(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Key business metrics and recent orders',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    _buildStatsGrid(),
                    const SizedBox(height: 20),
                    _buildTopProducts(),
                    const SizedBox(height: 20),
                    _buildRecentOrders(filteredOrders),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountMenu() {
    return PopupMenuButton<String>(
      color: AppColors.primary,
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AdminProfileScreen()));
        }
        if (value == 'settings') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
          );
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<String>(value: 'profile', child: Text('Profile')),
        PopupMenuItem<String>(value: 'settings', child: Text('Settings')),
      ],
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.secondary),
        ),
        alignment: Alignment.center,
        child: const Text(
          'AS',
          style: TextStyle(
            color: AppColors.purple,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.22,
      ),
      itemBuilder: (context, index) {
        final stat = _stats[index];
        return _CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: stat.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(stat.icon, color: stat.color),
              ),
              const Spacer(),
              Text(
                stat.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                stat.value,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopProducts() {
    final maxRevenue = _topProducts
        .map((product) => product.revenue)
        .reduce((a, b) => a > b ? a : b);

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Products',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'By revenue this month',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 18),
          ..._topProducts.map((product) {
            final widthFactor = (product.revenue / maxRevenue).clamp(0.08, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        'Rs. ${product.revenue.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: widthFactor,
                      minHeight: 10,
                      backgroundColor: AppColors.secondary.withValues(
                        alpha: 0.14,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.purple,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(List<_OrderItem> orders) {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Orders',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Latest sales orders across the organization',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 520;
              final searchField = TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search orders',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surfaceSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.secondary.withValues(alpha: 0.28),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.secondary.withValues(alpha: 0.28),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.purple),
                  ),
                ),
              );

              final actionButton = SoftActionButton(
                label: 'New Order',
                icon: Icons.add_rounded,
                onPressed: () {},
              );

              if (stacked) {
                return Column(
                  children: [
                    searchField,
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: actionButton),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: searchField),
                  const SizedBox(width: 12),
                  SizedBox(width: 180, child: actionButton),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (orders.isEmpty)
            const Text(
              'No orders match your search.',
              style: TextStyle(color: textSecondary),
            )
          else
            ...orders.map(_buildOrderTile),
        ],
      ),
    );
  }

  Widget _buildOrderTile(_OrderItem order) {
    final isConfirmed = order.status == 'Confirmed';
    final statusColor = isConfirmed ? AppColors.blue : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              order.orderNo,
              style: const TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              order.customer,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: textSecondary),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              order.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem(this.label, this.value, this.icon, this.color);
}

class _ProductRevenue {
  final String name;
  final double revenue;

  const _ProductRevenue(this.name, this.revenue);
}

class _OrderItem {
  final String orderNo;
  final String customer;
  final String status;

  const _OrderItem(this.orderNo, this.customer, this.status);
}
