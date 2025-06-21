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
// ── identity ─────────────────────────────────────────────
  String get id;
  String get firstName;
  String get lastName;
  String? get mrn; // ── location / admission ─────────────────────────────────
  String get location; // e.g. “3-East 12” or "Home Health"
  DateTime? get admittedAt;
  bool?
      get isIsolation; // ── clinical info ────────────────────────────────────────
  String get primaryDiagnosis;
  @RiskLevelConverter()
  RiskLevel? get manualRiskOverride;
  List<String>? get allergies;
  String? get codeStatus; // DNR / Full / etc.
// ── demographics ─────────────────────────────────────────
  DateTime? get birthDate;
  String? get pronouns;
  String?
      get photoUrl; // ── roster & ownership ───────────────────────────────────
  List<String>? get assignedNurses;
  String? get ownerUid; // head nurse / provider
  String? get createdBy; // who added record
// ── tags & misc ──────────────────────────────────────────
  List<String>? get tags;
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
            (identical(other.isIsolation, isIsolation) ||
                other.isIsolation == isIsolation) &&
            (identical(other.primaryDiagnosis, primaryDiagnosis) ||
                other.primaryDiagnosis == primaryDiagnosis) &&
            (identical(other.manualRiskOverride, manualRiskOverride) ||
                other.manualRiskOverride == manualRiskOverride) &&
            const DeepCollectionEquality().equals(other.allergies, allergies) &&
            (identical(other.codeStatus, codeStatus) ||
                other.codeStatus == codeStatus) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.pronouns, pronouns) ||
                other.pronouns == pronouns) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            const DeepCollectionEquality()
                .equals(other.assignedNurses, assignedNurses) &&
            (identical(other.ownerUid, ownerUid) ||
                other.ownerUid == ownerUid) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
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
        isIsolation,
        primaryDiagnosis,
        manualRiskOverride,
        const DeepCollectionEquality().hash(allergies),
        codeStatus,
        birthDate,
        pronouns,
        photoUrl,
        const DeepCollectionEquality().hash(assignedNurses),
        ownerUid,
        createdBy,
        const DeepCollectionEquality().hash(tags),
        notes
      ]);

  @override
  String toString() {
    return 'Patient(id: $id, firstName: $firstName, lastName: $lastName, mrn: $mrn, location: $location, admittedAt: $admittedAt, isIsolation: $isIsolation, primaryDiagnosis: $primaryDiagnosis, manualRiskOverride: $manualRiskOverride, allergies: $allergies, codeStatus: $codeStatus, birthDate: $birthDate, pronouns: $pronouns, photoUrl: $photoUrl, assignedNurses: $assignedNurses, ownerUid: $ownerUid, createdBy: $createdBy, tags: $tags, notes: $notes)';
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
      DateTime? admittedAt,
      bool? isIsolation,
      String primaryDiagnosis,
      @RiskLevelConverter() RiskLevel? manualRiskOverride,
      List<String>? allergies,
      String? codeStatus,
      DateTime? birthDate,
      String? pronouns,
      String? photoUrl,
      List<String>? assignedNurses,
      String? ownerUid,
      String? createdBy,
      List<String>? tags,
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
    Object? isIsolation = freezed,
    Object? primaryDiagnosis = null,
    Object? manualRiskOverride = freezed,
    Object? allergies = freezed,
    Object? codeStatus = freezed,
    Object? birthDate = freezed,
    Object? pronouns = freezed,
    Object? photoUrl = freezed,
    Object? assignedNurses = freezed,
    Object? ownerUid = freezed,
    Object? createdBy = freezed,
    Object? tags = freezed,
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
      isIsolation: freezed == isIsolation
          ? _self.isIsolation
          : isIsolation // ignore: cast_nullable_to_non_nullable
              as bool?,
      primaryDiagnosis: null == primaryDiagnosis
          ? _self.primaryDiagnosis
          : primaryDiagnosis // ignore: cast_nullable_to_non_nullable
              as String,
      manualRiskOverride: freezed == manualRiskOverride
          ? _self.manualRiskOverride
          : manualRiskOverride // ignore: cast_nullable_to_non_nullable
              as RiskLevel?,
      allergies: freezed == allergies
          ? _self.allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      codeStatus: freezed == codeStatus
          ? _self.codeStatus
          : codeStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _self.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pronouns: freezed == pronouns
          ? _self.pronouns
          : pronouns // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _self.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
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
      tags: freezed == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
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
      this.admittedAt,
      this.isIsolation,
      required this.primaryDiagnosis,
      @RiskLevelConverter() this.manualRiskOverride,
      final List<String>? allergies,
      this.codeStatus,
      this.birthDate,
      this.pronouns,
      this.photoUrl,
      final List<String>? assignedNurses,
      this.ownerUid,
      this.createdBy,
      final List<String>? tags,
      this.notes})
      : _allergies = allergies,
        _assignedNurses = assignedNurses,
        _tags = tags;
  factory _Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);

// ── identity ─────────────────────────────────────────────
  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? mrn;
// ── location / admission ─────────────────────────────────
  @override
  final String location;
// e.g. “3-East 12” or "Home Health"
  @override
  final DateTime? admittedAt;
  @override
  final bool? isIsolation;
// ── clinical info ────────────────────────────────────────
  @override
  final String primaryDiagnosis;
  @override
  @RiskLevelConverter()
  final RiskLevel? manualRiskOverride;
  final List<String>? _allergies;
  @override
  List<String>? get allergies {
    final value = _allergies;
    if (value == null) return null;
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? codeStatus;
// DNR / Full / etc.
// ── demographics ─────────────────────────────────────────
  @override
  final DateTime? birthDate;
  @override
  final String? pronouns;
  @override
  final String? photoUrl;
// ── roster & ownership ───────────────────────────────────
  final List<String>? _assignedNurses;
// ── roster & ownership ───────────────────────────────────
  @override
  List<String>? get assignedNurses {
    final value = _assignedNurses;
    if (value == null) return null;
    if (_assignedNurses is EqualUnmodifiableListView) return _assignedNurses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? ownerUid;
// head nurse / provider
  @override
  final String? createdBy;
// who added record
// ── tags & misc ──────────────────────────────────────────
  final List<String>? _tags;
// who added record
// ── tags & misc ──────────────────────────────────────────
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

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
            (identical(other.isIsolation, isIsolation) ||
                other.isIsolation == isIsolation) &&
            (identical(other.primaryDiagnosis, primaryDiagnosis) ||
                other.primaryDiagnosis == primaryDiagnosis) &&
            (identical(other.manualRiskOverride, manualRiskOverride) ||
                other.manualRiskOverride == manualRiskOverride) &&
            const DeepCollectionEquality()
                .equals(other._allergies, _allergies) &&
            (identical(other.codeStatus, codeStatus) ||
                other.codeStatus == codeStatus) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.pronouns, pronouns) ||
                other.pronouns == pronouns) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            const DeepCollectionEquality()
                .equals(other._assignedNurses, _assignedNurses) &&
            (identical(other.ownerUid, ownerUid) ||
                other.ownerUid == ownerUid) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
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
        isIsolation,
        primaryDiagnosis,
        manualRiskOverride,
        const DeepCollectionEquality().hash(_allergies),
        codeStatus,
        birthDate,
        pronouns,
        photoUrl,
        const DeepCollectionEquality().hash(_assignedNurses),
        ownerUid,
        createdBy,
        const DeepCollectionEquality().hash(_tags),
        notes
      ]);

  @override
  String toString() {
    return 'Patient(id: $id, firstName: $firstName, lastName: $lastName, mrn: $mrn, location: $location, admittedAt: $admittedAt, isIsolation: $isIsolation, primaryDiagnosis: $primaryDiagnosis, manualRiskOverride: $manualRiskOverride, allergies: $allergies, codeStatus: $codeStatus, birthDate: $birthDate, pronouns: $pronouns, photoUrl: $photoUrl, assignedNurses: $assignedNurses, ownerUid: $ownerUid, createdBy: $createdBy, tags: $tags, notes: $notes)';
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
      DateTime? admittedAt,
      bool? isIsolation,
      String primaryDiagnosis,
      @RiskLevelConverter() RiskLevel? manualRiskOverride,
      List<String>? allergies,
      String? codeStatus,
      DateTime? birthDate,
      String? pronouns,
      String? photoUrl,
      List<String>? assignedNurses,
      String? ownerUid,
      String? createdBy,
      List<String>? tags,
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
    Object? isIsolation = freezed,
    Object? primaryDiagnosis = null,
    Object? manualRiskOverride = freezed,
    Object? allergies = freezed,
    Object? codeStatus = freezed,
    Object? birthDate = freezed,
    Object? pronouns = freezed,
    Object? photoUrl = freezed,
    Object? assignedNurses = freezed,
    Object? ownerUid = freezed,
    Object? createdBy = freezed,
    Object? tags = freezed,
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
      isIsolation: freezed == isIsolation
          ? _self.isIsolation
          : isIsolation // ignore: cast_nullable_to_non_nullable
              as bool?,
      primaryDiagnosis: null == primaryDiagnosis
          ? _self.primaryDiagnosis
          : primaryDiagnosis // ignore: cast_nullable_to_non_nullable
              as String,
      manualRiskOverride: freezed == manualRiskOverride
          ? _self.manualRiskOverride
          : manualRiskOverride // ignore: cast_nullable_to_non_nullable
              as RiskLevel?,
      allergies: freezed == allergies
          ? _self._allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      codeStatus: freezed == codeStatus
          ? _self.codeStatus
          : codeStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _self.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pronouns: freezed == pronouns
          ? _self.pronouns
          : pronouns // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _self.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
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
      tags: freezed == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
