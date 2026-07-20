import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:lsf/config/app_config.dart';
import 'package:lsf/services/navigation_service.dart';
import 'http_client.dart';

class ApiService {
  static const String baseUrl = AppConfig.baseUrl;
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );

  // Serializes every secure-storage call. On some devices the plugin's
  // one-time cipher-algorithm migration (delete old Keystore key, generate a
  // new one) can be entered by two concurrent reads at once — e.g. the
  // splash screen's auth check racing SyncService's startup outbox check —
  // and the Android Keystore call for the second one can hang indefinitely
  // instead of erroring. Running all reads/writes through this queue means
  // that migration only ever happens on one call at a time.
  static Future<dynamic> _storageQueue = Future.value();

  static Future<T> _locked<T>(Future<T> Function() action) {
    final result = _storageQueue.then((_) => action());
    // Swallow the error here so a failed call doesn't poison the queue for
    // everything after it — the real error still reaches the caller below.
    _storageQueue = result.then((_) {}, onError: (_) {});
    return result;
  }

  // ── Token / Role storage (encrypted) ────────────────────────────────────

  // Pass [role] if the caller already fetched it — each secure-storage read
  // is a real platform-channel round-trip (slower on some devices, e.g. when
  // the Keystore cipher needs re-initializing), so avoid re-reading 'role'
  // when it's already in hand.
  static Future<String?> getToken({String? role}) => _locked(() async {
        final resolvedRole = role ?? await _storage.read(key: 'role');
        if (resolvedRole != null) {
          final roleToken = await _storage.read(key: '${resolvedRole}_token');
          if (roleToken != null) return roleToken;
        }
        return _storage.read(key: 'token');
      });

  static Future<void> saveToken(String token, {String? role}) => _locked(() async {
        await _storage.write(key: 'token', value: token);
        if (role != null) {
          await _storage.write(key: '${role}_token', value: token);
        }
      });

  static Future<void> clearToken() => _locked(() => _storage.delete(key: 'token'));

  static Future<String?> getRole() => _locked(() => _storage.read(key: 'role'));

  static Future<void> saveRole(String role) =>
      _locked(() => _storage.write(key: 'role', value: role));

  static Future<void> clearRole() => _locked(() => _storage.delete(key: 'role'));

  static Future<void> clearAll() => _locked(() => _storage.deleteAll());

  // ── First-run UI flags ──────────────────────────────────────────────────

  // Not sensitive data, but goes through the same secure storage the rest of
  // this class already uses rather than adding a second storage mechanism
  // (e.g. shared_preferences) just for one boolean.
  static Future<bool> hasSeenNavTour({required String role}) async {
    final value = await _locked(
      () => _storage.read(key: 'seen_nav_tour_$role'),
    );
    return value == 'true';
  }

  static Future<void> markNavTourSeen({required String role}) => _locked(
        () => _storage.write(key: 'seen_nav_tour_$role', value: 'true'),
      );

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

  // File uploads (images/video) go through here instead of postRequest —
  // deliberately a single attempt with no automatic retry, since blindly
  // re-sending a large video on a flaky connection is exactly what we don't
  // want; the idempotency_key still protects against duplicates if the
  // caller retries by hand.
  static Future<http.Response> multipartRequest(
    String endpoint, {
    required Map<String, String> fields,
    File? coverImage,
    List<File>? galleryImages,
    File? video,
    bool auth = true,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/$endpoint'),
    );

    request.headers['Accept'] = 'application/json';
    if (auth) {
      final token = await getToken();
      if (token != null) request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll(fields);
    request.fields.putIfAbsent('idempotency_key', _newIdempotencyKey);

    if (coverImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath('cover_image', coverImage.path),
      );
    }
    if (galleryImages != null) {
      for (final file in galleryImages) {
        request.files.add(
          await http.MultipartFile.fromPath('gallery_images[]', file.path),
        );
      }
    }
    if (video != null) {
      request.files.add(await http.MultipartFile.fromPath('video', video.path));
    }

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 90),
    );
    final response = await http.Response.fromStream(streamedResponse);
    _handleAuthError(response.statusCode);
    return response;
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
