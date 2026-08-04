import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/app_user.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../widgets/admin/admin_top_bar.dart';

class AddCustomerScreen extends StatefulWidget {
  final String? customerId;
  final CustomerModel? existingCustomer;

  const AddCustomerScreen({super.key, this.customerId, this.existingCustomer});

  bool get isEditMode =>
      (customerId ?? existingCustomer?.id ?? '').trim().isNotEmpty;

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  static const List<String> _baseCustomerTypes = [
    'Retailer',
    'Wholesale',
    'Distributor',
    'Manufacturer',
    'Trader',
    'Other',
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ApiProvider _apiProvider;
  late Future<List<AppUser>> _usersFuture;

  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _gstController = TextEditingController();
  final _billingAddressController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();

  AppUser? _selectedSalesOfficer;
  String? _selectedType;
  bool _sameAsBilling = false;
  bool _isActive = true;
  bool _isSubmitting = false;
  bool _providerReady = false;
  bool _customerLoaded = false;
  bool _customerLoadFailed = false;
  CustomerModel? _loadedCustomer;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingCustomer;
    if (existing != null) {
      _applyCustomer(existing);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providerReady) return;
    _apiProvider = ApiProviderScope.of(context);
    _usersFuture = _apiProvider.fetchAssignableUsers();
    _providerReady = true;

    if (widget.isEditMode && !_customerLoaded) {
      _loadCustomerForEdit();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    _billingAddressController.dispose();
    _deliveryAddressController.dispose();
    _creditLimitController.dispose();
    _openingBalanceController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _nullableText(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  int? _nullableInt(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }

  Future<void> _loadCustomerForEdit() async {
    final customerId = (widget.customerId ?? widget.existingCustomer?.id ?? '')
        .trim();
    if (customerId.isEmpty) return;

    setState(() {
      _customerLoadFailed = false;
      _customerLoaded = true;
    });

    try {
      final customer = await _apiProvider.fetchCustomerById(customerId);
      if (!mounted) return;
      setState(() {
        _loadedCustomer = customer;
        _applyCustomer(customer);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _customerLoadFailed = true;
      });
      _showMessage(error.toString());
    }
  }

  void _applyCustomer(CustomerModel customer) {
    _nameController.text = customer.name;
    _businessNameController.text = customer.businessName ?? '';
    _phoneController.text = customer.phone ?? '';
    _emailController.text = customer.email ?? '';
    _gstController.text = customer.gstNumber ?? '';
    _billingAddressController.text =
        customer.billingAddress ?? customer.address ?? '';
    _deliveryAddressController.text =
        customer.deliveryAddress ?? customer.billingAddress ?? '';
    _creditLimitController.text = (customer.creditLimit ?? 0).toString();
    _openingBalanceController.text = (customer.openingBalance ?? 0).toString();
    _categoryController.text = customer.category ?? '';
    _notesController.text = customer.notes ?? '';
    _selectedType = customer.category;
    _isActive = customer.isActive ?? true;
    _sameAsBilling =
        _billingAddressController.text.trim().isNotEmpty &&
        _billingAddressController.text.trim() ==
            _deliveryAddressController.text.trim();
  }

  AppUser? _effectiveSalesOfficer(List<AppUser> users) {
    final selected = _selectedSalesOfficer;
    if (selected != null) return selected;

    final customer = _loadedCustomer ?? widget.existingCustomer;
    final officerId = customer?.assignedSalesOfficerId?.trim();
    if (officerId == null || officerId.isEmpty) return null;

    for (final user in users) {
      if (user.id.trim() == officerId) {
        return user;
      }
    }

    return null;
  }

  List<String> _typeOptions() {
    final options = <String>[..._baseCustomerTypes];
    final current = _selectedType?.trim();
    if (current != null &&
        current.isNotEmpty &&
        !options.any((type) => type.toLowerCase() == current.toLowerCase())) {
      options.add(current);
    }
    return options;
  }

  Future<void> _submit(List<AppUser> users) async {
    final name = _nullableText(_nameController.text);
    final businessName = _nullableText(_businessNameController.text);
    final phone = _nullableText(_phoneController.text);
    final email = _nullableText(_emailController.text);
    final gstNumber = _nullableText(_gstController.text);
    final billingAddress = _nullableText(_billingAddressController.text);
    final deliveryAddress = _sameAsBilling
        ? billingAddress
        : _nullableText(_deliveryAddressController.text);
    final category = _nullableText(_selectedType ?? _categoryController.text);
    final notes = _nullableText(_notesController.text);
    final creditLimit = _nullableInt(_creditLimitController.text);
    final openingBalance = _nullableInt(_openingBalanceController.text);

    setState(() => _isSubmitting = true);

    try {
      final selected = _effectiveSalesOfficer(users);

      if (widget.isEditMode) {
        final customerId =
            (widget.customerId ?? widget.existingCustomer?.id ?? '').trim();
        if (customerId.isEmpty) {
          throw StateError('Missing customer id.');
        }

        final request = CustomerUpdateRequest(
          name: name,
          businessName: businessName,
          phone: phone,
          email: email,
          gstNumber: gstNumber,
          billingAddress: billingAddress,
          deliveryAddress: deliveryAddress,
          assignedSalesOfficerId: selected?.id,
          creditLimit: creditLimit,
          category: category,
          notes: notes,
          isActive: _isActive,
        );
        debugPrint('[CUSTOMER UPDATE REQUEST] ${jsonEncode(request.toJson())}');
        final updated = await _apiProvider.updateCustomer(
          customerId: customerId,
          request: request,
        );
        debugPrint(
          '[CUSTOMER UPDATE RESPONSE] ${jsonEncode(updated.toJson())}',
        );

        if (!mounted) return;
        Navigator.of(context).pop(updated);
      } else {
        final request = CustomerCreateRequest(
          name: name,
          businessName: businessName,
          phone: phone,
          email: email,
          gstNumber: gstNumber,
          billingAddress: billingAddress,
          deliveryAddress: deliveryAddress,
          assignedSalesOfficerId: selected?.id,
          creditLimit: creditLimit,
          openingBalance: openingBalance,
          category: category,
          notes: notes,
        );
        debugPrint('[CUSTOMER CREATE REQUEST] ${jsonEncode(request.toJson())}');
        final created = await _apiProvider.createCustomer(request: request);
        debugPrint(
          '[CUSTOMER CREATE RESPONSE] ${jsonEncode(created.toJson())}',
        );

        if (!mounted) return;
        Navigator.of(context).pop(created);
      }
    } catch (error) {
      debugPrint(
        widget.isEditMode
            ? '[CUSTOMER UPDATE ERROR] $error'
            : '[CUSTOMER CREATE ERROR] $error',
      );
      _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: widget.isEditMode ? 'Edit Customer' : 'Add a new customer',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: FutureBuilder<List<AppUser>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  final users = snapshot.data ?? const <AppUser>[];
                  final selectedSalesOfficer = _effectiveSalesOfficer(users);

                  if (snapshot.connectionState == ConnectionState.waiting &&
                      users.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError && users.isEmpty) {
                    return Center(
                      child: Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    );
                  }

                  if (widget.isEditMode &&
                      !_customerLoaded &&
                      _loadedCustomer == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.borderStrong.withValues(alpha: 0.35),
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth >= 920;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.isEditMode
                                              ? 'Edit Customer'
                                              : 'Add a new customer',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Keep billing, delivery, credit, and sales ownership details in one place.',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).maybePop(),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: const BorderSide(
                                        color: AppColors.primary,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 13,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Back to Customers'),
                                  ),
                                ],
                              ),
                              if (widget.isEditMode && _customerLoadFailed) ...[
                                const SizedBox(height: 12),
                                const Text(
                                  'Could not refresh customer details. The form still has the last loaded values.',
                                  style: TextStyle(
                                    color: AppColors.statusInactiveText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              const Divider(height: 1),
                              const SizedBox(height: 18),
                              _sectionHeader('1', 'Basic information'),
                              const SizedBox(height: 16),
                              if (wide) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: _field(
                                        label: 'Customer Name',
                                        controller: _nameController,
                                        hintText: 'Enter customer name',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(child: _typeDropdown()),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _field(
                                        label: 'Phone',
                                        controller: _phoneController,
                                        hintText: 'Enter phone number',
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _field(
                                        label: 'Email',
                                        controller: _emailController,
                                        hintText: 'user@example.com',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: constraints.maxWidth * 0.48,
                                  child: _field(
                                    label: 'GST Number',
                                    controller: _gstController,
                                    hintText: 'Enter GST number',
                                  ),
                                ),
                              ] else ...[
                                _field(
                                  label: 'Customer Name',
                                  controller: _nameController,
                                  hintText: 'Enter customer name',
                                ),
                                const SizedBox(height: 16),
                                _typeDropdown(),
                                const SizedBox(height: 16),
                                _field(
                                  label: 'Phone',
                                  controller: _phoneController,
                                  hintText: 'Enter phone number',
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 16),
                                _field(
                                  label: 'Email',
                                  controller: _emailController,
                                  hintText: 'user@example.com',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),
                                _field(
                                  label: 'GST Number',
                                  controller: _gstController,
                                  hintText: 'Enter GST number',
                                ),
                              ],
                              const SizedBox(height: 18),
                              _sectionHeader('2', 'Billing and delivery'),
                              const SizedBox(height: 16),
                              _field(
                                label: 'Billing Address',
                                controller: _billingAddressController,
                                hintText: 'Enter billing address',
                                maxLines: 3,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSoft.withValues(
                                    alpha: 0.25,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderStrong.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _sameAsBilling,
                                      onChanged: (value) {
                                        setState(() {
                                          _sameAsBilling = value ?? false;
                                          if (_sameAsBilling) {
                                            _deliveryAddressController.text =
                                                _billingAddressController.text;
                                          }
                                        });
                                      },
                                      activeColor: AppColors.primary,
                                      checkColor: Colors.white,
                                      side: const BorderSide(
                                        color: AppColors.borderStrong,
                                        width: 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Expanded(
                                      child: Text(
                                        'Delivery address same as billing',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _field(
                                label: 'Delivery Address',
                                controller: _deliveryAddressController,
                                hintText: 'Enter delivery address',
                                maxLines: 3,
                                enabled: !_sameAsBilling,
                              ),
                              const SizedBox(height: 18),
                              _sectionHeader('3', 'Ownership and credit'),
                              const SizedBox(height: 16),
                              if (wide) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: _salesOfficerDropdown(
                                        users,
                                        selectedSalesOfficer,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _field(
                                        label: 'Credit Limit',
                                        controller: _creditLimitController,
                                        hintText: '0',
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                _salesOfficerDropdown(
                                  users,
                                  selectedSalesOfficer,
                                ),
                                const SizedBox(height: 16),
                                _field(
                                  label: 'Credit Limit',
                                  controller: _creditLimitController,
                                  hintText: '0',
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                              const SizedBox(height: 16),
                              _field(
                                label: 'Opening Balance',
                                controller: _openingBalanceController,
                                hintText: '0',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              _field(
                                label: 'Notes',
                                controller: _notesController,
                                hintText: 'Enter notes',
                                maxLines: 3,
                              ),
                              if (widget.isEditMode) ...[
                                const SizedBox(height: 16),
                                _sectionHeader('4', 'Status'),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSoft.withValues(
                                      alpha: 0.32,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.borderStrong.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Customer is active',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: _isActive,
                                        onChanged: (value) {
                                          setState(() => _isActive = value);
                                        },
                                        activeThumbColor: Colors.white,
                                        activeTrackColor: AppColors.primary,
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: AppColors
                                            .borderStrong
                                            .withValues(alpha: 0.45),
                                        trackOutlineColor:
                                            const WidgetStatePropertyAll(
                                              Colors.transparent,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              const Divider(height: 1),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () =>
                                              Navigator.of(context).maybePop(),
                                    style: TextButton.styleFrom(
                                      backgroundColor: AppColors.surfaceSoft,
                                      foregroundColor: AppColors.textPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 22,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Cancel'),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => _submit(users),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 22,
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            widget.isEditMode
                                                ? 'Save Changes'
                                                : 'Save Customer',
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String step, String title) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(hintText),
        ),
      ],
    );
  }

  Widget _salesOfficerDropdown(List<AppUser> users, AppUser? selected) {
    final items = List<AppUser>.from(users);
    if (selected != null &&
        !items.any((user) => user.id.trim() == selected.id.trim())) {
      items.insert(0, selected);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            'Assigned Sales Officer',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          key: ValueKey<String?>('sales-${selected?.id}'),
          initialValue: selected?.id,
          isExpanded: true,
          hint: const Text('Select sales officer'),
          decoration: _inputDecoration('Select sales officer'),
          items: items
              .map(
                (user) => DropdownMenuItem<String>(
                  value: user.id,
                  child: Text(user.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedSalesOfficer = items.firstWhere(
                (user) => user.id == value,
                orElse: () => items.first,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _typeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            'Type',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        DropdownButtonFormField<String>(
          key: ValueKey<String?>('type-${_selectedType ?? ''}'),
          initialValue: _selectedType,
          isExpanded: true,
          items: _typeOptions()
              .map(
                (type) =>
                    DropdownMenuItem<String>(value: type, child: Text(type)),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value;
              _categoryController.text = value ?? '';
            });
          },
          decoration: _inputDecoration('Select customer type'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
}
