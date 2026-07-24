import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/soft_action_button.dart';
import '../inventory/inventory_screen.dart';
import '../products/products_screen.dart';
import '../profile/admin_profile_screen.dart';
import '../purchases/purchases_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/admin_settings_screen.dart';
import '../users/admin_user_list_screen.dart';

/// Date-range filters required by BRD section 5 ("Dashboard Charts" filters).
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  DashboardRange _selectedRange = DashboardRange.today;
  DateTimeRange? _customRange;
  bool _isLoading = false;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  // TODO(api): replace every mocked field below with data pulled from
  // ApiService, scoped by `_selectedRange` / `_customRange`. Kept as static
  // mock data here only so the widget tree / BRD coverage can be reviewed
  // without a backend wired up yet.

  // --- 13 summary cards required by BRD section 5 ("Dashboard Summary Cards") ---
  List<_StatItem> get _stats => [
    _StatItem(
      "Today's Sales",
      'Rs. 23,242',
      Icons.currency_rupee,
      AppColors.green,
      onTap: () => _openReports(context),
    ),
    _StatItem(
      'Monthly Sales',
      'Rs. 66,160',
      Icons.calendar_month,
      AppColors.purple,
      onTap: () => _openReports(context),
    ),
    _StatItem(
      'Yearly Sales',
      'Rs. 4,12,500',
      Icons.event,
      AppColors.blue,
      onTap: () => _openReports(context),
    ),
    _StatItem(
      "Today's Purchases",
      'Rs. 8,400',
      Icons.shopping_bag_outlined,
      AppColors.orange,
      onTap: () => _openPurchases(context),
    ),
    _StatItem(
      'Monthly Purchases',
      'Rs. 1,89,215',
      Icons.inventory_2,
      AppColors.teal,
      onTap: () => _openPurchases(context),
    ),
    _StatItem(
      'Total Customers',
      '186',
      Icons.groups_outlined,
      AppColors.purple,
    ),
    _StatItem(
      'Total Products',
      '92',
      Icons.category_outlined,
      AppColors.blue,
      onTap: () => _openProducts(context),
    ),
    _StatItem(
      'Total Users',
      '14',
      Icons.badge_outlined,
      AppColors.teal,
      onTap: () => _openUsers(context),
    ),
    _StatItem(
      'Outstanding Receivables',
      'Rs. 74,320',
      Icons.call_received,
      AppColors.red,
      onTap: () => _openReports(context),
    ),
    _StatItem(
      'Outstanding Payables',
      'Rs. 41,050',
      Icons.call_made,
      AppColors.amber,
      onTap: () => _openReports(context),
    ),
    _StatItem(
      'Low Stock Items',
      '5',
      Icons.warning_amber_rounded,
      AppColors.amber,
      onTap: () => _openInventory(context),
    ),
    _StatItem(
      'Pending Orders',
      '6',
      Icons.schedule,
      AppColors.blue,
    ),
    _StatItem(
      'Pending Deliveries',
      '9',
      Icons.local_shipping_outlined,
      AppColors.orange,
    ),
  ];

  // --- Sales trend (daily/monthly/yearly depending on selected range) ---
  final List<double> _salesTrend = const [
    12000, 15400, 9800, 18200, 22400, 19800, 23242,
  ];
  final List<String> _salesTrendLabels = const [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  // --- Purchase vs Sales comparison ---
  final List<_PurchaseSalesPoint> _purchaseVsSales = const [
    _PurchaseSalesPoint('Feb', 42000, 31000),
    _PurchaseSalesPoint('Mar', 51000, 38500),
    _PurchaseSalesPoint('Apr', 47500, 40200),
    _PurchaseSalesPoint('May', 66160, 48900),
  ];

  final List<_ProductRevenue> _topProducts = const [
    _ProductRevenue('Water Jar Refill (20L)', 14400),
    _ProductRevenue('Water Dispenser - Normal', 11200),
    _ProductRevenue('Water Dispenser - Hot & Cold', 9000),
    _ProductRevenue('Packaged Drinking Water (1L)', 6400),
  ];

  // --- Top-performing Sales Officers ---
  final List<_ProductRevenue> _topSalesOfficers = const [
    _ProductRevenue('Ravi Kumar', 28400),
    _ProductRevenue('Ananya Singh', 21200),
    _ProductRevenue('Mohit Sharma', 16600),
  ];

  // --- Category-wise sales ---
  final List<_CategorySlice> _categorySales = const [
    _CategorySlice('Water Jars', 32000, AppColors.blue),
    _CategorySlice('Dispensers', 18400, AppColors.purple),
    _CategorySlice('Packaged Water', 9600, AppColors.teal),
    _CategorySlice('Others', 6160, AppColors.amber),
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

  Future<void> _onRangeSelected(DashboardRange range) async {
    if (range == DashboardRange.custom) {
      final now = DateTime.now();
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(now.year - 2),
        lastDate: now,
        initialDateRange: _customRange ??
            DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      );
      if (picked == null) return;
      setState(() {
        _customRange = picked;
        _selectedRange = DashboardRange.custom;
      });
    } else {
      setState(() => _selectedRange = range);
    }
    // TODO(api): trigger ApiService call(s) here using _selectedRange /
    // _customRange and refresh _stats, _salesTrend, _purchaseVsSales, etc.
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (mounted) setState(() => _isLoading = false);
  }

  void _openReports(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsScreen()));
  }

  void _openPurchases(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PurchasesScreen()));
  }

  void _openProducts(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsScreen()));
  }

  void _openUsers(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminUserListScreen()));
  }

  void _openInventory(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InventoryScreen()));
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
              child: RefreshIndicator(
                onRefresh: () => _onRangeSelected(_selectedRange),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                      const SizedBox(height: 16),
                      _buildRangeFilterBar(),
                      if (_isLoading) ...[
                        const SizedBox(height: 12),
                        const LinearProgressIndicator(
                          color: AppColors.purple,
                          backgroundColor: AppColors.surfaceSoft,
                        ),
                      ],
                      const SizedBox(height: 20),
                      _buildStatsGrid(),
                      const SizedBox(height: 20),
                      _buildSalesTrendChart(),
                      const SizedBox(height: 20),
                      _buildPurchaseVsSalesChart(),
                      const SizedBox(height: 20),
                      _buildTopProducts(),
                      const SizedBox(height: 20),
                      _buildTopSalesOfficers(),
                      const SizedBox(height: 20),
                      _buildCategoryWiseSales(),
                      const SizedBox(height: 20),
                      _buildOutstandingPayments(),
                      const SizedBox(height: 20),
                      _buildRecentOrders(filteredOrders),
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

  /// BRD 5: "Filters should include: Today, Yesterday, This Week, This
  /// Month, Previous Month, This Financial Year, Previous Financial Year,
  /// Custom Date Range."
  Widget _buildRangeFilterBar() {
    final label = _selectedRange == DashboardRange.custom && _customRange != null
        ? '${_fmtDate(_customRange!.start)} - ${_fmtDate(_customRange!.end)}'
        : null;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: DashboardRange.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final range = DashboardRange.values[index];
          final isSelected = _selectedRange == range;
          final text = range == DashboardRange.custom && label != null
              ? label
              : range.label;

          return ChoiceChip(
            label: Text(text),
            selected: isSelected,
            onSelected: (_) => _onRangeSelected(range),
            selectedColor: AppColors.purple.withValues(alpha: 0.14),
            backgroundColor: AppColors.surfaceSoft,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.purple : textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: isSelected
                    ? AppColors.purple
                    : AppColors.secondary.withValues(alpha: 0.2),
              ),
            ),
          );
        },
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Widget _buildStatsGrid() {
    final stats = _stats;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.22,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _CardContainer(
          onTap: stat.onTap,
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

  /// BRD 5: "Daily sales trends / Monthly sales trends / Yearly sales
  /// trends" — rendered as a single trend chart that re-populates based on
  /// `_selectedRange`.
  Widget _buildSalesTrendChart() {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Trend',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Revenue for ${_selectedRange.label.toLowerCase()}',
            style: const TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 180,
            child: Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: _LineSparklinePainter(
                      values: _salesTrend,
                      lineColor: AppColors.purple,
                      fillColor: AppColors.purple.withValues(alpha: 0.12),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final label in _salesTrendLabels)
                      Expanded(
                        child: Center(
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// BRD 5: "Purchase versus sales comparison"
  Widget _buildPurchaseVsSalesChart() {
    final maxVal = _purchaseVsSales
        .expand((p) => [p.purchases, p.sales])
        .reduce((a, b) => a > b ? a : b);

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Purchases vs Sales',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Monthly comparison',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legendDot(AppColors.blue, 'Sales'),
              const SizedBox(width: 16),
              _legendDot(AppColors.orange, 'Purchases'),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              for (final point in _purchaseVsSales)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            point.month,
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Sales Rs. ${point.sales.toStringAsFixed(0)} | Purchases Rs. ${point.purchases.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _comparisonBar(
                        label: 'Sales',
                        value: point.sales,
                        maxValue: maxVal,
                        color: AppColors.blue,
                      ),
                      const SizedBox(height: 6),
                      _comparisonBar(
                        label: 'Purchases',
                        value: point.purchases,
                        maxValue: maxVal,
                        color: AppColors.orange,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _comparisonBar({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
  }) {
    final progress = (value / maxValue).clamp(0.08, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Rs. ${value.toStringAsFixed(0)}',
              style: const TextStyle(
                color: textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.14),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTopProducts() {
    return _rankedList(
      title: 'Top Products',
      subtitle: 'By revenue this month',
      items: _topProducts,
      barColor: AppColors.purple,
    );
  }

  /// BRD 5: "Top-performing Sales Officers"
  Widget _buildTopSalesOfficers() {
    return _rankedList(
      title: 'Top Sales Officers',
      subtitle: 'By revenue this month',
      items: _topSalesOfficers,
      barColor: AppColors.teal,
    );
  }

  Widget _rankedList({
    required String title,
    required String subtitle,
    required List<_ProductRevenue> items,
    required Color barColor,
  }) {
    final maxRevenue = items.map((p) => p.revenue).reduce((a, b) => a > b ? a : b);

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: textSecondary, fontSize: 12)),
          const SizedBox(height: 18),
          ...items.map((item) {
            final widthFactor = (item.revenue / maxRevenue).clamp(0.08, 1.0);
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
                          item.name,
                          style: const TextStyle(color: textPrimary, fontSize: 13),
                        ),
                      ),
                      Text(
                        'Rs. ${item.revenue.toStringAsFixed(0)}',
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
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.14),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
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

  /// BRD 5: "Category-wise sales"
  Widget _buildCategoryWiseSales() {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category-wise Sales',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: CustomPaint(
                  painter: _DonutChartPainter(slices: _categorySales),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final c in _categorySales)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: c.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c.name,
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              'Rs. ${c.value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
        ],
      ),
    );
  }

  /// BRD 5: "Outstanding payments"
  Widget _buildOutstandingPayments() {
    const receivables = 74320.0;
    const payables = 41050.0;
    final maxVal = receivables > payables ? receivables : payables;

    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Outstanding Payments',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Receivables vs payables',
            style: TextStyle(color: textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 18),
          _outstandingRow('Receivables', receivables, maxVal, AppColors.red),
          const SizedBox(height: 14),
          _outstandingRow('Payables', payables, maxVal, AppColors.amber),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _openReports(context),
              child: const Text('View full report'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _outstandingRow(String label, double value, double maxVal, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: textPrimary, fontSize: 13)),
            Text(
              'Rs. ${value.toStringAsFixed(0)}',
              style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (value / maxVal).clamp(0.05, 1.0),
            minHeight: 10,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.14),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
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
                onPressed: () {
                  // TODO(nav): push the sales-order creation screen once it
                  // exists (BRD 4.7 "Create sales orders").
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('New Order screen not wired yet')),
                  );
                },
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
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _openReports(context),
              child: const Text('View all orders'),
            ),
          ),
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
  final VoidCallback? onTap;

  const _CardContainer({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
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

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class _LineSparklinePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  _LineSparklinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal).abs() < 0.0001 ? 1.0 : (maxVal - minVal);
    final horizontalStep = values.length == 1 ? size.width : size.width / (values.length - 1);
    final points = <Offset>[];

    for (var i = 0; i < values.length; i++) {
      final x = i * horizontalStep;
      final normalized = (values[i] - minVal) / range;
      final y = size.height - (normalized * (size.height - 24)) - 12;
      points.add(Offset(x, y));
    }

    final areaPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);

    for (var i = 1; i < points.length; i++) {
      areaPath.lineTo(points[i].dx, points[i].dy);
    }

    areaPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(areaPath, fillPaint);
    canvas.drawPath(linePath, paint);
  }

  @override
  bool shouldRepaint(covariant _LineSparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<_CategorySlice> slices;

  _DonutChartPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;

    final total = slices.fold<double>(0, (sum, slice) => sum + slice.value);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final strokeWidth = 24.0;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var startAngle = -math.pi / 2;

    for (final slice in slices) {
      final sweep = (slice.value / total) * math.pi * 2;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    final holePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - strokeWidth / 2, holePaint);
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatItem(this.label, this.value, this.icon, this.color, {this.onTap});
}

class _ProductRevenue {
  final String name;
  final double revenue;

  const _ProductRevenue(this.name, this.revenue);
}

class _CategorySlice {
  final String name;
  final double value;
  final Color color;

  const _CategorySlice(this.name, this.value, this.color);
}

class _PurchaseSalesPoint {
  final String month;
  final double purchases;
  final double sales;

  const _PurchaseSalesPoint(this.month, this.purchases, this.sales);
}

class _OrderItem {
  final String orderNo;
  final String customer;
  final String status;

  const _OrderItem(this.orderNo, this.customer, this.status);
}
