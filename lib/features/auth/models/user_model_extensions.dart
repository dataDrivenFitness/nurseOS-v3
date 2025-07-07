// 📁 lib/features/auth/models/user_model_extensions.dart

import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';

/// 💼 Work-related extensions for UserModel
extension UserWorkContext on UserModel {
  /// Get work context information for session creation
  /// Uses available fields from UserModel to populate work session metadata
  Map<String, String?> get workContextForSession {
    return {
      'department': unit, // Use 'unit' field as department
      'shift': _inferShiftFromTime(),
      'facility': _inferFacilityFromUnit(),
    };
  }

  /// 🕐 Infer shift based on current time
  String? _inferShiftFromTime() {
    final hour = DateTime.now().hour;
    if (hour >= 7 && hour < 15) return 'day';
    if (hour >= 15 && hour < 23) return 'evening';
    if (hour >= 23 || hour < 7) return 'night';
    return null;
  }

  /// 🏥 Infer facility from unit if possible
  String? _inferFacilityFromUnit() {
    if (unit == null) return null;

    // Common unit name patterns to facility mapping
    final unitLower = unit!.toLowerCase();
    if (unitLower.contains('icu')) {
      return 'Intensive Care Unit';
    }
    if (unitLower.contains('er') || unitLower.contains('emergency')) {
      return 'Emergency Department';
    }
    if (unitLower.contains('med') && unitLower.contains('surg')) {
      return 'Medical/Surgical Unit';
    }
    if (unitLower.contains('peds') || unitLower.contains('pediatric')) {
      return 'Pediatric Unit';
    }
    if (unitLower.contains('onc') || unitLower.contains('cancer')) {
      return 'Oncology Unit';
    }
    if (unitLower.contains('cardiac') || unitLower.contains('cardio')) {
      return 'Cardiac Unit';
    }

    // Default to the unit name itself
    return unit;
  }

  /// 👩‍⚕️ Get display name for work context
  String get workDisplayName => '$firstName $lastName';

  /// 🏷️ Get role display name for work sessions
  String get roleDisplayName => role.displayName;
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.nurse:
        return 'Nurse';
    }
  }
}
