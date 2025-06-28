import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/shared/widgets/profile_avatar.dart';

import '../../../core/theme/animation_tokens.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/utils/image_picker_utils.dart';
import '../../auth/models/user_model.dart';
import '../../profile/state/user_profile_controller.dart';

class EditProfileForm extends ConsumerStatefulWidget {
  const EditProfileForm({super.key});

  @override
  ConsumerState<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<EditProfileForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  bool _fieldsInitialized = false; // 🆕 ensures controllers set once
  File? _newAvatar;
  bool _isDirty = false;

  late final AnimationController _fadeController;
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();

    _firstNameController.addListener(_checkDirty);
    _lastNameController.addListener(_checkDirty);

    _fadeController =
        AnimationController(vsync: this, duration: AnimationTokens.medium);
    _scaleController =
        AnimationController(vsync: this, duration: AnimationTokens.medium);
  }

  // ──────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────
  void _checkDirty() {
    final user = ref.read(userProfileStreamProvider).valueOrNull;
    if (user == null) return;

    final modified = _firstNameController.text.trim() != user.firstName ||
        _lastNameController.text.trim() != user.lastName ||
        _newAvatar != null;

    if (modified != _isDirty) {
      setState(() => _isDirty = modified);
      modified ? _fadeController.forward() : _fadeController.reverse();
      modified ? _scaleController.forward() : _scaleController.reverse();
    }
  }

  Future<void> _pickAndCropImage() async {
    final picked = await pickAndCropImage(context: context, isCircular: true);
    if (picked != null) {
      setState(() => _newAvatar = picked);
      _checkDirty();
    }
  }

  Future<void> _onSave(UserModel user) async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(userProfileProvider.notifier);
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    try {
      await notifier.updateUser(
        firstName: firstName,
        lastName: lastName,
        photoFile: _newAvatar,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );

      setState(() {
        _newAvatar = null;
        _isDirty = false;
      });
      _fadeController.reverse();
      _scaleController.reverse();

      context.go('/profile');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final userAsync = ref.watch(userProfileStreamProvider);

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (user) {
        // ⚠️  Only populate controllers once per user load
        if (!_fieldsInitialized) {
          _firstNameController.text = user.firstName;
          _lastNameController.text = user.lastName;
          _fieldsInitialized = true;
        }

        final fullName = '${user.firstName} ${user.lastName}';

        return Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  InkWell(
                    onTap: _pickAndCropImage,
                    child: Center(
                      child: ProfileAvatar(
                        file: _newAvatar,
                        photoUrl: user.photoUrl,
                        fallbackName: fullName,
                        radius: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name'),
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      fontSize: 16 * textScale,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Last Name'),
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      fontSize: 16 * textScale,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: user.email,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Email'),
                    style: AppTypography.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FadeTransition(
                opacity: _fadeController,
                child: ScaleTransition(
                  scale: _scaleController,
                  child: FloatingActionButton.extended(
                    onPressed: _isDirty ? () => _onSave(user) : null,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}
