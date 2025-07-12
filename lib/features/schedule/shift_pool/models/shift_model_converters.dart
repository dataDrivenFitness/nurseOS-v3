// lib/features/schedule/shift_pool/models/shift_model_converters.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'shift_model.dart';

/// Firestore converters for ShiftModel with agency-scoped storage
class ShiftModelConverters {
  /// Get Firestore converter for shifts within a specific agency
  ///
  /// Usage:
  /// ```dart
  /// final shiftsCollection = ShiftModelConverters.getAgencyCollection('hospital_123');
  /// final shifts = await shiftsCollection.get();
  /// ```
  static CollectionReference<ShiftModel> getAgencyCollection(String agencyId) {
    return FirebaseFirestore.instance
        .collection('agencies')
        .doc(agencyId)
        .collection('shifts')
        .withConverter<ShiftModel>(
      fromFirestore: (snap, _) {
        final data = snap.data()!;
        return ShiftModel.fromJson({
          ...data,
          'id': snap.id,
          'agencyId': agencyId, // Ensure agencyId is set from path
        });
      },
      toFirestore: (shift, _) {
        final json = shift.toJson();
        json.remove('id'); // Remove ID from document data
        // agencyId is implicit in the path, but keep in data for consistency
        return json;
      },
    );
  }

  /// Get a specific shift document reference within an agency
  ///
  /// Usage:
  /// ```dart
  /// final shiftDoc = ShiftModelConverters.getAgencyShiftDoc('hospital_123', 'shift_456');
  /// final shift = await shiftDoc.get();
  /// ```
  static DocumentReference<ShiftModel> getAgencyShiftDoc(
    String agencyId,
    String shiftId,
  ) {
    return getAgencyCollection(agencyId).doc(shiftId);
  }

  /// Legacy converter for existing shifts collection (used during migration)
  ///
  /// This handles shifts stored in the old global `/shifts/` collection
  /// and assigns them to a default agency during migration.
  static final CollectionReference<ShiftModel> legacyCollection =
      FirebaseFirestore.instance.collection('shifts').withConverter<ShiftModel>(
    fromFirestore: (snap, _) {
      final data = snap.data()!;
      return ShiftModel.fromJson({
        ...data,
        'id': snap.id,
        // For legacy shifts, assign to default agency during migration
        'agencyId': data['agencyId'] ?? 'default_agency',
      });
    },
    toFirestore: (shift, _) {
      final json = shift.toJson();
      json.remove('id');
      return json;
    },
  );

  /// Create a new shift in the specified agency
  ///
  /// Usage:
  /// ```dart
  /// final newShift = ShiftModel(...);
  /// final shiftId = await ShiftModelConverters.createShift('hospital_123', newShift);
  /// ```
  static Future<String> createShift(String agencyId, ShiftModel shift) async {
    final collection = getAgencyCollection(agencyId);
    // Ensure the shift has the correct agencyId - create new instance if needed
    final shiftWithAgency = shift.agencyId == agencyId
        ? shift
        : ShiftModel(
            id: shift.id,
            agencyId: agencyId,
            startTime: shift.startTime,
            endTime: shift.endTime,
            createdAt: shift.createdAt,
            location: shift.location,
            facilityName: shift.facilityName,
            department: shift.department,
            assignedTo: shift.assignedTo,
            status: shift.status,
            requestedBy: shift.requestedBy,
            addressLine1: shift.addressLine1,
            addressLine2: shift.addressLine2,
            city: shift.city,
            state: shift.state,
            zip: shift.zip,
            roomNumber: shift.roomNumber,
            patientName: shift.patientName,
            specialRequirements: shift.specialRequirements,
            isNightShift: shift.isNightShift,
            isWeekendShift: shift.isWeekendShift,
          );

    final doc = await collection.add(shiftWithAgency);
    return doc.id;
  }

  /// Update an existing shift
  ///
  /// Usage:
  /// ```dart
  /// await ShiftModelConverters.updateShift('hospital_123', updatedShift);
  /// ```
  static Future<void> updateShift(String agencyId, ShiftModel shift) async {
    if (shift.id.isEmpty) {
      throw ArgumentError('Shift ID cannot be empty for updates');
    }

    final doc = getAgencyShiftDoc(agencyId, shift.id);
    await doc.update(shift.toJson());
  }

  /// Delete a shift (soft delete by updating status)
  ///
  /// Usage:
  /// ```dart
  /// await ShiftModelConverters.deleteShift('hospital_123', 'shift_456');
  /// ```
  static Future<void> deleteShift(String agencyId, String shiftId) async {
    final doc = getAgencyShiftDoc(agencyId, shiftId);
    await doc.update({'status': 'deleted'});
  }

  /// Query shifts for an agency with common filters
  ///
  /// Usage:
  /// ```dart
  /// final availableShifts = await ShiftModelConverters.queryShifts(
  ///   'hospital_123',
  ///   status: 'available',
  ///   startDate: DateTime.now(),
  /// );
  /// ```
  static Query<ShiftModel> queryShifts(
    String agencyId, {
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    String? assignedTo,
    bool? isAvailable,
  }) {
    Query<ShiftModel> query = getAgencyCollection(agencyId);

    // Filter by status
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    // Filter by assignment
    if (assignedTo != null) {
      query = query.where('assignedTo', isEqualTo: assignedTo);
    }

    // Filter by date range
    if (startDate != null) {
      query = query.where('startTime', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('endTime', isLessThanOrEqualTo: endDate);
    }

    return query;
  }

  /// Get available shifts for an agency
  static Query<ShiftModel> getAvailableShifts(String agencyId) {
    return queryShifts(agencyId, status: 'available')
        .where('assignedTo', isNull: true)
        .orderBy('startTime');
  }

  /// Get assigned shifts for a specific user in an agency
  static Query<ShiftModel> getUserShifts(String agencyId, String userId) {
    return queryShifts(agencyId, assignedTo: userId)
        .orderBy('startTime', descending: true);
  }

  /// Get upcoming shifts for an agency
  static Query<ShiftModel> getUpcomingShifts(String agencyId) {
    final now = DateTime.now();
    return queryShifts(agencyId, startDate: now).orderBy('startTime');
  }
}
