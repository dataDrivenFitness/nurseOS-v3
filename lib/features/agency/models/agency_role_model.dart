// 📁 lib/features/agency/models/agency_role_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'agency_role_model.freezed.dart';
part 'agency_role_model.g.dart';

@freezed
abstract class AgencyRoleModel with _$AgencyRoleModel {
  const factory AgencyRoleModel({
    String? agencyId, // Made optional to handle null values
    String? userId, // Made optional to handle null values
    @UserRoleConverter() required UserRole role,
    String? department,
    String? assignedBy,
    @TimestampConverter() DateTime? joinedAt,
  }) = _AgencyRoleModel;

  factory AgencyRoleModel.fromJson(Map<String, dynamic> json) =>
      _$AgencyRoleModelFromJson(json);
}
