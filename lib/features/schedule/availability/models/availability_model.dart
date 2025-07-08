import 'package:freezed_annotation/freezed_annotation.dart';

part 'availability_model.freezed.dart';
part 'availability_model.g.dart';

@freezed
abstract class AvailabilityModel with _$AvailabilityModel {
  const factory AvailabilityModel({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) = _AvailabilityModel;

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityModelFromJson(json);
}
