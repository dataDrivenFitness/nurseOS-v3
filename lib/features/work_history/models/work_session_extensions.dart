import 'package:nurseos_v3/features/work_history/models/work_session.dart';

extension WorkSessionExtensions on WorkSession {
  /// Get formatted time range for display
  String get timeRange {
    final start =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    if (endTime == null) {
      return '$start - Active';
    }
    final end =
        '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  /// Get formatted duration
  String get formattedDuration {
    if (duration == null) {
      final now = DateTime.now();
      final elapsed = now.difference(startTime);
      final hours = elapsed.inHours;
      final minutes = elapsed.inMinutes.remainder(60);
      return '${hours}h ${minutes}m (active)';
    }

    final hours = duration! ~/ 3600;
    final minutes = (duration! % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  /// Get location display
  String get locationDisplay {
    return startAddress;
    return '${startLatitude.toStringAsFixed(4)}, ${startLongitude.toStringAsFixed(4)}';
  }

  /// Get work context map
  Map<String, String?> get workContext {
    return {
      'department': department,
      'shift': shift,
      'facility': facility,
    };
  }

  /// Check if session is active
  bool get isActive => endTime == null;

  /// Get session duration in seconds
  int get sessionDuration {
    if (duration != null) return duration!;
    return DateTime.now().difference(startTime).inSeconds;
  }
}
