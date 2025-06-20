import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color primaryVariant;
  final Color background;
  final Color surface;
  final Color onPrimary;
  final Color onSurface;
  final Color danger;
  final Color success;
  final Color warning;
  final Color text;
  final Color subdued;

  // 🌈 Brand Tokens
  final Color brandPrimary;
  final Color brandAccent;
  final Color brandSecondary;
  final Color brandNeutral;

  const AppColors({
    required this.primary,
    required this.primaryVariant,
    required this.background,
    required this.surface,
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
  });

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryVariant,
    Color? background,
    Color? surface,
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
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryVariant: primaryVariant ?? this.primaryVariant,
      background: background ?? this.background,
      surface: surface ?? this.surface,
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
    );
  }

  static const dark = AppColors(
    primary: Color(0xFF3B82F6),
    primaryVariant: Color(0xFF1D4ED8),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    onPrimary: Colors.white,
    onSurface: Color(0xFFF8FAFC),
    danger: Color(0xFFDC2626),
    success: Color(0xFF16A34A),
    warning: Color(0xFFF59E0B),
    text: Color(0xFFF1F5F9),
    subdued: Color(0xFF94A3B8),
    brandPrimary: Color(0xFF3B82F6),
    brandAccent: Color(0xFF60A5FA),
    brandSecondary: Color(0xFFF472B6),
    brandNeutral: Color(0xFF9CA3AF),
  );

  static const light = AppColors(
    primary: Color(0xFF2563EB),
    primaryVariant: Color(0xFF60A5FA),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF1F5F9),
    onPrimary: Colors.white,
    onSurface: Color(0xFF1E293B),
    danger: Color(0xFFB91C1C),
    success: Color(0xFF15803D),
    warning: Color(0xFFEAB308),
    text: Color(0xFF1E293B),
    subdued: Color(0xFF64748B),
    brandPrimary: Color(0xFF3B82F6),
    brandAccent: Color(0xFF60A5FA),
    brandSecondary: Color(0xFFF472B6),
    brandNeutral: Color(0xFF9CA3AF),
  );
}
