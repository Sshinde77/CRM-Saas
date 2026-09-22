import 'package:flutter/material.dart';

import '../delivery/delivery_top_bar.dart';

class SalesManagerTopBar extends StatelessWidget {
  final String title;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onNotificationTap;
  final List<Widget> actions;
  final String? profileName;
  final String? profileRole;
  final Future<void> Function()? onSignOut;

  const SalesManagerTopBar({
    super.key,
    required this.title,
    this.leadingIcon,
    this.onLeadingTap,
    this.onNotificationTap,
    this.actions = const [],
    this.profileName,
    this.profileRole,
    this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return DeliveryTopBar(
      title: title,
      leadingIcon: leadingIcon ?? Icons.menu_rounded,
      onLeadingTap:
          onLeadingTap ?? () => Scaffold.maybeOf(context)?.openDrawer(),
      onNotificationTap: onNotificationTap,
      actions: actions,
      profileName: profileName ?? 'Sales Manager',
      profileRole: profileRole ?? 'Sales Manager',
      onSignOut: onSignOut,
    );
  }
}
