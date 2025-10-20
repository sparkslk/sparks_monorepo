import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool isLoading = false;
  bool isResending = false;
  String? errorMsg;
  int? remainingAttempts;
  int timeRemaining = 600; // 10 minutes in seconds
  Timer? _timer;
  bool canResend = false;
  int resendCooldown = 0;
  Timer? _resendTimer;

  String? email;
  int? expiresIn;

  @override
  void initState() {
    super.initState();
    // Get arguments in the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          email = args['email'] as String?;
          expiresIn = args['expiresIn'] as int? ?? 600;
          timeRemaining = expiresIn!;
        });
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resendTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          errorMsg = 'OTP has expired. Please request a new code.';
        });
      }
    });
  }

  void _startResendCooldown(int seconds) {
    setState(() {
      resendCooldown = seconds;
      canResend = false;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendCooldown > 0) {
        setState(() {
          resendCooldown--;
        });
      } else {
        timer.cancel();
        setState(() {
          canResend = true;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  String _getOTP() {
    return _otpControllers.map((c) => c.text).join('');
  }

  void _verifyOTP() async {
    final otp = _getOTP();

    if (otp.length != 6) {
      setState(() {
        errorMsg = 'Please enter all 6 digits';
      });
      return;
    }

    if (email == null) {
      setState(() {
        errorMsg = 'Email not found. Please try again.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    final result = await ApiService.verifyPasswordResetOTP(email!, otp);

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      // Navigate to reset password screen
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/reset-password',
          arguments: {
            'email': email,
            'verificationToken': result['verificationToken'],
          },
        );
      }
    } else {
      setState(() {
        errorMsg = result['message'] ?? 'Invalid OTP code';
        remainingAttempts = result['remainingAttempts'];
      });
    }
  }

  void _resendOTP() async {
    if (!canResend && resendCooldown > 0) {
      setState(() {
        errorMsg = 'Please wait $resendCooldown seconds before resending';
      });
      return;
    }

    if (email == null) {
      setState(() {
        errorMsg = 'Email not found. Please try again.';
      });
      return;
    }

    setState(() {
      isResending = true;
      errorMsg = null;
    });

    final result = await ApiService.requestPasswordResetOTP(email!);

    setState(() {
      isResending = false;
    });

    if (result['success'] == true) {
      // Reset timer
      setState(() {
        timeRemaining = result['expiresIn'] ?? 600;
        errorMsg = null;
      });
      _startTimer();
      _startResendCooldown(60); // 60 second cooldown

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        errorMsg = result['message'] ?? 'Failed to resend code';
        if (result['remainingSeconds'] != null) {
          _startResendCooldown(result['remainingSeconds']);
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
                  Icons.verified_user,
                  size: 80,
                  color: Color(0xff8159a8),
                ),
                SizedBox(height: 20),
                Text(
                  'Verify Code',
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
                  'Enter the 6-digit code sent to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                Text(
                  email ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xff8159a8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
                  child: Column(
                    children: [
                      // Timer Display
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: timeRemaining < 60
                              ? Colors.red.shade50
                              : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer,
                              size: 20,
                              color: timeRemaining < 60
                                  ? Colors.red
                                  : Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Time remaining: ${_formatTime(timeRemaining)}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: timeRemaining < 60
                                    ? Colors.red.shade700
                                    : Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xff8159a8),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Color(0xff8159a8),
                                    width: 2,
                                  ),
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                              },
                            ),
                          );
                        }),
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
                      if (remainingAttempts != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                          margin: const EdgeInsets.only(top: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            border: Border.all(color: Colors.orange.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$remainingAttempts attempt${remainingAttempts != 1 ? 's' : ''} remaining',
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
                        onPressed: (isLoading || timeRemaining == 0) ? null : _verifyOTP,
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
                                'Verify Code',
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
                        onPressed: (isResending || !canResend && resendCooldown > 0)
                            ? null
                            : _resendOTP,
                        child: Text(
                          isResending
                              ? 'Sending...'
                              : resendCooldown > 0
                                  ? 'Resend Code (${resendCooldown}s)'
                                  : 'Resend Code',
                          style: TextStyle(
                            color: (isResending || !canResend && resendCooldown > 0)
                                ? Colors.grey
                                : Colors.purple,
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
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
