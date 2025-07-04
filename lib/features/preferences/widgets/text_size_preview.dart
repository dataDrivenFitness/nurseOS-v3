import 'package:flutter/material.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/app_colors.dart';

class TextSizePreview extends StatelessWidget {
  final double scaleFactor;

  const TextSizePreview({super.key, required this.scaleFactor});

  @override
  Widget build(BuildContext context) {
    final baseMediaQuery = MediaQuery.of(context);
    final appColors = Theme.of(context).extension<AppColors>()!;

    return MediaQuery(
      data: baseMediaQuery.copyWith(
        textScaler: TextScaler.linear(scaleFactor),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          color: appColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Patient vitals: BP 120/80, HR 72 bpm, Temp 98.6°F',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
