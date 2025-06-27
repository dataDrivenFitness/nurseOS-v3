import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/shared/widgets/profile_avatar.dart';

import '../../../core/theme/animation_tokens.dart';
import '../../../core/theme/typography.dart';
import '../../../shared/utils/image_picker_utils.dart';
import '../../auth/models/user_model.dart';
import '../../profile/state/user_profile_controller.dart'; // ✅ new import

class EditProfileForm extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileForm({super.key, required this.user});

  @override
  ConsumerState<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<EditProfileForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  File? _newAvatar;
  bool _isDirty = false;

  late AnimationController _fadeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);

    _firstNameController.addListener(_checkDirty);
    _lastNameController.addListener(_checkDirty);

    _fadeController = AnimationController(
      vsync: this,
      duration: AnimationTokens.medium,
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: AnimationTokens.medium,
    );
  }

  void _checkDirty() {
    final isModified =
        _firstNameController.text.trim() != widget.user.firstName ||
            _lastNameController.text.trim() != widget.user.lastName ||
            _newAvatar != null;

    if (isModified != _isDirty) {
      setState(() => _isDirty = isModified);
      isModified ? _showSave() : _hideSave();
    }
  }

  void _showSave() {
    _fadeController.forward();
    _scaleController.forward();
  }

  void _hideSave() {
    _fadeController.reverse();
    _scaleController.reverse();
  }

  Future<void> _pickAndCropImage() async {
    final picked = await pickAndCropImage(
      context: context,
      isCircular: true,
    );

    if (picked != null) {
      setState(() => _newAvatar = picked);
      _checkDirty();
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(userProfileProvider.notifier); // ✅ new notifier
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

      _hideSave();
      setState(() {
        _newAvatar = null;
        _isDirty = false;
      });

      context.go('/profile'); // ✅ always navigate cleanly
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0);
    final fullName = '${widget.user.firstName} ${widget.user.lastName}';

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
                    photoUrl: widget.user.photoUrl,
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
                  fontSize: 16 * scale,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  fontSize: 16 * scale,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: widget.user.email,
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
                onPressed: _isDirty ? _onSave : null,
                label: const Text('Save'),
                icon: const Icon(Icons.save),
              ),
            ),
          ),
        ),
      ],
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
