import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../routes/app_router.dart';
import '../sidebar_logout_button.dart';

class DeliveryPartnerSidebar extends StatelessWidget {
  final String currentRoute;

  const DeliveryPartnerSidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF7F9FC),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: _SidebarHeader(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                children: [
                  for (final item in _deliveryMenuItems)
                    _SidebarItemTile(
                      item: item,
                      active: item.route == currentRoute,
                      onTap: () => _handleNavigation(context, item),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            const SidebarLogoutButton(),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, _DeliveryMenuItem item) {
    Navigator.of(context).pop();

    if (item.route == currentRoute) {
      return;
    }

    switch (item.route) {
      case AppRoutes.deliveryDashboard:
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.deliveryDashboard,
          (route) => false,
        );
      case AppRoutes.deliveryDeliveries:
        Navigator.of(context).pushNamed(AppRoutes.deliveryDeliveries);
      case AppRoutes.deliveryCustomers:
        Navigator.of(context).pushNamed(AppRoutes.deliveryCustomers);
      case AppRoutes.deliveryCollections:
        Navigator.of(context).pushNamed(AppRoutes.deliveryCollections);
      case AppRoutes.deliveryVehicleStock:
        Navigator.of(context).pushNamed(AppRoutes.deliveryVehicleStock);
      case AppRoutes.deliveryVehicleLoading:
        Navigator.of(context).pushNamed(AppRoutes.deliveryVehicleLoading);
      case AppRoutes.deliveryAttendance:
        Navigator.of(context).pushNamed(AppRoutes.deliveryAttendance);
      case AppRoutes.deliveryLeaves:
        Navigator.of(context).pushNamed(AppRoutes.deliveryLeaves);
      case AppRoutes.deliveryExpenses:
        Navigator.of(context).pushNamed(AppRoutes.deliveryExpenses);
      case AppRoutes.deliveryEndOfDay:
        Navigator.of(context).pushNamed(AppRoutes.deliveryEndOfDay);
      default:
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('${item.label} screen is coming next.')),
          );
    }
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary900, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.deliveryHeroShadow.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          _SidebarBrandMark(),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delivery Partner',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Route operations',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.activeMenuBg,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarBrandMark extends StatelessWidget {
  const _SidebarBrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.buttonHeight,
      height: AppSizes.buttonHeight,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: const Icon(
        Icons.delivery_dining_rounded,
        color: AppColors.activeMenuBg,
        size: AppSizes.iconLarge,
      ),
    );
  }
}

class _SidebarItemTile extends StatelessWidget {
  final _DeliveryMenuItem item;
  final bool active;
  final VoidCallback onTap;

  const _SidebarItemTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : const Color(0xFF4F5870);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: active ? AppColors.activeMenuBg : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: Container(
            height: AppSizes.buttonHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: active
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.18))
                  : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Icon(item.icon, size: AppSizes.iconMedium, color: color),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (active ? AppTextStyles.bodyStrong : AppTextStyles.body)
                            .copyWith(
                              color: active
                                  ? AppColors.deliveryInk
                                  : const Color(0xFF31394D),
                            ),
                  ),
                ),
                if (active)
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryMenuItem {
  final String label;
  final String route;
  final IconData icon;

  const _DeliveryMenuItem({
    required this.label,
    required this.route,
    required this.icon,
  });
}

const List<_DeliveryMenuItem> _deliveryMenuItems = [
  _DeliveryMenuItem(
    label: 'Dashboard',
    route: AppRoutes.deliveryDashboard,
    icon: Icons.dashboard_rounded,
  ),
  _DeliveryMenuItem(
    label: 'My Deliveries',
    route: AppRoutes.deliveryDeliveries,
    icon: Icons.inventory_2_outlined,
  ),
  _DeliveryMenuItem(
    label: 'Customers',
    route: AppRoutes.deliveryCustomers,
    icon: Icons.people_outline_rounded,
  ),
  _DeliveryMenuItem(
    label: 'Collections',
    route: AppRoutes.deliveryCollections,
    icon: Icons.account_balance_wallet_outlined,
  ),
  _DeliveryMenuItem(
    label: 'Vehicle Stock',
    route: AppRoutes.deliveryVehicleStock,
    icon: Icons.local_shipping_outlined,
  ),
  _DeliveryMenuItem(
    label: 'Attendance',
    route: AppRoutes.deliveryAttendance,
    icon: Icons.fact_check_outlined,
  ),
  _DeliveryMenuItem(
    label: 'Leaves',
    route: AppRoutes.deliveryLeaves,
    icon: Icons.event_busy_outlined,
  ),
  _DeliveryMenuItem(
    label: 'Expenses',
    route: AppRoutes.deliveryExpenses,
    icon: Icons.receipt_long_outlined,
  ),
];
