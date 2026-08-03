import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  String _query = '';

  final List<_CustomerItem> _customers = const [
    _CustomerItem(
      name: 'Rahul Sharma',
      phone: '9876543210',
      salesOfficer: 'Amit Patil',
      creditLimit: 100000,
      outstanding: 35500,
      isActive: true,
      avatarAsset: 'assets/avatar1.png',
    ),
    _CustomerItem(
      name: 'Priya Mehta',
      phone: '9123456780',
      salesOfficer: 'Neha Gupta',
      creditLimit: 75000,
      outstanding: 18750,
      isActive: true,
      avatarAsset: 'assets/avatar2.png',
    ),
    _CustomerItem(
      name: 'Vikram Singh',
      phone: '9988776655',
      salesOfficer: 'Amit Patil',
      creditLimit: 50000,
      outstanding: 7200,
      isActive: false,
      avatarAsset: 'assets/avatar3.png',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_CustomerItem> get _filteredCustomers {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _customers;

    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(query) ||
          customer.phone.toLowerCase().contains(query) ||
          customer.salesOfficer.toLowerCase().contains(query) ||
          customer.statusLabel.toLowerCase().contains(query);
    }).toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showCustomerDetails(_CustomerItem customer) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _avatar(customer, 58),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      customer.name,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _statusChip(customer),
                ],
              ),
              const SizedBox(height: 18),
              _detailRow('Phone', customer.phone),
              _detailRow('Sales Officer', customer.salesOfficer),
              _detailRow('Credit Limit', _formatCurrency(customer.creditLimit)),
              _detailRow('Outstanding', _formatCurrency(customer.outstanding)),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: textSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = _filteredCustomers;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeItem: 'Customers'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Customers',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleRow(),
                    const SizedBox(height: 14),
                    _searchRow(),
                    const SizedBox(height: 14),
                    if (customers.isEmpty)
                      _emptyState()
                    else
                      ...customers.map(
                        (customer) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _customerCard(customer),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        text: 'Total Customers: ',
                        children: [
                          TextSpan(
                            text: '${customers.length}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
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
  }

  Widget _titleRow() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Customers',
            style: TextStyle(
              color: textPrimary,
              fontSize: 22,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: () => _showMessage('Add customer is not connected yet.'),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Add Customer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchRow() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search customers...',
                hintStyle: const TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 8, right: 2),
                  child: Icon(
                    Icons.search_rounded,
                    color: textPrimary,
                    size: 21,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 42,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                border: _outlineBorder(AppColors.borderStrong),
                enabledBorder: _outlineBorder(AppColors.borderStrong),
                focusedBorder: _outlineBorder(AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: 'Filter customers',
          child: InkWell(
            onTap: () => _showMessage('Customer filters are not connected yet.'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderStrong),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.filter_list_rounded,
                color: textPrimary,
                size: 21,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _customerCard(_CustomerItem customer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(customer, compact ? 52 : 60),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            customer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _statusChip(customer),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _infoPairRow(
                      leftIcon: Icons.phone_outlined,
                      leftText: customer.phone,
                      rightIcon: Icons.person_outline_rounded,
                      rightText: 'Sales Officer: ${customer.salesOfficer}',
                    ),
                    const SizedBox(height: 7),
                    _infoPairRow(
                      leftIcon: Icons.credit_card_rounded,
                      leftText:
                          'Credit Limit: ${_formatCurrency(customer.creditLimit)}',
                      rightIcon: Icons.currency_rupee_rounded,
                      rightText:
                          'Outstanding: ${_formatCurrency(customer.outstanding)}',
                      rightIconColor: AppColors.statusActiveText,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _actionRow(customer),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoPairRow({
    required IconData leftIcon,
    required String leftText,
    required IconData rightIcon,
    required String rightText,
    Color? rightIconColor,
  }) {
    return Row(
      children: [
        Expanded(child: _infoLine(leftIcon, leftText)),
        const SizedBox(width: 8),
        Expanded(
          child: _infoLine(
            rightIcon,
            rightText,
            iconColor: rightIconColor ?? textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _infoLine(IconData icon, String text, {Color iconColor = textPrimary}) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionRow(_CustomerItem customer) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionButton(
          icon: Icons.visibility_rounded,
          label: 'View',
          color: AppColors.primary,
          backgroundColor: AppColors.statusActiveBg,
          onTap: () => _showCustomerDetails(customer),
        ),
        const SizedBox(width: 6),
        _actionButton(
          icon: Icons.edit_outlined,
          label: 'Edit',
          color: textPrimary,
          backgroundColor: const Color(0xFFF3F5F8),
          onTap: () => _showMessage('Edit customer is not connected yet.'),
        ),
        const SizedBox(width: 6),
        _actionButton(
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          color: AppColors.red,
          backgroundColor: const Color(0xFFFFEBEB),
          onTap: () => _showMessage('Delete customer is not connected yet.'),
        ),
      ],
    );
  }

  Widget _avatar(_CustomerItem customer, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        customer.avatarAsset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              customer.initials,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.24,
                letterSpacing: 0,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(_CustomerItem customer) {
    final active = customer.isActive;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: active ? AppColors.statusActiveBg : AppColors.statusInactiveBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            customer.statusLabel,
            style: TextStyle(
              color: active
                  ? AppColors.statusActiveText
                  : AppColors.statusInactiveText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: active ? AppColors.statusActiveText : AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Center(
        child: Text(
          'No customers match your search.',
          style: TextStyle(color: textSecondary, fontSize: 15),
        ),
      ),
    );
  }

  OutlineInputBorder _outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }

  String _formatCurrency(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final fromEnd = raw.length - i;
      buffer.write(raw[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
    }
    return '₹$buffer';
  }
}

class _CustomerItem {
  final String name;
  final String phone;
  final String salesOfficer;
  final int creditLimit;
  final int outstanding;
  final bool isActive;
  final String avatarAsset;

  const _CustomerItem({
    required this.name,
    required this.phone,
    required this.salesOfficer,
    required this.creditLimit,
    required this.outstanding,
    required this.isActive,
    required this.avatarAsset,
  });

  String get statusLabel => isActive ? 'Active' : 'Inactive';

  String get initials {
    return name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
  }
}
