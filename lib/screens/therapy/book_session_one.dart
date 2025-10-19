import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import '../../widgets/therapy_appbar.dart';
import '../../services/api_service.dart';
import '../../services/payment_service.dart';
import 'package:intl/intl.dart';

class BookSessionOnePage extends StatefulWidget {
  @override
  _BookSessionOnePageState createState() => _BookSessionOnePageState();
}

class _BookSessionOnePageState extends State<BookSessionOnePage> {
  final Color primaryPurple = Color(0xff8159a8);
  int selectedDateIndex = 0;
  String? selectedTimeSlot;
  bool showCalendar = false;
  DateTime selectedDate = DateTime.now();

  // API data
  String? therapistId; // Store therapistId from navigation
  dynamic therapistData;
  List<dynamic> availableSlots = [];
  bool isLoadingTherapist = true;
  bool isLoadingSlots = false;
  bool isBooking = false;
  String errorMessage = '';

  // Generated dates list
  List<DateTime> dates = [];

  @override
  void initState() {
    super.initState();
    _generateDates();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get therapistId from navigation arguments
    if (therapistId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        therapistId = args;
        _fetchTherapistData();
      }
    }
  }

  void _generateDates() {
    dates.clear();
    for (int i = 0; i < 7; i++) {
      dates.add(DateTime.now().add(Duration(days: i)));
    }
    selectedDate = dates[0];
  }

  Future<void> _fetchTherapistData() async {
    if (therapistId == null) {
      setState(() {
        errorMessage = 'No therapist selected. Please select a therapist first.';
        isLoadingTherapist = false;
      });
      return;
    }

    setState(() {
      isLoadingTherapist = true;
      errorMessage = '';
    });

    try {
      final therapistResult = await ApiService.getTherapistById(therapistId!);

      if (therapistResult['success']) {
        setState(() {
          therapistData = therapistResult['therapist'];
          isLoadingTherapist = false;
        });

        // Fetch slots for the selected date
        _fetchAvailableSlots();
      } else {
        setState(() {
          errorMessage = therapistResult['message'] ?? 'Failed to load therapist data';
          isLoadingTherapist = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading therapist data: $e';
        isLoadingTherapist = false;
      });
    }
  }

  Future<void> _fetchAvailableSlots() async {
    if (therapistId == null) {
      setState(() {
        availableSlots = [];
        errorMessage = 'No therapist selected';
        isLoadingSlots = false;
      });
      return;
    }

    setState(() {
      isLoadingSlots = true;
      errorMessage = '';
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final result = await ApiService.getAvailableSlots(
        dateStr,
        therapistId: therapistId,
      );

      if (result['success']) {
        setState(() {
          availableSlots = result['availableSlots'] ?? [];
          isLoadingSlots = false;
          selectedTimeSlot = null; // Reset selection when date changes
        });
      } else {
        setState(() {
          availableSlots = [];
          errorMessage = result['message'] ?? 'Failed to load available slots';
          isLoadingSlots = false;
        });
      }
    } catch (e) {
      setState(() {
        availableSlots = [];
        errorMessage = 'Error loading slots: $e';
        isLoadingSlots = false;
      });
    }
  }

  Future<void> _bookSession() async {
    if (selectedTimeSlot == null) {
      _showErrorDialog('Please select a time slot');
      return;
    }

    if (therapistId == null) {
      _showErrorDialog('No therapist selected');
      return;
    }

    // Get the selected slot data to determine if it's free
    final selectedSlotData = availableSlots.firstWhere(
      (slot) => slot['slot'] == selectedTimeSlot,
      orElse: () => null,
    );

    if (selectedSlotData == null) {
      _showErrorDialog('Invalid time slot selected');
      return;
    }

    final cost = selectedSlotData['cost'] ?? 0;
    final isFree = selectedSlotData['isFree'] ?? false;

    setState(() {
      isBooking = true;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

      // If the session is free, book directly without payment
      if (isFree) {
        final bookingResult = await ApiService.bookSession(
          date: dateStr,
          timeSlot: selectedTimeSlot!,
          sessionType: 'Individual',
          therapistId: therapistId,
        );

        setState(() {
          isBooking = false;
        });

        if (bookingResult['success']) {
          _showBookingConfirmation();
        } else {
          _showErrorDialog(bookingResult['message'] ?? 'Failed to book session');
        }
        return;
      }

      // For paid sessions: Get patient profile for payment
      final profileResult = await ApiService.getProfile();
      if (!profileResult['success']) {
        setState(() {
          isBooking = false;
        });
        _showErrorDialog('Unable to retrieve profile information');
        return;
      }

      final profileData = profileResult['profile'];
      final firstName = profileData['firstName'] ?? '';
      final lastName = profileData['lastName'] ?? '';
      final email = profileData['email'] ?? '';
      final phone = profileData['phone'] ?? '';

      if (email.isEmpty || phone.isEmpty) {
        setState(() {
          isBooking = false;
        });
        _showErrorDialog('Please update your profile with email and phone number');
        return;
      }

      setState(() {
        isBooking = false;
      });

      // Navigate to payment review page
      Navigator.pushNamed(
        context,
        '/payment_review',
        arguments: {
          'bookingDetails': {
            'date': dateStr,
            'timeSlot': selectedTimeSlot!,
            'therapistId': therapistId,
            'sessionType': 'Individual',
          },
          'amount': (cost is num) ? cost.toDouble() : double.parse(cost.toString()),
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'therapistName': therapistData?['name'] ?? 'Therapist',
        },
      );

    } catch (e) {
      setState(() {
        isBooking = false;
      });
      _showErrorDialog('Error processing booking: $e');
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
                'Booking Error',
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

  void _showPaymentErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Icon(Icons.payment, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'Payment Failed',
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
            'Your payment could not be processed. Error: $error\n\nNo session has been booked. Please try again.',
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
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Try Again'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDismissedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 48),
              SizedBox(height: 16),
              Text(
                'Payment Cancelled',
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
            'You have cancelled the payment. No session has been booked.\n\nPlease try again when you are ready to complete the payment.',
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
                  Navigator.pushReplacementNamed(context, '/appointments');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('View Appointments'),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoadingTherapist
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty && therapistData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, '/choose_therapist');
                        },
                        child: Text('Select Therapist'),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Therapist',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              letterSpacing: 1.0,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 12),

                          // Therapist Card
                          _buildTherapistCard(),

                          SizedBox(height: 24),

                          // Select Date Section
                          Text(
                            'Select Date',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              letterSpacing: 0.5,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 12),

                          // Date Selection
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: dates.asMap().entries.map((entry) {
                                int index = entry.key;
                                DateTime date = entry.value;
                                bool isSelected = index == selectedDateIndex;

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedDateIndex = index;
                                      selectedDate = date;
                                    });
                                    _fetchAvailableSlots();
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 70,
                                    margin: EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryPurple
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? primaryPurple
                                            : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          DateFormat('EEE').format(date),
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            letterSpacing: 0.5,
                                            fontSize: 12,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          DateFormat('d').format(date),
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            letterSpacing: 0.5,
                                            fontSize: 18,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          SizedBox(height: 24),

                          // Available Time Slots
                          Text(
                            'Available Time Slots ${DateFormat('MMM d').format(selectedDate)}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              letterSpacing: 0.5,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Time Slots Grid
                          isLoadingSlots
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : availableSlots.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: Column(
                                          children: [
                                            Icon(Icons.event_busy,
                                                size: 48, color: Colors.grey),
                                            SizedBox(height: 16),
                                            Text(
                                              'No available slots for this date',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : GridView.count(
                                      crossAxisCount: 2,
                                      childAspectRatio: 3,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      children: availableSlots.map((slotData) {
                                        final slot = slotData['slot'];
                                        final isAvailable =
                                            slotData['isAvailable'] ?? false;
                                        final isFree = slotData['isFree'] ?? false;
                                        final cost = slotData['cost'] ?? 0;
                                        final isSelected = slot == selectedTimeSlot;

                                        return GestureDetector(
                                          onTap: isAvailable
                                              ? () {
                                                  setState(() {
                                                    selectedTimeSlot = slot;
                                                  });
                                                }
                                              : null,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: !isAvailable
                                                  ? Colors.grey[200]
                                                  : isSelected
                                                      ? primaryPurple
                                                      : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: !isAvailable
                                                    ? Colors.grey[400]!
                                                    : isSelected
                                                        ? primaryPurple
                                                        : Colors.grey[300]!,
                                                width: 1,
                                              ),
                                            ),
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    slot,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontFamily: 'Poppins',
                                                      letterSpacing: 0.5,
                                                      color: !isAvailable
                                                          ? Colors.grey[600]
                                                          : isSelected
                                                              ? Colors.white
                                                              : Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  if (isAvailable)
                                                    Text(
                                                      isFree
                                                          ? 'FREE'
                                                          : 'Rs.$cost',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontFamily: 'Poppins',
                                                        color: isFree
                                                            ? (isSelected
                                                                ? Colors.white
                                                                : Colors.green)
                                                            : (isSelected
                                                                ? Colors.white70
                                                                : Colors
                                                                    .grey[600]),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  if (!isAvailable)
                                                    Text(
                                                      'Booked',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontFamily: 'Poppins',
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),

                          SizedBox(height: 24),

                          // Booking Summary
                          _buildBookingSummary(),

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildTherapistCard() {
    final therapistName = therapistData?['name'] ?? 'Therapist';
    final therapistImage = therapistData?['image'];
    final therapistRating = therapistData?['rating'] ?? 0.0;
    final sessionRate = therapistData?['session_rate'] ?? 0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: therapistImage != null && therapistImage.isNotEmpty
                ? NetworkImage(therapistImage)
                : AssetImage('assets/images/logowhite.png') as ImageProvider,
            radius: 25,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Dr. $therapistName',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        letterSpacing: 0.5,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    SizedBox(width: 2),
                    Text(
                      therapistRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        letterSpacing: 0.5,
                        fontSize: 14,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
                SizedBox(height: 8),
                Text(
                  'Rs.$sessionRate per session',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    letterSpacing: 0.5,
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSummary() {
    final therapistName = therapistData?['name'] ?? 'Therapist';
    final selectedSlotData = availableSlots.firstWhere(
      (slot) => slot['slot'] == selectedTimeSlot,
      orElse: () => null,
    );
    final cost = selectedSlotData?['cost'] ?? 0;
    final isFree = selectedSlotData?['isFree'] ?? false;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: TextStyle(
              fontFamily: 'Inter',
              letterSpacing: 0.5,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Session Details',
            style: TextStyle(
              fontFamily: 'Poppins',
              letterSpacing: 0.5,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          _buildDetailRow(
            'Date:',
            '${DateFormat('EEE').format(selectedDate)} ${selectedDate.day}',
          ),
          SizedBox(height: 8),
          _buildDetailRow('Time:', selectedTimeSlot ?? '--'),
          SizedBox(height: 8),
          _buildDetailRow('Therapist:', 'Dr. $therapistName'),
          SizedBox(height: 16),
          _buildDetailRow(
            'Total Cost:',
            selectedTimeSlot == null
                ? '--'
                : (isFree ? 'FREE' : 'Rs.$cost'),
            isPrice: true,
            isFree: isFree,
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (selectedTimeSlot != null && !isBooking)
                  ? _bookSession
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isBooking
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Confirm Booking',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        letterSpacing: 0.5,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isPrice = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            letterSpacing: 0.5,
            fontSize: 14,
            color: isPrice
                ? (isFree ? Colors.green : primaryPurple)
                : Colors.black,
            fontWeight: isPrice ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showBookingConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Icon(Icons.check_circle, color: primaryPurple, size: 48),
              SizedBox(height: 16),
              Text(
                'Booking Confirmed!',
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
            'Your session with Dr. ${therapistData?['name'] ?? 'your therapist'} has been booked for ${DateFormat('EEEE, MMMM d').format(selectedDate)} at $selectedTimeSlot.',
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
                  Navigator.pushReplacementNamed(context, '/appointments');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('View Appointments'),
              ),
            ),
          ],
        );
      },
    );
  }
}
