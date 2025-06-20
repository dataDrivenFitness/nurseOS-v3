import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme textTheme = TextTheme(
    displayLarge: _base(32, FontWeight.w700),
    displayMedium: _base(28, FontWeight.w600),
    titleLarge: _base(22, FontWeight.w600),
    titleMedium: _base(18, FontWeight.w500),
    bodyLarge: _base(16, FontWeight.w500),
    bodyMedium: _base(14, FontWeight.w400),
    labelLarge: _base(14, FontWeight.w600),
    labelMedium: _base(12, FontWeight.w500),
    labelSmall: _base(10, FontWeight.w500),
  );

  static TextStyle _base(double size, FontWeight weight) {
    return TextStyle(
      fontFamily: 'InterVariable',
      fontSize: size,
      fontWeight: weight,
      letterSpacing: 0.25,
      height: 1.4,
    );
  }
}
