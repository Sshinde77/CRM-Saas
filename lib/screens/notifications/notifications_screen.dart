import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/admin_top_bar.dart';
import '../../widgets/app_drawer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  final List<_NotificationItem> _items = [
    _NotificationItem(
      title: 'Low stock alert',
      message: 'Packaged Drinking Water (1L) has reached the reorder level.',
      time: '2 min ago',
      icon: Icons.warning_amber_rounded,
      accent: AppColors.amber,
    ),
    _NotificationItem(
      title: 'Order delivered',
      message: 'Order #OD-2045 has been successfully delivered to the customer.',
      time: '18 min ago',
      icon: Icons.local_shipping_outlined,
      accent: AppColors.green,
    ),
    _NotificationItem(
      title: 'New user added',
      message: 'A new customer profile was created for Rajesh Kumar.',
      time: '1 hour ago',
      icon: Icons.person_add_alt_1_rounded,
      accent: AppColors.blue,
    ),
    _NotificationItem(
      title: 'Payment due',
      message: 'Invoice #INV-8824 is due today. Follow up with the customer.',
      time: '3 hours ago',
      icon: Icons.payments_outlined,
      accent: AppColors.red,
    ),
  ];

  void _markAsRead(int index) {
    setState(() {
      _items[index].isRead = true;
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _items.where((item) => !item.isRead).length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.primary,
      drawer: const AppDrawer(activeItem: 'Notifications'),
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Notifications',
              leadingIcon: Icons.menu_rounded,
              onLeadingTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifications',
                                style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Keep track of important system and business updates',
                                style: TextStyle(color: textSecondary, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$unreadCount unread',
                            style: const TextStyle(
                              color: AppColors.purple,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No notifications available.',
                            style: TextStyle(color: textSecondary, fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ..._items.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _notificationCard(entry.key, entry.value),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard(int index, _NotificationItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: item.isRead ? AppColors.primary : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: item.isRead ? AppColors.secondary.withValues(alpha: 0.16) : item.accent.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: item.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15.5,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.purple,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.message,
                  style: const TextStyle(color: textSecondary, fontSize: 12.8, height: 1.35),
                ),
                const SizedBox(height: 8),
                Text(
                  item.time,
                  style: const TextStyle(color: textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                onPressed: item.isRead ? null : () => _markAsRead(index),
                icon: Icon(
                  item.isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                  color: item.isRead ? AppColors.green : AppColors.purple,
                  size: 20,
                ),
                tooltip: item.isRead ? 'Marked as read' : 'Mark as read',
                style: IconButton.styleFrom(
                  backgroundColor: (item.isRead ? AppColors.green : AppColors.purple).withValues(alpha: 0.08),
                ),
              ),
              IconButton(
                onPressed: () => _deleteNotification(index),
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 20),
                tooltip: 'Delete notification',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.red.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color accent;
  bool isRead;

  _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.accent,
    this.isRead = false,
  });
}
