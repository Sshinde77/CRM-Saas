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
      child: SalesManagerSidebar(onSelect: onSelect, currentPage: currentPage),
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
      const _SidebarItem('Dashboard', Icons.dashboard_outlined),
      const _SidebarItem('Customers', Icons.groups_outlined),
      const _SidebarItem('Leads', Icons.person_add_alt_1_outlined),
      const _SidebarItem('Quotations', Icons.description_outlined),
      const _SidebarItem('Create Order', Icons.shopping_cart_outlined),
      const _SidebarItem('Stock', Icons.inventory_2_outlined),
      const _SidebarItem('Visits', Icons.place_outlined),
      const _SidebarItem('Follow-ups', Icons.notifications_active_outlined),
      const _SidebarItem('Attendance', Icons.fact_check_outlined),
      const _SidebarItem('My Performance', Icons.bar_chart_outlined),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.adminSidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.border.withValues(alpha: 0.45)),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Text(
                'MAIN MENU',
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.72),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected = _isSelected(item.label, currentPage);

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => onSelect(item.label),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.activeMenuBg.withValues(alpha: 0.86)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary.withValues(alpha: 0.18)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 4,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                item.icon,
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.label,
                                  style: TextStyle(
                                    color: selected
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                    fontSize: 13.5,
                                    fontWeight: selected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSelected(String itemLabel, String currentPage) {
    if (itemLabel == currentPage) return true;
    if (itemLabel == 'Create Order' && currentPage == 'Sales Orders') {
      return true;
    }
    if (itemLabel == 'Follow-ups' && currentPage == 'Follow-Ups') {
      return true;
    }
    return false;
  }
}

class _SidebarItem {
  final String label;
  final IconData icon;

  const _SidebarItem(this.label, this.icon);
}
