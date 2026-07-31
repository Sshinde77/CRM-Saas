import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class SalesManagerSidebarDrawer extends StatelessWidget {
  final ValueChanged<String> onSelect;
  final String currentPage;

  const SalesManagerSidebarDrawer({
    super.key,
    required this.onSelect,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.adminSidebarBg,
      child: SalesManagerSidebar(
        onSelect: onSelect,
        currentPage: currentPage,
      ),
    );
  }
}

class SalesManagerSidebar extends StatelessWidget {
  final ValueChanged<String> onSelect;
  final String currentPage;

  const SalesManagerSidebar({
    super.key,
    required this.onSelect,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_SidebarItem>[
      const _SidebarItem('Dashboard', Icons.dashboard_rounded),
      const _SidebarItem('Customers', Icons.groups_rounded),
      const _SidebarItem('Sales Orders', Icons.receipt_long_rounded),
      const _SidebarItem('Visits', Icons.place_rounded),
      const _SidebarItem('Follow-Ups', Icons.notifications_active_rounded),
      const _SidebarItem('Attendance', Icons.fact_check_rounded),
      const _SidebarItem('Notifications', Icons.notifications_rounded),
      const _SidebarItem('Products', Icons.inventory_2_rounded),
      const _SidebarItem('Outstanding & Payments', Icons.payments_rounded),
      const _SidebarItem('Reports', Icons.bar_chart_rounded),
      const _SidebarItem('Settings', Icons.settings_rounded),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.adminSidebarBg.withValues(alpha: 0.72),
        border: Border(
          right: BorderSide(color: AppColors.border.withValues(alpha: 0.65)),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SAAS CRM',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Sales Manager',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: AppColors.border.withValues(alpha: 0.75),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = item.label == currentPage;

                  return Material(
                    color: selected ? AppColors.activeMenuBg : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => onSelect(item.label),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppColors.activeMenuBg
                                : AppColors.border.withValues(alpha: 0.7),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontSize: 13.5,
                                  fontWeight: selected
                                      ? FontWeight.w800
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                            if (!selected)
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textLightMuted,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: AppColors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Check-Out',
                        style: TextStyle(
                          color: AppColors.red,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textLightMuted,
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
}

class _SidebarItem {
  final String label;
  final IconData icon;

  const _SidebarItem(this.label, this.icon);
}
