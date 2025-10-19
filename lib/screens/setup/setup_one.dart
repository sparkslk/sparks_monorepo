import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProfileSetupStep1 extends StatefulWidget {
  const ProfileSetupStep1({Key? key}) : super(key: key);

  @override
  State<ProfileSetupStep1> createState() => _ProfileSetupStep1State();
}

class _ProfileSetupStep1State extends State<ProfileSetupStep1> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _dobFocusNode = FocusNode();
  String? _selectedGender;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _preloadEmail();
  }

  Future<void> _preloadEmail() async {
    final user = await ApiService.getCurrentUser();
    if (user != null && user['email'] != null) {
      setState(() {
        _emailController.text = user['email'];
      });
    }
  }

  Future<void> _submitAndNext() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _dobController.text.trim().isEmpty ||
        _selectedGender == null ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^0\d{9}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid Contact Number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final response = await ApiService.authenticatedRequest(
      'POST',
      '/api/mobile/profile',
      body: {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'dateOfBirth': _dobController.text.trim(),
        'gender': _selectedGender?.toUpperCase(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'email': _emailController.text.trim(),
      },
    );
    setState(() => _loading = false);
    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pushReplacementNamed(context, '/setup_two');
    } else {
      String msg = 'Failed to save profile.';
      try {
        final data = response.body.isNotEmpty ? response.body : null;
        if (data != null) msg = data;
      } catch (_) {}
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _dobFocusNode.dispose();
    super.dispose();
  }

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
                      // First Name and Last Name Row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _firstNameController,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                hintText: 'Enter first name',
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
                                hintStyle: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _lastNameController,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                hintText: 'Enter last name',
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
                                hintStyle: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        enabled: false,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                          color: Colors.grey,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'example@email.com',
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
                          suffixIcon: const Icon(Icons.email_outlined),
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
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Phone',
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
                      TextField(
                        controller: _dobController,
                        focusNode: _dobFocusNode,
                        readOnly: true,
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
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(FocusNode());
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().subtract(
                                  const Duration(days: 365 * 18),
                                ),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                _dobController.text =
                                    "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              }
                            },
                          ),
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
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(
                              const Duration(days: 365 * 18),
                            ),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            _dobController.text =
                                "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
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
                            value: 'MALE',
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
                            value: 'FEMALE',
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
                            value: 'OTHER',
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
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
                      onPressed: _loading ? null : _submitAndNext,
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
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
