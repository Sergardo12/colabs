import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      error:   AppColors.error,
    ),
    fontFamily: 'Roboto',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor:  AppColors.primary,
        foregroundColor:  AppColors.white,
        minimumSize:      const Size(double.infinity, AppSizes.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled:      true,
      fillColor:   AppColors.inputField.withOpacity(0.15),
      hintStyle:   const TextStyle(color: AppColors.textSecondary),
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
        borderSide:   const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        borderSide:   const BorderSide(color: AppColors.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSizes.paddingM,
      vertical:   AppSizes.paddingS,
      ),
    ),    
  );
}