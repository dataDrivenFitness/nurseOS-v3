import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/core/models/user_role.dart';

extension UserModelExtensions on UserModel {
  /// Full display name with credentials
  String get displayName {
    final credentials = _buildCredentials();
    final suffix = credentials.isNotEmpty ? ', ${credentials.join(', ')}' : '';
    return '$firstName $lastName$suffix';
  }

  /// Short display name
  String get shortName => '$firstName $lastName';

  /// Fallback initials
  String get initials {
    if (firstName.isEmpty || lastName.isEmpty) return '?';
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }

  /// Years of experience
  int? get yearsOfExperience {
    if (hireDate == null) return null;
    return DateTime.now().difference(hireDate!).inDays ~/ 365;
  }

  /// Months of experience
  int? get monthsOfExperience {
    if (hireDate == null) return null;
    return DateTime.now().difference(hireDate!).inDays ~/ 30;
  }

  /// License audit logic
  LicenseStatus get licenseStatus {
    if (licenseNumber == null || licenseExpiry == null) {
      return LicenseStatus.unknown;
    }

    final daysUntilExpiry = licenseExpiry!.difference(DateTime.now()).inDays;
    if (daysUntilExpiry < 0) return LicenseStatus.expired;
    if (daysUntilExpiry < 30) return LicenseStatus.expiringSoon;
    if (daysUntilExpiry < 90) return LicenseStatus.expiringWarning;
    return LicenseStatus.valid;
  }

  /// Badge for professional context
  String get professionalContext {
    final parts = <String>[];
    if (department != null) parts.add(department!);
    if (shift != null) parts.add('${shift!} Shift');
    if (phoneExtension != null) parts.add('Ext. $phoneExtension');
    return parts.join(' • ');
  }

  /// Check if a nurse has a certification
  bool hasCertification(String certification) =>
      certifications?.contains(certification) ?? false;

  List<String> get majorCertifications {
    const majorCerts = ['ACLS', 'PALS', 'CCRN', 'CEN', 'TCRN'];
    return certifications?.where(majorCerts.contains).toList() ?? [];
  }

  List<String> _buildCredentials() {
    final creds = <String>[];
    if (role == UserRole.nurse) creds.add('RN');
    creds.addAll(majorCertifications);
    return creds;
  }

  bool get isProfileComplete =>
      licenseNumber != null &&
      licenseExpiry != null &&
      department != null &&
      shift != null;

  String get dutyStatusText => isOnDuty == null
      ? 'Status unknown'
      : isOnDuty!
          ? 'On Duty'
          : 'Off Duty';

  DutyStatusColor get dutyStatusColor {
    if (isOnDuty == null) return DutyStatusColor.unknown;
    return isOnDuty! ? DutyStatusColor.onDuty : DutyStatusColor.offDuty;
  }

  bool get hasActiveSession =>
      isOnDuty == true && currentSessionId?.isNotEmpty == true;

  Duration? get timeSinceStatusChange => lastStatusChange == null
      ? null
      : DateTime.now().difference(lastStatusChange!);

  String? get statusChangeDuration {
    final duration = timeSinceStatusChange;
    if (duration == null) return null;
    if (duration.inDays > 0) return '${duration.inDays} day(s) ago';
    if (duration.inHours > 0) return '${duration.inHours} hour(s) ago';
    if (duration.inMinutes > 0) return '${duration.inMinutes} minute(s) ago';
    return 'Just now';
  }

  // ═══════════════════════════════════════════════════════════════════
  // 🏠 Independent Nurse Extension Methods
  // ═══════════════════════════════════════════════════════════════════

  /// Check if nurse can create their own shifts
  bool get canCreateShifts => isIndependentNurse;

  /// Check if nurse can manage their own patients
  bool get canManageOwnPatients => isIndependentNurse;

  /// Get display name for business context
  String get businessDisplayName {
    if (!isIndependentNurse || businessName == null) {
      return displayName; // Fallback to regular display name
    }
    return businessName!;
  }

  /// Check if profile is complete for independent nursing
  bool get isIndependentProfileComplete {
    if (!isIndependentNurse) return true; // Not applicable

    return licenseNumber != null &&
        licenseExpiry != null &&
        businessName != null;
  }

  /// Get working mode display text
  String get workingModeDisplay {
    if (isIndependentNurse) return 'Independent';
    return 'Agency Only';
  }
}

enum LicenseStatus {
  valid,
  expiringWarning,
  expiringSoon,
  expired,
  unknown,
}

enum DutyStatusColor {
  onDuty,
  offDuty,
  unknown,
}

/// UI formatter for experience
String formatExperience(UserModel user) {
  final y = user.yearsOfExperience;
  final m = user.monthsOfExperience;
  if (y == null) return 'Experience not specified';
  if (y > 0) return '$y year${y != 1 ? 's' : ''} experience';
  if (m != null && m > 0) return '$m month${m != 1 ? 's' : ''} experience';
  return 'New nurse';
}

/// UI formatter for license display
String formatLicenseDisplay(UserModel user) {
  if (user.licenseNumber == null) return 'License not provided';
  var display = user.licenseNumber!;
  if (user.licenseExpiry != null) {
    final exp = user.licenseExpiry!;
    display += ' (Exp. ${exp.month.toString().padLeft(2, '0')}/${exp.year})';
  }
  return display;
}
