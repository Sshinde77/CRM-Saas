import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import 'company_settings_constants.dart';
import '../../../widgets/admin/admin_top_bar.dart';

const Color kGeneralInfoTitleColor = Color(0xFF0F172A);
const Color kGeneralInfoMutedColor = Color(0xFF64748B);
const Color kGeneralInfoAccentColor = Color(0xFF0B4D08);

class GeneralInformationScreen extends StatefulWidget {
  const GeneralInformationScreen({super.key});

  @override
  State<GeneralInformationScreen> createState() =>
      _GeneralInformationScreenState();
}

class _GeneralInformationScreenState extends State<GeneralInformationScreen> {
  static const Color _borderColor = Color(0xFFD8DFD8);
  static const Color _fieldBg = Colors.white;

  final TextEditingController _companyNameController =
      TextEditingController(text: 'lol');
  final TextEditingController _legalNameController =
      TextEditingController(text: 'lol');
  final TextEditingController _dateOfIncorporationController =
      TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _gstinController =
      TextEditingController(text: '29AAACA1234F1Z3');
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _primaryMobileController =
      TextEditingController(text: '9986547856');
  final TextEditingController _alternateMobileController =
      TextEditingController();
  final TextEditingController _landlineController = TextEditingController();
  final TextEditingController _officialEmailController =
      TextEditingController(text: 'testing@gmail.com');
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _supportNumberController =
      TextEditingController();
  final TextEditingController _registeredAddressController =
      TextEditingController(text: 'rwqyenebqqbth');
  final TextEditingController _branchOfficeAddressController =
      TextEditingController();
  final TextEditingController _cityController =
      TextEditingController(text: 'Mumbai');
  final TextEditingController _pinCodeController =
      TextEditingController(text: '400001');
  final TextEditingController _billingAddressController =
      TextEditingController(text: 'rwqyenebqqbth');
  final TextEditingController _shippingAddressController =
      TextEditingController();

  bool _isEditing = false;
  bool _basicExpanded = true;
  bool _contactExpanded = false;
  bool _addressExpanded = true;
  bool _saving = false;
  bool _billingSameAsRegistered = false;
  bool _shippingSameAsBilling = false;

  String _selectedBusinessType = 'Private Ltd';
  String? _selectedIndustry;
  String _selectedState = 'Maharashtra';
  String _selectedCountry = 'India';
  String _savedCompanyName = 'lol';
  String _savedLegalName = 'lol';
  String _savedDateOfIncorporation = '';
  String _savedCin = '';
  String _savedGstin = '29AAACA1234F1Z3';
  String _savedPan = '';
  String _savedDescription = '';
  String _savedPrimaryMobile = '9986547856';
  String _savedAlternateMobile = '';
  String _savedLandline = '';
  String _savedOfficialEmail = 'testing@gmail.com';
  String _savedWebsite = '';
  String _savedSupportNumber = '';
  String _savedBusinessType = 'Private Ltd';
  String? _savedIndustry;
  String _savedRegisteredAddress = 'rwqyenebqqbth';
  String _savedBranchOfficeAddress = '';
  String _savedCity = 'Mumbai';
  String _savedState = 'Maharashtra';
  String _savedCountry = 'India';
  String _savedPinCode = '400001';
  String _savedBillingAddress = 'rwqyenebqqbth';
  String _savedShippingAddress = '';
  bool _savedBillingSameAsRegistered = false;
  bool _savedShippingSameAsBilling = false;

  @override
  void initState() {
    super.initState();
    _registeredAddressController.addListener(_syncAddressFields);
    _billingAddressController.addListener(_syncAddressFields);
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _legalNameController.dispose();
    _dateOfIncorporationController.dispose();
    _cinController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _descriptionController.dispose();
    _primaryMobileController.dispose();
    _alternateMobileController.dispose();
    _landlineController.dispose();
    _officialEmailController.dispose();
    _websiteController.dispose();
    _supportNumberController.dispose();
    _registeredAddressController.dispose();
    _branchOfficeAddressController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    super.dispose();
  }

  void _syncAddressFields() {
    if (_billingSameAsRegistered &&
        _billingAddressController.text != _registeredAddressController.text) {
      _billingAddressController.text = _registeredAddressController.text;
    }

    if (_shippingSameAsBilling &&
        _shippingAddressController.text != _billingAddressController.text) {
      _shippingAddressController.text = _billingAddressController.text;
    }
  }

  Future<void> _handleSave() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _saving = false;
      _isEditing = false;
      _savedCompanyName = _companyNameController.text;
      _savedLegalName = _legalNameController.text;
      _savedDateOfIncorporation = _dateOfIncorporationController.text;
      _savedCin = _cinController.text;
      _savedGstin = _gstinController.text;
      _savedPan = _panController.text;
      _savedDescription = _descriptionController.text;
      _savedPrimaryMobile = _primaryMobileController.text;
      _savedAlternateMobile = _alternateMobileController.text;
      _savedLandline = _landlineController.text;
      _savedOfficialEmail = _officialEmailController.text;
      _savedWebsite = _websiteController.text;
      _savedSupportNumber = _supportNumberController.text;
      _savedBusinessType = _selectedBusinessType;
      _savedIndustry = _selectedIndustry;
      _savedRegisteredAddress = _registeredAddressController.text;
      _savedBranchOfficeAddress = _branchOfficeAddressController.text;
      _savedCity = _cityController.text;
      _savedState = _selectedState;
      _savedCountry = _selectedCountry;
      _savedPinCode = _pinCodeController.text;
      _savedBillingAddress = _billingAddressController.text;
      _savedShippingAddress = _shippingAddressController.text;
      _savedBillingSameAsRegistered = _billingSameAsRegistered;
      _savedShippingSameAsBilling = _shippingSameAsBilling;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('General information saved')));
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  void _cancelEdit() {
    setState(() {
      _companyNameController.text = _savedCompanyName;
      _legalNameController.text = _savedLegalName;
      _dateOfIncorporationController.text = _savedDateOfIncorporation;
      _cinController.text = _savedCin;
      _gstinController.text = _savedGstin;
      _panController.text = _savedPan;
      _descriptionController.text = _savedDescription;
      _primaryMobileController.text = _savedPrimaryMobile;
      _alternateMobileController.text = _savedAlternateMobile;
      _landlineController.text = _savedLandline;
      _officialEmailController.text = _savedOfficialEmail;
      _websiteController.text = _savedWebsite;
      _supportNumberController.text = _savedSupportNumber;
      _selectedBusinessType = _savedBusinessType;
      _selectedIndustry = _savedIndustry;
      _registeredAddressController.text = _savedRegisteredAddress;
      _branchOfficeAddressController.text = _savedBranchOfficeAddress;
      _cityController.text = _savedCity;
      _selectedState = _savedState;
      _selectedCountry = _savedCountry;
      _pinCodeController.text = _savedPinCode;
      _billingAddressController.text = _savedBillingAddress;
      _shippingAddressController.text = _savedShippingAddress;
      _billingSameAsRegistered = _savedBillingSameAsRegistered;
      _shippingSameAsBilling = _savedShippingSameAsBilling;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'General Information',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 700;
                  final contentWidth = constraints.maxWidth > 1180
                      ? 1180.0
                      : constraints.maxWidth;

                  return Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        children: [
                          _GeneralInfoSectionCard(
                            number: '1',
                            title: 'Basic Information',
                            subtitle:
                                'Company identity and legal registration details.',
                            expanded: _basicExpanded,
                            onTap: () =>
                                setState(() => _basicExpanded = !_basicExpanded),
                            child: _basicExpanded
                                ? _EditableAbsorbPointer(
                                    enabled: _isEditing,
                                    child: _ResponsiveFields(
                                      isWide: isWide,
                                      children: [
                                        _fieldBlock(
                                          label: 'Company Name',
                                          child: _textField(
                                            controller: _companyNameController,
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'Legal Name',
                                          child: _textField(
                                            controller: _legalNameController,
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'Business Type',
                                          child: _dropdownField<String>(
                                            value: _selectedBusinessType,
                                            items: kBusinessTypeOptions,
                                            onChanged: (value) {
                                              if (value == null) return;
                                              setState(
                                                () => _selectedBusinessType = value,
                                              );
                                            },
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'Industry',
                                          child: _dropdownField<String>(
                                            value: _selectedIndustry,
                                            hintText: 'Select industry',
                                            items: kIndustryOptions,
                                            onChanged: (value) {
                                              if (value == null) return;
                                              setState(
                                                () => _selectedIndustry = value,
                                              );
                                            },
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'Date of Incorporation',
                                          child: _textField(
                                            controller:
                                                _dateOfIncorporationController,
                                            hintText: 'dd-mm-yyyy',
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'CIN/Registration Number',
                                          child: _textField(
                                            controller: _cinController,
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'GSTIN/PAN',
                                          child: _textField(
                                            controller: _gstinController,
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'PAN Number (if applicable)',
                                          child: _textField(
                                            controller: _panController,
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'Company Description',
                                          fullWidth: true,
                                          child: _textField(
                                            controller: _descriptionController,
                                            maxLines: 4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 18),
                          _GeneralInfoSectionCard(
                            number: '2',
                            title: 'Contact Information',
                            subtitle: 'Primary business contact details.',
                            expanded: _contactExpanded,
                            onTap: () => setState(
                              () => _contactExpanded = !_contactExpanded,
                            ),
                            child: _contactExpanded
                                ? _EditableAbsorbPointer(
                                    enabled: _isEditing,
                                    child: _ResponsiveFields(
                                      isWide: isWide,
                                      children: [
                                        _fieldBlock(
                                          label: 'Primary Mobile Number',
                                          child: _textField(
                                            controller: _primaryMobileController,
                                            keyboardType: TextInputType.phone,
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'Alternate Mobile Number',
                                          child: _textField(
                                            controller:
                                                _alternateMobileController,
                                            keyboardType: TextInputType.phone,
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'Landline Number',
                                          child: _textField(
                                            controller: _landlineController,
                                            keyboardType: TextInputType.phone,
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'Official Email Address',
                                          child: _textField(
                                            controller: _officialEmailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'Website',
                                          child: _textField(
                                            controller: _websiteController,
                                            hintText: 'https://',
                                            keyboardType: TextInputType.url,
                                          ),
                                        ),
                                        _fieldBlock(
                                          label: 'Customer Support Number',
                                          child: _textField(
                                            controller: _supportNumberController,
                                            keyboardType: TextInputType.phone,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 18),
                          _GeneralInfoSectionCard(
                            number: '3',
                            title: 'Address Information',
                            subtitle:
                                'Registered, billing, and shipping addresses.',
                            expanded: _addressExpanded,
                            onTap: () => setState(
                              () => _addressExpanded = !_addressExpanded,
                            ),
                            child: _addressExpanded
                                ? _EditableAbsorbPointer(
                                    enabled: _isEditing,
                                    child: Column(
                                      children: [
                                        _fieldBlock(
                                          label: 'Registered Address',
                                          child: _textField(
                                            controller:
                                                _registeredAddressController,
                                            maxLines: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _fieldBlock(
                                          label: 'Branch/Office Address(es)',
                                          child: _textField(
                                            controller:
                                                _branchOfficeAddressController,
                                            maxLines: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        _ResponsiveFields(
                                          isWide: isWide,
                                          children: [
                                            _fieldBlock(
                                              label: 'City',
                                              child: _textField(
                                                controller: _cityController,
                                              ),
                                            ),
                                            _fieldBlock(
                                              label: 'State',
                                              child: _dropdownField<String>(
                                                value: _selectedState,
                                                items: const [
                                                  'Maharashtra',
                                                  'Gujarat',
                                                  'Karnataka',
                                                  'Delhi',
                                                  'Tamil Nadu',
                                                  'Other',
                                                ],
                                                onChanged: (value) {
                                                  if (value == null) return;
                                                  setState(
                                                    () => _selectedState = value,
                                                  );
                                                },
                                              ),
                                            ),
                                            _fieldBlock(
                                              label: 'Country',
                                              child: _dropdownField<String>(
                                                value: _selectedCountry,
                                                items: const [
                                                  'India',
                                                  'United States',
                                                  'United Kingdom',
                                                  'UAE',
                                                  'Other',
                                                ],
                                                onChanged: (value) {
                                                  if (value == null) return;
                                                  setState(
                                                    () => _selectedCountry =
                                                        value,
                                                  );
                                                },
                                              ),
                                            ),
                                            _fieldBlock(
                                              label: 'PIN/ZIP Code',
                                              child: _textField(
                                                controller: _pinCodeController,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 14),
                                        CheckboxListTile(
                                          contentPadding: EdgeInsets.zero,
                                          dense: true,
                                          visualDensity: VisualDensity.compact,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          value: _billingSameAsRegistered,
                                          onChanged: (value) {
                                            setState(() {
                                              _billingSameAsRegistered =
                                                  value ?? false;
                                              if (_billingSameAsRegistered) {
                                                _billingAddressController.text =
                                                    _registeredAddressController
                                                        .text;
                                              }
                                            });
                                          },
                                          title: const Text(
                                            'Billing address same as registered address',
                                            style: TextStyle(
                                              color: kGeneralInfoTitleColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        _fieldBlock(
                                          label: 'Billing Address',
                                          child: _textField(
                                            controller: _billingAddressController,
                                            maxLines: 3,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        CheckboxListTile(
                                          contentPadding: EdgeInsets.zero,
                                          dense: true,
                                          visualDensity: VisualDensity.compact,
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          value: _shippingSameAsBilling,
                                          onChanged: (value) {
                                            setState(() {
                                              _shippingSameAsBilling =
                                                  value ?? false;
                                              if (_shippingSameAsBilling) {
                                                _shippingAddressController.text =
                                                    _billingAddressController
                                                        .text;
                                              }
                                            });
                                          },
                                          title: const Text(
                                            'Shipping/Warehouse address same as billing address',
                                            style: TextStyle(
                                              color: kGeneralInfoTitleColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        _fieldBlock(
                                          label: 'Shipping/Warehouse Address',
                                          child: _textField(
                                            controller:
                                                _shippingAddressController,
                                            maxLines: 3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
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

  Widget _fieldBlock({
    required String label,
    required Widget child,
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                color: kGeneralInfoTitleColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: maxLines > 1 ? maxLines : 1,
      style: const TextStyle(fontSize: 15, color: kGeneralInfoTitleColor),
      decoration: _fieldDecoration(hintText: hintText),
    );
  }

  Widget _dropdownField<T>({
    T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: onChanged,
      isExpanded: true,
      menuMaxHeight: 260,
      icon: const Icon(
        Icons.expand_more_rounded,
        color: Color(0xFF98A2B3),
      ),
      hint: hintText == null
          ? null
          : Text(
              hintText,
              style: const TextStyle(color: Color(0xFFB5BCC6)),
            ),
      style: const TextStyle(fontSize: 15, color: kGeneralInfoTitleColor),
      decoration: _fieldDecoration(),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                '$item',
                style: const TextStyle(
                  fontSize: 15,
                  color: kGeneralInfoTitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      filled: true,
      fillColor: _fieldBg,
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFFB5BCC6),
        fontSize: 15,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _borderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kGeneralInfoAccentColor, width: 2),
      ),
    );
  }
}

class _GeneralInfoSectionCard extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool expanded;
  final VoidCallback onTap;
  final Widget child;

  const _GeneralInfoSectionCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE3EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B4D08),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: kGeneralInfoTitleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: kGeneralInfoMutedColor,
                            fontSize: 13,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF667085),
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 18),
            child,
          ],
        ],
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  final bool isWide;
  final List<Widget> children;

  const _ResponsiveFields({
    required this.isWide,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    }

    final width = MediaQuery.of(context).size.width;
    final cardWidth = (width > 1180 ? 1180 : width) / 2 - 22;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children
          .map((child) => SizedBox(width: cardWidth, child: child))
          .toList(),
    );
  }
}

class _EditableAbsorbPointer extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const _EditableAbsorbPointer({
    required this.enabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(absorbing: !enabled, child: child);
  }
}
