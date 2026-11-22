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
    required this.navBarBackground,
    required this.navBarBubble,
  });

  final Color primary;
  final Color inputField;
  final Color white;
  final Color textPrimary;
  final Color textSecondary;
  final Color background;
  final Color surface;
  final Color error;
  final Color navBarBackground;
  final Color navBarBubble;

  static const AppPalette light = AppPalette(
    primary:       Color(0xFF1E41BC),
    inputField:    Color(0xFF017DB0),
    white:         Color(0xFFFFFFFF),
    textPrimary:   Color(0xFF1A1A2E),
    textSecondary: Color(0xFF6B7280),
    background:    Color(0xFFF5F7FA),
    surface:       Color(0xFFFFFFFF),
    error:         Color(0xFFE53935),
    navBarBackground: Color(0xFFE5E5E5),
    navBarBubble:     Color(0xFF3871FE),
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
    navBarBackground: Color(0xFF2E2E2E),
    navBarBubble:     Color(0xFF3871FE),
  );
}

extension AppColorsX on BuildContext {
  AppPalette get colors =>
      Theme.of(this).brightness == Brightness.dark
          ? AppPalette.dark
          : AppPalette.light;
}

class AppChartColors {
  AppChartColors._();

  static const List<Color> barPalette = <Color>[
    Color(0xFFE53935),
    Color(0xFF1E41BC),
    Color(0xFF26A69A),
    Color(0xFFFFB300),
  ];

  static const Color requested = Color(0xFFB026FF);
  static const Color offered = Color(0xFF1E41BC);
  static const Color axis = Color(0xFF2F80ED);
  static const Color gaugeProgress = Color(0xFF1E41BC);
  static const Color gaugeTrack = Color(0xFF6FA8FF);
  static const Color star = Color(0xFFFFB300);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient headerBlue = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      Color(0xFF0119DD),
      Color(0xFF0064D8),
      Color(0xFF3697EB),
    ],
  );
}
