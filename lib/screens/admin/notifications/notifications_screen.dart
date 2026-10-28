import 'package:flutter/material.dart';
import '../../../widgets/app_skeleton.dart';

import '../../../constants/app_colors.dart';
import '../../../models/list_pagination.dart';
import '../../../models/notification_model.dart';
import '../../../providers/api_provider.dart';
import '../../../services/api_service.dart';
import '../../../widgets/admin/admin_top_bar.dart';
import '../../../widgets/list_pagination_bar.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  ApiService get _api => ApiProviderScope.of(context).service;
  final _pagination = ListPagination();
  List<NotificationModel> _items = const [];
  bool _loading = true;
  int _unreadCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pagination.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final result = await _api.fetchNotifications(pagination: _pagination);
      try {
        _unreadCount = await _api.fetchUnreadNotificationCount();
      } catch (_) {
        // Keep the list usable if an older deployment lacks this endpoint.
      }
      if (!mounted) return;
      setState(() {
        _items = result.items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _markRead(NotificationModel item) async {
    if (item.isRead || item.id.isEmpty) return;
    try {
      await _api.markNotificationRead(item.id);
      await _load();
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await _api.markAllNotificationsRead();
      await _load();
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(error.toString())));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Column(
        children: [
          AdminTopBar(
            title: 'Notifications',
            leadingIcon: Icons.arrow_back_rounded,
            onLeadingTap: () => Navigator.of(context).maybePop(),
            showNotification: false,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _loading || _items.every((item) => item.isRead)
                    ? null
                    : _markAllRead,
                icon: const Icon(Icons.done_all_rounded, size: 18),
                label: Text('Unread: $_unreadCount  •  Mark all as read'),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(onRefresh: _load, child: _buildContent()),
          ),
        ],
      ),
    ),
  );

  Widget _buildContent() {
    if (_loading && _items.isEmpty) {
      return const AppPageSkeleton(rows: 7, showHeader: false);
    }
    if (_error != null && _items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Text(
              'Unable to load notifications.',
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: TextButton(onPressed: _load, child: const Text('Retry')),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 100),
          Center(child: Text('No notifications available.')),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: _items.length + 1,
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return ListPaginationBar(
            pagination: _pagination,
            loading: _loading,
            onChanged: _load,
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _notificationCard(_items[index]),
        );
      },
    );
  }

  Widget _notificationCard(NotificationModel item) {
    final accent = _accentFor(item.type);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _markRead(item),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.primary : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_iconFor(item.type), color: accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.body,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(item.createdAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: item.isRead ? null : () => _markRead(item),
              icon: Icon(
                item.isRead
                    ? Icons.mark_email_read_outlined
                    : Icons.mark_email_unread_outlined,
                color: item.isRead ? AppColors.green : AppColors.purple,
              ),
              tooltip: item.isRead ? 'Read' : 'Mark as read',
            ),
          ],
        ),
      ),
    );
  }

  Color _accentFor(String type) => switch (type) {
    'order' => AppColors.blue,
    'delivery' => AppColors.green,
    'success' => AppColors.green,
    'expense' => AppColors.red,
    'leave' => AppColors.amber,
    _ => AppColors.purple,
  };

  IconData _iconFor(String type) => switch (type) {
    'order' => Icons.receipt_long_outlined,
    'delivery' => Icons.local_shipping_outlined,
    'success' => Icons.check_circle_outline_rounded,
    'expense' => Icons.payments_outlined,
    'leave' => Icons.event_note_outlined,
    _ => Icons.notifications_none_rounded,
  };

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}';
  }
}
