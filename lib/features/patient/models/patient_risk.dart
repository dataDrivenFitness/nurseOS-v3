import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'patient_model.dart';

/// 🔥 Triage Risk Levels
enum RiskLevel { high, medium, low, unknown }

/// 🔁 Firestore enum converter
class RiskLevelConverter implements JsonConverter<RiskLevel, String> {
  const RiskLevelConverter();

  @override
  RiskLevel fromJson(String json) => RiskLevel.values.firstWhere(
        (e) => e.name == json,
        orElse: () => RiskLevel.unknown,
      );

  @override
  String toJson(RiskLevel object) => object.name;
}

/// 🧠 Risk mapping by known diagnoses
const Map<RiskLevel, List<String>> riskDiagnosisMap = {
  RiskLevel.high: ['sepsis', 'stroke'],
  RiskLevel.medium: ['pneumonia', 'uti'],
  RiskLevel.low: ['constipation'],
};

/// 🤖 Returns either nurse-defined override or automatic inference
RiskLevel resolveRiskLevel(Patient patient) {
  return patient.manualRiskOverride ??
      getAutoRiskLevel(patient.primaryDiagnosis);
}

/// 🧠 Automatically infers risk from diagnosis string
RiskLevel getAutoRiskLevel(String primaryDiagnosis) {
  final normalized = primaryDiagnosis.toLowerCase().trim();
  for (final entry in riskDiagnosisMap.entries) {
    if (entry.value.contains(normalized)) return entry.key;
  }
  return RiskLevel.unknown;
}

/// 🎨 Risk display utilities
extension RiskLevelDisplay on RiskLevel {
  String get label => switch (this) {
        RiskLevel.high => 'High Risk',
        RiskLevel.medium => 'Moderate Risk',
        RiskLevel.low => 'Low Risk',
        RiskLevel.unknown => 'Unknown Risk',
      };

  Color color(AppColors colors) => switch (this) {
        RiskLevel.high => colors.danger,
        RiskLevel.medium => colors.warning,
        RiskLevel.low => colors.success,
        RiskLevel.unknown => colors.subdued,
      };
}
