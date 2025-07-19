import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/google_signin_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Dio _dio;
  late CookieJar _cookieJar;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
  bool isGoogleLoading = false;
  String? errorMsg;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Check if user is already logged in
  @override
  void initState() {
    super.initState();
    _dio = Dio();
    _cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(_cookieJar));
    _checkExistingSession();
  }

  void _checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userRole = prefs.getString('user_role');

    if (token != null && userRole != null) {
      // User is already logged in, redirect to appropriate screen
      _redirectBasedOnRole(userRole);
    }
  }

  void _redirectBasedOnRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      case 'doctor':
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        break;
      case 'patient':
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/choose');
    }
  }

  // Updated login method with CSRF token handling
  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    try {
      // Step 1: Get CSRF token first
      final csrfToken = await _getCSRFToken();
      if (csrfToken == null) {
        setState(() {
          errorMsg = 'Failed to get security token. Please try again.';
        });
        return;
      }

      // Step 2: Use the CSRF token for authentication
      await _authenticateWithCSRF(csrfToken);
    } catch (e) {
      print('Login error: $e');
      setState(() {
        errorMsg = 'Network error. Please check your connection and try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Get CSRF token from NextAuth
  Future<String?> _getCSRFToken() async {
    try {
      final String baseUrl = dotenv.env['API_BASE_URL']!;
      final resp = await _dio.get('$baseUrl/api/auth/csrf');
      print('CSRF Response status: ${resp.statusCode}');
      print('CSRF Response body: ${resp.data}');
      if (resp.statusCode == 200 &&
          resp.data != null &&
          resp.data['csrfToken'] != null) {
        return resp.data['csrfToken'];
      }
    } catch (e) {
      print('CSRF token error: $e');
    }
    return null;
  }

  // Authenticate with CSRF token
  Future<void> _authenticateWithCSRF(String csrfToken) async {
    try {
      final String baseUrl = dotenv.env['API_BASE_URL']!;
      final resp = await _dio.post(
        '$baseUrl/api/auth/callback/credentials',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 400,
        ),
        data: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'csrfToken': csrfToken,
          'callbackUrl': '/dashboard-redirect',
          'json': 'true',
        },
      );
      print('Auth Response status: ${resp.statusCode}');
      print('Auth Response body: ${resp.data}');
      print('Auth Response headers: ${resp.headers}');
      if (resp.statusCode == 200) {
        final data = resp.data;
        if (data is Map &&
            data['url'] != null &&
            !data['url'].toString().contains('error')) {
          await _handleSuccessfulLogin();
        } else if (data is Map && data['error'] != null) {
          setState(() {
            errorMsg = 'Invalid credentials. Please try again.';
          });
        } else {
          setState(() {
            errorMsg = 'Login failed. Please try again.';
          });
        }
      } else if (resp.statusCode == 302) {
        final location = resp.headers['location']?.first;
        if (location != null && location.contains('dashboard')) {
          await _handleSuccessfulLogin();
        } else {
          setState(() {
            errorMsg = 'Login failed. Please check your credentials.';
          });
        }
      } else if (resp.statusCode == 401) {
        setState(() {
          errorMsg =
              'Invalid email or password. Please check your credentials.';
        });
      } else {
        setState(() {
          errorMsg = 'Login failed (${resp.statusCode}). Please try again.';
        });
      }
    } catch (e) {
      print('Auth error: $e');
      setState(() {
        errorMsg = 'Network error. Please check your connection and try again.';
      });
    }
  }

  // Handle successful login
  Future<void> _handleSuccessfulLogin([Map<String, dynamic>? data]) async {
    final prefs = await SharedPreferences.getInstance();

    // Store user data if provided
    if (data != null && data['user'] != null) {
      await prefs.setString('user_id', data['user']['id'] ?? '');
      await prefs.setString('user_email', data['user']['email'] ?? '');
      await prefs.setString('user_role', data['user']['role'] ?? 'patient');
      String name = data['user']['name'] ?? '';
      if (name.isEmpty) {
        // Try to fetch name from profile endpoint if not present
        try {
          final String baseUrl = dotenv.env['API_BASE_URL']!;
          final profileResp = await _dio.get('$baseUrl/api/user/profile');
          if (profileResp.statusCode == 200 &&
              profileResp.data != null &&
              profileResp.data['name'] != null) {
            name = profileResp.data['name'];
          }
        } catch (e) {
          print('Profile fetch error: $e');
        }
      }
      await prefs.setString('user_name', name);
    } else {
      // Store basic user info
      await prefs.setString('user_email', _emailController.text.trim());
      await prefs.setString('user_role', 'patient'); // Default role
      // Try to fetch name from profile endpoint
      String name = '';
      try {
        final profileResp = await _dio.get(
          'http://192.168.1.199:3000/api/user/profile',
        );
        if (profileResp.statusCode == 200 &&
            profileResp.data != null &&
            profileResp.data['name'] != null) {
          name = profileResp.data['name'];
        }
      } catch (e) {
        print('Profile fetch error: $e');
      }
      await prefs.setString('user_name', name);
    }

    if (data != null && data['sessionToken'] != null) {
      await prefs.setString('auth_token', data['sessionToken']);
    }

    await prefs.setBool('is_logged_in', true);

    // Navigate to appropriate screen
    final userRole = data?['user']?['role'] ?? 'patient';
    _redirectBasedOnRole(userRole);
  }

  // Helper method to handle successful redirect
  Future<void> _handleSuccessfulRedirect(String location) async {
    final prefs = await SharedPreferences.getInstance();

    // Extract user info from redirect URL if available
    final uri = Uri.parse(location);
    final queryParams = uri.queryParameters;

    if (queryParams.containsKey('user')) {
      // Handle user data from query parameters if your backend provides it
      await prefs.setString('user_email', _emailController.text.trim());
    }

    // Determine role from redirect URL
    String role = 'patient';
    if (location.contains('admin')) {
      role = 'admin';
    } else if (location.contains('doctor')) {
      role = 'doctor';
    }

    await prefs.setString('user_role', role);
    await prefs.setBool('is_logged_in', true);
    _redirectBasedOnRole(role);
  }

  void _googleSignIn() async {
    setState(() {
      isGoogleLoading = true;
      errorMsg = null;
    });

    try {
      final result = await GoogleSignInService.signInWithGoogle();

      if (result['success']) {
        // Store Google sign-in data
        final prefs = await SharedPreferences.getInstance();
        if (result['user'] != null) {
          await prefs.setString('user_id', result['user']['id'] ?? '');
          await prefs.setString('user_email', result['user']['email'] ?? '');
          await prefs.setString(
            'user_role',
            result['user']['role'] ?? 'patient',
          );
          await prefs.setString('user_name', result['user']['name'] ?? '');
        }

        if (result['token'] != null) {
          await prefs.setString('auth_token', result['token']);
        }

        await prefs.setBool('is_logged_in', true);
        Navigator.pushReplacementNamed(context, '/onboarding');
      } else {
        setState(() {
          errorMsg =
              result['message'] ?? 'Google sign-in failed. Please try again.';
        });
      }
    } catch (e) {
      print('Google sign-in error: $e');
      setState(() {
        errorMsg = 'Google sign-in failed. Please try again.';
      });
    } finally {
      setState(() {
        isGoogleLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 5),
            child: Column(
              children: [
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    color: Color.fromRGBO(129, 89, 168, 1),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Log in to continue your ADHD journey',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 22),
                Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Color(0xFFF6F3FB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color.fromARGB(255, 242, 193, 250),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email *',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            letterSpacing: 1.0,
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Enter your email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(val)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password *',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            letterSpacing: 1.0,
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Enter your password';
                            }
                            if (val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/forgot-password');
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 14,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        if (errorMsg != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 12.0,
                            ),
                            margin: const EdgeInsets.only(bottom: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              errorMsg!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff8159a8),
                            minimumSize: Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    letterSpacing: 1.0,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: isGoogleLoading ? null : _googleSignIn,
                          icon: isGoogleLoading
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.grey,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/logowhite.png',
                                  width: 20,
                                  height: 20,
                                ),
                          label: Text(
                            isGoogleLoading
                                ? 'Signing in...'
                                : 'Continue with Google',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              letterSpacing: 1.0,
                              color: Colors.black87,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/signup',
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff8159a8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
