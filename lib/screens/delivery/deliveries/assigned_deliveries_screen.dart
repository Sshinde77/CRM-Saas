import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/delivery/delivery_partner_sidebar.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';
import 'delivery_detail_screen.dart';

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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeliveryDetailScreen(deliveryId: delivery.id),
      ),
    );
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
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
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
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 40,
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search by order, customer or status...',
                hintStyle: const TextStyle(
                  color: Color(0xFF5D667A),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF4A546B),
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
                  borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E7F0)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        PopupMenuButton<String>(
          initialValue: statusFilter,
          onSelected: onStatusChanged,
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'all', child: Text('All deliveries')),
            PopupMenuItem(value: 'planned', child: Text('Planned')),
            PopupMenuItem(value: 'accepted', child: Text('Accepted')),
            PopupMenuItem(value: 'ready', child: Text('Ready')),
            PopupMenuItem(value: 'loaded', child: Text('Loaded')),
            PopupMenuItem(value: 'in_transit', child: Text('In transit')),
            PopupMenuItem(value: 'delivered', child: Text('Delivered')),
          ],
          child: Container(
            width: 40,
            height: 40,
            decoration: _surfaceDecoration(radius: 10),
            child: const Icon(Icons.tune_rounded, color: Color(0xFF4A546B)),
          ),
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _surfaceDecoration(radius: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F6E7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.deliveryGreen,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Deliveries',
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 16,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total Deliveries',
                  style: const TextStyle(
                    color: Color(0xFF4F5870),
                    fontSize: 11.5,
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
                  'Sort by: ${sort.label}',
                  style: const TextStyle(
                    color: Color(0xFF31394D),
                    fontSize: 11.5,
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
  final VoidCallback onViewDetails;

  const _DeliveryCard({
    required this.delivery,
    required this.isBusy,
    this.showActions = true,
    required this.onAccept,
    required this.onReject,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final statusTone = _StatusTone.forStatus(delivery.status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(12),
      decoration: _surfaceDecoration(radius: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  delivery.orderNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 16,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StatusPill(delivery: delivery, tone: statusTone),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  children: [
                    _InfoLine(
                      icon: Icons.person_outline_rounded,
                      label: delivery.customerName,
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoLine(
                            icon: Icons.calendar_month_outlined,
                            label: delivery.formattedDate,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoLine(
                            icon: Icons.access_time_rounded,
                            label: delivery.formattedTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    _InfoLine(
                      icon: delivery.paymentIcon,
                      label: delivery.paymentLabel,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 64,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: const Color(0xFFE0E5EE),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount Due',
                      style: const TextStyle(
                        color: Color(0xFF4F5870),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      delivery.formattedAmountDue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.secondaryStrong.copyWith(
                        color: AppColors.deliveryInk,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _DetailsButton(onTap: onViewDetails),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showActions && delivery.canRespond) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isBusy ? null : onReject,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: AppSizes.iconMedium,
                    ),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deliveryRed,
                      side: const BorderSide(color: Color(0xFFF3B1B1)),
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.controlRadius,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: isBusy ? null : onAccept,
                    icon: isBusy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.check_rounded,
                            size: AppSizes.iconMedium,
                          ),
                    label: const Text('Accept'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.deliveryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.controlRadius,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
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
          onViewDetails: () {},
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final _AssignedDelivery delivery;
  final _StatusTone tone;

  const _StatusPill({required this.delivery, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: tone.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tone.icon, size: 14, color: tone.foreground),
          const SizedBox(width: 4),
          Text(
            delivery.statusLabel,
            style: AppTextStyles.smallStrong.copyWith(
              color: tone.foreground,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoLine({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF31394D)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.secondaryStrong.copyWith(
              color: AppColors.deliveryInk,
              fontSize: 12.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DetailsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE1E6EF)),
        ),
        child: const Icon(
          Icons.visibility_rounded,
          color: AppColors.deliveryGreen,
          size: 16,
        ),
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
    );
  }

  bool get canRespond => status == 'planned';

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
}

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
  return value.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
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
