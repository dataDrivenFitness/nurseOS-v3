// 📁 lib/features/work_history/models/work_session.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// These MUST match your file name exactly
part 'work_session.freezed.dart';

@freezed
abstract class WorkSession with _$WorkSession {
  const factory WorkSession({
    required String sessionId,
    required String userId,
    required DateTime startTime,
    DateTime? endTime,
    required double startLatitude,
    required double startLongitude,
    required double startAccuracy,
    required String startAddress,
    required DateTime startLocationTimestamp,
    double? endLatitude,
    double? endLongitude,
    double? endAccuracy,
    String? endAddress,
    DateTime? endLocationTimestamp,
    int? duration, // Duration in seconds
    String? department,
    String? shift,
    String? facility,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _WorkSession;

  const WorkSession._();

  /// Create from Firestore JSON with proper timestamp handling
  factory WorkSession.fromJson(Map<String, dynamic> json) {
    // Add safety checks for required DateTime fields
    final startTime = _parseDateTime(json['startTime']);
    final startLocationTimestamp =
        _parseDateTime(json['startLocationTimestamp']);
    final createdAt = _parseDateTime(json['createdAt']);
    final updatedAt = _parseDateTime(json['updatedAt']);

    if (startTime == null) {
      throw ArgumentError('startTime cannot be null');
    }
    if (startLocationTimestamp == null) {
      throw ArgumentError('startLocationTimestamp cannot be null');
    }
    if (createdAt == null) {
      throw ArgumentError('createdAt cannot be null');
    }
    if (updatedAt == null) {
      // If updatedAt is null, use createdAt as fallback
      debugPrint(
          '⚠️ updatedAt is null, using createdAt as fallback for session ${json['sessionId']}');
    }

    return WorkSession(
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String,
      startTime: startTime,
      endTime: _parseDateTime(json['endTime']),
      startLatitude: (json['startLatitude'] as num).toDouble(),
      startLongitude: (json['startLongitude'] as num).toDouble(),
      startAccuracy: (json['startAccuracy'] as num).toDouble(),
      startAddress: json['startAddress'] as String,
      startLocationTimestamp: startLocationTimestamp,
      endLatitude: json['endLatitude'] != null
          ? (json['endLatitude'] as num).toDouble()
          : null,
      endLongitude: json['endLongitude'] != null
          ? (json['endLongitude'] as num).toDouble()
          : null,
      endAccuracy: json['endAccuracy'] != null
          ? (json['endAccuracy'] as num).toDouble()
          : null,
      endAddress: json['endAddress'] as String?,
      endLocationTimestamp: _parseDateTime(json['endLocationTimestamp']),
      duration: json['duration'] as int?,
      department: json['department'] as String?,
      shift: json['shift'] as String?,
      facility: json['facility'] as String?,
      notes: json['notes'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt, // Use createdAt as fallback
    );
  }

  /// Convert to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'startLatitude': startLatitude,
      'startLongitude': startLongitude,
      'startAccuracy': startAccuracy,
      'startAddress': startAddress,
      'startLocationTimestamp': Timestamp.fromDate(startLocationTimestamp),
      'endLatitude': endLatitude,
      'endLongitude': endLongitude,
      'endAccuracy': endAccuracy,
      'endAddress': endAddress,
      'endLocationTimestamp': endLocationTimestamp != null
          ? Timestamp.fromDate(endLocationTimestamp!)
          : null,
      'duration': duration,
      'department': department,
      'shift': shift,
      'facility': facility,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Helper to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('⚠️ Failed to parse DateTime from string: $value');
        return null;
      }
    } else if (value is DateTime) {
      return value;
    }

    debugPrint('⚠️ Unknown DateTime format: ${value.runtimeType}');
    return null;
  }

  /// Check if this is an active session (no end time)
  bool get isActive => endTime == null;

  /// Get current or final duration
  Duration get currentDuration {
    if (duration != null) {
      return Duration(seconds: duration!);
    } else if (endTime != null) {
      return endTime!.difference(startTime);
    } else {
      // Active session - calculate current duration
      return DateTime.now().difference(startTime);
    }
  }

  /// Get formatted duration string
  String get formattedDuration {
    final dur = currentDuration;
    final hours = dur.inHours;
    final minutes = dur.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get time range string
  String get timeRange {
    final startStr = _formatTime(startTime);
    if (endTime != null) {
      final endStr = _formatTime(endTime!);
      return '$startStr - $endStr';
    } else {
      return 'Started at $startStr';
    }
  }

  /// Get location display string
  String get locationDisplay {
    if (startAddress.contains(',')) {
      return startAddress; // Already formatted coordinates
    } else {
      return '$startLatitude, $startLongitude';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }
}
