import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../../admin/customers/customers_screen.dart';
import '../../admin/leads/admin_leads_screen.dart';
import '../../admin/orders/admin_orders_screen.dart';
import '../../admin/orders/new_admin_order_screen.dart';
import '../../admin/quotations/admin_quotations_screen.dart';
import '../../admin/quotations/create_quotation_screen.dart';
import '../attendance/sales_manager_attendance_screen.dart';
import '../follow_ups/sales_manager_follow_ups_screen.dart';
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
  static const double _monthlyTarget = 80000;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<_DashboardData>? _future;
  bool _didStartLoad = false;

  final List<_VisitRecord> _mockVisits = const [
    _VisitRecord(
      customer: 'Ankit Bhatia',
      purpose: 'Product Demo',
      date: '2026-09-04',
      time: '11:00 AM',
      status: 'Scheduled',
    ),
    _VisitRecord(
      customer: 'Sunil Kumar',
      purpose: 'Follow-up Meeting',
      date: '2026-09-04',
      time: '02:00 PM',
      status: 'Follow-up Required',
    ),
    _VisitRecord(
      customer: 'Ravi Mehta',
      purpose: 'Product Presentation',
      date: '2026-09-05',
      time: '10:30 AM',
      status: 'Scheduled',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _future = _loadDashboard();
      _didStartLoad = true;
    }
  }

  Future<_DashboardData> _loadDashboard() async {
    final provider = ApiProviderScope.of(context);
    final mainResults = await Future.wait([
      provider.fetchCustomers(),
      provider.fetchOrders(),
      provider.fetchQuotations(),
    ]);

    final customers = mainResults[0] as List<CustomerModel>;
    final orders = (mainResults[1] as List<Map<String, dynamic>>)
        .map(_DashboardOrder.fromJson)
        .toList();
    final quotations = (mainResults[2] as List<Map<String, dynamic>>)
        .map(_DashboardQuotation.fromJson)
        .toList();

    _AttendanceRecord? attendance;
    try {
      final attendanceRows = await provider.fetchMyAttendance();
      attendance = _firstTodayAttendance(
        attendanceRows
          .map(_AttendanceRecord.fromJson)
          .where((record) => _isSameDay(record.date, DateTime.now()))
          .where((record) => record.checkIn != null),
      );
    } catch (_) {
      attendance = null;
    }

    final user = provider.currentUser;

    return _DashboardData(
      userName: user?.name.trim().isNotEmpty == true ? user!.name.trim() : 'User',
      customers: customers,
      orders: orders,
      quotations: quotations,
      attendance: attendance,
      visits: _mockVisits,
    );
  }

  Future<void> _refresh() async {
    final request = _loadDashboard();
    setState(() => _future = request);
    await request;
  }

  void _showSnack(String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$action is not wired yet'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _handleSidebarSelection(String action) {
    Navigator.of(context).pop();
    switch (action) {
      case 'Customers':
        _openCustomers();
        return;
      case 'Leads':
        _openLeads();
        return;
      case 'Create Order':
        _openCreateOrder();
        return;
      case 'Sales Orders':
        _openSalesOrders();
        return;
      case 'Stock':
        _openStock();
        return;
      case 'Follow-Ups':
      case 'Follow-ups':
        _openFollowUps();
        return;
      case 'My Performance':
        _openPerformance();
        return;
      case 'Attendance':
        _openAttendance();
        return;
      case 'Visits':
        _openVisits();
        return;
      default:
        _showSnack(action);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAF9),
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
              child: FutureBuilder<_DashboardData>(
                future: _future,
                builder: (context, snapshot) {
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData;
                  if (isLoading) return const _LoadingState();
                  if (snapshot.hasError) {
                    return _ErrorState(
                      message: _cleanError(snapshot.error),
                      onRetry: _refresh,
                    );
                  }

                  final data = snapshot.data ?? _DashboardData.empty();
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 980),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _GreetingPanel(
                                data: data,
                                onAttendanceTap: _openAttendance,
                              ),
                              const SizedBox(height: 10),
                              _QuickActions(
                                onCreateOrder: _openCreateOrder,
                                onCreateQuotation: _openCreateQuotation,
                                onAddCustomer: _openCustomers,
                                onAddLead: _openLeads,
                                onScheduleVisit: _openVisits,
                              ),
                              const SizedBox(height: 10),
                              _StatsGrid(data: data),
                              const SizedBox(height: 10),
                              _SalesTargetCard(data: data),
                              const SizedBox(height: 10),
                              _PrioritiesCard(
                                data: data,
                                onFollowUps: _openFollowUps,
                                onVisits: _openVisits,
                                onQuotations: _openQuotations,
                              ),
                              const SizedBox(height: 10),
                              _OrderStatusCard(
                                data: data,
                                onViewAll: _openSalesOrders,
                              ),
                              const SizedBox(height: 10),
                              _VisitsCard(
                                visits: data.recentVisits,
                                onViewAll: _openVisits,
                              ),
                              const SizedBox(height: 10),
                              _RecentOrdersCard(
                                orders: data.recentOrders,
                                onViewAll: _openSalesOrders,
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
          ],
        ),
      ),
    );
  }

  void _openCustomers() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const CustomersScreen(useSalesManagerShell: true),
      ),
    );
  }

  void _openLeads() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AdminLeadsScreen(useSalesManagerShell: true),
      ),
    );
  }

  void _openCreateOrder() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NewAdminOrderScreen(useSalesManagerShell: true),
      ),
    );
  }

  void _openSalesOrders() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AdminOrdersScreen(useSalesManagerShell: true),
      ),
    );
  }

  void _openCreateQuotation() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewQuotationScreen()),
    );
  }

  void _openQuotations() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdminQuotationsScreen()),
    );
  }

  void _openStock() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SalesManagerStockScreen()),
    );
  }

  void _openVisits() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
    );
  }

  void _openFollowUps() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SalesManagerFollowUpsScreen()),
    );
  }

  void _openPerformance() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SalesManagerPerformanceScreen()),
    );
  }

  void _openAttendance() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SalesManagerAttendanceScreen()),
    );
  }
}

class _GreetingPanel extends StatelessWidget {
  final _DashboardData data;
  final VoidCallback onAttendanceTap;

  const _GreetingPanel({required this.data, required this.onAttendanceTap});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF4D8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wb_sunny_outlined,
              color: Color(0xFFF59E0B),
              size: 26,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()},',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 19,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Stay focused and close more deals today!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (data.attendance != null) ...[
                  const SizedBox(height: 7),
                  InkWell(
                    onTap: onAttendanceTap,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFFDDE7E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Checked In - ${_formatTime(data.attendance!.checkIn!)}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onCreateOrder;
  final VoidCallback onCreateQuotation;
  final VoidCallback onAddCustomer;
  final VoidCallback onAddLead;
  final VoidCallback onScheduleVisit;

  const _QuickActions({
    required this.onCreateOrder,
    required this.onCreateQuotation,
    required this.onAddCustomer,
    required this.onAddLead,
    required this.onScheduleVisit,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction('Create Order', Icons.shopping_cart_outlined, onCreateOrder),
      _QuickAction(
        'Create Quotation',
        Icons.description_outlined,
        onCreateQuotation,
      ),
      _QuickAction('Add Customer', Icons.person_add_alt_1_outlined, onAddCustomer),
      _QuickAction('Add Lead', Icons.group_add_outlined, onAddLead),
      _QuickAction('Schedule Visit', Icons.event_available_outlined, onScheduleVisit),
    ];

    return _Panel(
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              for (var i = 0; i < actions.length; i++) ...[
                Expanded(child: _QuickActionTile(action: actions[i])),
                if (i != actions.length - 1)
                  Container(width: 1, height: 42, color: const Color(0xFFE6EBF0)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final _DashboardData data;

  const _StatsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatCardData(
        'Assigned Customers',
        data.activeCustomers.toString(),
        'Active accounts',
        Icons.groups_2_outlined,
        AppColors.primary,
      ),
      _StatCardData(
        'Visits Today',
        data.visitsToday.toString(),
        'Planned visits',
        Icons.calendar_month_outlined,
        const Color(0xFF2563EB),
      ),
      _StatCardData(
        'Pending Follow-ups',
        data.pendingFollowUps.toString(),
        'Require attention',
        Icons.history_rounded,
        const Color(0xFFF97316),
      ),
      _StatCardData(
        'Orders This Month',
        data.ordersThisMonth.length.toString(),
        'Total orders',
        Icons.bar_chart_rounded,
        const Color(0xFF16A34A),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: stats.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: constraints.maxWidth >= 760 ? 2.75 : 2.35,
          ),
          itemBuilder: (context, index) => _StatCard(data: stats[index]),
        );
      },
    );
  }
}

class _SalesTargetCard extends StatelessWidget {
  final _DashboardData data;

  const _SalesTargetCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final progress = (data.monthlySales / _SalesManagerDashboardScreenState._monthlyTarget)
        .clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return _Panel(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.track_changes_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Monthly Sales Target',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _currency(_SalesManagerDashboardScreenState._monthlyTarget),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'Target',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            _currency(data.monthlySales),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Current Sales',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFDDEFE4),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrioritiesCard extends StatelessWidget {
  final _DashboardData data;
  final VoidCallback onFollowUps;
  final VoidCallback onVisits;
  final VoidCallback onQuotations;

  const _PrioritiesCard({
    required this.data,
    required this.onFollowUps,
    required this.onVisits,
    required this.onQuotations,
  });

  @override
  Widget build(BuildContext context) {
    final rows = [
      _PriorityRowData(
        'Overdue Follow-ups',
        'Customers need attention',
        data.pendingFollowUps,
        Icons.error_outline_rounded,
        AppColors.deliveryRed,
        onFollowUps,
      ),
      _PriorityRowData(
        'Visits Today',
        'Planned for today',
        data.visitsToday,
        Icons.calendar_month_outlined,
        const Color(0xFF2563EB),
        onVisits,
      ),
      _PriorityRowData(
        'Quotations Awaiting Response',
        'Awaiting customer reply',
        data.quotationsAwaiting,
        Icons.description_outlined,
        const Color(0xFFF97316),
        onQuotations,
      ),
      _PriorityRowData(
        'Deliveries Today',
        'Scheduled deliveries',
        data.deliveriesToday,
        Icons.local_shipping_outlined,
        AppColors.primary,
        null,
      ),
    ];

    return _Panel(
      child: Column(
        children: [
          _SectionTitle(
            title: "Today's Priorities",
            action: 'View all priorities',
            onAction: onFollowUps,
          ),
          const SizedBox(height: 6),
          for (final row in rows) _PriorityRow(row: row),
        ],
      ),
    );
  }
}

class _OrderStatusCard extends StatelessWidget {
  final _DashboardData data;
  final VoidCallback onViewAll;

  const _OrderStatusCard({required this.data, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      _StatusTileData('Draft', data.draftOrders, Icons.description_outlined, const Color(0xFF7C3AED)),
      _StatusTileData('Confirmed', data.confirmedOrders, Icons.fact_check_outlined, const Color(0xFF2563EB)),
      _StatusTileData('Completed', data.completedOrders, Icons.check_circle_outline_rounded, AppColors.primary),
      _StatusTileData('Cancelled', data.cancelledOrders, Icons.cancel_outlined, AppColors.deliveryRed),
    ];

    return _Panel(
      child: Column(
        children: [
          _SectionTitle(
            title: 'Order Status',
            action: 'View all orders',
            onAction: onViewAll,
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: statuses.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3.25,
                ),
                itemBuilder: (context, index) => _StatusTile(data: statuses[index]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VisitsCard extends StatelessWidget {
  final List<_VisitRecord> visits;
  final VoidCallback onViewAll;

  const _VisitsCard({required this.visits, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          _SectionTitle(title: 'My Visits', action: 'View all visits', onAction: onViewAll),
          const SizedBox(height: 6),
          if (visits.isEmpty)
            const _EmptyInline('No visits scheduled.')
          else
            for (final visit in visits) _VisitRow(visit: visit),
          const SizedBox(height: 2),
          const _FooterNote('No more visits'),
        ],
      ),
    );
  }
}

class _RecentOrdersCard extends StatelessWidget {
  final List<_DashboardOrder> orders;
  final VoidCallback onViewAll;

  const _RecentOrdersCard({required this.orders, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        children: [
          _SectionTitle(title: 'Recent Orders', action: 'View all orders', onAction: onViewAll),
          const SizedBox(height: 8),
          if (orders.isEmpty)
            const _EmptyInline('No orders yet.')
          else
            for (final order in orders) _OrderRow(order: order),
          const SizedBox(height: 2),
          const _FooterNote('No more orders'),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction action;

  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, color: AppColors.primary, size: 23),
              const SizedBox(height: 5),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 10.5,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 19),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 19,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11.5,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final _PriorityRowData row;

  const _PriorityRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: row.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: Row(
            children: [
              _TintIcon(icon: row.icon, color: row.color, size: 34),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      row.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                row.count.toString(),
                style: TextStyle(
                  color: row.color,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final _StatusTileData data;

  const _StatusTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          _TintIcon(icon: data.icon, color: data.color, size: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.count.toString(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisitRow extends StatelessWidget {
  final _VisitRecord visit;

  const _VisitRow({required this.visit});

  @override
  Widget build(BuildContext context) {
    final color = _visitStatusColor(visit.status);
    return _ListRow(
      leading: _InitialsAvatar(name: visit.customer),
      title: visit.customer,
      subtitle: visit.purpose,
      middle: '${_formatShortDate(visit.dateTime)}\n${visit.time}',
      trailing: _Pill(label: visit.status, color: color),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final _DashboardOrder order;

  const _OrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final color = _orderStatusColor(order.status);
    return _ListRow(
      leading: _TintIcon(icon: Icons.description_outlined, color: AppColors.primary),
      title: order.number,
      subtitle: order.customer,
      middle: '${_currency(order.total)}\n${_formatShortDate(order.date)}',
      trailing: _Pill(label: _orderStatusLabel(order.status), color: color),
    );
  }
}

class _ListRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final String middle;
  final Widget trailing;

  const _ListRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.middle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 9),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              middle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(child: trailing),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const _SectionTitle({
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
            fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onAction,
          label: Text(action),
          icon: const Icon(Icons.chevron_right_rounded, size: 16),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _TintIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _TintIcon({required this.icon, required this.color, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size / 3.5),
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String name;

  const _InitialsAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD6E6FF)),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isEmpty ? 'SM' : initials,
        style: const TextStyle(
          color: Color(0xFF2563EB),
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;

  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(11),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _EmptyInline extends StatelessWidget {
  final String message;

  const _EmptyInline(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  final String text;

  const _FooterNote(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 12),
          Text(
            'Loading your dashboard...',
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _Panel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.deliveryRed,
                size: 36,
              ),
              const SizedBox(height: 10),
              const Text(
                'Dashboard could not load',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardData {
  final String userName;
  final List<CustomerModel> customers;
  final List<_DashboardOrder> orders;
  final List<_DashboardQuotation> quotations;
  final _AttendanceRecord? attendance;
  final List<_VisitRecord> visits;

  const _DashboardData({
    required this.userName,
    required this.customers,
    required this.orders,
    required this.quotations,
    required this.attendance,
    required this.visits,
  });

  factory _DashboardData.empty() {
    return const _DashboardData(
      userName: 'User',
      customers: [],
      orders: [],
      quotations: [],
      attendance: null,
      visits: [],
    );
  }

  List<_DashboardOrder> get ordersThisMonth {
    final now = DateTime.now();
    return orders.where((order) {
      return !_isCancelled(order.status) &&
          order.date.year == now.year &&
          order.date.month == now.month;
    }).toList();
  }

  List<_DashboardOrder> get recentOrders {
    final sorted = [...orders]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(3).toList();
  }

  List<_VisitRecord> get recentVisits {
    final sorted = [...visits]..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return sorted.take(3).toList();
  }

  double get monthlySales {
    return ordersThisMonth.fold(0, (sum, order) => sum + order.total);
  }

  int get activeCustomers {
    return customers.where((customer) => customer.isActive != false).length;
  }

  int get visitsToday {
    return visits.where((visit) => _isSameDay(visit.dateTime, DateTime.now())).length;
  }

  int get pendingFollowUps {
    return visits
        .where((visit) => visit.status.toLowerCase() == 'follow-up required')
        .length;
  }

  int get quotationsAwaiting {
    return quotations.where((quotation) => quotation.status == 'sent').length;
  }

  int get deliveriesToday {
    return orders.where((order) {
      final deliveryDate = order.deliveryDate;
      return deliveryDate != null &&
          !_isCancelled(order.status) &&
          _isSameDay(deliveryDate, DateTime.now());
    }).length;
  }

  int get draftOrders {
    return orders.where((order) {
      final status = order.status;
      return status == 'draft' || status == 'placed';
    }).length;
  }

  int get confirmedOrders {
    return orders.where((order) => order.status == 'confirmed').length;
  }

  int get completedOrders {
    return orders.where((order) {
      final status = order.status;
      return status == 'completed' || status == 'delivered';
    }).length;
  }

  int get cancelledOrders {
    return orders.where((order) => _isCancelled(order.status)).length;
  }
}

class _DashboardOrder {
  final String id;
  final String number;
  final String customer;
  final double total;
  final String status;
  final DateTime date;
  final DateTime? deliveryDate;

  const _DashboardOrder({
    required this.id,
    required this.number,
    required this.customer,
    required this.total,
    required this.status,
    required this.date,
    required this.deliveryDate,
  });

  factory _DashboardOrder.fromJson(Map<String, dynamic> json) {
    final order = _readMap(json, const ['order']);
    final source = order.isEmpty ? json : <String, dynamic>{...json, ...order};
    final customer = _readMap(source, const ['customer']);
    return _DashboardOrder(
      id: _readString(source, const ['id', '_id', 'order_id', 'orderId']),
      number: _readString(
        source,
        const ['order_number', 'orderNumber', 'number', 'invoice_number'],
        fallback: 'ORD-${_readString(source, const ['id', '_id']).takeLast(4)}',
      ),
      customer: _firstNonEmpty([
        _readString(source, const ['customer_name', 'customerName']),
        _readString(customer, const ['name', 'full_name', 'business_name']),
        'Customer',
      ]),
      total: _readDouble(source, const [
        'total',
        'grand_total',
        'grandTotal',
        'amount',
        'total_amount',
        'totalAmount',
      ]),
      status: _normalize(_readString(source, const ['status'], fallback: 'draft')),
      date: _readDate(
        _readString(source, const [
          'order_date',
          'orderDate',
          'date',
          'created_at',
          'createdAt',
        ]),
      ),
      deliveryDate: _readNullableDate(
        _readString(source, const [
          'delivery_date',
          'deliveryDate',
          'scheduled_delivery_date',
          'scheduledDeliveryDate',
        ]),
      ),
    );
  }
}

class _DashboardQuotation {
  final String status;

  const _DashboardQuotation({required this.status});

  factory _DashboardQuotation.fromJson(Map<String, dynamic> json) {
    final quotation = _readMap(json, const ['quotation']);
    final source = quotation.isEmpty
        ? json
        : <String, dynamic>{...json, ...quotation};
    return _DashboardQuotation(
      status: _normalize(_readString(source, const ['status'])),
    );
  }
}

class _AttendanceRecord {
  final DateTime date;
  final DateTime? checkIn;

  const _AttendanceRecord({required this.date, required this.checkIn});

  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final date = _readNullableDate(
          _readString(json, const ['date', 'attendance_date', 'created_at']),
        ) ??
        DateTime.now();
    return _AttendanceRecord(
      date: date,
      checkIn: _readNullableDate(
        _readString(json, const [
          'check_in',
          'checkIn',
          'check_in_time',
          'checkInTime',
          'checked_in_at',
          'checkedInAt',
        ]),
      ),
    );
  }
}

class _VisitRecord {
  final String customer;
  final String purpose;
  final String date;
  final String time;
  final String status;

  const _VisitRecord({
    required this.customer,
    required this.purpose,
    required this.date,
    required this.time,
    required this.status,
  });

  DateTime get dateTime => _readDate(date);
}

class _QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAction(this.label, this.icon, this.onTap);
}

class _StatCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCardData(
    this.title,
    this.value,
    this.subtitle,
    this.icon,
    this.color,
  );
}

class _PriorityRowData {
  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _PriorityRowData(
    this.title,
    this.subtitle,
    this.count,
    this.icon,
    this.color,
    this.onTap,
  );
}

class _StatusTileData {
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _StatusTileData(this.label, this.count, this.icon, this.color);
}

extension _StringTail on String {
  String takeLast(int count) {
    if (length <= count) return this;
    return substring(length - count);
  }
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

_AttendanceRecord? _firstTodayAttendance(
  Iterable<_AttendanceRecord> records,
) {
  for (final record in records) {
    return record;
  }
  return null;
}

bool _isCancelled(String status) {
  return status == 'cancelled' || status == 'canceled';
}

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
}

String _orderStatusLabel(String status) {
  if (status == 'placed' || status == 'draft') return 'Draft';
  return status
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

Color _orderStatusColor(String status) {
  if (status == 'confirmed') return const Color(0xFF2563EB);
  if (status == 'completed' || status == 'delivered') return AppColors.primary;
  if (_isCancelled(status)) return AppColors.deliveryRed;
  return const Color(0xFF7C3AED);
}

Color _visitStatusColor(String status) {
  final normalized = status.toLowerCase();
  if (normalized == 'completed') return AppColors.primary;
  if (normalized == 'scheduled') return const Color(0xFF2563EB);
  if (normalized == 'follow-up required') return const Color(0xFFF97316);
  if (normalized == 'missed') return AppColors.deliveryRed;
  return AppColors.textMuted;
}

String _currency(double value) {
  final rounded = value.round();
  final text = rounded.toString();
  if (text.length <= 3) return 'Rs. $text';

  final lastThree = text.substring(text.length - 3);
  var leading = text.substring(0, text.length - 3);
  final groups = <String>[];
  while (leading.length > 2) {
    groups.insert(0, leading.substring(leading.length - 2));
    leading = leading.substring(0, leading.length - 2);
  }
  if (leading.isNotEmpty) groups.insert(0, leading);
  return 'Rs. ${groups.join(',')},$lastThree';
}

String _formatShortDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year}';
}

String _formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour == 0
      ? 12
      : local.hour > 12
      ? local.hour - 12
      : local.hour;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${hour.toString().padLeft(2, '0')}:$minute $period';
}

String _cleanError(Object? error) {
  final text = error?.toString().trim() ?? '';
  if (text.isEmpty) return 'Something went wrong.';
  return text.replaceFirst('ApiException: ', '');
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return const {};
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    final text = value.trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(
        value.replaceAll(',', '').replaceAll('Rs.', '').trim(),
      );
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

DateTime _readDate(String value) {
  return _readNullableDate(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? _readNullableDate(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text)?.toLocal();
}
