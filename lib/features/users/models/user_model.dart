// TODO: Restore full UserModel once Freezed build is complete

/*import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    String? photoUrl,
    String? unit,
    DateTime? createdAt,
    String? authProvider, // e.g., 'email', 'google'
    @Default(1) int level,
    @Default(0) int xp,
    @Default('nurse') String role,
    @Default([]) List<String> badges,
    @Default(true) bool isActive,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}*/
