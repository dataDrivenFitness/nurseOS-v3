import 'package:json_annotation/json_annotation.dart';

enum RiskLevel { high, medium, low, unknown }

const riskDiagnosisMap = {
  RiskLevel.high: ['sepsis', 'stroke'],
  RiskLevel.medium: ['pneumonia', 'uti'],
  RiskLevel.low: ['constipation'],
};

class RiskLevelConverter implements JsonConverter<RiskLevel, String> {
  const RiskLevelConverter();

  @override
  RiskLevel fromJson(String json) => RiskLevel.values
      .firstWhere((e) => e.name == json, orElse: () => RiskLevel.unknown);

  @override
  String toJson(RiskLevel object) => object.name;
}
