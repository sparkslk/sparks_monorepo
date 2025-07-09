import 'package:flutter/material.dart';

class ConfirmTherapistPage extends StatefulWidget {
  @override
  _ConfirmTherapistPageState createState() => _ConfirmTherapistPageState();
}

class _ConfirmTherapistPageState extends State<ConfirmTherapistPage> {
  final Color primaryPurple = Color(0xff8159a8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Confirm Appointment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Therapist Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Therapist Photo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      image: DecorationImage(
                        image: AssetImage('assets/therapist_photo.jpg'), // Replace with actual image
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: primaryPurple.withOpacity(0.3),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: primaryPurple,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Therapist Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. Sarah Johnson',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Clinical Psychologist',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(
                              '4.9 (127 reviews)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Appointment Details
            Text(
              'Appointment Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 16),

            // Date & Time
            _buildDetailItem(
              icon: Icons.calendar_today,
              title: 'Date & Time',
              subtitle: 'Monday, July 15, 2025\n2:00 PM - 3:00 PM',
            ),

            SizedBox(height: 16),

            // Session Type
            _buildDetailItem(
              icon: Icons.video_call,
              title: 'Session Type',
              subtitle: 'Video Call',
            ),

            SizedBox(height: 16),

            // Duration
            _buildDetailItem(
              icon: Icons.access_time,
              title: 'Duration',
              subtitle: '60 minutes',
            ),

            SizedBox(height: 16),

            // Fee
            _buildDetailItem(
              icon: Icons.payment,
              title: 'Session Fee',
              subtitle: '\$120.00',
            ),

            SizedBox(height: 32),

            // Notes Section
            Text(
              'Additional Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                'First session - discussing anxiety management techniques',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ),

            SizedBox(height: 32),

            // Confirmation Message
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: primaryPurple.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primaryPurple,
                    size: 24,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You will receive a confirmation email and video call link 30 minutes before your appointment.',
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),

      // Bottom Action Buttons
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Confirm Appointment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 12),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryPurple,
                  side: BorderSide(color: primaryPurple),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: primaryPurple,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: primaryPurple,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Appointment Confirmed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            'Your appointment with Dr. Sarah Johnson has been confirmed for Monday, July 15, 2025 at 2:00 PM.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Done'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Main app to run the page
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Therapist Appointment',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Roboto',
      ),
      home: ConfirmTherapistPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}