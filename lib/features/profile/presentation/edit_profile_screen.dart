// 📁 lib/features/profile/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/shared/widgets/app_loader.dart';

import '../../../core/theme/text_styles.dart';
import '../../../shared/widgets/nurse_scaffold.dart';
import '../../profile/state/user_profile_controller.dart'; // live stream
import 'edit_profile_form.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        body: Center(child: AppLoader()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            'Error: $e',
            style: AppTypography.textTheme.bodyMedium,
          ),
        ),
      ),
      data: (_) => NurseScaffold(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
          ),
          body: const EditProfileForm(), // 👈 no args needed
        ),
      ),
    );
  }
}
