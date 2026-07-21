import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Anita Sharma');
    _emailController = TextEditingController(text: 'admin@demo.com');
    _phoneController = TextEditingController(text: '+91 98220 33445');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Profile',
              leadingIcon: Icons.arrow_back_rounded,
              onLeadingTap: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your account details',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildFormCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return _CardContainer(
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary),
            ),
            alignment: Alignment.center,
            child: const Text(
              'AS',
              style: TextStyle(
                color: AppColors.purple,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _nameController.text,
            style: const TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Admin',
              style: TextStyle(
                color: AppColors.purple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return _CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Details',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _fieldLabel('Full Name'),
          _inputField(controller: _nameController, icon: Icons.person_outline),
          const SizedBox(height: 16),
          _fieldLabel('Email'),
          _inputField(
            controller: _emailController,
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _fieldLabel('Phone'),
          _inputField(
            controller: _phoneController,
            icon: Icons.call_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.primary,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20, color: textSecondary),
        filled: true,
        fillColor: AppColors.surfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.24)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.secondary.withValues(alpha: 0.24)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.purple),
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;

  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
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
}
