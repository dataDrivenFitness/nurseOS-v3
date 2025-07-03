import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';

/// 🧩 FormCard: Reusable container for form sections (Add Patient, Vitals, etc.)
/// Matches visual style of PatientCard: same color, shape, shadow, and typography.
class FormCard extends StatelessWidget {
  final String? title;
  final Widget child;

  const FormCard({
    super.key,
    this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    // 🎨 Constants for consistent text and line styling
    final sectionTitleColor = theme.colorScheme.onSurface; // For section titles
    final fieldTextColor =
        theme.colorScheme.onSurface.withAlpha(200); // For form input text
    final fieldLineColor = theme.colorScheme.onSurface
        .withAlpha(100); // For input underline borders

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: Card(
        elevation: 2,
        color: colors.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Theme(
            data: theme.copyWith(
              inputDecorationTheme: InputDecorationTheme(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: fieldLineColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: fieldLineColor.withAlpha(200)),
                ),
                labelStyle: TextStyle(color: fieldTextColor),
                hintStyle: TextStyle(color: fieldTextColor.withAlpha(150)),
                contentPadding: const EdgeInsets.only(
                    bottom: SpacingTokens.md), // ⬆️ More space under last field
              ),
              textTheme: theme.textTheme.apply(
                bodyColor: fieldTextColor,
                displayColor: fieldTextColor,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                    child: Text(
                      title!.toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: sectionTitleColor,
                      ),
                    ),
                  ),
                child,
                const SizedBox(
                    height:
                        SpacingTokens.md), // ⬇️ Extra spacing after last field
              ],
            ),
          ),
        ),
      ),
    );
  }
}
