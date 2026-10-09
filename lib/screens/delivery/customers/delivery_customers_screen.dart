import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../routes/app_router.dart';
import '../../../widgets/customer_avatar.dart';
import '../../../widgets/delivery/delivery_bottom_navigation.dart';
import '../../../widgets/delivery/delivery_partner_sidebar.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';
import '../../shared/map_location_view_screen.dart';
import 'delivery_customer_detail_screen.dart';
import 'create_delivery_customer_screen.dart';

class DeliveryCustomersScreen extends StatefulWidget {
  const DeliveryCustomersScreen({super.key});

  @override
  State<DeliveryCustomersScreen> createState() =>
      _DeliveryCustomersScreenState();
}

class _DeliveryCustomersScreenState extends State<DeliveryCustomersScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _search = TextEditingController();
  List<CustomerModel> _customers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadCustomers();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final customers = await ApiProviderScope.of(context).fetchCustomers();
      if (!mounted) return;
      setState(() => _customers = customers);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Could not load customers. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createCustomer() async {
    final customer = await Navigator.of(context).push<CustomerModel>(
      MaterialPageRoute(builder: (_) => const CreateDeliveryCustomerScreen()),
    );
    if (customer != null && mounted) {
      _search.clear();
      await _loadCustomers();
    }
  }

  void _openCustomerDetail(CustomerModel customer) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DeliveryCustomerDetailScreen(
          customerId: customer.id,
          initialCustomer: customer,
        ),
      ),
    );
  }

  Future<void> _callCustomer(CustomerModel customer) async {
    final phone = customer.phone?.trim();
    if (phone == null || phone.isEmpty) return;
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  void _openCustomerMap(CustomerModel customer) {
    final latitude = customer.mapLatitude;
    final longitude = customer.mapLongitude;
    if (latitude == null || longitude == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapLocationViewScreen(
          latitude: latitude,
          longitude: longitude,
          title: customer.businessName ?? customer.name,
          subtitle: customer.deliveryAddress ?? customer.billingAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);
    final query = _search.text.trim().toLowerCase();
    final customers = _customers.where((customer) {
      return [
        customer.name,
        customer.businessName,
        customer.phone,
        customer.customerId,
        customer.city,
        customer.territory,
      ].whereType<String>().any((value) => value.toLowerCase().contains(query));
    }).toList();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.deliveryBackground,
        drawer: const DeliveryPartnerSidebar(
          currentRoute: AppRoutes.deliveryCustomers,
        ),
        bottomNavigationBar: const DeliveryBottomNavigation(currentIndex: -1),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              DeliveryTopBar(
                title: 'Customers',
                subtitle: 'View and search your customers',
                leadingIcon: Icons.menu_rounded,
                onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
                actions: [
                  DeliveryTopBarAction(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Refresh customers',
                    onTap: _loadCustomers,
                  ),
                ],
              ),
              Expanded(
                child: _loading
                    ? const _StateView.loading()
                    : _error != null
                    ? _StateView.error(
                        message: _error!,
                        onRetry: _loadCustomers,
                      )
                    : RefreshIndicator(
                        color: AppColors.deliveryGreen,
                        onRefresh: _loadCustomers,
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
                                constraints: const BoxConstraints(
                                  maxWidth: 820,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _HeaderCard(
                                      total: _customers.length,
                                      onAdd: _createCustomer,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    _MetricsGrid(customers: _customers),
                                    const SizedBox(height: AppSpacing.md),
                                    _SearchCard(
                                      controller: _search,
                                      query: query,
                                      onChanged: (_) => setState(() {}),
                                      onClear: () => setState(_search.clear),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    _SectionHeader(
                                      title: 'Customer List',
                                      count: customers.length,
                                      trailingIcon: Icons.groups_2_outlined,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    if (customers.isEmpty)
                                      _StateView.empty(
                                        hasSearch: query.isNotEmpty,
                                      )
                                    else
                                      ...customers.map(
                                        (customer) => Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          child: _CustomerCard(
                                            customer: customer,
                                            onTap: () =>
                                                _openCustomerDetail(customer),
                                            onCall: () =>
                                                _callCustomer(customer),
                                            onMap: () =>
                                                _openCustomerMap(customer),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
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
}

class _HeaderCard extends StatelessWidget {
  final int total;
  final VoidCallback onAdd;

  const _HeaderCard({required this.total, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 420;

    return _SurfaceCard(
      padding: EdgeInsets.all(compact ? 10 : 12),
      child: Row(
        children: [
          Container(
            width: compact ? 34 : 38,
            height: compact ? 34 : 38,
            decoration: BoxDecoration(
              color: AppColors.deliveryGreenSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.groups_2_outlined,
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
                  'My Customers',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: compact ? 14 : 16,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total Customers',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF4F5870),
                    fontSize: compact ? 10.5 : 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.deliveryGreen,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(10),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.surface,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final List<CustomerModel> customers;

  const _MetricsGrid({required this.customers});

  @override
  Widget build(BuildContext context) {
    final active = customers.where((customer) => customer.isActive != false);
    final withLocation = customers.where((customer) {
      return _customerAddress(customer).trim().isNotEmpty ||
          (customer.mapLatitude != null && customer.mapLongitude != null);
    }).length;
    final withDue = customers.where((customer) {
      return (customer.outstanding ?? 0) > 0;
    }).length;
    final rows = [
      _MetricInfo(
        'Active',
        active.length.toString(),
        Icons.verified_outlined,
        AppColors.deliveryGreen,
        AppColors.deliveryGreenSoft,
      ),
      _MetricInfo(
        'Locations',
        withLocation.toString(),
        Icons.location_on_outlined,
        AppColors.deliveryBlue,
        AppColors.deliveryBlueSoft,
      ),
      _MetricInfo(
        'With Due',
        withDue.toString(),
        Icons.pending_actions_outlined,
        AppColors.deliveryRed,
        AppColors.deliveryRedSoft,
      ),
      _MetricInfo(
        'Territories',
        _uniqueCount(
          customers.map((customer) => customer.territory),
        ).toString(),
        Icons.map_outlined,
        AppColors.deliveryOrange,
        AppColors.deliveryOrangeSoft,
      ),
    ];

    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index += 2) ...[
            Row(
              children: [
                Expanded(child: _MetricTile(info: rows[index])),
                const SizedBox(width: 10),
                Expanded(child: _MetricTile(info: rows[index + 1])),
              ],
            ),
            if (index < rows.length - 2) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final _MetricInfo info;

  const _MetricTile({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.deliveryCardSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.deliveryCardBorder),
      ),
      child: Row(
        children: [
          _MiniIcon(
            icon: info.icon,
            color: info.color,
            background: info.background,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 14,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  info.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF586176),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
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

class _SearchCard extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchCard({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            color: AppColors.deliveryInk,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Search by name, phone, ID or city',
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.deliveryGreen,
              size: 20,
            ),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: onClear,
                  ),
            filled: true,
            fillColor: AppColors.deliveryCardSoft,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.deliverySurfaceBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.deliverySurfaceBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(color: AppColors.deliveryGreen),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onMap;

  const _CustomerCard({
    required this.customer,
    required this.onTap,
    required this.onCall,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = customer.isActive == false
        ? AppColors.deliveryRed
        : AppColors.deliveryGreen;
    final outstanding = customer.outstanding ?? 0;
    final businessName = _firstNonEmpty([
      customer.businessName,
      customer.name,
      'Customer',
    ]);
    final contactName = _firstNonEmpty([
      customer.contactPerson,
      customer.name,
      'Not set',
    ]);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: Ink(
          decoration: _surfaceDecoration(),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: ColoredBox(
                  color: statusColor,
                  child: const SizedBox(width: 3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomerAvatar(
                          name: businessName,
                          photoUrl: customer.profilePhotoUrl,
                          size: 52,
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
                                      businessName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.deliveryInk,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    outstanding > 0
                                        ? 'Order Pending'
                                        : 'No Pending Order',
                                    style: TextStyle(
                                      color: outstanding > 0
                                          ? AppColors.deliveryOrange
                                          : AppColors.textMuted,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _StatusBadge(
                                    label: customer.statusLabel,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textMuted,
                                    size: 18,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _firstNonEmpty([
                                  customer.customerId,
                                  'Customer ID not set',
                                ]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _CustomerCardDetail(
                                      label: 'Contact Person',
                                      value: contactName,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _CustomerCardDetail(
                                      label: 'Area',
                                      value: _firstNonEmpty([
                                        customer.city,
                                        customer.territory,
                                        customer.state,
                                        'Not set',
                                      ]),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _CustomerCardDetail(
                                      label: 'Amount',
                                      value: outstanding > 0
                                          ? _formatMoney(outstanding)
                                          : 'No due',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      height: 1,
                      color: AppColors.deliverySurfaceBorder,
                    ),
                    const SizedBox(height: 9),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _CustomerCardDetail(
                            label: 'Case Officer',
                            value: _firstNonEmpty([
                              customer.assignedSalesOfficerName,
                              'Not assigned',
                            ]),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CustomerCardDetail(
                            label: 'Last Visited',
                            value: _formatCustomerDate(customer.lastVisitDate),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CustomerActionIcon(
                          icon: Icons.phone_rounded,
                          enabled: customer.phone?.trim().isNotEmpty == true,
                          tooltip: 'Call customer',
                          onTap: onCall,
                        ),
                        const SizedBox(width: 4),
                        _CustomerActionIcon(
                          icon: Icons.location_on_outlined,
                          enabled:
                              customer.mapLatitude != null &&
                              customer.mapLongitude != null,
                          tooltip: 'View customer location',
                          onTap: onMap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerCardDetail extends StatelessWidget {
  final String label;
  final String value;

  const _CustomerCardDetail({required this.label, required this.value});

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

class _CustomerActionIcon extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final String tooltip;
  final VoidCallback onTap;

  const _CustomerActionIcon({
    required this.icon,
    required this.enabled,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      tooltip: tooltip,
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      padding: EdgeInsets.zero,
      splashRadius: 22,
      icon: Icon(icon, size: 20),
      color: AppColors.deliveryGreen,
      disabledColor: AppColors.textLightMuted,
    );
  }
}

// ignore: unused_element
class _InlineInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InlineInfo({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData trailingIcon;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$title ($count)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.deliveryInk,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Icon(trailingIcon, color: AppColors.deliveryGreen, size: 20),
      ],
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
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, color: color, size: 19),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final bool loading;

  const _StateView._({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
    this.loading = false,
  });

  const _StateView.loading()
    : this._(
        icon: Icons.hourglass_empty_rounded,
        title: 'Loading customers',
        subtitle: 'Fetching your latest customer list.',
        loading: true,
      );

  const _StateView.empty({required bool hasSearch})
    : this._(
        icon: Icons.groups_2_outlined,
        title: hasSearch ? 'No matching customers' : 'No customers found',
        subtitle: hasSearch
            ? 'Try a different name, phone, ID or city.'
            : 'Create your first delivery customer to get started.',
      );

  const _StateView.error({required String message, VoidCallback? onRetry})
    : this._(
        icon: Icons.error_outline_rounded,
        title: 'Customers could not load',
        subtitle: message,
        onRetry: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenSmall),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _SurfaceCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  const CircularProgressIndicator(
                    color: AppColors.deliveryGreen,
                  )
                else
                  Icon(icon, color: AppColors.deliveryGreen, size: 48),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ],
            ),
          ),
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
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: _surfaceDecoration(),
      child: child,
    );
  }
}

class _MetricInfo {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const _MetricInfo(
    this.label,
    this.value,
    this.icon,
    this.color,
    this.background,
  );
}

BoxDecoration _surfaceDecoration({double? radius}) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(radius ?? AppSizes.cardRadius),
    border: Border.all(color: AppColors.deliverySurfaceBorder),
    boxShadow: [
      BoxShadow(
        color: AppColors.secondary.withValues(alpha: 0.035),
        blurRadius: 14,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

String _customerAddress(CustomerModel customer) {
  return _firstNonEmpty([
    customer.deliveryAddress,
    customer.address,
    customer.billingAddress,
  ]);
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    final text = value?.trim();
    if (text != null && text.isNotEmpty) return text;
  }
  return '';
}

int _uniqueCount(Iterable<String?> values) {
  return values
      .map((value) => value?.trim().toLowerCase() ?? '')
      .where((value) => value.isNotEmpty)
      .toSet()
      .length;
}

String _formatMoney(int value) {
  final source = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < source.length; i++) {
    final remaining = source.length - i;
    buffer.write(source[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }
  return '${value < 0 ? '-' : ''}Rs ${buffer.toString()} due';
}

String _formatCustomerDate(DateTime? value) {
  if (value == null) return 'Not visited';
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
  final date = value.toLocal();
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
