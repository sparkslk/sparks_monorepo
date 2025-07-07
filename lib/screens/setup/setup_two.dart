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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Let's Set Up Your Profile",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff8159a8),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Help us personalize your experience.\nWe'll guide you through this step by step - no rush!",
                  style: TextStyle(fontSize: 15, color: Colors.black54),
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
                const SizedBox(height: 28),
                const Text(
                  'Emergency Contact Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff8159a8),
                    fontSize: 16,
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
                        'Primary Emergency Contact',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _primaryNameController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Relationship',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            child: Text('Parent'),
                            value: 'parent',
                          ),
                          DropdownMenuItem(
                            child: Text('Sibling'),
                            value: 'sibling',
                          ),
                          DropdownMenuItem(
                            child: Text('Spouse'),
                            value: 'spouse',
                          ),
                          DropdownMenuItem(
                            child: Text('Friend'),
                            value: 'friend',
                          ),
                          DropdownMenuItem(
                            child: Text('Other'),
                            value: 'other',
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _primaryPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Emergency Phone Number',
                          hintText: '+1 (555) 123-4567',
                          border: OutlineInputBorder(),
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
                          fontWeight: FontWeight.bold,
                          color: Color(0xff8159a8),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _secondaryNameController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Name (Optional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Relationship (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            child: Text('Parent'),
                            value: 'parent',
                          ),
                          DropdownMenuItem(
                            child: Text('Sibling'),
                            value: 'sibling',
                          ),
                          DropdownMenuItem(
                            child: Text('Spouse'),
                            value: 'spouse',
                          ),
                          DropdownMenuItem(
                            child: Text('Friend'),
                            value: 'friend',
                          ),
                          DropdownMenuItem(
                            child: Text('Other'),
                            value: 'other',
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _secondaryPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Emergency Phone Number (Optional)',
                          hintText: '+1 (555) 123-4567',
                          border: OutlineInputBorder(),
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
                      child: const Text('Previous'),
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
