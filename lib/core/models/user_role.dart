// 📁 lib/core/models/user_role.dart

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

/// 👩‍⚕️ User roles in NurseOS v2 - aligned with healthcare hierarchy
///
/// These roles provide proper access control and workflow management
/// while maintaining simplicity for the core nursing workflow.
enum UserRole {
  /// 🏥 System administrator - full system access
  admin,

  /// 👩‍⚕️ Staff nurse - core clinical functionality
  nurse,

  /// 👑 Charge nurse - unit leadership, scheduling, staff oversight
  chargeNurse,

  /// 👩‍💼 Nurse manager - departmental management, performance reviews
  manager,

  /// 📋 Clinical coordinator - protocols, quality assurance, education
  clinicalCoordinator,
}

/// 🔄 Converter for UserRole enum to/from Firestore
class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'nurse':
        return UserRole.nurse;
      case 'charge_nurse':
      case 'chargenurse':
        return UserRole.chargeNurse;
      case 'manager':
        return UserRole.manager;
      case 'clinical_coordinator':
      case 'clinicalcoordinator':
        return UserRole.clinicalCoordinator;
      default:
        debugPrint('❌ Invalid user role from Firestore: $json');
        // Default to nurse for safety - most restrictive clinical role
        return UserRole.nurse;
    }
  }

  @override
  String toJson(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'admin';
      case UserRole.nurse:
        return 'nurse';
      case UserRole.chargeNurse:
        return 'charge_nurse';
      case UserRole.manager:
        return 'manager';
      case UserRole.clinicalCoordinator:
        return 'clinical_coordinator';
    }
  }
}

/// 🎯 Extension methods for role-based functionality
extension UserRoleExtensions on UserRole {
  /// Display name for UI
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.nurse:
        return 'Nurse';
      case UserRole.chargeNurse:
        return 'Charge Nurse';
      case UserRole.manager:
        return 'Nurse Manager';
      case UserRole.clinicalCoordinator:
        return 'Clinical Coordinator';
    }
  }

  /// Short abbreviation for badges/compact display
  String get abbreviation {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.nurse:
        return 'RN';
      case UserRole.chargeNurse:
        return 'CN';
      case UserRole.manager:
        return 'MGR';
      case UserRole.clinicalCoordinator:
        return 'CC';
    }
  }

  /// Role hierarchy level (higher = more authority)
  int get hierarchyLevel {
    switch (this) {
      case UserRole.admin:
        return 100; // System level
      case UserRole.manager:
        return 50; // Department level
      case UserRole.clinicalCoordinator:
        return 40; // Protocol/QA level
      case UserRole.chargeNurse:
        return 30; // Unit level
      case UserRole.nurse:
        return 10; // Staff level
    }
  }

  /// Can this role manage other users?
  bool get canManageUsers {
    return hierarchyLevel >= 30; // Charge nurse and above
  }

  /// Can this role access admin features?
  bool get canAccessAdminFeatures {
    return hierarchyLevel >= 50; // Manager and above
  }

  /// Can this role approve schedules?
  bool get canApproveSchedules {
    return hierarchyLevel >= 30; // Charge nurse and above
  }

  /// Can this role view department analytics?
  bool get canViewAnalytics {
    return hierarchyLevel >= 40; // Clinical coordinator and above
  }

  /// Can this role manage protocols and care plans?
  bool get canManageProtocols {
    return hierarchyLevel >= 40; // Clinical coordinator and above
  }

  /// Can this role override clinical decisions?
  bool get canOverrideClinical {
    return hierarchyLevel >= 30; // Charge nurse and above
  }

  /// Primary color for role identification (returns hex string)
  String get primaryColorHex {
    switch (this) {
      case UserRole.admin:
        return '#E53E3E'; // Red for system admin
      case UserRole.manager:
        return '#805AD5'; // Purple for management
      case UserRole.clinicalCoordinator:
        return '#3182CE'; // Blue for clinical leadership
      case UserRole.chargeNurse:
        return '#38A169'; // Green for unit leadership
      case UserRole.nurse:
        return '#2D3748'; // Dark gray for staff
    }
  }

  /// Get all roles this role can manage (based on hierarchy)
  List<UserRole> get canManage {
    final manageable = <UserRole>[];
    final currentLevel = hierarchyLevel;

    for (final role in UserRole.values) {
      if (role.hierarchyLevel < currentLevel) {
        manageable.add(role);
      }
    }

    return manageable;
  }

  /// Check if this role can manage another specific role
  bool canManageRole(UserRole other) {
    return hierarchyLevel > other.hierarchyLevel;
  }
}

/// 🎯 Helper functions for role management
class RolePermissions {
  /// Get minimum role required for a specific permission
  static UserRole getMinimumRoleFor({
    required String permission,
  }) {
    switch (permission.toLowerCase()) {
      case 'manage_users':
      case 'approve_schedules':
      case 'override_clinical':
        return UserRole.chargeNurse;

      case 'manage_protocols':
      case 'view_analytics':
        return UserRole.clinicalCoordinator;

      case 'admin_features':
      case 'system_config':
        return UserRole.manager;

      case 'full_system_access':
        return UserRole.admin;

      default:
        return UserRole.nurse; // Default to most restrictive
    }
  }

  /// Check if a role has a specific permission
  static bool hasPermission(UserRole role, String permission) {
    final requiredRole = getMinimumRoleFor(permission: permission);
    return role.hierarchyLevel >= requiredRole.hierarchyLevel;
  }

  /// Get all permissions for a role
  static List<String> getPermissionsFor(UserRole role) {
    final permissions = <String>[];

    // Base permissions for all roles
    permissions.addAll(['view_patients', 'create_notes', 'record_vitals']);

    if (role.canManageUsers) {
      permissions
          .addAll(['manage_users', 'approve_schedules', 'override_clinical']);
    }

    if (role.canManageProtocols) {
      permissions.addAll(['manage_protocols', 'view_analytics']);
    }

    if (role.canAccessAdminFeatures) {
      permissions.addAll(['admin_features', 'system_config']);
    }

    if (role == UserRole.admin) {
      permissions.add('full_system_access');
    }

    return permissions;
  }
}
