// lib/features/schedule/shift_pool/models/shift_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'shift_model.freezed.dart';
part 'shift_model.g.dart';

@freezed
abstract class ShiftModel with _$ShiftModel {
  const factory ShiftModel({
    required String id,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime startTime,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime endTime,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime createdAt,
    required String location,
    String? facilityName,
    String? department,
    String? assignedTo,
    @Default('available') String status,
    @Default([]) List<String> requestedBy,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zip,
    String? roomNumber,
    String? patientName,
    List<String>? specialRequirements,
    @Default(false) bool isNightShift,
    @Default(false) bool isWeekendShift,
  }) = _ShiftModel;

  factory ShiftModel.fromJson(Map<String, dynamic> json) =>
      _$ShiftModelFromJson(json);
}

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
