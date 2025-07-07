import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/patient/models/code_status_utils.dart';
import 'package:nurseos_v3/features/patient/models/patient_extensions.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:url_launcher/url_launcher.dart';

// ⬇️ Insert your existing imports here
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
        // 📍 Location - with map link for residence
        if (patient.isAtResidence && patient.mapLaunchUrl != null) ...[
          const SizedBox(height: SpacingTokens.xs),
          GestureDetector(
            onTap: () async {
              final url = Uri.parse(patient.mapLaunchUrl!);
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            child: _buildLineWithIcon(
              icon: Icons.home,
              text: 'Residence',
              textStyle: textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.underline,
              ),
              color: colors.subdued,
            ),
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
          height: (textStyle?.fontSize ?? 14) * 1.2,
          child: Icon(
            icon,
            size: (textStyle?.fontSize ?? 14).clamp(12.0, 18.0),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
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
    final color = CodeStatusUtils.getColor(codeStatus, colors);
    _showInfoDialog(context, 'Code Status', tooltip, color);
  }

  void _showFallRiskInfo(BuildContext context) {
    _showInfoDialog(
      context,
      'Fall Risk',
      'This patient has been marked as a fall risk.',
      colors.warning,
    );
  }

  void _showIsolationInfo(BuildContext context) {
    _showInfoDialog(
      context,
      'Isolation',
      'This patient requires isolation precautions.',
      colors.brandAccent,
    );
  }

  void _showAllergiesList(BuildContext context, List<String> allergies) {
    _showListDialog(
      context,
      'Allergies',
      allergies,
      colors.warning,
      Icons.warning_amber_rounded,
    );
  }

  void _showDietRestrictionsList(
      BuildContext context, List<String> restrictions) {
    _showListDialog(
      context,
      'Diet Restrictions',
      restrictions,
      colors.success,
      Icons.restaurant_menu,
    );
  }

  void _showInfoDialog(
      BuildContext context, String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: color, size: 20),
            const SizedBox(width: SpacingTokens.sm),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showListDialog(BuildContext context, String title, List<String> items,
      Color color, IconData icon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: SpacingTokens.sm),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Expanded(child: Text(item)),
                      ],
                    ),
                  ))
              .toList(),
        ),
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
