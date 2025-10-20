import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;
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
    _checkExistingSession();
  }

  void _checkExistingSession() async {
    final isLoggedIn = await ApiService.isLoggedIn();
    if (isLoggedIn) {
      final user = await ApiService.getCurrentUser();
      // Only redirect if user data exists and has a valid id/email
      if (user != null && (user['id'] != null || user['email'] != null)) {
        final role = user['role'] ?? 'patient';
        _redirectBasedOnRole(role);
      }
    }
  }

  void _redirectBasedOnRole(String role) async {
    switch (role.toLowerCase()) {
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      case 'doctor':
        Navigator.pushReplacementNamed(context, '/doctor-dashboard');
        break;
      case 'patient':
        // Check if user needs to complete ADHD quiz
        await _checkAdhdQuizAndRedirect();
        break;
      default:
        Navigator.pushReplacementNamed(context, '/choose');
    }
  }

  Future<void> _checkAdhdQuizAndRedirect() async {
    try {
      // Fetch dashboard data to check needsAdhdQuiz flag
      final dashboardData = await ApiService.getDashboardData();

      if (dashboardData['success'] == true) {
        final needsAdhdQuiz = dashboardData['needsAdhdQuiz'] ?? false;

        if (needsAdhdQuiz && mounted) {
          // Redirect to ADHD quiz if not completed
          Navigator.pushReplacementNamed(context, '/adhd_quiz');
        } else if (mounted) {
          // Redirect to dashboard if quiz already completed
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        // If dashboard data fetch fails, redirect to dashboard anyway
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      }
    } catch (e) {
      // On error, redirect to dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    final result = await ApiService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      final user = result['user'] ?? {};
      final role = user['role'] ?? 'patient';
      _redirectBasedOnRole(role);
    } else {
      setState(() {
        errorMsg = result['message'] ?? 'Login failed. Please try again.';
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
                        SizedBox(height: 20),
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
