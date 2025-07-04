// 📁 lib/features/patient/presentation/widgets/add_patient_basic_info_step.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/typography.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/patient_field_options.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';
import 'package:nurseos_v3/shared/widgets/profile_avatar.dart';

class AddPatientBasicInfoStep extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController pronounsController;
  final DateTime? birthDate;
  final String? biologicalSex;
  final String? language;
  final File? profileImage;
  final VoidCallback onPickBirthDate;
  final VoidCallback onPickImage;
  final ValueChanged<String?> onBiologicalSexChanged;
  final ValueChanged<String?> onLanguageChanged;

  const AddPatientBasicInfoStep({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.pronounsController,
    required this.birthDate,
    required this.biologicalSex,
    required this.language,
    required this.profileImage,
    required this.onPickBirthDate,
    required this.onPickImage,
    required this.onBiologicalSexChanged,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return FormCard(
      title: 'Essential Information',
      child: Column(
        children: [
          _buildPhotoSection(context),
          const SizedBox(height: SpacingTokens.lg),
          TextFormField(
            controller: firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name *',
              hintText: 'Enter patient\'s first name',
              border: OutlineInputBorder(),
            ),
            style: AppTypography.textTheme.bodyLarge,
            textCapitalization: TextCapitalization.words,
            validator: (val) =>
                val == null || val.isEmpty ? 'First name is required' : null,
          ),
          const SizedBox(height: SpacingTokens.md),
          TextFormField(
            controller: lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name *',
              hintText: 'Enter patient\'s last name',
              border: OutlineInputBorder(),
            ),
            style: AppTypography.textTheme.bodyLarge,
            textCapitalization: TextCapitalization.words,
            validator: (val) =>
                val == null || val.isEmpty ? 'Last name is required' : null,
          ),
          const SizedBox(height: SpacingTokens.md),
          _buildDatePicker(context),
          const SizedBox(height: SpacingTokens.md),
          TextFormField(
            controller: pronounsController,
            decoration: const InputDecoration(
              labelText: 'Pronouns (optional)',
              hintText: 'e.g., they/them, she/her, he/him',
              border: OutlineInputBorder(),
            ),
            style: AppTypography.textTheme.bodyLarge,
          ),
          const SizedBox(height: SpacingTokens.md),
          DropdownButtonFormField<String>(
            value: biologicalSex,
            decoration: const InputDecoration(
              labelText: 'Biological Sex (optional)',
              border: OutlineInputBorder(),
            ),
            style: AppTypography.textTheme.bodyLarge,
            items: biologicalSexOptions
                .map((sex) => DropdownMenuItem(
                      value: sex,
                      child:
                          Text(sex, style: AppTypography.textTheme.bodyLarge),
                    ))
                .toList(),
            onChanged: onBiologicalSexChanged,
          ),
          const SizedBox(height: SpacingTokens.md),
          DropdownButtonFormField<String>(
            value: language,
            decoration: const InputDecoration(
              labelText: 'Preferred Language (optional)',
              border: OutlineInputBorder(),
            ),
            style: AppTypography.textTheme.bodyLarge,
            items: languageOptions
                .map((lang) => DropdownMenuItem(
                      value: lang,
                      child:
                          Text(lang, style: AppTypography.textTheme.bodyLarge),
                    ))
                .toList(),
            onChanged: onLanguageChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final patientName = firstNameController.text.trim().isEmpty &&
            lastNameController.text.trim().isEmpty
        ? 'Patient'
        : '${firstNameController.text.trim()} ${lastNameController.text.trim()}';

    return Column(
      children: [
        InkWell(
          onTap: onPickImage,
          borderRadius: BorderRadius.circular(60),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ProfileAvatar(
              file: profileImage,
              photoUrl: null,
              fallbackName: patientName,
              radius: 50,
            ),
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          'Tap to add patient photo',
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: colors.subdued,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return InkWell(
      onTap: onPickBirthDate,
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          border: Border.all(color: colors.onSurface.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                birthDate != null
                    ? 'Birthdate: ${birthDate!.toLocal().toString().split(' ')[0]}'
                    : 'Select Birthdate *',
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: colors.text,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: colors.subdued,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
