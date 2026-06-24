import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _apiUrlKey = 'api_url';

  // Default API base URL (cPanel production path)
  static const String defaultApiBaseUrl = 'https://nlab-sangihe.web.bps.go.id/backend-form';

  static Future<String> getApiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String url = prefs.getString(_apiUrlKey) ?? defaultApiBaseUrl;
    if (url.startsWith('http://nlab-sangihe.web.bps.go.id')) {
      url = url.replaceFirst('http://', 'https://');
    }
    return url;
  }

  static Future<void> setApiBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrlKey, url);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        return json.decode(userJson) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error decoding user: $e');
      }
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final baseUrl = await getApiBaseUrl();
      final url = Uri.parse('$baseUrl/api/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      dynamic responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        return {
          'success': false,
          'error': 'Server error (${response.statusCode}): Pastikan kode backend cPanel Anda sudah di-upload, di-build, dan di-restart.'
        };
      }

      if (response.statusCode == 200) {
        final token = responseData['token'] as String;
        final user = responseData['user'] as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, json.encode(user));

        return {'success': true, 'token': token, 'user': user};
      } else {
        final errorMsg = responseData['error'] ?? 'Login failed';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String desa,
    required String kecamatan,
    required String kabupaten,
  }) async {
    try {
      final baseUrl = await getApiBaseUrl();
      final url = Uri.parse('$baseUrl/api/auth/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'desa': desa,
          'kecamatan': kecamatan,
          'kabupaten': kabupaten,
        }),
      );

      dynamic responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        return {
          'success': false,
          'error': 'Server error (${response.statusCode}): Pastikan kode backend cPanel Anda sudah di-upload, di-build, dan di-restart.'
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        final errorMsg = responseData['error'] ?? 'Registration failed';
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      return {'success': false, 'error': 'Connection error: $e'};
    }
  }
}
