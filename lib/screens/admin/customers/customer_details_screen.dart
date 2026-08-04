import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import 'add_customer_screen.dart';

String _formatMoneyValue(num value) {
  final text = value.toDouble() % 1 == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
  final parts = text.split('.');
  final whole = parts.first;
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    final fromEnd = whole.length - i;
    buffer.write(whole[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) {
      buffer.write(',');
    }
  }
  final fraction = parts.length > 1 ? '.${parts.last}' : '';
  return '\u20B9$buffer$fraction';
}

class CustomerDetailsScreen extends StatefulWidget {
  final String customerId;
  final CustomerModel? initialCustomer;

  const CustomerDetailsScreen({
    super.key,
    required this.customerId,
    this.initialCustomer,
  });

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  late ApiProvider _apiProvider;
  bool _providerReady = false;
  bool _isLoading = true;
  String? _errorMessage;
  CustomerModel? _customer;

  @override
  void initState() {
    super.initState();
    _customer = widget.initialCustomer;
    _isLoading = _customer == null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final customer = await _apiProvider.fetchCustomerById(widget.customerId);
      if (!mounted) return;
      setState(() {
        _customer = customer;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openEdit() async {
    final customer = _customer;
    if (customer == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddCustomerScreen(
          customerId: customer.id,
          existingCustomer: customer,
        ),
      ),
    );

    if (result != null && mounted) {
      await _loadCustomer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = _customer;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _DetailsTopBar(
              title: 'Customer Details',
              onBack: () => Navigator.of(context).maybePop(),
              onRefresh: _loadCustomer,
              onEdit: _openEdit,
              enabled: customer != null,
            ),
            Expanded(
              child: _isLoading && customer == null
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCustomer,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                        child: customer == null
                            ? _ErrorState(
                                message: _errorMessage ?? 'Customer not found.',
                                onRetry: _loadCustomer,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _HeroCard(customer: customer),
                                  const SizedBox(height: 12),
                                  _StatsGrid(customer: customer),
                                  const SizedBox(height: 12),
                                  _SectionCard(
                                    title: 'Contact Information',
                                    child: _ContactGrid(customer: customer),
                                  ),
                                  const SizedBox(height: 12),
                                  _SectionCard(
                                    title: 'Order & Transaction History',
                                    subtitle:
                                        'Activity recorded for this customer.',
                                    child: _HistoryCard(customer: customer),
                                  ),
                                ],
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

class _DetailsTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final VoidCallback onEdit;
  final bool enabled;

  const _DetailsTopBar({
    required this.title,
    required this.onBack,
    required this.onRefresh,
    required this.onEdit,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight.withValues(alpha: 0.85),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Customer profile and account summary',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            color: AppColors.textPrimary,
          ),
          IconButton(
            onPressed: enabled ? onEdit : null,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final CustomerModel customer;

  const _HeroCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final active = customer.isActive != false;
    final subtitle =
        customer.businessName ??
        customer.category ??
        customer.email ??
        'Customer profile';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(initials: customer.initials, active: active),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InlineChip(
                          icon: Icons.phone_outlined,
                          label: customer.phone ?? '--',
                        ),
                        _InlineChip(
                          icon: Icons.mail_outline_rounded,
                          label: customer.email ?? '--',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusChip(active: active),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.statusActiveBg
                  : AppColors.statusInactiveBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active
                    ? AppColors.statusActiveBg
                    : AppColors.statusInactiveBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  active ? Icons.verified_rounded : Icons.do_not_disturb_on,
                  size: 18,
                  color: active
                      ? AppColors.statusActiveText
                      : AppColors.statusInactiveText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    active
                        ? 'This customer is currently active.'
                        : 'This customer is currently inactive.',
                    style: TextStyle(
                      color: active
                          ? AppColors.statusActiveText
                          : AppColors.statusInactiveText,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
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

class _Avatar extends StatelessWidget {
  final String initials;
  final bool active;

  const _Avatar({required this.initials, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEAF6EB) : const Color(0xFFF7F7F7),
        shape: BoxShape.circle,
        border: Border.all(
          color: active
              ? const Color(0xFFCAE8CF)
              : AppColors.borderLight.withValues(alpha: 0.9),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 19,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool active;

  const _StatusChip({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: active ? AppColors.statusActiveBg : AppColors.statusInactiveBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.statusActiveText
                  : AppColors.statusInactiveText,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            active ? 'Active' : 'Inactive',
            style: TextStyle(
              color: active
                  ? AppColors.statusActiveText
                  : AppColors.statusInactiveText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InlineChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final CustomerModel customer;

  const _StatsGrid({required this.customer});

  @override
  Widget build(BuildContext context) {
    final cards = <_StatCardData>[
      _StatCardData(
        title: 'Total Orders',
        value: '0',
        icon: Icons.inventory_2_outlined,
        iconColor: const Color(0xFF0F5A16),
        iconBg: const Color(0xFFE6F5E9),
      ),
      _StatCardData(
        title: 'Lifetime Value',
        value: _formatMoneyValue(customer.totalBilled ?? 0),
        icon: Icons.account_balance_wallet_outlined,
        iconColor: const Color(0xFF00B95A),
        iconBg: const Color(0xFFE8FBF1),
      ),
      _StatCardData(
        title: 'Credit Limit',
        value: _formatMoneyValue(customer.creditLimit ?? 0),
        icon: Icons.credit_card_rounded,
        iconColor: const Color(0xFF3372FF),
        iconBg: const Color(0xFFE6EEFF),
      ),
      _StatCardData(
        title: 'Outstanding Balance',
        value: _formatMoneyValue(customer.outstanding ?? 0),
        icon: Icons.currency_rupee_rounded,
        iconColor: const Color(0xFFFF9F0A),
        iconBg: const Color(0xFFFFF0D9),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: compact ? 2 : 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: compact ? 1.55 : 1.75,
          ),
          itemBuilder: (context, index) => _StatCard(data: cards[index]),
        );
      },
    );
  }
}

class _StatCardData {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: data.iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(data.icon, size: 14, color: data.iconColor),
              ),
            ],
          ),
          const Spacer(),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({required this.title, required this.child, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ContactGrid extends StatelessWidget {
  final CustomerModel customer;

  const _ContactGrid({required this.customer});

  @override
  Widget build(BuildContext context) {
    final items = <_ContactItem>[
      _ContactItem(label: 'Phone', value: customer.phone ?? '--'),
      _ContactItem(label: 'Email', value: customer.email ?? '--'),
      _ContactItem(label: 'GST Number', value: customer.gstNumber ?? '--'),
      _ContactItem(
        label: 'Assigned Sales Officer',
        value:
            customer.assignedSalesOfficerName ??
            customer.assignedSalesOfficerId ??
            '--',
      ),
      _ContactItem(
        label: 'Billing Address',
        value: customer.billingAddress ?? '--',
      ),
      _ContactItem(
        label: 'Delivery Address',
        value: customer.deliveryAddress ?? '--',
      ),
      _ContactItem(label: 'Category', value: customer.category ?? '--'),
      _ContactItem(label: 'Notes', value: customer.notes ?? '--'),
    ];

    final rows = <Widget>[];
    for (var index = 0; index < items.length; index += 2) {
      final left = items[index];
      final right = index + 1 < items.length ? items[index + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _ContactDetail(item: left)),
            if (right != null) ...[
              const SizedBox(width: 16),
              Expanded(child: _ContactDetail(item: right)),
            ],
          ],
        ),
      );
      if (index + 2 < items.length) {
        rows.add(const SizedBox(height: 14));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

class _ContactItem {
  final String label;
  final String value;

  const _ContactItem({required this.label, required this.value});
}

class _ContactDetail extends StatelessWidget {
  final _ContactItem item;

  const _ContactDetail({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.borderLight.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final CustomerModel customer;

  const _HistoryCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.9)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _MiniMetric(
                label: 'Opening Balance',
                value: _formatMoneyValue(customer.openingBalance ?? 0),
                icon: Icons.payments_outlined,
              ),
              const SizedBox(width: 10),
              _MiniMetric(
                label: 'Total Received',
                value: _formatMoneyValue(customer.totalReceived ?? 0),
                icon: Icons.south_west_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Center(
              child: Text(
                'No orders recorded for this customer yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.9),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.adminSidebarBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 17, color: AppColors.primary),
            ),
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
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
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

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 46,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () {
                onRetry();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
