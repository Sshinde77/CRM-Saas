import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/admin/admin_top_bar.dart';
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
import 'admin_orders_screen.dart';
import 'new_admin_order_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final bool useSalesManagerShell;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.useSalesManagerShell = false,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ApiProvider _apiProvider;
  bool _providerReady = false;
  bool _isLoading = true;
  bool _isActionLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _order;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadOrder();
    });
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _apiProvider.fetchOrderById(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = _unwrapOrder(response);
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

  Future<void> _confirmOrder() async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);
    try {
      final response = await _apiProvider.confirmOrder(widget.orderId);
      if (!mounted) return;
      setState(() => _order = _unwrapOrder(response));
      _showSnack('Order confirmed.');
    } catch (error) {
      if (mounted) _showSnack(error.toString());
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  Future<void> _cancelOrder() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cancel Order'),
        children: [
          for (final option in const [
            'Customer Cancelled',
            'Stock Unavailable',
            'Duplicate Order',
            'Pricing Issue',
            'Delivery Issue',
            'Other',
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(option),
              child: Text(option),
            ),
        ],
      ),
    );
    if (reason == null || _isActionLoading) return;

    setState(() => _isActionLoading = true);
    try {
      final response = await _apiProvider.cancelOrder(
        orderId: widget.orderId,
        reason: reason,
      );
      if (!mounted) return;
      setState(() => _order = _unwrapOrder(response));
      _showSnack('Order cancelled.');
    } catch (error) {
      if (mounted) _showSnack(error.toString());
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _handleSalesManagerSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'Sales Orders') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminOrdersScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
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
          builder: (_) => const AdminQuotationsScreen(useSalesManagerShell: true),
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
        child: Column(
          children: [
            widget.useSalesManagerShell
                ? SalesManagerTopBar(
                    title: 'Order Detail',
                    leadingIcon: Icons.arrow_back_rounded,
                    onLeadingTap: () => Navigator.of(context).maybePop(),
                  )
                : AdminTopBar(
                    title: 'Order Detail',
                    leadingIcon: Icons.arrow_back_rounded,
                    onLeadingTap: () => Navigator.of(context).maybePop(),
                  ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadOrder,
                child: _body(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _StateCard(
            icon: Icons.cloud_off_rounded,
            title: 'Could not load order',
            subtitle: _errorMessage!,
            actionLabel: 'Retry',
            onAction: _loadOrder,
          ),
        ],
      );
    }

    final order = _order ?? const <String, dynamic>{};
    final items = _readList(order, const ['items', 'order_items', 'orderItems']);
    final status = _titleCase(_readString(order, const ['status'], fallback: 'Draft'));
    final fulfilment = _titleCase(
      _readString(order, const ['fulfilment_method', 'fulfillment_method']),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
      children: [
        _HeaderCard(
          number: _readString(
            order,
            const ['order_number', 'orderNumber', 'number'],
            fallback: 'Order',
          ),
          customer: _customerName(order),
          status: status,
          total: _formatMoney(_readDouble(order, const [
            'grand_total',
            'grandTotal',
            'total',
            'total_amount',
          ])),
          onConfirm: _isActionLoading ? null : _confirmOrder,
          onCancel: _isActionLoading ? null : _cancelOrder,
        ),
        const SizedBox(height: 10),
        _SectionCard(
          title: 'Order Summary',
          icon: Icons.receipt_long_outlined,
          child: Column(
            children: [
              _DetailRow('Order Date', _formatAnyDate(order, const ['order_date', 'orderDate', 'created_at'])),
              _DetailRow('Delivery Date', _formatAnyDate(order, const ['delivery_date', 'deliveryDate'])),
              _DetailRow('Fulfilment', fulfilment.isEmpty ? '-' : fulfilment),
              _DetailRow('Payment', _titleCase(_readString(order, const ['payment_type', 'paymentType', 'payment_status']))),
              _DetailRow('Source', _sourceLabel(order)),
              _DetailRow('Warehouse', _nestedName(order, const ['warehouse'])),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _SectionCard(
          title: 'Delivery & Customer',
          icon: Icons.local_shipping_outlined,
          child: Column(
            children: [
              _DetailRow('Customer', _customerName(order)),
              _DetailRow('Delivery Partner', _nestedName(order, const ['delivery_partner', 'deliveryPartner'])),
              _DetailRow('Delivery Address', _readString(order, const ['delivery_address', 'deliveryAddress', 'shipping_address'])),
              _DetailRow('Created By', _creatorName(order)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _SectionCard(
          title: 'Items (${items.length})',
          icon: Icons.inventory_2_outlined,
          child: items.isEmpty
              ? const Text(
                  'No items found.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                )
              : Column(
                  children: [
                    for (final item in items)
                      _ItemTile(item: item is Map ? Map<String, dynamic>.from(item) : const {}),
                  ],
                ),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String number;
  final String customer;
  final String status;
  final String total;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const _HeaderCard({
    required this.number,
    required this.customer,
    required this.status,
    required this.total,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E1B), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _TinyChip(label: status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            customer,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.86),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            total,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeaderAction(
                icon: Icons.fact_check_outlined,
                label: 'Confirm Order',
                onTap: onConfirm,
              ),
              _HeaderAction(
                icon: Icons.cancel_outlined,
                label: 'Cancel Order',
                onTap: onCancel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 17),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final quantity = _readString(item, const ['quantity', 'qty'], fallback: '0');
    final uom = _readString(item, const ['uom', 'unit', 'unit_of_measure']);
    final price = _readDouble(item, const ['unit_price', 'unitPrice', 'price']);
    final total = _readDouble(item, const ['line_total', 'lineTotal', 'total']);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _readString(item, const ['product_name', 'productName', 'name'], fallback: 'Product'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          _DetailRow('Qty / UOM', '$quantity $uom'),
          _DetailRow('Unit Price', _formatMoney(price)),
          _DetailRow('Line Total', _formatMoney(total)),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _HeaderAction({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _TinyChip extends StatelessWidget {
  final String label;

  const _TinyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StateCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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

Map<String, dynamic> _unwrapOrder(Map<String, dynamic> json) {
  final nested = _readMap(json, const ['order', 'sales_order', 'salesOrder', 'data']);
  return nested.isEmpty ? json : <String, dynamic>{...json, ...nested};
}

String _customerName(Map<String, dynamic> order) {
  final customer = _readMap(order, const ['customer']);
  return _firstNonEmpty([
    _readString(order, const ['customer_name', 'customerName']),
    _readString(customer, const ['business_name', 'businessName']),
    _readString(customer, const ['name', 'full_name', 'fullName']),
  ]);
}

String _creatorName(Map<String, dynamic> order) {
  final creator = _readMap(order, const ['creator', 'created_by_user', 'createdBy']);
  return _firstNonEmpty([
    _readString(order, const ['created_by_name', 'createdByName']),
    _readString(creator, const ['name', 'full_name', 'fullName']),
  ]);
}

String _nestedName(Map<String, dynamic> source, List<String> keys) {
  final nested = _readMap(source, keys);
  return _firstNonEmpty([
    _readString(nested, const ['name', 'full_name', 'fullName', 'business_name']),
    _readString(source, keys.map((key) => '${key}_name').toList()),
  ]);
}

String _sourceLabel(Map<String, dynamic> order) {
  final raw = _readString(order, const ['source', 'order_source', 'orderSource']);
  return _titleCase(raw.isEmpty ? 'office' : raw);
}

String _formatAnyDate(Map<String, dynamic> source, List<String> keys) {
  final date = DateTime.tryParse(_readString(source, keys));
  if (date == null) return '-';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
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

String _readString(Map<String, dynamic> source, List<String> keys, {String fallback = ''}) {
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
      final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.\-]'), ''));
      if (parsed != null) return parsed;
    }
  }
  return 0;
}

String _titleCase(String value) {
  final normalized = value.trim().replaceAll('_', ' ').replaceAll('-', ' ');
  if (normalized.isEmpty) return '';
  return normalized
      .split(RegExp(r'\s+'))
      .map((word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
      .join(' ');
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

String _formatMoney(double value) {
  final raw = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final fromRight = raw.length - i;
    buffer.write(raw[i]);
    if (fromRight > 1 && fromRight % 3 == 1) buffer.write(',');
  }
  return 'Rs. $buffer';
}
