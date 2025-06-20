import 'package:freezed_annotation/freezed_annotation.dart';
import '../utils/risk_utils.dart';

part 'patient_model.freezed.dart';
part 'patient_model.g.dart';

@freezed
class Patient with _$Patient {
  const factory Patient({
    // ── identity ─────────────────────────────────────────────
    required String id,
    required String firstName,
    required String lastName,
    String? mrn,

    // ── location / admission ─────────────────────────────────
    required String location, // e.g. “3-East 12” or "Home Health"
    DateTime? admittedAt,
    bool? isIsolation,

    // ── clinical info ────────────────────────────────────────
    required String primaryDiagnosis,
    @RiskLevelConverter() RiskLevel? manualRiskOverride,
    List<String>? allergies,
    String? codeStatus, // DNR / Full / etc.

    // ── demographics ─────────────────────────────────────────
    DateTime? birthDate,
    String? pronouns,
    String? photoUrl,

    // ── roster & ownership ───────────────────────────────────
    List<String>? assignedNurses,
    String? ownerUid, // head nurse / provider
    String? createdBy, // who added record

    // ── tags & misc ──────────────────────────────────────────
    List<String>? tags,
    String? notes,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
}
