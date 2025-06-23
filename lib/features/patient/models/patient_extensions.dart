import 'package:cloud_firestore/cloud_firestore.dart';
import 'patient_model.dart';

CollectionReference<Map<String, dynamic>> rawPatients(FirebaseFirestore db) =>
    db.collection('patients');

CollectionReference<Patient> typedPatients(FirebaseFirestore db) =>
    rawPatients(db).withConverter<Patient>(
      fromFirestore: (snap, _) =>
          Patient.fromJson(snap.data()!).copyWith(id: snap.id),
      toFirestore: (p, _) => p.toJson(),
    );
