import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../models/customer_activity_models.dart';
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

String _formatIsoDate(DateTime? date) {
  if (date == null) return '-';
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

String _titleCaseText(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return '-';
  return normalized
      .split(RegExp(r'[_\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
      .join(' ');
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
  bool _isLedgerLoading = false;
  String? _ledgerErrorMessage;
  CustomerLedger? _ledger;
  bool _isPaymentsLoading = false;
  String? _paymentsErrorMessage;
  List<CustomerPaymentRecord> _payments = const [];
  bool _isOrdersLoading = false;
  String? _ordersErrorMessage;
  List<CustomerOrderRecord> _orders = const [];
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
      _ledger = null;
      _ledgerErrorMessage = null;
      _payments = const [];
      _paymentsErrorMessage = null;
      _orders = const [];
      _ordersErrorMessage = null;
    });

    try {
      final customer = await _apiProvider.fetchCustomerById(widget.customerId);
      if (!mounted) return;
      setState(() {
        _customer = customer;
        _isLoading = false;
      });
      await Future.wait([
        _loadLedger(customer.id),
        _loadPayments(customer.id),
        _loadOrders(customer.id),
      ]);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPayments(String customerId) async {
    setState(() {
      _isPaymentsLoading = true;
      _paymentsErrorMessage = null;
    });

    try {
      final payments = await _apiProvider.fetchCustomerPayments(customerId);
      if (!mounted) return;
      setState(() {
        _payments = payments;
        _isPaymentsLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _paymentsErrorMessage = error.toString();
        _isPaymentsLoading = false;
      });
    }
  }

  Future<void> _loadOrders(String customerId) async {
    setState(() {
      _isOrdersLoading = true;
      _ordersErrorMessage = null;
    });

    try {
      final orders = await _apiProvider.fetchCustomerOrders(customerId);
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _isOrdersLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _ordersErrorMessage = error.toString();
        _isOrdersLoading = false;
      });
    }
  }

  Future<void> _loadLedger(String customerId) async {
    setState(() {
      _isLedgerLoading = true;
      _ledgerErrorMessage = null;
    });

    try {
      final ledger = await _apiProvider.fetchCustomerLedger(customerId);
      if (!mounted) return;
      setState(() {
        _ledger = ledger;
        _isLedgerLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _ledgerErrorMessage = error.toString();
        _isLedgerLoading = false;
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

  Future<void> _openMapLocation(CustomerModel customer) async {
    final latitude = customer.mapLatitude;
    final longitude = customer.mapLongitude;
    if (latitude == null || longitude == null) {
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched || !mounted) return;
  }

  String _visibleCustomerId(CustomerModel customer) {
    final externalId = customer.customerId?.trim();
    return externalId == null || externalId.isEmpty ? customer.id : externalId;
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
                  value: _displayText(customer.industry),
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
                  value: _displayText(customer.currency),
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
                _FieldItem(
                  label: 'Google Maps Location',
                  value: customer.mapLatitude != null && customer.mapLongitude != null
                      ? '${customer.mapLatitude}, ${customer.mapLongitude}'
                      : '-',
                  trailingIcon: Icons.map_outlined,
                  onTrailingTap: () => _openMapLocation(customer),
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
        child: _CustomerPaymentsSection(
          payments: _payments,
          isLoading: _isPaymentsLoading,
          errorMessage: _paymentsErrorMessage,
          onRetry: () => _loadPayments(customer.id),
        ),
      ),
      _SectionConfig(
        id: 'orders',
        title: '7. Order & Transaction History',
        icon: Icons.inventory_2_outlined,
        child: _CustomerOrdersSection(
          orders: _orders,
          isLoading: _isOrdersLoading,
          errorMessage: _ordersErrorMessage,
          onRetry: () => _loadOrders(customer.id),
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
        child: _AccountStatementCard(
          customer: customer,
          ledger: _ledger,
          isLoading: _isLedgerLoading,
          errorMessage: _ledgerErrorMessage,
          onRetry: () => _loadLedger(customer.id),
        ),
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
        mainAxisAlignment: MainAxisAlignment.center,
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
          const SizedBox(height: 10),
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
    final totalReceived = _safeMoneyNumber(customer.totalReceived);
    final totalBilled = _safeMoneyNumber(customer.totalBilled);
    final openingBalance = _safeMoneyNumber(customer.openingBalance);
    final availableCredit =
        (creditLimit - outstanding).clamp(-999999999.0, 999999999.0);
    final cards = [
      _SummaryCardData(
        label: 'Credit Limit',
        value: _formatMoneyValue(creditLimit),
      ),
      _SummaryCardData(
        label: 'Outstanding Balance',
        value: _formatMoneyValue(outstanding),
      ),
      _SummaryCardData(
        label: 'Available Credit',
        value: _formatMoneyValue(availableCredit),
      ),
      _SummaryCardData(
        label: 'Total Received',
        value: _formatMoneyValue(totalReceived),
      ),
      _SummaryCardData(
        label: 'Total Billed',
        value: _formatMoneyValue(totalBilled),
      ),
      _SummaryCardData(
        label: 'Opening Balance',
        value: _formatMoneyValue(openingBalance),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.0;
        final cardWidth = constraints.maxWidth >= 420
            ? (constraints.maxWidth - spacing) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
                  width: cardWidth,
                  child: _SummaryBox(label: card.label, value: card.value),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SummaryCardData {
  final String label;
  final String value;

  const _SummaryCardData({
    required this.label,
    required this.value,
  });
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
  final CustomerLedger? ledger;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  const _AccountStatementCard({
    required this.customer,
    required this.ledger,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && ledger == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBF8),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (errorMessage != null && ledger == null) {
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
            const Text(
              'Unable to load account statement.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final ledgerData = ledger;
    if (ledgerData == null) {
      return const _EmptySectionState(
        title: 'No account statement available.',
        subtitle: 'Ledger data was not returned for this customer.',
      );
    }

    final summary = ledgerData.summary;
    final ageing = ledgerData.ageing;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statement Overview',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _StatementMetricGrid(
            cards: [
              _StatementMetricData(
                label: 'Outstanding',
                value: _formatMoneyValue(summary.outstanding),
              ),
              _StatementMetricData(
                label: 'Overdue',
                value: _formatMoneyValue(summary.overdueAmount),
                accentColor: Colors.red,
              ),
              _StatementMetricData(
                label: 'Available Credit',
                value: _formatMoneyValue(summary.availableCredit),
              ),
              _StatementMetricData(
                label: 'Credit Limit',
                value: _formatMoneyValue(summary.creditLimit),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'AGEING ANALYSIS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _StatementMetricGrid(
            cards: [
              _StatementMetricData(
                label: '0-30 days',
                value: _formatMoneyValue(ageing.zeroTo30),
              ),
              _StatementMetricData(
                label: '31-60 days',
                value: _formatMoneyValue(ageing.days31To60),
              ),
              _StatementMetricData(
                label: '61-90 days',
                value: _formatMoneyValue(ageing.days61To90),
              ),
              _StatementMetricData(
                label: '90+ days',
                value: _formatMoneyValue(ageing.days90Plus),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'TRANSACTION HISTORY',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _StatementTransactionsTable(transactions: ledgerData.transactions),
        ],
      ),
    );
  }
}

class _StatementMetricData {
  final String label;
  final String value;
  final Color? accentColor;

  const _StatementMetricData({
    required this.label,
    required this.value,
    this.accentColor,
  });
}

class _StatementMetricGrid extends StatelessWidget {
  final List<_StatementMetricData> cards;

  const _StatementMetricGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    final rows = <List<_StatementMetricData>>[];
    for (var i = 0; i < cards.length; i += 2) {
      rows.add(cards.sublist(i, i + 2 > cards.length ? cards.length : i + 2));
    }

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          Row(
            children: [
              for (var i = 0; i < rows[rowIndex].length; i++) ...[
                Expanded(
                  child: _StatementMetricCard(data: rows[rowIndex][i]),
                ),
                if (i != rows[rowIndex].length - 1) const SizedBox(width: 12),
              ],
              if (rows[rowIndex].length == 1) ...[
                const SizedBox(width: 12),
                const Expanded(child: SizedBox.shrink()),
              ],
            ],
          ),
          if (rowIndex != rows.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StatementMetricCard extends StatelessWidget {
  final _StatementMetricData data;

  const _StatementMetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: TextStyle(
              color: data.accentColor ?? AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatementTransactionsTable extends StatelessWidget {
  final List<CustomerLedgerTransaction> transactions;

  const _StatementTransactionsTable({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const _EmptySectionState(
        title: 'No ledger transactions found.',
        subtitle: 'This customer has no ledger transaction history yet.',
      );
    }

    return Column(
      children: [
        for (var i = 0; i < transactions.length; i++) ...[
          _StatementTransactionCard(transaction: transactions[i]),
          if (i != transactions.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StatementTransactionCard extends StatelessWidget {
  final CustomerLedgerTransaction transaction;

  const _StatementTransactionCard({required this.transaction});

  bool get _isCredit => transaction.credit > 0;

  @override
  Widget build(BuildContext context) {
    final amount = _isCredit ? transaction.credit : transaction.debit;
    final amountColor = _isCredit ? const Color(0xFF0A8F3D) : const Color(0xFFC53030);
    final amountPrefix = _isCredit ? '+' : '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _TypeChip(label: _titleCaseText(transaction.type)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  transaction.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _formatIsoDate(transaction.date),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$amountPrefix${_formatMoneyValue(amount)}',
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    _isCredit
                        ? Icons.arrow_outward_rounded
                        : Icons.call_received_rounded,
                    color: amountColor,
                    size: 17,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Balance: ${_formatMoneyValue(transaction.balance)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (transaction.referenceNumber != null &&
                  transaction.referenceNumber!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  transaction.referenceNumber!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerPaymentsSection extends StatelessWidget {
  final List<CustomerPaymentRecord> payments;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  const _CustomerPaymentsSection({
    required this.payments,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && payments.isEmpty) {
      return const _SectionLoader();
    }
    if (errorMessage != null && payments.isEmpty) {
      return _SectionError(message: errorMessage!, onRetry: onRetry);
    }
    if (payments.isEmpty) {
      return const _EmptySectionState(
        title: 'No payment history found.',
        subtitle: 'This customer has no recorded payments yet.',
      );
    }

    return Column(
      children: [
        for (var i = 0; i < payments.length; i++) ...[
          _PaymentHistoryCard(payment: payments[i]),
          if (i != payments.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  final CustomerPaymentRecord payment;

  const _PaymentHistoryCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _formatMoneyValue(payment.amount),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _InfoPill(
                label: _titleCaseText(payment.method),
                foreground: AppColors.textPrimary,
                background: const Color(0xFFF7F9FC),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatIsoDate(payment.date)} · ${payment.referenceNumber}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (payment.status.trim() != '-' && payment.status.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _InfoPill(
              label: _titleCaseText(payment.status),
              foreground: AppColors.primary,
              background: const Color(0xFFEFF7EA),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              _ActionText(
                icon: Icons.receipt_long_outlined,
                label: 'Receipt',
                compact: true,
              ),
              SizedBox(width: 14),
              _ActionText(
                icon: Icons.undo_rounded,
                label: 'Void',
                compact: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomerOrdersSection extends StatelessWidget {
  final List<CustomerOrderRecord> orders;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  const _CustomerOrdersSection({
    required this.orders,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && orders.isEmpty) {
      return const _SectionLoader();
    }
    if (errorMessage != null && orders.isEmpty) {
      return _SectionError(message: errorMessage!, onRetry: onRetry);
    }
    if (orders.isEmpty) {
      return const _EmptySectionState(
        title: 'No orders found.',
        subtitle: 'This customer has no sales orders yet.',
      );
    }

    return Column(
      children: [
        for (var i = 0; i < orders.length; i++) ...[
          _OrderHistoryCard(order: orders[i]),
          if (i != orders.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final CustomerOrderRecord order;

  const _OrderHistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
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
                      order.orderNumber,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatIsoDate(order.date),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatMoneyValue(order.total),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                label: _titleCaseText(order.status),
                foreground: _statusTextColor(order.status),
                background: _statusBackgroundColor(order.status),
              ),
              _InfoPill(
                label: _titleCaseText(order.fulfillment),
                foreground: AppColors.textPrimary,
                background: const Color(0xFFF7F9FC),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _statusTextColor(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized == 'completed' || normalized == 'delivered') {
    return const Color(0xFF04844B);
  }
  if (normalized == 'placed' || normalized == 'pending' || normalized == 'reserved') {
    return const Color(0xFF1256F3);
  }
  if (normalized == 'cancelled' || normalized == 'void') {
    return const Color(0xFFC53030);
  }
  return AppColors.textPrimary;
}

Color _statusBackgroundColor(String status) {
  final normalized = status.trim().toLowerCase();
  if (normalized == 'completed' || normalized == 'delivered') {
    return const Color(0xFFE9F8EF);
  }
  if (normalized == 'placed' || normalized == 'pending' || normalized == 'reserved') {
    return const Color(0xFFECF3FF);
  }
  if (normalized == 'cancelled' || normalized == 'void') {
    return const Color(0xFFFDECEC);
  }
  return const Color(0xFFF4F6F8);
}

class _InfoPill extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;

  const _InfoPill({
    required this.label,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.75)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foreground,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionText extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool compact;

  const _ActionText({
    required this.icon,
    required this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: compact ? 16 : 18, color: AppColors.textPrimary),
        SizedBox(width: compact ? 5 : 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: compact ? 13 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionLoader extends StatelessWidget {
  const _SectionLoader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _SectionError({
    required this.message,
    required this.onRetry,
  });

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
          const Text(
            'Unable to load this section.',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              onRetry();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;

  const _TypeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5FA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
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
