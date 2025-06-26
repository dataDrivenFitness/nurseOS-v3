import 'dart:io';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final File? file; // 🆕 Local image file (used before upload)
  final String? photoUrl;
  final String fallbackName;
  final double radius;
  final bool showBorder;

  const ProfileAvatar({
    super.key,
    this.file,
    required this.photoUrl,
    required this.fallbackName,
    this.radius = 20,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context);
    final initials = _getInitials(fallbackName);

    ImageProvider? backgroundImage;
    if (file != null) {
      backgroundImage = FileImage(file!);
    } else if (photoUrl != null && photoUrl!.startsWith('http')) {
      backgroundImage = NetworkImage(photoUrl!);
    }

    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      backgroundImage: backgroundImage,
      child: backgroundImage == null
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
