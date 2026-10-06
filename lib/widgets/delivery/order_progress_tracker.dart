import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class OrderProgressTracker extends StatelessWidget {
  const OrderProgressTracker({super.key, required this.status});

  final String status;

  static const _steps = <String>[
    'Ordered',
    'Pending',
    'Accepted',
    'In Transit',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final normalized = status.trim().toLowerCase().replaceAll(' ', '_');
    final isCancelled = const {
      'cancelled',
      'canceled',
      'rejected',
      'failed',
    }.contains(normalized);
    final currentStep = _stepForStatus(normalized);

    return Semantics(
      label: isCancelled
          ? 'Order progress. Order cancelled.'
          : 'Order progress. Current status ${_steps[currentStep]}.',
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.deliverySurfaceBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.route_rounded,
                  size: 20,
                  color: AppColors.deliveryGreen,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Order Progress',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                if (isCancelled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.deliveryRed.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Cancelled',
                      style: TextStyle(
                        color: AppColors.deliveryRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_steps.length, (index) {
                final isCancelledStep = isCancelled && index == currentStep;
                final isCompleted = (!isCancelled && index <= currentStep) ||
                    (isCancelled && index < currentStep);
                final connectorCompleted = isCancelled
                    ? index < currentStep
                    : index <= currentStep;

                return Expanded(
                  child: _ProgressStep(
                    number: index + 1,
                    label: isCancelledStep ? 'Cancelled' : _steps[index],
                    completed: isCompleted,
                    cancelled: isCancelledStep,
                    leftConnected: index > 0 && connectorCompleted,
                    rightConnected:
                        index < _steps.length - 1 && index < currentStep,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  int _stepForStatus(String value) => switch (value) {
    'ordered' || 'draft' => 0,
    'pending' || 'planned' || 'assigned' || 'confirmed' => 1,
    'accepted' || 'ready' || 'loaded' => 2,
    'in_transit' || 'failed' => 3,
    'delivered' || 'completed' || 'partially_delivered' => 4,
    'cancelled' || 'canceled' || 'rejected' => 1,
    _ => 0,
  };
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.number,
    required this.label,
    required this.completed,
    required this.cancelled,
    required this.leftConnected,
    required this.rightConnected,
  });

  final int number;
  final String label;
  final bool completed;
  final bool cancelled;
  final bool leftConnected;
  final bool rightConnected;

  @override
  Widget build(BuildContext context) {
    final stateColor = cancelled
        ? AppColors.deliveryRed
        : AppColors.deliveryGreen;
    const pendingColor = Color(0xFFD8E4DC);

    return Column(
      children: [
        SizedBox(
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0,
                right: 0,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: number == 1
                            ? Colors.transparent
                            : leftConnected
                            ? AppColors.deliveryGreen
                            : pendingColor,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: number == 5
                            ? Colors.transparent
                            : rightConnected
                            ? AppColors.deliveryGreen
                            : pendingColor,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: completed ? stateColor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: stateColor, width: 1.5),
                  boxShadow: completed
                      ? [
                          BoxShadow(
                            color: stateColor.withValues(alpha: 0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: completed ? Colors.white : stateColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cancelled
                ? AppColors.deliveryRed
                : completed
                ? AppColors.deliveryInk
                : AppColors.textMuted,
            fontSize: 10,
            height: 1.15,
            fontWeight: completed || cancelled
                ? FontWeight.w700
                : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
