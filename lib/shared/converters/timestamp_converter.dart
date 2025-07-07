import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';

class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;

    if (json is Timestamp) {
      try {
        return json.toDate();
      } catch (e) {
        debugPrint('⚠️ Failed to convert Timestamp to DateTime: $e');
        return null;
      }
    }

    if (json is String) {
      try {
        return DateTime.parse(json);
      } catch (e) {
        debugPrint('⚠️ Failed to parse DateTime from string: $json');
        return null;
      }
    }

    if (json is DateTime) return json;

    debugPrint('⚠️ Unknown DateTime format: ${json.runtimeType} - $json');
    return null;
  }

  @override
  Object? toJson(DateTime? date) {
    if (date == null) return null;
    // Return as Timestamp for Firestore compatibility
    return Timestamp.fromDate(date);
  }
}
