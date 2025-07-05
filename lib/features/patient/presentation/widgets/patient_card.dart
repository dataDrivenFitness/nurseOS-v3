import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';
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

    return Card(
      elevation: 2,
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: ShapeTokens.cardRadius),
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: ShapeTokens.cardRadius,
        onTap: () {
          debugPrint('📋 Tapped patient card: ${patient.fullName}');
        },
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 🚦 Risk sidebar with padded inset to fit card corners
              if (risk == RiskLevel.medium || risk == RiskLevel.high)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Container(
                    width: 10,
                    decoration: BoxDecoration(
                      color: risk.color(colors),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),

              // 📋 Patient summary
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PatientAvatarColumn(patient: patient),
                      const SizedBox(width: SpacingTokens.md),
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
