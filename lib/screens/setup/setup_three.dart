import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProfileSetupStep3 extends StatefulWidget {
  const ProfileSetupStep3({Key? key}) : super(key: key);

  @override
  State<ProfileSetupStep3> createState() => _ProfileSetupStep3State();
}

class _ProfileSetupStep3State extends State<ProfileSetupStep3> {
  Map<String, dynamic>? profile;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      loading = true;
      error = null;
    });
    final res = await ApiService.getProfile();
    print('DEBUG: API response: ' + res.toString());
    dynamic profileData;
    if (res['hasProfile'] == true && res['profile'] != null) {
      profileData = res['profile'];
    } else if (res['success'] == true && res['profile'] != null) {
      // Handle double-wrapped structure
      if (res['profile']['hasProfile'] == true &&
          res['profile']['profile'] != null) {
        profileData = res['profile']['profile'];
      }
    }
    if (profileData != null) {
      setState(() {
        profile = profileData;
        loading = false;
      });
    } else if (res['error'] != null) {
      setState(() {
        error = res['error'].toString();
        loading = false;
      });
    } else {
      setState(() {
        error = res['message'] ?? 'Failed to load profile.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    final userData = profile ?? {};
    // Map emergency contact and medical info for display
    final emergencyContact = userData['emergencyContact'] ?? {};
    final emergencyName = emergencyContact['name'] ?? '';
    final emergencyPhone = emergencyContact['phone'] ?? '';
    final emergencyRelation = emergencyContact['relation'] ?? '';
    final medicalHistory = userData['medicalHistory'] ?? '';
    // Format date of birth to YYYY-MM-DD
    String formattedDob = '';
    if (userData['dateOfBirth'] != null &&
        userData['dateOfBirth'].toString().isNotEmpty) {
      final dobStr = userData['dateOfBirth'].toString();
      if (dobStr.length >= 10) {
        formattedDob = dobStr.substring(0, 10);
      } else {
        formattedDob = dobStr;
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: const Text(
                    "Review Your Profile",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff8159a8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Please review all the information below.\nMake sure everything is correct before confirming.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.black,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 24),
                // Stepper indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStepCircle(true),
                    _buildStepLine(),
                    _buildStepCircle(true),
                    _buildStepLine(),
                    _buildStepCircle(true),
                  ],
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Step 3 of 3',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xff8159a8),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Basic Information Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(245, 243, 251, 1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Color(0xff8159a8),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Name',
                        '${userData['firstName']} ${userData['lastName']}',
                      ),
                      _buildInfoRow('Email', userData['email']),
                      _buildInfoRow('Phone', userData['phone']),
                      _buildInfoRow('Date of Birth', formattedDob),
                      _buildInfoRow('Gender', userData['gender']),
                      _buildInfoRow('Address', userData['address']),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Emergency Contact Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(245, 243, 251, 1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Emergency Contact',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Color(0xff8159a8),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Contact Name',
                        emergencyName.isNotEmpty
                            ? emergencyName
                            : 'Not provided',
                      ),
                      _buildInfoRow(
                        'Contact Phone',
                        emergencyPhone.isNotEmpty
                            ? emergencyPhone
                            : 'Not provided',
                      ),
                      _buildInfoRow(
                        'Relationship',
                        emergencyRelation.isNotEmpty
                            ? emergencyRelation
                            : 'Not provided',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Medical Information Summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(245, 243, 251, 1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Medical Information',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Color(0xff8159a8),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        'Medical Notes',
                        medicalHistory.isNotEmpty
                            ? medicalHistory
                            : 'No medical information provided',
                      ),
                      if (userData['uploadedDocument'] != null)
                        _buildDocumentRow(
                          'Uploaded Document',
                          userData['uploadedDocument'],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Success Message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Setup Complete!',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your profile is ready. Click confirm to start using the app.',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Colors.green[600],
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Navigation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xff8159a8)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                          color: Color(0xff8159a8),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff8159a8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () {
                        _showConfirmDialog(context);
                      },
                      child: const Text(
                        'Confirm',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    // Convert any value to a string representation
    final displayValue = value == null
        ? 'Not provided'
        : value is String
        ? value.isNotEmpty
              ? value
              : 'Not provided'
        : value.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff8159a8),
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(String label, String fileName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xff8159a8),
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf, size: 16, color: Color(0xff8159a8)),
                const SizedBox(width: 8),
                Text(
                  fileName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xff8159a8),
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(bool filled) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: filled ? const Color(0xff8159a8) : Colors.white,
        border: Border.all(color: const Color(0xff8159a8), width: 2),
        shape: BoxShape.circle,
      ),
      child: filled
          ? const Center(
              child: Icon(Icons.check, size: 14, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildStepLine() {
    return Container(width: 32, height: 2, color: const Color(0xff8159a8));
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Confirm Profile Setup',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: Color(0xff8159a8),
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Are you sure you want to complete your profile setup? You can always edit your information later.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black,
              letterSpacing: 1.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff8159a8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToDashboard(context);
              },
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDashboard(BuildContext context) {
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile setup completed successfully!'),
        backgroundColor: Color(0xff8159a8),
        duration: Duration(seconds: 3),
      ),
    );

    // Navigate to dashboard - replace with your dashboard route
    Navigator.pushReplacementNamed(context, '/dashboard');
  }
}
