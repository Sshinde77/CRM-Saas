import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../customers/sales_manager_customers_screen.dart';
import '../attendance/sales_manager_attendance_screen.dart';
import '../follow_ups/sales_manager_follow_ups_screen.dart';
import '../leads/sales_manager_leads_screen.dart';
import '../orders/sales_manager_orders_screen.dart';
import '../performance/sales_manager_performance_screen.dart';
import '../stock/sales_manager_stock_screen.dart';
import '../visits/sales_manager_visits_screen.dart';

class SalesManagerDashboardScreen extends StatefulWidget {
  const SalesManagerDashboardScreen({super.key});

  @override
  State<SalesManagerDashboardScreen> createState() =>
      _SalesManagerDashboardScreenState();
}

class _SalesManagerDashboardScreenState
    extends State<SalesManagerDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_MetricCardData> _metrics = const [
    _MetricCardData(
      label: 'Assigned Customers',
      value: '12',
      icon: Icons.groups_rounded,
      color: AppColors.blue,
    ),
    _MetricCardData(
      label: 'Planned Visits',
      value: '6',
      icon: Icons.event_available_rounded,
      color: AppColors.green,
    ),
    _MetricCardData(
      label: 'Completed Visits',
      value: '4',
      icon: Icons.verified_rounded,
      color: AppColors.purple,
    ),
    _MetricCardData(
      label: 'Pending Follow-ups',
      value: '3',
      icon: Icons.notifications_active_rounded,
      color: AppColors.orange,
    ),
    _MetricCardData(
      label: 'Orders Created',
      value: '8',
      icon: Icons.receipt_long_rounded,
      color: AppColors.blue,
    ),
    _MetricCardData(
      label: "Today's Sales Value",
      value: 'Rs. 1,25,450',
      icon: Icons.currency_rupee_rounded,
      color: AppColors.green,
    ),
  ];

  final List<_CustomerItem> _customers = const [
    _CustomerItem(
      name: 'Shree Ganesh Traders',
      location: 'Dadar, Mumbai',
      value: 'Rs. 45,000',
      status: 'Active',
      icon: Icons.storefront_rounded,
      color: AppColors.green,
    ),
    _CustomerItem(
      name: 'Maa Durga Stores',
      location: 'Matunga, Mumbai',
      value: 'Rs. 12,500',
      status: 'Active',
      icon: Icons.store_rounded,
      color: AppColors.blue,
    ),
    _CustomerItem(
      name: 'Patel Retailers',
      location: 'Sion, Mumbai',
      value: 'Rs. 0',
      status: 'Active',
      icon: Icons.shopping_bag_rounded,
      color: AppColors.purple,
    ),
    _CustomerItem(
      name: 'S.K. Enterprises',
      location: 'Ghatkopar, Mumbai',
      value: 'Rs. 78,300',
      status: 'Overdue',
      icon: Icons.apartment_rounded,
      color: AppColors.red,
    ),
    _CustomerItem(
      name: 'New A One Traders',
      location: 'Kurla, Mumbai',
      value: 'Rs. 18,700',
      status: 'Active',
      icon: Icons.store_mall_directory_rounded,
      color: AppColors.green,
    ),
  ];

  final List<_OrderItem> _orders = const [
    _OrderItem(
      number: 'SO-1023',
      customer: 'Shree Ganesh Traders',
      date: '18 May 2024',
      amount: 'Rs. 25,600',
      status: 'Confirmed',
      color: AppColors.green,
    ),
    _OrderItem(
      number: 'SO-1022',
      customer: 'Maa Durga Stores',
      date: '18 May 2024',
      amount: 'Rs. 18,450',
      status: 'Pending',
      color: AppColors.orange,
    ),
    _OrderItem(
      number: 'SO-1021',
      customer: 'Patel Retailers',
      date: '17 May 2024',
      amount: 'Rs. 22,300',
      status: 'Confirmed',
      color: AppColors.green,
    ),
    _OrderItem(
      number: 'SO-1020',
      customer: 'S.K. Enterprises',
      date: '16 May 2024',
      amount: 'Rs. 15,600',
      status: 'Pending',
      color: AppColors.orange,
    ),
    _OrderItem(
      number: 'SO-1019',
      customer: 'New A One Traders',
      date: '15 May 2024',
      amount: 'Rs. 28,500',
      status: 'Confirmed',
      color: AppColors.green,
    ),
  ];

  final List<_VisitItem> _visits = const [
    _VisitItem(
      customer: 'Shree Ganesh Traders',
      location: 'Dadar, Mumbai',
      time: '10:00 AM - 10:45 AM',
      status: 'Completed',
      color: AppColors.green,
    ),
    _VisitItem(
      customer: 'Maa Durga Stores',
      location: 'Matunga, Mumbai',
      time: '12:00 PM - 12:45 PM',
      status: 'In Progress',
      color: AppColors.orange,
    ),
    _VisitItem(
      customer: 'Patel Retailers',
      location: 'Sion, Mumbai',
      time: '03:00 PM - 03:45 PM',
      status: 'Planned',
      color: AppColors.blue,
    ),
    _VisitItem(
      customer: 'S.K. Enterprises',
      location: 'Ghatkopar, Mumbai',
      time: '05:00 PM - 05:30 PM',
      status: 'Planned',
      color: AppColors.blue,
    ),
  ];

  final List<_ProductItem> _products = const [
    _ProductItem(
      name: 'Premium Basmati Rice 25kg',
      price: 'Rs. 1,650',
      stock: 'Stock: 120',
      icon: Icons.shopping_bag_rounded,
    ),
    _ProductItem(
      name: 'Sunflower Oil 1L',
      price: 'Rs. 1,350',
      stock: 'Stock: 80',
      icon: Icons.water_drop_rounded,
    ),
    _ProductItem(
      name: 'Toor Dal 5kg',
      price: 'Rs. 650',
      stock: 'Stock: 45',
      icon: Icons.inventory_2_rounded,
    ),
    _ProductItem(
      name: 'Wheat Atta 10kg',
      price: 'Rs. 380',
      stock: 'Stock: 60',
      icon: Icons.flatware_rounded,
    ),
    _ProductItem(
      name: 'Sugar 25kg',
      price: 'Rs. 1,200',
      stock: 'Stock: 200',
      icon: Icons.coffee_rounded,
    ),
  ];

  final List<_FollowUpItem> _followUps = const [
    _FollowUpItem(
      title: 'Payment follow up',
      subtitle: 'Shree Ganesh Traders',
      date: 'Today',
      color: AppColors.green,
    ),
    _FollowUpItem(
      title: 'Order follow up',
      subtitle: 'Maa Durga Stores',
      date: 'Today',
      color: AppColors.blue,
    ),
    _FollowUpItem(
      title: 'New product discussion',
      subtitle: 'New A One Traders',
      date: '19 May 2024',
      color: AppColors.purple,
    ),
    _FollowUpItem(
      title: 'Payment reminder',
      subtitle: 'S.K. Enterprises',
      date: '18 May 2024',
      color: AppColors.orange,
    ),
    _FollowUpItem(
      title: 'Order follow up',
      subtitle: 'Patel Retailers',
      date: '22 May 2024',
      color: AppColors.red,
    ),
  ];

  final List<_NotificationItem> _notifications = const [
    _NotificationItem(
      title: 'New order SO-1023 has been confirmed.',
      time: '10:30 AM',
      color: AppColors.green,
    ),
    _NotificationItem(
      title: 'Payment reminder for S.K. Enterprises.',
      time: '09:15 AM',
      color: AppColors.orange,
    ),
    _NotificationItem(
      title: 'Follow-up for Maa Durga Stores is due tomorrow.',
      time: 'Yesterday',
      color: AppColors.blue,
    ),
    _NotificationItem(
      title: 'Low stock alert for Sunflower Oil 1L.',
      time: 'Yesterday',
      color: AppColors.red,
    ),
    _NotificationItem(
      title: 'Your daily target progress is 55%.',
      time: '2 Days Ago',
      color: AppColors.purple,
    ),
  ];

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (mounted) setState(() {});
  }

  void _showSnack(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action is not wired yet'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSidebarSelection(String action) {
    Navigator.of(context).pop();
    if (action == 'Customers') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SalesManagerCustomersScreen()),
      );
      return;
    }

    if (action == 'Leads') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SalesManagerLeadsScreen()),
      );
      return;
    }

    if (action == 'Create Order' || action == 'Sales Orders') {
      _openSalesOrdersScreen();
      return;
    }

    if (action == 'Stock') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SalesManagerStockScreen()),
      );
      return;
    }

    if (action == 'Follow-Ups' || action == 'Follow-ups') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SalesManagerFollowUpsScreen(),
        ),
      );
      return;
    }

    if (action == 'My Performance') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SalesManagerPerformanceScreen(),
        ),
      );
      return;
    }

    if (action == 'Attendance') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SalesManagerAttendanceScreen(),
        ),
      );
      return;
    }

    if (action == 'Visits') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
      );
      return;
    }

    _showSnack(action);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: SalesManagerSidebarDrawer(
        onSelect: _handleSidebarSelection,
        currentPage: 'Dashboard',
      ),
      body: SafeArea(
        child: Column(
          children: [
            SalesManagerTopBar(
              title: 'Dashboard',
              onNotificationTap: () => _showSnack('Notifications'),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 14),
                      _buildMetricGrid(),
                      const SizedBox(height: 14),
                      _buildMainGrid(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Good Morning, Arjun! \u{1F44B}',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Here's what's happening today.",
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.95),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _HeaderDatePill(
            icon: Icons.calendar_month_rounded,
            label: '20 May 2024, Monday',
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 3;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: constraints.maxWidth > 700 ? 1.12 : 0.82,
          ),
          itemBuilder: (context, index) {
            return _MetricCard(data: _metrics[index]);
          },
        );
      },
    );
  }

  Widget _buildMainGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 900;

        if (!wide) {
          return Column(
            children: [
              _buildSalesTargetCard(),
              const SizedBox(height: 14),
              _buildTodayScheduleCard(),
              const SizedBox(height: 14),
              _buildRecentOrdersCard(),
              const SizedBox(height: 14),
              _buildOutstandingSummaryCard(),
            ],
          );
        }

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSalesTargetCard()),
                const SizedBox(width: 14),
                Expanded(child: _buildTodayScheduleCard()),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildRecentOrdersCard()),
                const SizedBox(width: 14),
                Expanded(child: _buildOutstandingSummaryCard()),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSalesTargetCard() {
    final target = 500000.0;
    final achieved = 275000.0;
    final progress = achieved / target;

    return _PanelCard(
      title: 'Sales Target',
      subtitle: 'May 2024',
      trailing: TextButton(
        onPressed: () => _showSnack('View details'),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: AppColors.primary,
        ),
        child: const Text(
          'View Details',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Rs. 2,75,000 / Rs. 5,00,000',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Remaining: Rs. 2,25,000',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayScheduleCard() {
    return _PanelCard(
      title: "Today's Schedule",
      subtitle: '',
      trailing: TextButton(
        onPressed: () => _showSnack('View all'),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: AppColors.primary,
        ),
        child: const Text(
          'View all',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      child: Column(
        children: [
          _timelineRow(
            '10:00 AM',
            'Visit',
            'Shree Ganesh Traders',
            'Dadar, Mumbai',
            AppColors.green,
            'Completed',
          ),
          const SizedBox(height: 14),
          _timelineRow(
            '12:00 PM',
            'Visit',
            'Maa Durga Stores',
            'Matunga, Mumbai',
            AppColors.orange,
            'In Progress',
          ),
          const SizedBox(height: 14),
          _timelineRow(
            '03:00 PM',
            'Visit',
            'Patel Retailers',
            'Sion, Mumbai',
            AppColors.blue,
            'Planned',
          ),
        ],
      ),
    );
  }

  Widget _timelineRow(
    String time,
    String type,
    String title,
    String subtitle,
    Color color,
    String status,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 58,
          child: Text(
            time,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            type == 'Visit' ? Icons.place_rounded : Icons.event_rounded,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _StatusPill(label: status, color: color),
      ],
    );
  }

  Widget _buildRecentOrdersCard() {
    return _PanelCard(
      title: 'Recent Orders',
      subtitle: 'Latest sales orders',
      trailing: TextButton(
        onPressed: _openSalesOrdersScreen,
        child: const Text('View All'),
      ),
      child: Column(
        children: [
          for (final order in _orders) ...[
            _orderRow(order),
            if (order != _orders.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _orderRow(_OrderItem order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: order.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              color: order.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.number,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  order.customer,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.date,
                  style: const TextStyle(
                    color: AppColors.textLightMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                order.amount,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              _StatusPill(label: order.status, color: order.color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutstandingSummaryCard() {
    return _PanelCard(
      title: 'Outstanding Summary',
      subtitle: 'Outstanding by aging bucket',
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Outstanding',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rs. 1,86,350',
                        style: TextStyle(
                          color: AppColors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.timelapse_rounded,
                    color: AppColors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _amountLine('0 - 30 Days', 'Rs. 45,600', AppColors.green),
          const SizedBox(height: 10),
          _amountLine('31 - 60 Days', 'Rs. 68,750', AppColors.orange),
          const SizedBox(height: 10),
          _amountLine('61 - 90 Days', 'Rs. 48,000', AppColors.red),
          const SizedBox(height: 10),
          _amountLine('90+ Days', 'Rs. 24,000', AppColors.purple),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showSnack('Outstanding details'),
              child: const Text('View Customer Outstanding'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountLine(String label, String amount, Color color) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildFollowUpsCard() {
    return _PanelCard(
      title: 'Follow-Ups',
      subtitle: 'Pending follow-up items and reminders',
      child: Column(
        children: [
          for (final item in _followUps) ...[
            _compactRow(
              icon: Icons.call_made_rounded,
              iconColor: item.color,
              title: item.title,
              subtitle: item.subtitle,
              trailing: item.date,
            ),
            if (item != _followUps.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildReportsCard() {
    const items = [
      ('Sales Report', Icons.bar_chart_rounded),
      ('Customer Report', Icons.groups_rounded),
      ('Order Report', Icons.receipt_long_rounded),
      ('Visit Report', Icons.place_rounded),
      ('Performance Report', Icons.insights_rounded),
      ('Outstanding Report', Icons.currency_rupee_rounded),
    ];

    return _PanelCard(
      title: 'Reports',
      subtitle: 'Quick access to operational reports',
      child: Column(
        children: [
          for (final item in items) ...[
            _arrowRow(item.$1, item.$2),
            if (item != items.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildNotificationsCard() {
    return _PanelCard(
      title: 'Notifications',
      subtitle: 'Recent alerts and activity',
      trailing: const _CounterBadge('5'),
      child: Column(
        children: [
          for (final item in _notifications) ...[
            _compactRow(
              icon: Icons.notifications_none_rounded,
              iconColor: item.color,
              title: item.title,
              subtitle: item.time,
              trailing: '',
            ),
            if (item != _notifications.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSettingsCard() {
    const items = [
      ('Profile', Icons.person_rounded),
      ('Change Password', Icons.lock_rounded),
      ('App Preferences', Icons.settings_rounded),
      ('Notification Settings', Icons.notifications_rounded),
      ('About App', Icons.info_outline_rounded),
    ];

    return _PanelCard(
      title: 'Settings',
      subtitle: 'Profile and application preferences',
      child: Column(
        children: [
          for (final item in items) ...[
            _arrowRow(item.$1, item.$2, trailingColor: AppColors.textSecondary),
            if (item != items.last) const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          _logoutTile(),
        ],
      ),
    );
  }

  Widget _logoutTile() {
    return Material(
      color: AppColors.red.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _showSnack('Logout'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: const [
              Icon(Icons.logout_rounded, color: AppColors.red, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildCustomersCard() {
    return _PanelCard(
      title: 'Customers',
      subtitle: 'Assigned accounts and visit coverage',
      trailing: const _CounterBadge('5'),
      child: Column(
        children: [
          _searchBar('Search customers...'),
          const SizedBox(height: 14),
          for (final customer in _customers) ...[
            _customerRow(customer),
            if (customer != _customers.last) const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          _footerButton('Add New Customer'),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildSalesOrdersCard() {
    return _PanelCard(
      title: 'Sales Orders',
      subtitle: 'Confirmed, pending, and draft orders',
      trailing: const _CounterBadge('8'),
      child: Column(
        children: [
          _searchBar('Search orders...'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _FilterPill('All'),
              _FilterPill('Draft'),
              _FilterPill('Pending'),
              _FilterPill('Confirmed'),
              _FilterPill('Cancelled'),
            ],
          ),
          const SizedBox(height: 14),
          for (final order in _orders) ...[
            _simpleOrderRow(order),
            if (order != _orders.last) const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          _footerButton('Create Order', onPressed: _openSalesOrdersScreen),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildVisitsCard() {
    return _PanelCard(
      title: 'Visits',
      subtitle: 'Today, this week, and this month',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _CounterBadge('Today'),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showSnack('Add visit'),
            icon: const Icon(Icons.add_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(34, 34),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _FilterPill('Today'),
              _FilterPill('This Week'),
              _FilterPill('This Month'),
              _FilterPill('Custom'),
            ],
          ),
          const SizedBox(height: 14),
          for (final visit in _visits) ...[
            _visitRow(visit),
            if (visit != _visits.last) const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          _footerButton('View All Visits'),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildProductsCard() {
    return _PanelCard(
      title: 'Products',
      subtitle: 'Frequently sold and stock-aware items',
      child: Column(
        children: [
          _searchBar('Search products...'),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _FilterPill('All Products'),
              _FilterPill('Low Stock'),
              _FilterPill('Out of Stock'),
            ],
          ),
          const SizedBox(height: 14),
          for (final product in _products) ...[
            _productRow(product),
            if (product != _products.last) const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          _footerButton(
            'View Product Stock Board',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SalesManagerStockScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildTargetsCard() {
    return _PanelCard(
      title: 'Targets & Performance',
      subtitle: 'Monthly target and KPI snapshot',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'May 2024',
                items: const [
                  DropdownMenuItem(value: 'May 2024', child: Text('May 2024')),
                  DropdownMenuItem(value: 'Jun 2024', child: Text('Jun 2024')),
                  DropdownMenuItem(value: 'Jul 2024', child: Text('Jul 2024')),
                ],
                onChanged: (_) {},
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monthly Target',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Rs. 2,75,000',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Remaining: Rs. 2,25,000',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                '55%',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 0.55,
              minHeight: 12,
              backgroundColor: AppColors.surfaceSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.green),
            ),
          ),
          const SizedBox(height: 16),
          _performanceLine('Orders Created', '23'),
          const SizedBox(height: 12),
          _performanceLine('Total Sales Value', 'Rs. 2,75,000'),
          const SizedBox(height: 12),
          _performanceLine('New Customers Added', '7'),
          const SizedBox(height: 12),
          _performanceLine('Customers Visited', '18'),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildPaymentsCard() {
    return _PanelCard(
      title: 'Outstanding & Payments',
      subtitle: 'Track dues and payment actions',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FilterPill('Outstanding', selected: true, onTap: () {}),
              ),
              const SizedBox(width: 8),
              Expanded(child: _FilterPill('Payments', onTap: () {})),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Outstanding',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rs. 1,86,350',
                        style: TextStyle(
                          color: AppColors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    color: AppColors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _amountLine('0 - 30 Days', 'Rs. 45,600', AppColors.green),
          const SizedBox(height: 10),
          _amountLine('31 - 60 Days', 'Rs. 68,750', AppColors.orange),
          const SizedBox(height: 10),
          _amountLine('61 - 90 Days', 'Rs. 48,000', AppColors.red),
          const SizedBox(height: 10),
          _amountLine('90+ Days', 'Rs. 24,000', AppColors.purple),
          const SizedBox(height: 12),
          _footerButton('View Customer Outstanding'),
        ],
      ),
    );
  }

  Widget _performanceLine(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: AppColors.green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(String hintText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, size: 20),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textLightMuted,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _customerRow(_CustomerItem item) {
    return _itemCard(
      icon: item.icon,
      iconColor: item.color,
      title: item.name,
      subtitle: item.location,
      leadingNote: item.value,
      trailing: _StatusPill(label: item.status, color: item.color),
    );
  }

  Widget _simpleOrderRow(_OrderItem item) {
    return _itemCard(
      icon: Icons.receipt_long_rounded,
      iconColor: item.color,
      title: item.number,
      subtitle: item.customer,
      leadingNote: item.date,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            item.amount,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _StatusPill(label: item.status, color: item.color),
        ],
      ),
    );
  }

  Widget _visitRow(_VisitItem item) {
    return _itemCard(
      icon: Icons.place_rounded,
      iconColor: item.color,
      title: item.customer,
      subtitle: item.location,
      leadingNote: item.time,
      trailing: _StatusPill(label: item.status, color: item.color),
    );
  }

  Widget _productRow(_ProductItem item) {
    return _itemCard(
      icon: item.icon,
      iconColor: AppColors.primary,
      title: item.name,
      subtitle: item.price,
      leadingNote: item.stock,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _itemCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String leadingNote,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  leadingNote,
                  style: const TextStyle(
                    color: AppColors.textLightMuted,
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    );
  }

  Widget _arrowRow(
    String title,
    IconData icon, {
    Color trailingColor = AppColors.textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: trailingColor, size: 18),
        ],
      ),
    );
  }

  Widget _compactRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (trailing.isNotEmpty)
                Text(
                  trailing,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLightMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openSalesOrdersScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SalesManagerOrdersScreen()));
  }

  Widget _footerButton(String label, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed ?? () => _showSnack(label),
        style: TextButton.styleFrom(
          backgroundColor: AppColors.surfaceSoft,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  const _PanelCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          if (subtitle.trim().isNotEmpty) ...[const SizedBox(height: 16)],
          child,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final _MetricCardData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data.label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(data.icon, color: data.color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CounterBadge extends StatelessWidget {
  final String label;

  const _CounterBadge(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ignore: unused_element
class _HeaderPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderDatePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeaderDatePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _FilterPill(this.label, {this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.border.withValues(alpha: 0.85),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCardData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _CustomerItem {
  final String name;
  final String location;
  final String value;
  final String status;
  final IconData icon;
  final Color color;

  const _CustomerItem({
    required this.name,
    required this.location,
    required this.value,
    required this.status,
    required this.icon,
    required this.color,
  });
}

class _OrderItem {
  final String number;
  final String customer;
  final String date;
  final String amount;
  final String status;
  final Color color;

  const _OrderItem({
    required this.number,
    required this.customer,
    required this.date,
    required this.amount,
    required this.status,
    required this.color,
  });
}

class _VisitItem {
  final String customer;
  final String location;
  final String time;
  final String status;
  final Color color;

  const _VisitItem({
    required this.customer,
    required this.location,
    required this.time,
    required this.status,
    required this.color,
  });
}

class _ProductItem {
  final String name;
  final String price;
  final String stock;
  final IconData icon;

  const _ProductItem({
    required this.name,
    required this.price,
    required this.stock,
    required this.icon,
  });
}

class _FollowUpItem {
  final String title;
  final String subtitle;
  final String date;
  final Color color;

  const _FollowUpItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.color,
  });
}

class _NotificationItem {
  final String title;
  final String time;
  final Color color;

  const _NotificationItem({
    required this.title,
    required this.time,
    required this.color,
  });
}

enum SalesRange { today, thisWeek, thisMonth }

extension on SalesRange {
  // ignore: unused_element
  String get label {
    switch (this) {
      case SalesRange.today:
        return 'Today';
      case SalesRange.thisWeek:
        return 'This Week';
      case SalesRange.thisMonth:
        return 'This Month';
    }
  }
}
