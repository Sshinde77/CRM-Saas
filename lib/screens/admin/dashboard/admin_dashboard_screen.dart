import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/admin_dashboard_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../invoices/invoices_screen.dart';
import '../purchases/purchases_screen.dart';
import '../reports/reports_screen.dart';

enum DashboardRange {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  previousMonth,
  thisFY,
  previousFY,
  custom,
}

extension on DashboardRange {
  String get label {
    switch (this) {
      case DashboardRange.today:
        return 'Today';
      case DashboardRange.yesterday:
        return 'Yesterday';
      case DashboardRange.thisWeek:
        return 'This Week';
      case DashboardRange.thisMonth:
        return 'This Month';
      case DashboardRange.previousMonth:
        return 'Previous Month';
      case DashboardRange.thisFY:
        return 'This Financial Year';
      case DashboardRange.previousFY:
        return 'Previous Financial Year';
      case DashboardRange.custom:
        return 'Custom Range';
    }
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const Color _green = Color(0xFF08763A);
  static const Color _darkGreen = Color(0xFF00451F);
  static const Color _lime = Color(0xFF56D36F);
  static const Color _red = Color(0xFFFF4B4B);
  static const Color _blue = Color(0xFF3168FF);
  static const Color _orange = Color(0xFFFF9F1C);
  static const Color _violet = Color(0xFF7C3EFF);
  static const Color _teal = Color(0xFF009688);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService _apiService = ApiService();

  DashboardRange _selectedRange = DashboardRange.thisMonth;
  DateTimeRange? _customRange;
  Future<AdminDashboardData>? _dashboardFuture;
  AdminDashboardData? _lastDashboard;
  bool _productsByAmount = true;
  String? _refreshWarning;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  @override
  void dispose() {
    _apiService.close();
    super.dispose();
  }

  void _loadDashboard({bool keepCurrent = false}) {
    final query = _dateQuery();
    final future = _apiService.fetchAdminDashboard(
      dateFrom: query.$1,
      dateTo: query.$2,
    );

    setState(() {
      _refreshWarning = null;
      _dashboardFuture = future;
      if (!keepCurrent) _lastDashboard = null;
    });

    future
        .then((data) {
          if (!mounted) return;
          setState(() => _lastDashboard = data);
        })
        .catchError((error) {
          if (!mounted || _lastDashboard == null) return;
          setState(() => _refreshWarning = _readableError(error));
        });
  }

  Future<void> _onRefresh() async {
    _loadDashboard(keepCurrent: true);
    try {
      await _dashboardFuture;
    } catch (_) {
      // The visible stale-data warning/error card handles refresh failures.
    }
  }

  Future<void> _selectRange(DashboardRange range) async {
    if (range == DashboardRange.custom) {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 3),
        lastDate: now,
        initialDateRange:
            _customRange ??
            DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            ),
      );
      if (picked == null) return;
      setState(() {
        _customRange = picked;
        _selectedRange = DashboardRange.custom;
      });
    } else {
      setState(() => _selectedRange = range);
    }
    _loadDashboard(keepCurrent: true);
  }

  (String?, String?) _dateQuery() {
    final now = DateTime.now();
    late DateTime start;
    late DateTime end;

    switch (_selectedRange) {
      case DashboardRange.today:
        start = DateTime(now.year, now.month, now.day);
        end = start;
        break;
      case DashboardRange.yesterday:
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 1));
        end = start;
        break;
      case DashboardRange.thisWeek:
        final today = DateTime(now.year, now.month, now.day);
        start = today.subtract(Duration(days: today.weekday - 1));
        end = now;
        break;
      case DashboardRange.thisMonth:
        start = DateTime(now.year, now.month);
        end = now;
        break;
      case DashboardRange.previousMonth:
        start = DateTime(now.year, now.month - 1);
        end = DateTime(now.year, now.month).subtract(const Duration(days: 1));
        break;
      case DashboardRange.thisFY:
        start = DateTime(now.month >= 4 ? now.year : now.year - 1, 4);
        end = now;
        break;
      case DashboardRange.previousFY:
        final fyYear = now.month >= 4 ? now.year - 1 : now.year - 2;
        start = DateTime(fyYear, 4);
        end = DateTime(fyYear + 1, 3, 31);
        break;
      case DashboardRange.custom:
        if (_customRange == null) return (null, null);
        start = _customRange!.start;
        end = _customRange!.end;
        break;
    }

    return (_apiDate(start), _apiDate(end));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFBFCFB),
      drawer: const AppDrawer(activeItem: 'Dashboard'),
      body: SafeArea(
        child: FutureBuilder<AdminDashboardData>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            final data = snapshot.data ?? _lastDashboard;
            return Column(
              children: [
                AdminTopBar(
                  title: 'Admin Dashboard',
                  leadingIcon: Icons.menu_rounded,
                  onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _filterBar(),
                ),
                Expanded(
                  child:
                      data == null &&
                          snapshot.connectionState == ConnectionState.waiting
                      ? _loadingView()
                      : data == null && snapshot.hasError
                      ? _errorView(snapshot.error)
                      : RefreshIndicator(
                          color: _green,
                          onRefresh: _onRefresh,
                          child: _dashboardBody(data!),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _filterBar() {
    final rangeLabel =
        _selectedRange == DashboardRange.custom && _customRange != null
        ? '${_shortDate(_customRange!.start)} - ${_shortDate(_customRange!.end)}'
        : _selectedRange.label;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PopupMenuButton<DashboardRange>(
              onSelected: _selectRange,
              itemBuilder: (context) => DashboardRange.values
                  .map(
                    (range) =>
                        PopupMenuItem(value: range, child: Text(range.label)),
                  )
                  .toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        rangeLabel,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, height: 24, color: const Color(0xFFE7EBEE)),
          Padding(
            padding: const EdgeInsets.all(6),
            child: ElevatedButton.icon(
              onPressed: () => _loadDashboard(keepCurrent: true),
              icon: const Icon(Icons.filter_alt_outlined, size: 18),
              label: const Text('Apply'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardBody(AdminDashboardData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 920;
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(wide ? 28 : 16, 18, wide ? 28 : 16, 92),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_refreshWarning != null) ...[
                    _warningBanner(_refreshWarning!),
                    const SizedBox(height: 14),
                  ],
                  _salesHero(data),
                  const SizedBox(height: 16),
                  _kpiGrid(data, wide),
                  const SizedBox(height: 18),
                  _quickActions(),
                  const SizedBox(height: 18),
                  _responsiveGrid(
                    wide: wide,
                    children: [_businessSignals(data), _stockWatch(data)],
                  ),
                  const SizedBox(height: 18),
                  _responsiveGrid(
                    wide: wide,
                    children: [
                      _cashflowCard(data),
                      _receivablesCard(data),
                      _expenseCard(data),
                      _salesTrendCard(data),
                      _topProductsCard(data),
                      _topCustomersCard(data),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _recentActivity(data),
                  const SizedBox(height: 18),
                  _recentOrders(data),
                  const SizedBox(height: 18),
                  _reportsGrid(wide),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _salesHero(AdminDashboardData data) {
    final summary = data.summary;
    final orders = data.orders;
    final progress = summary.monthlyTarget <= 0
        ? 0.0
        : (summary.monthSales / summary.monthlyTarget)
              .clamp(0.0, 1.0)
              .toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_darkGreen, Color(0xFF00662F), Color(0xFF064B26)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33005225),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -4,
            top: 12,
            child: Icon(
              Icons.trending_up_rounded,
              size: 116,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Today's Sales",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _money(summary.todaySales),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _heroAmount(
                      'Received',
                      data.receivablesPayables.receivables,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 42,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  Expanded(
                    child: _heroAmount(
                      'Pending',
                      data.receivablesPayables.payables,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Monthly Target ${_money(summary.monthlyTarget)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  color: _lime,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: _heroCount('${orders.total}', 'Orders')),
                    _heroDivider(),
                    Expanded(
                      child: _heroCount('${orders.delivered}', 'Delivered'),
                    ),
                    _heroDivider(),
                    Expanded(child: _heroCount('${orders.pending}', 'Pending')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroAmount(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _money(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCount(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _heroDivider() => Container(
    width: 1,
    height: 34,
    color: Colors.white.withValues(alpha: 0.15),
  );

  Widget _kpiGrid(AdminDashboardData data, bool wide) {
    final summary = data.summary;
    final cards = [
      _KpiSpec(
        'This Month Sales',
        _money(summary.monthSales),
        '${_signed(summary.salesGrowthPercentage)}%',
        'vs last month',
        Icons.shopping_bag_outlined,
        _green,
      ),
      _KpiSpec(
        'Purchases',
        _money(summary.purchases),
        '-5.2%',
        'vs last month',
        Icons.shopping_cart_outlined,
        _violet,
      ),
      _KpiSpec(
        'Expenses',
        _money(summary.expenses),
        '+3.8%',
        'vs last month',
        Icons.account_balance_wallet_outlined,
        _orange,
      ),
      _KpiSpec(
        'Profit Summary',
        _money(summary.netProfit),
        '+18.6%',
        'vs last month',
        Icons.pie_chart_outline_rounded,
        _blue,
      ),
      _KpiSpec(
        'New Customers',
        '${summary.newCustomers}',
        '+22.4%',
        'vs last month',
        Icons.group_outlined,
        _teal,
      ),
      _KpiSpec(
        'Sales Growth',
        '${summary.salesGrowthPercentage.toStringAsFixed(1)}%',
        '+',
        'vs last month',
        Icons.show_chart_rounded,
        const Color(0xFFE91E63),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: wide ? 3 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 112,
      ),
      itemBuilder: (context, index) => _kpiCard(cards[index]),
    );
  }

  Widget _kpiCard(_KpiSpec spec) {
    final positive = !spec.delta.trim().startsWith('-');
    return _card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: spec.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(spec.icon, color: spec.color, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  spec.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            spec.value,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                positive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 14,
                color: positive ? _green : _red,
              ),
              const SizedBox(width: 4),
              Text(
                spec.delta,
                style: TextStyle(
                  color: positive ? _green : _red,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  spec.caption,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    final actions = [
      _ActionSpec(
        'New Sale',
        Icons.shopping_cart_outlined,
        _green,
        () => _open(const InvoicesScreen()),
      ),
      _ActionSpec(
        'New Purchase',
        Icons.shopping_cart_outlined,
        _violet,
        () => _open(const PurchasesScreen()),
      ),
      _ActionSpec(
        'Collect Payment',
        Icons.currency_rupee_rounded,
        _blue,
        () {},
      ),
      _ActionSpec(
        'Pending Orders',
        Icons.pending_actions_outlined,
        _orange,
        () {},
      ),
      _ActionSpec(
        'More',
        Icons.apps_rounded,
        AppColors.textMuted,
        () => _open(const ReportsScreen()),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 106,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final action = actions[index];
              return SizedBox(
                width: 78,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: action.onTap,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE9EDF0)),
                      ),
                      child: Column(
                        children: [
                          Icon(action.icon, color: action.color, size: 32),
                          const Spacer(),
                          Text(
                            action.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              height: 1.12,
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
      ],
    );
  }

  Widget _businessSignals(AdminDashboardData data) {
    final signals = [
      _SignalSpec('Sales Growth', data.summary.salesGrowthPercentage >= 0),
      _SignalSpec('Net Profit', data.summary.netProfit >= 0),
      _SignalSpec(
        'Receivables Overdue',
        data.receivablesPayables.overdueReceivables <= 0,
      ),
      _SignalSpec(
        'Payables Overdue',
        data.receivablesPayables.overduePayables <= 0,
      ),
      _SignalSpec('Order Cancellations', data.orders.cancelled == 0),
    ];

    return _sectionCard(
      title: 'Business Signals',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _money(data.summary.netProfit),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          const Text(
            'Net Profit (This Month)',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 14),
          for (final signal in signals) ...[
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: signal.healthy ? _green : _red,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    signal.label,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(
                  signal.healthy ? Icons.check_circle : Icons.bolt_rounded,
                  size: 17,
                  color: signal.healthy ? _green : _red,
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            height: 68,
            child: CustomPaint(
              painter: _SparklinePainter(
                data.salesTrend.map((e) => e.sales).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockWatch(AdminDashboardData data) {
    final items = data.stockWatch.take(3).toList();
    return _sectionCard(
      title: 'Stock Watch',
      trailing: Text(
        '${data.stockWatch.length} Alerts',
        style: const TextStyle(color: _red, fontWeight: FontWeight.w900),
      ),
      child: items.isEmpty
          ? _emptyText('No stock alerts')
          : Column(
              children: [
                for (final item in items) ...[
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE9EDF0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.textMuted,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.status,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: item.stockPercentage <= 0
                                      ? _red
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 7),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: LinearProgressIndicator(
                                  value: (item.stockPercentage / 100)
                                      .clamp(0.0, 1.0)
                                      .toDouble(),
                                  minHeight: 5,
                                  color: item.stockPercentage <= 0
                                      ? _red
                                      : _orange,
                                  backgroundColor: const Color(0xFFE9EDF0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${item.stockPercentage.round()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                _viewAll(),
              ],
            ),
    );
  }

  Widget _cashflowCard(AdminDashboardData data) {
    return _sectionCard(
      title: 'Cashflow (This Month)',
      child: Column(
        children: [
          Row(
            children: [
              _legend(_green, 'Inflow'),
              const SizedBox(width: 18),
              _legend(_red, 'Outflow'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 178,
            child: data.cashflow.isEmpty
                ? _emptyText('No cashflow data')
                : CustomPaint(
                    painter: _BarChartPainter(data.cashflow),
                    child: const SizedBox.expand(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _receivablesCard(AdminDashboardData data) {
    final rp = data.receivablesPayables;
    final slices = [
      _DonutSlice('Receivables', rp.receivables, _green),
      _DonutSlice('Payables', rp.payables, _red),
    ];
    return _sectionCard(
      title: 'Receivables vs Payables',
      child: Column(
        children: [
          SizedBox(
            height: 154,
            child: CustomPaint(
              painter: _DonutChartPainter(slices),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _money(rp.receivables - rp.payables),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Net',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const Text(
                      'Outstanding',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _legendValue(_green, 'Receivables', rp.receivables),
              ),
              Expanded(child: _legendValue(_red, 'Payables', rp.payables)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Overdue: Rec. ${_money(rp.overdueReceivables)} | Pay. ${_money(rp.overduePayables)}',
            style: const TextStyle(
              color: _red,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _expenseCard(AdminDashboardData data) {
    final colors = [_violet, _blue, _orange, _teal, _green, _red];
    final expenses = data.expenseBreakdown.take(5).toList();
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final slices = [
      for (var i = 0; i < expenses.length; i++)
        _DonutSlice(
          expenses[i].category,
          expenses[i].amount,
          colors[i % colors.length],
        ),
    ];

    return _sectionCard(
      title: 'Expense Breakdown',
      child: expenses.isEmpty
          ? SizedBox(height: 170, child: _emptyText('No expense data'))
          : Column(
              children: [
                SizedBox(
                  height: 152,
                  child: CustomPaint(
                    painter: _DonutChartPainter(slices),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _money(total),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'Total Expenses',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < expenses.length; i++)
                  _expenseRow(expenses[i], colors[i % colors.length]),
              ],
            ),
    );
  }

  Widget _salesTrendCard(AdminDashboardData data) {
    return _sectionCard(
      title: 'Sales Trend (This Month)',
      child: SizedBox(
        height: 226,
        child: data.salesTrend.isEmpty
            ? _emptyText('No sales trend data')
            : CustomPaint(
                painter: _LineChartPainter(data.salesTrend),
                child: const SizedBox.expand(),
              ),
      ),
    );
  }

  Widget _topProductsCard(AdminDashboardData data) {
    final products = data.topProducts.take(5).toList();
    final maxValue = products.fold<double>(
      0,
      (max, p) => math.max(max, _productsByAmount ? p.salesAmount : p.quantity),
    );

    return _sectionCard(
      title: 'Top Selling Products',
      child: products.isEmpty
          ? SizedBox(height: 160, child: _emptyText('No product data'))
          : Column(
              children: [
                Row(
                  children: [
                    _toggleChip(
                      'Amount',
                      _productsByAmount,
                      () => setState(() => _productsByAmount = true),
                    ),
                    const SizedBox(width: 8),
                    _toggleChip(
                      'Quantity',
                      !_productsByAmount,
                      () => setState(() => _productsByAmount = false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < products.length; i++) ...[
                  _rankBar(
                    rank: i + 1,
                    label: products[i].productName,
                    value: _productsByAmount
                        ? _money(products[i].salesAmount)
                        : products[i].quantity.toStringAsFixed(0),
                    percent: maxValue <= 0
                        ? 0
                        : ((_productsByAmount
                                  ? products[i].salesAmount
                                  : products[i].quantity) /
                              maxValue),
                  ),
                  const SizedBox(height: 13),
                ],
                _viewAll(),
              ],
            ),
    );
  }

  Widget _topCustomersCard(AdminDashboardData data) {
    final customers = data.topCustomers.take(5).toList();
    final maxValue = customers.fold<double>(
      0,
      (max, c) => math.max(max, c.sales),
    );
    return _sectionCard(
      title: 'Top 5 Customers by Sales',
      child: customers.isEmpty
          ? SizedBox(height: 160, child: _emptyText('No customer data'))
          : Column(
              children: [
                for (var i = 0; i < customers.length; i++) ...[
                  _rankBar(
                    rank: i + 1,
                    label: customers[i].customerName,
                    value: _money(customers[i].sales),
                    percent: maxValue <= 0 ? 0 : customers[i].sales / maxValue,
                  ),
                  const SizedBox(height: 14),
                ],
                _viewAll(),
              ],
            ),
    );
  }

  Widget _recentActivity(AdminDashboardData data) {
    final orders = data.recentOrders.take(3).toList();
    return _sectionCard(
      title: 'Recent Activity',
      trailing: _viewAll(),
      child: orders.isEmpty
          ? _emptyText('No recent activity')
          : Column(
              children: [
                for (var i = 0; i < orders.length; i++) ...[
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: _avatarColor(i),
                        child: Text(
                          _initials(orders[i].customerName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              orders[i].customerName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${orders[i].orderNumber}   ${_displayDate(orders[i].date)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _statusBadge(orders[i].status),
                    ],
                  ),
                  if (i != orders.length - 1) const Divider(height: 24),
                ],
              ],
            ),
    );
  }

  Widget _recentOrders(AdminDashboardData data) {
    final orders = data.recentOrders.take(5).toList();
    return _sectionCard(
      title: 'Recent Orders',
      trailing: _viewAll(),
      child: orders.isEmpty
          ? _emptyText('No recent orders')
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE9EDF0)),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Order #', style: _TableText.header),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('Customer', style: _TableText.header),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Status', style: _TableText.header),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Total',
                          textAlign: TextAlign.right,
                          style: _TableText.header,
                        ),
                      ),
                    ],
                  ),
                ),
                for (final order in orders)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            order.orderNumber,
                            overflow: TextOverflow.ellipsis,
                            style: _TableText.cell,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            order.customerName,
                            overflow: TextOverflow.ellipsis,
                            style: _TableText.cell,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _statusBadge(order.status),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            _money(order.total),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: _TableText.cell,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _reportsGrid(bool wide) {
    final reports = [
      _ActionSpec(
        'Sales Report',
        Icons.assessment_outlined,
        _blue,
        () => _open(const ReportsScreen()),
      ),
      _ActionSpec(
        'Purchase Report',
        Icons.shopping_cart_outlined,
        _violet,
        () => _open(const ReportsScreen()),
      ),
      _ActionSpec(
        'Profit & Loss',
        Icons.currency_exchange_rounded,
        _green,
        () => _open(const ReportsScreen()),
      ),
      _ActionSpec(
        'Cash Flow Report',
        Icons.payments_outlined,
        _teal,
        () => _open(const ReportsScreen()),
      ),
      _ActionSpec(
        'Inventory Report',
        Icons.inventory_2_outlined,
        _orange,
        () => _open(const ReportsScreen()),
      ),
      _ActionSpec(
        'Tax Report',
        Icons.receipt_long_outlined,
        _red,
        () => _open(const ReportsScreen()),
      ),
      _ActionSpec(
        'AR Aging Report',
        Icons.event_note_outlined,
        _blue,
        () => _open(const ReportsScreen()),
      ),
      _ActionSpec(
        'AP Aging Report',
        Icons.assignment_late_outlined,
        _violet,
        () => _open(const ReportsScreen()),
      ),
      _ActionSpec(
        'Stock Valuation',
        Icons.extension_outlined,
        _green,
        () => _open(const ReportsScreen()),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Important Reports',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reports.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wide ? 3 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 46,
          ),
          itemBuilder: (context, index) {
            final report = reports[index];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: report.onTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE7EBEF)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: report.color.withValues(alpha: 0.09),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(report.icon, size: 17, color: report.color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          report.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _responsiveGrid({required bool wide, required List<Widget> children}) {
    if (!wide) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 14),
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 310,
      ),
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7EBEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _legendValue(Color color, String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _legend(color, label),
        const SizedBox(height: 7),
        Text(
          _money(value),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _expenseRow(AdminExpenseBreakdownItem item, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              item.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            _money(item.amount),
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _rankBar({
    required int rank,
    required String label,
    required String value,
    required double percent,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            '$rank',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: percent.clamp(0.0, 1.0).toDouble(),
                  minHeight: 5,
                  color: _green,
                  backgroundColor: const Color(0xFFE7EBEF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _toggleChip(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _green : Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: active ? _green : const Color(0xFFE1E5E8)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    final normalized = status.toLowerCase();
    final color =
        normalized.contains('deliver') ||
            normalized.contains('success') ||
            normalized.contains('complete')
        ? _green
        : normalized.contains('cancel') || normalized.contains('fail')
        ? _red
        : _orange;
    final label = status.trim().isEmpty ? 'Pending' : status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _viewAll() {
    return TextButton(
      onPressed: () => _open(const ReportsScreen()),
      style: TextButton.styleFrom(
        foregroundColor: _green,
        padding: EdgeInsets.zero,
        minimumSize: const Size(40, 26),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'View all',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _emptyText(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Text(
          message,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _warningBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE2A8)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: _orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Refresh failed. Showing previous data. $message',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 92),
      children: [
        _skeleton(height: 258),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 112,
          ),
          itemBuilder: (_, __) => _skeleton(height: 112),
        ),
      ],
    );
  }

  Widget _skeleton({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _errorView(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: _red, size: 34),
              const SizedBox(height: 12),
              const Text(
                'Dashboard data could not load',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                _readableError(error),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _loadDashboard(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  String _money(double value) {
    final sign = value < 0 ? '-' : '';
    final rounded = value.abs().round().toString();
    final chars = rounded.split('').reversed.toList();
    final grouped = <String>[];
    for (var i = 0; i < chars.length; i++) {
      if (i == 3 || (i > 3 && (i - 3) % 2 == 0)) grouped.add(',');
      grouped.add(chars[i]);
    }
    return '${sign}Rs. ${grouped.reversed.join()}';
  }

  String _signed(double value) =>
      value >= 0 ? '+${value.toStringAsFixed(1)}' : value.toStringAsFixed(1);

  String _apiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _shortDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]}';
  }

  String _displayDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return _shortDate(parsed);
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'NA';
    if (parts.length == 1)
      return parts.first.characters.take(2).toString().toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  Color _avatarColor(int index) =>
      const [_green, _violet, _blue, _orange, _teal][index % 5];

  String _readableError(Object? error) {
    final message = error?.toString() ?? 'Unknown error';
    return message
        .replaceFirst('ApiException: ', '')
        .replaceFirst(RegExp(r'ApiException\(\d+\): '), '');
  }
}

class _KpiSpec {
  final String title;
  final String value;
  final String delta;
  final String caption;
  final IconData icon;
  final Color color;

  const _KpiSpec(
    this.title,
    this.value,
    this.delta,
    this.caption,
    this.icon,
    this.color,
  );
}

class _ActionSpec {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionSpec(this.label, this.icon, this.color, this.onTap);
}

class _SignalSpec {
  final String label;
  final bool healthy;

  const _SignalSpec(this.label, this.healthy);
}

class _DonutSlice {
  final String label;
  final double value;
  final Color color;

  const _DonutSlice(this.label, this.value, this.color);
}

class _TableText {
  static const TextStyle header = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11.5,
    fontWeight: FontWeight.w900,
  );
  static const TextStyle cell = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
  );
}

class _BarChartPainter extends CustomPainter {
  final List<AdminCashflowPoint> points;

  const _BarChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = const Color(0xFFE2E6EA)
      ..strokeWidth = 1;
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    final maxValue = points.fold<double>(
      1,
      (max, p) => math.max(max, math.max(p.inflow, p.outflow)),
    );
    final chartHeight = size.height - 28;
    final step = size.width / points.length;

    for (var i = 0; i <= 3; i++) {
      final y = chartHeight - (chartHeight * i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), axisPaint);
    }

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final x = i * step + step * 0.2;
      final barWidth = math.max(3.0, step * 0.16);
      final inflowHeight = chartHeight * (point.inflow / maxValue);
      final outflowHeight = chartHeight * (point.outflow / maxValue);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, chartHeight - inflowHeight, barWidth, inflowHeight),
          const Radius.circular(4),
        ),
        Paint()..color = _AdminDashboardScreenState._green,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x + barWidth + 3,
            chartHeight - outflowHeight,
            barWidth,
            outflowHeight,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = _AdminDashboardScreenState._red,
      );

      if (i == 0 ||
          i == points.length - 1 ||
          i % math.max(1, points.length ~/ 5) == 0) {
        labelPainter.text = TextSpan(
          text: _dayLabel(point.date),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        );
        labelPainter.layout(maxWidth: step);
        labelPainter.paint(
          canvas,
          Offset(i * step + (step - labelPainter.width) / 2, chartHeight + 10),
        );
      }
    }
  }

  String _dayLabel(String value) {
    final parsed = DateTime.tryParse(value);
    return parsed == null ? value : parsed.day.toString();
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) =>
      oldDelegate.points != points;
}

class _LineChartPainter extends CustomPainter {
  final List<AdminSalesTrendPoint> points;

  const _LineChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - 26;
    final maxValue = points.fold<double>(1, (max, p) => math.max(max, p.sales));
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E6EA)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = _AdminDashboardScreenState._blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = _AdminDashboardScreenState._blue.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    final pointBorderPaint = Paint()
      ..color = _AdminDashboardScreenState._blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path();
    final fillPath = Path();

    for (var i = 0; i <= 3; i++) {
      final y = chartHeight - chartHeight * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? size.width / 2
          : size.width * i / (points.length - 1);
      final y = chartHeight - chartHeight * points[i].sales / maxValue;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y), 3, pointBorderPaint);
    }
    fillPath.lineTo(size.width, chartHeight);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.points != points;
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;

  const _SparklinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final range = math.max(1, maxValue - minValue);
    final path = Path();
    final fill = Path();
    final linePaint = Paint()
      ..color = _AdminDashboardScreenState._green
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y =
          size.height -
          ((values[i] - minValue) / range) * (size.height - 10) -
          5;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = _AdminDashboardScreenState._green,
      );
    }
    fill.lineTo(size.width, size.height);
    fill.close();
    canvas.drawPath(
      fill,
      Paint()
        ..color = _AdminDashboardScreenState._green.withValues(alpha: 0.09),
    );
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.values != values;
}

class _DonutChartPainter extends CustomPainter {
  final List<_DonutSlice> slices;

  const _DonutChartPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * math.pi * 2;
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..color = slice.color
          ..strokeWidth = 23
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.slices != slices;
}
