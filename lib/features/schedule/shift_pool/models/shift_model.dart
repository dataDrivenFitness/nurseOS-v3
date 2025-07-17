// 📁 lib/features/schedule/shift_pool/models/shift_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'shift_model.freezed.dart';
part 'shift_model.g.dart';

// Timestamp conversion helpers
DateTime _timestampFromJson(dynamic json) {
  final result = const TimestampConverter().fromJson(json);
  if (result == null) {
    throw ArgumentError(
        'Cannot convert timestamp to DateTime. Received: $json (${json.runtimeType})');
  }
  return result;
}

DateTime? _nullableTimestampFromJson(dynamic json) {
  if (json == null) return null;
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
    String? agencyId,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime startTime,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required DateTime endTime,
    @JsonKey(fromJson: _nullableTimestampFromJson, toJson: _timestampToJson)
    DateTime? createdAt,
    @JsonKey(fromJson: _nullableTimestampFromJson, toJson: _timestampToJson)
    DateTime? updatedAt,
    required String location,
    String? facilityName,
    String? department,
    String? assignedTo,
    @Default('available') String status,
    @Default([]) List<String>? requestedBy,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? zip,
    String? roomNumber,
    String? patientName,
    String? specialRequirements,
    @Default(false) bool isWeekendShift,
    @Default(false) bool isNightShift,
    @Default([]) List<String>? assignedPatientIds,
    String? shiftType,
    double? hourlyRate,
    String? createdBy,
  }) = _ShiftModel;

  factory ShiftModel.fromJson(Map<String, dynamic> json) =>
      _$ShiftModelFromJson(json);
}

/// Extension methods for ShiftModel
extension ShiftModelExtensions on ShiftModel {
  /// Get duration of the shift
  Duration get duration => endTime.difference(startTime);

  /// Check if shift is available for requests
  bool get isAvailable => status == 'available';

  /// Check if shift is already assigned
  bool get isAssigned => assignedTo != null;

  /// Check if user has already requested this shift
  bool hasRequestedBy(String userId) {
    if (requestedBy == null || requestedBy!.isEmpty) return false;
    return requestedBy!.contains(userId);
  }

  /// Get formatted time range
  String get timeRange {
    final startStr =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final endStr =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }

  /// Get formatted duration
  String get durationText {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  /// Get display name for the shift location
  String get displayLocation {
    if (facilityName?.isNotEmpty == true) {
      return facilityName!;
    }
    return location;
  }

  /// Get full address string
  String get fullAddress {
    final parts = <String>[];
    if (addressLine1?.isNotEmpty == true) {
      parts.add(addressLine1!);
    }
    if (addressLine2?.isNotEmpty == true) {
      parts.add(addressLine2!);
    }
    if (city?.isNotEmpty == true &&
        state?.isNotEmpty == true &&
        zip?.isNotEmpty == true) {
      parts.add('$city, $state $zip');
    }
    return parts.join(', ');
  }

  /// Get shift type display text
  String get shiftTypeDisplay {
    if (isNightShift && isWeekendShift) return 'Night Weekend';
    if (isNightShift) return 'Night Shift';
    if (isWeekendShift) return 'Weekend Shift';
    return shiftType ?? 'Regular';
  }
}
