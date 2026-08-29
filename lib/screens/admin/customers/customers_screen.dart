import 'dart:async';

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import 'customer_details_screen.dart';
import 'add_customer_screen.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../../sales_manager/attendance/sales_manager_attendance_screen.dart';
import '../../sales_manager/dashboard/sales_manager_dashboard_screen.dart';
import '../../sales_manager/follow_ups/sales_manager_follow_ups_screen.dart';
import '../../sales_manager/performance/sales_manager_performance_screen.dart';
import '../../sales_manager/stock/sales_manager_stock_screen.dart';
import '../../sales_manager/visits/sales_manager_visits_screen.dart';
import '../leads/admin_leads_screen.dart';
import '../orders/admin_orders_screen.dart';
import '../orders/new_admin_order_screen.dart';

class CustomersScreen extends StatefulWidget {
  final bool useSalesManagerShell;

  const CustomersScreen({super.key, this.useSalesManagerShell = false});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  late ApiProvider _apiProvider;
  Timer? _searchDebounce;

  bool _providerReady = false;
  bool _isLoading = true;
  String? _errorMessage;

  String _search = '';
  String? _category;
  bool? _isActive;
  String? _assignedSalesOfficerId;

  List<CustomerModel> _customers = const [];

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _providerReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    final assignedSalesOfficerId = widget.useSalesManagerShell
        ? _apiProvider.currentUser?.id
        : _assignedSalesOfficerId;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final customers = await _apiProvider.fetchCustomers(
        search: _search,
        category: _category,
        isActive: _isActive,
        assignedSalesOfficerId: assignedSalesOfficerId,
      );

      if (!mounted) return;
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _customers = const [];
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  void _scheduleSearchReload(String value) {
    _search = value.trim();
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _loadCustomers();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleSalesManagerSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'Customers') return;
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
      );
      return;
    }
    if (action == 'Leads') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminLeadsScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Create Order') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const NewAdminOrderScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Sales Orders') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminOrdersScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Stock') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerStockScreen()),
      );
      return;
    }
    if (action == 'Follow-ups' || action == 'Follow-Ups') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerFollowUpsScreen()),
      );
      return;
    }
    if (action == 'Attendance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerAttendanceScreen()),
      );
      return;
    }
    if (action == 'Visits') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
      );
      return;
    }
    if (action == 'My Performance') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const SalesManagerPerformanceScreen(),
        ),
      );
    }
  }

  Future<bool> _confirmDeleteCustomer(CustomerModel customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Customer',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            'Delete ${customer.name}? This action cannot be undone.',
            style: const TextStyle(height: 1.4),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return confirmed == true;
  }

  Future<void> _deleteCustomer(CustomerModel customer) async {
    final confirmed = await _confirmDeleteCustomer(customer);
    if (!confirmed || !mounted) return;

    try {
      await _apiProvider.deleteCustomer(customer.id);
      if (!mounted) return;
      _showMessage('${customer.name} deleted successfully.');
      await _loadCustomers();
    } catch (error) {
      if (!mounted) return;
      _showMessage(error.toString());
    }
  }

  Future<void> _openFilterSheet() async {
    final categoryController = TextEditingController(text: _category ?? '');
    final assignedSalesOfficerController = TextEditingController(
      text: _assignedSalesOfficerId ?? '',
    );
    bool? selectedIsActive = _isActive;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                left: 18,
                right: 18,
                top: 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Customer Filters',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.of(sheetContext).pop(false),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _filterField(
                      label: 'Category',
                      hint: 'category',
                      controller: categoryController,
                    ),
                    const SizedBox(height: 14),
                    if (!widget.useSalesManagerShell) ...[
                      _filterField(
                        label: 'Assigned Sales Officer ID',
                        hint: 'assigned_sales_officer_id',
                        controller: assignedSalesOfficerController,
                      ),
                      const SizedBox(height: 14),
                    ],
                    DropdownButtonFormField<bool?>(
                      key: ValueKey<bool?>(selectedIsActive),
                      initialValue: selectedIsActive,
                      items: const [
                        DropdownMenuItem<bool?>(
                          value: null,
                          child: Text('All Status'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: true,
                          child: Text('Active'),
                        ),
                        DropdownMenuItem<bool?>(
                          value: false,
                          child: Text('Inactive'),
                        ),
                      ],
                      onChanged: (value) {
                        setSheetState(() => selectedIsActive = value);
                      },
                      decoration: _inputDecoration('Status', 'is_active'),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setSheetState(() {
                                categoryController.clear();
                                if (!widget.useSalesManagerShell) {
                                  assignedSalesOfficerController.clear();
                                }
                                selectedIsActive = null;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.red,
                              side: const BorderSide(color: AppColors.red),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Clear'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(sheetContext).pop(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != true || !mounted) {
      return;
    }

    setState(() {
      _category = categoryController.text.trim().isEmpty
          ? null
          : categoryController.text.trim();
      if (!widget.useSalesManagerShell) {
        _assignedSalesOfficerId =
            assignedSalesOfficerController.text.trim().isEmpty
            ? null
            : assignedSalesOfficerController.text.trim();
      }
      _isActive = selectedIsActive;
    });

    await _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: widget.useSalesManagerShell
          ? SalesManagerSidebarDrawer(
              currentPage: 'Customers',
              onSelect: _handleSalesManagerSidebarSelection,
            )
          : const AppDrawer(activeItem: 'Customers'),
      body: SafeArea(
        child: Column(
          children: [
            widget.useSalesManagerShell
                ? const SalesManagerTopBar(title: 'Customers')
                : AdminTopBar(
                    title: 'Customers',
                    leadingIcon: Icons.menu_rounded,
                    onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadCustomers,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titleRow(),
                      const SizedBox(height: 10),
                      _searchRow(),
                      const SizedBox(height: 10),
                      _filterChips(),
                      const SizedBox(height: 10),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (_errorMessage != null)
                        _errorState(_errorMessage!)
                      else if (_customers.isEmpty)
                        _emptyState()
                      else
                        ..._customers.map(
                          (customer) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _customerCard(customer),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text.rich(
                        TextSpan(
                          text: 'Total Customers: ',
                          children: [
                            TextSpan(
                              text: '${_customers.length}',
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
              fontSize: 19,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _openAddCustomerScreen,
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Customer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 12,
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
            height: 38,
            child: TextField(
              controller: _searchController,
              onChanged: _scheduleSearchReload,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search name, business, phone, email...',
                hintStyle: const TextStyle(
                  color: textSecondary,
                  fontSize: 12,
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
            onTap: _openFilterSheet,
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

  Widget _filterChips() {
    final chips = <Widget>[];

    if (_category != null && _category!.isNotEmpty) {
      chips.add(_filterChip('Category: $_category'));
    }
    if (_isActive != null) {
      chips.add(
        _filterChip('Status: ${_isActive == true ? 'Active' : 'Inactive'}'),
      );
    }
    if (!widget.useSalesManagerShell &&
        _assignedSalesOfficerId != null &&
        _assignedSalesOfficerId!.isNotEmpty) {
      chips.add(_filterChip('Sales Officer: $_assignedSalesOfficerId'));
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...chips,
        ActionChip(
          label: const Text('Clear filters'),
          onPressed: () {
            setState(() {
              _category = null;
              _isActive = null;
              if (!widget.useSalesManagerShell) {
                _assignedSalesOfficerId = null;
              }
              _search = '';
              _searchController.clear();
            });
            _loadCustomers();
          },
          backgroundColor: const Color(0xFFF4F6F8),
        ),
      ],
    );
  }

  Widget _filterChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.surfaceSoft,
      side: BorderSide(color: AppColors.borderLight),
    );
  }

  Widget _customerCard(CustomerModel customer) {
    final statusActive = customer.isActive != false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(customer.initials, compact ? 42 : 48),
              const SizedBox(width: 8),
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
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _statusChip(customer),
                      ],
                    ),
                    const SizedBox(height: 3),
                    if (customer.businessName != null)
                      Text(
                        customer.businessName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 6),
                    _infoPairRow(
                      leftIcon: Icons.phone_outlined,
                      leftText: customer.phone ?? '--',
                      rightIcon: Icons.business_outlined,
                      rightText: customer.category ?? 'Category --',
                    ),
                    const SizedBox(height: 5),
                    _infoPairRow(
                      leftIcon: Icons.person_outline_rounded,
                      leftText:
                          customer.assignedSalesOfficerName ??
                          customer.assignedSalesOfficerId ??
                          'Sales officer --',
                      rightIcon: Icons.circle_rounded,
                      rightText: statusActive ? 'Active' : 'Inactive',
                      rightIconColor: statusActive
                          ? AppColors.statusActiveText
                          : AppColors.red,
                    ),
                    const SizedBox(height: 5),
                    _infoPairRow(
                      leftIcon: Icons.credit_card_rounded,
                      leftText:
                          'Credit Limit: ${_formatCurrency(customer.creditLimit)}',
                      rightIcon: Icons.currency_rupee_rounded,
                      rightText: _formatCurrency(customer.outstanding),
                      rightIconColor: AppColors.statusActiveText,
                    ),
                    const SizedBox(height: 7),
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

  Future<void> _openAddCustomerScreen() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddCustomerScreen()));

    if (result != null && mounted) {
      await _loadCustomers();
    }
  }

  Future<void> _openEditCustomerScreen(CustomerModel customer) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddCustomerScreen(
          customerId: customer.id,
          existingCustomer: customer,
        ),
      ),
    );

    if (result != null && mounted) {
      await _loadCustomers();
    }
  }

  Future<void> _openCustomerDetailsScreen(CustomerModel customer) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CustomerDetailsScreen(
          customerId: customer.id,
          initialCustomer: customer,
        ),
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
        const SizedBox(width: 6),
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

  Widget _infoLine(
    IconData icon,
    String text, {
    Color iconColor = textPrimary,
  }) {
    return Row(
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 10.8,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionRow(CustomerModel customer) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _actionButton(
          icon: Icons.visibility_outlined,
          label: 'View Details',
          color: AppColors.primary,
          backgroundColor: const Color(0xFFF3F5F8),
          onTap: () => _openCustomerDetailsScreen(customer),
        ),
        const SizedBox(width: 5),
        _actionButton(
          icon: Icons.edit_outlined,
          label: 'Edit',
          color: textPrimary,
          backgroundColor: const Color(0xFFF3F5F8),
          onTap: () => _openEditCustomerScreen(customer),
        ),
        const SizedBox(width: 5),
        _actionButton(
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          color: AppColors.red,
          backgroundColor: const Color(0xFFFFEBEB),
          onTap: () => _deleteCustomer(customer),
        ),
      ],
    );
  }

  Widget _avatar(String initials, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.24,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _statusChip(CustomerModel customer) {
    final active = customer.isActive != false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.statusActiveBg : AppColors.statusInactiveBg,
        borderRadius: BorderRadius.circular(12),
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
              fontSize: 10.8,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 5),
          Container(
            width: 6,
            height: 6,
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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 29,
          height: 29,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }

  Widget _errorState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: AppColors.textSecondary,
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              'Could not load customers',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCustomers,
              child: const Text('Retry'),
            ),
          ],
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

  Widget _filterField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: textPrimary),
          decoration: _inputDecoration(label, hint),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderStrong),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  OutlineInputBorder _outlineBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }

  String _formatCurrency(num? value) {
    if (value == null) return '--';
    final raw = value.toStringAsFixed(value % 1 == 0 ? 0 : 2);
    final parts = raw.split('.');
    final whole = parts.first;
    final fraction = parts.length > 1 ? '.${parts.last}' : '';
    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      final fromEnd = whole.length - i;
      buffer.write(whole[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write(',');
    }
    return 'Rs. $buffer$fraction';
  }
}
