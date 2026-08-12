// ignore_for_file: unused_field, unused_element, prefer_final_fields

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../../constants/app_colors.dart';
import '../../../models/auth_models.dart';
import '../../../services/api_service.dart';
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
  final ApiService _apiService = ApiService();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _companyNameController = TextEditingController(
    text: 'lol',
  );
  final TextEditingController _legalNameController = TextEditingController(
    text: 'lol',
  );
  final TextEditingController _dateOfIncorporationController =
      TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController(
    text: '29AAACA1234F1Z3',
  );
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _authorizedNameController = TextEditingController(
    text: 'Sushil',
  );
  final TextEditingController _designationController = TextEditingController(
    text: 'Admin',
  );
  final TextEditingController _authorizedMobileController =
      TextEditingController(text: '9986547856');
  final TextEditingController _authorizedEmailController =
      TextEditingController(text: 'testing@gmail.com');
  final TextEditingController _primaryMobileController = TextEditingController(
    text: '9986547856',
  );
  final TextEditingController _alternateMobileController =
      TextEditingController();
  final TextEditingController _landlineController = TextEditingController();
  final TextEditingController _officialEmailController = TextEditingController(
    text: 'testing@gmail.com',
  );
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _supportNumberController =
      TextEditingController();
  final TextEditingController _registeredAddressController =
      TextEditingController(text: 'rwqyenebqqbth');
  final TextEditingController _branchOfficeAddressController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController(
    text: 'Mumbai',
  );
  final TextEditingController _pinCodeController = TextEditingController(
    text: '400001',
  );
  final TextEditingController _billingAddressController = TextEditingController(
    text: 'rwqyenebqqbth',
  );
  final TextEditingController _shippingAddressController =
      TextEditingController();

  bool _isEditing = false;
  bool _basicExpanded = true;
  bool _authorizedExpanded = true;
  bool _contactExpanded = false;
  bool _addressExpanded = true;
  bool _billingSameAsRegistered = false;
  bool _shippingSameAsBilling = false;

  String _selectedBusinessType = 'Private Ltd';
  static const List<String> _designationOptions = [
    'Owner',
    'Director',
    'Admin',
    'Manager',
    'Sales Officer',
  ];
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
  Uint8List? _profilePictureBytes;
  String? _profilePictureName;
  String? _profilePictureUrl;
  Uint8List? _signatureBytes;
  String? _signatureName;

  @override
  void initState() {
    super.initState();
    _registeredAddressController.addListener(_syncAddressFields);
    _billingAddressController.addListener(_syncAddressFields);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrganizationSettings();
    });
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
    _authorizedNameController.dispose();
    _designationController.dispose();
    _authorizedMobileController.dispose();
    _authorizedEmailController.dispose();
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

  Future<void> _pickAttachment({required bool isSignature}) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      String? uploadedUrl;
      if (!isSignature) {
        uploadedUrl = await _apiService.uploadOrganizationSettingsFile(
          fileBytes: bytes,
          fileName: picked.name,
        );
      }
      setState(() {
        if (isSignature) {
          _signatureBytes = bytes;
          _signatureName = picked.name;
        } else {
          _profilePictureBytes = bytes;
          _profilePictureName = picked.name;
          if (uploadedUrl != null && uploadedUrl.trim().isNotEmpty) {
            _profilePictureUrl = uploadedUrl.trim();
          }
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to pick file: $error')));
    }
  }

  void _removeAttachment({required bool isSignature}) {
    setState(() {
      if (isSignature) {
        _signatureBytes = null;
        _signatureName = null;
      } else {
        _profilePictureBytes = null;
        _profilePictureName = null;
      }
    });
  }

  Future<void> _previewAttachment({
    required String title,
    required Uint8List? bytes,
    required String? name,
  }) async {
    if (bytes == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No file selected yet.')));
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 8),
                Text(
                  name ?? 'Selected file',
                  style: const TextStyle(
                    color: kGeneralInfoMutedColor,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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

  Future<void> _loadOrganizationSettings() async {
    try {
      final data = await _apiService.fetchOrganizationSettingsView();
      if (!mounted) return;
      setState(() {
        _applyOrganizationData(data);
      });
    } catch (_) {
      // Keep existing defaults when organization settings cannot be loaded.
    }
  }

  void _applyOrganizationData(Map<String, dynamic> data) {
    final name = _readString(data, 'name');
    final legalName = _readString(data, 'legal_name');
    final businessType = _readString(data, 'business_type');
    final industry = _readString(data, 'industry');
    final dateOfIncorporation = _readString(data, 'date_of_incorporation');
    final cin = _readString(data, 'cin_number');
    final gstinPan = _readString(data, 'gstin_pan');
    final pan = _readString(data, 'pan_number');
    final description = _readString(data, 'description');
    final primaryMobile = _readString(data, 'primary_mobile');
    final alternateMobile = _readString(data, 'alternate_mobile');
    final landline = _readString(data, 'landline');
    final officialEmail = _readString(data, 'email');
    final website = _readString(data, 'website');
    final supportNumber = _readString(data, 'customer_support_number');
    final profilePictureUrl =
        _readString(data, 'auth_person_photo_url') ??
        _readString(data, 'profile_picture_url');
    final registeredAddress =
        _readString(data, 'registered_address') ?? _readString(data, 'address');
    final city = _readString(data, 'city');
    final state = _readString(data, 'state');
    final country = _readString(data, 'country');
    final pinCode = _readString(data, 'pin_code');
    final branchAddress = _readBranchAddress(data);

    if (name != null) {
      _companyNameController.text = name;
      _savedCompanyName = name;
    }
    if (legalName != null) {
      _legalNameController.text = legalName;
      _savedLegalName = legalName;
    }
    if (businessType != null) {
      final matched = _matchOption(kBusinessTypeOptions, businessType);
      if (matched != null) {
        _selectedBusinessType = matched;
      }
      _savedBusinessType = _selectedBusinessType;
    }
    if (industry != null) {
      final matched = _matchOption(kIndustryOptions, industry);
      _selectedIndustry = matched;
      _savedIndustry = _selectedIndustry;
    }
    if (dateOfIncorporation != null) {
      _dateOfIncorporationController.text = dateOfIncorporation;
      _savedDateOfIncorporation = dateOfIncorporation;
    }
    if (cin != null) {
      _cinController.text = cin;
      _savedCin = cin;
    }
    if (gstinPan != null) {
      _gstinController.text = gstinPan;
      _savedGstin = gstinPan;
    }
    if (pan != null) {
      _panController.text = pan;
      _savedPan = pan;
    }
    if (description != null) {
      _descriptionController.text = description;
      _savedDescription = description;
    }
    if (primaryMobile != null) {
      _primaryMobileController.text = primaryMobile;
      _savedPrimaryMobile = primaryMobile;
    }
    if (alternateMobile != null) {
      _alternateMobileController.text = alternateMobile;
      _savedAlternateMobile = alternateMobile;
    }
    if (landline != null) {
      _landlineController.text = landline;
      _savedLandline = landline;
    }
    if (officialEmail != null) {
      _officialEmailController.text = officialEmail;
      _savedOfficialEmail = officialEmail;
    }
    if (website != null) {
      _websiteController.text = website;
      _savedWebsite = website;
    }
    if (supportNumber != null) {
      _supportNumberController.text = supportNumber;
      _savedSupportNumber = supportNumber;
    }
    if (profilePictureUrl != null) {
      _profilePictureUrl = profilePictureUrl;
      _profilePictureName = _extractFileName(profilePictureUrl);
      _loadRemoteBytes(profilePictureUrl).then((bytes) {
        if (!mounted || bytes == null) return;
        setState(() {
          _profilePictureBytes = bytes;
        });
      });
    }
    if (registeredAddress != null) {
      _registeredAddressController.text = registeredAddress;
      _savedRegisteredAddress = registeredAddress;
      _billingAddressController.text = registeredAddress;
      _savedBillingAddress = registeredAddress;
    }
    if (city != null) {
      _cityController.text = city;
      _savedCity = city;
    }
    if (state != null) {
      final matchedState = _matchOption(const [
        'Maharashtra',
        'Gujarat',
        'Karnataka',
        'Delhi',
        'Tamil Nadu',
        'Other',
      ], state);
      if (matchedState != null) {
        _selectedState = matchedState;
      }
      _savedState = _selectedState;
    }
    if (country != null) {
      final matchedCountry = _matchOption(const [
        'India',
        'United States',
        'United Kingdom',
        'UAE',
        'Other',
      ], country);
      if (matchedCountry != null) {
        _selectedCountry = matchedCountry;
      }
      _savedCountry = _selectedCountry;
    }
    if (pinCode != null) {
      _pinCodeController.text = pinCode;
      _savedPinCode = pinCode;
    }
    if (branchAddress != null) {
      _branchOfficeAddressController.text = branchAddress;
      _savedBranchOfficeAddress = branchAddress;
      _shippingAddressController.text = branchAddress;
      _savedShippingAddress = branchAddress;
    }

    final billing = _billingAddressController.text.trim();
    final registered = _registeredAddressController.text.trim();
    _billingSameAsRegistered = billing.isNotEmpty && billing == registered;
    _savedBillingSameAsRegistered = _billingSameAsRegistered;

    final shipping = _shippingAddressController.text.trim();
    _shippingSameAsBilling =
        shipping.isNotEmpty &&
        shipping == _billingAddressController.text.trim();
    _savedShippingSameAsBilling = _shippingSameAsBilling;
    _savedShippingAddress = shipping;
  }

  String? _readString(Map<String, dynamic> data, String key) {
    final value = data[key]?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? _readBranchAddress(Map<String, dynamic> data) {
    final branchAddresses = data['branch_addresses'];
    if (branchAddresses is List && branchAddresses.isNotEmpty) {
      final first = branchAddresses.first;
      if (first is Map<String, dynamic>) {
        return _readString(first, 'address');
      }
    }
    return _readString(data, 'branch_address');
  }

  String? _matchOption(List<String> options, String value) {
    for (final option in options) {
      if (option.trim().toLowerCase() == value.trim().toLowerCase()) {
        return option;
      }
    }
    return null;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: _actionButton(),
              ),
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
                            onTap: () => setState(
                              () => _basicExpanded = !_basicExpanded,
                            ),
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
                                                () => _selectedBusinessType =
                                                    value,
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
                            title: 'Authorized Person',
                            subtitle:
                                'Authorized representative contact and identity.',
                            expanded: _authorizedExpanded,
                            onTap: () => setState(
                              () => _authorizedExpanded = !_authorizedExpanded,
                            ),
                            child: _authorizedExpanded
                                ? _EditableAbsorbPointer(
                                    enabled: _isEditing,
                                    child: Column(
                                      children: [
                                        _ResponsiveFields(
                                          isWide: isWide,
                                          children: [
                                            _fieldBlock(
                                              label: 'Owner/Director Name *',
                                              child: _textField(
                                                controller:
                                                    _authorizedNameController,
                                              ),
                                            ),
                                            _fieldBlock(
                                              label: 'Designation *',
                                              child: _dropdownField<String>(
                                                value:
                                                    _designationController.text,
                                                hintText: 'Select designation',
                                                items: _designationOptions,
                                                onChanged: (value) {
                                                  if (value == null) return;
                                                  setState(
                                                    () =>
                                                        _designationController
                                                                .text =
                                                            value,
                                                  );
                                                },
                                              ),
                                            ),
                                            _fieldBlock(
                                              label: 'Mobile Number *',
                                              child: _textField(
                                                controller:
                                                    _authorizedMobileController,
                                                keyboardType:
                                                    TextInputType.phone,
                                              ),
                                            ),
                                            _fieldBlock(
                                              label: 'Email *',
                                              child: _textField(
                                                controller:
                                                    _authorizedEmailController,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                        _ResponsiveFields(
                                          isWide: isWide,
                                          children: [
                                            _attachmentCard(
                                              title: 'Profile Picture',
                                              subtitle:
                                                  _profilePictureName ??
                                                  'Tap upload to select a photo',
                                              previewBytes:
                                                  _profilePictureBytes,
                                              previewName: _profilePictureName,
                                              previewLabel: 'Preview',
                                              uploadLabel: 'Upload Photo',
                                              onPreview: () =>
                                                  _previewAttachment(
                                                    title: 'Profile Picture',
                                                    bytes: _profilePictureBytes,
                                                    name: _profilePictureName,
                                                  ),
                                              onUpload: () => _pickAttachment(
                                                isSignature: false,
                                              ),
                                              onRemove: () => _removeAttachment(
                                                isSignature: false,
                                              ),
                                            ),
                                            _attachmentCard(
                                              title: 'Digital Signature',
                                              subtitle:
                                                  _signatureName ??
                                                  'Tap upload to select a signature',
                                              previewBytes: _signatureBytes,
                                              previewName: _signatureName,
                                              previewLabel: 'Preview',
                                              uploadLabel: 'Upload Signature',
                                              onPreview: () =>
                                                  _previewAttachment(
                                                    title: 'Digital Signature',
                                                    bytes: _signatureBytes,
                                                    name: _signatureName,
                                                  ),
                                              onUpload: () => _pickAttachment(
                                                isSignature: true,
                                              ),
                                              onRemove: () => _removeAttachment(
                                                isSignature: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 18),
                          _GeneralInfoSectionCard(
                            number: '3',
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
                                            controller:
                                                _primaryMobileController,
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
                                            controller:
                                                _officialEmailController,
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
                                            controller:
                                                _supportNumberController,
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
                            number: '4',
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
                                                    () =>
                                                        _selectedState = value,
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
                                            controller:
                                                _billingAddressController,
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
                                                _shippingAddressController
                                                        .text =
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

  Widget _actionButton() {
    final editing = _isEditing;
    return ElevatedButton.icon(
      onPressed: () async {
        if (editing) {
          await _saveSettings();
          return;
        }
        setState(() => _isEditing = true);
      },
      icon: Icon(editing ? Icons.save_outlined : Icons.edit_outlined, size: 18),
      label: Text(editing ? 'Save' : 'Edit'),
      style: ElevatedButton.styleFrom(
        backgroundColor: editing
            ? kGeneralInfoAccentColor
            : const Color(0xFFF3F4F6),
        foregroundColor: editing ? Colors.white : kGeneralInfoTitleColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    );
  }

  Future<void> _saveSettings() async {
    try {
      final payload = <String, dynamic>{};
      _putIfNotBlank(payload, 'name', _companyNameController.text);
      _putIfNotBlank(payload, 'legal_name', _legalNameController.text);
      _putIfNotBlank(payload, 'business_type', _selectedBusinessType);
      _putIfNotBlank(payload, 'industry', _selectedIndustry);
      _putIfNotBlank(
        payload,
        'date_of_incorporation',
        _dateOfIncorporationController.text,
      );
      _putIfNotBlank(payload, 'cin_number', _cinController.text);
      _putIfNotBlank(payload, 'gstin_pan', _gstinController.text);
      _putIfNotBlank(payload, 'pan_number', _panController.text);
      _putIfNotBlank(payload, 'description', _descriptionController.text);
      _putIfNotBlank(payload, 'primary_mobile', _primaryMobileController.text);
      _putIfNotBlank(payload, 'auth_person_photo_url', _profilePictureUrl);
      _putIfNotBlank(
        payload,
        'alternate_mobile',
        _alternateMobileController.text,
      );
      _putIfNotBlank(payload, 'landline', _landlineController.text);
      _putIfNotBlank(payload, 'email', _officialEmailController.text);
      _putIfNotBlank(payload, 'website', _websiteController.text);
      _putIfNotBlank(
        payload,
        'customer_support_number',
        _supportNumberController.text,
      );
      _putIfNotBlank(payload, 'address', _registeredAddressController.text);
      _putIfNotBlank(
        payload,
        'registered_address',
        _registeredAddressController.text,
      );
      _putIfNotBlank(payload, 'city', _cityController.text);
      _putIfNotBlank(payload, 'state', _selectedState);
      _putIfNotBlank(payload, 'country', _selectedCountry);
      _putIfNotBlank(payload, 'pin_code', _pinCodeController.text);

      final branchAddress = _branchOfficeAddressController.text.trim();
      if (branchAddress.isNotEmpty) {
        payload['branch_addresses'] = [
          <String, dynamic>{
            'label': 'Branch Office',
            'address': branchAddress,
            'city': _cityController.text.trim(),
            'state': _selectedState,
            'country': _selectedCountry,
            'pin_code': _pinCodeController.text.trim(),
          },
        ];
      }

      await _apiService.updateOrganizationSettings(
        request: OrganizationSettingsRequest(fields: payload),
      );

      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Changes saved.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save changes: $error')));
    }
  }

  void _putIfNotBlank(Map<String, dynamic> payload, String key, String? value) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      payload[key] = trimmed;
    }
  }

  String _extractFileName(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.pathSegments.isEmpty) return url;
    return uri.pathSegments.last;
  }

  Future<Uint8List?> _loadRemoteBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      }
    } catch (_) {
      // Ignore preview loading failures.
    }
    return null;
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
      icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF98A2B3)),
      hint: hintText == null
          ? null
          : Text(hintText, style: const TextStyle(color: Color(0xFFB5BCC6))),
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
      hintStyle: const TextStyle(color: Color(0xFFB5BCC6), fontSize: 15),
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

  Widget _attachmentCard({
    required String title,
    required String subtitle,
    required Uint8List? previewBytes,
    required String? previewName,
    required String previewLabel,
    required String uploadLabel,
    required VoidCallback onPreview,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE3EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 120,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Center(
                  child: previewBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            previewBytes,
                            width: 100,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.upload_file_outlined,
                          color: Color(0xFF94A3B8),
                          size: 28,
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: kGeneralInfoTitleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: kGeneralInfoMutedColor,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _attachmentButton(
                          label: previewBytes != null
                              ? previewLabel
                              : uploadLabel,
                          icon: previewBytes != null
                              ? Icons.remove_red_eye_outlined
                              : Icons.upload_outlined,
                          active: true,
                          onPressed: previewBytes != null
                              ? onPreview
                              : onUpload,
                        ),
                        _attachmentButton(
                          label: 'Remove',
                          icon: Icons.delete_outline_rounded,
                          active: previewBytes != null,
                          onPressed: onRemove,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _attachmentButton({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: active ? onPressed : null,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: active
            ? kGeneralInfoTitleColor
            : const Color(0xFF98A2B3),
        side: BorderSide(
          color: active ? const Color(0xFFD1D5DB) : const Color(0xFFE5E7EB),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
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
          if (expanded) ...[const SizedBox(height: 18), child],
        ],
      ),
    );
  }
}

class _ResponsiveFields extends StatelessWidget {
  final bool isWide;
  final List<Widget> children;

  const _ResponsiveFields({required this.isWide, required this.children});

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

  const _EditableAbsorbPointer({required this.enabled, required this.child});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(absorbing: !enabled, child: child);
  }
}
