// 📁 lib/features/schedule/models/scheduled_shift_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'scheduled_shift_model.freezed.dart';
part 'scheduled_shift_model.g.dart';

// Helper functions for timestamp conversion
DateTime _timestampFromJson(dynamic json) {
  final result = const TimestampConverter().fromJson(json);
  if (result == null) {
    throw ArgumentError(
        'Cannot convert timestamp to DateTime. Received: $json (${json.runtimeType})');
  }
  return result;
}

Object? _timestampToJson(DateTime dateTime) =>
    const TimestampConverter().toJson(dateTime);

@freezed
abstract class ScheduledShiftModel with _$ScheduledShiftModel {
  const factory ScheduledShiftModel({
    required String id,
    required String assignedTo,
    required String status,
    required String locationType,
    String? facilityName,
    String? address,
    List<String>? assignedPatientIds,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime startTime,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime endTime,
    required bool isConfirmed,

    // ═══════════════════════════════════════════════════════════════
    // 🏠 INDEPENDENT NURSE SUPPORT FIELDS (NEW)
    // ═══════════════════════════════════════════════════════════════

    /// Identifies which agency created this shift (null for independent nurses)
    /// When null, indicates this is an independently created shift
    /// When populated, indicates agency-created shift with proper isolation
    ///
    /// CRITICAL: Agency-scoped shift architecture ensures:
    /// - Data isolation between agencies
    /// - Independent shifts separate from agency work
    /// - Clear billing and compliance boundaries
    /// - Agency admins only see their own shifts
    String? agencyId,

    /// Indicates if this shift was created by the nurse themselves
    /// When true: Nurse created their own shift (independent practice)
    /// When false: Shift was created by agency/admin (traditional model)
    ///
    /// Independent nurses can create multiple shifts per day:
    /// - One shift per agency they work for
    /// - One shift for independent practice
    /// - Each shift maintains clear organizational boundaries
    @Default(false) bool isUserCreated,

    /// Who created this shift (for audit trail and HIPAA compliance)
    /// Should be set to the nurse's UID for user-created shifts
    /// Should be set to admin/agency UID for agency-created shifts
    String? createdBy,

    // ═══════════════════════════════════════════════════════════════
    // 🔄 METADATA FIELDS (ENHANCED)
    // ═══════════════════════════════════════════════════════════════

    /// When this shift record was created
    @TimestampConverter() DateTime? createdAt,

    /// When this shift record was last modified
    @TimestampConverter() DateTime? updatedAt,
  }) = _ScheduledShiftModel;

  factory ScheduledShiftModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduledShiftModelFromJson(json);
}
