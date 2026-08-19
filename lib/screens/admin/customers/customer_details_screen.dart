import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import 'add_customer_screen.dart';

String _formatMoneyValue(num value) {
  final absolute = value.abs().toStringAsFixed(value % 1 == 0 ? 0 : 2);
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
  final sign = value < 0 ? '-' : '';
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

enum _CustomerTab { overview, financial, documents, more }

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
  _CustomerTab _activeTab = _CustomerTab.overview;
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
                    _copyValue('Customer ID', customer.id);
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

    switch (_activeTab) {
      case _CustomerTab.overview:
        return all;
      case _CustomerTab.financial:
        return all
            .where((section) =>
                section.id == 'financial' ||
                section.id == 'payments' ||
                section.id == 'statement')
            .toList();
      case _CustomerTab.documents:
        return [
          _SectionConfig(
            id: 'documents',
            title: 'Documents',
            icon: Icons.description_outlined,
            child: const _EmptySectionState(
              title: 'No document links are returned by the customer API.',
              subtitle: 'GST, PAN, address proof, and agreement uploads need backend document fields before they can appear here.',
            ),
          ),
        ];
      case _CustomerTab.more:
        return all
            .where((section) =>
                section.id == 'sales' ||
                section.id == 'notes' ||
                section.id == 'statement')
            .toList();
    }
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
                                  _TabStrip(
                                    activeTab: _activeTab,
                                    onChanged: (tab) {
                                      setState(() => _activeTab = tab);
                                    },
                                  ),
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
                                  const SizedBox(height: 8),
                                  _BottomActions(
                                    onEdit: _openEdit,
                                    onRecordPayment: _showRecordPaymentMessage,
                                    onMore: _showMoreActions,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFF4FAF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF063B00).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFF1F8EE), Color(0xFFE4F1DE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              customer.initials,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Customer ID: ${customer.id}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Badge(
                      label: statusActive ? 'Active' : 'Inactive',
                      backgroundColor: statusActive
                          ? const Color(0xFFE6F8E7)
                          : AppColors.statusInactiveBg,
                      textColor: statusActive
                          ? AppColors.statusActiveText
                          : AppColors.statusInactiveText,
                    ),
                    _Badge(
                      label: _displayText(customer.category, fallback: 'Customer'),
                      backgroundColor: const Color(0xFFEAF7EA),
                      textColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _HeaderRow(
                  icon: Icons.call_outlined,
                  text: _displayText(customer.phone),
                ),
                const SizedBox(height: 8),
                _HeaderRow(
                  icon: Icons.mail_outline_rounded,
                  text: _displayText(customer.email),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              InkWell(
                onTap: onCallTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.18),
                    ),
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.call_rounded,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Call',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
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
        actionLabel: 'View Orders',
        icon: Icons.inventory_2_outlined,
      ),
      _MetricCardData(
        title: 'Total Received',
        value: _formatMoneyValue(customer.totalReceived ?? 0),
        actionLabel: 'View Payments',
        icon: Icons.account_balance_wallet_outlined,
      ),
      _MetricCardData(
        title: 'Outstanding Balance',
        value: _formatMoneyValue(customer.outstanding ?? 0),
        actionLabel: 'View Payments',
        icon: Icons.wallet_outlined,
      ),
      _MetricCardData(
        title: 'Credit Limit',
        value: _formatMoneyValue(customer.creditLimit ?? 0),
        actionLabel: 'Edit Limit',
        icon: Icons.credit_card_rounded,
      ),
      _MetricCardData(
        title: 'Last Order Date',
        value: lastOrderDate,
        actionLabel: 'View Orders',
        icon: Icons.calendar_month_outlined,
      ),
      _MetricCardData(
        title: 'Avg. Order Value',
        value: _formatMoneyValue(avgOrderValue),
        actionLabel: null,
        icon: Icons.trending_up_rounded,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.18,
      ),
      itemBuilder: (context, index) => _MetricCard(data: cards[index]),
    );
  }
}

class _MetricCardData {
  final String title;
  final String value;
  final String? actionLabel;
  final IconData icon;

  const _MetricCardData({
    required this.title,
    required this.value,
    required this.actionLabel,
    required this.icon,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricCardData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(data.icon, size: 22, color: AppColors.primary),
            ],
          ),
          const Spacer(),
          Text(
            data.value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.actionLabel == null ? ' ' : '${data.actionLabel}  →',
            style: TextStyle(
              color: data.actionLabel == null
                  ? Colors.transparent
                  : AppColors.primary,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabStrip extends StatelessWidget {
  final _CustomerTab activeTab;
  final ValueChanged<_CustomerTab> onChanged;

  const _TabStrip({required this.activeTab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
      ),
      child: Row(
        children: [
          _TabButton(
            label: 'Overview',
            active: activeTab == _CustomerTab.overview,
            onTap: () => onChanged(_CustomerTab.overview),
          ),
          _TabButton(
            label: 'Financial',
            active: activeTab == _CustomerTab.financial,
            onTap: () => onChanged(_CustomerTab.financial),
          ),
          _TabButton(
            label: 'Documents',
            active: activeTab == _CustomerTab.documents,
            onTap: () => onChanged(_CustomerTab.documents),
          ),
          _TabButton(
            label: 'More',
            active: activeTab == _CustomerTab.more,
            onTap: () => onChanged(_CustomerTab.more),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF0F7EE) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? AppColors.primary : AppColors.textSecondary,
              fontSize: 13.5,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
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
    final creditLimit = customer.creditLimit ?? 0;
    final outstanding = customer.outstanding ?? 0;
    final availableCredit = (creditLimit - outstanding).clamp(-999999999, 999999999);

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

class _BottomActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onRecordPayment;
  final VoidCallback onMore;

  const _BottomActions({
    required this.onEdit,
    required this.onRecordPayment,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BottomButton(
            label: 'Edit Customer',
            icon: Icons.edit_rounded,
            filled: false,
            onTap: onEdit,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BottomButton(
            label: 'Record Payment',
            icon: Icons.add_circle_outline_rounded,
            filled: false,
            onTap: onRecordPayment,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BottomButton(
            label: 'More Actions',
            icon: Icons.menu_rounded,
            filled: true,
            onTap: onMore,
          ),
        ),
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  const _BottomButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        decoration: BoxDecoration(
          gradient: filled
              ? const LinearGradient(
                  colors: [Color(0xFF0B5D08), AppColors.primary],
                )
              : const LinearGradient(
                  colors: [Color(0xFFF9FCF8), Color(0xFFEFF7ED)],
                ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: filled
                ? Colors.transparent
                : AppColors.border.withValues(alpha: 0.9),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: filled ? Colors.white : AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: filled ? Colors.white : AppColors.primary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
