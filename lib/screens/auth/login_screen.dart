import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../dashboard/admin_dashboard_screen.dart';

// Place this file at: lib/screens/auth/login_screen.dart

class _DemoRole {
  final String label;
  final String email;
  final IconData icon;

  const _DemoRole({required this.label, required this.email, required this.icon});
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _showRoleSuggestions = false;

  static const Color primaryPurple = Color(0xFF6C4EE3);
  static const Color darkText = AppColors.textPrimary;
  static const Color greyText = AppColors.textSecondary;
  static const Color fieldBorder = AppColors.secondary;
  static const Color fieldFill = AppColors.primary;

  // Update these to match your own demo/test accounts.
  static const List<_DemoRole> _demoRoles = [
    _DemoRole(label: 'Super Admin', email: 'superadmin@demo.com', icon: Icons.shield_outlined),
    _DemoRole(label: 'Admin', email: 'admin@demo.com', icon: Icons.admin_panel_settings_outlined),
    _DemoRole(label: 'Sales Officer', email: 'sales@demo.com', icon: Icons.groups_outlined),
    _DemoRole(label: 'Delivery Partner', email: 'delivery@demo.com', icon: Icons.local_shipping_outlined),
    _DemoRole(label: 'Accountant', email: 'accountant@demo.com', icon: Icons.account_balance_wallet_outlined),
    _DemoRole(label: 'Warehouse Manager', email: 'warehouse@demo.com', icon: Icons.warehouse_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        setState(() => _showRoleSuggestions = true);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _selectRole(_DemoRole role) {
    setState(() {
      _emailController.text = role.email;
      _showRoleSuggestions = false;
    });
    _emailFocusNode.unfocus();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final email = _emailController.text.trim().toLowerCase();

    if (email == 'admin@demo.com') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        // Tapping outside the email field closes the role dropdown.
        onTap: () {
          if (_showRoleSuggestions) {
            setState(() => _showRoleSuggestions = false);
            _emailFocusNode.unfocus();
          }
        },
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            // Top-right faint concentric circles

            builder: (context, constraints) {
              final content = Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                          // Logo icon
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: primaryPurple.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primaryPurple, width: 2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.insert_chart_rounded,
                                  color: primaryPurple,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sign in to continue to your account',
                            style: TextStyle(fontSize: 15, color: greyText),
                          ),

                          const SizedBox(height: 28),

                          // Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email or Phone',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: darkText,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Email field + role suggestions dropdown
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTextField(
                                      controller: _emailController,
                                      focusNode: _emailFocusNode,
                                      hint: 'Enter your email or phone number',
                                      icon: Icons.person_outline,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _showRoleSuggestions
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: primaryPurple,
                                        ),
                                        onPressed: () {
                                          setState(() => _showRoleSuggestions = !_showRoleSuggestions);
                                          if (_showRoleSuggestions) {
                                            _emailFocusNode.requestFocus();
                                          }
                                        },
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'Please enter your email or phone';
                                        }
                                        return null;
                                      },
                                    ),
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 180),
                                      curve: Curves.easeOut,
                                      child: _showRoleSuggestions
                                          ? _buildRoleDropdown()
                                          : const SizedBox(width: double.infinity),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: darkText,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _passwordController,
                                  hint: 'Enter your password',
                                  icon: Icons.lock_outline,
                                  obscureText: _obscurePassword,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: primaryPurple,
                                    ),
                                    onPressed: () {
                                      setState(() => _obscurePassword = !_obscurePassword);
                                    },
                                  ),
                                ),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Navigator.pushNamed(context, '/forgot-password');
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: primaryPurple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Sign In button
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleSignIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              color: AppColors.primary,
                                              strokeWidth: 2.4,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  color: AppColors.primary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.arrow_forward, color: AppColors.primary, size: 20),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(color: greyText, fontSize: 13),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigator.pushNamed(context, '/contact-admin');
                                  },
                                  child: const Text(
                                    'Contact Admin',
                                    style: TextStyle(
                                      color: primaryPurple,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (_showRoleSuggestions) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: content,
                    );
                  }

                  return ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: content,
                  );
                },
              ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Scrollbar(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: _demoRoles.length,
            separatorBuilder: (_, index) => const Divider(height: 1, color: fieldFill),
            itemBuilder: (context, index) {
              final role = _demoRoles[index];
              return InkWell(
                onTap: () => _selectRole(role),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: primaryPurple.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(role.icon, color: primaryPurple, size: 19),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: darkText,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              role.email,
                              style: const TextStyle(color: greyText, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    FocusNode? focusNode,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: darkText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: greyText, fontSize: 14),
        prefixIcon: Icon(icon, color: primaryPurple),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryPurple, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
