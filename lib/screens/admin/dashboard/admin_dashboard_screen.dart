import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../inventory/inventory_screen.dart';
import '../invoices/invoices_screen.dart';
import '../products/products_screen.dart';
import '../purchases/purchases_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/admin_settings_screen.dart';
import '../users/admin_user_list_screen.dart';

enum DashboardRange { today, yesterday, thisWeek, thisMonth, previousMonth, thisFY, previousFY, custom }

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

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  String _query = '';
  String _activeNav = 'Dashboard';
  DashboardRange _selectedRange = DashboardRange.thisMonth;
  DateTimeRange? _customRange;
  bool _isLoading = false;

  final List<_SidebarItem> _sidebarItems = const [
    _SidebarItem('Dashboard', Icons.grid_view_rounded),
    _SidebarItem('Payments', Icons.payments_outlined),
    _SidebarItem('Transactions', Icons.swap_horiz_rounded),
    _SidebarItem('Invoices', Icons.description_outlined),
    _SidebarItem('Cards', Icons.credit_card_rounded),
    _SidebarItem('Saving Plans', Icons.savings_outlined),
    _SidebarItem('Investments', Icons.trending_up_rounded),
    _SidebarItem('Inbox', Icons.mail_outline_rounded),
    _SidebarItem('Promos', Icons.local_offer_outlined),
    _SidebarItem('Insights', Icons.insights_outlined),
    _SidebarItem('Settings', Icons.settings_outlined),
    _SidebarItem('Log out', Icons.logout_rounded),
  ];

  final List<_HeroStat> _heroStats = const [
    _HeroStat('Balance Amount', 'Rs. 562,000', '+12.8%', Icons.account_balance_wallet_rounded),
    _HeroStat('Total Income', 'Rs. 78,000', '+17.8%', Icons.payments_rounded),
    _HeroStat('Total Expense', 'Rs. 43,000', '-7.8%', Icons.payments_outlined),
    _HeroStat('Total Savings', 'Rs. 56,000', '+12.4%', Icons.savings_outlined),
  ];

  final List<_PlanItem> _plans = const [
    _PlanItem('Emergency Fund', 'Rs. 5,000', 'Rs. 10,000', 0.50),
    _PlanItem('Vacation Fund', 'Rs. 3,000', 'Rs. 5,000', 0.60),
    _PlanItem('Home Down Payment', 'Rs. 7,250', 'Rs. 20,000', 0.3625),
  ];

  final List<_TrendPoint> _cashflow = const [
    _TrendPoint('Jan', 5.4, 3.2),
    _TrendPoint('Feb', 4.1, 5.0),
    _TrendPoint('Mar', 4.8, 3.9),
    _TrendPoint('Apr', 6.2, 4.4),
    _TrendPoint('May', 4.5, 5.1),
    _TrendPoint('Jun', 5.7, 3.6),
    _TrendPoint('Jul', 4.0, 4.8),
    _TrendPoint('Aug', 4.4, 5.4),
    _TrendPoint('Sep', 6.5, 3.7),
    _TrendPoint('Oct', 5.3, 4.2),
    _TrendPoint('Nov', 4.2, 5.9),
    _TrendPoint('Dec', 4.7, 4.3),
  ];

  final List<_ExpenseSlice> _expenses = const [
    _ExpenseSlice('Rent & Living', 2100, 0.42),
    _ExpenseSlice('Investment', 525, 0.15),
    _ExpenseSlice('Education', 420, 0.12),
    _ExpenseSlice('Food & Drink', 280, 0.08),
    _ExpenseSlice('Entertainment', 175, 0.05),
  ];

  final List<_Transaction> _transactions = const [
    _Transaction('Mobile App Purchase', 'Wed, 12 Jun 2026', 'Rs. 806.50', 'Success', Icons.shopping_bag_outlined),
    _Transaction('Software License', 'Tue, 11 Jun 2026', 'Rs. 102.99', 'Success', Icons.computer_outlined),
    _Transaction('Grocery Purchase', 'Sun, 09 Jun 2026', 'Rs. 2,500.00', 'Success', Icons.local_grocery_store_outlined),
    _Transaction('Travel Expense', 'Fri, 07 Jun 2026', 'Rs. 1,200.00', 'Pending', Icons.flight_takeoff_outlined),
  ];

  final List<_Activity> _activities = const [
    _Activity('Jamie Smith updated account settings', '16:05'),
    _Activity('Alex Johnson logged in', '13:05'),
    _Activity('Morgan Lee added a new savings goal', '02:05'),
    _Activity('Taylor Green reviewed recent transactions', '21:05'),
    _Activity('Wilson Baptista transferred funds', '09:05'),
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
        initialDateRange: _customRange ?? DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
      );
      if (picked == null) return;
      setState(() {
        _customRange = picked;
        _selectedRange = DashboardRange.custom;
      });
    } else {
      setState(() => _selectedRange = range);
    }

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() => _isLoading = false);
  }

  void _openReports(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ReportsScreen()),
    );
  }

  void _navigate(String label) {
    setState(() => _activeNav = label);
    switch (label) {
      case 'Invoices':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InvoicesScreen()));
        break;
      case 'Inventory':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InventoryScreen()));
        break;
      case 'Products':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProductsScreen()));
        break;
      case 'Reports':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReportsScreen()));
        break;
      case 'Settings':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminSettingsScreen()));
        break;
      case 'Users':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminUserListScreen()));
        break;
      case 'Log out':
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logout is not wired yet')));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _query.isEmpty
        ? _transactions
        : _transactions.where((t) => t.title.toLowerCase().contains(_query.toLowerCase()) || t.date.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Dashboard'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 1080;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (wide) SizedBox(width: 264, child: _buildSidebar()),
                Expanded(child: _buildContent(filteredTransactions, wide)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 0, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.water_drop_rounded, color: AppColors.secondary),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'SAAS CRM',
                  style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: _sidebarItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _sidebarItems[index];
                return _SidebarTile(
                  label: item.label,
                  icon: item.icon,
                  active: item.label == _activeNav,
                  onTap: () => _navigate(item.label),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gain full access',
                  style: TextStyle(color: textPrimary, fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Unlock detailed analytics and more controls.',
                  style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Get Pro', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<_Transaction> filteredTransactions, bool wide) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.fromLTRB(wide ? 18 : 16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topBar(wide),
            const SizedBox(height: 18),
            _titleRow(),
            const SizedBox(height: 18),
            if (_isLoading) ...[
              const LinearProgressIndicator(color: AppColors.secondary, backgroundColor: Color(0xFFDDEBD5)),
              const SizedBox(height: 16),
            ],
            _heroRow(),
            const SizedBox(height: 16),
            _quickActions(),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 1040;
                if (stacked) {
                  return Column(
                    children: [
                      _dailyLimitCard(),
                      const SizedBox(height: 16),
                      _savingPlansCard(),
                      const SizedBox(height: 16),
                      _cashflowCard(),
                      const SizedBox(height: 16),
                      _statisticsCard(),
                      const SizedBox(height: 16),
                      _recentActivityCard(),
                      const SizedBox(height: 16),
                      _recentTransactionsCard(filteredTransactions),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          _dailyLimitCard(),
                          const SizedBox(height: 16),
                          _savingPlansCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _cashflowCard(),
                          const SizedBox(height: 16),
                          _recentTransactionsCard(filteredTransactions),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 300,
                      child: Column(
                        children: [
                          _statisticsCard(),
                          const SizedBox(height: 16),
                          _recentActivityCard(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(bool wide) {
    final search = TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: 'Search placeholder',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.10)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          borderSide: BorderSide(color: AppColors.secondary),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 820;
        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _topIcon(Icons.chat_bubble_outline_rounded),
            const SizedBox(width: 8),
            _topIcon(Icons.notifications_none_rounded, badge: true),
            const SizedBox(width: 12),
            _profileChip(),
          ],
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu_rounded),
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: search),
                ],
              ),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        }

        return Row(
          children: [
            const Expanded(
              child: Text(
                'Dashboard',
                style: TextStyle(color: textPrimary, fontSize: 26, fontWeight: FontWeight.w900),
              ),
            ),
            SizedBox(width: wide ? 320 : 260, child: search),
            const SizedBox(width: 12),
            actions,
          ],
        );
      },
    );
  }

  Widget _topIcon(IconData icon, {bool badge = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.10)),
          ),
          child: Icon(icon, size: 20, color: AppColors.accentGrey),
        ),
        if (badge)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: Color(0xFFFF5A5F), shape: BoxShape.circle),
            ),
          ),
      ],
    );
  }

  Widget _profileChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withValues(alpha: 0.12),
            ),
            alignment: Alignment.center,
            child: const Text(
              'AS',
              style: TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Anita Sharma',
            style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
        ],
      ),
    );
  }

  Widget _titleRow() {
    final rangeLabel = _selectedRange == DashboardRange.custom && _customRange != null
        ? '${_formatDate(_customRange!.start)} - ${_formatDate(_customRange!.end)}'
        : _selectedRange.label;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 700;
        final pill = _dropdownPill(rangeLabel);
        final export = ElevatedButton.icon(
          onPressed: () => _openReports(context),
          icon: const Icon(Icons.upload_outlined, size: 18),
          label: const Text('Export'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back, Anita Sharma',
                style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'Monitor and control what happens with your business today.',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 10, runSpacing: 10, children: [pill, export]),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Anita Sharma',
                    style: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Monitor and control what happens with your business today.',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Wrap(spacing: 10, runSpacing: 10, alignment: WrapAlignment.end, children: [pill, export]),
          ],
        );
      },
    );
  }

  Widget _heroRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 900;
        if (stacked) {
          return Column(
            children: [
              _featureCard(),
              const SizedBox(height: 16),
              ..._heroStats.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _miniStatCard(s),
                  )),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _featureCard()),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < _heroStats.length; i++) ...[
                    _miniStatCard(_heroStats[i]),
                    if (i != _heroStats.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _featureCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 22),
              ),
              const Spacer(),
              const Icon(Icons.wifi_rounded, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'SAAS Distributors',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Balance Amount',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.76), fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rs. 562,000',
            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(child: _ChipAction(label: 'Top Up')),
              SizedBox(width: 10),
              Expanded(child: _ChipAction(label: 'Transfer')),
              SizedBox(width: 10),
              Expanded(child: _ChipAction(label: 'Request')),
              SizedBox(width: 10),
              Expanded(child: _ChipAction(label: 'History')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStatCard(_HeroStat stat) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: AppColors.secondary.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stat.icon, color: AppColors.secondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.label, style: const TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Text(stat.value, style: const TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(stat.delta, style: const TextStyle(color: AppColors.secondary, fontSize: 11.5, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _ChipAction(label: 'Top Up'),
        _ChipAction(label: 'Transfer'),
        _ChipAction(label: 'Invoices'),
        _ChipAction(label: 'History'),
      ],
    );
  }

  Widget _dailyLimitCard() {
    return _sectionCard(
      title: 'Daily Limit',
      trailing: const Icon(Icons.more_horiz_rounded, color: AppColors.accentGrey),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rs. 2,500.00 spent of Rs. 20,000.00', style: TextStyle(color: textSecondary, fontSize: 12)),
              Text('12.5%', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 0.125,
              minHeight: 10,
              backgroundColor: const Color(0xFFE3F0DC),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _savingPlansCard() {
    return _sectionCard(
      title: 'Saving Plans',
      trailing: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded, size: 16),
        label: const Text('Add Plan'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Savings', style: TextStyle(color: textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('Rs. 84,500', style: TextStyle(color: textPrimary, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          for (var i = 0; i < _plans.length; i++) ...[
            _planCard(_plans[i]),
            if (i != _plans.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _planCard(_PlanItem plan) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8EE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.savings_outlined, color: AppColors.secondary, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  plan.title,
                  style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              Text(plan.percentLabel, style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: plan.progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE3F0DC),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(plan.currentValue, style: const TextStyle(color: textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
              Text('Target: ${plan.targetValue}', style: const TextStyle(color: textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cashflowCard() {
    final maxValue = _cashflow.map((p) => math.max(p.income, p.expense)).reduce(math.max);
    return _sectionCard(
      title: 'Cashflow',
      trailing: _dropdownPill(_selectedRange.label),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Balance', style: TextStyle(color: textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('Rs. 562,000', style: TextStyle(color: textPrimary, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final point in _cashflow)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(child: Container(height: 160 * (point.income / maxValue), decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(999)))),
                                    const SizedBox(width: 4),
                                    Expanded(child: Container(height: 160 * (point.expense / maxValue), decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(999)))),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(point.label, style: const TextStyle(color: textSecondary, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  _legendDot(AppColors.secondary, 'Income'),
                  const SizedBox(width: 14),
                  _legendDot(AppColors.secondary.withValues(alpha: 0.35), 'Expense'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statisticsCard() {
    return _sectionCard(
      title: 'Statistic',
      trailing: _dropdownPill('This Month'),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _DonutPainter(slices: _expenses),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Total Expense', style: TextStyle(color: textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('Rs. 3,500', style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          for (var i = 0; i < _expenses.length; i++) ...[
            _expenseRow(_expenses[i]),
            if (i != _expenses.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _expenseRow(_ExpenseSlice slice) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
          child: Text('${(slice.share * 100).round()}%', style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(slice.label, style: const TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600))),
        Text('Rs. ${slice.value.toStringAsFixed(0)}', style: const TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _recentActivityCard() {
    return _sectionCard(
      title: 'Recent Activity',
      trailing: const Icon(Icons.more_horiz_rounded, color: AppColors.accentGrey),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (var i = 0; i < _activities.length; i++) ...[
            _activityRow(_activities[i]),
            if (i != _activities.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _activityRow(_Activity activity) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: const Icon(Icons.person, size: 18, color: AppColors.secondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activity.title, style: const TextStyle(color: textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(activity.time, style: const TextStyle(color: textSecondary, fontSize: 11.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recentTransactionsCard(List<_Transaction> transactions) {
    return _sectionCard(
      title: 'Recent Transactions',
      trailing: Wrap(
        spacing: 8,
        children: [
          _dropdownPill(_selectedRange.label),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.secondary.withValues(alpha: 0.10))),
            child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.secondary),
          ),
        ],
      ),
      child: Column(
        children: [
          _tableHeader(),
          const SizedBox(height: 8),
          for (var i = 0; i < transactions.length; i++) ...[
            _transactionRow(transactions[i]),
            if (i != transactions.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF2F8EE), borderRadius: BorderRadius.circular(14)),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Transaction Name', style: _HeaderTextStyle.style)),
          Expanded(flex: 2, child: Text('Date & Time', style: _HeaderTextStyle.style)),
          Expanded(flex: 1, child: Text('Amount', style: _HeaderTextStyle.style)),
          Expanded(flex: 1, child: Text('Status', style: _HeaderTextStyle.style)),
        ],
      ),
    );
  }

  Widget _transactionRow(_Transaction transaction) {
    final statusColor = transaction.status == 'Success' ? AppColors.secondary : AppColors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.secondary.withValues(alpha: 0.08))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(transaction.icon, size: 18, color: AppColors.secondary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(transaction.title, style: const TextStyle(color: textPrimary, fontSize: 12.5, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text(transaction.date, style: const TextStyle(color: textSecondary, fontSize: 12))),
          Expanded(flex: 1, child: Text(transaction.amount, style: const TextStyle(color: textPrimary, fontSize: 12.5, fontWeight: FontWeight.w700))),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                child: Text(transaction.status, style: TextStyle(color: statusColor, fontSize: 11.5, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child, Widget? trailing}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: AppColors.secondary.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w800))),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _dropdownPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8EE),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.secondary),
        ],
      ),
    );
  }

  Widget _buildRangeFilters() {
    final customLabel = _selectedRange == DashboardRange.custom && _customRange != null
        ? '${_formatDate(_customRange!.start)} - ${_formatDate(_customRange!.end)}'
        : null;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: DashboardRange.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final range = DashboardRange.values[index];
          final selected = _selectedRange == range;
          final label = range == DashboardRange.custom && customLabel != null ? customLabel : range.label;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => _onRangeSelected(range),
            selectedColor: AppColors.secondary.withValues(alpha: 0.12),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: selected ? AppColors.secondary : textSecondary, fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(color: selected ? AppColors.secondary : AppColors.secondary.withValues(alpha: 0.10)),
            ),
          );
        },
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: textSecondary, fontSize: 12)),
      ],
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _SidebarTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _SidebarTile({required this.label, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.secondary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: active ? AppColors.secondary : AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: active ? AppColors.secondary : AppColors.textSecondary,
                    fontSize: 13.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipAction extends StatelessWidget {
  final String label;

  const _ChipAction({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class _HeaderTextStyle {
  static const TextStyle style = TextStyle(color: AppColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w700);
}

class _HeroStat {
  final String label;
  final String value;
  final String delta;
  final IconData icon;

  const _HeroStat(this.label, this.value, this.delta, this.icon);
}

class _PlanItem {
  final String title;
  final String currentValue;
  final String targetValue;
  final double progress;

  const _PlanItem(this.title, this.currentValue, this.targetValue, this.progress);

  String get percentLabel => '${(progress * 100).round()}%';
}

class _TrendPoint {
  final String label;
  final double income;
  final double expense;

  const _TrendPoint(this.label, this.income, this.expense);
}

class _ExpenseSlice {
  final String label;
  final double value;
  final double share;

  const _ExpenseSlice(this.label, this.value, this.share);
}

class _Transaction {
  final String title;
  final String date;
  final String amount;
  final String status;
  final IconData icon;

  const _Transaction(this.title, this.date, this.amount, this.status, this.icon);
}

class _Activity {
  final String title;
  final String time;

  const _Activity(this.title, this.time);
}

class _SidebarItem {
  final String label;
  final IconData icon;

  const _SidebarItem(this.label, this.icon);
}

class _DonutPainter extends CustomPainter {
  final List<_ExpenseSlice> slices;

  _DonutPainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;
    final total = slices.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const strokeWidth = 22.0;
    var startAngle = -math.pi / 2;

    for (final slice in slices) {
      final sweep = (slice.value / total) * math.pi * 2;
      final paint = Paint()
        ..color = AppColors.secondary.withValues(alpha: 0.25 + (slice.share * 0.65))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }

    final holePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - strokeWidth / 2, holePaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => oldDelegate.slices != slices;
}