// 📁 lib/features/schedule/shift_pool/models/shift_model_extensions.dart
// UPDATED: Add smart patient description support

import 'package:nurseos_v3/features/schedule/shift_pool/models/shift_model.dart';
import 'package:nurseos_v3/features/schedule/shift_pool/services/patient_analysis_service.dart';

/// Enhanced extension methods for ShiftModel
///
/// ✅ UPDATED: Now includes smart patient description generation
/// ✅ Uses existing fields to determine shift categories and display information
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
    if (isEmergencyShift) {
      return '+\$${bonus.toStringAsFixed(0)} emergency bonus';
    }
    return '+\$${bonus.toStringAsFixed(0)} bonus';
  }

  String? get compensationDisplay {
    if (hourlyRate == null) return null;
    final baseRate = hourlyRate!;
    final total = totalHourlyRate;

    if (hasFinancialIncentives) {
      return '\$${total.toStringAsFixed(0)}/hr';
    }
    return '\$${baseRate.toStringAsFixed(0)}/hr';
  }

  bool get hasCertificationRequirements => requiredCertifications.isNotEmpty;

  String? get certificationsDisplay {
    if (!hasCertificationRequirements) return null;
    return 'Requires: ${requiredCertifications.join(', ')}';
  }

  // ═══════════════════════════════════════════════════════════════════
  // ENHANCED PATIENT LOAD DESCRIPTIONS
  // ═══════════════════════════════════════════════════════════════════

  bool get hasAssignedPatients => assignedPatientIds.isNotEmpty;

  /// Generate basic patient load description (fallback)
  String generatePatientLoadDescription() {
    if (assignedPatientIds.isEmpty) {
      return 'No patients assigned';
    }

    final patientCount = assignedPatientIds.length;
    final patientText = patientCount == 1 ? 'patient' : 'patients';
    return '$patientCount $patientText assigned';
  }

  /// Generate smart patient load description using analysis service
  /// Falls back to basic description if service unavailable
  Future<String> generateSmartPatientDescription(
      PatientAnalysisService? analysisService) async {
    if (analysisService == null || assignedPatientIds.isEmpty) {
      return generatePatientLoadDescription();
    }

    try {
      return await analysisService
          .generatePatientLoadDescription(assignedPatientIds);
    } catch (e) {
      // Fallback to basic description on error
      return generatePatientLoadDescription();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // FACILITY & LOCATION DISPLAY
  // ═══════════════════════════════════════════════════════════════════

  String get facilityDisplayName {
    if (facilityName?.isNotEmpty == true) {
      return facilityName!;
    }
    return location;
  }

  String? get departmentDisplay {
    if (department == null) return null;
    if (unit == null) return department;
    return '$department • $unit';
  }

  // ═══════════════════════════════════════════════════════════════════
  // TIME UTILITIES
  // ═══════════════════════════════════════════════════════════════════

  bool get isStartingSoon {
    final hoursUntilStart = startTime.difference(DateTime.now()).inHours;
    return hoursUntilStart >= 0 && hoursUntilStart <= 4;
  }

  String get timeUntilStart {
    final difference = startTime.difference(DateTime.now());

    if (difference.isNegative) return 'Started';

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return 'Starts in ${hours}h ${minutes}m';
    } else {
      return 'Starts in ${minutes}m';
    }
  }
}
