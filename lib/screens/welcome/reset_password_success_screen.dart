import 'dart:async';
import 'package:flutter/material.dart';

class ResetPasswordSuccessScreen extends StatefulWidget {
  @override
  State<ResetPasswordSuccessScreen> createState() => _ResetPasswordSuccessScreenState();
}

class _ResetPasswordSuccessScreenState extends State<ResetPasswordSuccessScreen> {
  Timer? _redirectTimer;
  int countdown = 3;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _redirectTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    if (mounted) {
      // Pop all routes until login or root
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Animation / Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Password Reset Successful!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    color: Color.fromRGBO(129, 89, 168, 1),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Your password has been reset successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'You can now log in with your new password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Color(0xFFF6F3FB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromARGB(255, 242, 193, 250),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Redirecting to login in',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$countdown',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 36,
                          color: Color(0xff8159a8),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _navigateToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8159a8),
                    minimumSize: Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue to Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 1.0,
                      fontFamily: 'Poppins',
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
