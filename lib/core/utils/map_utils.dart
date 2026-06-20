import 'package:cloud_firestore/cloud_firestore.dart';

abstract final class MapUtils {
  static DateTime? dateTimeFromValue(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static List<String> stringListFromValue(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }

    return const [];
  }

  static List<Map<String, dynamic>> mapListFromValue(Object? value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    return const [];
  }

  static Map<String, dynamic> stringMapFromValue(Object? value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return const {};
  }

  static Map<String, dynamic> jsonReady(Map<String, dynamic> map) {
    return map.map((key, value) => MapEntry(key, _jsonReadyValue(value)));
  }

  static Object? _jsonReadyValue(Object? value) {
    if (value is DateTime) {
      return value.toIso8601String();
    }

    if (value is List) {
      return value.map(_jsonReadyValue).toList(growable: false);
    }

    if (value is Map) {
      return value.map(
        (key, mapValue) => MapEntry(key.toString(), _jsonReadyValue(mapValue)),
      );
    }

    return value;
  }
}
