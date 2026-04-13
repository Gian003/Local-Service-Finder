import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:lsffend/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = AppConfig.baseUrl;

  //Get Stored Token
  static Future<String?> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString('token');
  }

  //Save Token
  static Future<void> saveToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('token', token);
  }

  //Clear Token on logout
  static Future<void> clearToken() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('token');
  }

  //Get Request
  static Future<dynamic> getRequest(
    String endpoint, {
    bool auth = false,
  }) async {
    final headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await getToken();
      headers['Authorization'] = 'Bearer $token';
    }

    return await http.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);
  }

  //Post Request
  static Future<dynamic> postRequest(
    String endpoint,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await getToken();
      headers['Authorization'] = 'Bearer $token';
    }

    final result = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );

    debugPrint('URL: $baseUrl/$endpoint');
    debugPrint('Headers: $headers');
    debugPrint('Body: ${jsonEncode(body)})');
    debugPrint('Status Code: ${result.statusCode}');
    debugPrint('Response Body: ${result.body}');

    return result;
  }

  //Save Role
  static Future<void> saveRole(String role) async {
    final preference = await SharedPreferences.getInstance();
    await preference.setString('role', role);
  }

  //Get Role
  static Future<String?> getRole() async {
    final preference = await SharedPreferences.getInstance();
    return preference.getString('role');
  }

  //Clear Role on Logout
  static Future<void> clearRole() async {
    final preference = await SharedPreferences.getInstance();
    await preference.remove('token');
    await preference.remove('role');
  }
}
