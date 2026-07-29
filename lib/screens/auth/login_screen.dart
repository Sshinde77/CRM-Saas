import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../providers/api_provider.dart';
import '../../services/api_service.dart';
import '../role_home_screen.dart';
import 'register_screen.dart';

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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isPhoneTab = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _countryMenuOpen = false;
  _CountryCode _selectedCountry = _countryCodes.first;

  static const Color pageBg = AppColors.adminSidebarBg;
  static const Color cardBg = AppColors.surfaceOverlay;
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primary900;
  static const Color headingText = AppColors.textPrimary;
  static const Color bodyText = AppColors.textSecondary;
  static const Color mutedText = AppColors.textMuted;
  static const Color lightMutedText = AppColors.textLightMuted;
  static const Color cardBorder = AppColors.borderLight;
  static const Color border = AppColors.border;
  static const Color borderStrong = AppColors.borderStrong;
  static const Color activeMenuBg = AppColors.activeMenuBg;
  static const Color shadowColor = Color(0x14063B00);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
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
      final apiProvider = ApiProviderScope.of(context);
      final session = await apiProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(session.message)));
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RoleHomeScreen.forRole(session.user?.role),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $error')));
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
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: pageBg,
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
                    color: cardBg,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: cardBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 28,
                        offset: Offset(0, 18),
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
                            color: headingText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign in to your workspace to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: bodyText),
                        ),
                        const SizedBox(height: 22),
                        _buildTabSwitcher(),
                        const SizedBox(height: 18),
                        if (!_isPhoneTab) ...[
                          const _FieldLabel('Email'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: headingText,
                              fontSize: 14,
                            ),
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
                            ),
                          ),
                          const SizedBox(height: 14),
                          const _FieldLabel('Password'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              color: headingText,
                              fontSize: 14,
                            ),
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
                                  color: mutedText,
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
                                onTap: () {},
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _PrimaryButton(
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
                                          ? primary
                                          : border,
                                      width: 1.4,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedCountry.iso,
                                        style: const TextStyle(
                                          color: headingText,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _selectedCountry.dialCode,
                                        style: const TextStyle(
                                          color: headingText,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Icon(
                                        _countryMenuOpen
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: mutedText,
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
                                    color: headingText,
                                    fontSize: 14,
                                  ),
                                  decoration: _pillDecoration(
                                    hint: '98450 11223',
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
                          _PrimaryButton(
                            label: 'Get OTP',
                            isLoading: _isLoading,
                            onPressed: _handleSignIn,
                          ),
                        ],
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: borderStrong, thickness: 1),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: lightMutedText,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: borderStrong, thickness: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Or sign in with social platforms',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, color: mutedText),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialCircleButton(
                              label: 'G',
                              onTap: () {},
                            ),
                            const SizedBox(width: 15),
                            _SocialCircleButton(
                              icon: Icons.apple,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'New organization? ',
                              style: TextStyle(color: mutedText, fontSize: 12),
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
                                  color: primary,
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

  Widget _buildCountryList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(color: shadowColor, blurRadius: 18, offset: Offset(0, 10)),
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
                    style: const TextStyle(color: headingText, fontSize: 13),
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
        color: AppColors.adminSidebarBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
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
          _isPhoneTab = label == 'Phone No';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? activeMenuBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? primaryDark : mutedText,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  InputDecoration _pillDecoration({
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: lightMutedText, fontSize: 14),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.statusInactiveText),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.statusInactiveText),
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
        color: _LoginScreenState.headingText,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _PrimaryButton({
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
          backgroundColor: _LoginScreenState.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
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
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _LoginScreenState.border, width: 1.4),
        ),
        child: Center(
          child: label != null
              ? Text(
                  label!,
                  style: const TextStyle(
                    color: _LoginScreenState.headingText,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                )
              : Icon(icon, color: _LoginScreenState.headingText, size: 18),
        ),
      ),
    );
  }
}
