import 'package:json_annotation/json_annotation.dart';
import 'package:nurseos_v3/features/agency/models/agency_role_model.dart';

class AgencyRoleMapConverter
    extends JsonConverter<Map<String, AgencyRoleModel>, Map<String, dynamic>> {
  const AgencyRoleMapConverter();

  @override
  Map<String, AgencyRoleModel> fromJson(Map<String, dynamic> json) {
    return json.map(
      (key, value) => MapEntry(key, AgencyRoleModel.fromJson(value)),
    );
  }

  @override
  Map<String, dynamic> toJson(Map<String, AgencyRoleModel> object) {
    return object.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
  }
}
