import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class SalesManagerCustomersScreen extends StatefulWidget {
  const SalesManagerCustomersScreen({super.key});

  @override
  State<SalesManagerCustomersScreen> createState() =>
      _SalesManagerCustomersScreenState();
}

class _SalesManagerCustomersScreenState
    extends State<SalesManagerCustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = const [
    'All (56)',
    'Assigned (24)',
    'Recently Visited (16)',
  ];

  final List<_CustomerRecord> _allCustomers = const [
    _CustomerRecord(
      name: 'Shree Ganesh Traders',
      location: 'Dadar, Mumbai',
      outstanding: 'Rs. 45,000',
      status: 'Active',
      color: AppColors.primary,
    ),
    _CustomerRecord(
      name: 'Maa Durga Stores',
      location: 'Matunga, Mumbai',
      outstanding: 'Rs. 12,500',
      status: 'Active',
      color: AppColors.primary,
    ),
    _CustomerRecord(
      name: 'Patel Retailers',
      location: 'Sion, Mumbai',
      outstanding: 'Rs. 0',
      status: 'Active',
      color: AppColors.primary,
    ),
    _CustomerRecord(
      name: 'S.K. Enterprises',
      location: 'Ghatkopar, Mumbai',
      outstanding: 'Rs. 78,300',
      status: 'Overdue',
      color: AppColors.primary,
    ),
    _CustomerRecord(
      name: 'New A One Traders',
      location: 'Kurla, Mumbai',
      outstanding: 'Rs. 18,700',
      status: 'Active',
      color: AppColors.primary,
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
      backgroundColor: AppColors.background,
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
        return _allCustomers.take(4).toList();
      case 2:
        return _allCustomers.skip(2).toList();
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
            onPressed: () => Navigator.of(context).maybePop(),
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
    final isOverdue = customer.status == 'Overdue';

    return Container(
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
                  style: TextStyle(
                    color: isOverdue ? AppColors.red : AppColors.red,
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
              color: isOverdue
                  ? AppColors.statusInactiveBg
                  : AppColors.statusActiveBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              customer.status,
              style: TextStyle(
                color: isOverdue
                    ? AppColors.statusInactiveText
                    : AppColors.statusActiveText,
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
    );
  }
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
                                  label: 'Credit Limit (₹)',
                                  hintText: 'Enter credit limit',
                                  icon: Icons.account_balance_wallet_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _FieldCard(
                                  controller: _openingBalanceController,
                                  label: 'Opening Balance (₹)',
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

  const _CustomerRecord({
    required this.name,
    required this.location,
    required this.outstanding,
    required this.status,
    required this.color,
  });
}
