import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    const seedColor = Color(0xFF0B6E4F);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
      scaffoldBackgroundColor: const Color(0xFFF7FAF8),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
      ),
    );
  }
}
