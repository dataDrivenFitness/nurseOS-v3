import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift_model.freezed.dart';
part 'shift_model.g.dart';

@freezed
abstract class ShiftModel with _$ShiftModel {
  const factory ShiftModel({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
    required String location,
    String? assignedTo,
    @Default('available') String status,
    List<String>? requestedBy,
  }) = _ShiftModel;

  factory ShiftModel.fromJson(Map<String, dynamic> json) =>
      _$ShiftModelFromJson(json);
}
