import 'package:json_annotation/json_annotation.dart';
import '../models/patient_model.dart';

/// Enum representing patient triage risk levels.
enum RiskLevel { high, medium, low, unknown }

/// Map used for simple diagnosis-based risk inference.
const Map<RiskLevel, List<String>> riskDiagnosisMap = {
  RiskLevel.high: ['sepsis', 'stroke'],
  RiskLevel.medium: ['pneumonia', 'uti'],
  RiskLevel.low: ['constipation'],
};

/// Converts string-based Firestore values into RiskLevel enums.
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

/// Returns a risk level based on known diagnosis mappings.
/// Used when no manual override is present.
RiskLevel getAutoRiskLevel(String primaryDiagnosis) {
  final normalized = primaryDiagnosis.toLowerCase().trim();
  for (final entry in riskDiagnosisMap.entries) {
    if (entry.value.contains(normalized)) return entry.key;
  }
  return RiskLevel.unknown;
}

/// Returns either the nurse-defined risk override, or the automatic diagnosis-based risk.
RiskLevel resolveRiskLevel(Patient patient) {
  return patient.manualRiskOverride ??
      getAutoRiskLevel(patient.primaryDiagnosis);
}
