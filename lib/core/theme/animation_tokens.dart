// lib/core/theme/animation_tokens.dart
import 'package:flutter/material.dart';

class AnimationTokens {
  static const short = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 300);
  static const long = Duration(milliseconds: 600);

  static const curveEase = Curves.easeInOut;
  static const curveFast = Curves.fastOutSlowIn;
}
