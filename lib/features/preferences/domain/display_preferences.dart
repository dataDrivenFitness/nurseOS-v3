import 'package:freezed_annotation/freezed_annotation.dart';
import 'patient_display_option.dart';
import 'package:collection/collection.dart';

part 'display_preferences.freezed.dart';

@freezed
abstract class DisplayPreferences with _$DisplayPreferences {
  const factory DisplayPreferences({
    @Default([]) List<PatientDisplayOption> enabled,
  }) = _DisplayPreferences;

  const DisplayPreferences._(); // Needed for custom getters

  /// Default display configuration used on first login or when no prefs exist
  factory DisplayPreferences.defaults() => const DisplayPreferences(
        enabled: [
          PatientDisplayOption.codeStatus,
          PatientDisplayOption.allergies,
        ],
      );

  /// Manual deserialization with safe fallback
  factory DisplayPreferences.fromJson(Map<String, dynamic> json) {
    final raw = (json['enabled'] as List?) ?? [];
    final enabled = raw
        .map((e) => PatientDisplayOption.values
            .firstWhereOrNull((opt) => opt.name == e))
        .whereType<PatientDisplayOption>()
        .toList();

    return DisplayPreferences(enabled: enabled);
  }

  /// Manual serialization
  Map<String, dynamic> toJson() => {
        'enabled': enabled.map((e) => e.name).toList(),
      };

  /// Shortcut getter to expose enabled options
  List<PatientDisplayOption> get options => enabled;

  /// Toggle utility used in controller
  DisplayPreferences toggle(PatientDisplayOption option) {
    return enabled.contains(option)
        ? copyWith(enabled: enabled.where((e) => e != option).toList())
        : copyWith(enabled: [...enabled, option]);
  }
}
