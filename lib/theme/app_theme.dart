import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../core/theme/app_sizes.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'Poppins',
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        outline: AppColors.secondary,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.secondary,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.primary),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.controlRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.controlRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primary,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: const BorderSide(color: AppColors.secondary),
        ),
      ),
    );
  }
}
