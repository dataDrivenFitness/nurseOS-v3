// 📁 lib/features/patient/presentation/widgets/add_patient_risk_step.dart

import 'package:flutter/material.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/typography.dart';
import 'package:nurseos_v3/core/theme/shape_tokens.dart';
import 'package:nurseos_v3/features/patient/models/patient_field_options.dart';
import 'package:nurseos_v3/features/patient/models/code_status_utils.dart';
import 'package:nurseos_v3/shared/widgets/form_card.dart';

class AddPatientRiskStep extends StatelessWidget {
  final TextEditingController codeStatusController;
  final bool isIsolation;
  final bool isFallRisk;
  final ValueChanged<bool> onIsolationChanged;
  final ValueChanged<bool> onFallRiskChanged;
  final ValueChanged<String?> onCodeStatusChanged;

  const AddPatientRiskStep({
    super.key,
    required this.codeStatusController,
    required this.isIsolation,
    required this.isFallRisk,
    required this.onIsolationChanged,
    required this.onFallRiskChanged,
    required this.onCodeStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return FormCard(
      title: 'Risk Assessment',
      child: Column(
        children: [
          // Info banner
          _InfoBanner(
            message: 'Set risk flags and care directives for this patient',
            color: colors.brandPrimary,
          ),
          const SizedBox(height: SpacingTokens.lg),

          // Care Directives Section
          _SectionHeader(title: 'Care Directives'),
          const SizedBox(height: SpacingTokens.sm),
          _CodeStatusCard(
            controller: codeStatusController,
            onChanged: onCodeStatusChanged,
          ),
          const SizedBox(height: SpacingTokens.lg),

          // Risk Flags Section
          _SectionHeader(title: 'Risk Flags'),
          const SizedBox(height: SpacingTokens.sm),
          _RiskToggleCard(
            icon: Icons.medical_services,
            title: 'Isolation Precautions',
            description: 'Requires special infection control protocols',
            value: isIsolation,
            onChanged: onIsolationChanged,
            color: colors.danger,
          ),
          const SizedBox(height: SpacingTokens.sm),
          _RiskToggleCard(
            icon: Icons.accessibility,
            title: 'Fall Risk',
            description: 'Patient has elevated risk of falling',
            value: isFallRisk,
            onChanged: onFallRiskChanged,
            color: colors.warning,
          ),
        ],
      ),
    );
  }
}

// Helper widgets with consistent typography
class _InfoBanner extends StatelessWidget {
  final String message;
  final Color color;

  const _InfoBanner({
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: ShapeTokens.cardRadius,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTypography.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
      ),
    );
  }
}

class _CodeStatusCard extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String?> onChanged;

  const _CodeStatusCard({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final hasStatus = controller.text.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: hasStatus
            ? colors.brandPrimary.withOpacity(0.05)
            : colors.surfaceVariant,
        borderRadius: ShapeTokens.cardRadius,
        border: Border.all(
          color: hasStatus
              ? colors.brandPrimary.withOpacity(0.3)
              : colors.onSurface.withOpacity(0.2),
          width: hasStatus ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: hasStatus
                      ? colors.brandPrimary.withOpacity(0.15)
                      : colors.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SpacingTokens.sm),
                ),
                child: Icon(
                  Icons.medical_information,
                  color: hasStatus ? colors.brandPrimary : colors.subdued,
                  size: 24,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Code Status',
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasStatus ? colors.brandPrimary : colors.text,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      'Resuscitation preferences',
                      style: AppTypography.textTheme.bodySmall?.copyWith(
                        color: colors.subdued,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.xs),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(SpacingTokens.sm),
              border: Border.all(color: colors.onSurface.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.text.isEmpty ? null : controller.text,
                hint: Text(
                  'Select code status (optional)',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: colors.subdued,
                  ),
                ),
                isExpanded: true,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: colors.text,
                ),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Row(
                      children: [
                        Icon(Icons.clear, color: colors.subdued, size: 18),
                        const SizedBox(width: SpacingTokens.sm),
                        Text(
                          'None',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: colors.subdued,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const DropdownMenuItem(
                    enabled: false,
                    value: null,
                    child: Divider(height: 1),
                  ),
                  ...codeStatusOptions.map((status) => DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            _CodeStatusIcon(status: status),
                            const SizedBox(width: SpacingTokens.sm),
                            Text(
                              status,
                              style: AppTypography.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )),
                ],
                onChanged: (value) {
                  if (value == '') {
                    controller.clear();
                    onChanged(null);
                  } else {
                    controller.text = value ?? '';
                    onChanged(value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskToggleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  const _RiskToggleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.05) : colors.surfaceVariant,
        borderRadius: ShapeTokens.cardRadius,
        border: Border.all(
          color: value
              ? color.withOpacity(0.3)
              : colors.onSurface.withOpacity(0.2),
          width: value ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SpacingTokens.sm),
            decoration: BoxDecoration(
              color: value
                  ? color.withOpacity(0.15)
                  : colors.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SpacingTokens.sm),
            ),
            child: Icon(
              icon,
              color: value ? color : colors.subdued,
              size: 24,
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: value ? color : colors.text,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  description,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: colors.subdued,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeStatusIcon extends StatelessWidget {
  final String status;

  const _CodeStatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final style = CodeStatusUtils.getStyle(status, colors);

    return Icon(style.icon, color: style.color, size: 18);
  }
}
