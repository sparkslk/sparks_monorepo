import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl => dotenv.get('BASE_URI');

  static Future<Map<String, dynamic>> signup(String firstName, String lastName, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
      }),
    );
    if (res.statusCode == 200) {
      return {'success': true};
    } else {
      return {'success': false, 'message': jsonDecode(res.body)['message'] ?? 'Registration failed'};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return {'success': true, 'token': data['token']};
    } else {
      return {'success': false, 'message': jsonDecode(res.body)['message'] ?? 'Login failed'};
    }
  }
}
