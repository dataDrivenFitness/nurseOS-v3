import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'agency_model.freezed.dart';
part 'agency_model.g.dart';

@freezed
abstract class AgencyModel with _$AgencyModel {
  const factory AgencyModel({
    required String id,
    required String name,
    String? logoUrl,
    @Default(true) bool isActive,
    @Default([]) List<String> tags, // e.g., ['hospital', 'SNF']
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
    String? createdBy, // uid of org creator/admin
  }) = _AgencyModel;

  const AgencyModel._();

  factory AgencyModel.fromJson(Map<String, dynamic> json) =>
      _$AgencyModelFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime?, Timestamp?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Timestamp? ts) => ts?.toDate();

  @override
  Timestamp? toJson(DateTime? dt) => dt == null ? null : Timestamp.fromDate(dt);
}

// Firestore converter
final agencyModelConverter = FirebaseFirestore.instance
    .collection('agencies')
    .withConverter<AgencyModel>(
      fromFirestore: (snap, _) =>
          AgencyModel.fromJson(snap.data()!..['id'] = snap.id),
      toFirestore: (agency, _) => agency.toJson(),
    );
