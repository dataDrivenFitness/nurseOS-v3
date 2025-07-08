// Mock Admin Dashboard Functions
// Add this to your test utils or run in Firestore console

import 'package:cloud_firestore/cloud_firestore.dart';

class MockAdminDashboard {
  static final _firestore = FirebaseFirestore.instance;

  /// Simulate admin approving a shift request
  static Future<void> approveShiftRequest({
    required String shiftId,
    required String approvedNurseUid,
  }) async {
    print('🏥 ADMIN: Approving shift $shiftId for nurse $approvedNurseUid');

    final shiftRef = _firestore.collection('shifts').doc(shiftId);

    await _firestore.runTransaction((tx) async {
      final shiftDoc = await tx.get(shiftRef);
      if (!shiftDoc.exists) {
        throw Exception('Shift not found');
      }

      final currentData = shiftDoc.data()!;
      final requestedBy = List<String>.from(currentData['requestedBy'] ?? []);

      // Verify the nurse actually requested this shift
      if (!requestedBy.contains(approvedNurseUid)) {
        throw Exception('Nurse $approvedNurseUid did not request this shift');
      }

      print('📋 ADMIN: Current requests: $requestedBy');
      print('✅ ADMIN: Assigning shift to $approvedNurseUid');

      // Update the shift with assignment
      tx.update(shiftRef, {
        'assignedTo': approvedNurseUid, // ← Assign to the nurse
        'status': 'accepted', // ← Change status from 'available'
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': 'admin_mock_uid', // Mock admin UID
      });

      print('🎉 ADMIN: Shift approved and assigned!');
    });
  }

  /// Get all shifts pending approval
  static Future<void> showPendingRequests() async {
    final query = await _firestore
        .collection('shifts')
        .where('status', isEqualTo: 'available')
        .where('requestedBy', isNotEqualTo: []).get();

    print('\n📋 PENDING SHIFT REQUESTS:');
    print('=' * 50);

    for (final doc in query.docs) {
      final data = doc.data();
      final requestedBy = List<String>.from(data['requestedBy'] ?? []);

      if (requestedBy.isNotEmpty) {
        print('🔹 Shift: ${doc.id}');
        print('   Location: ${data['location']}');
        print('   Requested by: ${requestedBy.length} nurse(s)');
        print('   Nurse UIDs: $requestedBy');
        print('');
      }
    }
  }

  /// Quick approve the first nurse who requested a shift
  static Future<void> quickApproveFirstRequest(String shiftId) async {
    final shiftDoc = await _firestore.collection('shifts').doc(shiftId).get();
    if (!shiftDoc.exists) {
      print('❌ Shift $shiftId not found');
      return;
    }

    final data = shiftDoc.data()!;
    final requestedBy = List<String>.from(data['requestedBy'] ?? []);

    if (requestedBy.isEmpty) {
      print('❌ No requests for shift $shiftId');
      return;
    }

    final firstRequester = requestedBy.first;
    print('🚀 Quick approving first requester: $firstRequester');

    await approveShiftRequest(
      shiftId: shiftId,
      approvedNurseUid: firstRequester,
    );
  }
}
