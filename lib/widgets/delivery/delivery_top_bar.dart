import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/auth_models.dart';
import '../../providers/api_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../services/api_service.dart';

class DeliveryTopBar extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onNotificationTap;
  final List<Widget> actions;
  final bool showNotification;
  final bool showProfile;
  final String? profileName;
  final String? profileRole;
  final Future<void> Function()? onSignOut;

  const DeliveryTopBar({
    super.key,
    required this.title,
    required this.leadingIcon,
    this.subtitle,
    this.onLeadingTap,
    this.onNotificationTap,
    this.actions = const [],
    this.showNotification = true,
    this.showProfile = true,
    this.profileName,
    this.profileRole,
    this.onSignOut,
  });

  @override
  State<DeliveryTopBar> createState() => _DeliveryTopBarState();
}

class _DeliveryTopBarState extends State<DeliveryTopBar> {
  late Future<CurrentUserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = Future<CurrentUserProfile?>.value(null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.showProfile) {
      _profileFuture = _loadProfile();
    }
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
    final subtitle = widget.subtitle?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF042D0A), Color(0xFF075E19)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Row(
            children: [
              _TopBarIconButton(
                icon: widget.leadingIcon,
                onTap: widget.onLeadingTap,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFE7F7EA),
                          fontSize: 11.5,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.actions.isNotEmpty) ...[
                const SizedBox(width: 6),
                ...widget.actions,
              ],
              if (widget.showNotification) ...[
                const SizedBox(width: 6),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _TopBarIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: widget.onNotificationTap,
                    ),
                    Positioned(
                      right: 3,
                      top: 3,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.deliveryRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (widget.showProfile) ...[
                const SizedBox(width: 10),
                FutureBuilder<CurrentUserProfile?>(
                  future: _profileFuture,
                  builder: (context, snapshot) {
                    final profile = snapshot.data;
                    return _DeliveryAvatar(
                      profileName:
                          profile?.name ??
                          widget.profileName ??
                          (snapshot.connectionState == ConnectionState.waiting
                              ? 'Loading...'
                              : 'Partner'),
                      profileRole: profile?.role ?? widget.profileRole ?? '',
                      profilePhoto: profile?.profilePhoto,
                      onSignOut: widget.onSignOut ?? _handleSignOut,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class DeliveryTopBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;

  const DeliveryTopBarAction({
    super.key,
    required this.icon,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: _TopBarIconButton(icon: icon, onTap: onTap),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _TopBarIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }
}

class _DeliveryAvatar extends StatelessWidget {
  final String profileName;
  final String profileRole;
  final String? profilePhoto;
  final Future<void> Function()? onSignOut;

  const _DeliveryAvatar({
    required this.profileName,
    required this.profileRole,
    this.profilePhoto,
    this.onSignOut,
  });

  String get _initials {
    final parts = profileName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'DP';
    if (parts.length == 1) {
      final text = parts.first;
      return text.length >= 2
          ? text.substring(0, 2).toUpperCase()
          : text.toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = profilePhoto?.trim();
    final hasProfilePhoto = imageUrl != null && imageUrl.isNotEmpty;

    return PopupMenuButton<_ProfileMenuAction>(
      tooltip: 'Profile',
      color: AppColors.surface,
      surfaceTintColor: AppColors.surface,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      onSelected: (value) {
        if (value == _ProfileMenuAction.signOut && onSignOut != null) {
          onSignOut!();
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
        ),
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        child: hasProfilePhoto
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 36,
                height: 36,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    _initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  );
                },
              )
            : Text(
                _initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
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
