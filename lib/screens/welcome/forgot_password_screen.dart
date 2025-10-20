import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool isLoading = false;
  String? errorMsg;
  String? successMsg;
  int? resendCooldown;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _requestOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      errorMsg = null;
      successMsg = null;
    });

    final result = await ApiService.requestPasswordResetOTP(
      _emailController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      // Navigate to OTP verification screen
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: {
            'email': _emailController.text.trim(),
            'expiresIn': result['expiresIn'] ?? 600,
          },
        );
      }
    } else {
      setState(() {
        errorMsg = result['message'] ?? 'Failed to send verification code';
        if (result['remainingSeconds'] != null) {
          resendCooldown = result['remainingSeconds'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xff8159a8)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 5),
            child: Column(
              children: [
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: Color(0xff8159a8),
                ),
                SizedBox(height: 20),
                Text(
                  'Reset Password',
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
                  'Enter your email to receive a verification code',
                  textAlign: TextAlign.center,
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
                        if (successMsg != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 12.0,
                            ),
                            margin: const EdgeInsets.only(top: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              successMsg!,
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                letterSpacing: 1.0,
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
                            margin: const EdgeInsets.only(top: 12.0),
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
                        if (resendCooldown != null && resendCooldown! > 0)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 12.0,
                            ),
                            margin: const EdgeInsets.only(top: 12.0),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Please wait $resendCooldown seconds before requesting again',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: isLoading ? null : _requestOTP,
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
                                  'Send Code',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    letterSpacing: 1.0,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                        ),
                        SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Back to Login',
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 14,
                              letterSpacing: 1.0,
                            ),
                          ),
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
