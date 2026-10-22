import 'package:flutter/material.dart';

import '../core/theme/app_sizes.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'app_colors_ext.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData build(Color primary, {required bool dark}) {
    final colors = AppColorsExt.fromPrimary(primary, dark: dark);
    final textTheme = AppTextStyles.textTheme.apply(
      bodyColor: colors.text,
      displayColor: colors.text,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      borderSide: BorderSide(color: colors.border),
    );

    return ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      fontFamily: AppTextStyles.fontFamily,
      useMaterial3: true,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[colors],
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: colors.primary,
            brightness: dark ? Brightness.dark : Brightness.light,
          ).copyWith(
            primary: colors.primary,
            onPrimary: colors.onPrimary,
            secondary: colors.accent,
            onSecondary: colors.onAccent,
            surface: colors.surface,
            onSurface: colors.text,
            surfaceContainerHighest: colors.surfaceVariant,
            outline: colors.outline,
            error: colors.error,
            onError: AppColorsExt.foreground(colors.error),
            surfaceTint: Colors.transparent,
          ),
      scaffoldBackgroundColor: colors.background,
      dividerColor: colors.divider,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.primary,
        contentTextStyle: AppTextStyles.body.copyWith(color: colors.onPrimary),
        actionTextColor: colors.accent,
        closeIconColor: colors.onPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.controlRadius),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colors.appBar,
        foregroundColor: colors.onPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: kToolbarHeight,
        titleTextStyle: AppTextStyles.appBarTitle.copyWith(
          color: colors.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          side: BorderSide(color: colors.border),
        ),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: colors.drawer),
      listTileTheme: ListTileThemeData(
        titleTextStyle: AppTextStyles.cardTitle.copyWith(color: colors.text),
        subtitleTextStyle: AppTextStyles.cardBody.copyWith(
          color: colors.textSecondary,
        ),
        iconColor: colors.iconSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        minTileHeight: AppSizes.listTileHeight,
      ),
      chipTheme: ChipThemeData(
        labelStyle: AppTextStyles.secondaryStrong.copyWith(
          color: colors.textSecondary,
        ),
        secondaryLabelStyle: AppTextStyles.secondaryStrong.copyWith(
          color: colors.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.controlRadius),
        ),
        backgroundColor: colors.surfaceVariant,
        selectedColor: colors.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStatePropertyAll(colors.onPrimary),
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.surface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          textStyle: AppTextStyles.bodyStrong,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.controlRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: AppTextStyles.bodyStrong,
          foregroundColor: colors.primary,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          textStyle: AppTextStyles.bodyStrong,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.controlRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: AppTextStyles.bodyStrong,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          side: BorderSide(color: colors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.controlRadius),
          ),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        hintStyle: WidgetStatePropertyAll(
          AppTextStyles.inputHint.copyWith(color: colors.textSecondary),
        ),
        textStyle: WidgetStatePropertyAll(
          AppTextStyles.body.copyWith(color: colors.text),
        ),
        backgroundColor: WidgetStatePropertyAll(colors.inputFill),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTextStyles.inputHint.copyWith(color: colors.text),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: AppTextStyles.inputHint.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        labelStyle: AppTextStyles.fieldLabel.copyWith(
          color: colors.textSecondary,
        ),
        floatingLabelStyle: AppTextStyles.fieldLabel.copyWith(
          color: colors.text,
        ),
        hintStyle: AppTextStyles.inputHint.copyWith(
          color: colors.textSecondary,
        ),
        helperStyle: AppTextStyles.subtitle.copyWith(
          color: colors.textSecondary,
        ),
        errorStyle: AppTextStyles.small.copyWith(color: colors.error),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
      ),
    );
  }

  static ThemeData get lightTheme =>
      build(AppColorsExt.defaultPrimary, dark: false);
}
