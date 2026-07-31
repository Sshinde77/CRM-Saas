import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../dashboard/sales_manager_dashboard_screen.dart';
import '../orders/sales_manager_orders_screen.dart';

class SalesManagerCustomersScreen extends StatefulWidget {
  const SalesManagerCustomersScreen({super.key});

  @override
  State<SalesManagerCustomersScreen> createState() =>
      _SalesManagerCustomersScreenState();
}

class _SalesManagerCustomersScreenState
    extends State<SalesManagerCustomersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = const [
    'All (56)',
    'Active (48)',
    'Inactive (6)',
    'Blocked (2)',
  ];

  final List<_CustomerRecord> _allCustomers = const [
    _CustomerRecord(
      name: 'Shree Ganesh Traders',
      location: 'Dadar, Mumbai',
      outstanding: 'Rs. 45,000',
      status: 'Active',
      color: AppColors.primary,
      category: 'Retailer',
      since: '12 Jan 2023',
      customerCode: 'CUST-1001',
      contactPerson: 'Ramesh Kumar',
      mobileNumber: '98765 43210',
      email: 'ramesh@sgtraders.in',
      gstNumber: '27ABCDE1234F1Z5',
      address:
          'Shop No. 12, Main Road, Dadar (West), Mumbai, Maharashtra - 400028',
      totalOrders: '24',
      totalSales: 'Rs. 2,45,600',
      recentOrders: const [
        _CustomerRecentOrder(
          number: 'SO-1023',
          date: '18 May 2024',
          amount: 'Rs. 25,600',
          status: 'Confirmed',
        ),
      ],
    ),
    _CustomerRecord(
      name: 'Maa Durga Stores',
      location: 'Matunga, Mumbai',
      outstanding: 'Rs. 12,500',
      status: 'Active',
      color: AppColors.orange,
      category: 'Retailer',
      since: '05 Feb 2023',
      customerCode: 'CUST-1002',
      contactPerson: 'Madan Shah',
      mobileNumber: '98765 12345',
      email: 'hello@maadurgastores.in',
      gstNumber: '27ABCDE1234F1Z6',
      address:
          'Lal Bahadur Shastri Rd, Matunga, Mumbai, Maharashtra - 400019',
      totalOrders: '16',
      totalSales: 'Rs. 1,18,200',
      recentOrders: const [],
    ),
    _CustomerRecord(
      name: 'Patel Retailers',
      location: 'Sion, Mumbai',
      outstanding: 'Rs. 0',
      status: 'Active',
      color: AppColors.green,
      category: 'Wholesale',
      since: '22 Mar 2023',
      customerCode: 'CUST-1003',
      contactPerson: 'Ketan Patel',
      mobileNumber: '98989 98989',
      email: 'patel@retailers.in',
      gstNumber: '27ABCDE1234F1Z7',
      address: 'Sion Circle, Sion, Mumbai, Maharashtra - 400022',
      totalOrders: '9',
      totalSales: 'Rs. 86,100',
      recentOrders: const [],
    ),
    _CustomerRecord(
      name: 'S.K. Enterprises',
      location: 'Ghatkopar, Mumbai',
      outstanding: 'Rs. 78,300',
      status: 'Inactive',
      color: AppColors.purple,
      category: 'Distributor',
      since: '18 Dec 2022',
      customerCode: 'CUST-1004',
      contactPerson: 'Sanjay Kumar',
      mobileNumber: '99887 77665',
      email: 'info@skenterprises.in',
      gstNumber: '27ABCDE1234F1Z8',
      address: 'Ghatkopar East, Mumbai, Maharashtra - 400075',
      totalOrders: '31',
      totalSales: 'Rs. 4,12,800',
      recentOrders: const [],
    ),
    _CustomerRecord(
      name: 'New A One Traders',
      location: 'Kurla, Mumbai',
      outstanding: 'Rs. 18,700',
      status: 'Blocked',
      color: AppColors.primary,
      category: 'Retailer',
      since: '15 May 2023',
      customerCode: 'CUST-1005',
      contactPerson: 'Amit Shah',
      mobileNumber: '97654 32109',
      email: 'sales@aonetraders.in',
      gstNumber: '27ABCDE1234F1Z9',
      address: 'Kurla West, Mumbai, Maharashtra - 400070',
      totalOrders: '12',
      totalSales: 'Rs. 1,34,700',
      recentOrders: const [],
    ),
  ];

  int _selectedTab = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openAddCustomerForm() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddCustomerSheet(
          onSaved: _showCustomerAddedSuccessfullyPopup,
        );
      },
    );
  }

  void _handleSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'Customers') return;
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SalesManagerDashboardScreen(),
        ),
      );
      return;
    }
    if (action == 'Sales Orders') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SalesManagerOrdersScreen(),
        ),
      );
      return;
    }
  }

  Future<void> _showCustomerAddedSuccessfullyPopup(
    _CustomerFormData data,
  ) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Customer Added Successfully',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.75),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 78,
                            height: 78,
                            decoration: BoxDecoration(
                              color: AppColors.statusActiveBg,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: AppColors.statusActiveText,
                              size: 42,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Customer Added Successfully!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'The customer has been added to your list.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.75),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Customer Details',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _SuccessDetailRow(
                                icon: Icons.storefront_rounded,
                                label: data.businessName,
                                trailing: _StatusPill(
                                  label: 'Active',
                                  color: AppColors.statusActiveText,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _SuccessDetailRow(
                                icon: Icons.person_outline_rounded,
                                label: 'Contact Person',
                                value: data.contactPerson,
                              ),
                              const SizedBox(height: 10),
                              _SuccessDetailRow(
                                icon: Icons.call_outlined,
                                label: 'Mobile Number',
                                value: data.mobileNumber,
                              ),
                              const SizedBox(height: 10),
                              _SuccessDetailRow(
                                icon: Icons.location_on_outlined,
                                label: 'Address',
                                value: data.businessAddress,
                              ),
                              const SizedBox(height: 10),
                              _SuccessDetailRow(
                                icon: Icons.sell_outlined,
                                label: 'Credit Limit',
                                value: data.creditLimit.isEmpty
                                    ? 'Not provided'
                                    : data.creditLimit,
                              ),
                              const SizedBox(height: 10),
                              _SuccessDetailRow(
                                icon: Icons.payments_outlined,
                                label: 'Opening Balance',
                                value: data.openingBalance.isEmpty
                                    ? 'Not provided'
                                    : data.openingBalance,
                              ),
                              const SizedBox(height: 10),
                              _SuccessDetailRow(
                                icon: Icons.receipt_long_outlined,
                                label: 'GST Number',
                                value: data.gstNumber.isEmpty
                                    ? 'Not provided'
                                    : data.gstNumber,
                              ),
                              if (data.notes.trim().isNotEmpty) ...[
                                const SizedBox(height: 10),
                                _SuccessDetailRow(
                                  icon: Icons.notes_outlined,
                                  label: 'Notes',
                                  value: data.notes,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Done',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = _visibleCustomers();
    final query = _searchController.text.trim().toLowerCase();
    final filteredCustomers = customers.where((customer) {
      if (query.isEmpty) return true;
      return customer.name.toLowerCase().contains(query) ||
          customer.location.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _SalesManagerSidebar(onSelect: _handleSidebarSelection),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchRow(),
                    const SizedBox(height: 12),
                    _buildTabs(),
                    const SizedBox(height: 14),
                    for (var i = 0; i < filteredCustomers.length; i++) ...[
                      _CustomerTile(customer: filteredCustomers[i]),
                      if (i != filteredCustomers.length - 1)
                        const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 14),
                    _buildAddButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_CustomerRecord> _visibleCustomers() {
    switch (_selectedTab) {
      case 1:
        return _allCustomers
            .where((customer) => customer.status == 'Active')
            .toList();
      case 2:
        return _allCustomers
            .where((customer) => customer.status == 'Inactive')
            .toList();
      case 3:
        return _allCustomers
            .where((customer) => customer.status == 'Blocked')
            .toList();
      default:
        return _allCustomers;
    }
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 2),
          const Text(
            'Customers',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _openAddCustomerForm,
              child: const SizedBox(
                width: 28,
                height: 28,
                child: Icon(Icons.add_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.adminSidebarBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                hintText: 'Search customers...',
                hintStyle: TextStyle(
                  color: AppColors.textLightMuted,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.adminSidebarBg,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {},
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: List.generate(_tabs.length, (index) {
        final selected = index == _selectedTab;
        return Padding(
          padding: EdgeInsets.only(right: index == _tabs.length - 1 ? 0 : 8),
          child: ChoiceChip(
            label: Text(_tabs[index]),
            selected: selected,
            onSelected: (_) => setState(() => _selectedTab = index),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceSoft,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: selected
                    ? AppColors.primary
                    : AppColors.border.withValues(alpha: 0.65),
              ),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        );
      }),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: TextButton.icon(
        onPressed: _openAddCustomerForm,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text(
          'Add New Customer',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        style: TextButton.styleFrom(
          backgroundColor: AppColors.adminSidebarBg,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  final _CustomerRecord customer;

  const _CustomerTile({required this.customer});

  @override
  Widget build(BuildContext context) {
    final statusColor = _customerStatusColor(customer.status);
    final statusBackground = _customerStatusBackground(customer.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _CustomerDetailsScreen(customer: customer),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.adminSidebarBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: customer.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      customer.location,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Outstanding : ${customer.outstanding}',
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  customer.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLightMuted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomerDetailsScreen extends StatelessWidget {
  final _CustomerRecord customer;

  const _CustomerDetailsScreen({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _CustomerDetailsTopBar(
              title: 'Customer Details',
              onBack: () => Navigator.of(context).maybePop(),
              onEdit: () => _openActions(context),
              onMore: () => _openActions(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CustomerHeaderCard(customer: customer),
                    const SizedBox(height: 12),
                    _CustomerInfoCard(customer: customer),
                    const SizedBox(height: 12),
                    _CustomerStatsCard(customer: customer),
                    const SizedBox(height: 12),
                    _CustomerRecentOrdersCard(customer: customer),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openActions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _CustomerActionsSheet(
          customer: customer,
          onAction: (action) {
            Navigator.of(sheetContext).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$action for ${customer.name}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }
}

class _CustomerDetailsTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onMore;

  const _CustomerDetailsTopBar({
    required this.title,
    required this.onBack,
    required this.onEdit,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.textPrimary),
          ),
          IconButton(
            onPressed: onMore,
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _CustomerHeaderCard extends StatelessWidget {
  final _CustomerRecord customer;

  const _CustomerHeaderCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.adminSidebarBg,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.storefront_rounded, color: customer.color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${customer.category} | Since ${customer.since}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customer Code: ${customer.customerCode}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _StatusPill(
            label: customer.status,
            color: _customerStatusColor(customer.status),
          ),
        ],
      ),
    );
  }
}

class _CustomerInfoCard extends StatelessWidget {
  final _CustomerRecord customer;

  const _CustomerInfoCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
      ),
      child: Column(
        children: [
          _InfoRow(icon: Icons.person_outline_rounded, label: 'Contact Person', value: customer.contactPerson),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.call_outlined, label: 'Mobile Number', value: customer.mobileNumber),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.email_outlined, label: 'Email', value: customer.email),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.receipt_long_outlined, label: 'GST Number', value: customer.gstNumber),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: customer.address,
            valueAlignRight: false,
          ),
        ],
      ),
    );
  }
}

class _CustomerStatsCard extends StatelessWidget {
  final _CustomerRecord customer;

  const _CustomerStatsCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatBox(label: 'Total Orders', value: customer.totalOrders)),
        const SizedBox(width: 10),
        Expanded(child: _StatBox(label: 'Total Sales', value: customer.totalSales)),
        const SizedBox(width: 10),
        Expanded(
          child: _StatBox(
            label: 'Outstanding',
            value: customer.outstanding,
            valueColor: AppColors.red,
          ),
        ),
      ],
    );
  }
}

class _CustomerRecentOrdersCard extends StatelessWidget {
  final _CustomerRecord customer;

  const _CustomerRecentOrdersCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (customer.recentOrders.isEmpty)
            const Text(
              'No recent orders available.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            )
          else
            for (final order in customer.recentOrders) ...[
              _RecentOrderRow(order: order),
              if (order != customer.recentOrders.last) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _CustomerActionsSheet extends StatelessWidget {
  final _CustomerRecord customer;
  final ValueChanged<String> onAction;

  const _CustomerActionsSheet({
    required this.customer,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.48,
      minChildSize: 0.38,
      maxChildSize: 0.68,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'What would you like to do?',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _ActionTile(
                          icon: Icons.shopping_cart_outlined,
                          color: AppColors.primary,
                          title: 'Create Order',
                          subtitle: 'Create a new sales order for this customer',
                          onTap: () => onAction('Create Order'),
                        ),
                        _ActionTile(
                          icon: Icons.event_available_outlined,
                          color: AppColors.blue,
                          title: 'Record Visit',
                          subtitle: 'Record details of your customer visit',
                          onTap: () => onAction('Record Visit'),
                        ),
                        _ActionTile(
                          icon: Icons.currency_rupee_rounded,
                          color: AppColors.orange,
                          title: 'Outstanding',
                          subtitle: 'View outstanding balance and payment history',
                          onTap: () => onAction('Outstanding'),
                        ),
                        _ActionTile(
                          icon: Icons.edit_outlined,
                          color: AppColors.purple,
                          title: 'Edit Customer',
                          subtitle: 'Update customer information',
                          onTap: () => onAction('Edit Customer'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textLightMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool valueAlignRight;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueAlignRight = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: valueAlignRight ? TextAlign.right : TextAlign.left,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatBox({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentOrderRow extends StatelessWidget {
  final _CustomerRecentOrder order;

  const _RecentOrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor =
        order.status == 'Confirmed' ? AppColors.primary : AppColors.orange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.adminSidebarBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_long_rounded, color: statusColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.number,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  order.date,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              order.status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            order.amount,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesManagerSidebar extends StatelessWidget {
  final ValueChanged<String> onSelect;

  const _SalesManagerSidebar({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = <_SidebarItem>[
      const _SidebarItem('Dashboard', Icons.dashboard_rounded),
      const _SidebarItem('Customers', Icons.groups_rounded),
      const _SidebarItem('Sales Orders', Icons.receipt_long_rounded),
      const _SidebarItem('Visits', Icons.place_rounded),
      const _SidebarItem('Follow-Ups', Icons.notifications_active_rounded),
      const _SidebarItem('Products', Icons.inventory_2_rounded),
      const _SidebarItem('Targets & Performance', Icons.show_chart_rounded),
      const _SidebarItem('Outstanding & Payments', Icons.payments_rounded),
      const _SidebarItem('Reports', Icons.bar_chart_rounded),
      const _SidebarItem('Check-Out', Icons.logout_rounded),
    ];

    return Drawer(
      backgroundColor: AppColors.adminSidebarBg,
      child: Container(
        color: AppColors.adminSidebarBg,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SAAS CRM',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Sales Manager',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: AppColors.border.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = item.label == 'Dashboard';
                    final isCheckout = item.label == 'Check-Out';
                    return Material(
                      color: selected
                          ? AppColors.activeMenuBg
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => onSelect(item.label),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.activeMenuBg
                                  : AppColors.border.withValues(alpha: 0.8),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color: isCheckout
                                    ? AppColors.red
                                    : selected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                size: 21,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isCheckout
                                        ? AppColors.red
                                        : selected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                    fontSize: 15,
                                    fontWeight: selected || isCheckout
                                        ? FontWeight.w800
                                        : FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (!selected)
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textLightMuted,
                                  size: 18,
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
        ),
      ),
    );
  }
}

class _SidebarItem {
  final String label;
  final IconData icon;

  const _SidebarItem(this.label, this.icon);
}

class _AddCustomerSheet extends StatefulWidget {
  final Future<void> Function(_CustomerFormData data) onSaved;

  const _AddCustomerSheet({required this.onSaved});

  @override
  State<_AddCustomerSheet> createState() => _AddCustomerSheetState();
}

class _AddCustomerSheetState extends State<_AddCustomerSheet> {
  final _businessNameController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _gstController = TextEditingController();
  final _addressController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactNameController.dispose();
    _mobileController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    _creditLimitController.dispose();
    _openingBalanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.96,
      minChildSize: 0.85,
      maxChildSize: 0.98,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Add New Customer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _saveCustomer,
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.border.withValues(alpha: 0.75),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Business Information',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _FieldCard(
                            controller: _businessNameController,
                            label: 'Business Name',
                            hintText: 'Enter business name',
                            icon: Icons.business_rounded,
                            requiredField: true,
                          ),
                          const SizedBox(height: 10),
                          _FieldCard(
                            controller: _contactNameController,
                            label: 'Contact Person Name',
                            hintText: 'Enter contact person name',
                            icon: Icons.person_outline_rounded,
                            requiredField: true,
                          ),
                          const SizedBox(height: 10),
                          _FieldCard(
                            controller: _mobileController,
                            label: 'Mobile Number',
                            hintText: 'Enter mobile number',
                            icon: Icons.call_outlined,
                            requiredField: true,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 10),
                          _FieldCard(
                            controller: _gstController,
                            label: 'GST Number',
                            hintText: 'Enter GST number',
                            icon: Icons.receipt_long_outlined,
                          ),
                          const SizedBox(height: 10),
                          _FieldCard(
                            controller: _addressController,
                            label: 'Business Address',
                            hintText: 'Enter complete address',
                            icon: Icons.location_on_outlined,
                            requiredField: true,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Other Details',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _FieldCard(
                                  controller: _creditLimitController,
                                  label: 'Credit Limit (â‚¹)',
                                  hintText: 'Enter credit limit',
                                  icon: Icons.account_balance_wallet_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _FieldCard(
                                  controller: _openingBalanceController,
                                  label: 'Opening Balance (â‚¹)',
                                  hintText: 'Enter opening balance',
                                  icon: Icons.payments_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _FieldCard(
                            controller: _notesController,
                            label: 'Notes',
                            hintText: 'Enter notes (optional)',
                            icon: Icons.notes_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(
                                      color: AppColors.primary,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveCustomer,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Save Customer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
      },
    );
  }

  void _saveCustomer() {
    final data = _CustomerFormData(
      businessName: _businessNameController.text.trim(),
      contactPerson: _contactNameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      gstNumber: _gstController.text.trim(),
      businessAddress: _addressController.text.trim(),
      creditLimit: _creditLimitController.text.trim(),
      openingBalance: _openingBalanceController.text.trim(),
      notes: _notesController.text.trim(),
    );

    Navigator.of(context).pop();
    widget.onSaved(data);
  }
}

class _CustomerFormData {
  final String businessName;
  final String contactPerson;
  final String mobileNumber;
  final String gstNumber;
  final String businessAddress;
  final String creditLimit;
  final String openingBalance;
  final String notes;

  const _CustomerFormData({
    required this.businessName,
    required this.contactPerson,
    required this.mobileNumber,
    required this.gstNumber,
    required this.businessAddress,
    required this.creditLimit,
    required this.openingBalance,
    required this.notes,
  });
}

class _SuccessDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;

  const _SuccessDetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (trailing != null)
          trailing!
        else
          Flexible(
            child: Text(
              value ?? '',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final bool requiredField;
  final int maxLines;
  final TextInputType? keyboardType;

  const _FieldCard({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.requiredField = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final displayLabel = requiredField ? '$label *' : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            displayLabel,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.85),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
              hintText: hintText,
              hintStyle: const TextStyle(
                color: AppColors.textLightMuted,
                fontSize: 12.5,
              ),
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomerRecord {
  final String name;
  final String location;
  final String outstanding;
  final String status;
  final Color color;
  final String category;
  final String since;
  final String customerCode;
  final String contactPerson;
  final String mobileNumber;
  final String email;
  final String gstNumber;
  final String address;
  final String totalOrders;
  final String totalSales;
  final List<_CustomerRecentOrder> recentOrders;

  const _CustomerRecord({
    required this.name,
    required this.location,
    required this.outstanding,
    required this.status,
    required this.color,
    required this.category,
    required this.since,
    required this.customerCode,
    required this.contactPerson,
    required this.mobileNumber,
    required this.email,
    required this.gstNumber,
    required this.address,
    required this.totalOrders,
    required this.totalSales,
    required this.recentOrders,
  });
}

class _CustomerRecentOrder {
  final String number;
  final String date;
  final String amount;
  final String status;

  const _CustomerRecentOrder({
    required this.number,
    required this.date,
    required this.amount,
    required this.status,
  });
}

Color _customerStatusColor(String status) {
  switch (status) {
    case 'Active':
      return AppColors.statusActiveText;
    case 'Inactive':
      return AppColors.statusInactiveText;
    case 'Blocked':
      return AppColors.red;
    default:
      return AppColors.primary;
  }
}

Color _customerStatusBackground(String status) {
  switch (status) {
    case 'Active':
      return AppColors.statusActiveBg;
    case 'Inactive':
      return AppColors.statusInactiveBg;
    case 'Blocked':
      return AppColors.red.withValues(alpha: 0.12);
    default:
      return AppColors.adminSidebarBg;
  }
}
