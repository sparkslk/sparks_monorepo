import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String selectedRole = 'NORMAL_USER';
  bool agree = false;
  bool isLoading = false;
  String? errorMsg;

  void _signup() async {
    if (!_formKey.currentState!.validate() || !agree) return;
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    _formKey.currentState!.save();

    final fullName = '$firstName $lastName'.trim();
    final result = await ApiService.signup(
      name: fullName,
      email: email,
      password: password,
      role: selectedRole,
    );

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      // Show success message and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully! Please log in.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
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
                  'Join Our Platform!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    color: Color.fromRGBO(129, 89, 168, 1),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'Start your ADHD management journey today!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 22),
                Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(245, 243, 251, 1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Color.fromRGBO(185, 156, 213, 1)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'First Name *',
                                ),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  letterSpacing: 1.0,
                                ),
                                validator: (val) =>
                                    val!.isEmpty ? 'Required' : null,
                                onSaved: (val) => firstName = val!,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Last Name *',
                                ),
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  letterSpacing: 1.0,
                                ),
                                validator: (val) =>
                                    val!.isEmpty ? 'Required' : null,
                                onSaved: (val) => lastName = val!,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Email *'),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            letterSpacing: 1.0,
                          ),
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
                              val!.length < 8 ? 'Min 8 characters' : null,
                          onSaved: (val) => password = val!,
                        ),
                        SizedBox(height: 12),

                        SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: agree,
                              onChanged: (val) => setState(() => agree = val!),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.black87,
                                    fontSize: 13,
                                  ),
                                  children: [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xff8159a8),
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xff8159a8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!agree)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'You must agree before signing up.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.red,
                                fontSize: 12,
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
                          onPressed: isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff8159a8),
                            minimumSize: Size(double.infinity, 44),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: 18,
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
                          onPressed: () {}, // Google sign in logic
                          icon: Icon(Icons.g_mobiledata, color: Colors.black),
                          label: Text(
                            'Continue with Google',
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
                              "Already have an account? ",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/login',
                              ),
                              child: Text(
                                'Log In',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
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
