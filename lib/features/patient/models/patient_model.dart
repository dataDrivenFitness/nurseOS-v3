import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/features/patient/models/patient_risk.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'patient_model.freezed.dart';
part 'patient_model.g.dart';

@freezed
abstract class Patient with _$Patient {
  const factory Patient({
    required String id,
    required String firstName,
    required String lastName,
    String? mrn,
    required String location,
    @TimestampConverter() DateTime? admittedAt,
    @TimestampConverter() DateTime? createdAt,
    @Default(false) bool? isIsolation,
    @Default(false) bool isFallRisk,
    required String primaryDiagnosis,
    @RiskLevelConverter() RiskLevel? manualRiskOverride,
    @Default([]) List<String>? allergies,
    String? codeStatus,
    @TimestampConverter() DateTime? birthDate,
    String? pronouns,
    @Default('unspecified') String? biologicalSex,
    String? photoUrl,
    @Default([]) List<String>? assignedNurses,
    String? ownerUid,
    String? createdBy,
    @Default([]) List<String>? tags,
    String? notes,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
}

extension PatientRiskExtension on Patient {
  RiskLevel get riskLevel => resolveRiskLevel(this);
}
