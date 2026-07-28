import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/auth_models.dart';
import '../../providers/api_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../services/api_service.dart';

class AdminTopBar extends StatefulWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onNotificationTap;
  final Widget? trailingAvatar;
  final String? profileName;
  final String? profileRole;
  final Future<void> Function()? onSignOut;

  const AdminTopBar({
    super.key,
    required this.title,
    required this.leadingIcon,
    this.onLeadingTap,
    this.onNotificationTap,
    this.trailingAvatar,
    this.profileName,
    this.profileRole,
    this.onSignOut,
  });

  @override
  State<AdminTopBar> createState() => _AdminTopBarState();
}

class _AdminTopBarState extends State<AdminTopBar> {
  late Future<CurrentUserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = Future<CurrentUserProfile?>.value(null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileFuture = _loadProfile();
  }

  Future<CurrentUserProfile?> _loadProfile() async {
    final apiProvider = ApiProviderScope.maybeOf(context);
    if (apiProvider == null || (ApiService.accessToken ?? '').trim().isEmpty) {
      return null;
    }

    try {
      return await apiProvider.fetchCurrentUserProfile();
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleSignOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Confirm Logout',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Color(0xFFFF4D4F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true || !mounted) return;

    try {
      final apiProvider = ApiProviderScope.of(context);
      await apiProvider.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
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
      ).showSnackBar(SnackBar(content: Text('Logout failed: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        border: Border(bottom: BorderSide(color: AppColors.accentGrey)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: widget.onLeadingTap,
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                widget.leadingIcon,
                color: AppColors.accentGrey,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
                size: 30,
              ),
              Positioned(
                right: 1,
                top: 1,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          widget.trailingAvatar ??
              FutureBuilder<CurrentUserProfile?>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  return _DefaultAvatar(
                    profileName:
                        profile?.name ??
                        widget.profileName ??
                        (snapshot.connectionState == ConnectionState.waiting
                            ? 'Loading...'
                            : 'User'),
                    profileRole: profile?.role ?? widget.profileRole ?? '',
                    onSignOut: widget.onSignOut ?? _handleSignOut,
                  );
                },
              ),
        ],
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  final String profileName;
  final String profileRole;
  final Future<void> Function()? onSignOut;

  const _DefaultAvatar({
    required this.profileName,
    required this.profileRole,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ProfileMenuAction>(
      tooltip: 'Profile',
      color: AppColors.primary,
      surfaceTintColor: AppColors.primary,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onSelected: (value) {
        if (value == _ProfileMenuAction.signOut) {
          if (onSignOut != null) {
            onSignOut!();
          }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<_ProfileMenuAction>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: _ProfileMenuHeader(
            profileName: profileName,
            profileRole: profileRole,
          ),
        ),
        const PopupMenuDivider(height: 1),
        const PopupMenuItem<_ProfileMenuAction>(
          value: _ProfileMenuAction.signOut,
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFFF4D4F), size: 20),
              SizedBox(width: 10),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Color(0xFFFF4D4F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accentGrey),
        ),
        alignment: Alignment.center,
        child: const Text(
          'AS',
          style: TextStyle(
            color: AppColors.accentGrey,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

enum _ProfileMenuAction { signOut }

class _ProfileMenuHeader extends StatelessWidget {
  final String profileName;
  final String profileRole;

  const _ProfileMenuHeader({
    required this.profileName,
    required this.profileRole,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            profileName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (profileRole.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              profileRole,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

