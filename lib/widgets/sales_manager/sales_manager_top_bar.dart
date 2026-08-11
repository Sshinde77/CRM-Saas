import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/auth_models.dart';
import '../../providers/api_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../services/api_service.dart';

class SalesManagerTopBar extends StatefulWidget {
  final String title;
  final VoidCallback? onNotificationTap;
  final String? profileName;
  final String? profileRole;
  final Future<void> Function()? onSignOut;

  const SalesManagerTopBar({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.profileName,
    this.profileRole,
    this.onSignOut,
  });

  @override
  State<SalesManagerTopBar> createState() => _SalesManagerTopBarState();
}

class _SalesManagerTopBarState extends State<SalesManagerTopBar> {
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
          backgroundColor: AppColors.surface,
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
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              return InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                borderRadius: BorderRadius.circular(20),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.menu_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _NotificationButton(onTap: widget.onNotificationTap),
          const SizedBox(width: 16),
          FutureBuilder<CurrentUserProfile?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              final profile = snapshot.data;
              final name = profile?.name ?? widget.profileName ?? 'User';
              final role = profile?.role ?? widget.profileRole ?? '';
              final initials = _buildInitials(name);

              return _DefaultAvatar(
                initials: initials,
                profileName: name,
                profileRole: role,
                onSignOut: widget.onSignOut ?? _handleSignOut,
              );
            },
          ),
        ],
      ),
    );
  }

  String _buildInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == 'Loading...' || trimmed == 'User') {
      return 'SM';
    }

    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'SM';
    if (parts.length == 1) {
      final first = parts.first;
      return first.isNotEmpty
          ? first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase()
          : 'SM';
    }

    final first = parts[0].isNotEmpty ? parts[0][0] : '';
    final second = parts[1].isNotEmpty ? parts[1][0] : '';
    final initials = (first + second).trim();
    return initials.isEmpty ? 'SM' : initials.toUpperCase();
  }
}

class _NotificationButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _NotificationButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onTap,
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textPrimary,
            size: 30,
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  final String initials;
  final String profileName;
  final String profileRole;
  final Future<void> Function()? onSignOut;

  const _DefaultAvatar({
    required this.initials,
    required this.profileName,
    required this.profileRole,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ProfileMenuAction>(
      tooltip: 'Profile',
      color: AppColors.surface,
      surfaceTintColor: AppColors.surface,
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
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.primary,
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
