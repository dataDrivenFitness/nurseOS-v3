// 📁 lib/shared/models/location_data.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'location_data.freezed.dart';
part 'location_data.g.dart';

/// 📍 LocationData model for GPS tracking in EVV and work sessions
///
/// This model captures location information for Electronic Visit Verification
/// and duty session tracking while maintaining HIPAA compliance.
@freezed
abstract class LocationData with _$LocationData {
  const factory LocationData({
    required double latitude,
    required double longitude,
    required double accuracy,
    String? address,
    String? facility,
    @TimestampConverter() required DateTime timestamp,
  }) = _LocationData;

  factory LocationData.fromJson(Map<String, dynamic> json) =>
      _$LocationDataFromJson(json);
}

/// 🔄 Extension methods for converting LocationData to WorkSession fields
extension LocationDataMapping on LocationData {
  /// Convert to start location fields for WorkSession
  Map<String, dynamic> toStartLocationMap() => {
        'startLatitude': latitude,
        'startLongitude': longitude,
        'startAccuracy': accuracy,
        'startAddress': address,
        'startFacility': facility,
        'startLocationTimestamp': timestamp,
      };

  /// Convert to end location fields for WorkSession
  Map<String, dynamic> toEndLocationMap() => {
        'endLatitude': latitude,
        'endLongitude': longitude,
        'endAccuracy': accuracy,
        'endAddress': address,
        'endFacility': facility,
        'endLocationTimestamp': timestamp,
      };

  /// Create a WorkSession-compatible Map for Firestore updates
  Map<String, dynamic> toFirestoreEndLocationUpdate() => {
        'endLatitude': latitude,
        'endLongitude': longitude,
        'endAccuracy': accuracy,
        'endAddress': address,
        'endFacility': facility,
        'endLocationTimestamp': Timestamp.fromDate(timestamp),
      };
}
