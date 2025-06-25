// lib/shared/widgets/settings_tile.dart
import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';

/// One row inside a [`SettingsSection`].
///
/// * Uses design-system spacing via `SpacingTokens`.
/// * Adds a default chevron icon whenever `onTap` is provided _and_ no
///   explicit `trailing` widget is given.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.onTap,
  });

  /// Typically a [Text] widget, but kept generic for flexibility.
  final Widget title;

  /// Icon or avatar shown on the left.
  final Widget? leading;

  /// Right-hand widget (`Switch`, badge, etc.).
  /// If `null` and `onTap` is non-null, a chevron icon is shown automatically.
  final Widget? trailing;

  /// Called on tap; row becomes non-interactive when `null`.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      child: ListTile(
        dense: true,
        minLeadingWidth: 24, // tighter than default 40
        contentPadding: EdgeInsets.zero, // section handles side pads
        horizontalTitleGap: SpacingTokens.md,
        leading: leading,
        title: DefaultTextStyle.merge(
          style: theme.textTheme.bodyLarge!,
          child: title,
        ),
        // If caller passes a trailing widget, use it; otherwise show chevron
        trailing: trailing ??
            (onTap != null ? const Icon(Icons.chevron_right, size: 20) : null),
        onTap: onTap,
      ),
    );
  }
}
