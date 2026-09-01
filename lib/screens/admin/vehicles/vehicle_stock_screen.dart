import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../../../widgets/delivery/delivery_partner_sidebar.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';

enum VehicleStockMode { admin, delivery }

class VehicleStockScreen extends StatefulWidget {
  final VehicleStockMode mode;

  const VehicleStockScreen({super.key, this.mode = VehicleStockMode.admin});

  const VehicleStockScreen.delivery({super.key})
      : mode = VehicleStockMode.delivery;

  @override
  State<VehicleStockScreen> createState() => _VehicleStockScreenState();
}

class _VehicleStockScreenState extends State<VehicleStockScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<List<_VehicleStockSession>>? _future;
  bool _didStartLoad = false;
  String _selectedPartner = 'All Delivery Partners';

  bool get _isDelivery => widget.mode == VehicleStockMode.delivery;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _future = _load();
      _didStartLoad = true;
    }
  }

  Future<List<_VehicleStockSession>> _load() async {
    final provider = ApiProviderScope.of(context);
    if (_isDelivery) {
      final authMe = await provider.fetchAuthMe();
      final currentUser = provider.currentUser ?? authMe?.user;
      final deliveryPartnerId = currentUser?.id?.trim();
      if (deliveryPartnerId == null || deliveryPartnerId.isEmpty) {
        throw const _VehicleStockException('Delivery partner id is missing.');
      }
      final current = await provider.fetchCurrentVehicleStock(deliveryPartnerId);
      if (current == null) return const [];
      return [_VehicleStockSession.fromJson(current)];
    }

    final rows = await provider.fetchVehicleStockSessions();
    return rows.map(_VehicleStockSession.fromJson).toList();
  }

  Future<void> _refresh() async {
    final request = _load();
    setState(() => _future = request);
    await request;
  }

  void _openDetails(_VehicleStockSession session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _VehicleStockDetailScreen(
          session: session,
          isDelivery: _isDelivery,
        ),
      ),
    );
  }

  List<String> _partners(List<_VehicleStockSession> sessions) {
    final names = sessions
        .map((session) => session.partnerName)
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All Delivery Partners', ...names];
  }

  List<_VehicleStockSession> _filtered(List<_VehicleStockSession> sessions) {
    if (_isDelivery || _selectedPartner == 'All Delivery Partners') {
      return sessions;
    }
    return sessions
        .where((session) => session.partnerName == _selectedPartner)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _isDelivery ? const Color(0xFFF8FAF9) : AppColors.background,
      drawer: _isDelivery
          ? const DeliveryPartnerSidebar(
              currentRoute: AppRoutes.deliveryVehicleStock,
            )
          : const AppDrawer(activeItem: 'Vehicle Stock'),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (_isDelivery)
              DeliveryTopBar(
                title: 'Vehicle Stock',
                subtitle: 'Track loaded, delivered and remaining items',
                leadingIcon: Icons.menu_rounded,
                onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
              )
            else
              AdminTopBar(
                title: 'Vehicle Stock',
                leadingIcon: Icons.menu_rounded,
                onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            Expanded(
              child: FutureBuilder<List<_VehicleStockSession>>(
                future: _future,
                builder: (context, snapshot) {
                  final sessions = snapshot.data ?? const <_VehicleStockSession>[];
                  final filtered = _filtered(sessions);
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData;

                  return RefreshIndicator(
                    color: AppColors.deliveryGreen,
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 920),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!_isDelivery)
                                _AdminListFilter(
                                  partners: _partners(sessions),
                                  selectedPartner: _selectedPartner,
                                  onPartnerChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedPartner = value);
                                    }
                                  },
                                ),
                              const SizedBox(height: 12),
                              if (isLoading)
                                const _LoadingState()
                              else if (snapshot.hasError)
                                _ErrorState(
                                  message: _cleanError(snapshot.error),
                                  onRetry: _refresh,
                                )
                              else if (filtered.isEmpty)
                                _EmptyState(isDelivery: _isDelivery)
                              else
                                ...filtered.map(
                                  (session) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _VehicleListCard(
                                      session: session,
                                      showPartner: !_isDelivery,
                                      onTap: () => _openDetails(session),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
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

class _AdminListFilter extends StatelessWidget {
  final List<String> partners;
  final String selectedPartner;
  final ValueChanged<String?> onPartnerChanged;

  const _AdminListFilter({
    required this.partners,
    required this.selectedPartner,
    required this.onPartnerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Filter by delivery partner',
              style: TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _PartnerFilter(
            partners: partners,
            value: partners.contains(selectedPartner)
                ? selectedPartner
                : 'All Delivery Partners',
            onChanged: onPartnerChanged,
          ),
        ],
      ),
    );
  }
}

class _PartnerFilter extends StatelessWidget {
  final List<String> partners;
  final String value;
  final ValueChanged<String?> onChanged;

  const _PartnerFilter({
    required this.partners,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 210),
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E7F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          style: const TextStyle(
            color: AppColors.deliveryInk,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
          items: partners
              .map(
                (partner) => DropdownMenuItem(
                  value: partner,
                  child: Text(partner, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _VehicleListCard extends StatelessWidget {
  final _VehicleStockSession session;
  final bool showPartner;
  final VoidCallback onTap;

  const _VehicleListCard({
    required this.session,
    required this.showPartner,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (session.vehicleType.isNotEmpty) session.vehicleType,
      if (showPartner && session.partnerName.isNotEmpty)
        'Driver: ${session.partnerName}',
    ].join(' / ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
          child: Row(
            children: [
              const _TintIcon(
                icon: Icons.local_shipping_rounded,
                color: Color(0xFF2563EB),
                background: Color(0xFFEAF3FF),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.vehicleNumber.isEmpty
                          ? 'Vehicle not assigned'
                          : session.vehicleNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deliveryInk,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle.isEmpty ? 'Stock session' : subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusPill(session.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleStockDetailScreen extends StatelessWidget {
  final _VehicleStockSession session;
  final bool isDelivery;

  const _VehicleStockDetailScreen({
    required this.session,
    required this.isDelivery,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDelivery ? const Color(0xFFF8FAF9) : AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (isDelivery)
              DeliveryTopBar(
                title: 'Vehicle Stock',
                subtitle: 'Track stock levels in delivery vehicles',
                leadingIcon: Icons.arrow_back_rounded,
                onLeadingTap: () => Navigator.of(context).maybePop(),
              )
            else
              AdminTopBar(
                title: 'Vehicle Stock',
                leadingIcon: Icons.arrow_back_rounded,
                onLeadingTap: () => Navigator.of(context).maybePop(),
              ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      children: [
                        _SessionInfoCard(session: session),
                        const SizedBox(height: 12),
                        _StockItemsTable(session: session),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionInfoCard extends StatelessWidget {
  final _VehicleStockSession session;

  const _SessionInfoCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TintIcon(
                icon: Icons.delivery_dining_rounded,
                color: Color(0xFF0D7A24),
                background: Color(0xFFE9F7EA),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Active Session',
                  style: TextStyle(
                    color: Color(0xFF065F1B),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusPill(session.status),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 560;
              final itemWidth = wide
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 12,
                runSpacing: 14,
                children: [
                  _InfoField(
                    width: itemWidth,
                    icon: Icons.local_shipping_outlined,
                    label: 'Vehicle Number',
                    value: session.vehicleNumber,
                  ),
                  _InfoField(
                    width: itemWidth,
                    icon: Icons.local_shipping_outlined,
                    label: 'Vehicle Type',
                    value: session.vehicleType,
                  ),
                  _InfoField(
                    width: itemWidth,
                    icon: Icons.person_outline_rounded,
                    label: 'Delivery Partner',
                    value: session.partnerName,
                  ),
                  _InfoField(
                    width: itemWidth,
                    icon: Icons.calendar_month_outlined,
                    label: 'Session Date',
                    value: _formatDate(session.sessionDate),
                  ),
                  _InfoField(
                    width: itemWidth,
                    icon: Icons.event_outlined,
                    label: 'Session Started',
                    value: _formatDateTime(session.startedAt),
                  ),
                  _InfoField(
                    width: itemWidth,
                    icon: Icons.schedule_rounded,
                    label: 'Last Updated',
                    value: _formatDateTime(session.updatedAt),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String value;

  const _InfoField({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF4A546B), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.trim().isEmpty ? '-' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
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

class _StockItemsTable extends StatelessWidget {
  final _VehicleStockSession session;

  const _StockItemsTable({required this.session});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF0D7A24),
                size: 22,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vehicle Stock Items',
                  style: TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (session.items.isEmpty)
            const _InlineEmpty(message: 'No stock items found in this session.')
          else ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E7F0)),
              ),
              child: Column(
                children: [
                  const _StockTableHeader(),
                  ...session.items.map(_StockTableRow.new),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _RemainingSummary(total: session.totalRemaining),
          ],
        ],
      ),
    );
  }
}

class _StockTableHeader extends StatelessWidget {
  const _StockTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 4, child: _TableHeaderText('Product')),
          Expanded(flex: 2, child: _TableHeaderText('Loaded')),
          Expanded(flex: 2, child: _TableHeaderText('Delivered')),
          Expanded(flex: 2, child: _TableHeaderText('Returned')),
          Expanded(flex: 2, child: _TableHeaderText('Remaining')),
        ],
      ),
    );
  }
}

class _StockTableRow extends StatelessWidget {
  final _VehicleStockItem item;

  const _StockTableRow(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE9EDF5))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                _ProductImage(imageUrl: item.imageUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName.isEmpty
                            ? 'Unnamed product'
                            : item.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.deliveryInk,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.variantId.isEmpty ? '-' : item.variantId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: _QuantityText(item.loaded)),
          Expanded(flex: 2, child: _QuantityText(item.delivered)),
          Expanded(flex: 2, child: _QuantityText(item.returned)),
          Expanded(
            flex: 2,
            child: _QuantityText(
              item.remaining,
              color: const Color(0xFF065F1B),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderText extends StatelessWidget {
  final String text;

  const _TableHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.deliveryInk,
        fontSize: 11.5,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E7F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF4A546B),
              size: 22,
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF4A546B),
                  size: 22,
                );
              },
            ),
    );
  }
}

class _QuantityText extends StatelessWidget {
  final double value;
  final Color? color;

  const _QuantityText(this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      _qty(value),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color ?? AppColors.deliveryInk,
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _RemainingSummary extends StatelessWidget {
  final double total;

  const _RemainingSummary({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FBF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD8EEDD)),
      ),
      child: Row(
        children: [
          const _TintIcon(
            icon: Icons.inventory_2_outlined,
            color: Color(0xFF0D7A24),
            background: Color(0xFFE9F7EA),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remaining Vehicle Stock',
                  style: TextStyle(
                    color: Color(0xFF065F1B),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Total remaining units across all products',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _qty(total),
                style: const TextStyle(
                  color: Color(0xFF065F1B),
                  fontSize: 24,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'Units',
                style: TextStyle(
                  color: Color(0xFF065F1B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill(this.status);

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase();
    final active = normalized.isEmpty ||
        normalized == 'active' ||
        normalized == 'loaded' ||
        normalized == 'in_progress';
    final color = active ? const Color(0xFF0D8C28) : AppColors.textMuted;
    final label = status.trim().isEmpty ? 'Active' : _titleCase(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppSizes.pillRadius),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TintIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const _TintIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const _SurfaceCard(
      child: SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.deliveryGreen),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 26),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.deliveryRed,
              size: 34,
            ),
            const SizedBox(height: 8),
            const Text(
              'Vehicle stock could not load',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.deliveryInk,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDelivery;

  const _EmptyState({required this.isDelivery});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 34),
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.textMuted,
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              isDelivery
                  ? 'No active vehicle stock session'
                  : 'No vehicle stock sessions found',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.deliveryInk,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Loaded stock details will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  final String message;

  const _InlineEmpty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E7F0)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.all(AppSpacing.card),
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

class _VehicleStockSession {
  final String id;
  final String vehicleNumber;
  final String vehicleType;
  final String partnerName;
  final String status;
  final DateTime? sessionDate;
  final DateTime? startedAt;
  final DateTime? updatedAt;
  final List<_VehicleStockItem> items;

  const _VehicleStockSession({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.partnerName,
    required this.status,
    required this.sessionDate,
    required this.startedAt,
    required this.updatedAt,
    required this.items,
  });

  factory _VehicleStockSession.fromJson(Map<String, dynamic> json) {
    final nested = _readMap(json, const ['session', 'vehicle_stock', 'vehicleStock']);
    final source = nested.isEmpty ? json : <String, dynamic>{...json, ...nested};
    final vehicle = _readMap(source, const ['vehicle']);
    final partner = _readMap(source, const [
      'delivery_partner',
      'deliveryPartner',
      'partner',
      'driver',
      'user',
    ]);
    final itemRows = _readList(source, const [
      'items',
      'stock_items',
      'stockItems',
      'loaded_items',
      'loadedItems',
      'products',
    ]);

    return _VehicleStockSession(
      id: _readString(source, const ['id', '_id', 'session_id', 'sessionId']),
      vehicleNumber: _firstNonEmpty([
        _readString(source, const ['vehicle_number', 'vehicleNumber']),
        _readString(vehicle, const ['number', 'vehicle_number', 'vehicleNumber']),
      ]),
      vehicleType: _firstNonEmpty([
        _readString(source, const ['vehicle_type', 'vehicleType']),
        _readString(vehicle, const ['type', 'model', 'vehicle_type']),
      ]),
      partnerName: _firstNonEmpty([
        _readString(source, const [
          'delivery_partner_name',
          'deliveryPartnerName',
          'driver_name',
          'driverName',
        ]),
        _readString(partner, const ['name', 'full_name', 'fullName']),
      ]),
      status: _readString(source, const ['status', 'session_status', 'sessionStatus']),
      sessionDate: _parseDateTime(
        _readString(source, const [
          'session_date',
          'sessionDate',
          'date',
          'loading_date',
          'loadingDate',
        ]),
      ),
      startedAt: _parseDateTime(
        _readString(source, const [
          'session_started',
          'sessionStarted',
          'started_at',
          'startedAt',
          'created_at',
          'createdAt',
        ]),
      ),
      updatedAt: _parseDateTime(
        _readString(source, const [
          'last_updated',
          'lastUpdated',
          'updated_at',
          'updatedAt',
        ]),
      ),
      items: itemRows.map(_VehicleStockItem.fromJson).toList(),
    );
  }

  double get totalLoaded => items.fold(0, (sum, item) => sum + item.loaded);
  double get totalDelivered => items.fold(0, (sum, item) => sum + item.delivered);
  double get totalReturned => items.fold(0, (sum, item) => sum + item.returned);
  double get totalRemaining => items.fold(0, (sum, item) => sum + item.remaining);
}

class _VehicleStockItem {
  final String productName;
  final String variantId;
  final double loaded;
  final double delivered;
  final double returned;
  final double remaining;
  final String imageUrl;

  const _VehicleStockItem({
    required this.productName,
    required this.variantId,
    required this.loaded,
    required this.delivered,
    required this.returned,
    required this.remaining,
    required this.imageUrl,
  });

  factory _VehicleStockItem.fromJson(Map<String, dynamic> json) {
    final product = _readMap(json, const ['product']);
    final loaded = _readDouble(json, const [
      'loaded_quantity',
      'loadedQuantity',
      'loaded_qty',
      'loaded',
      'quantity',
    ]);
    final delivered = _readDouble(json, const [
      'delivered_quantity',
      'deliveredQuantity',
      'delivered_qty',
      'delivered',
    ]);
    final returned = _readDouble(json, const [
      'returned_quantity',
      'returnedQuantity',
      'returned_qty',
      'returned',
    ]);
    final explicitRemaining = _readNullableDouble(json, const [
      'remaining_quantity',
      'remainingQuantity',
      'remaining_qty',
      'remaining',
      'current_quantity',
      'currentQuantity',
    ]);

    return _VehicleStockItem(
      productName: _firstNonEmpty([
        _readString(json, const ['product_name', 'productName', 'name']),
        _readString(product, const ['name', 'product_name', 'productName']),
      ]),
      variantId: _firstNonEmpty([
        _readString(json, const ['variant_id', 'variantId', 'variant']),
        _readString(product, const ['variant_id', 'variantId']),
      ]),
      loaded: loaded,
      delivered: delivered,
      returned: returned,
      remaining: explicitRemaining ?? (loaded - delivered - returned),
      imageUrl: _firstNonEmpty([
        _readString(json, const ['image', 'image_url', 'imageUrl', 'photo']),
        _readString(product, const ['image', 'image_url', 'imageUrl', 'photo']),
      ]),
    );
  }
}

class _VehicleStockException implements Exception {
  final String message;

  const _VehicleStockException(this.message);

  @override
  String toString() => message;
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
  }
  return const {};
}

List<Map<String, dynamic>> _readList(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
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

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    final text = value.trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}

double _readDouble(Map<String, dynamic> json, List<String> keys) {
  return _readNullableDouble(json, keys) ?? 0;
}

double? _readNullableDouble(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.replaceAll(',', '').trim());
      if (parsed != null) return parsed;
    }
  }
  return null;
}

DateTime? _parseDateTime(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

String _formatDate(DateTime? value) {
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
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}';
}

String _formatDateTime(DateTime? value) {
  if (value == null) return '-';
  return '${_formatDate(value)}, ${_formatTime(value)}';
}

String _formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour == 0
      ? 12
      : local.hour > 12
          ? local.hour - 12
          : local.hour;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '${hour.toString().padLeft(2, '0')}:$minute $period';
}

String _qty(double value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(1);
}

String _titleCase(String value) {
  return value
      .replaceAll('_', ' ')
      .split(' ')
      .where((part) => part.trim().isNotEmpty)
      .map((part) {
        final text = part.trim().toLowerCase();
        return '${text[0].toUpperCase()}${text.substring(1)}';
      })
      .join(' ');
}

String _cleanError(Object? error) {
  final text = error?.toString().trim() ?? '';
  if (text.isEmpty) return 'Something went wrong.';
  return text.replaceFirst('ApiException: ', '');
}
