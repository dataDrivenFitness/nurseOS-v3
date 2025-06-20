import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.dark.background,
      textTheme: AppTypography.textTheme,
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColors.dark.primary,
        onPrimary: AppColors.dark.onPrimary,
        surface: AppColors.dark.surface,
        onSurface: AppColors.dark.onSurface,
        error: AppColors.dark.danger,
      ),
      extensions: const [
        AppColors.dark,
      ],
    );
  }

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.light.background,
      textTheme: AppTypography.textTheme,
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      colorScheme: const ColorScheme.light().copyWith(
        primary: AppColors.light.primary,
        onPrimary: AppColors.light.onPrimary,
        surface: AppColors.light.surface,
        onSurface: AppColors.light.onSurface,
        error: AppColors.light.danger,
      ),
      extensions: const [
        AppColors.light,
      ],
    );
  }
}
