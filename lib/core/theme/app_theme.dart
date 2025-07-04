import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/opacity_tokens.dart';
import 'package:nurseos_v3/core/theme/typography.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.light.surface,
      colorScheme: ColorScheme.light(
        primary: AppColors.light.primary,
        surface: AppColors.light.surface,
        onPrimary: AppColors.light.onPrimary,
        onSurface: AppColors.light.onSurface,
      ),
      textTheme: AppTypography.textTheme,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.light.subdued.withAlpha(OpacityTokens.hintText),
        ),
        labelStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.light.text,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.light.onSurface.withAlpha(OpacityTokens.low),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.light.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.light.danger,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.light.danger,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(SpacingTokens.md),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.light.text,
        ),
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
      textTheme: AppTypography.textTheme,
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.dark.subdued.withAlpha(OpacityTokens.hintText),
        ),
        labelStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.dark.text,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.dark.onSurface.withAlpha(OpacityTokens.low),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.dark.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.dark.danger,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.dark.danger,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(SpacingTokens.md),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.dark.text,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        AppColors.dark,
      ],
      useMaterial3: true,
    );
  }
}
