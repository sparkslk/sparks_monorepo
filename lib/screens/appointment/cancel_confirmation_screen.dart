import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';
import '../../services/api_service.dart';

class CancelConfirmationScreen extends StatefulWidget {
  const CancelConfirmationScreen({super.key});

  @override
  State<CancelConfirmationScreen> createState() => _CancelConfirmationScreenState();
}

class _CancelConfirmationScreenState extends State<CancelConfirmationScreen> {
  Map<String, dynamic>? sessionData;
  bool isProcessing = false;
  bool showResult = false;
  Map<String, dynamic>? cancellationResult;

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

  Future<void> _confirmCancellation() async {
    if (sessionData == null || sessionData!['id'] == null) {
      _showErrorDialog('Invalid session data');
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final result = await ApiService.cancelSession(
        sessionId: sessionData!['id'],
        cancellationReason: 'Cancelled by patient via mobile app',
      );

      if (result['success']) {
        setState(() {
          showResult = true;
          cancellationResult = result['cancellation'];
          isProcessing = false;
        });
      } else {
        setState(() {
          isProcessing = false;
        });
        _showErrorDialog(result['message'] ?? 'Failed to cancel session');
      }
    } catch (e) {
      setState(() {
        isProcessing = false;
      });
      _showErrorDialog('An error occurred: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Cancellation Failed',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF8159A8),
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _returnToAppointments() {
    // Pop all screens until we reach appointments page
    Navigator.popUntil(context, (route) => route.settings.name == '/appointments');
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
      appBar: const TherapyAppBar(
        title: 'Confirm Cancellation',
        showBackButton: true,
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
      body: showResult ? _buildResultView() : _buildConfirmationView(),
    );
  }

  Widget _buildConfirmationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                size: 48,
                color: Colors.red.shade600,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          const Center(
            child: Text(
              'Are you sure?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: Color(0xFF2D1B4E),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Description
          Center(
            child: Text(
              'You are about to cancel the following session:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: Colors.grey[600],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Session Details Card
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
                _buildInfoRow('Therapist', sessionData!['therapist'] ?? 'N/A'),
                const SizedBox(height: 12),
                _buildInfoRow('Date', _formatDate(sessionData!['scheduledAt'])),
                const SizedBox(height: 12),
                _buildInfoRow('Time', _formatTime(sessionData!['scheduledAt'])),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Refund Information
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blue.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Refund Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getRefundMessage(),
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    color: Colors.blue.shade800,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Warning Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.shade200,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This action cannot be undone. Once cancelled, you will need to book a new session.',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Inter',
                      color: Colors.red.shade900,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing ? null : () => Navigator.pop(context),
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
                  onPressed: isProcessing ? null : _confirmCancellation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Yes, Cancel',
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
    );
  }

  Widget _buildResultView() {
    final refundStatus = cancellationResult?['refundStatus'] ?? 'NO_REFUND';
    final refundAmount = cancellationResult?['refundAmount']?.toDouble() ?? 0.0;
    final cancellationFee = cancellationResult?['cancellationFee']?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Success Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.green.shade600,
            ),
          ),

          const SizedBox(height: 24),

          // Success Message
          const Text(
            'Session Cancelled',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: Color(0xFF2D1B4E),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Your therapy session has been successfully cancelled.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 32),

          // Refund Details Card
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
                  'Cancellation Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                    color: Color(0xFF8159A8),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Therapist', cancellationResult?['therapistName'] ?? 'N/A'),
                const SizedBox(height: 12),
                _buildInfoRow('Cancelled At', _formatDateTime(cancellationResult?['cancelledAt'])),
                const SizedBox(height: 12),
                _buildInfoRow('Refund Status', _getRefundStatusText(refundStatus)),
                if (refundAmount > 0) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow('Refund Amount', 'Rs. ${refundAmount.toStringAsFixed(2)}'),
                ],
                if (cancellationFee > 0) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow('Cancellation Fee', 'Rs. ${cancellationFee.toStringAsFixed(2)}'),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Refund Processing Info
          if (refundAmount > 0) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.schedule, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your refund of Rs. ${refundAmount.toStringAsFixed(2)} will be processed within 5-7 business days and credited to your original payment method.',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Inter',
                        color: Colors.blue.shade900,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Return Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _returnToAppointments,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8159A8),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Return to Appointments',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
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

  String _getRefundMessage() {
    if (sessionData == null || sessionData!['scheduledAt'] == null) {
      return 'Refund amount will be calculated based on our cancellation policy.';
    }

    try {
      DateTime scheduledAt;
      final scheduledAtValue = sessionData!['scheduledAt'];
      if (scheduledAtValue is DateTime) {
        scheduledAt = scheduledAtValue;
      } else if (scheduledAtValue is String) {
        scheduledAt = DateTime.parse(scheduledAtValue);
      } else {
        return 'Refund amount will be calculated based on our cancellation policy.';
      }

      final now = DateTime.now();
      final daysUntil = scheduledAt.difference(now).inDays;

      if (daysUntil >= 5) {
        return 'Since you are cancelling 5 or more days in advance, you will receive a full refund.';
      } else if (daysUntil >= 1) {
        return 'Since you are cancelling less than 5 days in advance, a cancellation fee of Rs. 30 will be deducted from your refund.';
      } else {
        return 'Since you are cancelling within 24 hours of the scheduled session, no refund will be issued according to our policy.';
      }
    } catch (e) {
      return 'Refund amount will be calculated based on our cancellation policy.';
    }
  }

  String _getRefundStatusText(String status) {
    switch (status) {
      case 'FULL_REFUND':
        return 'Full Refund';
      case 'PARTIAL_REFUND':
        return 'Partial Refund';
      case 'NO_REFUND':
        return 'No Refund';
      default:
        return status;
    }
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

  String _formatDateTime(dynamic dateTimeValue) {
    if (dateTimeValue == null) return 'N/A';
    try {
      return '${_formatDate(dateTimeValue)} at ${_formatTime(dateTimeValue)}';
    } catch (e) {
      return dateTimeValue.toString();
    }
  }
}
