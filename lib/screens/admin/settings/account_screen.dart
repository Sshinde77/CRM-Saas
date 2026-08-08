// ignore_for_file: unused_field, unused_element, prefer_final_fields

import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/auth_models.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import 'company_settings_constants.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  static const Color _titleColor = Color(0xFF0F172A);
  static const Color _mutedColor = Color(0xFF64748B);
  static const Color _cardBg = Colors.white;
  static const Color _accent = Color(0xFF0B4D08);
  final ApiService _apiService = ApiService();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _legalNameController = TextEditingController(
    text: 'lol',
  );
  final TextEditingController _ownerController = TextEditingController(
    text: 'Sushil',
  );
  final TextEditingController _mobileController = TextEditingController(
    text: '9986547856',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'testing@gmail.com',
  );

  String? _selectedIndustry;
  String _selectedStatus = 'Active';
  String _selectedDesignation = 'Admin';
  String _savedLegalName = 'lol';
  String _savedOwnerName = 'Sushil';
  String _savedMobileNumber = '9986547856';
  String _savedEmail = 'testing@gmail.com';
  String? _savedIndustry;
  String _savedStatus = 'Active';
  String _savedDesignation = 'Admin';
  bool _isEditing = false;
  bool _accountDetailsExpanded = true;
  bool _authorizedPersonExpanded = true;
  final List<String> _statusOptions = const [
    'Active',
    'Inactive',
    'Suspended',
    'Locked',
  ];
  final List<String> _designationOptions = const [
    'Owner',
    'Director',
    'Admin',
    'Manager',
    'Accountant',
    'Sales Officer',
  ];

  @override
  void dispose() {
    _legalNameController.dispose();
    _ownerController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
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
              title: 'Account',
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _SectionCard(
                    number: 1,
                    title: 'Account Details',
                    subtitle: 'Company account classification and status.',
                    expanded: _accountDetailsExpanded,
                    onToggle: () {
                      setState(
                        () =>
                            _accountDetailsExpanded = !_accountDetailsExpanded,
                      );
                    },
                    child: _accountDetailsExpanded
                        ? Column(
                            children: [
                              _fieldBlock(
                                label: 'Legal Name',
                                child: _textField(
                                  controller: _legalNameController,
                                  enabled: _isEditing,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _fieldBlock(
                                label: 'Industry',
                                child: _dropdownField(
                                  value: _selectedIndustry,
                                  hintText: 'Select industry',
                                  items: kIndustryOptions,
                                  enabled: _isEditing,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _selectedIndustry = value);
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              _fieldBlock(
                                label: 'Status',
                                child: _dropdownField(
                                  value: _selectedStatus,
                                  items: _statusOptions,
                                  enabled: _isEditing,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _selectedStatus = value);
                                  },
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 18),
                  _SectionCard(
                    number: 2,
                    title: 'Authorized Person',
                    subtitle: 'Authorized representative contact and identity.',
                    expanded: _authorizedPersonExpanded,
                    onToggle: () {
                      setState(
                        () => _authorizedPersonExpanded =
                            !_authorizedPersonExpanded,
                      );
                    },
                    child: _authorizedPersonExpanded
                        ? Column(
                            children: [
                              _fieldBlock(
                                label: 'Owner/Director Name',
                                child: _textField(
                                  controller: _ownerController,
                                  enabled: _isEditing,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _fieldBlock(
                                label: 'Designation',
                                child: _dropdownField(
                                  value: _selectedDesignation,
                                  items: _designationOptions,
                                  enabled: _isEditing,
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(
                                      () => _selectedDesignation = value,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              _fieldBlock(
                                label: 'Mobile Number',
                                child: _textField(
                                  controller: _mobileController,
                                  keyboardType: TextInputType.phone,
                                  enabled: _isEditing,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _fieldBlock(
                                label: 'Email',
                                child: _textField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: _isEditing,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldBlock({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              color: _titleColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        child,
      ],
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
        backgroundColor: editing ? _accent : const Color(0xFFF3F4F6),
        foregroundColor: editing ? Colors.white : _titleColor,
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
      _putIfNotBlank(payload, 'legal_name', _legalNameController.text);
      _putIfNotBlank(payload, 'industry', _selectedIndustry);
      _putIfNotBlank(payload, 'auth_person_name', _ownerController.text);
      _putIfNotBlank(payload, 'auth_person_designation', _selectedDesignation);
      _putIfNotBlank(payload, 'auth_person_mobile', _mobileController.text);
      _putIfNotBlank(payload, 'auth_person_email', _emailController.text);
      _putIfNotBlank(payload, 'company_status', _selectedStatus);

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

  Widget _textField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool enabled = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: const TextStyle(fontSize: 15, color: _titleColor),
      decoration: _fieldDecoration(),
    );
  }

  Widget _dropdownField<T>({
    T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    bool enabled = false,
    String? hintText,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      onChanged: enabled ? onChanged : null,
      isExpanded: true,
      menuMaxHeight: 260,
      icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF98A2B3)),
      hint: hintText == null
          ? null
          : Text(hintText, style: const TextStyle(color: Color(0xFF98A2B3))),
      style: const TextStyle(fontSize: 15, color: _titleColor),
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
                  color: _titleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: _cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD8DFD8), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD8DFD8), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _accent, width: 2),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _SectionCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE3EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
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
                      '$number',
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
                            color: _AccountScreenState._titleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: _AccountScreenState._mutedColor,
                            fontSize: 13,
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
          if (expanded) ...[const SizedBox(height: 20), child],
        ],
      ),
    );
  }
}
