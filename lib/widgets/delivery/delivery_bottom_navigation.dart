import 'package:flutter/material.dart';

import '../../constants/api_constants.dart';
import '../../constants/app_colors.dart';
import '../../providers/api_provider.dart';
import '../../routes/app_router.dart';
import '../../screens/delivery/customers/create_delivery_customer_screen.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final scale = (width / 390).clamp(0.82, 1.0).toDouble();

            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16 * scale,
                  16 * scale,
                  16 * scale,
                  96 * scale,
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: SizedBox(
                    width: 420 * scale,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(6 * scale),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _OrderActionTile(
                              icon: Icons.account_balance_wallet_outlined,
                              color: AppColors.deliveryKpiMintIcon,
                              background: AppColors.deliveryKpiMintBg,
                              label: 'Create Collection',
                              scale: scale,
                              onTap: () =>
                                  Navigator.pop(menuContext, 'collection'),
                            ),
                          ),
                          SizedBox(width: 6 * scale),
                          Expanded(
                            child: _OrderActionTile(
                              icon: Icons.shopping_bag_outlined,
                              color: AppColors.deliveryKpiYellowIcon,
                              background: AppColors.deliveryKpiYellowBg,
                              label: 'Create Orders',
                              scale: scale,
                              onTap: () => Navigator.pop(menuContext, 'create'),
                            ),
                          ),
                          SizedBox(width: 6 * scale),
                          Expanded(
                            child: _OrderActionTile(
                              icon: Icons.person_outline_rounded,
                              color: AppColors.deliveryKpiAquaIcon,
                              background: AppColors.deliveryKpiAquaBg,
                              label: 'Create Customer',
                              scale: scale,
                              onTap: () =>
                                  Navigator.pop(menuContext, 'customer'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
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
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateDeliveryCustomerScreen()),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateDeliveryOrderScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 0.9, maxScaleFactor: 1.2);
    const items = [
      _BottomNavInfo(Icons.home_rounded, 'Dashboard'),
      _BottomNavInfo(Icons.assignment_outlined, 'Orders'),
      _BottomNavInfo(Icons.add_rounded, 'Order actions'),
      _BottomNavInfo(Icons.event_available_outlined, 'Attendance'),
      _BottomNavInfo(Icons.account_balance_wallet_outlined, 'Collections'),
    ];

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final scale = (width / 390).clamp(0.82, 1.0).toDouble();
            final navHeight = 72.0 * scale;
            final fabOuterSize = 68.0 * scale;
            final fabIconSize = 30.0 * scale;
            final centerGap = fabOuterSize + (14.0 * scale);

            return SizedBox(
              height: navHeight + (22.0 * scale),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: navHeight,
                      padding: EdgeInsets.symmetric(
                        horizontal: 6 * scale,
                        vertical: 7 * scale,
                      ),
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
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _BottomNavItem(
                                    info: items[0],
                                    selected: currentIndex == 0,
                                    scale: scale,
                                    onTap: () => _navigate(context, 0),
                                  ),
                                ),
                                Expanded(
                                  child: _BottomNavItem(
                                    info: items[1],
                                    selected: currentIndex == 1,
                                    scale: scale,
                                    onTap: () => _navigate(context, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: centerGap),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: _BottomNavItem(
                                    info: items[3],
                                    selected: currentIndex == 3,
                                    scale: scale,
                                    onTap: () => _navigate(context, 3),
                                  ),
                                ),
                                Expanded(
                                  child: _BottomNavItem(
                                    info: items[4],
                                    selected: currentIndex == 4,
                                    scale: scale,
                                    onTap: () => _navigate(context, 4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: fabOuterSize,
                      height: fabOuterSize,
                      child: DecoratedBox(
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
                        child: Padding(
                          padding: EdgeInsets.all(4 * scale),
                          child: IconButton.filled(
                            onPressed: () => _navigate(context, 2),
                            tooltip: 'Create actions',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.surface,
                              minimumSize: Size.square(44 * scale),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                              shape: const CircleBorder(),
                            ),
                            icon: Icon(Icons.add_rounded, size: fabIconSize),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final double scale;
  final VoidCallback onTap;

  const _OrderActionTile({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tileSize = 54.0 * scale;
    final badgeSize = 16.0 * scale;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14 * scale),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 3 * scale,
          vertical: 7 * scale,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: tileSize,
              height: tileSize,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(16 * scale),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: color, size: 24 * scale),
                  Positioned(
                    right: 5 * scale,
                    bottom: 5 * scale,
                    child: Container(
                      width: badgeSize,
                      height: badgeSize,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: background, width: 1.5),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: AppColors.surface,
                        size: 11 * scale,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8 * scale),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11 * scale,
                  height: 1.05,
                  fontWeight: FontWeight.w700,
                  color: AppColors.surface,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
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
  final double scale;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.info,
    required this.selected,
    required this.scale,
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
        constraints: BoxConstraints(minHeight: 48 * scale),
        margin: EdgeInsets.symmetric(horizontal: 2 * scale),
        padding: EdgeInsets.symmetric(
          horizontal: 3 * scale,
          vertical: 6 * scale,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.deliveryDashboardNavActive
              : Colors.transparent,
          borderRadius: BorderRadius.circular(13 * scale),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              info.icon,
              color: selected ? AppColors.primary : AppColors.surface,
              size: (selected ? 23 : 21) * scale,
            ),
            SizedBox(height: 3 * scale),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                info.label,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: selected
                      ? AppColors.primary
                      : AppColors.surface.withValues(alpha: 0.88),
                  fontSize: 11.5 * scale,
                  height: 1.05,
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
