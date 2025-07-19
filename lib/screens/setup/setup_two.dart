import 'package:flutter/material.dart';

class ProfileSetupStep2 extends StatelessWidget {
  const ProfileSetupStep2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _primaryNameController = TextEditingController();
    final _primaryPhoneController = TextEditingController();
    final _secondaryNameController = TextEditingController();
    final _secondaryPhoneController = TextEditingController();

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
                        'Primary Emergency Contact',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Color(0xff8159a8),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _primaryNameController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Contact Name',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Relationship',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
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
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _primaryPhoneController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Emergency Phone Number',
                          hintText: '+1 (555) 123-4567',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F3FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Secondary Emergency Contact',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          color: Color(0xff8159a8),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _secondaryNameController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Contact Name (Optional)',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                          color: Colors.black,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Relationship (Optional)',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
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
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _secondaryPhoneController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Emergency Phone Number (Optional)',
                          hintText: '+1 (555) 123-4567',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff8159a8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
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
}
