import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';
import '../../services/payment_service.dart';

class PaymentReviewScreen extends StatefulWidget {
  const PaymentReviewScreen({super.key});

  @override
  State<PaymentReviewScreen> createState() => _PaymentReviewScreenState();
}

class _PaymentReviewScreenState extends State<PaymentReviewScreen> {
  final Color primaryPurple = Color(0xff8159a8);
  bool isProcessing = false;
  Map<String, dynamic>? bookingData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (bookingData == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        setState(() {
          bookingData = args;
        });
      }
    }
  }

  Future<void> _initiatePayment() async {
    if (bookingData == null) return;

    setState(() {
      isProcessing = true;
    });

    try {
      final bookingDetails = bookingData!['bookingDetails'] as Map<String, dynamic>;
      final cost = bookingData!['amount'] as double;
      final firstName = bookingData!['firstName'] as String;
      final lastName = bookingData!['lastName'] as String;
      final email = bookingData!['email'] as String;
      final phone = bookingData!['phone'] as String;
      final therapistName = bookingData!['therapistName'] as String? ?? 'Therapist';

      await PaymentService.initiatePayment(
        context: context,
        bookingDetails: bookingDetails,
        amount: cost,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        onCompleted: (orderId) {
          setState(() {
            isProcessing = false;
          });
          Navigator.pushReplacementNamed(
            context,
            '/payment_confirmation',
            arguments: {'orderId': orderId},
          );
        },
        onError: (error) {
          setState(() {
            isProcessing = false;
          });
          _showErrorDialog(error);
        },
        onDismissed: () {
          setState(() {
            isProcessing = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      _showErrorDialog('Error initiating payment: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'Payment Error',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
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
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('OK'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (bookingData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'No booking data available',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final bookingDetails = bookingData!['bookingDetails'] as Map<String, dynamic>;
    final date = bookingDetails['date'] as String;
    final timeSlot = bookingDetails['timeSlot'] as String;
    final therapistName = bookingData!['therapistName'] as String? ?? 'Therapist';
    final cost = bookingData!['amount'] as double;
    final isFree = cost == 0;

    DateTime parsedDate = DateTime.parse(date);

    return Scaffold(
      appBar: const TherapyAppBar(),
      bottomNavigationBar: MobileNavBar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 3) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/appointments');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/task_dashboard');
          }
        },
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text(
                  'Payment Review',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    letterSpacing: 1.0,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please review your booking details before proceeding to payment',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    letterSpacing: 0.5,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32),

                // Therapist Info Card
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: primaryPurple,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. $therapistName',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                letterSpacing: 0.5,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Cognitive Behavioral Therapy',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                letterSpacing: 0.5,
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Booking Details Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session Details',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          letterSpacing: 0.5,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildDetailRow(
                        Icons.calendar_today,
                        'Date',
                        DateFormat('EEEE, MMMM d, yyyy').format(parsedDate),
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.access_time,
                        'Time',
                        timeSlot,
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.videocam,
                        'Session Type',
                        'Individual Therapy',
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow(
                        Icons.schedule,
                        'Duration',
                        '45 minutes',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24),

                // Payment Summary Card
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryPurple.withOpacity(0.1),
                        primaryPurple.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryPurple.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Summary',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          letterSpacing: 0.5,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Session Fee',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              letterSpacing: 0.5,
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            isFree ? 'FREE' : 'Rs.${cost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              letterSpacing: 0.5,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Divider(color: primaryPurple.withOpacity(0.3)),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              letterSpacing: 0.5,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            isFree ? 'FREE' : 'Rs.${cost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              letterSpacing: 0.5,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: isFree ? Colors.green : primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Proceed to Payment Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _initiatePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: primaryPurple.withOpacity(0.5),
                    ),
                    child: isProcessing
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment, size: 24),
                              SizedBox(width: 12),
                              Text(
                                isFree ? 'Confirm Booking' : 'Proceed to Payment',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  letterSpacing: 0.5,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                SizedBox(height: 12),

                // Back Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: isProcessing
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        letterSpacing: 0.5,
                        fontSize: 16,
                        color: primaryPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
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
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
