import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants/app_colors.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/admin/app_drawer.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _companyNameController = TextEditingController(
    text: 'SAAS Distributors',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'info@saasdistributors.com',
  );
  final TextEditingController _phoneController = TextEditingController(
    text: '+91 9876543210',
  );
  final TextEditingController _gstinController = TextEditingController(
    text: '27AABCU9603R1ZX',
  );
  final TextEditingController _addressController = TextEditingController(
    text: '123 Main Street, Business District',
  );
  final TextEditingController _cityController = TextEditingController(
    text: 'Mumbai',
  );
  final TextEditingController _stateController = TextEditingController(
    text: 'Maharashtra',
  );
  final TextEditingController _pincodeController = TextEditingController(
    text: '400001',
  );
  final TextEditingController _adminNameController = TextEditingController(
    text: 'asdsfdaf',
  );
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _billingAddressController = TextEditingController(
    text: 'rwqyenebggbth',
  );
  final TextEditingController _shippingAddressController =
      TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _invoicePrefixController =
      TextEditingController();

  Uint8List? _profilePhotoBytes;
  String? _profilePhotoName;
  bool _isSaving = false;
  bool _passwordVisible = false;
  bool _shippingSameAsBilling = false;
  bool _adminDetailsExpanded = true;
  bool _organizationDetailsExpanded = true;
  bool _businessDetailsExpanded = true;
  int _selectedBottomNavIndex = 0;
  String? _selectedBusinessType;
  String _selectedFinancialYear = '2025-2026';

  static const List<String> _businessTypes = [
    'Sole Proprietorship',
    'Partnership',
    'Private Limited',
    'LLP',
  ];
  static const List<String> _financialYears = [
    '2024-2025',
    '2025-2026',
    '2026-2027',
  ];

  static const List<_CompanySettingsNavItem> _bottomNavItems = [
    _CompanySettingsNavItem(
      label: 'General Information',
      icon: Icons.business_outlined,
    ),
    _CompanySettingsNavItem(
      label: 'Notifications',
      icon: Icons.notifications_none_rounded,
    ),
    _CompanySettingsNavItem(label: 'Account', icon: Icons.person_outline),
    _CompanySettingsNavItem(
      label: 'Account Manager',
      icon: Icons.group_outlined,
    ),
    _CompanySettingsNavItem(
      label: 'Billings',
      icon: Icons.credit_card_outlined,
    ),
    _CompanySettingsNavItem(
      label: 'Support',
      icon: Icons.support_agent_outlined,
    ),
  ];

  static const Color _pageBg = AppColors.background;

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _adminNameController.dispose();
    _passwordController.dispose();
    _panController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    _websiteController.dispose();
    _invoicePrefixController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
      );
      if (picked == null || !mounted) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      setState(() {
        _profilePhotoBytes = bytes;
        _profilePhotoName = picked.name;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to upload profile picture: $error')),
      );
    }
  }

  void _removeProfilePhoto() {
    setState(() {
      _profilePhotoBytes = null;
      _profilePhotoName = null;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _pageBg,
      drawer: const AppDrawer(activeItem: 'Company Settings'),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AdminTopBar(
                  title: 'Company Settings',
                  leadingIcon: Icons.menu_rounded,
                  onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 160),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_buildSettingsShell()],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: _buildBottomNavigationBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.activeMenuBg.withValues(alpha: 0.55),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary950.withValues(alpha: 0.20),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var index = 0; index < _bottomNavItems.length; index++)
              Expanded(
                child: _CompanySettingsBottomNavButton(
                  item: _bottomNavItems[index],
                  selected: _selectedBottomNavIndex == index,
                  onTap: () {
                    setState(() => _selectedBottomNavIndex = index);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsShell() {
    switch (_bottomNavItems[_selectedBottomNavIndex].label) {
      case 'Notifications':
        return _buildSimpleSettingsPanel(
          title: 'Notifications',
          subtitle: 'Manage company alerts and communication settings.',
        );
      case 'Account':
        return _buildSimpleSettingsPanel(
          title: 'Account',
          subtitle: 'Manage account details and user preferences.',
        );
      case 'Account Manager':
        return _buildSimpleSettingsPanel(
          title: 'Account Manager',
          subtitle: 'Manage account manager details and assignments.',
        );
      case 'Billings':
        return _buildSimpleSettingsPanel(
          title: 'Billings',
          subtitle: 'Manage billing preferences and payment settings.',
        );
      case 'Support':
        return _buildSimpleSettingsPanel(
          title: 'Support',
          subtitle: 'Manage support contacts and assistance settings.',
        );
      default:
        return _buildMainPanel();
    }
  }

  Widget _buildSimpleSettingsPanel({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        const Divider(color: AppColors.border),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'General Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Update public company details used across invoices and reports.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border),
          const SizedBox(height: 10),
          _buildLogoSummary(),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          _buildSectionHeader(
            number: 1,
            title: 'Admin Details',
            subtitle: 'Manage primary admin registration details.',
            expanded: _adminDetailsExpanded,
            onTap: () {
              setState(() => _adminDetailsExpanded = !_adminDetailsExpanded);
            },
          ),
          if (_adminDetailsExpanded) ...[
            const SizedBox(height: 12),
            _buildSectionTitle('Admin Registration'),
            const SizedBox(height: 12),
            _settingField(
              label: 'Admin Name',
              controller: _adminNameController,
            ),
            const SizedBox(height: 12),
            _settingField(
              label: 'Email Address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _settingField(
              label: 'Password',
              controller: _passwordController,
              obscureText: !_passwordVisible,
              hintText: 'Enter your password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() => _passwordVisible = !_passwordVisible);
                },
                icon: Icon(
                  _passwordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textLightMuted,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _settingField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border),
          ],
          const SizedBox(height: 12),
          _buildSectionHeader(
            number: 2,
            title: 'Organization Details',
            subtitle: 'Update business identity and tax details.',
            expanded: _organizationDetailsExpanded,
            onTap: () {
              setState(
                () => _organizationDetailsExpanded =
                    !_organizationDetailsExpanded,
              );
            },
          ),
          if (_organizationDetailsExpanded) ...[
            const SizedBox(height: 12),
            _settingField(
              label: 'Company/Firm/Shop Name',
              controller: _companyNameController,
            ),
            const SizedBox(height: 12),
            _dropdownField<String>(
              label: 'Business Type',
              value: _selectedBusinessType,
              hintText: 'Select business type',
              items: _businessTypes,
              onChanged: (value) {
                setState(() => _selectedBusinessType = value);
              },
            ),
            const SizedBox(height: 12),
            _settingField(label: 'GST Number', controller: _gstinController),
            const SizedBox(height: 12),
            _settingField(
              label: 'PAN Number (if applicable)',
              controller: _panController,
            ),
            const SizedBox(height: 12),
            _dropdownField<String>(
              label: 'Financial Year',
              value: _selectedFinancialYear,
              items: _financialYears,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedFinancialYear = value);
              },
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border),
          ],
          const SizedBox(height: 12),
          _buildSectionHeader(
            number: 3,
            title: 'Business Details',
            subtitle: 'Manage billing, shipping, and invoice settings.',
            expanded: _businessDetailsExpanded,
            onTap: () {
              setState(
                () => _businessDetailsExpanded = !_businessDetailsExpanded,
              );
            },
          ),
          if (_businessDetailsExpanded) ...[
            const SizedBox(height: 12),
            _settingField(
              label: 'Billing Address',
              controller: _billingAddressController,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                setState(() {
                  _shippingSameAsBilling = !_shippingSameAsBilling;
                  if (_shippingSameAsBilling) {
                    _shippingAddressController.text =
                        _billingAddressController.text;
                  }
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Checkbox(
                    visualDensity: VisualDensity.compact,
                    value: _shippingSameAsBilling,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _shippingSameAsBilling = value ?? false;
                        if (_shippingSameAsBilling) {
                          _shippingAddressController.text =
                              _billingAddressController.text;
                        }
                      });
                    },
                  ),
                  const Expanded(
                    child: Text(
                      'Shipping/Warehouse address same as billing address',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _settingField(
              label: 'Shipping/Warehouse Address',
              controller: _shippingAddressController,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            _settingField(
              label: 'Website (if applicable)',
              controller: _websiteController,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            _settingField(
              label: 'Invoice Prefix',
              controller: _invoicePrefixController,
              hintText: 'e.g. INV',
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceSoft,
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: _profilePhotoBytes == null
                  ? const Icon(
                      Icons.business_outlined,
                      color: AppColors.primary,
                      size: 26,
                    )
                  : Image.memory(_profilePhotoBytes!, fit: BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _companyNameController.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _profilePhotoName ?? 'Business logo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Mumbai, Maharashtra',
                    style: TextStyle(
                      color: AppColors.textLightMuted,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: _pickProfilePhoto,
              icon: const Icon(Icons.upload_rounded, size: 16),
              label: const Text('Upload New Logo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 10,
                shadowColor: AppColors.primary.withValues(alpha: 0.22),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _profilePhotoBytes == null
                  ? null
                  : _removeProfilePhoto,
              icon: const Icon(Icons.delete_outline_rounded, size: 16),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required int number,
    required String title,
    required String subtitle,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        DropdownButtonFormField<T>(
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          initialValue: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textLightMuted,
          ),
          hint: hintText == null
              ? null
              : Text(
                  hintText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLightMuted,
                  ),
                ),
          decoration: _inputDecoration(),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    '$item',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
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

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _settingField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hintText,
    bool obscureText = false,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        TextFormField(
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          minLines: maxLines > 1 ? maxLines : 1,
          decoration: _inputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceSoft,
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textLightMuted),
      suffixIcon: suffixIcon,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderStrong),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }
}

class _CompanySettingsNavItem {
  final String label;
  final IconData icon;

  const _CompanySettingsNavItem({required this.label, required this.icon});
}

class _CompanySettingsBottomNavButton extends StatelessWidget {
  final _CompanySettingsNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _CompanySettingsBottomNavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const color = Colors.white;

    return Tooltip(
      message: item.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(item.icon, size: 22, color: color),
                  if (selected)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.activeMenuBg.withValues(alpha: 0.95),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(999),
                          ),
                        ),
                        child: const SizedBox(height: 2),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
