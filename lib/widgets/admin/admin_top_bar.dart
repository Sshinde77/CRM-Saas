import 'package:flutter/material.dart';

import '../delivery/delivery_top_bar.dart';

class AdminTopBar extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onNotificationTap;
  final List<Widget> actions;
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
    this.actions = const [],
    this.trailingAvatar,
    this.profileName,
    this.profileRole,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return DeliveryTopBar(
      title: title,
      leadingIcon: leadingIcon,
      onLeadingTap: onLeadingTap,
      onNotificationTap: onNotificationTap,
      actions: [...actions, if (trailingAvatar != null) trailingAvatar!],
      profileName: profileName ?? 'Admin',
      profileRole: profileRole ?? 'Admin',
      onSignOut: onSignOut,
    );
  }
}
