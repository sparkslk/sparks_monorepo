import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';

class CancelAppointmentScreen extends StatefulWidget {
  const CancelAppointmentScreen({super.key});

  @override
  State<CancelAppointmentScreen> createState() => _CancelAppointmentScreenState();
}

class _CancelAppointmentScreenState extends State<CancelAppointmentScreen> {
  Map<String, dynamic>? sessionData;
  bool hasAgreed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (sessionData == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map<String, dynamic>) {
        setState(() {
          sessionData = args;
        });
      }
    }
  }

  void _handleAgree() {
    if (hasAgreed) {
      // Navigate to cancellation confirmation/processing
      Navigator.pushNamed(
        context,
        '/cancel_confirmation',
        arguments: sessionData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sessionData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cancel Appointment',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: MobileNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/choose_therapist');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/task_dashboard');
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Information Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF8159A8).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Session Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Color(0xFF8159A8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Therapist', sessionData!['therapist'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Date', _formatDate(sessionData!['scheduledAt'])),
                  const SizedBox(height: 8),
                  _buildInfoRow('Time', _formatTime(sessionData!['scheduledAt'])),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Cancellation Policy Title
            const Text(
              'Cancellation Policy',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: Color(0xFF2D1B4E),
              ),
            ),

            const SizedBox(height: 16),

            // Policy Content
            _buildPolicySection(
              'Cancellation Rules',
              [
                'Sessions cancelled 5 or more days in advance will receive a full refund.',
                'Sessions cancelled less than 5 days in advance will be charged a cancellation fee of Rs. 30.',
                'Sessions cancelled within 24 hours of the scheduled time are non-refundable.',
                'Emergency cancellations may be reviewed on a case-by-case basis.',
              ],
            ),

            const SizedBox(height: 24),

            _buildPolicySection(
              'Money Transfer Policy',
              [
                'Refunds will be processed within 5-7 business days.',
                'Refunds will be credited to the original payment method used for booking.',
                'Cancellation fees, if applicable, will be deducted from the refund amount.',
                'Bank processing fees may apply depending on your financial institution.',
                'For payment disputes, please contact our support team within 14 days.',
              ],
            ),

            const SizedBox(height: 24),

            _buildPolicySection(
              'Important Notes',
              [
                'Once you agree and proceed with cancellation, the action cannot be undone.',
                'Your therapist will be notified immediately of the cancellation.',
                'You can book a new session at any time after cancellation.',
                'Frequent cancellations may affect your ability to book future sessions.',
              ],
            ),

            const SizedBox(height: 32),

            // Agreement Checkbox
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: hasAgreed,
                    onChanged: (value) {
                      setState(() {
                        hasAgreed = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF8159A8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, left: 8),
                      child: Text(
                        'I have read and agree to the cancellation policy and money transfer policy stated above.',
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF8159A8),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        color: Color(0xFF8159A8),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasAgreed ? _handleAgree : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8159A8),
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'I Agree',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              color: Color(0xFF2D1B4E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPolicySection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Color(0xFF2D1B4E),
          ),
        ),
        const SizedBox(height: 12),
        ...points.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8159A8),
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      color: Colors.grey[700],
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatDate(dynamic dateTimeValue) {
    if (dateTimeValue == null) return 'N/A';
    try {
      DateTime dateTime;
      if (dateTimeValue is DateTime) {
        dateTime = dateTimeValue;
      } else if (dateTimeValue is String) {
        dateTime = DateTime.parse(dateTimeValue);
      } else {
        return 'N/A';
      }
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return dateTimeValue.toString();
    }
  }

  String _formatTime(dynamic dateTimeValue) {
    if (dateTimeValue == null) return 'N/A';
    try {
      DateTime dateTime;
      if (dateTimeValue is DateTime) {
        dateTime = dateTimeValue;
      } else if (dateTimeValue is String) {
        dateTime = DateTime.parse(dateTimeValue);
      } else {
        return 'N/A';
      }
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } catch (e) {
      return dateTimeValue.toString();
    }
  }
}
