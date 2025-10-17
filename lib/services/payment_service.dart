import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import 'api_service.dart';

class PaymentService {
  /// Initiates payment for a therapy session booking
  /// Returns the orderId if successful, null otherwise
  static Future<String?> initiatePayment({
    required BuildContext context,
    required Map<String, dynamic> bookingDetails,
    required double amount,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    String? address,
    String? city,
    required Function(String orderId) onCompleted,
    required Function(String error) onError,
    required Function() onDismissed,
  }) async {
    try {
      // Step 1: Call backend to initiate payment and get PayHere details
      final response = await ApiService.authenticatedRequest(
        'POST',
        '/api/mobile/payment/initiate',
        body: {
          'bookingDetails': bookingDetails,
          'amount': amount.toString(),
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'address': address ?? '',
          'city': city ?? '',
        },
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        onError(error['error'] ?? 'Failed to initiate payment');
        return null;
      }

      final paymentData = jsonDecode(response.body);
      final orderId = paymentData['orderId'];

      print('DEBUG: Payment data received from backend:');
      print('  orderId: $orderId');
      print('  merchantId: ${paymentData['merchantId']}');
      print('  amount: ${paymentData['amount']}');
      print('  currency: ${paymentData['currency']}');
      print('  notifyUrl: ${paymentData['notifyUrl']}');

      // Step 2: Configure PayHere SDK
      Map<String, dynamic> paymentObject = {
        "sandbox": true, // Set to false for production
        "merchant_id": paymentData['merchantId'],
        "merchant_secret": paymentData['merchantSecret'],
        "notify_url": paymentData['notifyUrl'],
        "order_id": orderId,
        "items": paymentData['items'],
        "amount": paymentData['amount'],
        "currency": paymentData['currency'],
        "first_name": paymentData['customerFirstName'],
        "last_name": paymentData['customerLastName'],
        "email": paymentData['customerEmail'],
        "phone": paymentData['customerPhone'],
        "address": paymentData['customerAddress'],
        "city": paymentData['customerCity'],
        "country": "Sri Lanka",
      };

      print('DEBUG: PayHere payment object: $paymentObject');

      // Step 3: Start payment with PayHere
      PayHere.startPayment(
        paymentObject,
        (paymentId) {
          // Payment completed successfully
          print("Payment completed. PaymentId: $paymentId");
          onCompleted(orderId);
        },
        (error) {
          // Payment failed
          print("Payment Failed. Error: $error");
          onError(error);
        },
        () {
          // Payment dismissed
          print("Payment dismissed");
          onDismissed();
        },
      );

      return orderId;

    } catch (e) {
      print('Payment initiation error: $e');
      onError('Failed to start payment: $e');
      return null;
    }
  }

  /// Verifies payment status by orderId
  static Future<Map<String, dynamic>> verifyPayment(String orderId) async {
    try {
      final response = await ApiService.authenticatedRequest(
        'GET',
        '/api/mobile/payment/verify?orderId=$orderId',
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'payment': data,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to verify payment',
        };
      }
    } catch (e) {
      print('Payment verification error: $e');
      return {
        'success': false,
        'message': 'Failed to verify payment: $e',
      };
    }
  }

  /// Verifies payment status by sessionId
  static Future<Map<String, dynamic>> verifyPaymentBySession(
      String sessionId) async {
    try {
      final response = await ApiService.authenticatedRequest(
        'POST',
        '/api/mobile/payment/verify',
        body: {'sessionId': sessionId},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'payment': data,
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to verify payment',
        };
      }
    } catch (e) {
      print('Payment verification error: $e');
      return {
        'success': false,
        'message': 'Failed to verify payment: $e',
      };
    }
  }

  /// Gets payment status as a human-readable string
  static String getPaymentStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return 'Payment Successful';
      case 'PENDING':
        return 'Payment Pending';
      case 'FAILED':
        return 'Payment Failed';
      case 'CANCELLED':
        return 'Payment Cancelled';
      case 'CHARGEDBACK':
        return 'Payment Chargedback';
      default:
        return 'Unknown Status';
    }
  }

  /// Gets payment status color
  static Color getPaymentStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'FAILED':
      case 'CANCELLED':
      case 'CHARGEDBACK':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Gets payment status icon
  static IconData getPaymentStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Icons.check_circle;
      case 'PENDING':
        return Icons.pending;
      case 'FAILED':
      case 'CANCELLED':
        return Icons.cancel;
      case 'CHARGEDBACK':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  /// Completes booking after successful payment
  static Future<Map<String, dynamic>> completeBooking(String orderId) async {
    try {
      final response = await ApiService.authenticatedRequest(
        'POST',
        '/api/mobile/payment/complete-booking',
        body: {'orderId': orderId},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'session': data['session'],
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['error'] ?? 'Failed to complete booking',
        };
      }
    } catch (e) {
      print('Complete booking error: $e');
      return {
        'success': false,
        'message': 'Failed to complete booking: $e',
      };
    }
  }
}
