import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class SuperAdminSidebarDrawer extends StatelessWidget {
  final String currentPage;
  final ValueChanged<String> onSelect;

  const SuperAdminSidebarDrawer({
    super.key,
    required this.currentPage,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.adminSidebarBg,
      child: SuperAdminSidebar(
        currentPage: currentPage,
        onSelect: onSelect,
      ),
    );
  }
}

class SuperAdminSidebar extends StatelessWidget {
  final String currentPage;
  final ValueChanged<String> onSelect;

  const SuperAdminSidebar({
    super.key,
    required this.currentPage,
    required this.onSelect,
  });

  static const List<_SidebarItem> _items = [
    _SidebarItem('Dashboard', Icons.dashboard_outlined),
    _SidebarItem('Organizations', Icons.apartment_outlined),
    _SidebarItem('Upgrade Requests', Icons.upgrade_outlined),
    _SidebarItem('Plans', Icons.workspace_premium_outlined),
    _SidebarItem('Platform Analytics', Icons.bar_chart_outlined),
  ];

  @override
  Widget build(BuildContext context) {
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
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SAAS CRM',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Super Admin',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
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
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 16),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final selected = item.label == currentPage;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        onSelect(item.label);
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
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
                                duration: const Duration(milliseconds: 160),
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
                                size: 20,
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
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
}

class _SidebarItem {
  final String label;
  final IconData icon;

  const _SidebarItem(this.label, this.icon);
}
