import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/app_drawer.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color blue = Color(0xFF3B82F6);
  static const Color red = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFF1F2A2E);
  static const Color textSecondary = Color(0xFF667077);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _companyNameController = TextEditingController(text: 'SAAS Distributors');
  final _emailController = TextEditingController(text: 'contact@saasdistributors.in');
  final _phoneController = TextEditingController(text: '+91 80 4567 8901');
  final _altPhoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _gstController = TextEditingController(text: '29AAACA1234F1Z5');
  final _panController = TextEditingController();
  final _billingAddressController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _invoicePrefixController = TextEditingController();
  final _invoiceStartController = TextEditingController(text: '1');

  String _businessType = 'Water Distribution';
  String _financialYear = 'FY 2026-27';
  bool _shippingSameAsBilling = true;
  bool _isSaving = false;
  Uint8List? _logoBytes;

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
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Company settings saved')),
    );
  }

  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _logoBytes = bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open image picker: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bg,
      drawer: const AppDrawer(activeItem: 'Company Settings'),
      body: SafeArea(
        child: Container(
          color: bg,
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderRow(),
                      const SizedBox(height: 20),
                      _CardContainer(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(20),
                        child: _sectionWrap('Company Logo', _buildLogoRow()),
                      ),
                      const SizedBox(height: 20),
                      _CardContainer(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(20),
                        child: _sectionWrap('Company Information', _buildCompanyInfoFields()),
                      ),
                      const SizedBox(height: 20),
                      _CardContainer(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(20),
                        child: _sectionWrap('Address', _buildAddressFields()),
                      ),
                      const SizedBox(height: 20),
                      _CardContainer(
                        borderRadius: 24,
                        padding: const EdgeInsets.all(20),
                        child: _sectionWrap('Financial Year & Invoice Numbering', _buildFinancialFields()),
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
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: _CardContainer(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: _iconBadge(Icons.menu, textPrimary.withOpacity(0.06), textPrimary),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Company Settings',
                style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _iconBadge(Icons.notifications_none_rounded, textPrimary.withOpacity(0.06), textPrimary),
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [purple, blue]),
              ),
              alignment: Alignment.center,
              child: const Text('AS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Company Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary)),
              SizedBox(height: 4),
              Text('Manage your company profile and invoicing identity', style: TextStyle(color: textSecondary, fontSize: 12.5)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _isSaving ? null : _handleSave,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [purple, blue]),
              borderRadius: BorderRadius.circular(30),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _sectionWrap(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: textPrimary)),
        const SizedBox(height: 18),
        child,
      ],
    );
  }

  Widget _buildLogoRow() {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: textPrimary.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textPrimary.withOpacity(0.08)),
          ),
          alignment: Alignment.center,
          child: _logoBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(_logoBytes!, width: 72, height: 72, fit: BoxFit.cover),
                )
              : Text(
                  _companyNameController.text.isNotEmpty ? _companyNameController.text[0].toUpperCase() : '?',
                  style: TextStyle(fontSize: 26, color: textSecondary, fontWeight: FontWeight.w600),
                ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: _pickLogo,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: purple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: purple.withOpacity(0.25)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload_outlined, color: purple, size: 18),
                SizedBox(width: 8),
                Text('Upload Logo', style: TextStyle(color: purple, fontWeight: FontWeight.w600, fontSize: 13.5)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyInfoFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Company Name'),
        _textField(controller: _companyNameController),
        const SizedBox(height: 18),
        _fieldLabel('Business Type'),
        _dropdownField(
          value: _businessType,
          items: _businessTypes,
          onChanged: (v) => setState(() => _businessType = v!),
        ),
        const SizedBox(height: 18),
        _fieldLabel('Email'),
        _textField(controller: _emailController, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 18),
        _fieldLabel('Phone'),
        _textField(controller: _phoneController, keyboardType: TextInputType.phone),
        const SizedBox(height: 18),
        _fieldLabel('Alternate Phone'),
        _textField(controller: _altPhoneController, keyboardType: TextInputType.phone),
        const SizedBox(height: 18),
        _fieldLabel('Website'),
        _textField(controller: _websiteController, hint: 'https://example.com'),
        const SizedBox(height: 18),
        _fieldLabel('GST Number'),
        _textField(controller: _gstController),
        const SizedBox(height: 18),
        _fieldLabel('PAN Number'),
        _textField(controller: _panController),
      ],
    );
  }

  Widget _buildAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Billing Address'),
        _textField(controller: _billingAddressController, maxLines: 3),
        const SizedBox(height: 14),
        InkWell(
          onTap: () => setState(() => _shippingSameAsBilling = !_shippingSameAsBilling),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _shippingSameAsBilling,
                activeColor: purple,
                onChanged: (v) => setState(() => _shippingSameAsBilling = v ?? true),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    'Shipping / warehouse address is the same as billing',
                    style: TextStyle(color: textPrimary.withOpacity(0.85), fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!_shippingSameAsBilling) ...[
          const SizedBox(height: 14),
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
        _fieldLabel('Financial Year'),
        _dropdownField(
          value: _financialYear,
          items: _financialYears,
          onChanged: (v) => setState(() => _financialYear = v!),
        ),
        const SizedBox(height: 18),
        _fieldLabel('Invoice Prefix'),
        _textField(controller: _invoicePrefixController, hint: 'e.g. INV-'),
        const SizedBox(height: 18),
        _fieldLabel('Invoice Starting Number'),
        _textField(controller: _invoiceStartController, keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(color: textPrimary.withOpacity(0.85), fontWeight: FontWeight.w600, fontSize: 13.5)),
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
      style: const TextStyle(color: textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textSecondary.withOpacity(0.7), fontSize: 13.5),
        filled: true,
        fillColor: textPrimary.withOpacity(0.03),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textPrimary.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: textPrimary.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: purple, width: 1.4),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: textPrimary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textPrimary.withOpacity(0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: purple),
          style: const TextStyle(color: textPrimary, fontSize: 14),
          dropdownColor: Colors.white,
          items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color background, Color fg) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: 20),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const _CardContainer({
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE6E8EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2A2E).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
