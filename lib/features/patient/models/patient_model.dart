// lib/features/patient/models/patient_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/features/patient/models/patient_risk.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'patient_model.freezed.dart';
part 'patient_model.g.dart';

/// 🔍 Patient model representing a single patient record.
///
/// This model is used across the app and supports Firestore serialization,
/// structured patient metadata, care flags, and now enhanced location data.
@freezed
abstract class Patient with _$Patient {
  const factory Patient({
    // 🆔 Identity & Demographics
    required String id,
    required String firstName,
    required String lastName,
    String? mrn,

    /// 🌍 Type of location the patient is currently in
    /// e.g. "residence", "hospital", "snf", "rehab", "other"
    /// NOTE: Keeping field name as `location` for Firestore compatibility
    required String location,

    /// 🏢 Multi-agency support - REQUIRED field per v2.2 specs
    String? agencyId,

    /// 🕐 Admission & visibility timestamps
    @TimestampConverter() DateTime? admittedAt,
    @TimestampConverter() DateTime? lastSeen,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? birthDate,

    // 🚩 Clinical Risk Flags
    @Default(false) bool? isIsolation,
    @Default(false) bool isFallRisk,

    /// 💊 Supports multiple diagnoses per patient
    @Default([]) List<String> primaryDiagnoses,
    @RiskLevelConverter() RiskLevel? manualRiskOverride,
    String? codeStatus,

    // 🧍 Gender, pronouns, language
    String? pronouns,
    @Default('unspecified') String? biologicalSex,
    String? photoUrl,
    String? language,

    // 👩‍⚕️ Assigned nurses & ownership
    @Default([]) List<String>? assignedNurses,
    String? ownerUid,
    String? createdBy,

    // 🌿 Medical Notes & Dietary Flags
    @Default([]) List<String>? allergies,
    @Default([]) List<String>? dietRestrictions,

    // 🏥 Facility Location Fields (only applies if location != 'residence')
    String? department, // e.g. "ICU", "Med-Surg"
    String? roomNumber, // e.g. "12B"

    // 🏡 Structured Address Fields (only if location == 'residence')
    String? addressLine1, // e.g. "123 Main St"
    String? addressLine2, // e.g. "Apt 4B"
    String? city,
    String? state,
    String? zip,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
}
