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
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff8159a8),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Help us personalize your experience.\nWe'll guide you through this step by step - no rush!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black),
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
                    fontWeight: FontWeight.bold,
                    color: Color(0xff8159a8),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Just a few essential details to get started.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    hintText: '+94 (555) 123-4567',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'dd/mm/yyyy',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(child: Text('Male'), value: 'male'),
                    DropdownMenuItem(child: Text('Female'), value: 'female'),
                    DropdownMenuItem(child: Text('Other'), value: 'other'),
                  ],
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    hintText: 'Enter your full address',
                    border: OutlineInputBorder(),
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
                      child: const Text('Go Back'),
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
                      child: const Text('Next'),
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
