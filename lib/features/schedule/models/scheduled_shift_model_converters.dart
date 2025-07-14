// 📁 lib/features/schedule/models/scheduled_shift_model_converters.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'scheduled_shift_model.dart';

/// Firestore converters for ScheduledShiftModel with agency-scoped and independent shift storage
///
/// ARCHITECTURE: Agency-Scoped Shift Model
/// ========================================
/// Each shift belongs to exactly one agency OR is independent:
///
/// Agency Shifts:
/// - Path: /agencies/{agencyId}/scheduledShifts/{shiftId}
/// - Visibility: Only to agency admins and assigned nurses
/// - Patients: Must belong to same agency
///
/// Independent Shifts:
/// - Path: /independentShifts/{shiftId}
/// - Visibility: Only to creating nurse
/// - Patients: Must be nurse-owned (no agency)
///
/// Multi-Agency Nurse Daily Schedule:
/// - Tuesday 8am-4pm: Metro Hospital shift (agency patients)
/// - Tuesday 6pm-10pm: Sunrise Care shift (agency patients)
/// - Tuesday 11pm-7am: Independent shift (own patients)
///
/// This ensures clean data isolation, billing boundaries, and compliance.
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

  /// Get Firestore converter for independent nurse shifts (no agency scoping)
  ///
  /// Independent shifts are stored in a global collection since they don't belong to any agency
  ///
  /// Usage:
  /// ```dart
  /// final independentShifts = ScheduledShiftModelConverters.getIndependentCollection();
  /// final userShifts = independentShifts.where('createdBy', isEqualTo: userId);
  /// ```
  static CollectionReference<ScheduledShiftModel> getIndependentCollection() {
    return FirebaseFirestore.instance
        .collection('independentShifts')
        .withConverter<ScheduledShiftModel>(
      fromFirestore: (snap, _) {
        final data = snap.data()!;
        return ScheduledShiftModel.fromJson({
          ...data,
          'id': snap.id,
          // Independent shifts should have null agencyId
          'agencyId': null,
        });
      },
      toFirestore: (shift, _) {
        final json = shift.toJson();
        json.remove('id'); // Remove ID from document data
        // Ensure agencyId is null for independent shifts
        json['agencyId'] = null;
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

  /// Get a specific independent shift document reference
  ///
  /// Usage:
  /// ```dart
  /// final shiftDoc = ScheduledShiftModelConverters.getIndependentShiftDoc('shift_456');
  /// final shift = await shiftDoc.get();
  /// ```
  static DocumentReference<ScheduledShiftModel> getIndependentShiftDoc(
    String shiftId,
  ) {
    return getIndependentCollection().doc(shiftId);
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
    final now = DateTime.now();

    // Ensure the shift has the correct agencyId and metadata - create new instance with all fields
    final shiftWithAgency = ScheduledShiftModel(
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
      assignedPatientIds: shift.assignedPatientIds,
      // Include new independent nurse support fields
      isUserCreated: shift.isUserCreated,
      createdBy: shift.createdBy,
      createdAt: shift.createdAt ?? now,
      updatedAt: now,
    );

    final doc = await collection.add(shiftWithAgency);
    return doc.id;
  }

  /// Create a new independent shift (no agency)
  ///
  /// Usage:
  /// ```dart
  /// final independentShift = ScheduledShiftModel(...);
  /// final shiftId = await ScheduledShiftModelConverters.createIndependentShift(independentShift);
  /// ```
  static Future<String> createIndependentShift(
      ScheduledShiftModel shift) async {
    final collection = getIndependentCollection();
    final now = DateTime.now();

    // Ensure the shift is properly configured for independent use
    final independentShift = ScheduledShiftModel(
      id: shift.id,
      agencyId: null, // No agency for independent shifts
      assignedTo: shift.assignedTo,
      status: shift.status,
      isConfirmed: shift.isConfirmed,
      startTime: shift.startTime,
      endTime: shift.endTime,
      locationType: shift.locationType,
      facilityName: shift.facilityName,
      address: shift.address,
      assignedPatientIds: shift.assignedPatientIds,
      // Independent shifts are always user-created
      isUserCreated: true,
      createdBy: shift.createdBy,
      createdAt: shift.createdAt ?? now,
      updatedAt: now,
    );

    final doc = await collection.add(independentShift);
    return doc.id;
  }

  /// Update an existing scheduled shift (agency or independent)
  ///
  /// Usage:
  /// ```dart
  /// await ScheduledShiftModelConverters.updateShift(updatedShift);
  /// ```
  static Future<void> updateShift(ScheduledShiftModel shift) async {
    if (shift.id.isEmpty) {
      throw ArgumentError('Shift ID cannot be empty for updates');
    }

    final now = DateTime.now();
    final updatedShift = shift.copyWith(updatedAt: now);

    DocumentReference<ScheduledShiftModel> doc;

    if (shift.agencyId != null) {
      // Agency shift
      doc = getAgencyShiftDoc(shift.agencyId!, shift.id);
    } else {
      // Independent shift
      doc = getIndependentShiftDoc(shift.id);
    }

    await doc.update(updatedShift.toJson());
  }

  /// Delete a scheduled shift (soft delete by updating status)
  ///
  /// Usage:
  /// ```dart
  /// await ScheduledShiftModelConverters.deleteShift(shift);
  /// ```
  static Future<void> deleteShift(ScheduledShiftModel shift) async {
    final now = DateTime.now();

    DocumentReference<ScheduledShiftModel> doc;

    if (shift.agencyId != null) {
      // Agency shift
      doc = getAgencyShiftDoc(shift.agencyId!, shift.id);
    } else {
      // Independent shift
      doc = getIndependentShiftDoc(shift.id);
    }

    await doc.update({
      'status': 'cancelled',
      'updatedAt': Timestamp.fromDate(now),
    });
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
    bool? isUserCreated,
    String? createdBy,
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

    // Filter by creation type (user vs agency created)
    if (isUserCreated != null) {
      query = query.where('isUserCreated', isEqualTo: isUserCreated);
    }

    // Filter by creator
    if (createdBy != null) {
      query = query.where('createdBy', isEqualTo: createdBy);
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

  /// Query independent shifts with common filters
  ///
  /// Usage:
  /// ```dart
  /// final userIndependentShifts = ScheduledShiftModelConverters.queryIndependentShifts(
  ///   createdBy: 'user_123',
  /// );
  /// ```
  static Query<ScheduledShiftModel> queryIndependentShifts({
    String? assignedTo,
    String? status,
    bool? isConfirmed,
    String? createdBy,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query<ScheduledShiftModel> query = getIndependentCollection();

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

    // Filter by creator
    if (createdBy != null) {
      query = query.where('createdBy', isEqualTo: createdBy);
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

  /// Get all shifts for a user (both agency and independent)
  ///
  /// This method respects agency boundaries while providing nurses
  /// a unified view of their daily schedule across all contexts.
  ///
  /// Usage:
  /// ```dart
  /// final allUserShifts = await ScheduledShiftModelConverters.getAllUserShifts(
  ///   userId,
  ///   userAgencies: ['metro_hospital', 'sunrise_care'], // From user.agencyRoles
  /// );
  /// ```
  ///
  /// Returns shifts in chronological order:
  /// - 8am-4pm: Metro Hospital shift
  /// - 6pm-10pm: Sunrise Care shift
  /// - 11pm-7am: Independent shift
  static Future<List<ScheduledShiftModel>> getAllUserShifts(
    String userId, {
    List<String>? userAgencies,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<ScheduledShiftModel> allShifts = [];

    // Get independent shifts
    Query<ScheduledShiftModel> independentQuery = queryIndependentShifts(
      assignedTo: userId,
      startDate: startDate,
      endDate: endDate,
    );
    final independentShifts = await independentQuery.get();
    allShifts.addAll(independentShifts.docs.map((doc) => doc.data()));

    // Get agency shifts
    if (userAgencies != null) {
      for (final agencyId in userAgencies) {
        Query<ScheduledShiftModel> agencyQuery = queryShifts(
          agencyId,
          assignedTo: userId,
          startDate: startDate,
          endDate: endDate,
        );
        final agencyShifts = await agencyQuery.get();
        allShifts.addAll(agencyShifts.docs.map((doc) => doc.data()));
      }
    }

    // Sort by start time
    allShifts.sort((a, b) => a.startTime.compareTo(b.startTime));
    return allShifts;
  }

  /// Get scheduled shifts for a specific user in an agency
  static Query<ScheduledShiftModel> getUserScheduledShifts(
      String agencyId, String userId) {
    return queryShifts(agencyId, assignedTo: userId).orderBy('startTime');
  }

  /// Get user-created shifts in an agency (for admin oversight)
  static Query<ScheduledShiftModel> getUserCreatedShifts(String agencyId) {
    return queryShifts(agencyId, isUserCreated: true)
        .orderBy('createdAt', descending: true);
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
