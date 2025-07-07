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
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10),
            child: Column(
              children: [
                SizedBox(height: 30),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.purple[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Log in to continue your ADHD journey',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 22),
                Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Color(0xFFF6F3FB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.purple[100]!),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Email *'),
                          keyboardType: TextInputType.emailAddress,
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
                              style: TextStyle(color: Colors.purple),
                            ),
                          ),
                        ),
                        if (errorMsg != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(
                              errorMsg!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:const Color(0xff8159a8),
                            minimumSize: Size(double.infinity, 44),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Log In',
                                  style: TextStyle(color: Colors.white),
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
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 44),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? "),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/signup',
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(color: const Color(0xff8159a8)),
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
