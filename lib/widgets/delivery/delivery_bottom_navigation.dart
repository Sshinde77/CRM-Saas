import 'package:flutter/material.dart';

import '../../constants/api_constants.dart';
import '../../constants/app_colors.dart';
import '../../providers/api_provider.dart';
import '../../routes/app_router.dart';
import '../../screens/admin/customers/add_customer_screen.dart';
import '../../screens/delivery/orders/create_delivery_order_screen.dart';
import '../../screens/payment_collection_screen.dart';

class DeliveryBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Future<void> Function()? onCollectionCreated;

  const DeliveryBottomNavigation({
    required this.currentIndex,
    super.key,
    this.onCollectionCreated,
  });

  void _navigate(BuildContext context, int index) {
    if (index == 2) {
      _showOrderActions(context);
      return;
    }
    if (index == currentIndex) return;
    final route = switch (index) {
      0 => AppRoutes.deliveryDashboard,
      1 => AppRoutes.deliveryDeliveries,
      3 => AppRoutes.deliveryAttendance,
      4 => AppRoutes.deliveryCollections,
      _ => null,
    };
    if (route != null) Navigator.of(context).pushReplacementNamed(route);
  }

  Future<void> _showOrderActions(BuildContext context) async {
    final action = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      pageBuilder: (menuContext, animation, secondaryAnimation) => SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
            child: Material(
              type: MaterialType.transparency,
              child: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _OrderActionTile(
                          icon: Icons.add_card_rounded,
                          label: 'Create Collection',
                          onTap: () => Navigator.pop(menuContext, 'collection'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _OrderActionTile(
                          icon: Icons.add_shopping_cart_rounded,
                          label: 'Create Orders',
                          onTap: () => Navigator.pop(menuContext, 'create'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _OrderActionTile(
                          icon: Icons.person_add_alt_1_rounded,
                          label: 'Create Customer',
                          onTap: () => Navigator.pop(menuContext, 'customer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (!context.mounted || action == null) return;
    if (action == 'collection') {
      final provider = ApiProviderScope.of(context);
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => PaymentCollectionScreen(
            customersUrl:
                '${ApiConstants.baseUrl}${ApiEndpoints.customersList}',
            collectPaymentUrl:
                '${ApiConstants.baseUrl}${ApiEndpoints.customersPaymentsTemplate}',
            authToken: provider.session?.accessToken,
          ),
        ),
      );
      if (result == true && context.mounted) {
        await onCollectionCreated?.call();
      }
    } else if (action == 'customer') {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AddCustomerScreen()));
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateDeliveryOrderScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      _BottomNavInfo(Icons.home_rounded, 'Dashboard'),
      _BottomNavInfo(Icons.assignment_outlined, 'Orders'),
      _BottomNavInfo(Icons.add_rounded, 'Order actions'),
      _BottomNavInfo(Icons.event_available_outlined, 'Attendance'),
      _BottomNavInfo(Icons.account_balance_wallet_outlined, 'Collections'),
    ];

    return SafeArea(
      top: false,
      child: SizedBox(
        height: 100,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 76,
                margin: const EdgeInsets.fromLTRB(0, 6, 0, 0),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(0),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.deliveryDashboardNavStart,
                      AppColors.deliveryDashboardNavEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deliveryHeroShadow.withValues(
                        alpha: 0.22,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    for (var index = 0; index < items.length; index++)
                      Expanded(
                        child: index == 2
                            ? const SizedBox.shrink()
                            : _BottomNavItem(
                                info: items[index],
                                selected: currentIndex == index,
                                onTap: () => _navigate(context, index),
                              ),
                      ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.deliveryBackground,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deliveryHeroShadow.withValues(
                        alpha: 0.2,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton.filled(
                  onPressed: () => _navigate(context, 2),
                  tooltip: 'Create actions',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.deliveryDashboardNavActive,
                    foregroundColor: AppColors.surface,
                    shape: const CircleBorder(),
                  ),
                  icon: const Icon(Icons.add_rounded, size: 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OrderActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  AppColors.deliveryGreen.withValues(alpha: 0.10),
                  AppColors.surface,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: AppColors.deliveryGreen, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.surface,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final _BottomNavInfo info;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.info,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.deliveryDashboardNavActive.withValues(alpha: 0.78)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(info.icon, color: AppColors.surface, size: selected ? 25 : 23),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                info.label,
                maxLines: 1,
                style: TextStyle(
                  color: AppColors.surface.withValues(
                    alpha: selected ? 1 : 0.88,
                  ),
                  fontSize: selected ? 11 : 10,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavInfo {
  final IconData icon;
  final String label;

  const _BottomNavInfo(this.icon, this.label);
}
