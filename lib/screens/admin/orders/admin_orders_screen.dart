import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../sales_manager/attendance/sales_manager_attendance_screen.dart';
import '../../sales_manager/dashboard/sales_manager_dashboard_screen.dart';
import '../../sales_manager/follow_ups/sales_manager_follow_ups_screen.dart';
import '../../sales_manager/performance/sales_manager_performance_screen.dart';
import '../../sales_manager/stock/sales_manager_stock_screen.dart';
import '../../sales_manager/visits/sales_manager_visits_screen.dart';
import '../customers/customers_screen.dart';
import '../leads/admin_leads_screen.dart';
import 'new_admin_order_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  final bool useSalesManagerShell;

  const AdminOrdersScreen({super.key, this.useSalesManagerShell = false});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _selectedPayment = 'All payments';
  DateTime? _fromDate;
  DateTime? _toDate;

  final List<String> _tabs = const [
    'All',
    'Draft',
    'Confirmed',
    'Processing',
    'Out for Delivery',
    'Delivered',
    'Partially Delivered',
    'Cancelled',
    'Returned',
  ];

  static const List<String> _paymentOptions = ['Paid', 'Partial', 'Unpaid'];

  int _selectedTab = 0;

  final List<_OrderMetric> _metrics = const [
    _OrderMetric(
      'Total Orders',
      '21',
      Icons.shopping_cart_outlined,
      Color(0xFF0B4A06),
    ),
    _OrderMetric(
      'Pending Orders',
      '7',
      Icons.schedule_rounded,
      Color(0xFFF59E0B),
    ),
    _OrderMetric(
      'Total Value',
      '₹70,276',
      Icons.currency_rupee_rounded,
      Color(0xFF22C55E),
    ),
    _OrderMetric(
      'Outstanding',
      '₹43,681',
      Icons.account_balance_wallet_outlined,
      Color(0xFFEF4444),
    ),
  ];

  final List<_OrderRecord> _orders = const [
    _OrderRecord(
      number: 'SO-2026-1001',
      customer: 'Hotel Grand Meridian',
      date: '01 Jul 2026',
      items: '2',
      total: '₹4,600',
      payment: 'Paid',
      paymentColor: Color(0xFF16A34A),
      paymentBackground: Color(0xFFE8F8EE),
      status: 'Delivered',
      statusColor: Color(0xFF16A34A),
      statusBackground: Color(0xFFE8F8EE),
      deliveryPartner: 'Suresh Kumar',
    ),
    _OrderRecord(
      number: 'SO-2026-1002',
      customer: 'Spice Route Restaurant',
      date: '02 Jul 2026',
      items: '2',
      total: '₹2,406',
      payment: 'Partial',
      paymentColor: Color(0xFFF59E0B),
      paymentBackground: Color(0xFFFFF7E6),
      status: 'Delivered',
      statusColor: Color(0xFF16A34A),
      statusBackground: Color(0xFFE8F8EE),
      deliveryPartner: 'Suresh Kumar',
    ),
    _OrderRecord(
      number: 'SO-2026-1003',
      customer: 'Sunrise Corporate Park',
      date: '03 Jul 2026',
      items: '2',
      total: '₹11,564',
      payment: 'Paid',
      paymentColor: Color(0xFF16A34A),
      paymentBackground: Color(0xFFE8F8EE),
      status: 'Delivered',
      statusColor: Color(0xFF16A34A),
      statusBackground: Color(0xFFE8F8EE),
      deliveryPartner: 'Suresh Kumar',
    ),
    _OrderRecord(
      number: 'SO-2026-1004',
      customer: 'Mr. Arjun Reddy',
      date: '04 Jul 2026',
      items: '2',
      total: '₹413',
      payment: 'Paid',
      paymentColor: Color(0xFF16A34A),
      paymentBackground: Color(0xFFE8F8EE),
      status: 'Delivered',
      statusColor: Color(0xFF16A34A),
      statusBackground: Color(0xFFE8F8EE),
      deliveryPartner: 'Suresh Kumar',
    ),
    _OrderRecord(
      number: 'SO-2026-1005',
      customer: 'Green Leaf Caterers',
      date: '05 Jul 2026',
      items: '2',
      total: '₹4,882',
      payment: 'Unpaid',
      paymentColor: Color(0xFFEF4444),
      paymentBackground: Color(0xFFFEE2E2),
      status: 'Delivered',
      statusColor: Color(0xFF16A34A),
      statusBackground: Color(0xFFE8F8EE),
      deliveryPartner: 'Suresh Kumar',
    ),
    _OrderRecord(
      number: 'SO-2026-1006',
      customer: 'The Coastal Kitchen',
      date: '06 Jul 2026',
      items: '2',
      total: '₹2,618',
      payment: 'Partial',
      paymentColor: Color(0xFFF59E0B),
      paymentBackground: Color(0xFFFFF7E6),
      status: 'Delivered',
      statusColor: Color(0xFF16A34A),
      statusBackground: Color(0xFFE8F8EE),
      deliveryPartner: 'Suresh Kumar',
    ),
    _OrderRecord(
      number: 'SO-2026-1007',
      customer: 'Om Sai General Store',
      date: '07 Jul 2026',
      items: '2',
      total: '₹3,658',
      payment: 'Paid',
      paymentColor: Color(0xFF16A34A),
      paymentBackground: Color(0xFFE8F8EE),
      status: 'Delivered',
      statusColor: Color(0xFF16A34A),
      statusBackground: Color(0xFFE8F8EE),
      deliveryPartner: 'Suresh Kumar',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
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
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initialDate = isFrom
        ? (_fromDate ?? DateTime.now())
        : (_toDate ?? _fromDate ?? DateTime.now());

    final picked = await showDialog<DateTime>(
      context: context,
      barrierColor: Colors.black26,
      builder: (dialogContext) {
        DateTime selectedDate = initialDate;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: StatefulBuilder(
            builder: (context, setLocalState) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: const Color(0xFF111827),
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CalendarDatePicker(
                          initialDate: initialDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          currentDate: DateTime.now(),
                          onDateChanged: (date) {
                            setLocalState(() => selectedDate = date);
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              setLocalState(
                                () => selectedDate = DateTime.now(),
                              );
                            },
                            child: const Text(
                              'Today',
                              style: TextStyle(
                                color: Color(0xFF0B4A06),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(selectedDate),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0B4A06),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text('Select'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
      } else {
        _toDate = picked;
      }
    });
  }

  Future<void> _openNewOrder() async {
    Navigator.of(
      context,
    ).push(
      MaterialPageRoute(
        builder: (_) => NewAdminOrderScreen(
          useSalesManagerShell: widget.useSalesManagerShell,
        ),
      ),
    );
  }

  void _handleSalesManagerSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'Sales Orders') return;
    if (action == 'Create Order') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const NewAdminOrderScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
      );
      return;
    }
    if (action == 'Customers') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CustomersScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Leads') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminLeadsScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Stock') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerStockScreen()),
      );
      return;
    }
    if (action == 'Follow-ups' || action == 'Follow-Ups') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerFollowUpsScreen()),
      );
      return;
    }
    if (action == 'Attendance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerAttendanceScreen()),
      );
      return;
    }
    if (action == 'Visits') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
      );
      return;
    }
    if (action == 'My Performance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerPerformanceScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final orders = _filteredOrders().where((order) {
      if (_selectedPayment != 'All payments' &&
          order.payment != _selectedPayment) {
        return false;
      }
      if (query.isEmpty) return true;
      return order.number.toLowerCase().contains(query) ||
          order.customer.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: widget.useSalesManagerShell
          ? SalesManagerSidebarDrawer(
              currentPage: 'Sales Orders',
              onSelect: _handleSalesManagerSidebarSelection,
            )
          : const AppDrawer(activeItem: 'Orders'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 900;

            return Column(
              children: [
                _buildTopBar(isMobile),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 14 : 18,
                      10,
                      isMobile ? 14 : 18,
                      18,
                    ),
                    child: isMobile
                        ? _buildMobileContent(orders)
                        : _buildDesktopContent(orders),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<_OrderRecord> _filteredOrders() {
    switch (_selectedTab) {
      case 1:
        return _orders.where((order) => order.payment == 'Draft').toList();
      case 2:
        return _orders.where((order) => order.payment == 'Paid').toList();
      case 3:
        return _orders.where((order) => order.status == 'Processing').toList();
      case 4:
        return _orders
            .where((order) => order.status == 'Out for Delivery')
            .toList();
      case 5:
        return _orders.where((order) => order.status == 'Delivered').toList();
      case 6:
        return _orders.where((order) => order.payment == 'Partial').toList();
      case 7:
        return _orders.where((order) => order.status == 'Cancelled').toList();
      case 8:
        return _orders.where((order) => order.status == 'Returned').toList();
      default:
        return _orders;
    }
  }

  Widget _buildTopBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 14 : 18,
        14,
        isMobile ? 14 : 18,
        10,
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            IconButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(
                Icons.menu_rounded,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
          ],
          const Text(
            'Orders',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (!isMobile) ...[
            _topRightActionButton(),
            const SizedBox(width: 12),
          ],
          _roundIconButton(Icons.help_outline_rounded, () {}),
          const SizedBox(width: 10),
          _roundIconButton(Icons.notifications_none_rounded, () {}),
          const SizedBox(width: 10),
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B4A06),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sushil',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Admin',
                    style: TextStyle(
                      color: Color(0xFF0B4A06),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topRightActionButton() {
    return SizedBox(
      width: 128,
      height: 34,
      child: ElevatedButton.icon(
        onPressed: _openNewOrder,
        icon: const Icon(Icons.add_rounded, size: 16),
        label: const Text('New Order'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B4A06),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF0B4A06).withValues(alpha: 0.22),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _roundIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildDesktopContent(List<_OrderRecord> orders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 148,
              height: 34,
              child: ElevatedButton.icon(
                onPressed: _openNewOrder,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('New Order'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B4A06),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: const Color(0xFF0B4A06).withValues(alpha: 0.28),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _metricsGrid(),
        const SizedBox(height: 14),
        _contentCard(orders, desktop: true),
      ],
    );
  }

  Widget _buildMobileContent(List<_OrderRecord> orders) {
    final shownOrders = orders.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 140,
            height: 34,
            child: ElevatedButton.icon(
              onPressed: _openNewOrder,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('New Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B4A06),
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: const Color(0xFF0B4A06).withValues(alpha: 0.28),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _metricsGrid(mobile: true),
        const SizedBox(height: 12),
        _contentCard(shownOrders, desktop: false),
      ],
    );
  }

  Widget _metricsGrid({bool mobile = false}) {
    final crossAxisCount = mobile ? 2 : 4;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: mobile ? 108 : 128,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final metric = _metrics[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      metric.label,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: mobile ? 12 : 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: metric.color,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: metric.color.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(metric.icon, color: Colors.white, size: 20),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                metric.value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: mobile ? 21 : 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _contentCard(List<_OrderRecord> orders, {required bool desktop}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        desktop ? 18 : 14,
        desktop ? 18 : 14,
        desktop ? 18 : 14,
        desktop ? 18 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tabBar(desktop: desktop),
          const SizedBox(height: 14),
          _filterBar(desktop: desktop),
          const SizedBox(height: 14),
          if (desktop) _desktopTableHeader() else _mobileOrdersList(orders),
          if (desktop) ...[
            const SizedBox(height: 8),
            ...orders.asMap().entries.map(
              (entry) => Column(
                children: [
                  _DesktopOrderRow(record: entry.value),
                  if (entry.key != orders.length - 1)
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tabBar({required bool desktop}) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final selected = index == _selectedTab;
          return InkWell(
            onTap: () => setState(() => _selectedTab = index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF0B4A06)
                          : AppColors.textSecondary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 18 : 0,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B4A06),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _filterBar({required bool desktop}) {
    if (desktop) {
      return Row(
        children: [
          Expanded(child: _searchField()),
          const SizedBox(width: 12),
          Expanded(child: _paymentDropdown()),
          const SizedBox(width: 12),
          Expanded(child: _dropdownFilter('All sales officers')),
          const SizedBox(width: 12),
          Expanded(
            child: _dateField(
              'From date',
              selectedDate: _fromDate,
              onCalendarTap: () => _pickDate(isFrom: true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _dateField(
              'To date',
              selectedDate: _toDate,
              onCalendarTap: () => _pickDate(isFrom: false),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        _searchField(),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _paymentDropdown()),
            const SizedBox(width: 10),
            Expanded(child: _dropdownFilter('All sales officers')),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _dateField(
                'From date',
                selectedDate: _fromDate,
                onCalendarTap: () => _pickDate(isFrom: true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _dateField(
                'To date',
                selectedDate: _toDate,
                onCalendarTap: () => _pickDate(isFrom: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _searchField() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
        cursorColor: const Color(0xFF0B4A06),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          hintText: 'Search order # or customer',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0B4A06), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _dropdownFilter(String hint) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hint,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }

  Widget _paymentDropdown() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _selectedPayment = value),
      offset: const Offset(0, 48),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'All payments',
          child: Text(
            'All payments',
            style: TextStyle(
              color: _selectedPayment == 'All payments'
                  ? const Color(0xFF0B4A06)
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ..._paymentOptions.map(
          (payment) => PopupMenuItem<String>(
            value: payment,
            child: Text(
              payment,
              style: TextStyle(
                color: _selectedPayment == payment
                    ? const Color(0xFF0B4A06)
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedPayment,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(
    String hint, {
    required DateTime? selectedDate,
    required VoidCallback onCalendarTap,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              selectedDate == null ? hint : _formatDate(selectedDate),
              style: TextStyle(
                color: selectedDate == null
                    ? AppColors.textLightMuted
                    : AppColors.textPrimary,
                fontSize: 13.5,
              ),
            ),
          ),
          IconButton(
            onPressed: onCalendarTap,
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }

  Widget _desktopTableHeader() {
    Text header(String label) => Text(
      label,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
      child: Row(
        children: [
          Expanded(flex: 17, child: header('ORDER #')),
          Expanded(flex: 22, child: header('CUSTOMER')),
          Expanded(flex: 12, child: header('DATE')),
          Expanded(flex: 8, child: header('ITEMS')),
          Expanded(flex: 11, child: header('TOTAL')),
          Expanded(flex: 11, child: header('PAYMENT')),
          Expanded(flex: 12, child: header('STATUS')),
          Expanded(flex: 18, child: header('DELIVERY PARTNER')),
          const SizedBox(width: 28, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _mobileOrdersList(List<_OrderRecord> orders) {
    if (orders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No orders found.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < orders.length; i++) ...[
          _OrderMobileCard(record: orders[i]),
          if (i != orders.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _DesktopOrderRow extends StatelessWidget {
  final _OrderRecord record;

  const _DesktopOrderRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 17,
            child: Text(
              record.number,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 22,
            child: Text(
              record.customer,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
              ),
            ),
          ),
          Expanded(
            flex: 12,
            child: Text(
              record.date,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: Text(
              record.items,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
              ),
            ),
          ),
          Expanded(
            flex: 11,
            child: Text(
              record.total,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 11,
            child: _StatusChip(
              label: record.payment,
              foreground: record.paymentColor,
              background: record.paymentBackground,
            ),
          ),
          Expanded(
            flex: 12,
            child: _StatusChip(
              label: record.status,
              foreground: record.statusColor,
              background: record.statusBackground,
            ),
          ),
          Expanded(
            flex: 18,
            child: Text(
              record.deliveryPartner,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
              ),
            ),
          ),
          const SizedBox(
            width: 28,
            child: Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderMobileCard extends StatelessWidget {
  final _OrderRecord record;

  const _OrderMobileCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  record.number,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusChip(
                label: record.status,
                foreground: record.statusColor,
                background: record.statusBackground,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            record.customer,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _kv('Date', record.date)),
              Expanded(child: _kv('Items', record.items)),
              Expanded(child: _kv('Total', record.total)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatusChip(
                label: record.payment,
                foreground: record.paymentColor,
                background: record.paymentBackground,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  record.deliveryPartner,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;

  const _StatusChip({
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OrderMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _OrderMetric(this.label, this.value, this.icon, this.color);
}

class _OrderRecord {
  final String number;
  final String customer;
  final String date;
  final String items;
  final String total;
  final String payment;
  final Color paymentColor;
  final Color paymentBackground;
  final String status;
  final Color statusColor;
  final Color statusBackground;
  final String deliveryPartner;

  const _OrderRecord({
    required this.number,
    required this.customer,
    required this.date,
    required this.items,
    required this.total,
    required this.payment,
    required this.paymentColor,
    required this.paymentBackground,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
    required this.deliveryPartner,
  });
}
