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
      admittedAt: const TimestampConverter().fromJson(json['admittedAt']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      isIsolation: json['isIsolation'] as bool? ?? false,
      primaryDiagnosis: json['primaryDiagnosis'] as String,
      manualRiskOverride: _$JsonConverterFromJson<String, RiskLevel>(
          json['manualRiskOverride'], const RiskLevelConverter().fromJson),
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      codeStatus: json['codeStatus'] as String?,
      birthDate: const TimestampConverter().fromJson(json['birthDate']),
      pronouns: json['pronouns'] as String?,
      biologicalSex: json['biologicalSex'] as String? ?? 'unspecified',
      photoUrl: json['photoUrl'] as String?,
      assignedNurses: (json['assignedNurses'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      ownerUid: json['ownerUid'] as String?,
      createdBy: json['createdBy'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PatientToJson(_Patient instance) => <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'mrn': instance.mrn,
      'location': instance.location,
      'admittedAt': const TimestampConverter().toJson(instance.admittedAt),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'isIsolation': instance.isIsolation,
      'primaryDiagnosis': instance.primaryDiagnosis,
      'manualRiskOverride': _$JsonConverterToJson<String, RiskLevel>(
          instance.manualRiskOverride, const RiskLevelConverter().toJson),
      'allergies': instance.allergies,
      'codeStatus': instance.codeStatus,
      'birthDate': const TimestampConverter().toJson(instance.birthDate),
      'pronouns': instance.pronouns,
      'biologicalSex': instance.biologicalSex,
      'photoUrl': instance.photoUrl,
      'assignedNurses': instance.assignedNurses,
      'ownerUid': instance.ownerUid,
      'createdBy': instance.createdBy,
      'tags': instance.tags,
      'notes': instance.notes,
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
