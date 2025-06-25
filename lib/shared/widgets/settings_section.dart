import 'package:flutter/material.dart';
import '../../../core/theme/spacing.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaler = MediaQuery.textScalerOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              bottom: SpacingTokens.sm, top: SpacingTokens.lg),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: scaler.scale(18),
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
