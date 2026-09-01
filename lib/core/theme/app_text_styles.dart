import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle screenHeading = TextStyle(
    fontSize: 20,
    height: 1.2,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle secondary = TextStyle(
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static const TextStyle secondaryStrong = TextStyle(
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w800,
    color: AppColors.textMuted,
  );

  static const TextStyle small = TextStyle(
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static const TextStyle smallStrong = TextStyle(
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w800,
    color: AppColors.textMuted,
  );

  static const TextStyle importantNumber = TextStyle(
    fontSize: 22,
    height: 1.15,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const TextStyle bottomNavLabel = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
  );
}
