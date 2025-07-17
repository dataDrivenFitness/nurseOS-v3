// 📁 lib/features/profile/presentation/edit_profile_form.dart (UPDATED - NULL SAFETY)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/shared/widgets/app_snackbar.dart';

import '../../../core/theme/spacing.dart';
import '../../../shared/utils/image_picker_utils.dart'; // Use your existing utility
import '../../../shared/widgets/buttons/primary_button.dart';
import '../../../shared/widgets/form_card.dart';
import '../../../shared/widgets/profile_avatar.dart';
import '../../profile/state/user_profile_controller.dart';

class EditProfileForm extends ConsumerStatefulWidget {
  const EditProfileForm({super.key});

  @override
  ConsumerState<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();

  // Basic info controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;

  // Healthcare professional controllers
  late TextEditingController _licenseNumberController;
  late TextEditingController _specialtyController;

  // Independent practice controllers
  late TextEditingController _businessNameController;

  // Dropdowns and selections
  DateTime? _licenseExpiry;
  List<String> _selectedCertifications = [];

  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();

    final user = ref.read(userProfileStreamProvider).value;

    // ✅ SAFE: Basic controllers (existing fields)
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');

    // ✅ SAFE: Professional controllers with null safety
    _licenseNumberController = TextEditingController(
      text: _safeGetString(user, 'licenseNumber'),
    );
    _specialtyController = TextEditingController(
      text: _safeGetString(user, 'specialty'),
    );

    // ✅ SAFE: Independent practice controller
    _businessNameController = TextEditingController(
      text: _safeGetString(user, 'businessName'),
    );

    // ✅ SAFE: Initialize optional fields with null safety
    _licenseExpiry = _safeGetDateTime(user, 'licenseExpiry');
    _selectedCertifications = _safeGetStringList(user, 'certifications');
  }

  // 🛡️ SAFETY HELPERS: Handle potential missing fields gracefully
  String _safeGetString(dynamic user, String fieldName) {
    try {
      switch (fieldName) {
        case 'licenseNumber':
          return user?.licenseNumber?.trim() ?? '';
        case 'specialty':
          return user?.specialty?.trim() ?? '';
        case 'businessName':
          return user?.businessName?.trim() ?? '';
        default:
          return '';
      }
    } catch (e) {
      return '';
    }
  }

  DateTime? _safeGetDateTime(dynamic user, String fieldName) {
    try {
      switch (fieldName) {
        case 'licenseExpiry':
          return user?.licenseExpiry;
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  List<String> _safeGetStringList(dynamic user, String fieldName) {
    try {
      switch (fieldName) {
        case 'certifications':
          final certs = user?.certifications;
          return certs is List ? List<String>.from(certs) : <String>[];
        default:
          return <String>[];
      }
    } catch (e) {
      return <String>[];
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _licenseNumberController.dispose();
    _specialtyController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileStreamProvider).value;
    if (user == null) return const SizedBox.shrink();

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          children: [
            // Profile Photo Section
            FormCard(
              title: 'Profile Photo',
              child: Column(
                children: [
                  ProfileAvatar(
                    photoUrl: _selectedImageFile != null ? null : user.photoUrl,
                    file: _selectedImageFile,
                    fallbackName:
                        '${_firstNameController.text} ${_lastNameController.text}',
                    radius: 50,
                    showBorder: true,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Change Photo'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: SpacingTokens.lg),

            // Basic Information
            FormCard(
              title: 'Basic Information',
              child: Column(
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      hintText: 'Enter your first name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      hintText: 'Enter your last name',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: SpacingTokens.lg),

            // ✅ SAFE: Only show professional section if user has data or is editing
            if (_shouldShowProfessionalSection())
              FormCard(
                title: 'Professional Credentials',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _licenseNumberController,
                      decoration: const InputDecoration(
                        labelText: 'License Number',
                        hintText: 'e.g., RN123456',
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),

                    // License Expiry Date
                    InkWell(
                      onTap: _selectLicenseExpiry,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'License Expiry',
                          prefixIcon: Icon(Icons.calendar_today),
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          _licenseExpiry != null
                              ? '${_licenseExpiry!.month.toString().padLeft(2, '0')}/${_licenseExpiry!.year}'
                              : 'Select expiry date',
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),

                    TextFormField(
                      controller: _specialtyController,
                      decoration: const InputDecoration(
                        labelText: 'Specialty',
                        hintText: 'e.g., Critical Care, Med-Surg, ER',
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),

                    // Certifications
                    _buildCertificationsField(),
                  ],
                ),
              ),

            // ✅ CONDITIONAL: Independent Practice section (only for independent nurses)
            if (user.isIndependentNurse == true) ...[
              const SizedBox(height: SpacingTokens.lg),
              FormCard(
                title: 'Independent Practice',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _businessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        hintText: 'e.g., Smith Home Care Services',
                        prefixIcon: Icon(Icons.business_center),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: SpacingTokens.xl),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Save Changes',
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ SAFE: Only show professional section if user has data or is actively editing
  bool _shouldShowProfessionalSection() {
    // Always show if user is filling out any professional field
    return _licenseNumberController.text.isNotEmpty ||
        _specialtyController.text.isNotEmpty ||
        _selectedCertifications.isNotEmpty ||
        _licenseExpiry != null;
  }

  Widget _buildCertificationsField() {
    const availableCertifications = [
      'BLS',
      'ACLS',
      'PALS',
      'NRP',
      'CCRN',
      'CEN',
      'TCRN',
      'TNCC',
      'ENPC'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Certifications',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableCertifications.map((cert) {
            final isSelected = _selectedCertifications.contains(cert);
            return FilterChip(
              label: Text(cert),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCertifications.add(cert);
                  } else {
                    _selectedCertifications.remove(cert);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      // ✅ SAFE: Use existing function name from your codebase
      final imageFile = await pickAndCropImage(
        context: context,
        isCircular: true, // Circular crop for profile avatars
      );
      if (imageFile != null) {
        setState(() => _selectedImageFile = imageFile);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _selectLicenseExpiry() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _licenseExpiry ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (date != null) {
      setState(() => _licenseExpiry = date);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ FIX: Get user reference in the correct scope
    final user = ref.read(userProfileStreamProvider).value;
    if (user == null) return;

    try {
      // ✅ COMPLETE: Use extended updateUser method with only user-editable fields
      await ref.read(userProfileControllerProvider.notifier).updateUser(
            // Basic fields (required)
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            photoFile: _selectedImageFile,

            // Professional credentials (optional)
            licenseNumber: _licenseNumberController.text.trim().isNotEmpty
                ? _licenseNumberController.text.trim()
                : null,
            licenseExpiry: _licenseExpiry,
            specialty: _specialtyController.text.trim().isNotEmpty
                ? _specialtyController.text.trim()
                : null,
            certifications: _selectedCertifications.isNotEmpty
                ? _selectedCertifications
                : null,

            // ✅ FIXED: Independent practice fields (if applicable)
            businessName: user.isIndependentNurse &&
                    _businessNameController.text.trim().isNotEmpty
                ? _businessNameController.text.trim()
                : null,
          );

      if (mounted) {
        AppSnackbar.success(context, 'Profile updated successfully!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.error(context, 'Failed to update profile: $e');
      }
    }
  }
}
