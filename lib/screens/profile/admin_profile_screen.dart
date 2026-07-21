import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  // ---- Theme colours (kept consistent with the dashboard) ----
  static const Color bg = AppColors.primary;
  static const Color teal = AppColors.teal;
  static const Color green = AppColors.green;
  static const Color purple = AppColors.purple;
  static const Color blue = AppColors.blue;
  static const Color orange = AppColors.orange;
  static const Color red = AppColors.red;

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
      SnackBar(
        content: const Text('Profile updated'),
        backgroundColor: textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          Positioned(top: -60, left: -70, child: _glowBlob(purple, 220)),
          Positioned(top: 200, right: -90, child: _glowBlob(blue, 240)),
          Positioned(bottom: -80, left: 20, child: _glowBlob(teal, 220)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 18),
                  const Text('My Profile',
                      style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('Your account details',
                      style: TextStyle(color: textSecondary, fontSize: 13)),
                  const SizedBox(height: 20),
                  _buildProfileHero(),
                  const SizedBox(height: 20),
                  _buildFormCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Top bar (back / notifications / avatar) ----------------
  Widget _buildTopBar(BuildContext context) {
    return _GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: _iconBadge(Icons.arrow_back_rounded, textPrimary.withOpacity(0.06), textPrimary),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _iconBadge(Icons.notifications_none_rounded, textPrimary.withOpacity(0.06), textPrimary),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: red, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [purple, blue]),
            ),
            alignment: Alignment.center,
            child: const Text('AS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _iconBadge(IconData icon, Color bgColor, Color fg) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: fg, size: 19),
    );
  }

  Widget _glowBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.18),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.20), blurRadius: 100, spreadRadius: 30),
        ],
      ),
    );
  }

  // ---------------- Profile hero: gradient banner + overlapping avatar ----------------
  Widget _buildProfileHero() {
    return _CardContainer(
      borderRadius: 28,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            height: 92,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [purple, blue],
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -38),
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [purple, blue]),
                    ),
                    alignment: Alignment.center,
                    child: const Text('AS',
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(_nameController.text, style: const TextStyle(color: textPrimary, fontSize: 19, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: purple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: purple.withOpacity(0.3)),
                  ),
                  child: const Text('Admin', style: TextStyle(color: purple, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _statChip(Icons.calendar_today_outlined, 'Since Jan 2024', textSecondary),
                    const SizedBox(width: 10),
                    _statChip(Icons.verified_user_outlined, 'Verified', green),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return _CardContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Account details', style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Update your name, email or phone number', style: TextStyle(color: textSecondary, fontSize: 12)),
          const SizedBox(height: 20),
          _fieldLabel('Full Name'),
          _inputField(controller: _nameController, icon: Icons.person_outline),
          const SizedBox(height: 16),
          _fieldLabel('Email'),
          _inputField(controller: _emailController, icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _fieldLabel('Phone'),
          _inputField(controller: _phoneController, icon: Icons.call_outlined, keyboardType: TextInputType.phone),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [purple, blue]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, color: AppColors.primary, size: 18),
                            SizedBox(width: 8),
                            Text('Save Changes',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                          ],
                        ),
                ),
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
      child: Text(label, style: const TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: textPrimary.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: textPrimary.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: textPrimary, fontSize: 14),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const _CardContainer({
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color: Colors.white.withOpacity(0.55),
            border: Border.all(color: Colors.white.withOpacity(0.8)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F2A2E).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}