import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/patient/models/patient_model.dart';
import 'package:nurseos_v3/features/patient/models/diagnosis_catalog.dart';

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

/// 🤖 Returns either nurse-defined override or automatic inference
RiskLevel resolveRiskLevel(Patient patient) {
  return patient.manualRiskOverride ??
      getAutoRiskLevel(patient.primaryDiagnoses);
}

/// 🧠 Automatically infers risk from multiple diagnoses
RiskLevel getAutoRiskLevel(List<String> diagnoses) {
  final normalized = diagnoses.map((d) => d.toLowerCase().trim());

  for (final level in [RiskLevel.high, RiskLevel.medium, RiskLevel.low]) {
    if (normalized.any((d) => getRiskForDiagnosis(d) == level)) {
      return level;
    }
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
