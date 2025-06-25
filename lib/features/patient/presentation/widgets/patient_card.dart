import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/utils/risk_utils.dart';
import 'package:nurseos_v3/shared/widgets/risk_level_chip.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textTheme = theme.textTheme;

    final risk = patient.manualRiskOverride ?? RiskLevel.unknown;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      elevation: 2,
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${patient.firstName} ${patient.lastName}',
              style: textTheme.titleMedium?.copyWith(color: colors.text),
            ),
            const SizedBox(height: 4),
            Text(
              patient.primaryDiagnosis,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withAlpha(AppAlpha.softLabel),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  patient.location,
                  style: textTheme.labelSmall?.copyWith(color: colors.subdued),
                ),
                RiskLevelChip(risk: risk),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
