// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'display_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DisplayPreferences {
  List<PatientDisplayOption> get enabled;

  /// Create a copy of DisplayPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DisplayPreferencesCopyWith<DisplayPreferences> get copyWith =>
      _$DisplayPreferencesCopyWithImpl<DisplayPreferences>(
          this as DisplayPreferences, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DisplayPreferences &&
            const DeepCollectionEquality().equals(other.enabled, enabled));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(enabled));

  @override
  String toString() {
    return 'DisplayPreferences(enabled: $enabled)';
  }
}

/// @nodoc
abstract mixin class $DisplayPreferencesCopyWith<$Res> {
  factory $DisplayPreferencesCopyWith(
          DisplayPreferences value, $Res Function(DisplayPreferences) _then) =
      _$DisplayPreferencesCopyWithImpl;
  @useResult
  $Res call({List<PatientDisplayOption> enabled});
}

/// @nodoc
class _$DisplayPreferencesCopyWithImpl<$Res>
    implements $DisplayPreferencesCopyWith<$Res> {
  _$DisplayPreferencesCopyWithImpl(this._self, this._then);

  final DisplayPreferences _self;
  final $Res Function(DisplayPreferences) _then;

  /// Create a copy of DisplayPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enabled = null,
  }) {
    return _then(_self.copyWith(
      enabled: null == enabled
          ? _self.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as List<PatientDisplayOption>,
    ));
  }
}

/// Adds pattern-matching-related methods to [DisplayPreferences].
extension DisplayPreferencesPatterns on DisplayPreferences {
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
    TResult Function(_DisplayPreferences value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DisplayPreferences() when $default != null:
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
    TResult Function(_DisplayPreferences value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DisplayPreferences():
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
    TResult? Function(_DisplayPreferences value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DisplayPreferences() when $default != null:
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
    TResult Function(List<PatientDisplayOption> enabled)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DisplayPreferences() when $default != null:
        return $default(_that.enabled);
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
    TResult Function(List<PatientDisplayOption> enabled) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DisplayPreferences():
        return $default(_that.enabled);
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
    TResult? Function(List<PatientDisplayOption> enabled)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DisplayPreferences() when $default != null:
        return $default(_that.enabled);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DisplayPreferences extends DisplayPreferences {
  const _DisplayPreferences(
      {final List<PatientDisplayOption> enabled = const []})
      : _enabled = enabled,
        super._();

  final List<PatientDisplayOption> _enabled;
  @override
  @JsonKey()
  List<PatientDisplayOption> get enabled {
    if (_enabled is EqualUnmodifiableListView) return _enabled;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_enabled);
  }

  /// Create a copy of DisplayPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DisplayPreferencesCopyWith<_DisplayPreferences> get copyWith =>
      __$DisplayPreferencesCopyWithImpl<_DisplayPreferences>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DisplayPreferences &&
            const DeepCollectionEquality().equals(other._enabled, _enabled));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_enabled));

  @override
  String toString() {
    return 'DisplayPreferences(enabled: $enabled)';
  }
}

/// @nodoc
abstract mixin class _$DisplayPreferencesCopyWith<$Res>
    implements $DisplayPreferencesCopyWith<$Res> {
  factory _$DisplayPreferencesCopyWith(
          _DisplayPreferences value, $Res Function(_DisplayPreferences) _then) =
      __$DisplayPreferencesCopyWithImpl;
  @override
  @useResult
  $Res call({List<PatientDisplayOption> enabled});
}

/// @nodoc
class __$DisplayPreferencesCopyWithImpl<$Res>
    implements _$DisplayPreferencesCopyWith<$Res> {
  __$DisplayPreferencesCopyWithImpl(this._self, this._then);

  final _DisplayPreferences _self;
  final $Res Function(_DisplayPreferences) _then;

  /// Create a copy of DisplayPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? enabled = null,
  }) {
    return _then(_DisplayPreferences(
      enabled: null == enabled
          ? _self._enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as List<PatientDisplayOption>,
    ));
  }
}

// dart format on
