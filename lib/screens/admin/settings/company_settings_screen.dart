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

  Uint8List? _profilePhotoBytes;
  String? _profilePhotoName;
  bool _isSaving = false;

  static const Color _pageBg = Color(0xFFF3EDF9);

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
                    _buildSettingsShell(),
                  ],
                ),
              ),
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
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsShell() {
    return _buildMainPanel();
  }

  Widget _buildMainPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 720;
              final header = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Company Settings',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Manage your company credentials, branding, and contact details.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              );

              final actions = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).maybePop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header,
                    const SizedBox(height: 14),
                    actions,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: header),
                  const SizedBox(width: 16),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _buildProfileUploadCard(),
          const SizedBox(height: 18),
          _buildSectionTitle('Organization Information'),
          const SizedBox(height: 16),
          _buildFieldGrid(
            children: [
              _settingField(
                label: 'Company Name',
                controller: _companyNameController,
              ),
              _settingField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              _settingField(
                label: 'Phone',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              _settingField(
                label: 'GSTIN',
                controller: _gstinController,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSectionTitle('Address'),
          const SizedBox(height: 16),
          _buildFieldGrid(
            children: [
              _settingField(label: 'Address', controller: _addressController),
              _settingField(label: 'City', controller: _cityController),
              _settingField(label: 'State', controller: _stateController),
              _settingField(
                label: 'Pincode',
                controller: _pincodeController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildProfileUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.12)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 520;
          final preview = Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.25)),
            ),
            clipBehavior: Clip.antiAlias,
            child: _profilePhotoBytes == null
                ? const Icon(
                    Icons.person_rounded,
                    color: AppColors.secondary,
                    size: 34,
                  )
                : Image.memory(_profilePhotoBytes!, fit: BoxFit.cover),
          );

          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile picture upload',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _profilePhotoName ?? 'Upload a company logo or profile image',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.2,
                ),
              ),
            ],
          );

          final buttons = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: _pickProfilePhoto,
                icon: const Icon(Icons.upload_rounded, size: 18),
                label: const Text('Upload New Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: _profilePhotoBytes == null ? null : _removeProfilePhoto,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    preview,
                    const SizedBox(width: 14),
                    Expanded(child: info),
                  ],
                ),
                const SizedBox(height: 14),
                buttons,
              ],
            );
          }

          return Row(
            children: [
              preview,
              const SizedBox(width: 14),
              Expanded(child: info),
              const SizedBox(width: 14),
              buttons,
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildFieldGrid({required List<Widget> children}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 840 ? 2 : 1;
        if (columns == 1) {
          return Column(
            children: [
              for (final child in children) ...[
                child,
                if (child != children.last) const SizedBox(height: 16),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (var i = 0; i < children.length; i += 2) ...[
              Row(
                children: [
                  Expanded(child: children[i]),
                  const SizedBox(width: 16),
                  Expanded(child: children[i + 1]),
                ],
              ),
              if (i + 2 < children.length) const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }

  Widget _settingField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.surfaceSoft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.secondary.withValues(alpha: 0.16),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.secondary.withValues(alpha: 0.16),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.secondary),
      ),
    );
  }
}

