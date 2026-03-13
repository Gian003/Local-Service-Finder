import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

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
    final headers = {'Content-type': 'application/json'};

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
    final headers = {'Content-type': 'application/json'};

    if (auth) {
      final token = await getToken();
      headers['Authorization'] = 'Bearer $token';
    }

    return await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}
