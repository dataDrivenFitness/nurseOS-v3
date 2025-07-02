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
    @TimestampConverter() DateTime? lastSeen, // ✅ Correct location
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? birthDate,

    // 🧠 Clinical flags
    @Default(false) bool? isIsolation,
    @Default(false) bool isFallRisk,
    required String primaryDiagnosis,
    @RiskLevelConverter() RiskLevel? manualRiskOverride,
    String? codeStatus,

    // 🧍 Identity & meta
    String? pronouns,
    @Default('unspecified') String? biologicalSex,
    String? photoUrl,
    String? language,

    // 🩺 Assigned & created by
    @Default([]) List<String>? assignedNurses,
    String? ownerUid,
    String? createdBy,

    // 🏷️ Medical info
    @Default([]) List<String>? allergies,
    @Default([]) List<String>? dietRestrictions, // 🍽️ Diet restrictions
    String? notes,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
}
