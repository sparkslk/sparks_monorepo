import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://192.168.1.231:3000';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Login with email and password (MOBILE API)
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/api/auth/mobile/credentials');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['accessToken'] != null) {
        // Save JWT as 'jwt_token' for consistency
        await _storage.write(
          key: 'jwt_token',
          value: data['accessToken'].toString(),
        );
        await _saveUser(data['user']);
        return {
          'success': true,
          'token': data['accessToken'],
          'user': data['user'],
        };
      } else {
        return {'success': false, 'message': data['error'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Login error: $e'};
    }
  }

  // Google Sign-In (MOBILE API)
  static Future<Map<String, dynamic>> googleSignIn(String googleIdToken) async {
    try {
      final uri = Uri.parse('$baseUrl/api/mobile/auth/google');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({'idToken': googleIdToken}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        await _saveTokens(data, response);
        await _saveUser(data['user']);
        return {'success': true, 'token': data['token'], 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Google sign-in failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Google sign-in error: $e'};
    }
  }

  // Logout (MOBILE API)
  static Future<Map<String, dynamic>> logout() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final uri = Uri.parse('$baseUrl/api/mobile/auth/logout');
      final response = await http
          .post(
            uri,
            headers: {
              ..._headers,
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      await _clearLocalData();

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['error'] ?? 'Logout failed'};
      }
    } catch (e) {
      await _clearLocalData();
      return {'success': false, 'message': 'Logout error: $e'};
    }
  }

  // Get Profile (MOBILE API)
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final uri = Uri.parse('$baseUrl/api/mobile/profile');
      final response = await http
          .get(
            uri,
            headers: {
              ..._headers,
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'profile': data};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Profile fetch failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Profile fetch error: $e'};
    }
  }

  // Save tokens (JWT/session) securely
  static Future<void> _saveTokens(
    Map<String, dynamic> data,
    http.Response response,
  ) async {
    if (data['token'] != null) {
      await _storage.write(key: 'jwt_token', value: data['token'].toString());
    }
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      final sessionToken = _extractCookieValue(
        setCookie,
        'next-auth.session-token',
      );
      if (sessionToken != null) {
        await _storage.write(key: 'session_token', value: sessionToken);
      }
    }
  }

  // Save user data
  static Future<void> _saveUser(dynamic user) async {
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(user));
      await prefs.setBool('is_logged_in', true);
    }
  }

  // Extract cookie value from set-cookie header
  static String? _extractCookieValue(String cookieHeader, String name) {
    final cookies = cookieHeader.split(';');
    for (final cookie in cookies) {
      final parts = cookie.trim().split('=');
      if (parts.length == 2 && parts[0] == name) {
        return parts[1];
      }
    }
    return null;
  }

  // Clear all local data
  static Future<void> _clearLocalData() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'session_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null && userData.isNotEmpty) {
        return jsonDecode(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_logged_in') ?? false;
    } catch (e) {
      return false;
    }
  }

  // Generic authenticated request
  static Future<http.Response> authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    final token = await _storage.read(key: 'jwt_token');
    final headers = {
      ..._headers,
      if (token != null) 'Authorization': 'Bearer $token',
      ...?additionalHeaders,
    };
    final uri = Uri.parse('$baseUrl$endpoint');
    switch (method.toUpperCase()) {
      case 'GET':
        return http
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 10));
      case 'POST':
        return http
            .post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(const Duration(seconds: 10));
      case 'PUT':
        return http
            .put(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(const Duration(seconds: 10));
      case 'PATCH':
        return http
            .patch(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(const Duration(seconds: 10));
      case 'DELETE':
        return http
            .delete(uri, headers: headers)
            .timeout(const Duration(seconds: 10));
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/signup'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'role': role,
              'metadata': metadata ?? {},
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Signup response status: ${response.statusCode}');
      print('Signup response body: ${response.body}');

      if (response.body.isEmpty) {
        return {'success': false, 'message': 'Empty response from server'};
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Account created successfully',
          'user': data['user'] ?? {},
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      print('Signup error: $e');
      String errorMessage = 'An error occurred. Please try again.';

      if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid response format from server.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout. Please check your network.';
      }

      return {'success': false, 'message': errorMessage};
    }
  }
}
