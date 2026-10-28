import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:crm_saas/core/theme/app_text_styles.dart';

import '../../constants/app_colors.dart';
import '../../models/auth_models.dart';
import '../../providers/api_provider.dart';
import '../../services/api_service.dart';
import '../../services/google_auth_service.dart';
import '../../services/push_notification_service.dart';
import '../role_home_screen.dart';
import 'register_screen.dart';
import 'phone_otp_screen.dart';

class _CountryCode {
  final String iso;
  final String dialCode;

  const _CountryCode(this.iso, this.dialCode);
}

const List<_CountryCode> _countryCodes = [
  _CountryCode('IN', '+91'),
  _CountryCode('US', '+1'),
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
  final ScrollController _countryScrollController = ScrollController();

  bool _isPhoneTab = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _countryMenuOpen = false;
  bool _phoneLoginUnavailable = false;
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
    _countryScrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_isLoading) return;
    if (!_isPhoneTab && !_formKey.currentState!.validate()) return;

    if (_isPhoneTab) {
      await _sendPhoneOtp();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiProvider = ApiProviderScope.of(context);
      await PushNotificationService.instance.requestPermissionBeforeLogin();
      final session = await apiProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      _finishSignIn(apiProvider, session);
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

  String? _normalizedIndianPhone() {
    if (_selectedCountry.iso != 'IN') return null;
    final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    var normalized = digits;
    if (normalized.startsWith('0') && normalized.length == 11) {
      normalized = normalized.substring(1);
    } else if (normalized.startsWith('91') && normalized.length == 12) {
      normalized = normalized.substring(2);
    }
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(normalized)) return null;
    return normalized;
  }

  Future<void> _sendPhoneOtp() async {
    final phone = _normalizedIndianPhone();
    if (phone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid 10-digit Indian mobile number.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiProvider = ApiProviderScope.of(context);
      final resendAfter = await apiProvider.sendPhoneOtp(phone: phone);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PhoneOtpScreen(
            phone: phone,
            resendAfter: resendAfter,
            apiProvider: apiProvider,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 503) {
        setState(() {
          _phoneLoginUnavailable = true;
          _isPhoneTab = false;
        });
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not send OTP: $error')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await PushNotificationService.instance.requestPermissionBeforeLogin();
      final idToken = await GoogleAuthService().signIn();
      if (idToken == null || !mounted) return;
      final apiProvider = ApiProviderScope.of(context);
      final session = await apiProvider.loginWithGoogle(idToken: idToken);
      _finishSignIn(apiProvider, session);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ApiException
                ? error.message
                : 'Google sign-in failed. Please try again.',
          ),
          action: error is ApiException && error.code == 'registration_required'
              ? SnackBarAction(
                  label: 'Register',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                )
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _finishSignIn(ApiProvider apiProvider, AuthSession session) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(session.message)));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RoleHomeScreen.forRole(
          apiProvider.currentUser?.role ?? session.user?.role,
        ),
      ),
    );
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
                        Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [primary, primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.28),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.business_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Welcome back',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: headingText,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign in to your workspace to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: bodyText),
                        ),
                        const SizedBox(height: 24),
                        if (!_phoneLoginUnavailable) _buildTabSwitcher(),
                        const SizedBox(height: 18),
                        if (!_isPhoneTab || _phoneLoginUnavailable) ...[
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
                                    fontSize: 14,
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
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _selectedCountry.dialCode,
                                        style: const TextStyle(
                                          color: headingText,
                                          fontSize: 14,
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
                                  maxLength: 14,
                                  style: const TextStyle(
                                    color: headingText,
                                    fontSize: 14,
                                  ),
                                  buildCounter:
                                      (
                                        _, {
                                        required currentLength,
                                        required isFocused,
                                        maxLength,
                                      }) => null,
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
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: borderStrong, thickness: 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'or continue with',
                                style: TextStyle(
                                  color: lightMutedText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(color: borderStrong, thickness: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _GoogleSignInButton(
                          onTap: _isLoading ? null : _handleGoogleSignIn,
                        ),
                        // Registration link is intentionally hidden from the
                        // login page for now. The registration screen remains
                        // available for future use.
                        // const SizedBox(height: 18),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     const Text(
                        //       'New organization? ',
                        //       style: TextStyle(color: mutedText, fontSize: 14),
                        //     ),
                        //     GestureDetector(
                        //       onTap: () {
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(
                        //             builder: (_) => const RegisterScreen(),
                        //           ),
                        //         );
                        //       },
                        //       child: const Text(
                        //         'Register here',
                        //         style: TextStyle(
                        //           color: primary,
                        //           fontWeight: FontWeight.w700,
                        //           fontSize: 14,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
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
          controller: _countryScrollController,
          child: ListView.builder(
            controller: _countryScrollController,
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
                    style: const TextStyle(color: headingText, fontSize: 14),
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
        if (label == 'Phone No' && _phoneLoginUnavailable) return;
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
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  InputDecoration _pillDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.inputHint,
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
    return Text(text, style: AppTextStyles.fieldLabel);
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
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _GoogleSignInButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Continue with Google',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 120),
          opacity: onTap == null ? 0.55 : 1.0,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _LoginScreenState.border, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GoogleLogoIcon(size: 22),
                SizedBox(width: 12),
                Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: _LoginScreenState.headingText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleLogoIcon extends StatelessWidget {
  final double size;

  const _GoogleLogoIcon({this.size = 20});

  // Official Google G SVG paths (48×48 viewBox).
  static const _svg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#4285f4" d="M45.12 24.5c0-1.56-.14-3.06-.4-4.5H24v8.51h11.84c-.51 2.75-2.06 5.08-4.39 6.64v5.52h7.11c4.16-3.83 6.56-9.47 6.56-16.17z"/>
  <path fill="#34a853" d="M24 46c5.94 0 10.92-1.97 14.56-5.33l-7.11-5.52c-1.97 1.32-4.49 2.1-7.45 2.1-5.73 0-10.58-3.87-12.31-9.07H4.34v5.7C7.96 41.07 15.4 46 24 46z"/>
  <path fill="#fbbc05" d="M11.69 28.18C11.25 26.86 11 25.45 11 24s.25-2.86.69-4.18v-5.7H4.34C2.85 17.09 2 20.45 2 24c0 3.55.85 6.91 2.34 9.88l7.35-5.7z"/>
  <path fill="#ea4335" d="M24 10.75c3.23 0 6.13 1.11 8.41 3.29l6.31-6.31C34.91 4.18 29.93 2 24 2 15.4 2 7.96 6.93 4.34 14.12l7.35 5.7c1.73-5.2 6.58-9.07 12.31-9.07z"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_svg, width: size, height: size);
  }
}
