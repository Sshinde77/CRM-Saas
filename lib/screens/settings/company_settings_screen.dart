import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/soft_action_button.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _companyNameController = TextEditingController(
    text: 'SAAS Distributors',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'contact@saasdistributors.in',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+91 80 4567 8901',
  );
  final TextEditingController _altPhoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _gstController = TextEditingController(
    text: '29AAACA1234F1Z5',
  );
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _billingAddressController =
      TextEditingController();
  final TextEditingController _shippingAddressController =
      TextEditingController();
  final TextEditingController _invoicePrefixController =
      TextEditingController();
  final TextEditingController _invoiceStartController = TextEditingController(
    text: '1',
  );

  Uint8List? _logoBytes;
  bool _isSaving = false;
  bool _shippingSameAsBilling = true;
  String _businessType = 'Water Distribution';
  String _financialYear = 'FY 2026-27';

  static const List<String> _businessTypes = [
    'Water Distribution',
    'FMCG Distribution',
    'Pharma Distribution',
    'Electronics Distribution',
    'General Trading',
  ];

  static const List<String> _financialYears = [
    'FY 2024-25',
    'FY 2025-26',
    'FY 2026-27',
    'FY 2027-28',
  ];

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _websiteController.dispose();
    _gstController.dispose();
    _panController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    _invoicePrefixController.dispose();
    _invoiceStartController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Company settings saved')));
  }

  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _logoBytes = bytes);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open image picker: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(activeItem: 'Company Settings'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Company Settings',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Company Profile',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Manage your company identity and invoicing details',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.purple,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Text('Save Changes'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCard(child: _buildLogoSection()),
                    const SizedBox(height: 16),
                    _buildCard(child: _buildCompanyInfoFields()),
                    const SizedBox(height: 16),
                    _buildCard(child: _buildAddressFields()),
                    const SizedBox(height: 16),
                    _buildCard(child: _buildFinancialFields()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Logo',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.24),
                ),
              ),
              alignment: Alignment.center,
              child: _logoBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(_logoBytes!, fit: BoxFit.cover),
                    )
                  : Text(
                      _companyNameController.text.isEmpty
                          ? '?'
                          : _companyNameController.text[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.purple,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            SoftActionButton(
              label: 'Upload Logo',
              icon: Icons.upload_outlined,
              onPressed: _pickLogo,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompanyInfoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Company Information',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _fieldLabel('Company Name'),
        _textField(controller: _companyNameController),
        const SizedBox(height: 16),
        _fieldLabel('Business Type'),
        DropdownButtonFormField<String>(
          initialValue: _businessType,
          decoration: _inputDecoration(),
          items: _businessTypes
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _businessType = value);
            }
          },
        ),
        const SizedBox(height: 16),
        _fieldLabel('Email'),
        _textField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _fieldLabel('Phone'),
        _textField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _fieldLabel('Alternate Phone'),
        _textField(
          controller: _altPhoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _fieldLabel('Website'),
        _textField(controller: _websiteController, hint: 'https://example.com'),
        const SizedBox(height: 16),
        _fieldLabel('GST Number'),
        _textField(controller: _gstController),
        const SizedBox(height: 16),
        _fieldLabel('PAN Number'),
        _textField(controller: _panController),
      ],
    );
  }

  Widget _buildAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _fieldLabel('Billing Address'),
        _textField(controller: _billingAddressController, maxLines: 3),
        const SizedBox(height: 12),
        SwitchListTile(
          value: _shippingSameAsBilling,
          onChanged: (value) => setState(() => _shippingSameAsBilling = value),
          activeThumbColor: AppColors.purple,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Shipping / warehouse address is the same as billing',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        if (!_shippingSameAsBilling) ...[
          const SizedBox(height: 12),
          _fieldLabel('Shipping / Warehouse Address'),
          _textField(controller: _shippingAddressController, maxLines: 3),
        ],
      ],
    );
  }

  Widget _buildFinancialFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Year & Invoice Numbering',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _fieldLabel('Financial Year'),
        DropdownButtonFormField<String>(
          initialValue: _financialYear,
          decoration: _inputDecoration(),
          items: _financialYears
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _financialYear = value);
            }
          },
        ),
        const SizedBox(height: 16),
        _fieldLabel('Invoice Prefix'),
        _textField(controller: _invoicePrefixController, hint: 'e.g. INV-'),
        const SizedBox(height: 16),
        _fieldLabel('Invoice Starting Number'),
        _textField(
          controller: _invoiceStartController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(hint: hint),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.surfaceSoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.secondary.withValues(alpha: 0.24),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.secondary.withValues(alpha: 0.24),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.purple),
      ),
    );
  }
}
