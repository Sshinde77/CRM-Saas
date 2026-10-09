import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/delivery/delivery_bottom_navigation.dart';

import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/delivery/delivery_partner_sidebar.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';
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
  bool _showPending = true;

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
    final collections = await provider.fetchDeliveryCollections();
    final customers = await provider.fetchCustomers(isActive: true);

    return _CollectionDashboardData(
      deliveries: collections.map(_CollectionDelivery.fromJson).toList(),
      pendingCustomers: customers
          .where((customer) => (customer.outstanding ?? 0) > 0)
          .map(_CollectionDelivery.fromCustomer)
          .toList(),
    );
  }

  Future<void> _refresh() async {
    final nextFuture = _loadCollections();
    setState(() => _collectionFuture = nextFuture);
    await nextFuture;
  }

  Future<void> _openPaymentCollection(_CollectionDelivery customer) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaymentCollectionScreen(initialCustomerId: customer.id),
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
        bottomNavigationBar: DeliveryBottomNavigation(
          currentIndex: 4,
          onCollectionCreated: _refresh,
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              DeliveryTopBar(
                title: 'Collections',
                subtitle: 'Track and record customer payments',
                leadingIcon: Icons.menu_rounded,
                onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
                actions: [
                  DeliveryTopBarAction(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Refresh collections',
                    onTap: _refresh,
                  ),
                ],
              ),
              Expanded(
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
                                          _collectionFuture =
                                              _loadCollections();
                                        });
                                      },
                                    )
                                  : _CollectionContent(
                                      data:
                                          data ??
                                          const _CollectionDashboardData(
                                            deliveries: [],
                                            pendingCustomers: [],
                                          ),
                                      showPending: _showPending,
                                      onTabChanged: (value) =>
                                          setState(() => _showPending = value),
                                      onCollect: _openPaymentCollection,
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
      ),
    );
  }
}

class _CollectionContent extends StatelessWidget {
  const _CollectionContent({
    required this.data,
    required this.showPending,
    required this.onTabChanged,
    required this.onCollect,
  });

  final _CollectionDashboardData data;
  final bool showPending;
  final ValueChanged<bool> onTabChanged;
  final ValueChanged<_CollectionDelivery> onCollect;

  @override
  Widget build(BuildContext context) {
    final collectionRows = showPending ? data.pendingRows : data.collectedRows;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CollectionsCard(data: data),
        const SizedBox(height: AppSpacing.md),
        _SurfaceCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 2, 4, 8),
                child: Text(
                  'Collection List',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _CollectionTab(
                      label: 'Pending List',
                      selected: showPending,
                      color: AppColors.deliveryRed,
                      onTap: () => onTabChanged(true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CollectionTab(
                      label: 'Collected List',
                      selected: !showPending,
                      color: AppColors.deliveryGreen,
                      onTap: () => onTabChanged(false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (collectionRows.isEmpty)
          const _EmptyCollectionList()
        else
          ...collectionRows.map(
            (delivery) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CollectionListTile(
                delivery: delivery,
                onCollect: () => onCollect(delivery),
              ),
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
              color: const Color(0xFFF0F7EC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.deliveryGreen.withValues(alpha: 0.14),
              ),
            ),
            child: Row(
              children: [
                const _MiniIcon(
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.deliveryGreen,
                  background: AppColors.surface,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.formattedTotalToCollect,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deliveryInk,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Total Amount to Collect',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMuted,
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
                  info.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deliveryInk,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  info.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textMuted,
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
  const _CollectionListTile({required this.delivery, required this.onCollect});

  final _CollectionDelivery delivery;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    final hasDue = delivery.amountDue > 0;
    final accent = hasDue ? AppColors.deliveryRed : AppColors.deliveryGreen;

    return Container(
      clipBehavior: Clip.antiAlias,
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
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: ColoredBox(color: accent, child: const SizedBox(width: 3)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.deliveryGreenSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    delivery.initials,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.deliveryInk,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        delivery.orderNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        delivery.contactName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
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
                    Text(
                      hasDue
                          ? delivery.formattedDue
                          : delivery.formattedCollected,
                      style: TextStyle(
                        color: accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SmallAction(
                          icon: Icons.phone_rounded,
                          tooltip: 'Call customer',
                          onTap: delivery.phone == null
                              ? null
                              : () => launchUrl(
                                  Uri(scheme: 'tel', path: delivery.phone),
                                ),
                        ),
                        _SmallAction(
                          icon: Icons.location_on_outlined,
                          tooltip: 'Open location',
                          onTap: delivery.mapUrl == null
                              ? null
                              : () => launchUrl(
                                  Uri.parse(delivery.mapUrl!),
                                  mode: LaunchMode.externalApplication,
                                ),
                        ),
                        if (hasDue) ...[
                          const SizedBox(width: 4),
                          SizedBox(
                            height: 32,
                            child: FilledButton(
                              onPressed: onCollect,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.deliveryRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Collect',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
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

class _CollectionTab extends StatelessWidget {
  const _CollectionTab({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.07)
              : AppColors.deliveryGreenSoft,
          borderRadius: BorderRadius.circular(14),
          border: selected ? Border.all(color: color, width: 2) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.deliveryGreen,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: const EdgeInsets.all(8),
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 20,
        color: onTap == null ? AppColors.textMuted : AppColors.deliveryGreen,
      ),
    );
  }
}

// ignore: unused_element
class _CollectionCardDetail extends StatelessWidget {
  const _CollectionCardDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.deliveryInk,
          ),
        ),
      ],
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
              fontSize: 14,
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
            fontSize: 14,
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
              fontSize: 14,
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
  const _CollectionDashboardData({
    required this.deliveries,
    required this.pendingCustomers,
  });

  final List<_CollectionDelivery> deliveries;
  final List<_CollectionDelivery> pendingCustomers;

  List<_CollectionDelivery> get collectionRows {
    return deliveries.where((delivery) {
      return !delivery.isVoided && delivery.amountCollected > 0;
    }).toList();
  }

  List<_CollectionDelivery> get pendingRows => pendingCustomers;

  List<_CollectionDelivery> get collectedRows =>
      collectionRows.where((delivery) => delivery.amountCollected > 0).toList();

  double get totalAmountToCollect {
    return pendingAmount + totalAmountCollected;
  }

  double get totalAmountCollected {
    return collectionRows.fold<double>(
      0,
      (sum, delivery) => sum + delivery.amountCollected,
    );
  }

  double get cashInHand {
    return collectionRows
        .where((delivery) => delivery.paymentMode == 'cash')
        .fold<double>(0, (sum, delivery) => sum + delivery.amountCollected);
  }

  double get bankTransfer {
    return collectionRows
        .where((delivery) => delivery.paymentMode == 'bank_transfer')
        .fold<double>(0, (sum, delivery) => sum + delivery.amountCollected);
  }

  double get pendingAmount {
    return pendingRows.fold<double>(
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
    required this.paymentProofUrl,
    required this.contactName,
    required this.phone,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String orderNumber;
  final String customerName;
  final String status;
  final double amountDue;
  final double amountCollected;
  final String paymentMode;
  final String? paymentProofUrl;
  final String contactName;
  final String? phone;
  final double? latitude;
  final double? longitude;

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
        _readString(json, const [
              'reconciliation_status',
              'reconciliationStatus',
              'status',
              'delivery_status',
            ]) ??
            'recorded',
      ),
      amountDue: _readDouble(json, const [
        'outstanding_amount',
        'outstandingAmount',
        'outstanding_at_recording',
        'outstandingAtRecording',
        'amountDue',
        'amount_due',
        'due',
      ]),
      amountCollected: _readDouble(json, const [
        'amount',
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
      paymentProofUrl: _readString(json, const [
        'payment_proof_url',
        'paymentProofUrl',
      ]),
      contactName:
          _readString(json, const ['contact_person', 'contactPerson']) ??
          _readNestedString(json, 'customer', const [
            'contact_person',
            'contactPerson',
          ]) ??
          'Customer contact',
      phone:
          _readString(json, const ['customer_phone', 'phone', 'mobile']) ??
          _readNestedString(json, 'customer', const ['phone', 'mobile']),
      latitude:
          _readNullableDouble(json, const [
            'customer_latitude',
            'latitude',
            'map_latitude',
          ]) ??
          _readNestedDouble(json, 'customer', const [
            'latitude',
            'map_latitude',
          ]),
      longitude:
          _readNullableDouble(json, const [
            'customer_longitude',
            'longitude',
            'map_longitude',
          ]) ??
          _readNestedDouble(json, 'customer', const [
            'longitude',
            'map_longitude',
          ]),
    );
  }

  factory _CollectionDelivery.fromCustomer(CustomerModel customer) {
    final businessName = customer.businessName?.trim();
    final contactName = customer.contactPerson?.trim();
    final customerCode = customer.customerId?.trim();
    return _CollectionDelivery(
      id: customer.id,
      orderNumber: customerCode?.isNotEmpty == true
          ? customerCode!
          : 'Outstanding balance',
      customerName: businessName?.isNotEmpty == true
          ? businessName!
          : customer.name,
      status: 'pending',
      amountDue: (customer.outstanding ?? 0).toDouble(),
      amountCollected: 0,
      paymentMode: '',
      paymentProofUrl: null,
      contactName: contactName?.isNotEmpty == true
          ? contactName!
          : customer.name,
      phone: customer.phone,
      latitude: customer.mapLatitude,
      longitude: customer.mapLongitude,
    );
  }

  double get amountToCollect => amountDue + amountCollected;

  bool get isVoided => status == 'voided';

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

  String get initials {
    final words = customerName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return 'C';
    if (words.length == 1) {
      final end = words.first.length >= 2 ? 2 : 1;
      return words.first.substring(0, end).toUpperCase();
    }
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  String? get mapUrl {
    if (latitude == null || longitude == null) return null;
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }
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

// ignore: unused_element
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

double? _readNullableDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return null;
}

double? _readNestedDouble(
  Map<String, dynamic> json,
  String parentKey,
  List<String> keys,
) {
  final parent = json[parentKey];
  if (parent is! Map<String, dynamic>) return null;
  return _readNullableDouble(parent, keys);
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
