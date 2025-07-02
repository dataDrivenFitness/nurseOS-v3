import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/models/patient_extensions.dart';
import 'package:nurseos_v3/features/patient/models/patient_risk.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/patient_avatar_column.dart';
import 'package:nurseos_v3/features/patient/presentation/widgets/patient_info_column.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;

  const PatientCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final textTheme = theme.textTheme;
    final risk = patient.resolvedRiskLevel;

    final riskBarColor = switch (risk) {
      RiskLevel.high => colors.danger,
      RiskLevel.medium => colors.warning,
      _ => Colors.transparent,
    };

    return Card(
      elevation: 2,
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          debugPrint('📋 Tapped patient card: ${patient.fullName}');
        },
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 🚦 Vertical risk bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: riskBarColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PatientAvatarColumn(patient: patient),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PatientInfoColumn(
                          patient: patient,
                          colors: colors,
                          textTheme: textTheme,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
