import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/models/patient_extensions.dart';
import 'package:nurseos_v3/features/patient/models/patient_risk.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textTheme = theme.textTheme;

    final risk = patient.resolvedRiskLevel;
    final tags = patient.riskTags;
    final codeStatus = patient.codeStatus;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      elevation: 2,
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 🖼 Avatar section
            CircleAvatar(
              radius: 24,
              backgroundImage: patient.hasProfilePhoto
                  ? NetworkImage(patient.photoUrl!)
                  : null,
              backgroundColor: colors.primary.withAlpha(25),
              child: patient.hasProfilePhoto
                  ? null
                  : Text(
                      patient.initials,
                      style:
                          textTheme.labelLarge?.copyWith(color: colors.primary),
                    ),
            ),
            const SizedBox(width: 16),

            // 📋 Info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    patient.fullName,
                    style: textTheme.titleMedium?.copyWith(color: colors.text),
                  ),
                  const SizedBox(height: 2),

                  // Age · Sex
                  Text(
                    '${patient.age ?? "--"} yrs · ${patient.sexLabel}',
                    style: textTheme.bodySmall?.copyWith(color: colors.subdued),
                  ),
                  const SizedBox(height: 6),

                  // Diagnosis
                  Text(
                    patient.primaryDiagnosis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withAlpha(140),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 🔖 Tags: risk, fall, isolation, code
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      ...tags
                          .map((tag) => _buildRiskTag(tag, colors, textTheme)),
                      if (codeStatus != null)
                        _buildNeutralTag(codeStatus, colors, textTheme),
                    ],
                  ),
                ],
              ),
            ),

            // 🔴 Risk label pill
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: risk.color(colors).withAlpha(32),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  risk.label,
                  style: textTheme.labelSmall?.copyWith(
                    color: risk.color(colors),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskTag(String tag, AppColors colors, TextTheme textTheme) {
    final tagLower = tag.toLowerCase();
    Color bg;
    Color fg;

    if (tagLower.contains('fall')) {
      bg = colors.warning.withAlpha(30);
      fg = colors.warning;
    } else if (tagLower.contains('isolation')) {
      bg = colors.brandAccent.withAlpha(30);
      fg = colors.brandAccent;
    } else if (tagLower.contains('risk: high')) {
      bg = colors.danger.withAlpha(30);
      fg = colors.danger;
    } else if (tagLower.contains('risk: medium')) {
      bg = colors.warning.withAlpha(30);
      fg = colors.warning;
    } else if (tagLower.contains('risk: low')) {
      bg = colors.success.withAlpha(30);
      fg = colors.success;
    } else {
      bg = colors.onSurface.withAlpha(12);
      fg = colors.subdued;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(tag, style: textTheme.labelSmall?.copyWith(color: fg)),
    );
  }

  Widget _buildNeutralTag(String label, AppColors colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.onSurface.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: textTheme.labelSmall?.copyWith(color: colors.subdued)),
    );
  }
}
