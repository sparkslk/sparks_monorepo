import 'package:flutter/material.dart';
import '../../services/payment_service.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({super.key});

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  bool isLoading = true;
  bool verificationFailed = false;
  Map<String, dynamic>? paymentData;
  String? errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final orderId = args['orderId'] as String?;
      if (orderId != null && isLoading) {
        _verifyPayment(orderId);
      }
    } else {
      setState(() {
        isLoading = false;
        verificationFailed = true;
        errorMessage = 'No order ID provided';
      });
    }
  }

  Future<void> _verifyPayment(String orderId) async {
    try {
      // Wait a bit for PayHere notification to arrive
      await Future.delayed(const Duration(seconds: 2));

      final result = await PaymentService.verifyPayment(orderId);

      if (result['success'] == true) {
        final status = result['payment']['status'];

        // If payment is completed, create the booking
        if (status == 'COMPLETED') {
          final bookingResult = await PaymentService.completeBooking(orderId);

          if (bookingResult['success']) {
            // Merge booking data with payment data
            final paymentData = result['payment'];
            paymentData['session'] = bookingResult['session'];

            setState(() {
              this.paymentData = paymentData;
              isLoading = false;
              verificationFailed = false;
            });
          } else {
            // Payment succeeded but booking failed
            setState(() {
              isLoading = false;
              verificationFailed = true;
              errorMessage = bookingResult['message'] ?? 'Failed to complete booking after payment. Please contact support with your order ID.';
            });
          }
        } else {
          // Payment not completed (pending, failed, etc.)
          setState(() {
            paymentData = result['payment'];
            isLoading = false;
            verificationFailed = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
          verificationFailed = true;
          errorMessage =
              result['message'] ?? 'Failed to verify payment status';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        verificationFailed = true;
        errorMessage = 'Error verifying payment: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xff8159a8),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Verifying payment...',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      letterSpacing: 0.5,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : verificationFailed
              ? _buildErrorView()
              : _buildSuccessView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Verification Failed',
              style: TextStyle(
                fontFamily: 'Inter',
                letterSpacing: 1.0,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage ?? 'Unable to verify payment status',
              style: const TextStyle(
                fontFamily: 'Poppins',
                letterSpacing: 0.5,
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/appointments',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8159a8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go to Appointments',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    letterSpacing: 0.5,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    if (paymentData == null) return const SizedBox();

    final status = paymentData!['status'] ?? 'UNKNOWN';
    final isSuccess = status == 'COMPLETED';
    final amount = paymentData!['amount'] ?? '0.00';
    final currency = paymentData!['currency'] ?? 'LKR';
    final orderId = paymentData!['orderId'] ?? '';
    final paymentId = paymentData!['paymentId'];
    final session = paymentData!['session'];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isSuccess
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PaymentService.getPaymentStatusIcon(status),
                size: 60,
                color: PaymentService.getPaymentStatusColor(status),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              PaymentService.getPaymentStatusText(status),
              style: const TextStyle(
                fontFamily: 'Inter',
                letterSpacing: 1.0,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$currency $amount',
              style: const TextStyle(
                fontFamily: 'Inter',
                letterSpacing: 1.0,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xff8159a8),
              ),
            ),
            const SizedBox(height: 32),
            _buildDetailCard(orderId, paymentId, session),
            const SizedBox(height: 32),
            if (isSuccess) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your therapy session has been confirmed. You will receive a notification closer to your appointment time.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          letterSpacing: 0.5,
                          fontSize: 14,
                          color: Colors.green[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/appointments',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff8159a8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View My Appointments',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    letterSpacing: 0.5,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/therapy_dashboard',
                  (route) => false,
                );
              },
              child: const Text(
                'Back to Dashboard',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                  fontSize: 16,
                  color: Color(0xff8159a8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String orderId, String? paymentId, dynamic session) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(
              fontFamily: 'Inter',
              letterSpacing: 1.0,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Order ID', orderId),
          if (paymentId != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow('Payment ID', paymentId),
          ],
          if (session != null) ...[
            const Divider(height: 24),
            const Text(
              'Session Details',
              style: TextStyle(
                fontFamily: 'Inter',
                letterSpacing: 1.0,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Therapist', session['therapist']?['name'] ?? 'N/A'),
            const SizedBox(height: 12),
            _buildDetailRow('Date', _formatDate(session['scheduledAt'])),
            const SizedBox(height: 12),
            _buildDetailRow('Duration', '${session['duration']} minutes'),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
