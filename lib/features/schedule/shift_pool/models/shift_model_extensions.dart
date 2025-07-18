import 'shift_model.dart';

/// Enhanced extension methods for ShiftModel
///
/// ✅ FIXED: Now works with actual ShiftModel properties
/// Uses existing fields to determine shift categories and display information
extension ShiftModelEnhancements on ShiftModel {
  // ═══════════════════════════════════════════════════════════════════
  // URGENCY CATEGORIZATION - For 3-Section UI Layout
  // ═══════════════════════════════════════════════════════════════════

  bool get isEmergencyShift {
    if (urgencyLevel == 'emergency') return true;
    if (specialRequirements?.toLowerCase().contains('emergency') == true)
      return true;
    if (specialRequirements?.toLowerCase().contains('urgent') == true)
      return true;
    if (specialRequirements?.toLowerCase().contains('asap') == true)
      return true;
    final hoursUntilStart = startTime.difference(DateTime.now()).inHours;
    return hoursUntilStart <= 2 && hoursUntilStart >= 0;
  }

  bool get isCoverageRequest {
    if (urgencyLevel == 'coverage') return true;
    if (requestingNurseId?.isNotEmpty == true) return true;
    if (requestingNurseNote?.isNotEmpty == true) return true;
    if (specialRequirements?.toLowerCase().contains('coverage') == true)
      return true;
    if (specialRequirements?.toLowerCase().contains('help') == true)
      return true;
    if (specialRequirements?.toLowerCase().contains('colleague') == true)
      return true;
    return false;
  }

  bool get isRegularShift => !isEmergencyShift && !isCoverageRequest;

  String get urgencyText {
    if (isEmergencyShift) return 'Emergency Coverage';
    if (isCoverageRequest) return 'Coverage Request';
    return 'Open Shift';
  }

  int get urgencyPriority {
    if (isEmergencyShift) return 1;
    if (isCoverageRequest) return 2;
    return 3;
  }

  // ═══════════════════════════════════════════════════════════════════
  // COLLEAGUE EMPATHY FEATURES - For Coverage Requests
  // ═══════════════════════════════════════════════════════════════════

  String getCoverageButtonText([String? nurseName]) {
    if (!isCoverageRequest) return 'Request Shift';
    if (nurseName?.isNotEmpty == true) return 'Help $nurseName';
    return 'Help Colleague';
  }

  String? get coverageContextMessage {
    if (!isCoverageRequest) return null;
    return requestingNurseNote?.isNotEmpty == true
        ? requestingNurseNote
        : 'A colleague needs coverage for this shift';
  }

  bool get hasPersonalMessage => requestingNurseNote?.isNotEmpty == true;

  // ═══════════════════════════════════════════════════════════════════
  // FINANCIAL TRANSPARENCY - Enhanced Compensation Display
  // ═══════════════════════════════════════════════════════════════════

  double get totalHourlyRate => (hourlyRate ?? 0) + (urgencyBonus ?? 0);

  bool get hasFinancialIncentives => urgencyBonus != null && urgencyBonus! > 0;

  String? get incentiveText {
    if (!hasFinancialIncentives) return null;
    final bonus = urgencyBonus!;
    final label = isEmergencyShift
        ? 'emergency bonus'
        : isCoverageRequest
            ? 'coverage bonus'
            : 'bonus';
    return '+\$${bonus.toStringAsFixed(2)}/hr $label';
  }

  String? get compensationDisplay {
    if (hourlyRate == null) return null;
    return '\$${totalHourlyRate.toStringAsFixed(2)}/hr';
  }

  // ═══════════════════════════════════════════════════════════════════
  // ENHANCED LOCATION DISPLAY - Department + Unit Formatting
  // ═══════════════════════════════════════════════════════════════════

  String? get departmentDisplay {
    if (department == null) return null;
    return unit == null ? department : '$department • $unit';
  }

  String get facilityDisplayName {
    if (facilityName?.isNotEmpty == true) {
      return departmentDisplay != null
          ? '$facilityName - $departmentDisplay'
          : facilityName!;
    }
    return location;
  }

  bool get isFacilityShift =>
      facilityName?.isNotEmpty == true || department != null;
  bool get isHomeCareShift => location == 'residence';

  // ═══════════════════════════════════════════════════════════════════
  // ENHANCED PATIENT LOAD DESCRIPTIONS
  // ═══════════════════════════════════════════════════════════════════

  String generatePatientLoadDescription() {
    if (assignedPatientIds == null || assignedPatientIds!.isEmpty) {
      return 'No patients assigned';
    }
    final count = assignedPatientIds!.length;
    return '$count patient${count != 1 ? 's' : ''} assigned';
  }

  int get patientCount => assignedPatientIds?.length ?? 0;
  bool get hasAssignedPatients => patientCount > 0;

  // ═══════════════════════════════════════════════════════════════════
  // CERTIFICATION & REQUIREMENTS DISPLAY
  // ═══════════════════════════════════════════════════════════════════

  bool get hasCertificationRequirements => requiredCertifications.isNotEmpty;

  String? get certificationsDisplay {
    if (!hasCertificationRequirements) return null;
    final certs = requiredCertifications;
    if (certs.length == 1) return '${certs.first} required';
    if (certs.length <= 3) return '${certs.join(', ')} required';
    return '${certs.take(2).join(', ')} +${certs.length - 2} more required';
  }

  // ═══════════════════════════════════════════════════════════════════
  // SHIFT TIMING & SCHEDULE HELPERS
  // ═══════════════════════════════════════════════════════════════════

  bool get isStartingSoon {
    final hoursUntilStart = startTime.difference(DateTime.now()).inHours;
    return hoursUntilStart <= 4 && hoursUntilStart >= 0;
  }

  bool get isUrgent => isEmergencyShift || isStartingSoon;

  String get timeUntilStart {
    final diff = startTime.difference(DateTime.now());
    return diff.isNegative
        ? 'Started ${_formatDuration(diff.abs())} ago'
        : _futureStartTimeText(diff);
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays} day${d.inDays != 1 ? 's' : ''}';
    if (d.inHours > 0) return '${d.inHours} hour${d.inHours != 1 ? 's' : ''}';
    return '${d.inMinutes} minute${d.inMinutes != 1 ? 's' : ''}';
  }

  String _futureStartTimeText(Duration d) {
    if (d.inDays > 0)
      return 'Starts in ${d.inDays} day${d.inDays != 1 ? 's' : ''}';
    if (d.inHours > 0)
      return 'Starts in ${d.inHours} hour${d.inHours != 1 ? 's' : ''}';
    return 'Starts in ${d.inMinutes} minute${d.inMinutes != 1 ? 's' : ''}';
  }
}
