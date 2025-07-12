// lib/features/schedule/shift_pool/models/shift_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'shift_model.freezed.dart';
part 'shift_model.g.dart';

// Helper functions for timestamp conversion - matches ScheduledShiftModel pattern
DateTime? _nullableTimestampFromJson(dynamic json) {
  if (json == null) return null;
  final result = const TimestampConverter().fromJson(json);
  if (result == null) {
    throw ArgumentError(
        'Cannot convert timestamp to DateTime. Received: $json (${json.runtimeType})');
  }
  return result;
}

DateTime _timestampFromJson(dynamic json) {
  final result = const TimestampConverter().fromJson(json);
  if (result == null) {
    throw ArgumentError(
        'Cannot convert timestamp to DateTime. Received: $json (${json.runtimeType})');
  }
  return result;
}

Object? _timestampToJson(DateTime? dateTime) =>
    const TimestampConverter().toJson(dateTime);

@freezed
abstract class ShiftModel with _$ShiftModel {
  const factory ShiftModel({
    required String id,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime startTime,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime endTime,
    required String location,
    String? assignedTo,
    @Default('available') String status,
    @Default([]) List<String>? requestedBy,

    // MIGRATION: agencyId nullable during migration, will be required after
    String? agencyId,

    // 🆕 CRITICAL: Add patient assignment field for shift-centric architecture
    @Default([]) List<String>? assignedPatientIds,

    // Additional fields from Firestore documents (optional for compatibility)
    String? state,
    String? city,
    String? zip,
    String? addressLine1,
    String? addressLine2,
    String? roomNumber,
    String? patientName,
    String? department,
    String? facilityName,
    String? specialRequirements,
    @Default(false) bool isWeekendShift,
    @Default(false) bool isNightShift,
    @JsonKey(fromJson: _nullableTimestampFromJson, toJson: _timestampToJson)
    DateTime? createdAt,
  }) = _ShiftModel;

  factory ShiftModel.fromJson(Map<String, dynamic> json) =>
      _$ShiftModelFromJson(json);
}
