import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_model.dart';
import 'patient_risk.dart'; // <-- new import for risk logic

/// 🔗 Firestore collection accessors
CollectionReference<Map<String, dynamic>> rawPatients(FirebaseFirestore db) =>
    db.collection('patients');

CollectionReference<Patient> typedPatients(FirebaseFirestore db) =>
    rawPatients(db).withConverter<Patient>(
      fromFirestore: (snap, _) =>
          Patient.fromJson(snap.data()!).copyWith(id: snap.id),
      toFirestore: (p, _) => p.toJson(),
    );

/// 🧠 Patient-derived extensions
extension PatientExtensions on Patient {
  String get fullName => '$firstName $lastName';

  String get sexLabel {
    final value = biologicalSex?.toLowerCase();
    return switch (value) {
      'male' => 'Male',
      'female' => 'Female',
      'unspecified' || null => 'Unspecified',
      _ => value!.capitalize(),
    };
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  bool get hasProfilePhoto => photoUrl != null && photoUrl!.isNotEmpty;

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    return years;
  }

  /// ⚠️ Tags for display
  List<String> get riskTags {
    final tags = <String>[];
    if (isFallRisk) tags.add("Fall Risk");
    if (isIsolation == true) tags.add("Isolation");
    if (manualRiskOverride != null) {
      tags.add("Risk: ${manualRiskOverride!.name.capitalize()}");
    }
    return tags;
  }
}

/// 🔄 Risk extension wrapper (moved to patient_risk.dart)
extension PatientRiskExtension on Patient {
  RiskLevel get resolvedRiskLevel => resolveRiskLevel(this);
}

/// 💅 String casing helper
extension StringCasing on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
