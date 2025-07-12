// 📁 lib/features/agency/models/agency_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/converters/timestamp_converter.dart';

part 'agency_model.freezed.dart';
part 'agency_model.g.dart';

/// Agency types supported by NurseOS
enum AgencyType {
  @JsonValue('hospital')
  hospital,
  @JsonValue('snf')
  snf,
  @JsonValue('home_health')
  homeHealth,
  @JsonValue('agency')
  agency,
  @JsonValue('clinic')
  clinic,
  @JsonValue('other')
  other,
}

@freezed
abstract class AgencyModel with _$AgencyModel {
  const factory AgencyModel({
    required String id,
    required String name,
    @Default(AgencyType.other) AgencyType type,
    String? logoUrl,
    String? address,
    String? phone,
    String? email,
    @Default(true) bool isActive,
    @Default([])
    List<String> tags, // Legacy support - kept for backward compatibility
    @Default({}) Map<String, dynamic> settings, // Agency-specific configuration
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    String? createdBy, // uid of org creator/admin
  }) = _AgencyModel;

  const AgencyModel._();

  factory AgencyModel.fromJson(Map<String, dynamic> json) =>
      _$AgencyModelFromJson(json);

  /// Display name for agency type
  String get typeDisplayName {
    switch (type) {
      case AgencyType.hospital:
        return 'Hospital';
      case AgencyType.snf:
        return 'Skilled Nursing Facility';
      case AgencyType.homeHealth:
        return 'Home Health Agency';
      case AgencyType.agency:
        return 'Staffing Agency';
      case AgencyType.clinic:
        return 'Clinic';
      case AgencyType.other:
        return 'Other';
    }
  }

  /// Check if agency requires address for operations
  bool get requiresAddress {
    return type == AgencyType.homeHealth || type == AgencyType.clinic;
  }

  /// Check if agency supports shift scheduling
  bool get supportsScheduling {
    return type != AgencyType.other;
  }

  /// Get agency-specific settings with type safety
  T? getSetting<T>(String key) {
    final value = settings[key];
    return value is T ? value : null;
  }

  /// Create agency with default settings based on type
  AgencyModel withDefaultSettings() {
    final defaultSettings = <String, dynamic>{
      'allowCrossAgencyScheduling': false,
      'requireLocationVerification': requiresAddress,
      'enableTaskManagement': true,
      'gamificationEnabled': true,
      ...settings, // Preserve existing settings
    };

    // Add type-specific defaults
    switch (type) {
      case AgencyType.hospital:
        defaultSettings.addAll({
          'shiftDurationHours': 12,
          'breakDurationMinutes': 30,
          'overtimeThresholdHours': 40,
        });
        break;
      case AgencyType.homeHealth:
        defaultSettings.addAll({
          'travelTimeIncluded': true,
          'mileageTracking': true,
          'addressVerificationRequired': true,
        });
        break;
      case AgencyType.snf:
        defaultSettings.addAll({
          'shiftDurationHours': 8,
          'longTermCareMode': true,
          'medicationManagement': true,
        });
        break;
      case AgencyType.agency:
        defaultSettings.addAll({
          'multiClientSupport': true,
          'rateDifferentials': true,
          'flexibleScheduling': true,
        });
        break;
      default:
        break;
    }

    return copyWith(settings: defaultSettings);
  }
}

/// Firestore converter
final agencyModelConverter = FirebaseFirestore.instance
    .collection('agencies')
    .withConverter<AgencyModel>(
      fromFirestore: (snap, _) =>
          AgencyModel.fromJson(snap.data()!..['id'] = snap.id),
      toFirestore: (agency, _) {
        final json = agency.toJson();
        json.remove('id'); // Remove ID from document data
        return json;
      },
    );
