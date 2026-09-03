import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/delivery_detail_model.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';

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
      backgroundColor: const Color(0xFFF8FAF9),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<DeliveryDetail>(
          future: _future,
          builder: (context, snapshot) {
            final delivery = snapshot.data ?? _delivery;
            return Column(
              children: [
                DeliveryTopBar(
                  title: 'Delivery Details',
                  leadingIcon: Icons.arrow_back_rounded,
                  onLeadingTap: () => Navigator.of(context).maybePop(),
                  showNotification: false,
                  showProfile: false,
                  actions: [
                    DeliveryTopBarAction(
                      icon: Icons.download_rounded,
                      tooltip: 'Delivery Challan',
                      onTap: delivery == null ? null : _downloadChallan,
                    ),
                    const DeliveryTopBarAction(
                      icon: Icons.more_vert_rounded,
                      tooltip: 'More',
                    ),
                  ],
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
                            onDownloadChallan: _downloadChallan,
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
  final VoidCallback onDownloadChallan;
  final VoidCallback? onConfirm;
  final VoidCallback? onFailed;

  const _Body({
    required this.delivery,
    required this.isActionBusy,
    required this.onDownloadChallan,
    required this.onConfirm,
    required this.onFailed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 760;
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    _SummaryHeader(
                      delivery: delivery,
                      onDownloadChallan: onDownloadChallan,
                    ),
                    const SizedBox(height: 10),
                    _ProgressCard(status: delivery.status),
                    const SizedBox(height: 10),
                    _TileGrid(delivery: delivery, wide: wide),
                    const SizedBox(height: 10),
                    _InfoCard(delivery: delivery, wide: wide),
                    const SizedBox(height: 10),
                    _ContactsCard(delivery: delivery, wide: wide),
                    const SizedBox(height: 10),
                    _ItemsCard(delivery: delivery),
                    if (delivery.podPhotos.isNotEmpty ||
                        delivery.signatureUrl.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _ProofCard(delivery: delivery),
                    ],
                    if (delivery.notes.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _NotesCard(notes: delivery.notes),
                    ],
                    const SizedBox(height: 10),
                    _ActionsCard(
                      isBusy: isActionBusy,
                      onConfirm: onConfirm,
                      onFailed: onFailed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final DeliveryDetail delivery;
  final VoidCallback onDownloadChallan;

  const _SummaryHeader({
    required this.delivery,
    required this.onDownloadChallan,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Wrap(
        runSpacing: 14,
        spacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 145,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Delivery #', style: _mutedStyle),
                const SizedBox(height: 3),
                Text(
                  delivery.deliveryNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deliveryInk,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(
            status: delivery.status,
            icon: Icons.local_shipping_outlined,
          ),
          if (delivery.partialDelivery)
            const _SoftBadge(
              label: 'Partial Delivery',
              icon: Icons.calendar_month_outlined,
              color: Color(0xFF0284C7),
            ),
          SizedBox(
            width: 190,
            child: OutlinedButton.icon(
              onPressed: onDownloadChallan,
              icon: const Icon(Icons.download_rounded),
              label: const Text('Delivery Challan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF075E19),
                side: const BorderSide(color: Color(0xFF075E19)),
                minimumSize: const Size.fromHeight(40),
                textStyle: const TextStyle(fontWeight: FontWeight.w900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 132,
            child: _HeaderField(label: 'Order #', value: delivery.orderNumber),
          ),
          SizedBox(
            width: 190,
            child: _HeaderField(
              label: 'Customer',
              value: delivery.customerName,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderField extends StatelessWidget {
  final String label;
  final String value;

  const _HeaderField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _mutedStyle),
        const SizedBox(height: 3),
        Text(
          value.isEmpty ? '-' : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w900,
            color: AppColors.deliveryInk,
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String status;

  const _ProgressCard({required this.status});

  static const _steps = [
    ('planned', 'Planned', Icons.check_rounded),
    ('accepted', 'Accepted', Icons.check_rounded),
    ('ready', 'Ready', Icons.check_rounded),
    ('loaded', 'Loaded', Icons.check_rounded),
    ('in_transit', 'In Transit', Icons.local_shipping_outlined),
    ('delivered', 'Delivered', Icons.check_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final activeIndex = _steps.indexWhere((step) => step.$1 == status);
    final failed =
        status == 'failed' || status == 'cancelled' || status == 'rejected';
    return _SectionCard(
      title: 'Delivery Progress',
      child: SizedBox(
        height: 70,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gap = constraints.maxWidth / _steps.length;
            return Stack(
              children: [
                Positioned(
                  left: gap / 2,
                  right: gap / 2,
                  top: 20,
                  child: Container(height: 2, color: const Color(0xFFD2D8E0)),
                ),
                if (!failed && activeIndex > 0)
                  Positioned(
                    left: gap / 2,
                    width: gap * activeIndex,
                    top: 20,
                    child: Container(height: 2, color: AppColors.deliveryGreen),
                  ),
                for (var i = 0; i < _steps.length; i++)
                  Positioned(
                    left: gap * i,
                    width: gap,
                    top: 0,
                    child: _ProgressStep(
                      label: _steps[i].$2,
                      icon: failed && i == activeIndex
                          ? Icons.close_rounded
                          : _steps[i].$3,
                      active: !failed && i == activeIndex,
                      done: !failed && activeIndex >= 0 && i < activeIndex,
                      failed: failed && i == activeIndex,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final bool done;
  final bool failed;

  const _ProgressStep({
    required this.label,
    required this.icon,
    required this.active,
    required this.done,
    required this.failed,
  });

  @override
  Widget build(BuildContext context) {
    final color = failed
        ? AppColors.deliveryRed
        : active
        ? const Color(0xFF2563EB)
        : done
        ? AppColors.deliveryGreen
        : const Color(0xFFCBD2DD);
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: active ? const Color(0xFF2563EB) : const Color(0xFF566174),
          ),
        ),
      ],
    );
  }
}

class _TileGrid extends StatelessWidget {
  final DeliveryDetail delivery;
  final bool wide;

  const _TileGrid({required this.delivery, required this.wide});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _MiniTile(
        Icons.receipt_long_outlined,
        const Color(0xFF16A34A),
        'Delivery Number',
        delivery.deliveryNumber,
      ),
      _MiniTile(
        Icons.calendar_month_outlined,
        const Color(0xFF2563EB),
        'Order Number',
        delivery.orderNumber,
      ),
      _MiniTile(
        Icons.person_outline_rounded,
        const Color(0xFF7C3AED),
        'Customer',
        delivery.customerName,
        delivery.customerPhone,
      ),
      _MiniTile(
        Icons.delivery_dining_rounded,
        const Color(0xFFF97316),
        'Delivery Partner',
        delivery.partnerName,
        delivery.partnerPhone,
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: wide ? 4 : 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 100,
      ),
      itemBuilder: (context, index) => tiles[index],
    );
  }
}

class _MiniTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String caption;

  const _MiniTile(
    this.icon,
    this.color,
    this.label,
    this.value, [
    this.caption = '',
  ]);

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: AppColors.deliveryInk,
            ),
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.deliveryInk,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final DeliveryDetail delivery;
  final bool wide;

  const _InfoCard({required this.delivery, required this.wide});

  @override
  Widget build(BuildContext context) {
    final left = [
      ('Vehicle', delivery.vehicleNumber),
      ('Vehicle Type', delivery.vehicleType),
      ('Capacity', delivery.capacity),
      ('Warehouse', delivery.warehouseName),
      ('Scheduled Date', _formatDateTime(delivery.scheduledDate)),
      ('Delivery Address', delivery.deliveryAddress),
    ];
    final right = [
      ('Dispatched At', _formatDateTime(delivery.dispatchedAt)),
      ('Confirmed At', _formatDateTime(delivery.confirmedAt)),
      (
        'Previous Pending Balance',
        _formatMoney(delivery.previousPendingBalance),
      ),
      ('Amount Due', _formatMoney(delivery.amountDue)),
      ('Failure Reason', delivery.failureReason),
    ];

    return _SectionCard(
      title: 'Delivery Information',
      icon: Icons.local_shipping_outlined,
      iconColor: const Color(0xFF2563EB),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _InfoColumn(rows: left)),
                Container(
                  width: 1,
                  height: 190,
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  color: const Color(0xFFE2E7F0),
                ),
                Expanded(child: _InfoColumn(rows: right)),
              ],
            )
          : Column(
              children: [
                _InfoColumn(rows: left),
                const Divider(height: 20),
                _InfoColumn(rows: right),
              ],
            ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final List<(String, String)> rows;

  const _InfoColumn({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 138, child: Text(row.$1, style: _mutedStyle)),
                Expanded(
                  child: Text(
                    row.$2.trim().isEmpty ? '-' : row.$2,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.deliveryInk,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ContactsCard extends StatelessWidget {
  final DeliveryDetail delivery;
  final bool wide;

  const _ContactsCard({required this.delivery, required this.wide});

  @override
  Widget build(BuildContext context) {
    final children = [
      _ContactBlock(
        title: 'Customer Contact',
        name: delivery.customerName,
        phone: delivery.customerPhone,
        email: delivery.customerEmail,
      ),
      _ContactBlock(
        title: 'Delivery Partner Contact',
        name: delivery.partnerName,
        phone: delivery.partnerPhone,
        email: delivery.partnerEmail,
      ),
    ];
    return _SectionCard(
      title: 'Contacts',
      icon: Icons.local_shipping_outlined,
      iconColor: AppColors.deliveryGreen,
      child: wide
          ? Row(
              children: [
                Expanded(child: children[0]),
                Container(
                  width: 1,
                  height: 82,
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  color: const Color(0xFFE2E7F0),
                ),
                Expanded(child: children[1]),
              ],
            )
          : Column(
              children: [children[0], const Divider(height: 22), children[1]],
            ),
    );
  }
}

class _ContactBlock extends StatelessWidget {
  final String title;
  final String name;
  final String phone;
  final String email;

  const _ContactBlock({
    required this.title,
    required this.name,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _mutedStyle),
        const SizedBox(height: 7),
        Text(
          name.isEmpty ? '-' : name,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.deliveryInk,
          ),
        ),
        const SizedBox(height: 7),
        _ContactLine(Icons.phone_outlined, phone),
        const SizedBox(height: 6),
        _ContactLine(Icons.email_outlined, email),
      ],
    );
  }
}

class _ContactLine extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ContactLine(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF566174)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.trim().isEmpty ? '-' : value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF475166),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final DeliveryDetail delivery;

  const _ItemsCard({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final totals = delivery.totals;
    return _SectionCard(
      title: 'Delivery Items',
      icon: Icons.shopping_bag_outlined,
      iconColor: AppColors.deliveryGreen,
      child: Column(
        children: [
          if (delivery.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'No delivery items found',
                style: TextStyle(
                  color: Color(0xFF566174),
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            for (final item in delivery.items) ...[
              _ItemRow(item: item),
              const SizedBox(height: 8),
            ],
          _TotalsRow(totals: totals),
        ],
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
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E7F0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 640;
          final details = Wrap(
            runSpacing: 10,
            spacing: 20,
            children: [
              _Qty(label: 'Planned', value: item.planned),
              _Qty(label: 'Picked', value: item.picked),
              _Qty(label: 'Loaded', value: item.loaded),
              _Qty(label: 'Delivered', value: item.delivered),
              _Qty(label: 'Pending', value: item.pending),
              _BatchInfo(batch: item.batch, expiry: item.expiry),
            ],
          );
          final main = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProductImage(url: item.imageUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deliveryInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.variant.isEmpty
                          ? 'Variant: -'
                          : 'Variant: ${item.variant}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.deliveryInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [main, const SizedBox(height: 12), details],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 260, child: main),
              Expanded(child: details),
            ],
          );
        },
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String url;

  const _ProductImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: const Color(0xFFF0F3F5),
      child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF6B7280)),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 62,
        height: 62,
        child: url.trim().isEmpty
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

class _Qty extends StatelessWidget {
  final String label;
  final int value;

  const _Qty({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _tinyMutedStyle),
          const SizedBox(height: 3),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.deliveryInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchInfo extends StatelessWidget {
  final String batch;
  final String expiry;

  const _BatchInfo({required this.batch, required this.expiry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Batch / Expiry', style: _tinyMutedStyle),
          const SizedBox(height: 5),
          Text(
            batch.isEmpty ? '-' : batch,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.deliveryInk,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _formatLooseDate(expiry),
            style: const TextStyle(color: AppColors.deliveryInk),
          ),
        ],
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  final DeliveryTotals totals;

  const _TotalsRow({required this.totals});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E7F0)),
      ),
      child: Wrap(
        spacing: 22,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const SizedBox(
            width: 112,
            child: Text(
              'Total Summary',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: AppColors.deliveryInk,
              ),
            ),
          ),
          _Qty(label: 'Planned', value: totals.planned),
          _Qty(label: 'Picked', value: totals.picked),
          _Qty(label: 'Loaded', value: totals.loaded),
          _Qty(label: 'Delivered', value: totals.delivered),
          _Qty(label: 'Pending', value: totals.pending),
        ],
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  final bool isBusy;
  final VoidCallback? onConfirm;
  final VoidCallback? onFailed;

  const _ActionsCard({
    required this.isBusy,
    required this.onConfirm,
    required this.onFailed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FCF5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDCEFE1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final text = const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF064E18),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Confirm the delivery and update the delivered items.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF064E18),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          );
          final buttons = Column(
            children: [
              FilledButton.icon(
                onPressed: isBusy ? null : onConfirm,
                icon: isBusy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: const Text('Confirm Delivery'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.deliveryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(40),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: isBusy ? null : onFailed,
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Mark as Failed'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.deliveryRed,
                  side: const BorderSide(color: AppColors.deliveryRed),
                  minimumSize: const Size.fromHeight(40),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [text, const SizedBox(height: 12), buttons],
            );
          }
          return Row(
            children: [
              Expanded(child: text),
              SizedBox(width: 320, child: buttons),
            ],
          );
        },
      ),
    );
  }
}

class _ProofCard extends StatelessWidget {
  final DeliveryDetail delivery;

  const _ProofCard({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Proof of Delivery',
      icon: Icons.verified_outlined,
      iconColor: AppColors.deliveryGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final url in delivery.podPhotos)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      color: const Color(0xFFF0F3F5),
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
            ],
          ),
          if (delivery.signatureUrl.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Signature: ${delivery.signatureUrl}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.deliveryInk,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final String notes;

  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Notes',
      icon: Icons.sticky_note_2_outlined,
      iconColor: const Color(0xFF2563EB),
      child: Text(
        notes,
        style: const TextStyle(
          height: 1.45,
          color: AppColors.deliveryInk,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData? icon;
  final Color iconColor;

  const _SectionCard({
    required this.title,
    required this.child,
    this.icon,
    this.iconColor = AppColors.deliveryGreen,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 9),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.deliveryInk,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E7F0)),
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
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final IconData icon;

  const _StatusBadge({required this.status, required this.icon});

  @override
  Widget build(BuildContext context) {
    return _SoftBadge(
      label: _statusLabel(status),
      icon: icon,
      color: _statusColor(status),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SoftBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
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
        padding: const EdgeInsets.all(16),
        child: _Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 30,
                color: AppColors.deliveryRed,
              ),
              const SizedBox(height: 10),
              const Text(
                'Delivery details could not load',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF566174)),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const TextStyle _mutedStyle = TextStyle(
  color: Color(0xFF566174),
  fontSize: 12,
  fontWeight: FontWeight.w700,
);
const TextStyle _tinyMutedStyle = TextStyle(
  color: Color(0xFF566174),
  fontSize: 11.5,
  fontWeight: FontWeight.w800,
);

String _statusLabel(String value) {
  if (value == 'in_transit') return 'In Transit';
  if (value == 'partially_delivered') return 'Partial Delivery';
  return value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

Color _statusColor(String status) {
  return switch (status) {
    'delivered' => AppColors.deliveryGreen,
    'failed' || 'cancelled' || 'rejected' => AppColors.deliveryRed,
    'in_transit' => const Color(0xFF2563EB),
    'partially_delivered' => const Color(0xFF0284C7),
    'loaded' => const Color(0xFF7C3AED),
    'ready' => const Color(0xFFF97316),
    _ => const Color(0xFF2563EB),
  };
}

String _formatDateTime(DateTime? value) {
  if (value == null) return '-';
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
  final hour = value.hour > 12
      ? value.hour - 12
      : value.hour == 0
      ? 12
      : value.hour;
  final minute = value.minute.toString().padLeft(2, '0');
  final period = value.hour >= 12 ? 'PM' : 'AM';
  return '${value.day} ${months[value.month - 1]} ${value.year}, $hour:$minute $period';
}

String _formatLooseDate(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value.trim().isEmpty ? '-' : value;
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
  return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
}

String _formatMoney(double value) {
  final rounded = value.round();
  final source = rounded.abs().toString();
  final chars = source.split('').reversed.toList();
  final grouped = <String>[];
  for (var i = 0; i < chars.length; i++) {
    if (i == 3 || (i > 3 && (i - 3) % 2 == 0)) grouped.add(',');
    grouped.add(chars[i]);
  }
  return '${rounded < 0 ? '-' : ''}Rs. ${grouped.reversed.join()}';
}

String _cleanError(Object? error) {
  return (error?.toString() ?? 'Unknown error')
      .replaceFirst('ApiException: ', '')
      .replaceFirst(RegExp(r'ApiException\(\d+\): '), '')
      .trim();
}
