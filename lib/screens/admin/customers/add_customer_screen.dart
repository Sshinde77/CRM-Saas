import 'dart:convert';
import 'dart:typed_data';

import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    'Individual',
    'Business',
    'Government',
    'Dealer',
    'Distributor',
    'Vendor',
  ];
  static const List<String> _industryOptions = [
    'Food & Beverage',
    'Retail',
    'Wholesale',
    'Corporate',
    'Healthcare',
    'Education',
    'Hospitality',
    'Manufacturing',
    'Services',
  ];
  static const List<String> _customerCategoryOptions = [
    'Retail',
    'Wholesale',
    'Corporate',
    'VIP',
    'Dealer',
    'Distributor',
  ];
  static const List<String> _customerStatusOptions = [
    'Active',
    'Inactive',
    'Suspended',
    'Locked',
  ];
  // ignore: unused_field
  static const List<String> _stateOptions = [
    'Maharashtra',
    'Gujarat',
    'Delhi',
    'Karnataka',
    'Tamil Nadu',
    'Other',
  ];
  static const List<String> _currencyOptions = [
    'INR',
    'USD',
    'AED',
    'SGD',
    'GBP',
  ];
  static const List<String> _taxCategoryOptions = [
    'Registered',
    'Unregistered',
    'Exempt',
  ];
  static const List<String> _paymentTermsOptions = [
    'Net 15',
    'Net 30',
    'Advance',
    'Immediate',
    'Due on Receipt',
  ];
  static const List<String> _leadSourceOptions = [
    'Referral',
    'Website',
    'Social Media',
    'Walk-in',
    'Advertisement',
    'Other',
  ];
  static const List<String> _territoryOptions = [
    'North',
    'South',
    'East',
    'West',
    'Central',
  ];
  static const List<String> _priorityOptions = ['High', 'Medium', 'Low'];
  static const List<String> _paymentOptions = [
    'Cash',
    'Card',
    'UPI',
    'Bank Transfer',
    'Cheque',
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late ApiProvider _apiProvider;
  late Future<List<AppUser>> _usersFuture;
  final ImagePicker _imagePicker = ImagePicker();

  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _customerSinceController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _designationController = TextEditingController();
  final _alternatePhoneController = TextEditingController();
  final _supportEmailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _gstController = TextEditingController();
  final _panController = TextEditingController();
  final _googleMapsController = TextEditingController();
  final _billingAddressController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _outstandingBalanceController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _preferredCommunicationController = TextEditingController();
  final _customerTagsController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _xController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _customerRemarksController = TextEditingController();
  final _anniversaryController = TextEditingController();
  final _referralCustomerController = TextEditingController();
  final _loyaltyNumberController = TextEditingController();

  AppUser? _selectedSalesOfficer;
  String? _selectedType;
  String? _selectedIndustry;
  String? _selectedCustomerCategory;
  String _selectedCustomerStatus = 'Active';
  String? _selectedPaymentMethod;
  String? _selectedTaxCategory;
  String _selectedCurrency = 'INR';
  String? _selectedLeadSource;
  String? _selectedTerritory;
  String? _selectedCustomerPriority;
  // ignore: unused_field
  String? _selectedCountry;
  // ignore: unused_field
  String? _selectedState;
  String? _selectedPaymentTerm;
  bool _taxExempt = false;
  bool _sameAsBilling = false;
  bool _isActive = true;
  bool _isSubmitting = false;
  bool _providerReady = false;
  bool _customerLoaded = false;
  bool _customerLoadFailed = false;
  int _currentStep = 0;
  CustomerModel? _loadedCustomer;
  Uint8List? _gstCertificateBytes;
  String? _gstCertificateName;
  Uint8List? _panCardBytes;
  String? _panCardName;
  Uint8List? _businessRegistrationBytes;
  String? _businessRegistrationName;
  Uint8List? _addressProofBytes;
  String? _addressProofName;
  Uint8List? _purchaseAgreementBytes;
  String? _purchaseAgreementName;
  Uint8List? _otherDocBytes;
  String? _otherDocName;

  static const List<_CustomerWizardStep> _steps = [
    _CustomerWizardStep('Basic Information', Icons.info_outline_rounded),
    _CustomerWizardStep('Contact Information', Icons.call_outlined),
    _CustomerWizardStep('Address Information', Icons.location_on_outlined),
    _CustomerWizardStep(
      'Business & Tax Information',
      Icons.receipt_long_outlined,
    ),
    _CustomerWizardStep('Payment Information', Icons.payments_outlined),
    _CustomerWizardStep(
      'Sales & CRM Information',
      Icons.manage_accounts_outlined,
    ),
    _CustomerWizardStep(
      'Social Media & Online Presence',
      Icons.public_outlined,
    ),
    _CustomerWizardStep('Documents (Uploads)', Icons.upload_file_outlined),
    _CustomerWizardStep('Additional Information', Icons.notes_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _customerIdController.text = 'CUS-2026-AUTO';
    _customerSinceController.text = _formatToday();
    _selectedCurrency = 'INR';
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
    _usersFuture = _loadAssignableUsersForForm();
    _providerReady = true;

    if (widget.isEditMode && !_customerLoaded) {
      _loadCustomerForEdit();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _displayNameController.dispose();
    _customerIdController.dispose();
    _customerSinceController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _contactPersonController.dispose();
    _designationController.dispose();
    _alternatePhoneController.dispose();
    _supportEmailController.dispose();
    _websiteController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _gstController.dispose();
    _panController.dispose();
    _googleMapsController.dispose();
    _billingAddressController.dispose();
    _deliveryAddressController.dispose();
    _creditLimitController.dispose();
    _openingBalanceController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    _paymentMethodController.dispose();
    _outstandingBalanceController.dispose();
    _upiIdController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _preferredCommunicationController.dispose();
    _customerTagsController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _xController.dispose();
    _youtubeController.dispose();
    _whatsappController.dispose();
    _customerRemarksController.dispose();
    _anniversaryController.dispose();
    _referralCustomerController.dispose();
    _loyaltyNumberController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickCustomerSinceDate() async {
    final now = DateTime.now();
    final initialDate = _parseDisplayDate(_customerSinceController.text) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _customerSinceController.text = _formatDisplayDate(picked);
    });
  }

  String? _nullableText(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }

  T? _optionValueOrNull<T>(T? value, List<T> options) {
    if (value == null) return null;
    return options.where((option) => option == value).length == 1
        ? value
        : null;
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
    _customerIdController.text = customer.customerId ?? customer.id;
    _nameController.text = customer.name;
    _businessNameController.text = customer.businessName ?? '';
    _displayNameController.text = customer.name;
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
    _selectedType = _optionValueOrNull(customer.category, _baseCustomerTypes);
    _selectedCustomerCategory = _optionValueOrNull(
      customer.category,
      _customerCategoryOptions,
    );
    _isActive = customer.isActive ?? true;
    _selectedCustomerStatus = _isActive ? 'Active' : 'Inactive';
    _sameAsBilling =
        _billingAddressController.text.trim().isNotEmpty &&
        _billingAddressController.text.trim() ==
            _deliveryAddressController.text.trim();
    _customerSinceController.text =
        _formatDate(customer.createdAt) ?? _formatToday();
  }

  Future<void> _pickCustomerDocument(_CustomerDocSlot slot) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        switch (slot) {
          case _CustomerDocSlot.gst:
            _gstCertificateBytes = bytes;
            _gstCertificateName = picked.name;
            break;
          case _CustomerDocSlot.pan:
            _panCardBytes = bytes;
            _panCardName = picked.name;
            break;
          case _CustomerDocSlot.businessRegistration:
            _businessRegistrationBytes = bytes;
            _businessRegistrationName = picked.name;
            break;
          case _CustomerDocSlot.addressProof:
            _addressProofBytes = bytes;
            _addressProofName = picked.name;
            break;
          case _CustomerDocSlot.purchaseAgreement:
            _purchaseAgreementBytes = bytes;
            _purchaseAgreementName = picked.name;
            break;
          case _CustomerDocSlot.other:
            _otherDocBytes = bytes;
            _otherDocName = picked.name;
            break;
        }
      });
    } catch (error) {
      if (mounted) _showMessage('Unable to upload document: $error');
    }
  }

  void _removeCustomerDocument(_CustomerDocSlot slot) {
    setState(() {
      switch (slot) {
        case _CustomerDocSlot.gst:
          _gstCertificateBytes = null;
          _gstCertificateName = null;
          break;
        case _CustomerDocSlot.pan:
          _panCardBytes = null;
          _panCardName = null;
          break;
        case _CustomerDocSlot.businessRegistration:
          _businessRegistrationBytes = null;
          _businessRegistrationName = null;
          break;
        case _CustomerDocSlot.addressProof:
          _addressProofBytes = null;
          _addressProofName = null;
          break;
        case _CustomerDocSlot.purchaseAgreement:
          _purchaseAgreementBytes = null;
          _purchaseAgreementName = null;
          break;
        case _CustomerDocSlot.other:
          _otherDocBytes = null;
          _otherDocName = null;
          break;
      }
    });
  }

  List<AppUser> _currentUserAsAssignableUser() {
    final user = _apiProvider.currentUser;
    final id = user?.id?.trim();
    if (id == null || id.isEmpty) {
      return const <AppUser>[];
    }

    return [
      AppUser(
        id: id,
        name: user!.name,
        email: user.email ?? '',
        role: user.role,
      ),
    ];
  }

  Future<List<AppUser>> _loadAssignableUsersForForm() async {
    if (_apiProvider.authMe?.canView('users') == false) {
      return _currentUserAsAssignableUser();
    }

    try {
      return await _apiProvider.service.fetchAssignableUsers();
    } catch (error) {
      if (error.toString().contains('403')) {
        return _currentUserAsAssignableUser();
      }
      rethrow;
    }
  }

  AppUser? _effectiveSalesOfficer(List<AppUser> users) {
    final selected = _selectedSalesOfficer;
    if (selected != null) return selected;

    final customer = _loadedCustomer ?? widget.existingCustomer;
    final officerId = customer?.assignedSalesOfficerId?.trim();
    if (officerId == null || officerId.isEmpty) {
      return !widget.isEditMode && users.length == 1 ? users.first : null;
    }

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

  List<_PendingCustomerDocument> _pendingCustomerDocuments() {
    return [
      _PendingCustomerDocument(
        documentType: 'gst_certificate',
        bytes: _gstCertificateBytes,
        fileName: _gstCertificateName,
      ),
      _PendingCustomerDocument(
        documentType: 'pan_card',
        bytes: _panCardBytes,
        fileName: _panCardName,
      ),
      _PendingCustomerDocument(
        documentType: 'business_registration_certificate',
        bytes: _businessRegistrationBytes,
        fileName: _businessRegistrationName,
      ),
      _PendingCustomerDocument(
        documentType: 'address_proof',
        bytes: _addressProofBytes,
        fileName: _addressProofName,
      ),
      _PendingCustomerDocument(
        documentType: 'purchase_agreement',
        bytes: _purchaseAgreementBytes,
        fileName: _purchaseAgreementName,
      ),
      _PendingCustomerDocument(
        documentType: 'other',
        bytes: _otherDocBytes,
        fileName: _otherDocName,
      ),
    ].where((document) => document.canUpload).toList();
  }

  Future<void> _uploadPendingCustomerDocuments(String customerId) async {
    final documents = _pendingCustomerDocuments();
    if (documents.isEmpty) return;

    for (final document in documents) {
      await _apiProvider.uploadCustomerDocument(
        customerId: customerId,
        documentType: document.documentType,
        fileBytes: document.bytes!,
        fileName: document.fileName!,
      );
    }
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
    final notes = _nullableText(
      [
        _notesController.text.trim(),
        _customerRemarksController.text.trim(),
      ].where((value) => value.isNotEmpty).join(' • '),
    );
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
        await _uploadPendingCustomerDocuments(
          updated.id.trim().isEmpty ? customerId : updated.id,
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
        await _uploadPendingCustomerDocuments(created.id);

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
              title: widget.isEditMode ? 'Edit Customer' : 'Add Customer',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: FutureBuilder<List<AppUser>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  final users = snapshot.data ?? const <AppUser>[];

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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 1080;
                        final stepperPanel = _buildCustomerStepperPanel(
                          wide: wide,
                        );
                        final contentPanel = _buildCustomerContentPanel(
                          users: users,
                          wide: wide,
                        );

                        if (wide) {
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: AppColors.borderStrong.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 320, child: stepperPanel),
                                const SizedBox(width: 18),
                                Expanded(child: contentPanel),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            stepperPanel,
                            const SizedBox(height: 16),
                            contentPanel,
                          ],
                        );
                      },
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

  // ignore: unused_element
  Widget _buildIntroPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.98),
            const Color(0xFF0F5A00),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Text(
              widget.isEditMode ? 'Update customer' : 'Customer setup',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            widget.isEditMode ? 'Edit Customer' : 'Add Customer',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Capture customer identity, billing details, delivery address, ownership, and credit in one clean flow.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 20),
          _introBullet('Basic identity and contact details'),
          _introBullet('Billing and delivery addresses'),
          _introBullet('Sales ownership and credit limits'),
          if (widget.isEditMode) _introBullet('Active status control'),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick snapshot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _miniStat(label: 'Sections', value: '4'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _miniStat(
                        label: 'Mode',
                        value: widget.isEditMode ? 'Edit' : 'New',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _miniStat(
                  label: 'Status',
                  value: widget.isEditMode
                      ? (_isActive ? 'Active' : 'Inactive')
                      : 'Ready to create',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _introBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white70),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep(List<AppUser> users) {
    if (_currentStep >= _steps.length - 1) {
      _submit(users);
      return;
    }
    setState(() => _currentStep += 1);
  }

  void _previousStep() {
    if (_currentStep <= 0) return;
    setState(() => _currentStep -= 1);
  }

  Widget _buildCustomerStepperPanel({required bool wide}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer Setup',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Complete the customer profile in 9 steps.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.borderStrong),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_steps.length, (index) {
                final step = _steps[index];
                final isActive = index == _currentStep;
                final isCompleted = index < _currentStep;
                final isLast = index == _steps.length - 1;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => setState(() => _currentStep = index),
                      borderRadius: BorderRadius.circular(999),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isActive || isCompleted
                                  ? AppColors.primary
                                  : const Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.18,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  )
                                : Icon(
                                    step.icon,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    size: 22,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _customerStepShortLabel(step.title),
                            style: TextStyle(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          width: 56,
                          height: 2,
                          color: index < _currentStep
                              ? AppColors.primary
                              : const Color(0xFFD8DFE6),
                        ),
                      ),
                    if (!isLast) const SizedBox(width: 2),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerContentPanel({
    required List<AppUser> users,
    required bool wide,
  }) {
    final selectedSalesOfficer = _effectiveSalesOfficer(users);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isEditMode) ...[
            if (_customerLoadFailed) ...[
              const Text(
                'Could not refresh customer details. The form still has the last loaded values.',
                style: TextStyle(
                  color: AppColors.statusInactiveText,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
          _customerStepHeader(_steps[_currentStep]),
          const SizedBox(height: 18),
          _buildCustomerStepBody(
            users: users,
            selectedSalesOfficer: selectedSalesOfficer,
            wide: wide,
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppColors.borderStrong),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSubmitting
                    ? null
                    : (_currentStep == 0
                          ? () => Navigator.of(context).maybePop()
                          : _previousStep),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.surfaceSoft,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  _currentStep == 0 ? 'Cancel' : 'Back',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSubmitting ? null : () => _nextStep(users),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
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
                        _currentStep == _steps.length - 1
                            ? (widget.isEditMode
                                  ? 'Save Changes'
                                  : 'Add New Customer')
                            : 'Next',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _customerStepHeader(_CustomerWizardStep step) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${_currentStep + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          step.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  String _customerStepShortLabel(String title) {
    switch (title) {
      case 'Basic Information':
        return 'Basic Info';
      case 'Contact Information':
        return 'Contact Info';
      case 'Address Information':
        return 'Address';
      case 'Business & Tax Information':
        return 'Business';
      case 'Payment Information':
        return 'Payment';
      case 'Sales & CRM Information':
        return 'Sales CRM';
      case 'Social Media & Online Presence':
        return 'Social';
      case 'Documents (Uploads)':
        return 'Uploads';
      case 'Additional Information':
        return 'Additional';
      default:
        return title;
    }
  }

  Widget _buildCustomerStepBody({
    required List<AppUser> users,
    required AppUser? selectedSalesOfficer,
    required bool wide,
  }) {
    switch (_currentStep) {
      case 0:
        return _customerBasicInformationStep(wide: wide);
      case 1:
        return _customerContactInformationStep(wide: wide);
      case 2:
        return _customerAddressInformationStep(wide: wide);
      case 3:
        return _customerBusinessTaxStep(wide: wide);
      case 4:
        return _customerPaymentStep(wide: wide);
      case 5:
        return _customerSalesCrmStep(
          users: users,
          selectedSalesOfficer: selectedSalesOfficer,
          wide: wide,
        );
      case 6:
        return _customerSocialStep(wide: wide);
      case 7:
        return _customerDocumentsStep(wide: wide);
      case 8:
      default:
        return _customerAdditionalStep(wide: wide);
    }
  }

  Widget _customerTwoColumnFields({
    required bool wide,
    required List<Widget> children,
  }) {
    if (!wide) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children
          .map(
            (child) => SizedBox(
              width:
                  (MediaQuery.of(context).size.width > 1200
                          ? 1200
                          : MediaQuery.of(context).size.width) /
                      2 -
                  32,
              child: child,
            ),
          )
          .toList(),
    );
  }

  Widget _customerSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.borderStrong),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _customerBasicInformationStep({required bool wide}) {
    return _customerSectionCard(
      title: 'Basic Information',
      subtitle: 'Customer identity and profile details.',
      child: _customerTwoColumnFields(
        wide: wide,
        children: [
          _field(
            label: 'Customer ID',
            controller: _customerIdController,
            hintText: 'CUS-2026-AUTO',
            readOnly: true,
          ),
          _customerDropdownBlock(
            label: 'Customer Type *',
            value: _selectedType,
            hintText: 'Select customer type',
            items: _baseCustomerTypes,
            onChanged: (value) {
              setState(() => _selectedType = value);
            },
          ),
          _field(
            label: 'Customer Name *',
            controller: _nameController,
            hintText: 'Enter customer name',
          ),
          _field(
            label: 'Legal Business Name',
            controller: _businessNameController,
            hintText: 'Enter legal business name',
          ),
          _field(
            label: 'Display Name',
            controller: _displayNameController,
            hintText: 'Enter display name',
          ),
          _customerDropdownBlock(
            label: 'Industry',
            value: _selectedIndustry,
            hintText: 'Select industry',
            items: _industryOptions,
            onChanged: (value) {
              setState(() => _selectedIndustry = value);
            },
          ),
          _customerDropdownBlock(
            label: 'Customer Category',
            value: _selectedCustomerCategory,
            hintText: 'Select customer category',
            items: _customerCategoryOptions,
            onChanged: (value) {
              setState(() => _selectedCustomerCategory = value);
            },
          ),
          _field(
            label: 'Customer Since *',
            controller: _customerSinceController,
            hintText: '08-08-2026',
            readOnly: true,
            suffixIcon: IconButton(
              onPressed: _pickCustomerSinceDate,
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _customerDropdownBlock(
            label: 'Status *',
            value: _selectedCustomerStatus,
            hintText: 'Active',
            items: _customerStatusOptions,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedCustomerStatus = value;
                _isActive = value == 'Active';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _customerContactInformationStep({required bool wide}) {
    return _customerSectionCard(
      title: 'Contact Information',
      subtitle: 'Primary contact and online contact details.',
      child: _customerTwoColumnFields(
        wide: wide,
        children: [
          _field(
            label: 'Primary Contact Person *',
            controller: _contactPersonController,
            hintText: 'Enter contact person',
          ),
          _field(
            label: 'Designation',
            controller: _designationController,
            hintText: 'Enter designation',
          ),
          _field(
            label: 'Mobile Number *',
            controller: _phoneController,
            hintText: 'Enter mobile number',
            keyboardType: TextInputType.phone,
          ),
          _field(
            label: 'Alternate Mobile Number',
            controller: _alternatePhoneController,
            hintText: 'Enter alternate number',
            keyboardType: TextInputType.phone,
          ),
          _field(
            label: 'Email Address',
            controller: _emailController,
            hintText: 'user@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          _field(
            label: 'Website',
            controller: _websiteController,
            hintText: 'https://example.com',
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _customerAddressInformationStep({required bool wide}) {
    return _customerSectionCard(
      title: 'Address Information',
      subtitle: 'Billing, shipping, region, and map location.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(
            label: 'Billing Address *',
            controller: _billingAddressController,
            hintText: 'Enter billing address',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _field(
            label: 'Shipping Address',
            controller: _deliveryAddressController,
            hintText: 'Enter shipping address',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderStrong.withValues(alpha: 0.35),
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
                    'Shipping address same as billing address',
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
          const SizedBox(height: 16),
          Text(
            'Country / State / City',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          CSCPicker(
            layout: Layout.vertical,
            showStates: true,
            showCities: true,
            flagState: CountryFlag.DISABLE,
            currentCountry: _countryController.text.trim().isEmpty
                ? null
                : _countryController.text,
            currentState: _stateController.text.trim().isEmpty
                ? null
                : _stateController.text,
            currentCity: _cityController.text.trim().isEmpty
                ? null
                : _cityController.text,
            dropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.surfaceSoft.withValues(alpha: 0.28),
              border: Border.all(
                color: AppColors.borderStrong.withValues(alpha: 0.25),
              ),
            ),
            disabledDropdownDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.surfaceSoft.withValues(alpha: 0.28),
              border: Border.all(
                color: AppColors.borderStrong.withValues(alpha: 0.25),
              ),
            ),
            selectedItemStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            dropdownHeadingStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            dropdownItemStyle: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            dropdownDialogRadius: 12,
            searchBarRadius: 12,
            countryDropdownLabel: 'Select Country',
            stateDropdownLabel: 'Select State',
            cityDropdownLabel: 'Select City',
            countrySearchPlaceholder: 'Search country',
            stateSearchPlaceholder: 'Search state',
            citySearchPlaceholder: 'Search city',
            onCountryChanged: (value) {
              setState(() {
                _selectedCountry = value;
                _countryController.text = value;
                _selectedState = null;
                _stateController.clear();
                _cityController.clear();
              });
            },
            onStateChanged: (value) {
              setState(() {
                _selectedState = value;
                _stateController.text = value ?? '';
                _cityController.clear();
              });
            },
            onCityChanged: (value) {
              setState(() {
                _cityController.text = value ?? '';
              });
            },
          ),
          const SizedBox(height: 16),
          _customerTwoColumnFields(
            wide: wide,
            children: [
              _field(
                label: 'PIN/ZIP Code',
                controller: _pinCodeController,
                hintText: 'Enter pin code',
                keyboardType: TextInputType.number,
              ),
              _field(
                label: 'Google Maps Location *',
                controller: _googleMapsController,
                hintText: 'Paste Google Maps link or coordinates',
                suffixIcon: TextButton.icon(
                  onPressed: () =>
                      _showMessage('Map picker not connected yet.'),
                  icon: const Icon(
                    Icons.my_location_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: const Text('Pick'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _customerBusinessTaxStep({required bool wide}) {
    return _customerSectionCard(
      title: 'Business & Tax Information',
      subtitle: 'Tax registration, business identity, and currency settings.',
      child: _customerTwoColumnFields(
        wide: wide,
        children: [
          _field(
            label: 'GSTIN / Tax ID',
            controller: _gstController,
            hintText: 'Enter GSTIN / Tax ID',
          ),
          _field(
            label: 'PAN / Business Registration No.',
            controller: _panController,
            hintText: 'Enter PAN / registration no.',
          ),
          _customerDropdownBlock<String>(
            label: 'Tax Category',
            value: _selectedTaxCategory,
            hintText: 'Select tax category',
            items: _taxCategoryOptions,
            onChanged: (value) => setState(() => _selectedTaxCategory = value),
          ),
          _customerDropdownBlock<String>(
            label: 'Currency',
            value: _selectedCurrency,
            hintText: 'INR',
            items: _currencyOptions,
            onChanged: (value) {
              if (value != null) setState(() => _selectedCurrency = value);
            },
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderStrong.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _taxExempt,
                  onChanged: (value) =>
                      setState(() => _taxExempt = value ?? false),
                  activeColor: AppColors.primary,
                  checkColor: Colors.white,
                ),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    'Tax Exempt',
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
        ],
      ),
    );
  }

  Widget _customerPaymentStep({required bool wide}) {
    return _customerSectionCard(
      title: 'Payment Information',
      subtitle: 'Credit, payment terms, UPI, and bank details.',
      child: _customerTwoColumnFields(
        wide: wide,
        children: [
          _customerDropdownBlock<String>(
            label: 'Payment Terms',
            value: _selectedPaymentTerm,
            hintText: 'Select payment terms',
            items: _paymentTermsOptions,
            onChanged: (value) =>
                setState(() => _selectedPaymentTerm = value),
          ),
          _field(
            label: 'Credit Limit',
            controller: _creditLimitController,
            hintText: '0',
            keyboardType: TextInputType.number,
          ),
          _field(
            label: 'Outstanding Balance',
            controller: _outstandingBalanceController,
            hintText: '₹0',
            keyboardType: TextInputType.number,
          ),
          _customerDropdownBlock<String>(
            label: 'Preferred Payment Method',
            value: _selectedPaymentMethod,
            hintText: 'Select preferred payment method',
            items: _paymentOptions,
            onChanged: (value) =>
                setState(() => _selectedPaymentMethod = value),
          ),
          _field(
            label: 'UPI ID',
            controller: _upiIdController,
            hintText: 'Enter UPI ID',
          ),
          _field(
            label: 'Bank Name',
            controller: _bankNameController,
            hintText: 'Enter bank name',
          ),
          _field(
            label: 'Account Number',
            controller: _accountNumberController,
            hintText: 'Enter account number',
            keyboardType: TextInputType.number,
          ),
          _field(
            label: 'IFSC/SWIFT Code',
            controller: _ifscController,
            hintText: 'Enter IFSC/SWIFT code',
          ),
        ],
      ),
    );
  }

  Widget _customerSalesCrmStep({
    required List<AppUser> users,
    required AppUser? selectedSalesOfficer,
    required bool wide,
  }) {
    return _customerSectionCard(
      title: 'Sales & CRM Information',
      subtitle: 'Sales ownership, priority, source, territory, and tags.',
      child: _customerTwoColumnFields(
        wide: wide,
        children: [
          _salesOfficerDropdown(users, selectedSalesOfficer),
          _customerDropdownBlock<String>(
            label: 'Lead Source',
            value: _selectedLeadSource,
            hintText: 'Select lead source',
            items: _leadSourceOptions,
            onChanged: (value) => setState(() => _selectedLeadSource = value),
          ),
          _customerDropdownBlock<String>(
            label: 'Territory',
            value: _selectedTerritory,
            hintText: 'Select territory',
            items: _territoryOptions,
            onChanged: (value) => setState(() => _selectedTerritory = value),
          ),
          _customerDropdownBlock<String>(
            label: 'Customer Priority',
            value: _selectedCustomerPriority,
            hintText: 'Select customer priority',
            items: _priorityOptions,
            onChanged: (value) =>
                setState(() => _selectedCustomerPriority = value),
          ),
          _field(
            label: 'Preferred Communication',
            controller: _preferredCommunicationController,
            hintText: 'Email, Phone, SMS, WhatsApp',
          ),
          _field(
            label: 'Customer Tags',
            controller: _customerTagsController,
            hintText: 'VIP, monthly-billing, key-account',
          ),
          _field(
            label: 'Notes',
            controller: _notesController,
            hintText: 'Enter notes',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _customerSocialStep({required bool wide}) {
    return _customerSectionCard(
      title: 'Social Media & Online Presence',
      subtitle: 'Customer social profile and channel links.',
      child: _customerTwoColumnFields(
        wide: wide,
        children: [
          _field(
            label: 'Facebook',
            controller: _facebookController,
            hintText: 'Facebook URL',
            keyboardType: TextInputType.url,
          ),
          _field(
            label: 'Instagram',
            controller: _instagramController,
            hintText: 'Instagram URL',
            keyboardType: TextInputType.url,
          ),
          _field(
            label: 'LinkedIn',
            controller: _linkedinController,
            hintText: 'LinkedIn URL',
            keyboardType: TextInputType.url,
          ),
          _field(
            label: 'X (Twitter)',
            controller: _xController,
            hintText: 'X/Twitter URL',
            keyboardType: TextInputType.url,
          ),
          _field(
            label: 'YouTube',
            controller: _youtubeController,
            hintText: 'YouTube URL',
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _customerDocumentsStep({required bool wide}) {
    return _customerSectionCard(
      title: 'Documents (Uploads)',
      subtitle: 'Tax, registration, address, and agreement documents.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _customerTwoColumnFields(
            wide: wide,
            children: [
              _customerUploadCard(
                title: 'GST Certificate *',
                mimeHint: 'image/png,image/jpeg',
                bytes: _gstCertificateBytes,
                name: _gstCertificateName,
                onUpload: () => _pickCustomerDocument(_CustomerDocSlot.gst),
                onRemove: () => _removeCustomerDocument(_CustomerDocSlot.gst),
              ),
              _customerUploadCard(
                title: 'PAN Card',
                mimeHint: 'image/png,image/jpeg',
                bytes: _panCardBytes,
                name: _panCardName,
                onUpload: () => _pickCustomerDocument(_CustomerDocSlot.pan),
                onRemove: () => _removeCustomerDocument(_CustomerDocSlot.pan),
              ),
              _customerUploadCard(
                title: 'Business Registration Certificate',
                mimeHint: 'image/png,image/jpeg',
                bytes: _businessRegistrationBytes,
                name: _businessRegistrationName,
                onUpload: () => _pickCustomerDocument(
                  _CustomerDocSlot.businessRegistration,
                ),
                onRemove: () => _removeCustomerDocument(
                  _CustomerDocSlot.businessRegistration,
                ),
              ),
              _customerUploadCard(
                title: 'Address Proof',
                mimeHint: 'image/png,image/jpeg',
                bytes: _addressProofBytes,
                name: _addressProofName,
                onUpload: () =>
                    _pickCustomerDocument(_CustomerDocSlot.addressProof),
                onRemove: () =>
                    _removeCustomerDocument(_CustomerDocSlot.addressProof),
              ),
              _customerUploadCard(
                title: 'Purchase Agreement',
                mimeHint: 'image/png,image/jpeg',
                bytes: _purchaseAgreementBytes,
                name: _purchaseAgreementName,
                onUpload: () =>
                    _pickCustomerDocument(_CustomerDocSlot.purchaseAgreement),
                onRemove: () =>
                    _removeCustomerDocument(_CustomerDocSlot.purchaseAgreement),
              ),
              _customerUploadCard(
                title: 'Other Business Documents',
                mimeHint: 'image/png,image/jpeg',
                bytes: _otherDocBytes,
                name: _otherDocName,
                onUpload: () => _pickCustomerDocument(_CustomerDocSlot.other),
                onRemove: () => _removeCustomerDocument(_CustomerDocSlot.other),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _customerAdditionalStep({required bool wide}) {
    return _customerSectionCard(
      title: 'Additional Information',
      subtitle: 'Referral, loyalty, reminders, and internal notes.',
      child: _customerTwoColumnFields(
        wide: wide,
        children: [
          _field(
            label: 'Date of Birth',
            controller: _dobController,
            hintText: 'dd-mm-yyyy',
            readOnly: true,
            suffixIcon: IconButton(
              onPressed: () =>
                  _showMessage('Date of birth picker not connected yet.'),
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _field(
            label: 'Anniversary Date',
            controller: _anniversaryController,
            hintText: 'dd-mm-yyyy',
            readOnly: true,
            suffixIcon: IconButton(
              onPressed: () =>
                  _showMessage('Anniversary picker not connected yet.'),
              icon: const Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _field(
            label: 'Referral Customer',
            controller: _referralCustomerController,
            hintText: 'Enter referral customer',
          ),
          _field(
            label: 'Loyalty Number',
            controller: _loyaltyNumberController,
            hintText: 'Enter loyalty number',
          ),
          _field(
            label: 'Notes',
            controller: _customerRemarksController,
            hintText: 'Enter notes',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _customerUploadCard({
    required String title,
    required String mimeHint,
    required Uint8List? bytes,
    required String? name,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE3EA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFFBFBFB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE1E4E8)),
            ),
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            child: bytes == null
                ? const Text(
                    'Preview',
                    style: TextStyle(
                      color: Color(0xFF98A2B3),
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Image.memory(bytes, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mimeHint,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: onUpload,
                      icon: const Icon(Icons.file_upload_outlined, size: 18),
                      label: const Text('Upload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8CAD84),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: bytes == null ? null : onRemove,
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Remove'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF9CA3AF),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (name != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildFormPanel({
    required List<AppUser> users,
    required AppUser? selectedSalesOfficer,
    required bool wide,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderStrong.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Customer',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Keep the customer profile, addresses, and account settings in one place.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
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
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _field(
              label: 'GST Number',
              controller: _gstController,
              hintText: 'Enter GST number',
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderStrong.withValues(alpha: 0.35),
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
                  child: _salesOfficerDropdown(users, selectedSalesOfficer),
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
            _salesOfficerDropdown(users, selectedSalesOfficer),
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft.withValues(alpha: 0.32),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.borderStrong.withValues(alpha: 0.25),
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
                    inactiveTrackColor: AppColors.borderStrong.withValues(
                      alpha: 0.45,
                    ),
                    trackOutlineColor: const WidgetStatePropertyAll(
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
                    : () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.surfaceSoft,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSubmitting ? null : () => _submit(users),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
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
                        widget.isEditMode ? 'Save Changes' : 'Save Customer',
                      ),
              ),
            ],
          ),
        ],
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
    bool readOnly = false,
    Widget? suffixIcon,
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
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(hintText, suffixIcon: suffixIcon),
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

  // ignore: unused_element
  Widget _dropdownField<T>({
    T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hintText != null) ...[
          DropdownButtonFormField<T>(
            key: ValueKey<String?>('dropdown-$value'),
            initialValue: value,
            isExpanded: true,
            menuMaxHeight: 280,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textLightMuted,
            ),
            hint: Text(
              hintText,
              style: const TextStyle(color: AppColors.textLightMuted),
            ),
            decoration: _inputDecoration(''),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            items: items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      '$item',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ] else
          DropdownButtonFormField<T>(
            key: ValueKey<String?>('dropdown-$value'),
            initialValue: value,
            isExpanded: true,
            menuMaxHeight: 280,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textLightMuted,
            ),
            decoration: _inputDecoration(''),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            items: items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      '$item',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
      ],
    );
  }

  Widget _customerDropdownBlock<T>({
    required String label,
    required T? value,
    required String hintText,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    final effectiveValue = _optionValueOrNull(value, items);

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
        DropdownButtonFormField<T>(
          key: ValueKey<String?>('$label-$effectiveValue'),
          initialValue: effectiveValue,
          isExpanded: true,
          menuMaxHeight: 280,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textLightMuted,
          ),
          hint: Text(
            hintText,
            style: const TextStyle(color: AppColors.textLightMuted),
          ),
          decoration: _inputDecoration(''),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    '$item',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
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

  String _formatToday() {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(now.day)}-${two(now.month)}-${now.year}';
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}-${two(date.month)}-${date.year}';
  }

  DateTime? _parseDisplayDate(String value) {
    final parts = value.trim().split('-');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  String _formatDisplayDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}-${two(date.month)}-${date.year}';
  }
}

class _CustomerWizardStep {
  final String title;
  final IconData icon;

  const _CustomerWizardStep(this.title, this.icon);
}

class _PendingCustomerDocument {
  final String documentType;
  final Uint8List? bytes;
  final String? fileName;

  const _PendingCustomerDocument({
    required this.documentType,
    required this.bytes,
    required this.fileName,
  });

  bool get canUpload =>
      bytes != null && fileName != null && fileName!.trim().isNotEmpty;
}

enum _CustomerDocSlot {
  gst,
  pan,
  businessRegistration,
  addressProof,
  purchaseAgreement,
  other,
}
