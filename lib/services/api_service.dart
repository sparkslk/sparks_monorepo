import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  // Get base URL from environment variables
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Headers for API requests
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Login with email and password
  static Future<Map<String, dynamic>> login(
      String email,
      String password,
      ) async {
    try {
      print('🔍 Attempting login...');
      print('📍 Base URL: $baseUrl');
      print('📧 Email: $email');

      final uri = Uri.parse('$baseUrl/api/auth/callback/credentials');
      print('🌐 Full URL: $uri');

      // Properly URL-encode the body for x-www-form-urlencoded
      final body = 'email=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}&redirect=false';

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 10));

      print('✅ Login response status: ${response.statusCode}');
      print('📄 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return {'success': false, 'message': 'Empty response from server'};
        }

        final data = jsonDecode(response.body);

        if (data['url'] == null && data['error'] == null) {
          // Login successful
          await _handleSuccessfulLogin(data);
          return {
            'success': true,
            'message': 'Login successful',
            'user': data['user'] ?? {},
          };
        } else {
          // Login failed
          return {
            'success': false,
            'message': data['error'] ?? 'Invalid email or password',
          };
        }
      } else if (response.statusCode == 302) {
        // Handle redirect manually
        final location = response.headers['location'];
        if (location != null) {
          print('➡️ Following redirect to: $location');
          final redirectUri = Uri.parse(location);
          final redirectResponse = await http.get(redirectUri, headers: {
            'Accept': 'application/json',
          }).timeout(const Duration(seconds: 10));

          print('🔁 Redirect response status: ${redirectResponse.statusCode}');
          print('🔁 Redirect response body: ${redirectResponse.body}');

          // Check if response is HTML (starts with <!DOCTYPE or <html)
          if (redirectResponse.body.trim().startsWith('<!DOCTYPE') ||
              redirectResponse.body.trim().startsWith('<html')) {
            return {
              'success': false,
              'message': 'Login failed: Received an HTML page instead of user data. Please check your credentials or contact support.',
            };
          }

          if (redirectResponse.statusCode == 200) {
            if (redirectResponse.body.isEmpty) {
              return {'success': false, 'message': 'Empty redirect response from server'};
            }

            final data = jsonDecode(redirectResponse.body);
            await _handleSuccessfulLogin(data);
            return {
              'success': true,
              'message': 'Login successful (redirected)',
              'user': data['user'] ?? {},
            };
          } else {
            return {
              'success': false,
              'message': 'Login redirect failed (${redirectResponse.statusCode}).',
            };
          }
        } else {
          return {
            'success': false,
            'message': 'Login failed: Redirect (302) received but no Location header found.',
          };
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Server error (${response.statusCode}). Please try again.',
        };
      }
    } catch (e) {
      print('❌ Login error: $e');

      String errorMessage = 'An error occurred. Please try again.';

      if (e.toString().contains('Connection refused')) {
        errorMessage =
        'Cannot connect to server. Please check:\n'
            '1. Backend server is running\n'
            '2. Network connection\n'
            '3. Server URL is correct ($baseUrl)';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout. Please check your network.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid response format from server.';
      }

      return {'success': false, 'message': errorMessage};
    }
  }

  // Register new user
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String role,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          'metadata': metadata ?? {},
        }),
      ).timeout(const Duration(seconds: 10));

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

      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // Google Sign In
  static Future<Map<String, dynamic>> googleSignIn() async {
    try {
      // For Google Sign In, you'll need to integrate with the google_sign_in package
      // and then call your NextAuth Google provider endpoint
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signin/google'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return {'success': false, 'message': 'Empty response from server'};
        }

        final data = jsonDecode(response.body);
        await _handleSuccessfulLogin(data);
        return {
          'success': true,
          'message': 'Google sign in successful',
          'user': data['user'] ?? {},
        };
      } else {
        return {'success': false, 'message': 'Google sign in failed'};
      }
    } catch (e) {
      print('Google sign in error: $e');
      return {
        'success': false,
        'message': 'An error occurred with Google sign in.',
      };
    }
  }

  // Handle successful login - store tokens and user data
  static Future<void> _handleSuccessfulLogin(Map<String, dynamic> data) async {
    try {
      // Store session tokens securely
      if (data['token'] != null) {
        await _storage.write(key: 'session_token', value: data['token'].toString());
      }

      // Store user data in shared preferences
      if (data['user'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));
        await prefs.setBool('is_logged_in', true);
      }
    } catch (e) {
      print('Error handling successful login: $e');
      // Don't throw here, as login was successful
    }
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
      print('Get current user error: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('is_logged_in') ?? false;
    } catch (e) {
      print('Check login status error: $e');
      return false;
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      // Call NextAuth signout endpoint
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signout'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      // Clear local storage regardless of API response
      await _clearLocalData();

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        return {
          'success': true, // Still return success since we cleared local data
          'message': 'Logged out locally',
        };
      }
    } catch (e) {
      // Clear local data even if API call fails
      await _clearLocalData();
      print('Logout error: $e');
      return {'success': true, 'message': 'Logged out locally'};
    }
  }

  // Clear local user data
  static Future<void> _clearLocalData() async {
    try {
      await _storage.delete(key: 'session_token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.setBool('is_logged_in', false);
    } catch (e) {
      print('Error clearing local data: $e');
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _storage.read(key: 'session_token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/profile'),
        headers: {
          ..._headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return {'success': false, 'message': 'Empty response from server'};
        }

        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch profile'};
      }
    } catch (e) {
      print('Get profile error: $e');
      return {
        'success': false,
        'message': 'An error occurred while fetching profile.',
      };
    }
  }

  // Generic API call method with authentication
  static Future<http.Response> authenticatedRequest(
      String method,
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? additionalHeaders,
      }) async {
    final token = await _storage.read(key: 'session_token');
    final headers = {
      ..._headers,
      if (token != null) 'Authorization': 'Bearer $token',
      ...?additionalHeaders,
    };

    final uri = Uri.parse('$baseUrl$endpoint');

    switch (method.toUpperCase()) {
      case 'GET':
        return http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      case 'POST':
        return http.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(const Duration(seconds: 10));
      case 'PUT':
        return http.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(const Duration(seconds: 10));
      case 'DELETE':
        return http.delete(uri, headers: headers).timeout(const Duration(seconds: 10));
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }
}
