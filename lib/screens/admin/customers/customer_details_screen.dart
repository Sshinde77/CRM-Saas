import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import 'add_customer_screen.dart';

double _safeMoneyNumber(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is bool || value == null) {
    return 0;
  }

  final normalized = value.toString().trim();
  if (normalized.isEmpty) {
    return 0;
  }

  final sanitized = normalized.replaceAll(RegExp(r'[^0-9.\-]'), '');
  return double.tryParse(sanitized) ?? 0;
}

String _formatMoneyValue(Object? value) {
  final amount = _safeMoneyNumber(value);
  final absolute = amount.abs().toStringAsFixed(amount % 1 == 0 ? 0 : 2);
  final parts = absolute.split('.');
  final whole = parts.first;
  final fraction = parts.length > 1 ? '.${parts.last}' : '';
  final lastThree = whole.length > 3 ? whole.substring(whole.length - 3) : whole;
  final leading = whole.length > 3 ? whole.substring(0, whole.length - 3) : '';
  final chunks = <String>[];
  var rest = leading;
  while (rest.length > 2) {
    chunks.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) {
    chunks.insert(0, rest);
  }
  final grouped = chunks.isEmpty ? lastThree : '${chunks.join(',')},$lastThree';
  final sign = amount < 0 ? '-' : '';
  return '$sign\u20B9$grouped$fraction';
}

String _displayText(String? value, {String fallback = '-'}) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
}

String _formatDate(DateTime? date) {
  if (date == null) return '-';
  const months = <String>[
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
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
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
  final Set<String> _expandedSections = {
    'contact',
    'business',
    'address',
    'financial',
  };

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadCustomer();
    });
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

  Future<void> _copyValue(String label, String value) async {
    if (value.trim().isEmpty || value == '-') return;
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied')),
    );
  }

  String _visibleCustomerId(CustomerModel customer) {
    final externalId = customer.customerId?.trim();
    return externalId == null || externalId.isEmpty ? customer.id : externalId;
  }

  void _showRecordPaymentMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record payment flow is not connected yet.')),
    );
  }

  void _showMoreActions() {
    final customer = _customer;
    if (customer == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 18),
                _ActionSheetTile(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh details',
                  onTap: () {
                    Navigator.of(context).pop();
                    _loadCustomer();
                  },
                ),
                _ActionSheetTile(
                  icon: Icons.copy_all_rounded,
                  label: 'Copy customer ID',
                  onTap: () {
                    Navigator.of(context).pop();
                    _copyValue('Customer ID', _visibleCustomerId(customer));
                  },
                ),
                _ActionSheetTile(
                  icon: Icons.edit_outlined,
                  label: 'Edit customer',
                  onTap: () {
                    Navigator.of(context).pop();
                    _openEdit();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_SectionConfig> _sectionsFor(CustomerModel customer) {
    final all = <_SectionConfig>[
      _SectionConfig(
        id: 'contact',
        title: '1. Contact Information',
        icon: Icons.call_outlined,
        child: _DetailsSection(
          columns: [
            _FieldColumn(
              items: [
                _FieldItem(
                  label: 'Primary Phone',
                  value: _displayText(customer.phone),
                  trailingIcon: Icons.call_rounded,
                  onTrailingTap: () => _copyValue('Phone', customer.phone ?? ''),
                ),
                _FieldItem(
                  label: 'Email Address',
                  value: _displayText(customer.email),
                  trailingIcon: Icons.mail_outline_rounded,
                  onTrailingTap: () => _copyValue('Email', customer.email ?? ''),
                ),
                _FieldItem(
                  label: 'Primary Contact Person',
                  value: _displayText(customer.contactPerson ?? customer.name),
                ),
                _FieldItem(
                  label: 'Alternate Mobile',
                  value: _displayText(customer.alternatePhone),
                ),
                _FieldItem(
                  label: 'Designation',
                  value: _displayText(customer.designation),
                ),
                _FieldItem(label: 'Website', value: _displayText(customer.website)),
                _FieldItem(
                  label: 'Communication Preference',
                  value: _displayText(customer.communicationPreference),
                ),
              ],
            ),
          ],
        ),
      ),
      _SectionConfig(
        id: 'business',
        title: '2. Business & Tax Information',
        icon: Icons.business_center_outlined,
        child: _DetailsSection(
          columns: [
            _FieldColumn(
              items: [
                _FieldItem(
                  label: 'Business Type',
                  value: _displayText(customer.category),
                ),
                _FieldItem(
                  label: 'Industry',
                  value: _displayText(customer.businessName),
                ),
                _FieldItem(
                  label: 'GST Number',
                  value: _displayText(customer.gstNumber),
                  trailingIcon: Icons.copy_rounded,
                  onTrailingTap: () => _copyValue('GST Number', customer.gstNumber ?? ''),
                ),
                _FieldItem(
                  label: 'PAN / Registration No.',
                  value: _displayText(customer.panNumber),
                ),
                _FieldItem(
                  label: 'Tax Category',
                  value: _displayText(customer.taxCategory),
                ),
                _FieldItem(
                  label: 'Tax Exempt',
                  value: customer.taxExempt == null
                      ? '-'
                      : (customer.taxExempt! ? 'Yes' : 'No'),
                ),
                _FieldItem(
                  label: 'Currency',
                  value: _displayText(customer.currency ?? 'INR'),
                ),
              ],
            ),
          ],
        ),
      ),
      _SectionConfig(
        id: 'address',
        title: '3. Address Information',
        icon: Icons.location_on_outlined,
        child: _DetailsSection(
          columns: [
            _FieldColumn(
              items: [
                _FieldItem(
                  label: 'Billing Address',
                  value: _displayText(customer.billingAddress ?? customer.address),
                  trailingIcon: Icons.location_on_rounded,
                ),
                _FieldItem(
                  label: 'Shipping Address',
                  value: _displayText(customer.deliveryAddress ?? customer.billingAddress),
                  trailingIcon: Icons.location_on_rounded,
                ),
                _FieldItem(label: 'Country', value: _displayText(customer.country)),
                _FieldItem(label: 'City', value: _displayText(customer.city)),
                _FieldItem(label: 'State', value: _displayText(customer.state)),
                _FieldItem(label: 'Pin Code', value: _displayText(customer.pinCode)),
              ],
            ),
          ],
        ),
      ),
      _SectionConfig(
        id: 'financial',
        title: '4. Financial Summary',
        icon: Icons.currency_rupee_rounded,
        child: _FinancialSummary(customer: customer),
      ),
      _SectionConfig(
        id: 'sales',
        title: '5. Sales & Relationship Details',
        icon: Icons.person_outline_rounded,
        child: _DetailsSection(
          columns: [
            _FieldColumn(
              items: [
                _FieldItem(
                  label: 'Assigned Sales Officer',
                  value: _displayText(
                    customer.assignedSalesOfficerName ?? customer.assignedSalesOfficerId,
                  ),
                ),
                _FieldItem(
                  label: 'Lead Source',
                  value: _displayText(customer.leadSource),
                ),
                _FieldItem(
                  label: 'Territory',
                  value: _displayText(customer.territory),
                ),
                _FieldItem(
                  label: 'Customer Priority',
                  value: _displayText(customer.customerPriority),
                ),
                _FieldItem(
                  label: 'Customer Since',
                  value: _formatDate(
                    customer.customerSince ?? customer.createdAt ?? customer.updatedAt,
                  ),
                ),
                _FieldItem(
                  label: 'Customer Tags',
                  value: _displayText(customer.customerTags),
                  trailingIcon: Icons.sell_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
      _SectionConfig(
        id: 'payments',
        title: '6. Payment History',
        icon: Icons.account_balance_wallet_outlined,
        child: _EmptySectionState(
          title: 'Payment records are not exposed by this customer detail API.',
          subtitle: 'Totals above are live. Transaction rows need a dedicated payments endpoint.',
        ),
      ),
      _SectionConfig(
        id: 'orders',
        title: '7. Order & Transaction History',
        icon: Icons.inventory_2_outlined,
        child: _EmptySectionState(
          title: 'Order history is not connected yet.',
          subtitle: 'The current API provides summary values but not line-level orders for this customer.',
        ),
      ),
      _SectionConfig(
        id: 'notes',
        title: '8. Notes & Preferences',
        icon: Icons.note_alt_outlined,
        child: _DetailsSection(
          columns: [
            _FieldColumn(
              items: [
                _FieldItem(label: 'Notes', value: _displayText(customer.notes)),
                _FieldItem(
                  label: 'Communication Preference',
                  value: _displayText(customer.communicationPreference),
                ),
                _FieldItem(
                  label: 'Preferred Payment Method',
                  value: _displayText(customer.paymentMethod),
                ),
              ],
            ),
          ],
        ),
      ),
      _SectionConfig(
        id: 'statement',
        title: '9. Account Statement',
        icon: Icons.account_balance_outlined,
        child: _AccountStatementCard(customer: customer),
      ),
    ];

    return all;
  }

  @override
  Widget build(BuildContext context) {
    final customer = _customer;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              onBack: () => Navigator.of(context).maybePop(),
              onMore: _showMoreActions,
            ),
            Expanded(
              child: _isLoading && customer == null
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCustomer,
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
                        child: customer == null
                            ? _ErrorState(
                                message: _errorMessage ?? 'Customer not found.',
                                onRetry: _loadCustomer,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _HeaderCard(
                                    customer: customer,
                                    onCallTap: () =>
                                        _copyValue('Phone', customer.phone ?? ''),
                                  ),
                                  const SizedBox(height: 14),
                                  _MetricsGrid(customer: customer),
                                  const SizedBox(height: 14),
                                  ..._sectionsFor(customer).map(
                                    (section) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: _AccordionSection(
                                        title: section.title,
                                        icon: section.icon,
                                        expanded: _expandedSections.contains(section.id),
                                        onChanged: (expanded) {
                                          setState(() {
                                            if (expanded) {
                                              _expandedSections.add(section.id);
                                            } else {
                                              _expandedSections.remove(section.id);
                                            }
                                          });
                                        },
                                        child: section.child,
                                      ),
                                    ),
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

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMore;

  const _TopBar({required this.onBack, required this.onMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textPrimary,
          ),
          const Expanded(
            child: Text(
              'Customer Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onMore,
            icon: const Icon(Icons.more_vert_rounded),
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onCallTap;

  const _HeaderCard({required this.customer, required this.onCallTap});

  @override
  Widget build(BuildContext context) {
    final statusActive = customer.isActive != false;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 540;

        final infoSection = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Customer ID: ${customer.customerId ?? customer.id}',
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _Badge(
                  label: statusActive ? 'Active' : 'Inactive',
                  backgroundColor: statusActive
                      ? const Color(0xFFE8F6E5)
                      : AppColors.statusInactiveBg,
                  textColor: statusActive
                      ? AppColors.statusActiveText
                      : AppColors.statusInactiveText,
                ),
                _Badge(
                  label: _displayText(customer.category, fallback: 'Customer'),
                  backgroundColor: const Color(0xFFEFF7EA),
                  textColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _HeaderRow(
              icon: Icons.call_outlined,
              text: _displayText(customer.phone),
              trailing: InkWell(
                onTap: onCallTap,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF7EA),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.call_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _HeaderRow(
              icon: Icons.mail_outline_rounded,
              text: _displayText(customer.email),
            ),
          ],
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(22, compact ? 20 : 24, 22, 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF7FBF4), Color(0xFFF1F8EC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFDDE8D8)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A3C02).withValues(alpha: 0.045),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CustomerAvatar(initials: customer.initials),
                        const SizedBox(width: 16),
                        Expanded(child: infoSection),
                      ],
                    ),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CustomerAvatar(initials: customer.initials),
                    const SizedBox(width: 18),
                    Expanded(child: infoSection),
                  ],
                ),
        );
      },
    );
  }
}

class _CustomerAvatar extends StatelessWidget {
  final String initials;

  const _CustomerAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFF0F7E9), Color(0xFFE2EFD8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;

  const _HeaderRow({
    required this.icon,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          alignment: Alignment.topLeft,
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final CustomerModel customer;

  const _MetricsGrid({required this.customer});

  @override
  Widget build(BuildContext context) {
    final totalOrders = 0;
    final lastOrderDate = '-';
    final totalBilled = customer.totalBilled ?? 0;
    final avgOrderValue = totalOrders > 0 ? totalBilled / totalOrders : 0;
    final cards = [
      _MetricCardData(
        title: 'Total Orders',
        value: '$totalOrders',
        icon: Icons.inventory_2_outlined,
      ),
      _MetricCardData(
        title: 'Total Received',
        value: _formatMoneyValue(customer.totalReceived ?? 0),
        icon: Icons.account_balance_wallet_outlined,
      ),
      _MetricCardData(
        title: 'Outstanding Balance',
        value: _formatMoneyValue(customer.outstanding ?? 0),
        icon: Icons.wallet_outlined,
      ),
      _MetricCardData(
        title: 'Credit Limit',
        value: _formatMoneyValue(customer.creditLimit ?? 0),
        icon: Icons.credit_card_rounded,
      ),
      _MetricCardData(
        title: 'Last Order Date',
        value: lastOrderDate,
        icon: Icons.calendar_month_outlined,
      ),
      _MetricCardData(
        title: 'Avg. Order Value',
        value: _formatMoneyValue(avgOrderValue),
        icon: Icons.trending_up_rounded,
      ),
    ];

    return _SlidingMetricsStrip(cards: cards);
  }
}

class _MetricCardData {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCardData({
    required this.title,
    required this.value,
    required this.icon,
  });

  String? get actionLabel => null;
}

class _SlidingMetricsStrip extends StatefulWidget {
  final List<_MetricCardData> cards;

  const _SlidingMetricsStrip({required this.cards});

  @override
  State<_SlidingMetricsStrip> createState() => _SlidingMetricsStripState();
}

class _SlidingMetricsStripState extends State<_SlidingMetricsStrip>
    with SingleTickerProviderStateMixin {
  static const double _cardWidth = 210;
  static const double _gap = 12;
  late final AnimationController _controller;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePaused() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _controller.stop();
      } else {
        _controller.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loopWidth = widget.cards.length * (_cardWidth + _gap);
    final marqueeCards = [...widget.cards, ...widget.cards];

    return SizedBox(
      height: 116,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = -(loopWidth * _controller.value);
            return Transform.translate(
              offset: Offset(offset, 0),
              child: child,
            );
          },
          child: Row(
            children: [
              for (final card in marqueeCards) ...[
                GestureDetector(
                  onTap: _togglePaused,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: _cardWidth,
                    child: _MetricCard(data: card),
                  ),
                ),
                const SizedBox(width: _gap),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final _MetricCardData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.022),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F7EF),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(data.icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    data.value,
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox.shrink(),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 0),
          Text(
            data.actionLabel == null ? ' ' : '${data.actionLabel}  →',
            style: TextStyle(
              color: data.actionLabel == null
                  ? Colors.transparent
                  : AppColors.primary,
              fontSize: 0,
              fontWeight: FontWeight.w600,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionConfig {
  final String id;
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionConfig({
    required this.id,
    required this.title,
    required this.icon,
    required this.child,
  });
}

class _AccordionSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool expanded;
  final ValueChanged<bool> onChanged;
  final Widget child;

  const _AccordionSection({
    required this.title,
    required this.icon,
    required this.expanded,
    required this.onChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.022),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey<String>(title),
          initiallyExpanded: expanded,
          onExpansionChanged: onChanged,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F7EF),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: Icon(
            expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            color: AppColors.primary,
          ),
          children: [child],
        ),
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final List<_FieldColumn> columns;

  const _DetailsSection({required this.columns});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth > 620 && columns.length > 1;
        if (!twoColumns) {
          return Column(
            children: columns
                .expand((column) => column.items)
                .map((item) => _FieldTile(item: item))
                .toList(),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < columns.length; i++) ...[
              Expanded(
                child: Column(
                  children: columns[i].items
                      .map((item) => _FieldTile(item: item))
                      .toList(),
                ),
              ),
              if (i != columns.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      },
    );
  }
}

class _FieldColumn {
  final List<_FieldItem> items;

  const _FieldColumn({required this.items});
}

class _FieldItem {
  final String label;
  final String value;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  const _FieldItem({
    required this.label,
    required this.value,
    this.trailingIcon,
    this.onTrailingTap,
  });
}

class _FieldTile extends StatelessWidget {
  final _FieldItem item;

  const _FieldTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final trailingIcon = item.trailingIcon;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.9)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null)
            IconButton(
              onPressed: item.onTrailingTap,
              icon: Icon(trailingIcon, color: AppColors.primary, size: 22),
            ),
        ],
      ),
    );
  }
}

class _FinancialSummary extends StatelessWidget {
  final CustomerModel customer;

  const _FinancialSummary({required this.customer});

  @override
  Widget build(BuildContext context) {
    final creditLimit = _safeMoneyNumber(customer.creditLimit);
    final outstanding = _safeMoneyNumber(customer.outstanding);
    final availableCredit =
        (creditLimit - outstanding).clamp(-999999999.0, 999999999.0);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _SummaryBox(label: 'Credit Limit', value: _formatMoneyValue(creditLimit)),
        _SummaryBox(
          label: 'Outstanding Balance',
          value: _formatMoneyValue(outstanding),
        ),
        _SummaryBox(
          label: 'Available Credit',
          value: _formatMoneyValue(availableCredit),
        ),
        _SummaryBox(
          label: 'Total Received',
          value: _formatMoneyValue(customer.totalReceived ?? 0),
        ),
        _SummaryBox(
          label: 'Total Billed',
          value: _formatMoneyValue(customer.totalBilled ?? 0),
        ),
        _SummaryBox(
          label: 'Opening Balance',
          value: _formatMoneyValue(customer.openingBalance ?? 0),
        ),
      ],
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountStatementCard extends StatelessWidget {
  final CustomerModel customer;

  const _AccountStatementCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Balance Snapshot',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _StatementRow(
            label: 'Opening Balance',
            value: _formatMoneyValue(customer.openingBalance ?? 0),
          ),
          _StatementRow(
            label: 'Billed Amount',
            value: _formatMoneyValue(customer.totalBilled ?? 0),
          ),
          _StatementRow(
            label: 'Received Amount',
            value: _formatMoneyValue(customer.totalReceived ?? 0),
          ),
          _StatementRow(
            label: 'Outstanding Amount',
            value: _formatMoneyValue(customer.outstanding ?? 0),
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _StatementRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const _StatementRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: emphasized ? AppColors.primary : AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySectionState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptySectionState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionSheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F7EF),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
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
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  onRetry();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
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
      ),
    );
  }
}
