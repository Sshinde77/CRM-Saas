import 'package:flutter/material.dart';

import '../../../widgets/delivery/delivery_bottom_navigation.dart';

import '../../../constants/api_constants.dart';
import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/delivery/delivery_partner_sidebar.dart';
import '../../payment_collection_screen.dart';

class DeliveryCollectionListScreen extends StatefulWidget {
  const DeliveryCollectionListScreen({super.key});

  @override
  State<DeliveryCollectionListScreen> createState() =>
      _DeliveryCollectionListScreenState();
}

class _DeliveryCollectionListScreenState
    extends State<DeliveryCollectionListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<_CollectionDashboardData> _collectionFuture;
  bool _didStartLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _collectionFuture = _loadCollections();
      _didStartLoad = true;
    }
  }

  Future<_CollectionDashboardData> _loadCollections() async {
    final provider = ApiProviderScope.of(context);
    final authMe = await provider.fetchAuthMe();
    final currentUser = provider.currentUser ?? authMe?.user;
    final deliveryPartnerId = currentUser?.id?.trim();

    if (deliveryPartnerId == null || deliveryPartnerId.isEmpty) {
      throw const _CollectionException('Delivery partner id is missing.');
    }

    final deliveries = await provider.fetchDeliveryPartnerDeliveries(
      deliveryPartnerId: deliveryPartnerId,
    );

    return _CollectionDashboardData(
      deliveries: deliveries.map(_CollectionDelivery.fromJson).toList(),
    );
  }

  Future<void> _refresh() async {
    final nextFuture = _loadCollections();
    setState(() => _collectionFuture = nextFuture);
    await nextFuture;
  }

  Future<void> _openPaymentCollection() async {
    final provider = ApiProviderScope.of(context);
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentCollectionScreen(
          customersUrl: '${ApiConstants.baseUrl}${ApiEndpoints.customersList}',
          collectPaymentUrl:
              '${ApiConstants.baseUrl}${ApiEndpoints.customersPaymentsTemplate}',
          authToken: provider.session?.accessToken,
        ),
      ),
    );

    if (result == true && mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.deliveryBackground,
        drawer: const DeliveryPartnerSidebar(
          currentRoute: AppRoutes.deliveryCollections,
        ),
        appBar: AppBar(
          toolbarHeight: kToolbarHeight,
          elevation: 0,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          foregroundColor: AppColors.deliveryInk,
          leading: IconButton(
            icon: const Icon(Icons.menu_rounded, size: 24),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: const Text(
            'Collections',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.deliveryInk,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 24),
              onPressed: _refresh,
            ),
          ],
        ),
        bottomNavigationBar: DeliveryBottomNavigation(
          currentIndex: 4,
          onCollectionCreated: _refresh,
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'delivery-collection-create',
          onPressed: _openPaymentCollection,
          backgroundColor: AppColors.deliveryBlue,
          foregroundColor: AppColors.surface,
          icon: const Icon(Icons.add_card_rounded, size: 22),
          label: const Text(
            'Create Collection',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          bottom: false,
          child: FutureBuilder<_CollectionDashboardData>(
            future: _collectionFuture,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData;
              final data = snapshot.data;

              return RefreshIndicator(
                color: AppColors.deliveryGreen,
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenSmall,
                    AppSpacing.md,
                    AppSpacing.screenSmall,
                    AppSpacing.xl + 92,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: isLoading
                            ? const _LoadingPanel()
                            : snapshot.hasError
                            ? _ErrorPanel(
                                message: snapshot.error.toString(),
                                onRetry: () {
                                  setState(() {
                                    _collectionFuture = _loadCollections();
                                  });
                                },
                              )
                            : _CollectionContent(
                                data:
                                    data ??
                                    const _CollectionDashboardData(
                                      deliveries: [],
                                    ),
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CollectionContent extends StatelessWidget {
  const _CollectionContent({required this.data});

  final _CollectionDashboardData data;

  @override
  Widget build(BuildContext context) {
    final collectionRows = data.collectionRows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CollectionsCard(data: data),
        const SizedBox(height: AppSpacing.md),
        const _SectionHeader(
          title: 'Collection List',
          trailingIcon: Icons.receipt_long_outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (collectionRows.isEmpty)
          const _EmptyCollectionList()
        else
          ...collectionRows.map(
            (delivery) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CollectionListTile(delivery: delivery),
            ),
          ),
      ],
    );
  }
}

class _CollectionsCard extends StatelessWidget {
  const _CollectionsCard({required this.data});

  final _CollectionDashboardData data;

  @override
  Widget build(BuildContext context) {
    final rows = [
      _CollectionInfo(
        icon: Icons.payments_outlined,
        label: 'Collected',
        value: data.formattedTotalCollected,
        color: AppColors.deliveryGreen,
        background: AppColors.deliveryGreenSoft,
      ),
      _CollectionInfo(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Cash in Hand',
        value: data.formattedCashInHand,
        color: AppColors.deliveryOrange,
        background: AppColors.deliveryOrangeSoft,
      ),
      _CollectionInfo(
        icon: Icons.account_balance_outlined,
        label: 'Bank Transfer',
        value: data.formattedBankTransfer,
        color: AppColors.deliveryBlue,
        background: AppColors.deliveryBlueSoft,
      ),
      _CollectionInfo(
        icon: Icons.pending_actions_outlined,
        label: 'Pending Amount',
        value: data.formattedPendingAmount,
        color: AppColors.deliveryRed,
        background: AppColors.deliveryRedSoft,
      ),
    ];

    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: 'Collection',
            trailingIcon: Icons.receipt_long_outlined,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.deliveryVioletSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.deliveryViolet.withValues(alpha: 0.14),
              ),
            ),
            child: Row(
              children: [
                const _MiniIcon(
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.deliveryViolet,
                  background: AppColors.surface,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount to Collect',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data.formattedTotalToCollect,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deliveryInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return _CollectionMetricTile(info: rows[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _CollectionMetricTile extends StatelessWidget {
  const _CollectionMetricTile({required this.info});

  final _CollectionInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: info.background,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: info.color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          _MiniIcon(
            icon: info.icon,
            color: info.color,
            background: AppColors.surface,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  info.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deliveryInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionListTile extends StatelessWidget {
  const _CollectionListTile({required this.delivery});

  final _CollectionDelivery delivery;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniIcon(
            icon: delivery.amountDue > 0
                ? Icons.pending_actions_outlined
                : Icons.check_circle_outline_rounded,
            color: delivery.amountDue > 0
                ? AppColors.deliveryRed
                : AppColors.deliveryGreen,
            background: delivery.amountDue > 0
                ? AppColors.deliveryRedSoft
                : AppColors.deliveryGreenSoft,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        delivery.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.deliveryInk,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      delivery.formattedDue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: delivery.amountDue > 0
                            ? AppColors.deliveryRed
                            : AppColors.deliveryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${delivery.orderNumber} â€¢ ${delivery.statusLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SmallAmountPill(
                        label: 'Collected',
                        value: delivery.formattedCollected,
                        color: AppColors.deliveryGreen,
                        background: AppColors.deliveryGreenSoft,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SmallAmountPill(
                        label: 'Mode',
                        value: delivery.paymentModeLabel,
                        color: AppColors.deliveryBlue,
                        background: AppColors.deliveryBlueSoft,
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
}

class _SmallAmountPill extends StatelessWidget {
  const _SmallAmountPill({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final String label;
  final String value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCollectionList extends StatelessWidget {
  const _EmptyCollectionList();

  @override
  Widget build(BuildContext context) {
    return const _SurfaceCard(
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.deliveryBlue,
          ),
          SizedBox(height: 12),
          Text(
            'No collections found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.deliveryInk,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Collected and pending customer payments will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailingIcon});

  final String title;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.deliveryInk,
          ),
        ),
        const Spacer(),
        if (trailingIcon != null)
          Icon(trailingIcon, size: 18, color: AppColors.deliveryBlue),
      ],
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.card),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MiniIcon extends StatelessWidget {
  const _MiniIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.buttonHeightCompact,
      height: AppSizes.buttonHeightCompact,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.controlRadius),
      ),
      child: Icon(icon, color: color, size: AppSizes.iconSmall),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const _SurfaceCard(
      child: SizedBox(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.deliveryBlue),
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 38,
            color: AppColors.deliveryRed,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Collections could not load',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.deliveryInk,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.deliveryBlue,
              foregroundColor: AppColors.surface,
              minimumSize: const Size(130, AppSizes.buttonHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.controlRadius),
              ),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: AppSizes.iconMedium),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _CollectionDashboardData {
  const _CollectionDashboardData({required this.deliveries});

  final List<_CollectionDelivery> deliveries;

  List<_CollectionDelivery> get collectionRows {
    return deliveries.where((delivery) {
      return delivery.amountDue > 0 || delivery.amountCollected > 0;
    }).toList();
  }

  double get totalAmountToCollect {
    return deliveries.fold<double>(
      0,
      (sum, delivery) => sum + delivery.amountToCollect,
    );
  }

  double get totalAmountCollected {
    return deliveries.fold<double>(
      0,
      (sum, delivery) => sum + delivery.amountCollected,
    );
  }

  double get cashInHand {
    return deliveries
        .where((delivery) => delivery.paymentMode == 'cash')
        .fold<double>(0, (sum, delivery) => sum + delivery.amountCollected);
  }

  double get bankTransfer {
    return deliveries
        .where((delivery) => delivery.paymentMode == 'bank_transfer')
        .fold<double>(0, (sum, delivery) => sum + delivery.amountCollected);
  }

  double get pendingAmount {
    return deliveries.fold<double>(
      0,
      (sum, delivery) => sum + delivery.amountDue,
    );
  }

  String get formattedTotalToCollect => _formatMoney(totalAmountToCollect);
  String get formattedTotalCollected => _formatMoney(totalAmountCollected);
  String get formattedCashInHand => _formatMoney(cashInHand);
  String get formattedBankTransfer => _formatMoney(bankTransfer);
  String get formattedPendingAmount => _formatMoney(pendingAmount);
}

class _CollectionDelivery {
  const _CollectionDelivery({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.status,
    required this.amountDue,
    required this.amountCollected,
    required this.paymentMode,
  });

  final String id;
  final String orderNumber;
  final String customerName;
  final String status;
  final double amountDue;
  final double amountCollected;
  final String paymentMode;

  factory _CollectionDelivery.fromJson(Map<String, dynamic> json) {
    final id = _readString(json, const ['id', 'delivery_id']) ?? '';
    return _CollectionDelivery(
      id: id,
      orderNumber:
          _readString(json, const ['orderNumber', 'order_number', 'orderNo']) ??
          'ORD-${id.isEmpty ? 'NEW' : id.toUpperCase()}',
      customerName:
          _readString(json, const ['customerName', 'customer_name']) ??
          _readNestedString(json, 'customer', const ['name']) ??
          'Customer',
      status: _normalizeStatus(
        _readString(json, const ['status', 'delivery_status']) ?? 'planned',
      ),
      amountDue: _readDouble(json, const ['amountDue', 'amount_due', 'due']),
      amountCollected: _readDouble(json, const [
        'amountCollected',
        'amount_collected',
        'collectedAmount',
        'collected_amount',
        'paidAmount',
        'paid_amount',
      ]),
      paymentMode: _normalizePaymentMode(
        _readString(json, const [
              'paymentMode',
              'payment_mode',
              'paymentMethod',
              'payment_method',
              'collectionMode',
              'collection_mode',
            ]) ??
            '',
      ),
    );
  }

  double get amountToCollect => amountDue + amountCollected;

  String get statusLabel {
    return status
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String get paymentModeLabel {
    return switch (paymentMode) {
      'cash' => 'Cash',
      'bank_transfer' => 'Bank',
      '' => 'Not set',
      _ =>
        paymentMode
            .split('_')
            .where((part) => part.isNotEmpty)
            .map((part) => "${part[0].toUpperCase()}${part.substring(1)}")
            .join(' '),
    };
  }

  String get formattedDue => _formatMoney(amountDue);
  String get formattedCollected => _formatMoney(amountCollected);
}

class _CollectionInfo {
  const _CollectionInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color background;
}

class _CollectionException implements Exception {
  const _CollectionException(this.message);

  final String message;

  @override
  String toString() => message;
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

String? _readNestedString(
  Map<String, dynamic> json,
  String parentKey,
  List<String> keys,
) {
  final parent = json[parentKey];
  if (parent is! Map<String, dynamic>) return null;
  return _readString(parent, keys);
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

String _normalizeStatus(String value) {
  return value.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
}

String _normalizePaymentMode(String value) {
  final normalized = value
      .trim()
      .toLowerCase()
      .replaceAll('-', '_')
      .replaceAll(' ', '_');
  return switch (normalized) {
    'bank' ||
    'bank_transfer' ||
    'neft' ||
    'rtgs' ||
    'imps' ||
    'upi' ||
    'card' ||
    'online' => 'bank_transfer',
    'cash' || 'cod' => 'cash',
    _ => normalized,
  };
}

String _formatMoney(double value) {
  final rounded = value.round();
  final source = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < source.length; i++) {
    final remaining = source.length - i;
    buffer.write(source[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }
  return '${rounded < 0 ? '-' : ''}Rs ${buffer.toString()}';
}
