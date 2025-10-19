import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';
import '../../services/api_service.dart';

class RescheduleSessionPage extends StatefulWidget {
  const RescheduleSessionPage({Key? key}) : super(key: key);

  @override
  State<RescheduleSessionPage> createState() => _RescheduleSessionPageState();
}

class _RescheduleSessionPageState extends State<RescheduleSessionPage> {
  DateTime selectedDate = DateTime.now();
  String? selectedTimeSlot;
  DateTime currentMonth = DateTime.now();
  final DateTime today = DateTime.now();

  // Session data
  Map<String, dynamic>? sessionData;
  String? sessionId;
  String? therapistId;
  String? therapistName;
  DateTime? currentSessionDate;

  // State management
  bool isLoadingFee = true;
  bool isLoadingSlots = false;
  bool isProcessing = false;
  double rescheduleFee = 0;
  bool requiresPayment = false;
  int? daysUntilSession;

  // Available slots
  List<Map<String, dynamic>> availableSlots = [];
  String? errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (sessionData == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        setState(() {
          sessionData = args;
          sessionId = args['id'];
          therapistId = args['therapistId'];
          therapistName = args['therapist']?.toString().replaceAll('Dr. ', '') ?? 'Therapist';
          currentSessionDate = args['scheduledAt'] as DateTime?;
        });
        _loadRescheduleFee();
      }
    }
  }

  Future<void> _loadRescheduleFee() async {
    if (sessionId == null) return;

    setState(() {
      isLoadingFee = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getRescheduleFee(sessionId!);

      if (result['success']) {
        setState(() {
          rescheduleFee = (result['fee'] ?? 0).toDouble();
          requiresPayment = result['requiresPayment'] ?? false;
          daysUntilSession = result['daysUntilSession'];
          isLoadingFee = false;
        });
      } else {
        setState(() {
          errorMessage = result['message'];
          isLoadingFee = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading reschedule info: $e';
        isLoadingFee = false;
      });
    }
  }

  Future<void> _loadAvailableSlots(String date) async {
    // For now, we need to get therapistId from the session
    // In a real implementation, this should be included in the session data
    // passed from the appointments screen

    setState(() {
      isLoadingSlots = true;
      availableSlots = [];
    });

    try {
      // We need therapistId - for now using a placeholder
      // In production, update the sessions API to include therapistId
      final result = await ApiService.getAvailableSlots(date, therapistId: therapistId);

      if (result['success']) {
        setState(() {
          availableSlots = (result['availableSlots'] as List)
              .map((slot) => slot as Map<String, dynamic>)
              .toList();
          isLoadingSlots = false;
        });
      } else {
        setState(() {
          availableSlots = [];
          isLoadingSlots = false;
        });
      }
    } catch (e) {
      setState(() {
        availableSlots = [];
        isLoadingSlots = false;
      });
    }
  }

  Future<void> _confirmReschedule() async {
    if (selectedTimeSlot == null || sessionId == null) return;

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    // If payment is required, initiate payment first
    if (requiresPayment && rescheduleFee > 0) {
      await _initiateReschedulePayment(formattedDate, selectedTimeSlot!);
    } else {
      // Free reschedule
      await _submitReschedule(formattedDate, selectedTimeSlot!, null);
    }
  }

  Future<void> _initiateReschedulePayment(String newDate, String newTimeSlot) async {
    setState(() {
      isProcessing = true;
    });

    try {
      // Get user profile for payment details
      final profileResult = await ApiService.getProfile();

      if (!profileResult['success']) {
        _showErrorDialog('Failed to load profile information');
        setState(() => isProcessing = false);
        return;
      }

      final profile = profileResult['profile'];
      final email = profile['email'] ?? '';
      final phone = profile['phone'] ?? '';
      final firstName = profile['firstName'] ?? 'Patient';
      final lastName = profile['lastName'] ?? '';
      final address = profile['address'] ?? '';

      // Initiate reschedule fee payment
      final paymentResult = await ApiService.initiateRescheduleFeePayment(
        sessionId: sessionId!,
        amount: rescheduleFee,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        address: address,
        city: 'Colombo',
      );

      if (!paymentResult['success']) {
        setState(() => isProcessing = false);
        _showErrorDialog(paymentResult['message'] ?? 'Failed to initiate payment');
        return;
      }

      final paymentData = paymentResult['paymentDetails'];
      final orderId = paymentData['orderId'];

      // Configure PayHere payment
      // Note: merchant_secret is NOT sent to mobile for security
      // Instead, we use the hash generated on the backend
      Map<String, dynamic> paymentObject = {
        "sandbox": true,
        "merchant_id": paymentData['merchantId'] ?? '',
        "hash": paymentData['hash'] ?? '',
        "notify_url": paymentData['notifyUrl'] ?? '',
        "order_id": orderId ?? '',
        "items": paymentData['items'] ?? 'Reschedule Fee',
        "amount": paymentData['amount']?.toString() ?? '0.00',
        "currency": paymentData['currency'] ?? 'LKR',
        "first_name": paymentData['customerFirstName'] ?? firstName,
        "last_name": paymentData['customerLastName'] ?? lastName,
        "email": paymentData['customerEmail'] ?? email,
        "phone": paymentData['customerPhone'] ?? phone,
        "address": paymentData['customerAddress'] ?? address,
        "city": paymentData['customerCity'] ?? 'Colombo',
        "country": "Sri Lanka",
      };

      print('DEBUG: Reschedule PayHere payment object: $paymentObject');

      // Open PayHere
      PayHere.startPayment(
        paymentObject,
        (paymentId) async {
          // Payment completed successfully
          print("Reschedule payment completed. PaymentId: $paymentId");
          await _submitReschedule(newDate, newTimeSlot, paymentId);
        },
        (error) {
          // Payment failed
          print("Reschedule payment failed. Error: $error");
          setState(() => isProcessing = false);
          _showErrorDialog('Payment failed: $error');
        },
        () {
          // Payment dismissed
          print("Reschedule payment dismissed");
          setState(() => isProcessing = false);
        },
      );
    } catch (e) {
      setState(() => isProcessing = false);
      _showErrorDialog('Error initiating payment: $e');
    }
  }

  Future<void> _submitReschedule(String newDate, String newTimeSlot, String? paymentId) async {
    setState(() {
      isProcessing = true;
    });

    try {
      final result = await ApiService.rescheduleSession(
        sessionId: sessionId!,
        newDate: newDate,
        newTimeSlot: newTimeSlot,
        rescheduleReason: 'Rescheduled by patient',
        paymentId: paymentId,
      );

      setState(() => isProcessing = false);

      if (result['success']) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session rescheduled successfully!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      } else {
        _showErrorDialog(result['message'] ?? 'Failed to reschedule session');
      }
    } catch (e) {
      setState(() => isProcessing = false);
      _showErrorDialog('Error rescheduling session: $e');
    }
  }

  void _navigateToCancellation() {
    Navigator.pushNamed(
      context,
      '/cancel_appointment',
      arguments: sessionData,
    );
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
                'Error',
                style: TextStyle(
                  fontFamily: 'Poppins',
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
    if (sessionData == null || currentSessionDate == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'No session data available',
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

    return Scaffold(
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const TherapyAppBar(
        title: 'Reschedule Session',
        showBackButton: true,
      ),
      body: isLoadingFee
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff8159a8)),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Session Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xff8159a8),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    sessionData!['avatar'] ?? 'TH',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sessionData!['therapist'] ?? 'Dr. Therapist',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sessionData!['specialization'] ?? 'Therapist',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 12),
                          Text(
                            'Current Session',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: const Color(0xff8159a8)),
                              const SizedBox(width: 8),
                              Text(
                                '${sessionData!['date']} at ${sessionData!['time']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Reschedule Fee Warning
                    if (requiresPayment && rescheduleFee > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rescheduling Fee Required',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange.shade900,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'You are rescheduling within $daysUntilSession day(s). A fee of Rs. ${rescheduleFee.toStringAsFixed(2)} will be charged.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.orange.shade700,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Calendar Section
                    _buildCalendar(),
                    const SizedBox(height: 30),

                    // Time Slots Section
                    if (_isDateSelected() && _isValidFutureDate()) ...[
                      Text(
                        'Available Time Slots',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 16),
                      isLoadingSlots
                          ? const Center(child: CircularProgressIndicator(color: Color(0xff8159a8)))
                          : _buildTimeSlots(),
                      const SizedBox(height: 30),
                    ],

                    // Info message for past dates
                    if (_isDateSelected() && !_isValidFutureDate()) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Please select a future date for rescheduling.',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (selectedTimeSlot != null && _isValidFutureDate() && !isProcessing)
                            ? _confirmReschedule
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff8159a8),
                          disabledBackgroundColor: Colors.grey.shade300,
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
                            : Text(
                                requiresPayment && rescheduleFee > 0
                                    ? 'Pay Rs. ${rescheduleFee.toStringAsFixed(0)} & Reschedule'
                                    : 'Confirm Reschedule',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cancel Appointment Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: isProcessing ? null : _navigateToCancellation,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel Appointment',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  bool _isDateSelected() {
    return selectedDate.year != today.year ||
        selectedDate.month != today.month ||
        selectedDate.day != today.day;
  }

  bool _isValidFutureDate() {
    return selectedDate.isAfter(today.subtract(const Duration(days: 1)));
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
        children: [
          // Calendar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
                  });
                },
              ),
              Text(
                '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Days of Week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                .map(
                  (day) => SizedBox(
                width: 32,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            )
                .toList(),
          ),
          const SizedBox(height: 16),

          // Calendar Grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _buildCalendarGrid() {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final startingWeekday = firstDay.weekday == 7 ? 0 : firstDay.weekday;

    List<Widget> weeks = [];
    List<Widget> currentWeek = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < startingWeekday; i++) {
      currentWeek.add(_buildDayCell('', isCurrentMonth: false));
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(currentMonth.year, currentMonth.month, day);
      final isSelected = selectedDate.year == date.year &&
          selectedDate.month == date.month &&
          selectedDate.day == date.day;
      final isPast = date.isBefore(today);

      currentWeek.add(_buildDayCell(
        day.toString(),
        isSelected: isSelected,
        isPast: isPast,
        date: date,
        isCurrentMonth: true,
      ));

      if (currentWeek.length == 7) {
        weeks.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: currentWeek,
        ));
        currentWeek = [];
      }
    }

    while (currentWeek.length < 7) {
      currentWeek.add(_buildDayCell('', isCurrentMonth: false));
    }

    if (currentWeek.isNotEmpty) {
      weeks.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: currentWeek,
      ));
    }

    return Column(
      children: weeks.map((week) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: week,
      )).toList(),
    );
  }

  Widget _buildDayCell(String day, {
    bool isSelected = false,
    bool isPast = false,
    DateTime? date,
    bool isCurrentMonth = true,
  }) {
    return GestureDetector(
      onTap: day.isNotEmpty && isCurrentMonth
          ? () {
        if (date != null) {
          setState(() {
            selectedDate = date;
            selectedTimeSlot = null;
          });
          // Load available slots for selected date
          if (therapistId != null) {
            final formattedDate = DateFormat('yyyy-MM-dd').format(date);
            _loadAvailableSlots(formattedDate);
          }
        }
      }
          : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff8159a8) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isPast && isCurrentMonth
              ? Border.all(color: Colors.grey.shade300, width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              fontSize: 14,
              color: isSelected
                  ? Colors.white
                  : isPast && isCurrentMonth
                  ? Colors.grey.shade400
                  : day.isEmpty || !isCurrentMonth
                  ? Colors.transparent
                  : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          'No available slots for this date',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: availableSlots.map((slotData) {
        final slot = slotData['slot'] as String;
        final isAvailable = slotData['isAvailable'] as bool;
        final isSelected = selectedTimeSlot == slotData['startTime'];

        return GestureDetector(
          onTap: isAvailable
              ? () {
            setState(() {
              selectedTimeSlot = slotData['startTime'] as String;
            });
          }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: !isAvailable
                  ? Colors.grey.shade200
                  : isSelected
                      ? const Color(0xff8159a8)
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: !isAvailable
                    ? Colors.grey.shade300
                    : isSelected
                        ? const Color(0xff8159a8)
                        : Colors.grey.shade300,
              ),
            ),
            child: Text(
              isAvailable ? slot : '$slot (Booked)',
              style: TextStyle(
                fontSize: 14,
                color: !isAvailable
                    ? Colors.grey.shade500
                    : isSelected
                        ? Colors.white
                        : Colors.black87,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
