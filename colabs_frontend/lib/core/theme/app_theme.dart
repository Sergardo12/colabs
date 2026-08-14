import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    scaffoldBackgroundColor: AppPalette.light.background,
    colorScheme: ColorScheme.light(
      primary:   AppPalette.light.primary,
      surface:   AppPalette.light.surface,
      onSurface: AppPalette.light.textPrimary,
      error:     AppPalette.light.error,
    ),
    fontFamily: 'Roboto',
    iconTheme: IconThemeData(color: AppPalette.light.primary),
    appBarTheme: AppBarTheme(
      backgroundColor: AppPalette.light.surface,
      foregroundColor: AppPalette.light.textPrimary,
      elevation:       0,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: AppPalette.light.surface,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:    AppPalette.light.surface,
      selectedItemColor:  AppPalette.light.primary,
      unselectedItemColor: AppPalette.light.textSecondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:  AppPalette.light.primary,
        foregroundColor:  AppPalette.light.white,
        minimumSize:      const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
      ),
    ),
    inputDecorationTheme: _inputDecorationTheme(AppPalette.light),
  );

  static ThemeData get dark => ThemeData(
    scaffoldBackgroundColor: AppPalette.dark.background,
    colorScheme: ColorScheme.dark(
      primary:   AppPalette.dark.primary,
      surface:   AppPalette.dark.surface,
      onSurface: AppPalette.dark.textPrimary,
      error:     AppPalette.dark.error,
    ),
    fontFamily: 'Roboto',
    iconTheme: IconThemeData(color: AppPalette.dark.textPrimary),
    appBarTheme: AppBarTheme(
      backgroundColor: AppPalette.dark.surface,
      foregroundColor: AppPalette.dark.textPrimary,
      elevation:       0,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: AppPalette.dark.surface,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor:    AppPalette.dark.surface,
      selectedItemColor:  AppPalette.dark.textPrimary,
      unselectedItemColor: AppPalette.dark.textSecondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:  AppPalette.dark.primary,
        foregroundColor:  AppPalette.dark.white,
        minimumSize:      const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
      ),
    ),
    inputDecorationTheme: _inputDecorationTheme(AppPalette.dark),
  );

  static InputDecorationTheme _inputDecorationTheme(AppPalette palette) {
    return InputDecorationTheme(
      filled:      true,
      fillColor:   palette.inputField.withOpacity(0.15),
      hintStyle:   TextStyle(color: palette.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide:   BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide:   BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide:   BorderSide(color: AppPalette.light.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide:   BorderSide(color: AppPalette.light.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical:   AppSizes.paddingS,
      ),
    );
  }
}
