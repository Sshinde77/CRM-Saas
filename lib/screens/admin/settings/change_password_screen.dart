import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../models/auth_models.dart';
import '../../../services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const Color _titleColor = Color(0xFF0F172A);
  static const Color _mutedColor = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFDDE3EA);
  static const Color _fieldBg = Colors.white;
  static const Color _accent = Color(0xFF0B4D08);

  final ApiService _apiService = ApiService();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _saving = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final current = _currentPasswordController.text.trim();
    final next = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all password fields')),
      );
      return;
    }

    if (next != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password and confirm password do not match'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _apiService.changePassword(
        request: ChangePasswordRequest(
          currentPassword: current,
          newPassword: next,
        ),
      );

      if (!mounted) return;

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change password: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 780;
            final contentWidth = constraints.maxWidth > 1200
                ? 1200.0
                : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(26, 38, 26, 34),
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(
                        color: _titleColor,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Update the admin account password.',
                      style: TextStyle(
                        color: _mutedColor,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1, thickness: 1, color: _borderColor),
                    const SizedBox(height: 24),
                    _fieldBlock(
                      label: 'Current Password *',
                      child: _passwordField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        hintText: 'Enter current password',
                        onToggleVisibility: () {
                          setState(() => _obscureCurrent = !_obscureCurrent);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ResponsivePasswordRow(
                      isWide: isWide,
                      children: [
                        _fieldBlock(
                          label: 'New Password',
                          child: _passwordField(
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            hintText: 'Enter new password',
                            onToggleVisibility: () {
                              setState(() => _obscureNew = !_obscureNew);
                            },
                          ),
                        ),
                        _fieldBlock(
                          label: 'Confirm Password',
                          child: _passwordField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            hintText: 'Confirm new password',
                            onToggleVisibility: () {
                              setState(
                                () => _obscureConfirm = !_obscureConfirm,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _handleChangePassword,
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.vpn_key_outlined, size: 18),
                          label: Text(
                            _saving ? 'Changing...' : 'Change Password',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            elevation: 6,
                            shadowColor: Colors.black.withValues(alpha: 0.22),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _fieldBlock({required String label, required Widget child}) {
    final hasRequiredMark = label.endsWith(' *');
    final cleanLabel = hasRequiredMark ? label.replaceAll(' *', '') : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: hasRequiredMark
              ? RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: _titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [
                      TextSpan(text: cleanLabel),
                      const TextSpan(
                        text: ' *',
                        style: TextStyle(color: Color(0xFFEF4444)),
                      ),
                    ],
                  ),
                )
              : Text(
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

  Widget _passwordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15, color: _titleColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: _fieldBg,
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 15),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borderColor, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _accent, width: 1.8),
        ),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 20,
            color: const Color(0xFF98A2B3),
          ),
        ),
      ),
    );
  }
}

class _ResponsivePasswordRow extends StatelessWidget {
  final bool isWide;
  final List<Widget> children;

  const _ResponsivePasswordRow({required this.isWide, required this.children});

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
    final itemWidth = (width > 1200 ? 1200 : width) / 2 - 22;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: children
          .map((child) => SizedBox(width: itemWidth, child: child))
          .toList(),
    );
  }
}
