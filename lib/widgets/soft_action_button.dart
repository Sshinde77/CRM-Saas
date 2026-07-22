import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class SoftActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const SoftActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.color = AppColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final contentColor = isEnabled ? color : color.withValues(alpha: 0.65);

    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22, color: contentColor),
        label: Text(
          label,
          style: TextStyle(
            color: contentColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: contentColor,
          disabledForegroundColor: contentColor,
          backgroundColor: color.withValues(alpha: 0.08),
          side: BorderSide(color: color.withValues(alpha: 0.26), width: 1.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
