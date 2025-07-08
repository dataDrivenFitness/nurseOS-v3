// lib/features/schedule/models/scheduled_shift_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'scheduled_shift_model.freezed.dart';
part 'scheduled_shift_model.g.dart';

// Fixed helper functions - handle null values gracefully
DateTime _timestampFromJson(dynamic json) {
  final result = const TimestampConverter().fromJson(json);
  if (result == null) {
    // Instead of throwing an error, return a default DateTime
    // or throw a more specific error with the actual json value
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
  }) = _ScheduledShiftModel;

  factory ScheduledShiftModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduledShiftModelFromJson(json);
}
