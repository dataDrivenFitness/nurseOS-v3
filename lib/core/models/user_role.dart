import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

enum UserRole {
  admin,
  nurse,
}

class UserRoleConverter implements JsonConverter<UserRole, String> {
  const UserRoleConverter();

  @override
  UserRole fromJson(String json) {
    switch (json.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'nurse':
        return UserRole.nurse;
      default:
        debugPrint('❌ Invalid user role from Firestore: $json');
        throw FormatException('Unknown user role: $json');
    }
  }

  @override
  String toJson(UserRole role) => role.name;
}
