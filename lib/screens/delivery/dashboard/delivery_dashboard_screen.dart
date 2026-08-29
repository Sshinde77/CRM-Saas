import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../providers/api_provider.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  late Future<_DashboardData> _dashboardFuture;
  bool _didStartLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _dashboardFuture = _loadDashboard();
      _didStartLoad = true;
    }
  }

  Future<_DashboardData> _loadDashboard() async {
    final provider = ApiProviderScope.of(context);
    final authMe = await provider.fetchAuthMe();
    final currentUser = provider.currentUser ?? authMe?.user;
    final deliveryPartnerId = currentUser?.id?.trim();

    if (deliveryPartnerId == null || deliveryPartnerId.isEmpty) {
      throw const _DashboardException('Delivery partner id is missing.');
    }

    final results = await Future.wait<dynamic>([
      provider.fetchDeliveryPartnerDeliveries(
        deliveryPartnerId: deliveryPartnerId,
      ),
      provider.fetchCurrentVehicleStock(deliveryPartnerId),
      provider.fetchMyAttendance(),
    ]);

    final deliveries = (results[0] as List<Map<String, dynamic>>)
        .map(_DeliveryItem.fromJson)
        .toList();
    final vehicleStock = _VehicleStockSession.fromJson(
      results[1] as Map<String, dynamic>?,
    );
    final attendanceRecords = (results[2] as List<Map<String, dynamic>>)
        .map(_AttendanceRecord.fromJson)
        .toList();

    return _DashboardData(
      userName: currentUser?.name ?? 'Partner',
      deliveries: deliveries,
      vehicleStock: vehicleStock,
      todayAttendance: _AttendanceRecord.todayFrom(attendanceRecords),
    );
  }

  Future<void> _refresh() async {
    final nextFuture = _loadDashboard();
    setState(() => _dashboardFuture = nextFuture);
    await nextFuture;
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label screen is coming next.')));
  }

  void _shareLocation() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Location API is ready. Add GPS permissions to send live coordinates.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deliveryBackground,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<_DashboardData>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData;
            final data = snapshot.data;

            return RefreshIndicator(
              color: AppColors.deliveryGreen,
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final horizontalPadding =
                            constraints.maxWidth >= 600 ? 12.0 : 10.0;

                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                10,
                                horizontalPadding,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Header(
                                    name: data?.firstName ?? 'Partner',
                                    onMenuTap: () => _showComingSoon('Menu'),
                                  ),
                                  const SizedBox(height: 12),
                                  if (isLoading)
                                    const _LoadingPanel()
                                  else if (snapshot.hasError)
                                    _ErrorPanel(
                                      message: snapshot.error.toString(),
                                      onRetry: () {
                                        setState(() {
                                          _dashboardFuture = _loadDashboard();
                                        });
                                      },
                                    )
                                  else if (data != null)
                                    _DashboardContent(
                                      data: data,
                                  onShareLocation: _shareLocation,
                                  onPendingDeliveries: () =>
                                      _showComingSoon('Attendance'),
                                      onEndDayReturn: () =>
                                          _showComingSoon('End day return'),
                                      onViewAllItems: () =>
                                          _showComingSoon('Vehicle stock'),
                                      onViewAllDeliveries: () =>
                                          _showComingSoon('My deliveries'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _DeliveryBottomNav(onTap: _showComingSoon),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final _DashboardData data;
  final VoidCallback onShareLocation;
  final VoidCallback onPendingDeliveries;
  final VoidCallback onEndDayReturn;
  final VoidCallback onViewAllItems;
  final VoidCallback onViewAllDeliveries;

  const _DashboardContent({
    required this.data,
    required this.onShareLocation,
    required this.onPendingDeliveries,
    required this.onEndDayReturn,
    required this.onViewAllItems,
    required this.onViewAllDeliveries,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroSummaryCard(
          data: data,
          onShareLocation: onShareLocation,
          onPendingDeliveries: onPendingDeliveries,
          onEndDayReturn: onEndDayReturn,
        ),
        const SizedBox(height: 12),
        _StatsGrid(data: data),
        const SizedBox(height: 12),
        _CollectionsCard(data: data),
        const SizedBox(height: 12),
        _PrioritiesCard(data: data),
        const SizedBox(height: 12),
        _VehicleLoadCard(session: data.vehicleStock, onViewAll: onViewAllItems),
        const SizedBox(height: 12),
        _DeliveryStatusCard(data: data),
        const SizedBox(height: 12),
        _DeliveriesPreviewCard(
          deliveries: data.deliveries.take(4).toList(),
          onViewAll: onViewAllDeliveries,
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final VoidCallback onMenuTap;

  const _Header({required this.name, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          _IconButtonShell(
            icon: Icons.menu_rounded,
            color: AppColors.deliveryInk,
            onTap: onMenuTap,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning, $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deliveryInk,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Have a safe and productive day!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const _IconButtonShell(
                icon: Icons.notifications_none_rounded,
                color: AppColors.deliveryInk,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.deliveryRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroSummaryCard extends StatelessWidget {
  final _DashboardData data;
  final VoidCallback onShareLocation;
  final VoidCallback onPendingDeliveries;
  final VoidCallback onEndDayReturn;

  const _HeroSummaryCard({
    required this.data,
    required this.onShareLocation,
    required this.onPendingDeliveries,
    required this.onEndDayReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 168,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.deliveryHeroShadow.withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.deliveryHeroStart,
                      AppColors.deliveryHeroEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Image.asset(
                'assets/delivery1.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.deliveryHeroStart.withValues(alpha: 0.96),
                      AppColors.deliveryHeroStart.withValues(alpha: 0.80),
                      AppColors.deliveryHeroEnd.withValues(alpha: 0.42),
                    ],
                    stops: const [0, 0.54, 1],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.deliveryHeroEnd.withValues(alpha: 0.14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _HeroMetric(
                                      icon: Icons.verified_rounded,
                                      title: data.isCheckedIn
                                          ? 'Checked In Today'
                                          : 'Not checked in',
                                      value: data.checkInText,
                                      color: AppColors.deliveryGreen,
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 44,
                                    color: Colors.white.withValues(alpha: 0.20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _HeroMetric(
                                      title: "Today's Deliveries",
                                      value: data.deliveriesToday.toString(),
                                      color: Colors.white,
                                      isNumber: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.two_wheeler_rounded,
                                      size: 18,
                                      color: AppColors.deliveryHeroIcon,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Vehicle Number',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.78,
                                            ),
                                            fontSize: 11,
                                            height: 1.2,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          data.vehicleNumberText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _HeroAction(
                            icon: Icons.my_location_rounded,
                            label: 'Share Location',
                            color: AppColors.deliveryBlue,
                            onTap: onShareLocation,
                          ),
                        ),
                        const _HeroActionDivider(),
                        Expanded(
                          child: _HeroAction(
                            icon: data.isCheckedIn
                                ? Icons.event_available_outlined
                                : Icons.login_rounded,
                            label: data.isCheckedIn ? 'Attendance' : 'Check In',
                            color: AppColors.deliveryBlue,
                            onTap: onPendingDeliveries,
                          ),
                        ),
                        const _HeroActionDivider(),
                        Expanded(
                          child: _HeroAction(
                            icon: Icons.assignment_return_rounded,
                            label: 'End Day Return',
                            color: AppColors.deliveryRed,
                            onTap: onEndDayReturn,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String value;
  final Color color;
  final bool isNumber;

  const _HeroMetric({
    this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 11,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isNumber ? 24 : 15,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HeroAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: SizedBox(
        height: 44,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: AppColors.deliveryInk,
                  fontSize: 10,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroActionDivider extends StatelessWidget {
  const _HeroActionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: AppColors.border.withValues(alpha: 0.9),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final _DashboardData data;

  const _StatsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatInfo(
        icon: Icons.local_shipping_outlined,
        value: data.deliveriesToday,
        label: 'Deliveries Today',
        color: AppColors.deliveryBlue,
        background: AppColors.deliveryBlueSoft,
      ),
      _StatInfo(
        icon: Icons.check_circle_outline_rounded,
        value: data.completedToday,
        label: 'Completed Today',
        color: AppColors.deliveryGreen,
        background: AppColors.deliveryGreenSoft,
      ),
      _StatInfo(
        icon: Icons.schedule_rounded,
        value: data.pendingToday,
        label: 'Pending Today',
        color: AppColors.deliveryOrange,
        background: AppColors.deliveryOrangeSoft,
      ),
      _StatInfo(
        icon: Icons.currency_rupee_rounded,
        value: data.paymentPending,
        label: 'Payment Pending',
        color: AppColors.deliveryViolet,
        background: AppColors.deliveryVioletSoft,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.78,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) => _StatCard(info: stats[index]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatInfo info;

  const _StatCard({required this.info});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniIcon(
            icon: info.icon,
            color: info.color,
            background: info.background,
          ),
          const Spacer(),
          Text(
            info.value.toString(),
            style: const TextStyle(
              fontSize: 21,
              height: 1,
              fontWeight: FontWeight.w800,
              color: AppColors.deliveryInk,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.15,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionsCard extends StatelessWidget {
  final _DashboardData data;

  const _CollectionsCard({required this.data});

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
                _MiniIcon(
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.deliveryViolet,
                  background: Colors.white,
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
  final _CollectionInfo info;

  const _CollectionMetricTile({required this.info});

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
          _MiniIcon(icon: info.icon, color: info.color, background: Colors.white),
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

class _PrioritiesCard extends StatelessWidget {
  final _DashboardData data;

  const _PrioritiesCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final priorities = [
      _PriorityInfo(
        icon: Icons.priority_high_rounded,
        label: 'Needs your response',
        count: data.needsResponse,
        color: AppColors.deliveryRed,
        background: AppColors.deliveryRedSoft,
      ),
      _PriorityInfo(
        icon: Icons.outbox_rounded,
        label: 'Pending deliveries',
        count: data.pendingToday,
        color: AppColors.deliveryOrange,
        background: AppColors.deliveryOrangeBadge,
      ),
      _PriorityInfo(
        icon: Icons.warning_amber_rounded,
        label: 'Failed reattempts',
        count: data.failed,
        color: AppColors.deliveryYellow,
        background: AppColors.deliveryYellowSoft,
      ),
      _PriorityInfo(
        icon: Icons.currency_rupee_rounded,
        label: 'Payment pending',
        count: data.paymentPending,
        color: AppColors.deliveryViolet,
        background: AppColors.deliveryVioletBadge,
      ),
      _PriorityInfo(
        icon: Icons.inventory_2_outlined,
        label: 'Partial deliveries pending',
        count: data.partial,
        color: AppColors.deliveryBlue,
        background: AppColors.deliveryBlueBadge,
      ),
    ];

    return _SurfaceCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 8),
      child: Column(
        children: [
          const _SectionHeader(title: "Today's Priorities"),
          const SizedBox(height: 6),
          ...priorities.map((priority) => _PriorityRow(info: priority)),
        ],
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final _PriorityInfo info;

  const _PriorityRow({required this.info});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          _MiniIcon(icon: info.icon, color: info.color, background: info.background),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              info.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.deliveryInk,
              ),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 28),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: info.background,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              info.count.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: info.color,
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: AppColors.textLightMuted,
          ),
        ],
      ),
    );
  }
}

class _VehicleLoadCard extends StatelessWidget {
  final _VehicleStockSession? session;
  final VoidCallback onViewAll;

  const _VehicleLoadCard({required this.session, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final items = session?.items.take(3).toList() ?? const <_StockLine>[];

    return _SurfaceCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          _SectionHeader(
            title: 'Current Vehicle Load',
            trailingIcon: Icons.refresh_rounded,
            trailingText: session?.vehicleNumber,
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const SizedBox(
              height: 94,
              child: Center(
                child: Text(
                  'No active loading session',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ...items.map((item) => _StockLineRow(item: item)),
          _FooterLink(label: 'View All Items', onTap: onViewAll),
        ],
      ),
    );
  }
}

class _StockLineRow extends StatelessWidget {
  final _StockLine item;

  const _StockLineRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deliveryInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.variantLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.loadedQuantityText} Pcs',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.deliveryInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryStatusCard extends StatelessWidget {
  final _DashboardData data;

  const _DeliveryStatusCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _StatusInfo(
        'Awaiting Acceptance',
        data.needsResponse,
        AppColors.deliveryBlue,
      ),
      _StatusInfo('Ready', data.ready, AppColors.deliveryGreen),
      _StatusInfo('In Transit', data.inTransit, AppColors.deliveryOrange),
      _StatusInfo('Delivered', data.completedToday, AppColors.deliveryGreen),
      _StatusInfo('Failed', data.failed, AppColors.deliveryRed),
      _StatusInfo('Partial', data.partial, AppColors.deliveryViolet),
    ];

    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const _SectionHeader(title: 'Delivery Status'),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.25,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) => _StatusTile(info: tiles[index]),
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  final _StatusInfo info;

  const _StatusTile({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: info.color.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            info.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            info.count.toString(),
            style: TextStyle(
              fontSize: 19,
              height: 1,
              fontWeight: FontWeight.w900,
              color: info.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveriesPreviewCard extends StatelessWidget {
  final List<_DeliveryItem> deliveries;
  final VoidCallback onViewAll;

  const _DeliveriesPreviewCard({
    required this.deliveries,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          const _SectionHeader(title: 'My Deliveries'),
          const SizedBox(height: 8),
          if (deliveries.isEmpty)
            const SizedBox(
              height: 96,
              child: Center(
                child: Text(
                  'No deliveries assigned today',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            ...deliveries.map((delivery) => _DeliveryPreviewTile(delivery: delivery)),
          _FooterLink(label: 'View All Deliveries', onTap: onViewAll),
        ],
      ),
    );
  }
}

class _DeliveryPreviewTile extends StatelessWidget {
  final _DeliveryItem delivery;

  const _DeliveryPreviewTile({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(delivery.status);

    return Container(
      height: 104,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.deliveryCardSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.deliveryCardBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                delivery.orderNumber,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deliveryInk,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.visibility_outlined,
                size: 18,
                color: AppColors.deliveryBlue,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  delivery.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.deliveryInk,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                delivery.formattedAmount,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.deliveryInk,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                delivery.formattedDate,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  delivery.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'delivered' => AppColors.deliveryGreen,
      'failed' => AppColors.deliveryRed,
      'partially_delivered' => AppColors.deliveryViolet,
      'in_transit' => AppColors.deliveryOrange,
      'accepted' || 'loaded' => AppColors.deliveryBlue,
      _ => AppColors.textMuted,
    };
  }
}

class _DeliveryBottomNav extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _DeliveryBottomNav({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Row(
        children: [
          _BottomNavItem(
            icon: Icons.home_rounded,
            label: 'Dashboard',
            active: true,
            onTap: () {},
          ),
          _BottomNavItem(
            icon: Icons.inventory_2_outlined,
            label: 'Deliveries',
            onTap: () => onTap('Deliveries'),
          ),
          _BottomNavItem(
            icon: Icons.local_shipping_outlined,
            label: 'Stock',
            onTap: () => onTap('Stock'),
          ),
          _BottomNavItem(
            icon: Icons.more_horiz_rounded,
            label: 'More',
            onTap: () => onTap('More'),
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.deliveryBlue : AppColors.textMuted;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? trailingIcon;
  final String? trailingText;

  const _SectionHeader({
    required this.title,
    this.trailingIcon,
    this.trailingText,
  });

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
        if (trailingText != null && trailingText!.trim().isNotEmpty) ...[
          Flexible(
            child: Text(
              trailingText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
        if (trailingIcon != null)
          Icon(trailingIcon, size: 18, color: AppColors.deliveryBlue)
        else
          const Text(
            'View All',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.deliveryBlue,
            ),
          ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 36,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.deliveryBlue,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.deliveryBlue,
            ),
          ],
        ),
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
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
  final IconData icon;
  final Color color;
  final Color background;

  const _MiniIcon({
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _IconButtonShell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _IconButtonShell({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 24, color: color),
      ),
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
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({required this.message, required this.onRetry});

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
          const SizedBox(height: 10),
          const Text(
            'Dashboard could not load',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.deliveryInk,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.deliveryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(130, 42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _DashboardData {
  final String userName;
  final List<_DeliveryItem> deliveries;
  final _VehicleStockSession? vehicleStock;
  final _AttendanceRecord? todayAttendance;

  const _DashboardData({
    required this.userName,
    required this.deliveries,
    required this.vehicleStock,
    required this.todayAttendance,
  });

  String get firstName {
    final parts = userName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? 'Partner' : parts.first;
  }

  DateTime get _today => DateTime.now();

  List<_DeliveryItem> get todaysDeliveries {
    return deliveries.where((delivery) {
      final scheduled = delivery.scheduledDate;
      if (scheduled == null) return true;
      return scheduled.year == _today.year &&
          scheduled.month == _today.month &&
          scheduled.day == _today.day;
    }).toList();
  }

  int get deliveriesToday => todaysDeliveries.length;

  int get completedToday => todaysDeliveries
      .where((delivery) => delivery.status == 'delivered')
      .length;

  int get pendingToday => todaysDeliveries.where((delivery) {
        return const {'planned', 'accepted', 'loaded', 'in_transit'}
            .contains(delivery.status);
      }).length;

  int get paymentPending =>
      deliveries.where((delivery) => delivery.amountDue > 0).length;

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
    return deliveries.fold<double>(0, (sum, delivery) => sum + delivery.amountDue);
  }

  String get formattedTotalToCollect => _formatMoney(totalAmountToCollect);
  String get formattedTotalCollected => _formatMoney(totalAmountCollected);
  String get formattedCashInHand => _formatMoney(cashInHand);
  String get formattedBankTransfer => _formatMoney(bankTransfer);
  String get formattedPendingAmount => _formatMoney(pendingAmount);

  int get needsResponse =>
      deliveries.where((delivery) => delivery.status == 'planned').length;

  int get failed =>
      deliveries.where((delivery) => delivery.status == 'failed').length;

  int get partial => deliveries
      .where((delivery) => delivery.status == 'partially_delivered')
      .length;

  int get ready => deliveries
      .where(
        (delivery) =>
            delivery.status == 'accepted' || delivery.status == 'loaded',
      )
      .length;

  int get inTransit =>
      deliveries.where((delivery) => delivery.status == 'in_transit').length;

  bool get isCheckedIn => todayAttendance?.checkIn != null;

  String get checkInText {
    final checkIn = todayAttendance?.checkIn;
    if (checkIn == null) return 'Pending';
    final hour = checkIn.hour > 12
        ? checkIn.hour - 12
        : checkIn.hour == 0
            ? 12
            : checkIn.hour;
    final minute = checkIn.minute.toString().padLeft(2, '0');
    final period = checkIn.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get vehicleNumberText {
    final vehicleNumber = vehicleStock?.vehicleNumber.trim();
    return vehicleNumber == null || vehicleNumber.isEmpty
        ? 'Vehicle not assigned'
        : vehicleNumber;
  }
}

class _DeliveryItem {
  final String id;
  final String orderNumber;
  final String customerName;
  final DateTime? scheduledDate;
  final String status;
  final double amountDue;
  final double amountCollected;
  final String paymentMode;

  const _DeliveryItem({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.scheduledDate,
    required this.status,
    required this.amountDue,
    required this.amountCollected,
    required this.paymentMode,
  });

  factory _DeliveryItem.fromJson(Map<String, dynamic> json) {
    final id = _readString(json, const ['id', 'delivery_id']) ?? '';
    return _DeliveryItem(
      id: id,
      orderNumber:
          _readString(json, const ['orderNumber', 'order_number', 'orderNo']) ??
              'ORD-${id.isEmpty ? 'NEW' : id.toUpperCase()}',
      customerName:
          _readString(json, const ['customerName', 'customer_name']) ??
              _readNestedString(json, 'customer', const ['name']) ??
              'Customer',
      scheduledDate: _parseDate(
        _readString(json, const ['scheduledDate', 'scheduled_date', 'date']),
      ),
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

  String get formattedDate {
    final value = scheduledDate;
    if (value == null) return 'Not scheduled';
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
    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  String get formattedAmount {
    return _formatMoney(amountDue);
  }
}

class _VehicleStockSession {
  final String vehicleNumber;
  final List<_StockLine> items;

  const _VehicleStockSession({required this.vehicleNumber, required this.items});

  factory _VehicleStockSession.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const _VehicleStockSession(vehicleNumber: '', items: []);
    }

    final rawItems = json['items'] ?? json['lines'] ?? json['loading_items'];
    return _VehicleStockSession(
      vehicleNumber:
          _readString(json, const ['vehicleNumber', 'vehicle_number', 'vehicleNo']) ??
              '',
      items: rawItems is List
          ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(_StockLine.fromJson)
              .toList()
          : const [],
    );
  }
}

class _StockLine {
  final String productName;
  final String variantLabel;
  final double loadedQuantity;

  const _StockLine({
    required this.productName,
    required this.variantLabel,
    required this.loadedQuantity,
  });

  factory _StockLine.fromJson(Map<String, dynamic> json) {
    return _StockLine(
      productName:
          _readString(json, const ['productName', 'product_name', 'name']) ??
              'Product',
      variantLabel:
          _readString(json, const ['variantName', 'variant_name', 'variant']) ??
              _readNestedString(json, 'variant', const ['name', 'label']) ??
              'Loaded stock',
      loadedQuantity: _readDouble(
        json,
        const ['loadedQuantity', 'loaded_quantity', 'loaded_qty'],
      ),
    );
  }

  String get loadedQuantityText {
    if (loadedQuantity == loadedQuantity.roundToDouble()) {
      return loadedQuantity.round().toString();
    }
    return loadedQuantity.toStringAsFixed(1);
  }
}

class _AttendanceRecord {
  final DateTime? date;
  final DateTime? checkIn;

  const _AttendanceRecord({required this.date, required this.checkIn});

  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return _AttendanceRecord(
      date: _parseDate(_readString(json, const ['date', 'attendance_date'])),
      checkIn: _parseDateTime(
        _readString(json, const ['checkIn', 'check_in', 'office_check_in']),
      ),
    );
  }

  static _AttendanceRecord? todayFrom(List<_AttendanceRecord> records) {
    final today = DateTime.now();
    for (final record in records) {
      final date = record.date;
      if (date == null) continue;
      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        return record;
      }
    }
    return null;
  }
}

class _StatInfo {
  final IconData icon;
  final int value;
  final String label;
  final Color color;
  final Color background;

  const _StatInfo({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });
}

class _PriorityInfo {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final Color background;

  const _PriorityInfo({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.background,
  });
}

class _CollectionInfo {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color background;

  const _CollectionInfo({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });
}

class _StatusInfo {
  final String label;
  final int count;
  final Color color;

  const _StatusInfo(this.label, this.count, this.color);
}

class _DashboardException implements Exception {
  final String message;

  const _DashboardException(this.message);

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

DateTime? _parseDate(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value.trim());
}

DateTime? _parseDateTime(String? value) {
  final parsed = _parseDate(value);
  if (parsed != null) return parsed.toLocal();
  return null;
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
