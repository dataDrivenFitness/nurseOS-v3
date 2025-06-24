// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
      uid: json['uid'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      unit: json['unit'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      authProvider: json['authProvider'] as String?,
      role: const UserRoleConverter().fromJson(json['role'] as String),
      level: (json['level'] as num?)?.toInt() ?? 1,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'unit': instance.unit,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'authProvider': instance.authProvider,
      'role': const UserRoleConverter().toJson(instance.role),
      'level': instance.level,
      'xp': instance.xp,
      'badges': instance.badges,
    };
