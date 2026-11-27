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
    primary: Color(0xFF1E41BC),
    inputField: Color(0xFF017DB0),
    white: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFF6B7280),
    background: Color(0xFFF5F7FA),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFE53935),
    navBarBackground: Color(0xFFE5E5E5),
    navBarBubble: Color(0xFF3871FE),
  );

  static const AppPalette dark = AppPalette(
    primary: Color(0xFF1E41BC),
    inputField: Color(0xFF017DB0),
    white: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0B3B8),
    background: Color(0xFF1C1C1C),
    surface: Color(0xFF2A2A2A),
    error: Color(0xFFE53935),
    navBarBackground: Color(0xFF2E2E2E),
    navBarBubble: Color(0xFF3871FE),
  );
}

extension AppColorsX on BuildContext {
  AppPalette get colors => Theme.of(this).brightness == Brightness.dark
      ? AppPalette.dark
      : AppPalette.light;
}

class AppChartColors {
  AppChartColors._();

  static const List<Color> barPalette = <Color>[
    Color(0xFFD32F2F),
    Color(0xFF1976D2),
    Color(0xFF00A86B),
    Color(0xFFFBC02D),
    Color(0xFFF57C00),
    Color(0xFF8E24AA),
    Color(0xFF00ACC1),
    Color(0xFFE91E63),
    Color(0xFF7CB342),
    Color(0xFF3949AB),
    Color(0xFF00897B),
    Color(0xFF8D6E63),
  ];

  static const Color requested = Color(0xFFB026FF);
  static const Color offered = Color(0xFF1E41BC);
  static const Color axis = Color.fromARGB(255, 255, 128, 0);
  static const Color gaugeProgress = Color.fromARGB(255, 255, 128, 0);
  static const Color gaugeTrack = Color.fromARGB(255, 255, 255, 255);
  static const Color star = Color(0xFF2F80ED);
}

class AppGradients {
  AppGradients._();

  static const LinearGradient headerBlue = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[Color(0xFF0119DD), Color(0xFF0064D8), Color(0xFF3697EB)],
  );
}
