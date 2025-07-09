// lib/features/schedule/models/scheduled_shift_model.dart

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
    String? address, // Keep for backward compatibility
    // New structured address fields
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zip,
    List<String>? assignedPatientIds,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime startTime,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime endTime,
    required bool isConfirmed,
  }) = _ScheduledShiftModel;

  factory ScheduledShiftModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduledShiftModelFromJson(json);
}
