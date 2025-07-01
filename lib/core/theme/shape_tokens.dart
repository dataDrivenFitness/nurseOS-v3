import 'package:flutter/material.dart';
import 'spacing.dart';

class ShapeTokens {
  static final RoundedRectangleBorder defaultPill = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(SpacingTokens.xl),
  );

  static final BorderRadius pillRadius =
      BorderRadius.circular(SpacingTokens.xl);
  static final BorderRadius cardRadius =
      BorderRadius.circular(SpacingTokens.md);
}
