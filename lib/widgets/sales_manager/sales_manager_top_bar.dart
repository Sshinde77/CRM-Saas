import 'package:flutter/material.dart';

import '../delivery/delivery_top_bar.dart';

class SalesManagerTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onNotificationTap;
  final List<Widget> actions;
  final String? profileName;
  final String? profileRole;
  final Future<void> Function()? onSignOut;
  final FontWeight titleFontWeight;
  final double titleFontSize;

  const SalesManagerTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onLeadingTap,
    this.onNotificationTap,
    this.actions = const [],
    this.profileName,
    this.profileRole,
    this.onSignOut,
    this.titleFontWeight = FontWeight.w700,
    this.titleFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return DeliveryTopBar(
      title: title,
      subtitle: subtitle,
      leadingIcon: leadingIcon ?? Icons.menu_rounded,
      onLeadingTap:
          onLeadingTap ?? () => Scaffold.maybeOf(context)?.openDrawer(),
      onNotificationTap: onNotificationTap,
      actions: actions,
      profileName: profileName ?? 'Sales Manager',
      profileRole: profileRole ?? 'Sales Manager',
      onSignOut: onSignOut,
      titleFontWeight: titleFontWeight,
      titleFontSize: titleFontSize,
    );
  }
}
