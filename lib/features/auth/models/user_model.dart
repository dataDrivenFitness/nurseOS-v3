// 📁 lib/features/auth/models/user_model.dart (UPDATED FOR WORK HISTORY)

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    // ═══════════════════════════════════════════════════════════════
    // Core Identity Fields
    // ═══════════════════════════════════════════════════════════════
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    String? photoUrl,
    @TimestampConverter() DateTime? createdAt,
    String? authProvider,
    @UserRoleConverter() required UserRole role,

    // ═══════════════════════════════════════════════════════════════
    // Healthcare Professional Fields
    // ═══════════════════════════════════════════════════════════════

    /// Professional license number (e.g., "RN123456")
    String? licenseNumber,

    /// License expiration date (important for compliance tracking)
    @TimestampConverter() DateTime? licenseExpiry,

    /// Clinical specialty (e.g., "Critical Care", "Med-Surg", "Emergency")
    String? specialty,

    /// Department or unit assignment (e.g., "ICU", "Med-Surg Floor 3")
    String? department,

    /// Legacy unit field - kept for backward compatibility
    /// TODO: Migrate existing data to department field
    String? unit,

    /// Work shift schedule (e.g., "day", "night", "evening", "rotating")
    String? shift,

    /// Internal hospital phone extension
    String? phoneExtension,

    /// Date of hire (used to calculate years of experience)
    @TimestampConverter() DateTime? hireDate,

    /// Professional certifications (e.g., ["BLS", "ACLS", "PALS", "CCRN"])
    List<String>? certifications,

    // ═══════════════════════════════════════════════════════════════
    // Work Status Fields (Updated for Work History)
    // ═══════════════════════════════════════════════════════════════

    /// Current duty status (true = on duty, false = off duty, null = unknown)
    bool? isOnDuty,

    /// Timestamp of last duty status change (for audit and compliance)
    @TimestampConverter() DateTime? lastStatusChange,

    /// Reference to current active work session (if on duty)
    /// Points to: /users/{uid}/workHistory/{sessionId}
    String? currentSessionId,

    // ═══════════════════════════════════════════════════════════════
    // REMOVED: Legacy Location Fields
    // These are now stored in WorkSession documents for proper history
    // ═══════════════════════════════════════════════════════════════
    // REMOVED: Map<String, dynamic>? onDutyLocation,
    // REMOVED: String? onDutyAddress,
    // REMOVED: String? onDutyFacility,

    // ═══════════════════════════════════════════════════════════════
    // Gamification Fields (DEPRECATED - will be moved to GamificationProfile)
    // ═══════════════════════════════════════════════════════════════

    /// @deprecated Use GamificationProfile.level instead
    /// Keeping for backward compatibility during migration
    @Default(1) int level,

    /// @deprecated Use GamificationProfile.totalXp instead
    /// Keeping for backward compatibility during migration
    @Default(0) int xp,

    /// @deprecated Use GamificationProfile.badges instead
    /// Keeping for backward compatibility during migration
    @Default([]) List<String> badges,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

// ═══════════════════════════════════════════════════════════════════
// Extension Methods for Computed Properties
// ═══════════════════════════════════════════════════════════════════

extension UserModelExtensions on UserModel {
  /// Full display name with credentials
  String get displayName {
    final credentials = _buildCredentials();
    final suffix = credentials.isNotEmpty ? ', ${credentials.join(', ')}' : '';
    return '$firstName $lastName$suffix';
  }

  /// Short display name without credentials
  String get shortName => '$firstName $lastName';

  /// Initials for avatar fallback
  String get initials {
    if (firstName.isEmpty || lastName.isEmpty) return '?';
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }

  /// Years of experience (calculated from hire date)
  int? get yearsOfExperience {
    if (hireDate == null) return null;
    final diff = DateTime.now().difference(hireDate!);
    return (diff.inDays / 365).floor();
  }

  /// Months of experience (for nurses with < 1 year)
  int? get monthsOfExperience {
    if (hireDate == null) return null;
    final diff = DateTime.now().difference(hireDate!);
    return (diff.inDays / 30).floor();
  }

  /// License status for UI display
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

  /// Professional context for display (Department • Shift • Extension)
  String get professionalContext {
    final parts = <String>[];

    if (department != null) parts.add(department!);
    if (shift != null) parts.add('${shift!} Shift');
    if (phoneExtension != null) parts.add('Ext. $phoneExtension');

    return parts.join(' • ');
  }

  /// Check if user has a specific certification
  bool hasCertification(String certification) {
    return certifications?.contains(certification) ?? false;
  }

  /// Get major certifications for credentials display
  List<String> get majorCertifications {
    if (certifications == null) return [];

    const majorCerts = ['ACLS', 'PALS', 'CCRN', 'CEN', 'TCRN'];
    return certifications!.where((cert) => majorCerts.contains(cert)).toList();
  }

  /// Build credentials list for display name
  List<String> _buildCredentials() {
    final creds = <String>[];

    // Add role-based credentials
    if (role == UserRole.nurse) {
      creds.add('RN');
    }

    // Add major certifications
    creds.addAll(majorCertifications);

    return creds;
  }

  /// Check if profile is complete for healthcare professional
  bool get isProfileComplete {
    return licenseNumber != null &&
        licenseExpiry != null &&
        department != null &&
        shift != null;
  }

  /// Get display text for duty status
  String get dutyStatusText {
    if (isOnDuty == null) return 'Status unknown';
    return isOnDuty! ? 'On Duty' : 'Off Duty';
  }

  /// Get color for duty status indicator
  /// Note: Colors should be handled in UI layer, but this provides semantic meaning
  DutyStatusColor get dutyStatusColor {
    if (isOnDuty == null) return DutyStatusColor.unknown;
    return isOnDuty! ? DutyStatusColor.onDuty : DutyStatusColor.offDuty;
  }

  // ═══════════════════════════════════════════════════════════════════
  // NEW: Work Session Extensions
  // ═══════════════════════════════════════════════════════════════════

  /// Check if user has an active work session
  bool get hasActiveSession => isOnDuty == true && currentSessionId != null;

  /// Time since last status change (for audit purposes)
  Duration? get timeSinceStatusChange {
    if (lastStatusChange == null) return null;
    return DateTime.now().difference(lastStatusChange!);
  }

  /// Get formatted time since status change
  String? get statusChangeDuration {
    final duration = timeSinceStatusChange;
    if (duration == null) return null;

    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays != 1 ? 's' : ''} ago';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours != 1 ? 's' : ''} ago';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes != 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// Supporting Enums
// ═══════════════════════════════════════════════════════════════════

enum LicenseStatus {
  valid,
  expiringWarning, // 30-90 days
  expiringSoon, // < 30 days
  expired,
  unknown,
}

enum DutyStatusColor {
  onDuty, // Green
  offDuty, // Gray
  unknown, // Gray
}

// ═══════════════════════════════════════════════════════════════════
// Helper Functions for UI
// ═══════════════════════════════════════════════════════════════════

/// Get user-friendly experience text
String formatExperience(UserModel user) {
  final years = user.yearsOfExperience;
  final months = user.monthsOfExperience;

  if (years == null) return 'Experience not specified';

  if (years > 0) {
    return '$years year${years != 1 ? 's' : ''} experience';
  } else if (months != null && months > 0) {
    return '$months month${months != 1 ? 's' : ''} experience';
  } else {
    return 'New nurse';
  }
}

/// Format license for display with expiration
String formatLicenseDisplay(UserModel user) {
  if (user.licenseNumber == null) return 'License not provided';

  String display = user.licenseNumber!;

  if (user.licenseExpiry != null) {
    final expiry = user.licenseExpiry!;
    final monthYear =
        '${expiry.month.toString().padLeft(2, '0')}/${expiry.year}';
    display += ' (Exp. $monthYear)';
  }

  return display;
}
