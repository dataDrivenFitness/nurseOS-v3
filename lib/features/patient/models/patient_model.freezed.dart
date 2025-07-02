// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Patient {
  String get id;
  String get firstName;
  String get lastName;
  String? get mrn;
  String get location;
  @TimestampConverter()
  DateTime? get admittedAt;
  @TimestampConverter()
  DateTime? get lastSeen; // ✅ Correct location
  @TimestampConverter()
  DateTime? get createdAt;
  @TimestampConverter()
  DateTime? get birthDate; // 🧠 Clinical flags
  bool? get isIsolation;
  bool get isFallRisk;
  String get primaryDiagnosis;
  @RiskLevelConverter()
  RiskLevel? get manualRiskOverride;
  String? get codeStatus; // 🧍 Identity & meta
  String? get pronouns;
  String? get biologicalSex;
  String? get photoUrl;
  String? get language; // 🩺 Assigned & created by
  List<String>? get assignedNurses;
  String? get ownerUid;
  String? get createdBy; // 🏷️ Tags & notes
  List<String>? get allergies;
  List<String>? get tags;
  List<String>? get dietRestrictions; // 🍽️ NEW FIELD
  String? get notes;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PatientCopyWith<Patient> get copyWith =>
      _$PatientCopyWithImpl<Patient>(this as Patient, _$identity);

  /// Serializes this Patient to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Patient &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.mrn, mrn) || other.mrn == mrn) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.admittedAt, admittedAt) ||
                other.admittedAt == admittedAt) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.isIsolation, isIsolation) ||
                other.isIsolation == isIsolation) &&
            (identical(other.isFallRisk, isFallRisk) ||
                other.isFallRisk == isFallRisk) &&
            (identical(other.primaryDiagnosis, primaryDiagnosis) ||
                other.primaryDiagnosis == primaryDiagnosis) &&
            (identical(other.manualRiskOverride, manualRiskOverride) ||
                other.manualRiskOverride == manualRiskOverride) &&
            (identical(other.codeStatus, codeStatus) ||
                other.codeStatus == codeStatus) &&
            (identical(other.pronouns, pronouns) ||
                other.pronouns == pronouns) &&
            (identical(other.biologicalSex, biologicalSex) ||
                other.biologicalSex == biologicalSex) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.language, language) ||
                other.language == language) &&
            const DeepCollectionEquality()
                .equals(other.assignedNurses, assignedNurses) &&
            (identical(other.ownerUid, ownerUid) ||
                other.ownerUid == ownerUid) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            const DeepCollectionEquality().equals(other.allergies, allergies) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            const DeepCollectionEquality()
                .equals(other.dietRestrictions, dietRestrictions) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        firstName,
        lastName,
        mrn,
        location,
        admittedAt,
        lastSeen,
        createdAt,
        birthDate,
        isIsolation,
        isFallRisk,
        primaryDiagnosis,
        manualRiskOverride,
        codeStatus,
        pronouns,
        biologicalSex,
        photoUrl,
        language,
        const DeepCollectionEquality().hash(assignedNurses),
        ownerUid,
        createdBy,
        const DeepCollectionEquality().hash(allergies),
        const DeepCollectionEquality().hash(tags),
        const DeepCollectionEquality().hash(dietRestrictions),
        notes
      ]);

  @override
  String toString() {
    return 'Patient(id: $id, firstName: $firstName, lastName: $lastName, mrn: $mrn, location: $location, admittedAt: $admittedAt, lastSeen: $lastSeen, createdAt: $createdAt, birthDate: $birthDate, isIsolation: $isIsolation, isFallRisk: $isFallRisk, primaryDiagnosis: $primaryDiagnosis, manualRiskOverride: $manualRiskOverride, codeStatus: $codeStatus, pronouns: $pronouns, biologicalSex: $biologicalSex, photoUrl: $photoUrl, language: $language, assignedNurses: $assignedNurses, ownerUid: $ownerUid, createdBy: $createdBy, allergies: $allergies, tags: $tags, dietRestrictions: $dietRestrictions, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class $PatientCopyWith<$Res> {
  factory $PatientCopyWith(Patient value, $Res Function(Patient) _then) =
      _$PatientCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String firstName,
      String lastName,
      String? mrn,
      String location,
      @TimestampConverter() DateTime? admittedAt,
      @TimestampConverter() DateTime? lastSeen,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? birthDate,
      bool? isIsolation,
      bool isFallRisk,
      String primaryDiagnosis,
      @RiskLevelConverter() RiskLevel? manualRiskOverride,
      String? codeStatus,
      String? pronouns,
      String? biologicalSex,
      String? photoUrl,
      String? language,
      List<String>? assignedNurses,
      String? ownerUid,
      String? createdBy,
      List<String>? allergies,
      List<String>? tags,
      List<String>? dietRestrictions,
      String? notes});
}

/// @nodoc
class _$PatientCopyWithImpl<$Res> implements $PatientCopyWith<$Res> {
  _$PatientCopyWithImpl(this._self, this._then);

  final Patient _self;
  final $Res Function(Patient) _then;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? mrn = freezed,
    Object? location = null,
    Object? admittedAt = freezed,
    Object? lastSeen = freezed,
    Object? createdAt = freezed,
    Object? birthDate = freezed,
    Object? isIsolation = freezed,
    Object? isFallRisk = null,
    Object? primaryDiagnosis = null,
    Object? manualRiskOverride = freezed,
    Object? codeStatus = freezed,
    Object? pronouns = freezed,
    Object? biologicalSex = freezed,
    Object? photoUrl = freezed,
    Object? language = freezed,
    Object? assignedNurses = freezed,
    Object? ownerUid = freezed,
    Object? createdBy = freezed,
    Object? allergies = freezed,
    Object? tags = freezed,
    Object? dietRestrictions = freezed,
    Object? notes = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      mrn: freezed == mrn
          ? _self.mrn
          : mrn // ignore: cast_nullable_to_non_nullable
              as String?,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      admittedAt: freezed == admittedAt
          ? _self.admittedAt
          : admittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSeen: freezed == lastSeen
          ? _self.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      birthDate: freezed == birthDate
          ? _self.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isIsolation: freezed == isIsolation
          ? _self.isIsolation
          : isIsolation // ignore: cast_nullable_to_non_nullable
              as bool?,
      isFallRisk: null == isFallRisk
          ? _self.isFallRisk
          : isFallRisk // ignore: cast_nullable_to_non_nullable
              as bool,
      primaryDiagnosis: null == primaryDiagnosis
          ? _self.primaryDiagnosis
          : primaryDiagnosis // ignore: cast_nullable_to_non_nullable
              as String,
      manualRiskOverride: freezed == manualRiskOverride
          ? _self.manualRiskOverride
          : manualRiskOverride // ignore: cast_nullable_to_non_nullable
              as RiskLevel?,
      codeStatus: freezed == codeStatus
          ? _self.codeStatus
          : codeStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      pronouns: freezed == pronouns
          ? _self.pronouns
          : pronouns // ignore: cast_nullable_to_non_nullable
              as String?,
      biologicalSex: freezed == biologicalSex
          ? _self.biologicalSex
          : biologicalSex // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _self.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedNurses: freezed == assignedNurses
          ? _self.assignedNurses
          : assignedNurses // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      ownerUid: freezed == ownerUid
          ? _self.ownerUid
          : ownerUid // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      allergies: freezed == allergies
          ? _self.allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      dietRestrictions: freezed == dietRestrictions
          ? _self.dietRestrictions
          : dietRestrictions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _Patient implements Patient {
  const _Patient(
      {required this.id,
      required this.firstName,
      required this.lastName,
      this.mrn,
      required this.location,
      @TimestampConverter() this.admittedAt,
      @TimestampConverter() this.lastSeen,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.birthDate,
      this.isIsolation = false,
      this.isFallRisk = false,
      required this.primaryDiagnosis,
      @RiskLevelConverter() this.manualRiskOverride,
      this.codeStatus,
      this.pronouns,
      this.biologicalSex = 'unspecified',
      this.photoUrl,
      this.language,
      final List<String>? assignedNurses = const [],
      this.ownerUid,
      this.createdBy,
      final List<String>? allergies = const [],
      final List<String>? tags = const [],
      final List<String>? dietRestrictions = const [],
      this.notes})
      : _assignedNurses = assignedNurses,
        _allergies = allergies,
        _tags = tags,
        _dietRestrictions = dietRestrictions;
  factory _Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);

  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? mrn;
  @override
  final String location;
  @override
  @TimestampConverter()
  final DateTime? admittedAt;
  @override
  @TimestampConverter()
  final DateTime? lastSeen;
// ✅ Correct location
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? birthDate;
// 🧠 Clinical flags
  @override
  @JsonKey()
  final bool? isIsolation;
  @override
  @JsonKey()
  final bool isFallRisk;
  @override
  final String primaryDiagnosis;
  @override
  @RiskLevelConverter()
  final RiskLevel? manualRiskOverride;
  @override
  final String? codeStatus;
// 🧍 Identity & meta
  @override
  final String? pronouns;
  @override
  @JsonKey()
  final String? biologicalSex;
  @override
  final String? photoUrl;
  @override
  final String? language;
// 🩺 Assigned & created by
  final List<String>? _assignedNurses;
// 🩺 Assigned & created by
  @override
  @JsonKey()
  List<String>? get assignedNurses {
    final value = _assignedNurses;
    if (value == null) return null;
    if (_assignedNurses is EqualUnmodifiableListView) return _assignedNurses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? ownerUid;
  @override
  final String? createdBy;
// 🏷️ Tags & notes
  final List<String>? _allergies;
// 🏷️ Tags & notes
  @override
  @JsonKey()
  List<String>? get allergies {
    final value = _allergies;
    if (value == null) return null;
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _tags;
  @override
  @JsonKey()
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _dietRestrictions;
  @override
  @JsonKey()
  List<String>? get dietRestrictions {
    final value = _dietRestrictions;
    if (value == null) return null;
    if (_dietRestrictions is EqualUnmodifiableListView)
      return _dietRestrictions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// 🍽️ NEW FIELD
  @override
  final String? notes;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PatientCopyWith<_Patient> get copyWith =>
      __$PatientCopyWithImpl<_Patient>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PatientToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Patient &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.mrn, mrn) || other.mrn == mrn) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.admittedAt, admittedAt) ||
                other.admittedAt == admittedAt) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.isIsolation, isIsolation) ||
                other.isIsolation == isIsolation) &&
            (identical(other.isFallRisk, isFallRisk) ||
                other.isFallRisk == isFallRisk) &&
            (identical(other.primaryDiagnosis, primaryDiagnosis) ||
                other.primaryDiagnosis == primaryDiagnosis) &&
            (identical(other.manualRiskOverride, manualRiskOverride) ||
                other.manualRiskOverride == manualRiskOverride) &&
            (identical(other.codeStatus, codeStatus) ||
                other.codeStatus == codeStatus) &&
            (identical(other.pronouns, pronouns) ||
                other.pronouns == pronouns) &&
            (identical(other.biologicalSex, biologicalSex) ||
                other.biologicalSex == biologicalSex) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.language, language) ||
                other.language == language) &&
            const DeepCollectionEquality()
                .equals(other._assignedNurses, _assignedNurses) &&
            (identical(other.ownerUid, ownerUid) ||
                other.ownerUid == ownerUid) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            const DeepCollectionEquality()
                .equals(other._allergies, _allergies) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._dietRestrictions, _dietRestrictions) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        firstName,
        lastName,
        mrn,
        location,
        admittedAt,
        lastSeen,
        createdAt,
        birthDate,
        isIsolation,
        isFallRisk,
        primaryDiagnosis,
        manualRiskOverride,
        codeStatus,
        pronouns,
        biologicalSex,
        photoUrl,
        language,
        const DeepCollectionEquality().hash(_assignedNurses),
        ownerUid,
        createdBy,
        const DeepCollectionEquality().hash(_allergies),
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_dietRestrictions),
        notes
      ]);

  @override
  String toString() {
    return 'Patient(id: $id, firstName: $firstName, lastName: $lastName, mrn: $mrn, location: $location, admittedAt: $admittedAt, lastSeen: $lastSeen, createdAt: $createdAt, birthDate: $birthDate, isIsolation: $isIsolation, isFallRisk: $isFallRisk, primaryDiagnosis: $primaryDiagnosis, manualRiskOverride: $manualRiskOverride, codeStatus: $codeStatus, pronouns: $pronouns, biologicalSex: $biologicalSex, photoUrl: $photoUrl, language: $language, assignedNurses: $assignedNurses, ownerUid: $ownerUid, createdBy: $createdBy, allergies: $allergies, tags: $tags, dietRestrictions: $dietRestrictions, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class _$PatientCopyWith<$Res> implements $PatientCopyWith<$Res> {
  factory _$PatientCopyWith(_Patient value, $Res Function(_Patient) _then) =
      __$PatientCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String firstName,
      String lastName,
      String? mrn,
      String location,
      @TimestampConverter() DateTime? admittedAt,
      @TimestampConverter() DateTime? lastSeen,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? birthDate,
      bool? isIsolation,
      bool isFallRisk,
      String primaryDiagnosis,
      @RiskLevelConverter() RiskLevel? manualRiskOverride,
      String? codeStatus,
      String? pronouns,
      String? biologicalSex,
      String? photoUrl,
      String? language,
      List<String>? assignedNurses,
      String? ownerUid,
      String? createdBy,
      List<String>? allergies,
      List<String>? tags,
      List<String>? dietRestrictions,
      String? notes});
}

/// @nodoc
class __$PatientCopyWithImpl<$Res> implements _$PatientCopyWith<$Res> {
  __$PatientCopyWithImpl(this._self, this._then);

  final _Patient _self;
  final $Res Function(_Patient) _then;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? mrn = freezed,
    Object? location = null,
    Object? admittedAt = freezed,
    Object? lastSeen = freezed,
    Object? createdAt = freezed,
    Object? birthDate = freezed,
    Object? isIsolation = freezed,
    Object? isFallRisk = null,
    Object? primaryDiagnosis = null,
    Object? manualRiskOverride = freezed,
    Object? codeStatus = freezed,
    Object? pronouns = freezed,
    Object? biologicalSex = freezed,
    Object? photoUrl = freezed,
    Object? language = freezed,
    Object? assignedNurses = freezed,
    Object? ownerUid = freezed,
    Object? createdBy = freezed,
    Object? allergies = freezed,
    Object? tags = freezed,
    Object? dietRestrictions = freezed,
    Object? notes = freezed,
  }) {
    return _then(_Patient(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      mrn: freezed == mrn
          ? _self.mrn
          : mrn // ignore: cast_nullable_to_non_nullable
              as String?,
      location: null == location
          ? _self.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      admittedAt: freezed == admittedAt
          ? _self.admittedAt
          : admittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastSeen: freezed == lastSeen
          ? _self.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      birthDate: freezed == birthDate
          ? _self.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isIsolation: freezed == isIsolation
          ? _self.isIsolation
          : isIsolation // ignore: cast_nullable_to_non_nullable
              as bool?,
      isFallRisk: null == isFallRisk
          ? _self.isFallRisk
          : isFallRisk // ignore: cast_nullable_to_non_nullable
              as bool,
      primaryDiagnosis: null == primaryDiagnosis
          ? _self.primaryDiagnosis
          : primaryDiagnosis // ignore: cast_nullable_to_non_nullable
              as String,
      manualRiskOverride: freezed == manualRiskOverride
          ? _self.manualRiskOverride
          : manualRiskOverride // ignore: cast_nullable_to_non_nullable
              as RiskLevel?,
      codeStatus: freezed == codeStatus
          ? _self.codeStatus
          : codeStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      pronouns: freezed == pronouns
          ? _self.pronouns
          : pronouns // ignore: cast_nullable_to_non_nullable
              as String?,
      biologicalSex: freezed == biologicalSex
          ? _self.biologicalSex
          : biologicalSex // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _self.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedNurses: freezed == assignedNurses
          ? _self._assignedNurses
          : assignedNurses // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      ownerUid: freezed == ownerUid
          ? _self.ownerUid
          : ownerUid // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _self.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      allergies: freezed == allergies
          ? _self._allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: freezed == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      dietRestrictions: freezed == dietRestrictions
          ? _self._dietRestrictions
          : dietRestrictions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
