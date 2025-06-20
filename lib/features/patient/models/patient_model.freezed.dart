// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Patient _$PatientFromJson(Map<String, dynamic> json) {
  return _Patient.fromJson(json);
}

/// @nodoc
mixin _$Patient {
// ── identity ─────────────────────────────────────────────
  String get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String? get mrn =>
      throw _privateConstructorUsedError; // ── location / admission ─────────────────────────────────
  String get location =>
      throw _privateConstructorUsedError; // e.g. “3-East 12” or "Home Health"
  DateTime? get admittedAt => throw _privateConstructorUsedError;
  bool? get isIsolation =>
      throw _privateConstructorUsedError; // ── clinical info ────────────────────────────────────────
  String get primaryDiagnosis => throw _privateConstructorUsedError;
  @RiskLevelConverter()
  RiskLevel? get manualRiskOverride => throw _privateConstructorUsedError;
  List<String>? get allergies => throw _privateConstructorUsedError;
  String? get codeStatus =>
      throw _privateConstructorUsedError; // DNR / Full / etc.
// ── demographics ─────────────────────────────────────────
  DateTime? get birthDate => throw _privateConstructorUsedError;
  String? get pronouns => throw _privateConstructorUsedError;
  String? get photoUrl =>
      throw _privateConstructorUsedError; // ── roster & ownership ───────────────────────────────────
  List<String>? get assignedNurses => throw _privateConstructorUsedError;
  String? get ownerUid =>
      throw _privateConstructorUsedError; // head nurse / provider
  String? get createdBy =>
      throw _privateConstructorUsedError; // who added record
// ── tags & misc ──────────────────────────────────────────
  List<String>? get tags => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Patient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientCopyWith<Patient> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientCopyWith<$Res> {
  factory $PatientCopyWith(Patient value, $Res Function(Patient) then) =
      _$PatientCopyWithImpl<$Res, Patient>;
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
class _$PatientCopyWithImpl<$Res, $Val extends Patient>
    implements $PatientCopyWith<$Res> {
  _$PatientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      mrn: freezed == mrn
          ? _value.mrn
          : mrn // ignore: cast_nullable_to_non_nullable
              as String?,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      admittedAt: freezed == admittedAt
          ? _value.admittedAt
          : admittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isIsolation: freezed == isIsolation
          ? _value.isIsolation
          : isIsolation // ignore: cast_nullable_to_non_nullable
              as bool?,
      primaryDiagnosis: null == primaryDiagnosis
          ? _value.primaryDiagnosis
          : primaryDiagnosis // ignore: cast_nullable_to_non_nullable
              as String,
      manualRiskOverride: freezed == manualRiskOverride
          ? _value.manualRiskOverride
          : manualRiskOverride // ignore: cast_nullable_to_non_nullable
              as RiskLevel?,
      allergies: freezed == allergies
          ? _value.allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      codeStatus: freezed == codeStatus
          ? _value.codeStatus
          : codeStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pronouns: freezed == pronouns
          ? _value.pronouns
          : pronouns // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedNurses: freezed == assignedNurses
          ? _value.assignedNurses
          : assignedNurses // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      ownerUid: freezed == ownerUid
          ? _value.ownerUid
          : ownerUid // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PatientImplCopyWith<$Res> implements $PatientCopyWith<$Res> {
  factory _$$PatientImplCopyWith(
          _$PatientImpl value, $Res Function(_$PatientImpl) then) =
      __$$PatientImplCopyWithImpl<$Res>;
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
class __$$PatientImplCopyWithImpl<$Res>
    extends _$PatientCopyWithImpl<$Res, _$PatientImpl>
    implements _$$PatientImplCopyWith<$Res> {
  __$$PatientImplCopyWithImpl(
      _$PatientImpl _value, $Res Function(_$PatientImpl) _then)
      : super(_value, _then);

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
    return _then(_$PatientImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      mrn: freezed == mrn
          ? _value.mrn
          : mrn // ignore: cast_nullable_to_non_nullable
              as String?,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      admittedAt: freezed == admittedAt
          ? _value.admittedAt
          : admittedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isIsolation: freezed == isIsolation
          ? _value.isIsolation
          : isIsolation // ignore: cast_nullable_to_non_nullable
              as bool?,
      primaryDiagnosis: null == primaryDiagnosis
          ? _value.primaryDiagnosis
          : primaryDiagnosis // ignore: cast_nullable_to_non_nullable
              as String,
      manualRiskOverride: freezed == manualRiskOverride
          ? _value.manualRiskOverride
          : manualRiskOverride // ignore: cast_nullable_to_non_nullable
              as RiskLevel?,
      allergies: freezed == allergies
          ? _value._allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      codeStatus: freezed == codeStatus
          ? _value.codeStatus
          : codeStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      pronouns: freezed == pronouns
          ? _value.pronouns
          : pronouns // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedNurses: freezed == assignedNurses
          ? _value._assignedNurses
          : assignedNurses // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      ownerUid: freezed == ownerUid
          ? _value.ownerUid
          : ownerUid // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientImpl implements _Patient {
  const _$PatientImpl(
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

  factory _$PatientImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientImplFromJson(json);

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

  @override
  String toString() {
    return 'Patient(id: $id, firstName: $firstName, lastName: $lastName, mrn: $mrn, location: $location, admittedAt: $admittedAt, isIsolation: $isIsolation, primaryDiagnosis: $primaryDiagnosis, manualRiskOverride: $manualRiskOverride, allergies: $allergies, codeStatus: $codeStatus, birthDate: $birthDate, pronouns: $pronouns, photoUrl: $photoUrl, assignedNurses: $assignedNurses, ownerUid: $ownerUid, createdBy: $createdBy, tags: $tags, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientImpl &&
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

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientImplCopyWith<_$PatientImpl> get copyWith =>
      __$$PatientImplCopyWithImpl<_$PatientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientImplToJson(
      this,
    );
  }
}

abstract class _Patient implements Patient {
  const factory _Patient(
      {required final String id,
      required final String firstName,
      required final String lastName,
      final String? mrn,
      required final String location,
      final DateTime? admittedAt,
      final bool? isIsolation,
      required final String primaryDiagnosis,
      @RiskLevelConverter() final RiskLevel? manualRiskOverride,
      final List<String>? allergies,
      final String? codeStatus,
      final DateTime? birthDate,
      final String? pronouns,
      final String? photoUrl,
      final List<String>? assignedNurses,
      final String? ownerUid,
      final String? createdBy,
      final List<String>? tags,
      final String? notes}) = _$PatientImpl;

  factory _Patient.fromJson(Map<String, dynamic> json) = _$PatientImpl.fromJson;

// ── identity ─────────────────────────────────────────────
  @override
  String get id;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String? get mrn; // ── location / admission ─────────────────────────────────
  @override
  String get location; // e.g. “3-East 12” or "Home Health"
  @override
  DateTime? get admittedAt;
  @override
  bool?
      get isIsolation; // ── clinical info ────────────────────────────────────────
  @override
  String get primaryDiagnosis;
  @override
  @RiskLevelConverter()
  RiskLevel? get manualRiskOverride;
  @override
  List<String>? get allergies;
  @override
  String? get codeStatus; // DNR / Full / etc.
// ── demographics ─────────────────────────────────────────
  @override
  DateTime? get birthDate;
  @override
  String? get pronouns;
  @override
  String?
      get photoUrl; // ── roster & ownership ───────────────────────────────────
  @override
  List<String>? get assignedNurses;
  @override
  String? get ownerUid; // head nurse / provider
  @override
  String? get createdBy; // who added record
// ── tags & misc ──────────────────────────────────────────
  @override
  List<String>? get tags;
  @override
  String? get notes;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientImplCopyWith<_$PatientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
