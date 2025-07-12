// lib/features/schedule/models/scheduled_shift_model_extensions.dart

import 'scheduled_shift_model.dart';

/// Extensions for ScheduledShiftModel with helper methods and computed properties
extension ScheduledShiftModelExtensions on ScheduledShiftModel {
  
  // ═══════════════════════════════════════════════════════════════
  // Duration & Timing Methods
  // ═══════════════════════════════════════════════════════════════

  /// Get shift duration in hours
  double get durationInHours {
    return endTime.difference(startTime).inMinutes / 60.0;
  }

  /// Get shift duration as formatted string
  String get durationText {
    final hours = durationInHours;
    if (hours == hours.toInt()) {
      return '${hours.toInt()}h';
    }
    return '${hours.toStringAsFixed(1)}h';
  }

  /// Check if shift is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if shift is upcoming (starts within next 24 hours)
  bool get isUpcoming {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return startTime.isAfter(now) && startTime.isBefore(tomorrow);
  }

  /// Check if shift is in the past
  bool get isPast {
    return endTime.isBefore(DateTime.now());
  }

  /// Get time until shift starts (if upcoming)
  Duration? get timeUntilStart {
    final now = DateTime.now();
    if (startTime.isBefore(now)) return null;
    return startTime.difference(now);
  }

  /// Get time until shift ends (if active)
  Duration? get timeUntilEnd {
    final now = DateTime.now();
    if (endTime.isBefore(now) || startTime.isAfter(now)) return null;
    return endTime.difference(now);
  }

  // ═══════════════════════════════════════════════════════════════
  // Status & Confirmation Methods
  // ═══════════════════════════════════════════════════════════════

  /// Check if shift is confirmed by the assigned nurse
  bool get isConfirmedShift => isConfirmed;

  /// Check if shift needs confirmation
  bool get needsConfirmation => !isConfirmed && isUpcoming;

  /// Get status display text with proper capitalization
  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Scheduled';
      case 'confirmed':
        return 'Confirmed';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'no_show':
        return 'No Show';
      default:
        return status.substring(0, 1).toUpperCase() + 
               status.substring(1).toLowerCase();
    }
  }

  /// Check if shift can be started
  bool get canBeStarted {
    final now = DateTime.now();
    final allowEarlyStart = startTime.subtract(const Duration(minutes: 15));
    return isConfirmed && 
           now.isAfter(allowEarlyStart) && 
           now.isBefore(endTime) &&
           (status == 'scheduled' || status == 'confirmed');
  }

  /// Check if shift can be completed
  bool get canBeCompleted {
    return isActive && 
           (status == 'in_progress' || status == 'confirmed');
  }

  // ═══════════════════════════════════════════════════════════════
  // Location & Address Methods
  // ═══════════════════════════════════════════════════════════════

  /// Get full address as single string
  String? get fullAddress {
    // Try structured address first
    if (addressLine1?.isNotEmpty == true || city?.isNotEmpty == true) {
      final parts = <String>[];
      if (addressLine1?.isNotEmpty == true) parts.add(addressLine1!);
      if (addressLine2?.isNotEmpty == true) parts.add(addressLine2!);
      if (city?.isNotEmpty == true) parts.add(city!);
      if (state?.isNotEmpty == true) parts.add(state!);
      if (zip?.isNotEmpty == true) parts.add(zip!);
      return parts.join(', ');
    }
    
    // Fallback to legacy address field
    return address;
  }

  /// Get display location name
  String get displayLocation {
    if (facilityName?.isNotEmpty == true) {
      return facilityName!;
    }
    return locationType.substring(0, 1).toUpperCase() + 
           locationType.substring(1);
  }

  /// Check if shift has a physical address
  bool get hasAddress {
    return fullAddress?.isNotEmpty == true;
  }

  /// Get address for navigation/maps
  String? get navigationAddress {
    return fullAddress;
  }

  /// Check if location is a facility vs home care
  bool get isFacilityLocation {
    return locationType == 'facility' || 
           locationType == 'hospital' || 
           locationType == 'clinic';
  }

  /// Check if location is home/community based
  bool get isHomeCareLocation {
    return locationType == 'home' || 
           locationType == 'residence' || 
           locationType == 'community';
  }

  // ═══════════════════════════════════════════════════════════════
  // Patient Assignment Methods
  // ═══════════════════════════════════════════════════════════════

  /// Check if shift has patient assignments
  bool get hasPatientAssignments => 
      assignedPatientIds?.isNotEmpty == true;

  /// Get number of assigned patients
  int get patientCount => assignedPatientIds?.length ?? 0;

  /// Get patient assignment summary
  String get patientAssignmentSummary {
    if (!hasPatientAssignments) return 'No patients assigned';
    
    final count = patientCount;
    return '$count patient${count != 1 ? 's' : ''} assigned';
  }

  /// Check if specific patient is assigned to this shift
  bool isPatientAssigned(String patientId) {
    return assignedPatientIds?.contains(patientId) ?? false;
  }

  // ═══════════════════════════════════════════════════════════════
  // Priority & Classification Methods
  // ═══════════════════════════════════════════════════════════════

  /// Get priority level based on status and timing
  ScheduledShiftPriority get priority {
    if (status == 'cancelled' || isPast) {
      return ScheduledShiftPriority.low;
    }
    
    if (isActive && !isConfirmed) {
      return ScheduledShiftPriority.urgent;
    }
    
    if (needsConfirmation && isUpcoming) {
      final hoursUntilStart = timeUntilStart?.inHours ?? 0;
      if (hoursUntilStart <= 4) {
        return ScheduledShiftPriority.urgent;
      } else if (hoursUntilStart <= 24) {
        return ScheduledShiftPriority.high;
      }
    }
    
    if (isActive) {
      return ScheduledShiftPriority.high;
    }
    
    return ScheduledShiftPriority.medium;
  }

  // ═══════════════════════════════════════════════════════════════
  // Display & Formatting Methods
  // ═══════════════════════════════════════════════════════════════

  /// Get formatted time range for display
  String getFormattedTimeRange({bool includeDate = false}) {
    final start = startTime;
    final end = endTime;
    
    if (includeDate) {
      final startStr = '${start.month}/${start.day} ${_formatTime(start)}';
      final endStr = start.day == end.day 
          ? _formatTime(end)
          : '${end.month}/${end.day} ${_formatTime(end)}';
      return '$startStr - $endStr';
    } else {
      return '${_formatTime(start)} - ${_formatTime(end)}';
    }
  }

  /// Get shift summary for notifications
  String get notificationSummary {
    final timeRange = getFormattedTimeRange();
    final location = displayLocation;
    return '$timeRange at $location';
  }

  /// Get detailed shift description
  String get detailedDescription {
    final parts = <String>[];
    
    parts.add(getFormattedTimeRange(includeDate: true));
    parts.add('at $displayLocation');
    
    if (hasPatientAssignments) {
      parts.add(patientAssignmentSummary);
    }
    
    if (!isConfirmed) {
      parts.add('(Needs confirmation)');
    }
    
    return parts.join(' ');
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

/// Priority levels for scheduled shift display and sorting
enum ScheduledShiftPriority {
  urgent,
  high, 
  medium,
  low,
}

/// Extension for ScheduledShiftPriority enum
extension ScheduledShiftPriorityExtension on ScheduledShiftPriority {
  String get displayName {
    switch (this) {
      case ScheduledShiftPriority.urgent:
        return 'Urgent';
      case ScheduledShiftPriority.high:
        return 'High';
      case ScheduledShiftPriority.medium:
        return 'Medium';
      case ScheduledShiftPriority.low:
        return 'Low';
    }
  }

  int get sortOrder {
    switch (this) {
      case ScheduledShiftPriority.urgent:
        return 4;
      case ScheduledShiftPriority.high:
        return 3;
      case ScheduledShiftPriority.medium:
        return 2;
      case ScheduledShiftPriority.low:
        return 1;
    }
  }
}