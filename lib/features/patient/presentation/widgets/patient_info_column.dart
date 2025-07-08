// lib/features/patient/presentation/widgets/patient_info_column.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/patient/models/code_status_utils.dart';
import 'package:nurseos_v3/features/patient/models/patient_extensions.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';

class PatientInfoColumn extends StatelessWidget {
  final Patient patient;
  final AppColors colors;
  final TextTheme textTheme;

  const PatientInfoColumn({
    super.key,
    required this.patient,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final allergies = patient.allergies ?? [];
    final dietRestrictions = patient.dietRestrictions ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 👤 Name + pronouns
        RichText(
          text: TextSpan(
            style: textTheme.titleMedium?.copyWith(color: colors.text),
            children: [
              TextSpan(text: patient.fullName),
              if (patient.pronouns?.trim().isNotEmpty == true)
                TextSpan(
                  text: ' (${patient.pronouns!.trim()})',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.subdued,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        // 📋 Age · Sex · Language
        _buildLineWithIcon(
          icon: Icons.person,
          text: [
            if (patient.age != null) '${patient.age} yrs',
            patient.sexLabel,
            if (patient.language?.trim().isNotEmpty == true)
              patient.language!.trim(),
          ].join(' · '),
          textStyle: textTheme.bodySmall,
          color: colors.subdued,
        ),
        // 💉 Diagnoses - consolidated on one line
        if (patient.primaryDiagnoses.isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.xs),
          _buildLineWithIcon(
            icon: Icons.medical_services,
            text: patient.primaryDiagnoses.join(', '),
            textStyle: textTheme.bodySmall,
            color: colors.subdued,
          ),
        ],
        // 📍 Location - display only, no map functionality
        if (patient.isAtResidence && patient.formattedAddress != null) ...[
          const SizedBox(height: SpacingTokens.xs),
          _buildLineWithIcon(
            icon: Icons.home,
            text: 'Residence',
            textStyle: textTheme.bodySmall,
            color: colors.subdued,
          ),
        ] else if (patient.facilityLocationDisplay != null) ...[
          const SizedBox(height: SpacingTokens.xs),
          _buildLineWithIcon(
            icon: Icons.location_on,
            text: patient.facilityLocationDisplay!,
            textStyle: textTheme.bodySmall,
            color: colors.subdued,
          ),
        ],
        const SizedBox(height: SpacingTokens.sm),
        // 🏷️ Icon-only Status Pills
        Wrap(
          spacing: SpacingTokens.xs,
          runSpacing: SpacingTokens.xs,
          children: [
            if (patient.codeStatus?.trim().isNotEmpty == true)
              GestureDetector(
                onLongPress: () =>
                    _showCodeStatusInfo(context, patient.codeStatus!),
                child: _buildIconOnlyPill(
                  CodeStatusUtils.getIcon(patient.codeStatus!),
                  CodeStatusUtils.getColor(patient.codeStatus!, colors),
                ),
              ),
            if (patient.isFallRisk)
              GestureDetector(
                onLongPress: () => _showFallRiskInfo(context),
                child: _buildIconOnlyPill(
                  Icons.warning_amber_rounded,
                  colors.warning,
                ),
              ),
            if (patient.isIsolation == true)
              GestureDetector(
                onLongPress: () => _showIsolationInfo(context),
                child: _buildIconOnlyPill(
                  Icons.security,
                  colors.brandAccent,
                ),
              ),
            if (allergies.isNotEmpty)
              GestureDetector(
                onLongPress: () => _showAllergiesList(context, allergies),
                child: _buildIconOnlyPill(
                  Icons.medical_information,
                  colors.warning,
                ),
              ),
            if (dietRestrictions.isNotEmpty)
              GestureDetector(
                onLongPress: () =>
                    _showDietRestrictionsList(context, dietRestrictions),
                child: _buildIconOnlyPill(
                  Icons.restaurant_menu,
                  colors.success,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLineWithIcon({
    required IconData icon,
    required String text,
    required TextStyle? textStyle,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 16,
          height: (textStyle?.fontSize ?? 14) + 2,
          child: Icon(
            icon,
            size: 14,
            color: color,
          ),
        ),
        const SizedBox(width: SpacingTokens.xs),
        Expanded(
          child: Text(
            text,
            style: textStyle?.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildIconOnlyPill(IconData icon, Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 12,
        color: color,
      ),
    );
  }

  void _showCodeStatusInfo(BuildContext context, String codeStatus) {
    final tooltip = CodeStatusUtils.getTooltip(codeStatus);
    _showInfoDialog(context, 'Code Status', tooltip);
  }

  void _showFallRiskInfo(BuildContext context) {
    _showInfoDialog(
      context,
      'Fall Risk',
      'This patient has been identified as having an increased risk of falling. Take appropriate precautions.',
    );
  }

  void _showIsolationInfo(BuildContext context) {
    _showInfoDialog(
      context,
      'Isolation Precautions',
      'This patient requires isolation precautions. Follow facility protocols for PPE and room entry.',
    );
  }

  void _showAllergiesList(BuildContext context, List<String> allergies) {
    _showInfoDialog(
      context,
      'Known Allergies',
      allergies.join('\n• '),
      prefix: '• ',
    );
  }

  void _showDietRestrictionsList(
      BuildContext context, List<String> dietRestrictions) {
    _showInfoDialog(
      context,
      'Dietary Restrictions',
      dietRestrictions.join('\n• '),
      prefix: '• ',
    );
  }

  void _showInfoDialog(
    BuildContext context,
    String title,
    String content, {
    String? prefix,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(prefix != null ? '$prefix$content' : content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
