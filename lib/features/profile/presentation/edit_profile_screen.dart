import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/core/theme/text_styles.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/profile/state/user_profile_controller.dart';
import 'package:nurseos_v3/shared/widgets/nurse_scaffold.dart';

import 'edit_profile_form.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  bool _invalidated = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_invalidated) {
      // Only invalidate once per screen entry
      _invalidated = true;
      Future.microtask(() => ref.invalidate(userProfileProvider));
    }
  }

  @override
  Widget build(BuildContext context) {
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
