import 'package:flutter/foundation.dart';

/// Safely converts various types to target types
class TypeConverter {
  /// Safely convert to double
  static double toDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? defaultValue;
    }
    debugPrint('⚠️ Cannot convert $value (${value.runtimeType}) to double');
    return defaultValue;
  }

  /// Safely convert to int
  static int toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? defaultValue;
    }
    debugPrint('⚠️ Cannot convert $value (${value.runtimeType}) to int');
    return defaultValue;
  }

  /// Safely convert to string
  static String toString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  /// Safely convert to bool
  static bool toBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'yes';
    }
    if (value is int) return value != 0;
    debugPrint('⚠️ Cannot convert $value (${value.runtimeType}) to bool');
    return defaultValue;
  }

  /// Parse datetime from string (supports multiple formats)
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    final str = value.toString().trim();
    if (str.isEmpty) return null;

    try {
      // Try ISO8601 first
      return DateTime.parse(str);
    } catch (_) {
      // Try other common formats
      try {
        // Try YYYY-MM-DD HH:mm:ss
        return DateTime.parse(str.replaceAll(' ', 'T'));
      } catch (_) {
        debugPrint('⚠️ Cannot parse datetime: $str');
        return null;
      }
    }
  }

  /// Extract date part from datetime string (YYYY-MM-DD)
  static String extractDate(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;

    final str = value.toString().trim();
    if (str.isEmpty) return defaultValue;

    try {
      final dateTime = parseDateTime(str);
      if (dateTime != null) {
        return dateTime.toString().split(' ')[0];
      }
    } catch (_) {}

    // Try direct split as fallback
    if (str.contains(' ')) {
      return str.split(' ')[0];
    }

    return defaultValue;
  }

  /// Extract time part from datetime string (HH:mm:ss)
  static String extractTime(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;

    final str = value.toString().trim();
    if (str.isEmpty) return defaultValue;

    try {
      final dateTime = parseDateTime(str);
      if (dateTime != null) {
        final time = dateTime.toString().split(' ')[1];
        return time.substring(0, 8); // HH:mm:ss
      }
    } catch (_) {}

    // Try direct split as fallback
    if (str.contains(' ')) {
      return str.split(' ')[1];
    }

    return defaultValue;
  }

  /// Safely convert list of maps (JSON array to objects)
  static List<Map<String, dynamic>> toMapList(
    dynamic value, {
    List<Map<String, dynamic>> defaultValue = const [],
  }) {
    if (value == null) return defaultValue;
    if (value is List) {
      try {
        return value
            .whereType<Map<String, dynamic>>()
            .toList();
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  /// Safely convert list of strings
  static List<String> toStringList(
    dynamic value, {
    List<String> defaultValue = const [],
  }) {
    if (value == null) return defaultValue;
    if (value is List) {
      try {
        return value.map((e) => e.toString()).toList();
      } catch (_) {
        return defaultValue;
      }
    }
    return defaultValue;
  }
}
