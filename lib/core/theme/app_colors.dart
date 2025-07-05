import 'package:flutter/material.dart';

/// NurseOS Color Tokens — Refined for accessibility and cross-theme clarity
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primaryVariant;
  final Color background;
  final Color surface;
  final Color surfaceVariant; // ✅ NEW
  final Color onPrimary;
  final Color onSurface;
  final Color danger;
  final Color success;
  final Color warning;
  final Color text;
  final Color subdued;
  final Color brandPrimary;
  final Color brandAccent;
  final Color brandSecondary;
  final Color brandNeutral;
  final Color medicationPurple; // 💊 NEW - Purple for medications

  const AppColors({
    required this.primary,
    required this.primaryVariant,
    required this.background,
    required this.surface,
    required this.surfaceVariant, // ✅ NEW
    required this.onPrimary,
    required this.onSurface,
    required this.danger,
    required this.success,
    required this.warning,
    required this.text,
    required this.subdued,
    required this.brandPrimary,
    required this.brandAccent,
    required this.brandSecondary,
    required this.brandNeutral,
    required this.medicationPurple, // 💊 NEW
  });

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryVariant,
    Color? background,
    Color? surface,
    Color? surfaceVariant, // ✅ NEW
    Color? onPrimary,
    Color? onSurface,
    Color? danger,
    Color? success,
    Color? warning,
    Color? text,
    Color? subdued,
    Color? brandPrimary,
    Color? brandAccent,
    Color? brandSecondary,
    Color? brandNeutral,
    Color? medicationPurple, // 💊 NEW
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant, // ✅
      onPrimary: onPrimary ?? this.onPrimary,
      onSurface: onSurface ?? this.onSurface,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      text: text ?? this.text,
      subdued: subdued ?? this.subdued,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandAccent: brandAccent ?? this.brandAccent,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      brandNeutral: brandNeutral ?? this.brandNeutral,
      medicationPurple: medicationPurple ?? this.medicationPurple, // 💊 NEW
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryVariant: Color.lerp(primaryVariant, other.primaryVariant, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!, // ✅
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      text: Color.lerp(text, other.text, t)!,
      subdued: Color.lerp(subdued, other.subdued, t)!,
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandAccent: Color.lerp(brandAccent, other.brandAccent, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      brandNeutral: Color.lerp(brandNeutral, other.brandNeutral, t)!,
      medicationPurple:
          Color.lerp(medicationPurple, other.medicationPurple, t)!, // 💊 NEW
    );
  }

  static const dark = AppColors(
    primary: Color(0xFFA3BFFA),
    primaryVariant: Color(0xFF728EFD),
    background: Color(0xFF121620),
    surface: Color(0xFF1E2533),
    surfaceVariant: Color(0xFF2B3142), // ✅ DARK VARIANT
    onPrimary: Colors.black,
    onSurface: Color(0xFFE5E9FE),
    danger: Color(0xFFEF5350),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFFA000),
    text: Color(0xFFE5E9FE),
    subdued: Color(0xFF8A96A8),
    brandPrimary: Color(0xFFA3BFFA),
    brandAccent: Color(0xFF728EFD),
    brandSecondary: Color(0xFF607D8B),
    brandNeutral: Color(0xFF2C3445),
    medicationPurple: Color(0xFFB19CD9), // 💊 Lighter purple for dark mode
  );

  static const light = AppColors(
    primary: Color(0xFF0057D8),
    primaryVariant: Color(0xFF0041A3),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF1F5F9),
    surfaceVariant: Color(0xFFE8ECF2), // ✅ LIGHT VARIANT
    onPrimary: Colors.white,
    onSurface: Color(0xFF1E293B),
    danger: Color(0xFFD32F2F),
    success: Color(0xFF388E3C),
    warning: Color(0xFFF57C00),
    text: Color(0xFF1E293B),
    subdued: Color(0xFF64748B),
    brandPrimary: Color(0xFF0057D8),
    brandAccent: Color(0xFF3981F7),
    brandSecondary: Color(0xFFF368B3),
    brandNeutral: Color(0xFF94A3B8),
    medicationPurple: Color(0xFF8E44AD), // 💊 Rich purple for light mode
  );
}

/// Global opacity tokens for soft text and UI layering
class AppAlpha {
  static const softLabel = 153; // 0.6 * 255
  static const riskChip = 25; // 0.1 * 255
  static const dnrChip = 38; // 0.15 * 255
}
