import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../../sales_manager/attendance/sales_manager_attendance_screen.dart';
import '../../sales_manager/dashboard/sales_manager_dashboard_screen.dart';
import '../../sales_manager/follow_ups/sales_manager_follow_ups_screen.dart';
import '../../sales_manager/performance/sales_manager_performance_screen.dart';
import '../../sales_manager/stock/sales_manager_stock_screen.dart';
import '../../sales_manager/visits/sales_manager_visits_screen.dart';
import '../customers/customers_screen.dart';
import '../leads/admin_leads_screen.dart';
import '../quotations/admin_quotations_screen.dart';
import '../quotations/quotation_detail_screen.dart';
import 'new_admin_order_screen.dart';
import 'order_detail_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  final bool useSalesManagerShell;

  const AdminOrdersScreen({super.key, this.useSalesManagerShell = false});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  late ApiProvider _apiProvider;
  bool _providerReady = false;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedPayment = 'All payments';
  String _selectedDeliveryPartner = 'All delivery partners';
  String _selectedSource = 'All sources';
  DateTime? _fromDate;
  DateTime? _toDate;
  int _currentPage = 1;
  int _pageSize = 10;
  int _totalItems = 0;
  int _totalPages = 1;
  bool _hasNextPage = false;

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
  static const List<String> _sourceOptions = [
    'Office',
    'Quotation',
    'Delivery Vehicle',
  ];

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
  List<_OrderRecord> _apiOrders = [];

  List<_OrderRecord> get _displayOrders =>
      _apiOrders.isEmpty && !_isLoading && _errorMessage != null
      ? _orders
      : _apiOrders;

  List<_OrderMetric> get _displayMetrics {
    if (_isLoading && _apiOrders.isEmpty) return _metrics;

    final orders = _displayOrders;
    final totalValue = orders.fold<double>(
      0,
      (sum, order) => sum + order.totalAmount,
    );
    final outstanding = orders
        .where((order) => order.payment != 'Paid')
        .fold<double>(0, (sum, order) => sum + order.totalAmount);

    return [
      _OrderMetric(
        'Total Orders',
        orders.length.toString(),
        Icons.shopping_cart_outlined,
        const Color(0xFF0B4A06),
      ),
      _OrderMetric(
        'Pending Orders',
        orders
            .where((order) => !_isClosedStatus(order.status))
            .length
            .toString(),
        Icons.schedule_rounded,
        const Color(0xFFF59E0B),
      ),
      _OrderMetric(
        'Total Value',
        _formatMoney(totalValue),
        Icons.currency_rupee_rounded,
        const Color(0xFF22C55E),
      ),
      _OrderMetric(
        'Outstanding',
        _formatMoney(outstanding),
        Icons.account_balance_wallet_outlined,
        const Color(0xFFEF4444),
      ),
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _apiProvider.fetchPaginatedOrders(
        page: _currentPage,
        limit: _pageSize,
        status: _selectedTabStatus,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _apiOrders = result.orders.map(_OrderRecord.fromJson).toList();
        _currentPage = result.currentPage <= 0
            ? _currentPage
            : result.currentPage;
        _pageSize = result.pageSize <= 0 ? _pageSize : result.pageSize;
        _totalItems = result.totalItems;
        _totalPages = result.totalPages <= 0 ? 1 : result.totalPages;
        _hasNextPage = result.hasNextPage;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  String? get _selectedTabStatus {
    if (_selectedTab <= 0 || _selectedTab >= _tabs.length) return null;
    return _tabs[_selectedTab].toLowerCase().replaceAll(' ', '_');
  }

  Future<void> _goToPage(int page) async {
    if (_isLoading || page < 1) return;
    setState(() => _currentPage = page);
    await _loadOrders();
  }

  Future<void> _changePageSize(int size) async {
    if (_isLoading || size == _pageSize) return;
    setState(() {
      _pageSize = size;
      _currentPage = 1;
    });
    await _loadOrders();
  }

  Future<void> _reloadFirstPage() async {
    setState(() => _currentPage = 1);
    await _loadOrders();
  }

  static bool _isClosedStatus(String status) {
    final normalized = _normalizeStatus(status);
    return normalized == 'delivered' ||
        normalized == 'completed' ||
        normalized == 'cancelled' ||
        normalized == 'returned';
  }

  static String _formatMoney(double value) {
    final rounded = value.round();
    final raw = rounded.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final fromRight = raw.length - i;
      buffer.write(raw[i]);
      if (fromRight > 1 && fromRight % 3 == 1) buffer.write(',');
    }
    return 'Rs. $buffer';
  }

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

  static DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static String _normalizeStatus(String value) {
    return value.trim().toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ');
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewAdminOrderScreen(
          useSalesManagerShell: widget.useSalesManagerShell,
        ),
      ),
    );
  }

  Future<void> _openOrderDetails(_OrderRecord record) async {
    if (record.id.isEmpty) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailScreen(
          orderId: record.id,
          useSalesManagerShell: widget.useSalesManagerShell,
        ),
      ),
    );
    if (mounted) _loadOrders();
  }

  Future<void> _handleOrderAction(_OrderAction action) async {
    final record = action.record;
    switch (action.type) {
      case _OrderActionType.view:
        await _openOrderDetails(record);
        return;
      case _OrderActionType.edit:
      case _OrderActionType.duplicate:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => NewAdminOrderScreen(
              useSalesManagerShell: widget.useSalesManagerShell,
            ),
          ),
        );
        return;
      case _OrderActionType.sourceQuotation:
        if (record.quotationId.isEmpty) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => QuotationDetailScreen(
              quotationId: record.quotationId,
              useSalesManagerShell: widget.useSalesManagerShell,
            ),
          ),
        );
        return;
    }
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
    if (action == 'Quotations' || action == 'Quotation') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              const AdminQuotationsScreen(useSalesManagerShell: true),
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
        MaterialPageRoute(
          builder: (_) => const SalesManagerPerformanceScreen(),
        ),
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
      if (_selectedDeliveryPartner != 'All delivery partners' &&
          order.deliveryPartner != _selectedDeliveryPartner) {
        return false;
      }
      if (_selectedSource != 'All sources' &&
          order.sourceLabel != _selectedSource) {
        return false;
      }
      if (query.isEmpty) return true;
      return order.number.toLowerCase().contains(query) ||
          order.customer.toLowerCase().contains(query) ||
          order.sourceLabel.toLowerCase().contains(query) ||
          order.deliveryPartner.toLowerCase().contains(query);
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
                widget.useSalesManagerShell
                    ? const SalesManagerTopBar(title: 'Sales Orders')
                    : _buildTopBar(isMobile),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _reloadFirstPage,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        isMobile ? 10 : 14,
                        8,
                        isMobile ? 10 : 14,
                        14,
                      ),
                      child: isMobile
                          ? _buildMobileContent(orders)
                          : _buildDesktopContent(orders),
                    ),
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
    final source = _displayOrders.where((order) {
      if (_fromDate != null &&
          order.dateValue != null &&
          order.dateValue!.isBefore(_startOfDay(_fromDate!))) {
        return false;
      }
      if (_toDate != null &&
          order.dateValue != null &&
          order.dateValue!.isAfter(_endOfDay(_toDate!))) {
        return false;
      }
      return true;
    });

    switch (_selectedTab) {
      case 1:
        return source
            .where((order) => _normalizeStatus(order.status) == 'draft')
            .toList();
      case 2:
        return source
            .where((order) => _normalizeStatus(order.status) == 'confirmed')
            .toList();
      case 3:
        return source
            .where((order) => _normalizeStatus(order.status) == 'processing')
            .toList();
      case 4:
        return source
            .where(
              (order) => _normalizeStatus(order.status) == 'out for delivery',
            )
            .toList();
      case 5:
        return source
            .where((order) => _normalizeStatus(order.status) == 'delivered')
            .toList();
      case 6:
        return source
            .where(
              (order) =>
                  _normalizeStatus(order.status) == 'partially delivered',
            )
            .toList();
      case 7:
        return source
            .where((order) => _normalizeStatus(order.status) == 'cancelled')
            .toList();
      case 8:
        return source
            .where((order) => _normalizeStatus(order.status) == 'returned')
            .toList();
      default:
        return source.toList();
    }
  }

  Widget _buildTopBar(bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 10 : 14,
        10,
        isMobile ? 10 : 14,
        8,
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
            const SizedBox(width: 2),
          ],
          const Text(
            'Orders',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          if (!isMobile) ...[_topRightActionButton(), const SizedBox(width: 8)],
          _roundIconButton(Icons.help_outline_rounded, () {}),
          const SizedBox(width: 8),
          _roundIconButton(Icons.notifications_none_rounded, () {}),
          const SizedBox(width: 8),
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B4A06),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sushil',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Admin',
                    style: TextStyle(
                      color: Color(0xFF0B4A06),
                      fontSize: 10.5,
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
      width: 118,
      height: 30,
      child: ElevatedButton.icon(
        onPressed: _openNewOrder,
        icon: const Icon(Icons.add_rounded, size: 15),
        label: const Text('New Order'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B4A06),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: const Color(0xFF0B4A06).withValues(alpha: 0.22),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _roundIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 17, color: const Color(0xFF6B7280)),
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
              width: 126,
              height: 30,
              child: ElevatedButton.icon(
                onPressed: _openNewOrder,
                icon: const Icon(Icons.add_rounded, size: 15),
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
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _metricsGrid(),
        const SizedBox(height: 10),
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
            width: 126,
            height: 30,
            child: ElevatedButton.icon(
              onPressed: _openNewOrder,
              icon: const Icon(Icons.add_rounded, size: 15),
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
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _metricsGrid(mobile: true),
        const SizedBox(height: 10),
        _contentCard(shownOrders, desktop: false),
      ],
    );
  }

  Widget _metricsGrid({bool mobile = false}) {
    final crossAxisCount = mobile ? 2 : 4;
    final metrics = _displayMetrics;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: mobile ? 74 : 86,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                        fontSize: mobile ? 10.5 : 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: metric.color,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: metric.color.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(metric.icon, color: Colors.white, size: 16),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                metric.value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: mobile ? 15 : 17,
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
        desktop ? 12 : 10,
        desktop ? 12 : 10,
        desktop ? 12 : 10,
        desktop ? 12 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tabBar(desktop: desktop),
          const SizedBox(height: 10),
          _filterBar(desktop: desktop),
          const SizedBox(height: 10),
          if (_isLoading)
            const _OrdersStatePanel(
              icon: Icons.hourglass_empty_rounded,
              title: 'Loading orders...',
            )
          else if (_errorMessage != null)
            _OrdersStatePanel(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load orders',
              subtitle: _errorMessage!,
              actionLabel: 'Retry',
              onAction: _loadOrders,
            )
          else if (orders.isEmpty)
            const _OrdersStatePanel(
              icon: Icons.receipt_long_outlined,
              title: 'No orders found',
              subtitle: 'Orders matching your filters will appear here.',
            )
          else if (desktop)
            _desktopTableHeader()
          else
            _mobileOrdersList(orders),
          if (desktop && !_isLoading && _errorMessage == null) ...[
            const SizedBox(height: 4),
            ...orders.asMap().entries.map(
              (entry) => Column(
                children: [
                  _DesktopOrderRow(
                    record: entry.value,
                    onOpen: _openOrderDetails,
                    onAction: _handleOrderAction,
                  ),
                  if (entry.key != orders.length - 1)
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                ],
              ),
            ),
          ],
          if (!_isLoading && _errorMessage == null && orders.isNotEmpty) ...[
            const SizedBox(height: 10),
            _paginationBar(),
          ],
        ],
      ),
    );
  }

  Widget _paginationBar() {
    final start = _totalItems == 0 ? 0 : ((_currentPage - 1) * _pageSize) + 1;
    final end = (_currentPage * _pageSize).clamp(0, _totalItems);
    final totalPages = _hasNextPage && _totalPages <= _currentPage
        ? _currentPage + 1
        : (_totalPages < 1 ? 1 : _totalPages);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          Text(
            'Showing $start-$end of $_totalItems',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          _pageSizeDropdown(),
          const SizedBox(width: 4),
          _pagerButton(
            icon: Icons.chevron_left_rounded,
            enabled: _currentPage > 1,
            onTap: () => _goToPage(_currentPage - 1),
          ),
          Text(
            'Page $_currentPage / $totalPages',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          _pagerButton(
            icon: Icons.chevron_right_rounded,
            enabled: _hasNextPage,
            onTap: () => _goToPage(_currentPage + 1),
          ),
        ],
      ),
    );
  }

  Widget _pageSizeDropdown() {
    return PopupMenuButton<int>(
      tooltip: 'Rows per page',
      onSelected: _changePageSize,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 10, child: Text('10 / page')),
        PopupMenuItem(value: 25, child: Text('25 / page')),
        PopupMenuItem(value: 50, child: Text('50 / page')),
      ],
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_pageSize / page',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pagerButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.textPrimary : AppColors.textLightMuted,
        ),
      ),
    );
  }

  Widget _tabBar({required bool desktop}) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final selected = index == _selectedTab;
          return InkWell(
            onTap: () async {
              setState(() {
                _selectedTab = index;
                _currentPage = 1;
              });
              await _loadOrders();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF0B4A06)
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 16 : 0,
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
          Expanded(child: _deliveryPartnerDropdown()),
          const SizedBox(width: 12),
          Expanded(child: _sourceDropdown()),
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
            Expanded(child: _deliveryPartnerDropdown()),
          ],
        ),
        const SizedBox(height: 10),
        _sourceDropdown(),
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
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) {
          setState(() => _currentPage = 1);
          _loadOrders();
        },
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        cursorColor: const Color(0xFF0B4A06),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
            size: 18,
          ),
          hintText: 'Search order # or customer',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0B4A06), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
        ),
      ),
    );
  }

  Widget _dropdownFilter(String hint) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hint,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
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

  Widget _deliveryPartnerDropdown() {
    final partnerOptions =
        _displayOrders
            .map((order) => order.deliveryPartner)
            .where((partner) => partner.trim().isNotEmpty && partner != '-')
            .toSet()
            .toList()
          ..sort();

    return _selectDropdown(
      value: _selectedDeliveryPartner,
      options: ['All delivery partners', ...partnerOptions],
      onSelected: (value) => setState(() => _selectedDeliveryPartner = value),
    );
  }

  Widget _sourceDropdown() {
    return _selectDropdown(
      value: _selectedSource,
      options: const ['All sources', ..._sourceOptions],
      onSelected: (value) => setState(() => _selectedSource = value),
    );
  }

  Widget _selectDropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 42),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      itemBuilder: (context) => options
          .map(
            (option) => PopupMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: TextStyle(
                  color: value == option
                      ? const Color(0xFF0B4A06)
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
      child: _dropdownFilter(value),
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
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD1D5DB)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedPayment,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
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
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                fontSize: 12,
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
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          Expanded(flex: 17, child: header('ORDER #')),
          Expanded(flex: 22, child: header('CUSTOMER')),
          Expanded(flex: 12, child: header('DATE')),
          Expanded(flex: 8, child: header('ITEMS')),
          Expanded(flex: 11, child: header('TOTAL')),
          Expanded(flex: 11, child: header('PAYMENT')),
          Expanded(flex: 12, child: header('STATUS')),
          Expanded(flex: 12, child: header('SOURCE')),
          Expanded(flex: 16, child: header('DELIVERY PARTNER')),
          const SizedBox(width: 28, child: SizedBox()),
        ],
      ),
    );
  }

  Widget _mobileOrdersList(List<_OrderRecord> orders) {
    if (orders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
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
          _OrderMobileCard(
            record: orders[i],
            onOpen: _openOrderDetails,
            onAction: _handleOrderAction,
          ),
          if (i != orders.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _DesktopOrderRow extends StatelessWidget {
  final _OrderRecord record;
  final ValueChanged<_OrderRecord> onOpen;
  final ValueChanged<_OrderAction> onAction;

  const _DesktopOrderRow({
    required this.record,
    required this.onOpen,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onOpen(record),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 17,
              child: Text(
                record.number,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
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
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              flex: 12,
              child: Text(
                record.date,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Text(
                record.items,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              flex: 11,
              child: Text(
                record.total,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
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
              flex: 12,
              child: Text(
                record.sourceLabel,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              flex: 16,
              child: Text(
                record.deliveryPartner,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(
              width: 28,
              child: _OrderActionsMenu(record: record, onSelected: onAction),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderMobileCard extends StatelessWidget {
  final _OrderRecord record;
  final ValueChanged<_OrderRecord> onOpen;
  final ValueChanged<_OrderAction> onAction;

  const _OrderMobileCard({
    required this.record,
    required this.onOpen,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onOpen(record),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
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
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusChip(
                  label: record.status,
                  foreground: record.statusColor,
                  background: record.statusBackground,
                ),
                _OrderActionsMenu(record: record, onSelected: onAction),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              record.customer,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _kv('Date', record.date)),
                Expanded(child: _kv('Items', record.items)),
                Expanded(child: _kv('Total', record.total)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatusChip(
                  label: record.payment,
                  foreground: record.paymentColor,
                  background: record.paymentBackground,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${record.sourceLabel}  |  ${record.deliveryPartner}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 11.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _OrdersStatePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _OrdersStatePanel({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 26),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

enum _OrderActionType { view, edit, duplicate, sourceQuotation }

class _OrderAction {
  final _OrderActionType type;
  final _OrderRecord record;

  const _OrderAction(this.type, this.record);
}

class _OrderActionsMenu extends StatelessWidget {
  final _OrderRecord record;
  final ValueChanged<_OrderAction> onSelected;

  const _OrderActionsMenu({required this.record, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_OrderActionType>(
      tooltip: 'Order actions',
      color: Colors.white,
      padding: EdgeInsets.zero,
      icon: const Icon(
        Icons.more_vert_rounded,
        color: Color(0xFF94A3B8),
        size: 18,
      ),
      onSelected: (type) => onSelected(_OrderAction(type, record)),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _OrderActionType.view,
          child: Text('View Details'),
        ),
        const PopupMenuItem(value: _OrderActionType.edit, child: Text('Edit')),
        const PopupMenuItem(
          value: _OrderActionType.duplicate,
          child: Text('Duplicate'),
        ),
        if (record.quotationId.isNotEmpty)
          const PopupMenuItem(
            value: _OrderActionType.sourceQuotation,
            child: Text('View Source Quotation'),
          ),
      ],
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
  final String id;
  final String number;
  final String customer;
  final String date;
  final DateTime? dateValue;
  final String items;
  final String total;
  final double totalAmount;
  final String payment;
  final Color paymentColor;
  final Color paymentBackground;
  final String status;
  final Color statusColor;
  final Color statusBackground;
  final String deliveryPartner;
  final String sourceLabel;
  final String quotationId;

  const _OrderRecord({
    this.id = '',
    required this.number,
    required this.customer,
    required this.date,
    this.dateValue,
    required this.items,
    required this.total,
    this.totalAmount = 0,
    required this.payment,
    required this.paymentColor,
    required this.paymentBackground,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
    required this.deliveryPartner,
    this.sourceLabel = 'Office',
    this.quotationId = '',
  });

  factory _OrderRecord.fromJson(Map<String, dynamic> json) {
    final order = _readMap(json, const ['order', 'sales_order', 'salesOrder']);
    final source = order.isEmpty ? json : <String, dynamic>{...json, ...order};
    final customer = _readMap(source, const ['customer', 'customer_details']);
    final deliveryPartner = _readMap(source, const [
      'delivery_partner',
      'deliveryPartner',
      'assigned_delivery_partner',
      'assignedDeliveryPartner',
    ]);
    final itemsList = _readList(source, const [
      'items',
      'order_items',
      'orderItems',
      'products',
    ]);
    final totalAmount = _readDouble(source, const [
      'grand_total',
      'grandTotal',
      'total',
      'total_amount',
      'totalAmount',
      'amount',
      'net_amount',
      'netAmount',
    ]);
    final dateValue = _readDate(
      _readString(source, const [
        'order_date',
        'orderDate',
        'date',
        'created_at',
        'createdAt',
      ]),
    );
    final payment = _normalizePayment(
      _readString(source, const [
        'payment_status',
        'paymentStatus',
        'payment',
        'payment_state',
      ], fallback: 'Unpaid'),
    );
    final status = _titleCase(
      _readString(source, const [
        'status',
        'order_status',
        'orderStatus',
      ], fallback: 'Draft'),
    );
    final statusColors = _statusColors(status);
    final paymentColors = _paymentColors(payment);

    return _OrderRecord(
      id: _readString(source, const ['id', '_id', 'order_id', 'orderId']),
      number: _readString(
        source,
        const ['order_number', 'orderNumber', 'number', 'sales_order_number'],
        fallback: 'SO-${_readString(source, const ['id', '_id']).takeLast(5)}',
      ),
      customer: _firstNonEmpty([
        _readString(source, const ['customer_name', 'customerName']),
        _readString(customer, const ['business_name', 'businessName']),
        _readString(customer, const ['name', 'full_name', 'fullName']),
        'Customer',
      ]),
      date: dateValue == null ? '-' : _formatApiDate(dateValue),
      dateValue: dateValue,
      items: _readString(source, const [
        'items_count',
        'itemsCount',
        'total_items',
        'totalItems',
      ], fallback: itemsList.isEmpty ? '-' : itemsList.length.toString()),
      total: _formatApiMoney(totalAmount),
      totalAmount: totalAmount,
      payment: payment,
      paymentColor: paymentColors.foreground,
      paymentBackground: paymentColors.background,
      status: status,
      statusColor: statusColors.foreground,
      statusBackground: statusColors.background,
      deliveryPartner: _firstNonEmpty([
        _readString(source, const [
          'delivery_partner_name',
          'deliveryPartnerName',
        ]),
        _readString(deliveryPartner, const ['name', 'full_name', 'fullName']),
        '-',
      ]),
      sourceLabel: _sourceLabel(source),
      quotationId: _readString(source, const [
        'quotation_id',
        'quotationId',
        'source_quotation_id',
        'sourceQuotationId',
      ]),
    );
  }
}

class _ChipColors {
  final Color foreground;
  final Color background;

  const _ChipColors(this.foreground, this.background);
}

Map<String, dynamic> _readMap(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return const {};
}

List<dynamic> _readList(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is List) return value;
  }
  return const [];
}

String _readString(
  Map<String, dynamic> source,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = source[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return fallback;
}

double _readDouble(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(
        value.replaceAll(RegExp(r'[^0-9.\-]'), ''),
      );
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

DateTime? _readDate(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  final parsed = DateTime.tryParse(trimmed);
  if (parsed != null) return parsed;

  final parts = trimmed.split(RegExp(r'\s+'));
  if (parts.length < 3) return null;
  final day = int.tryParse(parts[0]);
  final month = _monthNumber(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

int? _monthNumber(String value) {
  const months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };
  final normalized = value.toLowerCase();
  return months[normalized.length <= 3
      ? normalized
      : normalized.substring(0, 3)];
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

String _titleCase(String value) {
  final normalized = value.trim().replaceAll('_', ' ').replaceAll('-', ' ');
  if (normalized.isEmpty) return '';
  return normalized
      .split(RegExp(r'\s+'))
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String _normalizePayment(String value) {
  final normalized = value.trim().toLowerCase().replaceAll('_', ' ');
  if (normalized.contains('paid') && !normalized.contains('unpaid')) {
    return 'Paid';
  }
  if (normalized.contains('partial')) return 'Partial';
  return 'Unpaid';
}

String _sourceLabel(Map<String, dynamic> order) {
  final raw = _readString(order, const [
    'source',
    'order_source',
    'orderSource',
    'source_type',
    'sourceType',
  ], fallback: 'office');
  return _titleCase(raw);
}

String _formatApiDate(DateTime date) {
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

String _formatApiMoney(double value) {
  final rounded = value.round();
  final raw = rounded.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final fromRight = raw.length - i;
    buffer.write(raw[i]);
    if (fromRight > 1 && fromRight % 3 == 1) buffer.write(',');
  }
  return 'Rs. $buffer';
}

_ChipColors _paymentColors(String payment) {
  switch (payment) {
    case 'Paid':
      return const _ChipColors(Color(0xFF16A34A), Color(0xFFE8F8EE));
    case 'Partial':
      return const _ChipColors(Color(0xFFF59E0B), Color(0xFFFFF7E6));
    default:
      return const _ChipColors(Color(0xFFEF4444), Color(0xFFFEE2E2));
  }
}

_ChipColors _statusColors(String status) {
  final normalized = _AdminOrdersScreenState._normalizeStatus(status);
  if (normalized == 'delivered' || normalized == 'completed') {
    return const _ChipColors(Color(0xFF16A34A), Color(0xFFE8F8EE));
  }
  if (normalized == 'confirmed') {
    return const _ChipColors(Color(0xFF2563EB), Color(0xFFEFF6FF));
  }
  if (normalized == 'processing' || normalized == 'out for delivery') {
    return const _ChipColors(Color(0xFFF59E0B), Color(0xFFFFF7E6));
  }
  if (normalized == 'cancelled' || normalized == 'returned') {
    return const _ChipColors(Color(0xFFEF4444), Color(0xFFFEE2E2));
  }
  if (normalized == 'partially delivered') {
    return const _ChipColors(Color(0xFF7C3AED), Color(0xFFF3E8FF));
  }
  return const _ChipColors(Color(0xFF64748B), Color(0xFFF1F5F9));
}

extension _StringTakeLast on String {
  String takeLast(int count) {
    if (length <= count) return this;
    return substring(length - count);
  }
}
