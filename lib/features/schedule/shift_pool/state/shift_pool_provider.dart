// 📁 lib/features/schedule/shift_pool/state/shift_pool_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/features/agency/state/agency_context_provider.dart';
import 'package:rxdart/rxdart.dart';
import '../models/shift_model.dart';

final shiftPoolProvider = StreamProvider<List<ShiftModel>>((ref) {
  final user = ref.watch(authControllerProvider).value;

  if (user == null) {
    return const Stream.empty();
  }

  // Get agencies where user is a member (agency-controlled access)
  final userAgenciesAsync = ref.watch(userAgenciesFromMembershipProvider);

  return userAgenciesAsync.when(
    data: (agencyIds) {
      if (agencyIds.isEmpty) {
        // No agency membership = no agency shifts visible
        return const Stream.empty();
      }

      // Create streams for each agency the nurse belongs to
      final allStreams = agencyIds.map((agencyId) {
        return FirebaseFirestore.instance
            .collection('agencies')
            .doc(agencyId)
            .collection('shifts')
            .where('status', isEqualTo: 'available')
            .withConverter<ShiftModel>(
              fromFirestore: (snap, _) => ShiftModel.fromJson({
                ...snap.data()!,
                'id': snap.id,
                'agencyId': agencyId,
              }),
              toFirestore: (shift, _) => shift.toJson(),
            )
            .snapshots()
            .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
      });

      // Combine streams from all user's agencies
      return Rx.combineLatestList(allStreams).map(
        (listOfLists) {
          final combined = listOfLists.expand((x) => x).toList();
          combined.sort((a, b) => a.startTime.compareTo(b.startTime));
          return combined;
        },
      );
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});
