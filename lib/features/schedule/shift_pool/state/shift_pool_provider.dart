import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shift_model.dart';

final shiftPoolProvider = StreamProvider<List<ShiftModel>>((ref) {
  final query = FirebaseFirestore.instance
      .collection('shifts')
      .where('status', isEqualTo: 'available')
      .withConverter<ShiftModel>(
        fromFirestore: (snap, _) => ShiftModel.fromJson(snap.data()!..['id'] = snap.id),
        toFirestore: (shift, _) => shift.toJson(),
      );

  return query.snapshots().map((snap) => snap.docs.map((doc) => doc.data()).toList());
});
