import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';

class DeliveryCompanyOrdersScreen extends StatefulWidget {
  const DeliveryCompanyOrdersScreen({super.key});

  @override
  State<DeliveryCompanyOrdersScreen> createState() =>
      _DeliveryCompanyOrdersScreenState();
}

class _DeliveryCompanyOrdersScreenState
    extends State<DeliveryCompanyOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<_CompanyOrder>>? _future;
  String _status = 'all';
  String _fulfilmentStatus = 'all';
  bool _didStartLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _future = _loadOrders();
      _didStartLoad = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<_CompanyOrder>> _loadOrders() async {
    final rows = await ApiProviderScope.of(context)
        .fetchDeliveryPartnerCompanyOrders(
          status: _status == 'all' ? null : _status,
          fulfilmentStatus: _fulfilmentStatus == 'all'
              ? null
              : _fulfilmentStatus,
          search: _searchController.text.trim(),
          limit: 50,
          offset: 0,
        );
    return rows.map(_CompanyOrder.fromJson).toList();
  }

  Future<void> _refresh() async {
    final request = _loadOrders();
    setState(() => _future = request);
    await request;
  }

  void _applyFilters() {
    setState(() => _future = _loadOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            DeliveryTopBar(
              title: 'Company Orders',
              subtitle: 'Read-only order list from dashboard',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: FutureBuilder<List<_CompanyOrder>>(
                future: _future,
                builder: (context, snapshot) {
                  final orders = snapshot.data ?? const <_CompanyOrder>[];
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData;

                  return RefreshIndicator(
                    color: AppColors.deliveryGreen,
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
                      children: [
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: Column(
                              children: [
                                _FiltersCard(
                                  controller: _searchController,
                                  status: _status,
                                  fulfilmentStatus: _fulfilmentStatus,
                                  onStatusChanged: (value) {
                                    setState(() => _status = value);
                                    _applyFilters();
                                  },
                                  onFulfilmentChanged: (value) {
                                    setState(() => _fulfilmentStatus = value);
                                    _applyFilters();
                                  },
                                  onSearch: _applyFilters,
                                ),
                                const SizedBox(height: 12),
                                if (isLoading)
                                  const _StateCard.loading()
                                else if (snapshot.hasError)
                                  _StateCard.error(
                                    message: _cleanError(snapshot.error),
                                    onRetry: _refresh,
                                  )
                                else if (orders.isEmpty)
                                  const _StateCard.empty()
                                else
                                  Column(
                                    children: [
                                      for (var i = 0; i < orders.length; i++)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: i == orders.length - 1
                                                ? 0
                                                : 10,
                                          ),
                                          child: _OrderCard(order: orders[i]),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
}

class _FiltersCard extends StatelessWidget {
  final TextEditingController controller;
  final String status;
  final String fulfilmentStatus;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onFulfilmentChanged;
  final VoidCallback onSearch;

  const _FiltersCard({
    required this.controller,
    required this.status,
    required this.fulfilmentStatus,
    required this.onStatusChanged,
    required this.onFulfilmentChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: [
          SizedBox(
            height: 42,
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                hintText: 'Search order number',
                hintStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
                suffixIcon: IconButton(
                  onPressed: onSearch,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  color: AppColors.deliveryGreen,
                ),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.deliverySurfaceBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.deliverySurfaceBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.deliveryGreen),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FilterMenu(
                  value: status,
                  options: const [
                    _FilterOption('all', 'All statuses'),
                    _FilterOption('draft', 'Draft'),
                    _FilterOption('confirmed', 'Confirmed'),
                    _FilterOption('completed', 'Completed'),
                    _FilterOption('cancelled', 'Cancelled'),
                  ],
                  onChanged: onStatusChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _FilterMenu(
                  value: fulfilmentStatus,
                  options: const [
                    _FilterOption('all', 'All fulfilment'),
                    _FilterOption('not_started', 'Not Started'),
                    _FilterOption('planned', 'Planned'),
                    _FilterOption('loaded', 'Loaded'),
                    _FilterOption('in_transit', 'In Transit'),
                    _FilterOption('delivered', 'Delivered'),
                    _FilterOption('failed', 'Failed'),
                  ],
                  onChanged: onFulfilmentChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterMenu extends StatelessWidget {
  final String value;
  final List<_FilterOption> options;
  final ValueChanged<String> onChanged;

  const _FilterMenu({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = options.firstWhere(
      (option) => option.value == value,
      orElse: () => options.first,
    );

    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<String>(
            value: option.value,
            child: Text(
              option.label,
              style: TextStyle(
                color: option.value == value
                    ? AppColors.deliveryGreen
                    : AppColors.deliveryInk,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.deliverySurfaceBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.deliveryInk,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final _CompanyOrder order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.deliveryGreenSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.deliveryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.deliveryInk,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(label: order.statusLabel, color: order.statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                icon: Icons.inventory_2_outlined,
                label: order.fulfilmentLabel,
              ),
              _MetricChip(
                icon: Icons.currency_rupee_rounded,
                label: order.formattedTotal,
              ),
              _MetricChip(
                icon: Icons.payments_outlined,
                label: order.paymentLabel,
              ),
              _MetricChip(
                icon: Icons.calendar_today_outlined,
                label: order.formattedDate,
              ),
            ],
          ),
          if (order.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.deliverySurfaceBorder),
            const SizedBox(height: 10),
            Text(
              order.items.take(2).map((item) => item.summary).join('\n'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppSizes.pillRadius),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.deliveryInk,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSizes.pillRadius),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final bool loading;

  const _StateCard._({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
    this.loading = false,
  });

  const _StateCard.loading()
    : this._(
        icon: Icons.hourglass_empty_rounded,
        title: 'Loading orders',
        message: 'Please wait while company orders load.',
        loading: true,
      );

  const _StateCard.empty()
    : this._(
        icon: Icons.receipt_long_outlined,
        title: 'No company orders found',
        message: 'Try changing filters or search text.',
      );

  const _StateCard.error({
    required String message,
    required VoidCallback onRetry,
  }) : this._(
         icon: Icons.cloud_off_rounded,
         title: 'Orders could not load',
         message: message,
         onRetry: onRetry,
       );

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: SizedBox(
        height: 210,
        child: Center(
          child: loading
              ? const CircularProgressIndicator(color: AppColors.deliveryGreen)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: AppColors.textMuted, size: 38),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.deliveryInk,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;

  const _SurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FilterOption {
  final String value;
  final String label;

  const _FilterOption(this.value, this.label);
}

class _CompanyOrder {
  final String id;
  final String orderNumber;
  final String customerName;
  final String status;
  final String fulfilmentStatus;
  final String paymentStatus;
  final double total;
  final DateTime? createdAt;
  final List<_CompanyOrderItem> items;

  const _CompanyOrder({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.status,
    required this.fulfilmentStatus,
    required this.paymentStatus,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  factory _CompanyOrder.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'];
    final rawItems = json['items'];
    return _CompanyOrder(
      id: _readString(json, const ['id']),
      orderNumber: _readString(json, const ['order_number', 'orderNumber']),
      customerName: customer is Map<String, dynamic>
          ? _readString(customer, const ['business_name', 'name'])
          : 'Customer',
      status: _normalize(_readString(json, const ['status'])),
      fulfilmentStatus: _normalize(
        _readString(json, const ['fulfilment_status', 'fulfilmentStatus']),
      ),
      paymentStatus: _normalize(
        _readString(json, const ['payment_status', 'paymentStatus']),
      ),
      total: _readDouble(json, const ['total', 'grand_total']),
      createdAt: _parseDate(_readString(json, const ['created_at'])),
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(_CompanyOrderItem.fromJson)
                .toList()
          : const [],
    );
  }

  String get statusLabel => _labelFor(status.isEmpty ? 'unknown' : status);

  String get fulfilmentLabel =>
      _labelFor(fulfilmentStatus.isEmpty ? 'not_started' : fulfilmentStatus);

  String get paymentLabel =>
      _labelFor(paymentStatus.isEmpty ? 'payment pending' : paymentStatus);

  String get formattedTotal => _formatMoney(total);

  String get formattedDate {
    final date = createdAt;
    if (date == null) return 'Date unavailable';
    return _formatDate(date);
  }

  Color get statusColor {
    return switch (status) {
      'completed' => AppColors.deliveryGreen,
      'cancelled' || 'canceled' => AppColors.deliveryRed,
      'confirmed' => AppColors.deliveryBlue,
      'draft' => AppColors.deliveryOrange,
      _ => AppColors.textMuted,
    };
  }
}

class _CompanyOrderItem {
  final String productName;
  final double quantity;
  final String uom;

  const _CompanyOrderItem({
    required this.productName,
    required this.quantity,
    required this.uom,
  });

  factory _CompanyOrderItem.fromJson(Map<String, dynamic> json) {
    return _CompanyOrderItem(
      productName: _readString(json, const ['product_name', 'productName']),
      quantity: _readDouble(json, const ['quantity', 'ordered_quantity']),
      uom: _readString(json, const ['uom']),
    );
  }

  String get summary {
    final qty = quantity == quantity.roundToDouble()
        ? quantity.round().toString()
        : quantity.toStringAsFixed(1);
    final unit = uom.trim().isEmpty ? '' : ' $uom';
    return '$productName - $qty$unit';
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return 0;
}

DateTime? _parseDate(String value) {
  if (value.trim().isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
}

String _labelFor(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _formatMoney(double value) {
  final rounded = value.round();
  final source = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < source.length; i++) {
    final remaining = source.length - i;
    buffer.write(source[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
  }
  return '${rounded < 0 ? '-' : ''}Rs ${buffer.toString()}';
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
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _cleanError(Object? error) {
  final text = error?.toString().trim() ?? '';
  if (text.isEmpty) return 'Something went wrong.';
  return text.replaceFirst('ApiException: ', '');
}
