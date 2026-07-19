import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _apiUrlKey = 'api_url';

  // URL untuk Android Emulator (10.0.2.2 adalah localhost komputer host dari emulator)
  static const String androidEmulatorUrl = 'http://10.0.2.2:3000';
  // URL untuk HP/Tablet fisik Android (sesuaikan dengan IP lokal laptop Anda jika tidak menggunakan adb reverse)
  static const String androidPhysicalUrl = 'http://192.168.1.84:3000';
  // URL untuk iOS simulator, desktop, dan koneksi adb reverse
  static const String _localUrl = 'http://localhost:3000';

  static String get defaultApiBaseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      // Menggunakan 10.0.2.2 agar otomatis terhubung ke localhost komputer host dari emulator.
      // Jika Anda memakai kabel USB (adb reverse), Anda bisa mengubahnya lewat pengaturan (ikon gerigi) di pojok kanan atas login screen.
      return androidEmulatorUrl;
    }
    return _localUrl;
  }

  static Future<String> getApiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_apiUrlKey);
    if (saved != null && saved.isNotEmpty) return saved;
    return defaultApiBaseUrl;
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
