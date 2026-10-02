import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../models/delivery_detail_model.dart';
import '../../../providers/api_provider.dart';
import '../../../utils/product_image_url.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';

class DeliveryDetailScreen extends StatefulWidget {
  final String deliveryId;

  const DeliveryDetailScreen({super.key, required this.deliveryId});

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _paidAmountController = TextEditingController();
  Future<DeliveryDetail>? _future;
  DeliveryDetail? _delivery;
  String _customerProfileImageUrl = '';
  Map<String, double> _productPrices = const {};
  String _paymentType = 'Cash';
  Uint8List? _deliveryConfirmation;
  Uint8List? _paymentConfirmation;
  bool _isActionBusy = false;
  final Map<String, int> _deliveryQuantities = {};

  @override
  void dispose() {
    _paidAmountController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future ??= _load();
  }

  Future<DeliveryDetail> _load() async {
    final provider = ApiProviderScope.of(context);
    final detail = await provider.fetchDeliveryById(widget.deliveryId);
    final customerProfileImageUrl = detail.customerProfileImageUrl.isNotEmpty
        ? detail.customerProfileImageUrl
        : await _resolveCustomerProfileImageUrl(provider, detail);
    final productPrices = await _resolveProductPrices(provider, detail);
    if (mounted) {
      setState(() {
        _delivery = detail;
        _customerProfileImageUrl = customerProfileImageUrl;
        _productPrices = productPrices;
        for (final item in detail.items) {
          _deliveryQuantities.putIfAbsent(item.id, () => item.delivered);
        }
      });
    }
    return detail;
  }

  Future<Map<String, double>> _resolveProductPrices(
    ApiProvider provider,
    DeliveryDetail detail,
  ) async {
    if (detail.items.isEmpty) return const {};

    final List<Map<String, dynamic>> products;
    try {
      products = await provider.fetchProducts();
    } catch (_) {
      return const {};
    }

    final prices = <String, double>{};
    for (final product in products) {
      final nestedProduct = _readMap(product, const ['product']);
      final source = nestedProduct.isEmpty
          ? product
          : <String, dynamic>{...product, ...nestedProduct};
      final price = _productApiPrice(source);
      if (price <= 0) continue;

      final id = _readString(source, const ['id', '_id', 'product_id']);
      final name = _readString(source, const [
        'name',
        'product_name',
        'title',
      ]).toLowerCase();
      if (id.isNotEmpty) prices['id:$id'] = price;
      if (name.isNotEmpty) prices['name:$name'] = price;
    }

    return {
      for (final item in detail.items)
        if (_priceForDeliveryItem(item, prices) != null)
          item.id: _priceForDeliveryItem(item, prices)!,
    };
  }

  Future<String> _resolveCustomerProfileImageUrl(
    ApiProvider provider,
    DeliveryDetail detail,
  ) async {
    final orderNumber = detail.orderNumber.trim();
    if (orderNumber.isEmpty) return '';

    final List<Map<String, dynamic>> orders;
    try {
      orders = await provider.fetchOrders(search: orderNumber);
    } catch (_) {
      return '';
    }
    for (final order in orders) {
      final orderMap = _readMap(order, const [
        'order',
        'order_details',
        'orderDetails',
      ]);
      final source = orderMap.isEmpty
          ? order
          : <String, dynamic>{...order, ...orderMap};
      final foundOrderNumber = _readString(source, const [
        'order_number',
        'orderNumber',
        'orderNo',
        'number',
        'sales_order_number',
      ]);
      if (foundOrderNumber != orderNumber) continue;

      final customer = _readMap(source, const [
        'customer',
        'customer_details',
        'customerDetails',
      ]);
      final photoUrl = _customerPhotoUrlFromMaps(source, customer);
      if (photoUrl.isNotEmpty) return photoUrl;
    }
    return '';
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

  Future<void> _runPrimaryAction() async {
    final delivery = _delivery;
    if (delivery == null || _isActionBusy) return;
    switch (delivery.status) {
      case 'pending':
      case 'planned':
      case 'assigned':
        await _runStatusAction(
          title: 'Accept Delivery',
          message: 'Accept this delivery assignment?',
          action: (provider) => provider.acceptDelivery(delivery.id),
          successMessage: 'Delivery accepted.',
        );
        return;
      case 'accepted':
        await _runStatusAction(
          title: 'Ready for Delivery',
          message: 'Confirm that the items are picked and ready for delivery?',
          action: (provider) async {
            final remaining = delivery.items
                .where((item) => item.planned > item.picked)
                .toList();
            if (remaining.isNotEmpty) {
              await provider.pickDelivery(
                deliveryId: delivery.id,
                items: [
                  for (final item in remaining)
                    {
                      'delivery_item_id': item.id,
                      'picked_quantity': item.planned - item.picked,
                    },
                ],
              );
            }
            return provider.markDeliveryReady(delivery.id);
          },
          successMessage: 'Delivery is ready.',
        );
        return;
      case 'ready':
        await _runStatusAction(
          title: 'Load Delivery',
          message: 'Confirm that all items are loaded in the vehicle?',
          action: (provider) => provider.loadDelivery(delivery.id),
          successMessage: 'Delivery loaded.',
        );
        return;
      case 'loaded':
        await _runStatusAction(
          title: 'Start Delivery',
          message: 'Start this delivery and mark it in transit?',
          action: (provider) => provider.dispatchDelivery(delivery.id),
          successMessage: 'Delivery is now in transit.',
        );
        return;
    }
    if (delivery.status != 'in_transit') return;
    if (delivery.items.isEmpty ||
        delivery.items.any((item) => item.id.isEmpty) ||
        !delivery.items.any((item) => item.loaded > 0)) {
      _showSnack(
        'This delivery has no loaded items to confirm.',
        isError: true,
      );
      return;
    }
    if (_deliveryConfirmation == null || _paymentConfirmation == null) {
      _showSnack(
        'Add delivery and payment confirmation images first.',
        isError: true,
      );
      return;
    }
    final ok = await _confirmDialog(
      title: 'Confirm Delivery',
      message: 'Confirm this delivery and update delivered item quantities?',
    );
    if (ok != true) return;

    await _submitDeliveryAction(
      delivery,
      payload: {
        'payment_type': _paymentType,
        'paid_amount': double.tryParse(_paidAmountController.text.trim()) ?? 0,
        'delivery_confirmation': base64Encode(_deliveryConfirmation!),
        'payment_confirmation': base64Encode(_paymentConfirmation!),
        'items': [
          for (final item in delivery.items)
            {
              'delivery_item_id': item.id,
              'delivered_quantity':
                  _deliveryQuantities[item.id] ?? item.delivered,
            },
        ],
      },
      successMessage: 'Delivery confirmed.',
    );
  }

  Future<void> _runStatusAction({
    required String title,
    required String message,
    required Future<Map<String, dynamic>> Function(ApiProvider provider) action,
    required String successMessage,
  }) async {
    final delivery = _delivery;
    if (delivery == null) return;
    if (await _confirmDialog(title: title, message: message) != true) return;
    setState(() => _isActionBusy = true);
    try {
      await action(ApiProviderScope.of(context));
      if (!mounted) return;
      await _refresh();
      _showSnack(successMessage);
    } catch (error) {
      _showSnack(_cleanError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isActionBusy = false);
    }
  }

  Future<void> _pickConfirmation({required bool deliveryProof}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add confirmation image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from files'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    if (source == ImageSource.camera) {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        _showSnack(
          'Camera permission is required to take a photo.',
          isError: true,
        );
        return;
      }
    }
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        if (deliveryProof) {
          _deliveryConfirmation = bytes;
        } else {
          _paymentConfirmation = bytes;
        }
      });
    } catch (error) {
      _showSnack('Could not add image: ${_cleanError(error)}', isError: true);
    }
  }

  Future<void> _markFailed() async {
    final delivery = _delivery;
    if (delivery == null || _isActionBusy) return;
    final reason = await _failureReasonDialog();
    if (reason == null || reason.trim().isEmpty) return;

    await _submitDeliveryAction(
      delivery,
      payload: {
        'failed': true,
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
      backgroundColor: const Color(0xFFF7FAF8),
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
                  subtitle: delivery?.orderNumber ?? 'View delivery status',
                  leadingIcon: Icons.arrow_back_rounded,
                  onLeadingTap: () => Navigator.of(context).maybePop(),
                  actions: [
                    DeliveryTopBarAction(
                      icon: Icons.download_outlined,
                      tooltip: 'Download delivery challan',
                      onTap: delivery == null || _isActionBusy
                          ? null
                          : _downloadChallan,
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
                            customerProfileImageUrl: _customerProfileImageUrl,
                            isActionBusy: _isActionBusy,
                            paymentType: _paymentType,
                            paidAmountController: _paidAmountController,
                            deliveryConfirmation: _deliveryConfirmation,
                            paymentConfirmation: _paymentConfirmation,
                            deliveryQuantities: _deliveryQuantities,
                            productPrices: _productPrices,
                            onDeliveryQuantityChanged: (itemId, quantity) {
                              setState(
                                () => _deliveryQuantities[itemId] = quantity,
                              );
                            },
                            onPaymentTypeChanged: (value) =>
                                setState(() => _paymentType = value),
                            onPickDeliveryConfirmation: () =>
                                _pickConfirmation(deliveryProof: true),
                            onPickPaymentConfirmation: () =>
                                _pickConfirmation(deliveryProof: false),
                            onConfirm: _hasPrimaryAction(delivery.status)
                                ? _runPrimaryAction
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
  final String customerProfileImageUrl;
  final bool isActionBusy;
  final String paymentType;
  final TextEditingController paidAmountController;
  final Uint8List? deliveryConfirmation;
  final Uint8List? paymentConfirmation;
  final Map<String, int> deliveryQuantities;
  final Map<String, double> productPrices;
  final void Function(String itemId, int quantity) onDeliveryQuantityChanged;
  final ValueChanged<String> onPaymentTypeChanged;
  final VoidCallback onPickDeliveryConfirmation;
  final VoidCallback onPickPaymentConfirmation;
  final VoidCallback? onConfirm;
  final VoidCallback? onFailed;

  const _Body({
    required this.delivery,
    required this.customerProfileImageUrl,
    required this.isActionBusy,
    required this.paymentType,
    required this.paidAmountController,
    required this.deliveryConfirmation,
    required this.paymentConfirmation,
    required this.deliveryQuantities,
    required this.productPrices,
    required this.onDeliveryQuantityChanged,
    required this.onPaymentTypeChanged,
    required this.onPickDeliveryConfirmation,
    required this.onPickPaymentConfirmation,
    required this.onConfirm,
    required this.onFailed,
  });

  @override
  Widget build(BuildContext context) {
    final orderAmount = delivery.items.fold<double>(0, (total, item) {
      final quantity = deliveryQuantities[item.id] ?? item.delivered;
      return total + (_itemUnitPrice(item, productPrices[item.id]) * quantity);
    });

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.textScalerOf(
          context,
        ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2),
      ),
      child: ListView(
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
                  fontSize: 14,
                  height: 1.35,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: _cardDecoration(),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _CustomerAvatar(
                                imageUrl: customerProfileImageUrl.isEmpty
                                    ? delivery.customerProfileImageUrl
                                    : customerProfileImageUrl,
                                radius: 28,
                                backgroundColor: AppColors.deliveryBlueSoft,
                                foregroundColor: AppColors.deliveryInk,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      delivery.customerName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      delivery.customerContactName.isNotEmpty
                                          ? delivery.customerContactName
                                          : delivery.customerPhone,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                borderRadius: BorderRadius.circular(9),
                                onTap: delivery.orderNumber.trim().isEmpty
                                    ? null
                                    : () async {
                                        await Clipboard.setData(
                                          ClipboardData(
                                            text: delivery.orderNumber,
                                          ),
                                        );
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(
                                            const SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: Text('Order ID copied.'),
                                            ),
                                          );
                                      },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE1F6EA),
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Order Id',
                                        style: TextStyle(
                                          color: Color(0xFF356B4B),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            delivery.orderNumber,
                                            style: const TextStyle(
                                              color: Color(0xFF123D28),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.copy_outlined,
                                            size: 16,
                                            color: AppColors.deliveryGreen,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (delivery.customerPhone.isNotEmpty)
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => _launchPhone(
                                    context,
                                    delivery.customerPhone,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.phone_rounded,
                                          size: 17,
                                          color: AppColors.deliveryGreen,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          delivery.customerPhone,
                                          style: const TextStyle(
                                            color: Color(0xFF40536A),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (delivery.customerPhone.isNotEmpty &&
                                  delivery.deliveryAddress.isNotEmpty)
                                const SizedBox(width: 12),
                              if (delivery.deliveryAddress.isNotEmpty)
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => _launchMap(
                                      context,
                                      delivery.deliveryAddress,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          const Icon(
                                            Icons.location_on_rounded,
                                            size: 18,
                                            color: AppColors.deliveryGreen,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              delivery.deliveryAddress,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                color: Color(0xFF40536A),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      decoration: _cardDecoration(),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primary,
                                  child: Icon(
                                    Icons.inventory_2_rounded,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Delivery Summary',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
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
                            planned: Text('Order Quantity'),
                            delivered: Text('Delivery Quantity'),
                            pending: Text('Amount'),
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
                          for (final item in delivery.items)
                            _ItemRow(
                              item: item,
                              unitPrice: _itemUnitPrice(
                                item,
                                productPrices[item.id],
                              ),
                              quantity:
                                  deliveryQuantities[item.id] ?? item.delivered,
                              onQuantityChanged: (quantity) =>
                                  onDeliveryQuantityChanged(item.id, quantity),
                            ),
                          const SizedBox(height: 8),
                          _AmountStrip(
                            label: 'Previous Balance',
                            value: _formatMoney(
                              delivery.previousPendingBalance,
                            ),
                            strong: false,
                          ),
                          const SizedBox(height: 4),
                          _AmountStrip(
                            label: 'Order Amount',
                            value: _formatMoney(orderAmount),
                            strong: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecoration(),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.deliveryGreen,
                                child: Icon(
                                  Icons.local_shipping_rounded,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                              const SizedBox(width: 9),
                              const Expanded(
                                child: Text(
                                  'Delivery Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              _StatusPill(status: delivery.status),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _DetailRow(
                            label: 'Delivery Id',
                            value: delivery.deliveryNumber,
                            icon: Icons.description_outlined,
                          ),
                          if (delivery.partialDelivery)
                            const _DetailRow(
                              label: 'Delivery Type',
                              value: 'Partial Delivery',
                              icon: Icons.call_split_rounded,
                            ),
                          _DetailRow(
                            label: 'Delivery Date',
                            value: _formatDate(delivery.scheduledDate),
                            icon: Icons.calendar_month_outlined,
                          ),
                          _DetailRow(
                            label: 'Warehouse',
                            value: delivery.warehouseName,
                            icon: Icons.warehouse_outlined,
                          ),
                          _DetailRow(
                            label: 'Delivery By',
                            value: delivery.partnerName,
                            icon: Icons.person_outline_rounded,
                          ),
                          if (delivery.partnerPhone.isNotEmpty)
                            _DetailRow(
                              label: 'Partner Phone',
                              value: delivery.partnerPhone,
                              icon: Icons.phone_outlined,
                            ),
                          if (delivery.vehicleNumber.isNotEmpty)
                            _DetailRow(
                              label: 'Vehicle',
                              value: delivery.vehicleNumber,
                              icon: Icons.local_shipping_outlined,
                            ),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECF8F2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              childrenPadding: EdgeInsets.zero,
                              shape: const Border(),
                              collapsedShape: const Border(),
                              iconColor: AppColors.primary,
                              collapsedIconColor: AppColors.primary,
                              title: const Text(
                                'More delivery details',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              leading: const Icon(
                                Icons.list_alt_rounded,
                                size: 20,
                                color: AppColors.deliveryGreen,
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
                                _DetailRow(
                                  label: 'Capacity',
                                  value: delivery.capacity,
                                ),
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
                        ],
                      ),
                    ),
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
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                        _DeliveryImage(url: delivery.signatureUrl, size: 120),
                      ],
                    ],
                    if (delivery.status == 'in_transit') ...[
                      const SizedBox(height: 14),
                      _PaymentConfirmationCard(
                        subtotal: orderAmount,
                        previousBalance: delivery.previousPendingBalance,
                        itemCount: delivery.items.length,
                        deliveryDate: delivery.scheduledDate,
                        paymentType: paymentType,
                        paidAmountController: paidAmountController,
                        deliveryConfirmation: deliveryConfirmation,
                        paymentConfirmation: paymentConfirmation,
                        onPaymentTypeChanged: onPaymentTypeChanged,
                        onPickDeliveryConfirmation: onPickDeliveryConfirmation,
                        onPickPaymentConfirmation: onPickPaymentConfirmation,
                      ),
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
                      label: Text(_primaryActionLabel(delivery.status)),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}

class _PaymentConfirmationCard extends StatelessWidget {
  final double subtotal;
  final double previousBalance;
  final int itemCount;
  final DateTime? deliveryDate;
  final String paymentType;
  final TextEditingController paidAmountController;
  final Uint8List? deliveryConfirmation;
  final Uint8List? paymentConfirmation;
  final ValueChanged<String> onPaymentTypeChanged;
  final VoidCallback onPickDeliveryConfirmation;
  final VoidCallback onPickPaymentConfirmation;

  const _PaymentConfirmationCard({
    required this.subtotal,
    required this.previousBalance,
    required this.itemCount,
    required this.deliveryDate,
    required this.paymentType,
    required this.paidAmountController,
    required this.deliveryConfirmation,
    required this.paymentConfirmation,
    required this.onPaymentTypeChanged,
    required this.onPickDeliveryConfirmation,
    required this.onPickPaymentConfirmation,
  });

  @override
  Widget build(BuildContext context) {
    final grandTotal = subtotal + previousBalance;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 17,
                  color: Color(0xFF246936),
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'Billing Summary',
                    style: TextStyle(
                      color: Color(0xFF174F28),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    color: Color(0xFF24713A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _BillingRow(
            icon: Icons.sell_outlined,
            label: 'Subtotal',
            value: _formatMoney(subtotal),
          ),
          const _BillingRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Tax',
            value: '+ ₹ 0.00',
          ),
          const _BillingRow(
            icon: Icons.percent_rounded,
            label: 'Discount',
            value: '− ₹ 0.00',
            valueColor: Color(0xFF21854A),
          ),
          const Divider(height: 8, color: AppColors.border),
          _BillingRow(
            icon: Icons.payments_outlined,
            label: 'Total',
            value: _formatMoney(subtotal),
            strong: true,
          ),
          _BillingRow(
            icon: Icons.receipt_outlined,
            label: 'Previous Balance',
            value: '+ ${_formatMoney(previousBalance)}',
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEAF5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _BillingRow(
              icon: Icons.shopping_bag_outlined,
              label: 'Grand Total',
              value: _formatMoney(grandTotal),
              valueColor: const Color(0xFF19652D),
              strong: true,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.money_outlined,
                  size: 18,
                  color: Color(0xFF246936),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Paid Amount',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  width: 120,
                  height: 34,
                  child: TextField(
                    controller: paidAmountController,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      hintText: '0.00',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: paidAmountController,
            builder: (context, value, _) {
              final paid = double.tryParse(value.text.trim()) ?? 0;
              final balance = (grandTotal - paid).clamp(0, double.infinity);
              return _BillingRow(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Balance',
                value: _formatMoney(balance.toDouble()),
                labelColor: AppColors.deliveryRed,
                valueColor: AppColors.deliveryRed,
                strong: true,
              );
            },
          ),
          const Divider(height: 20, color: AppColors.border),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Payment Type',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                width: 150,
                height: 40,
                child: DropdownButtonFormField<String>(
                  initialValue: paymentType,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'PhonePe', child: Text('Phone Pe')),
                    DropdownMenuItem(
                      value: 'Google Pay',
                      child: Text('Google Pay'),
                    ),
                    DropdownMenuItem(
                      value: 'Bank Transfer',
                      child: Text('Bank Transfer'),
                    ),
                    DropdownMenuItem(value: 'Card', child: Text('Card')),
                  ],
                  onChanged: (value) {
                    if (value != null) onPaymentTypeChanged(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ConfirmationImageBox(
                  label: 'Delivery Confirmation',
                  bytes: deliveryConfirmation,
                  onTap: onPickDeliveryConfirmation,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ConfirmationImageBox(
                  label: 'Payment Confirmation',
                  bytes: paymentConfirmation,
                  onTap: onPickPaymentConfirmation,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.border),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Delivery Date',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                _formatDate(deliveryDate),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;
  final bool strong;

  const _BillingRow({
    required this.icon,
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F7ED),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14, color: const Color(0xFF357343)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: labelColor ?? AppColors.deliveryInk,
                fontSize: 12,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.deliveryInk,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountStrip extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _AmountStrip({
    required this.label,
    required this.value,
    required this.strong,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: strong ? const Color(0xFFFFEEF0) : const Color(0xFFFFF5F6),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFFF4358),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '₹',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: strong ? AppColors.deliveryRed : const Color(0xFF31536B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: strong
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 5)
                : EdgeInsets.zero,
            decoration: strong
                ? BoxDecoration(
                    color: const Color(0xFFFFE4E8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFD2D8)),
                  )
                : null,
            child: Text(
              value,
              style: TextStyle(
                color: strong ? AppColors.deliveryRed : const Color(0xFF213B50),
                fontSize: strong ? 14 : 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 15, color: color),
          const SizedBox(width: 4),
          Text(
            _statusLabel(status),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationImageBox extends StatelessWidget {
  final String label;
  final Uint8List? bytes;
  final VoidCallback onTap;

  const _ConfirmationImageBox({
    required this.label,
    required this.bytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1.2,
          child: Material(
            color: AppColors.deliveryCardSoft,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.borderStrong),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: bytes == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 28,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Camera or file',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(bytes!, fit: BoxFit.cover),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
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

class _SectionIcon extends StatelessWidget {
  final IconData icon;
  const _SectionIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.deliveryGreenSoft,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: AppColors.deliveryGreen),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: AppColors.deliveryCardBorder),
  boxShadow: const [
    BoxShadow(color: Color(0x12063B00), blurRadius: 12, offset: Offset(0, 4)),
  ],
);

InputDecoration _inputDecoration(String label) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  filled: true,
  fillColor: AppColors.deliveryCardSoft,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
  ),
);

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
  final double unitPrice;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const _ItemRow({
    required this.item,
    required this.unitPrice,
    required this.quantity,
    required this.onQuantityChanged,
  });

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
                _DeliveryImage(url: item.imageUrl, size: 48, fit: BoxFit.cover),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName),
                      if (unitPrice > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatMoney(unitPrice),
                          style: const TextStyle(
                            color: AppColors.deliveryInk,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      if (item.variant.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          item.variant,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
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
            delivered: _QuantityStepper(
              value: quantity,
              onChanged: onQuantityChanged,
            ),
            pending: Text(
              _formatMoney(unitPrice * quantity),
              style: const TextStyle(color: AppColors.deliveryRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _QuantityButton(
          icon: Icons.remove_rounded,
          enabled: value > 0,
          onTap: () => onChanged(value - 1),
        ),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border.symmetric(
              horizontal: BorderSide(color: AppColors.borderStrong),
            ),
          ),
          child: Text('$value'),
        ),
        _QuantityButton(
          icon: Icons.add_rounded,
          enabled: true,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 16,
        visualDensity: VisualDensity.compact,
        onPressed: enabled ? onTap : null,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.borderStrong),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _DeliveryImage extends StatelessWidget {
  final String url;
  final double size;
  final BoxFit fit;
  const _DeliveryImage({
    required this.url,
    required this.size,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: AppColors.textMuted,
          size: size < 40 ? 20 : 28,
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child: url.trim().isEmpty
            ? placeholder
            : Image.network(
                url,
                fit: fit,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Color backgroundColor;
  final Color foregroundColor;

  const _CustomerAvatar({
    required this.imageUrl,
    required this.radius,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    final size = radius * 2;
    final fallback = Icon(
      Icons.storefront_outlined,
      color: foregroundColor,
      size: radius + 2,
    );

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: url.isEmpty
          ? fallback
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, error, stackTrace) => fallback,
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color color;
  final bool strong;
  final bool outlined;
  const _DetailRow({
    required this.label,
    required this.value,
    this.icon,
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
          if (icon != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F5F7),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 16, color: const Color(0xFF35566B)),
            ),
            const SizedBox(width: 8),
          ],
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

bool _hasPrimaryAction(String status) => const {
  'pending',
  'planned',
  'assigned',
  'accepted',
  'ready',
  'loaded',
  'in_transit',
}.contains(status);

String _primaryActionLabel(String status) => switch (status) {
  'pending' || 'planned' || 'assigned' => 'Accept Delivery',
  'accepted' => 'Ready for Delivery',
  'ready' => 'Load Delivery',
  'loaded' => 'Start Delivery',
  'in_transit' => 'Complete Order',
  'delivered' || 'completed' => 'Order Completed',
  _ => 'No Action Available',
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

double _itemUnitPrice(DeliveryDetailItem item, [double? productApiPrice]) {
  if (productApiPrice != null && productApiPrice > 0) return productApiPrice;
  if (item.unitPrice > 0) return item.unitPrice;
  return item.planned > 0 ? item.amount / item.planned : 0;
}

double? _priceForDeliveryItem(
  DeliveryDetailItem item,
  Map<String, double> productPrices,
) {
  final byId = productPrices['id:${item.productId}'];
  if (byId != null) return byId;
  return productPrices['name:${item.productName.trim().toLowerCase()}'];
}

double _productApiPrice(Map<String, dynamic> product) {
  double readPrice(Map<String, dynamic> source) {
    for (final key in const [
      'selling_price',
      'sellingPrice',
      'mrp',
      'price',
      'unit_price',
      'unitPrice',
    ]) {
      final price = double.tryParse(source[key]?.toString() ?? '');
      if (price != null && price.isFinite && price > 0) return price;
    }
    return 0;
  }

  final rootPrice = readPrice(product);
  if (rootPrice > 0) return rootPrice;

  final pricing = _readMap(product, const ['pricing']);
  final pricingPrice = readPrice(pricing);
  if (pricingPrice > 0) return pricingPrice;

  final variations = product['variations'];
  if (variations is List) {
    for (final variation in variations) {
      if (variation is Map) {
        final variationPrice = readPrice(Map<String, dynamic>.from(variation));
        if (variationPrice > 0) return variationPrice;
      }
    }
  }
  return 0;
}

Future<void> _launchPhone(BuildContext context, String phone) async {
  final normalized = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  final uri = Uri(scheme: 'tel', path: normalized);
  if (normalized.isEmpty || !await launchUrl(uri)) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the phone app.')),
    );
  }
}

Future<void> _launchMap(BuildContext context, String address) async {
  final uri = Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': address,
  });
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open Google Maps.')),
    );
  }
}

Map<String, dynamic> _readMap(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return const {};
}

String _readString(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
  }
  return '';
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    final text = value.trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

String _customerPhotoUrlFromMaps(
  Map<String, dynamic> source,
  Map<String, dynamic> customer,
) {
  return normalizeProductImageUrl(
        _firstNonEmpty([
          _readString(customer, const [
            'profile_photo',
            'profilePhoto',
            'profile_image_url',
            'profileImageUrl',
            'profile_image_id',
            'profileImageId',
            'avatar',
            'image',
          ]),
          _readString(source, const [
            'customer_profile_photo',
            'customerProfilePhoto',
            'customer_profile_image_url',
            'customerProfileImageUrl',
            'profile_photo',
            'profilePhoto',
            'profile_image_url',
            'profileImageUrl',
            'profile_image_id',
            'profileImageId',
          ]),
        ]),
      ) ??
      '';
}

String _cleanError(Object? error) {
  return (error?.toString() ?? 'Unknown error')
      .replaceFirst('ApiException: ', '')
      .replaceFirst(RegExp(r'ApiException\(\d+\): '), '')
      .trim();
}
