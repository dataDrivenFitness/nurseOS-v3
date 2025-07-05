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
// 🆔 Identity & Demographics
  String get id;
  String get firstName;
  String get lastName;
  String? get mrn;

  /// 🌍 Type of location the patient is currently in
  /// e.g. "residence", "hospital", "snf", "rehab", "other"
  /// NOTE: Keeping field name as `location` for Firestore compatibility
  String get location;

  /// 🕐 Admission & visibility timestamps
  @TimestampConverter()
  DateTime? get admittedAt;
  @TimestampConverter()
  DateTime? get lastSeen;
  @TimestampConverter()
  DateTime? get createdAt;
  @TimestampConverter()
  DateTime? get birthDate; // 🚩 Clinical Risk Flags
  bool? get isIsolation;
  bool get isFallRisk;

  /// 💊 Supports multiple diagnoses per patient
  List<String> get primaryDiagnoses;
  @RiskLevelConverter()
  RiskLevel? get manualRiskOverride;
  String? get codeStatus; // 🧍 Gender, pronouns, language
  String? get pronouns;
  String? get biologicalSex;
  String? get photoUrl;
  String? get language; // 👩‍⚕️ Assigned nurses & ownership
  List<String>? get assignedNurses;
  String? get ownerUid;
  String? get createdBy; // 🌿 Medical Notes & Dietary Flags
  List<String>? get allergies;
  List<String>?
      get dietRestrictions; // 🏥 Facility Location Fields (only applies if location != 'residence')
  String? get department; // e.g. "ICU", "Med-Surg"
  String? get roomNumber; // e.g. "12B"
// 🏡 Structured Address Fields (only if location == 'residence')
  String? get addressLine1; // e.g. "123 Main St"
  String? get addressLine2; // e.g. "Apt 4B"
  String? get city;
  String? get state;
  String? get zip;

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
            const DeepCollectionEquality()
                .equals(other.primaryDiagnoses, primaryDiagnoses) &&
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
            const DeepCollectionEquality()
                .equals(other.dietRestrictions, dietRestrictions) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.roomNumber, roomNumber) ||
                other.roomNumber == roomNumber) &&
            (identical(other.addressLine1, addressLine1) ||
                other.addressLine1 == addressLine1) &&
            (identical(other.addressLine2, addressLine2) ||
                other.addressLine2 == addressLine2) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.zip, zip) || other.zip == zip));
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
        const DeepCollectionEquality().hash(primaryDiagnoses),
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
        const DeepCollectionEquality().hash(dietRestrictions),
        department,
        roomNumber,
        addressLine1,
        addressLine2,
        city,
        state,
        zip
      ]);

  @override
  String toString() {
    return 'Patient(id: $id, firstName: $firstName, lastName: $lastName, mrn: $mrn, location: $location, admittedAt: $admittedAt, lastSeen: $lastSeen, createdAt: $createdAt, birthDate: $birthDate, isIsolation: $isIsolation, isFallRisk: $isFallRisk, primaryDiagnoses: $primaryDiagnoses, manualRiskOverride: $manualRiskOverride, codeStatus: $codeStatus, pronouns: $pronouns, biologicalSex: $biologicalSex, photoUrl: $photoUrl, language: $language, assignedNurses: $assignedNurses, ownerUid: $ownerUid, createdBy: $createdBy, allergies: $allergies, dietRestrictions: $dietRestrictions, department: $department, roomNumber: $roomNumber, addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, state: $state, zip: $zip)';
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
      List<String> primaryDiagnoses,
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
      List<String>? dietRestrictions,
      String? department,
      String? roomNumber,
      String? addressLine1,
      String? addressLine2,
      String? city,
      String? state,
      String? zip});
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
    Object? primaryDiagnoses = null,
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
    Object? dietRestrictions = freezed,
    Object? department = freezed,
    Object? roomNumber = freezed,
    Object? addressLine1 = freezed,
    Object? addressLine2 = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? zip = freezed,
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
      primaryDiagnoses: null == primaryDiagnoses
          ? _self.primaryDiagnoses
          : primaryDiagnoses // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
      dietRestrictions: freezed == dietRestrictions
          ? _self.dietRestrictions
          : dietRestrictions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      department: freezed == department
          ? _self.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      roomNumber: freezed == roomNumber
          ? _self.roomNumber
          : roomNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      addressLine1: freezed == addressLine1
          ? _self.addressLine1
          : addressLine1 // ignore: cast_nullable_to_non_nullable
              as String?,
      addressLine2: freezed == addressLine2
          ? _self.addressLine2
          : addressLine2 // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      zip: freezed == zip
          ? _self.zip
          : zip // ignore: cast_nullable_to_non_nullable
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
      final List<String> primaryDiagnoses = const [],
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
      final List<String>? dietRestrictions = const [],
      this.department,
      this.roomNumber,
      this.addressLine1,
      this.addressLine2,
      this.city,
      this.state,
      this.zip})
      : _primaryDiagnoses = primaryDiagnoses,
        _assignedNurses = assignedNurses,
        _allergies = allergies,
        _dietRestrictions = dietRestrictions;
  factory _Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);

// 🆔 Identity & Demographics
  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String? mrn;

  /// 🌍 Type of location the patient is currently in
  /// e.g. "residence", "hospital", "snf", "rehab", "other"
  /// NOTE: Keeping field name as `location` for Firestore compatibility
  @override
  final String location;

  /// 🕐 Admission & visibility timestamps
  @override
  @TimestampConverter()
  final DateTime? admittedAt;
  @override
  @TimestampConverter()
  final DateTime? lastSeen;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? birthDate;
// 🚩 Clinical Risk Flags
  @override
  @JsonKey()
  final bool? isIsolation;
  @override
  @JsonKey()
  final bool isFallRisk;

  /// 💊 Supports multiple diagnoses per patient
  final List<String> _primaryDiagnoses;

  /// 💊 Supports multiple diagnoses per patient
  @override
  @JsonKey()
  List<String> get primaryDiagnoses {
    if (_primaryDiagnoses is EqualUnmodifiableListView)
      return _primaryDiagnoses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_primaryDiagnoses);
  }

  @override
  @RiskLevelConverter()
  final RiskLevel? manualRiskOverride;
  @override
  final String? codeStatus;
// 🧍 Gender, pronouns, language
  @override
  final String? pronouns;
  @override
  @JsonKey()
  final String? biologicalSex;
  @override
  final String? photoUrl;
  @override
  final String? language;
// 👩‍⚕️ Assigned nurses & ownership
  final List<String>? _assignedNurses;
// 👩‍⚕️ Assigned nurses & ownership
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
// 🌿 Medical Notes & Dietary Flags
  final List<String>? _allergies;
// 🌿 Medical Notes & Dietary Flags
  @override
  @JsonKey()
  List<String>? get allergies {
    final value = _allergies;
    if (value == null) return null;
    if (_allergies is EqualUnmodifiableListView) return _allergies;
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

// 🏥 Facility Location Fields (only applies if location != 'residence')
  @override
  final String? department;
// e.g. "ICU", "Med-Surg"
  @override
  final String? roomNumber;
// e.g. "12B"
// 🏡 Structured Address Fields (only if location == 'residence')
  @override
  final String? addressLine1;
// e.g. "123 Main St"
  @override
  final String? addressLine2;
// e.g. "Apt 4B"
  @override
  final String? city;
  @override
  final String? state;
  @override
  final String? zip;

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
            const DeepCollectionEquality()
                .equals(other._primaryDiagnoses, _primaryDiagnoses) &&
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
            const DeepCollectionEquality()
                .equals(other._dietRestrictions, _dietRestrictions) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.roomNumber, roomNumber) ||
                other.roomNumber == roomNumber) &&
            (identical(other.addressLine1, addressLine1) ||
                other.addressLine1 == addressLine1) &&
            (identical(other.addressLine2, addressLine2) ||
                other.addressLine2 == addressLine2) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.zip, zip) || other.zip == zip));
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
        const DeepCollectionEquality().hash(_primaryDiagnoses),
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
        const DeepCollectionEquality().hash(_dietRestrictions),
        department,
        roomNumber,
        addressLine1,
        addressLine2,
        city,
        state,
        zip
      ]);

  @override
  String toString() {
    return 'Patient(id: $id, firstName: $firstName, lastName: $lastName, mrn: $mrn, location: $location, admittedAt: $admittedAt, lastSeen: $lastSeen, createdAt: $createdAt, birthDate: $birthDate, isIsolation: $isIsolation, isFallRisk: $isFallRisk, primaryDiagnoses: $primaryDiagnoses, manualRiskOverride: $manualRiskOverride, codeStatus: $codeStatus, pronouns: $pronouns, biologicalSex: $biologicalSex, photoUrl: $photoUrl, language: $language, assignedNurses: $assignedNurses, ownerUid: $ownerUid, createdBy: $createdBy, allergies: $allergies, dietRestrictions: $dietRestrictions, department: $department, roomNumber: $roomNumber, addressLine1: $addressLine1, addressLine2: $addressLine2, city: $city, state: $state, zip: $zip)';
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
      List<String> primaryDiagnoses,
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
      List<String>? dietRestrictions,
      String? department,
      String? roomNumber,
      String? addressLine1,
      String? addressLine2,
      String? city,
      String? state,
      String? zip});
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
    Object? primaryDiagnoses = null,
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
    Object? dietRestrictions = freezed,
    Object? department = freezed,
    Object? roomNumber = freezed,
    Object? addressLine1 = freezed,
    Object? addressLine2 = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? zip = freezed,
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
      primaryDiagnoses: null == primaryDiagnoses
          ? _self._primaryDiagnoses
          : primaryDiagnoses // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
      dietRestrictions: freezed == dietRestrictions
          ? _self._dietRestrictions
          : dietRestrictions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      department: freezed == department
          ? _self.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      roomNumber: freezed == roomNumber
          ? _self.roomNumber
          : roomNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      addressLine1: freezed == addressLine1
          ? _self.addressLine1
          : addressLine1 // ignore: cast_nullable_to_non_nullable
              as String?,
      addressLine2: freezed == addressLine2
          ? _self.addressLine2
          : addressLine2 // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      zip: freezed == zip
          ? _self.zip
          : zip // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
