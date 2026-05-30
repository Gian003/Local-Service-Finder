import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lsf/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'http_client.dart';
import 'response_handler.dart';
import 'auth_exception.dart';

class ApiService {
  static const String baseUrl = AppConfig.baseUrl;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    debugPrint('Token saved');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    debugPrint('Token cleared');
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
    debugPrint('Role saved: $role');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
    debugPrint('Role cleared');
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    debugPrint('Token and role cleared');
  }

  static Future<dynamic> getRequest(
    String endpoint, {
    bool auth = false,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (auth) {
        final token = await getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await HttpClient.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      // _handleAuthError(response.statusCode);

      return response;
    } catch (e, st) {
      debugPrint('GET request failed: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  static Future<dynamic> postRequest(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (auth) {
        final token = await getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await HttpClient.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint('URL: $baseUrl/$endpoint');
      debugPrint('Status: ${response.statusCode}');

      // _handleAuthError(response.statusCode);

      return response;
    } catch (e, st) {
      debugPrint('POST request failed: $e');
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  // /// Handle authentication errors (401/403)
  // static void _handleAuthError(int statusCode) {
  //   if (statusCode == 401 || statusCode == 403) {
  //     debugPrint('Auth error detected ($statusCode), clearing credentials');
  //     // clearAll();
  //     // throw AuthException(
  //     //   message: 'Authentication failed. Please login again.',
  //     //   statusCode: statusCode,
  //     // );
  //   }
  // }
}