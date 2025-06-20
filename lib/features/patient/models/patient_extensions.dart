// lib/features/patient/models/patient_extensions.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';
import '../utils/risk_utils.dart';

extension PatientRiskLevelX on Patient {
  RiskLevel get effectiveRiskLevel {
    if (manualRiskOverride != null) return manualRiskOverride!;
    final diag = primaryDiagnosis.toLowerCase();
    for (final e in riskDiagnosisMap.entries) {
      if (e.value.contains(diag)) return e.key;
    }
    return RiskLevel.unknown;
  }
}

extension PatientFirestoreX on Patient {
  static final collection = FirebaseFirestore.instance.collection('patients');

  static final converter = collection.withConverter<Patient>(
    fromFirestore: (snap, _) =>
        Patient.fromJson(snap.data()!).copyWith(id: snap.id),
    toFirestore: (p, _) => p.toJson()..remove('id'),
  );
}
