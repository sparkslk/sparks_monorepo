import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;
  String? errorMsg;

  String? email;
  String? verificationToken;

  @override
  void initState() {
    super.initState();
    // Get arguments in the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          email = args['email'] as String?;
          verificationToken = args['verificationToken'] as String?;
        });
      }
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _getPasswordStrength(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Weak';

    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    if (strength <= 2) return 'Weak';
    if (strength == 3) return 'Medium';
    if (strength >= 4) return 'Strong';
    return '';
  }

  Color _getPasswordStrengthColor(String password) {
    final strength = _getPasswordStrength(password);
    if (strength == 'Weak') return Colors.red;
    if (strength == 'Medium') return Colors.orange;
    if (strength == 'Strong') return Colors.green;
    return Colors.grey;
  }

  double _getPasswordStrengthProgress(String password) {
    final strength = _getPasswordStrength(password);
    if (strength == 'Weak') return 0.33;
    if (strength == 'Medium') return 0.66;
    if (strength == 'Strong') return 1.0;
    return 0.0;
  }

  void _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (email == null || verificationToken == null) {
      setState(() {
        errorMsg = 'Session expired. Please start over.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    final result = await ApiService.resetPassword(
      email: email!,
      verificationToken: verificationToken!,
      newPassword: _newPasswordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      // Navigate to success screen
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/reset-password-success',
        );
      }
    } else {
      setState(() {
        errorMsg = result['message'] ?? 'Failed to reset password';
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
                  Icons.lock_open,
                  size: 80,
                  color: Color(0xff8159a8),
                ),
                SizedBox(height: 20),
                Text(
                  'Create New Password',
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
                  'Please enter your new password',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _newPasswordController,
                          decoration: InputDecoration(
                            labelText: 'New Password *',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureNewPassword,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            letterSpacing: 1.0,
                          ),
                          onChanged: (value) {
                            setState(() {}); // Trigger rebuild for strength indicator
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Enter your new password';
                            }
                            if (val.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        if (_newPasswordController.text.isNotEmpty) ...[
                          SizedBox(height: 8),
                          // Password Strength Indicator
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Password Strength: ',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    _getPasswordStrength(_newPasswordController.text),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _getPasswordStrengthColor(
                                          _newPasswordController.text),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: _getPasswordStrengthProgress(
                                    _newPasswordController.text),
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getPasswordStrengthColor(
                                      _newPasswordController.text),
                                ),
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password *',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            letterSpacing: 1.0,
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Confirm your password';
                            }
                            if (val != _newPasswordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        // Password Requirements
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Password Requirements:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              SizedBox(height: 6),
                              _buildRequirement(
                                'At least 8 characters',
                                _newPasswordController.text.length >= 8,
                              ),
                              _buildRequirement(
                                'Contains uppercase letter',
                                RegExp(r'[A-Z]').hasMatch(_newPasswordController.text),
                              ),
                              _buildRequirement(
                                'Contains lowercase letter',
                                RegExp(r'[a-z]').hasMatch(_newPasswordController.text),
                              ),
                              _buildRequirement(
                                'Contains number',
                                RegExp(r'[0-9]').hasMatch(_newPasswordController.text),
                              ),
                              _buildRequirement(
                                'Contains special character',
                                RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                    .hasMatch(_newPasswordController.text),
                              ),
                            ],
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
                        SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: isLoading ? null : _resetPassword,
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
                                  'Reset Password',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: isMet ? Colors.green.shade700 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
