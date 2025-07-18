import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'shift_model.freezed.dart';
part 'shift_model.g.dart';

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
    String? unit,
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
    String? specialRequirements,
    @Default(false) bool isWeekendShift,
    @Default(false) bool isNightShift,
    @Default([]) List<String> assignedPatientIds,
    String? shiftType,
    double? hourlyRate,
    double? urgencyBonus,
    @Default('regular') String urgencyLevel,
    @Default([]) List<String> requiredCertifications,
    String? requestingNurseId,
    String? requestingNurseNote,
    String? createdBy,
  }) = _ShiftModel;

  factory ShiftModel.fromJson(Map<String, dynamic> json) =>
      _$ShiftModelFromJson(json);
}

// ═══════════════════════════════════════════════════════════════════
// EXTENSIONS: Safe accessors (no business logic here)
// ═══════════════════════════════════════════════════════════════════

extension ShiftModelExtensions on ShiftModel {
  Duration get duration => endTime.difference(startTime);
  bool get isAvailable => status == 'available';
  bool get isAssigned => assignedTo != null;

  bool hasRequestedBy(String userId) =>
      requestedBy.isNotEmpty && requestedBy.contains(userId);

  String get timeRange =>
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'
      ' - '
      '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

  String get durationText {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  String get displayLocation =>
      facilityName?.isNotEmpty == true ? facilityName! : location;

  String get fullAddress {
    final parts = <String>[];
    if (addressLine1?.isNotEmpty == true) parts.add(addressLine1!);
    if (addressLine2?.isNotEmpty == true) parts.add(addressLine2!);
    if (city?.isNotEmpty == true &&
        state?.isNotEmpty == true &&
        zip?.isNotEmpty == true) {
      parts.add('$city, $state $zip');
    }
    return parts.join(', ');
  }

  String get shiftTypeDisplay {
    if (isNightShift && isWeekendShift) return 'Night Weekend';
    if (isNightShift) return 'Night Shift';
    if (isWeekendShift) return 'Weekend Shift';
    return shiftType ?? 'Regular';
  }
}
