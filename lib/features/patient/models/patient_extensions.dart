import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // 👈 for Uri.encodeComponent (safe URL formatting)
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
  /// 📛 Full name (first + last)
  String get fullName => '$firstName $lastName';

  /// ⚥ Sex label formatting
  String get sexLabel {
    final value = biologicalSex?.toLowerCase();
    return switch (value) {
      'male' => 'Male',
      'female' => 'Female',
      'unspecified' || null => 'Unspecified',
      _ => value.capitalize(),
    };
  }

  /// 🔤 Initials for avatar/fallback
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return (f + l).toUpperCase();
  }

  /// 🖼️ Photo presence check
  bool get hasProfilePhoto => photoUrl != null && photoUrl!.isNotEmpty;

  /// 🎂 Age calculation from birthdate
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

  /// ⚠️ Clinical risk flags for UI tags
  List<String> get riskTags {
    final tags = <String>[];
    if (isFallRisk) tags.add("Fall Risk");
    if (isIsolation == true) tags.add("Isolation");
    if (manualRiskOverride != null) {
      tags.add("Risk: ${manualRiskOverride!.name.capitalize()}");
    }
    return tags;
  }

  /// 🏡 Whether patient is at home/residence
  bool get isAtResidence => location.toLowerCase() == 'residence';

  /// 📍 Address formatting (multiline or inline, fallback safe)
  String? get formattedAddress {
    if (!isAtResidence) return null;
    final parts = [
      addressLine1,
      if (addressLine2?.isNotEmpty == true) addressLine2,
      [city, state].where((s) => s?.isNotEmpty == true).join(', '),
      zip
    ].where((part) => part != null && part.isNotEmpty).map((e) => e!).toList();

    if (parts.isEmpty) return null;
    return parts.join('\n');
  }

  /// 🏥 In-facility location label (e.g., "ICU · Room 12B")
  String? get facilityLocationDisplay {
    if (isAtResidence) return null;
    if ((department?.isEmpty ?? true) && (roomNumber?.isEmpty ?? true)) {
      return null;
    }
    final dept = department?.trim();
    final room = roomNumber?.trim();
    if (dept != null && room != null && dept.isNotEmpty && room.isNotEmpty) {
      return '$dept · Room $room';
    }
    return dept ?? (room != null ? 'Room $room' : null);
  }

  /// 🗺️ Launchable map URL (Apple Maps format, fallback-safe)
  String? get mapLaunchUrl {
    if (!isAtResidence) return null;
    final addr = formattedAddress;
    if (addr == null) return null;
    final encoded = Uri.encodeComponent(addr.replaceAll('\n', ', '));
    return 'https://maps.apple.com/?q=$encoded';
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
