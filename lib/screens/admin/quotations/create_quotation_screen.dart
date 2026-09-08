import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/app_user.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
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
import '../customers/customers_screen.dart';
import '../leads/admin_leads_screen.dart';
import '../orders/admin_orders_screen.dart';
import '../orders/new_admin_order_screen.dart';
import 'admin_quotations_screen.dart';

class NewQuotationScreen extends StatefulWidget {
  final bool useSalesManagerShell;

  const NewQuotationScreen({super.key, this.useSalesManagerShell = false});

  @override
  State<NewQuotationScreen> createState() => _NewQuotationScreenState();
}

class _NewQuotationScreenState extends State<NewQuotationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _billingAddressController =
      TextEditingController();
  final TextEditingController _shippingAddressController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _termsController = TextEditingController(
    text: 'Prices are valid until the quotation expiry date.',
  );

  late ApiProvider _apiProvider;
  bool _providerReady = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;

  int _step = 0;
  bool _forCustomer = true;
  String _currency = 'INR';
  String _paymentTerms = 'Net 15';
  String _deliveryTerms = 'Standard delivery';
  DateTime _quotationDate = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 14));

  List<CustomerModel> _customers = const [];
  List<_LeadOption> _leads = const [];
  List<_ProductOption> _products = const [];
  List<AppUser> _salespeople = const [];
  final List<_QuoteItem> _items = [];

  CustomerModel? _selectedCustomer;
  _LeadOption? _selectedLead;
  AppUser? _selectedSalesperson;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _providerReady = true;
    _apiProvider = ApiProviderScope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _apiProvider.fetchCustomers(),
        _apiProvider.fetchLeads(),
        _apiProvider.fetchProducts(isActive: true),
        _apiProvider.fetchAssignableUsers(),
      ]);

      final customers = (results[0] as List<CustomerModel>)
          .where((customer) => customer.name.trim().isNotEmpty)
          .toList();
      final leads = (results[1] as List<Map<String, dynamic>>)
          .map(_LeadOption.fromJson)
          .where((lead) => lead.name.isNotEmpty && lead.isQuotable)
          .toList();
      final products = (results[2] as List<Map<String, dynamic>>)
          .map(_ProductOption.fromJson)
          .where((product) => product.id.isNotEmpty && product.name.isNotEmpty)
          .toList();
      final salespeople = (results[3] as List<AppUser>)
          .where((user) => user.id.trim().isNotEmpty)
          .toList();

      if (!mounted) return;
      setState(() {
        _customers = customers;
        _leads = leads;
        _products = products;
        _salespeople = salespeople;
        _selectedCustomer = customers.isNotEmpty ? customers.first : null;
        _selectedSalesperson = _currentUserAsSalesperson(salespeople);
        _applyCustomerDefaults(_selectedCustomer);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  AppUser? _currentUserAsSalesperson(List<AppUser> salespeople) {
    final currentId = _apiProvider.currentUser?.id?.trim();
    if (currentId != null && currentId.isNotEmpty) {
      for (final user in salespeople) {
        if (user.id == currentId) return user;
      }
    }
    return salespeople.isNotEmpty ? salespeople.first : null;
  }

  void _applyCustomerDefaults(CustomerModel? customer) {
    if (customer == null) return;
    _billingAddressController.text =
        (customer.billingAddress ?? customer.address ?? '').trim();
    _shippingAddressController.text =
        (customer.deliveryAddress ?? customer.address ?? '').trim();
    if ((customer.assignedSalesOfficerId ?? '').trim().isNotEmpty) {
      for (final user in _salespeople) {
        if (user.id == customer.assignedSalesOfficerId) {
          _selectedSalesperson = user;
          break;
        }
      }
    }
  }

  void _applyLeadDefaults(_LeadOption? lead) {
    if (lead == null) return;
    _billingAddressController.text = lead.address;
    _shippingAddressController.text = lead.address;
    if (lead.salespersonId.isNotEmpty) {
      for (final user in _salespeople) {
        if (user.id == lead.salespersonId) {
          _selectedSalesperson = user;
          break;
        }
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _quickAddCustomer() async {
    final created = await showDialog<CustomerModel>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (context) => _QuickAddCustomerDialog(apiProvider: _apiProvider),
    );
    if (created == null || !mounted) return;
    setState(() {
      _customers = [created, ..._customers];
      _selectedCustomer = created;
      _forCustomer = true;
      _applyCustomerDefaults(created);
    });
  }

  void _addProduct(_ProductOption product) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);
    setState(() {
      if (existingIndex >= 0) {
        _items[existingIndex] = _items[existingIndex].copyWith(
          quantity: _items[existingIndex].quantity + 1,
        );
      } else {
        _items.add(_QuoteItem(product: product, quantity: 1));
      }
    });
  }

  void _changeQuantity(int index, double delta) {
    final item = _items[index];
    final next = item.quantity + delta;
    setState(() {
      if (next <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = item.copyWith(quantity: next);
      }
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  bool _validateStep({bool showMessage = true}) {
    if (_step == 0) {
      if (_forCustomer && _selectedCustomer == null) {
        if (showMessage) _showSnack('Select a customer.');
        return false;
      }
      if (!_forCustomer && _selectedLead == null) {
        if (showMessage) _showSnack('Select a lead or prospect.');
        return false;
      }
      if (_selectedSalesperson == null) {
        if (showMessage) _showSnack('Select a salesperson.');
        return false;
      }
      if (_validUntil.isBefore(_quotationDate)) {
        if (showMessage) {
          _showSnack('Valid until cannot be before quotation date.');
        }
        return false;
      }
    }
    if (_step == 1 && _items.isEmpty) {
      if (showMessage) _showSnack('Add at least one product.');
      return false;
    }
    return true;
  }

  void _nextStep() {
    if (!_validateStep()) return;
    if (_step < 2) setState(() => _step++);
  }

  void _previousStep() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _step--);
  }

  Future<void> _saveQuotation() async {
    if (_isSaving) return;
    if (!_validateStep()) return;
    if (_items.isEmpty) {
      _showSnack('Add at least one product.');
      setState(() => _step = 1);
      return;
    }

    final request = <String, dynamic>{
      'quotation_number': 'QT-${DateTime.now().millisecondsSinceEpoch}',
      'quotation_date': _apiDate(_quotationDate),
      'valid_until': _apiDate(_validUntil),
      'currency': _currency,
      'status': 'draft',
      'salesperson_id': _selectedSalesperson!.id,
      'billing_address': _billingAddressController.text.trim(),
      'shipping_address': _shippingAddressController.text.trim(),
      'payment_terms': _paymentTerms,
      'delivery_terms': _deliveryTerms,
      'notes': _notesController.text.trim(),
      'terms_conditions': _termsController.text.trim(),
      'items': _items.map((item) => item.toApi()).toList(),
    };
    if (_forCustomer) {
      request['customer_id'] = _selectedCustomer!.id;
    } else {
      request['customer_id'] = '';
      request['lead_id'] = _selectedLead!.id;
      request['lead_name'] = _selectedLead!.name;
    }

    setState(() => _isSaving = true);
    try {
      await _apiProvider.createQuotation(request: request);
      if (!mounted) return;
      _showSnack('Quotation saved');
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _showSnack('Failed to save quotation: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleSalesManagerSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'Quotations' || action == 'Quotation') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminQuotationsScreen(useSalesManagerShell: true),
        ),
      );
      return;
    }
    if (action == 'Dashboard') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerDashboardScreen()),
      );
      return;
    }
    if (action == 'Customers') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CustomersScreen(useSalesManagerShell: true),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F8FC),
      drawer: widget.useSalesManagerShell
          ? SalesManagerSidebarDrawer(
              currentPage: 'Quotations',
              onSelect: _handleSalesManagerSidebarSelection,
            )
          : const AppDrawer(activeItem: 'Quotation'),
      body: SafeArea(
        child: Column(
          children: [
            widget.useSalesManagerShell
                ? const SalesManagerTopBar(title: 'Create Quotation')
                : AdminTopBar(
                    title: 'Create Quotation',
                    leadingIcon: Icons.arrow_back_rounded,
                    onLeadingTap: () => Navigator.of(context).maybePop(),
                  ),
            Expanded(
              child: _isLoading
                  ? const _CenteredState(
                      icon: Icons.receipt_long_outlined,
                      title: 'Loading quotation form',
                      message: 'Fetching customers, leads, products and staff.',
                    )
                  : _loadError != null
                      ? _CenteredState(
                          icon: Icons.error_outline_rounded,
                          title: 'Unable to load quotation form',
                          message: _loadError!,
                          actionLabel: 'Retry',
                          onAction: _loadData,
                        )
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final maxWidth = wide ? 860.0 : constraints.maxWidth;
        return Center(
          child: SizedBox(
            width: maxWidth,
            child: Column(
              children: [
                _buildStepper(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      wide ? 24 : 16,
                      10,
                      wide ? 24 : 16,
                      16,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: KeyedSubtree(
                        key: ValueKey<int>(_step),
                        child: _step == 0
                            ? _buildDetailsStep()
                            : _step == 1
                                ? _buildItemsStep()
                                : _buildReviewStep(),
                      ),
                    ),
                  ),
                ),
                _buildBottomActions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepper() {
    final labels = const ['Details', 'Items', 'Review'];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i == 0
                              ? Colors.transparent
                              : (_step >= i
                                  ? const Color(0xFF284BFF)
                                  : AppColors.border),
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color:
                              _step >= i ? const Color(0xFF284BFF) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _step >= i
                                ? const Color(0xFF284BFF)
                                : AppColors.borderStrong,
                          ),
                        ),
                        child: Center(
                          child: _step > i
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: _step >= i
                                        ? Colors.white
                                        : AppColors.textMuted,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i == labels.length - 1
                              ? Colors.transparent
                              : (_step > i
                                  ? const Color(0xFF284BFF)
                                  : AppColors.border),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    labels[i],
                    style: TextStyle(
                      color:
                          _step == i ? const Color(0xFF1234D8) : AppColors.textMuted,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Quotation For'),
          _SegmentedChoice(
            firstLabel: 'Customer',
            secondLabel: 'Lead / Prospect',
            firstSelected: _forCustomer,
            onFirst: () => setState(() => _forCustomer = true),
            onSecond: () => setState(() => _forCustomer = false),
          ),
          const SizedBox(height: 14),
          if (_forCustomer)
            _SelectTile(
              label: 'Customer',
              value: _selectedCustomer?.name,
              hint: 'Select customer',
              icon: Icons.business_outlined,
              onTap: _showCustomerPicker,
              trailing: IconButton(
                onPressed: _quickAddCustomer,
                icon: const Icon(Icons.add_rounded, color: Color(0xFF284BFF)),
              ),
            )
          else
            _SelectTile(
              label: 'Lead / Prospect',
              value: _selectedLead?.name,
              hint: 'Select lead',
              icon: Icons.person_add_alt_1_outlined,
              onTap: _showLeadPicker,
            ),
          const SizedBox(height: 12),
          _SelectTile(
            label: 'Salesperson',
            value: _selectedSalesperson?.name,
            hint: 'Select salesperson',
            icon: Icons.person_outline_rounded,
            onTap: _showSalespersonPicker,
          ),
          const SizedBox(height: 12),
          _SelectTile(
            label: 'Currency',
            value: _currency == 'INR' ? 'INR - Indian Rupee' : _currency,
            hint: 'Select currency',
            icon: Icons.currency_rupee_rounded,
            onTap: _showCurrencyPicker,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  label: 'Quotation Date',
                  value: _formatDate(_quotationDate),
                  onTap: () => _pickDate(isValidUntil: false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateTile(
                  label: 'Valid Until',
                  value: _formatDate(_validUntil),
                  onTap: () => _pickDate(isValidUntil: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SelectTile(
            label: 'Payment Terms',
            value: _paymentTerms,
            hint: 'Payment terms',
            icon: Icons.payments_outlined,
            onTap: _showPaymentPicker,
          ),
          const SizedBox(height: 12),
          _SelectTile(
            label: 'Delivery Terms',
            value: _deliveryTerms,
            hint: 'Delivery terms',
            icon: Icons.local_shipping_outlined,
            onTap: _showDeliveryPicker,
          ),
          const SizedBox(height: 12),
          _AppTextField(
            label: 'Billing Address',
            controller: _billingAddressController,
            minLines: 2,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _AppTextField(
            label: 'Shipping Address',
            controller: _shippingAddressController,
            minLines: 2,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsStep() {
    final query = _searchController.text.trim().toLowerCase();
    final visibleProducts = _products.where((product) {
      if (query.isEmpty) return true;
      return product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Add Products'),
              const SizedBox(height: 10),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration(
                  'Search products...',
                  prefixIcon: Icons.search_rounded,
                ),
              ),
              const SizedBox(height: 12),
              if (visibleProducts.isEmpty)
                const _EmptyInline('No matching products found.')
              else
                for (var i = 0; i < visibleProducts.take(8).length; i++) ...[
                  _ProductPickerRow(
                    product: visibleProducts[i],
                    onAdd: () => _addProduct(visibleProducts[i]),
                  ),
                  if (i != visibleProducts.take(8).length - 1)
                    const SizedBox(height: 8),
                ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Added Items (${_items.length})'),
              const SizedBox(height: 10),
              if (_items.isEmpty)
                const _EmptyInline('Add products to build this quotation.')
              else
                for (var i = 0; i < _items.length; i++) ...[
                  _QuoteItemRow(
                    item: _items[i],
                    onDecrease: () => _changeQuantity(i, -1),
                    onIncrease: () => _changeQuantity(i, 1),
                    onRemove: () => _removeItem(i),
                  ),
                  if (i != _items.length - 1) const SizedBox(height: 8),
                ],
              if (_items.isNotEmpty) ...[
                const SizedBox(height: 14),
                _TotalsPanel(
                  subtotal: _subtotal,
                  discount: _discountTotal,
                  tax: _taxTotal,
                  total: _grandTotal,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    final customerName =
        _forCustomer ? (_selectedCustomer?.name ?? '-') : (_selectedLead?.name ?? '-');
    return Column(
      children: [
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Customer & Details'),
              _ReviewRow('Customer', customerName),
              _ReviewRow('Salesperson', _selectedSalesperson?.name ?? '-'),
              _ReviewRow('Currency', _currency),
              _ReviewRow('Quotation Date', _formatDate(_quotationDate)),
              _ReviewRow('Valid Until', _formatDate(_validUntil)),
              _ReviewRow('Payment Terms', _paymentTerms),
              _ReviewRow('Delivery Terms', _deliveryTerms),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle('Items (${_items.length})'),
              const SizedBox(height: 10),
              for (final item in _items) ...[
                _ReviewItemRow(item: item),
                const SizedBox(height: 8),
              ],
              const Divider(height: 22, color: AppColors.border),
              _TotalsPanel(
                subtotal: _subtotal,
                discount: _discountTotal,
                tax: _taxTotal,
                total: _grandTotal,
                compact: true,
              ),
              const SizedBox(height: 12),
              _AppTextField(
                label: 'Notes',
                controller: _notesController,
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _AppTextField(
                label: 'Terms & Conditions',
                controller: _termsController,
                minLines: 2,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _previousStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_step == 0 ? 'Cancel' : 'Back'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    _isSaving ? null : (_step == 2 ? _saveQuotation : _nextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF284BFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isSaving
                      ? 'Saving...'
                      : _step == 2
                          ? 'Save Quotation'
                          : 'Next',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isValidUntil}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isValidUntil ? _validUntil : _quotationDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isValidUntil) {
        _validUntil = picked;
      } else {
        _quotationDate = picked;
        if (_validUntil.isBefore(picked)) {
          _validUntil = picked.add(const Duration(days: 14));
        }
      }
    });
  }

  Future<void> _showCustomerPicker() async {
    final customer = await _showOptionSheet<CustomerModel>(
      title: 'Select customer',
      items: _customers,
      label: (customer) => customer.name,
      subtitle: (customer) => customer.phone ?? customer.email ?? '',
    );
    if (customer == null) return;
    setState(() {
      _selectedCustomer = customer;
      _applyCustomerDefaults(customer);
    });
  }

  Future<void> _showLeadPicker() async {
    final lead = await _showOptionSheet<_LeadOption>(
      title: 'Select lead',
      items: _leads,
      label: (lead) => lead.name,
      subtitle: (lead) => lead.phone,
    );
    if (lead == null) return;
    setState(() {
      _selectedLead = lead;
      _applyLeadDefaults(lead);
    });
  }

  Future<void> _showSalespersonPicker() async {
    final user = await _showOptionSheet<AppUser>(
      title: 'Select salesperson',
      items: _salespeople,
      label: (user) => user.name,
      subtitle: (user) => user.email,
    );
    if (user == null) return;
    setState(() => _selectedSalesperson = user);
  }

  Future<void> _showCurrencyPicker() async {
    final value = await _showTextOptions(
      'Select currency',
      const ['INR', 'USD', 'AED', 'SGD', 'GBP'],
    );
    if (value != null) setState(() => _currency = value);
  }

  Future<void> _showPaymentPicker() async {
    final value = await _showTextOptions(
      'Payment terms',
      const ['Net 15', 'Net 30', 'Advance', 'Immediate', 'Due on Receipt'],
    );
    if (value != null) setState(() => _paymentTerms = value);
  }

  Future<void> _showDeliveryPicker() async {
    final value = await _showTextOptions(
      'Delivery terms',
      const [
        'Standard delivery',
        'Express delivery',
        'Customer pickup',
        'Delivery within 2 business days',
      ],
    );
    if (value != null) setState(() => _deliveryTerms = value);
  }

  Future<String?> _showTextOptions(String title, List<String> items) {
    return _showOptionSheet<String>(
      title: title,
      items: items,
      label: (value) => value,
      subtitle: (_) => '',
    );
  }

  Future<T?> _showOptionSheet<T>({
    required String title,
    required List<T> items,
    required String Function(T item) label,
    required String Function(T item) subtitle,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxHeight: 520),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 10, 10),
                child: Row(
                  children: [
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
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Flexible(
                child: items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(18),
                        child: _EmptyInline('No options available.'),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final sub = subtitle(item).trim();
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            tileColor: const Color(0xFFF8FAFC),
                            title: Text(
                              label(item),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: sub.isEmpty
                                ? null
                                : Text(sub, style: const TextStyle(fontSize: 11)),
                            onTap: () => Navigator.of(context).pop(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  double get _discountTotal =>
      _items.fold(0, (sum, item) => sum + item.discountAmount);
  double get _taxTotal => _items.fold(0, (sum, item) => sum + item.taxAmount);
  double get _grandTotal => _subtotal - _discountTotal + _taxTotal;
}

class _QuickAddCustomerDialog extends StatefulWidget {
  final ApiProvider apiProvider;

  const _QuickAddCustomerDialog({required this.apiProvider});

  @override
  State<_QuickAddCustomerDialog> createState() => _QuickAddCustomerDialogState();
}

class _QuickAddCustomerDialogState extends State<_QuickAddCustomerDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final customer = await widget.apiProvider.createCustomer(
        request: CustomerCreateRequest(
          name: name,
          businessName: name,
          phone: phone,
          email: _emailController.text.trim(),
          billingAddress: _addressController.text.trim(),
          deliveryAddress: _addressController.text.trim(),
        ),
      );
      if (mounted) Navigator.of(context).pop(customer);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add customer: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(18),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 430),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add Customer',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _AppTextField(label: 'Customer Name *', controller: _nameController),
            const SizedBox(height: 10),
            _AppTextField(
              label: 'Phone *',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            _AppTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            _AppTextField(
              label: 'Billing Address',
              controller: _addressController,
              minLines: 2,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF284BFF),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_saving ? 'Saving...' : 'Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SegmentedChoice extends StatelessWidget {
  final String firstLabel;
  final String secondLabel;
  final bool firstSelected;
  final VoidCallback onFirst;
  final VoidCallback onSecond;

  const _SegmentedChoice({
    required this.firstLabel,
    required this.secondLabel,
    required this.firstSelected,
    required this.onFirst,
    required this.onSecond,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: firstLabel,
              selected: firstSelected,
              onTap: onFirst,
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: secondLabel,
              selected: !firstSelected,
              onTap: onSecond,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF284BFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SelectTile({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = (value ?? '').trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasValue ? value! : hint,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          hasValue ? AppColors.textSecondary : AppColors.textLightMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                trailing ??
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _SelectTile(
      label: label,
      value: value,
      hint: label,
      icon: Icons.calendar_today_outlined,
      onTap: onTap,
    );
  }
}

class _AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  final TextInputType? keyboardType;

  const _AppTextField({
    required this.label,
    required this.controller,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          decoration: _inputDecoration('Enter $label'),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ProductPickerRow extends StatelessWidget {
  final _ProductOption product;
  final VoidCallback onAdd;

  const _ProductPickerRow({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _ProductThumb(product.name),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.sku}  |  ${_money(product.unitPrice)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF284BFF),
              foregroundColor: Colors.white,
              minimumSize: const Size(34, 34),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuoteItemRow extends StatelessWidget {
  final _QuoteItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  const _QuoteItemRow({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _ProductThumb(item.product.name),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_money(item.product.unitPrice)} x ${_qty(item.quantity)} ${item.product.uom}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _QtyButton(icon: Icons.remove_rounded, onTap: onDecrease),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              _qty(item.quantity),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ),
          _QtyButton(icon: Icons.add_rounded, onTap: onIncrease),
          const SizedBox(width: 8),
          Text(
            _money(item.lineTotal),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.close_rounded,
              color: Color(0xFFEF4444),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 15, color: AppColors.textSecondary),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewItemRow extends StatelessWidget {
  final _QuoteItem item;

  const _ReviewItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ProductThumb(item.product.name, size: 42),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${_qty(item.quantity)} x ${_money(item.product.unitPrice)}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          _money(item.lineTotal),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _TotalsPanel extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final bool compact;

  const _TotalsPanel({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _TotalRow('Subtotal', subtotal),
          _TotalRow('Discount', -discount),
          _TotalRow('Tax', tax),
          Divider(height: compact ? 16 : 20, color: AppColors.border),
          _TotalRow('Grand Total', total, strong: true),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;
  final bool strong;

  const _TotalRow(this.label, this.value, {this.strong = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: strong ? AppColors.textPrimary : AppColors.textMuted,
                fontSize: strong ? 13 : 12,
                fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          Text(
            _money(value),
            style: TextStyle(
              color: strong ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: strong ? 14 : 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductThumb extends StatelessWidget {
  final String seed;
  final double size;

  const _ProductThumb(this.seed, {this.size = 48});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFE0F2FE),
      const Color(0xFFDCFCE7),
      const Color(0xFFFFEDD5),
      const Color(0xFFF3E8FF),
    ];
    final color = colors[seed.hashCode.abs() % colors.length];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary),
    );
  }
}

class _EmptyInline extends StatelessWidget {
  final String text;

  const _EmptyInline(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CenteredState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 14),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _LeadOption {
  final String id;
  final String name;
  final String phone;
  final String status;
  final String address;
  final String salespersonId;

  const _LeadOption({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.address,
    required this.salespersonId,
  });

  bool get isQuotable {
    final value = status.toLowerCase();
    return value.isEmpty ||
        value == 'new' ||
        value == 'contacted' ||
        value == 'qualified';
  }

  factory _LeadOption.fromJson(Map<String, dynamic> json) {
    final lead = _readMap(json, const ['lead']);
    final data = lead.isEmpty ? json : <String, dynamic>{...json, ...lead};
    return _LeadOption(
      id: _readText(data, const ['id', 'lead_id', 'leadId']),
      name: _readText(data, const [
        'name',
        'business_name',
        'customer_name',
        'lead_name',
        'company_name',
      ]),
      phone: _readText(data, const ['phone', 'mobile', 'contact_number']),
      status: _readText(data, const ['status', 'lead_status']),
      address: _readText(data, const ['address', 'billing_address', 'city']),
      salespersonId: _readText(data, const [
        'salesperson_id',
        'assigned_to_id',
        'assigned_sales_officer_id',
      ]),
    );
  }
}

class _ProductOption {
  final String id;
  final String variantId;
  final String name;
  final String sku;
  final String uom;
  final double unitPrice;
  final double taxRate;

  const _ProductOption({
    required this.id,
    required this.variantId,
    required this.name,
    required this.sku,
    required this.uom,
    required this.unitPrice,
    required this.taxRate,
  });

  factory _ProductOption.fromJson(Map<String, dynamic> json) {
    final product = _readMap(json, const ['product']);
    final data = product.isEmpty ? json : <String, dynamic>{...json, ...product};
    return _ProductOption(
      id: _readText(data, const ['id', 'product_id', 'productId']),
      variantId: _readText(data, const [
        'variant_id',
        'variantId',
        'default_variant_id',
      ]),
      name: _readText(data, const ['name', 'product_name', 'title']),
      sku: _readText(data, const ['sku', 'product_sku', 'hsn', 'barcode']),
      uom: _readText(data, const [
        'uom',
        'unit',
        'unit_of_measure',
        'measurement_unit',
      ], fallback: 'unit'),
      unitPrice: _readNumber(data, const [
        'price',
        'selling_price',
        'sellingPrice',
        'mrp',
        'unit_price',
      ]),
      taxRate: _readNumber(data, const [
        'tax',
        'tax_rate',
        'taxRate',
        'gst',
        'gst_rate',
      ]),
    );
  }
}

class _QuoteItem {
  final _ProductOption product;
  final double quantity;
  final double discountPercent;

  const _QuoteItem({
    required this.product,
    required this.quantity,
    this.discountPercent = 0,
  });

  double get subtotal => quantity * product.unitPrice;
  double get discountAmount => subtotal * discountPercent / 100;
  double get taxable => subtotal - discountAmount;
  double get taxAmount => taxable * product.taxRate / 100;
  double get lineTotal => taxable + taxAmount;

  Map<String, dynamic> toApi() {
    return {
      'product_id': product.id,
      'variant_id': product.variantId,
      'quantity': quantity,
      'unit_price': product.unitPrice,
      'discount': discountPercent,
      'tax_rate': product.taxRate,
      'uom': product.uom,
    };
  }

  _QuoteItem copyWith({double? quantity, double? discountPercent}) {
    return _QuoteItem(
      product: product,
      quantity: quantity ?? this.quantity,
      discountPercent: discountPercent ?? this.discountPercent,
    );
  }
}

InputDecoration _inputDecoration(String hint, {IconData? prefixIcon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textLightMuted, fontSize: 12),
    prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 18),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(color: Color(0xFF284BFF), width: 1.4),
    ),
  );
}

String _formatDate(DateTime value) {
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

String _apiDate(DateTime value) {
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

String _money(double value) {
  final sign = value < 0 ? '- ' : '';
  final absolute = value.abs();
  return '${sign}Rs ${absolute.toStringAsFixed(0)}';
}

String _qty(double value) {
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toStringAsFixed(2);
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
  }
  return const {};
}

String _readText(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      final nested = _readText(value, const ['name', 'display_name']);
      if (nested.isNotEmpty) return nested;
    }
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty && text.toLowerCase() != 'null') {
      return text;
    }
  }
  return fallback;
}

double _readNumber(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    final text = value?.toString().replaceAll(RegExp(r'[^0-9.\-]'), '');
    final parsed = double.tryParse(text ?? '');
    if (parsed != null) return parsed;
  }
  return 0;
}
