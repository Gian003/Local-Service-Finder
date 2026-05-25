import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lsf/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = AppConfig.baseUrl;

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    debugPrint('✅ Token saved: $token');
  }

  // Only removes token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    debugPrint('✅ Token cleared');
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
    debugPrint('✅ Role saved: $role');
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  // Only removes role — NOT token!
  static Future<void> clearRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');
    debugPrint('✅ Role cleared');
  }

  // Clear both token and role together
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    debugPrint('✅ Token and role cleared');
  }

  static Future<dynamic> getRequest(
    String endpoint, {
    bool auth = false,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept':       'application/json',
    };

    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
  }

  static Future<dynamic> postRequest(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept':       'application/json',
    };

    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final result = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    debugPrint('URL: $baseUrl/$endpoint');
    debugPrint('Status: ${result.statusCode}');
    debugPrint('Response: ${result.body}');

    return result;
  }
}