// lib/features/schedule/models/scheduled_shift_model_converters.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'scheduled_shift_model.dart';

/// Firestore converters for ScheduledShiftModel with agency-scoped storage
class ScheduledShiftModelConverters {
  /// Get Firestore converter for scheduled shifts within a specific agency
  ///
  /// Usage:
  /// ```dart
  /// final shiftsCollection = ScheduledShiftModelConverters.getAgencyCollection('hospital_123');
  /// final shifts = await shiftsCollection.get();
  /// ```
  static CollectionReference<ScheduledShiftModel> getAgencyCollection(
      String agencyId) {
    return FirebaseFirestore.instance
        .collection('agencies')
        .doc(agencyId)
        .collection('scheduledShifts')
        .withConverter<ScheduledShiftModel>(
      fromFirestore: (snap, _) {
        final data = snap.data()!;
        return ScheduledShiftModel.fromJson({
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

  /// Get a specific scheduled shift document reference within an agency
  ///
  /// Usage:
  /// ```dart
  /// final shiftDoc = ScheduledShiftModelConverters.getAgencyShiftDoc('hospital_123', 'shift_456');
  /// final shift = await shiftDoc.get();
  /// ```
  static DocumentReference<ScheduledShiftModel> getAgencyShiftDoc(
    String agencyId,
    String shiftId,
  ) {
    return getAgencyCollection(agencyId).doc(shiftId);
  }

  /// Legacy converter for existing scheduled shifts collection (used during migration)
  ///
  /// This handles shifts stored in the old global `/scheduledShifts/` collection
  /// and assigns them to a default agency during migration.
  static final CollectionReference<ScheduledShiftModel> legacyCollection =
      FirebaseFirestore.instance
          .collection('scheduledShifts')
          .withConverter<ScheduledShiftModel>(
    fromFirestore: (snap, _) {
      final data = snap.data()!;
      return ScheduledShiftModel.fromJson({
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

  /// Create a new scheduled shift in the specified agency
  ///
  /// Usage:
  /// ```dart
  /// final newShift = ScheduledShiftModel(...);
  /// final shiftId = await ScheduledShiftModelConverters.createShift('hospital_123', newShift);
  /// ```
  static Future<String> createShift(
      String agencyId, ScheduledShiftModel shift) async {
    final collection = getAgencyCollection(agencyId);
    // Ensure the shift has the correct agencyId - create new instance if needed
    final shiftWithAgency = shift.agencyId == agencyId
        ? shift
        : ScheduledShiftModel(
            id: shift.id,
            agencyId: agencyId,
            assignedTo: shift.assignedTo,
            status: shift.status,
            isConfirmed: shift.isConfirmed,
            startTime: shift.startTime,
            endTime: shift.endTime,
            locationType: shift.locationType,
            facilityName: shift.facilityName,
            address: shift.address,
            addressLine1: shift.addressLine1,
            addressLine2: shift.addressLine2,
            city: shift.city,
            state: shift.state,
            zip: shift.zip,
            assignedPatientIds: shift.assignedPatientIds,
          );

    final doc = await collection.add(shiftWithAgency);
    return doc.id;
  }

  /// Update an existing scheduled shift
  ///
  /// Usage:
  /// ```dart
  /// await ScheduledShiftModelConverters.updateShift('hospital_123', updatedShift);
  /// ```
  static Future<void> updateShift(
      String agencyId, ScheduledShiftModel shift) async {
    if (shift.id.isEmpty) {
      throw ArgumentError('Shift ID cannot be empty for updates');
    }

    final doc = getAgencyShiftDoc(agencyId, shift.id);
    await doc.update(shift.toJson());
  }

  /// Delete a scheduled shift (soft delete by updating status)
  ///
  /// Usage:
  /// ```dart
  /// await ScheduledShiftModelConverters.deleteShift('hospital_123', 'shift_456');
  /// ```
  static Future<void> deleteShift(String agencyId, String shiftId) async {
    final doc = getAgencyShiftDoc(agencyId, shiftId);
    await doc.update({'status': 'cancelled'});
  }

  /// Query scheduled shifts for an agency with common filters
  ///
  /// Usage:
  /// ```dart
  /// final confirmedShifts = await ScheduledShiftModelConverters.queryShifts(
  ///   'hospital_123',
  ///   assignedTo: 'user_123',
  ///   isConfirmed: true,
  /// );
  /// ```
  static Query<ScheduledShiftModel> queryShifts(
    String agencyId, {
    String? assignedTo,
    String? status,
    bool? isConfirmed,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query<ScheduledShiftModel> query = getAgencyCollection(agencyId);

    // Filter by assigned user
    if (assignedTo != null) {
      query = query.where('assignedTo', isEqualTo: assignedTo);
    }

    // Filter by status
    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    // Filter by confirmation status
    if (isConfirmed != null) {
      query = query.where('isConfirmed', isEqualTo: isConfirmed);
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

  /// Get scheduled shifts for a specific user in an agency
  static Query<ScheduledShiftModel> getUserScheduledShifts(
      String agencyId, String userId) {
    return queryShifts(agencyId, assignedTo: userId).orderBy('startTime');
  }

  /// Get unconfirmed shifts for an agency
  static Query<ScheduledShiftModel> getUnconfirmedShifts(String agencyId) {
    return queryShifts(agencyId, isConfirmed: false)
        .where('status', isEqualTo: 'scheduled')
        .orderBy('startTime');
  }

  /// Get upcoming confirmed shifts for an agency
  static Query<ScheduledShiftModel> getUpcomingConfirmedShifts(
      String agencyId) {
    final now = DateTime.now();
    return queryShifts(agencyId, isConfirmed: true, startDate: now).where(
        'status',
        whereIn: ['scheduled', 'confirmed']).orderBy('startTime');
  }

  /// Get active shifts (currently in progress) for an agency
  static Query<ScheduledShiftModel> getActiveShifts(String agencyId) {
    final now = DateTime.now();
    return getAgencyCollection(agencyId)
        .where('startTime', isLessThanOrEqualTo: now)
        .where('endTime', isGreaterThan: now)
        .where('status',
            whereIn: ['confirmed', 'in_progress']).orderBy('startTime');
  }

  /// Get shifts that need confirmation within a time window
  static Query<ScheduledShiftModel> getShiftsNeedingConfirmation(
    String agencyId, {
    Duration timeWindow = const Duration(hours: 24),
  }) {
    final now = DateTime.now();
    final windowEnd = now.add(timeWindow);

    return queryShifts(agencyId, isConfirmed: false)
        .where('startTime', isGreaterThan: now)
        .where('startTime', isLessThanOrEqualTo: windowEnd)
        .where('status', isEqualTo: 'scheduled')
        .orderBy('startTime');
  }
}
