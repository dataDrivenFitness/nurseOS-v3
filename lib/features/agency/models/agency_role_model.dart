// 📁 lib/features/agency/models/agency_role_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'agency_role_model.freezed.dart';
part 'agency_role_model.g.dart';

/// Status of a user's role within an agency
enum AgencyRoleStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('pending')
  pending,
  @JsonValue('suspended')
  suspended,
}

@freezed
abstract class AgencyRoleModel with _$AgencyRoleModel {
  const factory AgencyRoleModel({
    String? agencyId, // Made optional to handle embedded storage in UserModel
    String? userId, // Made optional to handle embedded storage in UserModel
    @UserRoleConverter() required UserRole role,
    @Default(AgencyRoleStatus.active) AgencyRoleStatus status,
    String? department,
    String? unit, // More specific than department (e.g., "ICU-3")
    String? shift, // Default shift assignment
    String? assignedBy, // Who assigned this role
    @TimestampConverter() DateTime? assignedAt, // When role was assigned
    @TimestampConverter() DateTime? joinedAt, // When user actually started
    @TimestampConverter()
    DateTime? lastActiveAt, // Last activity in this agency
    @Default([]) List<String> permissions, // Specific permissions for this role
    @Default({}) Map<String, dynamic> metadata, // Additional role-specific data
  }) = _AgencyRoleModel;

  const AgencyRoleModel._();

  factory AgencyRoleModel.fromJson(Map<String, dynamic> json) =>
      _$AgencyRoleModelFromJson(json);

  /// Check if this role has administrative privileges
  bool get isAdmin {
    return role == UserRole.admin;
  }

  /// Check if this role has supervisory privileges (charge nurse and above)
  bool get isSupervisor {
    return role.hierarchyLevel >= UserRole.chargeNurse.hierarchyLevel;
  }

  /// Check if this role can manage other users
  bool get canManageUsers {
    return role.canManageUsers || permissions.contains('manage_users');
  }

  /// Check if this role can access admin dashboard
  bool get canAccessAdminDashboard {
    return role.canAccessAdminFeatures ||
        permissions.contains('admin_dashboard');
  }

  /// Check if this role can schedule shifts
  bool get canScheduleShifts {
    return role.canApproveSchedules || permissions.contains('schedule_shifts');
  }

  /// Check if this role can assign tasks
  bool get canAssignTasks {
    return isSupervisor || permissions.contains('assign_tasks');
  }

  /// Check if this role can view reports
  bool get canViewReports {
    return role.canViewAnalytics || permissions.contains('view_reports');
  }

  /// Check if this role is currently active
  bool get isActive {
    return status == AgencyRoleStatus.active;
  }

  /// Check if this role is pending approval
  bool get isPending {
    return status == AgencyRoleStatus.pending;
  }

  /// Get display name for the role
  String get roleDisplayName {
    return role.displayName;
  }

  /// Get status display name
  String get statusDisplayName {
    switch (status) {
      case AgencyRoleStatus.active:
        return 'Active';
      case AgencyRoleStatus.inactive:
        return 'Inactive';
      case AgencyRoleStatus.pending:
        return 'Pending';
      case AgencyRoleStatus.suspended:
        return 'Suspended';
    }
  }

  /// Get full role description with department
  String get fullDescription {
    final parts = <String>[roleDisplayName];

    if (department != null) {
      parts.add(department!);
    }

    if (unit != null && unit != department) {
      parts.add(unit!);
    }

    if (shift != null) {
      parts.add('${shift!} Shift');
    }

    return parts.join(' • ');
  }

  /// Create a role with default permissions based on UserRole
  AgencyRoleModel withDefaultPermissions() {
    final defaultPermissions = <String>[];

    switch (role) {
      case UserRole.admin:
        defaultPermissions.addAll([
          'manage_users',
          'admin_dashboard',
          'schedule_shifts',
          'assign_tasks',
          'view_reports',
          'manage_agency_settings',
          'audit_logs',
          'full_system_access',
        ]);
        break;
      case UserRole.manager:
        defaultPermissions.addAll([
          'admin_dashboard',
          'schedule_shifts',
          'assign_tasks',
          'view_reports',
          'manage_department_users',
          'admin_features',
        ]);
        break;
      case UserRole.clinicalCoordinator:
        defaultPermissions.addAll([
          'admin_dashboard',
          'assign_tasks',
          'view_reports',
          'manage_protocols',
          'view_analytics',
        ]);
        break;
      case UserRole.chargeNurse:
        defaultPermissions.addAll([
          'admin_dashboard',
          'schedule_shifts',
          'assign_tasks',
          'manage_unit_users',
          'approve_schedules',
          'override_clinical',
        ]);
        break;
      case UserRole.nurse:
        defaultPermissions.addAll([
          'view_assigned_patients',
          'update_patient_records',
          'clock_in_out',
          'record_vitals',
          'create_notes',
        ]);
        break;
    }

    // Merge with existing permissions, avoiding duplicates
    final allPermissions = {...permissions, ...defaultPermissions}.toList();

    return copyWith(permissions: allPermissions);
  }

  /// Check if role has specific permission
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  /// Add permission to role
  AgencyRoleModel addPermission(String permission) {
    if (hasPermission(permission)) return this;
    return copyWith(permissions: [...permissions, permission]);
  }

  /// Remove permission from role
  AgencyRoleModel removePermission(String permission) {
    return copyWith(
      permissions: permissions.where((p) => p != permission).toList(),
    );
  }

  /// Activate this role
  AgencyRoleModel activate() {
    return copyWith(
      status: AgencyRoleStatus.active,
      joinedAt: joinedAt ?? DateTime.now(),
    );
  }

  /// Deactivate this role
  AgencyRoleModel deactivate() {
    return copyWith(status: AgencyRoleStatus.inactive);
  }

  /// Suspend this role
  AgencyRoleModel suspend() {
    return copyWith(status: AgencyRoleStatus.suspended);
  }

  /// Update last activity timestamp
  AgencyRoleModel updateLastActivity() {
    return copyWith(lastActiveAt: DateTime.now());
  }
}
