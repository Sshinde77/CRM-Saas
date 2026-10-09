import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/customer_activity_models.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/customer_avatar.dart';
import '../../../widgets/delivery/delivery_top_bar.dart';
import '../../shared/map_location_view_screen.dart';
import '../orders/delivery_customer_order_detail_screen.dart';

class DeliveryCustomerDetailScreen extends StatefulWidget {
  final String customerId;
  final CustomerModel? initialCustomer;

  const DeliveryCustomerDetailScreen({
    super.key,
    required this.customerId,
    this.initialCustomer,
  });

  @override
  State<DeliveryCustomerDetailScreen> createState() =>
      _DeliveryCustomerDetailScreenState();
}

class _DeliveryCustomerDetailScreenState
    extends State<DeliveryCustomerDetailScreen> {
  ApiProvider? _api;
  CustomerModel? _customer;
  CustomerLedger? _ledger;
  List<CustomerOrderRecord> _orders = const [];
  List<CustomerPaymentRecord> _payments = const [];
  List<CustomerVisitRecord> _visits = const [];
  bool _loading = true;
  String? _error;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _customer = widget.initialCustomer;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_api != null) return;
    _api = ApiProviderScope.of(context);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final customer = await _api!.fetchCustomerById(widget.customerId);
      final results = await Future.wait<Object>([
        _api!.fetchCustomerLedger(customer.id),
        _api!.fetchCustomerOrders(customer.id),
        _api!.fetchCustomerPayments(customer.id),
        _api!.fetchCustomerVisits(customer.id),
      ]);
      if (!mounted) return;
      setState(() {
        _customer = customer;
        _ledger = results[0] as CustomerLedger;
        _orders = results[1] as List<CustomerOrderRecord>;
        _payments = results[2] as List<CustomerPaymentRecord>;
        _visits = results[3] as List<CustomerVisitRecord>;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _call() async {
    final phone = _customer?.phone?.trim();
    if (phone == null || phone.isEmpty) return;
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  void _map() {
    final customer = _customer;
    if (customer?.mapLatitude == null || customer?.mapLongitude == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapLocationViewScreen(
          latitude: customer!.mapLatitude!,
          longitude: customer.mapLongitude!,
          title: customer.businessName ?? customer.name,
          subtitle: customer.deliveryAddress ?? customer.billingAddress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);
    final customer = _customer;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Theme(
        data: Theme.of(context).copyWith(textTheme: AppTextStyles.textTheme),
        child: Scaffold(
          backgroundColor: AppColors.deliveryBackground,
          body: SafeArea(
            child: Column(
              children: [
                DeliveryTopBar(
                  title: 'Customer Details',
                  subtitle: customer?.customerId ?? widget.customerId,
                  leadingIcon: Icons.arrow_back_rounded,
                  onLeadingTap: () => Navigator.of(context).pop(),
                  showNotification: false,
                  showProfile: false,
                  actions: [
                    DeliveryTopBarAction(
                      icon: Icons.refresh_rounded,
                      tooltip: 'Refresh customer',
                      onTap: _load,
                    ),
                  ],
                ),
                Expanded(
                  child: _loading && customer == null
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.deliveryGreen,
                          ),
                        )
                      : _error != null && customer == null
                      ? _ErrorState(message: _error!, onRetry: _load)
                      : RefreshIndicator(
                          color: AppColors.deliveryGreen,
                          onRefresh: _load,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                            children: [
                              Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 820,
                                  ),
                                  child: Column(
                                    children: [
                                      _ProfileCard(
                                        customer: customer!,
                                        photoUrl:
                                            customer.profilePhotoUrl ??
                                            widget.initialCustomer
                                                ?.profilePhotoUrl,
                                        onCall: _call,
                                        onMap: _map,
                                      ),
                                      const SizedBox(height: 12),
                                      _MetricsSection(
                                        child: _Metrics(
                                          sales:
                                              _ledger?.summary.totalBilled ??
                                              customer.totalBilled
                                                  ?.toDouble() ??
                                              0,
                                          pending:
                                              _ledger?.summary.outstanding ??
                                              customer.outstanding
                                                  ?.toDouble() ??
                                              0,
                                          orders: _orders.length,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _ActivityPanel(
                                        selected: _tab,
                                        onSelected: (value) =>
                                            setState(() => _tab = value),
                                        child: _tabBody(customer),
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
      ),
    );
  }

  Widget _tabBody(CustomerModel customer) {
    if (_error != null) {
      return _InlineError(onRetry: _load);
    }
    switch (_tab) {
      case 0:
        return _orders.isEmpty
            ? const _EmptyState(
                icon: Icons.receipt_long_outlined,
                label: 'No orders yet',
              )
            : Column(
                children: _orders
                    .map(
                      (order) => _OrderTile(
                        order: order,
                        onTap: order.id.trim().isEmpty
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DeliveryCustomerOrderDetailScreen(
                                        orderId: order.id,
                                        initialProgressStatus:
                                            order.fulfillment == '-'
                                            ? order.status
                                            : order.fulfillment,
                                      ),
                                ),
                              ),
                      ),
                    )
                    .toList(),
              );
      case 1:
        return _payments.isEmpty
            ? const _EmptyState(
                icon: Icons.payments_outlined,
                label: 'No collections yet',
              )
            : Column(
                children: _payments
                    .map((e) => _PaymentTile(payment: e))
                    .toList(),
              );
      case 2:
        return _visits.isEmpty
            ? const _EmptyState(
                icon: Icons.route_outlined,
                label: 'No visits yet',
              )
            : Column(
                children: _visits.map((e) => _VisitTile(visit: e)).toList(),
              );
      default:
        return _CustomerInfo(customer: customer);
    }
  }
}

class _ProfileCard extends StatelessWidget {
  final CustomerModel customer;
  final String? photoUrl;
  final VoidCallback onCall;
  final VoidCallback onMap;
  const _ProfileCard({
    required this.customer,
    this.photoUrl,
    required this.onCall,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    final business = customer.businessName?.trim().isNotEmpty == true
        ? customer.businessName!
        : customer.name;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.deliveryGreenSoft,
                  AppColors.deliveryBlueSoft,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deliveryHeroShadow.withValues(alpha: 0.10),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: CustomerAvatar(
              name: business,
              photoUrl: photoUrl,
              size: 112,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            business,
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionHeading.copyWith(
              color: AppColors.deliveryInk,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  customer.contactPerson ?? customer.name,
                  style: const TextStyle(
                    color: AppColors.deliveryInk,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 4,
            children: [
              _DateSummary(label: 'Last Order', date: customer.lastOrderDate),
              Container(
                width: 1,
                height: 34,
                color: AppColors.deliverySurfaceBorder,
              ),
              _DateSummary(label: 'Last Visit', date: customer.lastVisitDate),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundAction(
                icon: Icons.call_rounded,
                color: AppColors.deliveryGreen,
                enabled: customer.phone?.trim().isNotEmpty == true,
                onTap: onCall,
              ),
              const SizedBox(width: 20),
              _RoundAction(
                icon: Icons.location_on_rounded,
                color: AppColors.deliveryCustomerLocation,
                background: AppColors.deliveryCustomerLocationSoft,
                enabled:
                    customer.mapLatitude != null &&
                    customer.mapLongitude != null,
                onTap: onMap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateSummary extends StatelessWidget {
  final String label;
  final DateTime? date;
  const _DateSummary({required this.label, this.date});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        _date(date),
        style: const TextStyle(
          color: AppColors.deliveryInk,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? background;
  final bool enabled;
  final VoidCallback onTap;
  const _RoundAction({
    required this.icon,
    required this.color,
    this.background,
    required this.enabled,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: enabled
        ? (background ?? color.withValues(alpha: .08))
        : AppColors.borderLight,
    shape: CircleBorder(
      side: BorderSide(
        color: enabled ? color.withValues(alpha: .22) : AppColors.border,
      ),
    ),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 52,
        height: 52,
        child: Icon(
          icon,
          color: enabled ? color : AppColors.textLightMuted,
          size: 24,
        ),
      ),
    ),
  );
}

class _MetricsSection extends StatelessWidget {
  final Widget child;

  const _MetricsSection({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: _cardDecoration(),
    child: child,
  );
}

class _Metrics extends StatelessWidget {
  final double sales;
  final double pending;
  final int orders;
  const _Metrics({
    required this.sales,
    required this.pending,
    required this.orders,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _MetricCard(
          label: 'Total Sales',
          value: _money(sales),
          icon: Icons.bar_chart_rounded,
          color: AppColors.deliveryCustomerSales,
          tint: AppColors.deliveryCustomerSalesSoft,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _MetricCard(
          label: 'Pending Amount',
          value: _money(pending),
          icon: Icons.currency_rupee_rounded,
          color: AppColors.deliveryCustomerPending,
          tint: AppColors.deliveryCustomerPendingSoft,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _MetricCard(
          label: 'Total Orders',
          value: '$orders',
          icon: Icons.receipt_long_outlined,
          color: AppColors.deliveryCustomerOrders,
          tint: AppColors.deliveryCustomerOrdersSoft,
        ),
      ),
    ],
  );
}

class _MetricCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, tint;
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.tint,
  });
  @override
  Widget build(BuildContext context) => Container(
    height: 104,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: tint,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: .16)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: AppColors.surface, size: 18),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: AppTextStyles.importantNumber.copyWith(
              color: AppColors.deliveryInk,
              fontSize: 15,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ActivityPanel extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;
  final Widget child;
  const _ActivityPanel({
    required this.selected,
    required this.onSelected,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Container(
    decoration: _cardDecoration(),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Row(
          children: List.generate(4, (index) {
            const labels = [
              'Orders',
              'Collections',
              'Visits',
              'Customer Details',
            ];
            final active = selected == index;
            return Expanded(
              child: InkWell(
                onTap: () => onSelected(index),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 13),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: active
                            ? AppColors.deliveryGreen
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      labels[index],
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: active
                            ? AppColors.deliveryGreen
                            : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const Divider(height: 1, color: AppColors.deliverySurfaceBorder),
        Padding(padding: const EdgeInsets.all(12), child: child),
      ],
    ),
  );
}

class _OrderTile extends StatelessWidget {
  final CustomerOrderRecord order;
  final VoidCallback? onTap;
  const _OrderTile({required this.order, required this.onTap});
  @override
  Widget build(BuildContext context) => _RecordTile(
    icon: Icons.description_outlined,
    title: order.orderNumber,
    subtitle: _dateTime(order.date),
    amount: _money(order.total),
    status: order.fulfillment == '-' ? order.status : order.fulfillment,
    onTap: onTap,
  );
}

class _PaymentTile extends StatelessWidget {
  final CustomerPaymentRecord payment;
  const _PaymentTile({required this.payment});
  @override
  Widget build(BuildContext context) => _RecordTile(
    icon: Icons.account_balance_wallet_outlined,
    title: payment.referenceNumber,
    subtitle: '${_dateTime(payment.date)}  •  ${_title(payment.method)}',
    amount: _money(payment.amount),
    status: payment.status,
  );
}

class _VisitTile extends StatelessWidget {
  final CustomerVisitRecord visit;
  const _VisitTile({required this.visit});
  @override
  Widget build(BuildContext context) => _RecordTile(
    icon: Icons.route_outlined,
    title: _title(visit.purpose),
    subtitle: visit.notes?.trim().isNotEmpty == true
        ? '${_dateTime(visit.date)}  •  ${visit.notes}'
        : _dateTime(visit.date),
    amount: visit.outcome == '-' ? '' : _title(visit.outcome),
    status: visit.status,
  );
}

class _RecordTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle, amount, status;
  final VoidCallback? onTap;
  const _RecordTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final tone = _statusColor(status);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.deliverySurfaceBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.deliveryBlueSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: AppColors.deliveryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.deliveryInk,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (amount.isNotEmpty)
                    Text(
                      amount,
                      style: AppTextStyles.bodyStrong.copyWith(
                        color: AppColors.deliveryInk,
                      ),
                    ),
                  if (amount.isNotEmpty) const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      _title(status),
                      style: TextStyle(
                        color: tone,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerInfo extends StatelessWidget {
  final CustomerModel customer;
  const _CustomerInfo({required this.customer});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      _InfoSection(
        title: 'Contact Information',
        icon: Icons.person_outline_rounded,
        rows: [
          _InfoRow('Contact Person', customer.contactPerson ?? customer.name),
          _InfoRow('Phone', customer.phone),
          _InfoRow('Email', customer.email),
          _InfoRow('Category', customer.category),
        ],
      ),
      const SizedBox(height: 12),
      _InfoSection(
        title: 'Address & Business',
        icon: Icons.storefront_outlined,
        rows: [
          _InfoRow(
            'Delivery Address',
            customer.deliveryAddress ?? customer.billingAddress,
          ),
          _InfoRow(
            'City / State',
            [
              customer.city,
              customer.state,
            ].where((e) => e?.trim().isNotEmpty == true).join(', '),
          ),
          _InfoRow('GST Number', customer.gstNumber),
          _InfoRow('Territory', customer.territory),
        ],
      ),
    ],
  );
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoRow> rows;
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.rows,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.deliveryCardSoft,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.deliverySurfaceBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.deliveryGreen),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(
                color: AppColors.deliveryInk,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(rows.length, (index) {
          final row = rows[index];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        row.label,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        row.value?.trim().isNotEmpty == true ? row.value! : '-',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: AppColors.deliveryInk,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < rows.length - 1)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.deliverySurfaceBorder,
                ),
            ],
          );
        }),
      ],
    ),
  );
}

class _InfoRow {
  final String label;
  final String? value;
  const _InfoRow(this.label, this.value);
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EmptyState({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36),
    child: Column(
      children: [
        Icon(icon, size: 48, color: AppColors.textLightMuted),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 52,
            color: AppColors.textLightMuted,
          ),
          const SizedBox(height: 12),
          const Text(
            'Could not load customer details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ),
    ),
  );
}

class _InlineError extends StatelessWidget {
  final VoidCallback onRetry;
  const _InlineError({required this.onRetry});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Column(
      children: [
        const Text(
          'Some activity could not be loaded.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Retry'),
        ),
      ],
    ),
  );
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: AppColors.deliverySurfaceBorder),
  boxShadow: [
    BoxShadow(
      color: AppColors.secondary.withValues(alpha: 0.035),
      blurRadius: 14,
      offset: const Offset(0, 8),
    ),
  ],
);

String _date(DateTime? value) {
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
  return '${value.day.toString().padLeft(2, '0')} ${months[value.month - 1]} ${value.year}';
}

String _dateTime(DateTime? value) {
  if (value == null) return '-';
  final hour = value.hour == 0
      ? 12
      : value.hour > 12
      ? value.hour - 12
      : value.hour;
  return '${_date(value)}  •  ${hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')} ${value.hour >= 12 ? 'PM' : 'AM'}';
}

String _money(double amount) {
  final digits = amount.round().abs().toString();
  if (digits.length <= 3) return '${amount < 0 ? '-' : ''}₹$digits';
  final last = digits.substring(digits.length - 3);
  var lead = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (lead.length > 2) {
    groups.insert(0, lead.substring(lead.length - 2));
    lead = lead.substring(0, lead.length - 2);
  }
  if (lead.isNotEmpty) groups.insert(0, lead);
  return '${amount < 0 ? '-' : ''}₹${groups.join(',')},$last';
}

String _title(String value) => value.trim().isEmpty || value == '-'
    ? '-'
    : value
          .split(RegExp(r'[_\s]+'))
          .map(
            (e) => e.isEmpty
                ? ''
                : '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}',
          )
          .join(' ');

Color _statusColor(String value) {
  final status = value.toLowerCase();
  if (status.contains('deliver') ||
      status.contains('paid') ||
      status.contains('complete') ||
      status.contains('success')) {
    return AppColors.deliveryGreen;
  }
  if (status.contains('progress') ||
      status.contains('confirm') ||
      status.contains('schedule')) {
    return AppColors.deliveryBlue;
  }
  if (status.contains('cancel') ||
      status.contains('fail') ||
      status.contains('overdue')) {
    return AppColors.deliveryRed;
  }
  return AppColors.textMuted;
}
