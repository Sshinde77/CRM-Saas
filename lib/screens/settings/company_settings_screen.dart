import 'package:flutter/material.dart';

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

  bool _isSaving = false;

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
                    const Text(
                      'Company Settings',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage your company information and preferences',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      child: Column(
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
                          const SizedBox(height: 24),
                          _buildFieldRow(
                            leftLabel: 'Company Name',
                            leftField: _textField(
                              controller: _companyNameController,
                            ),
                            rightLabel: 'Email',
                            rightField: _textField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFieldRow(
                            leftLabel: 'Phone',
                            leftField: _textField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            rightLabel: 'GSTIN',
                            rightField: _textField(
                              controller: _gstinController,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildFieldRow(
                            leftLabel: 'Address',
                            leftField: _textField(
                              controller: _addressController,
                            ),
                            rightLabel: 'City',
                            rightField: _textField(controller: _cityController),
                          ),
                          const SizedBox(height: 20),
                          _buildFieldRow(
                            leftLabel: 'State',
                            leftField: _textField(controller: _stateController),
                            rightLabel: 'Pincode',
                            rightField: _textField(
                              controller: _pincodeController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 220,
                              child: SoftActionButton(
                                label: _isSaving ? 'Saving...' : 'Save Changes',
                                icon: Icons.save_outlined,
                                onPressed: _isSaving ? null : _handleSave,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow({
    required String leftLabel,
    required Widget leftField,
    required String rightLabel,
    required Widget rightField,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fieldLabel(leftLabel),
              leftField,
              const SizedBox(height: 16),
              _fieldLabel(rightLabel),
              rightField,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_fieldLabel(leftLabel), leftField],
              ),
            ),
            const SizedBox(width: 28),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_fieldLabel(rightLabel), rightField],
              ),
            ),
          ],
        );
      },
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

  Widget _textField({
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _inputDecoration(),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.14)),
      ),
      child: child,
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
