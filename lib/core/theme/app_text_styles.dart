import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const String fontFamily = 'Poppins';

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle screenHeading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const TextStyle secondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static const TextStyle secondaryStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w800,
    color: AppColors.textMuted,
  );

  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static const TextStyle smallStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w800,
    color: AppColors.textMuted,
  );

  static const TextStyle importantNumber = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.15,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const TextStyle bottomNavLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardBody = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextTheme textTheme = TextTheme(
    displayLarge: screenHeading,
    displayMedium: screenHeading,
    displaySmall: screenHeading,
    headlineLarge: screenHeading,
    headlineMedium: screenHeading,
    headlineSmall: screenHeading,
    titleLarge: sectionHeading,
    titleMedium: cardTitle,
    titleSmall: bodyStrong,
    bodyLarge: body,
    bodyMedium: cardBody,
    bodySmall: secondary,
    labelLarge: bodyStrong,
    labelMedium: secondaryStrong,
    labelSmall: smallStrong,
  );
}
