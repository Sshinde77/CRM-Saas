import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../providers/api_provider.dart';
import '../screens/auth/login_screen.dart';

class SidebarLogoutButton extends StatefulWidget {
  const SidebarLogoutButton({super.key});

  @override
  State<SidebarLogoutButton> createState() => _SidebarLogoutButtonState();
}

class _SidebarLogoutButtonState extends State<SidebarLogoutButton> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.statusInactiveText),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSigningOut = true);
    try {
      await ApiProviderScope.of(context).logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSigningOut = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Logout failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSigningOut ? null : _signOut,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.statusInactiveBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.statusInactiveBorder),
            ),
            child: Row(
              children: [
                if (_isSigningOut)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.statusInactiveText,
                    ),
                  )
                else
                  const Icon(
                    Icons.logout_rounded,
                    color: AppColors.statusInactiveText,
                    size: 20,
                  ),
                const SizedBox(width: 12),
                Text(
                  _isSigningOut ? 'Signing out...' : 'Logout',
                  style: const TextStyle(
                    color: AppColors.statusInactiveText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
