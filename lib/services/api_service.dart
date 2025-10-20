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
        return {'success': true, 'profile': data['profile'], 'hasProfile': data['hasProfile']};
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

  // Update Profile (MOBILE API)
  static Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    Map<String, String>? emergencyContact,
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final uri = Uri.parse('$baseUrl/api/mobile/profile');

      final Map<String, dynamic> body = {};
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (emergencyContact != null) {
        body['emergencyContactName'] = emergencyContact['name'] ?? '';
        body['emergencyContactPhone'] = emergencyContact['phone'] ?? '';
        body['emergencyContactRelation'] = emergencyContact['relation'] ?? '';
      }

      final response = await http
          .patch(
            uri,
            headers: {
              ..._headers,
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'profile': data['profile']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Profile update failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Profile update error: $e'};
    }
  }

  // Upload Profile Image (MOBILE API)
  static Future<Map<String, dynamic>> uploadProfileImage(String base64Image) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final uri = Uri.parse('$baseUrl/api/mobile/profile/image');

      final response = await http
          .post(
            uri,
            headers: {
              ..._headers,
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'image': base64Image}),
          )
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Update local user_data with new image
        if (data['user'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(data['user']));
        }
        return {'success': true, 'image': data['image']};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Image upload failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Image upload error: $e'};
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

  // Get therapists list with optional filters
  static Future<Map<String, dynamic>> getTherapists({
    String? specialty,
    String? minRating,
    String? maxCost,
    String? availability,
    String? search,
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final queryParams = <String, String>{};
      if (specialty != null) queryParams['specialty'] = specialty;
      if (minRating != null) queryParams['minRating'] = minRating;
      if (maxCost != null) queryParams['maxCost'] = maxCost;
      if (availability != null) queryParams['availability'] = availability;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/api/mobile/therapists')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          ..._headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'therapists': data['therapists'] ?? [],
          'currentTherapist': data['currentTherapist'],
          'hasTherapist': data['hasTherapist'] ?? false,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch therapists',
        };
      }
    } catch (e) {
      print('Get therapists error: $e');
      return {'success': false, 'message': 'Failed to fetch therapists: $e'};
    }
  }

  // Get specific therapist by ID
  static Future<Map<String, dynamic>> getTherapistById(
      String therapistId) async {
    try {
      final response = await authenticatedRequest(
        'GET',
        '/api/mobile/therapists/$therapistId',
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'therapist': data['therapist'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch therapist details',
        };
      }
    } catch (e) {
      print('Get therapist by ID error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch therapist details: $e'
      };
    }
  }

  // Assign therapist to patient
  static Future<Map<String, dynamic>> assignTherapist(
      String therapistId) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        '/api/mobile/therapists/assign',
        body: {'therapistId': therapistId},
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'assigned': data['assigned'] ?? false,
          'message': data['message'] ?? 'Therapist assigned successfully',
          'therapist': data['therapist'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to assign therapist',
        };
      }
    } catch (e) {
      print('Assign therapist error: $e');
      return {
        'success': false,
        'message': 'Failed to assign therapist: $e'
      };
    }
  }

  // Get available slots for a specific date
  static Future<Map<String, dynamic>> getAvailableSlots(
    String date, {
    String? therapistId,
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final queryParams = {'date': date};
      if (therapistId != null) {
        queryParams['therapistId'] = therapistId;
      }

      final uri = Uri.parse('$baseUrl/api/mobile/sessions/available-slots')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          ..._headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'availableSlots': data['availableSlots'] ?? [],
          'therapistName': data['therapistName'],
          'therapistId': data['therapistId'],
          'date': data['date'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch available slots',
        };
      }
    } catch (e) {
      print('Get available slots error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch available slots: $e'
      };
    }
  }

  // Book a therapy session
  static Future<Map<String, dynamic>> bookSession({
    required String date,
    required String timeSlot,
    String sessionType = "Individual",
    String? therapistId,
  }) async {
    try {
      final requestBody = {
        'date': date,
        'timeSlot': timeSlot,
        'sessionType': sessionType,
      };

      if (therapistId != null) {
        requestBody['therapistId'] = therapistId;
      }

      final response = await authenticatedRequest(
        'POST',
        '/api/mobile/sessions/book',
        body: requestBody,
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Session booked successfully',
          'session': data['session'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to book session',
        };
      }
    } catch (e) {
      print('Book session error: $e');
      return {'success': false, 'message': 'Failed to book session: $e'};
    }
  }

  // Get patient's therapy sessions
  static Future<Map<String, dynamic>> getSessions({
    String? timeframe, // 'upcoming', 'past', or 'all'
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (timeframe != null) queryParams['timeframe'] = timeframe;
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/api/mobile/sessions')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          ..._headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'sessions': data['sessions'] ?? [],
          'total': data['total'] ?? 0,
          'hasMore': data['hasMore'] ?? false,
          'statistics': data['statistics'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch sessions',
        };
      }
    } catch (e) {
      print('Get sessions error: $e');
      return {'success': false, 'message': 'Failed to fetch sessions: $e'};
    }
  }

  // Get reschedule fee for a session
  static Future<Map<String, dynamic>> getRescheduleFee(String sessionId) async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      final uri = Uri.parse('$baseUrl/api/mobile/sessions/reschedule/fee')
          .replace(queryParameters: {'sessionId': sessionId});

      final response = await http.get(
        uri,
        headers: {
          ..._headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'fee': data['fee'],
          'requiresPayment': data['requiresPayment'],
          'daysUntilSession': data['daysUntilSession'],
          'currentSessionDate': data['currentSessionDate'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to get reschedule fee',
        };
      }
    } catch (e) {
      print('Get reschedule fee error: $e');
      return {
        'success': false,
        'message': 'Failed to get reschedule fee: $e'
      };
    }
  }

  // Initiate reschedule fee payment
  static Future<Map<String, dynamic>> initiateRescheduleFeePayment({
    required String sessionId,
    required double amount,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? address,
    String? city,
  }) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        '/api/mobile/payment/reschedule-fee',
        body: {
          'sessionId': sessionId,
          'amount': amount,
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          if (address != null) 'address': address,
          if (city != null) 'city': city,
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'paymentDetails': data,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to initiate reschedule fee payment',
        };
      }
    } catch (e) {
      print('Initiate reschedule fee payment error: $e');
      return {
        'success': false,
        'message': 'Failed to initiate reschedule fee payment: $e'
      };
    }
  }

  // Reschedule a therapy session
  static Future<Map<String, dynamic>> rescheduleSession({
    required String sessionId,
    required String newDate,
    required String newTimeSlot,
    String? rescheduleReason,
    String? paymentId,
  }) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        '/api/mobile/sessions/reschedule',
        body: {
          'sessionId': sessionId,
          'newDate': newDate,
          'newTimeSlot': newTimeSlot,
          if (rescheduleReason != null) 'rescheduleReason': rescheduleReason,
          if (paymentId != null) 'paymentId': paymentId,
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Session rescheduled successfully',
          'session': data['session'],
        };
      } else if (response.statusCode == 402) {
        // Payment Required
        return {
          'success': false,
          'requiresPayment': true,
          'fee': data['fee'],
          'message': data['message'] ?? 'Payment required for rescheduling',
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to reschedule session',
        };
      }
    } catch (e) {
      print('Reschedule session error: $e');
      return {
        'success': false,
        'message': 'Failed to reschedule session: $e'
      };
    }
  }

  // Cancel a therapy session
  static Future<Map<String, dynamic>> cancelSession({
    required String sessionId,
    String? cancellationReason,
  }) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        '/api/mobile/sessions/cancel',
        body: {
          'sessionId': sessionId,
          if (cancellationReason != null) 'cancellationReason': cancellationReason,
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Session cancelled successfully',
          'cancellation': data['cancellation'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to cancel session',
        };
      }
    } catch (e) {
      print('Cancel session error: $e');
      return {
        'success': false,
        'message': 'Failed to cancel session: $e'
      };
    }
  }

  // Get specific session by ID
  static Future<Map<String, dynamic>> getSessionById(String sessionId) async {
    try {
      final response = await authenticatedRequest(
        'GET',
        '/api/mobile/sessions/$sessionId',
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'session': data['session'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch session details',
        };
      }
    } catch (e) {
      print('Get session by ID error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch session details: $e'
      };
    }
  }

  // Update session notes (patient's personal notes)
  static Future<Map<String, dynamic>> updateSessionNotes({
    required String sessionId,
    required String notes,
  }) async {
    try {
      final response = await authenticatedRequest(
        'PATCH',
        '/api/mobile/sessions/$sessionId/notes',
        body: {
          'sessionNotes': notes,
        },
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Notes saved successfully',
          'session': data['session'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to save notes',
        };
      }
    } catch (e) {
      print('Update session notes error: $e');
      return {
        'success': false,
        'message': 'Failed to save notes: $e'
      };
    }
  }

  // Get patient's active medications
  static Future<Map<String, dynamic>> getMedications() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        '/api/mobile/medications',
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'medications': data['medications'] ?? [],
          'total': data['total'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch medications',
        };
      }
    } catch (e) {
      print('Get medications error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch medications: $e'
      };
    }
  }

  // Get patient's game assignments
  static Future<Map<String, dynamic>> getGameAssignments() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        '/api/mobile/game-assignments',
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'gameAssignments': data['gameAssignments'] ?? [],
          'total': data['total'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch game assignments',
        };
      }
    } catch (e) {
      print('Get game assignments error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch game assignments: $e'
      };
    }
  }

  // Get patient's assessment assignments
  static Future<Map<String, dynamic>> getAssessments() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        '/api/mobile/assessments',
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'assessments': data['assessments'] ?? [],
          'total': data['total'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch assessments',
        };
      }
    } catch (e) {
      print('Get assessments error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch assessments: $e'
      };
    }
  }

  // Get featured blogs (limited)
  static Future<Map<String, dynamic>> getFeaturedBlogs({int limit = 2}) async {
    try {
      final response = await authenticatedRequest(
        'GET',
        '/api/mobile/blogs?limit=$limit',
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'blogs': data['blogs'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch featured blogs',
        };
      }
    } catch (e) {
      print('Get featured blogs error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch featured blogs: $e'
      };
    }
  }

  // Get all blogs
  static Future<Map<String, dynamic>> getAllBlogs() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        '/api/mobile/blogs',
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'blogs': data['blogs'] ?? [],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch blogs',
        };
      }
    } catch (e) {
      print('Get all blogs error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch blogs: $e'
      };
    }
  }

  // Get blog by ID
  static Future<Map<String, dynamic>> getBlogById(String blogId) async {
    try {
      final response = await authenticatedRequest(
        'GET',
        '/api/mobile/blogs/$blogId',
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'blog': data['blog'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch blog',
        };
      }
    } catch (e) {
      print('Get blog by ID error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch blog: $e'
      };
    }
  }

  // Get Dashboard Data (MOBILE API)
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        '/api/mobile/dashboard',
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch dashboard data',
        };
      }
    } catch (e) {
      print('Get dashboard data error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch dashboard data: $e'
      };
    }
  }

  // Get Today's Tasks (MOBILE API)
  static Future<Map<String, dynamic>> getTodayTasks() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        '/api/mobile/task',
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['tasks'] is List) {
        final now = DateTime.now();
        final todayTasks = (data['tasks'] as List).where((task) {
          if (task['dueDate'] != null) {
            final due = DateTime.tryParse(task['dueDate']);
            if (due != null) {
              return due.year == now.year &&
                  due.month == now.month &&
                  due.day == now.day;
            }
          }
          return false;
        }).toList();

        final completedToday = todayTasks.where((task) =>
          task['status'] == 'COMPLETED').length;

        return {
          'success': true,
          'tasks': todayTasks,
          'total': todayTasks.length,
          'completed': completedToday,
          'pending': todayTasks.length - completedToday,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch tasks',
        };
      }
    } catch (e) {
      print('Get today tasks error: $e');
      return {
        'success': false,
        'message': 'Failed to fetch tasks: $e'
      };
    }
  }

  // ==================== ADHD Quiz Methods ====================

  /// Submit ADHD quiz responses
  static Future<Map<String, dynamic>> submitAdhdQuiz(
      Map<String, dynamic> quizData) async {
    try {
      final response = await authenticatedRequest(
        'POST',
        '/api/mobile/quiz/adhd',
        body: quizData,
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'result': data['result'],
          'disclaimer': data['disclaimer'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to submit quiz'
        };
      }
    } catch (e) {
      print('Submit ADHD quiz error: $e');
      return {'success': false, 'message': 'Failed to submit quiz: $e'};
    }
  }

  /// Get ADHD quiz result if already completed
  static Future<Map<String, dynamic>> getAdhdQuizResult() async {
    try {
      final response = await authenticatedRequest(
        'GET',
        '/api/mobile/quiz/adhd',
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'hasCompleted': data['hasCompleted'] ?? false,
          'submission': data['submission'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to fetch quiz result'
        };
      }
    } catch (e) {
      print('Get ADHD quiz result error: $e');
      return {'success': false, 'message': 'Failed to fetch quiz result: $e'};
    }
  }
}
