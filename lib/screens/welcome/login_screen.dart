import 'package:flutter/material.dart';
import '../../services/google_signin_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;
  bool isGoogleLoading = false;
  String? errorMsg;

  void _login() async {
    Navigator.pushReplacementNamed(context, '/choose');
  }

  void _googleSignIn() async {
    setState(() {
      isGoogleLoading = true;
      errorMsg = null;
    });

    final result = await GoogleSignInService.signInWithGoogle();

    setState(() {
      isGoogleLoading = false;
    });

    if (result['success']) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      setState(() {
        errorMsg = result['message'];
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
                    color: Colors.purple[700],
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
                      color: const Color.fromARGB(255, 242, 193, 250)!,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Email *'),
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            letterSpacing: 1.0,
                          ),
                          validator: (val) =>
                              val!.isEmpty ? 'Enter your email' : null,
                          onSaved: (val) => email = val!,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password *',
                            suffixIcon: Icon(Icons.visibility_off),
                          ),
                          obscureText: true,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            letterSpacing: 1.0,
                          ),
                          validator: (val) =>
                              val!.isEmpty ? 'Enter your password' : null,
                          onSaved: (val) => password = val!,
                        ),
                        SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              errorMsg!,
                              style: TextStyle(
                                color: Colors.red,
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
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
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
                              child: Text('or'),
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
                              : Icon(Icons.g_mobiledata, color: Colors.black),
                          label: Text(
                            isGoogleLoading
                                ? 'Signing in...'
                                : 'Continue with Google',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              letterSpacing: 1.0,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 44),
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
