import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/delivery/delivery_partner_sidebar.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';

class AssignedDeliveriesScreen extends StatefulWidget {
  const AssignedDeliveriesScreen({super.key});

  @override
  State<AssignedDeliveriesScreen> createState() =>
      _AssignedDeliveriesScreenState();
}

class _AssignedDeliveriesScreenState extends State<AssignedDeliveriesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _busyDeliveryIds = <String>{};
  List<_AssignedDelivery> _deliveries = const [];
  bool _isLoading = true;
  bool _didStartLoad = false;
  String? _error;
  String _statusFilter = 'all';
  _DeliverySort _sort = _DeliverySort.scheduledDate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didStartLoad) {
      _didStartLoad = true;
      _loadDeliveries();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = ApiProviderScope.of(context);
      final authMe = await provider.fetchAuthMe();
      final currentUser = provider.currentUser ?? authMe?.user;
      final deliveryPartnerId = currentUser?.id?.trim();

      if (deliveryPartnerId == null || deliveryPartnerId.isEmpty) {
        throw const _DeliveryListException('Delivery partner id is missing.');
      }

      final rows = await provider.fetchDeliveryPartnerDeliveries(
        deliveryPartnerId: deliveryPartnerId,
      );
      if (!mounted) return;
      setState(() {
        _deliveries = rows.map(_AssignedDelivery.fromJson).toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _deliveries = const [];
        _error = _cleanError(error);
        _isLoading = false;
      });
    }
  }

  Future<void> _accept(_AssignedDelivery delivery) async {
    if (_busyDeliveryIds.contains(delivery.id)) return;
    setState(() => _busyDeliveryIds.add(delivery.id));

    try {
      final provider = ApiProviderScope.of(context);
      final updated = await provider.acceptDelivery(delivery.id);
      final nextDelivery = _AssignedDelivery.fromJson(updated);
      if (!mounted) return;
      setState(() {
        _deliveries = _deliveries
            .map((item) => item.id == delivery.id ? nextDelivery : item)
            .toList();
      });
      _showSnack(
        title: 'Delivery accepted',
        message: '${delivery.orderNumber} is ready to load.',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      _showSnack(
        title: 'Unable to accept',
        message: _cleanError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _busyDeliveryIds.remove(delivery.id));
      }
    }
  }

  Future<void> _updateDeliveryStatus({
    required _AssignedDelivery delivery,
    required String status,
    required String successTitle,
    required String successMessage,
  }) async {
    if (_busyDeliveryIds.contains(delivery.id)) return;
    setState(() => _busyDeliveryIds.add(delivery.id));

    try {
      final provider = ApiProviderScope.of(context);
      final updated = await provider.confirmDelivery(
        deliveryId: delivery.id,
        payload: {'status': status},
      );
      final nextDelivery = _AssignedDelivery.fromJson(updated);
      if (!mounted) return;
      setState(() {
        _deliveries = _deliveries
            .map((item) => item.id == delivery.id ? nextDelivery : item)
            .toList();
      });
      _showSnack(title: successTitle, message: successMessage, isError: false);
    } catch (error) {
      if (!mounted) return;
      _showSnack(
        title: 'Unable to update delivery',
        message: _cleanError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _busyDeliveryIds.remove(delivery.id));
      }
    }
  }

  Future<void> _startDelivery(_AssignedDelivery delivery) {
    return _updateDeliveryStatus(
      delivery: delivery,
      status: 'in_transit',
      successTitle: 'Delivery started',
      successMessage: '${delivery.orderNumber} is now in transit.',
    );
  }

  Future<void> _markDelivered(_AssignedDelivery delivery) {
    return _updateDeliveryStatus(
      delivery: delivery,
      status: 'delivered',
      successTitle: 'Delivery completed',
      successMessage: '${delivery.orderNumber} was marked as delivered.',
    );
  }

  Future<void> _callCustomer(_AssignedDelivery delivery) async {
    final phone = delivery.customerPhone.trim();
    if (phone.isEmpty) {
      _showSnack(
        title: 'Phone unavailable',
        message: 'Customer phone number is missing for this delivery.',
        isError: true,
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: phone);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _showSnack(
        title: 'Unable to call',
        message: 'Could not open the phone dialer.',
        isError: true,
      );
    }
  }

  Future<void> _navigateToCustomer(_AssignedDelivery delivery) async {
    final uri = delivery.directionsUri;
    if (uri == null) {
      _showSnack(
        title: 'Location unavailable',
        message: 'Customer location is missing for this delivery.',
        isError: true,
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _showSnack(
        title: 'Unable to open maps',
        message: 'Could not open navigation for this delivery.',
        isError: true,
      );
    }
  }

  Future<void> _reject(_AssignedDelivery delivery) async {
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RejectDeliverySheet(
          delivery: delivery,
          controller: reasonController,
          formKey: formKey,
        );
      },
    );

    if (confirmed != true) {
      reasonController.dispose();
      return;
    }

    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (reason.isEmpty) {
      _showSnack(
        title: 'Reason required',
        message: 'Enter a reason for rejecting this delivery.',
        isError: true,
      );
      return;
    }

    setState(() => _busyDeliveryIds.add(delivery.id));
    try {
      final provider = ApiProviderScope.of(context);
      await provider.rejectDelivery(deliveryId: delivery.id, reason: reason);
      if (!mounted) return;
      setState(() {
        _deliveries = _deliveries
            .where((item) => item.id != delivery.id)
            .toList();
      });
      _showSnack(
        title: 'Delivery rejected',
        message: 'The admin has been notified to reassign this delivery.',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      _showSnack(
        title: 'Unable to reject',
        message: _cleanError(error),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _busyDeliveryIds.remove(delivery.id));
      }
    }
  }

  void _viewDetails(_AssignedDelivery delivery) {
    Navigator.of(context).pushNamed(AppRoutes.deliveryDetail(delivery.id));
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label screen is coming next.')));
  }

  void _navigateBottomItem(String label, String? route) {
    if (route == null) {
      _showComingSoon(label);
      return;
    }
    Navigator.of(context).pushNamed(route);
  }

  void _showSnack({
    required String title,
    required String message,
    required bool isError,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? AppColors.deliveryRed
              : AppColors.deliveryGreen,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(message),
            ],
          ),
        ),
      );
  }

  List<_AssignedDelivery> get _visibleDeliveries {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _deliveries.where((delivery) {
      final matchesStatus =
          _statusFilter == 'all' || delivery.status == _statusFilter;
      if (!matchesStatus) return false;
      if (query.isEmpty) return true;
      return delivery.orderNumber.toLowerCase().contains(query) ||
          delivery.deliveryNumber.toLowerCase().contains(query) ||
          delivery.customerName.toLowerCase().contains(query) ||
          delivery.statusLabel.toLowerCase().contains(query);
    }).toList();

    filtered.sort((a, b) {
      return switch (_sort) {
        _DeliverySort.scheduledDate => a.scheduledDateSort.compareTo(
          b.scheduledDateSort,
        ),
        _DeliverySort.amountDue => b.amountDue.compareTo(a.amountDue),
        _DeliverySort.status => a.statusLabel.compareTo(b.statusLabel),
      };
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final visibleDeliveries = _visibleDeliveries;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF7F9FC),
      drawer: const DeliveryPartnerSidebar(
        currentRoute: AppRoutes.deliveryDeliveries,
      ),
      bottomNavigationBar: _DeliveryBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.deliveryDashboard,
                (route) => false,
              );
            case 1:
              break;
            case 2:
              _navigateBottomItem('Collections', null);
            case 3:
              _navigateBottomItem('Attendance', AppRoutes.deliveryAttendance);
            case 4:
              _scaffoldKey.currentState?.openDrawer();
          }
        },
      ),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.deliveryGreen,
          onRefresh: _loadDeliveries,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: DeliveryTopBar(
                  title: 'Assigned Deliveries',
                  subtitle: 'View and manage assigned deliveries',
                  leadingIcon: Icons.menu_rounded,
                  onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Column(
                        children: [
                          _SearchAndFilterBar(
                            controller: _searchController,
                            statusFilter: _statusFilter,
                            onStatusChanged: (value) {
                              setState(() => _statusFilter = value);
                            },
                          ),
                          const SizedBox(height: 10),
                          _SummaryCard(
                            total: _deliveries.length,
                            sort: _sort,
                            onSortChanged: (value) {
                              setState(() => _sort = value);
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _LoadingState(),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorState(
                    message: _error!,
                    onRetry: _loadDeliveries,
                  ),
                )
              else if (visibleDeliveries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    hasFilters:
                        _searchController.text.trim().isNotEmpty ||
                        _statusFilter != 'all',
                    onReset: () {
                      _searchController.clear();
                      setState(() => _statusFilter = 'all');
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
                  sliver: SliverList.separated(
                    itemCount: visibleDeliveries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final delivery = visibleDeliveries[index];
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 820),
                          child: _DeliveryCard(
                            delivery: delivery,
                            isBusy: _busyDeliveryIds.contains(delivery.id),
                            onAccept: delivery.canRespond
                                ? () => _accept(delivery)
                                : null,
                            onReject: delivery.canRespond
                                ? () => _reject(delivery)
                                : null,
                            onStartDelivery: delivery.canStartDelivery
                                ? () => _startDelivery(delivery)
                                : null,
                            onMarkDelivered: delivery.canMarkDelivered
                                ? () => _markDelivered(delivery)
                                : null,
                            onCallCustomer: delivery.canContactCustomer
                                ? () => _callCustomer(delivery)
                                : null,
                            onNavigateCustomer: delivery.canContactCustomer
                                ? () => _navigateToCustomer(delivery)
                                : null,
                            onViewDetails: () => _viewDetails(delivery),
                          ),
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

class _SearchAndFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final String statusFilter;
  final ValueChanged<String> onStatusChanged;

  const _SearchAndFilterBar({
    required this.controller,
    required this.statusFilter,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              hintText: 'Search by order, customer or status...',
              hintStyle: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
              suffixIcon: controller.text.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: controller.clear,
                      icon: const Icon(Icons.close_rounded),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.deliverySurfaceBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.deliverySurfaceBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.deliveryGreen),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _statusFilterTabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final tab = _statusFilterTabs[index];
              final selected = tab.value == statusFilter;
              return _FilterTab(
                tab: tab,
                selected: selected,
                onTap: () => onStatusChanged(tab.value),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  final _StatusFilterInfo tab;
  final bool selected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.deliveryGreen : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.deliveryGreen
                : AppColors.deliverySurfaceBorder,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.deliveryGreen.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Text(
          tab.label,
          style: TextStyle(
            color: selected ? AppColors.surface : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DeliveryBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _DeliveryBottomNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      _BottomNavInfo(Icons.home_rounded, 'Dashboard'),
      _BottomNavInfo(Icons.assignment_outlined, 'Orders'),
      _BottomNavInfo(Icons.account_balance_wallet_outlined, 'Collections'),
      _BottomNavInfo(Icons.event_available_outlined, 'Attendance'),
      _BottomNavInfo(Icons.more_horiz_rounded, 'More'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 76,
        margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          gradient: const LinearGradient(
            colors: [
              AppColors.deliveryDashboardNavStart,
              AppColors.deliveryDashboardNavEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deliveryHeroShadow.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: _BottomNavItem(
                  info: items[index],
                  selected: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final _BottomNavInfo info;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.info,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.deliveryDashboardNavActive.withValues(alpha: 0.78)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(info.icon, color: AppColors.surface, size: selected ? 25 : 23),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                info.label,
                maxLines: 1,
                style: TextStyle(
                  color: AppColors.surface.withValues(
                    alpha: selected ? 1 : 0.88,
                  ),
                  fontSize: selected ? 11 : 10,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int total;
  final _DeliverySort sort;
  final ValueChanged<_DeliverySort> onSortChanged;

  const _SummaryCard({
    required this.total,
    required this.sort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: _surfaceDecoration(radius: 10),
      child: Row(
        children: [
          Container(
            width: compact ? 34 : 38,
            height: compact ? 34 : 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F6E7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: AppColors.deliveryGreen,
              size: compact ? 18 : 21,
            ),
          ),
          SizedBox(width: compact ? 8 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Deliveries',
                  style: TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: compact ? 14 : 16,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total Deliveries',
                  style: TextStyle(
                    color: Color(0xFF4F5870),
                    fontSize: compact ? 10.5 : 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<_DeliverySort>(
            initialValue: sort,
            onSelected: onSortChanged,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _DeliverySort.scheduledDate,
                child: Text('Scheduled Date'),
              ),
              PopupMenuItem(
                value: _DeliverySort.amountDue,
                child: Text('Amount Due'),
              ),
              PopupMenuItem(value: _DeliverySort.status, child: Text('Status')),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  compact ? sort.shortLabel : 'Sort by: ${sort.label}',
                  style: TextStyle(
                    color: Color(0xFF31394D),
                    fontSize: compact ? 10.5 : 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(Icons.expand_more_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final _AssignedDelivery delivery;
  final bool isBusy;
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onStartDelivery;
  final VoidCallback? onMarkDelivered;
  final VoidCallback? onCallCustomer;
  final VoidCallback? onNavigateCustomer;
  final VoidCallback onViewDetails;

  const _DeliveryCard({
    required this.delivery,
    required this.isBusy,
    this.showActions = true,
    required this.onAccept,
    required this.onReject,
    required this.onStartDelivery,
    required this.onMarkDelivered,
    required this.onCallCustomer,
    required this.onNavigateCustomer,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final statusTone = _StatusTone.forStatus(delivery.status);
    final compact = MediaQuery.sizeOf(context).width < 360;
    final action = showActions
        ? _DeliveryCardAction.forDelivery(
            delivery,
            onAccept: onAccept,
            onStartDelivery: onStartDelivery,
            onMarkDelivered: onMarkDelivered,
          )
        : null;

    return InkWell(
      onTap: onViewDetails,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.fromLTRB(
          compact ? 12 : 16,
          compact ? 12 : 14,
          compact ? 10 : 12,
          compact ? 12 : 14,
        ),
        decoration: _surfaceDecoration(radius: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.orderNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.deliveryInk,
                          fontSize: compact ? 14 : 15,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        delivery.formattedDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: compact ? 10.5 : 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _StatusPill(
                  delivery: delivery,
                  tone: statusTone,
                  compact: compact,
                ),
              ],
            ),
            SizedBox(height: compact ? 14 : 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: compact ? 10 : 11,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DeliveryCardLabel('Customer', compact: compact),
                      const SizedBox(height: 4),
                      Text(
                        delivery.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.deliveryInk,
                          fontSize: compact ? 12.5 : 14,
                          height: 1.12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: compact ? 10 : 12),
                      Text(
                        delivery.formattedAmountDue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.deliveryGreen,
                          fontSize: compact ? 15 : 17,
                          height: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: compact ? 6 : 10),
                Expanded(
                  flex: compact ? 7 : 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DeliveryCardLabel('Payment', compact: compact),
                      const SizedBox(height: 4),
                      Text(
                        delivery.paymentLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.deliveryInk,
                          fontSize: compact ? 12.5 : 14,
                          height: 1.12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: 8),
                  _DeliveryCardActions(
                    primaryAction: action,
                    busy: isBusy,
                    compact: compact,
                    onCallCustomer: delivery.canContactCustomer
                        ? onCallCustomer
                        : null,
                    onNavigateCustomer: delivery.canContactCustomer
                        ? onNavigateCustomer
                        : null,
                  ),
                ] else ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.deliveryInk,
                    size: 20,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryCardActions extends StatelessWidget {
  final _DeliveryCardAction primaryAction;
  final bool busy;
  final bool compact;
  final VoidCallback? onCallCustomer;
  final VoidCallback? onNavigateCustomer;

  const _DeliveryCardActions({
    required this.primaryAction,
    required this.busy,
    required this.compact,
    required this.onCallCustomer,
    required this.onNavigateCustomer,
  });

  @override
  Widget build(BuildContext context) {
    final iconActions = <Widget>[
      if (onCallCustomer != null)
        _DeliveryIconActionButton(
          icon: Icons.call_rounded,
          tooltip: 'Call customer',
          onPressed: onCallCustomer,
          compact: compact,
          background: AppColors.deliveryGreenSoft,
          foreground: AppColors.deliveryGreen,
        ),
      if (onNavigateCustomer != null)
        _DeliveryIconActionButton(
          icon: Icons.navigation_rounded,
          tooltip: 'Navigate',
          onPressed: onNavigateCustomer,
          compact: compact,
          background: AppColors.deliveryGreenSoft,
          foreground: AppColors.deliveryGreen,
        ),
    ];

    if (iconActions.isEmpty) {
      return _DeliveryActionButton(
        action: primaryAction,
        busy: busy,
        compact: compact,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.end,
          spacing: compact ? 5 : 6,
          runSpacing: compact ? 5 : 6,
          children: iconActions,
        ),
        SizedBox(height: compact ? 6 : 8),
        _DeliveryActionButton(
          action: primaryAction,
          busy: busy,
          compact: compact,
        ),
      ],
    );
  }
}

class _DeliveryIconActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool compact;
  final Color background;
  final Color foreground;
  final bool busy;

  const _DeliveryIconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.compact,
    required this.background,
    required this.foreground,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 32.0 : 34.0;
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: size,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: busy ? null : onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Center(
              child: busy
                  ? SizedBox(
                      width: compact ? 14 : 15,
                      height: compact ? 14 : 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: foreground,
                      ),
                    )
                  : Icon(icon, color: foreground, size: compact ? 17 : 18),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryActionButton extends StatelessWidget {
  final _DeliveryCardAction action;
  final bool busy;
  final bool compact;

  const _DeliveryActionButton({
    required this.action,
    required this.busy,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : action.onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: action.background,
        foregroundColor: action.foreground,
        minimumSize: Size(0, compact ? 30 : 32),
        padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: SizedBox(
        width: compact ? 82 : 108,
        child: Center(
          child: busy
              ? SizedBox(
                  width: compact ? 13 : 15,
                  height: compact ? 13 : 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: action.foreground,
                  ),
                )
              : FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    action.label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: compact ? 10.5 : 12,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _DeliveryCardAction {
  final String label;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;

  const _DeliveryCardAction({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
  });

  static _DeliveryCardAction? forDelivery(
    _AssignedDelivery delivery, {
    required VoidCallback? onAccept,
    required VoidCallback? onStartDelivery,
    required VoidCallback? onMarkDelivered,
  }) {
    if (delivery.canRespond && onAccept != null) {
      return _DeliveryCardAction(
        label: 'Accept',
        onPressed: onAccept,
        background: AppColors.deliveryGreen,
        foreground: AppColors.surface,
      );
    }
    if (delivery.canStartDelivery && onStartDelivery != null) {
      return _DeliveryCardAction(
        label: 'Start Delivery',
        onPressed: onStartDelivery,
        background: AppColors.deliveryBlue,
        foreground: AppColors.surface,
      );
    }
    if (delivery.canMarkDelivered && onMarkDelivered != null) {
      return _DeliveryCardAction(
        label: 'Mark Delivered',
        onPressed: onMarkDelivered,
        background: AppColors.deliveryGreen,
        foreground: AppColors.surface,
      );
    }
    return null;
  }
}

class _DeliveryCardLabel extends StatelessWidget {
  final String label;
  final bool compact;

  const _DeliveryCardLabel(this.label, {required this.compact});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: AppColors.textMuted,
        fontSize: compact ? 10.5 : 12,
        height: 1,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _RejectDeliverySheet extends StatelessWidget {
  final _AssignedDelivery delivery;
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;

  const _RejectDeliverySheet({
    required this.delivery,
    required this.controller,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9DEE8),
                    borderRadius: BorderRadius.circular(AppSizes.pillRadius),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Reject ${delivery.orderNumber}',
                style: AppTextStyles.sectionHeading.copyWith(
                  color: AppColors.deliveryInk,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                delivery.customerName,
                style: AppTextStyles.secondaryStrong.copyWith(
                  color: const Color(0xFF586176),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                autofocus: true,
                minLines: 4,
                maxLines: 5,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a reason for rejecting this delivery.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Reason for rejection',
                  filled: true,
                  fillColor: const Color(0xFFF7F9FC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    borderSide: const BorderSide(color: Color(0xFFE1E6EF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    borderSide: const BorderSide(color: Color(0xFFE1E6EF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    borderSide: const BorderSide(color: AppColors.deliveryRed),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.controlRadius,
                          ),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.deliveryRed,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.controlRadius,
                          ),
                        ),
                      ),
                      child: const Text('Confirm Rejection'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryDetailsPreviewScreen extends StatelessWidget {
  final _AssignedDelivery delivery;

  const _DeliveryDetailsPreviewScreen({required this.delivery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(delivery.orderNumber),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.deliveryInk,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: _DeliveryCard(
          delivery: delivery,
          isBusy: false,
          showActions: false,
          onAccept: null,
          onReject: null,
          onStartDelivery: null,
          onMarkDelivered: null,
          onCallCustomer: null,
          onNavigateCustomer: null,
          onViewDetails: () {},
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final _AssignedDelivery delivery;
  final _StatusTone tone;
  final bool compact;

  const _StatusPill({
    required this.delivery,
    required this.tone,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 7,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tone.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            delivery.statusLabel,
            style: TextStyle(
              color: tone.foreground,
              fontSize: compact ? 10.5 : 12,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.deliveryGreen),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(16),
          decoration: _surfaceDecoration(radius: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: AppColors.deliveryRed,
                size: AppSizes.iconLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Deliveries could not load',
                style: AppTextStyles.sectionHeading.copyWith(
                  color: AppColors.deliveryInk,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.secondary.copyWith(
                  color: const Color(0xFF586176),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.deliveryGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(124, 38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onReset;

  const _EmptyState({required this.hasFilters, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F6E7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.deliveryGreen,
                size: 30,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              hasFilters ? 'No matching deliveries' : 'No assigned deliveries',
              style: const TextStyle(
                color: AppColors.deliveryInk,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters
                  ? 'Clear filters to view your assigned queue.'
                  : 'New deliveries assigned by admin will appear here.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF586176),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.filter_alt_off_rounded),
                label: const Text('Reset filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AssignedDelivery {
  final String id;
  final String deliveryNumber;
  final String orderNumber;
  final String customerName;
  final String status;
  final DateTime? scheduledDate;
  final double amountDue;
  final int items;
  final String vehicleNumber;
  final String warehouseName;
  final String deliveryPartnerName;
  final String paymentMode;
  final String customerPhone;
  final String deliveryAddress;
  final double? customerLatitude;
  final double? customerLongitude;

  const _AssignedDelivery({
    required this.id,
    required this.deliveryNumber,
    required this.orderNumber,
    required this.customerName,
    required this.status,
    required this.scheduledDate,
    required this.amountDue,
    required this.items,
    required this.vehicleNumber,
    required this.warehouseName,
    required this.deliveryPartnerName,
    required this.paymentMode,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.customerLatitude,
    required this.customerLongitude,
  });

  factory _AssignedDelivery.fromJson(Map<String, dynamic> json) {
    final id = _readString(json, const ['id', 'delivery_id']) ?? '';
    final orderId = _readNestedString(json, 'order', const [
      'order_number',
      'orderNumber',
      'number',
    ]);
    final customerName =
        _readString(json, const ['customerName', 'customer_name']) ??
        _readNestedString(json, 'customer', const ['name', 'full_name']) ??
        _readNestedString(json, 'order', const ['customer_name']) ??
        'Customer';

    return _AssignedDelivery(
      id: id,
      deliveryNumber:
          _readString(json, const [
            'deliveryNumber',
            'delivery_number',
            'deliveryNo',
          ]) ??
          (id.isEmpty ? 'DEL-NEW' : 'DEL-${id.toUpperCase()}'),
      orderNumber:
          _readString(json, const ['orderNumber', 'order_number', 'orderNo']) ??
          orderId ??
          (id.isEmpty ? 'ORD-NEW' : 'ORD-${id.toUpperCase()}'),
      customerName: customerName,
      status: _normalizeStatus(
        _readString(json, const ['status', 'delivery_status']) ?? 'planned',
      ),
      scheduledDate: _parseDateTime(
        _readString(json, const [
          'scheduledDate',
          'scheduled_date',
          'scheduled_at',
          'date',
        ]),
      ),
      amountDue: _readDouble(json, const [
        'amountDue',
        'amount_due',
        'due_amount',
        'due',
        'balance_amount',
      ]),
      items:
          _readInt(json, const ['items', 'item_count', 'items_count']) ??
          _readListLength(json, const ['delivery_items', 'order_items']) ??
          0,
      vehicleNumber:
          _readString(json, const ['vehicleNumber', 'vehicle_number']) ??
          _readNestedString(json, 'vehicle', const [
            'number',
            'vehicle_number',
          ]) ??
          '',
      warehouseName:
          _readString(json, const ['warehouseName', 'warehouse_name']) ??
          _readNestedString(json, 'warehouse', const ['name']) ??
          '',
      deliveryPartnerName:
          _readString(json, const [
            'deliveryPartnerName',
            'delivery_partner_name',
          ]) ??
          _readNestedString(json, 'delivery_partner', const ['name']) ??
          '',
      paymentMode: _normalizePaymentMode(
        _readString(json, const [
              'paymentMode',
              'payment_mode',
              'paymentMethod',
              'payment_method',
            ]) ??
            '',
      ),
      customerPhone:
          _readString(json, const [
            'customerPhone',
            'customer_phone',
            'phone',
            'phone_number',
            'mobile',
            'mobile_number',
            'contact_number',
          ]) ??
          _readNestedString(json, 'customer', const [
            'phone',
            'phone_number',
            'mobile',
            'mobile_number',
            'contact_number',
          ]) ??
          _readNestedString(json, 'order', const [
            'customerPhone',
            'customer_phone',
            'phone',
            'mobile',
            'contact_number',
          ]) ??
          '',
      deliveryAddress:
          _readString(json, const [
            'deliveryAddress',
            'delivery_address',
            'shippingAddress',
            'shipping_address',
            'address',
          ]) ??
          _readNestedString(json, 'order', const [
            'deliveryAddress',
            'delivery_address',
            'shippingAddress',
            'shipping_address',
            'address',
          ]) ??
          _readNestedString(json, 'customer', const [
            'deliveryAddress',
            'delivery_address',
            'shippingAddress',
            'shipping_address',
            'address',
          ]) ??
          '',
      customerLatitude:
          _readNullableDouble(json, const [
            'latitude',
            'lat',
            'map_latitude',
            'maps_latitude',
            'customer_lat',
            'customer_latitude',
          ]) ??
          _readNestedDouble(json, 'customer', const ['latitude', 'lat']) ??
          _readNestedDouble(json, 'customer', const [
            'map_latitude',
            'maps_latitude',
          ]) ??
          _readNestedDouble(json, 'order', const ['latitude', 'lat']) ??
          _readNestedDouble(json, 'order', const [
            'map_latitude',
            'maps_latitude',
          ]) ??
          _readNestedDouble(json, 'location', const ['latitude', 'lat']) ??
          _readPathDouble(
            json,
            const ['customer', 'address_information', 'google_maps_location'],
            const ['latitude', 'lat'],
          ) ??
          _readNestedDouble(json, 'delivery_location', const [
            'latitude',
            'lat',
          ]),
      customerLongitude:
          _readNullableDouble(json, const [
            'longitude',
            'lng',
            'map_longitude',
            'maps_longitude',
            'customer_lng',
            'customer_long',
            'customer_longitude',
          ]) ??
          _readNestedDouble(json, 'customer', const [
            'longitude',
            'lng',
            'long',
          ]) ??
          _readNestedDouble(json, 'customer', const [
            'map_longitude',
            'maps_longitude',
          ]) ??
          _readNestedDouble(json, 'order', const [
            'longitude',
            'lng',
            'long',
          ]) ??
          _readNestedDouble(json, 'order', const [
            'map_longitude',
            'maps_longitude',
          ]) ??
          _readNestedDouble(json, 'location', const [
            'longitude',
            'lng',
            'long',
          ]) ??
          _readPathDouble(
            json,
            const ['customer', 'address_information', 'google_maps_location'],
            const ['longitude', 'lng', 'long'],
          ) ??
          _readNestedDouble(json, 'delivery_location', const [
            'longitude',
            'lng',
            'long',
          ]),
    );
  }

  bool get canRespond => status == 'planned' || status == 'pending';

  bool get canStartDelivery => status == 'accepted';

  bool get canMarkDelivered => status == 'in_transit';

  bool get canContactCustomer => status == 'accepted' || status == 'in_transit';

  Uri? get directionsUri {
    final latitude = customerLatitude;
    final longitude = customerLongitude;
    if (latitude != null && longitude != null) {
      return Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': '$latitude,$longitude',
      });
    }

    final address = deliveryAddress.trim();
    if (address.isEmpty) return null;
    return Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': address,
    });
  }

  int get scheduledDateSort =>
      scheduledDate?.millisecondsSinceEpoch ?? 8640000000000000;

  String get statusLabel {
    return switch (status) {
      'in_transit' => 'In Transit',
      'partially_delivered' => 'Partial',
      _ =>
        status
            .split('_')
            .where((part) => part.isNotEmpty)
            .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
            .join(' '),
    };
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

  String get formattedTime {
    final value = scheduledDate;
    if (value == null) return '--:--';
    final hour = value.hour > 12
        ? value.hour - 12
        : value.hour == 0
        ? 12
        : value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String get formattedAmountDue => _formatMoney(amountDue);

  String get paymentLabel {
    return switch (paymentMode) {
      'upi' => 'UPI Payment',
      'wallet' => 'Wallet',
      'debit_card' => 'Debit Card',
      'credit_card' => 'Credit Card',
      'card' => 'Card',
      'cash' || 'cod' => 'Cash',
      'bank_transfer' => 'Bank Transfer',
      _ =>
        paymentMode.isEmpty ? 'Payment pending' : statusLabelFor(paymentMode),
    };
  }

  IconData get paymentIcon {
    return switch (paymentMode) {
      'wallet' => Icons.account_balance_wallet_outlined,
      'cash' || 'cod' => Icons.payments_outlined,
      'upi' || 'bank_transfer' => Icons.account_balance_outlined,
      _ => Icons.credit_card_rounded,
    };
  }
}

class _StatusTone {
  final IconData icon;
  final Color foreground;
  final Color background;
  final Color border;

  const _StatusTone({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.border,
  });

  factory _StatusTone.forStatus(String status) {
    return switch (status) {
      'planned' => const _StatusTone(
        icon: Icons.calendar_month_outlined,
        foreground: Color(0xFF155EC7),
        background: Color(0xFFEAF3FF),
        border: Color(0xFFD4E8FF),
      ),
      'pending' => const _StatusTone(
        icon: Icons.pending_actions_outlined,
        foreground: Color(0xFF155EC7),
        background: Color(0xFFEAF3FF),
        border: Color(0xFFD4E8FF),
      ),
      'accepted' => const _StatusTone(
        icon: Icons.check_circle_outline_rounded,
        foreground: Color(0xFF15803D),
        background: Color(0xFFE8F7E8),
        border: Color(0xFFD4EFD3),
      ),
      'ready' => const _StatusTone(
        icon: Icons.delivery_dining_rounded,
        foreground: Color(0xFFF26B12),
        background: Color(0xFFFFF1DF),
        border: Color(0xFFFFDDB6),
      ),
      'loaded' => const _StatusTone(
        icon: Icons.local_shipping_outlined,
        foreground: Color(0xFF6D35D7),
        background: Color(0xFFF0E9FF),
        border: Color(0xFFE2D2FF),
      ),
      'in_transit' => const _StatusTone(
        icon: Icons.local_shipping_outlined,
        foreground: Color(0xFF155EC7),
        background: Color(0xFFEAF3FF),
        border: Color(0xFFD4E8FF),
      ),
      'delivered' => const _StatusTone(
        icon: Icons.done_all_rounded,
        foreground: Color(0xFF15803D),
        background: Color(0xFFE8F7E8),
        border: Color(0xFFD4EFD3),
      ),
      _ => const _StatusTone(
        icon: Icons.info_outline_rounded,
        foreground: Color(0xFF4F5870),
        background: Color(0xFFF1F4F8),
        border: Color(0xFFE1E6EF),
      ),
    };
  }
}

enum _DeliverySort {
  scheduledDate('Scheduled Date'),
  amountDue('Amount Due'),
  status('Status');

  final String label;

  const _DeliverySort(this.label);

  String get shortLabel {
    return switch (this) {
      _DeliverySort.scheduledDate => 'Date',
      _DeliverySort.amountDue => 'Amount',
      _DeliverySort.status => 'Status',
    };
  }
}

class _StatusFilterInfo {
  final String value;
  final String label;

  const _StatusFilterInfo(this.value, this.label);
}

class _BottomNavInfo {
  final IconData icon;
  final String label;

  const _BottomNavInfo(this.icon, this.label);
}

const List<_StatusFilterInfo> _statusFilterTabs = [
  _StatusFilterInfo('all', 'All'),
  _StatusFilterInfo('accepted', 'Accepted'),
  _StatusFilterInfo('pending', 'Pending'),
  _StatusFilterInfo('in_transit', 'Intransit'),
  _StatusFilterInfo('delivered', 'Delivered'),
];

BoxDecoration _surfaceDecoration({required double radius}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: const Color(0xFFE2E7F0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

String statusLabelFor(String value) {
  return value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _cleanError(Object error) {
  return error.toString().replaceFirst('ApiException: ', '').trim();
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
  if (parent is Map<String, dynamic>) {
    return _readString(parent, keys);
  }
  return null;
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
  if (parent is Map<String, dynamic>) {
    return _readNullableDouble(parent, keys);
  }
  return null;
}

double? _readPathDouble(
  Map<String, dynamic> json,
  List<String> path,
  List<String> keys,
) {
  dynamic current = json;
  for (final key in path) {
    if (current is! Map<String, dynamic>) return null;
    current = current[key];
  }
  if (current is Map<String, dynamic>) {
    return _readNullableDouble(current, keys);
  }
  return null;
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

int? _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }
  return null;
}

int? _readListLength(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) return value.length;
  }
  return null;
}

DateTime? _parseDateTime(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return DateTime.tryParse(value.trim())?.toLocal();
}

String _normalizeStatus(String value) {
  final normalized = value
      .trim()
      .toLowerCase()
      .replaceAll('-', '_')
      .replaceAll(' ', '_');
  return normalized == 'intransit' ? 'in_transit' : normalized;
}

String _normalizePaymentMode(String value) {
  return value.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
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

class _DeliveryListException implements Exception {
  final String message;

  const _DeliveryListException(this.message);

  @override
  String toString() => message;
}
