// 📁 lib/features/auth/models/user_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';
import 'package:nurseos_v3/features/agency/models/agency_role_model.dart';

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
    // Work Status Fields
    // ═══════════════════════════════════════════════════════════════

    /// Current duty status (true = on duty, false = off duty, null = unknown)
    bool? isOnDuty,

    /// Timestamp of last duty status change (for audit and compliance)
    @TimestampConverter() DateTime? lastStatusChange,

    /// Reference to current active work session (if on duty)
    /// Points to: /users/{uid}/workHistory/{sessionId}
    String? currentSessionId,

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

    // ═══════════════════════════════════════════════════════════════
    // Multi-Agency Support Fields
    // ═══════════════════════════════════════════════════════════════

    /// Currently active agency - determines data context for all operations
    /// This field controls which agency's patients, schedules, etc. the user sees
    required String activeAgencyId,

    /// Map of agency ID to role assignments
    /// Allows nurses to work across multiple hospitals/agencies with different roles
    /// Example: {"hospital_123": AgencyRoleModel(role: "nurse", department: "ICU")}
    @Default({}) Map<String, AgencyRoleModel> agencyRoles,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
