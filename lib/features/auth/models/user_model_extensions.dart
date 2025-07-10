import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/features/agency/models/agency_role_model.dart';

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
  // 🏥 Multi-Agency Extension Methods
  // ═══════════════════════════════════════════════════════════════════

  /// Check if user has access to a specific agency
  bool hasAccessToAgency(String agencyId) {
    return agencyRoles.containsKey(agencyId);
  }

  /// Get the user's role at a specific agency
  AgencyRoleModel? getRoleAtAgency(String agencyId) {
    return agencyRoles[agencyId];
  }

  /// Get the user's role at the currently active agency
  AgencyRoleModel? get currentAgencyRole {
    return agencyRoles[activeAgencyId];
  }

  /// Get all agencies where user has access
  List<String> get accessibleAgencies {
    return agencyRoles.keys.toList();
  }

  /// Check if user can switch to a specific agency
  bool canSwitchToAgency(String agencyId) {
    return hasAccessToAgency(agencyId) && agencyId != activeAgencyId;
  }

  /// Get user's display name with current agency context
  String get displayNameWithContext {
    final agencyRole = currentAgencyRole;
    if (agencyRole?.department != null) {
      return '$firstName $lastName - ${agencyRole!.department}';
    }
    return displayName;
  }

  /// Check if user is admin at any agency
  bool get isAdminAtAnyAgency {
    return agencyRoles.values.any((role) => role.role == UserRole.admin);
  }

  /// Check if user is admin at the current agency
  bool get isAdminAtCurrentAgency {
    return currentAgencyRole?.role == UserRole.admin;
  }

  /// Get all departments user works in across agencies
  List<String> get allDepartments {
    return agencyRoles.values
        .where((role) => role.department != null)
        .map((role) => role.department!)
        .toSet()
        .toList();
  }

  /// Get agency-specific professional context
  String get agencyProfessionalContext {
    final agencyRole = currentAgencyRole;
    final parts = <String>[];

    // Use agency-specific department if available, fallback to user department
    final dept = agencyRole?.department ?? department;
    if (dept != null) parts.add(dept);

    // Use user's default shift (AgencyRoleModel doesn't have shift field)
    if (shift != null) parts.add('$shift Shift');

    if (phoneExtension != null) parts.add('Ext. $phoneExtension');

    return parts.join(' • ');
  }

  /// Check if user has multiple agency access
  bool get hasMultipleAgencies => agencyRoles.length > 1;

  /// Get count of agencies user has access to
  int get agencyCount => agencyRoles.length;

  /// Check if user needs to select an agency (has access but none active)
  bool get needsAgencySelection {
    return agencyRoles.isNotEmpty && !hasAccessToAgency(activeAgencyId);
  }

  /// Get agency role display text for current agency
  String get currentAgencyRoleDisplay {
    final role = currentAgencyRole;
    if (role == null) return 'No role assigned';

    final roleName = role.role.name.substring(0, 1).toUpperCase() +
        role.role.name.substring(1);

    if (role.department != null) {
      return '$roleName - ${role.department}';
    }

    return roleName;
  }

  /// Check if profile is complete for current agency
  bool get isAgencyProfileComplete {
    final agencyRole = currentAgencyRole;
    return licenseNumber != null &&
        licenseExpiry != null &&
        (agencyRole?.department != null || department != null) &&
        shift !=
            null; // Use user's shift since AgencyRoleModel doesn't have shift
  }

  /// Get effective department (agency-specific or user default)
  String? get effectiveDepartment {
    return currentAgencyRole?.department ?? department;
  }

  /// Get effective shift (user default since AgencyRoleModel doesn't have shift)
  String? get effectiveShift {
    return shift; // Only user has shift field
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
