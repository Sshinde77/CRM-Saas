import 'package:flutter/material.dart';

import '../dashboard/admin_dashboard_screen.dart';
import '../../services/api_service.dart';
import 'register_screen.dart';

// Place this file at: lib/screens/auth/login_screen.dart
//
// v4: same fields/logic as v3 (role picker, email/phone tabs, country code
// picker, password visibility toggle, social buttons, register link) but
// restyled as a soft rounded "gradient card" — inspired by the Uiverse.io
// login card (Smit-Prajapati) — with a light blue/white gradient background,
// 40px rounded card corners, pill-shaped inputs with a soft cyan glow, and a
// blue-to-cyan gradient sign-in button.

enum UserRole { superAdmin, admin, salesOfficer, deliveryPartner, accountant }

extension on UserRole {
  String get label {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.admin:
        return 'Admin';
      case UserRole.salesOfficer:
        return 'Sales Officer';
      case UserRole.deliveryPartner:
        return 'Delivery Partner';
      case UserRole.accountant:
        return 'Accountant';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.superAdmin:
        return Icons.shield_outlined;
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
      case UserRole.salesOfficer:
        return Icons.groups_outlined;
      case UserRole.deliveryPartner:
        return Icons.local_shipping_outlined;
      case UserRole.accountant:
        return Icons.account_balance_wallet_outlined;
    }
  }
}

class _CountryCode {
  final String iso;
  final String dialCode;

  const _CountryCode(this.iso, this.dialCode);
}

const List<_CountryCode> _countryCodes = [
  _CountryCode('IN', '+91'),
  _CountryCode('US', '+44'),
  _CountryCode('AE', '+971'),
  _CountryCode('AU', '+61'),
  _CountryCode('JP', '+81'),
  _CountryCode('CN', '+86'),
  _CountryCode('DE', '+49'),
  _CountryCode('FR', '+33'),
  _CountryCode('IT', '+39'),
  _CountryCode('ES', '+34'),
  _CountryCode('NL', '+31'),
  _CountryCode('SG', '+65'),
  _CountryCode('MY', '+60'),
  _CountryCode('TH', '+66'),
  _CountryCode('BD', '+880'),
  _CountryCode('PK', '+92'),
  _CountryCode('LK', '+94'),
  _CountryCode('ZA', '+27'),
  _CountryCode('BR', '+55'),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  bool _isPhoneTab = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _roleMenuOpen = false;
  bool _countryMenuOpen = false;
  UserRole? _selectedRole;
  _CountryCode _selectedCountry = _countryCodes.first;

  // Gradient-card palette (Uiverse-inspired)
  static const Color cardTopColor = Color(0xFFFFFFFF);
  static const Color cardBottomColor = Color(0xFFF4F7FB);
  static const Color brandBlue = Color(0xFF1089D3);
  static const Color brandCyan = Color(0xFF12B1D1);
  static const Color darkText = Color(0xFF111827);
  static const Color greyText = Color(0xFFAAAAAA);
  static const Color shadowBlue = Color(0xFF85BDD7);
  static const Color inputShadow = Color(0xFFCFF0FF);

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        setState(() => _roleMenuOpen = true);
      }
    });
  }

  @override
  void dispose() {
    _apiService.close();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _selectRole(UserRole role) {
    setState(() {
      _selectedRole = role;
      _roleMenuOpen = false;
    });
  }

  Future<void> _handleSignIn() async {
    if (!_isPhoneTab && !_formKey.currentState!.validate()) return;

    if (_isPhoneTab) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone login is not connected yet. Use email sign-in.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final message = await _apiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _countryMenuOpen = false);
        _emailFocusNode.unfocus();
        setState(() => _roleMenuOpen = false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEEF3F8),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [cardTopColor, cardBottomColor],
                    ),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: shadowBlue.withValues(alpha: 0.55),
                        blurRadius: 30,
                        spreadRadius: -20,
                        offset: const Offset(0, 30),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Welcome back',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: brandBlue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign in to your workspace to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: greyText),
                        ),
                        const SizedBox(height: 22),

                        _buildTabSwitcher(),
                        const SizedBox(height: 18),

                        if (!_isPhoneTab) ...[
                          Row(
                            children: [
                              const _FieldLabel('Email'),
                              if (_selectedRole != null) ...[
                                const SizedBox(width: 8),
                                Icon(
                                  _selectedRole!.icon,
                                  size: 13,
                                  color: brandBlue,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  _selectedRole!.label,
                                  style: const TextStyle(
                                    color: brandBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: darkText, fontSize: 14),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!value.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                            decoration: _pillDecoration(
                              hint: 'you@company.com',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _roleMenuOpen
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: greyText,
                                ),
                                onPressed: () {
                                  setState(() => _roleMenuOpen = !_roleMenuOpen);
                                  if (_roleMenuOpen) {
                                    _emailFocusNode.requestFocus();
                                  }
                                },
                              ),
                            ),
                          ),

                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 150),
                            crossFadeState: _roleMenuOpen
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: _buildRoleList(),
                            secondChild: const SizedBox(width: double.infinity),
                          ),

                          const SizedBox(height: 14),
                          const _FieldLabel('Password'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: darkText, fontSize: 14),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              return null;
                            },
                            decoration: _pillDecoration(
                              hint: 'Enter your password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: greyText,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8, right: 6),
                              child: GestureDetector(
                                onTap: () {
                                  // TODO(auth): navigate to forgot-password flow.
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Color(0xFF0099FF),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _GradientButton(
                            label: 'Sign in',
                            isLoading: _isLoading,
                            onPressed: _handleSignIn,
                          ),
                        ] else ...[
                          const _FieldLabel('Phone Number'),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => setState(
                                  () => _countryMenuOpen = !_countryMenuOpen,
                                ),
                                child: Container(
                                  height: 52,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _countryMenuOpen
                                          ? brandCyan
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: inputShadow,
                                        blurRadius: 10,
                                        spreadRadius: -5,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedCountry.iso,
                                        style: const TextStyle(
                                          color: darkText,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _selectedCountry.dialCode,
                                        style: const TextStyle(
                                          color: darkText,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Icon(
                                        _countryMenuOpen
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: greyText,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(
                                    color: darkText,
                                    fontSize: 14,
                                  ),
                                  decoration: _pillDecoration(
                                    hint: '98450 11223',
                                    topMargin: 0,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 150),
                            crossFadeState: _countryMenuOpen
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            firstChild: _buildCountryList(),
                            secondChild: const SizedBox(width: double.infinity),
                          ),

                          const SizedBox(height: 18),
                          _GradientButton(
                            label: 'Get OTP',
                            isLoading: _isLoading,
                            onPressed: _handleSignIn,
                          ),
                        ],

                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: greyText,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Or sign in with social platforms',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: greyText),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialCircleButton(
                              label: 'G',
                              onTap: () {
                                // TODO(auth): wire real Google SSO.
                              },
                            ),
                            const SizedBox(width: 15),
                            _SocialCircleButton(
                              icon: Icons.apple,
                              onTap: () {
                                // TODO(auth): wire real Apple SSO.
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'New organization? ',
                              style: TextStyle(color: greyText, fontSize: 12),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Register here',
                                style: TextStyle(
                                  color: Color(0xFF0099FF),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: inputShadow,
            blurRadius: 14,
            spreadRadius: -4,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LOGIN AS',
                style: TextStyle(
                  color: greyText,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ),
          for (final role in UserRole.values)
            InkWell(
              onTap: () => _selectRole(role),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(role.icon, size: 18, color: brandBlue),
                    const SizedBox(width: 10),
                    Text(
                      role.label,
                      style: const TextStyle(color: darkText, fontSize: 13),
                    ),
                    if (_selectedRole == role) ...[
                      const Spacer(),
                      const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: brandBlue,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildCountryList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: inputShadow,
            blurRadius: 14,
            spreadRadius: -4,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemCount: _countryCodes.length,
            itemBuilder: (context, index) {
              final code = _countryCodes[index];
              return InkWell(
                onTap: () => setState(() {
                  _selectedCountry = code;
                  _countryMenuOpen = false;
                }),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  child: Text(
                    '${code.iso}  ${code.dialCode}',
                    style: const TextStyle(color: darkText, fontSize: 13),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E9F0)),
      ),
      child: Row(
        children: [
          Expanded(child: _tabButton('Email', isActive: !_isPhoneTab)),
          Expanded(child: _tabButton('Phone No', isActive: _isPhoneTab)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, {required bool isActive}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _countryMenuOpen = false;
          _roleMenuOpen = false;
          _isPhoneTab = label == 'Phone No';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? const [
                  BoxShadow(
                    color: inputShadow,
                    blurRadius: 8,
                    spreadRadius: -2,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? darkText : greyText,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Pill-shaped input decoration matching the Uiverse card's soft cyan glow
  // and rounded corners, with a colored inline border only while focused.
  InputDecoration _pillDecoration({
    required String hint,
    Widget? suffixIcon,
    double topMargin = 8,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: greyText, fontSize: 14),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: brandCyan, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _LoginScreenState.darkText,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _LoginScreenState.brandBlue,
                _LoginScreenState.brandCyan,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _LoginScreenState.shadowBlue.withValues(alpha: 0.55),
                blurRadius: 10,
                spreadRadius: -8,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const _SocialCircleButton({this.label, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Color(0xFF707070)],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: [
            BoxShadow(
              color: _LoginScreenState.shadowBlue.withValues(alpha: 0.55),
              blurRadius: 10,
              spreadRadius: -6,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Center(
          child: label != null
              ? Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                )
              : Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
