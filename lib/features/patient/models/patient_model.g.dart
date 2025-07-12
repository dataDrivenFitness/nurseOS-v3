// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Patient _$PatientFromJson(Map<String, dynamic> json) => _Patient(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      mrn: json['mrn'] as String?,
      location: json['location'] as String,
      agencyId: json['agencyId'] as String?,
      admittedAt: const TimestampConverter().fromJson(json['admittedAt']),
      lastSeen: const TimestampConverter().fromJson(json['lastSeen']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      birthDate: const TimestampConverter().fromJson(json['birthDate']),
      isIsolation: json['isIsolation'] as bool? ?? false,
      isFallRisk: json['isFallRisk'] as bool? ?? false,
      primaryDiagnoses: (json['primaryDiagnoses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      manualRiskOverride: _$JsonConverterFromJson<String, RiskLevel>(
          json['manualRiskOverride'], const RiskLevelConverter().fromJson),
      codeStatus: json['codeStatus'] as String?,
      pronouns: json['pronouns'] as String?,
      biologicalSex: json['biologicalSex'] as String? ?? 'unspecified',
      photoUrl: json['photoUrl'] as String?,
      language: json['language'] as String?,
      ownerUid: json['ownerUid'] as String?,
      createdBy: json['createdBy'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dietRestrictions: (json['dietRestrictions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      department: json['department'] as String?,
      roomNumber: json['roomNumber'] as String?,
      addressLine1: json['addressLine1'] as String?,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zip: json['zip'] as String?,
    );

Map<String, dynamic> _$PatientToJson(_Patient instance) => <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'mrn': instance.mrn,
      'location': instance.location,
      'agencyId': instance.agencyId,
      'admittedAt': const TimestampConverter().toJson(instance.admittedAt),
      'lastSeen': const TimestampConverter().toJson(instance.lastSeen),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'birthDate': const TimestampConverter().toJson(instance.birthDate),
      'isIsolation': instance.isIsolation,
      'isFallRisk': instance.isFallRisk,
      'primaryDiagnoses': instance.primaryDiagnoses,
      'manualRiskOverride': _$JsonConverterToJson<String, RiskLevel>(
          instance.manualRiskOverride, const RiskLevelConverter().toJson),
      'codeStatus': instance.codeStatus,
      'pronouns': instance.pronouns,
      'biologicalSex': instance.biologicalSex,
      'photoUrl': instance.photoUrl,
      'language': instance.language,
      'ownerUid': instance.ownerUid,
      'createdBy': instance.createdBy,
      'allergies': instance.allergies,
      'dietRestrictions': instance.dietRestrictions,
      'department': instance.department,
      'roomNumber': instance.roomNumber,
      'addressLine1': instance.addressLine1,
      'addressLine2': instance.addressLine2,
      'city': instance.city,
      'state': instance.state,
      'zip': instance.zip,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
