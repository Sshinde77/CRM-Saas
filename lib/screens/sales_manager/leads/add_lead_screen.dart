import 'package:flutter/material.dart';

import '../../../models/app_user.dart';
import '../../../models/customer_model.dart';
import '../../../providers/api_provider.dart';
import '../../../services/api_service.dart';
import '../../../widgets/sales_manager/sales_manager_sidebar.dart';
import '../../../widgets/sales_manager/sales_manager_top_bar.dart';
import '../../admin/customers/customers_screen.dart';
import '../../admin/orders/admin_orders_screen.dart';
import '../../admin/orders/new_admin_order_screen.dart';
import '../dashboard/sales_manager_dashboard_screen.dart';
import '../visits/sales_manager_visits_screen.dart';

class AddLeadScreen extends StatefulWidget {
  final String? leadId;

  const AddLeadScreen({super.key, this.leadId});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  final _productSearchController = TextEditingController();

  final List<String> _leadSources = const [
    'Website',
    'Referral',
    'Walk-in',
    'Phone Call',
    'Campaign',
    'Social Media',
    'Data Calling',
  ];

  final List<String> _leadTypes = const [
    'Retailer',
    'Distributor',
    'Wholesaler',
    'Restaurant',
    'Private Company',
    'Business',
    'Individual',
    'Other',
  ];

  final List<String> _segments = const [
    'Small',
    'Medium',
    'Large',
    'Key / High Value',
    'Group Company',
  ];

  bool _didLoad = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;
  String? _formError;
  String? _leadSource;
  String? _leadType;
  String? _segment;
  String? _customerId;
  String? _salespersonId;
  String _currentUserName = 'User';
  String _currentUserRole = '';

  final Map<String, String> _fieldErrors = {};
  List<CustomerModel> _customers = [];
  List<_ProductOption> _products = [];
  List<_SalespersonOption> _salespeople = [];
  final List<String> _selectedProducts = [];

  bool get _isEditMode => (widget.leadId ?? '').trim().isNotEmpty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactPersonController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final provider = ApiProviderScope.of(context);
      final profile =
          provider.currentUser ?? await provider.fetchCurrentUserProfile();
      final role = profile?.role ?? '';
      final isAdmin = _isAdminRole(role);

      final customers = await provider.fetchCustomers();
      final productRows = await provider.fetchProducts(isActive: true);
      final leadDetail = _isEditMode
          ? await provider.fetchLeadById(widget.leadId!)
          : null;

      final salespeople = <_SalespersonOption>[];
      if (isAdmin) {
        final users = await provider.service.fetchUsers();
        salespeople.addAll(
          users
              .where(_isAssignableLeadUser)
              .map((user) => _SalespersonOption(id: user.id, name: user.name)),
        );
      } else if ((profile?.id ?? '').trim().isNotEmpty) {
        salespeople.add(
          _SalespersonOption(id: profile!.id!.trim(), name: profile.name),
        );
      }

      if (!mounted) return;
      setState(() {
        _customers = customers;
        _products = productRows.map(_ProductOption.fromJson).toList();
        _salespeople = salespeople;
        _salespersonId = salespeople.length == 1 ? salespeople.first.id : null;
        _currentUserName = profile?.name ?? 'User';
        _currentUserRole = role;
        if (leadDetail != null) _prefillLead(leadDetail);
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = _cleanError(error);
        _isLoading = false;
      });
    }
  }

  bool _isAdminRole(String role) => role.toLowerCase().contains('admin');

  bool _isAssignableLeadUser(AppUser user) {
    if (user.id.trim().isEmpty || user.isActive == false) return false;
    final role = (user.role ?? '').trim().toLowerCase();
    final systemRole = (user.systemRole ?? '').trim().toLowerCase();
    final roleName = user.roleDetail?.name.trim().toLowerCase() ?? '';
    return role == 'sales_officer' ||
        role == 'admin' ||
        systemRole == 'admin' ||
        roleName == 'sales officer' ||
        roleName == 'admin';
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final errors = <String, String>{};
    final mobile = _mobileController.text.trim();
    final isAdmin = _isAdminRole(_currentUserRole);

    if (_nameController.text.trim().isEmpty) {
      errors['name'] = 'Prospect / business name is required.';
    }
    if ((_leadSource ?? '').trim().isEmpty) {
      errors['lead_source'] = 'Lead source is required.';
    }
    if (mobile.isEmpty) {
      errors['mobile_number'] = 'Mobile number is required.';
    } else if (!RegExp(r'^[0-9+\-\s()]{7,16}$').hasMatch(mobile)) {
      errors['mobile_number'] = 'Enter a valid mobile number.';
    }
    if (!isAdmin && (_salespersonId ?? '').trim().isEmpty) {
      errors['assigned_salesperson_id'] = 'Assigned salesperson is required.';
    }

    setState(() {
      _fieldErrors
        ..clear()
        ..addAll(errors);
      _formError = null;
    });
    if (errors.isNotEmpty) return;

    final request = <String, dynamic>{
      'name': _nameController.text.trim(),
      'lead_source': _leadSource,
      'mobile_number': mobile,
      'lead_status': _isEditMode ? null : 'new',
    };
    _putTrimmed(request, 'contact_person', _contactPersonController.text);
    _putTrimmed(request, 'email', _emailController.text);
    _putTrimmed(request, 'lead_type', _leadType);
    _putTrimmed(request, 'segment', _segment);
    _putTrimmed(request, 'notes', _notesController.text);
    _putTrimmed(request, 'customer_id', _customerId);
    _putTrimmed(request, 'assigned_salesperson_id', _salespersonId);
    _putTrimmed(request, 'interested_product', _selectedProducts.join(', '));

    setState(() => _isSaving = true);
    try {
      final provider = ApiProviderScope.of(context);
      if (_isEditMode) {
        request.removeWhere((key, value) => value == null);
        await provider.updateLead(leadId: widget.leadId!, request: request);
      } else {
        await provider.createLead(request: request);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _formError = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _putTrimmed(Map<String, dynamic> payload, String key, String? value) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) payload[key] = trimmed;
  }

  void _prefillLead(Map<String, dynamic> lead) {
    _nameController.text = _leadValue(lead, const [
      'name',
      'business_name',
      'company_name',
      'customer_name',
      'lead_name',
    ]);
    _contactPersonController.text = _leadValue(lead, const [
      'contact_person',
      'contactPerson',
      'contact_name',
      'contactName',
    ]);
    _mobileController.text = _leadValue(lead, const [
      'mobile_number',
      'mobileNumber',
      'phone',
      'phone_number',
    ]);
    _emailController.text = _leadValue(lead, const ['email', 'email_address']);
    _notesController.text = _leadValue(lead, const [
      'notes',
      'description',
      'remark',
      'remarks',
    ]);

    _leadSource = _matchingOption(
      _leadSources,
      _leadValue(lead, const ['lead_source', 'leadSource', 'source']),
    );
    _leadType = _matchingOption(
      _leadTypes,
      _leadValue(lead, const ['lead_type', 'leadType', 'type']),
    );
    _segment = _matchingOption(
      _segments,
      _leadValue(lead, const ['segment', 'lead_segment', 'leadSegment']),
    );

    _customerId = _leadIdValue(
      lead,
      const ['customer_id', 'customerId', 'existing_customer_id'],
      nestedKeys: const ['customer', 'existing_customer'],
    );
    if (_customerId != null && !_customers.any((c) => c.id == _customerId)) {
      _customerId = null;
    }

    final salespersonId = _leadIdValue(
      lead,
      const ['assigned_salesperson_id', 'assignedSalespersonId', 'owner_id'],
      nestedKeys: const ['assigned_salesperson', 'assigned_user', 'owner'],
    );
    if (salespersonId != null &&
        _salespeople.any((person) => person.id == salespersonId)) {
      _salespersonId = salespersonId;
    }

    _selectedProducts
      ..clear()
      ..addAll(
        _leadValue(lead, const ['interested_product', 'interestedProduct'])
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty && value != '-'),
      );
  }

  String _leadValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null' && text != '-') {
        return text;
      }
    }
    return '';
  }

  String? _leadIdValue(
    Map<String, dynamic> json,
    List<String> keys, {
    List<String> nestedKeys = const [],
  }) {
    final direct = _leadValue(json, keys);
    if (direct.isNotEmpty) return direct;
    for (final key in nestedKeys) {
      final nested = json[key];
      if (nested is Map<String, dynamic>) {
        final nestedId = _leadValue(nested, const ['id', 'user_id', 'userId']);
        if (nestedId.isNotEmpty) return nestedId;
      }
    }
    return null;
  }

  String? _matchingOption(List<String> options, String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final option in options) {
      if (option.toLowerCase() == normalized) return option;
    }
    return null;
  }

  String _cleanError(Object error) {
    if (error is ApiException) return error.message;
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _handleSidebarSelection(String action) {
    Navigator.of(context).maybePop();
    if (action == 'Leads') return;
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
    if (action == 'Visits') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SalesManagerVisitsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF7FAF8),
      drawer: SalesManagerSidebarDrawer(
        onSelect: _handleSidebarSelection,
        currentPage: 'Leads',
      ),
      body: SafeArea(
        child: Column(
          children: [
            SalesManagerTopBar(title: _isEditMode ? 'Edit Lead' : 'Add Lead'),
            Expanded(
              child: _isLoading
                  ? const _CenteredState(
                      icon: Icons.hourglass_empty_rounded,
                      title: 'Loading lead form',
                      message: 'Fetching customers and products...',
                    )
                  : _loadError != null
                  ? _CenteredState(
                      icon: Icons.error_outline_rounded,
                      title: 'Unable to load form',
                      message: _loadError!,
                      actionLabel: 'Retry',
                      onAction: _loadInitialData,
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
        final wide = constraints.maxWidth >= 980;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(wide ? 24 : 16, 16, wide ? 24 : 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                title: _isEditMode ? 'Edit Lead' : 'Add Lead',
                subtitle: _isEditMode
                    ? 'Update the lead details from the latest backend record.'
                    : 'Capture a new prospect and assign it to a salesperson.',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 16),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: _buildFormCard(wide: true)),
                    const SizedBox(width: 18),
                    SizedBox(width: 320, child: _buildSideCards()),
                  ],
                )
              else ...[
                _buildFormCard(wide: false),
                const SizedBox(height: 16),
                _buildSideCards(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormCard({required bool wide}) {
    return Container(
      padding: EdgeInsets.all(wide ? 22 : 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditMode ? 'Edit Lead Information' : 'Lead Information',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isEditMode
                ? 'Review and update the fields below.'
                : 'Fill in the details below to create a new lead.',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          if (_formError != null) ...[
            const SizedBox(height: 14),
            _Alert(message: _formError!),
          ],
          const SizedBox(height: 18),
          _FormGrid(
            wide: wide,
            children: [
              _LeadTextField(
                label: 'Prospect / Business Name *',
                hintText: 'e.g. Sunrise Distributors',
                controller: _nameController,
                errorText: _fieldErrors['name'],
                onChanged: (_) => setState(() {}),
              ),
              _LeadTextField(
                label: 'Contact Person',
                hintText: 'Who to speak with',
                controller: _contactPersonController,
                onChanged: (_) => setState(() {}),
              ),
              _SelectField<String>(
                label: 'Lead Source *',
                hintText: 'Select lead source',
                value: _leadSource,
                errorText: _fieldErrors['lead_source'],
                items: _leadSources,
                itemLabel: (value) => value,
                onChanged: (value) => setState(() => _leadSource = value),
              ),
              _SelectField<CustomerModel>(
                label: 'Existing Customer',
                hintText: _customers.isEmpty
                    ? 'No customers available'
                    : 'No existing customer (new prospect)',
                value: _selectedCustomer,
                items: _customers,
                itemLabel: _customerLabel,
                onChanged: (customer) {
                  setState(() => _customerId = customer?.id);
                },
              ),
              _LeadTextField(
                label: 'Mobile Number *',
                hintText: 'Contact mobile number',
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                errorText: _fieldErrors['mobile_number'],
              ),
              _LeadTextField(
                label: 'Email',
                hintText: 'Contact email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              _SelectField<_SalespersonOption>(
                label: 'Assigned Salesperson',
                hintText: _salespeople.isEmpty ? 'Unassigned' : 'Unassigned',
                value: _selectedSalesperson,
                items: _salespeople,
                itemLabel: (salesperson) => salesperson.name,
                enabled: _isAdminRole(_currentUserRole),
                errorText: _fieldErrors['assigned_salesperson_id'],
                onChanged: (salesperson) {
                  setState(() => _salespersonId = salesperson?.id);
                },
              ),
              _SelectField<String>(
                label: 'Lead Type',
                hintText: 'Select a type',
                value: _leadType,
                items: _leadTypes,
                itemLabel: (value) => value,
                onChanged: (value) => setState(() => _leadType = value),
              ),
              _SelectField<String>(
                label: 'Segment',
                hintText: 'Select segment',
                value: _segment,
                items: _segments,
                itemLabel: (value) => value,
                onChanged: (value) => setState(() => _segment = value),
              ),
              _ProductPicker(
                products: _products,
                selected: _selectedProducts,
                controller: _productSearchController,
                onChanged: () => setState(() {}),
              ),
              _LeadTextField(
                label: 'Notes',
                hintText: 'Any additional context for the sales team',
                controller: _notesController,
                maxLines: 4,
                fullWidth: true,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFD7DEE8)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  _isSaving
                      ? (_isEditMode ? 'Saving...' : 'Adding...')
                      : (_isEditMode ? 'Save Lead' : 'Add Lead'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF08783D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  CustomerModel? get _selectedCustomer {
    final id = _customerId;
    if (id == null) return null;
    for (final customer in _customers) {
      if (customer.id == id) return customer;
    }
    return null;
  }

  _SalespersonOption? get _selectedSalesperson {
    final id = _salespersonId;
    if (id == null) return null;
    for (final salesperson in _salespeople) {
      if (salesperson.id == id) return salesperson;
    }
    return null;
  }

  String _customerLabel(CustomerModel customer) {
    final phone = customer.phone?.trim();
    if (phone == null || phone.isEmpty) return customer.name;
    return '${customer.name} - $phone';
  }

  Widget _buildSideCards() {
    return Column(
      children: [
        _InfoCard(
          icon: Icons.lightbulb_outline_rounded,
          iconColor: const Color(0xFFF59E0B),
          title: 'Lead Tips',
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TipLine('Choose the right lead source'),
              _TipLine('Assign to the right salesperson'),
              _TipLine('Keep contact details up to date'),
              _TipLine('Update lead status regularly'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.assignment_ind_outlined,
          iconColor: const Color(0xFF08783D),
          title: 'Assignment Preview',
          child: Column(
            children: [
              _PreviewRow(
                label: 'Salesperson',
                value: _selectedSalesperson?.name ?? 'Unassigned',
              ),
              const _PreviewRow(label: 'Lead Status', value: 'New'),
              _PreviewRow(
                label: 'Customer',
                value: _selectedCustomer?.name ?? 'New prospect',
              ),
              _PreviewRow(label: 'Created By', value: _currentUserName),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _InfoCard(
          icon: Icons.notes_rounded,
          iconColor: const Color(0xFF2563EB),
          title: 'Notes Preview',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _notesController.text.trim().isEmpty
                  ? 'No notes added yet.'
                  : _notesController.text.trim(),
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Home > Leads',
                style: TextStyle(
                  color: Color(0xFF08783D),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 17),
          label: const Text('Back to Leads'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0F172A),
            side: const BorderSide(color: Color(0xFFD7DEE8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _FormGrid extends StatelessWidget {
  final bool wide;
  final List<Widget> children;

  const _FormGrid({required this.wide, required this.children});

  @override
  Widget build(BuildContext context) {
    if (!wide) return Column(children: _withSpacing(children));

    final rows = <Widget>[];
    var i = 0;
    while (i < children.length) {
      final first = children[i];
      final firstFull =
          first is _ProductPicker || first is _LeadTextField && first.fullWidth;
      if (firstFull) {
        rows.add(first);
        i += 1;
      } else {
        final second = i + 1 < children.length ? children[i + 1] : null;
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 14),
              Expanded(child: second ?? const SizedBox.shrink()),
            ],
          ),
        );
        i += 2;
      }
      if (i < children.length) rows.add(const SizedBox(height: 14));
    }
    return Column(children: rows);
  }

  List<Widget> _withSpacing(List<Widget> widgets) {
    return [
      for (var i = 0; i < widgets.length; i++) ...[
        widgets[i],
        if (i != widgets.length - 1) const SizedBox(height: 14),
      ],
    ];
  }
}

class _LeadTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool fullWidth;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const _LeadTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.fullWidth = false,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      errorText: errorText,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: _inputDecoration(hintText, errorText: errorText),
      ),
    );
  }
}

class _SelectField<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final String? errorText;
  final bool enabled;

  const _SelectField({
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return _LabeledField(
      label: label,
      errorText: errorText,
      child: DropdownButtonFormField<T>(
        key: ValueKey<T?>(value),
        initialValue: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF64748B),
        ),
        decoration: _inputDecoration(hintText, errorText: errorText),
        items: [
          DropdownMenuItem<T>(
            value: null,
            child: Text(hintText, overflow: TextOverflow.ellipsis),
          ),
          ...items.map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}

class _ProductPicker extends StatefulWidget {
  final List<_ProductOption> products;
  final List<String> selected;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _ProductPicker({
    required this.products,
    required this.selected,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_ProductPicker> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<_ProductPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final normalized = _query.trim().toLowerCase();
    final suggestions = normalized.isEmpty
        ? <_ProductOption>[]
        : widget.products
              .where((product) {
                if (widget.selected.contains(product.name)) return false;
                return product.name.toLowerCase().contains(normalized) ||
                    product.sku.toLowerCase().contains(normalized);
              })
              .take(8)
              .toList();
    final exactMatch = widget.products.any(
      (product) => product.name.toLowerCase() == normalized,
    );
    final canAddCustom =
        normalized.isNotEmpty &&
        !widget.selected.contains(_query.trim()) &&
        !exactMatch;

    return _LabeledField(
      label: 'Interested Products',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.controller,
            decoration: _inputDecoration(
              'Search products by name or SKU',
              suffixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF94A3B8),
              ),
            ),
            textInputAction: TextInputAction.done,
            onChanged: (value) => setState(() => _query = value),
            onSubmitted: (_) => _addCustom(),
          ),
          if (suggestions.isNotEmpty || canAddCustom) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  for (final product in suggestions)
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: const Icon(
                        Icons.inventory_2_outlined,
                        color: Color(0xFF08783D),
                      ),
                      title: Text(product.name),
                      subtitle: product.sku.isEmpty ? null : Text(product.sku),
                      onTap: () => _addProduct(product.name),
                    ),
                  if (canAddCustom)
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: const Icon(
                        Icons.add_circle_outline_rounded,
                        color: Color(0xFF08783D),
                      ),
                      title: Text('Add "${_query.trim()}"'),
                      onTap: _addCustom,
                    ),
                ],
              ),
            ),
          ],
          if (widget.selected.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final product in widget.selected)
                  InputChip(
                    label: Text(product),
                    labelStyle: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: const Color(0xFFEFF8F2),
                    side: const BorderSide(color: Color(0xFFCDECD7)),
                    onDeleted: () {
                      setState(() => widget.selected.remove(product));
                      widget.onChanged();
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _addCustom() {
    final value = _query.trim();
    if (value.isEmpty || widget.selected.contains(value)) return;
    _addProduct(value);
  }

  void _addProduct(String name) {
    setState(() {
      widget.selected.add(name);
      _query = '';
      widget.controller.clear();
    });
    widget.onChanged();
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _TipLine extends StatelessWidget {
  final String text;

  const _TipLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_rounded, color: Color(0xFF08783D), size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Alert extends StatelessWidget {
  final String message;

  const _Alert({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? errorText;

  const _LabeledField({
    required this.label,
    required this.child,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        child,
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFDC2626),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
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
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(22),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF08783D), size: 34),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
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

class _ProductOption {
  final String id;
  final String name;
  final String sku;

  const _ProductOption({
    required this.id,
    required this.name,
    required this.sku,
  });

  factory _ProductOption.fromJson(Map<String, dynamic> json) {
    return _ProductOption(
      id: (json['id'] ?? json['product_id'] ?? '').toString(),
      name:
          (json['name'] ??
                  json['product_name'] ??
                  json['item_name'] ??
                  'Product')
              .toString(),
      sku: (json['sku'] ?? json['sku_code'] ?? '').toString(),
    );
  }
}

class _SalespersonOption {
  final String id;
  final String name;

  const _SalespersonOption({required this.id, required this.name});
}

InputDecoration _inputDecoration(
  String hintText, {
  Widget? suffixIcon,
  String? errorText,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
    errorText: null,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD7DEE8)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: errorText == null
            ? const Color(0xFFD7DEE8)
            : const Color(0xFFDC2626),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF08783D), width: 1.4),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    suffixIcon: suffixIcon,
  );
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFFE2E8F0)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
