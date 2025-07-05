import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';

enum InfoPillType {
  diagnosis,
  allergy,
  dietRestriction,
  diagnosisAccent,
  dietRestrictionGreen,
  danger, // 🆕 New red color option
  medicationPrimary, // 💊 New medication pill type
}

class InfoPill extends StatelessWidget {
  final String text;
  final InfoPillType type;
  final VoidCallback? onTap;
  final bool showDeleteIcon;

  const InfoPill({
    super.key,
    required this.text,
    required this.type,
    this.onTap,
    this.showDeleteIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final pillColors = _getColors(type, colors);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: pillColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: pillColors.border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: pillColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (showDeleteIcon) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 14,
                color: pillColors.text,
              ),
            ],
          ],
        ),
      ),
    );
  }

  _PillColors _getColors(InfoPillType type, AppColors colors) {
    switch (type) {
      case InfoPillType.diagnosis:
        return _PillColors(
          background: colors.brandAccent.withAlpha(25),
          border: colors.brandAccent,
          text: colors.brandAccent,
        );
      case InfoPillType.allergy:
        return _PillColors(
          background: colors.warning.withAlpha(38),
          border: colors.warning,
          text: colors.warning,
        );
      case InfoPillType.dietRestriction:
        return _PillColors(
          background: colors.success.withAlpha(25),
          border: colors.success,
          text: colors.success,
        );
      case InfoPillType.diagnosisAccent:
        return _PillColors(
          background: colors.primary.withAlpha(25),
          border: colors.primary,
          text: colors.primary,
        );
      case InfoPillType.dietRestrictionGreen:
        return _PillColors(
          background: colors.success.withAlpha(38),
          border: colors.success,
          text: colors.success,
        );
      case InfoPillType.danger: // 🆕 Red color using your existing danger color
        return _PillColors(
          background: colors.danger.withAlpha(25),
          border: colors.danger,
          text: colors.danger,
        );
      case InfoPillType.medicationPrimary: // 💊 Purple medication pills
        return _PillColors(
          background: colors.medicationPurple.withAlpha(25),
          border: colors.medicationPurple,
          text: colors.medicationPurple,
        );
    }
  }
}

class _PillColors {
  final Color background;
  final Color border;
  final Color text;

  _PillColors({
    required this.background,
    required this.border,
    required this.text,
  });
}
