import 'package:flutter/material.dart';

class ProfileSetupStep1 extends StatelessWidget {
  const ProfileSetupStep1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _phoneController = TextEditingController();
    final _dobController = TextEditingController();
    final _addressController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
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
                    textAlign: TextAlign.left,
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
                    _buildStepCircle(false),
                    _buildStepLine(),
                    _buildStepCircle(false),
                  ],
                ),
                const SizedBox(height: 28),
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
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: '+94 (71) 123-4567',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14, letterSpacing: 1.0,),
                    hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14, letterSpacing: 1.0,),
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
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'dd/mm/yyyy',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                    labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14, letterSpacing: 1.0,),
                    hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14, letterSpacing: 1.0,),
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
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14, letterSpacing: 1.0,),
                  ),
                  items: const [
                    DropdownMenuItem(
                      child: Text(
                        'Male',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 16, letterSpacing: 1.0,),
                      ),
                      value: 'male',
                    ),
                    DropdownMenuItem(
                      child: Text(
                        'Female',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 16, letterSpacing: 1.0,),
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
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter your full address',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14, letterSpacing: 1.0,),
                    hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14, letterSpacing: 1.0,),
                  ),
                  maxLines: 2,
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
                        'Go Back',
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
