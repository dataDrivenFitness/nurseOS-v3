// 📁 lib/shared/widgets/app_divider.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppDivider extends StatelessWidget {
  final double height;
  final double opacity;

  const AppDivider({
    super.key,
    this.height = 1,
    this.opacity = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Divider(
      height: height,
      color: colors.onSurface.withAlpha(90),
    );
  }
}
