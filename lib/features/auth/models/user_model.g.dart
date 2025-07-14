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
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      authProvider: json['authProvider'] as String?,
      role: const UserRoleConverter().fromJson(json['role'] as String),
      licenseNumber: json['licenseNumber'] as String?,
      licenseExpiry: const TimestampConverter().fromJson(json['licenseExpiry']),
      specialty: json['specialty'] as String?,
      department: json['department'] as String?,
      unit: json['unit'] as String?,
      shift: json['shift'] as String?,
      phoneExtension: json['phoneExtension'] as String?,
      hireDate: const TimestampConverter().fromJson(json['hireDate']),
      certifications: (json['certifications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isOnDuty: json['isOnDuty'] as bool?,
      lastStatusChange:
          const TimestampConverter().fromJson(json['lastStatusChange']),
      currentSessionId: json['currentSessionId'] as String?,
      activeAgencyId: json['activeAgencyId'] as String?,
      agencyRoles: json['agencyRoles'] == null
          ? const {}
          : const AgencyRoleMapConverter()
              .fromJson(json['agencyRoles'] as Map<String, dynamic>),
      isIndependentNurse: json['isIndependentNurse'] as bool? ?? false,
      businessName: json['businessName'] as String?,
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
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'authProvider': instance.authProvider,
      'role': const UserRoleConverter().toJson(instance.role),
      'licenseNumber': instance.licenseNumber,
      'licenseExpiry':
          const TimestampConverter().toJson(instance.licenseExpiry),
      'specialty': instance.specialty,
      'department': instance.department,
      'unit': instance.unit,
      'shift': instance.shift,
      'phoneExtension': instance.phoneExtension,
      'hireDate': const TimestampConverter().toJson(instance.hireDate),
      'certifications': instance.certifications,
      'isOnDuty': instance.isOnDuty,
      'lastStatusChange':
          const TimestampConverter().toJson(instance.lastStatusChange),
      'currentSessionId': instance.currentSessionId,
      'activeAgencyId': instance.activeAgencyId,
      'agencyRoles':
          const AgencyRoleMapConverter().toJson(instance.agencyRoles),
      'isIndependentNurse': instance.isIndependentNurse,
      'businessName': instance.businessName,
      'level': instance.level,
      'xp': instance.xp,
      'badges': instance.badges,
    };
