import '../../../models/list_pagination.dart';
import '../../../widgets/list_pagination_bar.dart';
import 'package:flutter/material.dart';
import '../../../widgets/app_skeleton.dart';

import 'package:crm_saas/core/theme/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widgets/delivery/delivery_bottom_navigation.dart';

import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/customer_avatar.dart';
import '../../../widgets/delivery/delivery_partner_sidebar.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';
import '../../shared/payment_collection_screen.dart';

// ---------------------------------------------------------------------------
// Lifecycle tabs: To Collect → Collected → Completed
// ---------------------------------------------------------------------------

enum _TabKind { toCollect, collected, completed }

class DeliveryCollectionListScreen extends StatefulWidget {
  const DeliveryCollectionListScreen({super.key});

  @override
  State<DeliveryCollectionListScreen> createState() =>
      _DeliveryCollectionListScreenState();
}

class _DeliveryCollectionListScreenState
    extends State<DeliveryCollectionListScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _didStartLoad = false;
  _TabKind _activeTab = _TabKind.toCollect;

  final _paginations = {
    _TabKind.toCollect: ListPagination(),
    _TabKind.collected: ListPagination(),
    _TabKind.completed: ListPagination(),
  };
  final _futures = <_TabKind, Future<_TabData>>{};

  ListPagination get _activePagination => _paginations[_activeTab]!;

  @override
  void dispose() {
    for (final p in _paginations.values) {
      p.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _didStartLoad = true;
      _loadTab(_TabKind.toCollect);
    }
  }

  // ---- data loading -------------------------------------------------------

  void _loadTab(_TabKind tab) {
    final future = _fetchTabData(tab);
    setState(() => _futures[tab] = future);
  }

  Future<_TabData> _fetchTabData(_TabKind tab) async {
    final provider = ApiProviderScope.of(context);
    final pagination = _paginations[tab]!;

    Map<String, dynamic> result;
    switch (tab) {
      case _TabKind.toCollect:
        result = await provider.fetchDeliveryCollectionsView(
          view: 'pending',
          pagination: pagination,
        );
      case _TabKind.collected:
        result = await provider.fetchDeliveryCollectionsView(
          view: 'collected',
          status: 'collected',
          pagination: pagination,
        );
      case _TabKind.completed:
        result = await provider.fetchDeliveryCollectionsView(
          view: 'collected',
          status: 'completed',
          pagination: pagination,
        );
    }

    final items = (result['items'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(_CollectionRecord.fromJson)
        .where(
          (r) => _normalizeCollectionStatus(r.collectionStatus) != 'voided',
        )
        .toList();

    return _TabData(
      items: items,
      summary: (result['summary'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<void> _changeListPage() async {
    if (_activePagination.isLoading) return;
    setState(() => _activePagination.isLoading = true);
    try {
      _loadTab(_activeTab);
      await _futures[_activeTab];
    } finally {
      if (mounted) setState(() => _activePagination.isLoading = false);
    }
  }

  Future<void> _refresh() async => _loadTab(_activeTab);

  void _onTabSelected(_TabKind tab) {
    if (_activeTab == tab) return;
    _paginations[tab]!.reset();
    setState(() => _activeTab = tab);
    _loadTab(tab);
  }

  // ---- navigation ---------------------------------------------------------

  Future<void> _openPaymentCollection(_CollectionRecord record) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            PaymentCollectionScreen(initialCustomerId: record.customerId),
      ),
    );
    if (result == true && mounted) {
      _loadTab(_TabKind.toCollect);
      if (_futures.containsKey(_TabKind.collected)) {
        _loadTab(_TabKind.collected);
      }
    }
  }

  // ---- build --------------------------------------------------------------

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
                child: RefreshIndicator(
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
                      AppSpacing.xl,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: _buildContent(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ListPaginationPageSize(
                          pagination: _activePagination,
                          onChanged: _changeListPage,
                        ),
                      ),
                      ListPaginationBar(
                        pagination: _activePagination,
                        onChanged: _changeListPage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final future = _futures[_activeTab];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TabSwitcher(activeTab: _activeTab, onTabSelected: _onTabSelected),
        const SizedBox(height: 8),
        if (future == null)
          const _LoadingPanel()
        else
          FutureBuilder<_TabData>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const _LoadingPanel();
              }
              if (snapshot.hasError) {
                return _ErrorPanel(
                  message: snapshot.error.toString(),
                  onRetry: () => _loadTab(_activeTab),
                );
              }
              return _TabContent(
                tab: _activeTab,
                data: snapshot.data!,
                onCollect: _openPaymentCollection,
              );
            },
          ),
      ],
    );
  }
}

// ===========================================================================
// Tab switcher
// ===========================================================================

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.activeTab, required this.onTabSelected});

  final _TabKind activeTab;
  final ValueChanged<_TabKind> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: _CollectionTab(
              label: 'To Collect',
              selected: activeTab == _TabKind.toCollect,
              color: AppColors.deliveryRed,
              onTap: () => onTabSelected(_TabKind.toCollect),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _CollectionTab(
              label: 'Collected',
              selected: activeTab == _TabKind.collected,
              color: AppColors.deliveryGreen,
              onTap: () => onTabSelected(_TabKind.collected),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _CollectionTab(
              label: 'Completed',
              selected: activeTab == _TabKind.completed,
              color: AppColors.deliveryBlue,
              onTap: () => onTabSelected(_TabKind.completed),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// Tab content (summary + list)
// ===========================================================================

class _TabContent extends StatelessWidget {
  const _TabContent({
    required this.tab,
    required this.data,
    required this.onCollect,
  });

  final _TabKind tab;
  final _TabData data;
  final ValueChanged<_CollectionRecord> onCollect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCard(tab: tab, summary: data.summary),
        const SizedBox(height: 8),
        if (data.items.isEmpty)
          const _EmptyCollectionList()
        else
          ...data.items.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: tab == _TabKind.toCollect
                  ? _ToCollectTile(
                      record: record,
                      onCollect: () => onCollect(record),
                    )
                  : _CollectedCompletedTile(
                      record: record,
                      isCompleted: tab == _TabKind.completed,
                    ),
            ),
          ),
      ],
    );
  }
}

// ===========================================================================
// Summary cards (per tab)
// ===========================================================================

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.tab, required this.summary});

  final _TabKind tab;
  final Map<String, dynamic> summary;

  double _d(String key) => (summary[key] as num?)?.toDouble() ?? 0;
  int _i(String key) => (summary[key] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      _TabKind.toCollect => _buildToCollect(),
      _TabKind.collected => _buildCollected(),
      _TabKind.completed => _buildCompleted(),
    };
  }

  Widget _buildToCollect() {
    final amountToCollect = _d('total_pending_amount');
    final customerCount = _i('total_pending');
    final processing = _d('total_pending_collection_amount');
    final outstanding = _d('total_outstanding_amount');
    final showProcessing = processing > 0;

    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'To Collect'),
          const SizedBox(height: 12),
          _ProminentAmountRow(
            amount: amountToCollect,
            label: 'Amount To Collect',
            icon: Icons.currency_rupee_rounded,
            color: AppColors.deliveryRed,
            background: AppColors.deliveryRedSoft,
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: showProcessing ? 3 : 2,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: showProcessing ? 3 : 2,
              childAspectRatio: showProcessing ? 2.2 : 2.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (_, i) {
              final tiles = [
                _CollectionInfo(
                  icon: Icons.people_outline_rounded,
                  label: 'Customers',
                  value: '$customerCount',
                  color: AppColors.deliveryBlue,
                  background: AppColors.deliveryBlueSoft,
                ),
                _CollectionInfo(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Outstanding',
                  value: _formatMoney(
                    outstanding > 0 ? outstanding : amountToCollect,
                  ),
                  color: AppColors.deliveryOrange,
                  background: AppColors.deliveryOrangeSoft,
                ),
                if (showProcessing)
                  _CollectionInfo(
                    icon: Icons.pending_actions_outlined,
                    label: 'Processing',
                    value: _formatMoney(processing),
                    color: AppColors.deliveryGreen,
                    background: AppColors.deliveryGreenSoft,
                  ),
              ];
              return _CollectionMetricTile(info: tiles[i]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCollected() {
    final total = _d('total_collected');
    final cash = _d('cash_total');
    final bank = _d('bank_transfer_total');
    final count = _i('collected_only_count');

    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Collected'),
          const SizedBox(height: 12),
          _ProminentAmountRow(
            amount: total,
            label: 'Total Collected',
            icon: Icons.payments_outlined,
            color: AppColors.deliveryGreen,
            background: AppColors.deliveryGreenSoft,
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (_, i) {
              final tiles = [
                _CollectionInfo(
                  icon: Icons.receipt_long_outlined,
                  label: 'Payments',
                  value: '$count',
                  color: AppColors.deliveryBlue,
                  background: AppColors.deliveryBlueSoft,
                ),
                _CollectionInfo(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Cash',
                  value: _formatMoney(cash),
                  color: AppColors.deliveryOrange,
                  background: AppColors.deliveryOrangeSoft,
                ),
                _CollectionInfo(
                  icon: Icons.account_balance_outlined,
                  label: 'Bank',
                  value: _formatMoney(bank),
                  color: AppColors.deliveryBlue,
                  background: AppColors.deliveryBlueSoft,
                ),
              ];
              return _CollectionMetricTile(info: tiles[i]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompleted() {
    final total = _d('completed_amount');
    final count = _i('completed_count');

    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Completed'),
          const SizedBox(height: 12),
          _ProminentAmountRow(
            amount: total,
            label: 'Total Completed',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.deliveryBlue,
            background: AppColors.deliveryBlueSoft,
          ),
          const SizedBox(height: 10),
          _CollectionMetricTile(
            info: _CollectionInfo(
              icon: Icons.receipt_long_outlined,
              label: 'Completed Payments',
              value: '$count',
              color: AppColors.deliveryBlue,
              background: AppColors.deliveryBlueSoft,
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// To Collect tile (customer-level record)
// ===========================================================================

class _ToCollectTile extends StatelessWidget {
  const _ToCollectTile({required this.record, required this.onCollect});

  final _CollectionRecord record;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    final canCollect = record.collectableAmount > 0;
    final accent = canCollect ? AppColors.deliveryRed : AppColors.deliveryGreen;

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
                CustomerAvatar(
                  name: record.customerName,
                  photoUrl: record.photoUrl,
                  size: 56,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.secondaryStrong.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (record.contactName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          record.contactName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small,
                        ),
                      ],
                      const SizedBox(height: 6),
                      if (record.outstandingAmount > record.collectableAmount &&
                          record.outstandingAmount > 0)
                        Text(
                          'Outstanding: ${_formatMoney(record.outstandingAmount)}',
                          maxLines: 1,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      if (record.pendingCollectionAmount > 0)
                        Text(
                          '${_formatMoney(record.pendingCollectionAmount)} collected',
                          maxLines: 1,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.deliveryOrange,
                          ),
                        ),
                      Text(
                        '${_formatMoney(record.collectableAmount)} to collect',
                        maxLines: 1,
                        style: AppTextStyles.bodyStrong.copyWith(color: accent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SmallAction(
                          icon: Icons.phone_rounded,
                          tooltip: 'Call customer',
                          onTap: record.phone == null
                              ? null
                              : () => launchUrl(
                                  Uri(scheme: 'tel', path: record.phone),
                                ),
                        ),
                        _SmallAction(
                          icon: Icons.location_on_outlined,
                          tooltip: 'Open location',
                          onTap: record.mapUrl == null
                              ? null
                              : () => launchUrl(
                                  Uri.parse(record.mapUrl!),
                                  mode: LaunchMode.externalApplication,
                                ),
                        ),
                        if (canCollect) ...[
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
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 12,
                                  height: 1.3,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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

// ===========================================================================
// Collected / Completed tile (transaction-level record)
// ===========================================================================

class _CollectedCompletedTile extends StatelessWidget {
  const _CollectedCompletedTile({
    required this.record,
    required this.isCompleted,
  });

  final _CollectionRecord record;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final badgeLabel = isCompleted ? 'Completed' : 'Collected';
    final badgeColor = isCompleted
        ? AppColors.deliveryBlue
        : AppColors.deliveryGreen;
    final badgeBg = isCompleted
        ? AppColors.deliveryBlueSoft
        : AppColors.deliveryGreenSoft;

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
            child: ColoredBox(
              color: badgeColor,
              child: const SizedBox(width: 3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomerAvatar(
                  name: record.customerName,
                  photoUrl: record.photoUrl,
                  size: 48,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              record.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.secondaryStrong.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            record.formattedCollected,
                            style: AppTextStyles.bodyStrong.copyWith(
                              color: badgeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _StatusPill(
                            label: badgeLabel,
                            color: badgeColor,
                            background: badgeBg,
                          ),
                          if (record.paymentMode.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '• ${record.paymentModeLabel}',
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (record.collectedAt != null &&
                          record.collectedAt!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _dateLabel(_parseDateTimeString(record.collectedAt)),
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      if (record.orderNumber.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          record.orderNumber,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      if (record.deliveryNumber != null &&
                          record.deliveryNumber!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Delivery: ${record.deliveryNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      if (record.collectedByName != null &&
                          record.collectedByName!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'By: ${record.collectedByName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      if (record.reference != null &&
                          record.reference!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Ref: ${record.reference}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.small.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      if (record.paymentProofUrl != null &&
                          record.paymentProofUrl!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_file_rounded,
                              size: 13,
                              color: AppColors.deliveryBlue,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Payment proof attached',
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.deliveryBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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

// ===========================================================================
// Small shared widgets
// ===========================================================================

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
          style: AppTextStyles.secondaryStrong.copyWith(
            color: selected ? color : AppColors.deliveryGreen,
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    required this.background,
  });
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: color,
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

class _ProminentAmountRow extends StatelessWidget {
  const _ProminentAmountRow({
    required this.amount,
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });
  final double amount;
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          _MiniIcon(icon: icon, color: color, background: AppColors.surface),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatMoney(amount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.importantNumber.copyWith(
                    color: AppColors.deliveryInk,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small,
                ),
              ],
            ),
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
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.deliveryInk,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  info.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.small,
                ),
              ],
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
          Text('No records found', style: AppTextStyles.cardTitle),
          SizedBox(height: 6),
          Text(
            'Customer payments will appear here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.fieldLabel,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.sectionHeading),
        const Spacer(),
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
    return const _SurfaceCard(child: AppPageSkeleton(rows: 5));
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
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.fieldLabel.copyWith(
              color: AppColors.textMuted,
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

// ===========================================================================
// Data models
// ===========================================================================

class _TabData {
  const _TabData({required this.items, required this.summary});
  final List<_CollectionRecord> items;
  final Map<String, dynamic> summary;
}

class _CollectionRecord {
  const _CollectionRecord({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.collectionStatus,
    required this.outstandingAmount,
    required this.pendingCollectionAmount,
    required this.collectableAmount,
    required this.amountCollected,
    required this.paymentMode,
    required this.contactName,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.orderNumber,
    this.photoUrl,
    this.paymentProofUrl,
    this.collectedByName,
    this.deliveryNumber,
    this.collectedAt,
    this.reference,
  });

  final String id;
  final String customerId;
  final String customerName;
  final String? collectionStatus;
  final double outstandingAmount;
  final double pendingCollectionAmount;
  final double collectableAmount;
  final double amountCollected;
  final String paymentMode;
  final String contactName;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String orderNumber;
  final String? photoUrl;
  final String? paymentProofUrl;
  final String? collectedByName;
  final String? deliveryNumber;
  final String? collectedAt;
  final String? reference;

  factory _CollectionRecord.fromJson(Map<String, dynamic> json) {
    // For customer-level records (To Collect), id == customer_id.
    // For transaction records (Collected/Completed), customer_id is separate.
    final customerId = _readString(json, const ['customer_id', 'id']) ?? '';
    final id =
        _readString(json, const ['id', 'collection_id', 'customer_id']) ?? '';

    return _CollectionRecord(
      id: id,
      customerId: customerId,
      customerName:
          _readString(json, const ['customer_name', 'customerName']) ??
          _readNestedString(json, 'customer', const ['name']) ??
          (customerId.isNotEmpty ? customerId : 'Customer'),
      collectionStatus: _readString(json, const [
        'collection_status',
        'status',
        'reconciliation_status',
      ]),
      outstandingAmount: _readDouble(json, const [
        'outstanding_amount',
        'outstandingAmount',
        'outstanding_at_recording',
        'amount_due',
      ]),
      pendingCollectionAmount: _readDouble(json, const [
        'pending_collection_amount',
        'pendingCollectionAmount',
      ]),
      collectableAmount: _readDouble(json, const [
        'collectable_amount',
        'collectableAmount',
        'outstanding_amount',
      ]),
      amountCollected: _readDouble(json, const [
        'amount_collected',
        'amount',
        'amountCollected',
        'collected_amount',
      ]),
      paymentMode: _normalizePaymentMode(
        _readString(json, const [
              'payment_mode',
              'paymentMode',
              'payment_method',
              'paymentMethod',
            ]) ??
            '',
      ),
      contactName:
          _readString(json, const ['contact_name', 'contact_person']) ??
          _readNestedString(json, 'customer', const [
            'contact_person',
            'contact_name',
          ]) ??
          '',
      phone:
          _readString(json, const ['customer_phone', 'phone', 'mobile']) ??
          _readNestedString(json, 'customer', const ['phone', 'mobile']),
      latitude:
          _readNullableDouble(json, const ['customer_latitude', 'latitude']) ??
          _readNestedDouble(json, 'customer', const ['latitude']),
      longitude:
          _readNullableDouble(json, const [
            'customer_longitude',
            'longitude',
          ]) ??
          _readNestedDouble(json, 'customer', const ['longitude']),
      photoUrl:
          _readString(json, const [
            'customer_photo_url',
            'profile_photo_url',
          ]) ??
          _readNestedString(json, 'customer', const [
            'profile_photo_url',
            'photo_url',
          ]),
      orderNumber:
          _readString(json, const ['order_number', 'orderNumber', 'orderNo']) ??
          '',
      paymentProofUrl: _readString(json, const [
        'payment_proof_url',
        'paymentProofUrl',
      ]),
      collectedByName: _readString(json, const [
        'collected_by_name',
        'collectedByName',
        'collected_by',
      ]),
      deliveryNumber: _readString(json, const [
        'delivery_number',
        'deliveryNumber',
      ]),
      collectedAt: _readString(json, const [
        'collected_at',
        'collectedAt',
        'payment_date',
        'paymentDate',
      ]),
      reference: _readString(json, const [
        'reference',
        'transaction_id',
        'transactionId',
        'ref_number',
      ]),
    );
  }

  String get formattedCollected => _formatMoney(amountCollected);

  String get paymentModeLabel {
    return switch (paymentMode) {
      'cash' => 'Cash',
      'bank_transfer' => 'Bank',
      '' => '',
      _ =>
        paymentMode
            .split('_')
            .where((p) => p.isNotEmpty)
            .map((p) => '${p[0].toUpperCase()}${p.substring(1)}')
            .join(' '),
    };
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

// ===========================================================================
// Status normalization (single centralized helper)
// ===========================================================================

/// Maps any backend status value to one of: to_collect, collected, completed, voided.
String _normalizeCollectionStatus(String? raw) {
  final v = (raw ?? '')
      .trim()
      .toLowerCase()
      .replaceAll('-', '_')
      .replaceAll(' ', '_');
  return switch (v) {
    'to_collect' => 'to_collect',
    'collected' => 'collected',
    'completed' || 'reconciled' || 'approved' => 'completed',
    // legacy values
    'pending' => 'to_collect',
    'recorded' ||
    'pending_approval' ||
    'awaiting_approval' ||
    'awaiting_reconciliation' => 'collected',
    'voided' => 'voided',
    _ => v,
  };
}

// ===========================================================================
// JSON helpers
// ===========================================================================

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

// ===========================================================================
// Date / money helpers
// ===========================================================================

DateTime? _parseDateTimeString(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String _dateLabel(DateTime? date) {
  if (date == null) return '-';
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
  return '${date.day.toString().padLeft(2, '0')} '
      '${months[date.month - 1]} ${date.year}';
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
