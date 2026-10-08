import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';
import '../../../utils/product_image_url.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';
import '../../../widgets/delivery/order_progress_tracker.dart';

class DeliveryCustomerOrderDetailScreen extends StatefulWidget {
  const DeliveryCustomerOrderDetailScreen({
    super.key,
    required this.orderId,
    this.initialProgressStatus,
  });

  final String orderId;
  final String? initialProgressStatus;

  @override
  State<DeliveryCustomerOrderDetailScreen> createState() =>
      _DeliveryCustomerOrderDetailScreenState();
}

class _DeliveryCustomerOrderDetailScreenState
    extends State<DeliveryCustomerOrderDetailScreen> {
  ApiProvider? _api;
  Map<String, dynamic>? _order;
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_api != null) return;
    _api = ApiProviderScope.of(context);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api!.fetchOrderById(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = _unwrapOrder(response);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.textScalerOf(
          context,
        ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2),
      ),
      child: Scaffold(
        backgroundColor: AppColors.deliveryBackground,
        body: SafeArea(
          child: Column(
            children: [
              DeliveryTopBar(
                title: 'Customer Order Details',
                subtitle: 'Order summary and delivery information',
                leadingIcon: Icons.arrow_back_rounded,
                onLeadingTap: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.deliveryGreen,
                  onRefresh: _load,
                  child: _body(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.deliveryGreen),
      );
    }
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [_StateCard(message: _error!, onRetry: _load)],
      );
    }

    final order = _order ?? const <String, dynamic>{};
    final items = _readList(order, const [
      'items',
      'order_items',
      'orderItems',
    ]);
    final status = _titleCase(
      _readString(order, const ['status'], fallback: 'Order'),
    );
    final progressStatus = _readString(order, const [
      'fulfillment_status',
      'fulfilment_status',
      'delivery_status',
    ], fallback: widget.initialProgressStatus ?? status);
    final subtotal = _readDouble(order, const [
      'subtotal',
      'sub_total',
      'subtotal_amount',
    ]);
    final discount = _readDouble(order, const [
      'discount',
      'discount_amount',
      'total_discount',
    ]);
    final tax = _readDouble(order, const ['tax', 'tax_amount', 'total_tax']);
    final total = _readDouble(order, const [
      'total',
      'total_amount',
      'order_total',
    ]);
    final previousBalance = _readDouble(order, const [
      'previous_balance',
      'previousBalance',
      'customer_previous_balance',
    ]);
    final grandTotal = _readDouble(order, const [
      'grand_total',
      'grandTotal',
      'net_total',
    ], fallback: total + previousBalance);
    final paidAmount = _readDouble(order, const [
      'paid_amount',
      'paidAmount',
      'amount_paid',
    ]);
    final balance = _readDouble(order, const [
      'balance',
      'balance_amount',
      'due_amount',
      'amount_due',
    ], fallback: grandTotal - paidAmount);

    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OrderHeading(
                    number: _readString(order, const [
                      'order_number',
                      'orderNumber',
                      'number',
                    ], fallback: 'Sales Order'),
                    customer: _customerName(order),
                    status: status,
                  ),
                  const SizedBox(height: 12),
                  OrderProgressTracker(status: progressStatus),
                  const SizedBox(height: 12),
                  _OrderCard(
                    child: Column(
                      children: [
                        _SectionHeader(itemCount: items.length),
                        const SizedBox(height: 12),
                        if (items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'No order items found',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          for (
                            var index = 0;
                            index < items.length;
                            index++
                          ) ...[
                            _ProductRow(item: _asMap(items[index])),
                            if (index != items.length - 1)
                              const Divider(
                                height: 20,
                                color: AppColors.border,
                              ),
                          ],
                        const Divider(height: 24, color: AppColors.border),
                        _AmountRow(label: 'Subtotal', value: subtotal),
                        if (tax > 0) _AmountRow(label: 'Tax', value: tax),
                        _AmountRow(
                          label: 'Discount',
                          value: discount,
                          prefix: discount > 0 ? '− ' : '',
                          valueColor: AppColors.deliveryGreen,
                        ),
                        const Divider(height: 16, color: AppColors.border),
                        _AmountRow(label: 'Total', value: total, strong: true),
                        _AmountRow(
                          label: 'Previous Balance',
                          value: previousBalance,
                          prefix: previousBalance > 0 ? '+ ' : '',
                        ),
                        _AmountRow(
                          label: 'Grand Total',
                          value: grandTotal,
                          strong: true,
                          highlighted: true,
                        ),
                        _AmountRow(
                          label: 'Paid Amount',
                          value: paidAmount,
                          valueColor: AppColors.deliveryGreen,
                        ),
                        _AmountRow(
                          label: 'Balance',
                          value: balance,
                          strong: true,
                          valueColor: balance > 0
                              ? AppColors.deliveryRed
                              : AppColors.deliveryGreen,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _OrderCard(
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'Order Date',
                          value: _formatDate(order, const [
                            'order_date',
                            'orderDate',
                            'created_at',
                          ]),
                        ),
                        _DetailRow(
                          label: 'Delivery Date',
                          value: _formatDate(order, const [
                            'delivery_date',
                            'deliveryDate',
                          ]),
                        ),
                        _DetailRow(
                          label: 'Warehouse',
                          value: _nestedName(order, const ['warehouse']),
                        ),
                        _DetailRow(
                          label: 'Payment Type',
                          value: _titleCase(
                            _readString(order, const [
                              'payment_type',
                              'paymentType',
                              'payment_method',
                            ]),
                          ),
                        ),
                        _DetailRow(
                          label: 'Delivery Method',
                          value: _titleCase(
                            _readString(order, const [
                              'fulfilment_method',
                              'fulfillment_method',
                              'delivery_method',
                            ]),
                          ),
                        ),
                        _DetailRow(
                          label: 'Order Delivery By',
                          value: _nestedName(order, const [
                            'delivery_partner',
                            'deliveryPartner',
                          ]),
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderHeading extends StatelessWidget {
  const _OrderHeading({
    required this.number,
    required this.customer,
    required this.status,
  });

  final String number;
  final String customer;
  final String status;

  @override
  Widget build(BuildContext context) {
    return _OrderCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.deliveryGreenSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 22,
              color: AppColors.deliveryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.isEmpty ? 'Customer Order' : customer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  number,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.deliveryGreenSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: AppColors.deliveryGreen,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.itemCount});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deliveryGreenSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 20,
            color: AppColors.deliveryGreen,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Order Summary',
              style: TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            style: const TextStyle(
              color: AppColors.deliveryGreen,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = productImageUrlFromJson(item)?.trim() ?? '';
    final quantity = _readDouble(item, const ['quantity', 'qty']);
    final unit = _readString(item, const ['uom', 'unit', 'unit_of_measure']);
    final price = _readDouble(item, const ['unit_price', 'unitPrice', 'price']);
    final lineTotal = _readDouble(item, const [
      'line_total',
      'lineTotal',
      'total',
      'amount',
    ], fallback: quantity * price);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.deliverySurfaceBorder),
          ),
          child: imageUrl.isEmpty
              ? const Icon(
                  Icons.inventory_2_outlined,
                  size: 22,
                  color: AppColors.textLightMuted,
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.inventory_2_outlined,
                    size: 22,
                    color: AppColors.textLightMuted,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _readString(item, const [
                  'product_name',
                  'productName',
                  'name',
                ], fallback: 'Product'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.deliveryInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_money(price)}${unit.isEmpty ? '' : ' / $unit'}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _money(lineTotal),
                style: const TextStyle(
                  color: AppColors.deliveryInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Ordered',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              _cleanNumber(quantity),
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.label,
    required this.value,
    this.prefix = '',
    this.strong = false,
    this.highlighted = false,
    this.valueColor,
  });

  final String label;
  final double value;
  final String prefix;
  final bool strong;
  final bool highlighted;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.deliveryGreenSoft : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            _amountIcon(label),
            size: 16,
            color: valueColor ?? AppColors.deliveryGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 13,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$prefix${_money(value)}',
            style: TextStyle(
              color: valueColor ?? AppColors.deliveryInk,
              fontSize: 13,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.trim().isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.deliveryHeroShadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _OrderCard(
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: AppColors.textLightMuted,
          ),
          const SizedBox(height: 12),
          const Text(
            'Could not load order details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.deliveryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, dynamic> _unwrapOrder(Map<String, dynamic> json) {
  final nested = _readMap(json, const [
    'order',
    'sales_order',
    'salesOrder',
    'data',
  ]);
  return nested.isEmpty ? json : <String, dynamic>{...json, ...nested};
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

Map<String, dynamic> _readMap(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
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
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return fallback;
}

double _readDouble(
  Map<String, dynamic> source,
  List<String> keys, {
  double fallback = 0,
}) {
  for (final key in keys) {
    final value = source[key];
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return fallback;
}

String _customerName(Map<String, dynamic> order) {
  final customer = _readMap(order, const ['customer']);
  return _firstNonEmpty([
    _readString(order, const ['customer_name', 'customerName']),
    _readString(customer, const ['business_name', 'businessName']),
    _readString(customer, const ['name', 'full_name', 'fullName']),
  ]);
}

String _nestedName(Map<String, dynamic> source, List<String> keys) {
  final nested = _readMap(source, keys);
  final directKeys = <String>[];
  for (final key in keys) {
    directKeys.add('${key}_name');
  }
  return _firstNonEmpty([
    _readString(nested, const [
      'name',
      'full_name',
      'fullName',
      'business_name',
    ]),
    _readString(source, directKeys),
  ]);
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

String _titleCase(String value) {
  if (value.trim().isEmpty) return '-';
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map(
        (word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String _formatDate(Map<String, dynamic> source, List<String> keys) {
  final raw = _readString(source, keys);
  final date = DateTime.tryParse(raw);
  if (date == null) return raw.isEmpty ? '-' : raw;
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

String _money(double value) => '₹ ${value.toStringAsFixed(2)}';

String _cleanNumber(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();

IconData _amountIcon(String label) {
  if (label == 'Discount') return Icons.percent_rounded;
  if (label == 'Paid Amount') return Icons.payments_outlined;
  if (label == 'Balance') return Icons.account_balance_wallet_outlined;
  if (label == 'Grand Total') return Icons.shopping_bag_outlined;
  return Icons.receipt_long_outlined;
}
