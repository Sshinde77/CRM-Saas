import 'package:flutter/material.dart';

import '../../../../constants/app_colors.dart';
import '../../../../core/theme/app_sizes.dart';
import '../../../../core/theme/app_spacing.dart';

class EndOfDayCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const EndOfDayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.card),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.deliverySurfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class EndOfDayErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const EndOfDayErrorBanner({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFB4B4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.deliveryRed,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFB00000),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          InkWell(
            onTap: onDismiss,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class EndOfDayProductImage extends StatelessWidget {
  final String imageUrl;

  const EndOfDayProductImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E7F0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF4A546B),
              size: 20,
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF4A546B),
                  size: 20,
                );
              },
            ),
    );
  }
}

class VarianceBadge extends StatelessWidget {
  final double variance;

  const VarianceBadge({super.key, required this.variance});

  @override
  Widget build(BuildContext context) {
    final matched = variance == 0;
    final surplus = variance > 0;
    final color = matched
        ? const Color(0xFF0D8C28)
        : surplus
        ? const Color(0xFF2563EB)
        : AppColors.deliveryRed;
    final label = matched
        ? 'Matched'
        : surplus
        ? '+${qty(variance)} Surplus'
        : '${qty(variance.abs())} Shortage';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

String qty(double value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(1);
}
