import 'package:flutter/material.dart';
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
  static const Color darkText = Color(0xFF1E2140);
  static const Color greyText = Color(0xFF8A8DA6);
  static const Color fieldBorder = Color(0xFFE3E1F5);
  static const Color fieldFill = Color(0xFFF7F6FD);

  static const double _bottomWaveHeight = 160;

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

  // TODO: replace this with your real auth check (ApiService.login etc.)
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
    // Fallback for other roles until their dashboards are built
    Navigator.pushReplacementNamed(context, '/home');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFAFF),
      body: GestureDetector(
        // Tapping outside the email field closes the role dropdown.
        onTap: () {
          if (_showRoleSuggestions) {
            setState(() => _showRoleSuggestions = false);
            _emailFocusNode.unfocus();
          }
        },
        child: Stack(
          children: [
            // Top-right faint concentric circles
            Positioned(
              top: -40,
              right: -60,
              child: _ConcentricCircles(),
            ),

            // Top-left soft purple wave
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: _TopWaveClipper(),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryPurple.withOpacity(0.18),
                        primaryPurple.withOpacity(0.06),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom purple wave
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: _BottomWaveClipper(),
                child: Container(
                  height: _bottomWaveHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryPurple.withOpacity(0.9),
                        primaryPurple,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Scrollable form content.
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, _bottomWaveHeight + 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Logo icon
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: primaryPurple.withOpacity(0.08),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
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
                                          color: Colors.white,
                                          strokeWidth: 2.4,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Sign In',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // OR divider
                            Row(
                              children: [
                                const Expanded(child: Divider(color: fieldBorder)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(color: greyText, fontSize: 12),
                                  ),
                                ),
                                const Expanded(child: Divider(color: fieldBorder)),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Google Sign in
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton(
                                onPressed: () {
                                  // TODO: hook up Google sign-in
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: fieldBorder),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _GoogleIcon(),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Sign in with Google',
                                      style: TextStyle(
                                        color: darkText,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
            ),

            // Footer pinned above the wave.
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
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
              ),
            ),
          ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fieldBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
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
            separatorBuilder: (_, __) => const Divider(height: 1, color: fieldFill),
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
                          color: primaryPurple.withOpacity(0.08),
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

/// Simple 4-color "G" approximation for the Google button (no image asset needed).
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleGPainter(),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final double strokeWidth = size.width * 0.22;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    paint.color = const Color(0xFF4285F4); // blue
    canvas.drawArc(rect, -0.35, 1.6, false, paint);

    paint.color = const Color(0xFF34A853); // green
    canvas.drawArc(rect, 1.25, 1.6, false, paint);

    paint.color = const Color(0xFFFBBC05); // yellow
    canvas.drawArc(rect, 2.85, 1.4, false, paint);

    paint.color = const Color(0xFFEA4335); // red
    canvas.drawArc(rect, 4.25, 1.6, false, paint);

    // horizontal bar of the G
    final Paint barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - strokeWidth / 2, radius, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ConcentricCircles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: CustomPaint(
        painter: _CirclesPainter(),
      ),
    );
  }
}

class _CirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF6C4EE3).withOpacity(0.15);

    final Offset center = Offset(size.width, 0);
    for (int i = 1; i <= 5; i++) {
      canvas.drawCircle(center, i * 30.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height * 0.75,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.45,
      size.width,
      size.height * 0.6,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.55,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.65,
      size.width,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}