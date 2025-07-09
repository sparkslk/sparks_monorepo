import 'package:flutter/material.dart';

class ProfileSetupStep1 extends StatelessWidget {
  const ProfileSetupStep1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _phoneController = TextEditingController();
    final _dobController = TextEditingController();
    final _addressController = TextEditingController();

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
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Help us personalize your experience.\nWe'll guide you through this step by step -\nno rush!",
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
                    _buildStepCircle(false),
                    _buildStepLine(),
                    _buildStepCircle(false),
                  ],
                ),
                const SizedBox(height: 12),
                // Step indicator text
                const Center(
                  child: Text(
                    'Step 1 of 3',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xff8159a8),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Card container for form
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
                      const SizedBox(height: 8),
                      const Text(
                        'Just a few essential details to get started.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _phoneController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          hintText: '+94 (555) 123-4567',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xffe0e0e0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xffe0e0e0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xff8159a8)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
                      TextField(
                        controller: _dobController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          hintText: 'dd/mm/yyyy',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xffe0e0e0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xffe0e0e0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xff8159a8)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: const Icon(Icons.calendar_today),
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
                        keyboardType: TextInputType.datetime,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          hintText: 'Select gender',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xffe0e0e0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xffe0e0e0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xff8159a8)),
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
                          'Select gender',
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
                              'Male',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                            ),
                            value: 'male',
                          ),
                          DropdownMenuItem(
                            child: Text(
                              'Female',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                            ),
                            value: 'female',
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _addressController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Address',
                          hintText: 'Enter your full address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xffe0e0e0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xffe0e0e0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xff8159a8)),
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
                        maxLines: 3,
                        minLines: 3,
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
                        'Go Back',
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
                        Navigator.pushReplacementNamed(context, '/setup_two');
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