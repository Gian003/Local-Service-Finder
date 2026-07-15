import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lsf/config/app_config.dart';
import 'package:lsf/services/navigation_service.dart';
import 'http_client.dart';

class ApiService {
  static const String baseUrl = AppConfig.baseUrl;
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  // ── Token / Role storage (encrypted) ────────────────────────────────────

  static Future<String?> getToken() async {
    final role = await getRole();
    if (role != null) {
      final roleToken = await _storage.read(key: '${role}_token');
      if (roleToken != null) return roleToken;
    }
    return _storage.read(key: 'token');
  }

  static Future<void> saveToken(String token, {String? role}) async {
    await _storage.write(key: 'token', value: token);
    if (role != null) {
      await _storage.write(key: '${role}_token', value: token);
    }
  }

  static Future<void> clearToken() => _storage.delete(key: 'token');

  static Future<String?> getRole() => _storage.read(key: 'role');

  static Future<void> saveRole(String role) =>
      _storage.write(key: 'role', value: role);

  static Future<void> clearRole() => _storage.delete(key: 'role');

  static Future<void> clearAll() => _storage.deleteAll();

  // ── Internal helpers ─────────────────────────────────────────────────────

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  static void _handleAuthError(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      clearAll();
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  // ── HTTP methods ─────────────────────────────────────────────────────────

  static Future<dynamic> getRequest(
    String endpoint, {
    bool auth = false,
  }) async {
    try {
      final response = await HttpClient.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _headers(auth: auth),
      );
      _handleAuthError(response.statusCode);
      return response;
    } catch (e, st) {
      debugPrint('GET $endpoint failed: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  // Every POST carries an idempotency_key so a lost response + automatic
  // retry (see HttpClient) can't duplicate the side effect server-side.
  // Callers that already manage their own key (e.g. BookingService.confirmBooking)
  // are left untouched — this only fills the field in if it's absent.
  static String _newIdempotencyKey() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';

  static Future<dynamic> postRequest(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final requestBody = Map<String, dynamic>.from(body);
    requestBody.putIfAbsent('idempotency_key', _newIdempotencyKey);

    try {
      final response = await HttpClient.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _headers(auth: auth),
        body: jsonEncode(requestBody),
      );
      _handleAuthError(response.statusCode);
      return response;
    } catch (e, st) {
      debugPrint('POST $endpoint failed: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  static Future<dynamic> putRequest(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    try {
      final response = await HttpClient.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      );
      _handleAuthError(response.statusCode);
      return response;
    } catch (e, st) {
      debugPrint('PUT $endpoint failed: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  static Future<dynamic> deleteRequest(
    String endpoint, {
    bool auth = false,
  }) async {
    try {
      final response = await HttpClient.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: await _headers(auth: auth),
      );
      _handleAuthError(response.statusCode);
      return response;
    } catch (e, st) {
      debugPrint('DELETE $endpoint failed: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }
}
