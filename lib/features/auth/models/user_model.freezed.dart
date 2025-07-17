// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {
// ═══════════════════════════════════════════════════════════════
// Core Identity Fields
// ═══════════════════════════════════════════════════════════════
  String get uid;
  String get firstName;
  String get lastName;
  String get email;
  String? get photoUrl;
  @TimestampConverter()
  DateTime? get createdAt;
  String? get authProvider;
  @UserRoleConverter()
  UserRole
      get role; // ═══════════════════════════════════════════════════════════════
// Healthcare Professional Fields
// ═══════════════════════════════════════════════════════════════
  /// Professional license number (e.g., "RN123456")
  String? get licenseNumber;

  /// License expiration date (important for compliance tracking)
  @TimestampConverter()
  DateTime? get licenseExpiry;

  /// Clinical specialty (e.g., "Critical Care", "Med-Surg", "Emergency")
  String? get specialty;

  /// Department or unit assignment (e.g., "ICU", "Med-Surg Floor 3")
  String? get department;

  /// Legacy unit field - kept for backward compatibility
  /// TODO: Migrate existing data to department field
  String? get unit;

  /// Work shift schedule (e.g., "day", "night", "evening", "rotating")
  String? get shift;

  /// Internal hospital phone extension
  String? get phoneExtension;

  /// Date of hire (used to calculate years of experience)
  @TimestampConverter()
  DateTime? get hireDate;

  /// Professional certifications (e.g., ["BLS", "ACLS", "PALS", "CCRN"])
  List<String>?
      get certifications; // ═══════════════════════════════════════════════════════════════
// Work Status Fields (Updated for Work History)
// ═══════════════════════════════════════════════════════════════
  /// Current duty status (true = on duty, false = off duty, null = unknown)
  bool? get isOnDuty;

  /// Timestamp of last duty status change (for audit and compliance)
  @TimestampConverter()
  DateTime? get lastStatusChange;

  /// Reference to current active work session (if on duty)
  /// Points to: /users/{uid}/workHistory/{sessionId}
  String?
      get currentSessionId; // ═══════════════════════════════════════════════════════════════
// 🏠 INDEPENDENT NURSE SUPPORT FIELDS
// ═══════════════════════════════════════════════════════════════
  /// Indicates if the nurse can operate independently (self-employed)
  /// When true, nurse can create their own shifts and manage patients
  /// When false, nurse works only for agencies (current behavior)
  bool get isIndependentNurse;

  /// Business information for independent practice (optional)
  /// Only populated if isIndependentNurse is true
  /// Example: "Smith Home Care Services"
  String?
      get businessName; // ═══════════════════════════════════════════════════════════════
// Gamification Fields (DEPRECATED - will be moved to GamificationProfile)
// ═══════════════════════════════════════════════════════════════
  /// @deprecated Use GamificationProfile.level instead
  /// Keeping for backward compatibility during migration
  int get level;

  /// @deprecated Use GamificationProfile.totalXp instead
  /// Keeping for backward compatibility during migration
  int get xp;

  /// @deprecated Use GamificationProfile.badges instead
  /// Keeping for backward compatibility during migration
  List<String> get badges;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<UserModel> get copyWith =>
      _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserModel &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.authProvider, authProvider) ||
                other.authProvider == authProvider) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber) &&
            (identical(other.licenseExpiry, licenseExpiry) ||
                other.licenseExpiry == licenseExpiry) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.shift, shift) || other.shift == shift) &&
            (identical(other.phoneExtension, phoneExtension) ||
                other.phoneExtension == phoneExtension) &&
            (identical(other.hireDate, hireDate) ||
                other.hireDate == hireDate) &&
            const DeepCollectionEquality()
                .equals(other.certifications, certifications) &&
            (identical(other.isOnDuty, isOnDuty) ||
                other.isOnDuty == isOnDuty) &&
            (identical(other.lastStatusChange, lastStatusChange) ||
                other.lastStatusChange == lastStatusChange) &&
            (identical(other.currentSessionId, currentSessionId) ||
                other.currentSessionId == currentSessionId) &&
            (identical(other.isIndependentNurse, isIndependentNurse) ||
                other.isIndependentNurse == isIndependentNurse) &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            const DeepCollectionEquality().equals(other.badges, badges));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        uid,
        firstName,
        lastName,
        email,
        photoUrl,
        createdAt,
        authProvider,
        role,
        licenseNumber,
        licenseExpiry,
        specialty,
        department,
        unit,
        shift,
        phoneExtension,
        hireDate,
        const DeepCollectionEquality().hash(certifications),
        isOnDuty,
        lastStatusChange,
        currentSessionId,
        isIndependentNurse,
        businessName,
        level,
        xp,
        const DeepCollectionEquality().hash(badges)
      ]);

  @override
  String toString() {
    return 'UserModel(uid: $uid, firstName: $firstName, lastName: $lastName, email: $email, photoUrl: $photoUrl, createdAt: $createdAt, authProvider: $authProvider, role: $role, licenseNumber: $licenseNumber, licenseExpiry: $licenseExpiry, specialty: $specialty, department: $department, unit: $unit, shift: $shift, phoneExtension: $phoneExtension, hireDate: $hireDate, certifications: $certifications, isOnDuty: $isOnDuty, lastStatusChange: $lastStatusChange, currentSessionId: $currentSessionId, isIndependentNurse: $isIndependentNurse, businessName: $businessName, level: $level, xp: $xp, badges: $badges)';
  }
}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) =
      _$UserModelCopyWithImpl;
  @useResult
  $Res call(
      {String uid,
      String firstName,
      String lastName,
      String email,
      String? photoUrl,
      @TimestampConverter() DateTime? createdAt,
      String? authProvider,
      @UserRoleConverter() UserRole role,
      String? licenseNumber,
      @TimestampConverter() DateTime? licenseExpiry,
      String? specialty,
      String? department,
      String? unit,
      String? shift,
      String? phoneExtension,
      @TimestampConverter() DateTime? hireDate,
      List<String>? certifications,
      bool? isOnDuty,
      @TimestampConverter() DateTime? lastStatusChange,
      String? currentSessionId,
      bool isIndependentNurse,
      String? businessName,
      int level,
      int xp,
      List<String> badges});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res> implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? email = null,
    Object? photoUrl = freezed,
    Object? createdAt = freezed,
    Object? authProvider = freezed,
    Object? role = null,
    Object? licenseNumber = freezed,
    Object? licenseExpiry = freezed,
    Object? specialty = freezed,
    Object? department = freezed,
    Object? unit = freezed,
    Object? shift = freezed,
    Object? phoneExtension = freezed,
    Object? hireDate = freezed,
    Object? certifications = freezed,
    Object? isOnDuty = freezed,
    Object? lastStatusChange = freezed,
    Object? currentSessionId = freezed,
    Object? isIndependentNurse = null,
    Object? businessName = freezed,
    Object? level = null,
    Object? xp = null,
    Object? badges = null,
  }) {
    return _then(_self.copyWith(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _self.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      authProvider: freezed == authProvider
          ? _self.authProvider
          : authProvider // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      licenseNumber: freezed == licenseNumber
          ? _self.licenseNumber
          : licenseNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      licenseExpiry: freezed == licenseExpiry
          ? _self.licenseExpiry
          : licenseExpiry // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      specialty: freezed == specialty
          ? _self.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _self.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      unit: freezed == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      shift: freezed == shift
          ? _self.shift
          : shift // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneExtension: freezed == phoneExtension
          ? _self.phoneExtension
          : phoneExtension // ignore: cast_nullable_to_non_nullable
              as String?,
      hireDate: freezed == hireDate
          ? _self.hireDate
          : hireDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      certifications: freezed == certifications
          ? _self.certifications
          : certifications // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isOnDuty: freezed == isOnDuty
          ? _self.isOnDuty
          : isOnDuty // ignore: cast_nullable_to_non_nullable
              as bool?,
      lastStatusChange: freezed == lastStatusChange
          ? _self.lastStatusChange
          : lastStatusChange // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentSessionId: freezed == currentSessionId
          ? _self.currentSessionId
          : currentSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      isIndependentNurse: null == isIndependentNurse
          ? _self.isIndependentNurse
          : isIndependentNurse // ignore: cast_nullable_to_non_nullable
              as bool,
      businessName: freezed == businessName
          ? _self.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String?,
      level: null == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      xp: null == xp
          ? _self.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int,
      badges: null == badges
          ? _self.badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_UserModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_UserModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_UserModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String uid,
            String firstName,
            String lastName,
            String email,
            String? photoUrl,
            @TimestampConverter() DateTime? createdAt,
            String? authProvider,
            @UserRoleConverter() UserRole role,
            String? licenseNumber,
            @TimestampConverter() DateTime? licenseExpiry,
            String? specialty,
            String? department,
            String? unit,
            String? shift,
            String? phoneExtension,
            @TimestampConverter() DateTime? hireDate,
            List<String>? certifications,
            bool? isOnDuty,
            @TimestampConverter() DateTime? lastStatusChange,
            String? currentSessionId,
            bool isIndependentNurse,
            String? businessName,
            int level,
            int xp,
            List<String> badges)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserModel() when $default != null:
        return $default(
            _that.uid,
            _that.firstName,
            _that.lastName,
            _that.email,
            _that.photoUrl,
            _that.createdAt,
            _that.authProvider,
            _that.role,
            _that.licenseNumber,
            _that.licenseExpiry,
            _that.specialty,
            _that.department,
            _that.unit,
            _that.shift,
            _that.phoneExtension,
            _that.hireDate,
            _that.certifications,
            _that.isOnDuty,
            _that.lastStatusChange,
            _that.currentSessionId,
            _that.isIndependentNurse,
            _that.businessName,
            _that.level,
            _that.xp,
            _that.badges);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String uid,
            String firstName,
            String lastName,
            String email,
            String? photoUrl,
            @TimestampConverter() DateTime? createdAt,
            String? authProvider,
            @UserRoleConverter() UserRole role,
            String? licenseNumber,
            @TimestampConverter() DateTime? licenseExpiry,
            String? specialty,
            String? department,
            String? unit,
            String? shift,
            String? phoneExtension,
            @TimestampConverter() DateTime? hireDate,
            List<String>? certifications,
            bool? isOnDuty,
            @TimestampConverter() DateTime? lastStatusChange,
            String? currentSessionId,
            bool isIndependentNurse,
            String? businessName,
            int level,
            int xp,
            List<String> badges)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserModel():
        return $default(
            _that.uid,
            _that.firstName,
            _that.lastName,
            _that.email,
            _that.photoUrl,
            _that.createdAt,
            _that.authProvider,
            _that.role,
            _that.licenseNumber,
            _that.licenseExpiry,
            _that.specialty,
            _that.department,
            _that.unit,
            _that.shift,
            _that.phoneExtension,
            _that.hireDate,
            _that.certifications,
            _that.isOnDuty,
            _that.lastStatusChange,
            _that.currentSessionId,
            _that.isIndependentNurse,
            _that.businessName,
            _that.level,
            _that.xp,
            _that.badges);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String uid,
            String firstName,
            String lastName,
            String email,
            String? photoUrl,
            @TimestampConverter() DateTime? createdAt,
            String? authProvider,
            @UserRoleConverter() UserRole role,
            String? licenseNumber,
            @TimestampConverter() DateTime? licenseExpiry,
            String? specialty,
            String? department,
            String? unit,
            String? shift,
            String? phoneExtension,
            @TimestampConverter() DateTime? hireDate,
            List<String>? certifications,
            bool? isOnDuty,
            @TimestampConverter() DateTime? lastStatusChange,
            String? currentSessionId,
            bool isIndependentNurse,
            String? businessName,
            int level,
            int xp,
            List<String> badges)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserModel() when $default != null:
        return $default(
            _that.uid,
            _that.firstName,
            _that.lastName,
            _that.email,
            _that.photoUrl,
            _that.createdAt,
            _that.authProvider,
            _that.role,
            _that.licenseNumber,
            _that.licenseExpiry,
            _that.specialty,
            _that.department,
            _that.unit,
            _that.shift,
            _that.phoneExtension,
            _that.hireDate,
            _that.certifications,
            _that.isOnDuty,
            _that.lastStatusChange,
            _that.currentSessionId,
            _that.isIndependentNurse,
            _that.businessName,
            _that.level,
            _that.xp,
            _that.badges);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _UserModel implements UserModel {
  const _UserModel(
      {required this.uid,
      required this.firstName,
      required this.lastName,
      required this.email,
      this.photoUrl,
      @TimestampConverter() this.createdAt,
      this.authProvider,
      @UserRoleConverter() required this.role,
      this.licenseNumber,
      @TimestampConverter() this.licenseExpiry,
      this.specialty,
      this.department,
      this.unit,
      this.shift,
      this.phoneExtension,
      @TimestampConverter() this.hireDate,
      final List<String>? certifications,
      this.isOnDuty,
      @TimestampConverter() this.lastStatusChange,
      this.currentSessionId,
      this.isIndependentNurse = false,
      this.businessName,
      this.level = 1,
      this.xp = 0,
      final List<String> badges = const []})
      : _certifications = certifications,
        _badges = badges;
  factory _UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

// ═══════════════════════════════════════════════════════════════
// Core Identity Fields
// ═══════════════════════════════════════════════════════════════
  @override
  final String uid;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String email;
  @override
  final String? photoUrl;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  final String? authProvider;
  @override
  @UserRoleConverter()
  final UserRole role;
// ═══════════════════════════════════════════════════════════════
// Healthcare Professional Fields
// ═══════════════════════════════════════════════════════════════
  /// Professional license number (e.g., "RN123456")
  @override
  final String? licenseNumber;

  /// License expiration date (important for compliance tracking)
  @override
  @TimestampConverter()
  final DateTime? licenseExpiry;

  /// Clinical specialty (e.g., "Critical Care", "Med-Surg", "Emergency")
  @override
  final String? specialty;

  /// Department or unit assignment (e.g., "ICU", "Med-Surg Floor 3")
  @override
  final String? department;

  /// Legacy unit field - kept for backward compatibility
  /// TODO: Migrate existing data to department field
  @override
  final String? unit;

  /// Work shift schedule (e.g., "day", "night", "evening", "rotating")
  @override
  final String? shift;

  /// Internal hospital phone extension
  @override
  final String? phoneExtension;

  /// Date of hire (used to calculate years of experience)
  @override
  @TimestampConverter()
  final DateTime? hireDate;

  /// Professional certifications (e.g., ["BLS", "ACLS", "PALS", "CCRN"])
  final List<String>? _certifications;

  /// Professional certifications (e.g., ["BLS", "ACLS", "PALS", "CCRN"])
  @override
  List<String>? get certifications {
    final value = _certifications;
    if (value == null) return null;
    if (_certifications is EqualUnmodifiableListView) return _certifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// ═══════════════════════════════════════════════════════════════
// Work Status Fields (Updated for Work History)
// ═══════════════════════════════════════════════════════════════
  /// Current duty status (true = on duty, false = off duty, null = unknown)
  @override
  final bool? isOnDuty;

  /// Timestamp of last duty status change (for audit and compliance)
  @override
  @TimestampConverter()
  final DateTime? lastStatusChange;

  /// Reference to current active work session (if on duty)
  /// Points to: /users/{uid}/workHistory/{sessionId}
  @override
  final String? currentSessionId;
// ═══════════════════════════════════════════════════════════════
// 🏠 INDEPENDENT NURSE SUPPORT FIELDS
// ═══════════════════════════════════════════════════════════════
  /// Indicates if the nurse can operate independently (self-employed)
  /// When true, nurse can create their own shifts and manage patients
  /// When false, nurse works only for agencies (current behavior)
  @override
  @JsonKey()
  final bool isIndependentNurse;

  /// Business information for independent practice (optional)
  /// Only populated if isIndependentNurse is true
  /// Example: "Smith Home Care Services"
  @override
  final String? businessName;
// ═══════════════════════════════════════════════════════════════
// Gamification Fields (DEPRECATED - will be moved to GamificationProfile)
// ═══════════════════════════════════════════════════════════════
  /// @deprecated Use GamificationProfile.level instead
  /// Keeping for backward compatibility during migration
  @override
  @JsonKey()
  final int level;

  /// @deprecated Use GamificationProfile.totalXp instead
  /// Keeping for backward compatibility during migration
  @override
  @JsonKey()
  final int xp;

  /// @deprecated Use GamificationProfile.badges instead
  /// Keeping for backward compatibility during migration
  final List<String> _badges;

  /// @deprecated Use GamificationProfile.badges instead
  /// Keeping for backward compatibility during migration
  @override
  @JsonKey()
  List<String> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserModelCopyWith<_UserModel> get copyWith =>
      __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserModel &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.authProvider, authProvider) ||
                other.authProvider == authProvider) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber) &&
            (identical(other.licenseExpiry, licenseExpiry) ||
                other.licenseExpiry == licenseExpiry) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.shift, shift) || other.shift == shift) &&
            (identical(other.phoneExtension, phoneExtension) ||
                other.phoneExtension == phoneExtension) &&
            (identical(other.hireDate, hireDate) ||
                other.hireDate == hireDate) &&
            const DeepCollectionEquality()
                .equals(other._certifications, _certifications) &&
            (identical(other.isOnDuty, isOnDuty) ||
                other.isOnDuty == isOnDuty) &&
            (identical(other.lastStatusChange, lastStatusChange) ||
                other.lastStatusChange == lastStatusChange) &&
            (identical(other.currentSessionId, currentSessionId) ||
                other.currentSessionId == currentSessionId) &&
            (identical(other.isIndependentNurse, isIndependentNurse) ||
                other.isIndependentNurse == isIndependentNurse) &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.xp, xp) || other.xp == xp) &&
            const DeepCollectionEquality().equals(other._badges, _badges));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        uid,
        firstName,
        lastName,
        email,
        photoUrl,
        createdAt,
        authProvider,
        role,
        licenseNumber,
        licenseExpiry,
        specialty,
        department,
        unit,
        shift,
        phoneExtension,
        hireDate,
        const DeepCollectionEquality().hash(_certifications),
        isOnDuty,
        lastStatusChange,
        currentSessionId,
        isIndependentNurse,
        businessName,
        level,
        xp,
        const DeepCollectionEquality().hash(_badges)
      ]);

  @override
  String toString() {
    return 'UserModel(uid: $uid, firstName: $firstName, lastName: $lastName, email: $email, photoUrl: $photoUrl, createdAt: $createdAt, authProvider: $authProvider, role: $role, licenseNumber: $licenseNumber, licenseExpiry: $licenseExpiry, specialty: $specialty, department: $department, unit: $unit, shift: $shift, phoneExtension: $phoneExtension, hireDate: $hireDate, certifications: $certifications, isOnDuty: $isOnDuty, lastStatusChange: $lastStatusChange, currentSessionId: $currentSessionId, isIndependentNurse: $isIndependentNurse, businessName: $businessName, level: $level, xp: $xp, badges: $badges)';
  }
}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(
          _UserModel value, $Res Function(_UserModel) _then) =
      __$UserModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String uid,
      String firstName,
      String lastName,
      String email,
      String? photoUrl,
      @TimestampConverter() DateTime? createdAt,
      String? authProvider,
      @UserRoleConverter() UserRole role,
      String? licenseNumber,
      @TimestampConverter() DateTime? licenseExpiry,
      String? specialty,
      String? department,
      String? unit,
      String? shift,
      String? phoneExtension,
      @TimestampConverter() DateTime? hireDate,
      List<String>? certifications,
      bool? isOnDuty,
      @TimestampConverter() DateTime? lastStatusChange,
      String? currentSessionId,
      bool isIndependentNurse,
      String? businessName,
      int level,
      int xp,
      List<String> badges});
}

/// @nodoc
class __$UserModelCopyWithImpl<$Res> implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? uid = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? email = null,
    Object? photoUrl = freezed,
    Object? createdAt = freezed,
    Object? authProvider = freezed,
    Object? role = null,
    Object? licenseNumber = freezed,
    Object? licenseExpiry = freezed,
    Object? specialty = freezed,
    Object? department = freezed,
    Object? unit = freezed,
    Object? shift = freezed,
    Object? phoneExtension = freezed,
    Object? hireDate = freezed,
    Object? certifications = freezed,
    Object? isOnDuty = freezed,
    Object? lastStatusChange = freezed,
    Object? currentSessionId = freezed,
    Object? isIndependentNurse = null,
    Object? businessName = freezed,
    Object? level = null,
    Object? xp = null,
    Object? badges = null,
  }) {
    return _then(_UserModel(
      uid: null == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: freezed == photoUrl
          ? _self.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      authProvider: freezed == authProvider
          ? _self.authProvider
          : authProvider // ignore: cast_nullable_to_non_nullable
              as String?,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      licenseNumber: freezed == licenseNumber
          ? _self.licenseNumber
          : licenseNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      licenseExpiry: freezed == licenseExpiry
          ? _self.licenseExpiry
          : licenseExpiry // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      specialty: freezed == specialty
          ? _self.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String?,
      department: freezed == department
          ? _self.department
          : department // ignore: cast_nullable_to_non_nullable
              as String?,
      unit: freezed == unit
          ? _self.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      shift: freezed == shift
          ? _self.shift
          : shift // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneExtension: freezed == phoneExtension
          ? _self.phoneExtension
          : phoneExtension // ignore: cast_nullable_to_non_nullable
              as String?,
      hireDate: freezed == hireDate
          ? _self.hireDate
          : hireDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      certifications: freezed == certifications
          ? _self._certifications
          : certifications // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isOnDuty: freezed == isOnDuty
          ? _self.isOnDuty
          : isOnDuty // ignore: cast_nullable_to_non_nullable
              as bool?,
      lastStatusChange: freezed == lastStatusChange
          ? _self.lastStatusChange
          : lastStatusChange // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentSessionId: freezed == currentSessionId
          ? _self.currentSessionId
          : currentSessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      isIndependentNurse: null == isIndependentNurse
          ? _self.isIndependentNurse
          : isIndependentNurse // ignore: cast_nullable_to_non_nullable
              as bool,
      businessName: freezed == businessName
          ? _self.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String?,
      level: null == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      xp: null == xp
          ? _self.xp
          : xp // ignore: cast_nullable_to_non_nullable
              as int,
      badges: null == badges
          ? _self._badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
