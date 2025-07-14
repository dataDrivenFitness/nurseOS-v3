// 📁 lib/features/schedule/models/scheduled_shift_model_extensions.dart

import 'package:nurseos_v3/features/schedule/models/scheduled_shift_model.dart';

extension ScheduledShiftModelExtensions on ScheduledShiftModel {
  // ═══════════════════════════════════════════════════════════════════
  // 🏠 Independent Nurse Extension Methods
  // ═══════════════════════════════════════════════════════════════════

  /// Check if this is an independently created shift (no agency)
  /// Independent shifts: agencyId == null && isUserCreated == true
  bool get isIndependentShift => isUserCreated && agencyId == null;

  /// Check if this is an agency-created shift
  /// Agency shifts: agencyId != null && isUserCreated == false
  bool get isAgencyShift => !isUserCreated && agencyId != null;

  /// Check if this is a user-created shift within an agency context
  /// Dual-mode: agencyId != null && isUserCreated == true
  /// (Independent nurse working for an agency but creating own schedule)
  bool get isDualModeShift => isUserCreated && agencyId != null;

  /// Get comprehensive shift ownership type for display
  String get ownershipType {
    if (isIndependentShift) return 'Independent';
    if (isAgencyShift) return 'Agency';
    if (isDualModeShift) return 'Self-Scheduled';
    return 'Unknown';
  }

  /// Get detailed shift source information
  String get shiftSource {
    if (isIndependentShift) return 'Independent Practice';
    if (isAgencyShift) return 'Agency-Created';
    if (isDualModeShift) return 'Self-Created (Agency)';
    return 'System-Created';
  }

  /// Check if shift is editable by the assigned nurse
  /// Rules:
  /// - Independent shifts: Always editable by creator
  /// - Agency shifts: Typically not editable by nurses
  /// - Dual-mode shifts: Editable by nurse (they created it)
  bool get isEditableByNurse => isUserCreated;

  /// Check if shift can be cancelled by the nurse
  /// Rules:
  /// - Independent/dual-mode: Can cancel own shifts
  /// - Agency shifts: Require admin approval to cancel
  bool get isCancellableByNurse => isUserCreated;

  /// Get agency context display for multi-agency nurses
  String get agencyContext {
    if (agencyId == null) return 'Independent Practice';
    // TODO: Replace with actual agency name lookup
    return 'Agency: ${agencyId!}';
  }

  /// Check if shift has assigned patients
  bool get hasPatients => assignedPatientIds?.isNotEmpty == true;

  /// Get patient count
  int get patientCount => assignedPatientIds?.length ?? 0;

  /// Check if shift is in the past
  bool get isPastShift => endTime.isBefore(DateTime.now());

  /// Check if shift is currently active
  bool get isActiveShift {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Check if shift is upcoming
  bool get isUpcomingShift => startTime.isAfter(DateTime.now());

  /// Get shift duration in hours
  double get durationInHours {
    return endTime.difference(startTime).inMinutes / 60.0;
  }

  /// Get formatted duration (e.g., "8.0 hrs")
  String get formattedDuration {
    final hours = durationInHours;
    return '${hours.toStringAsFixed(1)} hrs';
  }

  /// Check if shift requires confirmation
  bool get needsConfirmation => !isConfirmed && isUpcomingShift;

  /// Get status display text with context
  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return needsConfirmation ? 'Pending Confirmation' : 'Scheduled';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'in_progress':
        return 'In Progress';
      default:
        return status;
    }
  }

  /// Check if shift supports patient management
  /// Independent shifts allow full patient management
  /// Agency shifts may have restrictions
  bool get allowsPatientManagement => isUserCreated;

  /// Get location display text
  String get locationDisplay {
    if (facilityName != null) return facilityName!;
    if (address != null) return address!;
    return 'Location not specified';
  }

  /// Check if shift location is a facility vs home care
  bool get isFacilityShift => locationType.toLowerCase() == 'facility';

  /// Check if shift location is home care
  bool get isHomeCareShift =>
      locationType.toLowerCase() == 'residence' ||
      locationType.toLowerCase() == 'home';

  /// Get time until shift starts (null if already started/past)
  Duration? get timeUntilStart {
    if (!isUpcomingShift) return null;
    return startTime.difference(DateTime.now());
  }

  /// Get time since shift ended (null if not ended yet)
  Duration? get timeSinceEnd {
    if (!isPastShift) return null;
    return DateTime.now().difference(endTime);
  }

  /// Format time until start for display
  String? get timeUntilStartDisplay {
    final duration = timeUntilStart;
    if (duration == null) return null;

    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays != 1 ? 's' : ''}';
    }
    if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours != 1 ? 's' : ''}';
    }
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes != 1 ? 's' : ''}';
    }
    return 'Starting soon';
  }

  /// Check if this shift was created recently (within last 24 hours)
  bool get isRecentlyCreated {
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt!).inHours < 24;
  }

  /// Check if shift supports modification
  /// Shifts can typically be modified if they're upcoming and user-created
  bool get supportsModification {
    return isUserCreated && isUpcomingShift && !isConfirmed;
  }
}
