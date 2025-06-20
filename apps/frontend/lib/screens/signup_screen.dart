import 'package:flutter/material.dart';
import '../services/api_service.dart';

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
  bool agree = false;
  bool isLoading = false;
  String? errorMsg;

  void _signup() async {
    if (!_formKey.currentState!.validate() || !agree) return;
    setState(() { isLoading = true; errorMsg = null; });
    _formKey.currentState!.save();
    final result = await ApiService.signup(firstName, lastName, email, password);
    setState(() { isLoading = false; });
    if (result['success']) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() { errorMsg = result['message']; });
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
                Text('Join Our Platform!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.purple[700])),
                SizedBox(height: 8),
                Text('Start your ADHD management journey today!', style: TextStyle(color: Colors.grey[700])),
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
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(labelText: 'First Name *'),
                                validator: (val) => val!.isEmpty ? 'Required' : null,
                                onSaved: (val) => firstName = val!,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(labelText: 'Last Name *'),
                                validator: (val) => val!.isEmpty ? 'Required' : null,
                                onSaved: (val) => lastName = val!,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Email *'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) => val!.isEmpty ? 'Enter your email' : null,
                          onSaved: (val) => email = val!,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Password *', suffixIcon: Icon(Icons.visibility_off)),
                          obscureText: true,
                          validator: (val) => val!.length < 6 ? 'Min 6 characters' : null,
                          onSaved: (val) => password = val!,
                        ),
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
                                  style: TextStyle(color: Colors.black87, fontSize: 13),
                                  children: [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(text: 'Terms of Service', style: TextStyle(color: Colors.purple)),
                                    TextSpan(text: ' and '),
                                    TextSpan(text: 'Privacy Policy', style: TextStyle(color: Colors.purple)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!agree)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('You must agree before signing up.', style: TextStyle(color: Colors.red, fontSize: 12)),
                          ),
                        if (errorMsg != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Text(errorMsg!, style: TextStyle(color: Colors.red)),
                          ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: isLoading ? null : _signup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            minimumSize: Size(double.infinity, 44),
                          ),
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Sign Up', style: TextStyle(color: Colors.white)),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('or'),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () {

                          }, // Google sign in logic
                          icon: Icon(Icons.g_mobiledata, color: Colors.black),
                          label: Text('Continue with Google'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 44),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? "),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                              child: Text('Log In', style: TextStyle(color: Colors.purple)),
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
