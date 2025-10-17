import 'package:flutter/material.dart';
import 'dart:io';
import '../../services/api_service.dart';

class ProfileSetupStep2 extends StatefulWidget {
  const ProfileSetupStep2({Key? key}) : super(key: key);

  @override
  State<ProfileSetupStep2> createState() => _ProfileSetupStep2State();
}

class _ProfileSetupStep2State extends State<ProfileSetupStep2> {
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _medicalInfoController = TextEditingController();
  String? _selectedRelationship;
  File? _uploadedDocument;
  String? _uploadedFileName;

  @override
  Widget build(BuildContext context) {
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
                    "Let's Set Up Your Profile",
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xff8159a8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Help us personalize your experience.\nWe'll guide you through this step by step - no rush!",
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
                    _buildStepCircle(false),
                  ],
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Step 2 of 3',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xff8159a8),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Emergency Contact Section
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
                      const SizedBox(height: 8),
                      const Text(
                        'Please provide emergency contact details for safety.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _emergencyNameController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Emergency Contact Name *',
                          hintText: 'Enter full name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xffe0e0e0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xffe0e0e0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff8159a8),
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: const Icon(Icons.person_outline),
                          labelStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                          hintStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emergencyPhoneController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Emergency Phone Number *',
                          hintText: '071 234 5678',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xffe0e0e0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xffe0e0e0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff8159a8),
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: const Icon(Icons.phone_outlined),
                          labelStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                          hintStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRelationship,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Relationship *',
                          hintText: 'Select relationship',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xffe0e0e0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xffe0e0e0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff8159a8),
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          labelStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                        hint: const Text(
                          'Select relationship',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                            color: Colors.grey,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            child: Text(
                              'Parent',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                            ),
                            value: 'parent',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              'Sibling',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                            ),
                            value: 'sibling',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              'Spouse',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                            ),
                            value: 'spouse',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              'Friend',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                            ),
                            value: 'friend',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              'Relative',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                            ),
                            value: 'relative',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              'Other',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                            ),
                            value: 'other',
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRelationship = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Medical Information Section
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
                      const SizedBox(height: 8),
                      const Text(
                        'Optional: Add any relevant medical information or conditions.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _medicalInfoController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Medical Information (Optional)',
                          hintText: 'Any allergies, conditions, medications...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xffe0e0e0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xffe0e0e0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xff8159a8),
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          alignLabelWithHint: true,
                          labelStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                          hintStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                        maxLines: 4,
                        minLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 16),
                      // Upload PDF Document
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xffe0e0e0),
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.upload_file_outlined,
                              size: 32,
                              color: Color(0xff8159a8),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _uploadedFileName ??
                                  'Upload Medical Document (PDF)',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                letterSpacing: 1.0,
                                color: _uploadedFileName != null
                                    ? Color(0xff8159a8)
                                    : Colors.grey[600],
                                fontWeight: _uploadedFileName != null
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Optional: Upload medical reports, prescriptions, or any relevant documents',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                letterSpacing: 1.0,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xff8159a8),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: _pickDocument,
                              icon: const Icon(
                                Icons.attach_file,
                                size: 18,
                                color: Color(0xff8159a8),
                              ),
                              label: Text(
                                _uploadedFileName != null
                                    ? 'Change Document'
                                    : 'Browse Files',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  letterSpacing: 1.0,
                                  color: Color(0xff8159a8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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
                      onPressed: _validateAndNext,
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickDocument() async {
    // In a real app, you would use file_picker package here
    // For now, we'll simulate file selection
    setState(() {
      _uploadedFileName = "medical_report.pdf";
    });

    // Show a snackbar to indicate file selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document selected successfully!'),
        backgroundColor: Color(0xff8159a8),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _validateAndNext() async {
    if (_emergencyNameController.text.trim().isEmpty ||
        _emergencyPhoneController.text.trim().isEmpty ||
        _selectedRelationship == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all mandatory fields (*)'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final emergencyPhone = _emergencyPhoneController.text.trim();
    if (!RegExp(r'^0\d{9} ?$').hasMatch(emergencyPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Contact Number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Save to backend (PATCH)
    final response = await ApiService.authenticatedRequest(
      'PATCH',
      '/api/mobile/profile',
      body: {
        'emergencyContactName': _emergencyNameController.text.trim(),
        'emergencyContactPhone': _emergencyPhoneController.text.trim(),
        'emergencyContactRelation': _selectedRelationship,
        'medicalInfo': _medicalInfoController.text.trim(),
      },
    );
    if (response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/setup_three');
    } else {
      // Show more informative error message if available
      String errorMessage = 'Failed to save emergency/medical info.';

      // Log the error details
      print('Error response: ${response.statusCode} - ${response.body}');

      try {
        final responseBody = response.body;
        if (responseBody.contains('error')) {
          // Try to extract error message from JSON response
          final errorStart = responseBody.indexOf('"error":"');
          if (errorStart != -1) {
            final start = errorStart + 9; // Length of '"error":"'
            final end = responseBody.indexOf('"', start);
            if (end != -1) {
              errorMessage = responseBody.substring(start, end);
            }
          }
        }
      } catch (e) {
        // Keep default error message if parsing fails
        print('Error parsing response: $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
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

  @override
  void dispose() {
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _medicalInfoController.dispose();
    super.dispose();
  }
}
