import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String fallbackName;
  final double radius;
  final bool showBorder;

  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.fallbackName,
    this.radius = 20,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context);
    final hasPhoto = photoUrl != null && photoUrl!.startsWith('http');
    final initials = _getInitials(fallbackName);

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
      child: !hasPhoto
          ? Text(
              initials,
              style: theme.textTheme.labelLarge?.copyWith(
                fontSize: radius * 0.9 * scale.scale(1),
                color: theme.colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );

    return showBorder
        ? Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
            child: avatar,
          )
        : avatar;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return parts[0].substring(0, 1).toUpperCase();
    }
  }
}
