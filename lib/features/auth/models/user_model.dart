import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/shared/converters/timestamp_converter.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    String? photoUrl,
    String? unit,
    @TimestampConverter() DateTime? createdAt,
    String? authProvider,
    @UserRoleConverter() required UserRole role,
    @Default(1) int level,
    @Default(0) int xp,
    @Default([]) List<String> badges,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
