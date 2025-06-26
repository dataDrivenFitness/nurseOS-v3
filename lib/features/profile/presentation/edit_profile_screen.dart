import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/text_styles.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';

import 'edit_profile_form.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authControllerProvider);

    return NurseScaffold(
      child: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text('No user data available.'),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: EditProfileForm(user: user),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Failed to load profile: $e',
            style: AppTypography.textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
