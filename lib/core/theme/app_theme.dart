import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.light.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.light.primary,
        surface: AppColors.light.surface,
        onPrimary: AppColors.light.onPrimary,
        onSurface: AppColors.light.onSurface,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColors.light,
      ],
      useMaterial3: true,
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dark.background,
      colorScheme: ColorScheme.dark(
        primary: AppColors.dark.primary,
        surface: AppColors.dark.surface,
        onPrimary: AppColors.dark.onPrimary,
        onSurface: AppColors.dark.onSurface,
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColors.dark,
      ],
      useMaterial3: true,
    );
  }
}
