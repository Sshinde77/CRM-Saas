import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';
import 'login_screen.dart';

// Place this file at: lib/screens/auth/register_screen.dart
//
// 3-step organization registration wizard:
//   1. Admin Registration   (name, email, password, phone)
//   2. Organization Details (company name, logo, business type, GST, PAN, FY)
//   3. Business Details     (billing/shipping address, website, invoice prefix)
//
// Restyled to match the gradient-card look used in login_screen.dart v4
// (Uiverse.io-inspired): rounded 40px card, pill-shaped inputs with a soft
// cyan glow, and a blue-to-cyan gradient primary button. All fields, steps,
// and validation logic are unchanged from the original.

const List<String> _businessTypes = [
  'Manufacturer',
  'Distributor',
  'Wholesaler',
  'Retailer',
  'Service Provider',
];

const List<String> _financialYears = ['2024-2025', '2025-2026', '2026-2027'];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();

  int _currentStep = 0;
  bool _isSubmitting = false;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();

  // Step 1
  final _adminNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;

  // Step 2
  final _companyNameController = TextEditingController();
  final _gstController = TextEditingController();
  final _panController = TextEditingController();
  String? _businessType;
  String? _financialYear;
  XFile? _logoFile;

  // Step 3
  final _billingAddressController = TextEditingController();
  final _shippingAddressController = TextEditingController();
  final _websiteController = TextEditingController();
  final _invoicePrefixController = TextEditingController();
  bool _shippingSameAsBilling = false;

  // Gradient-card palette (Uiverse-inspired) — matches login_screen.dart
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
    _billingAddressController.addListener(() {
      if (_shippingSameAsBilling) {
        _shippingAddressController.text = _billingAddressController.text;
      }
    });
  }

  @override
  void dispose() {
    _apiService.close();
    _adminNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _companyNameController.dispose();
    _gstController.dispose();
    _panController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    _websiteController.dispose();
    _invoicePrefixController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) setState(() => _logoFile = picked);
    } catch (_) {
      // TODO(ux): surface a snackbar if picker permissions are denied.
    }
  }

  void _goNext(GlobalKey<FormState> key) {
    if (!key.currentState!.validate()) return;
    setState(() => _currentStep += 1);
  }

  void _goBack() {
    setState(() => _currentStep -= 1);
  }

  Future<void> _submit() async {
    if (!_validateAllSteps()) return;

    setState(() => _isSubmitting = true);
    try {
      final message = await _apiService.registerOrganization(
        organizationName: _companyNameController.text.trim(),
        businessType: _businessType!.trim(),
        gstNumber: _gstController.text.trim(),
        panNumber: _panController.text.trim(),
        address: _billingAddressController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        financialYear: _financialYear!.trim(),
        logoUrl: _logoFile?.path ?? '',
        adminName: _adminNameController.text.trim(),
        password: _passwordController.text,
        role: 'admin',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  bool _validateAllSteps() {
    final step1Valid = _step1Key.currentState?.validate() ?? false;
    if (!step1Valid) {
      setState(() => _currentStep = 0);
      return false;
    }

    final step2Valid = _step2Key.currentState?.validate() ?? false;
    if (!step2Valid) {
      setState(() => _currentStep = 1);
      return false;
    }

    final step3Valid = _step3Key.currentState?.validate() ?? false;
    if (!step3Valid) {
      setState(() => _currentStep = 2);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF3F8),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 30,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Register your organization',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: brandBlue,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Set up your SAAS CRM workspace',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: greyText),
                    ),
                    const SizedBox(height: 18),
                    _buildStepDots(),
                    const SizedBox(height: 22),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _currentStep == 0
                          ? _buildStep1()
                          : _currentStep == 1
                          ? _buildStep2()
                          : _buildStep3(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: index == _currentStep ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: isActive
                  ? const LinearGradient(colors: [brandBlue, brandCyan])
                  : null,
              color: isActive ? null : const Color(0xFFE3E9F0),
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------
  // Step 1: Admin Registration
  // ---------------------------------------------------------------------
  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: Column(
        key: const ValueKey('step1'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepHeader(number: 1, title: 'Admin Registration'),
          const SizedBox(height: 18),
          _fieldRow(
            left: _labeledField(
              label: 'Admin Name',
              child: TextFormField(
                controller: _adminNameController,
                style: const TextStyle(color: darkText, fontSize: 14),
                validator: _requiredValidator,
                decoration: _pillDecoration(hint: 'e.g. Rohit Sharma'),
              ),
            ),
            right: _labeledField(
              label: 'Email Address',
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: darkText, fontSize: 14),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) return 'Enter a valid email';
                  return null;
                },
                decoration: _pillDecoration(hint: 'e.g. rohit@company.com'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _fieldRow(
            left: _labeledField(
              label: 'Password',
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: darkText, fontSize: 14),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Minimum 6 characters';
                  }
                  return null;
                },
                decoration: _pillDecoration(
                  hint: 'e.g. Minimum 6 characters',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: greyText,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
            ),
            right: _labeledField(
              label: 'Phone Number',
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: darkText, fontSize: 14),
                validator: _requiredValidator,
                decoration: _pillDecoration(hint: 'e.g. 98450 11223'),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _GradientButton(
            label: 'Next',
            isLoading: false,
            onPressed: () => _goNext(_step1Key),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(color: greyText, fontSize: 12),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  'Sign in',
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
    );
  }

  // ---------------------------------------------------------------------
  // Step 2: Organization Details
  // ---------------------------------------------------------------------
  Widget _buildStep2() {
    return Form(
      key: _step2Key,
      child: Column(
        key: const ValueKey('step2'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepHeader(number: 2, title: 'Organization Details'),
          const SizedBox(height: 18),
          _fieldRow(
            left: _labeledField(
              label: 'Company/Firm/Shop Name',
              child: TextFormField(
                controller: _companyNameController,
                style: const TextStyle(color: darkText, fontSize: 14),
                validator: _requiredValidator,
                decoration: _pillDecoration(hint: 'e.g. Sharma Distributors'),
              ),
            ),
            right: _labeledField(
              label: 'Company Logo',
              child: InkWell(
                onTap: _pickLogo,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        color: brandBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _logoFile?.name ?? 'Upload company logo',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _logoFile != null ? darkText : greyText,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _pickLogo,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Browse',
                          style: TextStyle(color: darkText, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _fieldRow(
            left: _labeledField(
              label: 'Business Type',
              child: DropdownButtonFormField<String>(
                initialValue: _businessType,
                validator: (v) => v == null ? 'Select business type' : null,
                style: const TextStyle(color: darkText, fontSize: 14),
                decoration: _pillDecoration(hint: 'Select business type'),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: greyText,
                ),
                items: _businessTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _businessType = value),
              ),
            ),
            right: _labeledField(
              label: 'GST Number',
              child: TextFormField(
                controller: _gstController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: darkText, fontSize: 14),
                decoration: _pillDecoration(hint: 'e.g. 27ABCDE1234F1Z5'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _fieldRow(
            left: _labeledField(
              label: 'PAN Number (if applicable)',
              child: TextFormField(
                controller: _panController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: darkText, fontSize: 14),
                decoration: _pillDecoration(hint: 'e.g. ABCDE1234F'),
              ),
            ),
            right: _labeledField(
              label: 'Financial Year',
              child: DropdownButtonFormField<String>(
                initialValue: _financialYear,
                validator: (v) => v == null ? 'Select financial year' : null,
                style: const TextStyle(color: darkText, fontSize: 14),
                decoration: _pillDecoration(hint: 'Select financial year'),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: greyText,
                ),
                items: _financialYears
                    .map(
                      (fy) => DropdownMenuItem(value: fy, child: Text(fy)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _financialYear = value),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _buildStepButtons(
            onNext: () => _goNext(_step2Key),
            nextLabel: 'Next',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Step 3: Business Details
  // ---------------------------------------------------------------------
  Widget _buildStep3() {
    return Form(
      key: _step3Key,
      child: Column(
        key: const ValueKey('step3'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepHeader(number: 3, title: 'Business Details'),
          const SizedBox(height: 18),
          _labeledField(
            label: 'Billing Address',
            child: TextFormField(
              controller: _billingAddressController,
              maxLines: 4,
              style: const TextStyle(color: darkText, fontSize: 14),
              validator: _requiredValidator,
              decoration: _pillDecoration(
                hint: 'e.g. 12, MG Road, Andheri East, Mumbai, MH 400069',
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _shippingSameAsBilling,
                  activeColor: brandBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
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
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Shipping/Warehouse address same as billing address',
                  style: TextStyle(color: darkText, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _labeledField(
            label: 'Shipping/Warehouse Address',
            child: TextFormField(
              controller: _shippingAddressController,
              maxLines: 4,
              enabled: !_shippingSameAsBilling,
              style: const TextStyle(color: darkText, fontSize: 14),
              validator: (value) {
                if (_shippingSameAsBilling) return null;
                return _requiredValidator(value);
              },
              decoration: _pillDecoration(
                hint: 'e.g. Plot 45, MIDC Industrial Area, Pune, MH 411019',
              ),
            ),
          ),
          const SizedBox(height: 16),
          _fieldRow(
            left: _labeledField(
              label: 'Website (if applicable)',
              child: TextFormField(
                controller: _websiteController,
                keyboardType: TextInputType.url,
                style: const TextStyle(color: darkText, fontSize: 14),
                decoration: _pillDecoration(hint: 'e.g. www.sharmadist.com'),
              ),
            ),
            right: _labeledField(
              label: 'Invoice Prefix',
              child: TextFormField(
                controller: _invoicePrefixController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: darkText, fontSize: 14),
                decoration: _pillDecoration(hint: 'e.g. INV'),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _buildStepButtons(
            onNext: _submit,
            nextLabel: 'Create organization',
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------
  Widget _buildStepButtons({
    required VoidCallback onNext,
    required String nextLabel,
    bool isLoading = false,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          height: 52,
          child: OutlinedButton(
            onPressed: _goBack,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Back',
              style: TextStyle(
                color: darkText,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GradientButton(
            label: nextLabel,
            isLoading: isLoading,
            onPressed: onNext,
          ),
        ),
      ],
    );
  }

  Widget _fieldRow({required Widget left, required Widget right}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 16), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            Expanded(child: right),
          ],
        );
      },
    );
  }

  Widget _labeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: darkText,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  // Pill-shaped input decoration matching the Uiverse card's soft cyan glow
  // and rounded corners, with a colored inline border only while focused.
  InputDecoration _pillDecoration({String? hint, Widget? suffixIcon}) {
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

class _StepHeader extends StatelessWidget {
  final int number;
  final String title;

  const _StepHeader({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _RegisterScreenState.brandBlue,
                _RegisterScreenState.brandCyan,
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: _RegisterScreenState.darkText,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
      ],
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
                _RegisterScreenState.brandBlue,
                _RegisterScreenState.brandCyan,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _RegisterScreenState.shadowBlue.withValues(alpha: 0.55),
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
