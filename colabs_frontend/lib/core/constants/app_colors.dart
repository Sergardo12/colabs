import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette({
    required this.primary,
    required this.inputField,
    required this.white,
    required this.textPrimary,
    required this.textSecondary,
    required this.background,
    required this.surface,
    required this.error,
  });

  final Color primary;
  final Color inputField;
  final Color white;
  final Color textPrimary;
  final Color textSecondary;
  final Color background;
  final Color surface;
  final Color error;

  static const AppPalette light = AppPalette(
    primary:       Color(0xFF1E41BC),
    inputField:    Color(0xFF017DB0),
    white:         Color(0xFFFFFFFF),
    textPrimary:   Color(0xFF1A1A2E),
    textSecondary: Color(0xFF6B7280),
    background:    Color(0xFFF5F7FA),
    surface:       Color(0xFFFFFFFF),
    error:         Color(0xFFE53935),
  );

  static const AppPalette dark = AppPalette(
    primary:       Color(0xFF1E41BC),
    inputField:    Color(0xFF017DB0),
    white:         Color(0xFFFFFFFF),
    textPrimary:   Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0B3B8),
    background:    Color(0xFF1C1C1C),
    surface:       Color(0xFF2A2A2A),
    error:         Color(0xFFE53935),
  );
}

extension AppColorsX on BuildContext {
  AppPalette get colors =>
      Theme.of(this).brightness == Brightness.dark
          ? AppPalette.dark
          : AppPalette.light;
}
