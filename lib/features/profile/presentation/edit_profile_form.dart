// 📁 lib/features/profile/presentation/edit_profile_form.dart (UPDATED)

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
  late TextEditingController _departmentController;
  late TextEditingController _phoneExtensionController;

  // Dropdowns and selections
  String? _selectedShift;
  DateTime? _licenseExpiry;
  DateTime? _hireDate;
  List<String> _selectedCertifications = [];
  bool _isOnDuty = false;

  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();

    final user = ref.read(userProfileStreamProvider).value;

    // Initialize basic controllers
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');

    // Initialize healthcare controllers
    _licenseNumberController =
        TextEditingController(text: user?.licenseNumber ?? '');
    _specialtyController = TextEditingController(text: user?.specialty ?? '');
    _departmentController =
        TextEditingController(text: user?.department ?? user?.unit ?? '');
    _phoneExtensionController =
        TextEditingController(text: user?.phoneExtension ?? '');

    // Initialize other fields
    _selectedShift = user?.shift;
    _licenseExpiry = user?.licenseExpiry;
    _hireDate = user?.hireDate;
    _selectedCertifications = List.from(user?.certifications ?? []);
    _isOnDuty = user?.isOnDuty ?? false;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _licenseNumberController.dispose();
    _specialtyController.dispose();
    _departmentController.dispose();
    _phoneExtensionController.dispose();
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

            // Professional Credentials
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

            const SizedBox(height: SpacingTokens.lg),

            // Work Information
            FormCard(
              title: 'Work Information',
              child: Column(
                children: [
                  TextFormField(
                    controller: _departmentController,
                    decoration: const InputDecoration(
                      labelText: 'Department/Unit',
                      hintText: 'e.g., ICU, Med-Surg Floor 3',
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),

                  // Shift Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedShift,
                    decoration: const InputDecoration(
                      labelText: 'Shift',
                      prefixIcon: Icon(Icons.schedule),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'day', child: Text('Day Shift')),
                      DropdownMenuItem(
                          value: 'evening', child: Text('Evening Shift')),
                      DropdownMenuItem(
                          value: 'night', child: Text('Night Shift')),
                      DropdownMenuItem(
                          value: 'rotating', child: Text('Rotating')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedShift = value),
                  ),
                  const SizedBox(height: SpacingTokens.md),

                  TextFormField(
                    controller: _phoneExtensionController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Extension',
                      hintText: 'e.g., 4521',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: SpacingTokens.md),

                  // Hire Date
                  InkWell(
                    onTap: _selectHireDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hire Date',
                        prefixIcon: Icon(Icons.work),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      child: Text(
                        _hireDate != null
                            ? '${_hireDate!.month}/${_hireDate!.day}/${_hireDate!.year}'
                            : 'Select hire date',
                      ),
                    ),
                  ),

                  // Remove the On Duty Toggle - we'll move it to main profile screen
                ],
              ),
            ),

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
      // Use your existing image picker utility
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

  Future<void> _selectHireDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _hireDate ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _hireDate = date);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Use the correct provider name from your existing code
      await ref.read(userProfileControllerProvider.notifier).updateUser(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            photoFile: _selectedImageFile,
            // Healthcare fields - will need to add these to the updateUser method
            licenseNumber: _licenseNumberController.text.trim().isNotEmpty
                ? _licenseNumberController.text.trim()
                : null,
            licenseExpiry: _licenseExpiry,
            specialty: _specialtyController.text.trim().isNotEmpty
                ? _specialtyController.text.trim()
                : null,
            department: _departmentController.text.trim().isNotEmpty
                ? _departmentController.text.trim()
                : null,
            shift: _selectedShift,
            phoneExtension: _phoneExtensionController.text.trim().isNotEmpty
                ? _phoneExtensionController.text.trim()
                : null,
            hireDate: _hireDate,
            certifications: _selectedCertifications,
            // Removed isOnDuty - now handled on main profile screen
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
