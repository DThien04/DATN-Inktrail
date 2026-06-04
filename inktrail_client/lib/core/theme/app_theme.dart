import 'package:flutter/material.dart';

class AppTheme {
  static const _primary = Color(0xFFC4773B);
  /// Neutral seed so light `surfaceContainer*` / tonal surfaces stay gray, not peach.
  static const _lightSchemeSeed = Color(0xFF64748B);
  static const _lightScaffold = Color(0xFFF8F9FA);
  static const _darkBg = Color(0xFF13100E);

  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: _lightScaffold,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _lightSchemeSeed,
      primary: _primary,
      surface: _lightScaffold,
    ),
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1A1A1A),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: _primary),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBg,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: _primary,
      primary: _primary,
      surface: _darkBg,
    ),
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1B1715),
      foregroundColor: Color(0xFFF6EFE6),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFFF6EFE6),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: _primary),
  );
}
