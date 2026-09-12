import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/delivery_detail_model.dart';
import '../../../providers/api_provider.dart';

class DeliveryDetailScreen extends StatefulWidget {
  final String deliveryId;

  const DeliveryDetailScreen({super.key, required this.deliveryId});

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  Future<DeliveryDetail>? _future;
  DeliveryDetail? _delivery;
  bool _isActionBusy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<DeliveryDetail> _load() async {
    final detail = await ApiProviderScope.of(
      context,
    ).fetchDeliveryById(widget.deliveryId);
    if (mounted) setState(() => _delivery = detail);
    return detail;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _downloadChallan() async {
    final delivery = _delivery;
    if (delivery == null || _isActionBusy) return;
    setState(() => _isActionBusy = true);
    try {
      final bytes = await ApiProviderScope.of(
        context,
      ).downloadDeliveryChallan(delivery.id);
      _showSnack('Delivery challan downloaded (${bytes.length} bytes).');
    } catch (error) {
      _showSnack(_cleanError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isActionBusy = false);
    }
  }

  Future<void> _confirmDelivery() async {
    final delivery = _delivery;
    if (delivery == null || _isActionBusy) return;
    final ok = await _confirmDialog(
      title: 'Confirm Delivery',
      message: 'Confirm this delivery and update delivered item quantities?',
    );
    if (ok != true) return;

    await _submitDeliveryAction(
      delivery,
      payload: {
        'status': 'delivered',
        'delivery_items': [
          for (final item in delivery.items)
            {
              if (item.id.isNotEmpty) 'id': item.id,
              if (item.productId.isNotEmpty) 'product_id': item.productId,
              'delivered_quantity': item.loaded > 0
                  ? item.loaded
                  : item.planned,
            },
        ],
      },
      successMessage: 'Delivery confirmed.',
    );
  }

  Future<void> _markFailed() async {
    final delivery = _delivery;
    if (delivery == null || _isActionBusy) return;
    final reason = await _failureReasonDialog();
    if (reason == null || reason.trim().isEmpty) return;

    await _submitDeliveryAction(
      delivery,
      payload: {
        'status': 'failed',
        'failure_reason': reason.trim(),
        'notes': reason.trim(),
      },
      successMessage: 'Delivery marked as failed.',
    );
  }

  Future<void> _submitDeliveryAction(
    DeliveryDetail delivery, {
    required Map<String, dynamic> payload,
    required String successMessage,
  }) async {
    setState(() => _isActionBusy = true);
    try {
      await ApiProviderScope.of(
        context,
      ).confirmDelivery(deliveryId: delivery.id, payload: payload);
      if (!mounted) return;
      final next = await ApiProviderScope.of(
        context,
      ).fetchDeliveryById(delivery.id);
      if (!mounted) return;
      setState(() {
        _delivery = next;
        _future = Future.value(next);
      });
      _showSnack(successMessage);
    } catch (error) {
      _showSnack(_cleanError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isActionBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<DeliveryDetail>(
          future: _future,
          builder: (context, snapshot) {
            final delivery = snapshot.data ?? _delivery;
            return Column(
              children: [
                Container(
                  color: AppColors.primary,
                  height: 52,
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Delivery Details',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Download delivery challan',
                        onPressed: delivery == null || _isActionBusy
                            ? null
                            : _downloadChallan,
                        icon: Icon(
                          Icons.download_outlined,
                          color: delivery == null || _isActionBusy
                              ? Colors.white38
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child:
                      delivery == null &&
                          snapshot.connectionState == ConnectionState.waiting
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.deliveryGreen,
                          ),
                        )
                      : delivery == null && snapshot.hasError
                      ? _ErrorState(
                          message: _cleanError(snapshot.error),
                          onRetry: _refresh,
                        )
                      : RefreshIndicator(
                          color: AppColors.deliveryGreen,
                          onRefresh: _refresh,
                          child: _Body(
                            delivery: delivery!,
                            isActionBusy: _isActionBusy,
                            onConfirm: delivery.canConfirm
                                ? _confirmDelivery
                                : null,
                            onFailed: delivery.canConfirm ? _markFailed : null,
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

  Future<bool?> _confirmDialog({
    required String title,
    required String message,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<String?> _failureReasonDialog() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Failed'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Failure reason',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.deliveryRed,
            ),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? AppColors.deliveryRed
              : AppColors.deliveryGreen,
          content: Text(message),
        ),
      );
  }
}

class _Body extends StatelessWidget {
  final DeliveryDetail delivery;
  final bool isActionBusy;
  final VoidCallback? onConfirm;
  final VoidCallback? onFailed;

  const _Body({
    required this.delivery,
    required this.isActionBusy,
    required this.onConfirm,
    required this.onFailed,
  });

  @override
  Widget build(BuildContext context) {
    final totals = delivery.totals;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: DefaultTextStyle(
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 13,
                height: 1.35,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Order Id - ${delivery.orderNumber}',
                    style: const TextStyle(
                      color: AppColors.deliveryGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.deliveryBlueSoft,
                        child: Icon(
                          Icons.storefront_outlined,
                          color: AppColors.deliveryInk,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              delivery.customerName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (delivery.deliveryAddress.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                delivery.deliveryAddress,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                            if (delivery.customerPhone.isNotEmpty)
                              Text(
                                delivery.customerPhone,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.list_alt_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Delivery Summary',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Text(
                          '${delivery.items.length} ${delivery.items.length == 1 ? 'item' : 'items'}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _ItemColumns(
                    product: Text('Product'),
                    planned: Text('Qty'),
                    delivered: Text('Delivered'),
                    pending: Text('Pending'),
                    heading: true,
                  ),
                  if (delivery.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No items in this delivery.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  for (final item in delivery.items) _ItemRow(item: item),
                  const SizedBox(height: 6),
                  _DetailRow(
                    label: 'Planned Quantity',
                    value: '${totals.planned}',
                  ),
                  _DetailRow(
                    label: 'Picked / Loaded',
                    value: '${totals.picked} / ${totals.loaded}',
                  ),
                  _DetailRow(
                    label: 'Delivered Quantity',
                    value: '${totals.delivered}',
                    color: AppColors.deliveryGreen,
                    strong: true,
                  ),
                  _DetailRow(
                    label: 'Pending Quantity',
                    value: '${totals.pending}',
                    strong: true,
                  ),
                  const Divider(height: 14, color: AppColors.border),
                  _DetailRow(
                    label: 'Previous Balance',
                    value: _formatMoney(delivery.previousPendingBalance),
                  ),
                  _DetailRow(
                    label: 'Amount Due',
                    value: _formatMoney(delivery.amountDue),
                    color: AppColors.deliveryRed,
                    strong: true,
                    outlined: true,
                  ),
                  const Divider(height: 18, color: AppColors.border),
                  _DetailRow(
                    label: 'Delivery Id',
                    value: delivery.deliveryNumber,
                  ),
                  _DetailRow(
                    label: 'Status',
                    value: _statusLabel(delivery.status),
                    color: _statusColor(delivery.status),
                  ),
                  if (delivery.partialDelivery)
                    const _DetailRow(
                      label: 'Delivery Type',
                      value: 'Partial Delivery',
                    ),
                  _DetailRow(
                    label: 'Delivery Date',
                    value: _formatDate(delivery.scheduledDate),
                  ),
                  _DetailRow(label: 'Warehouse', value: delivery.warehouseName),
                  _DetailRow(label: 'Delivery By', value: delivery.partnerName),
                  if (delivery.partnerPhone.isNotEmpty)
                    _DetailRow(
                      label: 'Partner Phone',
                      value: delivery.partnerPhone,
                    ),
                  if (delivery.vehicleNumber.isNotEmpty)
                    _DetailRow(label: 'Vehicle', value: delivery.vehicleNumber),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    iconColor: AppColors.primary,
                    collapsedIconColor: AppColors.primary,
                    title: const Text(
                      'More delivery details',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      if (delivery.customerEmail.isNotEmpty)
                        _DetailRow(
                          label: 'Customer Email',
                          value: delivery.customerEmail,
                        ),
                      if (delivery.partnerEmail.isNotEmpty)
                        _DetailRow(
                          label: 'Partner Email',
                          value: delivery.partnerEmail,
                        ),
                      _DetailRow(
                        label: 'Vehicle Type',
                        value: delivery.vehicleType,
                      ),
                      _DetailRow(label: 'Capacity', value: delivery.capacity),
                      _DetailRow(
                        label: 'Dispatched At',
                        value: _formatDate(
                          delivery.dispatchedAt,
                          includeTime: true,
                        ),
                      ),
                      _DetailRow(
                        label: 'Confirmed At',
                        value: _formatDate(
                          delivery.confirmedAt,
                          includeTime: true,
                        ),
                      ),
                    ],
                  ),
                  if (delivery.failureReason.isNotEmpty)
                    _DetailRow(
                      label: 'Failure Reason',
                      value: delivery.failureReason,
                      color: AppColors.deliveryRed,
                    ),
                  if (delivery.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Notes',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(delivery.notes),
                  ],
                  if (delivery.podPhotos.isNotEmpty ||
                      delivery.signatureUrl.isNotEmpty) ...[
                    const Divider(height: 24, color: AppColors.border),
                    const Text(
                      'Proof of Delivery',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final url in delivery.podPhotos)
                          _DeliveryImage(url: url, size: 76),
                      ],
                    ),
                    if (delivery.signatureUrl.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'Signature',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      _DeliveryImage(url: delivery.signatureUrl, size: 120),
                    ],
                  ],
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: isActionBusy ? null : onConfirm,
                    icon: isActionBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.local_shipping_outlined, size: 19),
                    label: Text(
                      delivery.status == 'delivered'
                          ? 'Delivery Confirmed'
                          : 'Confirm Delivery',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onFailed != null)
                    TextButton.icon(
                      onPressed: isActionBusy ? null : onFailed,
                      icon: const Icon(Icons.cancel_outlined, size: 17),
                      label: const Text('Mark as Failed'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.deliveryRed,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemColumns extends StatelessWidget {
  final Widget product;
  final Widget planned;
  final Widget delivered;
  final Widget pending;
  final bool heading;

  const _ItemColumns({
    required this.product,
    required this.planned,
    required this.delivered,
    required this.pending,
    this.heading = false,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: heading ? AppColors.textMuted : AppColors.deliveryInk,
        fontSize: heading ? 10 : 12,
        fontWeight: heading ? FontWeight.w500 : FontWeight.w600,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Expanded(flex: 5, child: product),
            Expanded(flex: 2, child: Center(child: planned)),
            Expanded(flex: 3, child: Center(child: delivered)),
            Expanded(
              flex: 2,
              child: Align(alignment: Alignment.centerRight, child: pending),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final DeliveryDetailItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ItemColumns(
            product: Row(
              children: [
                _DeliveryImage(url: item.imageUrl, size: 30),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName),
                      if (item.variant.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.variant,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            planned: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('${item.planned}'),
            ),
            delivered: Text('${item.delivered}'),
            pending: Text('${item.pending}'),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              [
                'Picked: ${item.picked}',
                'Loaded: ${item.loaded}',
                if (item.batch.isNotEmpty) 'Batch: ${item.batch}',
                if (item.expiry.isNotEmpty)
                  'Expiry: ${_formatLooseDate(item.expiry)}',
              ].join('  \u00b7  '),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryImage extends StatelessWidget {
  final String url;
  final double size;
  const _DeliveryImage({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.surfaceSoft,
      alignment: Alignment.center,
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textMuted,
        size: size < 40 ? 20 : 28,
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: size,
        height: size,
        child: url.trim().isEmpty
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool strong;
  final bool outlined;
  const _DetailRow({
    required this.label,
    required this.value,
    this.color = AppColors.deliveryInk,
    this.strong = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: outlined
                    ? const EdgeInsets.symmetric(horizontal: 9, vertical: 2)
                    : EdgeInsets.zero,
                decoration: outlined
                    ? BoxDecoration(
                        border: Border.all(
                          color: AppColors.deliveryRed.withValues(alpha: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      )
                    : null,
                child: Text(
                  value.trim().isEmpty ? '\u2014' : value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: color,
                    fontSize: strong ? 15 : 13,
                    fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 32,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            const Text(
              'Delivery details could not load',
              style: TextStyle(
                color: AppColors.deliveryInk,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(String value) => value
    .split('_')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');

Color _statusColor(String status) => switch (status) {
  'delivered' => AppColors.deliveryGreen,
  'failed' || 'cancelled' || 'rejected' => AppColors.deliveryRed,
  _ => AppColors.primary,
};

String _formatDate(DateTime? value, {bool includeTime = false}) {
  if (value == null) return '\u2014';
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
  final date = '${value.day} ${months[value.month - 1]} ${value.year}';
  if (!includeTime) return date;
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  return '$date, $hour:${value.minute.toString().padLeft(2, '0')} ${value.hour >= 12 ? 'PM' : 'AM'}';
}

String _formatLooseDate(String value) {
  final date = DateTime.tryParse(value);
  return date == null ? value : _formatDate(date);
}

String _formatMoney(double value) {
  final parts = value.abs().toStringAsFixed(2).split('.');
  final chars = parts.first.split('').reversed.toList();
  final grouped = <String>[];
  for (var i = 0; i < chars.length; i++) {
    if (i == 3 || (i > 3 && (i - 3) % 2 == 0)) grouped.add(',');
    grouped.add(chars[i]);
  }
  return '${value < 0 ? '-' : ''}\u20b9 ${grouped.reversed.join()}.${parts.last}';
}

String _cleanError(Object? error) {
  return (error?.toString() ?? 'Unknown error')
      .replaceFirst('ApiException: ', '')
      .replaceFirst(RegExp(r'ApiException\(\d+\): '), '')
      .trim();
}
