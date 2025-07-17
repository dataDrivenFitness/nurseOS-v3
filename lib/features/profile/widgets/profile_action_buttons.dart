// 📁 lib/features/profile/widgets/profile_action_buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/l10n/l10n.dart';

class ProfileActionButtons extends ConsumerWidget {
  final UserModel user;
  final VoidCallback onEditProfile;

  const ProfileActionButtons({
    super.key,
    required this.user,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        label: l10n.editProfile,
        onPressed: onEditProfile,
        icon: const Icon(Icons.edit, size: 18),
      ),
    );
  }
}
